#!/usr/bin/env python3
"""Generate a GateChecker race code."""

from __future__ import annotations

import argparse
from decimal import Decimal

from gatechecker_defs import generate_race_code


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("--race-id", required=True)
    parser.add_argument("--course-id", required=True)
    parser.add_argument("--year", required=True, type=int)
    parser.add_argument("--race-abbr")
    parser.add_argument("--course-label")
    parser.add_argument("--distance-km", type=Decimal)
    parser.add_argument("--display-name-eng", default="")
    parser.add_argument("--salt")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    race_code = generate_race_code(
        race_id=args.race_id,
        course_id=args.course_id,
        year=args.year,
        race_abbr=args.race_abbr,
        course_label=args.course_label,
        distance_km=args.distance_km,
        display_name_eng=args.display_name_eng,
        salt=args.salt,
    )
    print(race_code)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
