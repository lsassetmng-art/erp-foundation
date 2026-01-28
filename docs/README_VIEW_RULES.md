# VIEW 設計・運用ルール（確定）

## 概要
本プロジェクトでは **DB事故防止と進化耐性** のため、  
VIEW 設計・運用に以下のルールを適用する。

- **public スキーマ：VIEWのみ**
- **正本データ：業務スキーマ（例：sales）**
- アプリ・API は **VIEWのみ参照**

---

## 基本方針

- VIEW は「業務契約」
- TABLE は「正本データ」
- VIEW で業務意味を定義し、TABLE変更を吸収する

---

## VIEW 作成の必須手順（順序厳守）

### Step 1｜正本テーブル確認

```sql
SELECT table_schema, table_name, table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('pg_catalog','information_schema')
ORDER BY table_schema, table_type DESC, table_name;
BASE TABLE のみを正本として扱う
VIEW を JOIN 元にしない
Step 2｜列の実在確認
コードをコピーする
Sql
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'sales'
  AND table_name = '対象テーブル名';
存在しない列は 使用禁止
「あるはず」「後で作る」は不可
Step 3｜対象 VIEW のみ DROP
コードをコピーする
Sql
DROP VIEW IF EXISTS public.v_xxx CASCADE;
今回作成・再作成する VIEW のみ
public 全体 DROP は 禁止
Step 4｜VIEW 作成
CREATE OR REPLACE VIEW 使用可
命名規則：public.v_業務意味
schema 省略禁止（必ず sales. 等を明示）
JOIN 設計ルール（佐藤ルール）
実在 TABLE × 実在列のみ JOIN
仮定 JOIN 禁止
返品は必ず出荷（shipping_detail）起点
正しい JOIN 関係
コードをコピーする

shipping_header
 └ shipping_detail
     └ return_detail
         └ return_header
コードをコピーする

shipping_detail
 └ invoice_detail
     └ invoice_header
禁止事項（即差し戻し）
public に BASE TABLE を置く
存在しない列・テーブルを仮定
VIEW の無差別 DROP
status を TABLE に保存（VIEW 算出のみ）
目的
DB事故防止
差分管理・段階移行の実現
AI実装でも一貫した設計を保つ MD
コードをコピーする

👉 **README.md からリンク or 内容貼替で使用可能**

監視VIEWの制約（重要）
未請求出荷検知について
public.v_alert_unbilled_shipping は、
**shipping_id 単位で「請求が一切紐づいていない出荷」**を検知します。
背景
現行DBでは
shipping_detail ↔ billing_detail の直接対応が存在しない
item単位JOINによる検知は誤判定の恐れがある
採用方針
shipping_header → return_header → billing_header の存在関係のみで判断
数量・金額の厳密突合は 将来DDL（明細直結）後に実施
将来対応
return_detail.shipping_detail_id 等の追加後、
未請求検知を 明細レベルへ進化させる
