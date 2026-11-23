import {createHash,randomUUID} from 'node:crypto';
import {TOPICS,validateLead,summary,csvCell} from '../crm/domain.mjs';
const hash=v=>createHash('sha256').update(v).digest('hex');
export async function handle(req,res,environment=process.env,remoteFetch=fetch){
 res.setHeader('Cache-Control','no-store');res.setHeader('X-Content-Type-Options','nosniff');
 const respond=(status,data)=>{res.statusCode=status;res.setHeader('Content-Type','application/json; charset=utf-8');res.end(JSON.stringify(data));};
 const route=String(req.query?.route||'').replace(/^\/+|\/+$/g,'');const method=req.method;
 const host=req.headers['x-forwarded-host']||req.headers.host;const origin=req.headers.origin;
 if(!['GET','HEAD'].includes(method)&&origin!==`https://${host}`&&origin!==`http://${host}`)return respond(403,{error:'Origem não autorizada.'});
 if(!environment.SUPABASE_URL||!environment.SUPABASE_ANON_KEY||!environment.HARMOS_API_SECRET)return respond(503,{error:'Configuração do atendimento indisponível. Continue pelo WhatsApp.'});
 let data=req.body||{};if(typeof data==='string'){if(data.length>12000)return respond(413,{error:'Mensagem muito longa.'});try{data=JSON.parse(data)}catch{return respond(400,{error:'Dados inválidos.'})}}if(JSON.stringify(data).length>12000)return respond(413,{error:'Mensagem muito longa.'});
 const auth=String(req.headers.authorization||'');
 async function rpc(action,payload={}){const response=await remoteFetch(environment.SUPABASE_URL+'/rest/v1/rpc/harmos_conecta_api',{method:'POST',headers:{apikey:environment.SUPABASE_ANON_KEY,'Content-Type':'application/json',...(auth?{Authorization:auth}:{})},body:JSON.stringify({action,payload,api_secret:environment.HARMOS_API_SECRET})});const result=await response.json();if(!response.ok){const status=['42501','28000','PGRST301','PGRST303'].includes(result.code)?403:result.code==='23505'?409:400;const error=new Error(status===403?'Acesso reservado à equipe autorizada.':'Não foi possível concluir. Confira os dados.');error.status=status;throw error}if(result?.error){const error=new Error(result.error);error.status=result.status||400;throw error}return result}
 try{
  if(route==='me'&&method==='GET')return respond(200,await rpc('me'));
  if(route==='knowledge'&&method==='GET'){const rows=await rpc('knowledge');const map=new Map(rows.map(r=>[r.id,r]));return respond(200,{topics:TOPICS.map(t=>map.has(t.id)?{...t,...map.get(t.id).body,revision:map.get(t.id).revision,updated_at:map.get(t.id).updated_at}:{...t,revision:0})})}
  if(route==='leads'&&method==='POST'){const d=validateLead(data);const id=randomUUID(),token=randomUUID()+randomUUID();const ip=String(req.headers['x-forwarded-for']||req.headers['x-real-ip']||'unknown').split(',')[0].trim();const result=await rpc('create',{...d,id,consent:true,summary:summary({...d,topic:d.topic},id),handoff_hash:hash(token),rate_key:hash(ip)+':'+Math.floor(Date.now()/3600000)});return respond(201,{...result,token})}
  const handoff=route.match(/^leads\/([a-f0-9-]{36})\/handoff$/);if(handoff&&method==='POST'){if(typeof data.token!=='string'||typeof data.draft!=='string')return respond(400,{error:'Resumo inválido.'});return respond(200,await rpc('handoff',{id:handoff[1],hash:hash(data.token),draft:data.draft}))}
  if(route==='admin/leads'&&method==='GET')return respond(200,{leads:await rpc('list'),limit:1000});
  const item=route.match(/^admin\/leads\/([a-f0-9-]{36})$/);if(item){if(method==='GET')return respond(200,{events:await rpc('events',{id:item[1]})});if(method==='PATCH')return respond(200,await rpc('update',{...data,id:item[1]}));if(method==='DELETE')return respond(200,await rpc('delete',{id:item[1]}))}
  if(route==='admin/knowledge'&&method==='PUT')return respond(200,await rpc('knowledge_save',data));
  if(route==='admin/export'&&method==='GET'){const rows=await rpc('export');const keys=['id','name','phone','topic','kind','stage','owner','next_due','source','created_at','opened_at'];res.statusCode=200;res.setHeader('Content-Type','text/csv; charset=utf-8');res.setHeader('Content-Disposition','attachment; filename="harmos-atendimentos.csv"');return res.end('\uFEFF'+[keys.map(csvCell).join(';'),...rows.map(r=>keys.map(k=>csvCell(r[k])).join(';'))].join('\r\n'))}
  return respond(404,{error:'Rota não encontrada.'});
 }catch(error){return respond(error.status||400,{error:error.message||'Não foi possível concluir.'})}
}
export default handle;
