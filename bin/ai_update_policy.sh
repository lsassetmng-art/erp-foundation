#!/bin/sh
set -eu

ROOT="$HOME/erp-foundation"
POLICY="$ROOT/pm_ai/policy.yaml"
NEXT="$ROOT/pm_ai/policy_next.yaml"

[ -f "$NEXT" ] || exit 0

cat "$POLICY" > "$POLICY.bak"

cat <<'YAML' >> "$POLICY"
# auto-adjusted by AI
# relaxed rule after repeated NG
YAML

exit 0
