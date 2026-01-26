#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
BASE="${ERP_HOME:-$HOME/erp-foundation}"
IN="${1:-$BASE/ddl/official/official_ddl.sql}"
OUT_OFF="${2:-$BASE/ddl/official/official_ddl.curated.sql}"
OUT_EXP="${3:-$BASE/ddl/experimental/experimental_snippets.sql}"

if [ ! -f "$IN" ]; then
  echo "ERROR: input not found: $IN" >&2
  exit 2
fi

cp -f "$IN" "$OUT_OFF"
: > "$OUT_EXP"

echo "OK: curated created"
