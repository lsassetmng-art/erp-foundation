#!/bin/bash
set -e

POLICY_DIR="policy"
POLICY="$POLICY_DIR/policy_next.yaml"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

mkdir -p "$POLICY_DIR"

cat << EOF > "$POLICY"
generated_at: "$DATE"

status:
  safe_stop: true

required_actions:
  - review_spec
  - approve_regeneration

next_steps:
  on_approve:
    - remove_safe_stop
    - rerun_generation
EOF

echo "📜 policy_next.yaml generated"
