-- ============================================================
-- BenapoleBlood — Supabase Database Setup
-- Run in: Supabase Dashboard > SQL Editor > New query > Run
-- This replaces Firebase Firestore collections:
--   users -> profiles, requests -> requests, donations -> donations, team -> team
-- ============================================================

create extension if not exists pgcrypto;

-- ---------- PROFILES (was Firestore "users") ----------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  email text not null,
  phone text,
  blood text,              -- A+, A-, B+, B-, O+, O-, AB+, AB-
  role text not null default 'donor',  -- donor | receiver | admin
  district text,
  available boolean not null default true,
  donation_count int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- REQUESTS (blood requests) ----------
create table if not exists public.requests (
  id uuid primary key default gen_random_uuid(),
  patient text not null,
  problem text,
  hospital text,
  blood text not null,
  date date,
  location text not null,
  phone text not null,
  note text,
  is_emergency boolean not null default false,
  status text not null default 'active',  -- active | fulfilled | closed
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

-- ---------- DONATIONS ----------
create table if not exists public.donations (
  id uuid primary key default gen_random_uuid(),
  donor_id uuid references public.profiles(id) on delete set null,
  request_id uuid references public.requests(id) on delete set null,
  patient text,
  date timestamptz not null default now(),
  status text not null default 'verified',
  created_at timestamptz not null default now()
);

-- ---------- TEAM (volunteers shown in app) ----------
create table if not exists public.team (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text,
  img text,
  created_at timestamptz not null default now()
);

-- ---------- Helper: is current user an admin? ----------
create or replace function public.is_admin()
returns boolean language sql security definer stable as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

-- ---------- Row Level Security ----------
alter table public.profiles enable row level security;
alter table public.requests enable row level security;
alter table public.donations enable row level security;
alter table public.team enable row level security;

-- Profiles: anyone logged in can view donors (needed for donor search), only owner/admin can change
create policy "profiles read" on public.profiles for select using (auth.role() = 'authenticated');
create policy "profiles insert own" on public.profiles for insert with check (auth.uid() = id);
create policy "profiles update own or admin" on public.profiles for update using (auth.uid() = id or public.is_admin());
create policy "profiles delete admin" on public.profiles for delete using (public.is_admin());

-- Requests: logged-in users can read all, create own, edit/delete own or admin
create policy "requests read" on public.requests for select using (auth.role() = 'authenticated');
create policy "requests insert own" on public.requests for insert with check (auth.uid() = created_by);
create policy "requests update own or admin" on public.requests for update using (auth.uid() = created_by or public.is_admin());
create policy "requests delete own or admin" on public.requests for delete using (auth.uid() = created_by or public.is_admin());

-- Donations: read own + admin, admin creates/manages (admin verifies donations in current app)
create policy "donations read own or admin" on public.donations for select using (auth.uid() = donor_id or public.is_admin());
create policy "donations insert admin" on public.donations for insert with check (public.is_admin());
create policy "donations update admin" on public.donations for update using (public.is_admin());
create policy "donations delete admin" on public.donations for delete using (public.is_admin());

-- Team: everyone logged in can read, only admin can change
create policy "team read" on public.team for select using (auth.role() = 'authenticated');
create policy "team write admin" on public.team for all using (public.is_admin()) with check (public.is_admin());

-- ---------- Auto-create a profile row on signup ----------
-- The app should insert the full profile (name, blood, district etc.) right after signUp.
-- This trigger creates a minimal row if the app insert hasn't happened, so login never gets stuck.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', ''), new.email)
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- MAKE YOURSELF ADMIN ----------
-- After YOU register in the app with your email, run this once (replace email):
-- update public.profiles set role = 'admin' where email = 'YOUR_EMAIL_HERE';
