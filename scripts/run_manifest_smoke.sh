#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MANIFEST_PATH="$PROJECT_ROOT/manifest.xml"
DEV_KEY="${CIQ_DEV_KEY:-/Users/eibakatsu/Documents/codex/grow/.vscode/developer_key}"
TIMEOUT_SEC="${CIQ_SMOKE_TIMEOUT_SEC:-20}"
SIM_WAIT_SEC="${CIQ_SIM_WAIT_SEC:-12}"
BUILD_RETRIES="${CIQ_BUILD_RETRIES:-2}"
RUN_RETRIES="${CIQ_RUN_RETRIES:-2}"
KILL_BEFORE_RUN="${CIQ_KILL_BEFORE_RUN:-1}"
BUILD_ONLY=0

usage() {
  cat <<'EOF'
Usage:
  ./scripts/run_manifest_smoke.sh [--build-only]

Description:
  - manifest.xml に記載された全機種をビルド
  - (default) 各機種をシミュレーターで起動し、ログの [SETTINGS] 行を検出して起動確認

Options:
  --build-only   シミュレーター起動/ログ確認を行わず、ビルドのみ実施

Env:
  CIQ_DEV_KEY            開発者キーのパス
  CIQ_SMOKE_TIMEOUT_SEC  1機種あたりのログ待機秒数 (default: 20)
  CIQ_SIM_WAIT_SEC       シミュレーター起動待機秒数 (default: 12)
  CIQ_BUILD_RETRIES      monkeyc リトライ回数 (default: 2)
  CIQ_RUN_RETRIES        monkeydo リトライ回数 (default: 2)
  CIQ_KILL_BEFORE_RUN    起動前に既存simulatorをkill (default: 1)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --build-only)
      BUILD_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set."
  exit 1
fi

if [[ ! -f "$DEV_KEY" ]]; then
  echo "ERROR: Developer key not found: $DEV_KEY"
  exit 1
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
  echo "ERROR: Manifest not found: $MANIFEST_PATH"
  exit 1
fi

typeset -a DEVICES
DEVICES=("${(@f)$(sed -n 's/.*<iq:product id=\"\([^\"]*\)\".*/\1/p' "$MANIFEST_PATH")}")

if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "ERROR: No products found in manifest.xml"
  exit 1
fi

TS="$(date '+%Y%m%d_%H%M%S')"
OUT_DIR="$PROJECT_ROOT/bin/smoke_manifest_$TS"
LOG_DIR="$OUT_DIR/logs"
mkdir -p "$LOG_DIR"

SUMMARY_TSV="$OUT_DIR/summary.tsv"
echo -e "device\tbuild\tlaunch\tsettings_log\tsettings_line\tlog_path" > "$SUMMARY_TSV"

ensure_simulator_running() {
  local sim_exec="$CONNECTIQ_HOME/bin/ConnectIQ.app/Contents/MacOS/simulator"

  if [[ "$KILL_BEFORE_RUN" == "1" ]]; then
    pkill -f "ConnectIQ.app/Contents/MacOS/simulator" >/dev/null 2>&1 || true
    sleep 1
  fi

  if [[ -x "$sim_exec" ]]; then
    "$sim_exec" >/tmp/connectiq_simulator_stdout.log 2>&1 &
  fi

  if ! "$CONNECTIQ_HOME/bin/connectiq" >/dev/null 2>&1; then
    open "$CONNECTIQ_HOME/bin/ConnectIQ.app" >/dev/null 2>&1 || true
  fi

  sleep "$SIM_WAIT_SEC"
  return 0
}

run_and_check_settings_log() {
  local prg_path="$1"
  local device_id="$2"
  local run_log="$3"
  local settings_path="${prg_path%.prg}-settings.json"
  local settings_found=0
  local run_status=1
  local matched_line="-"

  typeset -a monkeydo_args
  monkeydo_args=("$prg_path" "$device_id")
  if [[ -f "$settings_path" ]]; then
    local settings_basename="${settings_path##*/}"
    local settings_dest="GARMIN/Settings/$settings_basename"
    monkeydo_args+=("-a" "$settings_path:$settings_dest")
    settings_found=1
  fi

  local attempt=1
  while [[ $attempt -le "$RUN_RETRIES" ]]; do
    local attempt_log="$run_log"
    if [[ "$RUN_RETRIES" -gt 1 ]]; then
      attempt_log="${run_log%.log}.attempt${attempt}.log"
    fi
    : > "$attempt_log"

    "$CONNECTIQ_HOME/bin/monkeydo" "${monkeydo_args[@]}" >"$attempt_log" 2>&1 &
    local run_pid=$!

    local i=0
    while [[ $i -lt "$TIMEOUT_SEC" ]]; do
      if rg -q "\\[SETTINGS\\]" "$attempt_log"; then
        run_status=0
        break
      fi
      if ! kill -0 "$run_pid" 2>/dev/null; then
        break
      fi
      sleep 1
      i=$((i + 1))
    done

    if kill -0 "$run_pid" 2>/dev/null; then
      kill "$run_pid" >/dev/null 2>&1 || true
      sleep 1
      kill -9 "$run_pid" >/dev/null 2>&1 || true
    fi
    wait "$run_pid" >/dev/null 2>&1 || true

    cp "$attempt_log" "$run_log"
    if [[ $run_status -eq 0 ]]; then
      matched_line="$(rg -m1 "\\[SETTINGS\\]" "$attempt_log" || true)"
      break
    fi
    attempt=$((attempt + 1))
    # Simulator startup can take around 10 seconds.
    sleep "$SIM_WAIT_SEC"
  done

  if [[ $run_status -eq 0 ]]; then
    if [[ $settings_found -eq 1 ]]; then
      echo "PASS_WITH_SETTINGS_FILE"
    else
      echo "PASS_NO_SETTINGS_FILE"
    fi
    echo "$matched_line"
    return 0
  fi
  echo "FAIL_NO_SETTINGS_LOG"
  echo "-"
  return 1
}

build_with_retry() {
  local device_id="$1"
  local prg_path="$2"
  local build_log="$3"
  local attempt=1

  : > "$build_log"
  while [[ $attempt -le "$BUILD_RETRIES" ]]; do
    if "$CONNECTIQ_HOME/bin/monkeyc" \
        -f "$PROJECT_ROOT/monkey.jungle" \
        -o "$prg_path" \
        -d "$device_id" \
        -y "$DEV_KEY" \
        -w >"$build_log" 2>&1; then
      return 0
    fi
    if [[ $attempt -lt "$BUILD_RETRIES" ]]; then
      echo "Retrying build: ${device_id} (${attempt}/${BUILD_RETRIES})" >> "$build_log"
      sleep 1
    fi
    attempt=$((attempt + 1))
  done
  return 1
}

if [[ "$BUILD_ONLY" -eq 0 ]]; then
  ensure_simulator_running
fi

echo "Smoke test start: devices=${#DEVICES[@]} output=$OUT_DIR"

for device_id in "${DEVICES[@]}"; do
  prg_path="$OUT_DIR/marathoncoach_${device_id}.prg"
  build_log="$LOG_DIR/${device_id}.build.log"
  run_log="$LOG_DIR/${device_id}.run.log"

  echo "[BUILD] $device_id"
  if build_with_retry "$device_id" "$prg_path" "$build_log"; then
    if [[ "$BUILD_ONLY" -eq 1 ]]; then
      echo -e "${device_id}\tPASS\tSKIP\tSKIP\tSKIP\t${build_log}" >> "$SUMMARY_TSV"
      continue
    fi
  else
    echo -e "${device_id}\tFAIL\tSKIP\tSKIP\t-\t${build_log}" >> "$SUMMARY_TSV"
    continue
  fi

  echo "[RUN]   $device_id"
  if run_output="$(run_and_check_settings_log "$prg_path" "$device_id" "$run_log")"; then
    run_ok=1
  else
    run_ok=0
  fi
  run_result="$(echo "$run_output" | sed -n '1p')"
  settings_line="$(echo "$run_output" | sed -n '2p' | tr '\t' ' ')"
  if [[ "$run_result" == PASS_* && "$run_ok" -eq 1 ]]; then
    echo -e "${device_id}\tPASS\tPASS\t${run_result}\t${settings_line}\t${run_log}" >> "$SUMMARY_TSV"
  else
    echo -e "${device_id}\tPASS\tFAIL\t${run_result}\t-\t${run_log}" >> "$SUMMARY_TSV"
  fi
done

echo ""
echo "Summary: $SUMMARY_TSV"
awk -F '\t' 'NR==1{next} {key=$2"/"$3"/"$4; cnt[key]++} END{for (k in cnt) print cnt[k], k}' "$SUMMARY_TSV" | sort -nr
