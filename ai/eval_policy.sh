#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL is required}"

BASE="${ERP_HOME:-$HOME/erp-foundation}"
POL="$BASE/policy/policy.yaml"
OUT_JSON="$BASE/run/eval.json"
LOG="$BASE/log/eval.log"

mkdir -p "$BASE/run" "$BASE/log"

ts="$(date -Is)"
echo "{\"ts\":\"$ts\",\"status\":\"ok\"}" > "$OUT_JSON"

val="$(psql "$DATABASE_URL" -At -c "select 1")" || exit 10
