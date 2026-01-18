#!/data/data/com.termux/files/usr/bin/bash
set -e

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== PM AUTO LOOP START ==="

# PM → UseCase
python3 tools/pm_usecase_ai.py

# Review
bash scripts/review_usecases.sh

# チーム指示書
python3 tools/generate_team_instructions.py

# 実装生成
bash scripts/full_generate.sh

echo "=== PM AUTO LOOP DONE ==="
