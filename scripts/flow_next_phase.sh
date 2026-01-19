#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== FLOW NEXT PHASE START ==="

# 前段レビューが NG なら止める
if [ -f reports/ai_review_gate.json ]; then
  if grep -q '"failed": \[' reports/ai_review_gate.json && ! grep -q '"failed": \[\]' reports/ai_review_gate.json; then
    echo "NG: Review gate failed → stop flow"
    exit 1
  fi
fi

# OK のときだけ次工程
echo "OK: Review passed → proceed next phase"

if [ -f scripts/foundation_stage_1_2_3.sh ]; then
  bash scripts/foundation_stage_1_2_3.sh
fi

echo "=== FLOW NEXT PHASE DONE ==="
