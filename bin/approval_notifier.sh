#!/data/data/com.termux/files/usr/bin/sh
set -eu
: "${DATABASE_URL:?}"

PENDING="$(psql "$DATABASE_URL" -t -A <<'SQL'
select count(*) from workflow.approval_request where status='pending';
SQL
)"

if [ "$PENDING" -gt 0 ]; then
  MSG="[APPROVAL] pending=${PENDING}"
  if [ -n "${SLACK_WEBHOOK_URL:-}" ]; then
    curl -fsS -X POST -H 'Content-type: application/json' \
      --data "{\"text\":\"${MSG}\"}" \
      "${SLACK_WEBHOOK_URL}" >/dev/null || true
  fi
fi
