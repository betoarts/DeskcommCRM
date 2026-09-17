-- Configuração do remetente Resend por instalação.
-- O segredo só é acessível pelo service_role e fica cifrado pela mesma RPC
-- usada nas demais credenciais da instalação.
create table if not exists public.platform_resend_settings (
  id smallint primary key default 1,
  api_key_encrypted bytea,
  from_email text,
  updated_at timestamptz not null default now(),
  updated_by uuid,
  constraint platform_resend_settings_singleton check (id = 1),
  constraint platform_resend_settings_from_email check (
    from_email is null or from_email ~* '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'
  )
);

comment on table public.platform_resend_settings is
  'Remetente Resend desta instalação. Server-side only; a API key nunca volta ao browser e nunca é gravada em claro.';

alter table public.platform_resend_settings enable row level security;
revoke all on public.platform_resend_settings from anon, authenticated;
grant select, insert, update on public.platform_resend_settings to service_role;

drop trigger if exists trg_platform_resend_settings_updated_at on public.platform_resend_settings;
create trigger trg_platform_resend_settings_updated_at
  before update on public.platform_resend_settings
  for each row execute function public.fn_set_updated_at();
