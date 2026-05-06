#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

RACE_KEY=""
DEVICE_ID="fr57042mm"
COURSE_CODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --race)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --race requires a value" >&2
        exit 1
      fi
      RACE_KEY="$2"
      shift 2
      ;;
    --device)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --device requires a value" >&2
        exit 1
      fi
      DEVICE_ID="$2"
      shift 2
      ;;
    --course)
      if [[ $# -lt 2 ]]; then
        echo "ERROR: --course requires a value" >&2
        exit 1
      fi
      COURSE_CODE="$2"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  apps/GateChecker/scripts/run_gatechecker_sim.sh --race <race_key> [--device <device_id>] [--course <course_code>]

Examples:
  apps/GateChecker/scripts/run_gatechecker_sim.sh --race toyama_marathon_2026
  apps/GateChecker/scripts/run_gatechecker_sim.sh --race sample_multi_course --course full_wave2
EOF
      exit 0
      ;;
    *)
      echo "ERROR: Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$RACE_KEY" ]]; then
  echo "ERROR: --race is required" >&2
  exit 1
fi

if [[ -n "$COURSE_CODE" ]]; then
  echo "Launching GateChecker simulator with course override: $COURSE_CODE"
  GATECHECKER_DEFAULT_COURSE_CODE_OVERRIDE="$COURSE_CODE" \
    "$SCRIPT_DIR/send_gatechecker_race_to_simulator.sh" "$RACE_KEY" "$DEVICE_ID"
  exit 0
fi

echo "Launching GateChecker simulator without course override"
"$SCRIPT_DIR/send_gatechecker_race_to_simulator.sh" "$RACE_KEY" "$DEVICE_ID"
