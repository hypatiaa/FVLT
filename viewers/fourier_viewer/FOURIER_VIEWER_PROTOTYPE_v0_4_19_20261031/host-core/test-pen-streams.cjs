'use strict';
// v0.4.18 (SCHEMA_ADDENDUM_25) test-pen-streams: the sign streams of the surface pens (EXACT register). Node only, no floating point.
// Expected values: the skeleton's caSigns / coinSigns (verbatim transcription), an independent BigInt primality test for the Goldbach mask.
const ST=require('./pen-streams-core.js'),GB=require('./goldbach-core.js'),TR=require('./transcription-skeleton-pens.cjs');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const same=(a,b)=>a.length===b.length&&Array.from(a).every((v,i)=>v===b[i]);
const isPrimeB=n=>{n=BigInt(n);if(n<2n)return false;for(let d=2n;d*d<=n;d++)if(n%d===0n)return false;return true;};   // independent: BigInt, every divisor
// ---- Rule 30, Rule 150, coin against the transcription
for(const T of [0,1,2,300,1328,4096]){
  ok('Rule 30 signs = skeleton caSigns(30, '+T+')',same(ST.caRun(30,T).s,TR.caSigns(30,T)));
  ok('Rule 150 signs = skeleton caSigns(150, '+T+')',same(ST.caRun(150,T).s,TR.caSigns(150,T)));}
for(const seed of [1,5,2,4294967295])for(const T of [300,4096])ok('coin seed '+seed+' T = '+T+' = skeleton coinSigns (xorshift32 13, 17, 5; + on odd)',same(ST.coinSigns(T,BigInt(seed)),TR.coinSigns(T,seed)));
{const r=ST.caRun(150,4096);ok('Rule 150: the centre cell x_t(0) is black for every t < 4096 (kit center150)',r.q.every(v=>v===1));}
{const r=ST.caRun(30,4096);let bad=0;for(let t=0;t<4096;t++){if(r.s[t]!==((r.q[t]^r.r[t])?-1:1))bad++;if(r.tooth[t]!==(r.q[t]&r.r[t]))bad++;}
  let teeth=0;for(const v of r.tooth)teeth+=v;ok('Rule 30: s_t = −1 exactly when q XOR r = 1, tooth exactly when q = r = 1 ('+teeth+' tooth events in 4096 steps)',bad===0);}
// Rule 30 centre column: first 32 values from a direct BigInt row computation (rule 30 on the integer x, seed 1 at bit 0 with the row centred)
{let row=1n<<5000n;const c=[];for(let t=0;t<32;t++){c.push(((row>>5000n)&1n)===1n?1:0);const L=row<<1n,R=row>>1n;row=(L^(row|R));}   // left neighbour of bit i is bit i+1
  const r=ST.caRun(30,32);ok('Rule 30 centre x_t(0), t < 32, equals an independent BigInt row computation',same(r.q,c),r.q.join('')+' vs '+c.join(''));}
ok('seed 0 and 2^32 are refused',(()=>{let n=0;for(const s of [0n,4294967296n,-1n,'x']){try{ST.coinSigns(8,s);}catch(e){n++;}}return n===4;})());
ok('T outside 0 … 4096 or not an integer is refused',(()=>{let n=0;for(const T of [-1,4097,'8']){try{ST.caRun(30,T);}catch(e){n++;}}return n===3;})());
// ---- Goldbach shells
{let bad=[],lenBad=[],relBad=[],orderBad=[];
  for(let N=4;N<=1448;N+=2){const g=ST.goldbachShell(N),md=GB.model(N);
    if(g.len!==md.teeth.length||g.len!==md.m)lenBad.push(N);
    if(!g.relation.holds)relBad.push(N);
    // each sign from an independent primality test: kept iff N/2 + c t2 and N/2 - c t2 are both prime
    for(let i=0;i<g.len;i++){const c=BigInt(g.c[i]),n=BigInt(N/2),t2=BigInt(g.t2),kept=isPrimeB(n+c*t2)&&isPrimeB(n-c*t2);if((g.s[i]>0)!==kept){bad.push(N+':'+c);break;}}
    // the order: c = 0 first, then |c| = 1, 2, ... with +c before -c
    const key=c=>2*(c<0?-c:c)-(c>0?1:0);for(let i=1;i<g.len;i++)if(key(g.c[i])<=key(g.c[i-1])){orderBad.push(N);break;}}
  ok('every Goldbach shell N = 4 … 1448: one sign per tooth, stream length = number of teeth m',lenBad.length===0,lenBad.join(','));
  ok('every shell: + exactly on the teeth with N/2 ± c·t₂ both prime (independent BigInt primality), − on the ghosted teeth',bad.length===0,bad.join(','));
  ok('every shell: tooth order c = 0, 1, −1, 2, −2, … (as present in the comb)',orderBad.length===0,orderBad.join(','));
  ok('every shell: #+ = 2g(N) − δ (δ = 1 when N/2 is prime: the equal pair counted once)',relBad.length===0,relBad.join(','));}
for(const [N,g,plus,len] of [[4,1,1,3],[6,1,1,3],[24,3,6,8],[26,3,5,11],[1448,20,40,706]]){const s=ST.goldbachShell(N);
  ok('N = '+N+': g(N) = '+g+', #+ = '+plus+', teeth '+len+', net turning (#+ − #−)·90° = '+(2*plus-len)+'·90°',s.g===g&&s.plus===plus&&s.len===len&&s.netQuarterTurns===2*plus-len,JSON.stringify([s.g,s.plus,s.len]));}
{const s=ST.goldbachShell(24,{pairs:[]});ok('empty-fibre guard (injected empty pair set, unreachable for 4 ≤ N ≤ 1448): g = 0, every tooth ghosted, the label is set',s.g===0&&s.plus===0&&s.empty&&/empty prime-pair fibre/.test(s.emptyLabel));}
{let mn=1000;for(let N=4;N<=1448;N+=2){const g=ST.goldbachShell(N).g;if(g<mn)mn=g;}ok('g(N) ≥ 1 for every even 4 ≤ N ≤ 1448 (so the empty-fibre label never shows on a real shell): min g = '+mn,mn>=1);}
// ---- Goldbach run
{const t0=process.hrtime.bigint(),r=ST.goldbachRun(1448),ms=(process.hrtime.bigint()-t0)/1000000n;let L=0,P=0,ok2=true;const b=[];
  for(let N=4;N<=1448;N+=2){const s=ST.goldbachShell(N);b.push(L);for(let i=0;i<s.len;i++)if(r.s[L+i]!==s.s[i])ok2=false;L+=s.len;P+=s.plus;}
  ok('Goldbach run to 1448 = the 723 shells concatenated in order ('+r.len+' signs, '+r.plus+' +), boundaries at the shell starts',ok2&&r.len===L&&r.plus===P&&r.shells===723&&r.bounds.length===723&&r.bounds.every((x,i)=>x===b[i]));
  ok('Goldbach run to 1448: '+r.relation.text+' (holds); built in '+ms+' ms',r.relation.holds);
  ok('Goldbach run is biased to − ('+r.minus+' − against '+r.plus+' +); recorded as a drawing-register observation only',r.minus>r.plus);}
ok('N_max must be even and 4 … 1448',(()=>{let n=0;for(const N of [2,5,1450]){try{ST.goldbachRun(N);}catch(e){n++;}}return n===3;})());
ok('the printed guards carry the brief wording',ST.GUARDS.pen==='The pen draws the prime-pair mask; it proves nothing about Goldbach.'&&ST.GUARDS.closure==='Closure reaches conjugation, not Goldbach.');
console.log('SUMMARY test-pen-streams: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
