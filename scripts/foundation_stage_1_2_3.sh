#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== FOUNDATION STAGE 1-2-3 START ==="

python3 tools/generate_repo_usecase.py
python3 tools/guard_company_id.py
python3 tools/generate_espresso_from_validation.py
python3 tools/ai_review_gate.py

echo "=== FOUNDATION STAGE 1-2-3 DONE ==="
