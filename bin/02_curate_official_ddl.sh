#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"

SRC="$ERP_HOME/ddl/official/official_ddl.sql"
OUT="$ERP_HOME/ddl/official/official_ddl.curated.sql"

[ -f "$SRC" ] || { echo "NG: not found: $SRC"; exit 92; }

# Drop obvious supabase-managed schemas & objects + RLS/POLICY statements
# (keep your app schemas; adjust allowlist if needed)
# NOTE: We remove whole statements for CREATE POLICY / ALTER TABLE ... ENABLE RLS
#       and also remove auth/storage/realtime extensions noise.
sed -E '
/^--/b keep_comment
b main
:keep_comment
p
b end
:main
/^(CREATE|ALTER|DROP)[[:space:]]+.*(SCHEMA[[:space:]]+auth|SCHEMA[[:space:]]+storage|SCHEMA[[:space:]]+realtime|SCHEMA[[:space:]]+extensions)/Id
/^(CREATE|ALTER|DROP)[[:space:]]+.*(auth\.|storage\.|realtime\.|extensions\.|pg_catalog\.|information_schema\.)/Id
/^[[:space:]]*ALTER[[:space:]]+TABLE[[:space:]]+.*ENABLE[[:space:]]+ROW[[:space:]]+LEVEL[[:space:]]+SECURITY[[:space:]]*;[[:space:]]*$/Id
/^[[:space:]]*CREATE[[:space:]]+POLICY[[:space:]]+/Id
/^[[:space:]]*DROP[[:space:]]+POLICY[[:space:]]+/Id
/^[[:space:]]*ALTER[[:space:]]+TABLE[[:space:]]+.*FORCE[[:space:]]+ROW[[:space:]]+LEVEL[[:space:]]+SECURITY[[:space:]]*;[[:space:]]*$/Id
p
:end
' "$SRC" > "$OUT"

echo "OK: curated ddl created"
echo "$OUT"
exit 0
