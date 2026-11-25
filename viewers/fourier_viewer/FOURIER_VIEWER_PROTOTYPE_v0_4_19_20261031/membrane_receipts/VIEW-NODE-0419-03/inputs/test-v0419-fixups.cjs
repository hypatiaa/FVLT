'use strict';
// v0.4.19 test-v0419-fixups (SCHEMA_ADDENDUM_26, item 7; verify finding 6 of v0.4.18): the successor of test-v0418-fixups, which checked a COPY of the
// reduction-label rule. Here the label rule is the real one: instruments/comb-hopf/panel-elliptic.js is read unchanged from disk and run in a Node vm
// context whose globals are the two exact cores (required from this folder) and a stub of FVViews (esc, registerPanel); the file then puts its own
// export, root.FVEllipticCards = {..., redLabel, redShort}, on that context, and the test calls those functions. panel-elliptic.js is not edited:
// it already exports redLabel on its root (the page's window), so no additive export was needed. The file's sha256 is printed.
// Test curves with additive reduction, as in v0.4.18: a_p = 0 by the naive count and by the character sum, the reduction type by the tangent cone (a cusp)
// and by p | c4 with p | Delta. No floating point.
const fs=require('fs'),path=require('path'),vm=require('vm'),crypto=require('crypto');
const EX=require('./elliptic-exact-core.js'),PE=require('./elliptic-period-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const FILE=path.join(__dirname,'..','instruments','comb-hopf','panel-elliptic.js'),src=fs.readFileSync(FILE,'utf8');
const registered=[];
const ctx={FVViews:{esc:s=>String(s),registerPanel:p=>registered.push(p.id)},FVEllipticExact:EX,FVEllipticPeriod:PE};
ctx.globalThis=ctx;vm.createContext(ctx);vm.runInContext(src,ctx,{filename:'panel-elliptic.js'});
const CARDS=ctx.FVEllipticCards;
ok('panel-elliptic.js (sha256 '+crypto.createHash('sha256').update(src).digest('hex')+') runs in a vm context and exports FVEllipticCards.redLabel and redShort (registered panels: '+registered.join(', ')+')',
  !!CARDS&&typeof CARDS.redLabel==='function'&&typeof CARDS.redShort==='function'&&registered.length===2);
const redLabel=CARDS.redLabel,redShort=CARDS.redShort;
ok('the real redLabel: additive → "additive", nonsplit → "nonsplit multiplicative", split → "split multiplicative", good → "good"; redShort: additive → "additive", split → "split mult."',
  redLabel({type:'additive'})==='additive'&&redLabel({type:'nonsplit'})==='nonsplit multiplicative'&&redLabel({type:'split'})==='split multiplicative'&&redLabel({type:'good'})==='good'&&redShort({type:'additive'})==='additive'&&redShort({type:'split'})==='split mult.',
  [redLabel({type:'additive'}),redLabel({type:'nonsplit'}),redLabel({type:'split'}),redLabel({type:'good'})].join('|'));
const qn=q=>q.num!==undefined?q:{num:q,den:1n};
for(const [name,A,p] of [['y² = x³ + 5',[0n,0n,0n,0n,5n],5n],['27a1: y² + y = x³ − 7',[0n,0n,1n,0n,-7n],3n],['y² = x³ + 5',[0n,0n,0n,0n,5n],7n],['37a1',[0n,0n,1n,-1n,0n],37n]]){
  const rt=EX.reductionType(A,p),i=EX.apNaive(A,p),ii=EX.apCharSum(A,p),C=EX.curveQ(A),c4=qn(C.c4),D=qn(C.disc);
  const pc4=c4.num%p===0n,pD=D.num%p===0n;
  if(pD&&pc4){
    ok(name+' at p = '+p+': reduction type by the tangent cone = '+rt.type+' ('+rt.label+')',rt.type==='additive'&&/cusp/.test(rt.label));
    ok(name+' at p = '+p+': a_p = 0 by route (i), naive count '+i.count+' = p + 1, and by route (ii), the character sum',i.ap===0n&&ii.ap===0n);
    ok(name+' at p = '+p+': the real redLabel of panel-elliptic.js gives "additive" (not "additive multiplicative")',redLabel(rt)==='additive',redLabel(rt));
  }else if(pD){
    ok(name+' at p = '+p+': multiplicative reduction ('+rt.type+'), the real redLabel gives "'+redLabel(rt)+'"',(rt.type==='split'||rt.type==='nonsplit')&&redLabel(rt)===rt.type+' multiplicative',rt.type);
  }else ok(name+' at p = '+p+': good reduction (p ∤ Δ), routes agree: a_p = '+i.ap+'; the real redLabel gives "good"',rt.type==='good'&&i.ap===ii.ap&&redLabel(rt)==='good');
}
console.log('SUMMARY test-v0419-fixups: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
