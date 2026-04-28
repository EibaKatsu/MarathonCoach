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
DEV_KEY="${CIQ_DEV_KEY:-$PROJECT_ROOT/.vscode/developer_key}"
OUT_DIR="$APP_DIR/dist/$RACE_KEY"
OUT_PRG="$OUT_DIR/gatechecker-${RACE_KEY}-${DEVICE_ID}.prg"

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set." >&2
  exit 1
fi

if [[ ! -f "$DEV_KEY" ]]; then
  echo "ERROR: Developer key not found: $DEV_KEY" >&2
  exit 1
fi

python3 "$SCRIPT_DIR/generate_gatechecker_race.py" "$RACE_KEY"

mkdir -p "$OUT_DIR"

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f "$APP_DIR/monkey.jungle" \
  -o "$OUT_PRG" \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w

echo "Built GateChecker race artifact: $OUT_PRG"
