"""Test helpers for deterministic FIT analysis fixtures."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Tuple

ROOT = Path(__file__).resolve().parents[1]
SRC_DIR = ROOT / "src"
VENDOR_DIR = ROOT / "_vendor"
if str(SRC_DIR) not in sys.path:
    sys.path.insert(0, str(SRC_DIR))
if str(VENDOR_DIR) not in sys.path:
    sys.path.insert(0, str(VENDOR_DIR))

from garmin_fit_sdk import Encoder, FIT_EPOCH_S  # type: ignore
from garmin_fit_sdk.profile import Profile  # type: ignore

FIXTURES_DIR = ROOT / "tests" / "fixtures"


def load_fixture_json(name: str):
    return json.loads((FIXTURES_DIR / name).read_text(encoding="utf-8"))


def create_sample_fit(path: Path) -> Path:
    """Create a deterministic full marathon FIT sample for tests."""
    start_time = int(datetime(2024, 1, 7, 0, 0, 0, tzinfo=timezone.utc).timestamp()) - FIT_EPOCH_S
    mesgs = [
        {
            "mesg_num": Profile["mesg_num"]["FILE_ID"],
            "type": "activity",
            "manufacturer": "development",
            "product": 0,
            "time_created": start_time,
            "serial_number": 4242,
        },
        {
            "mesg_num": Profile["mesg_num"]["EVENT"],
            "timestamp": start_time,
            "event": "timer",
            "event_type": "start",
        },
        {
            "mesg_num": Profile["mesg_num"]["RECORD"],
            "timestamp": start_time,
            "distance": 0.0,
            "enhanced_speed": 1000.0 / 330.0,
            "heart_rate": 152,
        },
    ]

    elapsed = 0.0
    for distance_km, pace_sec_per_km, heart_rate in _sample_points()[1:]:
        elapsed += pace_sec_per_km * 0.5
        mesgs.append(
            {
                "mesg_num": Profile["mesg_num"]["RECORD"],
                "timestamp": start_time + int(round(elapsed)),
                "distance": distance_km * 1000.0,
                "enhanced_speed": 1000.0 / pace_sec_per_km,
                "heart_rate": heart_rate,
            }
        )

    finish_timestamp = start_time + int(round(elapsed))
    mesgs.extend(
        [
            {
                "mesg_num": Profile["mesg_num"]["EVENT"],
                "timestamp": finish_timestamp,
                "event": "timer",
                "event_type": "stop",
            },
            {
                "mesg_num": Profile["mesg_num"]["LAP"],
                "message_index": 0,
                "timestamp": finish_timestamp,
                "start_time": start_time,
                "total_elapsed_time": int(round(elapsed)),
                "total_timer_time": int(round(elapsed)),
                "total_distance": 42195.0,
            },
            {
                "mesg_num": Profile["mesg_num"]["SESSION"],
                "message_index": 0,
                "timestamp": finish_timestamp,
                "start_time": start_time,
                "total_elapsed_time": int(round(elapsed)),
                "total_timer_time": int(round(elapsed)),
                "total_distance": 42195.0,
                "sport": "running",
                "sub_sport": "road",
                "first_lap_index": 0,
                "num_laps": 1,
            },
            {
                "mesg_num": Profile["mesg_num"]["ACTIVITY"],
                "timestamp": finish_timestamp,
                "num_sessions": 1,
                "local_timestamp": finish_timestamp,
                "total_timer_time": int(round(elapsed)),
            },
        ]
    )

    encoder = Encoder()
    for message in mesgs:
        encoder.write_mesg(message)
    path.write_bytes(encoder.close())
    return path


def _sample_points() -> List[Tuple[float, float, int]]:
    points: List[Tuple[float, float, int]] = [(0.0, 330.0, 152)]
    distance_km = 0.5
    toggle = False
    while distance_km <= 42.195 + 1e-9:
        if distance_km < 10.1268:
            pace = 330.0
            hr = 156
        elif distance_km < 24.8951:
            pace = 336.0
            hr = 157
        elif distance_km < 35.0219:
            pace = 350.0 + (12.0 if toggle else -8.0)
            hr = 164
            toggle = not toggle
        elif distance_km < 40.0852:
            pace = 378.0
            hr = 163
        else:
            pace = 382.0
            hr = 162

        if distance_km >= 42.0:
            distance_km = 42.195
        points.append((round(distance_km, 3), pace, hr))
        if distance_km == 42.195:
            break
        distance_km += 0.5
    return points
