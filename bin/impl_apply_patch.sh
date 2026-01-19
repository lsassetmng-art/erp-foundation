#!/bin/sh
set -e

PATCH_FILE="${1:-}"
[ -n "$PATCH_FILE" ] || { echo "❌ patch file not specified"; exit 1; }
[ -f "$PATCH_FILE" ] || { echo "❌ patch not found: $PATCH_FILE"; exit 1; }

# must be in git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "❌ not in git repo"; exit 1; }

# apply
if git apply --check "$PATCH_FILE" >/dev/null 2>&1; then
  git apply "$PATCH_FILE"
  echo "✅ patch applied: $PATCH_FILE"
  exit 0
else
  echo "❌ patch cannot be applied cleanly: $PATCH_FILE"
  git apply --check "$PATCH_FILE" || true
  exit 2
fi
