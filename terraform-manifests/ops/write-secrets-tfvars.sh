#!/usr/bin/env bash
# Write gitignored secrets.tfvars from env vars (never commit the result).
#
# CodeBuild maps Parameter Store into the environment:
#   DB_PASSWORD      <- /CodeBuild/DB_PASSWORD
#   APP3_DB_PASSWORD <- /CodeBuild/APP3_DB_PASSWORD
#
# Usage (from terraform-manifests/):
#   ./ops/write-secrets-tfvars.sh
#   ./ops/write-secrets-tfvars.sh /path/to/secrets.tfvars

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-${ROOT_DIR}/secrets.tfvars}"

if [[ -z "${DB_PASSWORD:-}" || -z "${APP3_DB_PASSWORD:-}" ]]; then
  echo "DB_PASSWORD and APP3_DB_PASSWORD must be set (CodeBuild parameter-store)." >&2
  exit 1
fi

# Escape \ and " so values are valid HCL double-quoted strings.
hcl_escape() {
  local s=$1
  s=${s//\\/\\\\}
  s=${s//\"/\\\"}
  printf '%s' "$s"
}

printf 'db_password = "%s"\napp3_db_password = "%s"\n' \
  "$(hcl_escape "$DB_PASSWORD")" \
  "$(hcl_escape "$APP3_DB_PASSWORD")" > "$OUT"

chmod 600 "$OUT"
echo "Wrote ${OUT} from Parameter Store env vars (file is gitignored)."
