alter function public.harmos_conecta_api(text,jsonb,text) set schema harmos_crm;
grant usage on schema harmos_crm to anon,authenticated;
grant execute on function harmos_crm.harmos_conecta_api(text,jsonb,text) to anon,authenticated;
create function public.harmos_conecta_api(action text,payload jsonb,api_secret text) returns jsonb language sql security invoker set search_path='' as $$ select harmos_crm.harmos_conecta_api(action,payload,api_secret) $$;
revoke all on function public.harmos_conecta_api(text,jsonb,text) from public;
grant execute on function public.harmos_conecta_api(text,jsonb,text) to anon,authenticated;
