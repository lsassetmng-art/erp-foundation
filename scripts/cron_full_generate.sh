#!/data/data/com.termux/files/usr/bin/bash
set -e

# cron / 手動 実行用
# - spec 変更を検知
# - 自動生成
# - Git 反映

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== CRON FULL GENERATE START ==="

# spec が存在する場合のみ
if [ ! -f "spec/usecases.schema.yaml" ]; then
  echo "No spec found, exit"
  exit 0
fi

# 生成
./scripts/full_generate.sh

echo "=== CRON FULL GENERATE END ==="
