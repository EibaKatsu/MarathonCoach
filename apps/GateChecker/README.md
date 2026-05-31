# GateChecker

GateChecker / Cutoff Guide is now a single Connect IQ data field app.

- Users install one app
- Users enter one `Race Code` in Garmin Connect app settings
- `Race Code` identifies `race + course`
- The app does not use `Unlock Key`
- The app does not judge free vs paid
- The app does not perform network access, license checks, or payment handling

If the entered `Race Code` exists in the generated internal course list, the app shows that race/course. If it does not exist, the app shows a clear `Race Code` error screen and asks the user to check app settings.

## Current Model

- `apps/GateChecker/race_defs/race_index.yml`
  - global app metadata
  - race file index
  - site/management metadata such as `sample_free`
- `apps/GateChecker/race_defs/races/*.yml`
  - human-edited race definitions
  - one file per race
  - new schema uses `race_id` and `courses[].race_code`
- `apps/GateChecker/source/generated/GateRaceConfig.mc`
  - generated flattened course table embedded into the app
- `apps/GateChecker/generated/supported_races.json`
  - generated site/helper output

## Race Code

Recommended format:

```text
{RACE_ABBR}{YY}-{COURSE}-{CHECK}
```

Examples:

```text
TKY26-F42-A7K3
HIDA26-100K-K7P2
SARO26-100K-Z8T4
```

Rules:

- Do not expose raw `race_id + course_id` as the code
- Codes are human-enterable but only lightly obfuscated
- App-side matching is exact after normalization
- Normalization removes spaces and uppercases ASCII letters
- Course selection is inside the `Race Code`, so there is no separate course setting

Code generation helper:

```bash
python3 apps/GateChecker/scripts/generate_race_code.py \
  --race-id 20261018_sample_multi_course \
  --course-id ultra_100k \
  --year 2026 \
  --race-abbr SAMP \
  --course-label 100K
```

Optional salt:

```bash
GATECHECKER_RACE_CODE_SALT="local-only-salt" \
python3 apps/GateChecker/scripts/generate_race_code.py ...
```

The salt is optional and must not be committed.

## Race Definition Schema

New schema example:

```yaml
race_id: london_marathon_2026

display_name:
  jpn: "ロンドンマラソン2026"
  eng: "London Marathon 2026"

meta:
  country: "GB"
  region: "Europe"
  category: "marathon"
  sample_free: true
  race_abbr: "LDN"

race:
  date: "2026/04/26"
  timezone: "Europe/London"

courses:
  - course_id: full
    race_code: "LDN26-F42-Q9M2"
    course_name:
      jpn: "フルマラソン"
      eng: "Marathon"
    distance_mi: 26.2187575
    gates:
      - point_mi: 13.1
        cutoff: "2026/04/26 13:00"
      - point: GOAL
        cutoff: "2026/04/26 17:00"
    aids:
      - mi: 3.0
      - mi: 6.0
```

Validation performed by the generators:

- `race_id` uniqueness in `race_index.yml`
- `race_code` uniqueness across all courses
- `race_code` non-empty and roughly format-compliant
- `course_id` uniqueness inside a race
- `distance_km` and `distance_mi` are mutually exclusive
- `gates[].point` and `gates[].point_mi` are mutually exclusive
- `aids[].km` and `aids[].mi` are mutually exclusive
- gates are ascending
- aids are ascending
- `GOAL` can appear only once and only as the last gate
- `display_name.eng/jpn` and `course_name.eng/jpn` are required

## Internal Data Model

The app is generated as a flat list of race courses.

- Distances are stored internally in meters
- Existing watch unit behavior remains intact
- `GOAL` is kept as a sentinel, not converted to a numeric distance
- Gate cutoff times are stored as `dayOffset + minuteOfDay`
- Existing gate / aid rendering logic is preserved as much as possible

## App Settings

Garmin Connect app settings now contain:

- `Race Code`
  - example: `SAMP26-100K-C4P8`
  - input type: alphanumeric string
  - normalized by trim + uppercase + space removal

There is no course chooser in settings anymore.

## Runtime Behavior

At startup or settings refresh:

1. Read `Race Code`
2. Normalize it
3. Search generated internal course list
4. If found, use that race/course
5. If not found, show an error splash

Error splash:

- English:
  - `Race Code`
  - `Not Found` or `Not Set`
  - `Check app settings`
- Japanese:
  - `Race Code`
  - `が見つかりません` or `が未設定です`
  - `設定を確認してください`

The normal pre-start splash still shows:

- app name
- resolved race name
- resolved course name
- `WAIT START`

## Free / Paid Handling

The app itself does not distinguish free and paid races.

- `sample_free` is only for website / management metadata
- Any internally defined `Race Code` is accepted
- Unknown codes are rejected
- Free sample race codes are intended to be published on the website
- Paid race codes are intended to be delivered from the website after purchase

## Build

Global single-app build:

```bash
python3 apps/GateChecker/scripts/generate_gatechecker_all_races.py
apps/GateChecker/scripts/build_gatechecker_global.sh fr57042mm
```

Generated outputs:

- `apps/GateChecker/source/generated/GateRaceConfig.mc`
- `apps/GateChecker/resources/properties.xml`
- `apps/GateChecker/resources/strings/strings.xml`
- `apps/GateChecker/resources-jpn/strings/strings.xml`
- `apps/GateChecker/generated/supported_races.json`
- `apps/GateChecker/dist/global/gatechecker-global-<device>.prg`

## Simulator

Recommended flow for the global app:

```bash
apps/GateChecker/scripts/build_gatechecker_global.sh fr57042mm
apps/GateChecker/scripts/run_gatechecker_global_sim.sh
```

`run_gatechecker_global_sim.sh` builds the global app and sends both PRG and settings JSON to the simulator via `monkeydo`.
After launch, enter any supported `Race Code` in Garmin Connect app settings.

## Notes

- `km` / `mi` race definitions are both supported
- `GOAL` is always treated as the last gate sentinel
- MarathonCoach main app should remain unaffected; GateChecker lives under `apps/GateChecker`
