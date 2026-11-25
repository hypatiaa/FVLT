'use strict';
// v0.4.14 core test (SCHEMA_ADDENDUM_22): the Goldbach prime-pair mask. Node only. The reference code below is independent of goldbach-core (own sieve, own direct G_N sum).
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const root=path.join(__dirname,'..'),BASE='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/';
const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),O=require('../host-core/orbit-core.js'),GB=require('../host-core/goldbach-core.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
const C0=require(BASE+'host-core/comb-core.js'),NUM0=require(BASE+'host-core/comb-numeric.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
// ---- independent reference: sieve, pair list, direct G_N
const LIM=1500,comp=new Uint8Array(LIM+1);comp[0]=comp[1]=1;for(let i=2;i*i<=LIM;i++)if(!comp[i])for(let j=i*i;j<=LIM;j+=i)comp[j]=1;
const pr=n=>n>=2&&!comp[n];
const refPairs=N=>{const o=[];for(let p=2;p<=N/2;p++)if(pr(p)&&pr(N-p))o.push(p);return o;};
function G(N,s){let re=0,im=0;for(const p of refPairs(N))for(const e of [p,N-p]){const t=2*Math.PI*e*s/N;re+=Math.cos(t);im+=Math.sin(t);}return {re,im};}
const sval=s=>{const q=X.parse(s);return Number(q.n)/Number(q.d);};
const stFor=(N,s,extra)=>C.initial({...GB.patchFor(N),sTyped:s,sEff:s,...(extra||{})});
const S_LIST=['0','1','2','3','1/2','3/2','1/3','4/3','7/5','3/7','5/2','-2/3','11/13','17/4','101/7','15/4'];
// 1. pair list and g(N): viewer core against independent trial division, every even N up to 1,448
{let bad=0,reach=0,maxm=0;for(let N=4;N<=1448;N+=2){const a=GB.pairsOf(N).map(r=>r.p),b=refPairs(N);if(JSON.stringify(a)!==JSON.stringify(b))bad++;const S=GB.settings(N);maxm=Math.max(maxm,S.m);if(S.m<=720)reach++;if(GB.model(N).g!==b.length)bad++;}
  ok('g(N) and the pair list match independent trial division for all 723 even N = 4…1448 ('+bad+' mismatches)',bad===0);
  ok('every even N = 4…1448 needs m <= 720 (max m = '+maxm+', reach '+reach+'/723); N = 1450 is refused',reach===723&&maxm<=720&&(()=>{try{GB.settings(1450);return false;}catch(e){return true;}})());}
// 2. mask weights: sum of weights = 2g(N) exactly (so the pen at s = 0 is G_N(0) = 2g(N)); conventions; coverage
{let bad=0,badConv=0,badCover=0;for(let N=4;N<=1448;N+=2){const M=GB.model(N),g=refPairs(N).length,sw=M.w.reduce((a,b)=>a+b,0);if(sw!==2*g)bad++;
    const n=N/2,S=GB.settings(N);const want=n%2?2:1;if(S.t2!==want)badConv++;
    // parity: N/2 odd -> odd m; N/2 even -> even m unless the equal pair is the only candidate (m = 3)
    if(n%2===1&&S.m%2!==1)badConv++;if(n%2===0&&S.amax>0&&S.m%2!==0)badConv++;
    const offs=new Set(C.offsets(S.m).map(Number));for(const p of refPairs(N)){const a=n-p;if(!offs.has(a/S.t2)||!offs.has(-a/S.t2))badCover++;}
    // the unmasked comb is exactly the odd candidate pairs (e, N - e), e odd, up to N/2, from min P_N (plus the equal pair)
  }
  ok('sum of mask weights = 2g(N) for every even N <= 1448 (G_N(0) = 2g(N), exact integers) ('+bad+' bad)',bad===0);
  ok('convention B: t2 = 2 iff N/2 odd, parity of m follows N/2, N = 4 uses m = 3 ('+badConv+' bad); every +-a_p is in comb(m) ('+badCover+' bad)',badConv===0&&badCover===0&&GB.settings(4).m===3&&GB.settings(4).t2===1);}
{let bad=0;for(const N of [30,34,50,90,150,210]){const S=GB.settings(N),n=N/2;if(n%2===0)continue;for(const c of C.offsets(S.m).map(Number)){const e=n+c*S.t2;if(e%2===0)bad++;}}
  ok('N/2 odd: the unmasked comb t2 = 2 consists only of odd candidate pairs (e, N - e) (convention B)',bad===0);}
// 3. identity through the viewer's own numerical core: pen = G_N(s), N = 4…200, 16 rational s, both N/2 parities
{let max=0,states=0,gate=0,gb0=0,maxPar=[0,0],bad=0;
  for(let N=4;N<=200;N+=2){const M=GB.model(N);
    for(const s of S_LIST){const st=stFor(N,s),num=NUM.compute(st,{mask:M.w});if(num.refused||num.empty){bad++;continue;}if(!C.gate(st))gate++;if(!GB.match(st).ok)bad++;
      const e=num.W[num.W.length-1],g=G(N,sval(s)),d=Math.hypot(e.re-g.re,e.im-g.im);max=Math.max(max,d);maxPar[(N/2)%2]=Math.max(maxPar[(N/2)%2],d);states++;
      if(d>1e-12)bad++;
      if(s==='0'&&Math.abs(e.re-2*refPairs(N).length)>1e-12)gb0++;}}
  ok('pen = G_N(s) through the built core: N = 4…200 (even), 16 s values, '+states+' states: max |diff| = '+max.toExponential(2)+' (N/2 even '+maxPar[0].toExponential(1)+', N/2 odd '+maxPar[1].toExponential(1)+') <= 1e-12',bad===0&&max<1e-12,'bad '+bad);
  ok('R21 gate open in all '+states+' states; W(0) = 2g(N) in every N',gate===0&&gb0===0);}
{let max=0,n=0;for(const N of [210,220,300,420,720,722,1000,1080,1442,1448])for(const s of ['0','1','1/2','3/7','-2/3','4/3']){const M=GB.model(N),st=stFor(N,s),num=NUM.compute(st,{mask:M.w}),e=num.W[num.W.length-1],g=G(N,sval(s));max=Math.max(max,Math.hypot(e.re-g.re,e.im-g.im));n++;}
  ok('pen = G_N(s) at large N (210 … 1448), '+n+' states: max |diff| = '+max.toExponential(2),max<1e-11);}
// 4. R_N(s) real: G_N e^{-i pi s} = 2 sum cos(2 pi a_p s / N), pen on the carrier page (arg = pi s or pi s + pi)
{let maxIm=0,maxR=0,page=0,n=0;for(let N=4;N<=200;N+=2){const M=GB.model(N);for(const s of S_LIST){const st=stFor(N,s),num=NUM.compute(st,{mask:M.w}),e=num.W[num.W.length-1],sf=sval(s),th=Math.PI*sf;
      const re=e.re*Math.cos(th)+e.im*Math.sin(th),im=e.im*Math.cos(th)-e.re*Math.sin(th);let R=0;for(const p of refPairs(N))R+=2*Math.cos(2*Math.PI*(N/2-p)*sf/N);
      maxIm=Math.max(maxIm,Math.abs(im));maxR=Math.max(maxR,Math.abs(re-R));n++;}}
  ok('R_N(s) real: max |Im(W e^{-i pi s})| = '+maxIm.toExponential(1)+', max |Re - 2 sum cos(2 pi a_p s/N)| = '+maxR.toExponential(1)+' ('+n+' states)',maxIm<1e-12&&maxR<1e-12);}
// 5. fixture N = 24, s = 4/3: the pen is below the viewer bound; the unmasked comb is not
{const M=GB.model(24),st=stFor(24,'4/3'),a=NUM.compute(st,{mask:M.w}),b=NUM.compute(st),ea=a.W[a.W.length-1],eb=b.W[b.W.length-1];
  ok('fixture N = 24, s = 4/3: |pen| = '+Math.hypot(ea.re,ea.im).toExponential(2)+' <= viewer bound '+a.bound.toExponential(2)+'; the unmasked comb has |W| = '+Math.hypot(eb.re,eb.im).toFixed(3),Math.hypot(ea.re,ea.im)<=a.bound&&Math.hypot(eb.re,eb.im)>0.5);}
// 6. ghosted teeth are not in the pen
{let bad=0;for(const N of [24,30,60,100,210]){const M=GB.model(N),st=stFor(N,'7/5'),num=NUM.compute(st,{mask:M.w});let re=0,im=0;M.teeth.forEach((t,i)=>{if(t.kept){re+=t.w*num.z[i].re;im+=t.w*num.z[i].im;}});
    const e=num.W[num.W.length-1];if(Math.hypot(e.re-re,e.im-im)>1e-12)bad++;
    // removing a ghost tooth's weight is not an option: its weight is 0, so zeroing it changes nothing; making it 1 does
    const w2=M.w.slice();const gi=M.teeth.findIndex(t=>!t.kept);if(gi>=0){w2[gi]=1;const n2=NUM.compute(st,{mask:w2}),e2=n2.W[n2.W.length-1];if(Math.hypot(e2.re-e.re,e2.im-e.im)<1e-9)bad++;}
    if(M.removed!==M.m-M.kept)bad++;for(const t of M.teeth)if((t.w===0)!==(!t.kept))bad++;}
  ok('ghosted teeth (weight 0) do not enter the pen: the pen is the sum over kept teeth only; giving a ghost weight changes it',bad===0);}
// 7. branches of the masked teeth, N <= 200: raw (N/2, -+a_p), k = p / q, x1, unknot iff a_p <= 1, torus knot T(min, max), mirror enantiomorphs, equal pair x(N/2)
{let rows=0,bad=0,twins=[],knots=0;const gcd=(a,b)=>{a=Math.abs(a);b=Math.abs(b);while(b)[a,b]=[b,a%b];return a;};
  for(let N=4;N<=200;N+=2){const S=GB.settings(N),st=stFor(N,'1'),bs=O.branches(st);
    for(const r of S.P)for(const sg of (r.a===0?[1]:[1,-1])){const c=sg*r.a/S.t2,b=bs.find(x=>Number(x.c)===c);rows++;
      const raw=b.clearedRate.map(Number),k=Number(b.k.n),mult=Number(b.commonFactor);let good=raw[0]===N/2&&raw[1]===-sg*r.a&&b.k.d===1n&&k===(sg>0?r.q:r.p);
      if(r.a===0)good=good&&mult===N/2&&b.knotClass==='UNKNOT'&&b.primitive.map(Number).join()==='1,0';
      else{good=good&&mult===1&&gcd(N/2,r.a)===1;const unknot=r.a<=1;good=good&&(b.knotClass==='UNKNOT')===unknot;
        if(!unknot){const lo=Math.min(r.a,N/2),hi=Math.max(r.a,N/2);good=good&&b.canonicalType==='T('+lo+','+hi+')'+(sg>0?'−':'+');knots++;}
        else if(sg>0)twins.push(N);}
      if(!good){bad++;console.log('  bad',N,c,O.chipText(b));}}}
  ok('masked branches N <= 200 ('+rows+' rows): raw (N/2, ∓a_p), k = p / N−p, ×1 (equal pair ×N/2), unknot iff a_p <= 1, T(min,max) otherwise with mirror signs ('+knots+' torus-knot rows) ('+bad+' bad)',bad===0&&rows===1135);
  ok('twin-pair unknots for N <= 200 are N = 8, 12, 24, 36, 60, 84, 120, 144 (a_p = 1)',JSON.stringify(twins)==='[8,12,24,36,60,84,120,144]',JSON.stringify(twins));}
// 8. exact register: tooth phases of the kept teeth equal 2 e s / N mod 2 as exact rationals
{let bad=0;for(const N of [24,30,60,102,210]){const S=GB.settings(N),M=GB.model(N);for(const s of ['4/3','7/5','-2/3','3/7']){const st=stFor(N,s),T=C.teeth(st);M.teeth.forEach((t,i)=>{if(!t.kept)return;const e=S.n+t.c*S.t2,ref=C.phaseRep(X.div(X.mul(X.rat(BigInt(2*e)),X.parse(s)),X.rat(BigInt(N))));if(!X.eq(T[i].phase,ref)||BigInt(e)!==BigInt(T[i].k.n))bad++;});}}
  ok('exact phases of kept teeth = 2es/N mod 2 and k_c = e (= p or N − p) as exact rationals',bad===0);}
// 9. empty-fibre code path (injected empty mask; not a reachable state for N <= 1,444)
{const M=GB.model(24,{pairs:[]}),st=C.initial({shellMode:'integer',B:String(11),nMode:'integer',phi3:'0',m:String(M.m),t1:'1',t2:String(M.t2),n6:'1',alpha:'0',sTyped:'4/3',sEff:'4/3'}),num=NUM.compute(st,{mask:M.w});
  ok('empty fibre (injected): g = 0, emptyFiber flag, every weight 0, the pen is exactly 0 at every vertex',M.g===0&&M.emptyFiber&&M.w.every(w=>w===0)&&num.W.every(w=>w.re===0&&w.im===0)&&num.endpoint.abs===0);
  ok('empty fibre guard text is the kernel wording ("makes no Goldbach-coverage claim"), and no even N in 4…1444 has an empty fibre (finite computation, not a claim)',/G_N≡0.*no Goldbach-coverage claim/.test(GB.GUARDS.empty)&&(()=>{for(let N=4;N<=1444;N+=2)if(!refPairs(N).length)return false;return true;})());}
// 10. tilt refusal and track matching
{const st=stFor(24,'1',{tilt:'1/2'}),mt=GB.match(st),num=NUM.compute(st,{mask:GB.model(24).w});
  ok('tilt: core refuses the mask with alpha_Tilt != 0 (compute refuses with a reason; match says tilt)',!!num.refused&&/α_Tilt/.test(num.refused)&&mt.ok===false&&mt.tilt===true);}
{let bad=0;for(let N=4;N<=1448;N+=2){const st=stFor(N,'1');const r=GB.match(st);if(!r.ok||r.N!==N)bad++;}
  const off=[C.initial({...GB.patchFor(24),m:'9'}),C.initial({...GB.patchFor(24),t2:'2'}),C.initial({...GB.patchFor(24),alpha:'1'}),C.initial({...GB.patchFor(24),n6:'2'}),C.initial({...GB.patchFor(24),phi3:'1'}),C.initial({...GB.patchFor(24),nMode:'continuous'}),C.initial({...GB.patchFor(24),shellMode:'factorial'}),C.initial({...GB.patchFor(24),B:'1448'})];
  ok('match: every even N = 4…1448 round-trips through patchFor/initial; 8 off-preset states are not matched ('+off.map(s=>GB.match(s).ok?'X':'-').join('')+')',bad===0&&off.every(s=>!GB.match(s).ok));}
// 11. track off: v0.4.13 behaviour unchanged (compute with no mask, and with an empty opts object, equals the v0.4.13 core)
{const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2'},{shellMode:'factorial',n1:'6',phi3:'700',m:'7',alpha:'1/2'},{shellMode:'integer',B:'5040',phi3:'5000',m:'7',t1:'1/2'},{shellMode:'factorial',n1:'5',phi3:'3',m:'9',n6:'2',alpha:'-1'}];
  let same=0,n=0;for(const o of S)for(const tilt of [undefined,'-1/2','1']){const st=C.initial({...o,sTyped:'7/5',sEff:'7/5'});if(tilt)st.tilt=tilt;const a=JSON.stringify(NUM.compute(st),(k,v)=>typeof v==='bigint'?String(v):v),b=JSON.stringify(NUM.compute(st,{}),(k,v)=>typeof v==='bigint'?String(v):v),c0=JSON.stringify(NUM0.compute(st),(k,v)=>typeof v==='bigint'?String(v):v);n++;if(a===b&&a===c0)same++;}
  ok('track off: comb-numeric compute equals the v0.4.13 core byte for byte ('+same+'/'+n+' states, tilt 0, -1/2, 1)',same===n);
  ok('comb-core.js, orbit-core.js, fraction-stack-core.js, stack-core.js, gearbox-core.js, shell-core.js, ca-core.js, exact-lib unchanged against v0.4.13',['host-core/comb-core.js','host-core/orbit-core.js','host-core/fraction-stack-core.js','host-core/stack-core.js','host-core/gearbox-core.js','host-core/shell-core.js','host-core/ca-core.js','host-core/branch-disk-core.js','host-core/rhm-core.js','exact-lib/exact-lib-0.2.0.js','instruments/comb-hopf/panel-g-robin.js','instruments/comb-hopf/panel-bd.js','instruments/comb-hopf/views-common.js','instruments/comb-hopf/view-panels.js'].every(f=>sha(path.join(root,f))===sha(BASE+f)));
  const changed=['host-core/comb-numeric.js','instruments/comb-hopf/panel.js','instruments/comb-hopf/view-fourier.js','instruments/comb-hopf/view-clifford.js','instruments/comb-hopf/view-hopf.js','instruments/comb-hopf/index.html'].filter(f=>sha(path.join(root,f))!==sha(BASE+f));
  ok('only the expected files differ from v0.4.13: '+changed.join(', ')+' (+ new host-core/goldbach-core.js)',changed.length===6);}
// 12. kernel guard wording
ok('guards printed verbatim from kernel v3.2.6: interference register, empty-fiber guard, "Closure reaches conjugation, not Goldbach."',/^Interference register\. “Constructive” and “destructive” interference mean only addition and cancellation of complex vectors in this finite sum\./.test(GB.GUARDS.interference)&&GB.GUARDS.closure==='Closure reaches conjugation, not Goldbach.'&&/^Empty-fiber guard\./.test(GB.GUARDS.empty));
console.log('SUMMARY test-v0414 '+pass+' passed, '+fail+' failed');
process.exit(fail?1:0);
