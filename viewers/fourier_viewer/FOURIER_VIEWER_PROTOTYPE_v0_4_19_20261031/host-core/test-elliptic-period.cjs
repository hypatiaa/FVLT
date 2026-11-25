'use strict';
// v0.4.17 (SCHEMA_ADDENDUM_24) test for host-core/elliptic-period-core.js: guaranteed enclosures of e1, e2, e3, w1, w2/i, tau/i and Omega for 37a1
// against the Sage strings in fixtures/elliptic-37a1-fixture.json, at D = 50 and D = 100 (and every D from 10 to 100 for the width).
// The reference strings are treated as correct to within 10^-105 (the source's statement); Omega is printed with 58 places only, so it is compared
// at its own last place, and Omega = 2 w1 is also checked against the w1 string. pi is checked against this test's own Euler-formula enclosure.
const fs=require('fs'),path=require('path');
const P=require('./elliptic-period-core.js'),EX=require('./elliptic-exact-core.js'),NF=require('../build/no-float-elliptic.cjs');
let pass=0,fail=0;
function t(name,fn){let ok=false,msg='';try{const r=fn();ok=r===true;if(!ok&&r!==false)msg=' '+r;}catch(e){msg=' threw: '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+msg);ok?pass++:fail++;}
const fx=JSON.parse(fs.readFileSync(path.join(__dirname,'..','fixtures','elliptic-37a1-fixture.json'),'utf8'));
const A=fx.ainvs.map(s=>BigInt(s));
const P10=n=>10n**BigInt(n);
const widthOK=(I,W,D)=>(I.hi-I.lo)*P10(D)<=(1n<<W);
// reference rounded to d places (half up), when the +-10^-tol band does not straddle a rounding boundary; else null
function refRound(ref,d,tol){const m=/^(-?)([0-9]+)\.([0-9]+)$/.exec(ref),L=BigInt(m[3].length),R=BigInt(m[1]+m[2]+m[3]),tp=BigInt(tol),Lc=L>tp?L:tp,r=R*P10(Lc-L),e=P10(Lc-tp);
  const rd=x=>{const q=P10(Lc-BigInt(d));const v=2n*x+q;const den=2n*q;return v>=0n?v/den:-((-v+den-1n)/den);};const a=rd(r-e),b=rd(r+e);return a===b?P.fmt(a,BigInt(d)):null;}
const KEYS=[['e1','e1',105],['e2','e2',105],['e3','e3',105],['w1','w1',105],['w2_over_i','w2_over_i',105],['Omega','Omega',58]];
// cold timing at D = 100 (cache cleared), BigInt nanoseconds
P.CACHE.clear();const t0=process.hrtime.bigint();const R100=P.periods(A,100);const t1=process.hrtime.bigint();
const R50=P.periods(A,50);
const ms=(t1-t0)/1000000n,us=((t1-t0)/1000n)%1000n;
t('cold period computation at D = 100 (W = '+R100.W+' bits): '+ms+' ms '+us+' µs (process.hrtime.bigint); under 2 s',()=>ms<2000n);
for(const [R,D] of [[R50,50],[R100,100]]){const W=BigInt(R.W);
  t('D = '+D+': W = '+R.W+' working bits; Δ = '+R.disc+' > 0; not refused',()=>!R.refused&&R.disc==='37'&&W===P.workingBits(BigInt(D)));
  for(const [k,fk,tol] of KEYS){const I=k==='Omega'?R.raw.Omega:k==='w1'?R.raw.w1:k==='w2_over_i'?R.raw.w2:R.raw.e[['e1','e2','e3'].indexOf(k)];
    t('D = '+D+': '+k+' enclosure meets the Sage string ± 10^−'+tol+' and has width ≤ 10^−'+D+' ('+R[k].width+')',()=>P.meetsDecimal(I,W,fx[fk],tol)&&widthOK(I,W,D));
    t('D = '+D+': '+k+' guaranteed digits ('+R[k].places+' places) = the Sage string rounded to the same places'+(k==='Omega'&&D>56?' (compared at 56 places: the Omega string has 58)':''),()=>{const g0=R[k].digits,pl=R[k].places;if(pl!==String(D))return 'only '+pl+' places';const L=fx[fk].split('.')[1].length,dc=D<=L-2?D:L-2,g=dc===D?g0:P.digits(I,W,dc).text,want=refRound(fx[fk],dc,tol);
      if(want===null)return 'reference straddles a rounding boundary';return g.replace('−','-')===want.replace('−','-')||g+' vs '+want;});}
  t('D = '+D+': Omega = 2·w1 exactly as intervals, and 2·(w1 string) lies in the Omega enclosure ± 2·10^−105',()=>R.raw.Omega.lo===2n*R.raw.w1.lo&&R.raw.Omega.hi===2n*R.raw.w1.hi&&
     P.meetsDecimal({lo:R.raw.Omega.lo,hi:R.raw.Omega.hi},W,(()=>{const m=/^([0-9]+)\.([0-9]+)$/.exec(fx.w1),v=BigInt(m[1]+m[2])*2n,s=v.toString();return s.slice(0,s.length-m[2].length)+'.'+s.slice(s.length-m[2].length);})(),104));
  t('D = '+D+': tau/i = (w2/i)/w1 is consistent: tau/i · w1 meets w2/i (interval product)',()=>{const a=R.raw.tau,b=R.raw.w1,S=1n<<W,lo=(a.lo*b.lo)>>W,hi=((a.hi*b.hi)+S-1n)>>W;return lo<=R.raw.w2.hi&&hi>=R.raw.w2.lo;});
  t('D = '+D+': roots ordered e1 > e2 > e3 with disjoint enclosures',()=>{const [a,b,c]=R.raw.e;return a.lo>b.hi&&b.lo>c.hi;});
  t('D = '+D+': Vieta on the enclosures of 4x³ − 4x + 1: e1+e2+e3 ∋ 0, e1e2+e1e3+e2e3 ∋ −1, e1e2e3 ∋ −1/4',()=>{const [a,b,c]=R.raw.e,S=1n<<W;
    const sum={lo:a.lo+b.lo+c.lo,hi:a.hi+b.hi+c.hi};
    const mul=(x,y)=>{const ps=[x.lo*y.lo,x.lo*y.hi,x.hi*y.lo,x.hi*y.hi];let lo=ps[0],hi=ps[0];for(const p of ps){if(p<lo)lo=p;if(p>hi)hi=p;}return {lo:P.fdiv(lo,S),hi:P.cdiv(hi,S)};};
    const ab=mul(a,b),ac=mul(a,c),bc=mul(b,c),s2={lo:ab.lo+ac.lo+bc.lo,hi:ab.hi+ac.hi+bc.hi},abc=mul(ab,c);
    return sum.lo<=0n&&sum.hi>=0n&&s2.lo<=-S&&s2.hi>=-S&&abc.lo*4n<=-S&&abc.hi*4n>=-S;});
  for(const [nm,G] of [['AGM(√(e1−e3), √(e1−e2))',R.raw.agm1],['AGM(√(e1−e3), √(e2−e3))',R.raw.agm2]])
    t('D = '+D+': '+nm+' step table monotone over '+G.length+' rows: a_n.hi non-increasing, b_n.lo non-decreasing, b_n.lo ≤ a_n.hi; stop gap ≤ '+P.STOP_ULPS+' ulps',()=>{
      for(let i=0;i<G.length;i++){const s=G[i];if(s.b.lo>s.a.hi)return 'b > a at '+i;if(i>0){if(s.a.hi>G[i-1].a.hi)return 'a up at '+i;if(s.b.lo<G[i-1].b.lo)return 'b down at '+i;}}
      const L=G[G.length-1];return L.a.hi-L.b.lo<=P.STOP_ULPS;});
}
t('the AGM bound is reported in the record: '+R100.agm1.bound,()=>/b_n ≤ M ≤ a_n/.test(R100.agm1.bound)&&R100.agm1.stop>0);
// pi, against this test's own enclosure by Euler's formula pi = 4 atan(1/2) + 4 atan(1/3)
{const W=BigInt(R100.W),own=x=>{let s=0n,k=0n,pw=x,n=0n;const S=1n<<W;for(;;){const q=S/((2n*k+1n)*pw);if(q===0n)break;s+=k%2n===0n?q:-q;n++;k++;pw*=x*x;}return {lo:s-n-1n,hi:s+n+1n};};
 const a=own(2n),b=own(3n),E={lo:4n*(a.lo+b.lo),hi:4n*(a.hi+b.hi)},M=R100.raw.pi;
 t('π (Machin, '+R100.pi.terms.join(' + ')+' terms) meets an independent Euler-formula enclosure 4 atan(1/2) + 4 atan(1/3), width ≤ 10^−100',()=>M.lo<=E.hi&&M.hi>=E.lo&&widthOK(M,W,100));
 t('π digits at D = 100, point removed, begin with the integer 314159265358979323846264338327950288419716939937510 (3 and the first 50 places, a well-known constant)',()=>R100.pi.digits.replace('.','').startsWith(String(314159265358979323846264338327950288419716939937510n)));}
// every D
t('every D = 10 … 100: all seven readouts print D guaranteed places and have width ≤ 10^−D',()=>{for(let D=10n;D<=100n;D++){const R=P.periods(A,D),W=BigInt(R.W);
  for(const k of ['e1','e2','e3','w1','w2_over_i','tau_over_i','Omega'])if(R[k].places!==String(D))return 'D = '+D+' '+k+' '+R[k].places;
  for(const I of [...R.raw.e,R.raw.w1,R.raw.w2,R.raw.tau,R.raw.Omega])if(!widthOK(I,W,D))return 'width D = '+D;}return true;});
t('D outside 10 … 100 or not an integer is refused',()=>{for(const d of [9,101,'x']){try{P.periods(A,d);return 'accepted '+d;}catch(e){}}return true;});
// refusals
{const r=P.periods([0n,-1n,1n,-10n,-20n],50);t('Δ < 0 (11a1, Δ = '+r.disc+'): refused with the label “'+P.REFUSE_NEG+'”, no numbers',()=>r.refused&&r.label===P.REFUSE_NEG&&!r.w1);}
{const r=P.periods([0n,0n,0n,0n,0n],50);t('Δ = 0 (y² = x³): refused (singular)',()=>r.refused&&r.label===P.REFUSE_ZERO);}
// a second Δ > 0 curve, internal consistency only (no reference): y^2 = x^3 - x (Δ = 64, roots 1, 0, -1 exactly)
{const r=P.periods([0n,0n,0n,-1n,0n],30),W=BigInt(r.W),S=1n<<W;t('y² = x³ − x: exact roots 1, 0, −1 found as point intervals; w1 and w2/i agree (square lattice, τ = i)',()=>
  r.raw.e[0].lo===S&&r.raw.e[0].hi===S&&r.raw.e[1].lo===0n&&r.raw.e[2].lo===-S&&r.w1.digits===r.w2_over_i.digits&&r.tau_over_i.digits.replace('.','')===String(10n**30n));}
t('isqrt and isqrtCeil are exact floor and ceiling square roots on 2000 test values',()=>{for(let n=0n;n<2000n;n++){const a=P.isqrt(n*n*7n+n),b=P.isqrtCeil(n*n*7n+n),v=n*n*7n+n;if(a*a>v||(a+1n)*(a+1n)<=v||b*b<v||(b>0n&&(b-1n)*(b-1n)>=v))return 'n = '+n;}return true;});
// the static scan
{const sc=NF.scan();t('no-float-elliptic scan passes on all '+sc.length+' new files ('+sc.filter(r=>!r.missing&&!r.hits.length).length+' clean)',()=>sc.every(r=>!r.missing&&r.hits.length===0)||sc.filter(r=>r.missing||r.hits.length).map(r=>r.file+(r.missing?' missing':' '+r.hits.length)).join(', '));}
console.log('SUMMARY test-elliptic-period: '+pass+' passed, '+fail+' failed');
process.exit(fail?1:0);
