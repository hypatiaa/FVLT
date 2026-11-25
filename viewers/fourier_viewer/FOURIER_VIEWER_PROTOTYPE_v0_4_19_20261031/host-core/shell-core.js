(function(root){
'use strict';
// fv-shell-core 0.1.0: EXACT register. Primality, factorisation, totients, shell contrast and bracket, divisors (addendum 2 s2.4, s2.5),
// order-m Wilson witness (s2.3). All BigInt.
// Primality: deterministic Miller-Rabin with the first 13 primes as bases (proven for n < 3.3e24), after trial division by small primes.
// Factorisation: that test plus Pollard rho (Brent); every factorisation is verified by multiplication before it is returned.
const X=typeof module!=='undefined'&&module.exports?require('../exact-lib/exact-lib-0.2.0.js'):root.FVExact;
const DIVISOR_LIMIT=10n**18n;
const SMALL=[2n,3n,5n,7n,11n,13n,17n,19n,23n,29n,31n,37n,41n];
const mulmod=(a,b,m)=>a*b%m;
function powmod(b,e,m){let r=1n;b%=m;while(e>0n){if(e&1n)r=r*b%m;b=b*b%m;e>>=1n;}return r;}
function isPrime(n){
  if(n<2n)return false;for(const p of SMALL){if(n===p)return true;if(n%p===0n)return false;}
  let d=n-1n,r=0n;while(d%2n===0n){d/=2n;r++;}
  for(const a of SMALL){let x=powmod(a,d,n);if(x===1n||x===n-1n)continue;let c=false;
    for(let i=1n;i<r;i++){x=x*x%n;if(x===n-1n){c=true;break;}}if(!c)return false;}
  return true;
}
const gcd=X.gcd;
function rho(n){
  if(n%2n===0n)return 2n;
  for(let c=1n;;c++){let x=2n,y=2n,d=1n;const f=v=>(v*v+c)%n;
    while(d===1n){x=f(x);y=f(f(y));d=gcd(x>y?x-y:y-x,n);}
    if(d!==n)return d;}
}
function factor(n){                                      // -> Map prime -> exponent (n >= 1)
  if(n<1n)throw Error('factor: positive integer required.');
  const out=new Map(),add=(p,k=1)=>out.set(p,(out.get(p)||0)+k);
  for(let p=2n;p<1000n&&p*p<=n;p++)while(n%p===0n){add(p);n/=p;}
  const stack=[n];
  while(stack.length){const v=stack.pop();if(v===1n)continue;
    if(isPrime(v)){add(v);continue;}
    const d=rho(v);stack.push(d,v/d);}
  let prod=1n;for(const [p,k] of out)prod*=p**BigInt(k);
  return out;
}
function factorChecked(n){const f=factor(n);let p=1n;for(const [q,k] of f)p*=q**BigInt(k);if(p!==n)throw Error('factorisation failed verification');return f;}
function totient(n){if(n<1n)throw Error('totient: n >= 1');let r=n;for(const [p] of factorChecked(n))r=r/p*(p-1n);return r;}
function tau(n){let t=1n;for(const [,k] of factorChecked(n))t*=BigInt(k+1);return t;}
// contrast = (phi(N-1)+phi(N+1)) / (2 phi(N)), exact rational; undefined for N < 2
function contrast(N){
  if(N<2n)return null;
  const num=totient(N-1n)+totient(N+1n),den=2n*totient(N);return X.rat(num,den);
}
// contrast band by EXACT rational comparison against 3 and 2 (no float): defend > 3, warn > 2, else dim; lock iff > 3
function contrastBand(c){
  if(c===null||c===undefined)return null;
  const hi=X.cmp(c,X.rat(3n))>0,mid=X.cmp(c,X.rat(2n))>0;return {band:hi?'defend':mid?'warn':'dim',lock:hi};
}
function bracket(N){                                     // B(N-1,N+1)
  const l=isPrime(N-1n),r=isPrime(N+1n);return l&&r?'TWIN':l?'LEFT_PRIME':r?'RIGHT_PRIME':'NULL';
}
function divisors(n){let ds=[1n];for(const [p,k] of factorChecked(n)){const nx=[];let pk=1n;for(let i=0;i<=k;i++){for(const d of ds)nx.push(d*pk);pk*=p;}ds=nx;}return ds.sort((a,b)=>a<b?-1:a>b?1:0);}
// Divisors card. ts = t2*s as an exact rational; B1 = B+1 (largest shell). tAbs2 = |t2|, s positive-flag for Div(s) labelling.
function divisorsReport(t2,s,B1){
  const ts=X.mul(t2,s);
  if(t2.n===0n||s.n===0n)return {kind:'zero',label:'all shell N align because t₂·s = 0 — no finite Div(0) or τ(0)'};
  if(ts.d!==1n)return {kind:'nonint',label:'t₂·s = '+X.text(ts)+' ∉ ℤ: no shell N has t₂·s/N ∈ ℤ'};
  const T=ts.n<0n?-ts.n:ts.n;
  if(T>DIVISOR_LIMIT)return {kind:'refused',label:'|t₂·s| = '+T+' exceeds the declared factorisation limit 10^18: refused, no list shown.'};
  const all=divisors(T),list=all.filter(d=>d<=B1),trunc=T>B1;
  const div_s=t2.d===1n&&(t2.n===1n||t2.n===-1n)&&s.n>0n&&s.d===1n;
  let head,tag='';
  if(div_s){head='Div(s):';tag=T===1n?'unit':isPrime(T)?'s is PRIME':'τ(s) = '+all.length+', composite';}
  else{head='shell contacts N | |t₂·s| = '+T+' — NOT Div(s):';tag=trunc?'shell-truncated':'';}
  return {kind:'list',T,list,truncated:trunc,tag,label:head+' {'+list.join(', ')+'}'+(tag?' — '+tag:'')};
}
// Order-m Wilson witness for a candidate p (2 <= p <= 10000)
function orderWitness(p){
  if(p<2n||p>10000n)throw Error('p must be 2–10000.');
  let phi=0n;for(let k=1n;k<p;k++)if(gcd(k,p)===1n)phi++;
  const prime=phi===p-1n;let f=1n;for(let k=2n;k<=p-1n;k++)f=f*k%p;     // (p-1)! mod p
  const n1=p-1n;let g=1n;for(let k=2n;k<=n1;k++)g=g*k%p;
  return {p,n1,prime,phi,delta:p-1n-phi,residue:(g+1n)%p,wilsonOk:prime===((g+1n)%p===0n),lod:p>500n};
}
const api={DIVISOR_LIMIT,isPrime,factor:factorChecked,totient,tau,contrast,contrastBand,bracket,divisors,divisorsReport,orderWitness};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVShell=api;
})(typeof globalThis!=='undefined'?globalThis:this);
