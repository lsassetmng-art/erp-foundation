#!/bin/sh
# ------------------------------------------------------------
# review_pending_watcher.sh
# Phase5–7 send_back 後の自動再レビュー起動
# ------------------------------------------------------------

set -e

STATUS=$(psql "$DATABASE_URL" -At <<'SQL'
SELECT status
FROM approval_request
WHERE target = 'phase5-7_ai_judgement_chamber'
ORDER BY decided_at DESC
LIMIT 1;
SQL
)

if [ "$STATUS" = "review_pending" ]; then
  echo "[pm_loop] review_pending detected. restarting review..."
  "$HOME/bin/pm_loop.sh" review
else
  echo "[pm_loop] no pending review."
fi

exit 0
