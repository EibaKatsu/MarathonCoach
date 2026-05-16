#!/usr/bin/env python3
"""Shared GateChecker race definition parsing and rendering helpers."""

from __future__ import annotations

import hashlib
import json
import os
import re
from dataclasses import dataclass
from datetime import date, datetime
from decimal import Decimal, InvalidOperation, ROUND_HALF_UP
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
GENERATED_JSON_DIR = APP_DIR / "generated"
SUPPORTED_RACES_JSON_PATH = GENERATED_JSON_DIR / "supported_races.json"
DIST_DIR = APP_DIR / "dist"

UUID_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)
RACE_ID_RE = re.compile(r"^[a-z0-9_]+$")
COURSE_ID_RE = re.compile(r"^[a-z0-9_]+$")
RACE_CODE_RE = re.compile(r"^[A-Z0-9]{3,10}-[A-Z0-9]{2,8}-[A-Z0-9]{4,6}$")
GOAL_TOKEN = "GOAL"
DEFAULT_SINGLE_COURSE_ID = "main"
DEFAULT_SINGLE_COURSE_NAME_JPN = "メインコース"
DEFAULT_SINGLE_COURSE_NAME_ENG = "Main Course"
KM_PER_MILE = Decimal("1.609344")
METERS_PER_KM = Decimal("1000")
RACE_CODE_SALT_ENV = "GATECHECKER_RACE_CODE_SALT"
APP_NAME_ENG = "Cutoff Guide"
APP_NAME_JPN = "関門ガイド"
STRINGS_COMMON_ENG = {
    "code_ok": "READY",
    "code_error": "CONFIG ERROR",
    "wait_dist": "WAIT START",
    "wait_time": "WAIT TIME",
    "no_gate": "NO GATE",
    "last": "LAST",
    "all_passed": "ALL PASSED",
    "pace_na": "PACE N/A",
    "pace_state_plenty": "PLENTY",
    "pace_state_ok": "OK",
    "pace_state_tight": "TIGHT",
    "pace_state_push": "PUSH",
    "pace_state_over": "OVER",
    "gate_label": "GATE",
    "cut_label": "CUT",
    "remain_label": "REMAIN",
    "left_label": "LEFT",
    "aid_label": "AID",
    "to_aid_label": "TO AID",
    "late_label": "LATE",
    "goal_label": "GOAL",
    "eta_label": "ETA",
    "pace_label": "PACE",
    "race_code_label": "Race Code",
    "race_code_not_found": "Not Found",
    "race_code_not_set": "Not Set",
    "check_app_settings": "Check app settings",
}
STRINGS_COMMON_JPN = {
    **STRINGS_COMMON_ENG,
    "race_code_not_found": "が見つかりません",
    "race_code_not_set": "が未設定です",
    "check_app_settings": "設定を確認してください",
}


class ValidationError(ValueError):
    """Raised when a race definition is invalid."""


@dataclass(frozen=True)
class LegacyBuildConfig:
    app_id: str
    version: str
    race_key: str


@dataclass(frozen=True)
class GlobalAppConfig:
    app_id: str
    version: str


@dataclass(frozen=True)
class RaceIndexEntry:
    race_id: str
    definition_path: Path
    status: str
    sample_free: bool
    region: str | None
    country: str | None
    category: str | None
    legacy_build: LegacyBuildConfig | None


@dataclass(frozen=True)
class CourseMeta:
    race_code: str
    course_id: str
    course_name_jpn: str
    course_name_eng: str
    distance_km: Decimal
    gates: list[list[Any]]
    aids: list[int]


@dataclass(frozen=True)
class RaceMeta:
    race_id: str
    display_name_jpn: str
    display_name_eng: str
    race_date: date
    timezone: str
    sample_free: bool
    region: str | None
    country: str | None
    category: str | None
    courses: list[CourseMeta]


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


def ensure_race_id(race_id: str, label: str) -> None:
    if not RACE_ID_RE.fullmatch(race_id):
        raise ValidationError(f"{label} must match [a-z0-9_]+, got: {race_id!r}")


def ensure_course_id(course_id: str, label: str) -> None:
    if not COURSE_ID_RE.fullmatch(course_id):
        raise ValidationError(f"{label} must match [a-z0-9_]+, got: {course_id!r}")


def ensure_uuid(text: str, label: str) -> None:
    if not UUID_RE.fullmatch(text):
        raise ValidationError(f"{label} must be a UUID, got: {text!r}")


def normalize_race_code(raw_code: str) -> str:
    text = raw_code.strip().upper()
    text = text.replace(" ", "").replace("\u3000", "")
    return text


def ensure_race_code(race_code: str, label: str) -> None:
    if not race_code:
        raise ValidationError(f"{label} must be a non-empty string.")
    if not RACE_CODE_RE.fullmatch(race_code):
        raise ValidationError(
            f"{label} must roughly match ABC26-F42-A7K3 format, got: {race_code!r}"
        )


def parse_decimal(raw: Any, label: str) -> Decimal:
    try:
        value = Decimal(str(raw))
    except (InvalidOperation, ValueError) as exc:
        raise ValidationError(f"{label} must be numeric, got: {raw!r}") from exc
    if value.is_nan():
        raise ValidationError(f"{label} must be numeric, got: {raw!r}")
    return value


def format_decimal(value: Decimal) -> str:
    text = format(value.normalize(), "f")
    if "." in text:
        text = text.rstrip("0").rstrip(".")
    return text or "0"


def distance_km_to_meter_int(distance_km: Decimal) -> int:
    distance_meters = (distance_km * METERS_PER_KM).quantize(
        Decimal("1"), rounding=ROUND_HALF_UP
    )
    return int(distance_meters)


def ensure_distance_field_xor(
    mapping: dict[str, Any], km_key: str, mi_key: str, label_prefix: str
) -> tuple[Any, Any]:
    raw_km = mapping.get(km_key)
    raw_mi = mapping.get(mi_key)
    has_km = raw_km is not None
    has_mi = raw_mi is not None
    if has_km and has_mi:
        raise ValidationError(
            f"{label_prefix}.{km_key} and {label_prefix}.{mi_key} may not both be set."
        )
    if not has_km and not has_mi:
        raise ValidationError(
            f"{label_prefix} must define either {label_prefix}.{km_key} or {label_prefix}.{mi_key}."
        )
    return raw_km, raw_mi


def parse_distance_input_km(
    mapping: dict[str, Any],
    km_key: str,
    mi_key: str,
    label_prefix: str,
    *,
    max_distance_km: Decimal | None = None,
    enforce_km_tenth: bool = False,
) -> Decimal:
    raw_km, raw_mi = ensure_distance_field_xor(mapping, km_key, mi_key, label_prefix)
    if raw_km is not None:
        distance_km = parse_decimal(raw_km, f"{label_prefix}.{km_key}")
    else:
        distance_mi = parse_decimal(raw_mi, f"{label_prefix}.{mi_key}")
        if distance_mi <= 0:
            raise ValidationError(f"{label_prefix}.{mi_key} must be > 0.")
        distance_km = distance_mi * KM_PER_MILE

    if distance_km <= 0:
        raise ValidationError(f"{label_prefix} distance must be > 0.")
    if max_distance_km is not None and distance_km > max_distance_km:
        raise ValidationError(
            f"{label_prefix} must be <= race distance ({format_decimal(max_distance_km)}km)."
        )
    if enforce_km_tenth:
        tenth = distance_km * Decimal("10")
        if tenth != tenth.to_integral_value():
            raise ValidationError(f"{label_prefix} must be aligned to 0.1km units.")
    return distance_km


def parse_optional_distance_input_km(
    mapping: dict[str, Any],
    km_key: str,
    mi_key: str,
    label_prefix: str,
) -> Decimal | None:
    raw_km = mapping.get(km_key)
    raw_mi = mapping.get(mi_key)
    if raw_km is None and raw_mi is None:
        return None
    return parse_distance_input_km(mapping, km_key, mi_key, label_prefix)


def parse_display_names(data: dict[str, Any], label_prefix: str) -> tuple[str, str]:
    display_name = data.get(label_prefix)
    if not isinstance(display_name, dict):
        raise ValidationError(f"{label_prefix} must be a mapping.")
    jpn = display_name.get("jpn")
    eng = display_name.get("eng")
    if not isinstance(jpn, str) or not jpn:
        raise ValidationError(f"{label_prefix}.jpn must be a non-empty string.")
    if not isinstance(eng, str) or not eng:
        raise ValidationError(f"{label_prefix}.eng must be a non-empty string.")
    return jpn, eng


def parse_race_header(data: dict[str, Any]) -> tuple[date, str, Decimal | None]:
    race = data.get("race")
    if not isinstance(race, dict):
        raise ValidationError("race must be a mapping.")
    raw_date = race.get("date")
    raw_timezone = race.get("timezone")
    if not isinstance(raw_date, str):
        raise ValidationError("race.date must be a string in yyyy/mm/dd format.")
    if not isinstance(raw_timezone, str) or not raw_timezone:
        raise ValidationError("race.timezone must be a non-empty string.")
    race_date = datetime.strptime(raw_date, "%Y/%m/%d").date()
    shared_distance_km = parse_optional_distance_input_km(
        race, "distance_km", "distance_mi", "race"
    )
    return race_date, raw_timezone, shared_distance_km


def parse_gates(
    raw_gates: Any,
    *,
    distance_km: Decimal,
    race_date: date,
    label_prefix: str,
) -> list[list[Any]]:
    if not isinstance(raw_gates, list) or not raw_gates:
        raise ValidationError(f"{label_prefix} must contain at least one item.")

    gates: list[list[Any]] = []
    last_point_km: Decimal | None = None
    last_cutoff: datetime | None = None
    goal_seen = False
    for index, raw_gate in enumerate(raw_gates):
        if not isinstance(raw_gate, dict):
            raise ValidationError(f"{label_prefix}[{index}] must be a mapping.")

        point = raw_gate.get("point")
        point_mi = raw_gate.get("point_mi")
        cutoff_raw = raw_gate.get("cutoff")
        if point is not None and point_mi is not None:
            raise ValidationError(
                f"{label_prefix}[{index}].point and {label_prefix}[{index}].point_mi may not both be set."
            )
        if not isinstance(cutoff_raw, str):
            raise ValidationError(f"{label_prefix}[{index}].cutoff must be a string.")
        cutoff_dt = datetime.strptime(cutoff_raw, "%Y/%m/%d %H:%M")
        cutoff_day_offset = (cutoff_dt.date() - race_date).days
        if cutoff_day_offset < 0:
            raise ValidationError(
                f"{label_prefix}[{index}].cutoff must not be before race.date."
            )
        cutoff_minute_of_day = (cutoff_dt.hour * 60) + cutoff_dt.minute
        if last_cutoff is not None and cutoff_dt <= last_cutoff:
            raise ValidationError(f"{label_prefix}[].cutoff must be strictly ascending.")
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

        point_km = parse_distance_input_km(
            raw_gate,
            "point",
            "point_mi",
            f"{label_prefix}[{index}]",
            max_distance_km=distance_km,
        )
        if last_point_km is not None and point_km <= last_point_km:
            raise ValidationError(f"{label_prefix} must be strictly ascending by distance.")
        point_meters = distance_km_to_meter_int(point_km)
        if gates and point_meters <= gates[-1][0]:
            raise ValidationError(
                f"{label_prefix} must remain strictly ascending after km/mi conversion."
            )
        gates.append([point_meters, cutoff_day_offset, cutoff_minute_of_day])
        last_point_km = point_km

    return gates


def parse_aids(
    raw_aids: Any,
    *,
    distance_km: Decimal,
    label_prefix: str,
) -> list[int]:
    if raw_aids is None:
        raw_aids = []
    if not isinstance(raw_aids, list):
        raise ValidationError(f"{label_prefix} must be a list.")

    aids: list[int] = []
    last_aid = None
    for index, raw_aid in enumerate(raw_aids):
        if not isinstance(raw_aid, dict):
            raise ValidationError(f"{label_prefix}[{index}] must be a mapping.")
        aid_distance_km = parse_distance_input_km(
            raw_aid,
            "km",
            "mi",
            f"{label_prefix}[{index}]",
            max_distance_km=distance_km,
        )
        aid_meters = distance_km_to_meter_int(aid_distance_km)
        if last_aid is not None and aid_meters <= last_aid:
            raise ValidationError(f"{label_prefix} must be strictly ascending by distance.")
        aids.append(aid_meters)
        last_aid = aid_meters
    return aids


def load_index_entries(
    index_path: Path = RACE_INDEX_PATH,
) -> tuple[GlobalAppConfig | None, list[RaceIndexEntry]]:
    index_data = load_yaml(index_path)
    raw_races = index_data.get("races")
    global_app = _parse_global_app(index_data.get("global_app"))

    if isinstance(raw_races, dict):
        entries = []
        for raw_race_id, raw_entry in raw_races.items():
            race_id = str(raw_race_id)
            ensure_race_id(race_id, "race_index key")
            if not isinstance(raw_entry, dict):
                raise ValidationError(f"races.{race_id} must be a mapping.")
            definition = raw_entry.get("definition")
            version = raw_entry.get("version")
            app_id = raw_entry.get("app_id")
            if not isinstance(definition, str) or not definition:
                raise ValidationError(f"races.{race_id}.definition must be a string.")
            if not isinstance(version, str) or not version:
                raise ValidationError(f"races.{race_id}.version must be a string.")
            if not isinstance(app_id, str) or not app_id:
                raise ValidationError(f"races.{race_id}.app_id must be a string.")
            ensure_uuid(app_id, f"races.{race_id}.app_id")
            entries.append(
                RaceIndexEntry(
                    race_id=race_id,
                    definition_path=RACE_DEFS_DIR / definition,
                    status="active",
                    sample_free=False,
                    region=None,
                    country=None,
                    category=None,
                    legacy_build=LegacyBuildConfig(
                        app_id=app_id,
                        version=version,
                        race_key=race_id,
                    ),
                )
            )
        return global_app, sorted(entries, key=lambda item: item.race_id)

    if not isinstance(raw_races, list) or not raw_races:
        raise ValidationError(f"{index_path} must define races.")

    entries: list[RaceIndexEntry] = []
    seen_race_ids: set[str] = set()
    for index, raw_entry in enumerate(raw_races):
        if not isinstance(raw_entry, dict):
            raise ValidationError(f"races[{index}] must be a mapping.")
        race_id = raw_entry.get("race_id")
        definition = raw_entry.get("file")
        if not isinstance(race_id, str) or not race_id:
            raise ValidationError(f"races[{index}].race_id must be a non-empty string.")
        ensure_race_id(race_id, f"races[{index}].race_id")
        if race_id in seen_race_ids:
            raise ValidationError(f"Duplicate race_id in race_index.yml: {race_id}")
        seen_race_ids.add(race_id)
        if not isinstance(definition, str) or not definition:
            raise ValidationError(f"races[{index}].file must be a non-empty string.")
        status = raw_entry.get("status")
        if not isinstance(status, str) or not status:
            raise ValidationError(f"races[{index}].status must be a non-empty string.")
        sample_free = bool(raw_entry.get("sample_free", False))
        raw_sort = raw_entry.get("sort")
        if raw_sort is not None and not isinstance(raw_sort, dict):
            raise ValidationError(f"races[{index}].sort must be a mapping when provided.")
        legacy_build = _parse_legacy_build(raw_entry.get("legacy"), race_id)
        entries.append(
            RaceIndexEntry(
                race_id=race_id,
                definition_path=RACE_DEFS_DIR / definition,
                status=status,
                sample_free=sample_free,
                region=_optional_mapping_string(raw_sort, "region"),
                country=_optional_mapping_string(raw_sort, "country"),
                category=_optional_mapping_string(raw_sort, "category"),
                legacy_build=legacy_build,
            )
        )
    return global_app, entries


def _parse_global_app(raw_global_app: Any) -> GlobalAppConfig | None:
    if raw_global_app is None:
        return None
    if not isinstance(raw_global_app, dict):
        raise ValidationError("global_app must be a mapping.")
    app_id = raw_global_app.get("app_id")
    version = raw_global_app.get("version")
    if not isinstance(app_id, str) or not app_id:
        raise ValidationError("global_app.app_id must be a non-empty string.")
    if not isinstance(version, str) or not version:
        raise ValidationError("global_app.version must be a non-empty string.")
    ensure_uuid(app_id, "global_app.app_id")
    return GlobalAppConfig(app_id=app_id, version=version)


def _parse_legacy_build(raw_legacy: Any, race_id: str) -> LegacyBuildConfig | None:
    if raw_legacy is None:
        return None
    if not isinstance(raw_legacy, dict):
        raise ValidationError(f"legacy for {race_id} must be a mapping.")
    app_id = raw_legacy.get("app_id")
    version = raw_legacy.get("version")
    race_key = raw_legacy.get("race_key", race_id)
    if not isinstance(app_id, str) or not app_id:
        raise ValidationError(f"legacy.app_id for {race_id} must be a string.")
    if not isinstance(version, str) or not version:
        raise ValidationError(f"legacy.version for {race_id} must be a string.")
    if not isinstance(race_key, str) or not race_key:
        raise ValidationError(f"legacy.race_key for {race_id} must be a string.")
    ensure_uuid(app_id, f"legacy.app_id for {race_id}")
    ensure_race_id(race_key, f"legacy.race_key for {race_id}")
    return LegacyBuildConfig(app_id=app_id, version=version, race_key=race_key)


def _optional_mapping_string(mapping: Any, key: str) -> str | None:
    if not isinstance(mapping, dict):
        return None
    value = mapping.get(key)
    if value is None:
        return None
    if not isinstance(value, str) or not value:
        raise ValidationError(f"sort.{key} must be a non-empty string when provided.")
    return value


def find_race_entry(identifier: str, entries: list[RaceIndexEntry]) -> RaceIndexEntry:
    matches = [
        entry
        for entry in entries
        if entry.race_id == identifier
        or (
            entry.legacy_build is not None and entry.legacy_build.race_key == identifier
        )
    ]
    if not matches:
        raise ValidationError(f"race not found in race_index.yml: {identifier}")
    if len(matches) > 1:
        raise ValidationError(f"multiple races matched identifier: {identifier}")
    return matches[0]


def parse_race_definition(entry: RaceIndexEntry) -> RaceMeta:
    data = load_yaml(entry.definition_path)
    definition_race_id = data.get("race_id")
    legacy_race_key = data.get("race_key")
    if definition_race_id is None:
        definition_race_id = legacy_race_key
    if definition_race_id != entry.race_id:
        raise ValidationError(
            f"Definition race_id mismatch: {definition_race_id!r} != {entry.race_id!r}"
        )
    ensure_race_id(entry.race_id, "definition race_id")

    display_name_jpn, display_name_eng = parse_display_names(data, "display_name")
    race_date, timezone, shared_distance_km = parse_race_header(data)
    meta = data.get("meta")
    if meta is not None and not isinstance(meta, dict):
        raise ValidationError("meta must be a mapping when provided.")
    meta = meta or {}

    if data.get("courses") is None:
        courses = _parse_single_course_definition(
            data,
            race_id=entry.race_id,
            display_name_eng=display_name_eng,
            race_date=race_date,
            shared_distance_km=shared_distance_km,
            meta=meta,
        )
    else:
        courses = _parse_multi_course_definition(
            data,
            race_id=entry.race_id,
            display_name_eng=display_name_eng,
            race_date=race_date,
            shared_distance_km=shared_distance_km,
            meta=meta,
        )

    return RaceMeta(
        race_id=entry.race_id,
        display_name_jpn=display_name_jpn,
        display_name_eng=display_name_eng,
        race_date=race_date,
        timezone=timezone,
        sample_free=bool(meta.get("sample_free", entry.sample_free)),
        region=_optional_mapping_string(meta, "region") or entry.region,
        country=_optional_mapping_string(meta, "country") or entry.country,
        category=_optional_mapping_string(meta, "category") or entry.category,
        courses=courses,
    )


def _parse_single_course_definition(
    data: dict[str, Any],
    *,
    race_id: str,
    display_name_eng: str,
    race_date: date,
    shared_distance_km: Decimal | None,
    meta: dict[str, Any],
) -> list[CourseMeta]:
    if shared_distance_km is None:
        raise ValidationError(
            "race.distance_km or race.distance_mi is required when courses is not defined."
        )
    course_id = DEFAULT_SINGLE_COURSE_ID
    gates = parse_gates(
        data.get("gates"),
        distance_km=shared_distance_km,
        race_date=race_date,
        label_prefix="gates",
    )
    aids = parse_aids(
        data.get("aids", []),
        distance_km=shared_distance_km,
        label_prefix="aids",
    )
    race_code = _resolve_race_code(
        raw_race_code=data.get("race_code"),
        race_id=race_id,
        course_id=course_id,
        display_name_eng=display_name_eng,
        course_label=None,
        distance_km=shared_distance_km,
        race_date=race_date,
        meta=meta,
    )
    return [
        CourseMeta(
            race_code=race_code,
            course_id=course_id,
            course_name_jpn=DEFAULT_SINGLE_COURSE_NAME_JPN,
            course_name_eng=DEFAULT_SINGLE_COURSE_NAME_ENG,
            distance_km=shared_distance_km,
            gates=gates,
            aids=aids,
        )
    ]


def _parse_multi_course_definition(
    data: dict[str, Any],
    *,
    race_id: str,
    display_name_eng: str,
    race_date: date,
    shared_distance_km: Decimal | None,
    meta: dict[str, Any],
) -> list[CourseMeta]:
    raw_courses = data.get("courses")
    if not isinstance(raw_courses, list) or not raw_courses:
        raise ValidationError("courses must contain at least one item.")

    courses: list[CourseMeta] = []
    seen_course_ids: set[str] = set()
    seen_race_codes: set[str] = set()
    for index, raw_course in enumerate(raw_courses):
        if not isinstance(raw_course, dict):
            raise ValidationError(f"courses[{index}] must be a mapping.")

        course_id = _resolve_course_id(raw_course, index)
        if course_id in seen_course_ids:
            raise ValidationError(f"Duplicate course_id: {course_id}")
        seen_course_ids.add(course_id)

        course_name_jpn, course_name_eng = _resolve_course_names(raw_course, index)
        course_distance_km = parse_optional_distance_input_km(
            raw_course, "distance_km", "distance_mi", f"courses[{index}]"
        )
        if course_distance_km is None:
            course_distance_km = shared_distance_km
        if course_distance_km is None:
            raise ValidationError(
                f"courses[{index}] must define distance_km or distance_mi when race distance is omitted."
            )

        gates = parse_gates(
            raw_course.get("gates"),
            distance_km=course_distance_km,
            race_date=race_date,
            label_prefix=f"courses[{index}].gates",
        )
        aids = parse_aids(
            raw_course.get("aids", []),
            distance_km=course_distance_km,
            label_prefix=f"courses[{index}].aids",
        )
        race_code = _resolve_race_code(
            raw_race_code=raw_course.get("race_code"),
            race_id=race_id,
            course_id=course_id,
            display_name_eng=display_name_eng,
            course_label=raw_course.get("course_label"),
            distance_km=course_distance_km,
            race_date=race_date,
            meta=meta,
        )
        if race_code in seen_race_codes:
            raise ValidationError(f"Duplicate race_code in {race_id}: {race_code}")
        seen_race_codes.add(race_code)

        courses.append(
            CourseMeta(
                race_code=race_code,
                course_id=course_id,
                course_name_jpn=course_name_jpn,
                course_name_eng=course_name_eng,
                distance_km=course_distance_km,
                gates=gates,
                aids=aids,
            )
        )
    return courses


def _resolve_course_id(raw_course: dict[str, Any], index: int) -> str:
    course_id = raw_course.get("course_id")
    if course_id is None:
        course_id = raw_course.get("courseCode")
    if not isinstance(course_id, str) or not course_id:
        raise ValidationError(
            f"courses[{index}].course_id or courses[{index}].courseCode must be a non-empty string."
        )
    ensure_course_id(course_id, f"courses[{index}].course_id")
    return course_id


def _resolve_course_names(raw_course: dict[str, Any], index: int) -> tuple[str, str]:
    course_name = raw_course.get("course_name")
    if isinstance(course_name, dict):
        return parse_display_names(raw_course, "course_name")

    jpn = raw_course.get("courseNameJa")
    eng = raw_course.get("courseNameEn")
    if not isinstance(jpn, str) or not jpn:
        raise ValidationError(
            f"courses[{index}].course_name.jpn or courses[{index}].courseNameJa must be a non-empty string."
        )
    if not isinstance(eng, str) or not eng:
        raise ValidationError(
            f"courses[{index}].course_name.eng or courses[{index}].courseNameEn must be a non-empty string."
        )
    return jpn, eng


def _resolve_race_code(
    *,
    raw_race_code: Any,
    race_id: str,
    course_id: str,
    display_name_eng: str,
    course_label: Any,
    distance_km: Decimal,
    race_date: date,
    meta: dict[str, Any],
) -> str:
    if raw_race_code is not None:
        if not isinstance(raw_race_code, str):
            raise ValidationError(
                f"race_code for {race_id}/{course_id} must be a string when provided."
            )
        race_code = normalize_race_code(raw_race_code)
        ensure_race_code(race_code, f"race_code for {race_id}/{course_id}")
        return race_code

    explicit_race_abbr = meta.get("race_abbr")
    if explicit_race_abbr is not None and not isinstance(explicit_race_abbr, str):
        raise ValidationError("meta.race_abbr must be a string when provided.")
    if course_label is not None and not isinstance(course_label, str):
        raise ValidationError(f"course_label for {race_id}/{course_id} must be a string.")
    return generate_race_code(
        race_id=race_id,
        course_id=course_id,
        race_abbr=str(explicit_race_abbr) if explicit_race_abbr else None,
        year=race_date.year,
        course_label=str(course_label) if course_label else None,
        distance_km=distance_km,
        display_name_eng=display_name_eng,
    )


def generate_race_code(
    *,
    race_id: str,
    course_id: str,
    year: int,
    race_abbr: str | None,
    course_label: str | None,
    distance_km: Decimal | None,
    display_name_eng: str,
    salt: str | None = None,
) -> str:
    abbr = normalize_code_segment(
        race_abbr or derive_race_abbr(race_id, display_name_eng), max_length=8
    )
    label = normalize_code_segment(
        course_label or derive_course_label(course_id, distance_km), max_length=8
    )
    if not abbr:
        raise ValidationError(f"Could not derive race_abbr for {race_id}.")
    if not label:
        raise ValidationError(f"Could not derive course label for {race_id}/{course_id}.")
    if salt is None:
        salt = os.environ.get(RACE_CODE_SALT_ENV, "")

    digest = hashlib.sha1(f"{race_id}:{course_id}:{salt}".encode("utf-8")).digest()
    check = _to_base36(int.from_bytes(digest[:5], "big"), 4)
    race_code = f"{abbr}{year % 100:02d}-{label}-{check}"
    ensure_race_code(race_code, f"generated race_code for {race_id}/{course_id}")
    return race_code


def derive_race_abbr(race_id: str, display_name_eng: str) -> str:
    if display_name_eng:
        english_tokens = [
            normalize_code_segment(token, max_length=8)
            for token in re.split(r"[^A-Za-z0-9]+", display_name_eng)
            if token
        ]
        english_tokens = [
            token
            for token in english_tokens
            if token and token not in {"MARATHON", "ULTRA", "INTERNATIONAL", "THE"}
        ]
        if english_tokens:
            token = english_tokens[0]
            return token[:4]

    normalized_race_id = re.sub(r"^\d{8}_", "", race_id)
    tokens = [
        normalize_code_segment(token, max_length=8)
        for token in normalized_race_id.split("_")
        if token
    ]
    tokens = [
        token
        for token in tokens
        if token and token not in {"MARATHON", "ULTRA", "INTERNATIONAL", "THE"}
    ]
    if tokens:
        return tokens[0][:4]
    return "RACE"


def derive_course_label(course_id: str, distance_km: Decimal | None) -> str:
    if distance_km is not None:
        if abs(distance_km - Decimal("42.195")) <= Decimal("0.01"):
            return "F42"
        if abs(distance_km - Decimal("21.0975")) <= Decimal("0.01"):
            return "H21"
        if distance_km == distance_km.to_integral_value():
            return f"{int(distance_km)}K"
        quantized = distance_km.quantize(Decimal("0.1"))
        return normalize_code_segment(f"{format_decimal(quantized)}K", max_length=8)
    return normalize_code_segment(course_id, max_length=8)


def normalize_code_segment(text: str, *, max_length: int) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9]", "", text.upper())
    return cleaned[:max_length]


def _to_base36(value: int, width: int) -> str:
    alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    chars: list[str] = []
    current = value
    for _ in range(width):
        chars.append(alphabet[current % 36])
        current //= 36
    return "".join(reversed(chars))


def validate_unique_race_codes(races: list[RaceMeta]) -> None:
    seen_codes: dict[str, str] = {}
    for race in races:
        for course in race.courses:
            owner = f"{race.race_id}/{course.course_id}"
            if course.race_code in seen_codes:
                raise ValidationError(
                    f"Duplicate race_code {course.race_code} for {owner} and {seen_codes[course.race_code]}"
                )
            seen_codes[course.race_code] = owner


def render_template(template_path: Path, values: dict[str, str]) -> str:
    template = Template(template_path.read_text(encoding="utf-8"))
    return template.substitute(values)


def mc_string_literal(text: str) -> str:
    escaped = (
        text.replace("\\", "\\\\")
        .replace('"', '\\"')
        .replace("\n", "\\n")
    )
    return f'"{escaped}"'


def xml_escape(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def build_legacy_courses_body(courses: list[CourseMeta]) -> str:
    rendered = []
    for course in courses:
        rendered.append(
            "            [\n"
            f"                {mc_string_literal(course.course_id)},\n"
            f"                {mc_string_literal(course.course_name_jpn)},\n"
            f"                {mc_string_literal(course.course_name_eng)},\n"
            f"                {format_decimal(course.distance_km)},\n"
            "                [\n"
            f"{build_gates_body(course.gates, '                    ')}\n"
            "                ],\n"
            f"                [{build_aids_body(course.aids)}]\n"
            "            ]"
        )
    return ",\n".join(rendered)


def build_global_course_rows(races: list[RaceMeta]) -> str:
    rendered = []
    for race in races:
        for course in race.courses:
            rendered.append(
                "            [\n"
                f"                {mc_string_literal(course.race_code)},\n"
                f"                {mc_string_literal(race.race_id)},\n"
                f"                {mc_string_literal(course.course_id)},\n"
                f"                {mc_string_literal(race.display_name_jpn)},\n"
                f"                {mc_string_literal(race.display_name_eng)},\n"
                f"                {mc_string_literal(course.course_name_jpn)},\n"
                f"                {mc_string_literal(course.course_name_eng)},\n"
                f"                {race.race_date.year},\n"
                f"                {race.race_date.month},\n"
                f"                {race.race_date.day},\n"
                f"                {mc_string_literal(race.timezone)},\n"
                f"                {format_decimal(course.distance_km)},\n"
                "                [\n"
                f"{build_gates_body(course.gates, '                    ')}\n"
                "                ],\n"
                f"                [{build_aids_body(course.aids)}]\n"
                "            ]"
            )
    return ",\n".join(rendered)


def build_gates_body(gates: list[list[Any]], indent: str) -> str:
    rendered = []
    for point, day_offset, minute_of_day in gates:
        point_text = "GOAL" if point == GOAL_TOKEN else str(point)
        rendered.append(f"{indent}[{point_text}, {day_offset}, {minute_of_day}]")
    return ",\n".join(rendered)


def build_aids_body(aids: list[int]) -> str:
    return ", ".join(str(value) for value in aids)


def build_global_properties_text() -> str:
    return (
        '<resources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">\n'
        "    <properties>\n"
        '        <property id="raceCode" type="string"></property>\n'
        "    </properties>\n"
        "\n"
        "    <settings>\n"
        '        <setting propertyKey="@Properties.raceCode" title="Race Code / レースコード">\n'
        '            <settingConfig type="alphaNumeric" maxLength="24" required="false" />\n'
        "        </setting>\n"
        "    </settings>\n"
        "</resources>\n"
    )


def build_strings_text(app_name: str, strings: dict[str, str]) -> str:
    return render_template(
        TEMPLATES_DIR / "strings.xml.tpl",
        {"app_name": app_name, **strings},
    )


def build_supported_races_payload(races: list[RaceMeta]) -> list[dict[str, Any]]:
    payload: list[dict[str, Any]] = []
    for race in races:
        payload.append(
            {
                "race_id": race.race_id,
                "display_name": {
                    "eng": race.display_name_eng,
                    "jpn": race.display_name_jpn,
                },
                "country": race.country,
                "region": race.region,
                "category": race.category,
                "sample_free": race.sample_free,
                "courses": [
                    {
                        "course_id": course.course_id,
                        "course_name": {
                            "eng": course.course_name_eng,
                            "jpn": course.course_name_jpn,
                        },
                        "race_code": course.race_code,
                        "distance_meters": distance_km_to_meter_int(course.distance_km),
                    }
                    for course in race.courses
                ],
            }
        )
    return payload


def write_supported_races_json(races: list[RaceMeta]) -> None:
    GENERATED_JSON_DIR.mkdir(parents=True, exist_ok=True)
    SUPPORTED_RACES_JSON_PATH.write_text(
        json.dumps(build_supported_races_payload(races), ensure_ascii=False, indent=2)
        + "\n",
        encoding="utf-8",
    )
