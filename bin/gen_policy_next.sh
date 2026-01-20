#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
LOG="$ROOT/logs/pm_lint.last"
OUT="$ROOT/pm_ai/policy_next.yaml"

NOW="$(date '+%Y-%m-%d %H:%M:%S')"

NG_LINE="$(cat "$LOG" | sed 's/.*NG: //')"

cat <<YAML > "$OUT"
version: 1
generated_at: "$NOW"

fix_instruction:
  reason: "$NG_LINE"
  action: "revise task to satisfy policy.yaml"
YAML
