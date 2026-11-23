create schema harmos_crm;
revoke all on schema harmos_crm from public,anon,authenticated;
create table harmos_crm.admins(email text primary key);
create table harmos_crm.settings(key text primary key,value text not null);
create table harmos_crm.leads(id uuid primary key default gen_random_uuid(), client_id uuid not null unique, topic text not null, kind text not null check(kind in ('aluno','interessado')), name text not null default '', phone text not null default '', goal text not null default '', preference text not null default '', source text not null default '', summary text not null, handoff_hash text not null, handoff_draft text not null default '', stage text not null default 'Novo', owner text not null default '', next_due text not null default '', notes text not null default '', opened_at timestamptz, consent_version text not null, created_at timestamptz not null default now(), updated_at timestamptz not null default now());
create index on harmos_crm.leads(created_at desc);
create table harmos_crm.events(id uuid primary key default gen_random_uuid(),lead_id uuid references harmos_crm.leads(id) on delete cascade,actor text not null,event text not null,detail text not null default '',created_at timestamptz not null default now());
create index on harmos_crm.events(lead_id);
create table harmos_crm.knowledge(id text primary key,body jsonb not null,revision integer not null default 1,updated_at timestamptz not null default now());
create table harmos_crm.limits(key text primary key,hits integer not null,expires timestamptz not null);
alter table harmos_crm.admins enable row level security;
alter table harmos_crm.settings enable row level security;
alter table harmos_crm.leads enable row level security;
alter table harmos_crm.events enable row level security;
alter table harmos_crm.knowledge enable row level security;
alter table harmos_crm.limits enable row level security;
create function harmos_crm.is_admin() returns boolean language sql stable security definer set search_path='' as $$
select exists(select 1 from auth.users u join harmos_crm.admins a on a.email=lower(u.email) where u.id=auth.uid() and u.email_confirmed_at is not null and u.deleted_at is null);
$$;
revoke all on function harmos_crm.is_admin() from public,anon,authenticated;
create function public.harmos_conecta_api(action text,payload jsonb,api_secret text) returns jsonb language plpgsql security definer set search_path='' as $$
declare actor text; lead harmos_crm.leads; topic_id text; stamp timestamptz:=clock_timestamp(); count_hits integer; out_data jsonb; affected integer; allowed_topics text[]:=array['planos','visita','pilates','mulher','aulas','tour','inicio','retorno','financeiro','cancelamento','manutencao','parcerias','humano'];
begin
 if not exists(select 1 from harmos_crm.settings where key='api_hash' and value=encode(extensions.digest(api_secret,'sha256'),'hex')) then raise sqlstate '28000' using message='Serviço não autorizado';end if;
 if action='me' then return jsonb_build_object('authorized',harmos_crm.is_admin());end if;
 if action='knowledge' then return coalesce((select jsonb_agg(to_jsonb(k)) from harmos_crm.knowledge k),'[]'::jsonb);end if;
 if action in ('list','events','update','delete','knowledge_save','export') then
  if not harmos_crm.is_admin() then raise sqlstate '42501' using message='Acesso reservado à equipe autorizada';end if;actor:=auth.uid()::text;
 end if;
 if action='create' then
  if payload->>'consent'<>'true' or not (payload->>'topic'=any(allowed_topics)) or (payload->>'kind') not in ('aluno','interessado') or length(coalesce(payload->>'name',''))>80 or length(coalesce(payload->>'phone',''))>22 or length(coalesce(payload->>'goal',''))>500 or length(coalesce(payload->>'preference',''))>180 or length(coalesce(payload->>'summary',''))>2200 then raise sqlstate '22023' using message='Confira os dados e a autorização de registro';end if;
  insert into harmos_crm.limits(key,hits,expires) values(payload->>'rate_key',1,stamp+interval '2 hours') on conflict(key) do update set hits=harmos_crm.limits.hits+1 returning hits into count_hits;
  if count_hits>20 then return jsonb_build_object('error','Limite de solicitações atingido. Continue pelo WhatsApp.','status',429);end if;
  delete from harmos_crm.limits where expires<stamp;
  if exists(select 1 from harmos_crm.leads where client_id=(payload->>'client_id')::uuid) then return jsonb_build_object('error','Este atendimento já foi registrado.','status',409);end if;
  insert into harmos_crm.leads(id,client_id,topic,kind,name,phone,goal,preference,source,summary,handoff_hash,consent_version) values((payload->>'id')::uuid,(payload->>'client_id')::uuid,payload->>'topic',payload->>'kind',coalesce(payload->>'name',''),coalesce(payload->>'phone',''),coalesce(payload->>'goal',''),coalesce(payload->>'preference',''),coalesce(payload->>'source',''),payload->>'summary',payload->>'handoff_hash','2026-11-23-v1') returning * into lead;
  insert into harmos_crm.events(lead_id,actor,event,detail) values(lead.id,'visitante','Solicitação registrada','Autorização de registro v1');return jsonb_build_object('id',lead.id,'summary',lead.summary);
 elsif action='handoff' then
  if length(payload->>'draft')>2500 then raise sqlstate '22023' using message='Resumo muito longo';end if;
  select * into lead from harmos_crm.leads where id=(payload->>'id')::uuid and handoff_hash=payload->>'hash' for update;
  if not found then raise sqlstate '42501' using message='Encaminhamento inválido';end if;
  update harmos_crm.leads set opened_at=stamp,handoff_draft=payload->>'draft',updated_at=stamp where id=lead.id;
  insert into harmos_crm.events(lead_id,actor,event,detail) values(lead.id,'visitante','Encaminhamento aberto','Envio no WhatsApp não comprovado');return jsonb_build_object('ok',true);
 elsif action in ('list','export') then
  return coalesce((select jsonb_agg(row) from (select to_jsonb(l)-'handoff_hash'-'client_id' as row from harmos_crm.leads l order by created_at desc limit case when action='export' then 10000 else 1000 end) x),'[]'::jsonb);
 elsif action='events' then
  return coalesce((select jsonb_agg(row) from (select to_jsonb(e) as row from harmos_crm.events e where lead_id=(payload->>'id')::uuid order by created_at desc limit 100)x),'[]'::jsonb);
 elsif action='update' then
  if not(payload->>'stage'=any(array['Novo','Em atendimento','Visita solicitada','Proposta','Matriculado','Encerrado'])) or length(coalesce(payload->>'owner',''))>100 or length(coalesce(payload->>'notes',''))>3000 or (payload->>'next_due'<>'' and not(payload->>'next_due'~'^\d{4}-\d{2}-\d{2}$')) then raise sqlstate '22023' using message='Confira os campos';end if;
  update harmos_crm.leads set stage=payload->>'stage',owner=payload->>'owner',notes=payload->>'notes',next_due=payload->>'next_due',updated_at=stamp where id=(payload->>'id')::uuid and updated_at=(payload->>'updated_at')::timestamptz;
  get diagnostics affected=row_count;if affected=0 then return jsonb_build_object('error','O registro mudou. Recarregue antes de editar.','status',409);end if;
  insert into harmos_crm.events(lead_id,actor,event,detail) values((payload->>'id')::uuid,actor,'Atualização da equipe','Etapa: '||(payload->>'stage'));return jsonb_build_object('ok',true);
 elsif action='delete' then
  delete from harmos_crm.leads where id=(payload->>'id')::uuid;
  insert into harmos_crm.events(actor,event,detail) values(actor,'Exclusão de solicitação',payload->>'id');return jsonb_build_object('ok',true);
 elsif action='knowledge_save' then
  if not(payload->>'id'=any(allowed_topics)) or length(payload->>'text') not between 10 and 2000 then raise sqlstate '22023' using message='Conteúdo inválido';end if;
  if (payload->>'revision')::int=0 then
   insert into harmos_crm.knowledge(id,body) values(payload->>'id',jsonb_build_object('text',payload->>'text')) on conflict(id) do nothing;
  else
   update harmos_crm.knowledge set body=jsonb_build_object('text',payload->>'text'),revision=revision+1,updated_at=stamp where id=payload->>'id' and revision=(payload->>'revision')::int;
  end if;
  get diagnostics affected=row_count;if affected=0 then return jsonb_build_object('error','O conteúdo mudou. Recarregue antes de editar.','status',409);end if;
  insert into harmos_crm.events(actor,event,detail) values(actor,'Conteúdo atualizado',payload->>'id');return jsonb_build_object('ok',true);
 end if;
 raise sqlstate '22023' using message='Ação inválida';
end;$$;
revoke all on function public.harmos_conecta_api(text,jsonb,text) from public;
grant execute on function public.harmos_conecta_api(text,jsonb,text) to anon,authenticated;
