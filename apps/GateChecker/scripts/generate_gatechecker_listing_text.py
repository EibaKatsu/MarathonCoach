#!/usr/bin/env python3
"""Generate Connect IQ Store listing text for a GateChecker race."""

from __future__ import annotations

import argparse
import sys
from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
from pathlib import Path
from typing import Any

import yaml


APP_DIR = Path(__file__).resolve().parent.parent
RACE_DEFS_DIR = APP_DIR / "race_defs"
RACE_INDEX_PATH = RACE_DEFS_DIR / "race_index.yml"
RELEASES_DIR = APP_DIR / "releases"
OUTPUT_FILE_NAME = "CONNECT_IQ_LISTING.md"
GOAL_TOKEN = "GOAL"


class ValidationError(ValueError):
    """Raised when a race definition cannot be converted into listing text."""


@dataclass(frozen=True)
class Gate:
    label: str
    distance_km: Decimal
    cutoff_time: str


@dataclass(frozen=True)
class Aid:
    distance_km: Decimal
    name_jpn: str | None
    name_eng: str | None


@dataclass(frozen=True)
class RaceListing:
    race_key: str
    event_name_jpn: str
    event_name_eng: str
    gates: list[Gate]
    aids: list[Aid]


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise ValidationError(f"{path} must contain a YAML mapping.")
    return data


def parse_decimal(raw: Any, label: str) -> Decimal:
    try:
        value = Decimal(str(raw))
    except (InvalidOperation, ValueError) as exc:
        raise ValidationError(f"{label} must be numeric, got: {raw!r}") from exc
    if value.is_nan():
        raise ValidationError(f"{label} must be numeric, got: {raw!r}")
    return value


def format_distance_km(value: Decimal) -> str:
    rounded = value.quantize(Decimal("0.1"), rounding=ROUND_HALF_UP)
    return f"{rounded:.1f}"


def parse_cutoff_time(raw: Any, label: str) -> str:
    if not isinstance(raw, str):
        raise ValidationError(f"{label} must be a string in yyyy/mm/dd HH:MM format.")
    try:
        cutoff_dt = datetime.strptime(raw, "%Y/%m/%d %H:%M")
    except ValueError as exc:
        raise ValidationError(
            f"{label} must be a string in yyyy/mm/dd HH:MM format."
        ) from exc
    return cutoff_dt.strftime("%H:%M")


def parse_aid_name(raw_aid: dict[str, Any]) -> tuple[str | None, str | None]:
    raw_name = raw_aid.get("name")
    if isinstance(raw_name, str) and raw_name.strip():
        value = raw_name.strip()
        return value, value
    if isinstance(raw_name, dict):
        name_jpn = raw_name.get("jpn")
        name_eng = raw_name.get("eng")
        if name_jpn is not None and not isinstance(name_jpn, str):
            raise ValidationError("aids[].name.jpn must be a string.")
        if name_eng is not None and not isinstance(name_eng, str):
            raise ValidationError("aids[].name.eng must be a string.")
        return (
            name_jpn.strip() if isinstance(name_jpn, str) and name_jpn.strip() else None,
            name_eng.strip() if isinstance(name_eng, str) and name_eng.strip() else None,
        )
    if raw_name is not None:
        raise ValidationError("aids[].name must be a string or mapping.")

    fallback_jpn = raw_aid.get("name_jpn")
    fallback_eng = raw_aid.get("name_eng")
    if fallback_jpn is not None and not isinstance(fallback_jpn, str):
        raise ValidationError("aids[].name_jpn must be a string.")
    if fallback_eng is not None and not isinstance(fallback_eng, str):
        raise ValidationError("aids[].name_eng must be a string.")
    return (
        fallback_jpn.strip() if isinstance(fallback_jpn, str) and fallback_jpn.strip() else None,
        fallback_eng.strip() if isinstance(fallback_eng, str) and fallback_eng.strip() else None,
    )


def resolve_definition_path(identifier: str) -> Path:
    index_data = load_yaml(RACE_INDEX_PATH)
    races = index_data.get("races")
    if not isinstance(races, dict) or not races:
        raise ValidationError(f"{RACE_INDEX_PATH} must define races.")

    if identifier in races:
        definition = races[identifier].get("definition")
        if not isinstance(definition, str) or not definition:
            raise ValidationError(f"races.{identifier}.definition must be a string.")
        return RACE_DEFS_DIR / definition

    matches: list[Path] = []
    for entry in races.values():
        if not isinstance(entry, dict):
            continue
        definition = entry.get("definition")
        if not isinstance(definition, str) or not definition:
            continue
        definition_path = RACE_DEFS_DIR / definition
        data = load_yaml(definition_path)
        display_name = data.get("display_name")
        if not isinstance(display_name, dict):
            continue
        jpn = display_name.get("jpn")
        eng = display_name.get("eng")
        if identifier == jpn or identifier == eng:
            matches.append(definition_path)

    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        raise ValidationError(
            f"Multiple races matched {identifier!r}. Please pass race_key explicitly."
        )
    raise ValidationError(f"Race not found: {identifier}")


def parse_race_listing(definition_path: Path) -> RaceListing:
    data = load_yaml(definition_path)
    race_key = data.get("race_key")
    if not isinstance(race_key, str) or not race_key:
        raise ValidationError(f"{definition_path}: race_key must be a non-empty string.")

    display_name = data.get("display_name")
    if not isinstance(display_name, dict):
        raise ValidationError(f"{definition_path}: display_name must be a mapping.")
    event_name_jpn = display_name.get("jpn")
    event_name_eng = display_name.get("eng")
    if not isinstance(event_name_jpn, str) or not event_name_jpn.strip():
        raise ValidationError(f"{definition_path}: display_name.jpn must be a string.")
    if not isinstance(event_name_eng, str) or not event_name_eng.strip():
        raise ValidationError(f"{definition_path}: display_name.eng must be a string.")

    race = data.get("race")
    if not isinstance(race, dict):
        raise ValidationError(f"{definition_path}: race must be a mapping.")
    distance_km = parse_decimal(race.get("distance_km"), "race.distance_km")

    raw_gates = data.get("gates")
    if not isinstance(raw_gates, list) or not raw_gates:
        raise ValidationError(f"{definition_path}: gates must contain at least one item.")

    gates: list[Gate] = []
    gate_number = 1
    for index, raw_gate in enumerate(raw_gates):
        if not isinstance(raw_gate, dict):
            raise ValidationError(f"{definition_path}: gates[{index}] must be a mapping.")
        point = raw_gate.get("point")
        cutoff_time = parse_cutoff_time(raw_gate.get("cutoff"), f"gates[{index}].cutoff")
        if point == GOAL_TOKEN:
            label = GOAL_TOKEN
            gate_distance = distance_km
        else:
            gate_distance = parse_decimal(point, f"gates[{index}].point")
            label = f"G{gate_number}"
            gate_number += 1
        gates.append(Gate(label=label, distance_km=gate_distance, cutoff_time=cutoff_time))

    raw_aids = data.get("aids")
    if raw_aids is None:
        raw_aids = []
    if not isinstance(raw_aids, list):
        raise ValidationError(f"{definition_path}: aids must be a list.")

    aids: list[Aid] = []
    for index, raw_aid in enumerate(raw_aids):
        if not isinstance(raw_aid, dict):
            raise ValidationError(f"{definition_path}: aids[{index}] must be a mapping.")
        distance = parse_decimal(raw_aid.get("km"), f"aids[{index}].km")
        name_jpn, name_eng = parse_aid_name(raw_aid)
        aids.append(Aid(distance_km=distance, name_jpn=name_jpn, name_eng=name_eng))

    return RaceListing(
        race_key=race_key,
        event_name_jpn=event_name_jpn.strip(),
        event_name_eng=event_name_eng.strip(),
        gates=gates,
        aids=aids,
    )


def render_gate_line_jpn(gate: Gate) -> str:
    return f"・{gate.label}: {format_distance_km(gate.distance_km)}km / {gate.cutoff_time}"


def render_gate_line_eng(gate: Gate) -> str:
    return f"- {gate.label}: {format_distance_km(gate.distance_km)} km / {gate.cutoff_time}"


def render_aid_line_jpn(aid: Aid) -> str:
    base = f"・{format_distance_km(aid.distance_km)}km"
    if aid.name_jpn:
        return f"{base}: {aid.name_jpn}"
    return base


def render_aid_line_eng(aid: Aid) -> str:
    base = f"- {format_distance_km(aid.distance_km)} km"
    name = aid.name_eng or aid.name_jpn
    if name:
        return f"{base}: {name}"
    return base


def render_listing_markdown(race: RaceListing) -> str:
    gate_lines_jpn = "\n".join(render_gate_line_jpn(gate) for gate in race.gates)
    gate_lines_eng = "\n".join(render_gate_line_eng(gate) for gate in race.gates)
    aid_lines_jpn = "\n".join(render_aid_line_jpn(aid) for aid in race.aids)
    aid_lines_eng = "\n".join(render_aid_line_eng(aid) for aid in race.aids)

    return f"""## Japanese

### Title

関門ガイド for {race.event_name_jpn}

### Description

関門ガイド for {race.event_name_jpn} は、{race.event_name_jpn}の関門時間とエイド地点をレース中に確認できる Garmin 向けデータフィールドです。

次の関門までの距離、残り時間、関門時刻、次のエイドまでの距離を1画面に表示します。

「次の関門まであと何km？」
「まだ間に合う？」
「次のエイドはどこ？」

そんな不安を減らし、ゴールまで落ち着いて進むためのガイドです。

【関門情報】
{gate_lines_jpn}

【AID情報】
{aid_lines_jpn}

※本アプリの関門・エイド情報は、作成時点で確認した大会情報を元に設定しています。
※大会運営による変更、天候・コース変更、ウェーブスタート、公式情報の更新などにより、実際の関門時刻・エイド地点と異なる場合があります。
※レース当日は必ず大会公式サイト、参加案内、会場案内、スタッフの指示を優先してください。

---

## English

### Title

Marathon Cutoff Guide for {race.event_name_eng}

### Description

Marathon Cutoff Guide for {race.event_name_eng} is a Garmin data field for checking race cutoffs and aid stations during {race.event_name_eng}.

It shows the next cutoff point, cutoff time, remaining distance, remaining time, and distance to the next aid station on one screen.

Reduce uncertainty during the race and keep moving calmly toward the finish.

Cutoff points:
{gate_lines_eng}

Aid stations:
{aid_lines_eng}

Note:
The cutoff and aid station data in this app is based on event information available at the time of creation.
Actual cutoff times and aid station locations may change due to event organizer updates, weather, course changes, wave starts, or other race-day conditions.
Please always follow the official event website, race guide, on-site announcements, and staff instructions on race day.
"""


def write_output(race: RaceListing, markdown: str) -> Path:
    output_dir = RELEASES_DIR / race.race_key
    output_dir.mkdir(parents=True, exist_ok=True)
    output_path = output_dir / OUTPUT_FILE_NAME
    output_path.write_text(markdown, encoding="utf-8")
    return output_path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Generate Connect IQ Store listing text for a GateChecker race."
    )
    parser.add_argument(
        "identifier",
        help="race_key or exact display_name.jpn/display_name.eng",
    )
    parser.add_argument(
        "--stdout",
        action="store_true",
        help="Print the generated Markdown instead of saving it.",
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    try:
        definition_path = resolve_definition_path(args.identifier)
        race = parse_race_listing(definition_path)
        markdown = render_listing_markdown(race)
        if args.stdout:
            print(markdown)
            return 0
        output_path = write_output(race, markdown)
    except ValidationError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1

    print(output_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
