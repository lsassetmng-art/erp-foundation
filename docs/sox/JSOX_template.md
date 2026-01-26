# J-SOX / 内部統制（AI承認基盤）テンプレ

## 1. スコープ
- 対象：AI承認基盤（approval_request / policy / rollout / autopilot）
- 対象会社：feature_flag(approval_ai)=true の会社

## 2. 統制目的（例）
- AI自動承認の誤爆抑止
- 変更の追跡可能性（監査証跡）
- SLA逸脱の検知と是正
- ルールの段階展開と自動Rollback

## 3. 統制一覧（Control Matrix）
- 出力：approval.v_jsox_control_matrix（CSV/HTML/PDF）
- Evidence：export_reports.sh の成果物

## 4. 運用手順（例）
- 日次：approval_guardian.sh / approval_autopilot*.sh 実行ログ確認
- 週次：SLA/ROI レポート確認（roi_monthly_report）
- 月次：監査レポート提出（audit_override_report）

## 5. 証跡（Evidence）
- CSV：audit_override_report.csv / roi_monthly_report.csv / jsox_control_matrix.csv
- PDF：audit_override_report.pdf（生成できる環境のみ）
- 代替：HTML をブラウザで印刷→PDF

## 6. 例外処理
- 自動Rollback発生時：policy_rollout_log / 通知ログを保管
- rework_task が発生した場合：原因分析と再発防止策を記録
