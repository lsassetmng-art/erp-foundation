#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ============================================================
# foundation_next_stage.sh
# - cd 位置非依存
# - 次段UI / Review / Test 自動処理の入口
# ============================================================

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== FOUNDATION NEXT STAGE START ==="

# --- Apply next stage if exists ---
if [ -f tools/apply_next_stage.py ]; then
  python3 tools/apply_next_stage.py
else
  echo "WARN: tools/apply_next_stage.py not found (skip)"
fi

echo "=== FOUNDATION NEXT STAGE DONE ==="
