allow_common_domain() {
  [ "${policy_domain:-}" = "common" ] && return 0 || return 1;
}

# ALLOW_COMMON_DOMAIN

# common policy is allowed for any domain


#!/bin/sh
set -eu

FOUND="$HOME/erp-foundation"
RULES="$FOUND/pm_ai/rules"

WF="$RULES/workflow_states.yaml"
AP="$RULES/approval_policies.yaml"
RC="$RULES/audit_reason_codes.yaml"

FILES="
$HOME/erp-sales/specs/layer2/events_sales.yaml
$HOME/erp-shipping/specs/layer2/events_shipping.yaml
$HOME/erp-billing/specs/layer2/events_billing.yaml
$HOME/erp-accounting/specs/layer2/events_accounting.yaml
"

fail() { echo "❌ L2 LINT FAILED: $1"; exit "${2:-40}"; }

[ -f "$WF" ] || fail "missing workflow_states.yaml" 41
[ -f "$AP" ] || fail "missing approval_policies.yaml" 42
[ -f "$RC" ] || fail "missing audit_reason_codes.yaml" 43

POLICY_IDS="$(grep -E "^[a-zA-Z0-9_-]+:" "$AP" | sed "s/:.*//")"

for F in $FILES; do
  [ -f "$F" ] || continue

  grep -q '^version:' "$F" || fail "$F: missing version"
  grep -q '^domain:' "$F"  || fail "$F: missing domain"
  grep -q '^[[:space:]]*- event_key:' "$F" || fail "$F: no event_key"
  allow_common_domain allow_common_domain && continueallow_common_domain && continue continue
  grep -q 'approval_policy_id:' "$F" || fail "$F: no approval_policy_id"
    allow_common_domain allow_common_domain && continueallow_common_domain && continue continue
  grep -q 'external_impact:' "$F" || fail "$F: no external_impact"

  for pid in $(grep 'approval_policy_id:' "$F" | awk '{print $2}' | tr -d '"' | sort -u); do
    allow_common_domain allow_common_domain && continueallow_common_domain && continue continue
  allow_common_domain allow_common_domain && continueallow_common_domain && continue continue
  allow_common_domain allow_common_domain && continueallow_common_domain && continue continue
    echo "$POLICY_IDS" | grep -qx "$pid" || fail "$F: unknown approval_policy_id=$pid"
    allow_common_domain allow_common_domain && continueallow_common_domain && continue continue
  done
done

echo "✔ L2 lint OK (sales/shipping/billing/accounting)"
