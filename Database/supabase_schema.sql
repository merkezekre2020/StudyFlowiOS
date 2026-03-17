-- Enable UUID generation
create extension if not exists "pgcrypto";

create table if not exists public.users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null unique,
  display_name text,
  timezone text,
  created_at timestamptz not null default now()
);

create table if not exists public.subjects (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(user_id) on delete cascade,
  title text not null,
  color_hex text,
  created_at timestamptz not null default now()
);

create table if not exists public.study_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(user_id) on delete cascade,
  subject_id uuid not null references public.subjects(id) on delete cascade,
  title text not null,
  objective text,
  starts_at timestamptz,
  ends_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.study_tasks (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(user_id) on delete cascade,
  plan_id uuid not null references public.study_plans(id) on delete cascade,
  title text not null,
  notes text,
  due_at timestamptz,
  is_completed boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.progress_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.users(user_id) on delete cascade,
  task_id uuid references public.study_tasks(id) on delete set null,
  plan_id uuid references public.study_plans(id) on delete set null,
  minutes_studied integer not null check(minutes_studied >= 0),
  confidence integer check(confidence between 1 and 5),
  notes text,
  logged_at timestamptz not null default now()
);

alter table public.users enable row level security;
alter table public.subjects enable row level security;
alter table public.study_plans enable row level security;
alter table public.study_tasks enable row level security;
alter table public.progress_logs enable row level security;

create policy if not exists "users_select_own"
  on public.users for select using (auth.uid() = user_id);
create policy if not exists "users_mutate_own"
  on public.users for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy if not exists "subjects_rw_own"
  on public.subjects for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy if not exists "plans_rw_own"
  on public.study_plans for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy if not exists "tasks_rw_own"
  on public.study_tasks for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy if not exists "logs_rw_own"
  on public.progress_logs for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
