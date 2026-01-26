#!/data/data/com.termux/files/usr/bin/sh
set -eu
. "$(dirname "$0")/lib.sh"
: "${DATABASE_URL:?}"
: "${COMPANY_ID:?}"

RID="$(run_id)"
CRIT="$(psql "$DATABASE_URL" -t -A -v ON_ERROR_STOP=1 -c \
  "select count(*) from audit.event where company_id='${COMPANY_ID}'::uuid and severity='critical' and created_at >= now() - interval '24 hour';" 2>/dev/null || echo 0)"
CRIT="$(printf "%s" "$CRIT" | tr -d '[:space:]' || echo 0)"

VERDICT="ok"
if [ "${CRIT}" -ge 3 ]; then VERDICT="ng"; fi

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
  "insert into ai.eval_result(company_id,run_id,policy_key,verdict,score,detail)
   values('${COMPANY_ID}'::uuid,'${RID}','db.connection','${VERDICT}',null,jsonb_build_object('critical_24h',${CRIT}));" >/dev/null

if [ "$VERDICT" = "ng" ]; then
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c \
    "insert into workflow.approval_request(company_id,request_type,ref_entity,title,body,requested_by,detail)
     values('${COMPANY_ID}'::uuid,'policy_change','db.connection','AI suggests tightening db policy','critical spikes detected','ai',
            jsonb_build_object('critical_24h',${CRIT},'run_id','${RID}'));"
fi

log OK "ai_eval verdict=${VERDICT} critical_24h=${CRIT}"
