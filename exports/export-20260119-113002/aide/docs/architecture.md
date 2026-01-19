# ERP Foundation (Coding-Only)
- This repo is the **source of truth** for coding.
- Build/test are handled elsewhere (PC / CI).
- **Hard rules**
  - company_id is never accessed outside SessionManager (and never exposed publicly).
  - Supabase RLS is assumed; client must not send company_id.
  - SQLite is cache only.
