#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"

ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"

# pick one pending approval not notified
row="$(psql "$DATABASE_URL" -tA -v ON_ERROR_STOP=1 -F $'\t' -c "
  SELECT approval_id, left(title,200), coalesce(confidence::text,''), coalesce(risk_score::text,''), dryrun_status
  FROM governance.policy_approval_queue
  WHERE status='pending' AND notified_at IS NULL
  ORDER BY created_at
  LIMIT 1;
")"

[ -z "$row" ] && exit 0

approval_id="$(printf '%s' "$row" | cut -f1)"
title="$(printf '%s' "$row" | cut -f2)"
conf="$(printf '%s' "$row" | cut -f3)"
risk="$(printf '%s' "$row" | cut -f4)"
dry="$(printf '%s' "$row" | cut -f5)"

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "
  UPDATE governance.policy_approval_queue SET notified_at=now() WHERE approval_id=$approval_id;
  INSERT INTO governance.governance_action_log(action_type,ref_type,ref_id,payload)
  VALUES('approval_notified','approval',$approval_id,
         jsonb_build_object('confidence','$conf','risk','$risk','dryrun','$dry'));
" >/dev/null

msg=$(
cat <<MSG
[APPROVAL PENDING] id=$approval_id
$title
confidence=$conf  risk=$risk  dryrun=$dry

approve: $ERP_HOME/bin/70_approve.sh $approval_id
reject : $ERP_HOME/bin/71_reject.sh  $approval_id "reason"
MSG
)

"$ERP_HOME/bin/notify.sh" "$msg" || true
