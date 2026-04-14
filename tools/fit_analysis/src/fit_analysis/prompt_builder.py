"""Build narrative input and prompts for client-facing AI generation."""

from __future__ import annotations

import json
from typing import Any, Dict, List

from .internal_report_renderer import format_duration_jp, format_pace_jp
from .schemas import PHASE_NAMES, PromptBundle, parse_duration_to_seconds

PROMPT_VERSION = "prompt_v1"
SECTION_HEADINGS = [
    "今回の結論",
    "目標",
    "今回のご提案設定",
    "今回の分析で見えたこと",
    "なぜこの設定にしたか",
    "区間ごとの見方",
    "ヒアリング内容の反映",
    "再調整の目安",
    "専用設定コード",
]


def build_narrative_input(
    analysis_result: Dict[str, Any],
    llm_config: Dict[str, Any],
) -> Dict[str, Any]:
    replacements = llm_config.get("style", {}).get("replacements", {})
    boundaries = analysis_result["race_profile"]["phases"]
    metrics = analysis_result["metrics"]
    baseline = analysis_result["baseline"]["values"]
    final_cap = analysis_result["final_cap"]
    deltas = analysis_result["adjustments"]["total_deltas"]

    recommended_setting = {}
    for phase in PHASE_NAMES:
        boundary = next(item for item in boundaries if item["name"] == phase)
        phase_metric = metrics["phases"][phase]
        recommended_setting[phase.lower()] = {
            "phase": phase,
            "label": replacements.get(phase, phase),
            "range": f"{boundary['start_km']:.1f}〜{boundary['end_km']:.1f}km",
            "sample_avg_hr_bpm": phase_metric["avg_hr_bpm"],
            "sample_avg_pace": format_pace_jp(phase_metric["avg_pace_sec_per_km"]),
            "baseline": baseline[phase],
            "final": final_cap[phase],
            "delta": deltas[phase],
        }
    hearing = analysis_result["hearing"]
    summary_lookup = {item["label"]: item["text"] for item in analysis_result["summary_items"]}

    return {
        "race_name": analysis_result["runner_profile"]["goal_race"],
        "goal_time": format_duration_jp(_goal_time_seconds(analysis_result)),
        "goal_pace": format_pace_jp(metrics["goal_pace_sec_per_km"]),
        "profile": analysis_result["race_profile"]["profile"],
        "quality_summary": _quality_summary(analysis_result["quality_gate"]["status"]),
        "recommended_terms": {
            "cap": replacements.get("CAP", "心拍上限"),
            "baseline": replacements.get("baseline", "自動設定"),
            "final_cap": replacements.get("final_cap", "今回のご提案設定"),
        },
        "recommended_setting": recommended_setting,
        "evidence": {
            "goal_pace": format_pace_jp(metrics["goal_pace_sec_per_km"]),
            "pace_25_35": format_pace_jp(metrics["avg_pace_25_35_sec_per_km"]),
            "pace_after_35": format_pace_jp(metrics["avg_pace_35_plus_sec_per_km"]),
            "pace_drop_after_35": f"{metrics['pace_drop_35_plus_sec']:.0f}秒/km",
            "hr_after_35_avg": analysis_result["metrics"]["avg_hr_35_plus_bpm"],
            "hr_rise_late": int(round(metrics["heart_rate_rise_bpm"])) if metrics["heart_rate_rise_bpm"] is not None else None,
        },
        "adjustment_summary": [_summarize_adjustment(record["rule_id"]) for record in analysis_result["adjustments"]["applied_rules"]],
        "seven_points": {
            "start": summary_lookup.get("前半の入り方", ""),
            "mid": summary_lookup.get("中盤の安定度", ""),
            "around_30k": summary_lookup.get("30km前後の崩れ始め", ""),
            "after_35k": summary_lookup.get("35km以降の失速度", ""),
            "hr_trend": summary_lookup.get("心拍の上がり方", ""),
            "finish_room": summary_lookup.get("終盤の粘り余地", ""),
            "next_direction": summary_lookup.get("次回設定方針", ""),
        },
        "hearing": {
            "heat": _heat_label(hearing["heat_impact"]),
            "fueling": _fueling_label(hearing["fueling_actual"]),
            "stomach_issue": "あり" if hearing["stomach_issue"] else "なし",
            "cramp": "あり" if hearing["cramp"] else "なし",
            "condition_note": hearing["condition_note"],
        },
        "limit_factor": hearing["limit_factor"] or "不明",
        "custom_code": analysis_result["custom_code"],
    }


def build_prompt_bundle(narrative_input: Dict[str, Any], llm_config: Dict[str, Any]) -> PromptBundle:
    system_prompt = _build_system_prompt(llm_config)
    user_prompt = _build_user_prompt(narrative_input, llm_config)
    return PromptBundle(version=PROMPT_VERSION, system_prompt=system_prompt, user_prompt=user_prompt)


def _build_system_prompt(llm_config: Dict[str, Any]) -> str:
    style = llm_config.get("style", {})
    avoid_terms = ", ".join(style.get("avoid_terms", []))
    return "\n".join(
        [
            "あなたはマラソン向け個別設定サービスの納品文章を作るライターです。",
            "読者は一般ランナーです。",
            f"文体は {style.get('tone', '一般ランナー向けで短く明快')} としてください。",
            "専門用語を減らし、短く明快に書いてください。",
            "ただし数値は具体的に示してください。",
            "渡された数値は変更しないでください。",
            "渡された Custom Code は変更しないでください。",
            "断定しすぎず、実戦向けに書いてください。",
            "医療判断のような表現はしないでください。",
            "営業色を強くしすぎないでください。",
            "文章の目的は、結論がすぐ分かり、理由も納得できることです。",
            f"避ける内部用語: {avoid_terms}" if avoid_terms else "",
        ]
    ).strip()


def _build_user_prompt(narrative_input: Dict[str, Any], llm_config: Dict[str, Any]) -> str:
    prompt_sections = "\n".join(f"- {heading}" for heading in SECTION_HEADINGS)
    setting_format_lines = "\n".join(
        f"- {item['label']}（{item['range']}）: サンプル平均心拍 {item['sample_avg_hr_bpm']}bpm / "
        f"サンプル平均ペース {item['sample_avg_pace']} / 今回のご提案上限 {item['final']}bpm"
        for item in narrative_input["recommended_setting"].values()
    )
    required_mentions = [
        narrative_input["goal_time"],
        narrative_input["goal_pace"],
        narrative_input["evidence"]["pace_25_35"],
        narrative_input["evidence"]["pace_after_35"],
        narrative_input["evidence"]["pace_drop_after_35"],
        str(narrative_input["evidence"]["hr_after_35_avg"]),
        str(narrative_input["evidence"]["hr_rise_late"]),
        narrative_input["custom_code"],
    ]
    return "\n".join(
        [
            "以下の JSON をもとに、クライアント向け納品文を Markdown で作成してください。",
            "新しい数字を推測しないでください。",
            "与えられた事実だけで書いてください。",
            "数値、差分、Custom Code は変更しないでください。",
            "内部用語は避け、一般ランナー向けに言い換えてください。",
            "各セクション見出しは必ず '# ' で始めてください。",
            "利用者向けの説明では、自動設定や標準値を基準にしないでください。",
            "今回のサンプル FIT で実際に出た区間ごとの平均心拍と平均ペースを基準に説明してください。",
            "「今回の分析で見えたこと」で先に事実を整理し、その結果として「なぜこの設定にしたか」で設定意図につなげてください。",
            "「なぜこの設定にしたか」では、上の分析結果を受けて判断したことが分かる書き方にしてください。",
            "出力に含めるセクションは次のとおりです。",
            prompt_sections,
            "",
            "「今回のご提案設定」セクションでは、次の5行をそのまま含めてください。",
            setting_format_lines,
            "",
            "次の値は本文中に必ずそのまま含めてください。",
            "\n".join(f"- {item}" for item in required_mentions),
            "",
            "JSON:",
            "```json",
            json.dumps(narrative_input, ensure_ascii=False, indent=2, sort_keys=True),
            "```",
        ]
    )


def _quality_summary(status: str) -> str:
    mapping = {
        "usable": "分析に十分使えるデータでした",
        "usable_with_caution": "分析には使えますが、一部は参考値として見ています",
        "not_recommended": "参考にはできますが、今回のログだけで強い調整はしない前提です",
    }
    return mapping.get(status, "分析結果をもとに判断しています")


def _summarize_adjustment(rule_id: str) -> str:
    mapping = {
        "early_restraint": "前半を少し抑える調整",
        "mid_stabilize": "中盤を安定させる調整",
        "late_fade_protection": "終盤の失速を減らす調整",
        "late_reserve_boost": "ラストで少し上げやすくする調整",
        "heat_guard": "暑さを考慮した保守的な調整",
        "fueling_guard": "補給負担を考慮した保守的な調整",
        "stomach_guard": "胃腸状態を考慮した保守的な調整",
        "cramp_guard": "けいれんリスクを考慮した保守的な調整",
    }
    return mapping.get(rule_id, "レース後半を安定させる調整")


def _heat_label(value: str) -> str:
    mapping = {"none": "特になし", "low": "少しあり", "high": "あり", "severe": "強くあり"}
    return mapping.get(value, value)


def _fueling_label(value: str) -> str:
    mapping = {
        "as_planned": "予定通り",
        "late": "少し遅れた",
        "insufficient": "やや不足した",
        "missed": "十分に取れなかった",
    }
    return mapping.get(value, value)


def _goal_time_seconds(analysis_result: Dict[str, Any]) -> int:
    value = analysis_result["runner_profile"]["goal_time"]
    parsed = parse_duration_to_seconds(value)
    if parsed is None:
        raise ValueError(f"Could not parse goal_time: {value}")
    return parsed
