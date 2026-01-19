#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== UI NEXT STAGE START ==="

python3 tools/patch_viewmodel_validation.py
python3 tools/generate_espresso_tests.py
python3 tools/ai_review_ci.py

echo "=== UI NEXT STAGE DONE ==="
