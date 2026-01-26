#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL:?}"
: "${COMPANY_ID:?}"
FEATURE_KEY="${1:-}"
[ -n "$FEATURE_KEY" ] || { log_line NG "feature_key required"; exit 2; }
psql "$DATABASE_URL" -t -A <<SQL
select licensing.is_feature_enabled('${COMPANY_ID}'::uuid, '${FEATURE_KEY}');
SQL
