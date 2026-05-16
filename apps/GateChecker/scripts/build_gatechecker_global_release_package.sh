#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$APP_DIR/../.." && pwd)"
DEFAULT_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key"
RELEASE_KEY="${CIQ_RELEASE_KEY:-$DEFAULT_RELEASE_KEY}"
OUTPUT_VERSION="${1:-}"
OUTPUT_DIR_ARG="${2:-}"

usage() {
  cat <<'EOF'
Usage:
  apps/GateChecker/scripts/build_gatechecker_global_release_package.sh <version> [output_dir]

Description:
  - GateChecker global app の公開用 .iq を署名して生成する
  - version は temp workspace 上で manifest.xml に反映して build する
  - 既定出力先は apps/GateChecker/releases/global/<version>/

Arguments:
  version     生成時の version
  output_dir  出力先。省略時は apps/GateChecker/releases/global/<version>

Env:
  CIQ_RELEASE_KEY  公開用署名鍵のパス

Notes:
  - このスクリプトは作業中の apps/GateChecker を直接書き換えない
  - Store 提出用の最終パッケージは .prg ではなく .iq を使う
EOF
}

if [[ "$OUTPUT_VERSION" == "-h" || "$OUTPUT_VERSION" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 1
fi

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set." >&2
  exit 1
fi

if [[ ! -f "$RELEASE_KEY" ]]; then
  echo "ERROR: Release signing key not found: $RELEASE_KEY" >&2
  echo "Set CIQ_RELEASE_KEY if the release key has moved." >&2
  exit 1
fi

TMP_ROOT="$(mktemp -d /tmp/gatechecker_global_release.XXXXXX)"
cleanup() {
  rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

WORK_APP_DIR="$TMP_ROOT/GateChecker"
cp -R "$APP_DIR" "$WORK_APP_DIR"

python3 - "$WORK_APP_DIR/manifest.xml" "$OUTPUT_VERSION" <<'PY'
from pathlib import Path
import sys
import xml.etree.ElementTree as ET

manifest_path = Path(sys.argv[1])
version = sys.argv[2]

tree = ET.parse(manifest_path)
root = tree.getroot()
namespace = {"iq": "http://www.garmin.com/xml/connectiq"}
application = root.find("iq:application", namespace)
if application is None:
    raise SystemExit("manifest.xml does not contain iq:application")

application.set("version", version)
tree.write(manifest_path, encoding="UTF-8", xml_declaration=True)
PY

python3 "$WORK_APP_DIR/scripts/generate_gatechecker_all_races.py"

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

OUTPUT_DIR="${OUTPUT_DIR_ARG:-$APP_DIR/releases/global/$OUTPUT_VERSION}"
OUTPUT_IQ="$OUTPUT_DIR/gatechecker-global-$OUTPUT_VERSION.iq"
BUILD_RECORD="$OUTPUT_DIR/BUILD.md"
OUTPUT_MANIFEST="$OUTPUT_DIR/manifest.xml"
OUTPUT_GENERATED_SOURCE="$OUTPUT_DIR/GateRaceConfig.mc"
OUTPUT_SUPPORTED_RACES="$OUTPUT_DIR/supported_races.json"
OUTPUT_RACE_INDEX="$OUTPUT_DIR/race_index.yml"

mkdir -p "$OUTPUT_DIR"

echo "Packaging GateChecker global release .iq"
echo "  version: $OUTPUT_VERSION"
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

cp "$WORK_APP_DIR/manifest.xml" "$OUTPUT_MANIFEST"
cp "$WORK_APP_DIR/source/generated/GateRaceConfig.mc" "$OUTPUT_GENERATED_SOURCE"
cp "$WORK_APP_DIR/generated/supported_races.json" "$OUTPUT_SUPPORTED_RACES"
cp "$WORK_APP_DIR/race_defs/race_index.yml" "$OUTPUT_RACE_INDEX"

PACKAGE_SHA="$(shasum -a 256 "$OUTPUT_IQ" | awk '{print $1}')"
PACKAGE_SIZE="$(wc -c < "$OUTPUT_IQ" | tr -d '[:space:]')"
SOURCE_COMMIT="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"

cat > "$BUILD_RECORD" <<EOF
# Build Memo

- built_at: \`$(date '+%Y-%m-%d %H:%M:%S %z')\`
- release_type: \`GATECHECKER_GLOBAL_PUBLIC\`
- version: \`$OUTPUT_VERSION\`
- branch: \`$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo unknown)\`
- source_commit: \`$SOURCE_COMMIT\`
- app_id: \`$APP_ID\`
- signing_key: \`$RELEASE_KEY\`
- output: \`${OUTPUT_IQ#$PROJECT_ROOT/}\`
- manifest: \`${OUTPUT_MANIFEST#$PROJECT_ROOT/}\`
- generated_source: \`${OUTPUT_GENERATED_SOURCE#$PROJECT_ROOT/}\`
- supported_races: \`${OUTPUT_SUPPORTED_RACES#$PROJECT_ROOT/}\`
- race_index: \`${OUTPUT_RACE_INDEX#$PROJECT_ROOT/}\`
- size: \`${PACKAGE_SIZE} bytes\`
- sha256: \`$PACKAGE_SHA\`

## Build Command

\`\`\`sh
CIQ_RELEASE_KEY="$RELEASE_KEY" apps/GateChecker/scripts/build_gatechecker_global_release_package.sh $OUTPUT_VERSION
\`\`\`

## Notes
- 一時ワークスペースで manifest version を上書きしてからパッケージ化した。
- race 定義と generated assets の snapshot を release ディレクトリへ保存した。
EOF

echo "GateChecker global release package created: $OUTPUT_IQ"
echo "SHA-256: $PACKAGE_SHA"
