from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.adjustment_engine import apply_adjustments
from fit_analysis.schemas import BaselineResult, HearingInput


class AdjustmentEngineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.rules = yaml.safe_load((ROOT / "configs" / "rules_v1.yaml").read_text(encoding="utf-8"))

    def test_rules_stack_deterministically(self) -> None:
        baseline = BaselineResult(
            profile="FULL",
            source="CAP_SOURCE_LTHR_PROPERTY",
            anchor_lthr_bpm=160,
            values={"S1": 152, "S2": 154, "S3": 155, "S4": 157, "S5": 158},
            debug={},
        )
        metrics = {
            "goal_pace_sec_per_km": 341.3,
            "early_pace_diff_sec": -10.0,
            "pace_drop_35_plus_sec": 26.0,
            "avg_pace_25_35_sec_per_km": 350.0,
            "avg_hr_35_plus_bpm": 163,
            "hr_rise_25_35_vs_s2_bpm": 7.0,
            "finish_kick_sec": 10.0,
            "phases": {
                "S1": {"avg_hr_bpm": 156, "pace_variability_sec": 5.0},
                "S2": {"avg_hr_bpm": 157, "pace_variability_sec": 6.0},
                "S3": {"avg_hr_bpm": 164, "pace_variability_sec": 18.0},
                "S4": {"avg_hr_bpm": 163, "avg_pace_sec_per_km": 378.0, "pace_variability_sec": 8.0},
                "S5": {"avg_hr_bpm": 162, "avg_pace_sec_per_km": 382.0, "pace_variability_sec": 7.0},
            },
        }
        hearing = HearingInput.from_dict({"fueling_actual": "late", "cramp": True})
        result = apply_adjustments(baseline, metrics, hearing, "usable", self.rules)
        self.assertEqual({"S1": 149, "S2": 151, "S3": 153, "S4": 153, "S5": 154}, result["final_values"])
        self.assertEqual(-4, result["total_deltas"]["S4"])
        self.assertEqual(-4, result["total_deltas"]["S5"])


if __name__ == "__main__":
    unittest.main()
