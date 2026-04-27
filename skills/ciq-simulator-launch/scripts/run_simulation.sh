#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DEVICE_ID="${1:-fr57042mm}"
SIM_WAIT_SEC="${CIQ_SIM_WAIT_SEC:-12}"
SIM_APP_PATH="${CONNECTIQ_HOME:-}/bin/ConnectIQ.app"
SIM_EXEC_PATH="${SIM_APP_PATH}/Contents/MacOS/simulator"
APP_BASE_NAME="marathoncoach"
APP_BASE_NAME_UPPER="$(echo "$APP_BASE_NAME" | tr '[:lower:]' '[:upper:]')"
SIM_TMP_ROOT="${TMPDIR%/}/com.garmin.connectiq"
SIM_SETTINGS_PATH="$SIM_TMP_ROOT/GARMIN/Settings/${APP_BASE_NAME}-settings.json"
SIM_ACTIVITY_PATH="$SIM_TMP_ROOT/GARMIN/Activities/FILE.FIT"

resolve_dev_key() {
  local project_key="$PROJECT_ROOT/.vscode/developer_key"
  local legacy_key="/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key"

  if [[ -n "${CIQ_DEV_KEY:-}" ]]; then
    echo "$CIQ_DEV_KEY"
    return
  fi
  if [[ -f "$project_key" ]]; then
    echo "$project_key"
    return
  fi
  echo "$legacy_key"
}

detect_dev_key_bits() {
  local key_path="$1"
  openssl pkey -in "$key_path" -inform DER -noout -text 2>/dev/null |
    sed -nE 's/^Private-Key: \(([0-9]+) bit,.*/\1/p' |
    head -n 1
}

validate_dev_key() {
  local key_path="$1"
  local key_bits
  key_bits="$(detect_dev_key_bits "$key_path")"

  if [[ -z "$key_bits" ]]; then
    echo "WARNING: Could not determine developer key strength: $key_path"
    echo "If the simulator shows only the Garmin blue triangle and CIQ_LOG.YML has"
    echo "'Signature check failed on file', regenerate the key as 4096-bit RSA."
    return 0
  fi

  if [[ "$key_bits" != "4096" ]]; then
    echo "ERROR: Developer key must be 4096-bit RSA for this simulator flow: $key_path"
    echo "Detected: ${key_bits}-bit"
    echo "Regenerate with:"
    echo "  openssl genrsa -out developer_key.pem 4096"
    echo "  openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out .vscode/developer_key -nocrypt"
    return 1
  fi
}

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
    "$SIM_EXEC_PATH" >/tmp/connectiq_simulator_stdout.log 2>&1 &
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
  echo "ERROR: Simulator did not become ready within ${SIM_WAIT_SEC}s"
  return 1
}

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set."
  exit 1
fi

DEV_KEY="$(resolve_dev_key)"

if [[ ! -f "$DEV_KEY" ]]; then
  echo "ERROR: Developer key not found: $DEV_KEY"
  exit 1
fi

validate_dev_key "$DEV_KEY"

cd "$PROJECT_ROOT"
mkdir -p bin

APP_PRG_PATH="bin/${APP_BASE_NAME}.prg"
APP_SETTINGS_PATH="${CIQ_SETTINGS_JSON:-}"
GENERATED_SETTINGS_PATH="${APP_PRG_PATH%.prg}-settings.json"

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f monkey.jungle \
  -o "$APP_PRG_PATH" \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w

launch_simulator
wait_for_simulator_ready

MONKEYDO_ARGS=("$APP_PRG_PATH" "$DEVICE_ID")
if [[ -z "$APP_SETTINGS_PATH" && -f "$GENERATED_SETTINGS_PATH" ]]; then
  APP_SETTINGS_PATH="$GENERATED_SETTINGS_PATH"
fi

if [[ -n "$APP_SETTINGS_PATH" && -f "$APP_SETTINGS_PATH" ]]; then
  SETTINGS_BASENAME="${APP_SETTINGS_PATH##*/}"
  SETTINGS_DEST_PATH="GARMIN/Settings/$SETTINGS_BASENAME"
  MONKEYDO_ARGS+=("-a" "$APP_SETTINGS_PATH:$SETTINGS_DEST_PATH")
  echo "Sending settings file: $APP_SETTINGS_PATH -> $SETTINGS_DEST_PATH"
  echo "If App Settings Editor says no settings file was found, close and reopen"
  echo "the editor after this resend so it picks up the current app + settings pair."
else
  echo "No settings JSON found; using simulator/app current settings"
fi

echo "Data field note: the simulator does not auto-start activity recording."
echo "If the watch stays on the Garmin blue triangle, use 'Simulation > FIT Data > Simulate'"
echo "and then 'Data Fields > Timer > Start Activity' in the simulator menu."

"$CONNECTIQ_HOME/bin/monkeydo" "${MONKEYDO_ARGS[@]}" &
MONKEYDO_PID=$!

sleep 3

if [[ -n "$APP_SETTINGS_PATH" && -f "$APP_SETTINGS_PATH" ]]; then
  if [[ -f "$SIM_SETTINGS_PATH" ]]; then
    echo "Simulator settings detected: $SIM_SETTINGS_PATH"
  else
    echo "WARNING: Simulator settings file not observed yet: $SIM_SETTINGS_PATH"
  fi
fi

if [[ -f "$SIM_ACTIVITY_PATH" ]]; then
  echo "Simulator activity detected: $SIM_ACTIVITY_PATH"
else
  echo "No simulator activity file detected yet: $SIM_ACTIVITY_PATH"
  echo "The data field is loaded, but activity recording has not started."
  echo "Run 'Simulation > FIT Data > Simulate' and then 'Data Fields > Timer > Start Activity'."
fi

wait "$MONKEYDO_PID"
