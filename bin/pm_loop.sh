#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL:?}"
: "${COMPANY_ID:?}"

INTERVAL="${INTERVAL_SEC:-60}"
log OK "pm_loop start interval=${INTERVAL}s"

while :; do
  RID="$(run_id)"

  KS="$(psql "$DATABASE_URL" -t -A -v ON_ERROR_STOP=1 -c \
    "select is_on from ops.get_kill_switch('${COMPANY_ID}'::uuid);" 2>/dev/null || true)"
  KS="$(printf "%s" "$KS" | tr -d '[:space:]' || true)"

  if [ "$KS" = "t" ]; then
    psql "$DATABASE_URL" -c \
      "insert into ops.sla_metric(company_id,metric_key,metric_value,detail)
       values('${COMPANY_ID}'::uuid,'pm_loop_stopped',1,jsonb_build_object('run_id','${RID}'));" >/dev/null || true
    log NG "kill_switch ON -> stop"
    exit 99
  fi

  "$(dirname "$0")/db_healthcheck.sh" || true

  psql "$DATABASE_URL" -c \
    "insert into ops.sla_metric(company_id,metric_key,metric_value,detail)
     values('${COMPANY_ID}'::uuid,'pm_loop_alive',1,jsonb_build_object('run_id','${RID}'));" >/dev/null || true

  "$(dirname "$0")/ai_eval.sh" || true

  "$(dirname "$0")/notify_worker.sh" || true
  "$(dirname "$0")/notify_worker.sh" || true

  sleep "$INTERVAL"
done
