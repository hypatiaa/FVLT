// Skeleton's scripted check of the frozen FF-1 signatures (SIGNATURE_FREEZE_DRAFT_v0_1.md, a9382d40...)
// and of FF-2 v0.1 Parts A and B (WORK_ORDER_v0_1.md, 1b00f78f...). Exact integer / BigInt-rational arithmetic only.
// Finite domains: this is evidence that each statement is true where checked, not a proof.
"use strict";
let fails=0, checks=0; const failLog={};
function ok(name, cond, info){ checks++; if(!cond){ fails++; (failLog[name]=failLog[name]||[]).length<5 && failLog[name].push(info); } }
const gcd=(a,b)=>{ a=a<0n?-a:a; b=b<0n?-b:b; while(b){ [a,b]=[b,a%b]; } return a; };
const abs=a=>a<0n?-a:a;
// exact rationals: [num, den] with den > 0, reduced
const R=(n,d=1n)=>{ n=BigInt(n); d=BigInt(d); if(d<0n){n=-n;d=-d;} const g=gcd(n,d)||1n; return [n/g,d/g]; };
const add=(x,y)=>R(x[0]*y[1]+y[0]*x[1], x[1]*y[1]), sub=(x,y)=>R(x[0]*y[1]-y[0]*x[1], x[1]*y[1]);
const mul=(x,y)=>R(x[0]*y[0], x[1]*y[1]), eq=(x,y)=>x[0]===y[0]&&x[1]===y[1], lt=(x,y)=>x[0]*y[1]<y[0]*x[1];
const cmp=(x,y)=>{ const d=x[0]*y[1]-y[0]*x[1]; return d<0n?-1:d>0n?1:0; };
const det=(x,y)=>x[0]*y[1]-y[0]*x[1], adj=(x,y)=>abs(det(x,y))===1n;
const rawValue=(a,q)=>R(a,q), mediant=(x,y)=>rawValue(x[0]+y[0], x[1]+y[1]), unit=a=>R(1n,BigInt(a));
const key=x=>x[0]+"/"+x[1];

// ---------- A1 ----------
for(let a=-12n;a<=12n;a++) for(let c=-12n;c<=12n;c++) for(let q=1n;q<=12n;q++) for(let s=1n;s<=12n;s++){
  if(abs(a*s-c*q)===1n) ok("A1 raw_det_one_coprime", gcd(a,q)===1n&&gcd(c,s)===1n&&gcd(q,s)===1n, [a,c,q,s]+"");
  if(gcd(a,q)===1n&&gcd(c,s)===1n) ok("A1 rawValue_unique", eq(rawValue(a,q),rawValue(c,s))===(a===c&&q===s), [a,c,q,s]+"");
}
for(let a=-20n;a<=20n;a++) for(let q=1n;q<=20n;q++) if(gcd(a,q)===1n){ const v=rawValue(a,q); ok("A1 rawValue_canonical", v[0]===a&&v[1]===q, [a,q]+""); }
const RAT=[]; for(let q=1n;q<=14n;q++) for(let a=-2n*q;a<=3n*q;a++) if(gcd(a,q)===1n) RAT.push(R(a,q));
for(const x of RAT){ ok("A1 rawValue_num_den", eq(rawValue(x[0],x[1]),x), key(x)); ok("A1 fareyAdj_irrefl", !adj(x,x), key(x)); }
for(const x of RAT) for(const y of RAT) ok("A1 fareyAdj_symm", adj(x,y)===adj(y,x), key(x)+" "+key(y));
ok("A1 coprime_den_not_adj", gcd(3n,5n)===1n && !adj(unit(3),unit(5)) && abs(det(unit(3),unit(5)))===2n, "");

// ---------- A2 ----------
for(const x of RAT) for(const y of RAT) if(lt(x,y)&&adj(x,y)){ const m=mediant(x,y);
  ok("A2 adjacent_mediant", gcd(x[0]+y[0],x[1]+y[1])===1n && m[0]===x[0]+y[0] && m[1]===x[1]+y[1] && lt(x,m)&&lt(m,y) && adj(x,m)&&adj(m,y), key(x)+" "+key(y)); }
for(let N=2;N<=300;N++) ok("A2 rosette", abs(det(unit(N-1),unit(N+1)))===2n && eq(mediant(unit(N-1),unit(N+1)),unit(N)) && adj(unit(N),unit(N-1)) && adj(unit(N),unit(N+1)), N);

// ---------- A3-A4 (exact: centres have rational coordinates) ----------
const rad=x=>R(1n,2n*x[1]*x[1]);
const d2=(x,y)=>{ const dx=sub(x,y), dy=sub(rad(x),rad(y)); return add(mul(dx,dx),mul(dy,dy)); };   // |c_x - c_y|^2
for(const x of RAT) ok("A3 radius_pos", rad(x)[0]>0n, key(x));
for(const x of RAT) for(const y of RAT) if(!eq(x,y)){
  const s=add(rad(x),rad(y)), dd=sub(rad(x),rad(y)), D=det(x,y);
  ok("A3 ford_distance_identity", eq(sub(d2(x,y),mul(s,s)), R(D*D-1n, x[1]*x[1]*y[1]*y[1])), key(x)+" "+key(y));
  ok("A3 ford_open_disjoint (d >= r1+r2)", cmp(d2(x,y),mul(s,s))>=0, key(x)+" "+key(y));
  if(abs(D)>=2n) ok("A3 ford_boundary_disjoint (d > r1+r2)", cmp(d2(x,y),mul(s,s))>0, key(x)+" "+key(y));
  // two distinct circles meet in exactly one point iff d = r1+r2 or d = |r1-r2| (d > 0 here)
  const one = eq(d2(x,y),mul(s,s)) || eq(d2(x,y),mul(dd,dd));
  ok("A4 ford_tangent_iff", one===adj(x,y), key(x)+" "+key(y));
  if(adj(x,y)){
    const kN=x[0]*x[1]+y[0]*y[1], kM=x[1]*x[1]+y[1]*y[1], kre=R(kN,kM), kim=R(1n,kM);
    for(const z of [x,y]){ const dx=sub(kre,z), dy=sub(kim,rad(z)); ok("A4 kiss_membership", eq(add(mul(dx,dx),mul(dy,dy)), mul(rad(z),rad(z))), key(x)+" "+key(y)); }
    ok("A4 kiss_integer_identity", kN*kN+1n===(x[0]*x[0]+y[0]*y[0])*kM, key(x)+" "+key(y));
  }
}
// ford_real_axis: point t on the real axis is on boundary x iff (t-x)^2 + r^2 = r^2 iff t = x
for(const x of RAT.slice(0,200)) for(const t of RAT.slice(0,200)){ const dx=sub(t,x); ok("A3 ford_real_axis", (eq(add(mul(dx,dx),mul(rad(x),rad(x))),mul(rad(x),rad(x))))===eq(t,x), key(x)+" "+key(t)); }
for(let a=-9n;a<=9n;a++) for(let c=-9n;c<=9n;c++) for(let q=-9n;q<=9n;q++) for(let s=-9n;s<=9n;s++)
  ok("A4 two_squares", (a*q+c*s)**2n+(a*s-c*q)**2n===(a*a+c*c)*(q*q+s*s), [a,c,q,s]+"");

// ---------- A5 ----------
for(let a=1;a<=80;a++) for(let b=1;b<=80;b++){
  ok("A5 unitFrac_injective_positive", eq(unit(a),unit(b))===(a===b), [a,b]+"");
  ok("A5 unitFrac_adj", adj(unit(a),unit(b))===(Math.abs(a-b)===1), [a,b]+"");
}
function connectedUnit(V){ if(!V.length) return false; const seen=new Set([V[0]]), st=[V[0]];
  while(st.length){ const u=st.pop(); for(const v of V) if(!seen.has(v)&&adj(unit(u),unit(v))){ seen.add(v); st.push(v);} } return seen.size===V.length; }
for(let m=0;m<(1<<11);m++){ const V=[]; for(let i=0;i<11;i++) if(m>>i&1) V.push(i+1); if(!V.length) continue;
  const interval = V[V.length-1]-V[0]+1===V.length;
  ok("A5 unitFrac_graph_connected", connectedUnit(V)===interval, V+""); }
for(let a=1;a<=60;a++) for(let k=1;k<=60;k++){
  ok("A5 gap_det", abs(det(unit(a),unit(a+k)))===BigInt(k), [a,k]+"");
  if(k===2) ok("A5 minimal_gap_mediant", eq(mediant(unit(a),unit(a+2)),unit(a+1)), a);
  if(k>2){ const m=mediant(unit(a),unit(a+k)); ok("A5 gap_mediant_unit_iff", (m[0]===1n&&m[1]>0n)===(k%2===0), [a,k]+""); }
}

// ---------- A6 ----------
const divisors=n=>{ const r=[]; for(let d=1;d<=n;d++) if(n%d===0) r.push(d); return r; };
function admissible(al){ const S=new Set(); for(const a of al) for(const q of divisors(a+1)) if(q>=2) S.add(q); return [...S].sort((a,b)=>a-b); }
function phases(al){ const M=new Map(); for(const q of admissible(al)) for(let c=1;c<q;c++) if(gcd(BigInt(c),BigInt(q))===1n){ const x=R(c,q); M.set(key(x),x);} return M; }
function unreduced(al){ const M=new Map(); for(const a of al) for(let e=1;e<=a;e++){ const x=R(e,a+1); M.set(key(x),x);} return M; }
const ediv=(a,b)=>{ let q=a/b; if(a-q*b<0n) q+= b>0n?-1n:1n; return q; };          // Euclidean division
const modEq=(n,a,b)=>((a-b)%n+n)%n===0n;
const PROFILES=[]; for(let a=1;a<=14;a++){ PROFILES.push([a]); for(let b=1;b<=a;b++){ PROFILES.push([a,b]); for(let c=1;c<=b;c+=2) PROFILES.push([a,b,c]); } }
PROFILES.push([4,3,2,1],[9,2],[8,3],[12,6,4,3,2,1]);
for(const al of PROFILES){
  const P=phases(al), U=unreduced(al), adm=admissible(al), lab=JSON.stringify(al), PV=[...P.values()];
  ok("A6 phases_eq_unreduced", P.size===U.size && [...P.keys()].every(k=>U.has(k)), lab);
  const iso=x=>PV.every(y=>!adj(x,y));
  for(const x of PV){
    ok("A6 phase_domain", x[0]>0n && x[0]<x[1] && x[1]>=2n && adm.includes(Number(x[1])), lab+" "+key(x));
    const one=sub(R(1),x); ok("A6 complement_mem", P.has(key(one)), lab+" "+key(x));
    ok("A6 isolated_complement_pairs", iso(x)===iso(one) && (eq(one,x)===eq(x,R(1,2))), lab+" "+key(x));
    for(const y of PV){ if(adj(x,y)) ok("A6 cross_denominator", x[1]!==y[1], lab+" "+key(x)+" "+key(y));
      ok("A6 complement_adj", adj(sub(R(1),x),sub(R(1),y))===adj(x,y), lab+" "+key(x)+" "+key(y)); }
    let anyPartner=false;
    for(const sN of adm){ const s=BigInt(sN);
      for(let c=-s-2n;c<=s+2n;c++){ const v=rawValue(c,s);
        const lhs = P.has(key(v)) && v[1]===s && v[0]===c && adj(x,v);
        const rhs = 1n<=c && c<=s-1n && [-1n,1n].some(e=>x[0]*s-c*x[1]===e);
        ok("A6 denominator_partner", lhs===rhs, lab+" "+key(x)+" s="+s+" c="+c); if(rhs) anyPartner=true; }
      const L = PV.some(y=>y[1]===s && adj(x,y));
      const Rr = [-1n,1n].some(e=> modEq(x[1], x[0]*s, e) && 1n<=ediv(x[0]*s-e,x[1]) && ediv(x[0]*s-e,x[1])<=s-1n);
      ok("A6 partner_congruence", L===Rr, lab+" "+key(x)+" s="+s);
    }
    ok("A6 isolation_criterion", iso(x)===!anyPartner, lab+" "+key(x));
  }
  for(const nN of adm){ const n=BigInt(nN), x=unit(nN);
    const rhs=!adm.some(sN=>{ const s=BigInt(sN); return [-1n,1n].some(e=> modEq(n,s,e) && 1n<=ediv(s-e,n) && ediv(s-e,n)<=s-1n); });
    ok("A6 endpoint_isolation", P.has(key(x)) && iso(x)===rhs, lab+" n="+n); }
}

// ---------- A7 fixtures (counts, partitions, isolated sets) ----------
function graphFacts(al){ const PV=[...phases(al).values()].sort(cmp); const n=PV.length, nb=PV.map(()=>[]); let E=0;
  for(let i=0;i<n;i++) for(let j=i+1;j<n;j++) if(adj(PV[i],PV[j])){ nb[i].push(j); nb[j].push(i); E++; }
  const comp=new Array(n).fill(-1); let C=0;
  for(let i=0;i<n;i++) if(comp[i]<0){ const st=[i]; comp[i]=C; while(st.length){ const u=st.pop(); for(const v of nb[u]) if(comp[v]<0){comp[v]=C; st.push(v);} } C++; }
  const parts=[...Array(C).keys()].map(c=>PV.filter((_,i)=>comp[i]===c).map(key).sort().join(" ")).sort();
  return {V:n,E,C,parts,iso:PV.filter((_,i)=>!nb[i].length).map(key).sort().join(" ")}; }
const want=(al,V,E,C,isoList,big)=>{ const f=graphFacts(al), lab=JSON.stringify(al);
  ok("A7 fixture counts "+lab, f.V===V&&f.E===E&&f.C===C, JSON.stringify(f));
  ok("A7 fixture isolated "+lab, f.iso===isoList.slice().sort().join(" "), f.iso);
  if(big) ok("A7 fixture partition "+lab, JSON.stringify(f.parts)===JSON.stringify([...isoList, big.slice().sort().join(" ")].sort()), JSON.stringify(f.parts)); };
want([4,2,1],7,6,3,["1/5","4/5"],["1/3","2/5","1/2","3/5","2/3"]);
want([4,3,2,1],9,10,1,[],null);
want([9,2],11,8,5,["1/10","1/5","4/5","9/10"],["3/10","1/3","2/5","1/2","3/5","2/3","7/10"]);
want([8,3],11,8,3,["1/9","8/9"],["2/9","1/4","1/3","4/9","1/2","5/9","2/3","3/4","7/9"]);
ok("A7 fixture421_vertices", [...phases([4,2,1]).keys()].sort().join(" ")===["1/5","1/3","2/5","1/2","3/5","2/3","4/5"].sort().join(" "), "");
ok("A7 fixture4321_repair_edges", ["1/5","1/4","3/4","4/5"].every(k=>phases([4,3,2,1]).has(k)) && adj(R(1,5),R(1,4)) && adj(R(3,4),R(4,5)), "");

// ---------- FF-2 Part A: the skin, omega = 3..12 ----------
const pc=v=>{ let c=0; while(v){ c+=v&1; v>>=1; } return c; };
const eps=v=>(pc(v)&1)?-1:1, md=(a,n)=>((a%n)+n)%n;
for(let n=3;n<=12;n++){
  const V=1<<n, sq=[]; for(let i=0;i<n;i++){ const j=(i+1)%n; for(let v=0;v<V;v++) if(!(v>>i&1)&&!(v>>j&1)) sq.push([v,i,j]); }
  let E=0; for(let v=0;v<V;v++) for(let d=0;d<n;d++) if(!(v>>d&1)) E++;
  const F=sq.length, chi=V-E+F;
  ok("FF2 A1 counts", V===2**n && E===n*2**(n-1) && F===n*2**(n-2) && chi===2**(n-2)*(4-n), n);
  ok("FF2 A5 genus", 1-chi/2===1+(n-4)*2**(n-3), n);
  // oriented boundary edges: key "v,d" (v without bit d) -> list of [square, coef]
  const inc=new Map(), put=(v,d,f,c)=>{ const k=v+","+d; if(!inc.has(k)) inc.set(k,[]); inc.get(k).push([f,c]); };
  sq.forEach(([v,i,j],f)=>{ const s=eps(v); put(v,i,f,s); put(v|1<<i,j,f,s); put(v|1<<j,i,f,-s); put(v,j,f,-s); });
  ok("FF2 A2 every edge in two squares", inc.size===E && [...inc.values()].every(l=>l.length===2), n);
  ok("FF2 A4 opposite coefficients", [...inc.values()].every(l=>l[0][1]===-l[1][1]), n);
  // A3 link: squares at w correspond to adjacent pairs {i,i+1}; consecutive ones share edge direction i+1; single n-cycle
  for(let w=0;w<V;w++){ const at=sq.filter(([v,i,j])=>{ const cs=[v,v|1<<i,v|1<<j,v|1<<i|1<<j]; return cs.includes(w); });
    const pairs=at.map(([v,i])=>i).sort((a,b)=>a-b);
    ok("FF2 A3 link is one n-cycle", at.length===n && pairs.every((p,k)=>p===k), n+" w="+w); }
  // A6 turn rule, A7 constant stream; orientation: does the corner (in b, out d) run along the square's oriented boundary?
  const sqOfCorner=(w,b,d)=>{ const lo=md(b-d,n)===1?d:b; /* pair {lo,lo+1} */ const v=w&~(1<<lo)&~(1<<((lo+1)%n)); return [v,lo,(lo+1)%n]; };
  const orientSign=(w,b,d)=>{ const [v,i,j]=sqOfCorner(w,b,d); const s=eps(v);
    const cyc=[v, v|1<<i, v|1<<i|1<<j, v|1<<j];                    // positive boundary order when s=+1
    const a=w^(1<<b), c=w^(1<<d), ia=cyc.indexOf(a), iw=cyc.indexOf(w), ic=cyc.indexOf(c);
    const fwd = md(iw-ia,4)===1 && md(ic-iw,4)===1, bwd = md(ia-iw,4)===1 && md(iw-ic,4)===1;
    return fwd ? s : bwd ? -s : 0; };
  const seen={1:new Set(),[-1]:new Set()};
  for(let w=0;w<V;w++) for(let b=0;b<n;b++) for(const s of [1,-1]){ const d=md(b-s*eps(w),n);
    ok("FF2 A6 d = b +- 1", md(d-b,n)===1||md(b-d,n)===1, [n,w,b,s]+"");
    seen[s].add(orientSign(w,b,d));
    // A7: constant stream from (w,b) returns in exactly 4 steps
    let ww=w, bb=b; const path=[ww]; for(let t=0;t<4;t++){ const dd=md(bb-s*eps(ww),n); ww^=1<<dd; bb=dd; path.push(ww); }
    ok("FF2 A7 constant stream closes in 4", ww===w && bb===b && new Set(path.slice(0,4)).size===4, [n,w,b,s]+""); }
  ok("FF2 A6 s=+1 one orientation side", seen[1].size===1 && !seen[1].has(0), n+" "+[...seen[1]]);
  ok("FF2 A6 s=-1 the other side", seen[-1].size===1 && [...seen[-1]][0]===-[...seen[1]][0], n+" "+[...seen[-1]]);
}

// ---------- FF-2 Part B: pillow map vs orbits of the half-turn group about (ia, jb) ----------
const mdI=(a,n)=>((a%n)+n)%n;
for(let a=1;a<=5;a++) for(let b=1;b<=5;b++){
  const pillow=(X,Y)=>{ const A=2*a,B=2*b; let x=mdI(X,A), y=mdI(Y,B); if(y>b){ y=B-y; x=mdI(A-x,A); } return x+","+y; };
  const rectX=x=> x<=a ? x : 2*a-x;
  const pkey=(X,Y)=>{ const [x,y]=pillow(X,Y).split(",").map(Number), r=rectX(x); const bd=r===0||r===a||y===0||y===b; return bd?'B'+r+','+y:(x<a?'F':'K')+r+','+y; };
  const orbitKey=(X,Y)=>{ // canonical rep of {(X+2ia, Y+2jb)} U {(-X+2ia, -Y+2jb)}
    const t=[mdI(X,2*a),mdI(Y,2*b)], u=[mdI(-X,2*a),mdI(-Y,2*b)]; return (t[0]<u[0]||(t[0]===u[0]&&t[1]<=u[1]))?t+"":u+""; };
  const pts=[]; for(let X=-2*a;X<=4*a;X++) for(let Y=-2*b;Y<=4*b;Y++) pts.push([X,Y]);
  let mapOK=true, keyOK=true;
  for(let i=0;i<pts.length;i+=3) for(let k=0;k<pts.length;k+=5){ const [P,Q]=[pts[i],pts[k]], same=orbitKey(...P)===orbitKey(...Q);
    if((pillow(...P)===pillow(...Q))!==same) mapOK=false;
    if((pkey(...P)===pkey(...Q))!==same) keyOK=false; }
  ok("FF2 B pillow(X,Y) identifies exactly the orbits (as written in the order)", mapOK, [a,b]+"");
  ok("FF2 B pillowKey identifies exactly the orbits", keyOK, [a,b]+"");
  // cone classes: orbit fixed by a half-turn  <=>  2X in 2aZ and 2Y in 2bZ  <=>  X in aZ, Y in bZ
  const cones=new Set(); for(const [X,Y] of pts) if(mdI(X,a)===0&&mdI(Y,b)===0) cones.add(orbitKey(X,Y));
  ok("FF2 B four cone classes", cones.size===4, [a,b]+" "+[...cones]);
}

console.log(JSON.stringify({checks, fails, failures:failLog}, null, 1));
process.exitCode = fails ? 1 : 0;
