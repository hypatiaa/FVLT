(function(root){
'use strict';
// fv-rule30-ladder-core 0.1.0 (v0.4.16, SCHEMA_ADDENDUM_23): the Rule 30 ladder-monodromy card D1. EXACT register: integers only (BigInt for the state x, plain
// integers for t, N, per, S, all far below 2^53 at J_MAX = 34). No DOM, no floats. The view layer turns the exact rationals into angles.
// Idea (writing Rule 30 on surfaces): saphir. Facts F1-F3: the rule30 track and its kit. Brief: BUILD_BRIEF_v0_4_16_RULE30_D1.md.
// T-functions on the seed x(0) = 1 (bit j of x(t) is the right diagonal A(j, t)):
//   rule 30: F(x) = x XOR ((x<<1) OR (x<<2));  rule 90: F(x) = x XOR (x<<2);  rule 150: F(x) = x XOR (x<<1) XOR (x<<2).
// New bit j is x_j XOR psi_j with psi_j(s) = x_{j-1} OR x_{j-2} (30), x_{j-2} (90), x_{j-1} XOR x_{j-2} (150); negative indices are 0. psi_j(s) = 1 is an "event".
// N_j(t) = #{ s < t : psi_j(s) = 1 } (the helix height in half-turns). F1: A(j, t) = (A(j, 0) + N_j(t)) mod 2.
// per_n = length of the orbit of 1 mod 2^n (per_0 = 1). The base cycle of row j is per_j (the rows below j). S_j = N_j(per_j). per_{j+1} = 2 per_j iff S_j is odd.
const RULES=[30,90,150],J_MAX=34,NBITS=J_MAX+1;   // bits 0 .. 34 are carried, so per_35 (the cycle of every row j <= 34) is exact
const QS=[1,2,4,8];
function checkRule(r){r=Number(r);if(RULES.indexOf(r)<0)throw Error('rule must be 30, 90 or 150 (got '+r+')');return r;}
function checkJ(j){j=Number(j);if(!Number.isInteger(j)||j<0||j>J_MAX)throw Error('j must be an integer 0 … '+J_MAX+' (got '+j+')');return j;}
function checkQ(q){q=Number(q);if(QS.indexOf(q)<0)throw Error('q must be 1, 2, 4 or 8 (got '+q+')');return q;}
// one step of the T-function, mod 2^n (BigInt)
function step(rule,x,n){
  rule=checkRule(rule);const mask=(1n<<BigInt(n))-1n;
  const y=rule===30?(x^((x<<1n)|(x<<2n))):rule===90?(x^(x<<2n)):(x^(x<<1n)^(x<<2n));
  return y&mask;
}
const CACHE=new Map();
// the orbit of 1 mod 2^35 over one full cycle (per_35 states), its bits, the per_n table and the psi rows. Built once per rule.
function table(rule){
  rule=checkRule(rule);if(CACHE.has(rule))return CACHE.get(rule);
  const xs=[];let x=1n;const LIM=1<<20;
  do{xs.push(x);x=step(rule,x,NBITS);if(xs.length>LIM)throw Error('orbit longer than '+LIM+' (not expected)');}while(x!==1n);
  const P=xs.length;   // per_35
  const bits=[];for(let j=0;j<NBITS;j++){const b=new Uint8Array(P),bj=BigInt(j);for(let t=0;t<P;t++)b[t]=Number((xs[t]>>bj)&1n);bits.push(b);}
  // per_n for n = 0 .. 35: the first t > 0 with x(t) = 1 mod 2^n (per_0 = 1 by definition)
  const per=[1];for(let n=1;n<=NBITS;n++){const mask=(1n<<BigInt(n))-1n;let p=1;while(p<P&&(xs[p]&mask)!==1n)p++;per.push(p);}
  const zero=new Uint8Array(P);
  const psi=[];for(let j=0;j<NBITS;j++){const a=j>=1?bits[j-1]:zero,b=j>=2?bits[j-2]:zero,r=new Uint8Array(P);
    for(let t=0;t<P;t++)r[t]=rule===30?(a[t]|b[t]):rule===90?b[t]:(a[t]^b[t]);psi.push(r);}
  // prefix sums of psi_j over one base cycle per_j: pre[j][t] = N_j(t) for 0 <= t <= per_j
  const pre=[],S=[];for(let j=0;j<NBITS;j++){const pj=per[j],a=new Int32Array(pj+1);for(let t=0;t<pj;t++)a[t+1]=a[t]+psi[j][t];pre.push(a);S.push(a[pj]);}
  // lift_iff, asserted for every j <= 34: per_{j+1} = 2 per_j iff S_j odd, else per_{j+1} = per_j
  for(let j=0;j<=J_MAX;j++){const want=S[j]%2===1?2*per[j]:per[j];if(per[j+1]!==want)throw Error('lift_iff violated at rule '+rule+', j = '+j+': per_j = '+per[j]+', S_j = '+S[j]+', per_{j+1} = '+per[j+1]);}
  const T={rule,P,xs,bits,per,psi,pre,S};CACHE.set(rule,T);return T;
}
const orbit=rule=>table(rule).xs.slice();               // x(t) mod 2^35, t = 0 .. per_35 - 1 (BigInt)
const perN=(rule,n)=>{n=Number(n);if(!Number.isInteger(n)||n<0||n>NBITS)throw Error('n must be 0 … '+NBITS);return table(rule).per[n];};
const mod=(t,p)=>((t%p)+p)%p;
function A(rule,j,t){j=checkJ(j);const T=table(rule);return T.bits[j][mod(Number(t),T.P)];}
function psi(rule,j,s){j=checkJ(j);const T=table(rule);return T.psi[j][mod(Number(s),T.P)];}
// N_j(t) for any integer t >= 0: whole base cycles contribute S_j each (psi_j has period per_j, since it reads only rows below j)
function N(rule,j,t){j=checkJ(j);t=Number(t);if(!Number.isInteger(t)||t<0)throw Error('t must be a non-negative integer');const T=table(rule),p=T.per[j];return Math.floor(t/p)*T.S[j]+T.pre[j][t%p];}
const S=(rule,j)=>table(rule).S[checkJ(j)];
// doubling set: the j in 0 .. jmax with per_{j+1} = 2 per_j
function doublingSet(rule,jmax){const T=table(rule),out=[];jmax=jmax===undefined?J_MAX:checkJ(jmax);for(let j=0;j<=jmax;j++)if(T.per[j+1]===2*T.per[j])out.push(j);return out;}
const gcd=(a,b)=>{a=Math.abs(a);b=Math.abs(b);while(b){const r=a%b;a=b;b=r;}return a;};
// first return of the lifted curve: k = q / gcd(q, S_j) base turns (gcd(q, 0) = q, so S_j = 0 gives k = 1)
function kTurns(q,Sj){q=checkQ(q);return q/gcd(q,Number(Sj));}
const red=(n,d)=>{const g=gcd(n,d)||1;return [n/g,d/g];};
// ones count of row j over a window of length L starting at t = 0 (the fixture reads L = per_{j+1})
function ones(rule,j,L){j=checkJ(j);const T=table(rule),b=T.bits[j];let c=0;for(let t=0;t<L;t++)c+=b[mod(t,T.P)];return c;}
// the lifted curve of row j at lift dial q (declared lift rule, SCHEMA_ADDENDUM_23 §3): t = 0 .. k*per_j, each base step t -> t+1 cut into `sub` equal parts.
// Point i/sub of step t: base = (t + i/sub)/per_j turns; fibre = (N_j(t) + psi_j(t)*i/sub)/q turns (monotone forward on an event, constant otherwise).
// Both are exact reduced rationals [num, den] in turns (angle = 2*pi*num/den). The last point is (k, k*S_j/q) = an integer pair: the curve closes.
function curve(rule,j,q,opts){
  rule=checkRule(rule);j=checkJ(j);q=checkQ(q);const T=table(rule),p=T.per[j],Sj=T.S[j],k=kTurns(q,Sj),steps=k*p;
  const sub=Math.max(1,Math.floor(Number(opts&&opts.sub)||1)),pts=[];
  for(let t=0;t<steps;t++){const n0=N(rule,j,t),e=T.psi[j][t%p];
    for(let i=0;i<sub;i++)pts.push({base:red(t*sub+i,p*sub),fibre:red(n0*sub+e*i,q*sub),event:e,t});}
  pts.push({base:red(steps,p),fibre:red(N(rule,j,steps),q),event:0,t:steps});
  return {rule,j,q,per:p,S:Sj,k,steps,sub,points:pts};
}
// the card record (exact): label text, monodromy, degenerate flags
function card(rule,j,q){
  rule=checkRule(rule);j=checkJ(j);q=checkQ(q);const T=table(rule),p=T.per[j],Sj=T.S[j],k=kTurns(q,Sj),odd=Sj%2===1,dens=red(ones(rule,j,T.per[j+1]),T.per[j+1]);
  const deg=[];
  if(q===1)deg.push({kind:'q1',label:'fibre constant (q = 1)'});
  if(Sj===0)deg.push({kind:'S0',label:'S_j = 0: no events over the base cycle, so the curve is a pure base circle'});
  if(j===0)deg.push({kind:'j0',label:'j = 0: per_0 = 1 and ψ_0 ≡ 0 (bit 0 is constant 1)'});
  if(dens[0]===0)deg.push({kind:'dens0',label:'row '+j+' of rule '+rule+' has density 0 over per_'+(j+1)+' = '+T.per[j+1]+' (A('+j+', t) = 0 for every t)'});
  const label='row '+j+', rule '+rule+', q = '+q+': S_'+j+' = '+Sj+', closes after '+k+' turn'+(k===1?'':'s');
  return {rule,j,q,per:p,perNext:T.per[j+1],S:Sj,k,odd,monodromy:odd?'monodromy nontrivial':'trivial (stall)',doubling:T.per[j+1]===2*p,
    density:dens,fibreTotal:red(k*Sj,q),label,degenerate:deg,events:T.pre[j][p]};
}
const api={RULES,J_MAX,NBITS,QS,step,table,orbit,perN,A,psi,N,S,doublingSet,kTurns,gcd,ones,curve,card};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVRule30Ladder=api;
})(typeof globalThis!=='undefined'?globalThis:this);
