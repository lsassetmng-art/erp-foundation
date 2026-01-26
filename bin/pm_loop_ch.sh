#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
. "$(dirname "$0")/db_ops.sh"

require_env DATABASE_URL
require_env COMPANY_ID

INTERVAL_SEC="${INTERVAL_SEC:-60}"
log OK "pm_loop_ch start interval=${INTERVAL_SEC}s"

while :; do
  RUN_ID="$(gen_run_id)"
  export RUN_ID

  HC_OUT="$("$(dirname "$0")/db_healthcheck.sh" || true)"
  HC_CODE=$?
  DETAIL="{\"health\":\"$(json_escape "$HC_OUT")\"}"

  if [ "$HC_CODE" -eq 0 ]; then
    log_run "$RUN_ID" "healthcheck" "ok" "$DETAIL"
  elif [ "$HC_CODE" -eq 10 ]; then
    log_run "$RUN_ID" "healthcheck" "warn" "$DETAIL"
    log_audit "$RUN_ID" "connection_warn_direct" "warn" "$DETAIL"
  else
    log_run "$RUN_ID" "healthcheck" "ng" "$DETAIL"
    log_audit "$RUN_ID" "connection_ng" "critical" "$DETAIL"
    enqueue_slack "[NG] DB connection failed run_id=${RUN_ID} ${HC_OUT}" || true
    enqueue_line  "[NG] DB connection failed run_id=${RUN_ID} ${HC_OUT}" || true
    "$(dirname "$0")/notify_sender.sh" || true
    exit 20
  fi

  # ライセンスゲート
  AUDIT_ON="$(is_feature_enabled "audit" || echo f)"
  AI_ON="$(is_feature_enabled "ai" || echo f)"

  if [ "$AUDIT_ON" = "t" ]; then
    log_audit "$RUN_ID" "ops_cycle" "info" "{\"msg\":\"cycle ok\"}"
  fi

  if [ "$AI_ON" = "t" ]; then
    if [ "$HC_CODE" -eq 0 ]; then
      log_eval "$RUN_ID" "db.connection" "ok" "1.0" "{\"mode\":\"pooler\"}"
    else
      log_eval "$RUN_ID" "db.connection" "warn" "0.5" "{\"mode\":\"direct\"}"
      log_feedback "$RUN_ID" "db.connection" "warn" "Direct(5432) detected; prefer pooler(6543) for daily ops"
    fi
    "$(dirname "$0")/ai_self_improve.sh" || true
  fi

  "$(dirname "$0")/notify_sender.sh" || true
  sleep "$INTERVAL_SEC"
done
