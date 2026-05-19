#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CONTENT_DIR="$BASE_DIR/content"
mkdir -p "$CONTENT_DIR"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <markdown-file>"
  exit 1
fi

SOURCE_FILE="$1"
if [[ ! -f "$SOURCE_FILE" ]]; then
  echo "Error: source file not found: $SOURCE_FILE"
  exit 1
fi

DATE_STR="$(date -u +%F)"
TARGET_FILE="$CONTENT_DIR/${DATE_STR}.md"

if [[ -e "$TARGET_FILE" ]]; then
  n=2
  while [[ -e "$CONTENT_DIR/${DATE_STR}-${n}.md" ]]; do
    n=$((n + 1))
  done
  TARGET_FILE="$CONTENT_DIR/${DATE_STR}-${n}.md"
fi

cp "$SOURCE_FILE" "$TARGET_FILE"
echo "Saved: $TARGET_FILE"
