#!/bin/sh
set -eu

TYPE="$1"        # required / passed / approved / rejected
ORDER_NO="$2"
REQUEST_ID="$3"
POLICY_ID="$4"
SEVERITY="$5"

BASE_URL="https://YOUR-APP-DOMAIN/approve"
APPROVAL_URL="$BASE_URL?request_id=$REQUEST_ID"

case "$TYPE" in
  required)
    MSG="🔴 承認が必要です\n注文:$ORDER_NO\n理由:$POLICY_ID\n$APPROVAL_URL"
    ;;
  approved)
    MSG="✅ 承認されました\n注文:$ORDER_NO"
    ;;
  rejected)
    MSG="❌ 却下されました\n注文:$ORDER_NO"
    ;;
  passed)
    MSG="🟢 承認不要\n注文:$ORDER_NO"
    ;;
  *)
    exit 2
    ;;
esac

# severity / policy 別の分岐（例）
case "$SEVERITY" in
  high)   echo "📣 [SLACK] $MSG" ;;
  medium) echo "📣 [LINE]  $MSG" ;;
  *)      echo "📣 [INFO]  $MSG" ;;
esac

exit 0
