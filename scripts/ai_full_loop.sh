#!/data/data/com.termux/files/usr/bin/bash
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== AI FULL LOOP START ==="

python3 tools/pm_usecase_ai.py
python3 tools/spec_diff_ai.py
python3 ai_roles/architect_ai.py
bash ai_roles/reviewer_ai.sh
bash ai_roles/coder_ai.sh

echo "=== AI FULL LOOP DONE ==="
