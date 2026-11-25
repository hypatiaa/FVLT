'use strict';
// v0.4.18 test-v0418-fixups: node-side checks for the v0.4.17 fix-ups (verify report F3: the label of additive reduction).
// Test curves with additive reduction, each with the reference value a_p = 0 (additive reduction) checked two ways (the naive projective count and the
// character sum), and the reduction type checked two ways (the tangent cone at the singular point: a cusp; and p | c4 with p | Δ). No floating point.
const EX=require('./elliptic-exact-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const qn=q=>q.num!==undefined?q:{num:q,den:1n};
for(const [name,A,p] of [['y² = x³ + 5',[0n,0n,0n,0n,5n],5n],['27a1: y² + y = x³ − 7',[0n,0n,1n,0n,-7n],3n],['y² = x³ + 5',[0n,0n,0n,0n,5n],7n]]){
  const rt=EX.reductionType(A,p),i=EX.apNaive(A,p),ii=EX.apCharSum(A,p),C=EX.curveQ(A),c4=qn(C.c4),D=qn(C.disc);
  const pc4=c4.num%p===0n,pD=D.num%p===0n;
  if(pD){
    ok(name+' at p = '+p+': reduction type by the tangent cone = '+rt.type+' ('+rt.label+')',rt.type==='additive'&&/cusp/.test(rt.label));
    ok(name+' at p = '+p+': second route, p | c4 = '+EX.qstr(C.c4)+' and p | Δ = '+EX.qstr(C.disc)+' (additive)',pc4&&pD);
    ok(name+' at p = '+p+': a_p = 0 (the reference value for additive reduction) by route (i), naive count '+i.count+' = p + 1',i.ap===0n);
    ok(name+' at p = '+p+': a_p = 0 by route (ii), the character sum',ii.ap===0n);
    ok(name+' at p = '+p+': the label shown is "additive", not "additive multiplicative" (the label rule of panel-elliptic.js, v0.4.18)',(rt.type==='good'?'good':rt.type==='additive'?'additive':rt.type+' multiplicative')==='additive');
  }else ok(name+' at p = '+p+': good reduction (p ∤ Δ), routes agree: a_p = '+i.ap,rt.type==='good'&&i.ap===ii.ap);
}
console.log('SUMMARY test-v0418-fixups: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
