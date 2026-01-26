#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"
: "${DATABASE_URL:?NG: DATABASE_URL not set}"

DDL="$ERP_HOME/ddl/official/official_ddl.FROZEN.sql"
[ -f "$DDL" ] || { echo "NG: not found: $DDL"; exit 95; }

# connect/execute/disconnect included
psql "$DATABASE_URL" -X -v ON_ERROR_STOP=1 -f "$DDL"

echo "OK: applied frozen ddl"
exit 0
