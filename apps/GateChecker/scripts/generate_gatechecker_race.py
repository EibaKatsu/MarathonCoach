#!/usr/bin/env python3
"""Generate GateChecker race-specific assets from YAML definitions."""

from __future__ import annotations

import argparse
import os
import re
import sys
import uuid
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
DIST_DIR = APP_DIR / "dist"

RACE_KEY_RE = re.compile(r"^[a-z0-9_]+$")
UUID_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
)
COURSE_CODE_RE = re.compile(r"^[a-z0-9_]+$")
GOAL_TOKEN = "GOAL"
DEFAULT_SINGLE_COURSE_CODE = "main"
DEFAULT_SINGLE_COURSE_NAME_JPN = "メインコース"
DEFAULT_SINGLE_COURSE_NAME_ENG = "Main Course"
COURSE_OVERRIDE_ENV = "GATECHECKER_DEFAULT_COURSE_CODE_OVERRIDE"
APP_NAME_ENG = "Marathon Cutoff Guide"
APP_NAME_JPN = "関門ガイド"
KM_PER_MILE = Decimal("1.609344")
METERS_PER_KM = Decimal("1000")
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
}
STRINGS_COMMON_JPN = dict(STRINGS_COMMON_ENG)


class ValidationError(ValueError):
    """Raised when a race definition is invalid."""


@dataclass(frozen=True)
class RaceEntry:
    race_key: str
    app_id: str
    version: str
    definition_path: Path


@dataclass(frozen=True)
class CourseMeta:
    course_code: str
    course_name_jpn: str
    course_name_eng: str
    distance_km: Decimal
    gates: list[list[Any]]
    aids: list[int]


@dataclass(frozen=True)
class RaceMeta:
    race_key: str
    display_name_jpn: str
    display_name_eng: str
    race_date: date
    timezone: str
    default_course_code: str
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


def ensure_race_key(race_key: str, label: str) -> None:
    if not RACE_KEY_RE.fullmatch(race_key):
        raise ValidationError(
            f"{label} must match [a-z0-9_]+, got: {race_key!r}"
        )


def ensure_course_code(course_code: str, label: str) -> None:
    if not COURSE_CODE_RE.fullmatch(course_code):
        raise ValidationError(
            f"{label} must match [a-z0-9_]+, got: {course_code!r}"
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
        if enforce_km_tenth:
            parse_tenth_km(raw_km, f"{label_prefix}.{km_key}", max_distance_km)
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


def distance_km_to_meter_int(distance_km: Decimal) -> int:
    distance_meters = (distance_km * METERS_PER_KM).quantize(
        Decimal("1"), rounding=ROUND_HALF_UP
    )
    return int(distance_meters)


def parse_display_names(data: dict[str, Any]) -> tuple[str, str]:
    display_name = data.get("display_name")
    if not isinstance(display_name, dict):
        raise ValidationError("display_name must be a mapping.")
    display_name_jpn = display_name.get("jpn")
    display_name_eng = display_name.get("eng")
    if not isinstance(display_name_jpn, str) or not display_name_jpn:
        raise ValidationError("display_name.jpn must be a non-empty string.")
    if not isinstance(display_name_eng, str) or not display_name_eng:
        raise ValidationError("display_name.eng must be a non-empty string.")
    return display_name_jpn, display_name_eng


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
        race,
        "distance_km",
        "distance_mi",
        "race",
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
            if point_mi is not None:
                raise ValidationError(
                    f"{label_prefix}[{index}].point and {label_prefix}[{index}].point_mi may not both be set."
                )
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
            enforce_km_tenth=True,
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
            enforce_km_tenth=True,
        )
        aid_meters = distance_km_to_meter_int(aid_distance_km)
        if last_aid is not None and aid_meters <= last_aid:
            raise ValidationError(f"{label_prefix} must be strictly ascending by distance.")
        aids.append(aid_meters)
        last_aid = aid_meters

    return aids


def resolve_default_course_code(
    course_codes: list[str],
    requested_default: str | None,
) -> str:
    if not course_codes:
        raise ValidationError("At least one course is required.")

    env_override = _normalize_optional_string_value(os.environ.get(COURSE_OVERRIDE_ENV))
    if env_override is not None:
        ensure_course_code(env_override, COURSE_OVERRIDE_ENV)
        if env_override not in course_codes:
            raise ValidationError(
                f"{COURSE_OVERRIDE_ENV} must match one of {course_codes}, got: {env_override!r}"
            )
        return env_override

    if requested_default is not None:
        ensure_course_code(requested_default, "defaultCourseCode")
        if requested_default not in course_codes:
            raise ValidationError(
                f"defaultCourseCode must match one of {course_codes}, got: {requested_default!r}"
            )
        return requested_default

    return course_codes[0]


def _normalize_optional_string_value(raw: str | None) -> str | None:
    if raw is None:
        return None
    value = raw.strip()
    if not value:
        return None
    return value
def parse_single_course_definition(
    data: dict[str, Any],
    *,
    race_date: date,
    shared_distance_km: Decimal | None,
) -> tuple[str, list[CourseMeta]]:
    if shared_distance_km is None:
        raise ValidationError(
            "race.distance_km or race.distance_mi is required when courses is not defined."
        )

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
    course = CourseMeta(
        course_code=DEFAULT_SINGLE_COURSE_CODE,
        course_name_jpn=DEFAULT_SINGLE_COURSE_NAME_JPN,
        course_name_eng=DEFAULT_SINGLE_COURSE_NAME_ENG,
        distance_km=shared_distance_km,
        gates=gates,
        aids=aids,
    )
    return DEFAULT_SINGLE_COURSE_CODE, [course]


def parse_multi_course_definition(
    data: dict[str, Any],
    *,
    race_date: date,
    shared_distance_km: Decimal | None,
) -> tuple[str, list[CourseMeta]]:
    raw_courses = data.get("courses")
    if not isinstance(raw_courses, list) or not raw_courses:
        raise ValidationError("courses must contain at least one item.")

    courses: list[CourseMeta] = []
    seen_course_codes: set[str] = set()
    for index, raw_course in enumerate(raw_courses):
        if not isinstance(raw_course, dict):
            raise ValidationError(f"courses[{index}] must be a mapping.")

        raw_course_code = raw_course.get("courseCode")
        raw_course_name_jpn = raw_course.get("courseNameJa")
        raw_course_name_eng = raw_course.get("courseNameEn")
        if not isinstance(raw_course_code, str) or not raw_course_code:
            raise ValidationError(f"courses[{index}].courseCode must be a non-empty string.")
        ensure_course_code(raw_course_code, f"courses[{index}].courseCode")
        if raw_course_code in seen_course_codes:
            raise ValidationError(f"Duplicate courseCode: {raw_course_code}")
        seen_course_codes.add(raw_course_code)

        if not isinstance(raw_course_name_jpn, str) or not raw_course_name_jpn:
            raise ValidationError(f"courses[{index}].courseNameJa must be a non-empty string.")
        if not isinstance(raw_course_name_eng, str) or not raw_course_name_eng:
            raise ValidationError(f"courses[{index}].courseNameEn must be a non-empty string.")

        course_distance_km = parse_optional_distance_input_km(
            raw_course,
            "distance_km",
            "distance_mi",
            f"courses[{index}]",
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
        courses.append(
            CourseMeta(
                course_code=raw_course_code,
                course_name_jpn=raw_course_name_jpn,
                course_name_eng=raw_course_name_eng,
                distance_km=course_distance_km,
                gates=gates,
                aids=aids,
            )
        )

    raw_default_course_code = data.get("defaultCourseCode")
    if raw_default_course_code is not None and not isinstance(raw_default_course_code, str):
        raise ValidationError("defaultCourseCode must be a string when provided.")
    requested_default = _normalize_optional_string_value(raw_default_course_code)
    default_course_code = resolve_default_course_code(
        [course.course_code for course in courses],
        requested_default,
    )
    return default_course_code, courses


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

    display_name_jpn, display_name_eng = parse_display_names(data)
    race_date, timezone, shared_distance_km = parse_race_header(data)

    if data.get("courses") is None:
        default_course_code, courses = parse_single_course_definition(
            data,
            race_date=race_date,
            shared_distance_km=shared_distance_km,
        )
    else:
        default_course_code, courses = parse_multi_course_definition(
            data,
            race_date=race_date,
            shared_distance_km=shared_distance_km,
        )

    return RaceMeta(
        race_key=entry.race_key,
        display_name_jpn=display_name_jpn,
        display_name_eng=display_name_eng,
        race_date=race_date,
        timezone=timezone,
        default_course_code=default_course_code,
        courses=courses,
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


def build_gates_body(gates: list[list[Any]], indent: str) -> str:
    rendered = []
    for point, day_offset, minute_of_day in gates:
        point_text = "GOAL" if point == GOAL_TOKEN else str(point)
        rendered.append(
            f"{indent}[{point_text}, {day_offset}, {minute_of_day}]"
        )
    return ",\n".join(rendered)


def build_aids_body(aids: list[int]) -> str:
    return ", ".join(str(value) for value in aids)


def build_courses_body(courses: list[CourseMeta]) -> str:
    rendered = []
    for course in courses:
        rendered.append(
            "            [\n"
            f"                {mc_string_literal(course.course_code)},\n"
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


def get_default_course_index(race: RaceMeta) -> int:
    for index, course in enumerate(race.courses):
        if course.course_code == race.default_course_code:
            return index
    return 0


def build_course_setting_label(course: CourseMeta) -> str:
    if course.course_name_jpn == course.course_name_eng:
        return course.course_name_jpn
    return f"{course.course_name_jpn} / {course.course_name_eng}"


def build_properties_text(race: RaceMeta) -> str:
    if len(race.courses) <= 1:
        return (
            '<resources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
            'xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">\n'
            "</resources>\n"
        )

    default_course_index = get_default_course_index(race)
    list_entries = "\n".join(
        f'                <listEntry value="{index}">'
        f"{xml_escape(build_course_setting_label(course))}</listEntry>"
        for index, course in enumerate(race.courses)
    )
    return (
        '<resources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">\n'
        "    <properties>\n"
        f'        <property id="courseCode" type="string">{xml_escape(race.default_course_code)}</property>\n'
        f'        <property id="courseIndex" type="number">{default_course_index}</property>\n'
        "    </properties>\n"
        "\n"
        "    <settings>\n"
        '        <setting propertyKey="@Properties.courseIndex" title="Course / コース">\n'
        '            <settingConfig type="list">\n'
        f"{list_entries}\n"
        "            </settingConfig>\n"
        "        </setting>\n"
        "    </settings>\n"
        "</resources>\n"
    )


def xml_escape(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


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
        {"app_name": APP_NAME_ENG, **STRINGS_COMMON_ENG},
    )
    strings_jpn_text = render_template(
        TEMPLATES_DIR / "strings.xml.tpl",
        {"app_name": APP_NAME_JPN, **STRINGS_COMMON_JPN},
    )
    generated_text = render_template(
        TEMPLATES_DIR / "GateRaceConfig.mc.tpl",
        {
            "race_key_literal": mc_string_literal(race.race_key),
            "race_name_jpn_literal": mc_string_literal(race.display_name_jpn),
            "race_name_eng_literal": mc_string_literal(race.display_name_eng),
            "race_year": str(race.race_date.year),
            "race_month": str(race.race_date.month),
            "race_day": str(race.race_date.day),
            "race_timezone_literal": mc_string_literal(race.timezone),
            "default_course_code_literal": mc_string_literal(race.default_course_code),
            "courses_body": build_courses_body(race.courses),
        },
    )
    properties_text = build_properties_text(race)

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
        f"(app_id={entry.app_id}, version={entry.version}, courses={len(race.courses)})"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
