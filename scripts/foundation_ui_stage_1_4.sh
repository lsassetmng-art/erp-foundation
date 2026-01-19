#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== UI STAGE 1-4 START ==="

python3 tools/generate_ui_binding.py
python3 tools/generate_validation_schema.py
python3 tools/generate_ui_tests.py
python3 tools/ai_review_ui.py

echo "=== UI STAGE 1-4 DONE ==="
echo "Check:"
echo " - Fragment: app/src/main/java/app/ui/fragment"
echo " - ViewModel: app/src/main/java/app/ui/viewmodel"
echo " - Validation: spec/validation.schema.yaml"
echo " - Test: app/src/test/java/app/ui"
echo " - Review: reports/ai_review_ui.md"
