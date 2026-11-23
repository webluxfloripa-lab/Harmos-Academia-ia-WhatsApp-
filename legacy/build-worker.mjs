import {readFileSync,writeFileSync,readdirSync,mkdirSync,rmSync} from 'node:fs';
import path from 'node:path';
const types={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.svg':'image/svg+xml','.webp':'image/webp','.woff2':'font/woff2','.webmanifest':'application/manifest+json'};
const assets={};function scan(dir){for(const entry of readdirSync(dir,{withFileTypes:true})){const p=path.join(dir,entry.name);if(entry.isDirectory())scan(p);else assets['/'+path.relative('dist',p).replaceAll('\\','/')]={type:types[path.extname(p)]||'application/octet-stream',data:readFileSync(p).toString('base64')}}}scan('dist');
mkdirSync('dist/server',{recursive:true});writeFileSync('dist/server/assets.mjs','export const assets='+JSON.stringify(assets)+';');
writeFileSync('dist/server/index.js',readFileSync('worker/index.mjs','utf8').replace("'./api.mjs'","'./api.mjs'"));
writeFileSync('dist/server/api.mjs',readFileSync('worker/api.mjs','utf8').replace("'../crm/domain.mjs'","'./domain.mjs'"));writeFileSync('dist/server/domain.mjs',readFileSync('crm/domain.mjs'));
mkdirSync('dist/.openai',{recursive:true});writeFileSync('dist/.openai/hosting.json',readFileSync('.openai/hosting.json'));console.log('Worker e arquivos estáticos preparados.');
