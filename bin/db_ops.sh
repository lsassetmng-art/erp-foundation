#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
require_env DATABASE_URL
require_env COMPANY_ID

log_run(){
  run_id="$1"; phase="$2"; status="$3"; detail="$4"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL >/dev/null
select ops.log_run('${run_id}','termux','${phase}','${status}','${detail}'::jsonb);
SQL
}

log_audit(){
  run_id="$1"; event_type="$2"; severity="$3"; detail="$4"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL >/dev/null
select audit.log_event('${COMPANY_ID}'::uuid,'${event_type}','${severity}','termux','${run_id}','${detail}'::jsonb);
SQL
}

log_eval(){
  run_id="$1"; policy_key="$2"; verdict="$3"; score="$4"; detail="$5"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL >/dev/null
select ai.log_eval('${run_id}','${policy_key}','${verdict}',${score},'${detail}'::jsonb);
SQL
}

log_feedback(){
  run_id="$1"; policy_key="$2"; verdict="$3"; msg="$4"
  esc="$(printf "%s" "$msg" | sed "s/'/''/g")"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL >/dev/null
select ai.log_feedback('${run_id}','${policy_key}','${verdict}','${esc}','{}'::jsonb);
SQL
}

is_feature_enabled(){
  feature_key="$1"
  psql1 "select licensing.is_feature_enabled('${COMPANY_ID}'::uuid,'${feature_key}');"
}

enqueue_slack(){
  txt="$1"
  [ -n "${SLACK_WEBHOOK_URL:-}" ] || return 0
  payload="$(printf '{"text":"%s"}' "$(printf "%s" "$txt" | sed 's/"/\\"/g')")"
  psql1 "select ops.enqueue_notification('${COMPANY_ID}'::uuid,'slack','${SLACK_WEBHOOK_URL}','${payload}'::jsonb);" >/dev/null
}

enqueue_line(){
  txt="$1"
  [ -n "${LINE_NOTIFY_TOKEN:-}" ] || return 0
  payload="$(printf '{"message":"%s"}' "$(printf "%s" "$txt" | sed 's/"/\\"/g')")"
  psql1 "select ops.enqueue_notification('${COMPANY_ID}'::uuid,'line','line_notify','${payload}'::jsonb);" >/dev/null
}

propose_policy_change(){
  policy_key="$1"
  policy_yaml="$2"
  esc="$(printf "%s" "$policy_yaml" | sed "s/'/''/g")"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL >/dev/null
select public.api_propose_policy_change('${COMPANY_ID}'::uuid,'${policy_key}', '${esc}', 'ai');
SQL
}
