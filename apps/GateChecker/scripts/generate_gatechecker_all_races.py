#!/usr/bin/env python3
"""Generate the single-app GateChecker assets for all active races."""

from __future__ import annotations

import argparse
import sys

from gatechecker_defs import (
    APP_NAME_ENG,
    APP_NAME_JPN,
    GENERATED_SOURCE_PATH,
    GlobalAppConfig,
    MANIFEST_PATH,
    PROPERTIES_PATH,
    STRINGS_COMMON_ENG,
    STRINGS_COMMON_JPN,
    STRINGS_ENG_PATH,
    STRINGS_JPN_PATH,
    TEMPLATES_DIR,
    ValidationError,
    build_global_course_rows,
    build_global_properties_text,
    build_strings_text,
    load_index_entries,
    parse_race_definition,
    render_template,
    validate_unique_race_codes,
    write_supported_races_json,
)


def _resolve_global_app(global_app: GlobalAppConfig | None) -> GlobalAppConfig:
    if global_app is None:
        raise ValidationError("race_index.yml must define global_app for global builds.")
    return global_app


def _load_active_races():
    global_app, entries = load_index_entries()
    active_entries = [entry for entry in entries if entry.status == "active"]
    if not active_entries:
        raise ValidationError("No active races found in race_index.yml.")
    races = [parse_race_definition(entry) for entry in active_entries]
    validate_unique_race_codes(races)
    return _resolve_global_app(global_app), races


def write_outputs(global_app: GlobalAppConfig, races) -> None:
    manifest_text = render_template(
        TEMPLATES_DIR / "manifest.xml.tpl",
        {
            "app_id": global_app.app_id,
            "version": global_app.version,
        },
    )
    generated_text = render_template(
        TEMPLATES_DIR / "GateRaceConfigGlobal.mc.tpl",
        {"race_courses_body": build_global_course_rows(races)},
    )
    strings_eng_text = build_strings_text(APP_NAME_ENG, STRINGS_COMMON_ENG)
    strings_jpn_text = build_strings_text(APP_NAME_JPN, STRINGS_COMMON_JPN)
    properties_text = build_global_properties_text()

    GENERATED_SOURCE_PATH.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST_PATH.write_text(manifest_text, encoding="utf-8")
    STRINGS_ENG_PATH.write_text(strings_eng_text, encoding="utf-8")
    STRINGS_JPN_PATH.write_text(strings_jpn_text, encoding="utf-8")
    PROPERTIES_PATH.write_text(properties_text, encoding="utf-8")
    GENERATED_SOURCE_PATH.write_text(generated_text, encoding="utf-8")
    write_supported_races_json(races)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--include-non-active",
        action="store_true",
        help="Reserved for future use; active races are always used for now.",
    )
    return parser


def main() -> int:
    build_parser().parse_args()
    global_app, races = _load_active_races()
    write_outputs(global_app, races)
    print(
        f"Generated GateChecker global assets "
        f"(app_id={global_app.app_id}, version={global_app.version}, races={len(races)})"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except ValidationError as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        raise SystemExit(1)
