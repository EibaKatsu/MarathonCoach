#!/usr/bin/env python3
"""Generate GateChecker simulator scenario codes."""

from __future__ import annotations

import argparse
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Iterable, List, Sequence, Tuple


BASE36 = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
CODE_PREFIX = "G1"


@dataclass(frozen=True)
class Scenario:
    name: str
    description: str
    gates: Sequence[Tuple[int, int]]
    notes: Sequence[str]


def encode_base36_pair(value: int) -> str:
    clamped = max(0, min(value, 1295))
    hi = clamped // 36
    lo = clamped % 36
    return BASE36[hi] + BASE36[lo]


def compute_checksum(code_without_checksum: str) -> str:
    total = 0
    for index, ch in enumerate(code_without_checksum):
        digit = BASE36.find(ch.upper())
        if digit >= 0:
            total += (index + 1) * digit
    return encode_base36_pair(total % 1296)


def build_gate_code(gates: Sequence[Tuple[int, int]]) -> str:
    payload = "".join(
        f"{distance_tenth_km:04d}{hhmm:04d}"
        for distance_tenth_km, hhmm in gates
    )
    base = f"{CODE_PREFIX}{len(gates):02d}{payload}"
    return base + compute_checksum(base)


def hhmm_from_offset(base_time: datetime, offset_min: int) -> int:
    target = base_time + timedelta(minutes=offset_min)
    return (target.hour * 100) + target.minute


def build_scenarios(base_time: datetime) -> List[Scenario]:
    return [
        Scenario(
            name="normal",
            description="Next gate exists and both remaining distance/time are positive.",
            gates=[
                (3, hhmm_from_offset(base_time, 20)),
                (6, hhmm_from_offset(base_time, 35)),
                (9, hhmm_from_offset(base_time, 50)),
                (12, hhmm_from_offset(base_time, 65)),
            ],
            notes=[
                "Use while current distance is still below 0.3km.",
                "Expected displayState=normal in [GATE_CODE_DIAG].",
            ],
        ),
        Scenario(
            name="pace_na",
            description="Next gate exists but required pace is intentionally unavailable.",
            gates=[
                (0, hhmm_from_offset(base_time, 20)),
                (3, hhmm_from_offset(base_time, 35)),
                (6, hhmm_from_offset(base_time, 50)),
                (9, hhmm_from_offset(base_time, 65)),
            ],
            notes=[
                "Start the activity and inspect before distance advances past 0.00km.",
                "Expected displayState=pace_na in [GATE_CODE_DIAG].",
            ],
        ),
        Scenario(
            name="over",
            description="Next gate still remains by distance, but its close time is already past.",
            gates=[
                (3, hhmm_from_offset(base_time, -5)),
                (6, hhmm_from_offset(base_time, 15)),
                (9, hhmm_from_offset(base_time, 30)),
                (12, hhmm_from_offset(base_time, 45)),
            ],
            notes=[
                "Keep current distance below 0.3km.",
                "Expected displayState=over in [GATE_CODE_DIAG].",
            ],
        ),
        Scenario(
            name="all_passed",
            description="All registered gates are already passed by distance.",
            gates=[
                (3, hhmm_from_offset(base_time, 25)),
                (6, hhmm_from_offset(base_time, 40)),
                (9, hhmm_from_offset(base_time, 55)),
                (12, hhmm_from_offset(base_time, 70)),
            ],
            notes=[
                "Advance current distance beyond 1.2km.",
                "Expected displayState=all_passed in [GATE_CODE_DIAG].",
            ],
        ),
    ]


def parse_base_time(raw: str | None) -> datetime:
    now = datetime.now()
    if raw is None:
        return now

    hour_text, minute_text = raw.split(":", 1)
    return now.replace(
        hour=int(hour_text),
        minute=int(minute_text),
        second=0,
        microsecond=0,
    )


def render_scenario(base_time: datetime, scenario: Scenario) -> str:
    code = build_gate_code(scenario.gates)
    gate_text = ", ".join(
        f"{distance_tenth / 10.0:.1f}km@{hhmm:04d}"
        for distance_tenth, hhmm in scenario.gates
    )
    note_lines = "\n".join(f"  - {note}" for note in scenario.notes)
    return "\n".join(
        [
            f"[{scenario.name}]",
            f"description: {scenario.description}",
            f"base_time: {base_time.strftime('%H:%M')}",
            f"gates: {gate_text}",
            f"gate_code: {code}",
            "notes:",
            note_lines,
        ]
    )


def render_output(base_time: datetime, scenarios: Iterable[Scenario]) -> str:
    blocks = [render_scenario(base_time, scenario) for scenario in scenarios]
    return "\n\n".join(blocks)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base-time",
        help="Base clock time in HH:MM. Defaults to local current time.",
    )
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    base_time = parse_base_time(args.base_time)
    print(render_output(base_time, build_scenarios(base_time)))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
