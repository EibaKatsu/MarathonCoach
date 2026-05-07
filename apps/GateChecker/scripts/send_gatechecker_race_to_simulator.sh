#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$APP_DIR/../.." && pwd)"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <race_key> [device_id]" >&2
  exit 1
fi

RACE_KEY="$1"
DEVICE_ID="${2:-fr57042mm}"
SIM_WAIT_SEC="${CIQ_SIM_WAIT_SEC:-12}"
SIM_APP_PATH="${CONNECTIQ_HOME:-}/bin/ConnectIQ.app"
SIM_EXEC_PATH="${SIM_APP_PATH}/Contents/MacOS/simulator"

TARGET_DIR="$APP_DIR/dist/$RACE_KEY"
TARGET_PRG="$TARGET_DIR/gatechecker-${RACE_KEY}-${DEVICE_ID}.prg"
TARGET_DEBUG_XML="${TARGET_PRG}.debug.xml"
TARGET_SETTINGS_JSON="${TARGET_PRG%.prg}-settings.json"

typeset -a SLOT_RACE_KEYS
if [[ -n "${GATECHECKER_SIM_SLOT_RACE:-}" ]]; then
  SLOT_RACE_KEYS=("${GATECHECKER_SIM_SLOT_RACE}")
else
  SLOT_RACE_KEYS=(
    "20260428_gatechecker_beta_check"
    "20261101_toyama_marathon"
    "20260517_iwate_oshu_kirameki_marathon"
  )
fi

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
    "$SIM_EXEC_PATH" >/tmp/connectiq_gatechecker_simulator_stdout.log 2>&1 &
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

prepare_slot_artifact() {
  local slot_race_key="$1"
  local slot_dir="$APP_DIR/dist/$slot_race_key"
  local slot_prg="$slot_dir/gatechecker-${slot_race_key}-${DEVICE_ID}.prg"
  local slot_debug_xml="${slot_prg}.debug.xml"

  if [[ "$slot_race_key" == "$RACE_KEY" ]]; then
    echo "$TARGET_PRG"
    return 0
  fi

  mkdir -p "$slot_dir"
  cp "$TARGET_PRG" "$slot_prg"
  if [[ -f "$TARGET_DEBUG_XML" ]]; then
    cp "$TARGET_DEBUG_XML" "$slot_debug_xml"
  fi
  echo "$slot_prg"
}

build_settings_send_spec() {
  local send_prg="$1"
  local send_prg_base="${send_prg:t:r}"
  local send_settings_name
  send_settings_name="$(echo "${send_prg_base}-settings.json" | tr '[:lower:]' '[:upper:]')"

  if [[ ! -f "$TARGET_SETTINGS_JSON" ]]; then
    return 1
  fi

  echo "$TARGET_SETTINGS_JSON:GARMIN/Settings/$send_settings_name"
}

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set." >&2
  exit 1
fi

"$SCRIPT_DIR/build_gatechecker_race.sh" "$RACE_KEY" "$DEVICE_ID"

if [[ ! -f "$TARGET_PRG" ]]; then
  echo "ERROR: Built race artifact not found: $TARGET_PRG" >&2
  exit 1
fi

launch_simulator
wait_for_simulator_ready

SUCCESS_SLOT_RACE_KEY=""
SUCCESS_SEND_PRG=""
SUCCESS_MONKEYDO_PID=""
SUCCESS_LOG=""

for slot_race_key in "${SLOT_RACE_KEYS[@]}"; do
  SEND_PRG="$(prepare_slot_artifact "$slot_race_key")"
  ATTEMPT_LOG="$(mktemp)"
  SETTINGS_SEND_SPEC=""
  if SETTINGS_SEND_SPEC="$(build_settings_send_spec "$SEND_PRG")"; then
    :
  else
    SETTINGS_SEND_SPEC=""
  fi

  stop_stale_monkeydo

  echo "Sending GateChecker race '$RACE_KEY' to simulator on $DEVICE_ID"
  if [[ "$slot_race_key" != "$RACE_KEY" ]]; then
    echo "Trying simulator slot: $slot_race_key"
    echo "Aliased artifact: $TARGET_PRG -> $SEND_PRG"
  else
    echo "Trying direct artifact: $SEND_PRG"
  fi
  if [[ -n "$SETTINGS_SEND_SPEC" ]]; then
    echo "Sending settings schema: ${SETTINGS_SEND_SPEC#*:}"
  else
    echo "No settings schema generated for this race build"
  fi

  MONKEYDO_ARGS=("$SEND_PRG" "$DEVICE_ID")
  if [[ -n "$SETTINGS_SEND_SPEC" ]]; then
    MONKEYDO_ARGS+=("-a" "$SETTINGS_SEND_SPEC")
  fi

  "$CONNECTIQ_HOME/bin/monkeydo" "${MONKEYDO_ARGS[@]}" >"$ATTEMPT_LOG" 2>&1 &
  MONKEYDO_PID=$!

  sleep 3

  if kill -0 "$MONKEYDO_PID" >/dev/null 2>&1; then
    if [[ -s "$ATTEMPT_LOG" ]]; then
      cat "$ATTEMPT_LOG"
    fi
    SUCCESS_SLOT_RACE_KEY="$slot_race_key"
    SUCCESS_SEND_PRG="$SEND_PRG"
    SUCCESS_MONKEYDO_PID="$MONKEYDO_PID"
    SUCCESS_LOG="$ATTEMPT_LOG"
    break
  fi

  ATTEMPT_EXIT_CODE=0
  wait "$MONKEYDO_PID" || ATTEMPT_EXIT_CODE=$?
  if [[ -s "$ATTEMPT_LOG" ]]; then
    cat "$ATTEMPT_LOG"
  fi
  rm -f "$ATTEMPT_LOG"
  echo "Simulator slot '$slot_race_key' failed with exit code ${ATTEMPT_EXIT_CODE}. Trying next slot..."
done

if [[ -z "$SUCCESS_MONKEYDO_PID" ]]; then
  echo "ERROR: No simulator slot accepted race '$RACE_KEY'." >&2
  exit 2
fi

echo "Simulator send is active."
echo "Accepted slot: $SUCCESS_SLOT_RACE_KEY"
echo "Data field note: run 'Simulation > FIT Data > Simulate' and then 'Data Fields > Timer > Start Activity'."
if [[ "$SUCCESS_SLOT_RACE_KEY" != "$RACE_KEY" ]]; then
  echo "Rebuild '$SUCCESS_SLOT_RACE_KEY' later if you want to restore the slot artifact in dist/."
fi

wait "$SUCCESS_MONKEYDO_PID"
