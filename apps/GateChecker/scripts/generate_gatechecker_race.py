#!/usr/bin/env python3
"""Generate GateChecker race-specific assets from YAML definitions."""

from __future__ import annotations

import argparse
import re
import sys
import uuid
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal, InvalidOperation
from pathlib import Path
from string import Template
from typing import Any

import yaml


APP_DIR = Path(__file__).resolve().parent.parent
RACE_DEFS_DIR = APP_DIR / "race_defs"
RACE_INDEX_PATH = RACE_DEFS_DIR / "race_index.yml"
TEMPLATES_DIR = APP_DIR / "templates"
MANIFEST_PATH = APP_DIR / "manifest.xml"
STRINGS_ENG_PATH = APP_DIR / "resources" / "strings" / "strings.xml"
STRINGS_JPN_PATH = APP_DIR / "resources-jpn" / "strings" / "strings.xml"
PROPERTIES_PATH = APP_DIR / "resources" / "properties.xml"
GENERATED_SOURCE_PATH = APP_DIR / "source" / "generated" / "GateRaceConfig.mc"
DIST_DIR = APP_DIR / "dist"

RACE_KEY_RE = re.compile(r"^[a-z0-9_]+$")
UUID_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)
GOAL_TOKEN = "GOAL"


class ValidationError(ValueError):
    """Raised when a race definition is invalid."""


@dataclass(frozen=True)
class RaceEntry:
    race_key: str
    app_id: str
    version: str
    definition_path: Path


@dataclass(frozen=True)
class RaceMeta:
    race_key: str
    display_name_jpn: str
    display_name_eng: str
    race_date: date
    timezone: str
    distance_km: Decimal
    gates: list[list[Any]]
    aids: list[int]


def load_yaml(path: Path) -> dict[str, Any]:
    with path.open("r", encoding="utf-8") as fh:
        data = yaml.safe_load(fh)
    if data is None:
        return {}
    if not isinstance(data, dict):
        raise ValidationError(f"{path} must contain a YAML mapping.")
    return data


def save_yaml(path: Path, data: dict[str, Any]) -> None:
    with path.open("w", encoding="utf-8") as fh:
        yaml.safe_dump(
            data,
            fh,
            allow_unicode=True,
            sort_keys=False,
            default_flow_style=False,
        )


def ensure_race_key(race_key: str, label: str) -> None:
    if not RACE_KEY_RE.fullmatch(race_key):
        raise ValidationError(
            f"{label} must match [a-z0-9_]+, got: {race_key!r}"
        )


def ensure_uuid(text: str, label: str) -> None:
    if not UUID_RE.fullmatch(text):
        raise ValidationError(f"{label} must be a UUID, got: {text!r}")


def parse_index(race_key: str) -> RaceEntry:
    index_data = load_yaml(RACE_INDEX_PATH)
    races = index_data.get("races")
    if not isinstance(races, dict) or not races:
        raise ValidationError(f"{RACE_INDEX_PATH} must define races.")

    app_ids: dict[str, str] = {}
    for indexed_key, entry in races.items():
        ensure_race_key(str(indexed_key), "race_index key")
        if not isinstance(entry, dict):
            raise ValidationError(f"races.{indexed_key} must be a mapping.")
        app_id = entry.get("app_id")
        if app_id is not None:
            app_id = str(app_id)
            ensure_uuid(app_id, f"races.{indexed_key}.app_id")
            if app_id in app_ids:
                raise ValidationError(
                    f"Duplicate app_id {app_id} for {indexed_key} and {app_ids[app_id]}"
                )
            app_ids[app_id] = str(indexed_key)

    if race_key not in races:
        raise ValidationError(f"race_key not found in race_index.yml: {race_key}")

    target = races[race_key]
    definition = target.get("definition")
    version = target.get("version")
    if not isinstance(definition, str) or not definition:
        raise ValidationError(f"races.{race_key}.definition must be a string.")
    if not isinstance(version, str) or not version:
        raise ValidationError(f"races.{race_key}.version must be a string.")

    app_id = target.get("app_id")
    if app_id is None:
        app_id = str(uuid.uuid4())
        target["app_id"] = app_id
        save_yaml(RACE_INDEX_PATH, index_data)
    else:
        app_id = str(app_id)

    ensure_uuid(app_id, f"races.{race_key}.app_id")
    return RaceEntry(
        race_key=race_key,
        app_id=app_id,
        version=version,
        definition_path=RACE_DEFS_DIR / definition,
    )


def parse_decimal(raw: Any, label: str) -> Decimal:
    try:
        value = Decimal(str(raw))
    except (InvalidOperation, ValueError) as exc:
        raise ValidationError(f"{label} must be numeric, got: {raw!r}") from exc
    if value.is_nan():
        raise ValidationError(f"{label} must be numeric, got: {raw!r}")
    return value


def parse_tenth_km(raw: Any, label: str, max_distance_km: Decimal) -> int:
    distance_km = parse_decimal(raw, label)
    if distance_km <= 0:
        raise ValidationError(f"{label} must be > 0.")
    if distance_km > max_distance_km:
        raise ValidationError(
            f"{label} must be <= race.distance_km ({format_decimal(max_distance_km)})."
        )

    tenth = distance_km * Decimal("10")
    if tenth != tenth.to_integral_value():
        raise ValidationError(f"{label} must be aligned to 0.1km units.")
    return int(tenth)


def parse_definition(entry: RaceEntry) -> RaceMeta:
    if not entry.definition_path.exists():
        raise ValidationError(f"Definition file not found: {entry.definition_path}")

    data = load_yaml(entry.definition_path)
    definition_key = data.get("race_key")
    if definition_key != entry.race_key:
        raise ValidationError(
            f"Definition race_key mismatch: {definition_key!r} != {entry.race_key!r}"
        )
    ensure_race_key(entry.race_key, "definition race_key")

    display_name = data.get("display_name")
    if not isinstance(display_name, dict):
        raise ValidationError("display_name must be a mapping.")
    display_name_jpn = display_name.get("jpn")
    display_name_eng = display_name.get("eng")
    if not isinstance(display_name_jpn, str) or not display_name_jpn:
        raise ValidationError("display_name.jpn must be a non-empty string.")
    if not isinstance(display_name_eng, str) or not display_name_eng:
        raise ValidationError("display_name.eng must be a non-empty string.")

    race = data.get("race")
    if not isinstance(race, dict):
        raise ValidationError("race must be a mapping.")
    raw_date = race.get("date")
    raw_timezone = race.get("timezone")
    raw_distance_km = race.get("distance_km")
    if not isinstance(raw_date, str):
        raise ValidationError("race.date must be a string in yyyy/mm/dd format.")
    if not isinstance(raw_timezone, str) or not raw_timezone:
        raise ValidationError("race.timezone must be a non-empty string.")
    race_date = datetime.strptime(raw_date, "%Y/%m/%d").date()
    distance_km = parse_decimal(raw_distance_km, "race.distance_km")
    if distance_km <= 0:
        raise ValidationError("race.distance_km must be > 0.")

    raw_gates = data.get("gates")
    if not isinstance(raw_gates, list) or not raw_gates:
        raise ValidationError("gates must contain at least one item.")

    gates: list[list[Any]] = []
    last_point_km: Decimal | None = None
    last_cutoff: datetime | None = None
    goal_seen = False
    for index, raw_gate in enumerate(raw_gates):
        if not isinstance(raw_gate, dict):
            raise ValidationError(f"gates[{index}] must be a mapping.")

        point = raw_gate.get("point")
        cutoff_raw = raw_gate.get("cutoff")
        if not isinstance(cutoff_raw, str):
            raise ValidationError(f"gates[{index}].cutoff must be a string.")
        cutoff_dt = datetime.strptime(cutoff_raw, "%Y/%m/%d %H:%M")
        cutoff_day_offset = (cutoff_dt.date() - race_date).days
        if cutoff_day_offset < 0:
            raise ValidationError(
                f"gates[{index}].cutoff must not be before race.date."
            )
        cutoff_minute_of_day = (cutoff_dt.hour * 60) + cutoff_dt.minute
        if last_cutoff is not None and cutoff_dt <= last_cutoff:
            raise ValidationError("gates[].cutoff must be strictly ascending.")
        last_cutoff = cutoff_dt

        if point == GOAL_TOKEN:
            if goal_seen:
                raise ValidationError("GOAL may only appear once.")
            if index != len(raw_gates) - 1:
                raise ValidationError("GOAL is only allowed as the final gate.")
            goal_seen = True
            gates.append([GOAL_TOKEN, cutoff_day_offset, cutoff_minute_of_day])
            continue

        if goal_seen:
            raise ValidationError("No gate may appear after GOAL.")

        point_km = parse_decimal(point, f"gates[{index}].point")
        if point_km <= 0:
            raise ValidationError(f"gates[{index}].point must be > 0.")
        if point_km > distance_km:
            raise ValidationError(
                f"gates[{index}].point must be <= race.distance_km."
            )
        if last_point_km is not None and point_km <= last_point_km:
            raise ValidationError("gates[].point must be strictly ascending.")

        point_tenth_km = parse_tenth_km(
            point_km, f"gates[{index}].point", distance_km
        )
        gates.append([point_tenth_km, cutoff_day_offset, cutoff_minute_of_day])
        last_point_km = point_km

    raw_aids = data.get("aids", [])
    if raw_aids is None:
        raw_aids = []
    if not isinstance(raw_aids, list):
        raise ValidationError("aids must be a list.")

    aids: list[int] = []
    last_aid = None
    for index, raw_aid in enumerate(raw_aids):
        if not isinstance(raw_aid, dict):
            raise ValidationError(f"aids[{index}] must be a mapping.")
        km_tenth = parse_tenth_km(raw_aid.get("km"), f"aids[{index}].km", distance_km)
        if last_aid is not None and km_tenth <= last_aid:
            raise ValidationError("aids[].km must be strictly ascending.")
        aids.append(km_tenth)
        last_aid = km_tenth

    return RaceMeta(
        race_key=entry.race_key,
        display_name_jpn=display_name_jpn,
        display_name_eng=display_name_eng,
        race_date=race_date,
        timezone=raw_timezone,
        distance_km=distance_km,
        gates=gates,
        aids=aids,
    )


def format_decimal(value: Decimal) -> str:
    text = format(value.normalize(), "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text or "0"


def mc_string_literal(text: str) -> str:
    escaped = (
        text.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
    )
    return f'"{escaped}"'


def render_template(template_path: Path, values: dict[str, str]) -> str:
    template = Template(template_path.read_text(encoding="utf-8"))
    return template.substitute(values)


def build_gates_body(gates: list[list[Any]]) -> str:
    rendered = []
    for point, day_offset, minute_of_day in gates:
        point_text = "GOAL" if point == GOAL_TOKEN else str(point)
        rendered.append(f"            [{point_text}, {day_offset}, {minute_of_day}]")
    return ",\n".join(rendered)


def build_aids_body(aids: list[int]) -> str:
    return ", ".join(str(value) for value in aids)


def write_outputs(entry: RaceEntry, race: RaceMeta) -> None:
    manifest_text = render_template(
        TEMPLATES_DIR / "manifest.xml.tpl",
        {
            "app_id": entry.app_id,
            "version": entry.version,
        },
    )
    strings_eng_text = render_template(
        TEMPLATES_DIR / "strings.xml.tpl",
        {"app_name": race.display_name_eng},
    )
    strings_jpn_text = render_template(
        TEMPLATES_DIR / "strings.xml.tpl",
        {"app_name": race.display_name_jpn},
    )
    generated_text = render_template(
        TEMPLATES_DIR / "GateRaceConfig.mc.tpl",
        {
            "race_key_literal": mc_string_literal(race.race_key),
            "race_name_jpn_literal": mc_string_literal(race.display_name_jpn),
            "race_name_eng_literal": mc_string_literal(race.display_name_eng),
            "race_distance_km": format_decimal(race.distance_km),
            "race_year": str(race.race_date.year),
            "race_month": str(race.race_date.month),
            "race_day": str(race.race_date.day),
            "race_timezone_literal": mc_string_literal(race.timezone),
            "gates_body": build_gates_body(race.gates),
            "aids_body": build_aids_body(race.aids),
        },
    )
    properties_text = (
        '<resources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">\n'
        "</resources>\n"
    )

    GENERATED_SOURCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    DIST_DIR.joinpath(entry.race_key).mkdir(parents=True, exist_ok=True)

    MANIFEST_PATH.write_text(manifest_text, encoding="utf-8")
    STRINGS_ENG_PATH.write_text(strings_eng_text, encoding="utf-8")
    STRINGS_JPN_PATH.write_text(strings_jpn_text, encoding="utf-8")
    PROPERTIES_PATH.write_text(properties_text, encoding="utf-8")
    GENERATED_SOURCE_PATH.write_text(generated_text, encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("race_key", help="Race key from race_defs/race_index.yml")
    return parser


def main() -> int:
    parser = build_parser()
    args = parser.parse_args()
    ensure_race_key(args.race_key, "race_key")
    entry = parse_index(args.race_key)
    race = parse_definition(entry)
    write_outputs(entry, race)
    print(
        f"Generated GateChecker race assets for {entry.race_key} "
        f"(app_id={entry.app_id}, version={entry.version})"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
