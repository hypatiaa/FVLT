// Fixed source registry; no network, filesystem or dynamic module names outside it.
const moduleCache={};
const Buffer={byteLength:s=>new TextEncoder().encode(s).length};
function resolveModule(name,from='/'){
 if(name.startsWith('node:'))return name;const parts=(name.startsWith('/')?name:from.slice(0,from.lastIndexOf('/')+1)+name).split('/'),out=[];for(const p of parts){if(p==='..')out.pop();else if(p&&p!=='.')out.push(p);}return '/'+out.join('/');
}
function requireModule(name,from='/'){
 const id=resolveModule(name,from),canon=x=>x===null||typeof x!=='object'?JSON.stringify(x):Array.isArray(x)?'['+x.map(canon).join(',')+']':'{'+Object.keys(x).sort().map(k=>JSON.stringify(k)+':'+canon(x[k])).join(',')+'}';
 if(id==='node:crypto')return {webcrypto:globalThis.crypto,createHash:alg=>{if(alg!=='sha256')throw Error('Hash algorithm');let data='';const h={update(x){data+=typeof x==='string'?x:new TextDecoder().decode(x);return h;},digest(format){if(format!=='hex')throw Error('Hash encoding');return sha256(data);}};return h;}};
 if(id==='node:fs')return {readFileSync:f=>{if(!(f in SOURCE))throw Error('No browser file access');return SOURCE[f];}};
 if(id==='node:path')return {};
 if(id==='node:assert/strict'){const a=(x,m)=>{if(!x)throw Error(m||'Generator assertion');};a.equal=(x,y,m)=>a(x===y,m);a.deepEqual=(x,y,m)=>a(canon(x)===canon(y),m);a.ok=a;return a;}
 if(moduleCache[id])return moduleCache[id].exports;if(!FACTORIES[id])throw Error('Module outside fixed generator registry: '+id);
 const module={exports:{}};moduleCache[id]=module;const req=n=>requireModule(n,id);req.resolve=n=>resolveModule(n,id);FACTORIES[id](req,module,module.exports,id,id.slice(0,id.lastIndexOf('/')));return module.exports;
}
