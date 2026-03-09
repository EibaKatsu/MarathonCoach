#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="${1:-build}"
DEVICE_ID="${2:-fr255}"
TEST_NAME="${3:-}"
DEV_KEY="${CIQ_DEV_KEY:-/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key}"
OUTPUT_PRG="$PROJECT_ROOT/bin/marathoncoach_tests.prg"

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

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f monkey.jungle \
  -o "$OUTPUT_PRG" \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w \
  -t

echo "Unit-test build completed: $OUTPUT_PRG"

if [[ "$MODE" != "run" ]]; then
  exit 0
fi

if ! ps aux | rg -q "[C]onnectIQ"; then
  echo "Starting Connect IQ simulator..."
  "$CONNECTIQ_HOME/bin/connectiq" >/dev/null 2>&1 || true
  sleep 8
fi

MONKEYDO_ARGS=("$OUTPUT_PRG" "$DEVICE_ID" "-t")
if [[ -n "$TEST_NAME" ]]; then
  MONKEYDO_ARGS+=("$TEST_NAME")
fi

"$CONNECTIQ_HOME/bin/monkeydo" "${MONKEYDO_ARGS[@]}"
