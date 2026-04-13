from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.client_delivery_renderer import build_client_delivery_artifacts
from fit_analysis.fallback_template_renderer import render_fallback_client_markdown
from fit_analysis.narrative_generator import NarrativeGenerationError
from fit_analysis.prompt_builder import build_narrative_input
from fit_analysis.schemas import LLMRequestResult


class ClientDeliveryRendererTests(unittest.TestCase):
    def setUp(self) -> None:
        self.analysis_result = json.loads((ROOT / "tests" / "fixtures" / "analysis_result.json").read_text(encoding="utf-8"))
        self.llm_config = yaml.safe_load((ROOT / "configs" / "llm_v1.yaml").read_text(encoding="utf-8"))
        self.narrative_input = build_narrative_input(self.analysis_result, self.llm_config)

    def test_auto_mode_falls_back_on_generation_error(self) -> None:
        with patch("fit_analysis.client_delivery_renderer.generate_narrative_markdown", side_effect=NarrativeGenerationError("boom")):
            result = build_client_delivery_artifacts(
                analysis_result=self.analysis_result,
                llm_config=self.llm_config,
                mode="auto",
                generated_at="2026-04-13T00:00:00+00:00",
                save_llm_audit=True,
            )
        self.assertIn("## 今回の結論", result.markdown)
        self.assertTrue(result.audit["fallback_used"])
        self.assertTrue(result.validation.ok)

    def test_ai_mode_errors_on_invalid_llm_output(self) -> None:
        bad_markdown = "# タイトル\n\n## 今回の結論\n\nBROKEN\n"
        fake_result = LLMRequestResult(provider="openai", model="gpt-5", markdown=bad_markdown, raw_response={"id": "resp_1"})
        with patch("fit_analysis.client_delivery_renderer.generate_narrative_markdown", return_value=fake_result):
            with self.assertRaises(NarrativeGenerationError):
                build_client_delivery_artifacts(
                    analysis_result=self.analysis_result,
                    llm_config=self.llm_config,
                    mode="ai",
                    generated_at="2026-04-13T00:00:00+00:00",
                    save_llm_audit=True,
                )

    def test_ai_mode_accepts_valid_mocked_output(self) -> None:
        markdown = render_fallback_client_markdown(self.narrative_input).replace(
            f"# {self.narrative_input['race_name']} 向けご提案設定",
            f"# {self.narrative_input['race_name']} ご提案レポート",
        )
        fake_result = LLMRequestResult(provider="openai", model="gpt-5", markdown=markdown, raw_response={"id": "resp_2"})
        with patch("fit_analysis.client_delivery_renderer.generate_narrative_markdown", return_value=fake_result):
            result = build_client_delivery_artifacts(
                analysis_result=self.analysis_result,
                llm_config=self.llm_config,
                mode="ai",
                generated_at="2026-04-13T00:00:00+00:00",
                save_llm_audit=True,
            )
        self.assertFalse(result.audit["fallback_used"])
        self.assertIn("ご提案レポート", result.markdown)
        self.assertTrue(result.validation.ok)


if __name__ == "__main__":
    unittest.main()
