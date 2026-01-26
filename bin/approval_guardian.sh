#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

SLACK="${SLACK_WEBHOOK_URL:-}"
LINE="${LINE_WEBHOOK_URL:-}"

post_slack(){ [ -n "$SLACK" ] && curl -sS -X POST "$SLACK" -H 'Content-Type: application/json' -d "{\"text\":\"$1\"}" >/dev/null || echo "[SLACK] $1"; }
post_line(){  [ -n "$LINE"  ] && curl -sS -X POST "$LINE"  -H 'Content-Type: application/json' -d "{\"message\":\"$1\"}" >/dev/null || echo "[LINE] $1"; }

patch_json() {
  path="$1"; body="$2"
  curl -sS -X PATCH "$SUPABASE_URL/rest/v1/$path" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" -d "$body" >/dev/null
}

# ------------------------------------------------------------
# 1️⃣ high severity 検出（即 rollback 対象）
# ------------------------------------------------------------
HIGH="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_severity_escalation_target?limit=1" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

if echo "$HIGH" | grep -q "auto_policy_id"; then
  ID="$(echo "$HIGH" | sed -n 's/.*"auto_policy_id":"\([^"]*\)".*/\1/p')"

  # rollback
  patch_json "approval.policy_rollout?auto_policy_id=eq.$ID" '{"status":"rolled_back","rollout_percent":0}'
  patch_json "approval.policy_auto_generated?auto_policy_id=eq.$ID" '{"activated":false}'

  post_slack "🛑 HIGH severity override → policy rolled back ($ID)"
  post_line  "🛑 HIGH severity override → policy rolled back ($ID)"

  exit 111
fi

# ------------------------------------------------------------
# 2️⃣ 監査レポート（直近5件）
# ------------------------------------------------------------
REPORT="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_ai_override_audit_report?order=overridden_at.desc&limit=5" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

if echo "$REPORT" | grep -q "request_id"; then
  post_slack "🧾 AI Override Audit: $(echo "$REPORT" | tr '\n' ' ')"
  post_line  "🧾 AI Override Audit: $(echo "$REPORT" | tr '\n' ' ')"
  exit 112
fi

exit 0
