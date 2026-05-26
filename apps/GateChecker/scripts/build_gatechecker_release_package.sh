#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$APP_DIR/../.." && pwd)"
RACE_INDEX_PATH="$APP_DIR/race_defs/race_index.yml"
DEFAULT_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key"
RELEASE_KEY="${CIQ_RELEASE_KEY:-$DEFAULT_RELEASE_KEY}"
RACE_KEY="${1:-}"
OUTPUT_VERSION="${2:-}"
OUTPUT_DIR_ARG="${3:-}"

usage() {
  cat <<'EOF'
Usage:
  apps/GateChecker/scripts/build_gatechecker_release_package.sh <race_key> [version] [output_dir]

Description:
  - GateChecker の大会別リリース用 .iq を署名して生成する
  - 既定では race_index.yml に登録された version を使う
  - version を指定すると、一時ワークスペース上でその race の version だけ上書きして生成する
  - 既定出力先は apps/GateChecker/releases/<race_key>/<version>/

Arguments:
  race_key    race_defs/race_index.yml に登録されたキー
  version     生成時の version。省略時は race_index.yml の値
  output_dir  出力先。省略時は apps/GateChecker/releases/<race_key>/<version>

Env:
  CIQ_RELEASE_KEY  公開用署名鍵のパス

Notes:
  - このスクリプトは作業中の apps/GateChecker を直接書き換えない
  - Store 提出用や大会配布用の最終パッケージは .prg ではなく .iq を使う
EOF
}

if [[ "$RACE_KEY" == "-h" || "$RACE_KEY" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 3 ]]; then
  usage >&2
  exit 1
fi

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set." >&2
  exit 1
fi

if [[ ! -f "$RACE_INDEX_PATH" ]]; then
  echo "ERROR: race_index.yml not found: $RACE_INDEX_PATH" >&2
  exit 1
fi

if [[ ! -f "$RELEASE_KEY" ]]; then
  echo "ERROR: Release signing key not found: $RELEASE_KEY" >&2
  echo "Set CIQ_RELEASE_KEY if the release key has moved." >&2
  exit 1
fi

TMP_ROOT="$(mktemp -d /tmp/gatechecker_release.XXXXXX)"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

WORK_APP_DIR="$TMP_ROOT/GateChecker"
cp -R "$APP_DIR" "$WORK_APP_DIR"

if [[ -n "$OUTPUT_VERSION" ]]; then
  python3 - "$WORK_APP_DIR" "$RACE_KEY" "$OUTPUT_VERSION" <<'PY'
from pathlib import Path
import sys
import yaml

app_dir = Path(sys.argv[1])
race_key = sys.argv[2]
version = sys.argv[3]
path = app_dir / "race_defs" / "race_index.yml"

data = yaml.safe_load(path.read_text(encoding="utf-8")) or {}
races = data.get("races")
if not isinstance(races, list):
    raise SystemExit("race_index.yml must define races as a list.")

for entry in races:
    if not isinstance(entry, dict):
        continue
    if entry.get("race_id") != race_key:
        legacy = entry.get("legacy")
        if not isinstance(legacy, dict) or legacy.get("race_key") != race_key:
            continue
    legacy = entry.get("legacy")
    if not isinstance(legacy, dict):
        raise SystemExit(f"legacy build metadata is required for race_key: {race_key}")
    legacy["version"] = version
    break
else:
    raise SystemExit(f"race_key not found in race_index.yml: {race_key}")

path.write_text(
    yaml.safe_dump(
        data,
        allow_unicode=True,
        sort_keys=False,
        default_flow_style=False,
    ),
    encoding="utf-8",
)
PY
fi

resolved_lines="$(
  python3 - "$WORK_APP_DIR" "$RACE_KEY" <<'PY'
from pathlib import Path
import sys

app_dir = Path(sys.argv[1])
race_key = sys.argv[2]
sys.path.insert(0, str((app_dir / "scripts").resolve()))

from gatechecker_defs import find_race_entry, load_index_entries  # noqa: E402

_, entries = load_index_entries(app_dir / "race_defs" / "race_index.yml")
entry = find_race_entry(race_key, entries)
if entry.legacy_build is None:
    raise SystemExit(f"legacy build metadata is not available for {race_key}")

version = entry.legacy_build.version
definition = entry.definition_path.resolve().relative_to((app_dir / "race_defs").resolve())

print(version)
print(definition)
PY
)"

resolved_parts=("${(@f)resolved_lines}")

RESOLVED_VERSION="${resolved_parts[1]:-}"
DEFINITION_REL="${resolved_parts[2]:-}"

if [[ -z "$RESOLVED_VERSION" || -z "$DEFINITION_REL" ]]; then
  echo "ERROR: Failed to resolve version/definition for race_key=$RACE_KEY" >&2
  exit 1
fi

OUTPUT_DIR="${OUTPUT_DIR_ARG:-$APP_DIR/releases/$RACE_KEY/$RESOLVED_VERSION}"
OUTPUT_IQ="$OUTPUT_DIR/gatechecker-${RACE_KEY}-${RESOLVED_VERSION}.iq"
BUILD_RECORD="$OUTPUT_DIR/BUILD.md"
OUTPUT_DEFINITION="$OUTPUT_DIR/$(basename "$DEFINITION_REL")"
OUTPUT_MANIFEST="$OUTPUT_DIR/manifest.xml"
OUTPUT_GENERATED_SOURCE="$OUTPUT_DIR/GateRaceConfig.mc"

python3 "$WORK_APP_DIR/scripts/generate_gatechecker_race.py" "$RACE_KEY"

APP_ID="$(
  python3 - "$WORK_APP_DIR/manifest.xml" <<'PY'
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

manifest_path = Path(sys.argv[1])
root = ET.fromstring(manifest_path.read_text(encoding="utf-8"))
namespace = {"iq": "http://www.garmin.com/xml/connectiq"}
application = root.find("iq:application", namespace)
if application is None:
    raise SystemExit("manifest.xml does not contain iq:application")

app_id = application.attrib.get("id", "")
if not app_id:
    raise SystemExit("manifest.xml iq:application is missing id")

print(app_id)
PY
)"

if [[ -z "$APP_ID" ]]; then
  echo "ERROR: Failed to resolve app id from generated manifest." >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

echo "Packaging GateChecker release .iq"
echo "  race   : $RACE_KEY"
echo "  version: $RESOLVED_VERSION"
echo "  app id : $APP_ID"
echo "  output : $OUTPUT_IQ"
echo "  key    : $RELEASE_KEY"

JAVA_TOOL_OPTIONS=-Djava.awt.headless=true \
  "$CONNECTIQ_HOME/bin/monkeyc" \
  -f "$WORK_APP_DIR/monkey.jungle" \
  -o "$OUTPUT_IQ" \
  -y "$RELEASE_KEY" \
  -w \
  -r \
  -e

cp "$WORK_APP_DIR/race_defs/$DEFINITION_REL" "$OUTPUT_DEFINITION"
cp "$WORK_APP_DIR/manifest.xml" "$OUTPUT_MANIFEST"
cp "$WORK_APP_DIR/source/generated/GateRaceConfig.mc" "$OUTPUT_GENERATED_SOURCE"

PACKAGE_SHA="$(shasum -a 256 "$OUTPUT_IQ" | awk '{print $1}')"
PACKAGE_SIZE="$(wc -c < "$OUTPUT_IQ" | tr -d '[:space:]')"
SOURCE_COMMIT="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"

cat > "$BUILD_RECORD" <<EOF
# Build Memo

- built_at: \`$(date '+%Y-%m-%d %H:%M:%S %z')\`
- release_type: \`GATECHECKER_PUBLIC\`
- race_key: \`$RACE_KEY\`
- version: \`$RESOLVED_VERSION\`
- branch: \`$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo unknown)\`
- source_commit: \`$SOURCE_COMMIT\`
- app_id: \`$APP_ID\`
- signing_key: \`$RELEASE_KEY\`
- output: \`${OUTPUT_IQ#$PROJECT_ROOT/}\`
- manifest: \`${OUTPUT_MANIFEST#$PROJECT_ROOT/}\`
- race_definition: \`${OUTPUT_DEFINITION#$PROJECT_ROOT/}\`
- generated_source: \`${OUTPUT_GENERATED_SOURCE#$PROJECT_ROOT/}\`
- size: \`${PACKAGE_SIZE} bytes\`
- sha256: \`$PACKAGE_SHA\`

## Build Command

\`\`\`sh
CIQ_RELEASE_KEY="$RELEASE_KEY" apps/GateChecker/scripts/build_gatechecker_release_package.sh $RACE_KEY $RESOLVED_VERSION
\`\`\`

## Notes
- 一時ワークスペースで race/version を解決してからパッケージ化した。
- 同じ大会でも version を変えて別ディレクトリへ並行出力できる。
EOF

echo "GateChecker release package created: $OUTPUT_IQ"
echo "SHA-256: $PACKAGE_SHA"
