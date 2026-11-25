'use strict';
// v0.4.19 (SCHEMA_ADDENDUM_26) no-float-v0419: the static scan of every code file changed or added in the v0.4.19 fix round, with the rules of
// build/no-float-elliptic.cjs (v0.4.17), reused unchanged: the whole text of each file (code, strings and comments) is scanned; banned are the Math object,
// parseFloat / parseInt, toFixed / toPrecision / toExponential, Float32Array / Float64Array, performance.now, decimal and exponent literals, the Number
// namespace, and Number(...) calls outside the allowlist below.
// Allowlisted (exact line text, per file): panel-pens.js, the canvas pixel helper px (BigInt -> Number, checked on the same line; unchanged from v0.4.18).
// NOT scanned, by the brief (item 2): instruments/comb-hopf/view-clifford.js, the inherited D1 projection (floats at the canvas, permitted by the v0.4.16
// brief). Its v0.4.19 change only calls host-core/d1-event-pieces.js (scanned here) and maps the exact rationals with the inherited rlTurn/at; no new
// float code was added there (the report lists the inherited float sites). Also not scanned: instruments/comb-hopf/index.html (one added script tag;
// markup and CSS), build/package.cjs (its one change is the viewer version string; its version strings such as the exact-lib version trip the lexical
// decimal-literal rule, and it computes nothing), the Markdown and text files, and dist/ (generated). Not decidable lexically, and checked by reading (stated in the report): "/" on
// Number operands. This file itself is excluded (it spells the banned tokens).
const fs=require('fs'),path=require('path');
const root=path.join(__dirname,'..');
const NF=require('./no-float-elliptic.cjs');
const FILES=['host-core/pen-interval-core.js','host-core/pen-curvature-core.js','host-core/pen-sphere-core.js','host-core/d1-event-pieces.js',
  'instruments/comb-hopf/panel-pens.js',
  'host-core/test-v0419-goldbach-order.cjs','host-core/test-v0419-fixups.cjs','host-core/test-v0419-pens.cjs',
  'build/browser-check-d1-v0419.cjs','build/browser-check-v0419.cjs','build/shots-v0419.cjs','build/check-expected-fails-v0419.cjs',
  'build/selftest-expected-fails-v0419.cjs','build/make-expected-fails-v0419.cjs',
  'build/dump-a5-moves-v0419.cjs','build/sage-a5-v0419.sage','build/runall.sh'];
const ALLOW={'instruments/comb-hopf/panel-pens.js':["const px=b=>{if(typeof b!=='bigint')throw Error('px needs a BigInt');return Number(b);};"]};
function scan(){
  const out=[];
  for(const rel of FILES){
    const f=path.join(root,rel);if(!fs.existsSync(f)){out.push({file:rel,missing:true,hits:[]});continue;}
    const lines=fs.readFileSync(f,'utf8').split(/\r?\n/),hits=[],allowed=[];
    lines.forEach((l,i)=>{
      for(const [name,re] of NF.RULES)if(re.test(l))hits.push({line:i+1,rule:name,text:l.trim().slice(0,160)});
      const n=(l.match(/\bNumber\s*\(/g)||[]).length;
      if(n){const ok=(ALLOW[rel]||[]).some(a=>l.trim()===a)&&n===1;if(ok)allowed.push(i+1);else hits.push({line:i+1,rule:'Number(...) outside the allowlist',text:l.trim().slice(0,160)});}
    });
    out.push({file:rel,missing:false,hits,allowed});
  }
  return out;
}
module.exports={scan,FILES,ALLOW};
if(require.main===module){
  let pass=0,fail=0;
  for(const r of scan()){
    if(r.missing){console.log('FAIL '+r.file+': missing');fail++;continue;}
    const ok=r.hits.length===0;console.log((ok?'PASS ':'FAIL ')+r.file+': '+(ok?'no banned token':r.hits.length+' banned token(s)')+(r.allowed.length?' (allowlisted at line '+r.allowed.join(', ')+')':''));
    for(const h of r.hits)console.log('     line '+h.line+' ['+h.rule+'] '+h.text);
    ok?pass++:fail++;}
  console.log('SUMMARY no-float-v0419: '+pass+' passed, '+fail+' failed');
  process.exit(fail?1:0);
}
