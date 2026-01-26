# AI承認SaaS（外販パッケージ）概要

## 提供価値
- 承認SLA短縮（自動承認＋段階展開）
- 誤爆抑止（品質評価＋自動Rollback）
- 監査対応（Override監査・J-SOXテンプレ）

## 構成（正本）
- approval_request / approval_log
- policy_auto_generated（AIルール）
- policy_rollout / policy_eval_event / rework_task
- export：approval.v_audit_report_export / approval.v_roi_report_export / approval.v_jsox_control_matrix

## 外販の境界
- 機能ON/OFF：approval.feature_flag（approval_ai）
- 契約：approval.saas_plan / approval.saas_subscription
- KPI：approval.saas_usage_daily / approval.v_saas_kpi_company

## 運用（例）
- 日次：export_reports.sh（監査資料の自動生成）
- 監査：JSOX_template.md に沿って提出
