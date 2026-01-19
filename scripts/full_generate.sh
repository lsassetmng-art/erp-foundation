#!/data/data/com.termux/files/usr/bin/bash
set -e

# =====================================
# full_generate.sh
# - YAML → UseCase/DTO/Repository 生成
# - テスト/バリデータ生成
# - company_id ガード（domain限定）
# - auto_commit.sh 実行
# =====================================

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "=== FULL GENERATE START ==="

# ---------- 前提チェック ----------
if [ ! -f "spec/usecases.schema.yaml" ]; then
  echo "ERROR: spec/usecases.schema.yaml not found"
  exit 1
fi

# ---------- 生成フェーズ ----------
echo "[1/5] Generate UseCases / DTO / Repository"
echo "[B] Generate Repository Impl (Supabase RPC)"
echo "[C] Generate ViewModels"
python3 tools/generate_viewmodels.py
echo "[C] Generate Activities"
echo "[1C] Generate Compose Screens"
python3 tools/generate_compose_screens.py

echo "[2C] Generate Navigation Helpers"
python3 tools/generate_navigation_helpers.py

echo "[3C] Generate Espresso UI tests"
python3 tools/generate_espresso_tests.py

echo "[4C] UI Reviewer (static)"
python3 tools/ui_reviewer_ai.py

echo "[5C] Export for mobile IDE"
./scripts/export_for_mobile_ide.sh


echo "[D] Generate XML layouts"
echo "[XML] Wire Activities to XML"
python3 tools/wire_activity_xml.py

echo "[XML] Wire Activities to ViewModel"
echo "[XML] Add input forms"
echo "[E] Generate input XML from spec"
python3 tools/generate_input_xml_from_spec.py

echo "[E] Wire Activities from input spec"
python3 tools/wire_activity_from_input_spec.py

echo "[F] Generate Home menu (navigation)"
python3 tools/generate_home_menu.py

echo "[G] Export mobile templates"
./scripts/export_mobile_templates.sh

python3 tools/augment_xml_inputs.py

echo "[XML] Wire Activity to DTO"
python3 tools/wire_activity_dto.py

python3 tools/wire_activity_viewmodel.py

python3 tools/generate_xml_layouts.py

echo "[E] Enhance ViewModels"
python3 tools/enhance_viewmodels.py

echo "[G] Generate navigation graph"
python3 tools/generate_nav_graph.py

python3 tools/generate_activities.py

python3 tools/generate_repositories_impl.py

echo "[A] Generate ViewModels"
python3 tools/generate_viewmodels.py

python3 tools/generate_usecases.py

if [ -x "tools/generate_rpc_tests.py" ]; then
  echo "[2/5] Generate RPC positive tests"
  python3 tools/generate_rpc_tests.py
fi

if [ -x "tools/generate_rpc_validators.py" ]; then
  echo "[3/5] Generate RPC schema validators"
  python3 tools/generate_rpc_validators.py
fi

if [ -x "tools/generate_rpc_negative_tests.py" ]; then
  echo "[4/5] Generate RPC negative tests"
  python3 tools/generate_rpc_negative_tests.py
fi

# ---------- company_id ガード（domain限定） ----------
echo "[GUARD] Check company_id leakage in domain layer"

LEAK_FOUND=0

for DIR in \
  app/src/main/java/usecase \
  app/src/main/java/dto \
  app/src/main/java/repository
do
  if [ -d "$DIR" ]; then
    if grep -R "company_id" "$DIR" >/dev/null 2>&1; then
      echo "ERROR: company_id detected in $DIR"
      LEAK_FOUND=1
    fi
  fi
done

if [ "$LEAK_FOUND" -ne 0 ]; then
  echo "❌ company_id leakage detected in domain layer"
  exit 1
fi

echo "✅ company_id guard passed (domain clean)"

# ---------- commit & push ----------
echo "[5/5] Auto commit"
./scripts/auto_commit.sh "auto: full generate"

echo "=== FULL GENERATE DONE ==="
