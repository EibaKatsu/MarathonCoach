from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

import yaml

from fit_analysis.race_profile import build_phase_boundaries, resolve_race_profile


class RaceProfileTests(unittest.TestCase):
    def setUp(self) -> None:
        self.rules = yaml.safe_load((ROOT / "configs" / "rules_v1.yaml").read_text(encoding="utf-8"))

    def test_profile_resolution(self) -> None:
        self.assertEqual("SHORT", resolve_race_profile(10.0, self.rules))
        self.assertEqual("HALF", resolve_race_profile(21.0975, self.rules))
        self.assertEqual("FULL", resolve_race_profile(42.195, self.rules))

    def test_phase_boundaries(self) -> None:
        boundaries = build_phase_boundaries(42.195, self.rules)
        self.assertEqual("S1", boundaries[0].name)
        self.assertAlmostEqual(10.1268, boundaries[0].end_km, places=4)
        self.assertAlmostEqual(24.8950, boundaries[1].end_km, places=4)
        self.assertAlmostEqual(42.195, boundaries[-1].end_km, places=4)


if __name__ == "__main__":
    unittest.main()
