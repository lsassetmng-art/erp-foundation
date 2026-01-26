#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${ERP_HOME:=$HOME/erp-foundation}"

SRC="$ERP_HOME/ddl/official/official_ddl.curated.sql"
DST="$ERP_HOME/ddl/official/official_ddl.FROZEN.sql"
SUM="$ERP_HOME/ddl/official/official_ddl.FROZEN.sha256"

[ -f "$SRC" ] || { echo "NG: not found: $SRC"; exit 94; }

cp -f "$SRC" "$DST"
if command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$DST" > "$SUM"
else
  # fallback
  python3 - <<PY > "$SUM"
import hashlib, pathlib
p=pathlib.Path(r"$DST")
h=hashlib.sha256(p.read_bytes()).hexdigest()
print(h, p.name)
PY
fi

echo "OK: FROZEN"
echo "ddl : $DST"
echo "sum : $SUM"
exit 0
