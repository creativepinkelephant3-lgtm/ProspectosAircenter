-- CRM Instagram + Supabase
-- 1) Ejecuta este script en Supabase > SQL Editor.
-- 2) Crea los usuarios en Authentication > Users.
-- 3) Inserta sus user_id en public.app_users con rol admin o asesor.

create table if not exists public.app_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  full_name text not null,
  role text not null default 'asesor' check (role in ('admin','asesor')),
  active boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.prospectos (
  id text primary key,
  username text,
  full_name text,
  profile_link text,
  raw_data jsonb not null,
  score integer,
  clasificacion text,
  sector text,
  accion text,
  contacto_visible text,
  senales_negocio text,
  posible_competidor text,
  evidencia text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.gestiones (
  gestion_id text primary key,
  prospecto_id text not null references public.prospectos(id) on delete cascade,
  asesor_id uuid references auth.users(id) on delete set null,
  asesor_email text,
  asesor text,
  fecha date not null default current_date,
  canal text,
  contactabilidad text,
  tipificacion text,
  proximo_seguimiento date,
  valor numeric default 0,
  intencion text,
  mensaje text,
  observacion text,
  raw_data jsonb not null,
  created_at timestamptz not null default now()
);

create table if not exists public.app_config (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

insert into public.app_config(key, value) values
('competitorKeywords','keaser, keaser marketing, kaiser, mercaderismo, trade marketing'),
('targetKeywords','empresa, negocio, tienda, restaurante, gastro, hotel, moda, belleza, industria, industrial, construcción, ferretería, salud, odontología, clínica, laboratorio, alimentos, ecommerce, comercio, retail, servicios, b2b, compresor, aire comprimido'),
('advisorList','Asesor 1, Asesor 2, Asesor 3'),
('typificationList','Pendiente, Mensaje enviado, Contactado, No contestó, Envió cotización, Seguimiento, Venta, No venta, No interesado, Datos inválidos, Posible trabajador/competencia')
on conflict (key) do nothing;

create or replace function public.is_active_app_user()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists(select 1 from public.app_users where user_id = auth.uid() and active = true);
$$;

create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists(select 1 from public.app_users where user_id = auth.uid() and active = true and role = 'admin');
$$;

alter table public.app_users enable row level security;
alter table public.prospectos enable row level security;
alter table public.gestiones enable row level security;
alter table public.app_config enable row level security;

drop policy if exists "app_users_select" on public.app_users;
drop policy if exists "app_users_admin_all" on public.app_users;
drop policy if exists "prospectos_select_active" on public.prospectos;
drop policy if exists "prospectos_admin_insert" on public.prospectos;
drop policy if exists "prospectos_admin_update" on public.prospectos;
drop policy if exists "prospectos_admin_delete" on public.prospectos;
drop policy if exists "gestiones_select_active" on public.gestiones;
drop policy if exists "gestiones_insert_active" on public.gestiones;
drop policy if exists "gestiones_admin_update" on public.gestiones;
drop policy if exists "gestiones_admin_delete" on public.gestiones;
drop policy if exists "config_select_active" on public.app_config;
drop policy if exists "config_admin_all" on public.app_config;

create policy "app_users_select" on public.app_users
for select to authenticated
using (auth.uid() = user_id or public.is_admin());

create policy "app_users_admin_all" on public.app_users
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "prospectos_select_active" on public.prospectos
for select to authenticated
using (public.is_active_app_user());

create policy "prospectos_admin_insert" on public.prospectos
for insert to authenticated
with check (public.is_admin());

create policy "prospectos_admin_update" on public.prospectos
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "prospectos_admin_delete" on public.prospectos
for delete to authenticated
using (public.is_admin());

create policy "gestiones_select_active" on public.gestiones
for select to authenticated
using (public.is_active_app_user());

create policy "gestiones_insert_active" on public.gestiones
for insert to authenticated
with check (public.is_active_app_user() and asesor_id = auth.uid());

create policy "gestiones_admin_update" on public.gestiones
for update to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "gestiones_admin_delete" on public.gestiones
for delete to authenticated
using (public.is_admin());

create policy "config_select_active" on public.app_config
for select to authenticated
using (public.is_active_app_user());

create policy "config_admin_all" on public.app_config
for all to authenticated
using (public.is_admin())
with check (public.is_admin());

-- Ejemplo después de crear usuarios en Authentication > Users:
-- insert into public.app_users(user_id, email, full_name, role)
-- values ('PEGA_AQUI_UUID_DEL_USUARIO', 'correo@empresa.com', 'Nombre asesor', 'admin');
