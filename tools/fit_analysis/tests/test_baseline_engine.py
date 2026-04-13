from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.baseline_engine import calculate_baseline
from fit_analysis.schemas import RunnerProfile


class BaselineEngineTests(unittest.TestCase):
    def setUp(self) -> None:
        self.rules = yaml.safe_load((ROOT / "configs" / "rules_v1.yaml").read_text(encoding="utf-8"))

    def test_lthr_property_priority(self) -> None:
        runner = RunnerProfile.from_dict(
            {
                "runner_id": "r1",
                "goal_race": "Test",
                "race_distance_km": 42.195,
                "goal_time": "4:00:00",
                "lthr_bpm": 168,
                "device_lthr_bpm": 166,
                "max_hr": 190,
                "resting_hr": 50,
            }
        )
        baseline = calculate_baseline("FULL", runner, self.rules)
        self.assertEqual("CAP_SOURCE_LTHR_PROPERTY", baseline.source)
        self.assertEqual({"S1": 160, "S2": 161, "S3": 163, "S4": 165, "S5": 166}, baseline.values)

    def test_hrr_fallback(self) -> None:
        runner = RunnerProfile.from_dict(
            {
                "runner_id": "r1",
                "goal_race": "Test",
                "race_distance_km": 21.0975,
                "goal_time": "1:45:00",
                "max_hr": 188,
                "resting_hr": 52,
            }
        )
        baseline = calculate_baseline("HALF", runner, self.rules)
        self.assertEqual("CAP_SOURCE_HRR", baseline.source)
        self.assertEqual(170, baseline.values["S3"])


if __name__ == "__main__":
    unittest.main()
