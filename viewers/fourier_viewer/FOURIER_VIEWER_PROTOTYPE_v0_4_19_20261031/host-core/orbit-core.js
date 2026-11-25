(function(root){
'use strict';
// fv-orbit-core 0.1.0 (SCHEMA_ADDENDUM_5): EXACT register only. BigInt rationals from fv-exact; no Number arithmetic sources any statement here.
// For each tooth c, with exact t1, t2 and N > 0, the s-orbit on the Clifford leaf has carrier rate t1 and offset rate c*t2/N per unit s (in units of pi).
// v0.3 (addendum 8): N is the exact rational Nq (an integer on a shell); every formula below already clears denominators, so it holds for rational N.
//   raw rate pair    (N*t1, -c*t2)                       rationals
//   denominator scale L = lcm of the two denominators
//   cleared rate     (a, b) = (L*N*t1, -L*c*t2)           integers
//   common factor    g = gcd(|a|, |b|)  (= branch multiplicity d_c); primitive winding (p, q) = (a/g, b/g)
//   closure period   the least s > 0 at which u = pi*t1*s and v = pi*c*t2*s/N both return mod 2pi:  lcm(2/|t1|, 2N/|c*t2|)  (a zero rate imposes no condition)
//   knot class       UNKNOT if |p| <= 1 or |q| <= 1, otherwise NONTRIVIAL_TORUS_KNOT with type T(min,max) and the sign of p*q
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const C=typeof module!=='undefined'&&module.exports?require('./comb-core.js'):root.FVCombCore;
const {rat,add,mul,div,text}=X;
const babs=n=>n<0n?-n:n,gcd=X.gcd,lcmI=(a,b)=>a===0n||b===0n?0n:babs(a)/gcd(a,b)*babs(b);
const MINUS='−';
const ratObj=q=>({numerator:String(q.n),denominator:String(q.d),text:text(q)});
const lcmQ=(a,b)=>rat(lcmI(a.n,b.n),gcd(a.d,b.d));             // lcm of reduced positive rationals
function closurePeriod(t1,t2,c,N){                             // N: a BigInt or an exact rational a/b; 2N/|c*t2| = 2*a*ct.d/(b*|ct.n|)
  const Nq=typeof N==='bigint'?rat(N):N;
  const ps=[];if(t1.n!==0n)ps.push(rat(2n*t1.d,babs(t1.n)));
  const ct=mul(rat(c),t2);if(ct.n!==0n)ps.push(rat(2n*Nq.n*ct.d,Nq.d*babs(ct.n)));
  return ps.length?ps.reduce(lcmQ):null;
}
const sgn=n=>n>0n?1n:n<0n?-1n:0n;
function knot(p,q){
  if(p===0n&&q===0n)return {cls:'STATIONARY',type:'STATIONARY',chi:'0'};
  const s=sgn(p)*sgn(q),chi=s>0n?'+':s<0n?MINUS:'0';
  if(babs(p)<=1n||babs(q)<=1n)return {cls:'UNKNOT',type:'UNKNOT',chi};
  const lo=babs(p)<babs(q)?babs(p):babs(q),hi=babs(p)<babs(q)?babs(q):babs(p);
  return {cls:'NONTRIVIAL_TORUS_KNOT',type:'T('+lo+','+hi+')'+chi,chi};
}
// One branch per tooth; every tooth gets a branch (stationary / undefined are labelled, never omitted).
function branches(st){
  const R=C.resolve(st);
  return C.offsets(R.m).map(c=>{
    if(R.Nq.n<=0n)return {c,status:'undefined',reason:'N ≤ 0: no angular denominator, so no orbit is defined.',rawRate:null,denominatorScale:null,clearedRate:null,commonFactor:null,primitive:null,closurePeriod:null,k:null,kIntegral:null,knotClass:'UNDEFINED',canonicalType:'UNDEFINED',chi:'0'};
    const Nq=R.Nq,a0=mul(Nq,R.t1),b0=mul(rat(-c),R.t2),k=add(a0,mul(rat(c),R.t2));
    const L=lcmI(a0.d,b0.d),a=a0.n*(L/a0.d),b=b0.n*(L/b0.d),g=gcd(a,b);
    const base={c,rawRate:[a0,b0],denominatorScale:L,clearedRate:[a,b],commonFactor:g,k,kIntegral:k.d===1n};
    if(g===0n)return {...base,status:'stationary',reason:'both phase rates are zero (N·t₁ = 0 and c·t₂ = 0).',primitive:[0n,0n],closurePeriod:null,knotClass:'STATIONARY',canonicalType:'STATIONARY',chi:'0'};
    const p=a/g,q=b/g,kn=knot(p,q);
    return {...base,status:'defined',reason:'',primitive:[p,q],closurePeriod:closurePeriod(R.t1,R.t2,c,R.Nq),knotClass:kn.cls,canonicalType:kn.type,chi:kn.chi};
  });
}
// Same shape as the old viewer's `orbitBranches` entries (numbers: display / comparison only; never written into an exact export)
const summary=b=>b.status==='undefined'?{c:Number(b.c),status:'undefined',canonicalType:'UNDEFINED'}
  :{c:Number(b.c),rawWinding:b.clearedRate.map(Number),divisor:Number(b.commonFactor),branchMultiplicityDc:Number(b.commonFactor),primitiveWinding:b.primitive.map(Number),canonicalType:b.canonicalType};
// Lift JSON entry (every value an exact string / rational object; same key set as the old viewer's exactRationalLift.branches)
function liftBranch(b){
  const nul=b.status==='undefined';
  return {c:String(b.c),
    raw_rate:nul?null:b.rawRate.map(ratObj),denominator_scale:nul?null:String(b.denominatorScale),cleared_rate:nul?null:b.clearedRate.map(String),
    common_factor:nul?null:String(b.commonFactor),primitive_winding:nul?null:b.primitive.map(String),
    closure_period_s:b.closurePeriod?ratObj(b.closurePeriod):null,frequency_k_c:nul?null:ratObj(b.k),frequency_integral:nul?null:b.kIntegral,
    knot_class:b.knotClass,canonical_type:b.canonicalType,presentation_chi:b.chi};
}
// Chip label: c, raw (a,b), primitive (p,q), multiplicity d, type
function chipText(b){
  const c=(b.c>0n?'+':b.c<0n?MINUS:'')+babs(b.c);
  if(b.status==='undefined')return 'c '+c+' · undefined (N ≤ 0)';
  if(b.status==='stationary')return 'c '+c+' · raw (0,0) · stationary';
  const sg=n=>(n<0n?MINUS:'')+babs(n);
  return 'c '+c+' · raw ('+b.clearedRate.map(sg).join(',')+') · primitive ('+b.primitive.map(sg).join(',')+') ×'+b.commonFactor+' · '+b.canonicalType;
}
// ---- cyclotomic fields.  Orders come from comb-core.teeth (exact).
//   generated: lcm over nonzero-amplitude teeth of the order of e^{i pi phi_c}, phi_c = k_c*s/N mod 2.  Amplitude n6*N^alpha is zero iff n6 = 0 (N > 0).
//   ambient:   lcm of the orders of the carrier phase e^{i pi t1 s} and of the offset phases e^{-i pi c t2 s/N}, taken separately, over all teeth. The sign of n6 is an amplitude (a rational), so
//              it is not part of the carrier phase here; phi_c = (carrier) - (offset), hence the generated field is always contained in the ambient one.
//   shell:     B (the shell base) for the reference field Q(zeta_B).
const SUB='₀₁₂₃₄₅₆₇₈₉';
const zeta=n=>'ℚ(ζ'+String(n).replace(/\d/g,d=>SUB[d])+')';
function field(st){
  const R=C.resolve(st);
  if(R.Nq.n<=0n)return {defined:false,label:'N = 0: no phasors, so no field is defined.',line:'field undefined (N = 0)'};
  const T=C.teeth(st,R),zero=R.n6.n===0n,s=X.parse(st.sTyped);
  let gen=1n,amb=1n;
  const ordQ=x=>C.order(C.phaseRep(x));          // order of e^{i pi x}
  const car=ordQ(mul(R.t1,s));                    // carrier phase t1*s; the sign of n6 belongs to the amplitude (a rational), not to the phase
  for(const t of T){gen=lcmI(gen,t.order);amb=lcmI(amb,lcmI(car,ordQ(X.neg(div(mul(mul(rat(t.c),R.t2),s),R.Nq)))));}
  const g=zero?null:gen,out={defined:true,zeroAmplitude:zero,generated:g,ambient:amb,shell:R.B,generatedLabel:zero?'zero amplitude — no generated field':zeta(gen),ambientLabel:zeta(amb),shellLabel:zeta(R.B)};
  // Two labelled values (owner decision, addendum 6): the field generated by the phase factors, and the phase container (the host's "ambient" is a container convention, not minimal).
  const cy=C.cyclotomic(st);
  out.phaseContainer=cy.phaseContainer;out.hostAmbientEquivalent=cy.hostAmbientEquivalent;out.twoqN=cy.twoqN;out.twoqa=cy.twoqa;out.kDenominatorLcm=cy.kDenominatorLcm;
  out.containerLabel=zeta(cy.phaseContainer);out.L_k=cy.kDenominatorLcm;
  out.rhoIrrational=cy.rhoIrrational;out.line='generated by the phase factors '+out.generatedLabel+' · phase container (convention) '+out.containerLabel+' (exact)';
  return out;
}
// ---- Lift gates (addendum 7, F6): computed from the state, never constant. Exact (BigInt); statuses PASS / FAIL, plus two gates that live outside this viewer.
function gates(st){
  const out={},cs=c=>String(c);
  // exact_rational_lift: t1, t2 and s are exact rationals (parse refuses anything else)
  const bad=[];for(const [k,v] of [['t1',st.t1],['t2',st.t2],['s',st.sTyped]]){try{X.parse(v);}catch(e){bad.push(k);}}
  out.exact_rational_lift=bad.length?{status:'FAIL',failing:bad,reason:'not an exact rational: '+bad.join(', ')}:{status:'PASS',failing:[],reason:'t1, t2 and s are exact rationals'};
  let bs=null;try{bs=branches(st);}catch(e){}
  if(bs===null){const why='no branches: the state is not resolvable';out.closed_orbits={status:'FAIL',failing:[],reason:why};out.integral_frequencies={status:'FAIL',failing:[],reason:why};}
  else{
    const nc=bs.filter(b=>b.status!=='defined'||b.closurePeriod===null).map(b=>cs(b.c));
    out.closed_orbits=nc.length?{status:'FAIL',failing:nc,reason:'no finite exact closure period for c = '+nc.join(', ')+(bs.some(b=>b.status==='undefined')?' (N ≤ 0: no orbit is defined)':' (stationary: both phase rates are zero)')}
      :{status:'PASS',failing:[],reason:'every branch has a finite exact closure period'};
    const ni=bs.filter(b=>b.status==='undefined'||!b.kIntegral).map(b=>cs(b.c));
    out.integral_frequencies=ni.length?{status:'FAIL',failing:ni,reason:'k_c is not an integer for c = '+ni.join(', ')+(bs.some(b=>b.status==='undefined')?' (N ≤ 0: undefined)':'')}
      :{status:'PASS',failing:[],reason:'every k_c is an integer'};
  }
  // between shells (addendum 8): the integrality gate belongs to shell arithmetic, which is undefined; it is switched off with the label, not evaluated
  let between=null;try{const R=C.resolve(st);if(!R.Nint)between=C.BETWEEN(R.Nq);}catch(e){}
  if(between)out.integral_frequencies={status:'NOT_EVALUATED',failing:[],reason:between};
  out.prime_pair={status:'SEPARATE_GATE',failing:[],reason:'requires integral selected frequencies and independent primality evidence'+(between?'; '+between:'')};
  out.rank4_smith_monodromy={status:'OUT_OF_SCOPE',failing:[],reason:'Rank-4 monodromy has its own viewer (saphir, 2026-10-13)'};
  return out;
}
// ---- v0.4 mirror axis (feature note FEATURE_NOTE_EVEN_COMB_MIRROR_AXIS_FOR_V06_20261019.md, 9267e39f…, from saphir's observations; amended by the S0 design
// review SEIFERT_S0_DESIGN_REVIEW_20261019/REVIEW.md §5, 01262856…, Codex, review #539). EXACT register, BigInt only.
// Lift (as in this file and comb-numeric `orbits`): z1 = a e^{i pi (t1 s + f)}, f = 1 if n6 < 0 else 0;  z2 = b e^{-i pi c t2 s/N}.
// The comb's mirror c -> -c is z2 -> conj(z2). On a positive finite leaf it fixes the two reference longitudes arg z2 = 0 (beta = 0, z2 = b) and arg z2 = pi (beta = pi).
// SAME-TIME TIP COINCIDENCES (review §5 R2): teeth c and -c share z1, so at the same s they are at the same point exactly when c t2 s/N is an integer k:
//   P = lcm_Q(2/|t1|, 2N/|c t2|),  M = P |c t2| / N  (an even integer),  s_k = k N/|c t2|, 0 <= k < M,  on beta = 0 for even k and beta = pi for odd k.
// This is NOT the number of intersections of the two orbit images. For primitive cleared windings (p, q) and (p, -q) the images meet in |det| = 2|p q| points
// (IMAGE INTERSECTIONS, a separate count); only the M same-time events lie on the reference longitudes. Guards: c t2 = 0 (the two trajectories coincide
// continuously: no division, no isolated events); t1 = 0 (both images are the same transverse circle; the c = 0 tooth is stationary, a point).
function mirrorParity(st){
  const R=C.resolve(st),odd=R.m%2===1,pos=C.offsets(R.m).filter(c=>c>0n),inner=pos.length?pos.reduce((a,c)=>c<a?c:a):null,t1z=R.t1.n===0n;
  return {odd,fixedTeeth:odd?1:0,innermost:inner,kind:odd?'pants':'line',
    readout:odd?'mirror c ↦ '+MINUS+'c fixes 1 tooth (c = 0): pants (mnemonic)':'mirror c ↦ '+MINUS+'c fixes 0 teeth: line between c = ∓'+inner+' (mnemonic)',
    label:odd?(t1z?'c = 0 · carrier tooth (t₁ = 0: stationary, a point, not the whole longitude)':'c = 0 · carrier tooth'):'reference carrier · no tooth',
    carrierStationary:odd&&t1z};
}
// one record per mirror pair +-c (c > 0): spacing w = N/|c t2|, common period P, same-time count M = P/w, and the image-intersection count 2|p q| (separate)
function mirrorPairs(st){
  const R=C.resolve(st),out=[];
  for(const c of C.offsets(R.m)){if(c<=0n)continue;
    const base={c,spacing:null,period:null,count:null,imageIntersections:null,imageNote:''};
    if(R.Nq.n<=0n){out.push({...base,status:'undefined',reason:'N ≤ 0: no orbit is defined'});continue;}
    const ct=mul(rat(c),R.t2);
    if(ct.n===0n){out.push({...base,status:'coincident',reason:'c·t₂ = 0: the trajectories of c and '+MINUS+'c coincide continuously (z₂ = b for both); no isolated events'});continue;}
    const w=div(R.Nq,X.qabs(ct)),P=closurePeriod(R.t1,R.t2,c,R.Nq),Mq=div(P,w);
    if(Mq.d!==1n)throw Error('same-time count P·|c·t₂|/N is not an integer for c = '+c+' (P = '+text(P)+')');   // never expected: P is a multiple of 2N/|c t2| = 2w
    // primitive cleared winding of tooth c: (p, q) from (L N t1, -L c t2); tooth -c has (p, -q). Straight curves: |det| = 2|p q| intersections when p, q != 0.
    const a0=mul(R.Nq,R.t1),b0=mul(rat(-c),R.t2),L=lcmI(a0.d,b0.d),a=a0.n*(L/a0.d),b=b0.n*(L/b0.d),g=gcd(a,b),p=a/g,q=b/g;
    const t1z=R.t1.n===0n;
    out.push({...base,status:'defined',reason:t1z?'t₁ = 0: z₁ is fixed, both images are the same transverse circle':'',spacing:w,period:P,count:Mq.n,primitive:[p,q],
      imageIntersections:t1z?null:2n*babs(p*q),imageNote:t1z?'image sets coincide (t₁ = 0)':''});}
  return out;
}
// same-time event k of pair +-c: s_k = k*w; beta (units of pi) = k mod 2; carrier phase t1 s_k + f mod 2; the two offset phases -+ c t2 s_k/N mod 2 (equal, 0 or 1)
function mirrorMeeting(st,R,c,w,k){
  const s=mul(rat(k),w),f=rat(R.n6.n<0n?1n:0n),x=div(mul(mul(rat(c),R.t2),s),R.Nq);
  const car=C.phaseRep(add(mul(R.t1,s),f)),offP=C.phaseRep(X.neg(x)),offM=C.phaseRep(x),beta=((k%2n)+2n)%2n;
  return {k,s,beta,carrier:car,offsetPlus:offP,offsetMinus:offM};
}
// R4 (review §5): the plane phasors z_c = rho e^{i pi t1 s} e^{i pi c t2 s/N} of a pair +-c are reflections of each other in the carrier line e^{i pi (t1 s + f)} R at every s;
// that line is the real axis exactly when t1 s is an integer (then the lab-frame sum is real). Integer s alone is not enough with rational t1.
function mirrorConjugate(st){const R=C.resolve(st);if(R.Nq.n<=0n)return false;return X.isInt(mul(R.t1,X.parse(st.sTyped)));}
function mirrorCarrierPhase(st){const R=C.resolve(st);return C.phaseRep(add(mul(R.t1,X.parse(st.sTyped)),rat(R.n6.n<0n?1n:0n)));}
// ---- v0.4.1 carrier foliation (display register; design from the merged viewer's v0.8.8-fix.5 "c = 0 transverse-phase foliation", read for meaning only).
// EXACT register: the selected transverse phase on the lattice beta/pi = k/120 (k mod 240), its companion beta + pi, the family lattice beta = 2 pi j/K, and which
// teeth run along a carrier longitude. The family is the orbit foliation of the carrier action (lambda z1, z2) on the leaf: the longitudes (a e^{i theta}, b e^{i beta}).
const FOL_COUNTS=[6,12,24,120],FOL_DEN=120n;
function folNorm(k){const n=BigInt(k)%(2n*FOL_DEN);return n<0n?n+2n*FOL_DEN:n;}
const folText=k=>text(rat(folNorm(k),FOL_DEN))+'·π';
function carrierFoliation(st,K,k){
  const R=C.resolve(st),kk=folNorm(k),comp=folNorm(kk+FOL_DEN),Kn=FOL_COUNTS.includes(Number(K))?Number(K):24;
  const on=C.offsets(R.m).filter(c=>mul(rat(c),R.t2).n===0n);   // tooth c runs along a carrier longitude (beta = 0) iff c t2 = 0
  return {K:Kn,k:kk,beta:rat(kk,FOL_DEN),betaText:folText(kk),companionK:comp,companion:rat(comp,FOL_DEN),companionText:folText(comp),
    family:Array.from({length:Kn},(_,j)=>rat(2n*BigInt(j),BigInt(Kn))),          // beta/pi = 2j/K (reduced)
    t1Zero:R.t1.n===0n,undefinedN:R.Nq.n<=0n,teethOn:on,odd:R.m%2===1,
    mirrorFixed:kk===0n||kk===FOL_DEN};
}
const api={closurePeriod,knot,branches,summary,liftBranch,chipText,field,gates,zeta,lcmQ,mirrorParity,mirrorPairs,mirrorMeeting,mirrorConjugate,mirrorCarrierPhase,FOL_COUNTS,folText,carrierFoliation};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVOrbit=api;
})(typeof globalThis!=='undefined'?globalThis:this);
