# GateChecker

GateChecker is a separate Connect IQ data field app that lives alongside MarathonCoach in the same repository.

## STEP 1 scope

- Create an isolated minimum app under `apps/GateChecker/`
- Confirm it can build as a data field
- Confirm it can be launched in the Connect IQ simulator
- Keep logic limited to a single `GateChecker` label on screen

## STEP 2 scope

- Add a `gate_code` setting
- Load the configured code inside the app
- Run only the minimum format validation needed before a future decoder step
- Render either `CODE OK` or `CODE ERROR`

## STEP 3 scope

- Decode the normalized code into a gate list
- Parse each 8-digit gate block into `distance(0.1km)` and `close time(HHMM)`
- Keep the UI minimal and stop before next-gate selection or time-based judgment

## STEP 4 scope

- Select only the next gate from the decoded gate list
- Use current distance only for gate selection
- Display the next gate distance and close time with a minimal layout
- Stop before time-based cutoff judgment, remaining-time math, or pace math

## STEP 5 scope

- Compute remaining time to the selected next gate using the watch clock
- Assume same-day daytime races only; no date rollover support yet
- Display `next gate distance + time remaining`
- Stop before pace math or cutoff-state decision logic

## STEP 6 scope

- Compute remaining distance to the selected next gate
- Display `next gate distance + remaining distance + time remaining`
- Keep selection rules unchanged and stop before pace math

## STEP 7 scope

- Compute simple required pace from `remaining distance` and `remaining time`
- Display `next gate distance + remaining distance + required pace`
- Keep cutoff judgment and visual warnings out of scope

## STEP 8 scope

- Add a minimal status label for the required pace
- Keep the judgment simple and threshold-based
- Stop before color rules or richer warning UI

## STEP 9 scope

- Add minimal color emphasis for the pace-state label line
- Keep the current 3-line layout and the same pace-judge logic
- Stop before any larger UI redesign

## STEP 10 scope

- Reorganize the screen into a 4-line layout
- Add current pace and separate fact lines from interpretation lines
- Prioritize `CODE ERROR -> WAIT DIST -> ALL PASSED -> OVER -> PACE N/A -> NORMAL`
- Clean up terminal-state display without redesigning the whole app

## Build

From the repository root:

```bash
mkdir -p apps/GateChecker/bin
"$CONNECTIQ_HOME/bin/monkeyc" \
  -f apps/GateChecker/monkey.jungle \
  -o apps/GateChecker/bin/gatechecker.prg \
  -d fr57042mm \
  -y .vscode/developer_key \
  -w
```

## Simulator

From the repository root:

```bash
open "$CONNECTIQ_HOME/bin/ConnectIQ.app"
"$CONNECTIQ_HOME/bin/monkeydo" apps/GateChecker/bin/gatechecker.prg fr57042mm
```

Because this app is a data field, activity recording does not start automatically. After `monkeydo`, use the simulator menu:

1. `Simulation > FIT Data > Simulate`
2. `Data Fields > Timer > Start Activity`

## Settings

After loading the app in the simulator, open the App Settings Editor and edit `Gate Code`.

- Sample valid code: `G104000322000006221500092230001222450X`
- Sample invalid code: `G104000322000006221500092230001222457K`
- Hyphens are optional because the app normalizes them out before validation
- STEP 10 adds a 4-line layout with current pace and terminal-state display cleanup
- Use `python3 scripts/generate_gatechecker_scenarios.py` when you need fresh simulator scenario codes tied to the current clock
- State-by-state simulator steps live in `docs/dev/gatechecker_simulator_scenarios.md`

## Human check points for STEP 10

1. The app installs in the simulator without a build error
2. Normal display shows `GATE / CUT`, `REM / LEFT`, `PACE / ETA`, and `DIST / NOW`
3. `OVER`, `ALL PASSED`, and `PACE N/A` each replace only the intended line content
