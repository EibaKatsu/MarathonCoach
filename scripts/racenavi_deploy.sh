#!/bin/zsh

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

CONFIG_FILE="${DEPLOY_CONFIG:-$REPO_ROOT/.deploy/racenavi.env}"
COMMAND="${1:-help}"

if [[ -f "$CONFIG_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$CONFIG_FILE"
else
  echo "Config file not found: $CONFIG_FILE" >&2
  echo "Copy .deploy/racenavi.env.example to .deploy/racenavi.env and fill in your values." >&2
  exit 1
fi

: "${DEPLOY_HOST:?DEPLOY_HOST is required}"
: "${DEPLOY_USER:?DEPLOY_USER is required}"
: "${DEPLOY_PASSWORD:?DEPLOY_PASSWORD is required}"
: "${DEPLOY_REMOTE_DIR:?DEPLOY_REMOTE_DIR is required}"

SOURCE_DIR_VALUE="${DEPLOY_SOURCE_DIR:-site/racenavi}"
if [[ "$SOURCE_DIR_VALUE" = /* ]]; then
  SOURCE_DIR="$SOURCE_DIR_VALUE"
else
  SOURCE_DIR="$REPO_ROOT/$SOURCE_DIR_VALUE"
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

typeset -a CURL_ARGS
CURL_ARGS=(
  --silent
  --show-error
  --fail
  --ftp-ssl-reqd
  --ftp-pasv
  --user "$DEPLOY_USER:$DEPLOY_PASSWORD"
)

if [[ "${DEPLOY_INSECURE:-0}" = "1" ]]; then
  CURL_ARGS+=(--insecure)
fi

remote_url() {
  local remote_path="$1"
  echo "ftp://$DEPLOY_HOST${remote_path}"
}

check_connection() {
  echo "Checking FTPS connection to $DEPLOY_HOST ..."
  curl "${CURL_ARGS[@]}" "$(remote_url "${DEPLOY_REMOTE_DIR%/}/")"
}

upload_site() {
  local file
  local rel_path
  local remote_path
  local upload_count=0

  echo "Uploading files from $SOURCE_DIR"
  while IFS= read -r -d '' file; do
    rel_path="${file#$SOURCE_DIR/}"
    remote_path="${DEPLOY_REMOTE_DIR%/}/$rel_path"
    echo "  -> $rel_path"
    curl "${CURL_ARGS[@]}" --ftp-create-dirs -T "$file" "$(remote_url "$remote_path")"
    upload_count=$((upload_count + 1))
  done < <(find "$SOURCE_DIR" -type f ! -name '.DS_Store' ! -name 'README.md' -print0)

  echo "Uploaded $upload_count files."
  if [[ -n "${DEPLOY_PUBLIC_URL:-}" ]]; then
    echo "Public URL: ${DEPLOY_PUBLIC_URL}"
  fi
}

usage() {
  cat <<'EOF'
Usage:
  scripts/racenavi_deploy.sh check
  scripts/racenavi_deploy.sh upload

Environment:
  DEPLOY_CONFIG=/absolute/path/to/envfile
EOF
}

case "$COMMAND" in
  check)
    check_connection
    ;;
  upload)
    upload_site
    ;;
  *)
    usage
    ;;
esac
