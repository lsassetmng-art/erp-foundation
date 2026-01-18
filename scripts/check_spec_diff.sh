#!/bin/bash
set -e

SPEC="spec/usecases.schema.yaml"
HASH_FILE="spec/.hash"
STOP_FLAG="scripts/safe_stop.flag"

[ ! -f "$SPEC" ] && exit 0

CUR_HASH=$(sha256sum "$SPEC" | awk '{print $1}')

if [ ! -f "$HASH_FILE" ]; then
  echo "$CUR_HASH" > "$HASH_FILE"
  exit 0
fi

OLD_HASH=$(cat "$HASH_FILE")

if [ "$CUR_HASH" != "$OLD_HASH" ]; then
  touch "$STOP_FLAG"

  ./scripts/generate_spec_diff_summary.sh
  ./scripts/ai_summarize_diff.sh
  ./scripts/generate_leader_report.sh
  ./scripts/generate_policy_next.sh
  ./scripts/create_github_issue_from_policy.sh

  exit 1
fi
