#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

MANIFEST_PATH="$PROJECT_ROOT/manifest.xml"
DEFAULT_RELEASE_KEY="/Users/eibakatsu/Downloads/grow/.vscode/developer_key"
RELEASE_KEY="${CIQ_RELEASE_KEY:-$DEFAULT_RELEASE_KEY}"
OUTPUT_VERSION="${1:-}"
OUTPUT_DIR_ARG="${2:-}"
APP_BASENAME="marathoncoach"
UNIT_TEST_LOG="$PROJECT_ROOT/bin/marathoncoach_tests.run.log"

usage() {
  cat <<'EOF'
Usage:
  ./scripts/build_release_package.sh [version] [output_dir]

Description:
  - Garmin Store 提出用の .iq を旧リリース鍵で署名して生成する
  - 既定では manifest.xml の version を読み、bin/releases/<version>/ へ出力する
  - 署名鍵は CIQ_RELEASE_KEY を最優先し、未指定時は旧公開版で使っていた固定鍵を使う

Arguments:
  version     出力版。省略時は manifest.xml の version
  output_dir  出力先。省略時は bin/releases/<version>

Env:
  CIQ_RELEASE_KEY  公開版署名鍵のパス

Notes:
  - このスクリプトは CIQ_DEV_KEY を参照しない
  - Store に提出する .iq は必ずこのスクリプト経由で生成する
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ -z "${CONNECTIQ_HOME:-}" ]]; then
  echo "ERROR: CONNECTIQ_HOME is not set."
  exit 1
fi

if [[ ! -f "$MANIFEST_PATH" ]]; then
  echo "ERROR: Manifest not found: $MANIFEST_PATH"
  exit 1
fi

if [[ ! -f "$RELEASE_KEY" ]]; then
  echo "ERROR: Release signing key not found: $RELEASE_KEY"
  echo "Set CIQ_RELEASE_KEY to the Garmin Store signing key if it has moved."
  exit 1
fi

if [[ -z "$OUTPUT_VERSION" ]]; then
  OUTPUT_VERSION="$(
    sed -n '/<iq:application /s/.*version="\([^"]*\)".*/\1/p' "$MANIFEST_PATH" | head -n 1
  )"
fi

if [[ -z "$OUTPUT_VERSION" ]]; then
  echo "ERROR: Could not resolve release version from manifest.xml"
  exit 1
fi

OUTPUT_DIR="${OUTPUT_DIR_ARG:-$PROJECT_ROOT/bin/releases/$OUTPUT_VERSION}"
OUTPUT_IQ="$OUTPUT_DIR/${APP_BASENAME}.iq"
BUILD_RECORD="$OUTPUT_DIR/BUILD.md"

mkdir -p "$OUTPUT_DIR"

echo "Packaging release .iq"
echo "  version: $OUTPUT_VERSION"
echo "  output : $OUTPUT_IQ"
echo "  key    : $RELEASE_KEY"

JAVA_TOOL_OPTIONS=-Djava.awt.headless=true \
  "$CONNECTIQ_HOME/bin/monkeyc" \
  -f "$PROJECT_ROOT/monkey.jungle" \
  -o "$OUTPUT_IQ" \
  -y "$RELEASE_KEY" \
  -w \
  -r \
  -e

PACKAGE_SHA="$(shasum -a 256 "$OUTPUT_IQ" | awk '{print $1}')"
PACKAGE_SIZE="$(wc -c < "$OUTPUT_IQ" | tr -d '[:space:]')"
SOURCE_COMMIT="$(git -C "$PROJECT_ROOT" rev-parse HEAD 2>/dev/null || echo unknown)"

if [[ -f "$UNIT_TEST_LOG" ]]; then
  cp "$UNIT_TEST_LOG" "$OUTPUT_DIR/unit_tests.run.log"
fi

cat > "$BUILD_RECORD" <<EOF
# Build Memo

- built_at: \`$(date '+%Y-%m-%d %H:%M:%S %z')\`
- release_type: \`PUBLIC\`
- version: \`$OUTPUT_VERSION\`
- branch: \`$(git -C "$PROJECT_ROOT" branch --show-current 2>/dev/null || echo unknown)\`
- source_commit: \`$SOURCE_COMMIT\`
- app_id: \`12e1a6ba-4da8-47a1-b9ef-710f630f7c73\`
- signing_key: \`$RELEASE_KEY\`
- output: \`bin/releases/$OUTPUT_VERSION/${APP_BASENAME}.iq\`
- size: \`${PACKAGE_SIZE} bytes\`
- sha256: \`$PACKAGE_SHA\`

## Build Command

\`\`\`sh
CIQ_RELEASE_KEY="$RELEASE_KEY" ./scripts/build_release_package.sh $OUTPUT_VERSION
\`\`\`

## Notes
- Garmin Store 提出用パッケージは旧公開版と同じ署名鍵で生成した。
- \`CIQ_DEV_KEY\` や \`./.vscode/developer_key\` ではなく、この build record の \`signing_key\` を使うこと。
EOF

echo "Release package created: $OUTPUT_IQ"
echo "SHA-256: $PACKAGE_SHA"
