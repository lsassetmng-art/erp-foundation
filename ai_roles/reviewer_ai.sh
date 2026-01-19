#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "[ReviewerAI] reviewing spec & code"

bash scripts/review_usecases.sh

# 実行ロジックのみチェック（コメント・ガード除外）
if grep -R "company_id" app/src/main/java \
 | grep -vE "(禁止|Forbidden|NEVER|block|IllegalState|//|/\\*)" \
 >/dev/null; then
  echo "NG: company_id used in logic"
  exit 1
fi

echo "OK: ReviewerAI passed (logic clean)"
