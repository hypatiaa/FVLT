'use strict';
// v0.4.1 tests (SCHEMA_ADDENDUM_9): shell range n1 = 1..13 and B >= 1, the star keyed on t1*s in Z, the carrier foliation (display register), and
// byte-identical exact output for every previously valid state (compared with the v0.4 modules, read-only).
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js'),O=require('./orbit-core.js'),NUM=require('./comb-numeric.js'),SH=require('./shell-core.js'),FS=require('./fraction-stack-core.js');
const V4='../../FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/host-core/';
const C4=require(V4+'comb-core.js'),O4=require(V4+'orbit-core.js'),N4=require(V4+'comb-numeric.js'),FS4=require(V4+'fraction-stack-core.js');
let pass=0,fail=0;
const t=(name,fn)=>{let ok=false,extra='';try{const r=fn();ok=r===true||(r&&r.ok===true);if(r&&r.note)extra=' '+r.note;}catch(e){extra=' threw '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+extra);ok?pass++:fail++;};
const {rat,text}=X,TOL=1e-9;
// ---------------------------------------------------------------- 1. shell range
const small=[];   // every shell position on the four new / small shells, both N modes, a few dials
for(const sh of [{shellMode:'factorial',n1:'1'},{shellMode:'factorial',n1:'2'},{shellMode:'integer',B:'1'},{shellMode:'integer',B:'2'}]){
  const B=sh.shellMode==='factorial'?(sh.n1==='1'?1:2):Number(sh.B);
  const phis=[];for(let g=0;g<=B+1;g++)phis.push(['integer',String(g)]);for(let q=0;q<=4*(B+1);q++)phis.push(['continuous',text(rat(BigInt(q),4n))]);
  for(const [nMode,phi3] of phis)for(const m of ['2','3','4','5'])for(const [t1,t2] of [['1','1'],['1/2','1'],['0','1'],['1','0'],['2','-1/3']])for(const s of ['0','1','1/3'])
    small.push(C.enterSpin(C.initial({...sh,nMode,phi3,m,t1,t2,n6:'1',alpha:'1'}),s));
}
t('shell range: n₁ = 1 and n₁ = 2 resolve to B = 1! = 1 and B = 2! = 2; integer B = 1 resolves; n₁ = 0, n₁ = 14 and B = 0 are refused with the widened reasons ("1–13", "1–6,227,020,800")',()=>{
  const r=o=>{try{return C.resolve(C.initial(o));}catch(e){return e.message;}};
  const a=r({shellMode:'factorial',n1:'1',phi3:'0'}),b=r({shellMode:'factorial',n1:'2',phi3:'0'}),c=r({shellMode:'integer',B:'1',phi3:'0'});
  return a.B===1n&&a.N===2n&&b.B===2n&&b.N===3n&&c.B===1n&&c.N===2n&&r({shellMode:'factorial',n1:'0'})==='Factorial index n₁ must be 1–13.'&&r({shellMode:'factorial',n1:'14'})==='Factorial index n₁ must be 1–13.'&&r({shellMode:'integer',B:'0',phi3:'0'})==='Shell base must be 1–6,227,020,800.';});
t('shell range: on B = 1 and B = 2 (n₁ = 1, 2 and integer B = 1, 2), every shell position in both N modes (integer φ₃ and φ₃ ∈ ¼ℤ), m = 2..5, five gears, three spins: every exact readout, export, stop set, step, branch, gate, field, divisor report, fraction-stack caption, mirror and foliation record and the numerical model evaluate without an exception and without a NaN; N ≤ 0 is refused by orbit-core and comb-numeric',()=>{
  let bad=[],n=0,n0=0,between=0;
  for(const st of small){n++;try{
    const R=C.resolve(st),rd=C.readouts(st);if(!R.Nint)between++;
    C.teeth(st);C.stopSet(st);C.step(st,1);C.step(st,-1);C.divisorsOf(st);C.cyclotomic(st);C.cycloJson(st);JSON.parse(C.exportExact(st,null,{}));JSON.parse(C.exportState(st));
    const back=C.importAny(C.encodeAddress(st));if(!back.ok||C.encodeAddress(back.state)!==C.encodeAddress(st))bad.push('address '+C.encodeAddress(st));
    const bs=O.branches(st);O.gates(st);O.field(st);FS.caption(st);FS.heads(st);O.mirrorPairs(st);O.mirrorParity(st);O.carrierFoliation(st,24,7);
    if(R.Nint&&R.N>=2n){SH.contrast(R.N);SH.bracket(R.N);}
    const num=NUM.compute(st);
    if(R.Nq.n<=0n){n0++;if(!num.empty||!bs.every(b=>b.status==='undefined'))bad.push('N=0 not refused');continue;}
    if(num.refused){bad.push('refused '+num.refused);continue;}
    const orbs=NUM.orbits(st,num),mg=NUM.mirrorGeometry(st,num,orbs),fg=NUM.foliationGeometry(st,num,24,7);
    const nan=v=>typeof v==='number'?Number.isNaN(v):Array.isArray(v)?v.some(nan):v&&typeof v==='object'?Object.values(v).some(nan):false;if(nan([num.W,num.H,num.z,orbs.map(o=>o.s3.filter(Boolean)),mg.longitudes,mg.pairs.map(p=>p.meetings.map(q=>q.p)),fg.collapsed?[]:fg.family.map(f=>f.pts)]))bad.push('NaN '+C.encodeAddress(st));
    if(!rd.empty&&rd.wilsonN.label==='')bad.push('empty wilson label');
  }catch(e){bad.push(C.encodeAddress(st)+' threw '+e.message);}}
  return {ok:bad.length===0&&n>1000&&n0>0&&between>0,note:'('+n+' states, '+n0+' with N = 0, '+between+' between shells) '+bad.slice(0,3).join(' | ')};});
t('shell range B = 1, 2: honest labels — N = 1: Wilson "N = 1 is not prime.", shell contrast undefined (N < 2), Wilson gearbox at n₁ = 1, m = 2, φ₃ = 0 (N = 2 = 1! + 1): WILSON_PRIME_RESIDENT; at n₁ = 2, m = 3, φ₃ = 0 (N = 3 = 2! + 1): WILSON_PRIME_RESIDENT; between shells on B = 1 (φ₃ = 1/2, N = 3/2): every shell readout carries the between-shells label; the fraction stack is idle at N = 3/2 and evaluates at N = 2',()=>{
  const S=o=>C.initial({shellMode:'factorial',n1:'1',m:'2',...o});
  const a=C.readouts(S({phi3:'1'})),g1=C.gearbox(S({phi3:'0'})),g2=C.gearbox(C.initial({shellMode:'factorial',n1:'2',m:'3',phi3:'0'}));
  const b=S({nMode:'continuous',phi3:'1/2'}),rb=C.readouts(b),fb=FS.lattice(b),f2=FS.lattice(C.enterSpin(S({phi3:'0',m:'3',t1:'1',t2:'1'}),'1/3'));
  return a.wilsonN.label==='N = 1 is not prime.'&&SH.contrast(1n)===null&&g1.code==='WILSON_PRIME_RESIDENT'&&g2.code==='WILSON_PRIME_RESIDENT'
    &&rb.between==='between shells: N = 3/2; shell arithmetic undefined'&&rb.gearbox.code==='BETWEEN_SHELLS'&&C.divisorsOf(b).kind==='between'&&fb.idle&&!f2.idle;});
// ---------------------------------------------------------------- 2. previously valid states: byte-identical exact output (v0.4 modules, read-only)
const PRE=[];
for(const N of [2,3,4,5,6,7,8,9,10,11,12])for(const m of [2,3,4,5,6,7])for(const [t1,t2] of [['1','1'],['1/2','1'],['2','1/3'],['3/2','-3/2'],['-1','2'],['1','2/3']])
  PRE.push({shellMode:'integer',B:'24',nMode:'integer',phi3:String(25-N),m:String(m),t1,t2,n6:N%2?'1':'-1',alpha:N%3?'0':'1',sTyped:['0','1','7/3','-5/2'][(N+m)%4]});
for(const phi3 of ['7/2','89/4'])for(const m of [3,4,6])for(const [t1,t2] of [['1','1'],['1/2','3']])PRE.push({shellMode:'integer',B:'24',nMode:'continuous',phi3,m:String(m),t1,t2,n6:'1',alpha:'0',sTyped:'1/3'});
let seed=20261019;const rnd=()=>{seed=(seed*1103515245+12345)%2147483648;return seed/2147483648;},pick=a=>a[Math.floor(rnd()*a.length)];
for(let i=0;i<1600;i++){const fac=rnd()<0.5,n1=String(3+Math.floor(rnd()*4)),B=fac?null:String(2+Math.floor(rnd()*60));const Bv=fac?[6,24,120,720][Number(n1)-3]:Number(B);
  const cont=rnd()<0.3,phi3=cont?text(rat(BigInt(Math.floor(rnd()*4*(Bv+1))),4n)):String(Math.floor(rnd()*(Bv+2)));
  PRE.push({shellMode:fac?'factorial':'integer',n1,B:B||'24',nMode:cont?'continuous':'integer',phi3,m:String(2+Math.floor(rnd()*9)),t1:pick(['1','0','2','1/2','-3/2','1/3']),t2:pick(['1','0','-1','2','1/2','3/4']),n6:pick(['1','-1','0','2']),alpha:pick(['0','1','1/2','-1']),sTyped:pick(['0','1','-1','1/3','7/2','-5/4','12'])});}
const BJ=(k,v)=>typeof v==='bigint'?String(v)+'n':v;
const sig4=st=>{const num=N4.compute(st),orbs=num.empty||num.refused?[]:N4.orbits(st,num);
  return [C4.exportExact(st,null,{}),C4.exportState(st),C4.encodeAddress(st),JSON.stringify(C4.readouts(st),(k,v)=>typeof v==='bigint'?String(v)+'n':v),JSON.stringify(O4.branches(st).map(O4.liftBranch)),JSON.stringify(O4.gates(st)),O4.field(st).line,JSON.stringify(C4.stopSet(st),(k,v)=>typeof v==='bigint'?String(v)+'n':v),JSON.stringify(C4.step(st,1),(k,v)=>typeof v==='bigint'?String(v)+'n':v),FS4.caption(st),JSON.stringify(num,BJ),JSON.stringify(orbs,BJ),JSON.stringify(O4.mirrorPairs(st),(k,v)=>typeof v==='bigint'?String(v)+'n':v)].join('\u0001');};
const sig=st=>{const num=NUM.compute(st),orbs=num.empty||num.refused?[]:NUM.orbits(st,num);
  return [C.exportExact(st,null,{}),C.exportState(st),C.encodeAddress(st),JSON.stringify(C.readouts(st),(k,v)=>typeof v==='bigint'?String(v)+'n':v),JSON.stringify(O.branches(st).map(O.liftBranch)),JSON.stringify(O.gates(st)),O.field(st).line,JSON.stringify(C.stopSet(st),(k,v)=>typeof v==='bigint'?String(v)+'n':v),JSON.stringify(C.step(st,1),(k,v)=>typeof v==='bigint'?String(v)+'n':v),FS.caption(st),JSON.stringify(num,BJ),JSON.stringify(orbs,BJ),JSON.stringify(O.mirrorPairs(st),(k,v)=>typeof v==='bigint'?String(v)+'n':v)].join('\u0001');};
t('unchanged states: the 408-state v0.4 preset grid plus 1,600 random states valid in v0.4 (factorial n₁ 3–6, integer B 2–61, both N modes, N = 0 included) give byte-identical exact export, state export, address, readouts, Lift branches, gates, field line, stop set, step record, fraction-stack caption, numerical model, orbit samples and mirror pairs under the v0.4 and v0.4.1 modules',()=>{
  let n=0,bad=0,valid=0,n0=0;
  for(const o of PRE){let st4;try{st4=C4.enterSpin(C4.initial(o),o.sTyped);}catch(e){continue;}valid++;
    const st=C.enterSpin(C.initial(o),o.sTyped);if(JSON.stringify(st)!==JSON.stringify(st4)){bad++;continue;}
    if(C.resolve(st).Nq.n<=0n)n0++;n++;if(sig(st)!==sig4(st4))bad++;}
  return {ok:bad===0&&n>1800&&n0>0,note:'('+n+' states compared, '+n0+' with N = 0, '+bad+' differences)'};});
t('previously refused states: every state v0.4 refuses is refused by v0.4.1 with the same reason, except n₁ ∈ {1, 2} and integer B = 1, which are now valid, and the two widened range reasons themselves',()=>{
  let bad=0,newly=0,same=0;const cand=[];
  for(const n1 of ['0','1','2','3','13','14'])for(const phi3 of ['0','1','3','99'])cand.push({shellMode:'factorial',n1,phi3,m:'2'});
  for(const B of ['0','1','2','3','6227020801'])for(const phi3 of ['0','2','4'])cand.push({shellMode:'integer',B,phi3,m:'3'});
  for(const m of ['1','721'])cand.push({m});
  for(const o of cand){let e4=null,e=null;try{C4.initial(o);}catch(x){e4=x.message;}try{C.initial(o);}catch(x){e=x.message;}
    if(e4===null){if(e!==null)bad++;continue;}
    const widened=(o.n1==='1'||o.n1==='2'||o.B==='1');
    if(e===null){if(!widened)bad++;else newly++;continue;}
    if(widened&&!/n₁ must|Shell base must/.test(e)){newly++;continue;}   // a newly valid shell refused by a later check (φ₃ outside 0 … B + 1): that check's own reason
    const map={'Factorial index n₁ must be 3–13.':'Factorial index n₁ must be 1–13.','Shell base must be 2–6,227,020,800.':'Shell base must be 1–6,227,020,800.'};
    if((map[e4]||e4)!==e)bad++;else same++;}
  return {ok:bad===0&&newly>0&&same>0,note:'('+newly+' newly valid, '+same+' still refused)'};});
// ---------------------------------------------------------------- 3. the star
t('★ (SCHEMA_ADDENDUM_9 §2): keyed on t₁·s ∈ ℤ, the exact ALIGN condition. Review counterexample N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1: s ∈ ℤ but t₁·s = 1/2 ∉ ℤ, so no ★; the lab resultant is −i (|Im W| = 1, numerical); W·e^{−iπ(t₁s+f)} is real (numerical, within the bound)',()=>{
  const st=C.enterSpin(C.initial({shellMode:'integer',B:'24',phi3:'20',m:'6',t1:'1/2',t2:'1',n6:'1',alpha:'0'}),'1'),R=C.resolve(st),num=NUM.compute(st),W=num.W[num.W.length-1];
  const labReal=R.Nq.n>0n&&X.isInt(X.mul(R.t1,X.parse(st.sTyped))),ph=O.mirrorCarrierPhase(st),th=Math.PI*NUM.number(ph);
  return X.isInt(X.parse(st.sTyped))&&!labReal&&!C.readouts(st).flagAlign&&Math.abs(num.qres.value-1)<=num.bound&&Math.abs(W.im*Math.cos(th)-W.re*Math.sin(th))<=num.bound;});
t('★: over the preset grid and the random states, "t₁·s ∈ ℤ" equals the exact ALIGN flag, and whenever it holds the lab-frame |Im W| is within the numerical bound',()=>{
  let bad=0,on=0;for(const o of PRE){let st;try{st=C.enterSpin(C.initial(o),o.sTyped);}catch(e){continue;}const R=C.resolve(st);if(R.Nq.n<=0n)continue;const rd=C.readouts(st),lab=X.isInt(X.mul(R.t1,X.parse(st.sTyped)));
    if(lab!==rd.flagAlign)bad++;if(lab){on++;const num=NUM.compute(st);if(!num.refused&&num.qres.value>num.bound)bad++;}}
  return {ok:bad===0&&on>200,note:'('+on+' states with ★)'};});
// ---------------------------------------------------------------- 4. carrier foliation
const argOK=(y,betaPi,a,b)=>{const x=NUM.unproject(y),g=Math.atan2(x[3],x[2])-Math.PI*NUM.number(betaPi),r=Math.abs(Math.atan2(Math.sin(g),Math.cos(g)));return {d:Math.max(r,Math.abs(Math.hypot(x[0],x[1])-a),Math.abs(Math.hypot(x[2],x[3])-b)),r};};
const FOLST=PRE.slice(0,408).map(o=>C.enterSpin(C.initial(o),o.sTyped));
t('foliation: for every preset, K ∈ {6, 12, 24, 120} and selected k ∈ {0, 1, 10, 119, 120, 239, −1, 241}, every drawn point of every family curve, of the selected curve and of its companion has arg z₂ = β within 1e-9 and |z₁| = a, |z₂| = b within 1e-9 (inverse projection of the drawn 3D points)',()=>{
  let n=0,bad=0,worst=0;
  for(const [i,st] of FOLST.entries()){const num=NUM.compute(st);if(num.empty||num.refused)continue;const K=[6,12,24,120][i%4],k=[0,1,10,119,120,239,-1,241][i%8],g=NUM.foliationGeometry(st,num,K,k);
    if(g.collapsed)continue;for(const c of [...g.family,g.selected,g.companion])for(const y of c.pts){n++;const r=argOK(y,c.beta,g.a,g.b);worst=Math.max(worst,r.d);if(r.d>TOL)bad++;}}
  return {ok:bad===0&&n>1e6,note:'('+n+' points, worst '+worst.toExponential(2)+')'};});
t('foliation: the selected β is reported exactly as (k mod 240)/120·π reduced (k = 10 → "1/12·π", 119 → "119/120·π", 120 → "1·π", −1 → "239/120·π", 241 → "1/120·π"); the companion is β + π exactly ((k + 120) mod 240) and its drawn curve sits at arg z₂ = β + π (1e-9); the family is β = 2πj/K, j = 0..K−1; β = 0 and β = π are flagged as the mirror\'s fixed longitudes',()=>{
  const st=C.enterSpin(C.initial({shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'1',alpha:'0'}),'1/3'),num=NUM.compute(st);
  const want={'10':['1/12·π','13/12·π'],'119':['119/120·π','239/120·π'],'120':['1·π','0·π'],'-1':['239/120·π','119/120·π'],'241':['1/120·π','121/120·π'],'0':['0·π','1·π']};
  for(const k in want){const F=O.carrierFoliation(st,24,Number(k));if(F.betaText!==want[k][0]||F.companionText!==want[k][1]||!X.eq(X.sub(F.companion,F.beta),rat(1n))&&!X.eq(X.sub(F.beta,F.companion),rat(1n)))return false;
    const g=NUM.foliationGeometry(st,num,24,Number(k));if(!g.companion.pts.every(y=>argOK(y,X.add(F.beta,rat(1n)),g.a,g.b).d<=TOL))return false;if(F.mirrorFixed!==(k==='0'||k==='120'))return false;}
  for(const K of [6,12,24,120]){const F=O.carrierFoliation(st,K,0);if(F.family.length!==K||!F.family.every((b,j)=>X.eq(b,rat(2n*BigInt(j),BigInt(K)))))return false;}
  return O.carrierFoliation(st,7,0).K===24;});
t('foliation guards: t₁ = 0 → the carrier is stationary, every family member is one point at the carrier phase θ = π(t₁s + f) with arg z₂ = β; ρ = 0 (n₆ = 0) → collapsed, nothing drawn; teeth on the foliation: odd m → c = 0 only, even m → none, t₂ = 0 → every tooth',()=>{
  const S=o=>C.enterSpin(C.initial({shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'1',alpha:'0',...o}),'1/3');
  const a=S({t1:'0'}),na=NUM.compute(a),ga=NUM.foliationGeometry(a,na,24,30),z=S({n6:'0'}),gz=NUM.foliationGeometry(z,NUM.compute(z),24,30);
  const pts=ga.family.every(f=>f.pts.length===1&&argOK(f.pts[0],f.beta,ga.a,ga.b).d<=TOL)&&ga.selected.pts.length===1;
  const x=NUM.unproject(ga.family[3].pts[0]),thOk=Math.abs(Math.atan2(x[1],x[0])-0)<TOL;   // t1 = 0, n6 > 0: carrier phase 0
  return ga.stationary&&pts&&thOk&&gz.collapsed&&gz.family.length===0&&O.carrierFoliation(S({}),24,0).teethOn.map(String).join()==='0'&&O.carrierFoliation(S({m:'6'}),24,0).teethOn.length===0&&O.carrierFoliation(S({m:'6',t2:'0'}),24,0).teethOn.length===6;});
t('foliation is display register only: for the preset grid, branches, gates, exports and readouts do not depend on the foliation dials (they are view keys, excluded from the exact export); the exact export is identical with view "cff=1;cfk=120;cfb=17" and with view ""',()=>{
  let bad=0;for(const st of FOLST.slice(0,120)){const a={...st,view:'cff=1;cfk=120;cfb=17'};if(C.exportExact(a,null,{})!==C.exportExact({...st,view:''},null,{}))bad++;
    const r=C.importAny(C.encodeAddress(a));if(!r.ok||r.state.view!=='cff=1;cfk=120;cfb=17')bad++;}
  return bad===0;});
console.log(`test-v041: ${pass} passed, ${fail} failed`);
process.exit(fail?1:0);
