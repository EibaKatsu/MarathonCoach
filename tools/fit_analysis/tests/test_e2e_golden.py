from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))
sys.path.insert(0, str(ROOT / "_vendor"))

from fit_analysis.cli import main

from .helpers import FIXTURES_DIR, create_sample_fit


class E2EGoldenTests(unittest.TestCase):
    def test_golden_outputs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = Path(tmp_dir)
            fit_path = create_sample_fit(tmp_path / "sample.fit")
            out_dir = tmp_path / "out"
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
                    "--out",
                    str(out_dir),
                    "--generated-at",
                    "2026-04-13T00:00:00+00:00",
                ]
            )
            self.assertEqual(0, exit_code)
            for name in ["analysis_result.json", "custom_code.txt", "delivery_report.md"]:
                self.assertEqual(
                    (FIXTURES_DIR / name).read_text(encoding="utf-8"),
                    (out_dir / name).read_text(encoding="utf-8"),
                )


if __name__ == "__main__":
    unittest.main()
