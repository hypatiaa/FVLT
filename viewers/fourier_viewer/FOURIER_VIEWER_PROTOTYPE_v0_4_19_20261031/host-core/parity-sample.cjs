'use strict';
// Informative parity sample (not R18): 2000 random integer-gear states, rebuild vs frozen v0.3.2 comb-core.js / control-math.js (read-only load).
// Every difference is listed with its class: (a) mandated by R20/R21, (d) reference defect reproduced by exact arithmetic, or UNEXPLAINED.
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js');
const F='C:/Users/robin/s6_atom/cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/';
const HC=require(F+'comb-core.js'),HM=require(F+'control-math.js');
let seed=0x12345678;const rnd=()=>{seed^=seed<<13;seed>>>=0;seed^=seed>>>17;seed^=seed<<5;seed>>>=0;return seed/4294967296;};
const ri=(a,b)=>a+Math.floor(rnd()*(b-a+1)),pick=a=>a[ri(0,a.length-1)];
const P=X.parse,T=X.text;
// host stepper with an explicit epsilon, for the integer-snap branch (host: near = |s - nearest| * 1000 < 1)
function hostSnap(s,dir,eps){const fl=(n,d)=>X.floorDiv(n,d),nearest=fl(2n*s.n+s.d,2n*s.d);
  const near=eps?X.qabs(X.sub(s,X.rat(nearest)))&&(X.cmp(X.mul(X.qabs(X.sub(s,X.rat(nearest))),X.rat(1000n)),X.rat(1n))<0):X.eq(s,X.rat(nearest));
  return near?X.rat(nearest+BigInt(dir)):dir>0?X.rat(X.ceil(s)):X.rat(X.floor(s));}
const stats={states:0,phaseDiff:0,stepCompared:0,stepSame:0,diffs:{}};const ex=[];
const note=(cls,msg)=>{stats.diffs[cls]=(stats.diffs[cls]||0)+1;if(ex.filter(e=>e.cls===cls).length<4)ex.push({cls,msg});};
for(let i=0;i<2000;i++){
  stats.states++;
  const m=pick([2,3,4,5,6,7,8,9,12,30,60,ri(2,720)]),N=BigInt(pick([1,2,3,7,12,25,121,ri(1,5000),ri(1,1e6)])),B=N<2n?2n:N-1n<2n?2n:N-1n,phi3=B+1n-N;
  const t1=pick([1,2,3,-1,-2,-3,5,0,ri(-9,9)]),t2=pick([1,2,3,-1,-2,-3,5,0,ri(-9,9)]);
  const sd=pick([1,2,3,4,6,10,100,720]),sn=ri(-5000,5000),s=X.rat(BigInt(sn),BigInt(sd));
  const dir=rnd()<0.5?1:-1;
  const st={...C.initial({shellMode:'integer',B:String(B),phi3:String(phi3),m:String(m),t1:String(t1),t2:String(t2),n6:'1',alpha:'0',sTyped:T(s)}),sEff:T(s),E:T(X.cmp(X.qabs(s),X.rat(N))>0?X.qabs(s):X.rat(N))};
  // exact phases (host compute() refuses N = 0 and radius cases; here N >= 1, rho = 1)
  const h=HC.compute({shellMode:'integer',n1:'4',base:String(B),phi3:String(phi3),combM:String(m),t1:String(t1),t2:String(t2),s:T(s),n6:'1',alpha:'0'});
  const mine=C.teeth(st);
  mine.forEach((t,k)=>{const ht=h.teeth[k];if(String(ht.c)!==String(t.c)||T(ht.k)!==T(t.k)||T(X.div(X.sub(ht.phase,t.phase),X.rat(2n))).includes('/'))stats.phaseDiff++;});
  // stepping
  const mineR=C.step(st,dir),host=HM.nextSpin(T(s),N,m,String(t1),String(t2),dir,P(st.E));
  stats.stepCompared++;
  const hv=P(host.value);
  if(mineR.outcome==='refused'){
    if(m>=3&&(t1===0||t2===0)){   // host's integer gearbox is inactive here: it snaps (possibly then clamps to the range); the rebuild refuses
    note('(a) R20.2/4e: refusal where the host snaps to an integer',m+' t1='+t1+' t2='+t2+' N='+N+' s='+T(s)+' mine refused ('+mineR.reason.slice(0,40)+') host '+host.value);}
    else note('UNEXPLAINED','refused but m='+m+' t1='+t1+' t2='+t2);
    continue;
  }
  const mv=P(mineR.value);
  if(X.eq(mv,hv)){stats.stepSame++;continue;}
  if(m===2){
    const h1=hostSnap(s,dir,true),h0=hostSnap(s,dir,false);
    if(X.eq(h1,hv)&&X.eq(h0,mv))note('(d) host epsilon skip (|s - nearest|*1000 < 1) reproduced with eps; eps = 0 reproduces the rebuild',m+' s='+T(s)+' dir '+dir+' host '+host.value+' mine '+mineR.value);
    else note('UNEXPLAINED','PAIR m=2 s='+T(s)+' host '+host.value+' mine '+mineR.value);
  }else note('UNEXPLAINED','m='+m+' t1='+t1+' t2='+t2+' N='+N+' s='+T(s)+' dir '+dir+' host '+host.value+' ('+host.kind+') mine '+mineR.value+' ('+mineR.outcome+')');
}
console.log('parity sample: '+stats.states+' states; exact phase/k_c differences: '+stats.phaseDiff+'; stepper compared '+stats.stepCompared+', identical value '+stats.stepSame);
for(const [k,v] of Object.entries(stats.diffs))console.log('  '+v+' x '+k);
for(const e of ex)console.log('    e.g. ['+e.cls.slice(0,3)+'] '+e.msg);
const unexplained=stats.diffs['UNEXPLAINED']||0;console.log('UNEXPLAINED differences: '+unexplained);
process.exit(unexplained||stats.phaseDiff?1:0);
