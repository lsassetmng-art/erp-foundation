#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"
: "${DATABASE_URL:?NG: DATABASE_URL not set}"
command -v psql >/dev/null 2>&1 || { echo "NG: psql not found"; exit 90; }

# connect test (connect/disconnect included)
psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "select current_user, current_database();" >/dev/null
echo "OK: env + psql connectivity"
exit 0
