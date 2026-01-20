#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
QUEUE="$ROOT/pm_ai/approve_queue"
APPROVED="$ROOT/pm_ai/approved"
REJECTED="$ROOT/pm_ai/rejected"

TASK="$1"
[ -f "$TASK" ] || exit 0

mkdir -p "$QUEUE" "$APPROVED" "$REJECTED"

BASENAME="$(basename "$TASK")"
cp "$TASK" "$QUEUE/$BASENAME"

echo ""
echo "=== HUMAN APPROVAL REQUIRED ==="
echo "Task: $BASENAME"
echo "Approve? (y/n)"
read ans

if [ "$ans" = "y" ]; then
  mv "$QUEUE/$BASENAME" "$APPROVED/$BASENAME"
  exit 0
else
  mv "$QUEUE/$BASENAME" "$REJECTED/$BASENAME"
  exit 2
fi
