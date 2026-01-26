#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL:?}"
: "${COMPANY_ID:?}"

RID="$(run_id)"
OUT="$(psql "$DATABASE_URL" -t -A -v ON_ERROR_STOP=1 -c "select current_setting('ssl'), inet_server_port();" 2>&1 || true)"
LINE1="$(printf "%s" "$OUT" | head -n1 | tr -d '\r' || true)"
SSL="$(printf "%s" "$LINE1" | cut -d'|' -f1 | tr -d '[:space:]' || true)"
PORT="$(printf "%s" "$LINE1" | cut -d'|' -f2 | tr -d '[:space:]' || true)"

if [ "$SSL" = "on" ]; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
    "insert into ops.sla_metric(company_id,metric_key,metric_value,detail)
     values('${COMPANY_ID}'::uuid,'db_ssl',1,jsonb_build_object('port','${PORT}','run_id','${RID}'));" >/dev/null
  log OK "db ok ssl=on port=${PORT}"
  exit 0
fi

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
  "insert into ops.alert(company_id,alert_type,severity,detail)
   values('${COMPANY_ID}'::uuid,'db_ng','critical',jsonb_build_object('out',\$j\$${OUT}\$j\$,'run_id','${RID}'));" >/dev/null || true
log NG "db ssl not on"
exit 20
