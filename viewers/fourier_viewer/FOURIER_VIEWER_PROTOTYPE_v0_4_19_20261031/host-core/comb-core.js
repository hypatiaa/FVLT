(function(root){
'use strict';
// fv-comb-core 0.2.0: EXACT register only. No Number arithmetic sources any statement here.
// v0.3 (SCHEMA_ADDENDUM_8): N may be a rational (nMode = continuous): Nq = B + 1 - phi3 is always an exact rational; N is the BigInt only when Nq is an
// integer (Nint). Exact phasor mathematics uses Nq; every integer-only readout (Wilson, gearbox residency, divisors, shell contrast and bracket,
// SPREAD stops, fraction stack, integrality gates) checks Nint and, between shells, carries the label BETWEEN(Nq) instead of a value.
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const SH=typeof module!=='undefined'&&module.exports?require('./shell-core.js'):root.FVShell;
const G=typeof module!=='undefined'&&module.exports?require('./gearbox-core.js'):root.FVGearbox;
const {rat,add,sub,mul,div,cmp,eq,isInt,floor,ceil,text,parse,qabs}=X;
const ADDRESS_ID='fv-comb-hopf/0.2',STATE_SCHEMA='fv-comb-hopf-state/0.2',EXACT_SCHEMA='fv-comb-hopf/0.2';
const ADDRESS_ID_V01='fv-comb-hopf/0.1';                 // accepted on load only: a 0.1 address has no nMode and is read as nMode = integer (the only upgrade rule)
const TABS=['fourier','clifford','hopf','panels'];
const N_MODES=['integer','continuous'];
const DIAL_KEYS=['shellMode','n1','B','nMode','phi3','m','t1','t2','n6','alpha'];
const ADDRESS_KEYS=[...DIAL_KEYS,'chart','sTyped','sEff','E','tab','view'];
const DEFAULTS=Object.freeze({shellMode:'factorial',n1:'4',B:'24',nMode:'integer',phi3:'23',m:'2',t1:'1',t2:'1',n6:'1',alpha:'1',chart:'host',sTyped:'1',sEff:'1',E:'2',tab:'fourier',view:''});
// the one wording of the between-shells label (addendum 8; handoff s1; Lumen's correction: continuous N is the variable moved along at fixed s, not a new arithmetic object)
const BETWEEN=Nq=>'between shells: N = '+text(Nq)+'; shell arithmetic undefined';
// step 2 (addendum 8 amendment, saphir F2): the per-tab warning line carries this short form (one line at 375 px); the fraction stays in the shell
// readout ("N = p/q") and every card, export and gate reason keeps the full BETWEEN(Nq) wording
const BETWEEN_SHORT='between shells: shell arithmetic undefined';
// Objects the page draws (addendum 1): the planar walk and the S3 lift (Clifford tab). The R21 wrap gate is decided over these
// drawn objects, never over the active tab: k_c, N*t1 and c*t2 must all be integers (REQ l.252, bus #366).
const DRAWN_OBJECTS=['planar-walk','s3-lift'];
const bi=s=>X.parseInteger(s),factorial=n=>{let v=1n;for(let k=2n;k<=n;k++)v*=k;return v;};
const offsets=m=>{const o=[];for(let i=0;i<m;i++)o.push(BigInt(m%2?i-Math.floor(m/2):2*i-m+1));return o;};
// v0.4.7 (SCHEMA_ADDENDUM_15): alpha_Tilt, an optional exact rational state field `tilt` in [-1, 1]; absent means 0 and 0 is never written.
const TILT_KEY='tilt';
function tiltOf(st){
  if(st.tilt===undefined)return rat(0n);
  const q=parse(st.tilt);
  if(cmp(qabs(q),rat(1n))>0)throw Error('α_Tilt must be between −1 and 1.');
  return q;
}
// weights w_t = t^alpha_Tilt, t = 1 … m (walk position in offset order). Integer tilt: exact rationals; fractional tilt: numerical floats only.
function tiltWeights(st,R){
  R=R||resolve(st);const m=R.m,al=R.tilt;
  if(al.n===0n)return {tilt:al,integer:true,exact:null,numeric:null};
  if(al.d===1n){const e=al.n,ex=[];for(let t=1;t<=m;t++){const b=BigInt(t);ex.push(e>0n?rat(b**e):rat(1n,b**(-e)));}return {tilt:al,integer:true,exact:ex,numeric:null};}
  const a=Number(al.n)/Number(al.d),nu=[];for(let t=1;t<=m;t++)nu.push(Math.pow(t,a));
  return {tilt:al,integer:false,exact:null,numeric:nu};
}
// ---- shell and dial validation (throws Error with a reason)
function resolve(st){
  if(st.shellMode!=='factorial'&&st.shellMode!=='integer')throw Error('Shell mode must be factorial or integer.');
  const n1=bi(st.n1);if(n1<1n||n1>13n)throw Error('Factorial index n₁ must be 1–13.');   // v0.4.1 (SCHEMA_ADDENDUM_9): n1 = 1, 2 allowed (B = 1, 2)
  if(!N_MODES.includes(st.nMode))throw Error('N mode must be integer or continuous.');
  const B=st.shellMode==='integer'?bi(st.B):factorial(n1);
  if(B<1n||B>6227020800n)throw Error('Shell base must be 1–6,227,020,800.');   // v0.4.1 (SCHEMA_ADDENDUM_9): B = 1 allowed
  let phi3q;
  if(st.nMode==='integer'){const g=bi(st.phi3);if(g<0n||g>B+1n)throw Error('Shell position φ₃ must be 0 through B + 1.');phi3q=rat(g);}
  else{phi3q=parse(st.phi3);if(cmp(phi3q,rat(0n))<0||cmp(phi3q,rat(B+1n))>0)throw Error('Shell position φ₃ must be 0 through B + 1.');}
  const mb=bi(st.m);if(mb<2n||mb>720n)throw Error('Comb tooth count m must be 2–720.');
  const t1=parse(st.t1),t2=parse(st.t2),n6=parse(st.n6),alpha=parse(st.alpha),eight=rat(8n);
  if(cmp(qabs(alpha),eight)>0||cmp(qabs(n6),eight)>0)throw Error('Radius controls α and n₆ must be between −8 and 8.');
  if(st.chart!=='host'&&st.chart!=='comb')throw Error('Chart must be host or comb.');
  if(!TABS.includes(st.tab))throw Error('Unknown tab.');
  const tilt=tiltOf(st);   // v0.4.7: absent = 0
  const Nq=sub(rat(B+1n),phi3q),Nint=Nq.d===1n;
  return {B,N:Nint?Nq.n:null,Nq,Nint,phi3:phi3q.d===1n?phi3q.n:null,phi3q,nMode:st.nMode,n1,m:Number(mb),t1,t2,n6,alpha,tilt};
}
function canonicalDial(k,v,st){
  if(k==='shellMode'||k==='chart'||k==='tab'||k==='nMode')return String(v);
  if(k==='phi3'&&st&&st.nMode==='continuous')return text(parse(v));   // continuous mode: phi3 is an exact rational in the exact lib's canonical text
  if(['n1','B','phi3','m'].includes(k))return String(bi(v));
  return text(parse(v));
}
// ---- teeth and exact readouts
function phaseRep(q){const per=2n*q.d;let r=((q.n%per)+per)%per;if(r>q.d)r-=per;return rat(r,q.d);}   // q mod 2 into (-1,1]
const order=ph=>rat(ph.n,2n*ph.d).d;                    // order of exp(i*pi*ph)
function teeth(st,R){
  R=R||resolve(st);const s=parse(st.sTyped),Nq=R.Nq,pos=Nq.n>0n;                          // Nq: exact rational N (an integer on a shell)
  return offsets(R.m).map(c=>{const k=add(mul(Nq,R.t1),mul(rat(c),R.t2));const ph=pos?phaseRep(div(mul(k,s),Nq)):null;
    const car=pos?phaseRep(add(mul(R.t1,s),rat(R.n6.n<0n?1n:0n))):null;                 // z1 carrier phase (mod 2), +1 if n6<0
    const off=pos?phaseRep(X.neg(div(mul(mul(rat(c),R.t2),s),Nq))):null;               // z2 offset phase, negative sign (mod 2)
    return {c,k,phase:ph,order:ph?order(ph):null,carrier:car,carrierOrder:car?order(car):null,offset:off,offsetOrder:off?order(off):null};});
}
function wilsonN(N){
  if(N===0n)return {checked:false,prime:null,residue:null,label:'N = 0: no comb, so the Wilson test does not apply.'};   // v0.4.2 (SCHEMA_ADDENDUM_10 §1): was 'N = 1 is not prime.' at N = 0
  if(N<2n)return {checked:true,prime:false,residue:0n,label:'N = 1 is not prime.'};
  if(N>10000n)return {checked:false,prime:null,residue:null,label:'Wilson readout not evaluated above N = 10,000; the comb still draws.'};
  let w=1n;for(let k=2n;k<N;k++){w=w*k%N;if(w===0n)break;}
  return {checked:true,prime:w===N-1n,residue:w,label:'Shell N = '+N+': (N−1)! mod N = '+w+' · N is '+(w===N-1n?'prime':'not prime')};
}
// between shells the shell-N Wilson test is undefined (no integer N): labelled, never evaluated
function wilsonOf(R){return R.Nint?wilsonN(R.N):{checked:false,prime:null,residue:null,label:BETWEEN(R.Nq),betweenShells:true};}
// Second, distinct Wilson readout: the m-based gearbox witness (gearbox-core.js, port of v0.3.2 analyze()). Between shells: G.between (no residency).
function gearbox(st,R){
  R=R||resolve(st);
  if(!R.Nint)return G.between({shellMode:st.shellMode,n1:R.n1,m:R.m,B:R.B,label:BETWEEN(R.Nq)});
  return G.analyze({shellMode:st.shellMode,n1:R.n1,m:R.m,phi3:R.phi3,B:R.B});
}
function readouts(st){
  const R=resolve(st),s=parse(st.sTyped),Nq=R.Nq,between=R.Nint?null:BETWEEN(Nq);
  if(Nq.n<=0n)return {N:R.N,Nq,Nint:R.Nint,between,m:R.m,empty:true,reason:'N = 0: the Fourier comb has no angular denominator, so no walk is defined.',wilsonN:wilsonOf(R),gearbox:gearbox(st,R)};
  const spread=div(mul(R.t2,s),Nq),pairAligned=isInt(spread);
  const allAligned=R.m%2?pairAligned&&spread.n%2n===0n:pairAligned;
  const half=mul(rat(2n),Nq),tsN=div(mul(R.t2,s),Nq);
  const flagAlign=isInt(mul(R.t1,s));                                         // ALIGN stop: t1*s in Z
  const flagSpread=R.m%2?isInt(mul(rat(BigInt(R.m)),div(mul(R.t2,s),half)))&&!isInt(div(mul(R.t2,s),half))   // K_m = 0
                       :isInt(mul(rat(BigInt(R.m)),tsN))&&!isInt(tsN);
  return {N:R.N,Nq,Nint:R.Nint,between,m:R.m,empty:false,spread,pairAligned,allAligned,flagAlign,flagSpread,wilsonN:wilsonOf(R),gearbox:gearbox(st,R)};
}
// ---- R21 gate and spin address
function gate(st,drawn){
  drawn=drawn||DRAWN_OBJECTS;const R=resolve(st),Nq=R.Nq;if(Nq.n<=0n)return false;   // the same logic over the rational Nq (addendum 8)
  const s3=drawn.includes('s3-lift');
  for(const c of offsets(R.m)){
    if(!isInt(add(mul(Nq,R.t1),mul(rat(c),R.t2))))return false;
    if(s3&&(!isInt(mul(Nq,R.t1))||!isInt(mul(rat(c),R.t2))))return false;
  }
  return true;
}
function center(q,N){                                    // representative mod 2N in (-N, N]; N a BigInt or an exact rational
  const Nq=typeof N==='bigint'?rat(N):N,per=mul(rat(2n),Nq),x=sub(q,mul(per,rat(X.floor(div(q,per)))));return cmp(x,Nq)>0?sub(x,per):x;
}
function derive(st,drawn){                               // s_eff and E from s_typed under the current dials
  const R=resolve(st),s=parse(st.sTyped),eff=gate(st,drawn)?center(s,R.Nq):s;
  const a=qabs(eff),Nq=R.Nq;
  return {sEff:text(eff),E:text(cmp(a,Nq)>0?a:Nq)};
}
// R21.2: gate closed (N > 0) and s_typed is not already its own representative in (-N, N]: the label "kept: wrap not invariant here" applies
function wrapKept(st){
  const R=resolve(st);if(R.Nq.n<=0n||gate(st))return false;
  const s=parse(st.sTyped);return !eq(center(s,R.Nq),s);
}
function normalise(st){
  const o={...st};for(const k of DIAL_KEYS)o[k]=canonicalDial(k,o[k],o);
  if(o.shellMode==='factorial')o.B=String(factorial(bi(o.n1)));
  if(o.tilt!==undefined){const q=parse(o.tilt);if(q.n===0n)delete o.tilt;else o.tilt=text(q);}   // v0.4.7: zero is never stored
  return o;
}
function initial(patch){const st=normalise({...DEFAULTS,...patch});return {...st,...derive(st)};}
function enterSpin(st,raw,drawn){                        // typed entry
  const s=X.parseProduct(raw),next={...st,sTyped:text(s)};return {...next,...derive(next,drawn)};
}
function dialChange(st,patch,drawn){
  const next=normalise({...st,...patch});resolve(next);
  const keys=Object.keys(patch);
  if(keys.every(k=>k==='chart'||k==='tab'||k==='view'))return next;  // view-only: never touches spin
  return {...next,...derive(next,drawn)};
}
// N mode switch (addendum 8). integer -> continuous: no change of value. continuous -> integer with a non-integer phi3: phi3 is rounded to the
// nearest shell (a tie phi3 = j + 1/2 goes to j + 1, the smaller N) and the rounding is returned as a note for the message line (never silent).
function switchNMode(st,mode,drawn){
  if(!N_MODES.includes(mode))throw Error('N mode must be integer or continuous.');
  if(mode===st.nMode)return {state:st,rounded:null,note:''};
  if(mode==='continuous')return {state:dialChange(st,{nMode:'continuous'},drawn),rounded:null,note:''};
  const g=parse(st.phi3);if(g.d===1n)return {state:dialChange(st,{nMode:'integer'},drawn),rounded:null,note:''};
  const r=floor(add(g,rat(1n,2n))),next=dialChange(st,{nMode:'integer',phi3:String(r)},drawn),R=resolve(next);
  return {state:next,rounded:{from:text(g),to:String(r)},note:'N continuous → integer: φ₃ = '+text(g)+' rounded to the nearest shell φ₃ = '+r+' (N = '+R.N+').'};
}
// phi3 ◀ ▶ (addendum 8): dir = -1 is "N - 1" (phi3 up), dir = +1 is "N + 1" (phi3 down). Both modes snap to the next integer shell in that direction
// (in integer mode that is phi3 -+ 1, unchanged); clamped to 0 .. B + 1. Returns the phi3 text.
function shellStep(st,dir){
  const R=resolve(st),g=R.phi3q,B1=R.B+1n;
  if(dir<0){const n=floor(g)+1n;return String(n>B1?B1:n);}
  const n=ceil(g)-1n;return String(n<0n?0n:n);
}
// Play N: one shell per tick in integer mode, one slider step (1/100 of a shell) per tick in continuous mode; null at the end (phi3 = B + 1, N = 0).
const PHI_STEP=rat(1n,100n);
function playNStep(st){
  const R=resolve(st),B1=rat(R.B+1n);if(cmp(R.phi3q,B1)>=0)return null;
  const n=add(R.phi3q,st.nMode==='continuous'?PHI_STEP:rat(1n));return text(cmp(n,B1)>0?B1:n);
}
// ---- R20 stop families and the stepper
function stopSet(st){
  const R=resolve(st);
  if(R.Nq.n<=0n)return {active:false,source:'4e',reason:'N ≤ 0: comb stepping is inactive.'};
  if(R.m===2)return {active:true,mode:'PAIR',families:[{kind:'PAIR',o:rat(0n),h:rat(1n),order:null}]};
  if(!isInt(R.t1)||!isInt(R.t2))return {active:false,source:'4e',reason:'Non-integer gears: no exact stop family is derived, so stepping is unavailable (no integer-snap fallback).'};
  if(R.t1.n===0n)return {active:false,source:'4e',reason:'t₁ = 0: ALIGN and SPREAD stops are undefined, so stepping is unavailable.'};
  if(R.t2.n===0n)return {active:false,source:'4e',reason:'t₂ = 0: SPREAD stops are undefined, so stepping is unavailable.'};
  const m=BigInt(R.m),A=qabs(R.t1).n,Bt=qabs(R.t2).n,D=m*A*Bt,fam=[{kind:'ALIGN',o:rat(0n),h:rat(1n,A),order:null}];
  // between shells (addendum 8, handoff s2.1): SPREAD stops need an integer gearbox, so the SPREAD families are refused (4e) with a label, never
  // approximated; ALIGN (s in Z/|t1|) stays.
  if(!R.Nint)return {active:true,mode:'COMB',families:fam,refused:[{kind:'SPREAD',source:'4e',reason:'SPREAD needs an integer gearbox: N = '+text(R.Nq)}]};
  const N=R.N;
  if(R.m%2){const h=rat(2n*m*N*A,D);for(let r=1n;r<m;r++)fam.push({kind:'SPREAD',o:rat(2n*N*A*r,D),h,order:m/X.gcd(r,m)});}
  else{const h=rat(m*N*A,D);for(let k=1n;k<m;k++)fam.push({kind:'SPREAD',o:rat(N*A*k,D),h,order:m/X.gcd(k,m)});}
  return {active:true,mode:'COMB',families:fam};
}
// Families: {kind,o,h,order} progression o+h*Z (h>0), or {kind,finite:[rationals],order}.
function candidate(f,s0,dir){
  if(f.finite){let b=null;for(const x of f.finite){const c=cmp(x,s0);if(dir>0?c>0:c<0){if(b===null||(dir>0?cmp(x,b)<0:cmp(x,b)>0))b=x;}}return b;}
  const u=div(sub(s0,f.o),f.h);const k=dir>0?floor(u)+1n:ceil(u)-1n;return add(f.o,mul(f.h,rat(k)));
}
function stepPure(s0,dir,families,lo,hi){
  const cands=families.map(f=>candidate(f,s0,dir));let best=null;
  for(const c of cands)if(c&&(best===null||(dir>0?cmp(c,best)<0:cmp(c,best)>0)))best=c;
  if(best&&(dir>0?cmp(best,hi)<=0:cmp(best,lo)>=0)){
    const hits=families.filter((f,i)=>cands[i]&&eq(cands[i],best)).map(f=>({kind:f.kind,order:f.order===null?null:String(f.order)}));
    hits.sort((a,b)=>(a.kind==='ALIGN'?0:1)-(b.kind==='ALIGN'?0:1));
    return {outcome:'stop',value:best,hits,label:hits.length?kindText(hits[0],hits.length>1?hits.slice(1):[]):'stop'};
  }
  const edge=dir>0?hi:lo;
  if(dir>0?cmp(s0,hi)<0:cmp(s0,lo)>0)return {outcome:'range-limit',value:edge,hits:[],label:'range limit, not a stop'};
  return {outcome:'none',value:s0,hits:[],label:'no stop in this direction within range'};
}
function kindText(h,others){
  const one=x=>x.kind==='ALIGN'?'ALIGN stop (t₁·s ∈ ℤ)':x.kind==='SPREAD'?'SPREAD stop (order '+x.order+')':'PAIR stop (s ∈ ℤ)';
  return one(h)+(others.length?'; also '+others.map(one).join(', '):'');
}
function step(st,dir){                                   // R20 + R21.3; returns {outcome,state,...}
  const rec={direction:dir>0?'forward':'backward',from:st.sEff};
  const set=stopSet(st);
  if(!set.active)return {...rec,outcome:'refused',source:set.source,reason:set.reason,label:'refused ('+set.source+'): '+set.reason,value:st.sEff,hits:[],state:st};
  const E=parse(st.E),r=stepPure(parse(st.sEff),dir,set.families,rec.direction==='forward'?X.neg(E):X.neg(E),E);
  const out={...rec,outcome:r.outcome,label:r.label,hits:r.hits,value:text(r.value),mode:set.mode};
  if(set.refused&&set.refused.length){out.refused=set.refused;out.label+='; '+set.refused.map(f=>f.kind+' refused ('+f.source+'): '+f.reason).join('; ');}
  out.state=r.outcome==='none'?st:{...st,sTyped:out.value,sEff:out.value};
  return out;
}
// ---- address and export
function validateState(st){
  const R=resolve(st);                                   // throws
  for(const k of ADDRESS_KEYS)if(typeof st[k]!=='string')throw Error('Missing value for '+k+'.');
  for(const k of DIAL_KEYS)if(canonicalDial(k,st[k],st)!==st[k])throw Error('Value for '+k+' is not in canonical exact form.');
  if(st.tilt!==undefined){
    if(typeof st.tilt!=='string')throw Error('tilt is not a string.');
    let q;try{q=parse(st.tilt);}catch(e){throw Error('tilt is not an exact rational.');}
    if(q.n===0n)throw Error('tilt = 0 is not written: absence is the one form of 0.');
    if(text(q)!==st.tilt)throw Error('tilt is not in canonical exact form.');
    if(cmp(qabs(q),rat(1n))>0)throw Error('tilt (α_Tilt) must be between −1 and 1.');
  }
  if(!/^[A-Za-z0-9_.,:;=\-]*$/.test(st.view))throw Error('view (drawing register) has an invalid form.');
  if(st.shellMode==='factorial'&&st.B!==String(factorial(R.n1)))throw Error('B does not match n1! in factorial mode.');
  let sT,sE,E;
  for(const [k,v] of [['sTyped',st.sTyped],['sEff',st.sEff],['E',st.E]]){let q;try{q=parse(v);}catch(e){throw Error(k+' is not an exact rational.');}
    if(text(q)!==v)throw Error(k+' is not in canonical exact form.');if(k==='sTyped')sT=q;else if(k==='sEff')sE=q;else E=q;}
  if(cmp(E,R.Nq)<0)throw Error('E < N.');
  if(cmp(E,qabs(sE))<0)throw Error('E < |sEff|.');
  if(!eq(sE,sT)){
    if(!(gate(st)&&eq(sE,center(sT,R.Nq))))throw Error('sEff is neither sTyped nor its declared invariant representative.');
  }
  return true;
}
function encodeAddress(st){
  return '#v='+ADDRESS_ID+'&'+ADDRESS_KEYS.map(k=>k+'='+encodeURIComponent(st[k]).replace(/%2F/g,'/')).join('&')+(st.tilt!==undefined?'&tilt='+encodeURIComponent(st.tilt).replace(/%2F/g,'/'):'');
}
function decodeAddress(str){
  try{
    const parts=String(str).replace(/^#/,'').split('&'),kv={};
    for(const p of parts){const i=p.indexOf('=');if(i<0)throw Error('Malformed address.');const k=p.slice(0,i);if(k in kv)throw Error('Duplicate key '+k+'.');kv[k]=decodeURIComponent(p.slice(i+1));}
    const v=kv.v;if(v!==ADDRESS_ID&&v!==ADDRESS_ID_V01)throw Error('Unknown address version.');delete kv.v;
    const keys=v===ADDRESS_ID?ADDRESS_KEYS:ADDRESS_KEYS.filter(k=>k!=='nMode');   // a 0.1 address has no nMode key (and may not carry one)
    const extra=Object.keys(kv).filter(k=>!keys.includes(k)&&!(k===TILT_KEY&&v===ADDRESS_ID));if(extra.length)throw Error('Unknown key '+extra[0]+'.');
    const st={};for(const k of ADDRESS_KEYS)st[k]=k==='nMode'&&v===ADDRESS_ID_V01?'integer':kv[k];
    if(TILT_KEY in kv)st.tilt=kv.tilt;   // the only upgrade rule: 0.1 is read as nMode = integer
    validateState(st);return {ok:true,state:st,upgraded:v===ADDRESS_ID_V01};
  }catch(e){return {ok:false,reason:e.message};}
}
function stateObject(st){const s={};for(const k of ADDRESS_KEYS)s[k]=st[k];if(st.tilt!==undefined)s.tilt=st.tilt;return s;}
function exportState(st){return X.canonicalFile({schema:STATE_SCHEMA,state:stateObject(st)});}
function cycloJson(st){
  const c=cyclotomic(st);if(!c.defined)return {status:'N = 0: no phasors, so no field is defined'};
  const tl=tiltOf(st),fracTilt=tl.n!==0n&&tl.d!==1n;
  const z=n=>'ℚ(ζ_'+n+')';
  return {generated:c.zeroAmplitude?'zero amplitude: no generated field':z(c.generated),generated_n:c.zeroAmplitude?null:String(c.generated),
    phase_container:z(c.phaseContainer),phase_container_n:String(c.phaseContainer),phase_container_factor:c.Nint?(c.hostAmbientEquivalent?'2qN':'2qN*L_k'):'2qa*L_k',
    phase_container_formula:c.Nint?'C = 2*q*N*L_k':'C = 2*q*a*L_k (N = a/b in lowest terms)',L_k:String(c.kDenominatorLcm),rho_irrational:c.rhoIrrational,
    q:String(c.q),N:text(c.Nq),N_integer:c.Nint,a:String(c.a),k_denominator_lcm:String(c.kDenominatorLcm),host_ambient_equivalent:c.hostAmbientEquivalent,exact_spin:c.exactSpin,shell_reference:z(c.shell),
    note:'generated by the phase factors: Q(zeta_L), L = lcm over the nonzero-amplitude teeth of the order of exp(i*pi*k_c*s/N); the amplitude rho = n6*N^alpha may be irrational, so the phasor values themselves may need Q(zeta_L, rho); phase container (convention): Q(zeta_C), C = 2*q*a*L_k for s = p/q and N = a/b in lowest terms (a = N on an integer shell, so C = 2*q*N*L_k there), L_k = lcm of the denominators of the k_c (1 when every k_c is an integer): every k_c*s/N lies in (1/(L_k*q*a))Z; a container convention, not a minimal field'+(fracTilt?'; with alpha_Tilt = '+text(tl)+' not an integer, walk values also need the radicals j^('+text(tl)+') (j <= m), so they are numerical':'')};
}
function exportExact(st,lastStep,opts){
  opts=opts||{};
  const {tab,view,...state}=stateObject(st);              // active tab and camera/view state (drawing register) are excluded from the exact export
  const R=resolve(st),rd=readouts(st),T=R.Nq.n>0n?teeth(st,R):[];
  const set=stopSet(st),between=R.Nint?null:BETWEEN(R.Nq);
  const o={schema:EXACT_SCHEMA,state,
    gate:{wrapInvariant:gate(st),drawn:DRAWN_OBJECTS},
    exact:{N:text(R.Nq),N_integer:R.Nint,nMode:st.nMode,betweenShells:between,m:String(R.m),
      k:T.map(x=>text(x.k)),phase:T.map(x=>text(x.phase)),order:T.map(x=>String(x.order)),
      spread:rd.empty?null:text(rd.spread),flagAlign:rd.empty?null:rd.flagAlign,flagSpread:rd.empty?null:rd.flagSpread,
      carrier:T.map(x=>text(x.carrier)),carrierOrder:T.map(x=>String(x.carrierOrder)),offset:T.map(x=>text(x.offset)),offsetOrder:T.map(x=>String(x.offsetOrder)),
      gearboxCode:rd.gearbox.code,gearboxSignature:rd.gearbox.signature,gearboxResidue:rd.gearbox.remainder===null?null:String(rd.gearbox.remainder),gearboxPhi:String(rd.gearbox.phi),gearboxDefect:String(rd.gearbox.defect),pairAligned:rd.empty?null:rd.pairAligned,allAligned:rd.empty?null:rd.allAligned,
      wilsonN:rd.wilsonN.label,gearbox:rd.gearbox.label,
      stepping:set.active?set.mode+(set.refused?'; '+set.refused.map(f=>f.kind+' refused ('+f.source+'): '+f.reason).join('; '):''):'unavailable: '+set.reason,
      liveFormula:'z_c = n6*N^alpha*exp(i*(N*t1+c*t2)*s*pi/N)'+(R.tilt.n!==0n?'; W_t = sum_{j<=t} j^tilt * z_{c_j} (walk order)':''),
      cyclotomic_field:cycloJson(st),
      shell:R.Nq.n<=0n?{N:text(R.Nq),B:String(R.B)}:!R.Nint?{N:text(R.Nq),B:String(R.B),span:String(R.B+1n),contrast:null,bracket:null,status:between}
        :{N:String(R.N),B:String(R.B),span:String(R.B+1n),contrast:SH.contrast(R.N)?text(SH.contrast(R.N)):null,bracket:SH.bracket(R.N)},
      divisors:(()=>{const d=divisorsOf(st,R);return {kind:d.kind,label:d.label,list:d.list?d.list.map(String):null,truncated:!!d.truncated,tag:d.tag||null};})(),
      orderWitness:opts.witnessP?(()=>{const w=SH.orderWitness(BigInt(opts.witnessP));return {p:String(w.p),prime:w.prime,phi:String(w.phi),delta:String(w.delta),residue:String(w.residue)};})():null},
    lastStep:lastStep?{direction:lastStep.direction,from:lastStep.from,outcome:lastStep.outcome,value:lastStep.value,label:lastStep.label,
      families:lastStep.hits.map(h=>h.kind+(h.order?':'+h.order:''))}:null};
  if(R.tilt.n!==0n){const w=tiltWeights(st,R);
    o.exact.tilt={alpha_Tilt:text(R.tilt),standing:'instrument-tier use of the kernel parameter alpha_Tilt (w_k = k^alpha_Tilt, kernel v3.2.7 notation); the comb walk for m >= 3 is outside the kernel; no theorem standing',weight:'w_t = t^alpha_Tilt, t = 1 … m, position in offset order (walk only; teeth unchanged)',
      register:w.integer?'exact':'numerical',weights:w.integer?w.exact.map(text):w.numeric.map(x=>'numerical '+x.toPrecision(17))};}
  return X.canonicalFile(o);
}
function importAny(src){
  const t=String(src).trim();
  if(t[0]==='{'){try{const o=X.parseStrict(t);if(o.schema!==STATE_SCHEMA&&o.schema!==EXACT_SCHEMA)throw Error('Unknown schema.');
      const s=o.state;if(!s||typeof s!=='object')throw Error('No state object.');
      const st={tab:'fourier',view:'',...s};validateState(st);return {ok:true,state:st};}catch(e){return {ok:false,reason:e.message};}}
  const i=t.indexOf('#v=');return decodeAddress(i>=0?t.slice(i):t);
}
// ---- cyclotomic fields (EXACT). generated by the phase factors e^{i pi k_c s/N}: Q(zeta_L) (not necessarily the field of the phasor values, rho = n6*N^alpha may be irrational), L = lcm of the orders of e^{i pi phi_c} over the teeth (the field is empty-labelled at zero amplitude).
//   phase container (a container convention, not minimal): for s = p/q and N = a/b in lowest terms (a = N on an integer shell), with D = L_k = lcm of the k_c
//   denominators (D = 1 when every k_c is an integer), every k_c*s/N lies in (1/(D*q*a))Z, so the field Q(zeta_C), C = 2*q*a*D, holds every tooth phase exp(i pi k s / N)
//   for k in (1/D)Z. On a shell with D = 1 this is 2qN, the host's "ambient" Q(zeta_{2qN}) (frozen host L6406).
const lcmB=(a,b)=>a===0n||b===0n?0n:(a<0n?-a:a)/X.gcd(a,b)*(b<0n?-b:b);
// rho = n6*N^alpha with N = a/b in lowest terms is irrational iff n6 != 0, N != 1 and alpha = p/r (lowest terms, r > 1) with a or b not a perfect r-th power
// (for an integer shell b = 1: N not a perfect r-th power, as before)
function iroot(n,b){let lo=1n,hi=n;while(lo<hi){const mid=(lo+hi+1n)/2n;if(mid**b<=n)lo=mid;else hi=mid-1n;}return lo;}
function rhoIrr(R){const al=R.alpha,Nq=R.Nq;if(R.n6.n===0n||Nq.n<=0n||Nq.n===Nq.d||al.n===0n||al.d===1n)return false;
  const perfect=x=>{const r=iroot(x,al.d);return r**al.d===x;};return !(perfect(Nq.n)&&perfect(Nq.d));}
// phase container generalised (addendum 8): N = a/b, s = p/q in lowest terms, L_k = lcm of the k_c denominators; k_c*s/N = (j/L_k)*(p/q)*(b/a) lies in
// (1/(L_k*q*a))Z, so every phase factor exp(i*pi*k_c*s/N) is a (2*q*a*L_k)-th root of unity: C = 2*q*a*L_k (a container convention; a = N on a shell).
function cyclotomic(st){
  const R=resolve(st);
  if(R.Nq.n<=0n)return {defined:false};
  const T=teeth(st,R),s=parse(st.sTyped);let gen=1n,D=1n;
  for(const t of T){gen=lcmB(gen,t.order);D=lcmB(D,t.k.d);}
  const zero=R.n6.n===0n,q=s.d,a=R.Nq.n,base=2n*q*a;
  return {defined:true,zeroAmplitude:zero,generated:zero?null:gen,phaseContainer:base*D,twoqN:R.Nint?base:null,twoqa:base,q,N:R.N,Nq:R.Nq,Nint:R.Nint,a,b:R.Nq.d,kDenominatorLcm:D,
    hostAmbientEquivalent:R.Nint&&D===1n,rhoIrrational:rhoIrr(R),exactSpin:text(s),shell:R.B};
}
// divisors (addendum 2 s2.5) need an integer shell for the card and the phi3 marks; between shells they are switched off with the label
function divisorsOf(st,R){
  R=R||resolve(st);
  if(!R.Nint)return {kind:'between',label:BETWEEN(R.Nq),list:null,truncated:false,tag:null};
  return SH.divisorsReport(R.t2,parse(st.sTyped),R.B+1n);
}
const api={tiltOf,tiltWeights,TILT_KEY,cyclotomic,cycloJson,ADDRESS_ID,ADDRESS_ID_V01,STATE_SCHEMA,EXACT_SCHEMA,TABS,N_MODES,DIAL_KEYS,ADDRESS_KEYS,DEFAULTS,DRAWN_OBJECTS,BETWEEN,BETWEEN_SHORT,PHI_STEP,resolve,offsets,phaseRep,order,teeth,wilsonN,wilsonOf,gearbox,readouts,
  gate,wrapKept,center,derive,normalise,initial,enterSpin,dialChange,switchNMode,shellStep,playNStep,divisorsOf,stopSet,stepPure,step,kindText,validateState,encodeAddress,decodeAddress,exportState,exportExact,importAny};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVCombCore=api;
})(typeof globalThis!=='undefined'?globalThis:this);
