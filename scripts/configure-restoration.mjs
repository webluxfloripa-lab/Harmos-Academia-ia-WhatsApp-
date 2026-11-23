// Executar somente pelo operador ao restaurar uma instalação nova.
import {randomBytes,createHash} from 'node:crypto';
import {writeFileSync,existsSync} from 'node:fs';
const url=process.env.NEW_SUPABASE_URL,key=process.env.NEW_SUPABASE_PUBLISHABLE_KEY,email=process.env.ADMIN_EMAIL;
if(!url||!key||!email||!/^https:\/\//.test(url)||!email.includes('@'))throw Error('Defina NEW_SUPABASE_URL, NEW_SUPABASE_PUBLISHABLE_KEY e ADMIN_EMAIL.');
if(existsSync('.env.local')||existsSync('bootstrap-private.local.sql'))throw Error('Arquivos de configuração já existem. Não serão sobrescritos.');
const secret=randomBytes(48).toString('hex'),hash=createHash('sha256').update(secret).digest('hex');
const quote=s=>"'"+s.replaceAll("'","''")+"'";
writeFileSync('.env.local',`SUPABASE_URL=${url}\nSUPABASE_ANON_KEY=${key}\nHARMOS_API_SECRET=${secret}\n`,{mode:0o600});
writeFileSync('bootstrap-private.local.sql',`insert into harmos_crm.settings(key,value) values('api_hash',${quote(hash)}) on conflict(key) do update set value=excluded.value;\ninsert into harmos_crm.admins(email) values(${quote(email.toLowerCase())}) on conflict do nothing;\n`,{mode:0o600});
console.log('Configuração privada gerada localmente. Execute bootstrap-private.local.sql no banco novo e configure as variáveis do servidor. Não publique esses arquivos.');
