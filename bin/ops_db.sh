#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"

require_env DATABASE_URL
require_env COMPANY_ID

db_log_run(){
  run_id="$1"; phase="$2"; status="$3"; detail_json="$4"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
select ops.log_run(
  '${run_id}',
  'termux',
  '${phase}',
  '${status}',
  '${detail_json}'::jsonb
);
SQL
}

db_audit(){
  run_id="$1"; event_type="$2"; severity="$3"; detail_json="$4"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
select audit.log_event(
  '${COMPANY_ID}'::uuid,
  '${event_type}',
  '${severity}',
  'termux',
  '${run_id}',
  '${detail_json}'::jsonb
);
SQL
}

db_eval(){
  run_id="$1"; policy_key="$2"; verdict="$3"; score="$4"; detail_json="$5"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
select ai.log_eval(
  '${run_id}',
  '${policy_key}',
  '${verdict}',
  ${score},
  '${detail_json}'::jsonb
);
SQL
}

db_feedback(){
  run_id="$1"; policy_key="$2"; verdict="$3"; msg="$4"; detail_json="$5"
  esc_msg="$(printf "%s" "$msg" | sed "s/'/''/g")"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
select ai.log_feedback(
  '${run_id}',
  '${policy_key}',
  '${verdict}',
  '${esc_msg}',
  '${detail_json}'::jsonb
);
SQL
}

is_feature_enabled(){
  feature_key="$1"
  psql1 "select licensing.is_feature_enabled('${COMPANY_ID}'::uuid, '${feature_key}');"
}

enqueue_notify(){
  channel="$1"; dest="$2"; payload_json="$3"
  psql1 "select ops.enqueue_notification('${COMPANY_ID}'::uuid,'${channel}','${dest}','${payload_json}'::jsonb);"
}
