# 外部監査テンプレ集（業種別・業種横断）

本ドキュメントは、ERP 上で生成される **audit.audit_event** を前提に、
第三者（監査法人・行政・取引先）へ提示可能な
**業種別 外部監査観点・reason_code・是正指針**をまとめたものである。

---

## 共通（全業種共通）

### 監査観点
- 承認なし処理
- 職務分掌違反
- 異常時間帯処理
- 繰り返しNG
- 自動修復失敗の継続

### reason_code
- NO_APPROVAL
- SEGREGATION_OF_DUTIES_VIOLATION
- ABNORMAL_TIME_OPERATION
- REPEATED_FAILURE
- AUTO_FIX_FAILED

---

## 小売業（Retail）

### 監査観点
- 在庫差異
- 廃棄ロス
- 原価割れ販売
- 異常値引き
- 承認なし価格変更

### reason_code
- INVENTORY_MISMATCH
- EXCESSIVE_LOSS
- NEGATIVE_MARGIN
- EXCESSIVE_DISCOUNT
- PRICE_OVERRIDE_NO_APPROVAL

---

## 飲食業（Food Service）

### 監査観点
- 食材ロス
- 原価率異常
- 衛生点検未実施
- 無断メニュー変更
- 夜間集中処理

### reason_code
- FOOD_LOSS_ABNORMAL
- COST_RATIO_ANOMALY
- SANITATION_CHECK_MISSING
- MENU_CHANGE_NO_APPROVAL
- NIGHT_OPERATION_SPIKE

---

## 製造業（Manufacturing）

### 監査観点
- BOM変更未承認
- 原価乖離
- 不良率上昇
- 工程スキップ
- 在庫滞留

### reason_code
- BOM_CHANGE_NO_APPROVAL
- COST_DEVIATION
- DEFECT_RATE_INCREASE
- PROCESS_SKIP
- DEAD_STOCK

---

## 物流・倉庫（Logistics / Warehouse）

### 監査観点
- 出荷ミス
- 紛失
- 滞留
- 承認なし配送条件変更
- 休日集中処理

### reason_code
- SHIPPING_ERROR
- LOST_ITEM
- INVENTORY_STAGNATION
- DELIVERY_OVERRIDE_NO_APPROVAL
- HOLIDAY_OPERATION_SPIKE

---

## 建設業（Construction）

### 監査観点
- 原価超過
- 工程遅延
- 契約外作業
- 外注先集中
- 支払先異常

### reason_code
- COST_OVERRUN
- SCHEDULE_DELAY
- OUT_OF_SCOPE_WORK
- SUBCONTRACTOR_CONCENTRATION
- PAYMENT_ANOMALY

---

## サービス業（Service）

### 監査観点
- 無断値引き
- 無断契約変更
- クレーム急増
- 返金多発

### reason_code
- UNAUTHORIZED_DISCOUNT
- CONTRACT_CHANGE_NO_APPROVAL
- COMPLAINT_SPIKE
- REFUND_SPIKE

---

## IT / SaaS

### 監査観点
- 権限過多
- 本番直変更
- 監査ログ欠損
- API異常呼び出し

### reason_code
- EXCESSIVE_PRIVILEGE
- PROD_CHANGE_NO_REVIEW
- AUDIT_LOG_MISSING
- API_ABUSE

---

## 医療・介護（Healthcare）

### 監査観点
- 個人情報アクセス
- 無資格対応
- 記録欠損
- 請求不整合

### reason_code
- UNAUTHORIZED_DATA_ACCESS
- UNQUALIFIED_OPERATION
- RECORD_MISSING
- BILLING_INCONSISTENCY

---

## 教育（Education）

### 監査観点
- 成績改ざん
- 個人情報漏洩
- 無断カリキュラム変更

### reason_code
- GRADE_TAMPERING
- PERSONAL_DATA_LEAK
- CURRICULUM_CHANGE_NO_APPROVAL

---

## 金融・会計（Finance / Accounting）

### 監査観点
- 仕訳改ざん
- 期ズレ処理
- 二重計上
- 不正支払

### reason_code
- JOURNAL_TAMPERING
- PERIOD_MISMATCH
- DOUBLE_POSTING
- FRAUDULENT_PAYMENT

---

## 是正・再発防止 共通指針

- 承認ポリシー強化
- 閾値（threshold）再設定
- 自動 quarantine 条件見直し
- 再実行回数制限
- 監査頻度引き上げ

---

本テンプレは **audit.audit_event / reason_code** を唯一の正本とし、
業種追加時は同構造で追記すること。
