from __future__ import annotations

import sys
import unittest
from datetime import datetime, timedelta, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from fit_analysis.schemas import FitRecord
from fit_analysis.segmenter import build_intervals, slice_intervals_by_distance


class SegmenterTests(unittest.TestCase):
    def test_interval_generation_and_slice(self) -> None:
        start = datetime(2024, 1, 1, tzinfo=timezone.utc)
        records = [
            FitRecord(start, 0.0, 150, 3.0, 333.333),
            FitRecord(start + timedelta(seconds=100), 500.0, 152, 5.0, 200.0),
            FitRecord(start + timedelta(seconds=220), 1000.0, 154, 4.167, 240.0),
        ]
        intervals = build_intervals(records)
        self.assertEqual(2, len(intervals))
        self.assertAlmostEqual(500.0, intervals[0].delta_distance_m)
        sliced = slice_intervals_by_distance(intervals, 0.25, 0.75)
        self.assertEqual(2, len(sliced))
        self.assertAlmostEqual(250.0, sliced[0].delta_distance_m, places=3)
        self.assertAlmostEqual(250.0, sliced[1].delta_distance_m, places=3)


if __name__ == "__main__":
    unittest.main()
