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

"$CONNECTIQ_HOME/bin/monkeyc" \
  -f monkey.jungle \
  -o bin/marathoncoach.prg \
  -d "$DEVICE_ID" \
  -y "$DEV_KEY" \
  -w

if ! connectiq >/dev/null 2>&1; then
  open "$CONNECTIQ_HOME/bin/ConnectIQ.app" || true
fi

echo "Waiting 10 seconds for simulator startup..."
sleep 10
"$CONNECTIQ_HOME/bin/monkeydo" "bin/marathoncoach.prg" "$DEVICE_ID"
