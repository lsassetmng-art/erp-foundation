#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL not set}"
ERP_HOME="${ERP_HOME:-$HOME/erp-foundation}"

ID="${1:-}"
[ -z "$ID" ] && { echo "USAGE: $0 <approval_id>" >&2; exit 2; }

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<SQL
UPDATE governance.policy_approval_queue
  SET status='approved', decided_at=now(), decided_by=current_user, decision_note='manual approve'
WHERE approval_id=$ID AND status='pending';

INSERT INTO governance.governance_action_log(action_type,ref_type,ref_id,payload)
VALUES('approved','approval',$ID,jsonb_build_object('by','manual'));

INSERT INTO governance.policy_learning_event(approval_id, outcome, note)
VALUES($ID,'approved','manual');
SQL

"$ERP_HOME/bin/notify.sh" "APPROVED: approval_id=$ID" || true
echo "OK: approved $ID"
