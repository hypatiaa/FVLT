(function(root){
'use strict';
// fv-pen-sphere-core 0_1_0 (v0.4.18, SCHEMA_ADDENDUM_25): the squeezed-sphere pen, a geodesic turtle on S^2 (skeleton's squeeze_sphere_pen_v0_1_1.html, penPath),
// without floating point. Frame (x, v), x on S^2, v a unit tangent; start x = (0, 0, 1), v = (1, 0, 0). One step with sign s:
//   turn  v <- cos(s theta) v + sin(s theta) (x cross v);   walk  x' = cos(a) x + sin(a) v,  v' = -sin(a) x + cos(a) v.
// Registers:
//   EXACT: the dodecahedron preset theta = 60 deg, cos a = sqrt5/3 (sin a = 2/3), frames in K = Q(sqrt3, sqrt5) (host-core/field-q2-q5-tau.js).
//   GUARANTEED NUMERICAL: theta = k/24 turn, a = j/96 turn, cos and sin of the rational turns by the outward-rounded series of pen-interval-core.
//     penBall (drawn by the card): a midpoint frame and a rigorous radius that grows linearly in T (one orthogonal matrix per sign), 96 bits.
//     penIntervals (the cross-check): interval frames at 2^-P, P = 64 + T, by Rodrigues steps (no renormalisation).
//   Why not Q(zeta_96) (degree 32, Phi_96 = x^32 - x^16 + 1)? Measured in test-pen-sphere: an exact frame over Q(zeta_96) needs coefficient vectors whose
//     size grows linearly with T (the 1/2 in cos = (zeta + zeta^-1)/2 accumulates); the benchmark there is the reason intervals were chosen. See the report.
// Coverage: 432 equal-area cells (24 z-bands x 18 sectors, as the skeleton): a point whose enclosure meets a cell boundary is counted as UNCERTAIN.
const NODE=typeof module!=='undefined'&&module.exports;
const IV=NODE?require('./pen-interval-core.js'):root.FVPenIv;
const FQ=NODE?require('./field-q2-q5-tau.js'):root.FVFieldQ2Q5Tau;
const VERSION='fv-pen-sphere-core 0_1_0';
const K=FQ.K;
// ---------------------------------------------------------------- interval register
const ivCross=(u,v,P)=>[IV.sub(IV.mul(u[1],v[2],P),IV.mul(u[2],v[1],P)),IV.sub(IV.mul(u[2],v[0],P),IV.mul(u[0],v[2],P)),IV.sub(IV.mul(u[0],v[1],P),IV.mul(u[1],v[0],P))];
const ivLin=(a,x,b,y,P)=>x.map((xi,i)=>IV.add(IV.mul(a,xi,P),IV.mul(b,y[i],P)));
function workingBits(n){return 64n+BigInt(n);}   // the wrapping growth of the enclosures, measured at about 74/100 bit per step (test-pen-sphere); widths are checked, not assumed
function penIntervals(s,n,aTurn,tTurn,P){
  const S=1n<<P,ca=IV.cosSinTurn(aTurn[0],aTurn[1],P),ct=IV.cosSinTurn(tTurn[0],tTurn[1],P),sNeg=IV.neg(ct.s);
  let x=[IV.pt(0n),IV.pt(0n),IV.pt(S)],v=[IV.pt(S),IV.pt(0n),IV.pt(0n)];const pts=[x];
  for(let t=0;t<n;t++){const w=ivCross(x,v,P);v=ivLin(ct.c,v,s[t]>0?ct.s:sNeg,w,P);
    const nx=ivLin(ca.c,x,ca.s,v,P),nv=ivLin(IV.neg(ca.s),x,ca.c,v,P);x=nx;v=nv;pts.push(x);}
  return {pts,P};
}
// ---------------------------------------------------------------- the ball register (used by the card): one orthogonal matrix per sign, error bound linear in T
// The frame F = (x; v; w) with w = x cross v (rows, world coordinates) moves by F <- A_s F with A_s = S(a) T(s theta):
//   T(s theta) = [[1, 0, 0], [0, c, s'], [0, -s', c]] (the turn: v' = c v + s' w, w' = -s' v + c w, s' = s sin theta),
//   S(a) = [[ca, sa, 0], [-sa, ca, 0], [0, 0, 1]] (the walk: x' = ca x + sa v, v' = -sa x + ca v, w unchanged).
// A_s is orthogonal, so an error E in F is carried with the same Frobenius norm. With a midpoint matrix A~ (|A - A~|_F <= delta) and rounded products:
//   E_t = A E_(t-1) + (A - A~) F~_(t-1) + (rounding), so |E_t|_F <= |E_(t-1)|_F + delta (1 + |E_(t-1)|_F) + 3 ulp (|F~|_2 <= 1 + |E|_F).
// The radius grows linearly in T, not exponentially: a fixed working scale suffices. Every coordinate of x_t lies within eps_t of the midpoint.
const BALL_BITS=96n;
function aMatrix(sg,ca,ct,P){
  const sPrime=sg>0?ct.s:IV.neg(ct.s),z=IV.pt(0n),one=IV.pt(1n<<P);
  const T=[[one,z,z],[z,ct.c,sPrime],[z,IV.neg(sPrime),ct.c]],S=[[ca.c,ca.s,z],[IV.neg(ca.s),ca.c,z],[z,z,one]];
  const A=[0,1,2].map(i=>[0,1,2].map(j=>[0,1,2].reduce((acc,k)=>IV.add(acc,IV.mul(S[i][k],T[k][j],P)),z)));
  let delta=0n;const mid=A.map(row=>row.map(e=>{const m=(e.lo+e.hi)>>1n;const rad=(e.hi-m>m-e.lo?e.hi-m:m-e.lo)+1n;delta+=rad;return m;}));
  return {mid,delta};
}
function penBall(s,n,aTurn,tTurn,P){
  P=P||BALL_BITS;const S=1n<<P,ca=IV.cosSinTurn(aTurn[0],aTurn[1],P),ct=IV.cosSinTurn(tTurn[0],tTurn[1],P),AL=aMatrix(1,ca,ct,P),AR=aMatrix(-1,ca,ct,P);
  let F=[[0n,0n,S],[S,0n,0n],[0n,S,0n]],eps=0n;const out=[];
  const pt=()=>F[0].map(m=>IV.iv(m-eps,m+eps));out.push(pt());
  for(let t=0;t<n;t++){const A=s[t]>0?AL:AR;
    F=[0,1,2].map(i=>[0,1,2].map(j=>(A.mid[i][0]*F[0][j]+A.mid[i][1]*F[1][j]+A.mid[i][2]*F[2][j])>>P));
    eps=eps+IV.cdiv(A.delta*(S+eps),S)+3n;out.push(pt());}
  return {pts:out,P,eps};
}
// ---------------------------------------------------------------- exact register: the dodecahedron preset in K
const kv=(a,b,c)=>[K.fromInt(a),K.fromInt(b),K.fromInt(c)];
const S3=K.gen(0),S5=K.gen(1);
const DODECA={ct:K.fromInt(1n,2n),st:K.scale(S3,1n,2n),ca:K.scale(S5,1n,3n),sa:K.fromInt(2n,3n)};
const kCross=(u,v)=>[K.sub(K.mul(u[1],v[2]),K.mul(u[2],v[1])),K.sub(K.mul(u[2],v[0]),K.mul(u[0],v[2])),K.sub(K.mul(u[0],v[1]),K.mul(u[1],v[0]))];
const kLin=(a,x,b,y)=>x.map((xi,i)=>K.add(K.mul(a,xi),K.mul(b,y[i])));
const kDot=(u,v)=>K.add(K.add(K.mul(u[0],v[0]),K.mul(u[1],v[1])),K.mul(u[2],v[2]));
const kKey=u=>u.map(K.key).join(';');
const DSTART={x:kv(0n,0n,1n),v:kv(1n,0n,0n)};
function dodecaStep(f,sg){const w=kCross(f.x,f.v),v=kLin(DODECA.ct,f.v,sg>0?DODECA.st:K.neg(DODECA.st),w);
  return {x:kLin(DODECA.ca,f.x,DODECA.sa,v),v:kLin(K.neg(DODECA.sa),f.x,DODECA.ca,v)};}
const dFlagKey=f=>kKey(f.x)+'>'+kKey(f.v);
function dodecaPen(s,n){let f=DSTART;const fl=[f];for(let t=0;t<n;t++){f=dodecaStep(f,s[t]);fl.push(f);}return fl;}
// the exact structure the preset walks: reachable flags by closure under the two moves, the group they generate, the vertex set and its dot products
function dodecaStructure(closure){
  const flags=new Map([[dFlagKey(DSTART),DSTART]]),q=[DSTART];
  while(q.length){const f=q.shift();for(const sg of [1,-1]){const g=dodecaStep(f,sg),k=dFlagKey(g);if(!flags.has(k)){flags.set(k,g);q.push(g);}}}
  const list=[...flags.values()],idx=new Map(list.map((f,i)=>[dFlagKey(f),i]));
  const perm=sg=>list.map(f=>idx.get(dFlagKey(dodecaStep(f,sg))));
  const grp=closure?closure([perm(1),perm(-1)],list.length):null;
  const verts=new Map();for(const f of list)verts.set(kKey(f.x),f.x);const V=[...verts.values()];
  const dots=new Map();let unit=true,orth=true;for(const f of list){if(!K.eq(kDot(f.x,f.x),K.ONE)||!K.eq(kDot(f.v,f.v),K.ONE))unit=false;if(!K.isZero(kDot(f.x,f.v)))orth=false;}
  const nb=V.map(()=>0),cosA=DODECA.ca;
  V.forEach((a,i)=>V.forEach((b,j)=>{if(i===j)return;const d=kDot(a,b),k=K.key(d);dots.set(k,(dots.get(k)||{v:d,n:0}));dots.get(k).n++;if(K.eq(d,cosA))nb[i]++;}));
  // a fixed sign run of five closes a pentagonal face: five lefts (and five rights) return to the start flag exactly
  let L=DSTART,R=DSTART;for(let i=0;i<5;i++){L=dodecaStep(L,1);R=dodecaStep(R,-1);}
  let L3=DSTART;for(let i=0;i<3;i++)L3=dodecaStep(L3,1);
  return {flags:list.length,vertices:V.length,group:grp,dotValues:[...dots.values()].map(x=>({value:K.str(x.v),count:x.n})),neighbours:nb,unit,orth,
    fiveLeftsClose:dFlagKey(L)===dFlagKey(DSTART),fiveRightsClose:dFlagKey(R)===dFlagKey(DSTART),threeLeftsNotClose:dFlagKey(L3)!==dFlagKey(DSTART),V};
}
const dodecaToIv=(fl,P)=>fl.map(f=>f.x.map(c=>K.toIv(c,P)));
// v0.4.19 (SCHEMA_ADDENDUM_26, verify section 7): a dodecahedron edge from vertex a to vertex b (exact unit vectors of K^3) drawn as its great-circle arc.
// Interior points k = 1 ... ARC_PIECES - 1: m_k = (ARC_PIECES - k) a + k b, exact in K^3 (on the plane of a and b, between them), then normalised by
// intervals: x = m_k / sqrt(|m_k|^2), |m_k|^2 exact in K and enclosed at W = P + ARC_GUARD bits, square root and quotient rounded outward, then
// rescaled outward to P. Every point lies on the minor arc from a to b (the arc is the normalised segment). Cached per (a, b, P): 30 edges, 60 directions.
const ARC_PIECES=8,ARC_GUARD=16n,ARCS=new Map();
function dodecaArc(a,b,P){
  const key=kKey(a)+'|'+kKey(b)+'|'+P;if(ARCS.has(key))return ARCS.get(key);
  const W=P+ARC_GUARD,out=[];
  for(let k=1;k<ARC_PIECES;k++){const m=kLin(K.fromInt(BigInt(ARC_PIECES-k)),a,K.fromInt(BigInt(k)),b),n2=K.toIv(kDot(m,m),W),nr=IV.sqrt(n2,W);
    out.push(m.map(c=>IV.rescale(IV.div(K.toIv(c,W),nr,W),W,P)));}
  if(ARCS.size>512)ARCS.clear();ARCS.set(key,out);return out;
}
// the arcs of a dodecahedron-preset run: arcs[i] = the interior points of the step from flag i to flag i + 1
function dodecaArcs(fl,P){const out=[];for(let i=0;i+1<fl.length;i++)out.push(dodecaArc(fl[i].x,fl[i+1].x,P));return out;}
// ---------------------------------------------------------------- coverage cells (skeleton: zb = min(23, floor((z+1)/2*24)), sb = min(17, floor((atan2(y,x)+pi)/(2pi)*18)))
const RAYS=new Map();
function rays(P){if(RAYS.has(P))return RAYS.get(P);const r=[];for(let j=0;j<=18;j++){const cs=IV.cosSinTurn(BigInt(j-9),18n,P);r.push(cs);}RAYS.set(P,r);return r;}
function cellOf(p,P){
  const S=1n<<P,[x,y,z]=p;
  // z band: floor(12 (z + 1)), clamped to 23
  const band=e=>{let b=IV.fdiv(12n*(e+S),S);if(b>23n)b=23n;if(b<0n)b=0n;return b;};
  const zb0=band(z.lo),zb1=band(z.hi);if(zb0!==zb1)return {cell:null,why:'z band'};
  // sector: on exact points the skeleton's atan2 conventions (atan2(0,0) = 0 -> sector 9; angle pi -> clamped to 17)
  const ex=x.lo===x.hi&&y.lo===y.hi;
  if(ex&&x.lo===0n&&y.lo===0n)return {cell:zb0*18n+9n};
  if(ex&&y.lo===0n&&x.lo<0n)return {cell:zb0*18n+17n};
  const R=rays(P),cand=[];
  for(let j=0;j<18;j++){
    const c0=IV.sub(IV.mul(R[j].c,y,P),IV.mul(R[j].s,x,P)),c1=IV.sub(IV.mul(R[j+1].c,y,P),IV.mul(R[j+1].s,x,P));   // cross(u_j, p), cross(u_{j+1}, p)
    const s0=IV.sign(c0),s1=IV.sign(c1);
    const can0=s0===null||s0>=0,can1=s1===null||s1<0;if(can0&&can1)cand.push(j);}
  if(cand.length!==1)return {cell:null,why:'sector'};
  return {cell:zb0*18n+BigInt(cand[0])};
}
// the cell test runs on enclosures rescaled to CELL_BITS (outward: they only widen, so a decided cell stays decided correctly)
const CELL_BITS=96n;
function coverage(pts,P){const seen=new Set();let uncertain=0;const Wc=P<CELL_BITS?P:CELL_BITS;
  for(const p of pts){const c=cellOf(p.map(e=>IV.rescale(e,P,Wc)),Wc);if(c.cell===null)uncertain++;else seen.add(c.cell);}return {cells:seen.size,of:432,uncertain};}
// exact cells for exact points of K^3 (the dodecahedron preset): every comparison decided exactly, so no point is uncertain.
// z band: the integer b with b <= 12 (z + 1) < b + 1 (exact signs in K). Sector rays u_j at (j - 9)/18 turn: for j = 0 mod 3 their cos and sin lie in K
// (0, +-1/2, +-sqrt3/2, +-1) and the sign of cross(u_j, p) is exact; for the other j, tan(u_j) is not in K, so cross(u_j, p) != 0 unless x = y = 0,
// and enclosures of increasing precision decide its sign.
const RAY_K=(()=>{const h=K.fromInt(1n,2n),r=K.scale(K.gen(0),1n,2n),z=K.ZERO,o=K.ONE,n=K.neg;
  const t={0:[n(o),z],3:[n(h),n(r)],6:[h,n(r)],9:[o,z],12:[h,r],15:[n(h),r],18:[n(o),z]};return t;})();
function crossSignExact(j,p){
  if(RAY_K[j]){const [c,s]=RAY_K[j];return K.signOf(K.sub(K.mul(c,p[1]),K.mul(s,p[0])));}
  for(let W=96n;W<=4096n;W*=2n){const R=rays(W)[j],x=K.toIv(p[0],W),y=K.toIv(p[1],W),sg=IV.sign(IV.sub(IV.mul(R.c,y,W),IV.mul(R.s,x,W)));if(sg!==null&&sg!==0)return sg;}
  throw Error('sector sign not decided');
}
function cellOfExact(p){
  const z1=K.scale(K.add(p[2],K.ONE),12n,1n);let b=0n;while(b<24n&&K.signOf(K.sub(z1,K.fromInt(b+1n)))>=0)b++;if(b>23n)b=23n;
  if(K.isZero(p[0])&&K.isZero(p[1]))return b*18n+9n;
  if(K.isZero(p[1])&&K.signOf(p[0])<0)return b*18n+17n;
  const cand=[];for(let j=0;j<18;j++){if(crossSignExact(j,p)>=0&&crossSignExact(j+1,p)<0)cand.push(j);}
  if(cand.length!==1)throw Error('exact sector not unique');return b*18n+BigInt(cand[0]);
}
function coverageExact(fl){const seen=new Set();for(const f of fl)seen.add(String(cellOfExact(f.x)));return {cells:seen.size,of:432,uncertain:0};}
// ---------------------------------------------------------------- display rotation: an integer quaternion, exact rational matrix (no sin, no cos)
function quatMatrix(a,b,c,d){a=BigInt(a);b=BigInt(b);c=BigInt(c);d=BigInt(d);const n=a*a+b*b+c*c+d*d;
  return {den:n,m:[[a*a+b*b-c*c-d*d,2n*(b*c-a*d),2n*(b*d+a*c)],[2n*(b*c+a*d),a*a-b*b+c*c-d*d,2n*(c*d-a*b)],[2n*(b*d-a*c),2n*(c*d+a*b),a*a-b*b-c*c+d*d]]};}
const VIEW_Q=[7n,3n,-2n,-1n];
const api={VERSION,workingBits,penIntervals,penBall,BALL_BITS,aMatrix,DODECA,DSTART,dodecaStep,dodecaPen,dodecaStructure,dodecaToIv,dodecaArc,dodecaArcs,ARC_PIECES,dFlagKey,kKey,kDot,cellOf,coverage,cellOfExact,coverageExact,rays,quatMatrix,VIEW_Q,ivCross,ivLin};
if(NODE)module.exports=api;else root.FVPenSphere=api;
})(typeof globalThis!=='undefined'?globalThis:this);
