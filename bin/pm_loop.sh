#!/bin/sh
set -eu

REPO="$HOME/erp-foundation"
INBOX="$REPO/pm_ai/inbox"
DONE="$REPO/pm_ai/done"
RULES="$REPO/pm_ai/rules"
LINT="$REPO/bin/pm_lint.sh"
LOGS="$REPO/logs"

NOW="$(date '+%Y-%m-%d %H:%M:%S')"
STATUS_FILE="$LOGS/pm_loop.status"
LAST_FILE="$LOGS/pm_loop.last"
NOTIFY_FILE="$LOGS/pm_loop.notify"

mkdir -p "$DONE" "$LOGS"

notify_ok() {
  echo "[$NOW] ✅ pm_loop SUCCESS" > "$STATUS_FILE"
  echo "$NOW" > "$LAST_FILE"
  echo "PM LOOP SUCCESS at $NOW" > "$NOTIFY_FILE"
}

notify_ng() {
  CODE="$1"
  echo "[$NOW] ❌ pm_loop FAILED (exit=$CODE)" > "$STATUS_FILE"
  echo "$NOW" > "$LAST_FILE"
  echo "PM LOOP FAILED at $NOW (exit=$CODE)" > "$NOTIFY_FILE"
}

trap 'notify_ng $?' EXIT

echo "▶ pm_loop start"
echo "▶ repo: $REPO"

[ -d "$RULES" ] || { echo "❌ rules missing"; exit 2; }
[ -x "$LINT" ]  || { echo "❌ pm_lint.sh missing"; exit 3; }

cd "$REPO"

if ! git diff --quiet || [ -n "$(git ls-files --others --exclude-standard)" ]; then
  echo "❌ working tree not clean; stop"
  git status --short
  exit 4
fi

count=0
for TASK in "$INBOX"/*.md; do
  [ -f "$TASK" ] || continue

  echo "▶ lint: $(basename "$TASK")"
  "$LINT" "$TASK"

  TARGET=$(grep '^対象業務:' "$TASK" | awk '{print $2}')
  APPLY="$HOME/$TARGET/apply_task.sh"

  [ -x "$APPLY" ] || { echo "❌ apply_task.sh not found: $APPLY"; exit 5; }

  echo "▶ apply: $TARGET"
  "$APPLY" "$TASK"

  mv "$TASK" "$DONE/"
  count=$((count+1))
done

echo "✔ processed $count task(s)"
echo "▶ pm_loop end"

notify_ok
exit 0
