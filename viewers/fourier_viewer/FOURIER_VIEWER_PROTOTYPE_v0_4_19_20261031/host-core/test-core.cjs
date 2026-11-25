'use strict';
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js'),O=require('./orbit-core.js'),VW=require('../instruments/comb-hopf/views-common.js'),G=require('./gearbox-core.js'),NUM=require('./comb-numeric.js'),REF=require('./reference-stops.cjs');
let pass=0,fail=0;
function t(name,fn){let ok=false,msg='';try{ok=fn()===true;}catch(e){msg=' threw: '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+msg);ok?pass++:fail++;}
const T=X.text,P=X.parse;
// deterministic PRNG
let seed=0x9e3779b9;const rnd=()=>{seed^=seed<<13;seed>>>=0;seed^=seed>>>17;seed^=seed<<5;seed>>>=0;return seed/4294967296;};
const ri=(a,b)=>a+Math.floor(rnd()*(b-a+1)),pick=a=>a[ri(0,a.length-1)];
const FACT13=6227020800n;
// build a state with given exact N (integer shell), m, gears, typed spin; sEff/E overridable
function S(o){
  const N=BigInt(o.N),B=N-1n<2n?2n:N-1n,phi3=B+1n-N;
  let st=C.initial({shellMode:'integer',B:String(B),phi3:String(phi3),m:String(o.m),t1:String(o.t1),t2:String(o.t2),n6:o.n6||'1',alpha:o.alpha||'0',sTyped:String(o.s),chart:'host'});
  if(o.sEff!==undefined)st={...st,sEff:String(o.sEff)};
  if(o.E!==undefined)st={...st,E:String(o.E)};
  return st;
}
const asPair=q=>[q.n,q.d];
const sameQ=(q,p)=>q.n*p[1]===p[0]*q.d;
const kindsOf=r=>r.hits.map(h=>h.kind+(h.order?':'+h.order:'')).sort();
// compare core step with the independent reference; returns true or a message
function vsRef(st,dir){
  const R=C.resolve(st),set=C.stopSet(st),r=C.step(st,dir);
  if(!set.active)return r.outcome==='refused'||'expected refusal';
  const s0=P(st.sEff),E=P(st.E);
  const ref=REF.refStep({N:R.N,m:R.m,t1:R.t1.n,t2:R.t2.n,s0:asPair(s0),dir,E:asPair(E),mode:set.mode});
  if(r.outcome!==ref.outcome)return 'outcome '+r.outcome+' vs ref '+ref.outcome;
  if(!sameQ(P(r.value),ref.value))return 'value '+r.value+' vs ref '+ref.value;
  if(ref.outcome==='stop'&&kindsOf(r).join()!==ref.kinds.join())return 'kinds '+kindsOf(r)+' vs '+ref.kinds;
  return noSkip(st,r,dir,set);
}
// no-skip: no family has an element strictly between s0 and the landing (outcomes 2/3); unchanged state for 4/1
function noSkip(st,r,dir,set){
  const s0=P(st.sEff);
  if(r.outcome==='refused'||r.outcome==='none')return X.eq(P(r.state.sEff),s0)&&r.state.sTyped===st.sTyped&&r.state.E===st.E||'unchanged state violated';
  const v=P(r.value);if(dir>0?X.cmp(v,s0)<=0:X.cmp(v,s0)>=0)return 'not strictly in direction';
  for(const f of set.families){const c=C.stepPure(s0,dir,[f],X.neg(P(st.E)),P(st.E));
    if(c.outcome==='stop'&&(dir>0?X.cmp(c.value,v)<0:X.cmp(c.value,v)>0))return 'family '+f.kind+' has a nearer element '+T(c.value);}
  return true;
}
const ok=x=>x===true;
const D0=p=>C.initial({phi3:'0',m:'5',alpha:'1/2',...p});   // N=25, m=5 test baseline (the page defaults differ: phi3=23, m=2, alpha=1)
// ---------- R20 named cases
t('R20 #245: N=1 m=720 t1=-3 t2=-2 s=-1 forward -> -1439/1440',()=>{const st=S({N:1,m:720,t1:-3,t2:-2,s:-1,sEff:-1,E:1});return C.step(st,1).value==='-1439/1440'&&ok(vsRef(st,1));});
t('R20 #245: N=13!+1 m=7 t1=t2=3 s=1e6 both directions, no ALIGN skipped',()=>{
  const N=FACT13+1n,st=S({N,m:7,t1:3,t2:3,s:1000000,sEff:1000000,E:N});
  const f=C.step(st,1),b=C.step(st,-1),s0=P('1000000');
  const third=P('1/3');
  return X.cmp(P(f.value),X.add(s0,third))<=0&&X.cmp(P(b.value),X.sub(s0,third))>=0&&ok(vsRef(st,1))&&ok(vsRef(st,-1));});
t('R20 (i) N=1 m=3 t1=t2=1 s0=1 forward: no movement (limit)',()=>{const st=S({N:1,m:3,t1:1,t2:1,s:1,sEff:1,E:1}),r=C.step(st,1);return r.outcome==='none'&&r.label==='no stop in this direction within range'&&r.value==='1'&&ok(vsRef(st,1));});
t('R20 (ii) N=1 m=3 t1=0 t2=1 s0=0: refused (4e), no snap',()=>{const st=S({N:1,m:3,t1:0,t2:1,s:0}),r=C.step(st,1);return r.outcome==='refused'&&r.source==='4e'&&r.value==='0'&&r.state===st;});
t('R20 (iii) N=1 m=3 t1=1 t2=3 s0=1/2 forward -> 8/9',()=>{const st=S({N:1,m:3,t1:1,t2:3,s:'1/2',sEff:'1/2',E:1});return C.step(st,1).value==='8/9'&&ok(vsRef(st,1));});
t('R20 (iv) finite stop set {0,1}, range [0,1], s0=1 forward: no movement, not a refusal',()=>{const r=C.stepPure(P('1'),1,[{kind:'F',finite:[P('0'),P('1')]}],P('0'),P('1'));return r.outcome==='none'&&r.label==='no stop in this direction within range';});
t('R20 (iv) positive control: s0=0 forward lands on stop 1',()=>{const r=C.stepPure(P('0'),1,[{kind:'F',finite:[P('0'),P('1')]}],P('0'),P('1'));return r.outcome==='stop'&&T(r.value)==='1';});
t('R20 (v) integer stops, range [-1,1], s0=1 forward: no movement, no wrap',()=>{const r=C.stepPure(P('1'),1,[{kind:'Z',o:P('0'),h:P('1')}],P('-1'),P('1'));return r.outcome==='none'&&T(r.value)==='1';});
t('R20 (v) negative control: s0=0 forward lands on stop 1',()=>{const r=C.stepPure(P('0'),1,[{kind:'Z',o:P('0'),h:P('1')}],P('-1'),P('1'));return r.outcome==='stop'&&T(r.value)==='1';});
t('R20 4a: from a stop, with room, never stays put',()=>{const st=S({N:5,m:3,t1:1,t2:1,s:0,sEff:0,E:20}),r=C.step(st,1);return r.outcome==='stop'&&X.cmp(P(r.value),P('0'))>0;});
t('R20 4b: coincident families reported, ALIGN primary',()=>{
  for(let k=0;k<400;k++){const st=S({N:ri(1,30),m:pick([3,4,5,6,7,8]),t1:pick([1,2,3,-2]),t2:pick([1,2,3,-3]),s:'0',sEff:'0',E:50});
    const r=C.step(st,1);if(r.outcome==='stop'&&r.hits.length>1&&r.hits[0].kind==='ALIGN'&&r.label.startsWith('ALIGN stop (t₁·s ∈ ℤ); also'))return true;}return false;});
t('R20 4c: range-limit landing (stop beyond limit, s0 inside)',()=>{const r=C.stepPure(P('0'),1,[{kind:'Z',o:P('0'),h:P('2')}],P('-1'),P('1'));return r.outcome==='range-limit'&&T(r.value)==='1'&&r.label==='range limit, not a stop';});
t('R20 4c: limit that is itself a stop is outcome 2',()=>{const r=C.stepPure(P('0'),1,[{kind:'Z',o:P('0'),h:P('1')}],P('-1'),P('1'));return r.outcome==='stop';});
t('R20 4d: no stepping wrap (period-2 walk, step at limit)',()=>{const st=S({N:1,m:2,t1:1,t2:1,s:1,sEff:1,E:1});const r=C.step(st,1);return r.outcome==='none'&&r.value==='1';});
t('R20 4e: refusal arises for N<=0, t1=0, t2=0, non-integer gears; negative control: integer gears active',()=>{
  const bad=[S({N:0,m:3,t1:1,t2:1,s:0}),S({N:3,m:3,t1:0,t2:1,s:0}),S({N:3,m:4,t1:1,t2:0,s:0}),S({N:3,m:3,t1:'1/2',t2:1,s:0})];
  return bad.every(s=>C.step(s,1).outcome==='refused')&&C.step(S({N:3,m:3,t1:1,t2:1,s:0,E:9}),1).outcome==='stop';});
t('R20 4f: no size cutoff (s0=10^40 steps exactly, agrees with reference)',()=>{const big='10000000000000000000000000000000000000000';const st=S({N:7,m:11,t1:5,t2:3,s:big,sEff:big,E:big+'0'});return ok(vsRef(st,1))&&ok(vsRef(st,-1))&&C.step(st,1).outcome==='stop';});
t('R20 PAIR (m=2): integer lattice, guard N>0 only',()=>{const st=S({N:3,m:2,t1:'1/2',t2:0,s:'1/3',sEff:'1/3',E:3});return C.step(st,1).value==='1'&&C.step(st,-1).value==='0'&&C.step(S({N:0,m:2,t1:1,t2:1,s:0}),1).outcome==='refused';});
t('R20 labels: ALIGN stop (t₁·s ∈ ℤ) wording, no bare "contact"',()=>{const st=S({N:5,m:3,t1:1,t2:1,s:0,sEff:0,E:20}),r=C.step(st,1);return /stop \(/.test(r.label)&&!/contact/i.test(r.label);});
// ---------- R20 random sweep
let sweep=0,sweepBad=[],dense=0,landings=0,nones=0,stops=0;
function sweepOne(){
  const m=pick([2,3,4,5,6,7,8,9,12,30,60,120,360,719,720,ri(2,720)]);
  const N=pick([1n,2n,3n,7n,12n,25n,121n,BigInt(ri(1,2000)),FACT13+1n,BigInt(ri(1,1e9))]);
  const tv=()=>pick([1,2,3,-1,-2,-3,5,7,ri(-9,9)||1]);
  const sd=BigInt(pick([1,2,3,4,6,9,10,100,720,1440,ri(1,5000)])),sn=BigInt(ri(-3e6,3e6))*pick([1n,1n,1000n,1000000000n]);
  let sEffq=X.rat(sn,sd);
  if(rnd()<0.4){ // land near a stop
    const st0=S({N,m,t1:tv(),t2:tv(),s:0,sEff:0,E:1000});const set=C.stopSet(st0);
    if(set.active){const f=pick(set.families);sEffq=X.add(f.o,X.mul(f.h,X.rat(BigInt(ri(-50,50)))));if(rnd()<0.5)sEffq=X.add(sEffq,X.rat(BigInt(pick([-1,1])),BigInt(ri(10,1e6))));}}
  const a=X.qabs(sEffq),Nq=X.rat(N),base=X.cmp(a,Nq)>0?a:Nq,r0=rnd(),E=r0<0.2?X.add(base,X.rat(BigInt(ri(0,10)))):r0<0.6?X.add(base,X.rat(1n,BigInt(ri(2,3000)))):base;
  return S({N,m,t1:pick([1,2,3,-1,-2,-3,5,7,ri(-9,9)]),t2:tv(),s:T(sEffq),sEff:T(sEffq),E:T(E)});
}
t('R20 random sweep >= 5000 states, both directions vs independent reference (incl. m up to 720)',()=>{
  while(sweep<5000){const st=sweepOne(),R=C.resolve(st);
    for(const d of [1,-1]){const v=vsRef(st,d);const r=C.step(st,d);if(r.outcome==='stop')stops++;else if(r.outcome==='range-limit')landings++;else if(r.outcome==='none')nones++;if(R.m>=300)dense++;if(v!==true)sweepBad.push(v+' @ '+C.encodeAddress(st));}
    sweep++;}
  console.log('     sweep: '+sweep+' states x2 dirs, stops '+stops+', range-limit '+landings+', none '+nones+', dense(m>=300) '+dense+', mismatches '+sweepBad.length);
  if(sweepBad.length)console.log('     first mismatch: '+sweepBad[0]);
  return sweepBad.length===0&&dense>500&&landings>0&&nones>0;});
// ---------- R21
t('R21 D1 witness: B=4! N=24 m=3 t1=1/3 t2=1/2 typed 49 -> kept (gate closed), s_typed=s_eff=49',()=>{
  let st=C.initial({shellMode:'factorial',n1:'4',phi3:'1',m:'3',t1:'1/3',t2:'1/2'});st=C.enterSpin(st,'49');
  return C.resolve(st).N===24n&&!C.gate(st)&&st.sTyped==='49'&&st.sEff==='49'&&st.E==='49';});
t('R21 invariant wrap: N=25 typed 51 -> s_typed=51, s_eff=1 (mod 2N), E=25; boundary reps (-N,N]',()=>{
  let st=D0();st=C.enterSpin(st,'51');const a=st;
  const b=C.enterSpin(D0(),'-25'),c=C.enterSpin(D0(),'25'),d=C.enterSpin(D0(),'101/2');
  return C.gate(a)&&a.sTyped==='51'&&a.sEff==='1'&&a.E==='25'&&b.sEff==='25'&&c.sEff==='25'&&d.sEff==='1/2';});
t('page defaults (v0.1.1, match the old viewer): n1=4 alpha=1 n6=1 t1=t2=1 m=2 phi3=23, N=2, E=2',()=>{const d=C.initial();return d.n1==='4'&&d.alpha==='1'&&d.n6==='1'&&d.t1==='1'&&d.t2==='1'&&d.m==='2'&&d.phi3==='23'&&C.resolve(d).N===2n&&d.E==='2'&&d.sTyped==='1'&&d.tab==='fourier';});
t('R21 typed entry accepts decimals, fractions and products',()=>C.enterSpin(D0(),'0.5*3/4').sTyped==='3/8');
t('R21 wrap needs N>0: at N=0 s_eff=s_typed',()=>{let st=C.initial({phi3:'25',m:'3'});st=C.enterSpin(st,'7');return C.resolve(st).N===0n&&!C.gate(st)&&st.sEff==='7'&&st.E==='7';});
t('R21 dial changes: t1 change closing the gate returns s_eff to s_typed and E grows',()=>{
  let st=C.initial({phi3:'1',m:'3'});st=C.enterSpin(st,'49');       // N=24, t1=t2=1: gate open
  const open=st;st=C.dialChange(st,{t1:'1/5'});
  return open.sTyped==='49'&&open.sEff==='1'&&open.E==='24'&&st.sTyped==='49'&&st.sEff==='49'&&st.E==='49'&&!C.gate(st);});
t('R21 dial changes: gate re-opens, E shrinks back',()=>{let st=C.initial({phi3:'1',m:'3',t1:'1/3'});st=C.enterSpin(st,'49');st=C.dialChange(st,{t1:'1'});return st.sEff==='1'&&st.E==='24';});
t('R21 play through N=0 (phi3 0..B+1): s_typed never changes; range recomputed',()=>{
  let st=D0();st=C.enterSpin(st,'51');
  for(let g=0;g<=25;g++){st=C.dialChange(st,{phi3:String(g)});if(st.sTyped!=='51')return false;const N=C.resolve(st).N;
    if(N===0n&&(st.sEff!=='51'||st.E!=='51'))return false;if(N>0n&&X.cmp(P(st.E),X.rat(N))<0)return false;}
  return true;});
t('R21 random dial changes never rewrite s_typed (500 steps) and always satisfy the address validation',()=>{
  let st=C.enterSpin(D0(),'51');
  for(let i=0;i<500;i++){const k=pick(['phi3','m','t1','t2','n6','alpha']);const v=k==='phi3'?String(ri(0,25)):k==='m'?String(ri(2,40)):k==='n6'||k==='alpha'?pick(['0','1','-1','1/2','2']):pick(['1','2','1/3','3/2','-1','0']);
    try{st=C.dialChange(st,{[k]:v});}catch(e){continue;}
    if(st.sTyped!=='51')return false;C.validateState(st);}return true;});
t('R21-S: N=1 PAIR period-2 rep: forward 0 -> 1 commits s_typed=s_eff=1 (no rewrap), then no movement; E fixed',()=>{
  let st=S({N:1,m:2,t1:1,t2:1,s:0});st=C.enterSpin(st,'0');if(!C.gate(st)||st.E!=='1')return false;
  const r=C.step(st,1);if(r.outcome!=='stop'||r.state.sTyped!=='1'||r.state.sEff!=='1'||r.state.E!=='1')return false;
  return C.step(r.state,1).outcome==='none';});
const roundTrip=st=>{const r=C.importAny(C.exportState(st));if(!r.ok)throw Error(r.reason);return r.state;};
t('R21-R: N=1 PAIR no wrap: type 3 -> E=3; back -> 2, E=3; export/reload; forward -> 3',()=>{
  let st=S({N:1,m:2,t1:'1/2',t2:1,s:0});st=C.enterSpin(st,'3');if(C.gate(st)||st.E!=='3')return false;
  const b=C.step(st,-1);if(b.value!=='2'||b.state.E!=='3')return false;
  const re=roundTrip(b.state);return re.sTyped==='2'&&re.E==='3'&&C.step(re,1).value==='3';});
const imp=(st,patch)=>C.importAny(C.exportState({...st,...patch}));
t('R21-R controls: E<|sEff|, E<N, non-exact E are each refused as a whole',()=>{
  const st=C.enterSpin(S({N:1,m:2,t1:'1/2',t2:1,s:0}),'3');
  return !imp(st,{E:'2'}).ok&&!imp(st,{E:'0'}).ok&&!imp(st,{E:'abc'}).ok&&!imp(st,{E:'1.5'}).ok&&imp(st,{E:'3'}).ok;});
t('R21-EFF-REPLAY: type 0, back -> -1 (no wrap), back -> none; reload keeps -1/-1; back -> none',()=>{
  let st=C.enterSpin(S({N:1,m:2,t1:1,t2:1,s:0}),'0');const r1=C.step(st,-1);
  if(r1.state.sTyped!=='-1'||r1.state.sEff!=='-1')return false;if(C.step(r1.state,-1).outcome!=='none')return false;
  const re=roundTrip(r1.state);return re.sTyped==='-1'&&re.sEff==='-1'&&C.step(re,-1).outcome==='none';});
t('R21-EFF-REPLAY mirror: type 0, forward -> 1, reload, forward -> none',()=>{
  let st=C.enterSpin(S({N:1,m:2,t1:1,t2:1,s:0}),'0');const r=C.step(st,1);const re=roundTrip(r.state);return re.sEff==='1'&&C.step(re,1).outcome==='none';});
t('R21 two histories: freshly typed -1 stores s_eff=+1, stepped -1 stores s_eff=-1; each reloads to its own next step',()=>{
  const base=S({N:1,m:2,t1:1,t2:1,s:0});const fresh=C.enterSpin(base,'-1'),stepped=C.step(C.enterSpin(base,'0'),-1).state;
  if(fresh.sTyped!=='-1'||fresh.sEff!=='1'||stepped.sTyped!=='-1'||stepped.sEff!=='-1')return false;
  const a=roundTrip(fresh),b=roundTrip(stepped);
  return a.sEff==='1'&&b.sEff==='-1'&&C.step(a,-1).value==='0'&&C.step(b,-1).outcome==='none'&&C.step(a,1).outcome==='none';});
t('R21-EFF-REPLAY controls: s_eff neither s_typed nor invariant rep -> refused; s_eff outside [-E,E] -> refused',()=>{
  const fresh=C.enterSpin(S({N:1,m:2,t1:1,t2:1,s:0}),'-1');
  return !imp(fresh,{sEff:'0'}).ok&&!imp(fresh,{sEff:'3'}).ok&&!imp(fresh,{sEff:'-3',sTyped:'-3',E:'1'}).ok&&imp(fresh,{}).ok;});
t('R21 unchanged outcomes: refusal and no-movement leave state and export bytes identical',()=>{
  const ref=S({N:3,m:3,t1:0,t2:1,s:'7/2'}),r=C.step(ref,1);
  const lim=C.enterSpin(S({N:1,m:2,t1:1,t2:1,s:0}),'1'),rl=C.step(lim,1);
  return r.outcome==='refused'&&JSON.stringify(r.state)===JSON.stringify(ref)&&C.exportState(r.state)===C.exportState(ref)
    &&rl.outcome==='none'&&JSON.stringify(rl.state)===JSON.stringify(lim)&&C.exportState(rl.state)===C.exportState(lim)&&C.exportExact(rl.state)===C.exportExact(lim);});
t('R21 wrap gate is decided over the drawn objects (planar walk + S3 lift): k_c, N*t1, c*t2 all integral; independent of the tab',()=>{
  const st=C.initial({shellMode:'integer',B:'2',phi3:'1',m:'2',t1:'1/4',t2:'1/2'});   // N=2, k_c = 1/2 +- 1/2 integral, c*t2 = +-1/2 not
  const sw=C.enterSpin(st,'7');
  return C.resolve(st).N===2n&&C.gate(st,['planar-walk'])&&!C.gate(st)&&C.gate(D0())&&sw.sEff==='7'&&C.dialChange(sw,{tab:'hopf'}).sEff==='7'&&C.dialChange(sw,{tab:'clifford'}).E===sw.E;});
t('R21 step from stepped state: E never recomputed by a run of steps',()=>{let st=C.enterSpin(S({N:5,m:3,t1:1,t2:1,s:0}),'3');const E=st.E;for(let i=0;i<30;i++)st=C.step(st,i%3?-1:1).state;return st.E===E;});
// ---------- address and export
t('address round trip, tab and view carried',()=>{const st={...C.enterSpin(D0(),'51'),tab:'hopf',view:'hz=2.5,hy=0.6'};const r=C.decodeAddress(C.encodeAddress(st));return r.ok&&JSON.stringify(r.state)===JSON.stringify(Object.fromEntries(C.ADDRESS_KEYS.map(k=>[k,st[k]])));});
t('address refusals: version, unknown key, missing key, duplicate key, non-canonical, bad tab',()=>{
  const a=C.encodeAddress(D0());
  return [a.replace('fv-comb-hopf/0.2','fv-comb-hopf/0.3'),a+'&x=1',a.replace('&m=5',''),a+'&m=5',a.replace('t1=1','t1=2/2'),a.replace('tab=fourier','tab=nope'),a.replace('view=','view=%3Cb%3E')].every(s=>!C.decodeAddress(s).ok);});
t('exact export excludes tab and view; state export includes them',()=>{const st={...D0(),tab:'hopf',view:'hz=2'};const e=C.exportExact(st),s=C.exportState(st);const eo=X.parseStrict(e),so=X.parseStrict(s);return !('tab' in eo.state)&&!('view' in eo.state)&&!/hz=2/.test(e)&&so.state.tab==='hopf'&&so.state.view==='hz=2';});
t('exact export is canonical (parse/serialise identity) with trailing LF; changing tab leaves its bytes unchanged',()=>{
  const st=D0(),e=C.exportExact(st);return e.endsWith('}\n')&&X.canonicalFile(X.parseStrict(e))===e&&C.exportExact({...st,tab:'clifford',view:'zz=1'})===e;});
t('exact export carries k_c, phases, orders, spread, flags, last step with families',()=>{
  let st=D0();const r=C.step(st,1);const o=X.parseStrict(C.exportExact(r.state,r));
  return o.exact.k.length===5&&o.exact.order.length===5&&o.lastStep.outcome==='stop'&&Array.isArray(o.lastStep.families)&&typeof o.exact.spread==='string';});
t('import JSON path round trip and duplicate-key refusal',()=>{const st=D0();const j=C.exportState(st);const dup=j.replace('{"schema"','{"schema":"x","schema"');return C.importAny(j).ok&&!C.importAny(dup).ok;});
t('phase order: phase 0 -> 1, phase 1 -> 2, 1/2 -> 4, phases reduced into (-1,1]',()=>C.order(P('0'))===1n&&C.order(P('1'))===2n&&C.order(P('1/2'))===4n&&T(C.phaseRep(P('3')))==='1'&&T(C.phaseRep(P('-1')))==='1'&&T(C.phaseRep(P('5/2')))==='1/2');
t('teeth: offsets odd/even, k_c = N t1 + c t2',()=>{const st=D0({m:'4',t1:'2',t2:'3'});const T4=C.teeth(st);return T4.map(x=>x.c).join()==='-3,-1,1,3'&&T(T4[0].k)==='41'&&C.offsets(5).join()==='-2,-1,0,1,2';});
t('spread and alignment flags (exact)',()=>{
  const a=C.readouts(D0({m:'3',t2:'2',sTyped:'25'}));       // spread = 2*25/25 = 2
  const b=C.readouts(D0({m:'3',t2:'1',sTyped:'25'}));       // spread 1: pair aligned, odd m not all aligned
  const c=C.readouts(D0({m:'4',t2:'1',sTyped:'25'}));
  return T(a.spread)==='2'&&a.pairAligned&&a.allAligned&&b.pairAligned&&!b.allAligned&&c.allAligned;});
// ---------- gearbox and Wilson
t('gearbox: Wilson prime witness n1=4 m=5 g=0; composite exclusion n1=5 m=6',()=>{
  const a=G.analyze({shellMode:'factorial',n1:4,m:5,phi3:0,B:24}),b=G.analyze({shellMode:'factorial',n1:5,m:6,phi3:0,B:120});
  return a.code==='WILSON_PRIME_RESIDENT'&&a.stride===5n&&a.phi===4n&&a.defect===0n&&a.signature==='WILSON_PRIME_ZERO'&&b.code==='WILSON_COMPOSITE_EXCLUDED'&&b.defect===3n&&b.phi===2n;});
t('gearbox: N=0 hold, prev/next gear, signatures',()=>{
  const z=G.analyze({shellMode:'integer',n1:4,m:5,phi3:25,B:24});const g=G.analyze({shellMode:'integer',n1:4,m:7,phi3:3,B:24});
  return z.code==='DEGENERATE_AMBIENT_HOLD'&&g.first===4n&&g.next===4n&&g.previous===null&&g.remainder===22n%7n;});
t('two distinct Wilson readouts: shell-N test and the order-m witness are separate fields',()=>{const r=C.readouts(D0({n1:'5',m:'6'}));return /^Shell N = 121: \(N−1\)! mod N = 0/.test(r.wilsonN.label)&&r.gearbox.code==='WILSON_COMPOSITE_EXCLUDED'&&r.wilsonN.label!==r.gearbox.label;});
t('shell-N Wilson readout: prime 13 -> prime; 12 -> not; 10001 -> not evaluated',()=>C.wilsonN(13n).prime===true&&C.wilsonN(12n).prime===false&&C.wilsonN(10001n).checked===false);
// ---------- numerical register
t('numerical: gate residual within bound, Hopf points unit norm (<1e-12) for 500 random states',()=>{
  let n=0,bad=0,worst=0;
  for(let i=0;i<2000&&n<500;i++){
    const st=C.initial({shellMode:'integer',B:String(ri(2,5000)),phi3:'0',m:String(ri(2,60)),t1:pick(['1','2','1/2','-3','3/2']),t2:pick(['1','3','1/3','-2','0']),n6:pick(['1','2','-1','1/2','0','3']),alpha:pick(['0','1/2','1','-1','2']),sTyped:pick(['1','7/3','12','-5','0']),chart:pick(['host','comb'])});
    const r=NUM.compute(st);if(r.refused)continue;n++;
    if(!r.gate.ok)bad++;for(const p of r.H){const e=Math.abs(Math.hypot(...p)-1);worst=Math.max(worst,e);if(e>1e-12)bad++;}}
  console.log('     numeric: '+n+' states checked, worst unit-norm error '+worst.toExponential(2));
  return n===500&&bad===0;});
t('numerical: south pole at W0, tooth latitude (rho^2-1)/(rho^2+1) at host chart; rho=0 labelled, underflow refused',()=>{
  const a=NUM.compute(C.initial({phi3:'2',m:'3',alpha:'0',n6:'3'}));const z=NUM.compute(C.initial({phi3:'2',m:'3',n6:'0'}));
  const u=NUM.compute(C.initial({phi3:'2',m:'3',n6:'0.'+'0'.repeat(400)+'1'}));
  return Math.abs(a.lat-0.8)<1e-15&&a.H[0][2]===-1&&z.rhoZero&&z.W.every(w=>w.re===0&&w.im===0)&&!!u.refused&&/underflows/.test(u.refused);});
t('numerical: N=0 gives the empty state',()=>NUM.compute(C.initial({phi3:'25',m:'3'})).empty===true);
t('numerical values carry a stated bound',()=>{const r=NUM.compute(D0());return r.bound>0&&r.hopfBound>0&&r.bound<1e-10;});

// ---------- addendum tests: shell core, flags, gates, lift, gearbox parity
const SH=require('./shell-core.js');
const FROZEN='C:/Users/robin/s6_atom/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
t('SPREAD/ALIGN exact flags vs numerical |K_m| < 1e-9 at 2000 random states (any disagreement fails)',()=>{
  let bad=0,zeros=0;
  for(let i=0;i<2000;i++){
    const m=ri(2,30),N=ri(1,30),sd=pick([1,2,3,4,5,6,8,12]),sn=ri(-40,40)*(rnd()<0.5?1:sd),t2=pick(['1','2','3','1/2','3/2','-2','5']);
    const st=D0({shellMode:'integer',B:String(Math.max(N-1,2)),phi3:String(Math.max(N-1,2)+1-N),m:String(m),t2,sTyped:sn+'/'+sd});
    const rd=C.readouts(st),beta=Math.PI*Number(P(t2).n)/Number(P(t2).d)*sn/sd/N;
    let K;if(m%2){const d=Math.sin(beta/2);K=Math.abs(d)<1e-12?m:Math.sin(m*beta/2)/d;}else{const d=Math.sin(beta);K=Math.abs(d)<1e-12?m:Math.sin(m*beta)/d;}
    const numZero=Math.abs(K)<1e-9;if(rd.flagSpread!==numZero)bad++;if(numZero)zeros++;
    if(rd.flagAlign!==X.isInt(X.mul(P(st.t1),P(st.sTyped))))bad++;}
  console.log('     K_m flags: '+zeros+' zero-kernel states among 2000, disagreements '+bad);return bad===0&&zeros>50;});
t('gate fixtures G-HOPF-BASE-S2-01 (5 fixtures)',()=>NUM.gateFixtures().every(Boolean));
t('G-HOPF-BASE-S2-CHART-COMPAT: S2 from the S3 lift equals fromAffine(tooth z) within 1e-10 (300 random states)',()=>{
  let n=0,worst=0;for(let i=0;i<1000&&n<300;i++){
    const st=D0({shellMode:'integer',B:String(ri(2,3000)),phi3:'0',m:String(ri(2,40)),t1:pick(['1','2','1/2','-3']),t2:pick(['1','3','1/3','-2']),n6:pick(['1','-1','2','-1/2','0']),alpha:pick(['0','1','-1/2','2']),sTyped:pick(['1','7/3','12','-5/2'])});
    const r=NUM.compute(st);if(r.refused)continue;n++;worst=Math.max(worst,r.chartCompat.maxDiff);if(!r.chartCompat.ok)return false;}
  console.log('     chart-compat worst '+worst.toExponential(2)+' over '+n);return n===300;});
t('S3 lift: z1/z2 = rho e^{i pi k s/N} (numerical) and carrier gets +1 when n6<0',()=>{
  const st=D0({n6:'-1/2',alpha:'1',t1:'3/2',sTyped:'7/3'});const r=NUM.compute(st);let w=0;
  r.lift.forEach((l,i)=>{const den=l.z2.re*l.z2.re+l.z2.im*l.z2.im,re=(l.z1.re*l.z2.re+l.z1.im*l.z2.im)/den,im=(l.z1.im*l.z2.re-l.z1.re*l.z2.im)/den;w=Math.max(w,Math.hypot(re-r.z[i].re,im-r.z[i].im));});
  const T0=C.teeth(st)[0];return w<1e-12&&X.isInt(X.div(X.sub(T0.carrier,X.add(X.mul(P(st.t1),P(st.sTyped)),P('1'))),P('2')));});
t('stereographic projection statuses: finite, AT_INFINITY (exact north pole), CLIPPED_NEAR_POLE',()=>{
  const a=NUM.stereo({re:0,im:0},{re:0,im:1},true),b=NUM.stereo({re:0,im:0},{re:0,im:1},false),c=NUM.stereo({re:0.6,im:0},{re:0,im:-0.8},false);return a.status==='AT_INFINITY'&&b.status==='CLIPPED_NEAR_POLE'&&c.status==='FINITE';});
t('gearbox analyze() vs frozen v0.3.2 gearbox.js on 2000 random states (read-only load)',()=>{
  const F=require(FROZEN+'gearbox.js');let diff=[];
  const Bs=[6n,24n,120n,720n,5040n,40320n,362880n,3628800n,39916800n,479001600n,6227020800n];
  for(let i=0;i<2000;i++){const fact=rnd()<0.5,n1=ri(3,13),B=fact?Bs[n1-3]:BigInt(ri(2,100000)),m=pick([ri(2,720),n1+1,ri(2,30)]),g=rnd()<0.3?0:ri(0,Math.min(Number(B)+1,5000));
    const a=G.analyze({shellMode:fact?'factorial':'integer',n1,m,phi3:g,B}),f=F.analyze({shellMode:fact?'factorial':'integer',n1:String(n1),combM:String(m),phi3:String(g),base:String(B)});
    for(const k of Object.keys(f)){if(String(a[k])!==String(f[k]))diff.push(k+' '+a[k]+' vs '+f[k]);}}
  console.log('     gearbox differences: '+diff.length+(diff.length?' first '+diff[0]:''));return diff.length===0;});
t('Wilson shell-N test N=2..200 vs trial-division primality',()=>{for(let n=2n;n<=200n;n++){let p=true;for(let d=2n;d*d<=n;d++)if(n%d===0n){p=false;break;}if(C.wilsonN(n).prime!==p)return false;}return true;});
t('Wilson order-m witness p=2..200: PRIME iff (p-1)!+1 = 0 mod p, phi relation consistent',()=>{for(let p=2n;p<=200n;p++){const w=SH.orderWitness(p);let pr=true;for(let d=2n;d*d<=p;d++)if(p%d===0n){pr=false;break;}
  if(w.prime!==pr||!w.wilsonOk||(w.delta===0n)!==pr)return false;}return SH.orderWitness(5n).residue===0n&&SH.orderWitness(6n).residue!==0n;});
t('Wilson order-m witness: residue (n1)!+1 mod p, n1=p-1 (p=7: 0; p=9: 8!+1 mod 9)',()=>{let f=1n;for(let k=2n;k<=8n;k++)f*=k;return SH.orderWitness(7n).residue===0n&&SH.orderWitness(9n).residue===(f+1n)%9n;});
t('divisors: T=12,B=24 -> {1,2,3,4,6,12}',()=>{const r=SH.divisorsReport(P('1'),P('12'),25n);return r.kind==='list'&&r.list.join()==='1,2,3,4,6,12'&&r.tag==='\u03c4(s) = 6, composite'&&r.label.startsWith('Div(s):');});
t('divisors: prime s tagged PRIME, unit tagged unit, t2=2 uses "NOT Div(s)"',()=>SH.divisorsReport(P('1'),P('13'),25n).tag==='s is PRIME'&&SH.divisorsReport(P('1'),P('1'),25n).tag==='unit'&&/NOT Div\(s\)/.test(SH.divisorsReport(P('2'),P('6'),25n).label));
t('divisors: non-integer t2*s -> no shell aligns (no round(s) shadow); s=0 and t2=0 degenerate labels',()=>{const a=SH.divisorsReport(P('1'),P('5/2'),25n),b=SH.divisorsReport(P('1'),P('0'),25n),c=SH.divisorsReport(P('0'),P('3'),25n);return a.kind==='nonint'&&/\u2209 \u2124/.test(a.label)&&b.kind==='zero'&&c.kind==='zero';});
t('divisors: shell truncation (T=1000, B+1=25 keeps divisors <= 25) tagged shell-truncated',()=>{const r=SH.divisorsReport(P('2'),P('500'),25n);return r.truncated&&r.list.join()==='1,2,4,5,8,10,20,25'&&r.tag==='shell-truncated';});
t('divisors: refusal above the size limit 10^18; limit itself accepted; large factorisation verified',()=>{
  const a=SH.divisorsReport(P('1'),X.rat(10n**18n+1n),6227020801n);const b=SH.divisorsReport(P('1'),X.rat(10n**18n),6227020801n);const f=SH.factor(999999999989n*1000003n);
  return a.kind==='refused'&&b.kind==='list'&&f.size===2;});
t('divisors: negative T uses |T|; negative s is not Div(s)',()=>{const r=SH.divisorsReport(P('1'),P('-12'),25n);return r.list.join()==='1,2,3,4,6,12'&&/NOT Div/.test(r.label);});
t('contrast exact at N=5,6,7,30 (hand-computed totients)',()=>
  T(SH.contrast(5n))==='1/2'&&T(SH.contrast(6n))==='5/2'&&T(SH.contrast(7n))==='1/2'&&T(SH.contrast(30n))==='29/8'&&SH.contrast(1n)===null);
t('shell bracket: N=4 TWIN, N=8 LEFT_PRIME, N=6 TWIN, N=9 NULL, N=10 RIGHT_PRIME',()=>SH.bracket(4n)==='TWIN'&&SH.bracket(8n)==='LEFT_PRIME'&&SH.bracket(6n)==='TWIN'&&SH.bracket(9n)==='NULL'&&SH.bracket(10n)==='RIGHT_PRIME');
t('shell-core totient/tau/isPrime spot checks (Carmichael 561, Mersenne 2^61-1, big semiprime)',()=>SH.totient(36n)===12n&&SH.tau(360n)===24n&&!SH.isPrime(561n)&&SH.isPrime(2305843009213693951n)&&SH.totient(1000003n*999983n)===1000002n*999982n);

// ---------- fraction stack (addendum 3)
const FS=require('./fraction-stack-core.js');
const fsState=(o)=>C.initial({shellMode:'integer',B:String(o.B),phi3:String(BigInt(o.B)+1n-BigInt(o.N)),m:String(o.m),t1:String(o.t1||1),t2:String(o.t2||1),sTyped:String(o.s)});
t('fraction stack fixture: B=24 N=9 m=5 s=72/5 -> q=5, 630 heads, 10 pages, spread-zero columns 18/5,36/5,54/5,72/5,108/5',()=>{
  const st=fsState({B:24,N:9,m:5,s:'72/5'}),r=FS.heads(st),L=r.lattice;
  if(L.idle||L.q!==5n||L.raw!==630n||r.heads.length!==630)return false;
  const cols=[...new Set(r.heads.filter(h=>h.spreadZero).map(h=>T(h.s)))];
  return cols.join()==='18/5,36/5,54/5,72/5,108/5'&&L.source==='slider lattice'&&new Set(r.heads.map(h=>h.j)).size===126;});
t('fraction stack: 10 azimuth pages u = j*pi/5 (j mod 10) ; 90/5 = 18 is an alignment pole, not a zero',()=>{
  const st=fsState({B:24,N:9,m:5,s:'72/5'}),r=FS.heads(st);const pages=new Set(r.heads.map(h=>h.j%10n));
  const j90=r.heads.find(h=>h.j===90n);return pages.size===10&&j90&&!j90.spreadZero&&FS.spreadZero(P('18'),9n,5,P('1'))===false;});
t('fraction stack lattice q: s=136/25 -> 25; integer spin fallback odd m (q=m|t2|/gcd(2N,m|t2|)) and even m',()=>{
  const a=FS.lattice(fsState({B:24,N:9,m:5,s:'136/25'}));
  const b=FS.lattice(fsState({B:24,N:9,m:5,t2:3,s:'4'}));       // mt=15, gcd(18,15)=3 -> q=5
  const c=FS.lattice(fsState({B:24,N:9,m:4,t2:3,s:'4'}));       // mt=12, gcd(9,12)=3 -> q=4
  return a.q===25n&&a.source==='slider lattice'&&b.q===5n&&/integer spin/.test(b.source)&&c.q===4n;});
t('fraction stack gates: N=10 m=5 idle (integer stops), N<=0, non-integer gears, q=61 cap',()=>{
  const a=FS.lattice(fsState({B:24,N:10,m:5,s:'4'})),b=FS.lattice(C.initial({phi3:'25',m:'3'})),c=FS.lattice(fsState({B:24,N:9,m:5,t1:'1/2',s:'1/3'})),d=FS.lattice(fsState({B:200,N:9,m:5,s:'1/61'})),e=FS.lattice(fsState({B:24,N:9,m:5,s:'1/60'}));
  return a.idle&&/spread stops are integers/.test(a.reason)&&b.reason==='no current shell'&&/integer gearbox required/.test(c.reason)&&d.idle&&d.reason==='lattice ζ_61 beyond draw cap 60'&&!e.idle&&/^fraction stack idle/.test(FS.caption(fsState({B:24,N:10,m:5,s:'4'})));});
t('fraction stack: exact spread-zero equals the host Number port (fractionSpinSpreadZero) and numerical |K_m| < 1e-9, 200 random lattices',()=>{
  const gN=(a,b)=>{while(b){[a,b]=[b,a%b];}return a;};
  const host=(num,den,N,m,t2)=>{let a=t2*num,b=den*N;if(b===0)return false;if(b<0){a=-a;b=-b;}const g0=gN(Math.abs(a),b)||1;a/=g0;b/=g0;const twoB=2*b,p=((a%twoB)+twoB)%twoB;
    if(m%2===1){if(p===0||(m*p)%twoB!==0)return false;const d=twoB/(gN(p,twoB)||1);return d>1&&m%d===0;}return b>1&&m%b===0;};
  let bad=0,cols=0,zeros=0;
  for(let i=0;i<200;i++){const m=ri(2,24),N=ri(1,40),t2=pick([1,2,3,-2,5]),q=ri(2,30);
    for(let j=0;j<=q*3;j++){cols++;const mine=FS.spreadZero(X.rat(BigInt(j),BigInt(q)),BigInt(N),m,X.rat(BigInt(t2)));const h=host(j,q,N,m,t2);
      const beta=Math.PI*t2*j/q/N;let K;if(m%2){const d=Math.sin(beta/2);K=Math.abs(d)<1e-12?m:Math.sin(m*beta/2)/d;}else{const d=Math.sin(beta);K=Math.abs(d)<1e-12?m:Math.sin(m*beta)/d;}
      if(mine!==h||mine!==(Math.abs(K)<1e-9))bad++;if(mine)zeros++;}}
  console.log('     fraction-stack columns checked '+cols+', spread-zero '+zeros+', disagreements '+bad);return bad===0&&zeros>20;});
t('fraction stack selection: count = min(raw,4000); even indices floor(i*raw/4000); huge raw never materialised (13!, q=60, m=720)',()=>{
  const a=FS.selectIndices(630n),b=FS.selectIndices(100000n),c=FS.selectIndices(60n*6227020801n*720n);
  return a.length===630&&b.length===4000&&b[1]===25n&&b[3999]===99975n&&c.length===4000&&c[0]===0n&&c[3999]<60n*6227020801n*720n&&c.every((v,i)=>i===0||v>c[i-1]);});
t('fraction stack numerical points are finite unit-consistent S3 projections (display only)',()=>{
  const st=fsState({B:24,N:9,m:5,s:'72/5'}),r=FS.heads(st),num=NUM.compute(st),pts=NUM.fractionPoints(st,r.heads,num);return pts.length===630&&pts.every(p=>p.p===null||p.p.every(Number.isFinite));});
// ---------- fix round 2
// Fix 7: contrast colour band and lock by exact rational comparison (no float)
t('contrastBand: exact thresholds 3 and 2 (strict): 3 -> warn/no lock, 2 -> dim, 3+1e-40 -> defend/lock although the float is 3, 2+1e-40 -> warn',()=>{
  const q=(n,d)=>X.rat(n,d),E30=10n**40n;
  const b3=SH.contrastBand(q(3n)),b2=SH.contrastBand(q(2n)),b3p=SH.contrastBand(q(3n*E30+1n,E30)),b2p=SH.contrastBand(q(2n*E30+1n,E30)),b3m=SH.contrastBand(q(3n*E30-1n,E30));
  const floatSays3=Number(3n*E30+1n)/Number(E30)===3;
  return floatSays3&&b3.band==='warn'&&!b3.lock&&b2.band==='dim'&&!b2.lock&&b3p.band==='defend'&&b3p.lock&&b2p.band==='warn'&&!b2p.lock&&b3m.band==='warn'&&!b3m.lock&&SH.contrastBand(null)===null;});
t('contrastBand agrees with independent BigInt cross-multiplication for every shell N = 2..400 (and the known fixtures N=5,6,7,30)',()=>{
  let bad=0;for(let N=2n;N<=400n;N++){const c=SH.contrast(N),b=SH.contrastBand(c),hi=c.n>3n*c.d,mid=c.n>2n*c.d;
    if(b.lock!==hi||b.band!==(hi?'defend':mid?'warn':'dim'))bad++;}
  return bad===0&&SH.contrastBand(SH.contrast(5n)).band==='dim'&&SH.contrastBand(SH.contrast(6n)).band==='warn'&&SH.contrastBand(SH.contrast(7n)).band==='dim'&&SH.contrastBand(SH.contrast(30n)).lock;});
t('panel.js decides colour band and lock through SH.contrastBand, not from the float decimal',()=>{
  const src=require('fs').readFileSync(require('path').join(__dirname,'..','instruments','comb-hopf','panel.js'),'utf8');
  return /SH\.contrastBand\(c\)/.test(src)&&!/v>3|v>2|lock:v/.test(src);});
// Fix 6: R21.2 label whenever the gate is closed and s_typed is not already its own representative in (-N, N]
t('wrapKept (R21.2): D1 shell N=24 gate closed: 49 -> label; -24 -> label (wrap would give 24); 5, 24, -23, 0, 47/2 -> no label; 25 -> label',()=>{
  const d1=s=>C.enterSpin(C.initial({shellMode:'factorial',n1:'4',phi3:'1',m:'3',t1:'1/3',t2:'1/2'}),s);
  const a=d1('49');if(C.gate(a))return false;
  return C.wrapKept(a)&&C.wrapKept(d1('-24'))&&C.wrapKept(d1('25'))&&C.wrapKept(d1('-49/2'))&&!C.wrapKept(d1('5'))&&!C.wrapKept(d1('24'))&&!C.wrapKept(d1('-23'))&&!C.wrapKept(d1('0'))&&!C.wrapKept(d1('47/2'));});
t('wrapKept: false when the gate is open (wrap applied, not kept), false at N=0; label state is exactly "gate closed and center(s_typed) != s_typed" over 1500 random states',()=>{
  let st=C.enterSpin(D0(),'51');if(!C.gate(st)||C.wrapKept(st))return false;
  if(C.wrapKept(C.enterSpin(C.initial({phi3:'25',m:'3'}),'7')))return false;
  let bad=0,seen=0;for(let i=0;i<1500;i++){const N=ri(1,40),x=S({N,m:pick([3,4,5,6]),t1:pick(['1','1/3','2','3/2','-1/2']),t2:pick(['1','1/2','2','-1/3','3']),s:'0'});
    const sT=pick([String(ri(-120,120)),ri(-120,120)+'/2',ri(-90,90)+'/3']),y=C.enterSpin(x,sT),R=C.resolve(y),want=!C.gate(y)&&!X.eq(C.center(P(sT),R.N),P(sT));
    if(C.wrapKept(y)!==want)bad++;if(want)seen++;}
  return bad===0&&seen>100;});
// Fix 9: PAIR guard unchanged (owner decision 2026-10-13): integer lattice, active whenever N>0, whatever t1, t2
t('PAIR guard (owner decision 2026-10-13): m=2 stepping is active for any t1,t2 (0, non-integer) when N>0, mode PAIR, stops at integers; refused at N<=0',()=>{
  const a=C.stopSet(S({N:5,m:2,t1:0,t2:0,s:0})),b=C.stopSet(S({N:5,m:2,t1:'1/3',t2:'-5/7',s:0})),c=C.step(C.enterSpin(S({N:5,m:2,t1:0,t2:'1/2',s:0}),'1/2'),1),z=C.stopSet(C.initial({phi3:'25',m:'2'}));
  return a.active&&a.mode==='PAIR'&&b.active&&b.mode==='PAIR'&&c.outcome==='stop'&&c.value==='1'&&!z.active;});
// ---------- build pins (R13a): the non-rendered block in the page equals the module file hashes
t('fv-build-pins block in dist page equals the sha256 of every inlined module file',()=>{
  const fs=require('fs'),cr=require('crypto'),pathm=require('path'),root=pathm.join(__dirname,'..');
  const html=fs.readFileSync(pathm.join(root,'dist','comb-hopf.html'),'utf8'),m=/<script type="application\/json" id="fv-build-pins">([^<]*)<\/script>/.exec(html);
  if(!m)return false;const pins=JSON.parse(m[1]);if(pins.schema!=='fv-comb-hopf-build/0.1'||!pins.exact_lib||pins.exact_lib.version!=='0.2.0'||pins.exact_lib.sha256!=='3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71'||X.VERSION!=='exact-lib/0.2.0'||!pins.modules.length)return false;
  const inlined=['exact-lib/exact-lib-0.2.0.js','host-core/gearbox-core.js','host-core/shell-core.js','host-core/comb-core.js','host-core/orbit-core.js','host-core/fraction-stack-core.js','host-core/comb-numeric.js','instruments/comb-hopf/views-common.js','instruments/comb-hopf/view-fourier.js','instruments/comb-hopf/view-clifford.js','instruments/comb-hopf/view-hopf.js','instruments/comb-hopf/view-panels.js','instruments/comb-hopf/panel.js'];
  if(pins.modules.map(x=>x.path).join()!==inlined.join())return false;
  const bodyPos=html.lastIndexOf('</body>'),pinPos=html.indexOf('id="fv-build-pins"');
  const ok=pins.modules.every(x=>cr.createHash('sha256').update(fs.readFileSync(pathm.join(root,x.path))).digest('hex')===x.sha256);
  return ok&&pinPos>0&&bodyPos-pinPos<2000;});
// ---------- fix round 4: s-orbit sampling
{
  const exSt=C.initial({shellMode:'integer',B:'24',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'0',sTyped:'408/125',chart:'host'});
  const numE=NUM.compute(exSt),orbE=NUM.orbits(exSt,numE),R=C.resolve(exSt),deg=Math.PI/180;
  t('orbit example state: N = 4, rho = 1',()=>R.N===4n&&Math.abs(numE.rho-1)<1e-12);
  t('orbit period is the exact lcm(2/|t1|, 2N/|c t2|) for every tooth (BigInt rationals)',()=>orbE.every(o=>{
    if(o.stationary)return true;const a=NUM.orbitPeriod(R.t1,R.t2,o.c,R.N),parts=[X.rat(2n)];
    if(o.c!==0n)parts.push(X.rat(2n*R.N,o.c<0n?-o.c:o.c));
    let L=parts[0];for(const q of parts.slice(1)){const g=(x,y)=>X.gcd(x,y);L=X.rat(L.n/g(L.n,q.n)*q.n,g(L.d,q.d));}
    return X.eq(a,L)&&o.period===X.text(a);}));
  t('orbit example: every step advances u and v by at most 2 degrees; closed full period; no partial',()=>orbE.filter(o=>!o.stationary).every(o=>{
    const dsv=o.span/(o.points-1),du=Math.PI*1*dsv,dv=Math.PI*Math.abs(Number(o.c))*dsv/4;
    return !o.partial&&du<=2*deg*(1+1e-9)&&dv<=2*deg*(1+1e-9)&&o.points>=180&&o.s3.length===o.points&&o.s2.length===o.points
      &&Math.hypot(...o.s3[0].map((x,i)=>x-o.s3[o.points-1][i]))<1e-6;}));
  t('orbit example: each of the 7 teeth has a drawn orbit (c = 0 carrier has none only if rate 0)',()=>orbE.length===7&&orbE.filter(o=>!o.stationary).length>=6);
  const st2=C.initial({shellMode:'integer',B:'24',phi3:'21',m:'7',t1:'1',t2:'7919',n6:'1',alpha:'0',sTyped:'1/3',chart:'host'}),o2=NUM.orbits(st2,NUM.compute(st2));
  t('orbit window too long for 4,000 points at 2 degrees: partial, exactly 4,000 points, centred on s',()=>{
    const p=o2.filter(o=>o.partial);if(!p.length)return false;
    return p.every(o=>o.points===4000&&Math.abs(o.span-3999*o.ds)<1e-9*o.span&&o.span<Number(o.period.split('/')[0])/(Number(o.period.split('/')[1]||1)));});
  t('orbit pole break: a point at the pole projects to null (the view splits the polyline there)',()=>{
    const v=NUM.stereo({re:0,im:0},{re:0,im:1},false);return v.vector===null&&v.status==='CLIPPED_NEAR_POLE';});
}
// ---------- v0.1.1: SCHEMA_ADDENDUM_5 (orbit branches, cyclotomic field, lift branch data), Hopf comb-walk edge curves
{
  const fs=require('fs'),REF_PATH='C:/Users/robin/Downloads/fvlt_fourier_m7_fact-4-24_s0.5714285714285714_1791886895936.json';
  let ref=null;try{ref=JSON.parse(fs.readFileSync(REF_PATH,'utf8'));}catch(e){}
  const refSt=C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'1',sTyped:'4/7'});   // n1=4, phi3=21 (N=4), m=7, t1=t2=1, s=4/7, n6=1, alpha=1
  t('reference export is readable and is the m=7, N=4, s=4/7 state',()=>ref!==null&&ref.parameters.m===7&&ref.parameters.N===4&&ref.parameters.sExact==='4/7'&&ref.parameters.phi3===21&&ref.parameters.n1===4&&C.resolve(refSt).N===4n);
  const BR=O.branches(refSt);
  t('orbit branches reproduce the export orbitBranches exactly (raw winding, divisor, primitive winding, canonical type, 7 entries)',()=>ref!==null&&JSON.stringify(BR.map(O.summary))===JSON.stringify(ref.orbitBranches));
  t('lift branches reproduce exactRationalLift.branches exactly (raw_rate, scale, cleared rate, factor, primitive, closure period, k_c, class, type, chi); c is a string in the new export',()=>{
    if(ref===null)return false;const mine=BR.map(O.liftBranch),want=ref.exactRationalLift.branches.map(b=>({...b,c:String(b.c)}));
    return mine.length===7&&JSON.stringify(mine)===JSON.stringify(want)&&mine.every(b=>typeof b.c==='string');});
  t('closure periods c = -3 -> 8, c = -2 -> 4, c = 0 -> 2 (addendum 5 s1.3) and k_c = N t1 + c t2',()=>{
    const per=c=>X.text(BR.find(b=>b.c===BigInt(c)).closurePeriod);
    return per(-3)==='8'&&per(-2)==='4'&&per(0)==='2'&&BR.every(b=>X.text(b.k)===String(4+Number(b.c)));});
  t('every Lift JSON branch value is an exact string, rational object or boolean (the canonical serializer refuses JS numbers)',()=>BR.map(O.liftBranch).every(b=>X.canonicalFile(b).length>0));
  t('generated field at the reference state is Q(zeta_14) and the shell reference Q(zeta_24): both equal the export',()=>{const f=O.field(refSt);
    return ref!==null&&f.generated===14n&&f.generatedLabel==='\u211A(\u03B6\u2081\u2084)'&&f.shell===24n&&ref.cyclotomic_field_detail.generated==='\u211A(\u03B6_14)'&&ref.cyclotomic_field_detail.shell_reference==='\u211A(\u03B6_24)'&&ref.cyclotomic_field==='\u211A(\u03B6_14)';});
  // independent brute force: least n such that every phase x (e^{i pi x}) has n*x/2 an integer
  const bruteN=xs=>{for(let n=1n;n<100000n;n++)if(xs.every(x=>X.isInt(X.mul(x,X.rat(n,2n)))))return n;return null;};
  const phases=st=>{const R0=C.resolve(st),s=P(st.sTyped),Nq=X.rat(R0.N),xs=[];
    for(const c of C.offsets(R0.m)){xs.push(X.mul(R0.t1,s));xs.push(X.neg(X.div(X.mul(X.mul(X.rat(c),R0.t2),s),Nq)));}return xs;};
  t('ambient field derived from the definitions (carrier and offset phases separately, brute force) at the reference state is Q(zeta_14); the export states Q(zeta_56): difference recorded, not forced (56 = lcm(14, 2N))',()=>{
    const f=O.field(refSt);return ref!==null&&f.ambient===14n&&bruteN(phases(refSt))===14n&&ref.cyclotomic_field_detail.ambient==='\u211A(\u03B6_56)'&&56n%f.ambient===0n&&56n===14n*8n/X.gcd(14n,8n);});
  t('ambient field equals the brute-force least n over 1,500 random states; generated divides ambient',()=>{
    let bad=0;for(let i=0;i<1500;i++){
      const st=S({N:ri(1,40),m:ri(2,9),t1:pick(['1','2','1/2','-3','3/2','0','5/3']),t2:pick(['1','3','1/3','-2','0','7/4']),n6:pick(['1','-1','2']),s:pick(['1','4/7','-3/5','7/3','5','1/12','0','9/4'])});
      const f=O.field(st);if(f.ambient!==bruteN(phases(st))||f.ambient%f.generated!==0n)bad++;}
    return bad===0;});
  t('generated field equals the brute-force least n over the tooth phases e^{i pi k_c s/N} (1,500 random states)',()=>{
    let bad=0;for(let i=0;i<1500;i++){
      const st=S({N:ri(1,40),m:ri(2,9),t1:pick(['1','2','1/2','-3','3/2','0']),t2:pick(['1','3','1/3','-2','0']),n6:pick(['1','-1','2']),s:pick(['1','4/7','-3/5','7/3','5','1/12','0','9/4'])});
      const f=O.field(st),xs=C.teeth(st).map(x=>x.phase);if(f.generated!==bruteN(xs))bad++;}
    return bad===0;});
  t('rho = 0 (n6 = 0): "zero amplitude \u2014 no generated field", ambient still defined; N = 0: field undefined',()=>{
    const z=O.field(C.initial({phi3:'21',m:'7',n6:'0',sTyped:'4/7'})),e=O.field(C.initial({phi3:'25',m:'3'}));
    return z.zeroAmplitude&&z.generated===null&&z.generatedLabel==='zero amplitude \u2014 no generated field'&&z.line.includes('zero amplitude')&&z.ambient===14n&&e.defined===false;});
  t('field line at the reference state: generated by the phase factors Q(zeta_14) and phase container (convention) Q(zeta_56), labelled as addendum 7 F7 specifies; N is not repeated in the line',()=>{const f=O.field(refSt);
    return f.line==='generated by the phase factors \u211A(\u03B6\u2081\u2084) \u00B7 phase container (convention) \u211A(\u03B6\u2085\u2086) (exact)'&&f.generated===14n&&f.phaseContainer===56n&&f.hostAmbientEquivalent===true&&f.twoqN===56n&&f.L_k===1n&&!/N = /.test(f.line);});
  t('phase container equals the frozen export ambient Q(zeta_56) at the reference state, with the full factor 2qN = 2*7*4',()=>{const c=C.cyclotomic(refSt);return ref!==null&&c.phaseContainer===2n*7n*4n&&c.generated===14n&&c.hostAmbientEquivalent&&ref.cyclotomic_field_detail.ambient==='\u211A(\u03B6_56)'&&ref.cyclotomic_field_detail.generated==='\u211A(\u03B6_14)';});
  t('phase container holds every tooth phase exp(i pi k s/N), contains the generated field, and carries D (lcm of the k_c denominators) when some k_c is not an integer (2,000 random states incl. fractional t1, t2)',()=>{
    let bad=0,withD=0;for(let i=0;i<2000;i++){
      const st=S({N:ri(1,40),m:ri(2,9),t1:pick(['1','2','1/2','-3','3/2','0','5/3']),t2:pick(['1','3','1/3','-2','0','7/4']),n6:pick(['1','-1','2']),s:pick(['1','4/7','-3/5','7/3','5','1/12','0','9/4'])});
      const c=C.cyclotomic(st),R=C.resolve(st),sq=P(st.sTyped),Ts=C.teeth(st,R),allInt=Ts.every(x=>x.k.d===1n);
      const holds=Ts.every(x=>X.isInt(X.mul(X.div(X.mul(x.k,sq),X.rat(R.N)),X.rat(c.phaseContainer,2n))));
      if(!holds||c.phaseContainer%c.twoqN!==0n||c.twoqN!==2n*sq.d*R.N||c.hostAmbientEquivalent!==allInt||(allInt&&c.phaseContainer!==c.twoqN)||(c.generated!==null&&c.phaseContainer%c.generated!==0n))bad++;
      if(!allInt){withD++;const f=O.field(st);let Lk=1n;for(const x of Ts)Lk=Lk/X.gcd(Lk,x.k.d)*x.k.d;
        if(f.L_k!==Lk||f.phaseContainer!==2n*sq.d*R.N*Lk||f.containerLabel!==O.zeta(2n*sq.d*R.N*Lk))bad++;}}
    return bad===0&&withD>50;});
  t('exact JSON and Lift cyclotomic_field name the fields generated and phase_container, with host_ambient_equivalent',()=>{
    const j=C.cycloJson(refSt);const ex=X.parseStrict(C.exportExact(refSt,null,{})).exact.cyclotomic_field;
    return j.generated==='\u211A(\u03B6_14)'&&j.phase_container==='\u211A(\u03B6_56)'&&j.host_ambient_equivalent===true&&j.phase_container_factor==='2qN'&&j.L_k==='1'&&j.phase_container_formula==='C = 2*q*N*L_k'&&X.canonical(ex)===X.canonical(j)
      &&C.cycloJson(C.initial({phi3:'25',m:'3'})).status!==undefined;});
  t('fractional k_c (L_k = 3): phase container C = 2*q*N*L_k = 120 (factor 2qN*L_k) and host_ambient_equivalent is false',()=>{const st=S({N:4,m:3,t1:'1/3',t2:'1',n6:'1',s:'3/5'});const c=C.cyclotomic(st),j=C.cycloJson(st);return c.kDenominatorLcm===3n&&c.phaseContainer===2n*5n*4n*3n&&j.host_ambient_equivalent===false&&j.phase_container_factor==='2qN*L_k'&&j.L_k==='3'&&j.phase_container==='\u211A(\u03B6_120)'&&O.field(st).line==='generated by the phase factors '+O.field(st).generatedLabel+' \u00B7 phase container (convention) '+O.zeta(120n)+' (exact)';});
  // orbit property tests
  const rq=()=>pick(['1','2','3','1/2','1/3','2/3','5/4','-1','-2','-3/2','7/5','4','0']);
  t('closure period is the least s > 0 at which both phases return mod 2 (brute force over the carrier return times j*2/|t1|, or the offset return times when t1 = 0; 600 random states)',()=>{
    let bad=0,n=0;for(let i=0;i<600;i++){
      const N=ri(1,9),st=S({N,m:ri(2,6),t1:rq(),t2:rq(),s:0}),R0=C.resolve(st);
      for(const b of O.branches(st)){
        if(b.status!=='defined')continue;n++;
        const ct=X.mul(X.rat(b.c),R0.t2),step=R0.t1.n!==0n?X.rat(2n*R0.t1.d,R0.t1.n<0n?-R0.t1.n:R0.t1.n):X.rat(2n*R0.N*ct.d,ct.n<0n?-ct.n:ct.n),grid=step;
        const ret=s=>X.isInt(X.div(X.mul(R0.t1,s),X.rat(2n)))&&X.isInt(X.div(X.div(X.mul(X.mul(X.rat(b.c),R0.t2),s),X.rat(R0.N)),X.rat(2n)));
        let found=null;for(let j=1n;j<=200000n;j++){const s=X.mul(grid,X.rat(j));if(ret(s)){found=s;break;}}
        if(found===null||!X.eq(found,b.closurePeriod))bad++;
        const np=NUM.orbitPeriod(R0.t1,R0.t2,b.c,R0.N);if(np&&!X.eq(np,b.closurePeriod))bad++;}}
    return bad===0&&n>1000;});
  t('primitive winding has gcd 1; cleared = d * primitive; d = gcd of the cleared rate; cleared = L * raw with L the lcm of the denominators (800 random states, rational gears)',()=>{
    let bad=0,n=0;for(let i=0;i<800;i++){
      const st=S({N:ri(1,30),m:ri(2,9),t1:rq(),t2:rq(),s:0});
      for(const b of O.branches(st)){
        if(b.status!=='defined')continue;n++;const [a,c2]=b.clearedRate,[p,q]=b.primitive,L=b.denominatorScale;
        if(X.gcd(p,q)!==1n||a!==p*b.commonFactor||c2!==q*b.commonFactor||b.commonFactor!==X.gcd(a,c2))bad++;
        const [r1,r2]=b.rawRate;if(r1.n*L!==a*r1.d||r2.n*L!==c2*r2.d||L<1n)bad++;
        if(L!==(r1.d/X.gcd(r1.d,r2.d)*r2.d))bad++;}}
    return bad===0&&n>2000;});
  t('knot class: UNKNOT iff |p| <= 1 or |q| <= 1; otherwise T(min,max) with chirality sign(p q); chi = sign(p q), "0" when p q = 0 (random)',()=>{
    let bad=0,tor=0;for(let i=0;i<800;i++){
      const st=S({N:ri(1,30),m:ri(2,9),t1:rq(),t2:rq(),s:0});
      for(const b of O.branches(st)){
        if(b.status!=='defined')continue;const [p,q]=b.primitive,ap=p<0n?-p:p,aq=q<0n?-q:q,sg=(p>0n?1:p<0n?-1:0)*(q>0n?1:q<0n?-1:0),chi=sg>0?'+':sg<0?'\u2212':'0';
        const wantUn=ap<=1n||aq<=1n;
        if(b.chi!==chi)bad++;
        if(wantUn){if(b.knotClass!=='UNKNOT'||b.canonicalType!=='UNKNOT')bad++;}
        else{tor++;const lo=ap<aq?ap:aq,hi=ap<aq?aq:ap;if(b.knotClass!=='NONTRIVIAL_TORUS_KNOT'||b.canonicalType!=='T('+lo+','+hi+')'+chi)bad++;}}}
    return bad===0&&tor>100;});
  t('mirror (t2 -> -t2) keeps the torus type and flips the chirality sign of every nontrivial branch',()=>{
    let bad=0,n=0;for(const [t1,t2] of [['1','1'],['2','1'],['3','2'],['1','3']]){
      const a=O.branches(S({N:5,m:9,t1,t2,s:0})),b=O.branches(S({N:5,m:9,t1,t2:'-'+t2,s:0}));
      a.forEach((x,i)=>{const y=b[i];if(x.knotClass!=='NONTRIVIAL_TORUS_KNOT')return;n++;if(y.canonicalType.slice(0,-1)!==x.canonicalType.slice(0,-1)||y.chi===x.chi)bad++;});}
    return bad===0&&n>3;});
  t('stationary and undefined branches are labelled, never omitted: t1 = t2 = 0 -> all stationary; N = 0 -> all undefined; t1 = 0, t2 != 0 -> c = 0 stationary, others UNKNOT (0,+-1)',()=>{
    const a=O.branches(S({N:5,m:5,t1:0,t2:0,s:1})),z=O.branches(C.initial({phi3:'25',m:'6'})),c=O.branches(S({N:5,m:5,t1:0,t2:2,s:1}));
    return a.length===5&&a.every(b=>b.status==='stationary'&&b.knotClass==='STATIONARY'&&b.closurePeriod===null&&b.chi==='0')
      &&z.length===6&&z.every(b=>b.status==='undefined'&&b.canonicalType==='UNDEFINED')&&z.map(O.liftBranch).every(b=>b.knot_class==='UNDEFINED')
      &&c.length===5&&c.every(b=>b.c===0n?b.status==='stationary':(b.status==='defined'&&b.knotClass==='UNKNOT'&&b.primitive[0]===0n))
      &&a.map(O.liftBranch).every(b=>b.closure_period_s===null&&b.common_factor==='0')&&O.chipText(a[0]).includes('stationary');});
  t('rational gears: the cleared rate uses the common denominator L (t1 = 1/2, t2 = 1/3, N = 4, c = 1: raw (2, -1/3), L = 3, cleared (6, -1))',()=>{
    const b=O.branches(S({N:4,m:3,t1:'1/2',t2:'1/3',s:0})).find(x=>x.c===1n);
    return b.denominatorScale===3n&&b.clearedRate[0]===6n&&b.clearedRate[1]===-1n&&b.commonFactor===1n&&b.primitive.join()==='6,-1'&&b.knotClass==='UNKNOT';});
  t('chip text carries c, raw, primitive, multiplicity and type (reference c = -3 and c = -2)',()=>O.chipText(BR[0])==='c \u22123 \u00B7 raw (4,3) \u00B7 primitive (4,3) \u00D71 \u00B7 T(3,4)+'&&O.chipText(BR[1])==='c \u22122 \u00B7 raw (4,2) \u00B7 primitive (2,1) \u00D72 \u00B7 UNKNOT');
  // branch visibility (drawing register: in the view string of the address, never in the exact export)
  t('branch visibility codes round-trip over random subsets and survive the state address; the exact export does not contain them',()=>{
    let bad=0;for(let i=0;i<300;i++){
      const m=ri(2,12),cs=C.offsets(m),keep=new Set(cs.filter(()=>rnd()<0.5).map(String)),vis=c=>keep.has(String(c)),code=VW.branchStr(vis,cs),back=VW.branchVis(code);
      if(!cs.every(c=>back(c)===vis(c)))bad++;
      const st={...C.initial({m:String(m)}),view:code?'ch='+code:''};
      const r=C.decodeAddress(C.encodeAddress(st));if(!r.ok||r.state.view!==st.view)bad++;
      if(C.exportExact(st).includes('ch='))bad++;}
    return bad===0&&VW.branchStr(()=>true,C.offsets(5))===''&&VW.branchStr(()=>false,C.offsets(5))==='v:'&&VW.branchVis('v:')(0n)===false&&VW.branchVis('')(0n)===true;});
  // Hopf comb-walk edges: the true curve on S2
  const sph2=(p,q)=>2*Math.asin(Math.min(1,Math.hypot(p[0]-q[0],p[1]-q[1],p[2]-q[2])/2)),DEG=Math.PI/180;
  const maxStep=c=>{let m=0;for(let i=1;i<c.length;i++)if(c[i]&&c[i-1])m=Math.max(m,sph2(c[i],c[i-1]));return m;};
  t('edge curve: at least 32 samples, consecutive sphere points at most 2 degrees apart, endpoints are the mapped vertices (short and long edges)',()=>{
    for(const [a,b] of [[{re:0,im:0},{re:3,im:1}],[{re:0.1,im:0},{re:1e6,im:0}],[{re:-2,im:1},{re:4,im:-3}],[{re:1,im:1},{re:1.001,im:1}]]){
      const c=NUM.edgeCurve(a,b,1);if(c.length<33||c.some(x=>!x)||maxStep(c)>2*DEG*(1+1e-9))return false;
      const e0=NUM.fromAffine(a),e1=NUM.fromAffine(b);if(Math.hypot(...c[0].map((x,i)=>x-e0[i]))>1e-12||Math.hypot(...c[c.length-1].map((x,i)=>x-e1[i]))>1e-12)return false;}
    return true;});
  t('edge curve: every sample is the fromAffine image of a point of the planar segment (inverse stereographic collinearity): the true curve, not a chord',()=>{
    const a={re:-2,im:1},b={re:4,im:-3},c=NUM.edgeCurve(a,b,1);let worst=0;
    for(const p of c){const w={re:p[0]/(1-p[2]),im:p[1]/(1-p[2])},u=((w.re-a.re)*(b.re-a.re)+(w.im-a.im)*(b.im-a.im))/((b.re-a.re)**2+(b.im-a.im)**2),
      off=Math.hypot(a.re+u*(b.re-a.re)-w.re,a.im+u*(b.im-a.im)-w.im);worst=Math.max(worst,off,u<-1e-9||u>1+1e-9?1:0);}
    const e0=NUM.fromAffine(a),e1=NUM.fromAffine(b),chordAngle=sph2(e0,e1);
    return worst<1e-9&&c.length>=33&&maxStep(c)<=2*DEG*(1+1e-9)&&c.length>chordAngle/(2*DEG);});
  t('edge curve: the polyline is broken near the north pole (null samples), finite steps keep the 2-degree bound, and the chart scale divides the plane',()=>{
    const c=NUM.edgeCurve({re:0,im:0},{re:1e14,im:3e13},1),n=c.filter(x=>!x).length;
    const d=NUM.edgeCurve({re:0,im:0},{re:5,im:0},5),e=NUM.edgeCurve({re:0,im:0},{re:1,im:0},1);
    return n>0&&c[0]!==null&&c[c.length-1]===null&&maxStep(c)<=2*DEG*(1+1e-9)&&Math.hypot(...d[d.length-1].map((x,i)=>x-e[e.length-1][i]))<1e-12;});
  t('edge curve: a zero-length edge is one repeated point (no division by zero, no null)',()=>{const c=NUM.edgeCurve({re:2,im:0},{re:2,im:0},1);return c.length>=33&&c.every(p=>p&&Math.hypot(...p.map((x,i)=>x-c[0][i]))<1e-15);});
  t('comb walk at the example state: all 7 edges are curves of more than 32 samples with step <= 2 degrees, ending at the mapped vertices',()=>{
    const st=C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'0',sTyped:'408/125'}),num=NUM.compute(st);
    let worst=0;for(let i=0;i<num.W.length-1;i++){const c=NUM.edgeCurve(num.W[i],num.W[i+1],num.scale);if(c.length<33||c.some(x=>!x))return false;worst=Math.max(worst,maxStep(c));
      const v0=NUM.fromAffine(num.W[i]),v1=NUM.fromAffine(num.W[i+1]);if(Math.hypot(...c[0].map((x,k)=>x-v0[k]))>1e-9||Math.hypot(...c[c.length-1].map((x,k)=>x-v1[k]))>1e-9)return false;}
    return worst<=2*DEG*(1+1e-9);});
}

// ---------- v0.2 Release A fix round (addendum 7): lift gates, computed from the state
{
  const G=O.gates,keys=['exact_rational_lift','closed_orbits','integral_frequencies','prime_pair','rank4_smith_monodromy'];
  const ref=C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'1',sTyped:'4/7'});
  t('gates: the five gate keys exist; prime_pair is SEPARATE_GATE and rank4_smith_monodromy is OUT_OF_SCOPE, with the reasons of addendum 7',()=>{const g=G(ref);
    return JSON.stringify(Object.keys(g).sort())===JSON.stringify(keys.slice().sort())&&g.prime_pair.status==='SEPARATE_GATE'&&g.prime_pair.reason==='requires integral selected frequencies and independent primality evidence'
      &&g.rank4_smith_monodromy.status==='OUT_OF_SCOPE'&&g.rank4_smith_monodromy.reason==='Rank-4 monodromy has its own viewer (saphir, 2026-10-13)';});
  t('gate exact_rational_lift PASS at the reference state (t1, t2, s exact rationals)',()=>G(ref).exact_rational_lift.status==='PASS');
  t('gate exact_rational_lift FAIL when s (or t1) is not an exact rational: it lists the failing names',()=>{const g1=G({...ref,sTyped:'not a number'}).exact_rational_lift,g2=G({...ref,t1:'1/0'}).exact_rational_lift;
    return g1.status==='FAIL'&&g1.failing.join()==='s'&&g2.status==='FAIL'&&g2.failing.join()==='t1';});
  t('gate closed_orbits PASS at the reference state (all 7 branches have a finite exact closure period)',()=>{const g=G(ref).closed_orbits;return g.status==='PASS'&&g.failing.length===0;});
  t('gate closed_orbits FAIL when both gears are 0 (every branch stationary) and lists all c; FAIL at N = 0 (undefined branches)',()=>{
    const st=C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'3',t1:'0',t2:'0',sTyped:'1'}),g=G(st).closed_orbits,e=G(C.initial({phi3:'25',m:'3'})).closed_orbits;
    return g.status==='FAIL'&&g.failing.join()==='-1,0,1'&&e.status==='FAIL'&&e.failing.length===3;});
  t('gate closed_orbits is per branch: t1 = 0, t2 = 1, m = 5 makes only the tooth c = 0 stationary: FAIL listing exactly c = 0',()=>{
    const g=G(C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'5',t1:'0',t2:'1',sTyped:'1'})).closed_orbits;return g.status==='FAIL'&&g.failing.join()==='0';});
  t('gate integral_frequencies PASS at the reference state (every k_c an integer)',()=>{const g=G(ref).integral_frequencies;return g.status==='PASS'&&g.failing.length===0;});
  t('gate integral_frequencies FAIL for t1 = 1/3 at N = 4, m = 3 (k_c = 4/3 + c): all three branches listed',()=>{
    const g=G(C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'3',t1:'1/3',t2:'1',sTyped:'3/5'})).integral_frequencies;return g.status==='FAIL'&&g.failing.join()==='-1,0,1';});
  t('gate integral_frequencies is per branch: t2 = 1/2, t1 = 1, N = 4: m = 4 (k_c = 4 + c/2, c odd) fails for every c; m = 5 fails only for c = -1, 1',()=>{
    const a=G(C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'4',t1:'1',t2:'1/2',sTyped:'1'})).integral_frequencies,b=G(C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'5',t1:'1',t2:'1/2',sTyped:'1'})).integral_frequencies;
    return a.status==='FAIL'&&a.failing.join()==='-3,-1,1,3'&&b.status==='FAIL'&&b.failing.join()==='-1,1';});
  t('gates are never constant: over 600 random states each computed gate takes both PASS and FAIL, and agrees with a direct definition',()=>{
    const seen={closed_orbits:new Set(),integral_frequencies:new Set()};let bad=0;
    for(let i=0;i<600;i++){const st=S({N:ri(0,12),m:ri(2,7),t1:pick(['1','2','1/2','-3','3/2','0','5/3']),t2:pick(['1','3','1/3','-2','0','7/4']),n6:'1',s:pick(['1','4/7','-3/5','7/3','0'])}),g=G(st),R=C.resolve(st);
      seen.closed_orbits.add(g.closed_orbits.status);seen.integral_frequencies.add(g.integral_frequencies.status);
      const cs=C.offsets(R.m);
      const wantInt=R.N>0n?cs.filter(c=>!X.isInt(X.add(X.mul(X.rat(R.N),R.t1),X.mul(X.rat(c),R.t2)))).map(String):cs.map(String);
      const wantClosed=R.N>0n?cs.filter(c=>R.t1.n===0n&&X.mul(X.rat(c),R.t2).n===0n).map(String):cs.map(String);
      if(g.integral_frequencies.failing.join()!==wantInt.join()||g.closed_orbits.failing.join()!==wantClosed.join()||(wantInt.length===0)!==(g.integral_frequencies.status==='PASS')||(wantClosed.length===0)!==(g.closed_orbits.status==='PASS')||g.exact_rational_lift.status!=='PASS')bad++;}
    return bad===0&&seen.closed_orbits.size===2&&seen.integral_frequencies.size===2;});
}
t('rho irrational flag: N = 2, alpha = 1/2 irrational (sqrt 2); N = 4, alpha = 1/2 rational (2); alpha integer, n6 = 0 and N = 1 rational; export carries rho_irrational',()=>{
  const f=(N,al,n6)=>C.cyclotomic(S({N,m:3,t1:1,t2:1,n6:n6||'1',alpha:al,s:0}));
  return f(2,'1/2').rhoIrrational===true&&f(4,'1/2').rhoIrrational===false&&f(8,'2/3').rhoIrrational===false&&f(2,'1').rhoIrrational===false&&f(2,'1/2','0').rhoIrrational===false&&f(1,'1/2').rhoIrrational===false
    &&f(2,'1/2').generated===1n&&C.cycloJson(S({N:2,m:3,t1:1,t2:1,alpha:'1/2',s:0})).rho_irrational===true&&/phase factors/.test(C.cycloJson(refSt0()).note)&&!/minimal field of the/.test(C.cycloJson(refSt0()).note)&&O.field(S({N:2,m:3,t1:1,t2:1,alpha:'1/2',s:0})).rhoIrrational===true;});
t('fix round 2026-10-14: N = 2, m = 2, t1 = 1, t2 = 2: tooth c = -1 has k_c = 0 but is baseFixed (not stationary): s2 empty, s3 finite, period 2; c = +1 moves normally',()=>{
  const st=C.initial({shellMode:'integer',B:'2',phi3:'1',m:'2',t1:'1',t2:'2',n6:'1',alpha:'0',sTyped:'1',chart:'host'}),R=C.resolve(st),o=NUM.orbits(st,NUM.compute(st)),a=o.find(x=>x.c===-1||String(x.c)==='-1'),b=o.find(x=>String(x.c)==='1');
  return String(R.N)==='2'&&!!a&&!!b&&a.stationary===false&&a.baseFixed===true&&a.s2.length===0&&a.s3.length>1&&a.s3.every(v=>v===null||(v.length===3&&v.every(Number.isFinite)))&&a.s3.some(v=>v!==null)&&a.period==='2'
    &&b.stationary===false&&b.baseFixed===false&&b.s2.length>1&&b.s3.length>1;});
t('fix round 2026-10-14: t1 = 0, t2 = 0 keeps every tooth stationary; t1 = 0, t2 = 1, m = 3: c = 0 stationary, the others moving',()=>{
  const a=C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'3',t1:'0',t2:'0',sTyped:'1'}),oa=NUM.orbits(a,NUM.compute(a));
  const b=C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'3',t1:'0',t2:'1',sTyped:'1'}),ob=NUM.orbits(b,NUM.compute(b));
  return oa.length===3&&oa.every(x=>x.stationary&&x.s2.length===0&&x.s3.length===0)&&ob.length===3&&ob.filter(x=>x.stationary).map(x=>String(x.c)).join()==='0'&&ob.filter(x=>!x.stationary).every(x=>x.s2.length>1&&x.s3.length>1&&!x.baseFixed);});
function refSt0(){return C.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'1',sTyped:'4/7'});}
// ---------- v0.3 step 1: continuous N, option B (SCHEMA_ADDENDUM_8; handoff s2 conditions 1-6)
{
  // a state with an exact rational N = B + 1 - phi3 (continuous mode, integer base B)
  const Q=o=>{const B=BigInt(o.B||24),Nq=P(String(o.N)),phi3=X.sub(X.rat(B+1n),Nq);
    let st=C.initial({shellMode:'integer',B:String(B),nMode:'continuous',phi3:T(phi3),m:String(o.m||3),t1:String(o.t1===undefined?1:o.t1),t2:String(o.t2===undefined?1:o.t2),n6:o.n6||'1',alpha:o.alpha||'0',sTyped:String(o.s===undefined?'1/3':o.s),chart:'host'});
    if(o.sEff!==undefined)st={...st,sEff:String(o.sEff)};if(o.E!==undefined)st={...st,E:String(o.E)};return st;};
  const LBL=n=>'between shells: N = '+n+'; shell arithmetic undefined';
  const rq=()=>pick(['1','2','3','1/2','1/3','2/3','5/4','-1','-2','-3/2','7/5','4']);
  const ratN=()=>{const b=BigInt(ri(1,9)),a=BigInt(ri(1,60));return X.rat(a,b);};                 // N = a/b, often non-integer
  const RS=()=>{const N=ratN();return Q({N:T(N),B:61,m:ri(2,9),t1:rq(),t2:rq(),n6:pick(['1','-1','2']),s:pick(['1','4/7','-3/5','7/3','5','1/12','0','9/4','13/6'])});};
  const red=x=>{const two=X.rat(2n);let r=X.sub(x,X.mul(two,X.rat(X.ceil(X.div(X.sub(x,X.rat(1n)),two)))));return r;};   // x mod 2 into (-1, 1], independent of comb-core
  const ordOf=x=>X.div(x,X.rat(2n)).d;                                                                  // order of e^{i pi x}
  const bruteN=xs=>{for(let n=1n;n<200000n;n++)if(xs.every(x=>X.isInt(X.mul(x,X.rat(n,2n)))))return n;return null;};
  t('v0.3 resolve: nMode default integer; continuous phi3 accepts 7/2, 3.5 and 0 (stored as canonical exact text); Nq always, N only on a shell, Nint; integer mode still refuses 7/2; continuous range 0..B+1',()=>{
    const d=C.initial(),a=C.initial({nMode:'continuous',phi3:'3.5'}),b=C.initial({nMode:'continuous',phi3:'7/2'}),z=C.initial({nMode:'continuous',phi3:'0'}),Ra=C.resolve(a),Rz=C.resolve(z);
    const thr=f=>{try{f();return false;}catch(e){return /φ₃|rational|integer|exact/.test(e.message);}};
    return d.nMode==='integer'&&a.phi3==='7/2'&&b.phi3==='7/2'&&z.phi3==='0'&&T(Ra.Nq)==='43/2'&&Ra.N===null&&Ra.Nint===false&&Ra.phi3===null&&T(Ra.phi3q)==='7/2'
      &&Rz.N===25n&&Rz.Nint===true&&Rz.phi3===0n&&thr(()=>C.initial({phi3:'7/2'}))&&thr(()=>C.initial({nMode:'continuous',phi3:'51/2'}))&&thr(()=>C.initial({nMode:'continuous',phi3:'-1/2'}))
      &&C.resolve(C.initial({nMode:'continuous',phi3:'25'})).N===0n&&thr(()=>C.initial({nMode:'other'}));});
  t('v0.3 rational-N phases equal a direct computation (k_c = N t1 + c t2, phase k_c s/N mod 2, carrier t1 s (+1 if n6 < 0), offset -c t2 s/N, every order), and the numerical tooth equals rho*exp(i pi k_c s/N) from floats (1,000 random rational-N states, more than 500 of them between shells)',()=>{
    let bad=0,nonInt=0,num=0;for(let i=0;i<1000;i++){const st=RS(),R=C.resolve(st),s=P(st.sTyped);if(!R.Nint)nonInt++;
      const Ts=C.teeth(st,R);C.offsets(R.m).forEach((c,j)=>{const t0=Ts[j],k=X.add(X.mul(R.Nq,R.t1),X.mul(X.rat(c),R.t2)),ph=red(X.div(X.mul(k,s),R.Nq)),car=red(X.add(X.mul(R.t1,s),X.rat(R.n6.n<0n?1n:0n))),off=red(X.neg(X.div(X.mul(X.mul(X.rat(c),R.t2),s),R.Nq)));
        if(t0.c!==c||!X.eq(t0.k,k)||!X.eq(t0.phase,ph)||t0.order!==ordOf(ph)||!X.eq(t0.carrier,car)||t0.carrierOrder!==ordOf(car)||!X.eq(t0.offset,off)||t0.offsetOrder!==ordOf(off))bad++;});
      const r=NUM.compute(st);if(r.refused)continue;num++;const f=q=>Number(q.n)/Number(q.d);
      r.z.forEach((z,j)=>{const k=Ts[j].k,th=Math.PI*f(k)*f(s)/f(R.Nq),re=r.radius*Math.cos(th),im=r.radius*Math.sin(th);if(Math.hypot(z.re-re,z.im-im)>1e-9*Math.max(1,Math.abs(r.radius)))bad++;});}
    console.log('     rational-N phases: 1000 states ('+nonInt+' between shells), numerical teeth compared in '+num+', mismatches '+bad);return bad===0&&nonInt>500&&num>900;});
  t('v0.3 ALIGN and SPREAD flags with rational N (exact, Nq in the existing formulas) agree with the numerical kernel |K_m(beta)| < 1e-9, beta = pi t2 s/N (2,000 random states)',()=>{
    let bad=0,zeros=0;for(let i=0;i<2000;i++){const b=ri(1,6),a=ri(1,40),N=a/b,m=ri(2,30),sd=pick([1,2,3,4,5,6,8,12]),sn=ri(-40,40)*(rnd()<0.5?1:sd),t2=pick(['1','2','3','1/2','3/2','-2','5']);
      const st=Q({N:a+'/'+b,B:41,m,t1:pick(['1','2','1/3']),t2,s:sn+'/'+sd}),rd=C.readouts(st),beta=Math.PI*Number(P(t2).n)/Number(P(t2).d)*sn/sd/N;
      let K;if(m%2){const d=Math.sin(beta/2);K=Math.abs(d)<1e-12?m:Math.sin(m*beta/2)/d;}else{const d=Math.sin(beta);K=Math.abs(d)<1e-12?m:Math.sin(m*beta)/d;}
      const z=Math.abs(K)<1e-9;if(rd.flagSpread!==z)bad++;if(z)zeros++;if(rd.flagAlign!==X.isInt(X.mul(P(st.t1),P(st.sTyped))))bad++;}
    console.log('     rational-N K_m flags: '+zeros+' zero-kernel states among 2000, disagreements '+bad);return bad===0&&zeros>30;});
  // handoff s2.1: R20 stepping
  t('v0.3 handoff 2.1 (R20, named state N = 7/2, m = 5, t1 = t2 = 1, s = 1/3): SPREAD refused (4e) "SPREAD needs an integer gearbox: N = 7/2"; forward lands on the ALIGN stop 1, backward on 0; label carries the refusal; no ALIGN stop skipped',()=>{
    const st=Q({N:'7/2',m:5,t1:1,t2:1,s:'1/3'}),set=C.stopSet(st),f=C.step(st,1),b=C.step(st,-1);
    const want='SPREAD needs an integer gearbox: N = 7/2';
    return set.active&&set.mode==='COMB'&&set.families.length===1&&set.families[0].kind==='ALIGN'&&set.refused.length===1&&set.refused[0].kind==='SPREAD'&&set.refused[0].source==='4e'&&set.refused[0].reason===want
      &&f.outcome==='stop'&&f.value==='1'&&b.outcome==='stop'&&b.value==='0'&&[f,b].every(r=>r.hits.every(h=>h.kind==='ALIGN')&&r.refused[0].reason===want&&r.label.includes('SPREAD refused (4e): '+want))
      &&ok(noSkip(st,f,1,set))&&ok(noSkip(st,b,-1,set))&&/SPREAD refused \(4e\): SPREAD needs an integer gearbox: N = 7\/2/.test(X.parseStrict(C.exportExact(st)).exact.stepping);});
  t('v0.3 handoff 2.1: 40 forward and 40 backward steps between shells (N = 43/2, m = 7, t1 = 2, t2 = 3) visit only ALIGN stops s in Z/2 and never a SPREAD stop; on the integer shell N = 21 of the same continuous mode SPREAD families are back (no refusal)',()=>{
    for(const dir of [1,-1]){let st=Q({N:'43/2',m:7,t1:2,t2:3,s:'1/5'});for(let i=0;i<40;i++){const r=C.step(st,dir);if(r.outcome!=='stop')break;if(!r.hits.every(h=>h.kind==='ALIGN')||!X.isInt(X.mul(P(r.value),X.rat(2n)))||!r.refused)return false;st=r.state;}}
    const on=C.stopSet(Q({N:'21',m:7,t1:2,t2:3}));return on.families.some(f=>f.kind==='SPREAD')&&!on.refused;});
  t('v0.3 handoff 2.1: PAIR (m = 2) works between shells as now (N = 7/2, s = 1/3: forward 1, backward 0, no refusal); refusals for t1 = 0 or non-integer gears are unchanged (4e with their own reason)',()=>{
    const st=Q({N:'7/2',m:2,s:'1/3'}),f=C.step(st,1),b=C.step(st,-1),z=C.step(Q({N:'7/2',m:3,t1:0,s:'1/3'}),1),h=C.step(Q({N:'7/2',m:3,t1:'1/2',s:'1/3'}),1);
    return f.value==='1'&&b.value==='0'&&!f.refused&&f.mode==='PAIR'&&z.outcome==='refused'&&/t₁ = 0/.test(z.reason)&&h.outcome==='refused'&&/Non-integer gears/.test(h.reason);});
  // handoff s2.2: R21 wrap gate
  t('v0.3 handoff 2.2 (R21) closed case N = 7/2, t1 = t2 = 1, m = 3: k_c = 7/2 + c not integers, gate closed; typed 9 is kept (s_eff = s_typed = 9, E = 9) and "kept: wrap not invariant here" applies; typed 3 (own representative) has no label',()=>{
    const st=Q({N:'7/2',m:3,t1:1,t2:1,s:'0'}),a=C.enterSpin(st,'9'),b=C.enterSpin(st,'3');
    return !C.gate(st)&&C.teeth(st).every(x=>x.k.d===2n)&&a.sTyped==='9'&&a.sEff==='9'&&a.E==='9'&&C.wrapKept(a)&&b.sEff==='3'&&b.E==='7/2'&&!C.wrapKept(b);});
  t('v0.3 handoff 2.2 open case N = 7/2, t1 = t2 = 2, m = 3: k_c = 7 + 2c, N t1 = 7, c t2 = 2c integers, gate open; typed 9 -> s_eff = 2 (mod 2N = 7), E = 7/2; the wrap is invariant: exact tooth, carrier and offset phases equal at s and s + 2N, floats of exp(i pi k_c s/N) and the numerical walk endpoints equal within the bound',()=>{
    const st=Q({N:'7/2',m:3,t1:2,t2:2,s:'0'}),w=C.enterSpin(st,'9');
    if(!C.gate(st)||C.teeth(st).map(x=>T(x.k)).join()!=='5,7,9'||w.sTyped!=='9'||w.sEff!=='2'||w.E!=='7/2')return false;
    for(const s of ['2','1/3','-5/7','3/2']){const s2=T(X.add(P(s),X.rat(7n))),A=C.teeth(Q({N:'7/2',m:3,t1:2,t2:2,s})),Bt=C.teeth(Q({N:'7/2',m:3,t1:2,t2:2,s:s2}));
      if(!A.every((x,i)=>X.eq(x.phase,Bt[i].phase)&&X.eq(x.carrier,Bt[i].carrier)&&X.eq(x.offset,Bt[i].offset)))return false;
      const na=NUM.compute(Q({N:'7/2',m:3,t1:2,t2:2,s,alpha:'1'})),nb=NUM.compute(Q({N:'7/2',m:3,t1:2,t2:2,s:s2,alpha:'1'})),ea=na.W[na.W.length-1],eb=nb.W[nb.W.length-1];
      if(Math.hypot(ea.re-eb.re,ea.im-eb.im)>na.bound)return false;
      const f=q=>Number(q.n)/Number(q.d);for(const x of A){const d=Math.PI*f(x.k)*f(P(s))/3.5,e=Math.PI*f(x.k)*f(P(s2))/3.5;if(Math.hypot(Math.cos(d)-Math.cos(e),Math.sin(d)-Math.sin(e))>1e-12)return false;}}
    return true;});
  // handoff s2.3: orbits
  t('v0.3 handoff 2.3 orbits with rational N = 7/2 (t1 = t2 = 1, m = 3): raw rate (7/2, -c), L = 2, cleared (7, -2c), c = 1: primitive (7,-2), T(2,7)-; closure periods c = +-1: 14, c = 0: 2 (exact)',()=>{
    const bs=O.branches(Q({N:'7/2',m:3,t1:1,t2:1})),b1=bs.find(b=>b.c===1n),b0=bs.find(b=>b.c===0n),bm=bs.find(b=>b.c===-1n);
    return b1.denominatorScale===2n&&b1.clearedRate.join()==='7,-2'&&b1.primitive.join()==='7,-2'&&b1.canonicalType==='T(2,7)−'&&T(b1.closurePeriod)==='14'&&T(bm.closurePeriod)==='14'&&T(b0.closurePeriod)==='2'&&b1.kIntegral===false&&T(b1.k)==='9/2';});
  t('v0.3 handoff 2.3 closure period with rational N is the least s > 0 at which both phases return mod 2 (brute force over the carrier return grid, 600 random rational-N states); numeric orbitPeriod agrees',()=>{
    let bad=0,n=0;for(let i=0;i<600;i++){const N=X.rat(BigInt(ri(1,30)),BigInt(ri(2,6))),st=Q({N:T(N),B:30,m:ri(2,6),t1:rq(),t2:rq()}),R0=C.resolve(st);
      for(const b of O.branches(st)){if(b.status!=='defined')continue;n++;
        const ct=X.mul(X.rat(b.c),R0.t2),grid=R0.t1.n!==0n?X.rat(2n*R0.t1.d,R0.t1.n<0n?-R0.t1.n:R0.t1.n):X.div(X.mul(X.rat(2n),R0.Nq),X.qabs(ct));
        const ret=s=>X.isInt(X.div(X.mul(R0.t1,s),X.rat(2n)))&&X.isInt(X.div(X.div(X.mul(ct,s),R0.Nq),X.rat(2n)));
        let found=null;for(let j=1n;j<=200000n;j++){const s=X.mul(grid,X.rat(j));if(ret(s)){found=s;break;}}
        if(found===null||!X.eq(found,b.closurePeriod))bad++;const np=NUM.orbitPeriod(R0.t1,R0.t2,b.c,R0.Nq);if(np&&!X.eq(np,b.closurePeriod))bad++;}}
    return bad===0&&n>1000;});
  t('v0.3 handoff 2.3 long-period rational case N = 1234567/1000 (B = 2000, m = 3, t1 = t2 = 1): orbits c = +-1 are partial (4,000 points) and the record keeps the exact closure period 2469134 (orbit period text, branch closure period and Lift closure_period_s)',()=>{
    const st=Q({N:'1234567/1000',B:2000,m:3,t1:1,t2:1,s:'1/3'}),num=NUM.compute(st),ob=NUM.orbits(st,num),bs=O.branches(st);
    const p=ob.filter(o=>o.c!==0n);return p.length===2&&p.every(o=>o.partial===true&&o.points===4000&&o.period==='2469134')&&bs.filter(b=>b.c!==0n).every(b=>T(b.closurePeriod)==='2469134'&&O.liftBranch(b).closure_period_s.text==='2469134')&&ob.find(o=>o.c===0n).period==='2';});
  // handoff s2.4: phase container
  t('v0.3 handoff 2.4 phase container generalised: N = a/b, s = p/q, C = 2*q*a*L_k; the order of every phase factor divides C, C = 2qN*L_k on a shell, generated = brute-force least n, host_ambient_equivalent iff N integer and L_k = 1 (1,500 random states, mostly between shells)',()=>{
    let bad=0,btw=0;for(let i=0;i<1500;i++){const st=RS(),R=C.resolve(st),c=C.cyclotomic(st),s=P(st.sTyped),Ts=C.teeth(st,R);if(!c.defined)continue;if(!R.Nint)btw++;
      let Lk=1n;for(const x of Ts)Lk=Lk/X.gcd(Lk,x.k.d)*x.k.d;const want=2n*s.d*R.Nq.n*Lk;
      if(c.phaseContainer!==want||!Ts.every(x=>want%x.order===0n)||(R.Nint&&want!==2n*s.d*R.N*Lk)||c.hostAmbientEquivalent!==(R.Nint&&Lk===1n))bad++;
      if(!Ts.every(x=>X.isInt(X.mul(X.div(X.mul(x.k,s),R.Nq),X.rat(want,2n)))))bad++;
      if(c.generated!==null&&(c.generated!==bruteN(Ts.map(x=>x.phase))||want%c.generated!==0n))bad++;}
    return bad===0&&btw>900;});
  t('v0.3 handoff 2.4 named state N = 7/2, t1 = t2 = 1, m = 3, s = 1/3: k_c = 5/2, 7/2, 9/2 (L_k = 2), a = 7, q = 3: C = 84, host_ambient_equivalent false, factor 2qa*L_k, formula "C = 2*q*a*L_k (N = a/b in lowest terms)", N "7/2" in the JSON; generated Q(zeta_42)',()=>{
    const st=Q({N:'7/2',m:3,t1:1,t2:1,s:'1/3'}),c=C.cyclotomic(st),j=C.cycloJson(st),f=O.field(st);
    return c.kDenominatorLcm===2n&&c.a===7n&&c.phaseContainer===84n&&c.generated===42n&&!c.hostAmbientEquivalent&&c.twoqN===null&&c.twoqa===42n&&j.phase_container==='ℚ(ζ_84)'&&j.phase_container_factor==='2qa*L_k'
      &&j.phase_container_formula==='C = 2*q*a*L_k (N = a/b in lowest terms)'&&j.N==='7/2'&&j.N_integer===false&&j.host_ambient_equivalent===false&&/C = 2\*q\*a\*L_k/.test(j.note)&&f.containerLabel==='ℚ(ζ₈₄)'&&f.line.includes('phase container (convention)');});
  // handoff s2.5: fraction stack
  t('v0.3 handoff 2.5 fraction stack: idle between shells with the label (N = 9/2, m = 5, s = 72/5); the integer shell N = 9 in continuous mode gives the integer-mode lattice (q = 5, 630 heads)',()=>{
    const a=FS.lattice(Q({N:'9/2',m:5,s:'72/5'})),b=FS.heads(Q({N:'9',m:5,s:'72/5'}));
    return a.idle&&a.reason===LBL('9/2')&&FS.caption(Q({N:'9/2',m:5,s:'72/5'}))==='fraction stack idle — '+LBL('9/2')&&!b.lattice.idle&&b.lattice.q===5n&&b.lattice.raw===630n&&b.heads.length===630;});
  // handoff s2.6: registers
  t('v0.3 handoff 2.6 registers: rho = n6*N^alpha is numerical from the float of Nq (N = 7/2, alpha = 1/2: sqrt 3.5 within the bound); rho_irrational is decided exactly from BigInts (7/2, 1/2: true; 9/4, 1/2: false; 8/27, 1/3 and 2/3: false; 9/4, 1/3: true; N = 1 never); the exact export of a between-shells state has no decimal float in it (the schema id aside)',()=>{
    const r=NUM.compute(Q({N:'7/2',alpha:'1/2'})),ir=(N,al)=>C.cyclotomic(Q({N,alpha:al})).rhoIrrational,ex=C.exportExact(Q({N:'7/2',alpha:'1/2',s:'2/3'}));
    return Math.abs(r.rho-Math.sqrt(3.5))<=r.bound&&r.bound>0&&ir('7/2','1/2')===true&&ir('9/4','1/2')===false&&ir('8/27','1/3')===false&&ir('8/27','2/3')===false&&ir('9/4','1/3')===true&&ir('1','1/2')===false
      &&!/\d\.\d/.test(ex.replace(/"schema":"[^"]*"/g,''))&&!/"rho"/.test(ex)&&X.parseStrict(ex).exact.cyclotomic_field.rho_irrational===true;});
  t('v0.3 numerical bound uses |ln N| (N = 1/2 between shells: positive, finite; N >= 1: the old formula 8(m + 2 + |alpha|(1 + ln N)) eps max(rho,1))',()=>{
    const a=NUM.compute(Q({N:'1/2',alpha:'3',m:3})),b=NUM.compute(Q({N:'5',alpha:'3',m:3})),E=Math.pow(2,-52);
    return a.bound>0&&Number.isFinite(a.bound)&&Math.abs(a.bound-8*(3+2+3*(1+Math.log(2)))*E*Math.max(a.rho,1))<1e-30&&Math.abs(b.bound-8*(3+2+3*(1+Math.log(5)))*E*Math.max(b.rho,1))<1e-30;});
  // integer-only readouts between shells
  t('v0.3 integer-only readouts switch off between shells with the label "between shells: N = 7/2; shell arithmetic undefined": both Wilson readouts, gearbox (BETWEEN_SHELLS, eligible false, no residency), divisors, shell contrast and bracket, Lift integral_frequencies (NOT_EVALUATED, reason), prime_pair reason; exports carry nMode, N "7/2", N_integer false',()=>{
    const st=Q({N:'7/2',m:5,s:'6'}),rd=C.readouts(st),g=rd.gearbox,dv=C.divisorsOf(st),ex=X.parseStrict(C.exportExact(st)),gt=O.gates(st),L=LBL('7/2');
    return rd.between===L&&rd.wilsonN.label===L&&rd.wilsonN.checked===false&&g.code==='BETWEEN_SHELLS'&&g.eligible===false&&g.resident===null&&g.remainder===null&&g.label===L&&dv.kind==='between'&&dv.label===L
      &&ex.exact.N==='7/2'&&ex.exact.N_integer===false&&ex.exact.nMode==='continuous'&&ex.state.nMode==='continuous'&&ex.exact.betweenShells===L&&ex.exact.shell.contrast===null&&ex.exact.shell.bracket===null&&ex.exact.shell.status===L
      &&ex.exact.divisors.kind==='between'&&ex.exact.wilsonN===L&&ex.exact.gearboxCode==='BETWEEN_SHELLS'&&gt.integral_frequencies.status==='NOT_EVALUATED'&&gt.integral_frequencies.reason===L&&gt.prime_pair.reason.endsWith(L)
      &&gt.closed_orbits.status==='PASS'&&gt.exact_rational_lift.status==='PASS'&&ex.schema==='fv-comb-hopf/0.2';});
  t('v0.3 continuous mode on an integer shell equals integer mode: for 400 random integer-shell states the continuous copy gives identical teeth, readouts, stop set, gates, branches, cyclotomic JSON, divisors and exact export apart from nMode',()=>{
    let bad=0;const big=x=>JSON.stringify(x,(k,v)=>typeof v==='bigint'?'b'+v:v);
    for(let i=0;i<400;i++){const N=ri(0,40),a=S({N,m:ri(2,9),t1:rq(),t2:rq(),n6:pick(['1','-1','2']),s:pick(['1','4/7','-3/5','7/3','5','0'])}),b=C.dialChange(a,{nMode:'continuous'});
      if(b.phi3!==a.phi3||b.sEff!==a.sEff||b.E!==a.E)bad++;
      const ea=X.parseStrict(C.exportExact(a)),eb=X.parseStrict(C.exportExact(b));ea.state.nMode=eb.state.nMode;ea.exact.nMode=eb.exact.nMode;
      if(big(ea)!==big(eb)||big(C.teeth(a))!==big(C.teeth(b))||big(C.readouts(a))!==big(C.readouts(b))||big(C.stopSet(a))!==big(C.stopSet(b))||big(O.gates(a))!==big(O.gates(b))||big(O.branches(a))!==big(O.branches(b))||big(C.cycloJson(a))!==big(C.cycloJson(b)))bad++;}
    return bad===0;});
  // address and records
  t('v0.3 address round trip with nMode = continuous and fractional phi3 (7/2); state JSON round trip; refusals: phi3 "3.5" in an address (non-canonical), phi3 7/2 with nMode integer, a 0.2 address without nMode, an unknown nMode',()=>{
    const st={...Q({N:'43/2',m:5,s:'1/3'}),tab:'hopf',view:'hz=2'},a=C.encodeAddress(st),r=C.decodeAddress(a),j=C.importAny(C.exportState(st));
    return st.phi3==='7/2'&&a.startsWith('#v=fv-comb-hopf/0.2&')&&a.includes('&nMode=continuous&phi3=7/2&')&&r.ok&&JSON.stringify(r.state)===JSON.stringify(Object.fromEntries(C.ADDRESS_KEYS.map(k=>[k,st[k]])))&&r.upgraded===false
      &&j.ok&&j.state.phi3==='7/2'&&j.state.nMode==='continuous'&&!C.decodeAddress(a.replace('phi3=7/2','phi3=3.5')).ok&&!C.decodeAddress(a.replace('nMode=continuous','nMode=integer')).ok
      &&!C.decodeAddress(a.replace('&nMode=continuous','')).ok&&!C.decodeAddress(a.replace('nMode=continuous','nMode=rational')).ok&&X.parseStrict(C.exportState(st)).schema==='fv-comb-hopf-state/0.2';});
  t('v0.3 0.1 address upgrade (the only upgrade rule): a v0.2-era address without nMode loads as nMode = integer, every other key unchanged, and re-encodes as 0.2; a 0.1 address carrying nMode is refused; a 0.1 state JSON is refused (unknown schema)',()=>{
    const old='#v=fv-comb-hopf/0.1&shellMode=factorial&n1=4&B=24&phi3=6&m=3&t1=1&t2=-21/4&n6=1&alpha=-1/50&chart=host&sTyped=-627/250&sEff=-627/250&E=19&tab=clifford&view=';   // the v0.2 perf reproduction address
    const r=C.decodeAddress(old),j=C.exportState(C.initial()).replace('fv-comb-hopf-state/0.2','fv-comb-hopf-state/0.1');
    return r.ok&&r.upgraded===true&&r.state.nMode==='integer'&&r.state.phi3==='6'&&r.state.t2==='-21/4'&&r.state.tab==='clifford'&&C.resolve(r.state).N===19n
      &&C.encodeAddress(r.state)===old.replace('fv-comb-hopf/0.1','fv-comb-hopf/0.2').replace('&phi3=6','&nMode=integer&phi3=6')&&C.importAny(old).ok
      &&!C.decodeAddress(old.replace('&phi3=6','&nMode=integer&phi3=6')).ok&&!C.importAny(j).ok;});
  t('v0.3 mode switch: integer -> continuous keeps phi3 (23 stays 23); continuous -> integer rounds a non-integer phi3 to the nearest shell and says so (7/2 -> 4 tie upward, 13/4 -> 3, 27/4 -> 7), never silently; an integer phi3 switches without a note',()=>{
    const a=C.switchNMode(C.initial(),'continuous'),sw=g=>C.switchNMode(C.initial({nMode:'continuous',phi3:g}),'integer');
    const r1=sw('7/2'),r2=sw('13/4'),r3=sw('27/4'),r4=sw('5');
    return a.state.nMode==='continuous'&&a.state.phi3==='23'&&a.note===''&&r1.state.phi3==='4'&&r1.state.nMode==='integer'&&r1.note==='N continuous → integer: φ₃ = 7/2 rounded to the nearest shell φ₃ = 4 (N = 21).'
      &&r2.state.phi3==='3'&&r3.state.phi3==='7'&&/rounded/.test(r2.note)&&r4.state.phi3==='5'&&r4.note===''&&r4.rounded===null;});
  t('v0.3 phi3 arrows snap to the next integer shell (continuous 7/2: N - 1 -> 4, N + 1 -> 3; at a shell 4: -> 5 and 3); integer mode unchanged (phi3 +-1, clamped to 0..B+1); Play N: +1 per tick (integer), +1/100 (continuous), null at B + 1',()=>{
    const c=g=>C.initial({nMode:'continuous',phi3:g}),i=g=>C.initial({phi3:g});
    return C.shellStep(c('7/2'),-1)==='4'&&C.shellStep(c('7/2'),1)==='3'&&C.shellStep(c('4'),-1)==='5'&&C.shellStep(c('4'),1)==='3'&&C.shellStep(c('1/100'),1)==='0'&&C.shellStep(c('2499/100'),-1)==='25'
      &&C.shellStep(i('7'),-1)==='8'&&C.shellStep(i('7'),1)==='6'&&C.shellStep(i('25'),-1)==='25'&&C.shellStep(i('0'),1)==='0'
      &&C.playNStep(i('7'))==='8'&&C.playNStep(c('7'))==='701/100'&&C.playNStep(c('2499/100'))==='25'&&C.playNStep(c('25'))===null&&C.playNStep(i('25'))===null;});
  t('v0.3 N = 0 in continuous mode (phi3 = B + 1 exactly) is the empty state as today; N between 0 and 1 (phi3 = 49/2) is not empty and is between shells',()=>{
    const z=C.initial({nMode:'continuous',phi3:'25',m:'3'}),h=C.initial({nMode:'continuous',phi3:'49/2',m:'3'});
    return C.readouts(z).empty&&NUM.compute(z).empty&&!C.stopSet(z).active&&C.cycloJson(z).status!==undefined&&!C.readouts(h).empty&&C.readouts(h).between===LBL('1/2')&&!NUM.compute(h).refused;});
}
// ---------- v0.3 step 2: fix round after VERIFY (F2 label split, F6 build-pins id). Appended; nothing above changed except the pins id in the build-pins check.
{
  const FULL=n=>'between shells: N = '+n+'; shell arithmetic undefined';
  t('v0.3 step 2 (F2): the warning-line short form is exactly "between shells: shell arithmetic undefined" (no fraction); the full label is unchanged and is what the readouts, Wilson, gearbox, divisors, fraction stack, exact export (betweenShells, shell.status) and the Lift gate reason carry at N = 11/4',()=>{
    const st=C.initial({nMode:'continuous',phi3:'89/4',m:'5'}),R=C.resolve(st),rd=C.readouts(st),ex=JSON.parse(C.exportExact(st,null,{})),g=O.gates(st),L=FULL('11/4');
    return C.BETWEEN_SHORT==='between shells: shell arithmetic undefined'&&!/N = /.test(C.BETWEEN_SHORT)&&C.BETWEEN(R.Nq)===L&&X.text(R.Nq)==='11/4'&&R.B===24n
      &&rd.between===L&&rd.wilsonN.label===L&&rd.gearbox.code==='BETWEEN_SHELLS'&&C.divisorsOf(st,R).label===L&&FS.caption(st).endsWith(L)
      &&ex.exact.betweenShells===L&&ex.exact.shell.status===L&&g.integral_frequencies.reason===L;});
  t('v0.3 step 2 (F2): the SPREAD refusal between shells is unchanged in the core (stop set, step record, step label, exact export stepping) at N = 11/4, m = 5, s = 1/3; only its place on the page moved',()=>{
    const st=C.enterSpin(C.initial({nMode:'continuous',phi3:'89/4',m:'5',t1:'1',t2:'1'}),'1/3'),set=C.stopSet(st),f=C.step(st,1),b=C.step(st,-1),why='SPREAD needs an integer gearbox: N = 11/4';
    return set.active&&set.mode==='COMB'&&set.families.length===1&&set.refused.length===1&&set.refused[0].reason===why&&f.value==='1'&&b.value==='0'&&f.refused[0].reason===why&&f.label.endsWith('; SPREAD refused (4e): '+why)
      &&JSON.parse(C.exportExact(st,null,{})).exact.stepping==='COMB; SPREAD refused (4e): '+why;});
  t('v0.3 step 2 (F6): the build-pins block of the dist page has its own id fv-comb-hopf-build/0.1, pairwise distinct from the exact-export id, the state-export id (read from real exports) and the address id',()=>{
    const fs=require('fs'),pathm=require('path'),html=fs.readFileSync(pathm.join(__dirname,'..','dist','comb-hopf.html'),'utf8');
    const m=/<script type="application\/json" id="fv-build-pins">([^<]*)<\/script>/.exec(html);if(!m)return false;
    const ids=[JSON.parse(m[1]).schema,JSON.parse(C.exportExact(C.initial(),null,{})).schema,JSON.parse(C.exportState(C.initial())).schema,C.ADDRESS_ID];
    return ids[0]==='fv-comb-hopf-build/0.1'&&ids[1]==='fv-comb-hopf/0.2'&&ids[2]==='fv-comb-hopf-state/0.2'&&new Set(ids.slice(0,3)).size===3&&ids[0]!==ids[3];});
}
console.log(`test-core: ${pass} passed, ${fail} failed`);
process.exit(fail?1:0);
