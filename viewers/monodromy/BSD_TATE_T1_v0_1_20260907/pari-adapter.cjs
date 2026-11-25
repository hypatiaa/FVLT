'use strict';
const fs=require('node:fs'),path=require('node:path'),{spawnSync}=require('node:child_process'),assert=require('node:assert/strict');
const C=require('./t1.cjs');
const runtimeFiles={
 'gp-sta.js':{url:'https://pari.math.u-bordeaux.fr/gpjswasm/gp-sta.js',sha256:'4033ab9d300a51944d372033c14d7b910f24e6d91d38ede61a7d6fe5aaad0c69'},
 'gp-sta.wasm':{url:'https://pari.math.u-bordeaux.fr/gpjswasm/gp-sta.wasm',sha256:'b95fcd8239209d076b2b26f508b1fc2bba627c5660d8fda4447e199a5b1b12ba'}
};
function runtime(env=process.env){const dir=path.resolve(env.BSD_T1_PARI_DIR||path.join(__dirname,'../.bsd-arithmetic-runtime'));for(const [name,pin]of Object.entries(runtimeFiles))assert.equal(C.shaFile(path.join(dir,name)),pin.sha256,'PARI pin mismatch: '+name);return {dir,node:process.execPath,nodeSha256:C.shaFile(process.execPath),files:runtimeFiles};}
// Parse only nested vectors, canonical integers/rationals and short quoted version strings. Never eval GP output.
function parse(text){let i=0,nodes=0;function ws(){while(/\s/.test(text[i]||'!'))i++;}function item(depth=0){if(depth>8||++nodes>200)throw Error('GP output work cap');ws();if(text[i]==='['){i++;const a=[];ws();if(text[i]!==']'){while(true){a.push(item(depth+1));ws();if(text[i]!==',')break;i++;}}if(text[i++]!==']')throw Error('GP vector syntax');return a;}if(text[i]==='"'){const m=/^"([a-zA-Z0-9.-]{1,40})"/.exec(text.slice(i));if(!m)throw Error('GP string syntax');i+=m[0].length;return m[1];}const m=/^(?:0|-?[1-9][0-9]*)(?:\/[1-9][0-9]*)?/.exec(text.slice(i));if(!m)throw Error('GP scalar syntax');i+=m[0].length;C.R(m[0]);return m[0];}const out=item();ws();if(i!==text.length)throw Error('Trailing GP syntax');return out;}
function script(ainvs,p){ainvs.forEach(C.R);if(ainvs.length!==5||ainvs.some(x=>C.R(x)[1]!==1n))throw Error('PARI input must have five integral coefficients');C.primeProof(p);return `E=ellinit([${ainvs.join(',')}]);G=ellminimalmodel(E,&V);L=elllocalred(G,${p});H=ellchangecurve(G,L[3]);print("T1_VERSION|",version());print("T1_GLOBAL|",vector(5,i,G[i]));print("T1_URST|",V);print("T1_LOCAL|",L);print("T1_TARGET|",vector(5,i,H[i]));quit\n`;}
function decode(stdout){const out={};for(const line of stdout.split(/\r?\n/)){const hit=/^(?:\? )?T1_(VERSION|GLOBAL|URST|LOCAL|TARGET)\|(.*)$/.exec(line.trim());if(hit){if(out[hit[1]])throw Error('Duplicate producer field');out[hit[1]]=parse(hit[2]);}else if(line.trim()&&line.trim()!=='?')throw Error('Unexpected GP output');}assert.deepEqual(Object.keys(out).sort(),['GLOBAL','LOCAL','TARGET','URST','VERSION']);return out;}
function urst(a){if(!Array.isArray(a)||a.length!==4||a.some(s=>typeof s!=='string'))throw Error('Invalid backend tuple');return Object.fromEntries(['u','r','s','t'].map((k,i)=>[k,a[i]]));}
function produce(parent,p){const from=parent.models.find(m=>m.modelId===parent.normalization.targetModelId),clear=C.clearing(from.ainvs),a=C.transform(from.ainvs,clear),rt=runtime(),input=script(a,p);
 const run=spawnSync(process.execPath,[path.join(rt.dir,'gp-sta.js'),'-q','-f'],{input,encoding:'utf8',timeout:20000,maxBuffer:200000,windowsHide:true,env:{...process.env}});
 if(run.status!==0||run.error||run.stderr.trim())throw Error('PARI unavailable/failed: '+(run.error?.message||run.stderr||run.status));
 const parsed=decode(run.stdout);assert.deepEqual(parsed.VERSION,['2','17','4','29757','f24e5d7cc5']);
 const report={schema:'BSD_T1_PARI_REPORT_V1',status:'SOURCE_REPORT',producer:{name:'PARI_GP_WASM',version:parsed.VERSION,adapterSha256:C.shaFile(__filename),nodeVersion:process.version,nodeSha256:rt.nodeSha256,runtimeFiles},request:{ainvs:a,p,script:input,scriptSha256:C.hash(input)},stdout:run.stdout,stdoutSha256:C.hash(run.stdout),stderr:run.stderr,stderrSha256:C.hash(run.stderr),claims:parsed};
 const steps=[clear,urst(parsed.URST),urst(parsed.LOCAL[2])];return {report,steps};}
function verifyReport(report,parent,steps,trace){
 assert.equal(report.status,'SOURCE_REPORT');assert.equal(report.producer.adapterSha256,C.shaFile(__filename));assert.equal(report.producer.name,'PARI_GP_WASM');assert.deepEqual(report.producer.runtimeFiles,runtimeFiles);assert.deepEqual(report.producer.version,['2','17','4','29757','f24e5d7cc5']);
 assert.equal(C.hash(report.stdout),report.stdoutSha256);assert.equal(C.hash(report.stderr),report.stderrSha256);assert.equal(report.stderr,'');assert.deepEqual(decode(report.stdout),report.claims);assert.deepEqual(report.claims.VERSION,report.producer.version);
 const from=parent.models.find(m=>m.modelId===parent.normalization.targetModelId),clear=C.clearing(from.ainvs),a=C.transform(from.ainvs,clear),input=script(a,trace.p);assert.deepEqual(report.request,{ainvs:a,p:trace.p,script:input,scriptSha256:C.hash(input)});
 const c=report.claims;assert.deepEqual(steps,[clear,urst(c.URST),urst(c.LOCAL[2])]);assert.deepEqual(C.transform(a,steps[1]),c.GLOBAL);assert.deepEqual(C.transform(c.GLOBAL,steps[2]),c.TARGET);assert.deepEqual(c.TARGET,trace.ainvs);
 if(trace.terminal.status==='REPLAYABLE'){
  const r=trace.terminal.result,kod=r.kodaira==='I0'?'1':String(4+Number(r.discriminantValuation));assert.equal(c.LOCAL[0],r.conductorExponent);assert.equal(c.LOCAL[1],kod);assert.equal(c.LOCAL[3],r.tamagawaNumber);
 }
 // Retain every v0.3 cheap gate, even for branches T1 cannot certify.
 const child=C.transport(parent,steps).record,q=structuredClone(child),m=q.models.find(m=>m.modelId===trace.modelId),kod=Number(c.LOCAL[1]),f=Number(c.LOCAL[0]);
 let result;
 if(kod===1){const counted=C.count(m.ainvs,Number(trace.p));result={reduction:'GOOD',kodaira:'I0',split:null,discriminantValuation:'0',conductorExponent:'0',wildConductorContribution:'0',tamagawaNumber:c.LOCAL[3],eulerPolynomial:['1',String(-BigInt(counted.ap)),trace.p]};}
 else if(kod>=5){const ap=C.count(m.ainvs,Number(trace.p)).ap;if(!['1','-1'].includes(ap))throw Error('Invalid multiplicative fibre count');const split=ap==='1';result={reduction:split?'SPLIT_MULTIPLICATIVE':'NONSPLIT_MULTIPLICATIVE',kodaira:'I'+(kod-4),split,discriminantValuation:trace.valuations.discriminant.exponent,conductorExponent:c.LOCAL[0],wildConductorContribution:'0',tamagawaNumber:c.LOCAL[3],eulerPolynomial:['1',split?'-1':'1']};}
 else {const label=({2:'II',3:'III',4:'IV','-1':'I0*','-2':'II*','-3':'III*','-4':'IV*'})[kod]||(kod<=-5?'I'+(-kod-4)+'*':null);if(!label)throw Error('Invalid PARI Kodaira code');result={reduction:'ADDITIVE',kodaira:label,split:null,discriminantValuation:trace.valuations.discriminant.exponent,conductorExponent:c.LOCAL[0],wildConductorContribution:String(f-2),tamagawaNumber:c.LOCAL[3],eulerPolynomial:['1']};}
 const bytes=C.canonical(report),sha256=C.hash(bytes);q.sources.push({sha256,mediaType:'application/json',bytes});const evidence={status:'UNVERIFIED',method:'PARI_ELLLOCALRED_SOURCE_REPORT',software:'PARI GP WASM 2.17.4 f24e5d7cc5',sourceHash:sha256,assumptions:[],dependencies:[],certificate:null};
 q.localData=[{p:trace.p,modelId:trace.modelId,minimalityEvidence:result.reduction==='GOOD'?null:evidence,result,evidence}];C.verifyTransport(q);
 // Source hashes identify bytes, not authorship. Local certification comes only from trace replay.
 return {status:'PASS',globalMinimality:'SOURCE_REPORTED_NOT_CERTIFIED'};
}
module.exports={runtimeFiles,runtime,parse,script,decode,urst,produce,verifyReport};
