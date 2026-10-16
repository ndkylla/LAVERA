-- LAVÉRA Supabase schema (revised)
-- Run in Supabase Dashboard > SQL Editor > New query.
-- Includes service_method for drop-off, pickup, and pickup + delivery.

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null default '',
  phone text not null default '',
  role text not null default 'customer'
    check (role in ('customer', 'owner')),
  created_at timestamptz not null default now()
);

create table if not exists public.services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text not null default '',
  price numeric(12,2) not null check (price >= 0),
  unit text not null default 'kg' check (unit in ('kg', 'pcs')),
  eta_text text not null default '1–2 hari',
  active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique
    default ('LAV-' || upper(substr(encode(gen_random_bytes(5), 'hex'), 1, 8))),
  customer_id uuid not null references public.profiles(id) on delete cascade,
  service_id uuid references public.services(id) on delete set null,
  customer_name text not null,
  customer_phone text not null,
  service_method text not null default 'drop_off'
    check (service_method in ('drop_off', 'pickup', 'pickup_delivery')),
  pickup_address text not null,
  pickup_date date not null,
  quantity numeric(8,2) not null check (quantity > 0),
  unit text not null default 'kg',
  unit_price numeric(12,2) not null check (unit_price >= 0),
  total_price numeric(12,2) not null check (total_price >= 0),
  notes text not null default '',
  status text not null default 'Menunggu konfirmasi'
    check (status in ('Menunggu konfirmasi', 'Diproses', 'Siap diantar', 'Selesai', 'Dibatalkan')),
  created_at timestamptz not null default now()
);

-- Migration for projects where public.orders already existed before service_method was added.
alter table public.orders
  add column if not exists service_method text not null default 'drop_off';

-- Add the check constraint safely whether the table is new or already existed.
do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'orders_service_method_check'
      and conrelid = 'public.orders'::regclass
  ) then
    alter table public.orders
      add constraint orders_service_method_check
      check (service_method in ('drop_off', 'pickup', 'pickup_delivery'));
  end if;
end;
$$;

-- Automatically create a customer profile when someone signs up.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'phone', ''),
    'customer'
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Helper function for owner checks without recursive profile RLS.
create or replace function public.is_lavera_owner()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'owner'
  );
$$;

grant execute on function public.is_lavera_owner() to authenticated;

alter table public.profiles enable row level security;
alter table public.services enable row level security;
alter table public.orders enable row level security;

-- PROFILES
drop policy if exists "profiles read self or owner" on public.profiles;
create policy "profiles read self or owner"
on public.profiles
for select
to authenticated
using (id = auth.uid() or public.is_lavera_owner());

drop policy if exists "profiles update self or owner" on public.profiles;
create policy "profiles update self or owner"
on public.profiles
for update
to authenticated
using (id = auth.uid() or public.is_lavera_owner())
with check (id = auth.uid() or public.is_lavera_owner());

-- Prevent a customer from promoting their own role through the frontend.
-- Users can update their own name/phone; promote the owner account in SQL Editor.
revoke update on public.profiles from authenticated;
grant update (full_name, phone) on public.profiles to authenticated;

-- SERVICES
drop policy if exists "services public read active" on public.services;
create policy "services public read active"
on public.services
for select
to anon, authenticated
using (active = true or public.is_lavera_owner());

drop policy if exists "services owner manage" on public.services;
create policy "services owner manage"
on public.services
for all
to authenticated
using (public.is_lavera_owner())
with check (public.is_lavera_owner());

-- ORDERS
drop policy if exists "orders customer read own or owner read all" on public.orders;
create policy "orders customer read own or owner read all"
on public.orders
for select
to authenticated
using (customer_id = auth.uid() or public.is_lavera_owner());

drop policy if exists "orders customer create own" on public.orders;
create policy "orders customer create own"
on public.orders
for insert
to authenticated
with check (customer_id = auth.uid());

drop policy if exists "orders owner update" on public.orders;
create policy "orders owner update"
on public.orders
for update
to authenticated
using (public.is_lavera_owner())
with check (public.is_lavera_owner());

-- Starter services (safe to run repeatedly by service name).
insert into public.services (name, description, price, unit, eta_text, sort_order)
select v.name, v.description, v.price, v.unit, v.eta_text, v.sort_order
from (
  values
    ('Cuci Kering', 'Cuci dan pengeringan, siap disetrika sendiri.', 5000::numeric, 'kg', 'Sekitar 1 hari', 1),
    ('Cuci Komplit', 'Cuci, pelembut, dan setrika rapi.', 8000::numeric, 'kg', 'Sekitar 2 hari', 2),
    ('Setrika Saja', 'Setrika rapi dengan pewangi pilihan.', 4000::numeric, 'kg', 'Sekitar 1 hari', 3),
    ('Express Service', 'Layanan prioritas kilat.', 15000::numeric, 'kg', 'Sekitar 6 jam', 4),
    ('Bed Cover & Selimut', 'Perawatan item besar atau tebal.', 20000::numeric, 'pcs', 'Sekitar 2 hari', 5)
) as v(name, description, price, unit, eta_text, sort_order)
where not exists (
  select 1
  from public.services s
  where s.name = v.name
);

-- After creating your owner account through the website, promote it using SQL Editor:
-- update public.profiles
-- set role = 'owner'
-- where id = (select id from auth.users where email = 'owner@email.com');
--
-- Never expose a service_role key or secret key in frontend code.
