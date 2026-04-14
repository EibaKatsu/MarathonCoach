from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(ROOT / "_vendor"))

from fit_analysis.cli import main
from fit_analysis.fallback_template_renderer import render_fallback_client_markdown
from fit_analysis.narrative_generator import NarrativeGenerationError
from fit_analysis.prompt_builder import build_narrative_input
from fit_analysis.schemas import LLMRequestResult

from .helpers import FIXTURES_DIR, create_sample_fit

import yaml


class ClientDeliveryE2ETests(unittest.TestCase):
    def setUp(self) -> None:
        self.llm_config = yaml.safe_load((ROOT / "configs" / "llm_v1.yaml").read_text(encoding="utf-8"))
        self.analysis_fixture = json.loads((FIXTURES_DIR / "analysis_result.json").read_text(encoding="utf-8"))
        self.narrative_input = build_narrative_input(self.analysis_fixture, self.llm_config)

    def test_template_mode_generates_client_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            out_dir = self._run_cli(tmp_dir, "template")
            self.assertTrue((out_dir / "client_delivery.md").exists())
            text = (out_dir / "client_delivery.md").read_text(encoding="utf-8")
            self.assertIn("## 今回のご提案設定", text)
            self.assertIn("サンプル平均心拍", text)
            self.assertIn("サンプル平均ペース", text)
            self.assertNotIn("## ご提案設定グラフ", text)
            self.assertLess(text.index("## 今回の分析で見えたこと"), text.index("## なぜこの設定にしたか"))
            self.assertTrue((out_dir / "llm_generation_audit.json").exists())

    def test_auto_mode_uses_ai_when_mock_succeeds(self) -> None:
        markdown = render_fallback_client_markdown(self.narrative_input).replace(
            f"# {self.narrative_input['race_name']} 向けご提案設定",
            "# AI生成レポート",
        )
        fake_result = LLMRequestResult(provider="openai", model="gpt-5", markdown=markdown, raw_response={"id": "resp_ok"})
        with tempfile.TemporaryDirectory() as tmp_dir, patch(
            "fit_analysis.client_delivery_renderer.generate_narrative_markdown",
            return_value=fake_result,
        ):
            out_dir = self._run_cli(tmp_dir, "auto")
            self.assertIn("AI生成レポート", (out_dir / "client_delivery.md").read_text(encoding="utf-8"))
            audit = json.loads((out_dir / "llm_generation_audit.json").read_text(encoding="utf-8"))
            self.assertFalse(audit["fallback_used"])

    def test_auto_mode_falls_back_when_mock_fails(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir, patch(
            "fit_analysis.client_delivery_renderer.generate_narrative_markdown",
            side_effect=NarrativeGenerationError("llm failed"),
        ):
            out_dir = self._run_cli(tmp_dir, "auto")
            text = (out_dir / "client_delivery.md").read_text(encoding="utf-8")
            self.assertIn("## 今回の結論", text)
            audit = json.loads((out_dir / "llm_generation_audit.json").read_text(encoding="utf-8"))
            self.assertTrue(audit["fallback_used"])

    def _run_cli(self, tmp_dir: str, mode: str) -> Path:
        tmp_path = Path(tmp_dir)
        fit_path = create_sample_fit(tmp_path / "sample.fit")
        out_dir = tmp_path / f"out-{mode}"
        exit_code = main(
            [
                "--fit",
                str(fit_path),
                "--profile",
                str(FIXTURES_DIR / "sample_runner_profile.json"),
                "--hearing",
                str(FIXTURES_DIR / "sample_hearing.json"),
                "--rules",
                str(ROOT / "configs" / "rules_v1.yaml"),
                "--client-report-mode",
                mode,
                "--generated-at",
                "2026-04-13T00:00:00+00:00",
                "--out",
                str(out_dir),
            ]
        )
        self.assertEqual(0, exit_code)
        return out_dir


if __name__ == "__main__":
    unittest.main()
