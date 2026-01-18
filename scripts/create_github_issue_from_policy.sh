#!/bin/bash
set -e

POLICY="policy/policy_next.yaml"
REPORT="reports/leader_report.md"
SUMMARY="reports/spec_diff_summary.md"

[ ! -f "$POLICY" ] && exit 0

TITLE="SAFE STOP: Spec change requires approval"
BODY_FILE="$(mktemp)"

{
  echo "## 🚨 SAFE STOP DETECTED"
  echo
  [ -f "$POLICY" ] && { echo "### policy_next.yaml"; echo '```'; cat "$POLICY"; echo '```'; }
  [ -f "$SUMMARY" ] && { echo "### Diff Summary"; echo '```'; cat "$SUMMARY"; echo '```'; }
  [ -f "$REPORT" ] && { echo "### Leader Report"; echo '```'; cat "$REPORT"; echo '```'; }
} > "$BODY_FILE"

# GitHub CLI がある場合のみ起票
if command -v gh >/dev/null 2>&1; then
  gh issue create --title "$TITLE" --body-file "$BODY_FILE"
fi
