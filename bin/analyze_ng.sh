#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
LOG="$ROOT/logs/pm_lint.last"
OUT="$ROOT/logs/ng_stats.txt"

grep 'NG:' "$ROOT/logs"/pm_lint.* 2>/dev/null \
  | sed 's/.*NG: //' \
  | sort \
  | uniq -c \
  | sort -nr > "$OUT"
