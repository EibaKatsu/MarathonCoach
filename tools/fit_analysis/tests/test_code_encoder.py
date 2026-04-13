from __future__ import annotations

import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from fit_analysis.code_encoder import CodeFormatError, decode_c2, encode_c2, validate_c2


class CodeEncoderTests(unittest.TestCase):
    def test_round_trip(self) -> None:
        code = encode_c2(149, 151, 153, 153, 154)
        self.assertEqual({"S1": 149, "S2": 151, "S3": 153, "S4": 153, "S5": 154}, decode_c2(code))
        self.assertTrue(validate_c2(code))

    def test_invalid_checksum(self) -> None:
        with self.assertRaises(CodeFormatError):
            decode_c2("C2454749494A00")


if __name__ == "__main__":
    unittest.main()
