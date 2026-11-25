'use strict';
// v0.4.18 (SCHEMA_ADDENDUM_25) no-float-v0418: the static scan of every file added in v0.4.18 (saphir: "No floating point"), with the rules of
// build/no-float-elliptic.cjs (v0.4.17), reused unchanged: the whole text of each file (code, strings and comments) is scanned; banned are the Math object,
// parseFloat / parseInt, toFixed / toPrecision / toExponential, Float32Array / Float64Array, performance.now, decimal and exponent literals, the Number
// namespace, and Number(...) calls outside the allowlist below. Decimal strings in the tests are built from integer strings, so the scan stays strict.
// Allowlisted (exact line text, per file):
//   panel-pens.js: the canvas pixel helper px (BigInt -> Number, checked on the same line);
//   transcription-skeleton-pens.cjs: the skeleton's spherePen line with map(Math.round), kept verbatim (the transcription is test-only; it rounds integers).
// Not decidable lexically, and checked by reading (stated in the report): "/" on Number operands. This file itself is excluded (it spells the banned tokens).
const fs=require('fs'),path=require('path');
const root=path.join(__dirname,'..');
const NF=require('./no-float-elliptic.cjs');
const FILES=['host-core/pen-interval-core.js','host-core/field-q2-q5-tau.js','host-core/pen-streams-core.js','host-core/pen-curvature-core.js','host-core/pen-sphere-core.js',
  'instruments/comb-hopf/panel-pens.js','host-core/transcription-skeleton-pens.cjs','host-core/test-pen-streams.cjs','host-core/test-pen-fields.cjs','host-core/test-pen-curvature.cjs',
  'host-core/test-pen-sphere.cjs','host-core/test-v0418-fixups.cjs','build/browser-check-v0418.cjs','build/shots-v0418.cjs','build/browser-check-legacy-panels-v0418.cjs',
  'build/check-expected-fails-v0418.cjs'];
const ALLOW={'instruments/comb-hopf/panel-pens.js':["const px=b=>{if(typeof b!=='bigint')throw Error('px needs a BigInt');return Number(b);};"]};
const ALLOW_MATH={'host-core/transcription-skeleton-pens.cjs':["x=nx.map(Math.round); v=nv.map(Math.round);               // octahedron vertices are exact unit vectors"]};
function scan(){
  const out=[];
  for(const rel of FILES){
    const f=path.join(root,rel);if(!fs.existsSync(f)){out.push({file:rel,missing:true,hits:[]});continue;}
    const lines=fs.readFileSync(f,'utf8').split(/\r?\n/),hits=[],allowed=[];
    lines.forEach((l,i)=>{
      const mathOk=(ALLOW_MATH[rel]||[]).some(a=>l.trim()===a);
      for(const [name,re] of NF.RULES){if(name==='Math object'&&mathOk){allowed.push(i+1);continue;}if(re.test(l))hits.push({line:i+1,rule:name,text:l.trim().slice(0,160)});}
      const n=(l.match(/\bNumber\s*\(/g)||[]).length;
      if(n){const ok=(ALLOW[rel]||[]).some(a=>l.trim()===a)&&n===1;if(ok)allowed.push(i+1);else hits.push({line:i+1,rule:'Number(...) outside the allowlist',text:l.trim().slice(0,160)});}
    });
    out.push({file:rel,missing:false,hits,allowed});
  }
  return out;
}
module.exports={scan,FILES,ALLOW,ALLOW_MATH};
if(require.main===module){
  let pass=0,fail=0;
  for(const r of scan()){
    if(r.missing){console.log('FAIL '+r.file+': missing');fail++;continue;}
    const ok=r.hits.length===0;console.log((ok?'PASS ':'FAIL ')+r.file+': '+(ok?'no banned token':r.hits.length+' banned token(s)')+(r.allowed.length?' (allowlisted at line '+r.allowed.join(', ')+')':''));
    for(const h of r.hits)console.log('     line '+h.line+' ['+h.rule+'] '+h.text);
    ok?pass++:fail++;}
  console.log('SUMMARY no-float-v0418: '+pass+' passed, '+fail+' failed');
  process.exit(fail?1:0);
}
