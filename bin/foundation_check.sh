#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is not set}"

echo "== foundation_check =="

# -----------------------------------
# 1. DB接続チェック
# -----------------------------------
echo "[1/5] database connection..."
psql "$DATABASE_URL" -c "select 1;" >/dev/null
echo "  OK"

# -----------------------------------
# 2. foundation schema 存在チェック
# -----------------------------------
echo "[2/5] schema existence..."
psql "$DATABASE_URL" -Atc "
select 1
from information_schema.schemata
where schema_name = 'foundation';
" | grep -q 1
echo "  OK"

# -----------------------------------
# 3. 主要テーブル存在チェック
# -----------------------------------
echo "[3/5] core tables..."

REQUIRED_TABLES="
schema_version
company
company_user
role
permission
role_permission
user_role
license
foundation_config
outbox_event
"

for tbl in $REQUIRED_TABLES; do
  psql "$DATABASE_URL" -Atc "
    select 1
    from information_schema.tables
    where table_schema = 'foundation'
      and table_name = '$tbl';
  " | grep -q 1 || {
    echo "  NG: missing table foundation.$tbl" >&2
    exit 1
  }
done

echo "  OK"

# -----------------------------------
# 4. RPC 存在チェック
# -----------------------------------
echo "[4/5] rpc function..."

psql "$DATABASE_URL" -Atc "
select 1
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'foundation'
  and p.proname = 'get_my_foundation_context';
" | grep -q 1

echo "  OK"

# -----------------------------------
# 5. 基盤バージョン取得チェック
# -----------------------------------
echo "[5/5] foundation version..."

VERSION=$(psql "$DATABASE_URL" -Atc "
select config_value
from foundation.foundation_config
where config_key = 'foundation_version'
limit 1;
")

if [ -z "$VERSION" ]; then
  echo "  NG: foundation_version not found" >&2
  exit 1
fi

echo "  OK (version=$VERSION)"

echo "== foundation_check: ALL OK =="
