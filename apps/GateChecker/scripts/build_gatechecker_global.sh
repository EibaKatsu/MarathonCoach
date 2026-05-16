#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$APP_DIR/../.." && pwd)"

if [[ $# -gt 1 ]]; then
  echo "Usage: $0 [device_id]" >&2
  exit 1
fi

DEVICE_ID="${1:-fr57042mm}"
DEV_KEY="${CIQ_DEV_KEY:-$PROJECT_ROOT/.vscode/developer_key}"
OUT_DIR="$APP_DIR/dist/global"
OUT_PRG="$OUT_DIR/gatechecker-global-${DEVICE_ID}.prg"

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set." >&2
  exit 1
fi

if [[ ! -f "$DEV_KEY" ]]; then
  echo "ERROR: Developer key not found: $DEV_KEY" >&2
  exit 1
fi

python3 "$SCRIPT_DIR/generate_gatechecker_all_races.py"

mkdir -p "$OUT_DIR"

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f "$APP_DIR/monkey.jungle" \
  -o "$OUT_PRG" \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w

echo "Built GateChecker global artifact: $OUT_PRG"
