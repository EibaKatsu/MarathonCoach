# GateChecker

GateChecker is a separate Connect IQ data field app that lives alongside MarathonCoach in the same repository. This app now assumes race-specific builds: each marathon gets its own YAML definition, app ID, generated manifest, generated strings, and embedded gate/AID data.

## Race Definition Flow

- Edit `apps/GateChecker/race_defs/races/<race_key>.yml`
- Register the race in `apps/GateChecker/race_defs/race_index.yml`
- Run `python3 apps/GateChecker/scripts/generate_gatechecker_race.py <race_key>`
- Build the race-specific binary with `apps/GateChecker/scripts/build_gatechecker_race.sh <race_key> [device_id]`

`race_index.yml` is the app ID ledger. If `app_id` is `null`, the generator creates a UUID once and writes it back to the file. Existing `app_id` values are preserved and reused on later builds.

## Definition Files

Race definitions live under `apps/GateChecker/race_defs/races/`.

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

Rules:

- `race_key` must match `[a-z0-9_]+`
- `gates[].point` accepts a numeric km value or `GOAL`
- `GOAL` is final-gate only and uses `race.distance_km` internally
- Numeric gate and aid points must align to `0.1km` units
- `cutoff` must be `yyyy/mm/dd HH:MM`
- Gates and aids must be strictly ascending

Important: the final gate must remain `GOAL` in generated code. It must not be flattened into a rounded distance such as `42.2km`.

Naming:

- `display_name` is the race name embedded in race data and on-race UI
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
[90, 0, 620]
[GOAL, 0, 900]
```

That keeps `GOAL` distinct from numeric points, so the app can:

- show `GOAL` on screen
- use the exact `42.195km` race distance for remaining-distance math
- avoid generating `[422, ...]` for the last gate

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

From the repository root:

```bash
open "$CONNECTIQ_HOME/bin/ConnectIQ.app"
"$CONNECTIQ_HOME/bin/monkeydo" \
  apps/GateChecker/dist/toyama_marathon_2026/gatechecker-toyama_marathon_2026-fr57042mm.prg \
  fr57042mm
```

Because this app is a data field, activity recording does not start automatically. After `monkeydo`, use the simulator menu:

1. `Simulation > FIT Data > Simulate`
2. `Data Fields > Timer > Start Activity`

## Runtime Notes

- The old `gate_code` property workflow is no longer the primary path
- Next gate selection is based on embedded race gates
- Next AID selection is based on embedded AID points
- If the next gate is `GOAL`, the UI displays `GOAL` and still uses the exact race distance for calculations
- If all AIDs are passed, the UI keeps a stable `AID --` style display instead of breaking
