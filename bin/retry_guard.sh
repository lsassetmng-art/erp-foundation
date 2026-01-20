#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
INBOX="$ROOT/pm_ai/inbox"
QUAR="$ROOT/pm_ai/quarantine"

TASK="$1"
[ -f "$TASK" ] || exit 0

mkdir -p "$QUAR"

RETRY="$(grep '^retry:' "$TASK" 2>/dev/null | awk '{print $2}' || echo 0)"
RETRY="${RETRY:-0}"

if [ "$RETRY" -ge 3 ]; then
  mv "$TASK" "$QUAR/$(basename "$TASK")"
  exit 9
fi

# retry +1
grep -v '^retry:' "$TASK" > "$TASK.tmp"
echo "retry: $((RETRY + 1))" >> "$TASK.tmp"
mv "$TASK.tmp" "$TASK"

exit 0
