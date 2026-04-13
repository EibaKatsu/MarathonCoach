from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.prompt_builder import SECTION_HEADINGS, build_narrative_input, build_prompt_bundle


class PromptBuilderTests(unittest.TestCase):
    def setUp(self) -> None:
        self.analysis_result = json.loads((ROOT / "tests" / "fixtures" / "analysis_result.json").read_text(encoding="utf-8"))
        self.llm_config = yaml.safe_load((ROOT / "configs" / "llm_v1.yaml").read_text(encoding="utf-8"))

    def test_build_narrative_input_uses_term_replacements(self) -> None:
        narrative_input = build_narrative_input(self.analysis_result, self.llm_config)
        self.assertEqual("序盤", narrative_input["recommended_setting"]["s1"]["label"])
        self.assertEqual("今回のご提案設定", narrative_input["recommended_terms"]["final_cap"])
        self.assertEqual("分析に十分使えるデータでした", narrative_input["quality_summary"])
        self.assertEqual("C2454749494ADW", narrative_input["custom_code"])

    def test_prompt_bundle_contains_required_sections(self) -> None:
        narrative_input = build_narrative_input(self.analysis_result, self.llm_config)
        bundle = build_prompt_bundle(narrative_input, self.llm_config)
        self.assertIn("マラソン向け個別設定サービス", bundle.system_prompt)
        for heading in SECTION_HEADINGS:
            self.assertIn(heading, bundle.user_prompt)
        self.assertIn('"custom_code": "C2454749494ADW"', bundle.user_prompt)


if __name__ == "__main__":
    unittest.main()
