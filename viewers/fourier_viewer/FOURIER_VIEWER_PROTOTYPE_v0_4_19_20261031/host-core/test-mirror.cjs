'use strict';
// T-MA (v0.4 mirror axis): feature note 9267e39f… (Claude Fable 5.1, from saphir's observations) as amended by the S0 design review §5
// (SEIFERT_S0_DESIGN_REVIEW_20261019/REVIEW.md, 01262856…, Codex, review #539). Exact statements are checked with BigInt rationals computed here
// independently of orbit-core; geometric statements in the viewer's own numerical register (comb-numeric) with tolerance 1e-9.
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('./comb-core.js'),O=require('./orbit-core.js'),NUM=require('./comb-numeric.js');
let pass=0,fail=0;const INFO=[];
const t=(name,fn)=>{let ok=false,extra='';try{const r=fn();ok=r===true||(r&&r.ok===true);if(r&&r.note)extra=' '+r.note;}catch(e){extra=' threw '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+extra);ok?pass++:fail++;};
const info=s=>{INFO.push(s);console.log('INFO '+s);};
const {rat,add,mul,div,sub,text}=X,babs=n=>n<0n?-n:n,gcd=(a,b)=>{a=babs(a);b=babs(b);while(b){[a,b]=[b,a%b];}return a;};
const TOL=1e-9;
// ---- independent exact helpers (not orbit-core)
const lcmQ=(x,y)=>{const ln=x.n/gcd(x.n,y.n)*y.n;return rat(ln,gcd(x.d,y.d));};
function periodIndep(t1,t2,c,Nq){const ps=[];if(t1.n!==0n)ps.push(div(rat(2n),X.qabs(t1)));const ct=mul(rat(c),t2);if(ct.n!==0n)ps.push(div(mul(rat(2n),Nq),X.qabs(ct)));return ps.reduce(lcmQ);}
// ---- the preset grid: integer shells N = 2..12 (B = 24), two between-shells N (continuous mode), rational gears, both parities, both n6 signs
const PRESETS=[];
for(const N of [2,3,4,5,6,7,8,9,10,11,12])for(const m of [2,3,4,5,6,7])for(const [t1,t2] of [['1','1'],['1/2','1'],['2','1/3'],['3/2','-3/2'],['-1','2'],['1','2/3']])
  PRESETS.push({shellMode:'integer',B:'24',nMode:'integer',phi3:String(25-N),m:String(m),t1,t2,n6:N%2?'1':'-1',alpha:N%3?'0':'1',sTyped:['0','1','7/3','-5/2'][(N+m)%4]});
for(const phi3 of ['7/2','89/4'])for(const m of [3,4,6])for(const [t1,t2] of [['1','1'],['1/2','3']])PRESETS.push({shellMode:'integer',B:'24',nMode:'continuous',phi3,m:String(m),t1,t2,n6:'1',alpha:'0',sTyped:'1/3'});
const states=PRESETS.map(p=>C.enterSpin(C.initial(p),p.sTyped));
info('preset grid: '+states.length+' states ('+states.filter(s=>C.resolve(s).Nint).length+' on integer shells, '+states.filter(s=>!C.resolve(s).Nint).length+' between shells)');
// ---- per state: geometry as drawn (comb-numeric mirrorGeometry with the orbits the view draws)
const G=states.map(st=>{const num=NUM.compute(st),orbs=NUM.orbits(st,num);return {st,R:C.resolve(st),num,orbs,g:NUM.mirrorGeometry(st,num,orbs)};});
let nPairs=0,nPartial=0,nEvents=0,nCoincident=0;
// T-MA 1: drawn same-time count equals the exact M = P|c t2|/N (independent P), M even; s_k = k N/|c t2|, 0 <= k < M
t('T-MA 1: for every preset and every mirror pair, the drawn same-time tip coincidences number exactly M = P·|c·t₂|/N (P = lcm_Q(2/|t₁|, 2N/|c·t₂|) recomputed here), M is an even integer, and the events are s_k = k·N/|c·t₂|, 0 ≤ k < M, alternating β = 0 / β = π',()=>{
  let bad=[];
  for(const {st,R,g} of G){if(!g)continue;
    for(const p of g.pairs){
      const ct=mul(rat(p.c),R.t2);
      if(ct.n===0n){nCoincident++;if(p.status!=='coincident'||p.meetings.length)bad.push('coincident '+p.c);continue;}
      nPairs++;if(p.partial){nPartial++;continue;}
      const P=periodIndep(R.t1,R.t2,p.c,R.Nq),Mq=div(mul(P,X.qabs(ct)),R.Nq),w=div(R.Nq,X.qabs(ct));
      if(Mq.d!==1n||Mq.n%2n!==0n)bad.push('M not even int');
      if(!X.eq(P,p.period)||p.count!==Mq.n||BigInt(p.meetings.length)!==Mq.n)bad.push(C.encodeAddress(st)+' c='+p.c+' drawn '+p.meetings.length+' M '+text(Mq));
      p.meetings.forEach((q,i)=>{if(q.k!==BigInt(i)||!X.eq(q.s,mul(rat(q.k),w))||q.beta!==i%2||X.cmp(q.s,P)>=0)bad.push('event '+i);});
      nEvents+=p.meetings.length;}}
  return {ok:bad.length===0&&nPairs>500,note:'('+nPairs+' pairs with c·t₂ ≠ 0, '+nEvents+' events drawn; '+nPartial+' partial-orbit pairs checked in T-MA 6; '+nCoincident+' pairs with c·t₂ = 0) '+bad.slice(0,3).join(' | ')};});
// T-MA 2: every drawn event lies on a reference longitude within 1e-9 (viewer's numerical register), on the beta of its parity; both teeth are there
let worst=0,worstPair=0,worstRaw=0;
t('T-MA 2: every drawn same-time event lies on a reference longitude within 1e-9 (|arg z₂ − β| from the inverse projection of the drawn 3D point; |z₁| = a, |z₂| = b), on β = 0 for even k and β = π for odd k; tooth −c is at the same point (1e-9); the unreduced float lift of both teeth at s_k agrees (1e-9)',()=>{
  let bad=0;
  for(const {st,R,num,g} of G){if(!g)continue;const a=num.rho/Math.sqrt(1+num.rho*num.rho),b=1/Math.sqrt(1+num.rho*num.rho),Nf=NUM.number(R.Nq),t1=NUM.number(R.t1),t2=NUM.number(R.t2),sg=R.n6.n<0n?Math.PI:0;
    for(const p of g.pairs)for(const q of p.meetings){
      const d=NUM.longitudeDistance(q.p);worst=Math.max(worst,d.dist,Math.abs(d.z1abs-a),Math.abs(d.z2abs-b));
      const dm=Math.hypot(q.p[0]-q.pMinus[0],q.p[1]-q.pMinus[1],q.p[2]-q.pMinus[2]);worstPair=Math.max(worstPair,dm);
      const s=NUM.number(q.s),u=Math.PI*t1*s+sg,v=Math.PI*Number(p.c)*t2*s/Nf,z1={re:a*Math.cos(u),im:a*Math.sin(u)};
      const rp=NUM.stereo(z1,{re:b*Math.cos(-v),im:b*Math.sin(-v)},false).vector,rm=NUM.stereo(z1,{re:b*Math.cos(v),im:b*Math.sin(v)},false).vector;
      const er=Math.max(Math.hypot(rp[0]-q.p[0],rp[1]-q.p[1],rp[2]-q.p[2]),Math.hypot(rm[0]-q.p[0],rm[1]-q.p[1],rm[2]-q.p[2]));worstRaw=Math.max(worstRaw,er);
      if(d.dist>TOL||d.beta!==q.beta||Math.abs(d.z1abs-a)>TOL||Math.abs(d.z2abs-b)>TOL||dm>TOL||er>TOL)bad++;}}
  return {ok:bad===0&&nEvents>0,note:'(worst on-longitude '+worst.toExponential(2)+', worst c / −c separation '+worstPair.toExponential(2)+', worst unreduced-lift difference '+worstRaw.toExponential(2)+'; '+bad+' bad)'};});
// T-MA 3: odd comb: the c = 0 orbit coincides with the beta = 0 longitude (and covers it when t1 != 0)
t('T-MA 3: for every odd comb with t₁ ≠ 0 the drawn c = 0 orbit lies on the β = 0 longitude within 1e-9 at every point (|arg z₂|, |z₁| = a, |z₂| = b) and covers it (largest gap in arg z₁ ≤ 2.01°); the drawn β = 0 longitude points lie on it as well',()=>{
  let bad=0,n=0,w=0,gapMax=0;
  for(const {st,R,num,orbs,g} of G){if(R.m%2===0||R.t1.n===0n||!g)continue;const o=orbs.find(x=>x.c===0n);if(!o||o.stationary){bad++;continue;}n++;
    const a=num.rho/Math.sqrt(1+num.rho*num.rho),b=1/Math.sqrt(1+num.rho*num.rho),ang=[];
    for(const y of o.s3){if(!y){bad++;continue;}const d=NUM.longitudeDistance(y);w=Math.max(w,d.dist,Math.abs(d.z1abs-a),Math.abs(d.z2abs-b));if(d.dist>TOL||d.beta!==0||Math.abs(d.z1abs-a)>TOL||Math.abs(d.z2abs-b)>TOL)bad++;const x=NUM.unproject(y);ang.push((Math.atan2(x[1],x[0])+2*Math.PI)%(2*Math.PI));}
    ang.sort((p,q)=>p-q);let gap=ang[0]+2*Math.PI-ang[ang.length-1];for(let i=1;i<ang.length;i++)gap=Math.max(gap,ang[i]-ang[i-1]);gapMax=Math.max(gapMax,gap*180/Math.PI);if(gap*180/Math.PI>2.01)bad++;
    for(const y of g.longitudes[0].pts){const d=NUM.longitudeDistance(y);if(d.dist>TOL||d.beta!==0)bad++;}}
  return {ok:bad===0&&n>50,note:'('+n+' odd combs, worst '+w.toExponential(2)+', largest arg z₁ gap '+gapMax.toFixed(3)+'°)'};});
// T-MA 4: negative control — one-sided start offset pi/120 on tooth +c only breaks the mirror pairing; the same-time events must leave the longitudes
const B0=Math.PI/120;
t('T-MA 4 (negative control, one-sided start offset): shifting only tooth +c by β₀ = π/120 breaks the mirror pairing; its same-time events with tooth −c (2x ≡ β₀ mod 2π, x = π·c·t₂·s/N) all leave the reference longitudes: every one is farther than 1e-9 from both (distance β₀/2 = π/240 expected), and the on-longitude test that passes T-MA 2 rejects them',()=>{
  let n=0,bad=0,mn=Infinity;
  for(const {st,R,num,g} of G){if(!g)continue;const a=num.rho/Math.sqrt(1+num.rho*num.rho),b=1/Math.sqrt(1+num.rho*num.rho),Nf=NUM.number(R.Nq),t1=NUM.number(R.t1),t2=NUM.number(R.t2),sg=R.n6.n<0n?Math.PI:0;
    for(const p of g.pairs){if(p.status!=='defined'||p.partial)continue;const ct=Number(p.c)*t2/Nf;
      for(let k=0;k<Number(p.count);k++){const x=B0/2+Math.PI*k,s=x/(Math.PI*ct),u=Math.PI*t1*s+sg,z1={re:a*Math.cos(u),im:a*Math.sin(u)};
        const yp=NUM.stereo(z1,{re:b*Math.cos(-x+B0),im:b*Math.sin(-x+B0)},false).vector,ym=NUM.stereo(z1,{re:b*Math.cos(x),im:b*Math.sin(x)},false).vector;
        if(Math.hypot(yp[0]-ym[0],yp[1]-ym[1],yp[2]-ym[2])>TOL){bad++;continue;}   // it is a same-time event of the offset pair
        const d=NUM.longitudeDistance(ym);n++;mn=Math.min(mn,d.dist);if(!(d.dist>TOL))bad++;}}}
  return {ok:bad===0&&n>500&&Math.abs(mn-B0/2)<1e-6,note:'('+n+' offset events, smallest distance to a longitude '+mn.toExponential(4)+' rad, π/240 = '+(B0/2).toExponential(4)+')'};});
t('T-MA 4b (informative contrast, not the negative control): a mirror-preserving paired offset (+β₀ on tooth +c, −β₀ on tooth −c) still puts every same-time event on a reference longitude (within 1e-9)',()=>{
  let n=0,bad=0;
  for(const {R,num,g} of G){if(!g)continue;const a=num.rho/Math.sqrt(1+num.rho*num.rho),b=1/Math.sqrt(1+num.rho*num.rho),Nf=NUM.number(R.Nq),t1=NUM.number(R.t1),t2=NUM.number(R.t2),sg=R.n6.n<0n?Math.PI:0;
    for(const p of g.pairs){if(p.status!=='defined'||p.partial)continue;const ct=Number(p.c)*t2/Nf;
      for(let k=0;k<Number(p.count);k++){const x=B0+Math.PI*k,s=x/(Math.PI*ct),u=Math.PI*t1*s+sg,z1={re:a*Math.cos(u),im:a*Math.sin(u)};   // -x+B0 = -(x-B0) and x-B0: conjugate, equal iff x - B0 in pi Z
        const yp=NUM.stereo(z1,{re:b*Math.cos(-x+B0),im:b*Math.sin(-x+B0)},false).vector,ym=NUM.stereo(z1,{re:b*Math.cos(x-B0),im:b*Math.sin(x-B0)},false).vector;
        n++;if(Math.hypot(yp[0]-ym[0],yp[1]-ym[1],yp[2]-ym[2])>TOL||NUM.longitudeDistance(ym).dist>TOL)bad++;}}}
  return {ok:bad===0&&n>500,note:'('+n+' events)'};});
// T-MA 5: same-time events vs image intersections (review §5 R2): exact enumeration of the intersections of the two straight closed curves
t('T-MA 5: image intersections are a separate count: exact enumeration of the intersection points of the closed images of c and −c (windings (A, B) and (A, −B) over P) gives 2|A·B| = 2|p·q| (the count shown), the same-time ones (τ = τ′) number M, and only those lie on the reference longitudes (numerical, 1e-9)',()=>{
  let bad=[],n=0,tot=0,on=0;
  for(const {st,R,num,g} of G){if(!g||R.t1.n===0n)continue;const a=num.rho/Math.sqrt(1+num.rho*num.rho),b=1/Math.sqrt(1+num.rho*num.rho),sg=R.n6.n<0n?Math.PI:0;
    for(const p of g.pairs){if(p.status!=='defined'||p.partial)continue;const pr=O.mirrorPairs(st).find(x=>x.c===p.c);
      const A=mul(R.t1,div(p.period,rat(2n))),Bw=div(mul(mul(rat(-p.c),R.t2),p.period),mul(rat(2n),R.Nq));
      if(A.d!==1n||Bw.d!==1n||babs(A.n)!==babs(pr.primitive[0])||babs(Bw.n)!==babs(pr.primitive[1])){bad.push('winding');continue;}
      const An=A.n,Bn=Bw.n,pts=new Map();
      // tau - tau' = i/A, tau + tau' = j/B (mod 1): every solution pair (tau, tau') in [0,1)^2
      const fr=q=>{const f=sub(q,rat(X.floor(q)));return f;};
      for(let i=0n;i<2n*babs(An);i++)for(let j=0n;j<2n*babs(Bn);j++){const ta=fr(div(add(rat(i,An),rat(j,Bn)),rat(2n))),tb=fr(div(sub(rat(j,Bn),rat(i,An)),rat(2n)));pts.set(text(ta)+'|'+text(tb),[ta,tb]);}
      // keep only true solutions (A(tau - tau') and B(tau + tau') integers)
      const sol=[...pts.values()].filter(([ta,tb])=>X.isInt(mul(rat(An),sub(ta,tb)))&&X.isInt(mul(rat(Bn),add(ta,tb))));
      const same=sol.filter(([ta,tb])=>X.eq(ta,tb)).length;n++;tot+=sol.length;
      if(BigInt(sol.length)!==pr.imageIntersections||BigInt(same)!==pr.count)bad.push(C.encodeAddress(st)+' c='+p.c+' sol '+sol.length+' img '+pr.imageIntersections+' same '+same);
      // numerically: the points tau of curve +c at the solutions; on a longitude iff tau = tau' (here at most 64 per pair)
      const Nf=NUM.number(R.Nq),t1=NUM.number(R.t1),t2=NUM.number(R.t2);
      for(const [ta,tb] of sol.slice(0,64)){const s=NUM.number(mul(ta,p.period)),u=Math.PI*t1*s+sg,v=Math.PI*Number(p.c)*t2*s/Nf;
        const y=NUM.stereo({re:a*Math.cos(u),im:a*Math.sin(u)},{re:b*Math.cos(-v),im:b*Math.sin(-v)},false).vector,d=NUM.longitudeDistance(y).dist;
        if(X.eq(ta,tb)){on++;if(d>TOL)bad.push('same-time off axis');}else if(d<=TOL)bad.push('image intersection on axis '+C.encodeAddress(st)+' c='+p.c);}}}
  return {ok:bad.length===0&&n>300,note:'('+n+' pairs, '+tot+' image intersections enumerated) '+bad.slice(0,3).join(' | ')};});
// T-MA 6: partial orbits (more than 4,000 points per period): the drawn events are those of the drawn window, flagged, and the exact M is still reported
t('T-MA 6: for every pair whose orbit is drawn as a partial window, the drawn same-time events are exactly the s_k = k·N/|c·t₂| inside the drawn window [s − span/2, s + span/2] (recounted here), flagged partial, never more than M, and the exact M is still the pair count',()=>{
  let n=0,bad=0;
  for(const {st,R,orbs,g} of G){if(!g)continue;const s0=NUM.number(X.parse(st.sTyped));
    for(const p of g.pairs){if(!p.partial)continue;n++;const ob=orbs.find(o=>o.c===p.c),w=NUM.number(p.spacing),lo=s0-ob.span/2,hi=s0+ob.span/2;
      let cnt=0;for(let k=Math.ceil(lo/w)-2;k<=Math.floor(hi/w)+2;k++){const s=k*w;if(s>=lo&&s<=hi)cnt++;}
      const pr=O.mirrorPairs(st).find(x=>x.c===p.c);
      if(!ob.partial||p.meetings.length!==cnt||BigInt(cnt)>p.count||p.count!==pr.count||p.capped)bad++;}}
  return {ok:bad===0&&n>0,note:'('+n+' partial-orbit pairs)'};});
t('drawing cap: at m = 720 (360 pairs) the drawn events stop at MIRROR_CAP = 2000 and the geometry says so (capped, labelled in the view); every exact count is still reported',()=>{
  const st=C.initial({shellMode:'integer',B:'24',phi3:'1',m:'720',t1:'1',t2:'1',n6:'1',alpha:'0'}),num=NUM.compute(st),g=NUM.mirrorGeometry(st,num,NUM.orbits(st,num));
  const drawn=g.pairs.reduce((a,p)=>a+p.meetings.length,0);
  return {ok:g.capped&&drawn===NUM.MIRROR_CAP&&g.pairs.length===360&&g.pairs.every(p=>p.count!==null),note:'(drawn '+drawn+')'};});
// Fable's example and the review's witness
t('T-MA example (feature note; review §5): N = 5, t₁ = t₂ = 1, m = 6, pair ±1: P = 10, M = 2 same-time events at s = 0 (β = 0) and s = 5 (β = π); 10 image intersections; tooth −1 at s = 1 and tooth +1 at s = 9 meet at one point that is not on a reference longitude',()=>{
  const st=C.enterSpin(C.initial({shellMode:'integer',B:'24',phi3:'20',m:'6',t1:'1',t2:'1',n6:'1',alpha:'0'}),'0'),num=NUM.compute(st),g=NUM.mirrorGeometry(st,num,NUM.orbits(st,num)),p=g.pairs.find(x=>x.c===1n),pr=O.mirrorPairs(st)[0];
  const a=Math.SQRT1_2,b=Math.SQRT1_2,pt=(c,s)=>NUM.stereo({re:a*Math.cos(Math.PI*s),im:a*Math.sin(Math.PI*s)},{re:b*Math.cos(-Math.PI*c*s/5),im:b*Math.sin(-Math.PI*c*s/5)},false).vector;
  const y1=pt(-1,1),y9=pt(1,9),d=Math.hypot(y1[0]-y9[0],y1[1]-y9[1],y1[2]-y9[2]),off=NUM.longitudeDistance(y1).dist;
  return text(p.period)==='10'&&p.count===2n&&p.meetings.map(q=>text(q.s)+':'+q.beta).join()==='0:0,5:1'&&pr.imageIntersections===10n&&d<TOL&&off>0.1;});
// guards (review §5)
t('guards: c·t₂ = 0 (t₂ = 0) gives status "coincident" for every pair, no count, no events, no division; t₁ = 0 keeps M = 2 isolated events per pair, labels both images as the same transverse circle (no image-intersection count) and the c = 0 tooth as stationary (a point, the orbit sampler agrees); N = 0 gives "undefined"; ρ = 0 (n₆ = 0) is a collapsed leaf: no longitudes, no events',()=>{
  const a=C.initial({shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'0',n6:'1',alpha:'0'}),pa=O.mirrorPairs(a),na=NUM.compute(a),ga=NUM.mirrorGeometry(a,na,NUM.orbits(a,na));
  const b=C.initial({shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'0',t2:'1',n6:'1',alpha:'0'}),pb=O.mirrorPairs(b),nb=NUM.compute(b),ob=NUM.orbits(b,nb),gb=NUM.mirrorGeometry(b,nb,ob),par=O.mirrorParity(b);
  const z=O.mirrorPairs(C.initial({phi3:'25',m:'4'})),r0=C.initial({shellMode:'integer',B:'24',phi3:'20',m:'5',n6:'0'}),n0=NUM.compute(r0),g0=NUM.mirrorGeometry(r0,n0,NUM.orbits(r0,n0));
  return pa.every(p=>p.status==='coincident'&&p.count===null)&&ga.pairs.every(p=>p.meetings.length===0)
    &&pb.every(p=>p.status==='defined'&&p.count===2n&&p.imageIntersections===null&&/same transverse circle/.test(p.reason))&&gb.pairs.every(p=>p.meetings.length===2)
    &&ob.find(o=>o.c===0n).stationary&&par.carrierStationary&&/stationary, a point/.test(par.label)
    &&z.every(p=>p.status==='undefined')&&n0.rho===0&&g0.collapsed&&g0.longitudes.length===0&&g0.pairs.length===0;});
// parity readout (R3, mnemonic)
t('parity readout (R3, labelled mnemonic): odd m → "mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic)", label "c = 0 · carrier tooth"; even m → "… fixes 0 teeth: line between c = ∓1 (mnemonic)", label "reference carrier · no tooth"; for m = 2..40',()=>{
  for(let m=2;m<=40;m++){const p=O.mirrorParity(C.initial({m:String(m)}));
    if(m%2?(p.readout!=='mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic)'||p.label!=='c = 0 · carrier tooth'||p.fixedTeeth!==1):(p.readout!=='mirror c ↦ −c fixes 0 teeth: line between c = ∓1 (mnemonic)'||p.label!=='reference carrier · no tooth'||p.fixedTeeth!==0))return false;}
  return true;});
// R4: carrier-relative axis; the review's counterexample
t('R4 (review §5): N = 5, m = 6 (offsets ±1, ±3, ±5), t₁ = 1/2, t₂ = 1, s = 1, ρ = 1: the lab-frame resultant is −i (numerical, within the bound), t₁·s ∉ ℤ so the axis is not the real axis (mirrorConjugate false), and the resultant divided by the carrier e^{iπ/2} is real (−1) within the bound',()=>{
  const st=C.enterSpin(C.initial({shellMode:'integer',B:'24',phi3:'20',m:'6',t1:'1/2',t2:'1',n6:'1',alpha:'0'}),'1'),num=NUM.compute(st),W=num.W[num.W.length-1],ph=O.mirrorCarrierPhase(st);
  const th=Math.PI*NUM.number(ph),rel={re:W.re*Math.cos(th)+W.im*Math.sin(th),im:W.im*Math.cos(th)-W.re*Math.sin(th)};
  return num.rho===1&&Math.abs(W.re)<=num.bound&&Math.abs(W.im+1)<=num.bound&&!O.mirrorConjugate(st)&&text(ph)==='1/2'&&Math.abs(rel.im)<=num.bound&&Math.abs(rel.re+1)<=num.bound;});
t('R4: over every preset, the resultant divided by the carrier phase e^{iπ(t₁s + f)} is real within the numerical bound (symmetric offsets), and the lab-frame resultant is real within the bound whenever t₁·s ∈ ℤ (mirrorConjugate)',()=>{
  let bad=0,nc=0;
  for(const {st,num} of G){if(num.refused||num.empty)continue;const W=num.W[num.W.length-1],ph=O.mirrorCarrierPhase(st),th=Math.PI*NUM.number(ph),im=W.im*Math.cos(th)-W.re*Math.sin(th);
    if(Math.abs(im)>num.bound)bad++;if(O.mirrorConjugate(st)){nc++;if(Math.abs(W.im)>num.bound)bad++;}}
  return {ok:bad===0&&nc>50,note:'('+nc+' presets with t₁·s ∈ ℤ)'};});
// display objects: nothing exact or exported changes (compared with the v0.3 modules, read-only)
const V3='../../FOURIER_VIEWER_PROTOTYPE_v0_3_20261014/host-core/';
t('display register only: against the v0.3 modules (read-only), every preset gives identical branches (Lift entries), gates, field line, exact export and state export; the branch count stays m (the reference longitudes are no branch)',()=>{
  const C3=require(V3+'comb-core.js'),O3=require(V3+'orbit-core.js');let bad=0;
  for(const st of states){const a=JSON.stringify(O.branches(st).map(O.liftBranch)),b=JSON.stringify(O3.branches(st).map(O3.liftBranch));
    if(a!==b||JSON.stringify(O.gates(st))!==JSON.stringify(O3.gates(st))||O.field(st).line!==O3.field(st).line||C.exportExact(st,null,{})!==C3.exportExact(st,null,{})||C.exportState(st)!==C3.exportState(st)||O.branches(st).length!==C.resolve(st).m)bad++;}
  return {ok:bad===0,note:'('+states.length+' states, '+bad+' differences)'};});
info('worst numerical figures: on-longitude '+worst.toExponential(3)+', c/−c separation '+worstPair.toExponential(3)+', unreduced-lift difference '+worstRaw.toExponential(3));
console.log(`test-mirror (T-MA): ${pass} passed, ${fail} failed`);
process.exit(fail?1:0);
