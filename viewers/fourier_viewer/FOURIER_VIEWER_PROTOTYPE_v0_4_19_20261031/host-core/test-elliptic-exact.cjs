'use strict';
// v0.4.17 (SCHEMA_ADDENDUM_24) core test for host-core/elliptic-exact-core.js against fixtures/elliptic-37a1-fixture.json (transcribed from the
// Sage reference, sha256 599c6855...). Exact register only: BigInt and exact rationals. The case classification below is this test's own, not the core's.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const E=require('./elliptic-exact-core.js');
let pass=0,fail=0;
function t(name,fn){let ok=false,msg='';try{const r=fn();ok=r===true;if(!ok&&r!==false)msg=' '+r;}catch(e){msg=' threw: '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+msg);ok?pass++:fail++;}
const FIX=path.join(__dirname,'..','fixtures','elliptic-37a1-fixture.json'),fx=JSON.parse(fs.readFileSync(FIX,'utf8'));
const SRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
const B=s=>BigInt(s),A=fx.ainvs.map(B),C=E.curveQ(A),P=E.pt(E.Q(B(fx.generator.x)),E.Q(B(fx.generator.y)));
const qs=E.qascii;
t('fixture records the source sha256 599c6855…',()=>fx.source.sha256==='599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72');
t('the source file is present and still matches its sha256 (read only)',()=>fs.existsSync(SRC)&&crypto.createHash('sha256').update(fs.readFileSync(SRC)).digest('hex')===fx.source.sha256);
t('ainvs = (0, 0, 1, −1, 0) (37a1)',()=>A.join()==='0,0,1,-1,0');
t('invariants b2, b4, b6, b8, c4, c6 = fixture ('+[fx.b2,fx.b4,fx.b6,fx.b8,fx.c4,fx.c6].join(', ')+')',()=>['b2','b4','b6','b8','c4','c6'].every(k=>C[k].den===1n&&C[k].num===B(fx[k]))||['b2','b4','b6','b8','c4','c6'].map(k=>qs(C[k])).join());
t('Δ = 37 = fixture discriminant, and 1728 Δ = c4³ − c6²',()=>C.disc.num===37n&&C.disc.den===1n&&B(fx.discriminant)===37n&&1728n*37n===48n**3n-216n**2n);
t('P = (0, −1) lies on the curve; O is a flag, not a coordinate',()=>E.onCurve(C,P)&&E.O.inf===true&&!('x' in E.O));
// short model
const [u,r,s,tt]=fx.short_model.urst.map(E.qparse),SA=E.changeModel(A,u,r,s,tt),S=E.curveQ(SA);
t('short model via (u, r, s, t) = (1/2, 0, 0, −1/2): [0, 0, 0, −16, 16] = fixture y² = x³ − 16x + 16',()=>SA.map(qs).join()==='0,0,0,-16,16'&&fx.short_model.a4==='-16'&&fx.short_model.a6==='16'||SA.map(qs).join());
t('short model discriminant = u^(−12) Δ = 4096·37',()=>S.disc.num===4096n*37n&&S.disc.den===1n);
// multiples
const muls=[];for(let k=1n;k<=20n;k++)muls.push(E.mul(C,k,P));
t('kP for k = 1 … 10 = fixture (exact rationals)',()=>{for(const [i,m] of fx.multiples.entries()){if(m.k!==String(i+1))return 'fixture order';const R=muls[i].R;if(R.inf||qs(R.x)!==m.x||qs(R.y)!==m.y)return 'k = '+m.k+': '+E.ptStr(C,R);}return true;});
// own classification of a step: O+Q, Q+O, opposite, generic, doubling
const own=(P1,P2)=>{if(P1.inf)return 'P1 = O';if(P2.inf)return 'P2 = O';if(!E.qeq(P1.x,P2.x))return 'generic';const sy=E.qadd(E.qadd(P1.y,P2.y),E.Q(1n));return sy.num===0n?'P2 = \u2212P1':'doubling';};
t('double-and-add labels: each step’s case equals this test’s own classification, and the sequence follows the bits of k (k = 1 … 20)',()=>{
  for(let k=1;k<=20;k++){const m=muls[k-1],bits=k.toString(2);let R=E.O,i=0;const want=[];
    for(let j=0;j<bits.length;j++){if(j>0){want.push(own(R,R));R=E.add(C,R,R).R;}if(bits[j]==='1'){want.push(own(R,P));R=E.add(C,R,P).R;}}
    const got=m.steps.map(x=>x.case);if(got.join('|')!==want.join('|'))return 'k = '+k+': '+got.join(',')+' vs '+want.join(',');
    i++;if(m.steps.length!==(bits.length-1)+[...bits].filter(b=>b==='1').length)return 'steps k = '+k;}return true;});
t('kP labels k = 1 … 10 as recorded: '+muls.slice(0,10).map((m,i)=>(i+1)+': '+m.steps.map(x=>x.key).join('>')).join('; '),()=>muls.slice(0,10).every(m=>m.steps[0].case==='P1 = O'&&m.steps.slice(1).every(x=>x.case==='doubling'||x.case==='generic')));
t('kP by double-and-add = (k−1)P + P by the table, k = 1 … 20 (the chain step at k = 2 is the doubling case, the rest generic)',()=>{let R=P;for(let k=2;k<=20;k++){const a=E.add(C,R,P);if(a.case!==(k===2?'doubling':'generic'))return 'case k = '+k+' '+a.case;R=a.R;if(!E.ptEq(C,R,muls[k-1].R))return 'k = '+k;}return true;});
t('every kP (k ≤ 20) lies on the curve',()=>muls.every(m=>E.onCurve(C,m.R)));
t('map to the short model: x′ = 4x, y′ = 8y + 4, every kP (k ≤ 10) lands on y² = x³ − 16x + 16 and the map commutes with [k]',()=>{
  const P2=E.mapPoint(P,u,r,s,tt);if(qs(P2.x)!=='0'||qs(P2.y)!=='-4')return 'P′ = '+E.ptStr(S,P2);
  for(let k=1;k<=10;k++){const M=E.mapPoint(muls[k-1].R,u,r,s,tt);if(!E.onCurve(S,M))return 'off k = '+k;
    if(!E.qeq(M.x,E.qmul(E.Q(4n),muls[k-1].R.x))||!E.qeq(M.y,E.qadd(E.qmul(E.Q(8n),muls[k-1].R.y),E.Q(4n))))return 'formula k = '+k;
    if(!E.ptEq(S,M,E.mul(S,BigInt(k),P2).R))return 'commute k = '+k;}return true;});
// special cases
{const mP=E.neg(C,P),a=E.add(C,P,mP),b=E.add(C,E.O,P),c=E.add(C,P,E.O),d=E.add(C,E.O,E.O);
 t('−P = (0, 0) by −(x, y) = (x, −y − a1x − a3); P + (−P) = O, case “P2 = −P1”',()=>qs(mP.x)==='0'&&qs(mP.y)==='0'&&a.R.inf&&a.case==='P2 = \u2212P1');
 t('O + P = P (case “P1 = O”), P + O = P (case “P2 = O”), O + O = O (case “P1 = O”)',()=>E.ptEq(C,b.R,P)&&b.case==='P1 = O'&&E.ptEq(C,c.R,P)&&c.case==='P2 = O'&&d.R.inf&&d.case==='P1 = O');
 t('[0]P = O and [−3]P = −(3P)',()=>E.mul(C,0n,P).R.inf&&E.ptEq(C,E.mul(C,-3n,P).R,E.neg(C,muls[2].R)));}
t('exactly-one assertion: two off-curve points with x1 = x2 that are neither equal nor opposite are refused (no case applies)',()=>{const F7=E.curveFp([0n,0n,0n,1n,1n],7n);try{E.add(F7,E.pt(0n,1n),E.pt(0n,5n));return 'not refused';}catch(e){return /exactly one/.test(e.message)||e.message;}});
// 2-torsion doubling refusal, over F_5 (#E(F_5) = 8 is even, so E(F_5) has a 2-torsion point)
{const E5=E.curveFp(A,5n),T=E.points(E5).filter(Q=>!Q.inf&&(2n*Q.y+0n*Q.x+1n)%5n===0n);
 t('2-torsion over F_5: T = '+(T[0]?E.ptStr(E5,T[0]):'none')+' has 2y + a1x + a3 = 0; T + T is the case “P2 = −P1” and gives O',()=>T.length===1&&(()=>{const a=E.add(E5,T[0],T[0]);return a.case==='P2 = \u2212P1'&&a.R.inf;})());
 t('2-torsion over F_5: the doubling formula refuses T (division by 2y + a1x + a3 = 0)',()=>{try{E.doublingLambda(E5,T[0]);return 'not refused';}catch(e){return /doubling refused/.test(e.message)||e.message;}});
 t('2-torsion over F_5: [2]T = O by double-and-add, labels '+E.mul(E5,2n,T[0]).steps.map(x=>x.case).join(', '),()=>{const m=E.mul(E5,2n,T[0]);return m.R.inf&&m.steps[1].case==='P2 = \u2212P1';});}
// Jacobi symbol vs the table of squares
t('Jacobi symbol (by reciprocity) = Legendre symbol from the table of squares, every a mod p, odd p < 100',()=>{for(const p of E.primesBelow(100n)){if(p===2n)continue;const sq=new Set();for(let x=1n;x<p;x++)sq.add((x*x)%p);
  for(let a=0n;a<p;a++){const want=a===0n?0n:sq.has(a)?1n:-1n;if(E.jacobi(a,p)!==want)return 'a = '+a+' p = '+p;}}return true;});
// a_p by two routes
const PR=E.primesBelow(100n),apFx=Object.fromEntries(fx.ap.map(x=>[x.p,B(x.ap)])),NFx=Object.fromEntries(fx.Np.map(x=>[x.p,B(x.N)]));
const rows=PR.map(p=>({p,i:E.apNaive(A,p),ii:p===2n?null:E.apCharSum(A,p)}));
t('a_p route (i) (naive projective count, singular point included) = fixture for all 25 p < 100',()=>rows.every(r=>r.i.ap===apFx[String(r.p)])||rows.filter(r=>r.i.ap!==apFx[String(r.p)]).map(r=>r.p).join());
t('a_p route (ii) (character sum, Jacobi reciprocity) = fixture for all 24 odd p < 100; p = 2 uses route (i) only',()=>rows.every(r=>r.p===2n?r.ii===null:r.ii.ap===apFx[String(r.p)]));
t('routes (i) and (ii) agree for every odd p < 100, the bad prime 37 included',()=>rows.filter(r=>r.ii).every(r=>r.i.ap===r.ii.ap&&r.i.count===r.ii.count));
t('#E(F_p) = p + 1 − a_p = fixture E.Np(p) for all 24 good p < 100',()=>rows.filter(r=>r.p!==37n).every(r=>r.i.count===NFx[String(r.p)])&&fx.Np.length===24);
t('at p = 37 the naive count 39 = p + 2 includes the singular point (E_ns(F_37) has p + 1 = 38 points)',()=>{const r=rows.find(x=>x.p===37n);return r.i.count===39n&&E.singularPoints(E.curveFp(A,37n)).length===1;});
t('Hasse bound |a_p| ≤ 2√p (as a_p² ≤ 4p) for every good p < 100',()=>rows.filter(r=>r.p!==37n).every(r=>r.i.ap*r.i.ap<=4n*r.p));
// bad prime
{const rt=E.reductionType(A,37n);
 t('p = 37: reduction type '+rt.label+' (tangent cone at the singular point '+E.ptStr(E.curveFp(A,37n),rt.singular)+'), matching a_37 = −1',()=>rt.type==='nonsplit'&&rt.expected_ap===-1n&&apFx['37']===-1n);
 t('p = 37: independent route: 37 ∤ c4 = 48 (multiplicative) and −c6 = 216 is a non-square mod 37 (nonsplit)',()=>48n%37n!==0n&&E.jacobi(216n,37n)===-1n);
 t('every other p < 100 has good reduction (p ∤ Δ = 37)',()=>PR.filter(p=>p!==37n).every(p=>E.reductionType(A,p).type==='good'));}
// orders and cyclicity
const inv=Object.fromEntries(fx.abelian_invariants.rows.map(x=>[x.p,x.invariants]));
t('order of P mod p divides #E(F_p) for every good p < 60',()=>{for(const p of PR.filter(p=>p<60n&&p!==37n)){const Rd=E.reduce(C,P,p),n=E.order(Rd.E,Rd.R),N=NFx[String(p)];if(N%n!==0n)return 'p = '+p;}return true;});
{const W=PR.filter(p=>p<60n&&p!==37n).map(p=>({p,w:E.cyclicWitness(E.curveFp(A,p))}));
 t('E(F_p) cyclic for every good p < 60, by a point of full order (found by search), and #E(F_p) = fixture',()=>W.every(x=>x.w.cyclic&&x.w.N===NFx[String(x.p)])||W.filter(x=>!x.w.cyclic).map(x=>x.p).join());
 t('…which matches the fixture’s abelian invariants (n,) for 3 ≤ p < 60, p ≠ 37 (p = 2: #E = 5, cyclic, not in the fixture list)',()=>W.filter(x=>x.p>=3n).every(x=>inv[String(x.p)]&&inv[String(x.p)].length===1&&B(inv[String(x.p)][0])===x.w.N)&&!inv['2']);
 t('orders of P mod p, p < 60 good: '+W.map(x=>{const Rd=E.reduce(C,P,x.p);return x.p+':'+E.order(Rd.E,Rd.R)+'|'+x.w.N;}).join(' '),()=>true);}
// reduction of rational points
t('reduction mod p is a homomorphism on kP, k = 1 … 10, every good p < 100; O exactly when p divides a denominator',()=>{for(const p of PR.filter(p=>p!==37n)){const R1=E.reduce(C,P,p);
  for(let k=1;k<=10;k++){const Rk=E.reduce(C,muls[k-1].R,p),want=E.mul(R1.E,BigInt(k),R1.R).R;if(!E.ptEq(R1.E,Rk.R,want))return 'p = '+p+' k = '+k;
    const dv=muls[k-1].R.x.den%p===0n;if(dv!==Rk.R.inf)return 'O rule p = '+p+' k = '+k;}}return true;});
t('5P = (1/4, −3/8) reduces to O mod 2; 7P = (−5/9, …) reduces to O mod 3',()=>E.reduce(C,muls[4].R,2n).R.inf&&E.reduce(C,muls[6].R,3n).R.inf&&!E.reduce(C,muls[4].R,3n).R.inf);
// enc
const encCheck=(ainvs,p)=>{const Ep=E.curveFp(ainvs,p),pts=E.points(Ep),seen=new Map();let coll=0;for(const Q of pts){const e=E.enc(Ep,Q);if(seen.has(e))coll++;else seen.set(e,Q);}
  const byX=new Map();for(const Q of pts)if(!Q.inf)byX.set(Q.x,(byX.get(Q.x)||0)+1);return {coll,pairs:[...byX.values()].filter(v=>v===2).length,n:pts.length};};
t('enc(A) = 2x + (y mod 2) is injective on E(F_p) for a1 = a3 = 0: short model y² = x³ − 16x + 16 and y² = x³ + x + 1, every p < 100 (exhaustive)',()=>{
  for(const p of PR)for(const a of [[0n,0n,0n,-16n,16n],[0n,0n,0n,1n,1n]]){const c=encCheck(a,p);if(c.coll)return 'p = '+p+' '+a.join();}return true;});
{const res=PR.map(p=>({p,...encCheck(A,p)}));
 t('enc on 37a1 (a3 = 1): injective at p = 2 only; at every odd p < 100 the collisions are exactly the x with two points (y + y′ = p − 1 is even, so y ≡ y′ mod 2)',()=>
   res.every(r=>r.p===2n?r.coll===0:(r.coll===r.pairs&&r.pairs>0))||res.map(r=>r.p+':'+r.coll+'/'+r.pairs).join(' '));
 t('enc collisions on 37a1 per p (collisions / x-values with two points): '+res.map(r=>r.p+':'+r.coll+'/'+r.pairs).join(' '),()=>true);}
t('the y-pairing proof for 37a1, checked: for odd p and every affine point, the partner y′ = −y − 1 mod p satisfies y + y′ = p − 1',()=>{for(const p of PR.filter(p=>p!==2n)){const Ep=E.curveFp(A,p);for(const Q of E.points(Ep)){if(Q.inf)continue;const y2=E.neg(Ep,Q).y;if(Q.y+y2!==p-1n)return 'p = '+p;}}return true;});
t('not adopted, recorded only: enc′(A) = 2x + ((2y + a1x + a3) mod p mod 2) is injective on 37a1 for every odd p < 100',()=>{for(const p of PR.filter(p=>p!==2n)){const Ep=E.curveFp(A,p),seen=new Set();for(const Q of E.points(Ep)){const e=Q.inf?2n*p:2n*Q.x+(((2n*Q.y+1n)%p)%2n);if(seen.has(e))return 'p = '+p;seen.add(e);}}return true;});
t('curves over F_p keep residues canonical in [0, p) (all points of 37a1 mod 97)',()=>E.points(E.curveFp(A,97n)).every(Q=>Q.inf||(Q.x>=0n&&Q.x<97n&&Q.y>=0n&&Q.y<97n)));
console.log('SUMMARY test-elliptic-exact: '+pass+' passed, '+fail+' failed');
process.exit(fail?1:0);
