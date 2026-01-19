#!/bin/sh
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INBOX="$REPO/pm_ai/inbox"
DONE="$REPO/pm_ai/done"
LOG="$REPO/logs/pm_loop.log"

echo "▶ pm_loop start"
echo "▶ repo: $REPO"

cd "$REPO"

# --- clean check（今まで通り） ---
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ working tree not clean; stop"
  git status --short
  exit 2
fi

mkdir -p "$DONE" "$(dirname "$LOG")"

count=0
for task in "$INBOX"/*.md; do
  [ -e "$task" ] || break
  name="$(basename "$task")"
  echo "▶ task: $name"

  # --- マスタ指示チェック（警告のみ） ---
  if ! grep -Eq 'マスタ|共通マスタ|準マスタ|マスタ判定' "$task"; then
    echo "⚠ WARNING: master judgment not found in $name" | tee -a "$LOG"
    echo "  👉 マスタ管理 実装指示書の形式を推奨" | tee -a "$LOG"
  fi

  # （ここでは実装しない：運用どおり）
  mv "$task" "$DONE/$name"
  count=$((count + 1))
done

echo "✔ processed $count task(s)"
echo "▶ pm_loop end"
exit 0
