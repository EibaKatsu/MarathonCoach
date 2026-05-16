#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

DEVICE_ID="fr57042mm"
RACE_CODE=""
SIM_WAIT_SEC="${CIQ_SIM_WAIT_SEC:-12}"
SIM_APP_PATH="${CONNECTIQ_HOME:-}/bin/ConnectIQ.app"
SIM_EXEC_PATH="${SIM_APP_PATH}/Contents/MacOS/simulator"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE_ID="$2"
      shift 2
      ;;
    --race-code)
      RACE_CODE="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  apps/GateChecker/scripts/run_gatechecker_global_sim.sh [--device <device_id>] [--race-code <code>]

Examples:
  apps/GateChecker/scripts/run_gatechecker_global_sim.sh
  apps/GateChecker/scripts/run_gatechecker_global_sim.sh --race-code SAMP26-F42-A7K3
EOF
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

TARGET_DIR="$APP_DIR/dist/global"
TARGET_PRG="$TARGET_DIR/gatechecker-global-${DEVICE_ID}.prg"
TARGET_SETTINGS_JSON="$TARGET_DIR/gatechecker-global-${DEVICE_ID}-settings.json"
OVERRIDE_SETTINGS_JSON="$TARGET_DIR/gatechecker-global-${DEVICE_ID}-settings-override.json"

simulator_is_running() {
  pgrep -f "ConnectIQ.app/Contents/MacOS/simulator" >/dev/null 2>&1
}

simulator_is_ready() {
  lsof -nP -a -c simulator -iTCP -sTCP:LISTEN >/dev/null 2>&1
}

launch_simulator() {
  if simulator_is_ready; then
    return 0
  fi

  if [[ -d "$SIM_APP_PATH" ]]; then
    open "$SIM_APP_PATH" >/dev/null 2>&1 || true
  fi

  sleep 1

  if ! simulator_is_running && [[ -x "$SIM_EXEC_PATH" ]]; then
    "$SIM_EXEC_PATH" >/tmp/connectiq_gatechecker_global_simulator_stdout.log 2>&1 &
  fi
}

wait_for_simulator_ready() {
  local waited=0
  echo "Waiting for simulator startup..."
  while [[ "$waited" -lt "$SIM_WAIT_SEC" ]]; do
    if simulator_is_ready; then
      return 0
    fi
    sleep 1
    waited=$((waited + 1))
  done
  echo "ERROR: Simulator did not become ready within ${SIM_WAIT_SEC}s" >&2
  return 1
}

stop_stale_monkeydo() {
  pkill -f "/bin/monkeydo " >/dev/null 2>&1 || true
  pkill -f "com.garmin.monkeybrains.monkeydodeux.MonkeyDoDeux" >/dev/null 2>&1 || true
  pkill -f "/bin/shell --transport=tcp --transport_args=127.0.0.1:1234" >/dev/null 2>&1 || true
}

build_settings_send_spec() {
  if [[ ! -f "$TARGET_SETTINGS_JSON" ]]; then
    return 1
  fi

  local settings_path="$TARGET_SETTINGS_JSON"
  if [[ -n "$RACE_CODE" ]]; then
    python3 - "$TARGET_SETTINGS_JSON" "$OVERRIDE_SETTINGS_JSON" "$RACE_CODE" <<'PY'
import json
import sys
from pathlib import Path

src = Path(sys.argv[1])
dst = Path(sys.argv[2])
race_code = sys.argv[3].strip().upper().replace(" ", "").replace("\u3000", "")
data = json.loads(src.read_text(encoding="utf-8"))
for setting in data.get("settings", []):
    if setting.get("key") == "raceCode":
        setting["defaultValue"] = race_code
dst.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
    settings_path="$OVERRIDE_SETTINGS_JSON"
  fi

  echo "$settings_path:GARMIN/Settings/GATECHECKER-GLOBAL-${DEVICE_ID:u}-SETTINGS.JSON"
}

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set." >&2
  exit 1
fi

"$SCRIPT_DIR/build_gatechecker_global.sh" "$DEVICE_ID"

if [[ ! -f "$TARGET_PRG" ]]; then
  echo "ERROR: Built global artifact not found: $TARGET_PRG" >&2
  exit 1
fi

launch_simulator
wait_for_simulator_ready
stop_stale_monkeydo

MONKEYDO_ARGS=("$TARGET_PRG" "$DEVICE_ID")
if SETTINGS_SEND_SPEC="$(build_settings_send_spec)"; then
  MONKEYDO_ARGS+=("-a" "$SETTINGS_SEND_SPEC")
  echo "Sending settings file: ${SETTINGS_SEND_SPEC#*:}"
else
  echo "No settings file found; sending PRG only"
fi

echo "Sending GateChecker global app to simulator on $DEVICE_ID"
"$CONNECTIQ_HOME/bin/monkeydo" "${MONKEYDO_ARGS[@]}"
