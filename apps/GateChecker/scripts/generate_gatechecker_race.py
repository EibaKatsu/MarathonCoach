#!/usr/bin/env python3
"""Generate legacy race-specific GateChecker assets from YAML definitions."""

from __future__ import annotations

import argparse
import sys

from gatechecker_defs import (
    APP_NAME_ENG,
    APP_NAME_JPN,
    DIST_DIR,
    GENERATED_SOURCE_PATH,
    MANIFEST_PATH,
    PROPERTIES_PATH,
    STRINGS_COMMON_ENG,
    STRINGS_COMMON_JPN,
    STRINGS_ENG_PATH,
    STRINGS_JPN_PATH,
    TEMPLATES_DIR,
    ValidationError,
    RaceMeta,
    build_legacy_courses_body,
    build_strings_text,
    find_race_entry,
    load_index_entries,
    mc_string_literal,
    parse_race_definition,
    render_template,
)


def build_properties_text(race: RaceMeta) -> str:
    if len(race.courses) <= 1:
        return (
            '<resources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
            'xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">\n'
            "</resources>\n"
        )

    list_entries = "\n".join(
        f'                <listEntry value="{index}">{_build_course_setting_label(course)}</listEntry>'
        for index, course in enumerate(race.courses)
    )
    return (
        '<resources xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:noNamespaceSchemaLocation="https://developer.garmin.com/downloads/connect-iq/resources.xsd">\n'
        "    <properties>\n"
        f'        <property id="courseCode" type="string">{race.courses[0].course_id}</property>\n'
        '        <property id="courseIndex" type="number">0</property>\n'
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


def _build_course_setting_label(course) -> str:
    label = course.course_name_jpn
    if course.course_name_jpn != course.course_name_eng:
        label = f"{course.course_name_jpn} / {course.course_name_eng}"
    return _xml_escape(label)


def _xml_escape(text: str) -> str:
    return (
        text.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace('"', "&quot;")
        .replace("'", "&apos;")
    )


def write_outputs(app_id: str, version: str, race: RaceMeta, dist_key: str) -> None:
    manifest_text = render_template(
        TEMPLATES_DIR / "manifest.xml.tpl",
        {
            "app_id": app_id,
            "version": version,
        },
    )
    generated_text = render_template(
        TEMPLATES_DIR / "GateRaceConfig.mc.tpl",
        {
            "race_key_literal": mc_string_literal(race.race_id),
            "race_name_jpn_literal": mc_string_literal(race.display_name_jpn),
            "race_name_eng_literal": mc_string_literal(race.display_name_eng),
            "race_year": str(race.race_date.year),
            "race_month": str(race.race_date.month),
            "race_day": str(race.race_date.day),
            "race_timezone_literal": mc_string_literal(race.timezone),
            "default_course_code_literal": mc_string_literal(race.courses[0].course_id),
            "courses_body": build_legacy_courses_body(race.courses),
        },
    )
    strings_eng_text = build_strings_text(APP_NAME_ENG, STRINGS_COMMON_ENG)
    strings_jpn_text = build_strings_text(APP_NAME_JPN, STRINGS_COMMON_JPN)
    properties_text = build_properties_text(race)

    GENERATED_SOURCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    DIST_DIR.joinpath(dist_key).mkdir(parents=True, exist_ok=True)

    MANIFEST_PATH.write_text(manifest_text, encoding="utf-8")
    STRINGS_ENG_PATH.write_text(strings_eng_text, encoding="utf-8")
    STRINGS_JPN_PATH.write_text(strings_jpn_text, encoding="utf-8")
    PROPERTIES_PATH.write_text(properties_text, encoding="utf-8")
    GENERATED_SOURCE_PATH.write_text(generated_text, encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument("race_key", help="Race identifier from race_defs/race_index.yml")
    return parser


def main() -> int:
    args = build_parser().parse_args()
    _, entries = load_index_entries()
    entry = find_race_entry(args.race_key, entries)
    if entry.legacy_build is None:
        raise ValidationError(
            f"Legacy per-race build metadata is not available for {entry.race_id}."
        )

    race = parse_race_definition(entry)
    write_outputs(
        app_id=entry.legacy_build.app_id,
        version=entry.legacy_build.version,
        race=race,
        dist_key=entry.legacy_build.race_key,
    )
    print(
        f"Generated GateChecker race assets for {entry.race_id} "
        f"(legacy_key={entry.legacy_build.race_key}, courses={len(race.courses)})"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
