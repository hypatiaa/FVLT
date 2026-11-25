'use strict';
// v0.4.7 unit tests (SCHEMA_ADDENDUM_15): alpha_Tilt as a walk weight. Numbers refer to the design note section 9.
// The reference below (ref*) shares no code with comb-core / comb-numeric: it rebuilds the teeth phases and the walk from the closed forms
// with its own complex arithmetic, and the exact weights with its own BigInt fractions.
const path=require('path');
const root=path.join(__dirname,'..');
const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/';
const C6=require(OLD+'host-core/comb-core.js'),N6=require(OLD+'host-core/comb-numeric.js');
let pass=0,fail=0;const ok=(n,c,x)=>{if(!c)console.log('FAIL '+n+(x?' '+x:''));c?pass++:fail++;};
let seed=20261020;const rnd=()=>{seed=(seed*1664525+1013904223)>>>0;return seed/4294967296;};const pick=a=>a[Math.floor(rnd()*a.length)];
const ints=(a,b)=>a+Math.floor(rnd()*(b-a+1));
function randState(){
  const fact=rnd()<0.6,patch={};
  if(fact){patch.shellMode='factorial';patch.n1=String(ints(2,7));}
  else{patch.shellMode='integer';patch.B=String(pick([6,12,24,60,120,720,5040,55440]));}
  const B=fact?[1,2,6,24,120,720,5040,40320][Number(patch.n1)-1]:Number(patch.B);
  patch.phi3=String(ints(0,B+1));patch.m=String(ints(2,pick([6,12,40])));
  patch.t1=pick(['1','2','1/2','3','-1','0','3/2']);patch.t2=pick(['1','2','1/3','-1','3','2/5','0']);
  patch.n6=pick(['1','1','2','-1','1/2']);patch.alpha=pick(['0','1','1/2','-1','2']);
  patch.sTyped=pick(['0','1','1/2','3','7/3','-2','5','13/4','0.37'.replace('0.37','37/100')]);
  try{return C.initial(patch);}catch(e){return null;}
}
const states=[];while(states.length<600){const s=randState();if(s)states.push(s);}
// named fixtures
const fixtures=[C.initial(),C.initial({shellMode:'factorial',n1:'5',phi3:'119',m:'7',t1:'1/2',t2:'1',sTyped:'1'}),C.initial({shellMode:'integer',B:'5040',phi3:'5040',m:'720',sTyped:'0'}),
  C.initial({shellMode:'factorial',n1:'3',phi3:'0',m:'7',sTyped:'1'}),C.initial({shellMode:'factorial',n1:'3',phi3:'5',m:'7',sTyped:'1'})];
const all=[...fixtures,...states];
const jstr=o=>JSON.stringify(o,(k,v)=>typeof v==='bigint'?'n'+v:v);
// ---- 1. byte identity at tilt = 0
{let bad=0,badNum=0;
  for(const st of all){
    const s0=C.dialChange(st,{tilt:'0'});   // explicit zero is never stored
    if(s0.tilt!==undefined)bad++;
    if(C.encodeAddress(st)!==C6.encodeAddress(st)||C.encodeAddress(s0)!==C6.encodeAddress(st))bad++;
    if(C.exportState(s0)!==C6.exportState(st)||C.exportExact(s0,null)!==C6.exportExact(st,null))bad++;
    const a=NUM.compute(s0),b=N6.compute(st);if(jstr(a)!==jstr(b))badNum++;
  }
  ok('1. byte identity at tilt = 0 (address, state, exact export)',bad===0,'bad='+bad);
  ok('1. byte identity at tilt = 0 (compute() output)',badNum===0,'bad='+badNum);
  console.log('   corpus: '+all.length+' states');}
// ---- 2. exact readouts do not depend on tilt
{const tilts=['-1','-1/2','-1/100','1/3','1'];let bad=0,n=0;
  for(const st of all.slice(0,300)){
    const base=JSON.parse(C.exportExact(st,null));
    for(const t of tilts){
      const s1=C.dialChange(st,{tilt:t}),ex=JSON.parse(C.exportExact(s1,null));n++;
      if(ex.state.tilt!==C.normalise({...st,tilt:t}).tilt)bad++;
      const e1=ex.exact,e0=base.exact;
      const keys=Object.keys(e0);
      for(const k of keys){if(k==='liveFormula'||k==='cyclotomic_field')continue;if(JSON.stringify(e0[k])!==JSON.stringify(e1[k]))bad++;}
      const c0=e0.cyclotomic_field,c1=e1.cyclotomic_field;
      for(const k of Object.keys(c0))if(k!=='note'&&JSON.stringify(c0[k])!==JSON.stringify(c1[k]))bad++;
      if(!e1.liveFormula.startsWith(e0.liveFormula)||!e1.tilt)bad++;
      if(JSON.stringify(ex.gate)!==JSON.stringify(base.gate))bad++;
      // R20 steps and R21 s_eff / E
      for(const d of [1,-1]){const r0=C.step(st,d),r1=C.step(s1,d);if(r0.outcome!==r1.outcome||r0.value!==r1.value||r0.label!==r1.label)bad++;}
      const d0=C.derive(st),d1=C.derive(s1);if(d0.sEff!==d1.sEff||d0.E!==d1.E)bad++;
    }
  }
  ok('2. exact readouts, gate, R20 steps, R21 s_eff/E independent of tilt ('+n+' state x tilt pairs)',bad===0,'bad='+bad);}
// ---- reference walk (independent)
const TWO_PI=2*Math.PI;
function refWalk(st,tilt){
  // st: comb-core state object, read only as numbers. Rebuild everything from the raw fields.
  const fr=s=>{const [a,b]=String(s).split('/');return Number(a)/(b?Number(b):1);};
  const B=Number(st.B),phi3=fr(st.phi3),N=B+1-phi3,m=Number(st.m),t1=fr(st.t1),t2=fr(st.t2),s=fr(st.sTyped),n6=fr(st.n6),al=fr(st.alpha);
  const rho0=n6*Math.pow(N,al),offs=[];for(let i=0;i<m;i++)offs.push(m%2?i-(m-1)/2:2*i-m+1);
  const z=offs.map(c=>{const ph=Math.PI*((N*t1+c*t2)*s/N);return [rho0*Math.cos(ph),rho0*Math.sin(ph)];});
  const W=[[0,0]];let w=1;
  z.forEach((v,i)=>{w=tilt===0?1:Math.pow(i+1,tilt);const p=W[W.length-1];W.push([p[0]+w*v[0],p[1]+w*v[1]]);});
  return {W,rho:Math.abs(rho0),z,N,m,t1,t2,s};
}
// ---- 3. closed forms (own geometric-series formulas), 500 states
{let bad=0,n=0,worst=0;
  const cmul=(a,b)=>[a[0]*b[0]-a[1]*b[1],a[0]*b[1]+a[1]*b[0]],cdiv=(a,b)=>{const d=b[0]*b[0]+b[1]*b[1];return [(a[0]*b[0]+a[1]*b[1])/d,(a[1]*b[0]-a[0]*b[1])/d];};
  for(const st of states.slice(0,500)){
    for(const t of ['0','1','-1']){
      const s1=C.dialChange(st,{tilt:t}),num=NUM.compute(s1);if(num.refused||num.empty)continue;
      const rf=refWalk(st,Number(t)),m=rf.m;
      // Delta: 1 odd m, 2 even m; q = exp(i pi Delta t2 s / N); z_c1 = first tooth
      const Dl=m%2?1:2,qa=Math.PI*Dl*rf.t2*rf.s/rf.N,q=[Math.cos(qa),Math.sin(qa)],z1=rf.z[0];
      let end;
      const qm=[Math.cos(qa*m),Math.sin(qa*m)],qm1=[Math.cos(qa*(m+1)),Math.sin(qa*(m+1))];
      const one=[1,0],sub=(a,b)=>[a[0]-b[0],a[1]-b[1]];
      const qIs1=Math.abs(sub(q,one)[0])<1e-12&&Math.abs(q[1])<1e-12;
      if(t==='0'){end=qIs1?[m*z1[0],m*z1[1]]:cmul(z1,cdiv(sub(one,qm),sub(one,q)));}
      else if(t==='1'){end=qIs1?[z1[0]*m*(m+1)/2,z1[1]*m*(m+1)/2]:cmul(z1,cdiv([1-(m+1)*qm[0]+m*qm1[0],-(m+1)*qm[1]+m*qm1[1]],cmul(sub(one,q),sub(one,q))));}
      else{ // alpha_Tilt = -1: compensated (Kahan) sum of q^(j-1)/j
        let sr=0,cr=0,si=0,ci=0;for(let j=1;j<=m;j++){const a=qa*(j-1),vr=Math.cos(a)/j,vi=Math.sin(a)/j;
          let y=vr-cr,tt=sr+y;cr=(tt-sr)-y;sr=tt;y=vi-ci;tt=si+y;ci=(tt-si)-y;si=tt;}
        end=cmul(z1,[sr,si]);}
      const e=num.W[num.W.length-1],err=Math.hypot(e.re-end[0],e.im-end[1]);
      // the reference itself is float64 and the mod-2 reduction of the phases is not shared, so allow the stated bound plus the reference's own scale
      const tol=num.bound+1e-9*Math.max(1,rf.rho*m*m)*(1+Math.abs(Math.log(Math.max(rf.N,1))));
      const d1q=Math.hypot(sub(one,q)[0],sub(one,q)[1]),cond=qIs1?0:(t==='1'?1e-15*rf.rho*(m+1)*(m+1)/(d1q*d1q):(t==='0'?1e-15*rf.rho/d1q:0));   // conditioning of the REFERENCE closed form (cancellation near q = 1), not of the viewer
      n++;worst=Math.max(worst,err/tol);if(!(err<=tol+cond)){bad++;console.log('  closed-form miss',st.shellMode,st.B,st.phi3,st.m,st.t1,st.t2,st.sTyped,st.n6,st.alpha,t,err,tol);}
      // direct reference walk agrees too
      const ee=rf.W[rf.W.length-1];if(!(Math.hypot(e.re-ee[0],e.im-ee[1])<=tol))bad++;
    }
  }
  ok('3. closed forms at tilt 0, 1, -1 (Kahan for -1) within the stated bound ('+n+' comparisons)',bad===0,'bad='+bad+' worst err/tol '+worst.toExponential(2));}
// exact weights at -1, 1 against independent BigInt fractions
{let bad=0;for(const t of ['-1','1']){const st=C.dialChange(fixtures[1],{tilt:t}),ex=JSON.parse(C.exportExact(st,null)).exact.tilt,m=Number(st.m);
    const gcd=(a,b)=>b?gcd(b,a%b):a;const refw=[];for(let j=1;j<=m;j++)refw.push(t==='1'?String(j):(j===1?'1':'1/'+j));
    if(ex.register!=='exact'||JSON.stringify(ex.weights)!==JSON.stringify(refw))bad++;}
  ok('3. exact weights at tilt -1 and 1 equal independent fractions (register exact)',bad===0);}
// ---- fractional tilt: numerical label and the stated bound formula
{const st=C.dialChange(fixtures[1],{tilt:'-1/2'}),ex=JSON.parse(C.exportExact(st,null)),num=NUM.compute(st),R=C.resolve(st);
  ok('3. fractional tilt: weights labelled numerical',ex.exact.tilt.register==='numerical'&&ex.exact.tilt.weights.every(w=>w.startsWith('numerical ')));
  const Nf=NUM.number(R.Nq),al=NUM.number(R.alpha),tl=-0.5,m=R.m,eps=Math.pow(2,-52);
  const rho=num.rho,expect=8*(m+2+Math.abs(al)*(1+Math.abs(Math.log(Nf)))+Math.abs(tl)*(1+Math.log(m)))*eps*Math.max(rho*1,1);
  ok('3. stated bound formula (tilt < 0: w_max = 1)',Math.abs(num.bound-expect)<=1e-18*Math.max(1,expect),num.bound+' vs '+expect);
  const st2=C.dialChange(fixtures[1],{tilt:'1/3'}),n2=NUM.compute(st2),exp2=8*(m+2+Math.abs(al)*(1+Math.abs(Math.log(Nf)))+(1/3)*(1+Math.log(m)))*eps*Math.max(n2.rho*Math.pow(m,1/3),1);
  ok('3. stated bound formula (tilt > 0: w_max = m^tilt)',Math.abs(n2.bound-exp2)<=1e-18*Math.max(1,exp2));
  ok('11. cyclotomic note gains the radicals sentence only for fractional tilt',/radicals/.test(ex.exact.cyclotomic_field.note)&&!/radicals/.test(JSON.parse(C.exportExact(C.dialChange(fixtures[1],{tilt:'1'}),null)).exact.cyclotomic_field.note));}
// ---- 4. gate: W1 = z_c1 at every tilt
{let bad=0,n=0;for(const st of states.slice(0,300))for(const t of ['-1','-3/5','1/7','1']){const num=NUM.compute(C.dialChange(st,{tilt:t}));if(num.refused||num.empty)continue;n++;
    if(num.W[1].re!==num.z[0].re||num.W[1].im!==num.z[0].im)bad++;if(!num.gate.ok)bad++;if(!num.chartCompat.ok)bad++;}
  ok('4. W1 = z_c1 exactly (w1 = 1), latitude gate and chartCompat pass ('+n+' cases)',bad===0,'bad='+bad);}
// ---- 5. line case
{let bad=0,n=0;const cases=[C.initial({shellMode:'integer',B:'5040',phi3:'5040',m:'720',t2:'2',sTyped:'2'}),C.initial({shellMode:'factorial',n1:'4',phi3:'20',m:'5',t2:'1',sTyped:'10'}),C.initial({shellMode:'integer',B:'24',phi3:'24',m:'9',t2:'2',sTyped:'0'})];
  for(const base of cases){for(const t of ['-1','-1/2','0','1/2','1']){const st=C.dialChange(base,{tilt:t}),rd=C.readouts(st);if(!rd.allAligned){bad++;continue;}
      const num=NUM.compute(st);if(num.refused){bad++;continue;}n++;
      const z1=num.z[0],L=Math.hypot(z1.re,z1.im);
      for(const w of num.W){const cross=Math.abs(w.re*z1.im-w.im*z1.re)/(L||1);if(!(cross<=num.bound*Math.max(1,num.W.length)))bad++;}}}
  ok('5. all-aligned: every vertex on the ray of z_c1 at every tilt, including N = 1, m = 720 ('+n+' cases)',bad===0,'bad='+bad);}
// ---- 6. meaning changes (unit part; the captions are checked in the browser test)
{const st=C.initial({shellMode:'factorial',n1:'5',phi3:'119',m:'6',t1:'1',t2:'1',sTyped:'1'}); // N = 1? check labReal
  const R=C.resolve(st),lab=X.isInt(X.mul(R.t1,X.parse(st.sTyped)));
  const n0=NUM.compute(st),n1=NUM.compute(C.dialChange(st,{tilt:'1'}));
  ok('6. t1*s in Z, tilt 0: Q-res within bound; tilt 1: Q-res exceeds its bound',lab&&n0.qres.value<=n0.qres.bound&&n1.qres.value>n1.qres.bound,n0.qres.value+' / '+n1.qres.value+' bound '+n1.qres.bound);
  const cx=C.initial({shellMode:'factorial',n1:'4',phi3:'20',m:'6',t1:'1/2',t2:'1',sTyped:'1'});   // N = 5, the v0.4.1 counterexample
  ok('6. v0.4.1 counterexample N = 5, m = 6, t1 = 1/2: t1*s not an integer (no star) at any tilt',!X.isInt(X.mul(C.resolve(C.dialChange(cx,{tilt:'1'})).t1,X.parse(cx.sTyped)))&&C.resolve(cx).Nq.n===5n);}
// ---- 8. address
{const a=C.encodeAddress(fixtures[1]);ok('8. tilt 0 never writes tilt',!/tilt/.test(a)&&!/tilt/.test(C.exportState(fixtures[1])));
  const rr=(s)=>C.decodeAddress(a+s);
  const r0=rr('&tilt=0'),r1=rr('&tilt=2/4'),r2=rr('&tilt=3'),r3=rr('&tilt=-1/2'),r4=rr('&tilt=-1/2&tilt=1/2');
  ok('8. tilt=0 refused with a reason',!r0.ok&&r0.reason.length>5,r0.reason);ok('8. tilt=2/4 refused with a reason',!r1.ok&&r1.reason.length>5,r1.reason);ok('8. tilt=3 refused with a reason',!r2.ok&&r2.reason.length>5,r2.reason);
  ok('8. tilt=-1/2 round-trips',r3.ok&&r3.state.tilt==='-1/2'&&C.encodeAddress(r3.state)===a+'&tilt=-1/2');ok('8. duplicate tilt refused',!r4.ok);
  const st=C.dialChange(fixtures[1],{tilt:'-1/2'}),back=C.importAny(C.exportState(st));ok('8. state JSON round-trips with tilt',back.ok&&back.state.tilt==='-1/2');
  ok('8. exact JSON imports with tilt',C.importAny(C.exportExact(st,null)).ok);
  ok('8. id unchanged',C.ADDRESS_ID==='fv-comb-hopf/0.2'&&/^#v=fv-comb-hopf\/0\.2&/.test(C.encodeAddress(st)));
  const old=C6.decodeAddress(C.encodeAddress(st));ok('8. (informative) the v0.4.6 reader refuses a tilt address visibly: '+old.reason,!old.ok&&/Unknown key tilt/.test(old.reason));
  ok('8. ADDRESS_KEYS unchanged (tilt is a separate optional key)',JSON.stringify(C.ADDRESS_KEYS)===JSON.stringify(C6.ADDRESS_KEYS)&&C.TILT_KEY==='tilt');}
// ---- 9. degenerate cases
{const n0=C.initial({shellMode:'factorial',n1:'3',phi3:'7',m:'7'});   // N = 0
  const u=C.dialChange(n0,{tilt:'-1'});ok('9. N = 0 empty state at tilt',NUM.compute(u).empty===true&&NUM.compute(n0).empty===true&&C.readouts(u).empty===true);
  const z6=C.dialChange(C.initial({shellMode:'factorial',n1:'3',phi3:'5',m:'7',n6:'0'}),{tilt:'1/2'}),zn=NUM.compute(z6);
  ok('9. n6 = 0 (rho = 0): every vertex at the origin, flagged',zn.rhoZero===true&&zn.W.every(w=>w.re===0&&w.im===0));
  const un=C.dialChange(C.initial({shellMode:'factorial',n1:'3',phi3:'5',m:'7',n6:'1/100000000000000000000000000000000000',alpha:'8'}),{tilt:'1'}),u2=NUM.compute(un),u0=NUM.compute(C.initial({shellMode:'factorial',n1:'3',phi3:'5',m:'7',n6:'1/100000000000000000000000000000000000',alpha:'8'}));
  ok('9. numeric range/underflow behaviour identical to tilt 0 ('+(u0.refused||'drawn')+')',(!!u0.refused)===(!!u2.refused)&&(u0.refused||'')===(u2.refused||''));
  const m2=C.dialChange(C.initial({shellMode:'factorial',n1:'3',phi3:'5',m:'2',t2:'1'}),{tilt:'1'}),nm=NUM.compute(m2);
  ok('9. m = 2: W2 = z(-1) + 2*z(+1)',Math.abs(nm.W[2].re-(nm.z[0].re+2*nm.z[1].re))<1e-12&&Math.abs(nm.W[2].im-(nm.z[0].im+2*nm.z[1].im))<1e-12);
  ok('9. range: tilt 2 refused, tilt -1 and 1 accepted',(()=>{try{C.dialChange(fixtures[1],{tilt:'2'});return false;}catch(e){return true;}})()&&C.dialChange(fixtures[1],{tilt:'-1'}).tilt==='-1'&&C.dialChange(fixtures[1],{tilt:'1'}).tilt==='1');}
// ---- 11. exactness of input
{const st=C.dialChange(fixtures[1],{tilt:'0.37'});ok('11. 0.37 is stored as 37/100',st.tilt==='37/100');
  const cmp0=C.dialChange(st,{tilt:'0.00'});ok('11. 0.00 returns to the absent form',cmp0.tilt===undefined&&C.encodeAddress(cmp0)===C.encodeAddress(fixtures[1]));
  ok('11. -0.6 stored as -3/5',C.dialChange(fixtures[1],{tilt:'-0.6'}).tilt==='-3/5');}
// ---- kernel standing text
{const ex=JSON.parse(C.exportExact(C.dialChange(fixtures[1],{tilt:'1'}),null)).exact.tilt;ok('standing: instrument-tier, no theorem standing, kernel v3.2.7 cited',/instrument-tier/.test(ex.standing)&&/no theorem standing/.test(ex.standing)&&/v3\.2\.7/.test(ex.standing));}
console.log('test-v047 unit: '+pass+' pass, '+fail+' fail');
process.exit(fail?1:0);
