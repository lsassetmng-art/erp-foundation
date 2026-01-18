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
