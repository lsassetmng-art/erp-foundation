#!/bin/sh
set -e

BASE="$HOME/erp-foundation"
INBOX="$BASE/pm_ai/inbox"

title="${1:-task}"
ts="$(date +%Y%m%d_%H%M%S)"
slug="$(echo "$title" | tr ' ' '_' | tr -cd 'A-Za-z0-9_-')"
id="${ts}_${slug}"

mkdir -p "$INBOX"
f="$INBOX/${id}.md"

# read stdin to file
cat >"$f"

echo "✅ created task: $f"
exit 0
