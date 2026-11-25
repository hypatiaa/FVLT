'use strict';
// v0.4.18 (SCHEMA_ADDENDUM_25) test-pen-fields: the exact fields F = Q(sqrt2, sqrt5, tau), K = Q(sqrt3, sqrt5), SU(1,1) over F, and the interval core.
// No floating point. Reference constants: well-known decimal expansions, compared by guaranteed digits only.
const FQ=require('./field-q2-q5-tau.js'),IV=require('./pen-interval-core.js');
const {F,K,C,SU}=FQ;
const dec=(i,f)=>i+'.'+f;   // decimal strings from integer strings (keeps the lexical no-float scan strict)
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
// a deterministic pseudo-random generator on BigInt (no floats): LCG mod 2^61 - 1
let seed=12345n;const rnd=m=>{seed=(seed*48271n)%2305843009213693951n;return seed%m;};
const rElem=(T)=>T.make(Array.from({length:T.DIM},()=>rnd(41n)-20n),rnd(7n)+1n);
// ---- reduction table of F, generator by generator
const e=i=>{const n=Array.from({length:8},()=>0n);n[i]=1n;return F.make(n,1n);};
const v=x=>x.n.join(',')+'/'+x.d;
ok('F: √2·√2 = 2, √5·√5 = 5, τ·τ = √5 − 1 (τ² = √5 − 1)',v(F.mul(e(1),e(1)))===v(F.fromInt(2n))&&v(F.mul(e(2),e(2)))===v(F.fromInt(5n))&&v(F.mul(e(4),e(4)))===v(F.sub(e(2),F.ONE)));
ok('F: √2·√5 = √10 (basis e3), (√10)² = 10, (√2τ)² = 2√5 − 2, (√10 τ)² = 10√5 − 10',v(F.mul(e(1),e(2)))===v(e(3))&&v(F.mul(e(3),e(3)))===v(F.fromInt(10n))&&v(F.mul(e(5),e(5)))===v(F.scale(F.sub(e(2),F.ONE),2n))&&v(F.mul(e(7),e(7)))===v(F.scale(F.sub(e(2),F.ONE),10n)));
{let tab=0;for(let i=0;i<8;i++)for(let j=0;j<8;j++){const p=F.mul(e(i),e(j)),W=128n,a=F.toIv(e(i),W),b=F.toIv(e(j),W),pr=IV.mul(a,b,W),pv=F.toIv(p,W);if(pv.hi<pr.lo-4n||pv.lo>pr.hi+4n)tab++;}
  ok('F: all 64 entries of the reduction table agree with the product of the basis enclosures (2^−128)',tab===0,String(tab));}
{let bad=0;for(let i=0;i<60;i++){const x=rElem(F),y=rElem(F),z=rElem(F);if(!F.eq(F.mul(x,y),F.mul(y,x)))bad++;if(!F.eq(F.mul(F.mul(x,y),z),F.mul(x,F.mul(y,z))))bad++;if(!F.eq(F.mul(x,F.add(y,z)),F.add(F.mul(x,y),F.mul(x,z))))bad++;}
  ok('F: commutative, associative, distributive on 60 random triples',bad===0,String(bad));}
{let bad=0;for(let i=0;i<120;i++){const x=rElem(F);if(F.isZero(x))continue;if(!F.eq(F.mul(x,F.inv(x)),F.ONE))bad++;}ok('F: x · x⁻¹ = 1 on 120 random elements (inverse by the tower conjugates)',bad===0);}
{let bad=0;for(let i=0;i<120;i++){const x=rElem(K);if(K.isZero(x))continue;if(!K.eq(K.mul(x,K.inv(x)),K.ONE))bad++;}ok('K = ℚ(√3, √5): x · x⁻¹ = 1 on 120 random elements',bad===0);}
// ---- the {5,4} constants
const W=200n;
ok('cosh²(ℓ/2) − sinh²(ℓ/2) = 1 exactly: ((√2 + √10)/4)² − (τ/2)² = 1',F.eq(F.sub(F.mul(FQ.CH,FQ.CH),F.mul(FQ.SH,FQ.SH)),F.ONE));
ok('cosh²(ℓ/2) = (3 + √5)/4 and sinh²(ℓ/2) = (√5 − 1)/4 = cos 72° (so sinh(ℓ/2) ∉ ℚ(√2, √5): the field needs τ)',F.eq(F.mul(FQ.CH,FQ.CH),F.scale(F.add(F.fromInt(3n),FQ.S5),1n,4n))&&F.eq(F.mul(FQ.SH,FQ.SH),F.scale(F.sub(FQ.S5,F.ONE),1n,4n)));
{const c36=IV.cosSinTurn(1n,10n,W).c,s45=IV.cosSinTurn(1n,8n,W).s,q=IV.div(c36,s45,W),ch=F.toIv(FQ.CH,W);ok('cosh(ℓ/2) = cos 36°/sin 45°: the F enclosure meets the quotient of the series enclosures (2^−200)',!(ch.hi<q.lo||ch.lo>q.hi));
  const c72=IV.cosSinTurn(1n,5n,W).c,sh2=F.toIv(F.mul(FQ.SH,FQ.SH),W);ok('sinh²(ℓ/2) = cos 72°: enclosures meet',!(sh2.hi<c72.lo||sh2.lo>c72.hi));}
ok('τ = '+dec('1','1117859405028')+'… (guaranteed digits: '+IV.digits(F.toIv(FQ.TAU,W),W,12n).text+')',IV.digits(F.toIv(FQ.TAU,W),W,12n).text===dec('1','111785940503'));
ok('edge ℓ = 2 arccosh(cos 36°/sin 45°) = '+dec('1','06127506190504')+' to 14 places (skeleton: '+dec('1','0612751')+'): d of one step from 0, by the interval log',(()=>{const g=SU.mul(SU.I,FQ.TE),X=F.toIv(F.add(C.abs2(g.a),C.abs2(g.b)),W),one=1n<<W,sq=IV.iv(IV.isqrt(X.lo*X.lo-one*one),IV.isqrtCeil(X.hi*X.hi-one*one)),d=IV.log(IV.add(X,sq),W);return IV.digits(d,W,14n).text===dec('1','06127506190504');})());
// ---- SU(1,1) closures (exact)
const pw=(M,k)=>{let g=SU.I;for(let i=0;i<k;i++)g=SU.mul(g,M);return g;};
const isPmI=g=>C.isZero(g.b)&&F.isZero(g.a.im)&&(F.eq(g.a.re,F.ONE)||F.eq(g.a.re,F.neg(F.ONE)));
ok('det = |a|² − |b|² = 1 exactly for R(±90°), T(ℓ), M_L = R(90°)T(ℓ), M_R = R(−90°)T(ℓ)',[FQ.RL,FQ.RR,FQ.TE,FQ.ML,FQ.MR].every(g=>F.eq(SU.det(g),F.ONE)));
ok('(rotate-left · step)^5 = −I in SU(1,1) over F: five lefts close a face of the disk',(()=>{const g=pw(FQ.ML,5);return isPmI(g)&&F.eq(g.a.re,F.neg(F.ONE));})());
ok('(rotate-right · step)^5 = −I likewise',(()=>{const g=pw(FQ.MR,5);return isPmI(g)&&F.eq(g.a.re,F.neg(F.ONE));})());
ok('(M_L)^k and (M_R)^k ≠ ±I for k = 1 … 4 (the face has exactly five edges)',[1,2,3,4].every(k=>!isPmI(pw(FQ.ML,k))&&!isPmI(pw(FQ.MR,k))));
ok('R(90°)^4 = −I (the vertex has four edges; −I acts as the identity on the disk)',(()=>{const g=pw(FQ.RL,4);return isPmI(g)&&F.eq(g.a.re,F.neg(F.ONE));})());
ok('K: cos²60° + sin²60° = 1 and (√5/3)² + (2/3)² = 1 exactly',K.eq(K.add(K.mul(K.fromInt(1n,2n),K.fromInt(1n,2n)),K.mul(K.scale(K.gen(0),1n,2n),K.scale(K.gen(0),1n,2n))),K.ONE)&&K.eq(K.add(K.mul(K.scale(K.gen(1),1n,3n),K.scale(K.gen(1),1n,3n)),K.fromInt(4n,9n)),K.ONE));
// ---- interval core
{let bad=0;for(let q=1n;q<=96n;q++)for(let p=0n;p<q;p+=q>12n?7n:1n){const cs=IV.cosSinTurn(p,q,128n),s=IV.add(IV.sqr(cs.c,128n),IV.sqr(cs.s,128n));if(s.lo>(1n<<128n)||s.hi<(1n<<128n)||IV.width(cs.c)>(1n<<40n))bad++;}
  ok('cos² + sin² ∋ 1 and widths ≤ 2^−88 for rational turns p/q, q ≤ 96 (sampled)',bad===0,String(bad));}
ok('exact quadrant values: cos(1/4 turn) = 0, sin(1/4) = 1, cos(1/2) = −1 are point intervals',(()=>{const a=IV.cosSinTurn(1n,4n,64n),b=IV.cosSinTurn(1n,2n,64n);return a.c.lo===0n&&a.c.hi===0n&&a.s.lo===1n<<64n&&a.s.hi===1n<<64n&&b.c.lo===-(1n<<64n)&&b.c.hi===-(1n<<64n);})());
ok('cos(1/6 turn) ∋ 1/2, sin(1/12 turn) ∋ 1/2, cos(1/8 turn)² ∋ 1/2',(()=>{const W2=128n,h=1n<<127n,a=IV.cosSinTurn(1n,6n,W2).c,b=IV.cosSinTurn(1n,12n,W2).s,c=IV.sqr(IV.cosSinTurn(1n,8n,W2).c,W2);return a.lo<=h&&h<=a.hi&&b.lo<=h&&h<=b.hi&&c.lo<=h&&h<=c.hi;})());
ok('π = '+dec('3','14159265358979323846264338327950288')+'… (Machin, guaranteed digits)',IV.digits(IV.pi(200n),200n,35n).text===dec('3','14159265358979323846264338327950288'));
ok('ln 2 = '+dec('0','693147180559945309417232121458')+'… and ln 10 = '+dec('2','302585092994045684017991454684')+'…',IV.digits(IV.ln2(200n),200n,30n).text===dec('0','693147180559945309417232121458')&&IV.digits(IV.log(IV.pt(10n<<200n),200n),200n,30n).text===dec('2','302585092994045684017991454684'));
ok('log of a huge number: log(2^5000) = 5000 ln 2 = '+dec('3465','73590279972654708616')+'…',IV.digits(IV.log(IV.pt(1n<<5200n),200n),200n,20n).text===dec('3465','73590279972654708616'));
{let bad=0;for(let i=0;i<2000;i++){const n=rnd(1n<<200n);const r=IV.isqrt(n);if(r*r>n||(r+1n)*(r+1n)<=n)bad++;}ok('isqrt is the exact floor square root on 2000 values',bad===0);}
ok('outward rounding: [−3, −1]·[2, 5] at scale 0 = [−15, −2]; division by an interval containing 0 is refused',(()=>{const m=IV.mul(IV.iv(-3n,-1n),IV.iv(2n,5n),0n);let r=false;try{IV.div(IV.pt(1n),IV.iv(-1n,1n),0n);}catch(e){r=true;}return m.lo===-15n&&m.hi===-2n&&r;})());
console.log('SUMMARY test-pen-fields: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
