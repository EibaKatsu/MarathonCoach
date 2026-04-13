from __future__ import annotations

import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.quality_gate import evaluate_quality
from fit_analysis.schemas import FitActivityData, FitRecord


class QualityGateTests(unittest.TestCase):
    def setUp(self) -> None:
        self.rules = yaml.safe_load((ROOT / "configs" / "rules_v1.yaml").read_text(encoding="utf-8"))

    def test_usable_with_caution_when_short_and_missing_hr(self) -> None:
        start = datetime(2024, 1, 1, tzinfo=timezone.utc)
        records = [
            FitRecord(start, 0.0, 150, 3.0, 333.0),
            FitRecord(start + timedelta(seconds=300), 1000.0, 151, 3.2, 312.5),
            FitRecord(start + timedelta(seconds=600), 2000.0, None, 3.2, 312.5),
            FitRecord(start + timedelta(seconds=900), 3000.0, 155, 3.2, 312.5),
            FitRecord(start + timedelta(seconds=1200), 3200.0, 156, 0.4, 2500.0),
        ]
        fit_data = FitActivityData(
            path="sample.fit",
            file_hash="abc",
            integrity_ok=True,
            records=records,
            session={"total_distance": 3200.0},
            messages_summary={},
        )
        result = evaluate_quality(fit_data, 4.0, self.rules)
        self.assertEqual("usable_with_caution", result.status)

    def test_not_recommended_when_distance_is_far_too_short(self) -> None:
        start = datetime(2024, 1, 1, tzinfo=timezone.utc)
        records = [
            FitRecord(start, 0.0, 150, 3.0, 333.0),
            FitRecord(start + timedelta(seconds=600), 1000.0, 152, 1.7, 588.2),
        ]
        fit_data = FitActivityData(
            path="sample.fit",
            file_hash="abc",
            integrity_ok=True,
            records=records,
            session={"total_distance": 1000.0},
            messages_summary={},
        )
        result = evaluate_quality(fit_data, 10.0, self.rules)
        self.assertEqual("not_recommended", result.status)


if __name__ == "__main__":
    unittest.main()
