#!/bin/sh
set -e

SUPABASE_URL="${SUPABASE_URL:?}"
KEY="${SUPABASE_SERVICE_ROLE_KEY:?}"

# ------------------------------------------------------------
# helper: PATCH
# ------------------------------------------------------------
patch_json() {
  path="$1"
  body="$2"
  curl -sS -X PATCH "$SUPABASE_URL/rest/v1/$path" \
    -H "apikey: $KEY" \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$body" >/dev/null
}

post_json() {
  path="$1"
  body="$2"
  curl -sS -X POST "$SUPABASE_URL/rest/v1/$path" \
    -H "apikey: $KEY" \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$body" >/dev/null
}

# ------------------------------------------------------------
# 0) feature ON の会社だけ処理（SaaS切り出し）
#    company_id を環境変数で固定（マルチテナント運用に合わせる）
# ------------------------------------------------------------
COMPANY_ID="${COMPANY_ID:-}"
if [ -n "$COMPANY_ID" ]; then
  FEAT="$(curl -s \
    "$SUPABASE_URL/rest/v1/approval.v_feature_enabled_company?company_id=eq.$COMPANY_ID&select=company_id&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"
  echo "$FEAT" | grep -q "company_id" || exit 0
fi

# ------------------------------------------------------------
# 1) rollout対象の一覧取得（staged/active）
# ------------------------------------------------------------
ROLL="$(curl -s \
  "$SUPABASE_URL/rest/v1/approval.policy_rollout?select=auto_policy_id,rollout_percent,status,max_error_rate,min_samples&status=in.(staged,active)" \
  -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

echo "$ROLL" | grep -q "auto_policy_id" || exit 0

PROMOTED=0
ROLLED_BACK=0

# JSONを雑に1行ずつ扱う（jq無し縛り）
IDS="$(echo "$ROLL" | sed -n 's/.*"auto_policy_id":"\([^"]*\)".*/\1/p')"

for ID in $IDS; do
  # rollout row 再取得（percent/status/threshold）
  ROW="$(curl -s \
    "$SUPABASE_URL/rest/v1/approval.policy_rollout?auto_policy_id=eq.$ID&select=rollout_percent,status,max_error_rate,min_samples&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

  PCT="$(echo "$ROW" | sed -n 's/.*"rollout_percent":\([0-9]*\).*/\1/p')"
  ST="$(echo "$ROW"  | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
  MAX_ERR="$(echo "$ROW" | sed -n 's/.*"max_error_rate":\([0-9.]*\).*/\1/p')"
  MIN_SAMPLES="$(echo "$ROW" | sed -n 's/.*"min_samples":\([0-9]*\).*/\1/p')"

  PCT="${PCT:-0}"
  ST="${ST:-staged}"
  MAX_ERR="${MAX_ERR:-0.05}"
  MIN_SAMPLES="${MIN_SAMPLES:-30}"

  # 直近7日評価
  EVAL="$(curl -s \
    "$SUPABASE_URL/rest/v1/approval.v_policy_eval_7d?auto_policy_id=eq.$ID&select=samples,error_rate&limit=1" \
    -H "apikey: $KEY" -H "Authorization: Bearer $KEY")"

  SAMPLES="$(echo "$EVAL" | sed -n 's/.*"samples":\([0-9]*\).*/\1/p')"
  ERR="$(echo "$EVAL" | sed -n 's/.*"error_rate":\([0-9.]*\).*/\1/p')"
  SAMPLES="${SAMPLES:-0}"
  ERR="${ERR:-0}"

  # ----------------------------------------------------------
  # 2) rollback 判定（サンプル足りてて、errが閾値超え）
  # ----------------------------------------------------------
  # 比較（小数）をawkで
  RB="$(awk "BEGIN{print ($SAMPLES >= $MIN_SAMPLES && $ERR > $MAX_ERR) ? 1 : 0}")"
  if [ "$RB" = "1" ]; then
    # rollback
    patch_json "approval.policy_rollout?auto_policy_id=eq.$ID" '{"status":"rolled_back","rollout_percent":0}'
    patch_json "approval.policy_auto_generated?auto_policy_id=eq.$ID" '{"activated":false}'
    post_json "approval.policy_rollout_log" "{\"auto_policy_id\":\"$ID\",\"action\":\"rollback\",\"from_percent\":$PCT,\"to_percent\":0,\"reason\":\"error_rate_exceeded\"}"
    ROLLED_BACK=1
    continue
  fi

  # ----------------------------------------------------------
  # 3) promote 判定（サンプル足りてて、errが閾値以下）
  # ----------------------------------------------------------
  OK="$(awk "BEGIN{print ($SAMPLES >= $MIN_SAMPLES && $ERR <= $MAX_ERR) ? 1 : 0}")"
  if [ "$OK" = "1" ]; then
    NEXT="$PCT"
    if [ "$PCT" -eq 0 ]; then NEXT=10; fi
    if [ "$PCT" -eq 10 ]; then NEXT=50; fi
    if [ "$PCT" -eq 50 ]; then NEXT=100; fi

    if [ "$NEXT" -ne "$PCT" ]; then
      patch_json "approval.policy_rollout?auto_policy_id=eq.$ID" "{\"status\":\"active\",\"rollout_percent\":$NEXT}"
      # 100% になったら activated=true を維持（すでにtrue想定）
      post_json "approval.policy_rollout_log" "{\"auto_policy_id\":\"$ID\",\"action\":\"promote\",\"from_percent\":$PCT,\"to_percent\":$NEXT,\"reason\":\"metrics_ok\"}"
      PROMOTED=1
    fi
  fi
done

if [ "$ROLLED_BACK" = "1" ]; then
  exit 61
fi
if [ "$PROMOTED" = "1" ]; then
  exit 60
fi
exit 0
