#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"
ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"

# thresholds (env overridable)
MAX_PENDING_APPROVALS="${MAX_PENDING_APPROVALS:-50}"
MAX_PENDING_APPLIES="${MAX_PENDING_APPLIES:-50}"
MAX_REJECTED_24H="${MAX_REJECTED_24H:-10}"

row="$(psql "$DATABASE_URL" -tA -F '|' -c "select pending_approvals,pending_applies,rejected_24h,autonomy_mode from governance.v_ops_dashboard limit 1;")"
pa="$(printf '%s' "$row" | cut -d'|' -f1 | tr -d ' ')"
pp="$(printf '%s' "$row" | cut -d'|' -f2 | tr -d ' ')"
rj="$(printf '%s' "$row" | cut -d'|' -f3 | tr -d ' ')"
am="$(printf '%s' "$row" | cut -d'|' -f4 | tr -d ' ')"

alert_sql=""
if [ "${pa:-0}" -ge "$MAX_PENDING_APPROVALS" ]; then
  alert_sql="$alert_sql
INSERT INTO governance.sla_alert_event(alert_type,severity,message,snapshot)
VALUES ('queue_backlog','warn','pending approvals too many', jsonb_build_object('pending_approvals',$pa,'autonomy_mode','$am'));"
fi
if [ "${pp:-0}" -ge "$MAX_PENDING_APPLIES" ]; then
  alert_sql="$alert_sql
INSERT INTO governance.sla_alert_event(alert_type,severity,message,snapshot)
VALUES ('queue_backlog','warn','pending applies too many', jsonb_build_object('pending_applies',$pp,'autonomy_mode','$am'));"
fi
if [ "${rj:-0}" -ge "$MAX_REJECTED_24H" ]; then
  alert_sql="$alert_sql
INSERT INTO governance.sla_alert_event(alert_type,severity,message,snapshot)
VALUES ('apply_fail_spike','crit','apply rejected spike (24h)', jsonb_build_object('rejected_24h',$rj,'autonomy_mode','$am'));"
fi

if [ -n "$alert_sql" ]; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
$alert_sql
SQL
  # notify last alert (best-effort)
  if [ -x "$ERP_HOME/bin/notify.sh" ]; then
    "$ERP_HOME/bin/notify.sh" "SLA ALERT: approvals=$pa applies=$pp rejected24h=$rj autonomy=$am"
  fi
fi
