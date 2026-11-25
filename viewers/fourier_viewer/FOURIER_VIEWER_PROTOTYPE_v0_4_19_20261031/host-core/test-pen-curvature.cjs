'use strict';
// v0.4.18 (SCHEMA_ADDENDUM_25) test-pen-curvature: the curvature pen at k = 0 (lattice), +1 (octahedron), -1 (Poincare disk). No floating point.
// Cross-implementation: the skeleton's planePen and spherePen (verbatim transcription, transcription-skeleton-pens.cjs). The disk: exact F[i] runs
// against the interval runs (the enclosures must contain the exact values). Timings by process.hrtime.bigint (integer nanoseconds).
const ST=require('./pen-streams-core.js'),CV=require('./pen-curvature-core.js'),IV=require('./pen-interval-core.js'),FQ=require('./field-q2-q5-tau.js'),TR=require('./transcription-skeleton-pens.cjs');
const {F,C,SU}=FQ;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const ms=t0=>(process.hrtime.bigint()-t0)/1000000n;
const STREAMS=[['Rule 30',()=>ST.caRun(30,300).s],['Rule 150',()=>ST.caRun(150,300).s],['coin seed 1',()=>ST.coinSigns(300,1n)],['coin seed 5',()=>ST.coinSigns(300,5n)]];
// ---- cross-implementation at T = 300
for(const [name,mk] of STREAMS){const s=mk(),P=CV.planePen(s),tp=TR.planePen(s);
  ok('T = 300, '+name+': lattice positions = the skeleton planePen (transcription), all 301',tp.length===301&&tp.every((p,i)=>p[0]===P.X[i]&&p[1]===P.Y[i]));
  const fl=CV.octPen(s),ts=TR.spherePen(s);
  ok('T = 300, '+name+': octahedron vertices = the skeleton spherePen (transcription), all 301; each flag direction v_t = −x_(t−1)',ts.length===301&&ts.every((p,i)=>p.join()===fl[i].x.join())&&fl.every((f,i)=>i===0||f.v.join()===fl[i-1].x.map(c=>-c).join()));}
// ---- closures
const ones=(n,v)=>new Int8Array(n).fill(v);
ok('lattice: 4 lefts close a face, 4 rights too; 1, 2, 3 do not',CV.planePen(ones(4,1)).X[4]===0&&CV.planePen(ones(4,1)).Y[4]===0&&CV.planePen(ones(4,-1)).X[4]===0&&[1,2,3].every(k=>{const p=CV.planePen(ones(k,1));return p.X[k]!==0||p.Y[k]!==0;}));
ok('octahedron: 3 lefts close a face (back to the start flag), 3 rights too; 1 and 2 do not',CV.flagKey(CV.octPen(ones(3,1))[3])===CV.flagKey(CV.START)&&CV.flagKey(CV.octPen(ones(3,-1))[3])===CV.flagKey(CV.START)&&[1,2].every(k=>CV.flagKey(CV.octPen(ones(k,1))[k])!==CV.flagKey(CV.START)));
ok('disk: 5 lefts return the pen to 0 exactly (product −I), 5 rights too',(()=>{const a=CV.diskExact(ones(5,1))[5],b=CV.diskExact(ones(5,-1))[5];return C.isZero(a.b)&&C.isZero(b.b)&&F.eq(a.a.re,F.neg(F.ONE))&&F.eq(b.a.re,F.neg(F.ONE));})());
// ---- Rule 150 confinement (Lean v16 FVLTS4sRule150PenV1.pen_confined) and the 13-point count
{const P=CV.planePen(ST.caRun(150,4096).s),s=CV.planeStats(P);ok('Rule 150 planar pen to T = 4096: |x| ≤ 3, |y| ≤ 2 (max '+s.maxX+', '+s.maxY+'), '+s.points+' lattice points visited (13: a FINITE count)',s.maxX<=3&&s.maxY<=2&&s.points===13);}
// ---- octahedron: A4
{const g=CV.octGroup();
  ok('octahedron: the two moves (as permutations of the 24 flags) generate a group of order '+g.order+', element orders '+JSON.stringify(g.orders)+', non-abelian, both moves of order 3: A₄ (the only group of order 12 with 8 elements of order 3), not S₄',g.order===12&&g.orders[1]===1&&g.orders[2]===3&&g.orders[3]===8&&!g.abelian&&g.genOrders.join()==='3,3');
  ok('octahedron: the start flag has an orbit of exactly 12 of the 24 flags',g.startOrbit===12);
  const reach=[['Rule 30 T = 4096',ST.caRun(30,4096).s],['Rule 150 T = 4096',ST.caRun(150,4096).s],['coin seed 1 T = 4096',ST.coinSigns(4096,1n)],['coin seed 5 T = 4096',ST.coinSigns(4096,5n)],['Goldbach shell 24',ST.goldbachShell(24).s],['Goldbach shell 1448',ST.goldbachShell(1448).s],['Goldbach run to 1448',ST.goldbachRun(1448).s]];
  for(const [nm,s] of reach){const os=CV.octStats(CV.octPen(s)),short=nm.startsWith('Goldbach shell');ok('octahedron flags reached, '+nm+' ('+s.length+' steps): '+os.flags+' of 24 (vertices '+os.vertices+'/6)'+(short?'; a short stream reaches part of the 12-flag orbit only':'; the whole orbit of 12'),short?os.flags<=12:os.flags===12,String(os.flags));}}
// ---- Goldbach run timings on the lattice and the octahedron (N_max = 1448)
{const s=ST.goldbachRun(1448).s;let t0=process.hrtime.bigint();const P=CV.planePen(s),tl=ms(t0);t0=process.hrtime.bigint();const O=CV.octPen(s),to=ms(t0);const ps=CV.planeStats(P);
  ok('TIMING Goldbach run N_max = 1448 ('+s.length+' steps): lattice '+tl+' ms, octahedron '+to+' ms (lattice: '+ps.points+' points, max |x| '+ps.maxX+', |y| '+ps.maxY+')',P.n===s.length&&O.length===s.length+1);}
// ---- the disk: exact against intervals
for(const [name,mk] of STREAMS){const s=mk().slice(0,64),ex=CV.diskExact(s,64),P=CV.workingBits(64),run=CV.diskIntervalRun(s,64,P,false),g=run.g;
  const inside=(I,x,E)=>{const W=P+64n,xe=F.toIv(x,W),lo=I.lo<<(E+64n),hi=I.hi<<(E+64n);return lo<=xe.lo&&xe.hi<=hi;};
  const okc=inside(g.a.re,ex[64].a.re,g.E)&&inside(g.a.im,ex[64].a.im,g.E)&&inside(g.b.re,ex[64].b.re,g.E)&&inside(g.b.im,ex[64].b.im,g.E);
  ok('disk T = 64, '+name+': the interval product (P = '+P+') contains the exact F[i] product entrywise',okc);
  const de=CV.distanceExact(ex[64]),di=CV.distance(g);ok('disk T = 64, '+name+': d exact-route '+de.dText+' meets d interval-route '+di.dText,!(de.d.hi<di.d.lo||de.d.lo>di.d.hi));
  ok('disk T = 64, '+name+': det = 1 exactly for the exact product',F.eq(SU.det(ex[64]),F.ONE));}
// trail frames: Q_j = g_u^-1 g_(u-j) exactly (u = 40), and the interval trail contains them
{const s=ST.caRun(30,40).s,ex=CV.diskExact(s,40),u=40;let Q=SU.I,okx=true;for(let j=0;j<u;j++){Q=SU.mul(Q,SU.inv(s[u-j-1]>0?FQ.ML:FQ.MR));if(!SU.eq(Q,SU.mul(SU.inv(ex[u]),ex[u-j-1])))okx=false;}
  ok('trail: Q_j = g_u⁻¹ g_(u−j) exactly for j = 1 … 40 (u = 40, Rule 30)',okx);
  const fr=CV.trailFrames(s,u,u,CV.workingBits(u)),geo=CV.pathGeometry(fr,j=>s[u-j-1],true);let okp=true;Q=SU.I;
  for(let j=0;j<=u;j++){if(j>0)Q=SU.mul(Q,SU.inv(s[u-j]>0?FQ.ML:FQ.MR));const z=SU.point(Q),zr=F.toIv(z.re,geo.P),zi=F.toIv(z.im,geo.P),p=geo.pts[j];if(zr.lo<p.re.lo||zr.hi>p.re.hi||zi.lo<p.im.lo||zi.hi>p.im.hi)okp=false;}
  ok('trail: every interval trail point Q_j(0) contains the exact point (j = 0 … 40)',okp);}
// ---- long runs: precision, timings, widths
for(const T of [1024,4096]){const s=ST.caRun(30,T).s,P=CV.workingBits(T),t0=process.hrtime.bigint(),run=CV.diskIntervalRun(s,T,P,false),t=ms(t0),d=CV.distance(run.g);
  const w=IV.blen(IV.width(run.g.a.re)),m=IV.blen(run.g.a.re.hi);
  ok('TIMING k = −1, Rule 30, T = '+T+': '+t+' ms at P = '+P+' bits; d = '+d.dText+' ('+d.dPlaces+' guaranteed places), cosh d = '+d.coshText+'; enclosure width 2^'+w+' against magnitude 2^'+m+' (relative precision 2^−'+(m-w)+')',d.dPlaces>=12n&&m-w>64n);}
// the chunked exact products: the measured precision loss per chunk join, against the 8 bits per join that workingBits allows
{const rows=[];let worst=0n;for(const [nm,s] of [['Rule 30',ST.caRun(30,4096).s],['Rule 150',ST.caRun(150,4096).s],['coin seed 1',ST.coinSigns(4096,1n)],['coin seed 5',ST.coinSigns(4096,5n)],['Goldbach shell 1448',ST.goldbachShell(1448).s],['Goldbach run (first 4096)',ST.goldbachRun(1448).s.slice(0,4096)]]){
    const n=s.length,P=2048n,g=CV.diskIntervalRun(s,n,P,false).g,w=IV.blen(IV.width(g.a.re)),m=IV.blen(g.a.re.hi>0n?g.a.re.hi:-g.a.re.lo),joins=(BigInt(n)+BigInt(CV.CHUNK)-1n)/BigInt(CV.CHUNK),lost=P-(m-w),per=(lost+joins-1n)/joins;if(per>worst)worst=per;rows.push(nm+' '+lost+' bits over '+joins+' joins');}
  ok('chunked exact products (CHUNK = '+CV.CHUNK+'): precision lost at P = 2048: '+rows.join('; ')+'; worst ≤ '+worst+' bits per join, within the 8 allowed',worst<=8n);}
// pixel certification of what the card draws (canvas R = 118 px, the drawing scale DRAW_BITS)
{const R=118n,cx=130n;const count=geo=>{let n=0,bad=0;const chk=z=>{n++;const a=IV.pixel(z.re,geo.P,R,cx,false),b=IV.pixel(z.im,geo.P,R,cx,true);if(!a.ok||!b.ok)bad++;};geo.pts.forEach(chk);geo.edges.forEach(e=>e.forEach(chk));return [n,bad];};
  const s=ST.caRun(30,4096).s;let t0=process.hrtime.bigint();const fr=CV.trailFrames(s,4096,600,CV.workingBits(600)),gf=CV.pathGeometry(fr,j=>s[4096-j-1],true),[n1,b1]=count(gf),t1=ms(t0);
  ok('follow the pen, T = 4096, W = 600: pixels not certified 0 of '+n1+' ('+t1+' ms)',b1===0,String(b1));
  t0=process.hrtime.bigint();const run=CV.diskIntervalRun(s,4096,CV.workingBits(4096),true),ga=CV.pathGeometry(run.frames,j=>s[j],false),[n2,b2]=count(ga),t2=ms(t0);
  ok('absolute view, T = 4096: pixels not certified 0 of '+n2+' ('+t2+' ms)',b2===0,String(b2));
  t0=process.hrtime.bigint();const tg=CV.tilingGeometry(8);let n3=0,b3=0;for(const e of tg)for(const z of e){n3++;const a=IV.pixel(z.re,CV.DRAW_BITS,R,cx,false),b=IV.pixel(z.im,CV.DRAW_BITS,R,cx,true);if(!a.ok||!b.ok)b3++;}
  ok('{5,4} tiling patch, exact BFS depth 8: '+tg.length+' edges, pixels not certified 0 of '+n3+' ('+ms(t0)+' ms)',b3===0&&tg.length===CV.tilingPatch(8).count);}
// the tiling patch: every vertex of the patch has degree at most 4, and the vertices strictly inside have degree exactly 4 (the {5,4} vertex figure)
{const t=CV.tilingPatch(6),deg=new Map(),pk=g=>C.key(SU.point(g));for(const G of t.frames){for(const k of [pk(G),pk(SU.mul(G,FQ.TE))])deg.set(k,(deg.get(k)||0)+1);}
  const ds=[...deg.values()];ok('{5,4} patch (depth 6, '+t.count+' edges, exact keys in F[i]): every vertex degree ≤ 4, the start vertex has degree 4',ds.every(d=>d<=4)&&deg.get(pk(SU.I))===4);}
console.log('SUMMARY test-pen-curvature: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
