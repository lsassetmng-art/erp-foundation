-- ============================================================
-- FOUNDATION DDL (Single Source of Truth)
-- ============================================================

\set ON_ERROR_STOP on
begin;

create schema if not exists foundation;

create table if not exists foundation.schema_version (
  version_text text primary key,
  applied_at   timestamptz not null default now()
);

create table if not exists foundation.company (
  company_id   uuid primary key default gen_random_uuid(),
  company_name text not null,
  status       text not null default 'active',
  created_at   timestamptz not null default now()
);

create table if not exists foundation.company_user (
  user_id      uuid not null,
  company_id   uuid not null references foundation.company(company_id) on delete cascade,
  email        text not null,
  status       text not null default 'active',
  created_at   timestamptz not null default now(),
  primary key (user_id, company_id)
);

create index if not exists ix_company_user_company on foundation.company_user(company_id);
create index if not exists ix_company_user_email   on foundation.company_user(email);

create table if not exists foundation.role (
  role_code    text primary key,
  description  text,
  created_at   timestamptz not null default now()
);

create table if not exists foundation.permission (
  permission_code text primary key,
  description     text,
  created_at      timestamptz not null default now()
);

create table if not exists foundation.role_permission (
  role_code        text not null references foundation.role(role_code) on delete cascade,
  permission_code  text not null references foundation.permission(permission_code) on delete cascade,
  created_at       timestamptz not null default now(),
  primary key (role_code, permission_code)
);

create table if not exists foundation.user_role (
  user_id    uuid not null,
  role_code  text not null references foundation.role(role_code) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, role_code)
);

create table if not exists foundation.license (
  license_code text not null,
  company_id   uuid not null references foundation.company(company_id) on delete cascade,
  valid_from   date,
  valid_to     date,
  status       text not null default 'active',
  created_at   timestamptz not null default now(),
  primary key (license_code, company_id)
);

create index if not exists ix_license_company on foundation.license(company_id);

create table if not exists foundation.foundation_config (
  config_key   text primary key,
  config_value text,
  updated_at   timestamptz not null default now()
);

create table if not exists foundation.outbox_event (
  outbox_id    uuid primary key default gen_random_uuid(),
  event_type   text not null,
  idempotency_key text,
  payload      jsonb not null,
  status       text not null default 'queued',
  retry_count  int not null default 0,
  last_error   text,
  created_at   timestamptz not null default now(),
  sent_at      timestamptz
);

create index if not exists ix_outbox_event_status  on foundation.outbox_event(status);
create index if not exists ix_outbox_event_created on foundation.outbox_event(created_at);

create or replace function foundation.get_my_foundation_context()
returns jsonb
language sql
security definer
as $$
select jsonb_build_object(
  'user_id', auth.uid(),
  'company_id', cu.company_id,
  'roles', coalesce((select jsonb_agg(ur.role_code) from foundation.user_role ur where ur.user_id = auth.uid()), '[]'::jsonb),
  'permissions', coalesce((
      select jsonb_agg(rp.permission_code)
      from foundation.user_role ur
      join foundation.role_permission rp on rp.role_code = ur.role_code
      where ur.user_id = auth.uid()
  ), '[]'::jsonb),
  'license_codes', coalesce((
      select jsonb_agg(l.license_code)
      from foundation.license l
      where l.company_id = cu.company_id
        and l.status = 'active'
        and (l.valid_from is null or l.valid_from <= current_date)
        and (l.valid_to is null or l.valid_to >= current_date)
  ), '[]'::jsonb)
)
from foundation.company_user cu
where cu.user_id = auth.uid()
limit 1;
$$;

-- seed (idempotent)
insert into foundation.role(role_code, description)
values ('ADMIN','Foundation administrator'), ('OPERATOR','Foundation operator')
on conflict (role_code) do nothing;

insert into foundation.permission(permission_code, description)
values
  ('FOUNDATION_VIEW','View foundation status'),
  ('FOUNDATION_CONFIG_EDIT','Edit foundation config'),
  ('FOUNDATION_MASTER_EDIT','Edit foundation masters'),
  ('FOUNDATION_OUTBOX_RETRY','Retry outbox')
on conflict (permission_code) do nothing;

insert into foundation.role_permission(role_code, permission_code)
values
  ('ADMIN','FOUNDATION_VIEW'),
  ('ADMIN','FOUNDATION_CONFIG_EDIT'),
  ('ADMIN','FOUNDATION_MASTER_EDIT'),
  ('ADMIN','FOUNDATION_OUTBOX_RETRY'),
  ('OPERATOR','FOUNDATION_VIEW')
on conflict do nothing;

insert into foundation.foundation_config(config_key, config_value)
values
  ('post_login_destination','FOUNDATION_HOME'),
  ('foundation_version','0.1.0'),
  ('foundation_mode','foundation-only')
on conflict (config_key) do update
set config_value = excluded.config_value,
    updated_at  = now();

insert into foundation.schema_version(version_text)
values ('foundation-0.1.0')
on conflict (version_text) do nothing;

commit;
