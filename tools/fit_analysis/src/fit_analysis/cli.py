"""CLI entrypoint for deterministic MarathonCoach FIT analysis."""

from __future__ import annotations

import argparse
import hashlib
import json
from datetime import datetime, timezone
import os
from pathlib import Path
from typing import Any, Dict

import yaml

from . import __version__
from .adjustment_engine import apply_adjustments
from .baseline_engine import calculate_baseline
from .client_delivery_renderer import build_client_delivery_artifacts
from .code_encoder import encode_c2
from .fit_loader import FitLoaderError, load_fit
from .metric_engine import calculate_metrics
from .narrative_generator import NarrativeGenerationError
from .quality_gate import evaluate_quality
from .race_profile import build_phase_boundaries, resolve_race_profile
from .report_renderer import build_summary_items, render_reports
from .schemas import HearingInput, RunnerProfile, parse_bool, to_plain_dict


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="Deterministic MarathonCoach FIT analysis CLI")
    parser.add_argument("--fit", required=True, help="Path to activity.fit")
    parser.add_argument("--profile", required=True, help="Path to runner_profile.json")
    parser.add_argument("--hearing", required=True, help="Path to hearing.json")
    parser.add_argument("--rules", required=True, help="Path to rules_v1.yaml")
    parser.add_argument("--out", required=True, help="Output directory")
    parser.add_argument(
        "--client-report-mode",
        choices=["template", "ai", "auto"],
        default="template",
        help="Client delivery rendering mode",
    )
    parser.add_argument(
        "--llm-config",
        help="Path to llm_v1.yaml. Defaults to tools/fit_analysis/configs/llm_v1.yaml",
    )
    parser.add_argument("--llm-model", help="Override model name for client AI generation")
    parser.add_argument("--llm-timeout", type=int, help="Override LLM timeout in seconds")
    parser.add_argument(
        "--save-llm-audit",
        help="Whether to write llm_generation_audit.json (true/false). Defaults to llm config",
    )
    parser.add_argument(
        "--generated-at",
        help="ISO8601 timestamp to embed in audit output for reproducible runs",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)

    try:
        runner = RunnerProfile.from_dict(_load_json(args.profile))
        hearing = HearingInput.from_dict(_load_json(args.hearing))
        rules = _load_yaml(args.rules)
        fit_data = load_fit(args.fit)
    except FitLoaderError as exc:
        print(_serialize_error(exc))
        return 2
    except Exception as exc:  # noqa: BLE001
        print(json.dumps({"error": str(exc)}, ensure_ascii=False))
        return 2

    profile_name = resolve_race_profile(runner.race_distance_km, rules)
    phase_boundaries = build_phase_boundaries(runner.race_distance_km, rules)
    quality = evaluate_quality(fit_data, runner.race_distance_km, rules)
    baseline = calculate_baseline(profile_name, runner, rules)
    metrics = calculate_metrics(fit_data, runner, phase_boundaries, quality.metrics)
    adjustments = apply_adjustments(baseline, metrics, hearing, quality.status, rules)
    final_values = adjustments["final_values"]
    custom_code = encode_c2(*(final_values[phase] for phase in ["S1", "S2", "S3", "S4", "S5"]))
    summary_items = build_summary_items(metrics, rules, hearing)

    quality_dict = to_plain_dict(quality)
    quality_dict["race_profile"] = profile_name
    reports = render_reports(
        runner=runner,
        hearing=hearing,
        rule_version=str(rules["version"]),
        quality=quality_dict,
        boundaries=phase_boundaries,
        baseline=baseline.values,
        final_values=final_values,
        deltas=adjustments["total_deltas"],
        applied_rules=[to_plain_dict(record) for record in adjustments["applied_rules"]],
        metrics=metrics,
        custom_code=custom_code,
        summary_items=summary_items,
    )

    generated_at = _resolve_generated_at(args.generated_at)
    llm_config = _load_llm_config(args.llm_config)
    save_llm_audit = _resolve_save_llm_audit(args.save_llm_audit, llm_config)
    analysis_result = {
        "tool_version": __version__,
        "rule_version": str(rules["version"]),
        "generated_at": generated_at,
        "runner_profile": to_plain_dict(runner),
        "hearing": to_plain_dict(hearing),
        "fit_input": {
            "file_name": Path(fit_data.path).name,
            "file_hash": fit_data.file_hash,
            "integrity_ok": fit_data.integrity_ok,
            "messages_summary": fit_data.messages_summary,
        },
        "quality_gate": quality_dict,
        "race_profile": {
            "profile": profile_name,
            "phases": [to_plain_dict(boundary) for boundary in phase_boundaries],
        },
        "baseline": to_plain_dict(baseline),
        "metrics": metrics,
        "adjustments": {
            "reference_only": adjustments["reference_only"],
            "total_deltas": adjustments["total_deltas"],
            "applied_rules": [to_plain_dict(record) for record in adjustments["applied_rules"]],
        },
        "final_cap": final_values,
        "summary_items": summary_items,
        "custom_code": custom_code,
    }

    audit = {
        "tool_version": __version__,
        "generated_at": generated_at,
        "rule_version": str(rules["version"]),
        "input_files": {
            "fit": _file_audit(args.fit, fit_data.file_hash),
            "profile": _file_audit(args.profile),
            "hearing": _file_audit(args.hearing),
            "rules": _file_audit(args.rules),
        },
        "applied_rules": [record.rule_id for record in adjustments["applied_rules"]],
        "quality_status": quality.status,
    }

    out_dir = Path(args.out)
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "analysis_result.json").write_text(_to_json(analysis_result), encoding="utf-8")
    (out_dir / "audit.json").write_text(_to_json(audit), encoding="utf-8")
    (out_dir / "delivery_report.md").write_text(reports.markdown, encoding="utf-8")
    (out_dir / "delivery_report.html").write_text(reports.html, encoding="utf-8")
    (out_dir / "custom_code.txt").write_text(custom_code + "\n", encoding="utf-8")

    try:
        client_delivery = build_client_delivery_artifacts(
            analysis_result=analysis_result,
            llm_config=llm_config,
            mode=args.client_report_mode,
            generated_at=generated_at,
            model_override=args.llm_model,
            timeout_override=args.llm_timeout,
            save_llm_audit=save_llm_audit,
        )
    except NarrativeGenerationError as exc:
        print(json.dumps({"error": str(exc), "code": "client_delivery_generation_failed"}, ensure_ascii=False))
        return 3

    (out_dir / "client_delivery.md").write_text(client_delivery.markdown, encoding="utf-8")
    (out_dir / "client_delivery.html").write_text(client_delivery.html, encoding="utf-8")
    if client_delivery.audit is not None:
        (out_dir / "llm_generation_audit.json").write_text(_to_json(client_delivery.audit), encoding="utf-8")
    return 0


def _resolve_generated_at(value: str | None) -> str:
    if value:
        return value
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat()


def _load_json(path: str) -> Dict[str, Any]:
    return json.loads(Path(path).read_text(encoding="utf-8"))


def _load_yaml(path: str) -> Dict[str, Any]:
    return yaml.safe_load(Path(path).read_text(encoding="utf-8"))


def _load_llm_config(path: str | None) -> Dict[str, Any]:
    if path:
        return _load_yaml(path)
    default_path = Path(__file__).resolve().parents[2] / "configs" / "llm_v1.yaml"
    if default_path.exists():
        return _load_yaml(str(default_path))
    return {
        "provider": "openai",
        "model": os.environ.get("OPENAI_MODEL", "gpt-5"),
        "temperature": 0.2,
        "max_output_tokens": 1800,
        "timeout_sec": 30,
        "save_audit": False,
        "save_raw_response": True,
        "language": "ja",
        "style": {"tone": "一般ランナー向け、短く明快、営業っぽすぎない", "avoid_terms": [], "replacements": {}},
    }


def _resolve_save_llm_audit(value: str | None, llm_config: Dict[str, Any]) -> bool:
    if value is None:
        return bool(llm_config.get("save_audit", False))
    return parse_bool(value)


def _to_json(value: Dict[str, Any]) -> str:
    return json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True) + "\n"


def _file_audit(path: str, file_hash: str | None = None) -> Dict[str, str]:
    resolved = Path(path)
    return {
        "file_name": resolved.name,
        "sha256": file_hash or hashlib.sha256(resolved.read_bytes()).hexdigest(),
    }


def _serialize_error(exc: FitLoaderError) -> str:
    payload = {"error": str(exc), "code": exc.code, "details": exc.details}
    return json.dumps(payload, ensure_ascii=False)


if __name__ == "__main__":
    raise SystemExit(main())
