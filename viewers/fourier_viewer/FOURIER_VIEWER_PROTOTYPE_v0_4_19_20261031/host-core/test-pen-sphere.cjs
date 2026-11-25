'use strict';
// v0.4.18 (SCHEMA_ADDENDUM_25) test-pen-sphere: the squeezed-sphere pen. No floating point.
// (1) the dodecahedron preset, exactly in K = Q(sqrt3, sqrt5); (2) the interval register at free (alpha, theta): enclosure widths, the precision P,
// pixels and coverage cells; (3) the octahedron special case (alpha = 1/4 turn, theta = 1/4 turn) against the exact integer pen; (4) the benchmark that
// decided against the exact field Q(zeta_96) for general 96ths and 24ths, with a containment check of the intervals against the exact cyclotomic frames.
const ST=require('./pen-streams-core.js'),SP=require('./pen-sphere-core.js'),CV=require('./pen-curvature-core.js'),IV=require('./pen-interval-core.js'),FQ=require('./field-q2-q5-tau.js');
const K=FQ.K;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const ms=t0=>(process.hrtime.bigint()-t0)/1000000n;
// ---- (1) dodecahedron preset, exact
{const t0=process.hrtime.bigint(),D=SP.dodecaStructure(CV.closure),t=ms(t0);
  ok('dodecahedron preset: cos θ = 1/2, sin θ = √3/2, cos α = √5/3, sin α = 2/3 with cos² + sin² = 1 exactly in K',K.eq(K.add(K.mul(SP.DODECA.ct,SP.DODECA.ct),K.mul(SP.DODECA.st,SP.DODECA.st)),K.ONE)&&K.eq(K.add(K.mul(SP.DODECA.ca,SP.DODECA.ca),K.mul(SP.DODECA.sa,SP.DODECA.sa)),K.ONE));
  ok('dodecahedron: five lefts return to the start flag exactly (a pentagonal face closes), five rights too; three lefts do not',D.fiveLeftsClose&&D.fiveRightsClose&&D.threeLeftsNotClose);
  ok('dodecahedron: closing the start flag under the two moves gives exactly '+D.flags+' flags on '+D.vertices+' vertices (60 on 20)',D.flags===60&&D.vertices===20);
  ok('dodecahedron: every reached frame has |x| = |v| = 1 and x · v = 0 exactly',D.unit&&D.orth);
  ok('dodecahedron: every vertex has exactly 3 others at x · y = cos α = √5/3 (its edge neighbours)',D.neighbours.every(n=>n===3));
  ok('dodecahedron: the dot products between distinct vertices are exactly √5/3 (60), 1/3 (120), −1/3 (120), −√5/3 (60), −1 (20 antipodes): the regular dodecahedron’s',JSON.stringify(D.dotValues.map(x=>x.count).sort())===JSON.stringify([120,120,20,60,60].sort())&&D.dotValues.length===5,JSON.stringify(D.dotValues));
  ok('dodecahedron: the moves generate a group of order '+D.group.order+' with element orders '+JSON.stringify(D.group.orders)+' (A₅’s profile 1, 15, 20, 24), each move of order 5 ('+t+' ms)',D.group.order===60&&D.group.orders[1]===1&&D.group.orders[2]===15&&D.group.orders[3]===20&&D.group.orders[5]===24&&D.group.genOrders.join()==='5,5');
  for(const [nm,s] of [['Rule 30 T = 1328',ST.caRun(30,1328).s],['coin seed 1 T = 1328',ST.coinSigns(1328,1n)],['Goldbach run to 1448 (first 4096)',ST.goldbachRun(1448).s.slice(0,4096)]]){
    const t1=process.hrtime.bigint(),fl=SP.dodecaPen(s,s.length),tt=ms(t1),keys=new Set(fl.map(SP.dFlagKey)),vs=new Set(fl.map(f=>f.x.map(K.key).join(';'))),cov=SP.coverageExact(fl);
    ok('dodecahedron, '+nm+': every position is one of the 20 vertices ('+vs.size+' visited, '+keys.size+' flags), coverage '+cov.cells+'/432 exact, 0 uncertain ('+tt+' ms)',vs.size<=20&&[...vs].every(k=>D.V.some(x=>x.map(K.key).join(';')===k))&&cov.uncertain===0);}}
// ---- (2) the interval register at free alpha, theta
const R=140n;   // the card's sphere radius in pixels (320 * 44/100)
for(const [T,a,th] of [[1328,3n,2n],[4096,3n,2n],[1328,24n,4n],[1328,1n,11n]]){
  const s=ST.caRun(30,T).s,P=SP.workingBits(T),t0=process.hrtime.bigint(),r=SP.penIntervals(s,T,[a,96n],[th,24n],P),t=ms(t0);let mw=0n,bad=0;
  for(const p of r.pts)for(const e of p){const w=e.hi-e.lo;if(w>mw)mw=w;if(4n*R*w>(1n<<P))bad++;}
  let unit=true;for(const p of [r.pts[T>>1],r.pts[T]]){const n2=IV.add(IV.add(IV.sqr(p[0],P),IV.sqr(p[1],P)),IV.sqr(p[2],P));if(n2.lo>(1n<<P)||n2.hi<(1n<<P))unit=false;}
  const t1=process.hrtime.bigint(),cov=SP.coverage(r.pts,P),tc=ms(t1);
  ok('TIMING sphere pen, Rule 30, T = '+T+', α = '+a+'/96, θ = '+th+'/24: '+t+' ms at P = '+P+' bits; widest enclosure 2^'+IV.blen(mw)+'·2^−'+P+'; pixels not certified (R = 140 px) '+bad+'; |x|² ∋ 1; coverage '+cov.cells+'/432, uncertain cells '+cov.uncertain+' ('+tc+' ms)',bad===0&&unit);}
// ---- (2b) the ball register (what the card draws): one orthogonal matrix per sign, a rigorous radius linear in T, P = 96 bits
for(const [nm,T,a,th,mk] of [['Rule 30',1328,3n,2n,T=>ST.caRun(30,T).s],['Rule 30',4096,3n,2n,T=>ST.caRun(30,T).s],['Rule 30',1328,24n,4n,T=>ST.caRun(30,T).s],['coin seed 1',1328,5n,7n,T=>ST.coinSigns(T,1n)],['Goldbach run to 1448 (first 4096)',4096,3n,2n,T=>ST.goldbachRun(1448).s.slice(0,T)]]){
  const s=mk(T),t0=process.hrtime.bigint(),b=SP.penBall(s,T,[a,96n],[th,24n]),t=ms(t0),P=SP.workingBits(T),r=SP.penIntervals(s,T,[a,96n],[th,24n],P);let meet=true,bad=0;
  for(let i=0;i<=T;i++)for(let k=0;k<3;k++){const x=IV.rescale(r.pts[i][k],P,b.P),y=b.pts[i][k];if(x.hi<y.lo||x.lo>y.hi)meet=false;if(4n*R*(y.hi-y.lo)>(1n<<b.P))bad++;}
  const cb=SP.coverage(b.pts,b.P),ci=SP.coverage(r.pts,P);
  ok('TIMING ball register, '+nm+', T = '+T+', α = '+a+'/96, θ = '+th+'/24: '+t+' ms at P = '+b.P+' bits, final radius '+b.eps+' ulp; every ball meets the interval-register enclosure; pixels not certified '+bad+'; coverage '+cb.cells+'/432, uncertain '+cb.uncertain+' (interval register: '+ci.cells+', '+ci.uncertain+')',meet&&bad===0&&cb.cells===ci.cells&&cb.uncertain===ci.uncertain);}
// the ball register on the octahedron: contains the exact vertices
{const s=ST.caRun(30,300).s,b=SP.penBall(s,300,[24n,96n],[6n,24n]),o=CV.octPen(s);let okc=true;b.pts.forEach((p,i)=>p.forEach((e,k)=>{const v=BigInt(o[i].x[k])<<b.P;if(e.lo>v||e.hi<v)okc=false;}));
  ok('ball register, α = 24/96, θ = 6/24, Rule 30, T = 300: every ball contains the exact octahedron vertex',okc);}
// ---- (3) the octahedron special case
for(const [nm,s] of [['Rule 30',ST.caRun(30,300).s],['coin seed 5',ST.coinSigns(300,5n)]]){const P=SP.workingBits(300),r=SP.penIntervals(s,300,[24n,96n],[6n,24n],P),o=CV.octPen(s);let okc=true;
  r.pts.forEach((p,i)=>p.forEach((e,k)=>{const v=BigInt(o[i].x[k])<<P;if(e.lo>v||e.hi<v)okc=false;}));
  ok('α = 24/96, θ = 6/24 (the octahedron), '+nm+', T = 300: every interval position contains the exact octahedron vertex',okc);}
// ---- (4) Q(zeta_96): the exact alternative, benchmarked
// Z[zeta]/2^e with Phi_96 = x^32 - x^16 + 1; cos(2 pi j/96) = (z^j + z^-j)/2, sin = (z^j - z^-j) z^72 / 2 (1/i = z^72).
const N32=32;
function cyMul(a,b){const c=new Array(2*N32-1).fill(0n);for(let i=0;i<N32;i++){if(a[i]===0n)continue;for(let j=0;j<N32;j++)c[i+j]+=a[i]*b[j];}
  for(let k=2*N32-2;k>=N32;k--){const v=c[k];if(v===0n)continue;c[k-16]+=v;c[k-32]-=v;c[k]=0n;}return c.slice(0,N32);}
function zpow(m){m=((m%96)+96)%96;let r=new Array(N32).fill(0n);r[0]=1n;const z=new Array(N32).fill(0n);z[1]=1n;for(let i=0;i<m;i++)r=cyMul(r,z);return r;}
const cyAdd=(a,b)=>a.map((x,i)=>x+b[i]),cySub=(a,b)=>a.map((x,i)=>x-b[i]);
// an element is {n: BigInt[32], e: BigInt} = n / 2^e
// kept reduced: the power basis is an integral basis of Z[zeta], so 2 divides an element iff it divides every coefficient
const cy=(n,e)=>{while(e>0n&&n.every(v=>(v&1n)===0n)){n=n.map(v=>v>>1n);e--;}return {n,e};};const cyM=(x,y)=>cy(cyMul(x.n,y.n),x.e+y.e);
const cyA=(x,y)=>{const e=x.e>y.e?x.e:y.e;return cy(cyAdd(x.n.map(v=>v<<(e-x.e)),y.n.map(v=>v<<(e-y.e))),e);};
const cyNeg=x=>cy(x.n.map(v=>-v),x.e);
function cyCosSin(j){const zp=zpow(j),zm=zpow(-j),c=cy(cyAdd(zp,zm),1n),s=cy(cyMul(cySub(zp,zm),zpow(72)),1n);return {c,s};}
function cyPen(s,n,a,th){const A=cyCosSin(a),Th=cyCosSin(4*th),one=cy((()=>{const r=new Array(N32).fill(0n);r[0]=1n;return r;})(),0n),zero=cy(new Array(N32).fill(0n),0n);
  let x=[zero,zero,one],v=[one,zero,zero];const pts=[x];
  const cr=(u,w)=>[cyA(cyM(u[1],w[2]),cyNeg(cyM(u[2],w[1]))),cyA(cyM(u[2],w[0]),cyNeg(cyM(u[0],w[2]))),cyA(cyM(u[0],w[1]),cyNeg(cyM(u[1],w[0])))];
  for(let t=0;t<n;t++){const w=cr(x,v),st=s[t]>0?Th.s:cyNeg(Th.s);v=v.map((vi,i)=>cyA(cyM(Th.c,vi),cyM(st,w[i])));
    const nx=x.map((xi,i)=>cyA(cyM(A.c,xi),cyM(A.s,v[i]))),nv=x.map((xi,i)=>cyA(cyM(cyNeg(A.s),xi),cyM(A.c,v[i])));x=nx;v=nv;pts.push(x);}
  return pts;}
function cyToIv(x,W){let s=IV.pt(0n);x.n.forEach((c,k)=>{if(c!==0n)s=IV.add(s,IV.mulInt(IV.cosSinTurn(BigInt(k),96n,W+32n).c,c));});const sc=IV.iv(IV.shrF(s.lo,32n),IV.shrC(s.hi,32n));return IV.iv(IV.shrF(sc.lo,x.e),IV.shrC(sc.hi,x.e));}
{const s=ST.caRun(30,128).s,rows=[];let lastBits=0n,lastT=0;
  for(const T of [16,32,64,128,256,512]){const t0=process.hrtime.bigint(),pts=cyPen(s,T,3,2),t=ms(t0);let bits=0n;for(const c of pts[T])for(const v of c.n){const b=IV.blen(v);if(b>bits)bits=b;}rows.push('T = '+T+': '+t+' ms, numerators up to '+bits+' bits over 2^'+pts[T][0].e);lastBits=bits;lastT=T;
    if(T===64){const P=SP.workingBits(64),r=SP.penIntervals(s,64,[3n,96n],[2n,24n],P);let meet=true;for(let i=0;i<=64;i+=8)for(let k=0;k<3;k++){const ex=cyToIv(pts[i][k],P),I=r.pts[i][k];if(ex.hi<I.lo||ex.lo>I.hi)meet=false;}
      ok('Q(ζ₉₆) exact frames (α = 3/96, θ = 2/24, Rule 30, T = 64) meet the interval enclosures at every 8th step',meet);}}
  ok('Q(ζ₉₆) benchmark (degree 32, Φ₉₆ = x³² − x¹⁶ + 1): '+rows.join('; ')+'. Each step costs about 24 products of 32 × 32 BigInt convolutions on coefficients that grow by about 2 bits per step, so the cost per step grows with T; against the interval register (T = 1328: see the timing above) the exact field is far slower, and its positions would still need enclosures for the pixels and the cells. Chosen: the guaranteed numerical register (the ball register for the card, the interval register as its cross-check).',lastBits>BigInt(lastT));}
// ---- coverage edge cases: exact points on cell boundaries
ok('coverage cell of the start point (0, 0, 1): band 23, sector 9 (the skeleton’s atan2(0, 0) = 0), decided exactly',SP.cellOf([IV.pt(0n),IV.pt(0n),IV.pt(1n<<64n)],64n).cell===23n*18n+9n);
ok('coverage cell of (−1, 0, 0): band 12, sector 17 (atan2 = π, clamped as the skeleton does)',SP.cellOf([IV.pt(-(1n<<64n)),IV.pt(0n),IV.pt(0n)],64n).cell===12n*18n+17n);
ok('a point whose enclosure straddles a sector ray (here the ray at angle 0) is counted as uncertain, not placed; a nearby decided point is placed',SP.cellOf([IV.pt(1n<<63n),IV.iv(-5n,5n),IV.pt(0n)],64n).cell===null&&SP.cellOf([IV.pt(1n<<63n),IV.iv(5n,9n),IV.pt(0n)],64n).cell===12n*18n+9n);
console.log('SUMMARY test-pen-sphere: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
