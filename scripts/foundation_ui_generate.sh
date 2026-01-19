#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

###############################################################################
# foundation_ui_generate.sh
# - ViewModel.executeSafe() 生成
# - Fragment + HostActivity + nav_graph 生成
# - Sketchware 用 export
# ※ cd 位置非依存（スクリプト基点）
###############################################################################

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== FOUNDATION UI GENERATE START ==="

# ---------- 前提チェック ----------
for d in tools spec app scripts; do
  if [ ! -d "$d" ]; then
    echo "ERROR: required directory missing: $d"
    exit 1
  fi
done

# ---------- [1/4] ViewModels ----------
echo "[1/4] Generate ViewModels (executeSafe + validation)"
python3 tools/generate_viewmodel_execute_safe.py

# ---------- [2/4] Fragments / HostActivity / Nav ----------
echo "[2/4] Generate Fragments + HostActivity + nav_graph"
python3 tools/generate_fragments_from_spec.py
python3 tools/generate_nav_graph.py

# ---------- [3/4] Sketchware Export ----------
echo "[3/4] Export for Sketchware"
bash scripts/export_mobile_templates.sh

# ---------- [4/4] Done ----------
echo "[4/4] Done"
echo "Check:"
echo " - Nav:        app/src/main/res/navigation/nav_graph.xml"
echo " - Fragments:  app/src/main/java/app/ui/fragment/"
echo " - ViewModels: app/src/main/java/app/ui/viewmodel/"
echo " - Export:     exports/sketchware/export_*/"

echo "=== FOUNDATION UI GENERATE DONE ==="
