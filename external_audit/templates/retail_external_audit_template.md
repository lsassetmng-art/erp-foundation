# 小売業向け 外部監査テンプレ

## 主な監査観点

### 在庫
- 在庫差異の多発
- 廃棄ロスの異常
- 棚卸未実施

### 価格・販売
- 承認なし価格変更
- 異常値引き
- 原価割れ販売

### 業務統制
- 承認スキップ
- 同一担当による多重処理
- 夜間・休日処理の集中

## 推奨 reason_code
- INVENTORY_MISMATCH
- PRICE_OVERRIDE_NO_APPROVAL
- EXCESSIVE_DISCOUNT
- UNAUTHORIZED_OPERATION
- ABNORMAL_LOSS

## 是正ガイドライン
- 承認ポリシー強化
- 閾値（threshold）見直し
- 再発時の自動 quarantine
