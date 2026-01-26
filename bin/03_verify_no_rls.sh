#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"

IN="${1:-$ERP_HOME/ddl/official/official_ddl.curated.sql}"
[ -f "$IN" ] || { echo "NG: not found: $IN"; exit 93; }

# Remove line comments, block comments, and single-quoted strings (best-effort) before scanning
CLEAN="$(
  sed \
    -e 's/--.*$//g' \
    -e ':a; /\/*/!{N;ba}; s@/\*[^*]*\*+([^/*][^*]*\*+)*/@@g' \
    -e "s/'[^']*'//g" \
    "$IN" 2>/dev/null || cat "$IN"
)"

echo "$CLEAN" | grep -nEi 'ALTER[[:space:]]+TABLE[[:space:]]+.*ENABLE[[:space:]]+ROW[[:space:]]+LEVEL[[:space:]]+SECURITY|CREATE[[:space:]]+POLICY' \
  && { echo "NG: RLS still in curated ddl"; exit 20; } \
  || true

echo "OK: curated ddl contains NO RLS/POLICY"
exit 0
