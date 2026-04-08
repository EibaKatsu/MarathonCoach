#!/usr/bin/env python3
"""Generate MarathonCoach custom code from 5-item user input."""

from __future__ import annotations

import argparse
import re
import sys
from typing import Dict, List, Tuple

BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
PREFIX = "C2"

RANGES = {
    "customCapS1": (30, 260),
    "customCapS2": (30, 260),
    "customCapS3": (30, 260),
    "customCapS4": (30, 260),
    "customCapS5": (30, 260),
}


def to_base36_pair(value: int) -> str:
    if value < 0:
        value = 0
    if value > 1295:
        value = 1295
    hi = value // 36
    lo = value % 36
    return BASE36[hi] + BASE36[lo]


def checksum(code_without_checksum: str) -> str:
    total = 0
    for i, ch in enumerate(code_without_checksum):
        idx = BASE36.find(ch)
        if idx >= 0:
            total += (i + 1) * idx
    return to_base36_pair(total % 1296)


def normalize_text(text: str) -> str:
    table = str.maketrans(
        {
            "：": ":",
            "－": "-",
            "ー": "-",
            "（": "(",
            "）": ")",
            "，": ",",
            "　": " ",
            "０": "0",
            "１": "1",
            "２": "2",
            "３": "3",
            "４": "4",
            "５": "5",
            "６": "6",
            "７": "7",
            "８": "8",
            "９": "9",
        }
    )
    return text.translate(table)


def parse_key_values(text: str) -> Dict[str, str]:
    normalized = normalize_text(text)
    out: Dict[str, str] = {}
    pattern = re.compile(
        r"^\s*(?:[1-5]\s*[\.\)]\s*)?([A-Za-z][A-Za-z0-9_]*)\s*(?:\([^)]*\))?\s*:\s*(.*?)\s*$"
    )
    for line in normalized.splitlines():
        m = pattern.match(line)
        if not m:
            continue
        key = m.group(1)
        val = m.group(2)
        out[key] = val
    return out


def parse_int_in_range(name: str, raw: str, lo: int, hi: int) -> int:
    try:
        v = int(raw.strip())
    except Exception as exc:  # noqa: BLE001
        raise ValueError(f"{name} must be integer") from exc
    if v < lo or v > hi:
        raise ValueError(f"{name} must be in {lo}..{hi}")
    return v


def build_code(values: Dict[str, str]) -> str:
    required = [
        "customCapS1",
        "customCapS2",
        "customCapS3",
        "customCapS4",
        "customCapS5",
    ]
    missing = [k for k in required if k not in values or values[k].strip() == ""]
    if missing:
        raise ValueError("missing: " + ", ".join(missing))

    cap_s1 = parse_int_in_range("customCapS1", values["customCapS1"], *RANGES["customCapS1"])
    cap_s2 = parse_int_in_range("customCapS2", values["customCapS2"], *RANGES["customCapS2"])
    cap_s3 = parse_int_in_range("customCapS3", values["customCapS3"], *RANGES["customCapS3"])
    cap_s4 = parse_int_in_range("customCapS4", values["customCapS4"], *RANGES["customCapS4"])
    cap_s5 = parse_int_in_range("customCapS5", values["customCapS5"], *RANGES["customCapS5"])

    payload = (
        to_base36_pair(cap_s1)
        + to_base36_pair(cap_s2)
        + to_base36_pair(cap_s3)
        + to_base36_pair(cap_s4)
        + to_base36_pair(cap_s5)
    )
    base = PREFIX + payload
    return base + checksum(base)


def template_text() -> str:
    return "\n".join(
        [
            "1. customCapS1(30-260):",
            "2. customCapS2(30-260):",
            "3. customCapS3(30-260):",
            "4. customCapS4(30-260):",
            "5. customCapS5(30-260):",
        ]
    )


def cmd_template(_: argparse.Namespace) -> int:
    print(template_text())
    return 0


def cmd_generate(args: argparse.Namespace) -> int:
    text = args.text
    if text is None:
        text = sys.stdin.read()

    values = parse_key_values(text)
    try:
        code = build_code(values)
    except ValueError as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2

    print(code)
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser()
    sp = p.add_subparsers(dest="command", required=True)

    p_t = sp.add_parser("template")
    p_t.set_defaults(func=cmd_template)

    p_g = sp.add_parser("generate")
    p_g.add_argument("--text", help="filled 1..5 item text")
    p_g.set_defaults(func=cmd_generate)
    return p


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
