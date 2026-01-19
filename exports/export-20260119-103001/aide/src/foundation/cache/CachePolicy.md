# SQLite Cache Policy

- SQLite は **キャッシュ用途のみ**
- 正本は Supabase（Postgres + RLS）
- company_id / tenant 情報は保存しない
- 書き込みは同期処理のみが担当
- 破棄可能なデータのみ保存
