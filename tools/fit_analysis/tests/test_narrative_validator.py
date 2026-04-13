from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.fallback_template_renderer import render_fallback_client_markdown
from fit_analysis.narrative_validator import validate_narrative_markdown
from fit_analysis.prompt_builder import build_narrative_input


class NarrativeValidatorTests(unittest.TestCase):
    def setUp(self) -> None:
        self.analysis_result = json.loads((ROOT / "tests" / "fixtures" / "analysis_result.json").read_text(encoding="utf-8"))
        self.llm_config = yaml.safe_load((ROOT / "configs" / "llm_v1.yaml").read_text(encoding="utf-8"))
        self.narrative_input = build_narrative_input(self.analysis_result, self.llm_config)

    def test_validator_accepts_valid_markdown(self) -> None:
        markdown = render_fallback_client_markdown(self.narrative_input)
        result = validate_narrative_markdown(markdown, self.narrative_input, self.llm_config)
        self.assertTrue(result.ok)
        self.assertFalse(result.issues)

    def test_validator_rejects_missing_code(self) -> None:
        markdown = render_fallback_client_markdown(self.narrative_input).replace(self.narrative_input["custom_code"], "BROKEN")
        result = validate_narrative_markdown(markdown, self.narrative_input, self.llm_config)
        self.assertFalse(result.ok)
        self.assertTrue(any("Custom Code" in issue for issue in result.issues))


if __name__ == "__main__":
    unittest.main()
