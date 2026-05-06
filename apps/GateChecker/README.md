# GateChecker

GateChecker is a separate Connect IQ data field app that lives alongside MarathonCoach in the same repository. This app now assumes race-specific builds: each race gets its own YAML definition, app ID, generated manifest, generated strings, and embedded gate/AID data.

One race can contain one or more `courses`. This is used for wave starts, weather/course-change patterns, and distance variants such as `100K / 70K / 50K`.

Distance display follows the watch's distance unit setting:

- `Metric` shows `km`
- `Statute` shows `mi`
- Internal gate/aid calculations always stay in `km`
- `GOAL` stays `GOAL` even when the watch is set to miles

## Race Definition Flow

- Edit `apps/GateChecker/race_defs/races/<race_key>.yml`
- Register the race in `apps/GateChecker/race_defs/race_index.yml`
- Run `python3 apps/GateChecker/scripts/generate_gatechecker_race.py <race_key>`
- Build the race-specific binary with `apps/GateChecker/scripts/build_gatechecker_race.sh <race_key> [device_id]`

`race_index.yml` is the app ID ledger. If `app_id` is `null`, the generator creates a UUID once and writes it back to the file. Existing `app_id` values are preserved and reused on later builds.

## Definition Files

Race definitions live under `apps/GateChecker/race_defs/races/`.

Single-course races can stay in the legacy format. They are treated as one implicit course, so no `courseCode` setting file is generated.

Example:

```yaml
race_key: toyama_marathon_2026

display_name:
  jpn: "富山マラソン2026"
  eng: "Toyama Marathon 2026"

race:
  date: "2026/11/01"
  timezone: "Asia/Tokyo"
  distance_km: 42.195

gates:
  - point: 9.0
    cutoff: "2026/11/01 10:20"
  - point: GOAL
    cutoff: "2026/11/01 15:00"

aids:
  - km: 5.0
  - km: 10.5
```

Multi-course races add a `course` layer above the existing `gates` / `aids` payload. The gate and aid item formats themselves do not change.

```yaml
race_key: sample_multi_course

display_name:
  jpn: "GateChecker 複数コース確認用"
  eng: "GateChecker Multi Course Sample"

race:
  date: "2026/10/18"
  timezone: "Asia/Tokyo"

defaultCourseCode: full_main

courses:
  - courseCode: full_main
    courseNameJa: "フルマラソン"
    courseNameEn: "Full Marathon"
    distance_km: 42.195
    gates:
      - point: 10.0
        cutoff: "2026/10/18 09:40"
      - point: GOAL
        cutoff: "2026/10/18 14:30"
    aids:
      - km: 5.0
      - km: 10.0

  - courseCode: full_wave2
    courseNameJa: "フルマラソン 第2ウェーブ"
    courseNameEn: "Full Marathon Wave 2"
    distance_km: 42.195
    gates:
      - point: 10.0
        cutoff: "2026/10/18 09:55"
      - point: GOAL
        cutoff: "2026/10/18 14:45"
    aids:
      - km: 5.0
      - km: 10.0
```

Mile-based definitions are also supported:

```yaml
race_key: gatechecker_mile_sample_2026

display_name:
  jpn: "GateChecker Mile Sample 2026"
  eng: "GateChecker Mile Sample 2026"

race:
  date: "2026/10/18"
  timezone: "America/New_York"
  distance_mi: 26.2187575

gates:
  - point_mi: 5.0
    cutoff: "2026/10/18 08:10"
  - point_mi: 13.1
    cutoff: "2026/10/18 10:00"
  - point_mi: 20.0
    cutoff: "2026/10/18 12:00"
  - point: GOAL
    cutoff: "2026/10/18 13:30"

aids:
  - mi: 3.1
  - mi: 6.2
  - mi: 9.3
  - mi: 13.1
```

Rules:

- `race_key` must match `[a-z0-9_]+`
- `race.date` and `race.timezone` are always required
- Legacy single-course format keeps `race.distance_km` or `race.distance_mi` at the top level
- Multi-course format may keep a shared top-level race distance, or each course may define its own `distance_km` or `distance_mi`
- `defaultCourseCode` is optional; if omitted, `courses[0]` becomes the default
- `courses[].courseCode` must match `[a-z0-9_]+`
- `courses[].courseNameJa` and `courses[].courseNameEn` are required in multi-course format
- `gates[].point` accepts a numeric km value or `GOAL`
- `gates[].point_mi` accepts a numeric mile value
- `aids[].km` accepts a numeric km value
- `aids[].mi` accepts a numeric mile value
- `distance_km` and `distance_mi` may not both be set
- `gates[].point` and `gates[].point_mi` may not both be set
- `aids[].km` and `aids[].mi` may not both be set
- `GOAL` is final-gate only and uses the exact normalized race distance internally
- Numeric `km` gate and aid points must align to `0.1km` units
- `cutoff` must be `yyyy/mm/dd HH:MM`
- Gates and aids must be strictly ascending

Important: the final gate must remain `GOAL` in generated code. It must not be flattened into a rounded distance such as `42.2km`.

Naming:

- `display_name` is the race name embedded in race data and on-race UI
- `courseNameJa` / `courseNameEn` are shown on the pre-start title screen
- The app name shown by Connect IQ is fixed to `関門ガイド` / `Marathon Cutoff Guide`
- Changing `display_name` does not rename the app itself

## Generated Files

The generator updates only files under `apps/GateChecker/`:

- `manifest.xml`
- `resources/strings/strings.xml`
- `resources-jpn/strings/strings.xml`
- `resources/properties.xml`
- `source/generated/GateRaceConfig.mc`

Generated `GateRaceConfig.mc` stores gates as `[point, cutoffDayOffset, cutoffMinuteOfDay]`.

Example:

```monkeyc
[9000, 0, 620]
[GOAL, 0, 900]
```

Numeric points are stored as meters. That keeps `GOAL` distinct from numeric points, so the app can:

- show `GOAL` on screen
- use the exact normalized race distance for remaining-distance math
- preserve mile-based definitions without forcing `0.1km` rounding
- avoid generating `[42195, ...]` for the last gate

Generated `resources/properties.xml` behavior:

- If the race resolves to exactly one course, no `courseCode` setting is generated
- If the race has two or more courses, a `courseIndex` list setting is generated
- The Garmin settings screen shows a pull-down list labeled `Course / コース`
- Each list item displays `courseNameJa / courseNameEn`, while `race_defs` still keep the stable `courseCode`
- The generated resources also keep an internal `courseCode` default so the runtime can resolve a stable course identifier behind the pull-down
- The generated default is `defaultCourseCode`
- For simulator-only verification, `GATECHECKER_DEFAULT_COURSE_CODE_OVERRIDE=<course_code>` can temporarily replace the generated default

## Build

From the repository root:

```bash
python3 apps/GateChecker/scripts/generate_gatechecker_race.py toyama_marathon_2026
apps/GateChecker/scripts/build_gatechecker_race.sh toyama_marathon_2026 fr57042mm
```

The build artifact is written to `apps/GateChecker/dist/<race_key>/`.

## Release Package

For a race-specific distributable `.iq`:

```bash
apps/GateChecker/scripts/build_gatechecker_release_package.sh toyama_marathon_2026
```

To build a different release version without editing `race_index.yml`:

```bash
apps/GateChecker/scripts/build_gatechecker_release_package.sh toyama_marathon_2026 0.2.0
```

Behavior:

- The script copies `apps/GateChecker/` to a temporary workspace
- It resolves the race definition and version there
- If a version argument is passed, only the temporary copy is updated
- It packages a signed `.iq` to `apps/GateChecker/releases/<race_key>/<version>/`
- It also stores `BUILD.md`, the generated `manifest.xml`, the generated `GateRaceConfig.mc`, and the race YAML snapshot for traceability

## Connect IQ Listing Text

To generate Connect IQ Store title/description Markdown for a race:

```bash
python3 apps/GateChecker/scripts/generate_gatechecker_listing_text.py toyama_marathon_2026
```

Behavior:

- It reads only `apps/GateChecker/race_defs/`
- It creates Japanese and English titles/descriptions
- It saves the output to `apps/GateChecker/releases/<race_key>/CONNECT_IQ_LISTING.md`

## Simulator

Use the GateChecker simulator wrapper from the repository root.

Single-course race, no settings file required:

```bash
apps/GateChecker/scripts/run_gatechecker_sim.sh --race toyama_marathon_2026
```

Multi-course race, select a course and send the generated settings schema:

```bash
apps/GateChecker/scripts/run_gatechecker_sim.sh --race sample_multi_course --course full_wave2
```

Behavior:

- `run_gatechecker_sim.sh` calls the slot-based simulator sender
- It builds the requested race under `apps/GateChecker/dist/<race_key>/`
- It retries known-good simulator slot paths if direct launch is rejected
- If a settings schema exists, it is sent to `GARMIN/Settings/...-settings.json`
- `--course` sets `GATECHECKER_DEFAULT_COURSE_CODE_OVERRIDE`, which changes the generated default course for that simulator build only
- If no `--course` is passed and the race has one course, no settings file is generated or sent
- If the race has multiple courses, the simulator receives a settings schema with the course pull-down entries
- Pin a single slot when needed with `GATECHECKER_SIM_SLOT_RACE=toyama_marathon_2026`

Examples:

```bash
apps/GateChecker/scripts/run_gatechecker_sim.sh --race gatechecker_mile_sample_2026 --device fr57042mm

GATECHECKER_SIM_SLOT_RACE=iwate_oshu_kirameki_marathon_2026 \
  apps/GateChecker/scripts/run_gatechecker_sim.sh --race sample_multi_course --course ultra_100k
```

Notes:

- The slot script temporarily overwrites the slot `.prg` in `apps/GateChecker/dist/<slot_race_key>/`
- Rebuild the slot race later if you want to restore that artifact on disk
- On the pre-start / GPS-wait title screen, the app shows both `raceName` and the selected `courseName`

Because this app is a data field, activity recording does not start automatically. After `monkeydo`, use the simulator menu:

1. `Simulation > FIT Data > Simulate`
2. `Data Fields > Timer > Start Activity`

## Runtime Notes

- The old `gate_code` property workflow is no longer the primary path
- Next gate selection is based on the selected course's embedded gates
- Next AID selection is based on the selected course's embedded AID points
- Distance labels switch between `km` and `mi` from the watch setting
- If the next gate is `GOAL`, the UI displays `GOAL` and still uses the exact race distance for calculations
- If all AIDs are passed, the UI keeps a stable `AID --` style display instead of breaking
- Course resolution order is:
  1. If there is exactly one course, use it
  2. Otherwise try the course selected by the `courseIndex` pull-down
  3. Fall back to `defaultCourseCode`
  4. Fall back to `courses[0]`
  5. If nothing is usable, stay in a safe no-course/no-gate state instead of crashing
- Invalid course selections do not crash the app; they fall back to the default or first course
