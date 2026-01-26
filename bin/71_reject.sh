#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"
ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"

ID="${1:-}"
NOTE="${2:-rejected}"
[ -z "$ID" ] && { echo "USAGE: $0 <approval_id> \"reason\"" >&2; exit 2; }

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
UPDATE governance.policy_approval_queue
  SET status='rejected', decided_at=now(), decided_by=current_user, decision_note=\$\$$NOTE\$\$
WHERE approval_id=$ID AND status IN ('pending','approved');

INSERT INTO governance.governance_action_log(action_type,ref_type,ref_id,payload)
VALUES('rejected','approval',$ID,jsonb_build_object('by','manual','note',\$\$$NOTE\$\$));

INSERT INTO governance.policy_learning_event(approval_id, outcome, note)
VALUES($ID,'rejected',\$\$$NOTE\$\$);
SQL

"$ERP_HOME/bin/notify.sh" "REJECTED: approval_id=$ID note=$NOTE" || true
echo "OK: rejected $ID"
