#!/data/data/com.termux/files/usr/bin/sh
set -eu
: "${DATABASE_URL:?}"
: "${COMPANY_ID:?}"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
insert into workflow.approval_request(
  company_id, request_type, title, body, detail
)
select
  :'COMPANY_ID'::uuid,
  'policy_change',
  'AI policy improvement suggested',
  'NG evaluations exceeded threshold',
  jsonb_build_object('source','ai_self_improve')
from ai.eval_result
where verdict='ng'
  and created_at >= now() - interval '24 hour'
group by 1
having count(*) >= 3
on conflict do nothing;
SQL
