#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

DEVICE_ID="${1:-fr57042mm}"
DEV_KEY="${CIQ_DEV_KEY:-/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key}"

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set."
  exit 1
fi

if [[ ! -f "$DEV_KEY" ]]; then
  echo "ERROR: Developer key not found: $DEV_KEY"
  exit 1
fi

cd "$PROJECT_ROOT"
mkdir -p bin

APP_PRG_PATH="bin/marathoncoach.prg"
APP_SETTINGS_PATH="${APP_PRG_PATH%.prg}-settings.json"

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f monkey.jungle \
  -o "$APP_PRG_PATH" \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w

if ! connectiq >/dev/null 2>&1; then
  open "$CONNECTIQ_HOME/bin/ConnectIQ.app" || true
fi

echo "Waiting 10 seconds for simulator startup..."
sleep 10

MONKEYDO_ARGS=("$APP_PRG_PATH" "$DEVICE_ID")
if [[ -f "$APP_SETTINGS_PATH" ]]; then
  SETTINGS_BASENAME="${APP_SETTINGS_PATH##*/}"
  SETTINGS_DEST_PATH="GARMIN/Settings/$SETTINGS_BASENAME"
  MONKEYDO_ARGS+=("-a" "$APP_SETTINGS_PATH:$SETTINGS_DEST_PATH")
  echo "Sending settings file: $APP_SETTINGS_PATH -> $SETTINGS_DEST_PATH"
else
  echo "WARNING: settings file not found: $APP_SETTINGS_PATH"
fi

"$CONNECTIQ_HOME/bin/monkeydo" "${MONKEYDO_ARGS[@]}"
