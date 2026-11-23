create table public.harmos_plans (
 id text primary key, name text not null, monthly_cents integer not null check(monthly_cents>=0),
 first_month_cents integer not null check(first_month_cents>=0), enrollment_cents integer not null check(enrollment_cents>=0),
 benefits text[] not null default '{}', active boolean not null default true);
create table public.harmos_staff (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null check(role in ('SUPER_ADMIN','ADMIN_ACADEMIA','GESTOR_FINANCEIRO','RECEPCAO','COMERCIAL','PROFESSOR')));
create table public.harmos_profiles (
 user_id uuid primary key references auth.users(id) on delete cascade,
 full_name text not null check(char_length(trim(full_name)) between 3 and 120),
 phone text not null check(phone ~ '^[0-9]{10,11}$'), created_at timestamptz not null default now());
create table public.harmos_enrollment_requests (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id) on delete cascade,
 plan_id text not null references public.harmos_plans(id),
 status text not null default 'requested' check(status in ('requested','reviewing','cancelled')),
 created_at timestamptz not null default now(), unique(user_id,plan_id));
alter table public.harmos_plans enable row level security;
alter table public.harmos_staff enable row level security;
alter table public.harmos_profiles enable row level security;
alter table public.harmos_enrollment_requests enable row level security;
create policy plans_read on public.harmos_plans for select to anon,authenticated using(active);
create policy plans_staff_read on public.harmos_plans for select to authenticated using(exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA')));
create policy staff_self on public.harmos_staff for select to authenticated using(user_id=(select auth.uid()));
create policy plans_manage on public.harmos_plans for all to authenticated using(exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA'))) with check(exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA')));
create policy profiles_read on public.harmos_profiles for select to authenticated using(user_id=(select auth.uid()) or exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA','RECEPCAO','COMERCIAL')));
create policy profiles_insert on public.harmos_profiles for insert to authenticated with check(user_id=(select auth.uid()));
create policy profiles_update on public.harmos_profiles for update to authenticated using(user_id=(select auth.uid())) with check(user_id=(select auth.uid()));
create policy requests_read on public.harmos_enrollment_requests for select to authenticated using(user_id=(select auth.uid()) or exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA','RECEPCAO','COMERCIAL')));
create policy requests_insert on public.harmos_enrollment_requests for insert to authenticated with check(user_id=(select auth.uid()) and status='requested' and exists(select 1 from public.harmos_plans p where p.id=plan_id and p.active) and exists(select 1 from public.harmos_profiles p where p.user_id=(select auth.uid())));
create policy requests_staff_update on public.harmos_enrollment_requests for update to authenticated using(exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA','RECEPCAO','COMERCIAL'))) with check(exists(select 1 from public.harmos_staff s where s.user_id=(select auth.uid()) and s.role in ('SUPER_ADMIN','ADMIN_ACADEMIA','RECEPCAO','COMERCIAL')));
grant select on public.harmos_plans to anon,authenticated;
grant insert,update,delete on public.harmos_plans to authenticated;
grant select on public.harmos_staff to authenticated;
grant select,insert,update on public.harmos_profiles,public.harmos_enrollment_requests to authenticated;
revoke all on public.harmos_staff from anon;
revoke insert,update,delete on public.harmos_staff from authenticated;
create index harmos_requests_plan_idx on public.harmos_enrollment_requests(plan_id);
