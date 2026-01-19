#!/bin/sh
set -eu

REPO="$HOME/erp-foundation"
INBOX="$REPO/pm_ai/inbox"
DONE="$REPO/pm_ai/done"
RULES="$REPO/pm_ai/rules"

echo "▶ pm_loop start"
echo "▶ repo: $REPO"

cd "$REPO"

# rules 前提チェック
[ -d "$RULES" ] || { echo "❌ rules missing"; exit 2; }

# git clean check
if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "❌ working tree not clean; stop"
  git status --short
  exit 3
fi

count=0
for TASK in "$INBOX"/*.md; do
  [ -f "$TASK" ] || continue

  TARGET=$(grep '^対象業務:' "$TASK" | awk '{print $2}')
  [ -n "$TARGET" ] || { echo "⚠ no target"; continue; }

  APPLY="$HOME/$TARGET/apply_task.sh"
  if [ ! -x "$APPLY" ]; then
    echo "❌ apply_task.sh not found: $APPLY"
    exit 4
  fi

  echo "▶ task: $(basename "$TASK")"
  echo "▶ call: $TARGET"
  "$APPLY" "$TASK"

  mv "$TASK" "$DONE/"
  count=$((count+1))
done

echo "✔ processed $count task(s)"
echo "▶ pm_loop end"
exit 0
