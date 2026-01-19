#!/bin/sh
set -eu

REPO="$(cd "$(dirname "$0")/.." && pwd)"
INBOX="$REPO/pm_ai/inbox"
DONE="$REPO/pm_ai/done"
LOG="$REPO/logs/pm_loop.log"
RULES="$REPO/pm_ai/rules"

echo "▶ pm_loop start"
echo "▶ repo: $REPO"

# --- rules existence check (HARD) ---
if [ ! -d "$RULES" ] || [ -z "$(ls -A "$RULES" 2>/dev/null)" ]; then
  echo "❌ PM rules not found or empty: $RULES"
  exit 3
fi

cd "$REPO"

# --- clean check ---
if [ -n "$(git status --porcelain)" ]; then
  echo "❌ working tree not clean; stop"
  git status --short
  exit 2
fi

mkdir -p "$DONE" "$(dirname "$LOG")"

dispatch_one() {
  task="$1"
  name="$(basename "$task")"

  # 対象業務を抽出（最初に一致した erp-xxx）
  target="$(grep -Eo 'erp-[a-z]+' "$task" | head -n 1 || true)"

  if [ -z "$target" ]; then
    echo "⚠ WARNING: no target repo in $name" | tee -a "$LOG"
    return 0
  fi

  dest="$HOME/$target/pm_ai/inbox"
  if [ ! -d "$dest" ]; then
    echo "⚠ WARNING: target repo not found: $target" | tee -a "$LOG"
    return 0
  fi

  cp "$task" "$dest/$name"
  echo "➡ dispatched to $target" | tee -a "$LOG"
}

count=0
for task in "$INBOX"/*.md; do
  [ -e "$task" ] || break
  name="$(basename "$task")"
  echo "▶ task: $name"

  # マスタ判定ヒント（警告）
  if ! grep -Eq 'マスタ|共通マスタ|準マスタ|マスタ判定' "$task"; then
    echo "⚠ WARNING: master judgment not found in $name" | tee -a "$LOG"
  fi

  dispatch_one "$task"
  mv "$task" "$DONE/$name"
  count=$((count+1))
done

echo "✔ processed $count task(s)"
echo "▶ pm_loop end"
exit 0
