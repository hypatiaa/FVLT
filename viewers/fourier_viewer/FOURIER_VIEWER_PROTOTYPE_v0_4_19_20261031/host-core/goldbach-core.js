(function(root){
'use strict';
// fv-goldbach-core 0.1.0 (v0.4.14, SCHEMA_ADDENDUM_22): the Goldbach prime-pair mask. EXACT register: integers only (N <= 1,448), primality by exact trial division.
// Design: GOLDBACH_PRIME_PAIR_MASK_DESIGN_NOTE_v0_1_20261021 (NOTE.md, 4f2d1c9c…), saphir's decisions 1-7 (the note's leans). Display only: nothing here touches the state schema or an export.
// Setup for the Goldbach shell N (even, 4 <= N <= 1,448): integer mode, B = N/2 - 1, phi3 = 0 (so the viewer shell is N/2), t1 = 1, n6 = 1, alpha = 0, alpha_Tilt = 0.
// Convention B: t2 = 2 when N/2 is odd (then every a_p is even, odd m = a_max + 1, c = a_p/2), t2 = 1 when N/2 is even (every a_p odd, even m = a_max + 1, c = +-a_p);
// the equal pair alone (N = 4, or an empty fibre) needs an odd comb: m = 3.
// Mask: a walk weight w_c in {0, 1, 2}. w_c = 1 when N/2 + c*t2 and N/2 - c*t2 are both prime; the c = 0 tooth (the equal pair p = N/2) has weight 2 when N/2 is prime, so that
// the masked pen is exactly the kernel's G_N(s) (Cor II.23.5c). Every other tooth has weight 0 (ghosted by the views, never part of the pen).
const C=typeof module!=='undefined'&&module.exports?require('./comb-core.js'):root.FVCombCore;
const GB_MIN=4,GB_MAX=1448;
const isPrime=n=>{if(!Number.isInteger(n)||n<2)return false;if(n%2===0)return n===2;for(let d=3;d*d<=n;d+=2)if(n%d===0)return false;return true;};
function pairsOf(N){const o=[];for(let p=2;p<=N/2;p++)if(isPrime(p)&&isPrime(N-p))o.push({p,q:N-p,a:N/2-p});return o;}
const SET=new Map();
function settings(N,P){
  if(!Number.isInteger(N)||N%2!==0||N<GB_MIN||N>GB_MAX)throw Error('Goldbach N must be even, '+GB_MIN+' to '+GB_MAX+'.');
  if(!P&&SET.has(N))return SET.get(N);
  const Pn=P||pairsOf(N),n=N/2,amax=Pn.reduce((x,r)=>Math.max(x,r.a),0),t2=n%2===1?2:1,m=amax===0?3:amax+1;
  if(m>720)throw Error('Goldbach N = '+N+' needs m = '+m+' > 720.');
  const s={N,n,P:Pn,amax,t2,m,g:Pn.length};
  if(!P)SET.set(N,s);return s;
}
// the dial patch (comb-core dialChange) that reaches the Goldbach shell N; tilt '0' is stored as absence
function patchFor(N){const s=settings(N);return {shellMode:'integer',B:String(s.n-1),nMode:'integer',phi3:'0',m:String(s.m),t1:'1',t2:String(s.t2),n6:'1',alpha:'0'};}
// does the state sit exactly on the preset of some Goldbach N? {ok:true,N} | {ok:false,reason,N?}
function match(st){
  if(st.shellMode!=='integer'||st.nMode!=='integer'||st.phi3!=='0')return {ok:false,reason:'not on a Goldbach shell (integer mode, φ₃ = 0 required)'};
  let B;try{B=BigInt(st.B);}catch(e){return {ok:false,reason:'B is not an integer'};}
  const n=B+1n;if(n<BigInt(GB_MIN/2)||n>BigInt(GB_MAX/2))return {ok:false,reason:'N = '+(2n*n)+' is outside 4 … '+GB_MAX};
  const N=Number(2n*n),s=settings(N);
  if(st.m!==String(s.m)||st.t1!=='1'||st.t2!==String(s.t2)||st.n6!=='1'||st.alpha!=='0')return {ok:false,reason:'a dial left the preset of N = '+N,N};
  if(st.tilt!==undefined)return {ok:false,reason:'α_Tilt ≠ 0',N,tilt:true};
  return {ok:true,N};
}
// the mask over the teeth in offset order. opts.pairs injects another pair set (tests only: an empty fibre is not reachable for N <= 1,444).
function model(N,opts){
  const s=settings(N,opts&&opts.pairs),aset=new Set(s.P.map(r=>r.a)),n=s.n;
  const teeth=C.offsets(s.m).map(Number).map(c=>{const k=n+c*s.t2,q=N-k,kept=aset.has(Math.abs(c)*s.t2);return {c,k,q,kept,w:kept?(c===0?2:1):0};});
  return {N,n,t2:s.t2,m:s.m,P:s.P,g:s.g,G0:2*s.g,delta:isPrime(n)?1:0,emptyFiber:s.g===0,teeth,w:teeth.map(t=>t.w),kept:teeth.filter(t=>t.kept).length,removed:teeth.filter(t=>!t.kept).length};
}
const GUARDS={
  empty:'Empty-fiber guard. The identity remains true when P_N is empty, in which case G_N≡0. The corollary therefore makes no Goldbach-coverage claim.',
  interference:'Interference register. “Constructive” and “destructive” interference mean only addition and cancellation of complex vectors in this finite sum. No physical-wave, quantum, probability or pair-count implication follows from |G_N(s)| at a selected spin.',
  closure:'Closure reaches conjugation, not Goldbach.',
  unit:'Unit-fiber guard. Every nondegenerate Goldbach pair p≠N-p has gcd(p,N)=gcd(N-p,N)=1; otherwise the prime divisor common to one endpoint and N also divides the other, forcing the equal pair. The equal pair p=N/2, when prime, is not a unit modulo N.',
  status:'Status. Common-carrier factorization: unconditional. Prime selection: definitional/external. Nonempty coverage for all even N: not claimed here and remains conditional under III.11 / Thm 6.3. Density or asymptotics: not claimed.'};
const GHOST_LABEL='removed by the prime filter: N/2 ± c not both prime';
const PRIOR_ART='Prior art: the correspondence between the Goldbach phasor trajectory and the Fourier m-comb was stated earlier in GOLDBACH_COMB_CORRESPONDENCE_v0.2.md (2026-07-20, Fable, Sol and Codex) and Codex’s goldbach_clifford_adapter_v0_7_1.html (a per-pair mask, the resultant G_N(s) and the native lift (N/2, −a_p)). Nothing is ported from either: this track is the same identity inside the v0.4 comb, with its exact phases, its R21 gate and its branch chips.';
const api={GB_MIN,GB_MAX,isPrime,pairsOf,settings,patchFor,match,model,GUARDS,GHOST_LABEL,PRIOR_ART};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVGoldbach=api;
})(typeof globalThis!=='undefined'?globalThis:this);
