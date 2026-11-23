begin;
insert into auth.users(id,aud,role,email) values
('00000000-0000-4000-8000-000000000001','authenticated','authenticated','harmos-rls-a@example.invalid'),
('00000000-0000-4000-8000-000000000002','authenticated','authenticated','harmos-rls-b@example.invalid');
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000001',true);
insert into public.harmos_profiles(user_id,full_name,phone) values('00000000-0000-4000-8000-000000000001','Teste RLS','41999999999');
insert into public.harmos_enrollment_requests(user_id,plan_id) values('00000000-0000-4000-8000-000000000001','essencial');
do $$ begin
 if (select count(*) from public.harmos_enrollment_requests)<>1 then raise exception 'owner read failed';end if;
 begin
 insert into public.harmos_profiles(user_id,full_name,phone) values('00000000-0000-4000-8000-000000000002','Acesso indevido','41999999999');
 raise exception 'cross-user profile write allowed';
 exception when insufficient_privilege then null;end;
 begin
 insert into public.harmos_staff(user_id,role) values('00000000-0000-4000-8000-000000000001','SUPER_ADMIN');
 raise exception 'privilege escalation allowed';
 exception when insufficient_privilege then null;end;
 begin
 insert into public.harmos_enrollment_requests(user_id,plan_id,status) values('00000000-0000-4000-8000-000000000001','exclusive','reviewing');
 raise exception 'forged status allowed';
 exception when insufficient_privilege then null;end;
 begin
 insert into public.harmos_enrollment_requests(user_id,plan_id) values('00000000-0000-4000-8000-000000000001','essencial');
 raise exception 'duplicate allowed';
 exception when unique_violation then null;end;
end $$;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000002',true);
do $$ begin
 if (select count(*) from public.harmos_profiles)<>0 then raise exception 'cross-user profile disclosure';end if;
 if (select count(*) from public.harmos_enrollment_requests)<>0 then raise exception 'cross-user request disclosure';end if;
 if (select count(*) from public.harmos_staff)<>0 then raise exception 'staff disclosure';end if;
end $$;
reset role;
insert into public.harmos_staff(user_id,role) values('00000000-0000-4000-8000-000000000002','COMERCIAL');
set local role authenticated;
select set_config('request.jwt.claim.sub','00000000-0000-4000-8000-000000000002',true);
do $$ begin
 if (select count(*) from public.harmos_enrollment_requests)<>1 then raise exception 'staff read failed';end if;
 update public.harmos_enrollment_requests set status='reviewing';
 if not found then raise exception 'staff update failed';end if;
 if (select count(*) from public.harmos_profiles)<>1 then raise exception 'staff profile read failed';end if;
end $$;
set local role anon;
select set_config('request.jwt.claim.sub','',true);
do $$ begin
 if (select count(*) from public.harmos_plans)<>2 then raise exception 'public plans unavailable';end if;
 begin
 insert into public.harmos_profiles(user_id,full_name,phone) values('00000000-0000-4000-8000-000000000002','Anonymous','41999999999');
 raise exception 'anonymous write allowed';
 exception when insufficient_privilege then null;end;
end $$;
rollback;
select 'PASS: owner persistence, isolation, public plans, duplicate prevention, status and role escalation checks; all fixtures rolled back' as result;
