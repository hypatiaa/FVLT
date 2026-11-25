'use strict';
// v0.4.17 (SCHEMA_ADDENDUM_24) no-float-elliptic: a static scan of the files added for group D exact (saphir: "No floating point").
// The scan reads the whole text of each file (code, strings and comments alike) and fails on any banned token. Banned:
//   the Math object; parseFloat and parseInt; toFixed, toPrecision, toExponential; Float32Array and Float64Array; performance.now (a float clock);
//   decimal literals (digits with a point) and exponent literals; the Number namespace; Number(...) calls except the allowlisted ones below.
// Allowlisted Number(...) calls (exact text, per file): the canvas pixel helper, which converts a BigInt that the same line checks to be a BigInt.
// Not decidable by a lexical scan, and so checked by reading instead (stated in the report): "/" applied to Number operands.
// This file itself is excluded: it has to spell the banned tokens.
const fs=require('fs'),path=require('path');
const root=path.join(__dirname,'..');
const FILES=['host-core/elliptic-exact-core.js','host-core/elliptic-period-core.js','instruments/comb-hopf/panel-elliptic.js',
  'host-core/test-elliptic-exact.cjs','host-core/test-elliptic-period.cjs','build/transcribe-elliptic-fixture.cjs','build/browser-check-v0417.cjs','build/shots-v0417.cjs'];
const ALLOW={'instruments/comb-hopf/panel-elliptic.js':["const px=b=>{if(typeof b!=='bigint')throw Error('px needs a BigInt');return Number(b);};"]};
const RULES=[
  ['Math object',/\bMath\s*\./],
  ['parseFloat',/\bparseFloat\b/],['parseInt',/\bparseInt\b/],
  ['toFixed / toPrecision / toExponential',/\bto(Fixed|Precision|Exponential)\b/],
  ['Float32Array / Float64Array',/\bFloat(32|64)Array\b/],
  ['performance.now',/\bperformance\s*\.\s*now\b/],
  ['decimal literal',/(?<![\w.$\\])\d*\.\d+(?![\w])/],
  ['exponent literal',/(?<![\w.$\\])\d+(\.\d+)?[eE][+-]?\d+(?![\w])/],
  ['Number namespace',/\bNumber\s*\./],
];
function scan(){
  const out=[];
  for(const rel of FILES){
    const f=path.join(root,rel);if(!fs.existsSync(f)){out.push({file:rel,missing:true,hits:[]});continue;}
    const lines=fs.readFileSync(f,'utf8').split(/\r?\n/),hits=[],allowed=[];
    lines.forEach((l,i)=>{
      for(const [name,re] of RULES)if(re.test(l))hits.push({line:i+1,rule:name,text:l.trim().slice(0,160)});
      const n=(l.match(/\bNumber\s*\(/g)||[]).length;
      if(n){const ok=(ALLOW[rel]||[]).some(a=>l.trim()===a)&&n===1;if(ok)allowed.push(i+1);else hits.push({line:i+1,rule:'Number(...) outside the allowlist',text:l.trim().slice(0,160)});}
    });
    out.push({file:rel,missing:false,hits,allowed});
  }
  return out;
}
module.exports={scan,FILES,ALLOW,RULES};
if(require.main===module){
  let pass=0,fail=0;
  for(const r of scan()){
    if(r.missing){console.log('FAIL '+r.file+': missing');fail++;continue;}
    const ok=r.hits.length===0;console.log((ok?'PASS ':'FAIL ')+r.file+': '+(ok?'no banned token':r.hits.length+' banned token(s)')+(r.allowed.length?' (allowlisted Number(...) at line '+r.allowed.join(', ')+')':''));
    for(const h of r.hits)console.log('     line '+h.line+' ['+h.rule+'] '+h.text);
    ok?pass++:fail++;}
  console.log('SUMMARY no-float-elliptic: '+pass+' passed, '+fail+' failed');
  process.exit(fail?1:0);
}
