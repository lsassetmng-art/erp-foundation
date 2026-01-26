#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

: "${DATABASE_URL:?DATABASE_URL is not set}"

echo "== foundation_phase2_check =="

# 1. 基盤チェックは通るか
echo "[1/4] core check..."
bash "$HOME/erp-foundation/bin/foundation_check.sh"
echo "  OK"

# 2. 設定キー存在チェック
echo "[2/4] foundation_config keys..."

REQUIRED_KEYS="
post_login_destination
foundation_version
foundation_mode
"

for k in $REQUIRED_KEYS; do
  psql "$DATABASE_URL" -Atc "
    select 1
    from foundation.foundation_config
    where config_key = '$k';
  " | grep -q 1 || {
    echo "  NG: missing config_key=$k" >&2
    exit 1
  }
done

echo "  OK"

# 3. Outbox テーブル最低条件
echo "[3/4] outbox sanity..."

psql "$DATABASE_URL" -Atc "
select count(*)
from foundation.outbox_event;
" >/dev/null

echo "  OK"

# 4. RPC 呼び出し可能か（authなし想定）
echo "[4/4] rpc callable..."

psql "$DATABASE_URL" -Atc "
select proname
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname='foundation'
  and p.proname='get_my_foundation_context';
" | grep -q get_my_foundation_context

echo "  OK"

echo "== foundation_phase2_check: ALL OK =="
