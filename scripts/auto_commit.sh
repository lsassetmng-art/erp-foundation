#!/data/data/com.termux/files/usr/bin/bash
set -e

REPO="$HOME/erp-foundation"
cd "$REPO"

echo "== Generate UseCases =="
python3 tools/generate_usecases.py

# company_id ガード（Fail Fast）
if grep -R "company_id" app/src/main/java >/dev/null 2>&1; then
  echo "ERROR: company_id detected in generated code"
  exit 1
fi

if [ -z "$(git status --porcelain)" ]; then
  echo "== No changes. Skip commit. =="
  exit 0
fi

git add -A
git commit -m "ai: generate usecases from yaml"

echo "== Committed =="
git --no-pager log -1 --oneline
