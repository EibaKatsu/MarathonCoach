#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MODE="run"
DEVICE_ID="fr255"
TEST_NAME=""
DEV_KEY="${CIQ_DEV_KEY:-/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key}"
OUTPUT_PRG="$PROJECT_ROOT/bin/marathoncoach_tests.prg"
TIMEOUT_SEC="${CIQ_TEST_TIMEOUT_SEC:-60}"
SIM_WAIT_SEC="${CIQ_TEST_SIM_WAIT_SEC:-8}"
RUN_LOG="${CIQ_TEST_RUN_LOG:-$PROJECT_ROOT/bin/marathoncoach_tests.run.log}"

if [[ $# -gt 0 ]]; then
  case "$1" in
    build|run)
      MODE="$1"
      shift
      ;;
    --build-only)
      MODE="build"
      shift
      ;;
    --run)
      MODE="run"
      shift
      ;;
  esac
fi

if [[ $# -gt 0 ]]; then
  DEVICE_ID="$1"
  shift
fi

if [[ $# -gt 0 ]]; then
  TEST_NAME="$1"
  shift
fi

if [[ $# -gt 0 ]]; then
  echo "ERROR: Unexpected arguments: $*"
  exit 1
fi

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
mkdir -p "$(dirname "$RUN_LOG")"

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f monkey.jungle \
  -o "$OUTPUT_PRG" \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w \
  -t

echo "Unit-test build completed: $OUTPUT_PRG"

if [[ "$MODE" == "build" ]]; then
  exit 0
fi

if ! ps aux 2>/dev/null | rg -q "[C]onnectIQ"; then
  echo "Starting Connect IQ simulator..."
  "$CONNECTIQ_HOME/bin/connectiq" >/dev/null 2>&1 || true
  sleep "$SIM_WAIT_SEC"
fi

MONKEYDO_ARGS=("$OUTPUT_PRG" "$DEVICE_ID" "-t")
if [[ -n "$TEST_NAME" ]]; then
  MONKEYDO_ARGS+=("$TEST_NAME")
fi

: > "$RUN_LOG"
"$CONNECTIQ_HOME/bin/monkeydo" "${MONKEYDO_ARGS[@]}" >"$RUN_LOG" 2>&1 &
RUN_PID=$!
ELAPSED_SEC=0

while kill -0 "$RUN_PID" 2>/dev/null; do
  if [[ "$ELAPSED_SEC" -ge "$TIMEOUT_SEC" ]]; then
    kill "$RUN_PID" >/dev/null 2>&1 || true
    sleep 1
    kill -9 "$RUN_PID" >/dev/null 2>&1 || true
    wait "$RUN_PID" >/dev/null 2>&1 || true
    cat "$RUN_LOG"
    echo "ERROR: Unit-test run timed out after ${TIMEOUT_SEC}s" >&2
    exit 124
  fi
  sleep 1
  ELAPSED_SEC=$((ELAPSED_SEC + 1))
done

set +e
wait "$RUN_PID"
RUN_STATUS=$?
set -e

cat "$RUN_LOG"

if [[ "$RUN_STATUS" -ne 0 ]]; then
  exit "$RUN_STATUS"
fi

if rg -q "Unhandled Exception|Encountered an app crash|UnexpectedTypeException" "$RUN_LOG"; then
  echo "ERROR: Crash markers were found in unit-test output." >&2
  exit 1
fi

echo "Unit-test run completed: $RUN_LOG"
