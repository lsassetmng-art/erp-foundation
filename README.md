# ERP Foundation / Approval / AI Governance  
README（正本・Freeze）

---

## 0. はじめに（裁定文・Freeze 宣言）

本リポジトリは、ERP 全体における **基盤（Foundation）レイヤ**を実装する。

ここで言う基盤とは、以下を含む。

- 認証・設定・通信などの Foundation 機構  
- Approval / AI Governance（承認・判断支援・証跡）  
- Analytics（READ ONLY・可視化）  
- Ops / KillSwitch / 運用制御  
- UI（READ ONLY・入力補助のみ）

これらは **業務ロジックではない**。  
また、**自動判断・自動承認は一切行わない**。

---

## 1. 裁定（Phase Freeze）

本リポジトリに含まれる基盤設計は、  
**Phase 0 〜 Phase 12 をもって確定（Freeze）**とする。

以降、以下を禁止する。

- 基盤仕様の変更
- 自動判断・自動承認の追加
- analytics / public schema への WRITE
- 既存判断フローを暗黙に変更する実装

基盤に対する変更が必要な場合は、  
**業務フェーズとは独立した再裁定フェーズ**を設けること。

---

## 2. 基盤の責務範囲

基盤が担うのは以下のみ。

- 判断材料の収集・整形・可視化
- 判断結果の記録（証跡）
- 人の判断を阻害しない UI 提供
- 夜間・単独運用でも事故を起こさない構造

基盤は **賢くならない**。  
判断は常に人が行う。

---

## 3. Approval / AI Governance 方針

- Approval は「判断の代替」ではない
- AI は提案・補助・可視化まで
- 決裁は必ず人が行う
- 決裁結果は必ず記録される

Approval / AI Governance は  
**販売管理・在庫管理・会計の上位概念ではなく、横断基盤**である。

---

## 4. Analytics 方針

- analytics スキーマは **READ ONLY**
- 集計・傾向・SLA・バックログ可視化のみ
- 推測・補完・自動決定は禁止
- 0 件は正常

---

## 5. UI 方針（Android / Web）

- UI は READ ONLY
- 入力は補助のみ
- 判断を誘導しない
- 操作不能＝安全側

---

## 6. public スキーマの扱い

- TABLE は作らない
- VIEW のみ
- 参照・並び替えのみ
- 判断・集約・推測は禁止

---

## 7. 業務フェーズとの関係

販売管理・在庫管理・会計等の **業務機能は Phase 13 以降**とする。

業務機能は必ず、

- 本基盤のルールに従う
- 判断は人が行う
- 判断結果を記録する

こと。

---

## 8. フェーズ一覧（確定）

- Phase 0–5 : Foundation / 基盤整備  
- Phase 6–8 : Approval / Governance  
- Phase 9–10 : Analytics / Recommendation（READ ONLY）  
- Phase 11–12 : UI / Ops / Freeze  

👉 **Phase 13 以降：業務機能**

---

## 9. 本 README の位置づけ

- 本 README は **唯一の正本**
- 実装・運用・引き継ぎの判断基準
- 監査・再構築時の基準文書

---

**最終裁定者：ナイト**  
**状態：Freeze（変更禁止）**
