#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

SLACK="${SLACK_WEBHOOK_URL:-}"
LINE="${LINE_WEBHOOK_URL:-}"

post_slack() { [ -n "$SLACK" ] && curl -sS -X POST "$SLACK" -H 'Content-Type: application/json' -d "{\"text\":\"$1\"}" >/dev/null || echo "[SLACK] $1"; }
post_line()  { [ -n "$LINE" ]  && curl -sS -X POST "$LINE"  -H 'Content-Type: application/json' -d "{\"message\":\"$1\"}" >/dev/null || echo "[LINE] $1"; }

patch_json() {
  path="$1"; body="$2"
  curl -sS -X PATCH "$SUPABASE_URL/rest/v1/$path" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" -d "$body" >/dev/null
}
post_json() {
  path="$1"; body="$2"
  curl -sS -X POST "$SUPABASE_URL/rest/v1/$path" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" -d "$body" >/dev/null
}

# ------------------------------------------------------------
# 1) BAD 自動検出 → bad記録＆rework_task生成
# ------------------------------------------------------------
BAD_COUNT="$(curl -sS -X POST "$SUPABASE_URL/rest/v1/rpc/enqueue_rework_from_bad" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" \
  -d '{}' | tr -dc '0-9')"
BAD_COUNT="${BAD_COUNT:-0}"

if [ "$BAD_COUNT" -gt 0 ]; then
  TASKS="$(curl -s \
    "$SUPABASE_URL/rest/v1/approval.rework_task?status=eq.open&order=created_at.desc&limit=5" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"
  MSG="🛠️ REWORK created (BAD detected=$BAD_COUNT): $(echo "$TASKS" | tr '\n' ' ')"
  post_slack "$MSG"
  post_line  "$MSG"
  EXIT_BAD=83
else
  EXIT_BAD=0
fi

# ------------------------------------------------------------
# 2) 自律運用（promote/rollback）
#   - 推奨アクションをDBで取得
#   - promote: rollout 0→10→50→100
#   - rollback: rollout=0 & policy_auto_generated.activated=false
# ------------------------------------------------------------
REC="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_autopilot_recommendation?select=auto_policy_id,rollout_percent,recommended_action&limit=50" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

PROM=0
RB=0

IDS="$(echo "$REC" | sed -n 's/.*"auto_policy_id":"\([^"]*\)".*/\1/p')"
for ID in $IDS; do
  ONE="$(curl -s \
    "$SUPABASE_URL/rest/v1/approval.v_autopilot_recommendation?auto_policy_id=eq.$ID&select=auto_policy_id,rollout_percent,recommended_action&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

  PCT="$(echo "$ONE" | sed -n 's/.*"rollout_percent":\([0-9]*\).*/\1/p')"
  ACT="$(echo "$ONE" | sed -n 's/.*"recommended_action":"\([^"]*\)".*/\1/p')"
  PCT="${PCT:-0}"
  ACT="${ACT:-hold}"

  if [ "$ACT" = "rollback" ]; then
    patch_json "approval.policy_rollout?auto_policy_id=eq.$ID" '{"status":"rolled_back","rollout_percent":0}'
    patch_json "approval.policy_auto_generated?auto_policy_id=eq.$ID" '{"activated":false}'
    post_json "approval.policy_rollout_log" "{\"auto_policy_id\":\"$ID\",\"action\":\"rollback\",\"from_percent\":$PCT,\"to_percent\":0,\"reason\":\"autopilot_error_rate\"}"
    RB=1
    continue
  fi

  if [ "$ACT" = "promote" ]; then
    NEXT="$PCT"
    [ "$PCT" -eq 0 ] && NEXT=10
    [ "$PCT" -eq 10 ] && NEXT=50
    [ "$PCT" -eq 50 ] && NEXT=100
    if [ "$NEXT" -ne "$PCT" ]; then
      patch_json "approval.policy_rollout?auto_policy_id=eq.$ID" "{\"status\":\"active\",\"rollout_percent\":$NEXT}"
      post_json "approval.policy_rollout_log" "{\"auto_policy_id\":\"$ID\",\"action\":\"promote\",\"from_percent\":$PCT,\"to_percent\":$NEXT,\"reason\":\"autopilot_metrics_ok\"}"
      PROM=1
    fi
  fi
done

if [ "$RB" -eq 1 ]; then
  post_slack "🧯 AUTOPILOT rollback executed."
  post_line  "🧯 AUTOPILOT rollback executed."
  exit 81
fi

if [ "$PROM" -eq 1 ]; then
  post_slack "🚀 AUTOPILOT promote executed (rollout step up)."
  post_line  "🚀 AUTOPILOT promote executed (rollout step up)."
  exit 82
fi

# ------------------------------------------------------------
# 3) policy ROI レポート通知（上位3）
# ------------------------------------------------------------
ROI="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.v_policy_roi?order=savings_minutes_total.desc&limit=3" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"
post_slack "📈 ROI(top3): $(echo "$ROI" | tr '\n' ' ')"
post_line  "📈 ROI(top3): $(echo "$ROI" | tr '\n' ' ')"

exit "$EXIT_BAD"
