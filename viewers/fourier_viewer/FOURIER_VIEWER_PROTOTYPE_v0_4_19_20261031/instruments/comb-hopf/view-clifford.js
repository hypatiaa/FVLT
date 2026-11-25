(function(root){
'use strict';
// Clifford tab: stereographic projection of the S3 lift (host renderClifford). DRAWING register.
// The guide mesh and the leaf mesh are numerical; the tooth dots use the exact reduced phases via comb-numeric.
// Performance round 2: the 3D points of the meshes, the s-orbits and the tooth dots are packed ONCE per exact-state change into Float64Arrays; a camera change
// only rotates and projects them (V.projectInto) and strokes the canvas. No sample and no model value is recomputed by a camera move.
const SBUF=new WeakMap(),SBUFR=new WeakMap();   // v0.4.9: projection buffer per lifted full stack
const V=root.FVViews,GB=root.FVGoldbach,N_=root.FVCombNumeric,EXT=new WeakMap(),PACK=new WeakMap(),W=640,H=480,EL=Math.PI/2-0.01;
const FOLSEL='#ffffff';   // v0.4.1 carrier foliation: faint family, white selected beta (solid) and beta + pi (dashed)
const MIR='#c084fc';   // v0.4 mirror axis colour: the carrier's violet (accent-z0-text), distinct from every tooth colour (the merged viewer's gold would clash with tooth c = ±3)
const DEF={cz:'0.95',ca:'-0.65',ce:'0.45',cx:'0',cy:'0',cl:'1',co:'1',cg:'1',c4:'0',cf:'0',cp:'0',ch:'',cm:'1',cff:'0',cfk:'24',cfb:'0',cs:'0',cr:'0',rl:'0',rlj:'3',rlr:'30',rlq:'2'};   // v0.4.16 D1 Rule 30 ladder card: rl on/off (default off), rlj row j, rlr rule, rlq lift dial q   // v0.4.9: cs full stack (lifted), default off   // v0.4.1 carrier foliation: cff layer (default off), cfk leaf count K in {6, 12, 24, 120}, cfb selected k (beta/pi = k/120, mod 240)   // cm (v0.4): mirror axis layer (reference longitudes and pair meetings), default on
// a mesh (rows x cols of [x,y,z] or null) as typed arrays: vertices, segments between valid neighbours, a projection buffer and six depth buckets. Cached per mesh and line stride.
function pack(pts,k){
  let byK=PACK.get(pts);if(!byK){byK=new Map();PACK.set(pts,byK);}
  if(byK.has(k))return byK.get(k);
  const ii=V.strideIdx(pts.length,k),jj=V.strideIdx(pts[0].length,k),nv=ii.length*jj.length,xyz=new Float64Array(3*nv),ok=new Uint8Array(nv),sa=[],sb=[];
  ii.forEach((i,a)=>jj.forEach((j,b)=>{const p=pts[i][j],v=a*jj.length+b;if(p){xyz[3*v]=p[0];xyz[3*v+1]=p[1];xyz[3*v+2]=p[2];ok[v]=1;}}));
  for(let a=0;a<ii.length;a++)for(let b=0;b<jj.length;b++){const v=a*jj.length+b;
    if(ok[v]&&b+1<jj.length&&ok[v+1]){sa.push(v);sb.push(v+1);}
    if(ok[v]&&a+1<ii.length&&ok[v+jj.length]){sa.push(v);sb.push(v+jj.length);}}
  const ns=sa.length,pk={nv,xyz,ok,sa:Uint32Array.from(sa),sb:Uint32Array.from(sb),ns,sx:new Float64Array(3*nv),bk:Array.from({length:6},()=>new Float32Array(4*ns)),cnt:new Int32Array(6)};
  byK.set(k,pk);return pk;
}
// project the mesh, bucket its segments by depth into 6 alpha levels (one stroke per bucket)
function drawMesh(ctx,pk,cm,fit,cx,cy,rgb,a0,a1,w,role){
  V.projectInto(pk.xyz,pk.nv,cm,fit,cx,cy,pk.sx);
  const sx=pk.sx,ok=pk.ok;let dmin=1e9,dmax=-1e9;
  for(let v=0;v<pk.nv;v++)if(ok[v]){const d=sx[3*v+2];if(d<dmin)dmin=d;if(d>dmax)dmax=d;}
  const sp=(dmax-dmin)||1,cnt=pk.cnt,bk=pk.bk;cnt.fill(0);
  for(let s=0;s<pk.ns;s++){const a=pk.sa[s],b=pk.sb[s],k=Math.min(5,Math.max(0,Math.floor(((sx[3*a+2]+sx[3*b+2])/2-dmin)/sp*6))),B=bk[k],q=4*cnt[k]++;
    B[q]=sx[3*a];B[q+1]=sx[3*a+1];B[q+2]=sx[3*b];B[q+3]=sx[3*b+1];}
  let any=0;
  if(ctx){ctx.lineWidth=w;ctx.setLineDash([]);for(let k=0;k<6;k++){const c=cnt[k];if(!c)continue;any+=c;const B=bk[k];ctx.beginPath();for(let q=0;q<4*c;q+=4){ctx.moveTo(B[q],B[q+1]);ctx.lineTo(B[q+2],B[q+3]);}
    ctx.strokeStyle='rgba('+rgb+','+(a0+(a1-a0)*k/5).toFixed(3)+')';ctx.stroke();}}
  else for(let k=0;k<6;k++)any+=cnt[k];
  return '<path d="" fill="none" stroke="rgba('+rgb+','+a1+')" stroke-width="'+w+'" data-role="'+role+'" data-layer="canvas" data-n="'+any+'"/>';
}
// geometry cache: valid while the numerical model, the orbit sample and the meshes are the same objects (they change only with the exact state)
let GEO=null;
function geometry(M,num,guide,leaf,mir,fol){
  const orbs=M.orbits;
  if(GEO&&GEO.num===num&&GEO.src===orbs&&GEO.guide===guide&&GEO.leaf===leaf&&GEO.mirSrc===mir&&GEO.folSrc===fol)return GEO;
  const ext0=mesh=>{let e=EXT.get(mesh);if(e===undefined){e=0;for(const row of mesh)for(const p of row)if(p)e=Math.max(e,Math.hypot(p[0],p[1],p[2]));EXT.set(mesh,e);}return e;};   // extent of a mesh is memoised on the mesh
  let ext=ext0(guide);if(num.rho>0)ext=Math.max(ext,ext0(leaf));for(const l of num.lift)if(l.proj.vector)ext=Math.max(ext,Math.hypot(...l.proj.vector));
  const od=[];
  orbs.forEach((ob,t)=>{if(ob.stationary||!ob.s3.length)return;const runs=[];let cur=[];
    const flush=()=>{if(cur.length>1){const xyz=V.packXYZ(cur);runs.push({xyz,n:cur.length,buf:new Float64Array(3*cur.length)});}cur=[];};
    for(const p of ob.s3){if(p)cur.push(p);else flush();}flush();      // a null point is a pole break: never joined by a straight segment
    od.push({c:ob.c,t,partial:!!ob.partial,total:ob.s3.length,runs});});
  const nl=num.lift.length,dots={c:num.lift.map(l=>l.c),xyz:new Float64Array(3*nl),ok:new Uint8Array(nl),buf:new Float64Array(3*nl)};
  num.lift.forEach((l,i)=>{const v=l.proj.vector;if(v){dots.xyz[3*i]=v[0];dots.xyz[3*i+1]=v[1];dots.xyz[3*i+2]=v[2];dots.ok[i]=1;}});
  // v0.4 mirror axis: the two reference longitudes and the pair meeting points, packed once per exact-state change like the orbits
  let mg=null;if(mir){const lon=mir.longitudes.map(l=>({beta:l.beta,xyz:V.packXYZ(l.pts),n:l.pts.length,buf:new Float64Array(3*l.pts.length)}));
    const ms=[];for(const p of mir.pairs)for(const q of p.meetings)if(q.p)ms.push({c:p.c,k:q.k,s:q.s,beta:q.beta,p:q.p});
    mg={lon,ms,xyz:V.packXYZ(ms.map(q=>q.p)),buf:new Float64Array(3*ms.length)};}
  // v0.4.1 carrier foliation: family, selected beta and its companion, packed once per exact-state or foliation-dial change
  let fg=null;if(fol&&!fol.collapsed){const pk=c=>({beta:c.beta,xyz:V.packXYZ(c.pts),n:c.pts.length,buf:new Float64Array(3*c.pts.length)});
    fg={fam:fol.family.map(pk),sel:pk(fol.selected),comp:pk(fol.companion),stationary:fol.stationary};}
  GEO={num,src:orbs,guide,leaf,mirSrc:mir,folSrc:fol,ext,orbs:od,dots,mir:mg,fol:fg};return GEO;
}
// ---------------------------------------------------------------- v0.4.16 (SCHEMA_ADDENDUM_23): D1, the Rule 30 ladder-monodromy card. Idea (Rule 30 written on surfaces): saphir.
// Exact register in host-core/rule30-ladder-core.js (integers, BigInt x); the curve's points arrive as exact rationals of a turn and become angles here, at the drawing.
// One torus leaf: the Clifford torus |z1| = |z2| = 1/sqrt2 (rho = 1), z1 = a e^{i*base}, z2 = b e^{i*fibre}, projected from x4 = +1 like every other Clifford drawing.
const RL=root.FVRule30Ladder,RLGEO=new Map(),RLC='#00e5ff',RLE='#f59e0b',RLT='#c084fc';
const rlTurn=f=>2*Math.PI*f[0]/f[1];   // exact rational of a turn -> radians (drawing register)
function rlDial(vs){
  const bad=[];let rule=Number(vs.rlr),j=Number(vs.rlj),q=Number(vs.rlq);
  if(RL.RULES.indexOf(rule)<0){bad.push('rule '+vs.rlr+' is not 30, 90 or 150; showing rule 30');rule=30;}
  if(!(Number.isInteger(j)&&j>=0&&j<=RL.J_MAX)||!/^\d+$/.test(String(vs.rlj))){bad.push('j = '+vs.rlj+' is outside 0 … '+RL.J_MAX+'; showing j = 3');j=3;}
  if(RL.QS.indexOf(q)<0||!/^\d+$/.test(String(vs.rlq))){bad.push('q = '+vs.rlq+' is not 1, 2, 4 or 8; showing q = 2');q=2;}
  return {rule,j,q,bad};
}
function rlGeometry(rule,j,q){
  const key=rule+'|'+j+'|'+q;if(RLGEO.has(key))return RLGEO.get(key);
  const a=Math.SQRT1_2,b=Math.SQRT1_2,pj=RL.perN(rule,j),sub=Math.max(1,Math.ceil(720/pj)),c=RL.curve(rule,j,q,{sub}),cd=RL.card(rule,j,q);
  // v0.4.19 (SCHEMA_ADDENDUM_26): event steps get at least 16 pieces (32 at q = 1) through host-core/d1-event-pieces.js (exact rationals); base steps
  // keep the core's subdivision; the end point is the core's. The mapping of the exact rationals to angles below (rlTurn, at) is the inherited one.
  const PC=root.FVD1Pieces.build(c,t=>RL.N(rule,j,t)),pts=PC.pts,n=pts.length,au=root.FVD1Pieces.audit(PC),evl=root.FVD1Pieces.eventSteps(PC);
  const at=(u,v)=>N_.stereo({re:a*Math.cos(u),im:a*Math.sin(u)},{re:b*Math.cos(v),im:b*Math.sin(v)},false).vector;
  const xyz=new Float64Array(3*n),ev=new Uint8Array(n);
  pts.forEach((p,i)=>{const v=at(rlTurn(p.base),rlTurn(p.fibre));xyz[3*i]=v[0];xyz[3*i+1]=v[1];xyz[3*i+2]=v[2];ev[i]=p.event;});
  // returns to base angle 0 after i whole base cycles: fibre N_j(i*per_j)/q = i*S_j/q turns (i = 0 .. k; i = k is the closure)
  const turns=[];for(let i=0;i<=c.k;i++){const f=[i*c.S,q],v=at(0,rlTurn(f));turns.push({i,fibre:f,xyz:v});}
  const ring=(fn)=>{const pts=[];for(let i=0;i<=256;i++)pts.push(fn(2*Math.PI*i/256));return {xyz:V.packXYZ(pts),n:pts.length,buf:new Float64Array(3*pts.length)};};
  const g={c,cd,n,xyz,ev,buf:new Float64Array(3*n),turns,txyz:V.packXYZ(turns.map(t=>t.xyz)),tbuf:new Float64Array(3*turns.length),
    baseC:ring(u=>at(u,0)),fibC:ring(v=>at(0,v)),samples:c.steps<=128?c.steps:0,pc:PC,au,evl,pts};
  if(RLGEO.size>24)RLGEO.clear();RLGEO.set(key,g);return g;
}
const RL_RULE_TEXT={30:'F(x) = x ⊕ ((x≪1) ∨ (x≪2))',90:'F(x) = x ⊕ (x≪2)',150:'F(x) = x ⊕ (x≪1) ⊕ (x≪2)'};
const RL_PSI_TEXT={30:'ψ_j = x_{j−1} ∨ x_{j−2}',90:'ψ_j = x_{j−2}',150:'ψ_j = x_{j−1} ⊕ x_{j−2}'};
const RL_LIFT='Declared lift rule (D1): within a base step t → t+1 the base angle advances by 2π/per_j; if ψ_j(t) = 1 the fibre advances monotonically forward by 2π/q across that same step, linearly in the step parameter; otherwise the fibre is constant. The fibre never goes backwards and never takes the short way round: the drawn curve is the lift of N_j, not its shadow mod 2.';
const RL_ABOUT='Rule 30 ladder-monodromy card D1 (v0.4.16, SCHEMA_ADDENDUM_23). The idea of writing Rule 30 on surfaces is saphir’s; the exact facts F1–F3 come from the rule30 track and its kit. T-function on the seed x(0) = 1; bit j of x(t) is the right diagonal A(j, t); new bit j is x_j ⊕ ψ_j; N_j(t) = #{s < t : ψ_j(s) = 1}; F1: A(j, t) = (A(j, 0) + N_j(t)) mod 2. Row j is drawn on one torus leaf (the Clifford torus, ρ = 1) with base angle 2π·t/per_j, where per_j is the cycle of the rows below j (mod 2^j), and fibre angle 2π·N_j(t)/q. It is drawn from t = 0 to t = k·per_j, k = q/gcd(q, S_j), S_j = N_j(per_j): the first return of the lifted curve. With q = 2 the curve closes after two turns exactly when S_j is odd, which is exactly per_{j+1} = 2·per_j (lift_iff). '+RL_LIFT+' Colours: cyan = base steps without an event, amber = event steps (the fibre advances), violet = the fibre circle at base angle 0 and the returns to it after each whole base cycle. Not claimed: D1 displays F2 and F3; it is not evidence about the centre column, and nothing here concerns Problems 1 or 2.';
function rlItems(vs){
  const on=vs.rl==='1',items=[{id:'rladder',label:on?'▦ Rule 30 ladder (D1)':'○ Rule 30 ladder (D1)',pressed:on,menu:'layers',title:'D1: Rule 30 ladder-monodromy card (one torus leaf; replaces the comb picture while on)',sw:[RLC,RLE]}];
  if(!on)return items;
  const d=rlDial(vs);
  items.push({id:'rl_rule',label:'rule',menu:'layers',select:RL.RULES.map(r=>['rlr'+r,String(r)]),value:'rlr'+d.rule});
  items.push({id:'rlj_dn',label:'◀ j',menu:'layers',title:'row j − 1'});
  items.push({id:'rl_j',label:'row',menu:'layers',select:Array.from({length:RL.J_MAX+1},(_,j)=>{const c=RL.card(d.rule,j,2);return ['rlj'+j,'j = '+j+(c.doubling?' · doubling':' · stall')];}),value:'rlj'+d.j});
  items.push({id:'rlj_up',label:'j ▶',menu:'layers',title:'row j + 1'});
  items.push({id:'rl_q',label:'lift q',menu:'layers',select:RL.QS.map(q=>['rlq'+q,String(q)]),value:'rlq'+d.q});
  return items;
}
function rlAct(id,vs){
  if(id==='rladder')return {vs:{rl:vs.rl==='1'?'0':'1'}};
  let m=/^rlr(30|90|150)$/.exec(id);if(m)return {vs:{rlr:m[1]}};
  m=/^rlq(1|2|4|8)$/.exec(id);if(m)return {vs:{rlq:m[1]}};
  m=/^rlj(\d+)$/.exec(id);if(m&&Number(m[1])<=RL.J_MAX)return {vs:{rlj:String(Number(m[1]))}};
  if(id==='rlj_dn'||id==='rlj_up'){const j=rlDial(vs).j,n=Math.min(RL.J_MAX,Math.max(0,j+(id==='rlj_up'?1:-1)));return {vs:{rlj:String(n)}};}
  return null;
}
function rlRender(svg,M,vs,ctx){
  const P=V.palette(),d=rlDial(vs),g=rlGeometry(d.rule,d.j,d.q),c=g.c,cd=g.cd;let o='';
  o+='<rect x="0" y="0" width="'+W+'" height="'+H+'" fill="none" data-role="bg"/>';
  const az=V.num(vs.ca,-0.65),el=V.num(vs.ce,0.45),guide=M.meshGuide;
  let ext=EXT.get(guide);if(ext===undefined){ext=0;for(const row of guide)for(const p of row)if(p)ext=Math.max(ext,Math.hypot(p[0],p[1],p[2]));EXT.set(guide,ext);}
  const fit=(Math.min(W,H)-48)/(2*ext)*V.num(vs.cz,0.95),cx=W/2+V.num(vs.cx,0),cy=H/2+V.num(vs.cy,0),cm=V.camMat(az,el),lod=!!V.layer.preview||!!V.layer.moving;
  if(vs.cl==='1')o+=drawMesh(ctx,pack(guide,lod?2:1),cm,fit,cx,cy,'34,211,238',0.03,0.14,0.7,'r30-leaf');
  const ringLine=(r,col,w,role,dash)=>{V.projectInto(r.xyz,r.n,cm,fit,cx,cy,r.buf);const pts=[];for(let i=0;i<r.n;i++)pts.push([r.buf[3*i],r.buf[3*i+1]]);return V.cvLine(pts,col,w,role,undefined,dash);};
  o+=ringLine(g.baseC,'rgba(184,192,212,0.55)',1.2,'r30-base-circle',[5,5]);
  o+=ringLine(g.fibC,RLT,1.6,'r30-fibre-circle',[3,4]);
  // the lifted curve: event steps amber, other steps cyan (one stroke per colour)
  V.projectInto(g.xyz,g.n,cm,fit,cx,cy,g.buf);const B=g.buf;let nev=0,nbase=0;
  for(const [flag,col,w] of [[0,RLC,2],[1,RLE,2.6]]){if(ctx){ctx.beginPath();ctx.setLineDash([]);}
    for(let i=0;i+1<g.n;i++){if(g.ev[i]!==flag)continue;if(flag)nev++;else nbase++;if(ctx){ctx.moveTo(B[3*i],B[3*i+1]);ctx.lineTo(B[3*i+3],B[3*i+4]);}}
    if(ctx){ctx.strokeStyle=col;ctx.lineWidth=w;ctx.lineCap='round';ctx.stroke();ctx.lineCap='butt';}}
  {const pts=[];for(let i=0;i<g.n;i++)pts.push([B[3*i],B[3*i+1]]);V.layer.runs.push({role:'r30-curve',c:null,stroke:RLC,width:2,pts});}
  o+='<g data-role="r30-curve" data-layer="canvas" data-rule="'+d.rule+'" data-j="'+d.j+'" data-q="'+d.q+'" data-per="'+c.per+'" data-s="'+c.S+'" data-k="'+c.k+'" data-steps="'+c.steps+'" data-sub="'+c.sub+'" data-n="'+g.n+'" data-event-segments="'+nev+'" data-base-segments="'+nbase+'" data-end-base="'+g.pts[g.n-1].base.join('/')+'" data-end-fibre="'+g.pts[g.n-1].fibre.join('/')+'"'
    // v0.4.19: the event-step pieces (exact audit by host-core/d1-event-pieces.js) and the exact fibre values of the first and last event steps
    +' data-event-steps="'+g.pc.evSteps+'" data-event-parts="'+g.pc.e+'" data-event-need="'+g.pc.need+'" data-event-pieces-min="'+g.au.pmin+'" data-event-pieces-max="'+g.au.pmax+'" data-event-forward="'+g.au.forward+'" data-event-not-forward="'+g.au.notForward+'" data-event-base-forward="'+g.au.baseForward+'"'
    +(g.evl.length?' data-event-first="'+g.evl[0]+':'+root.FVD1Pieces.stepFibres(g.pc,g.evl[0]).join(',')+'" data-event-last="'+g.evl[g.evl.length-1]+':'+root.FVD1Pieces.stepFibres(g.pc,g.evl[g.evl.length-1]).join(',')+'"':'')+'></g>';
  // sample points at integer t (only when there are at most 128 steps)
  if(g.samples){let ns=0;for(let s=0;s<c.steps;s++){const i=g.pc.starts[s],x=B[3*i],y=B[3*i+1];o+=V.cvDot(x,y,2.6,g.ev[i]?RLE:RLC,1,'#0c0c18',0.8,'r30-sample',undefined,String(g.pts[i].t));ns++;}
    o+='<g data-role="r30-samples" data-n="'+ns+'"></g>';}
  // returns to base angle 0 after each whole base cycle (the monodromy): i*S_j/q turns on the fibre circle
  V.projectInto(g.txyz,g.turns.length,cm,fit,cx,cy,g.tbuf);
  g.turns.forEach((t,i)=>{const x=g.tbuf[3*i],y=g.tbuf[3*i+1],end=i===0||i===c.k;
    o+=V.cvDot(x,y,end?6.2:5,end?'#ffffff':P.bgDeep,1,RLT,2,'r30-turn',undefined,String(i));
    if(i<c.k&&(i===0||t.fibre[0]%t.fibre[1]!==0))o+=V.text(x+8,y-8,i===0?'t = 0':'turn '+i,'fill="'+RLT+'" data-role="r30-turn-label"');});
  o+='<g data-role="r30-turns" data-n="'+g.turns.length+'" data-k="'+c.k+'"></g>';
  // captions: the exact label, the monodromy, the degenerate cases, the dial refusals
  for(const b of d.bad)V.cap('D1 dial refused: '+b,P.defend,'degenerate');
  V.cap(cd.label,P.z1,'r30-label');
  V.cap((cd.odd?'monodromy nontrivial':'trivial (stall)')+' · S_'+d.j+' = '+cd.S+' is '+(cd.odd?'odd':'even')+', so per_'+(d.j+1)+' = '+(cd.odd?'2·per_'+d.j+' = ':'per_'+d.j+' = ')+cd.perNext+' · base cycle per_'+d.j+' = '+cd.per+' (cycle of the rows below j, mod 2^'+d.j+')',cd.odd?P.good:P.warn,'r30-monodromy');
  for(const x of cd.degenerate)V.cap(x.kind==='q1'?x.label+': the sampled fibre N_j(t)/1 is 0 mod 1 at every t; the declared lift still draws each event as one full forward fibre loop (2π/q = 2π)':x.label,P.warn,'degenerate');
  if(d.q===1&&cd.S===0){}   // both labels already present
  V.abt(RL_ABOUT);
  V.abt('Exact: '+cd.label+'. per_'+d.j+' = '+cd.per+', S_'+d.j+' = '+cd.S+', k = '+d.q+'/gcd('+d.q+', '+cd.S+') = '+cd.k+', '+c.steps+' base steps drawn (each cut into '+c.sub+' parts'+(g.pc.e!==c.sub?'; each event step into '+g.pc.e+' pieces, at least '+g.pc.need+', with exact rational fibre values (v0.4.19)':'')+'), fibre total k·S_j/q = '+cd.fibreTotal.join('/')+' turn(s). Angles are converted to floats only here, at the canvas; the stereographic projection is numerical.');
  svg.innerHTML=o;
}
function rlCard(vs){
  if(vs.rl!=='1')return null;
  const d=rlDial(vs),cd=RL.card(d.rule,d.j,d.q),T=RL.table(d.rule),j=d.j,p=cd.per,E=V.esc;
  const a0=j===0?1:0;let f1=true;for(let t=0;t<T.P;t++)if(RL.A(d.rule,j,t)!==(a0+RL.N(d.rule,j,t))%2){f1=false;break;}
  const fr=(n,dd)=>{const g=RL.gcd(n,dd)||1;return dd/g===1?String(n/g):(n/g)+'/'+(dd/g);};
  const rets=[];for(let i=0;i<cd.k;i++)rets.push('i = '+i+': '+fr((i*cd.S)%d.q,d.q));
  const L=Math.min(cd.perNext,16),rows=[];for(let t=0;t<L;t++)rows.push('<tr data-role="r30-row" data-t="'+t+'"><td>'+t+'</td><td>'+RL.A(d.rule,j,t)+'</td><td>'+RL.psi(d.rule,j,t)+'</td><td>'+RL.N(d.rule,j,t)+'</td></tr>');
  const body='<div class="kv"><span>rule (T-function on x(0) = 1)</span><b data-role="r30-rule">rule '+d.rule+': '+E(RL_RULE_TEXT[d.rule])+'</b>'
    +'<span>row j (A(j, t) = bit j of x(t))</span><b data-role="r30-j">j = '+j+'</b>'
    +'<span>events</span><b>'+E(RL_PSI_TEXT[d.rule])+' (negative index: 0); N_j(t) = #{s < t : ψ_j(s) = 1}</b>'
    +'<span>base cycle per_j (cycle of the rows below j, mod 2^j)</span><b data-role="r30-per">per_'+j+' = '+p+'</b>'
    +'<span>S_j = N_j(per_j) (exact)</span><b data-role="r30-S">S_'+j+' = '+cd.S+' ('+(cd.odd?'odd':'even')+')</b>'
    +'<span>per_{j+1}</span><b data-role="r30-pernext">'+cd.perNext+(cd.doubling?' = 2·per_'+j+' (doubling)':' = per_'+j+' (stall)')+'</b>'
    +'<span>monodromy</span><b data-role="r30-mono">'+(cd.odd?'monodromy nontrivial':'trivial (stall)')+'</b>'
    +'<span>lift dial q</span><b data-role="r30-q">q = '+d.q+(d.q===1?' (fibre constant (q = 1))':d.q===2?' (the flat bit)':' (next 2-adic digits of N)')+'</b>'
    +'<span>first return k = q/gcd(q, S_j)</span><b data-role="r30-k">k = '+cd.k+' turn'+(cd.k===1?'':'s')+'</b>'
    +'<span>fibre at base angle 0 after i base cycles (turns mod 1, exact)</span><b data-role="r30-returns">'+rets.join(' · ')+'</b>'
    +'<span>density of row j over per_{j+1}</span><b data-role="r30-density">'+fr(cd.density[0],cd.density[1])+'</b>'
    +'<span>F1: A(j,t) = (A(j,0) + N_j(t)) mod 2</span><b data-role="r30-f1">'+(f1?'holds for every t < per_35 = '+T.P+' (checked now, exact)':'FAILS (report this)')+'</b>'
    +'<span>doubling set j ≤ '+RL.J_MAX+' (rule '+d.rule+')</span><b data-role="r30-doublings">'+RL.doublingSet(d.rule).join(', ')+'</b></div>'
    +'<p class="note" data-role="r30-label-card">'+E(cd.label)+'</p>'
    +cd.degenerate.map(x=>'<p class="warn" data-role="r30-degenerate" data-kind="'+x.kind+'">'+E(x.label)+'</p>').join('')
    +'<div class="panel-sub">t, A(j, t), ψ_j(t), N_j(t) for t < '+L+(cd.perNext>16?' (of per_{j+1} = '+cd.perNext+')':'')+'</div><div class="scroll"><table class="ph" data-role="r30-table"><thead><tr><th>t</th><th>A(j,t)</th><th>ψ_j(t)</th><th>N_j(t)</th></tr></thead><tbody>'+rows.join('')+'</tbody></table></div>'
    +'<p class="note" data-role="r30-lift">'+E(RL_LIFT)+'</p>'
    +'<p class="note dim" data-role="r30-claim">Not claimed: D1 displays F2 and F3 (the monodromy of the lifted rows); it is not evidence about the centre column, and nothing here concerns Problems 1 or 2.</p>'
    +'<p class="note dim" data-role="r30-seealso"><a href="#" data-pen-goto="pens">See also: the surface pens (Panels tab, group E), written by the same Rule 30 sign stream</a> (v0.4.18).</p>';   // v0.4.18: the only change to D1
  return {title:'Rule 30 ladder (D1)',body,about:RL_ABOUT};
}
const view={
  id:'clifford',label:'Clifford',W,H,defaults:DEF,canvas:true,d1Card:rlCard,
  toolbar(vs,M){if(vs.rl==='1')return [{id:'zin',label:'+',menu:'strip'},{id:'zout',label:'−',menu:'strip'},{id:'reset',label:'⟲',menu:'strip',title:'reset camera, zoom and pan'},{id:'full',label:'⛶',menu:'strip',title:'full view'},
      ...rlItems(vs),{id:'leaf',label:'Tρ leaf',pressed:vs.cl==='1',menu:'layers',sw:['#22d3ee']},
      {id:'cam',label:'Camera',menu:'camera',select:[['','view…'],['top','Top'],['xp','Side X+'],['xm','Side X−'],['yp','Side Y+'],['ym','Side Y−'],['isotop','ISO TOP'],['isoside','ISO SIDE']],value:''},
      {id:'pan',label:'✥ pan',pressed:vs.cp==='1',title:'pan: one-finger drag pans instead of rotating',menu:'camera'}];   // v0.4.16 D1 on: the comb layers do not apply; the D1 dials take their place
    return [
    {id:'zin',label:'+',menu:'strip'},{id:'zout',label:'−',menu:'strip'},{id:'reset',label:'⟲',menu:'strip',title:'reset camera, zoom and pan'},{id:'full',label:'⛶',menu:'strip',title:'full view'},
    {id:'leaf',label:'Tρ leaf',pressed:vs.cl==='1',menu:'layers',sw:['#22d3ee']},{id:'orb',label:'s-orbits',pressed:vs.co==='1',menu:'layers',sw:['#00e5ff','#ff5e6c','#10b981']},{id:'grid',label:'Grid',pressed:vs.cg==='1',menu:'layers',sw:['#b8c0d4']},
    {id:'guides',label:'Guides',menu:'layers',select:[['g_none','none'],['g_four','four circles']],value:vs.c4==='1'?'g_four':'g_none',sw:vs.c4==='1'?['#38bdf8','#34d399','#fbbf24','#f472b6']:[]},
    {id:'frac',label:vs.cf==='1'?'⅟ Fraction stack':'○ Fraction stack',pressed:vs.cf==='1',menu:'layers',sw:['#f59e0b','#e0faff']},
    {id:'cstack',label:vs.cs==='1'?'✦ Full stack':'○ Full stack',pressed:vs.cs==='1',menu:'layers',title:'the full stack lifted to S³: every integer s and φ₃ in 0 … B+1, each on its own leaf ρ_N (display only)',sw:['#00e5ff','#ff5e6c']},...(vs.cs==='1'?[root.FVStackView.opacItem(vs),root.FVStackView.RECIP_ITEM(vs,'cr')]:[]),
    {id:'mirror',label:'Mirror axis',pressed:vs.cm==='1',menu:'layers',sw:[MIR]},
    {id:'fol',label:'Carrier foliation',pressed:vs.cff==='1',menu:'layers',sw:[FOLSEL]},...rlItems(vs),
    {id:'fol_k',label:'foliation leaves',menu:'layers',adv:true,select:[['fk6','6'],['fk12','12'],['fk24','24'],['fk120','120']],value:'fk'+vs.cfk},
    {id:'fb_m10',label:'◀◀ β',menu:'layers',adv:true,title:'selected β − π/12'},{id:'fb_m1',label:'◀ β',menu:'layers',adv:true,title:'selected β − π/120'},
    {id:'fb_p1',label:'β ▶',menu:'layers',adv:true,title:'selected β + π/120'},{id:'fb_p10',label:'β ▶▶',menu:'layers',adv:true,title:'selected β + π/12'},
    {id:'cam',label:'Camera',menu:'camera',select:[['','view…'],['top','Top'],['xp','Side X+'],['xm','Side X−'],['yp','Side Y+'],['ym','Side Y−'],['isotop','ISO TOP'],['isoside','ISO SIDE']],value:''},
    {id:'pan',label:'✥ pan',pressed:vs.cp==='1',title:'pan: one-finger drag pans instead of rotating',menu:'camera'}];},
  act(id,vs){
    {const r=rlAct(id,vs);if(r)return r;}   // v0.4.16 D1 dials
    const z=V.num(vs.cz,0.95),cam=(a,e)=>({vs:{ca:String(a),ce:String(e)}});
    if(id==='g_none')return {vs:{c4:'0'}};if(id==='g_four')return {vs:{c4:'1'}};
    if(id==='top')return cam(V.num(vs.ca,0),EL);if(id==='xp')return cam(Math.PI/2,0);if(id==='xm')return cam(-Math.PI/2,0);if(id==='yp')return cam(0,0);if(id==='ym')return cam(Math.PI,0);
    if(id==='isotop')return cam(-0.65,1.0);if(id==='isoside')return cam(-0.65,0.25);
    if(id==='zin')return {vs:{cz:String(V.clamp(z*1.1,0.25,8))}};if(id==='zout')return {vs:{cz:String(V.clamp(z/1.1,0.25,8))}};
    if(id==='reset')return {vs:{cz:'0.95',ca:'-0.65',ce:'0.45',cx:'0',cy:'0'}};
    const tg=(k)=>({vs:{[k]:vs[k]==='1'?'0':'1'}});
    if(id==='pan')return tg('cp');if(id==='leaf')return tg('cl');if(id==='orb')return tg('co');if(id==='grid')return tg('cg');if(id==='four')return tg('c4');if(id==='frac')return tg('cf');if(id==='mirror')return tg('cm');if(id==='fol')return tg('cff');if(id==='cstack')return tg('cs');if(id==='sopac')return {vs:{so:root.FVStackView.opacNext(vs)}};if(id==='recip')return {vs:{cr:vs.cr==='1'?'0':'1'}};
    if(/^fk(6|12|24|120)$/.test(id))return {vs:{cfk:id.slice(2)}};
    {const st={fb_m10:-10,fb_m1:-1,fb_p1:1,fb_p10:10}[id];if(st!==undefined){const k=((Math.round(V.num(vs.cfb,0))+st)%240+240)%240;return {vs:{cfb:String(k)}};}}
    return {};
  },
  gesture(kind,arg,vs){
    if(kind==='drag'){
      if(arg.shift||arg.pan||vs.cp==='1')return {vs:{cx:String(V.num(vs.cx,0)+arg.dx),cy:String(V.num(vs.cy,0)+arg.dy)}};
      return {vs:{ca:String(V.num(vs.ca,-0.65)+0.008*arg.dx),ce:String(V.clamp(V.num(vs.ce,0.45)+0.008*arg.dy,-EL,EL))}};}
    if(kind==='wheel'||kind==='pinch'){const f=kind==='wheel'?(arg>0?1.1:0.9):arg;return {vs:{cz:String(V.clamp(V.num(vs.cz,0.95)*f,0.25,8))}};}
    return {};
  },
  render(svg,M,vs,ui,cvs){
    const P=V.palette(),m=M.R.m;let o='';
    svg.setAttribute('viewBox','0 0 '+W+' '+H);
    const ctx=V.layerBegin(cvs,W,H),pv=!!V.layer.preview,lod=pv||!!V.layer.moving;      // heavy geometry goes to the canvas under the SVG; the SVG keeps labels, hit proxies and data-attribute elements
    if(vs.rl==='1')return rlRender(svg,M,vs,ctx);   // v0.4.16 D1: the Rule 30 ladder card replaces the comb picture while on (the comb state is kept, not drawn)
    o+='<rect x="0" y="0" width="'+W+'" height="'+H+'" fill="none" data-role="bg"/>';
    if(vs.cs==='1'&&(M.rd.empty||M.num.refused))V.cap('✦ full stack not drawn: the current state has no comb to frame it (N = 0 or refused); move φ₃',P.warn,'degenerate');   // v0.4.9
    if(M.rd.empty){o+=V.text(W/2,H/2,'N = 0: no S³ lift is defined (empty state, drawn and labelled).','text-anchor="middle" fill="'+P.warn+'" data-role="degenerate"');svg.innerHTML=o;return;}
    const num=M.num;
    if(num.refused){o+=V.text(W/2,H/2,num.refused,'text-anchor="middle" fill="'+P.defend+'" data-role="degenerate"');svg.innerHTML=o;return;}
    const GBm=M.gb||null,gbKept=GBm?new Set(GBm.teeth.filter(t=>t.kept).map(t=>t.c)):null;   // v0.4.14: the Goldbach prime-pair mask (null with the track off)
    const az=V.num(vs.ca,-0.65),el=V.num(vs.ce,0.45),rho=num.rho,a=rho/Math.sqrt(1+rho*rho),b=1/Math.sqrt(1+rho*rho);
    const mir=vs.cm==='1'?M.mirror:null;   // v0.4: mirror geometry (lazy, cached on the exact state); null when the layer is off
    const fol=vs.cff==='1'?M.foliation:null;   // v0.4.1: carrier foliation geometry (lazy); null when the layer is off
    const guide=M.meshGuide,leaf=M.meshLeaf(rho),G=geometry(M,num,guide,leaf,mir,fol);     // typed-array geometry, rebuilt only when the exact state changes (never for a camera move)
    let ext=G.ext;if(!(ext>0))ext=1;
    const fit=(Math.min(W,H)-48)/(2*ext)*V.num(vs.cz,0.95),cx=W/2+V.num(vs.cx,0),cy=H/2+V.num(vs.cy,0),cm=V.camMat(az,el);
    const prj=p=>{const r=V.rot(p,az,el);return [cx+fit*r[0],cy-fit*r[1],r[2]];};     // small point sets only (rho = 0 axis, four circles, fraction stack)
    // meshes (canvas): segments bucketed by depth into 6 alpha levels (one stroke per bucket); the reduced register (slider preview, camera in motion) draws every 2nd grid line
    if(vs.cg==='1')o+=drawMesh(ctx,pack(guide,lod?2:1),cm,fit,cx,cy,'184,192,212',0.02,0.09,0.55,'guide');
    if(vs.cl==='1'&&rho>0)o+=drawMesh(ctx,pack(leaf,lod?2:1),cm,fit,cx,cy,'34,211,238',0.04,0.21,0.78,'leaf');
    // rho = 0: the leaf is the circle z1 = 0; it passes through the projection pole x4 = +1, so its stereographic image is the x3 axis (a line through the origin, closed at infinity)
    if(rho===0){const Lx=1e4,a0=prj([0,0,-Lx]),a1=prj([0,0,Lx]);
      o+=V.line(a0[0],a0[1],a1[0],a1[1],'stroke="#22d3ee" stroke-width="2" data-role="rho0-axis"');}
    // four circles on the leaf (builder's reading: see README)
    if(vs.c4==='1'){[['meridian','#38bdf8',2.4],['parallel','#34d399',2.4],['hopf','#fbbf24',2.7],['opposite','#f472b6',2.7]].forEach(([k,col,w])=>{
      o+=V.poly(N_.circle3(a,b,k,[0.3,0.7]).map(p=>p?prj(p):[0,0]).filter(p=>p),'stroke="'+col+'" stroke-width="'+w+'" data-role="circle-'+k+'"');});
      V.abt('Four circles on the leaf: meridian, parallel, Hopf, opposite (one reading of these curves; colours and widths follow the host).');}
    // v0.4 mirror axis (R1): the fixed set of c -> -c on the leaf, beta = 0 solid and beta = pi dashed. Display objects: no branch, no head, no export field.
    if(G.mir){for(const l of G.mir.lon){V.projectInto(l.xyz,l.n,cm,fit,cx,cy,l.buf);const pts=[];for(let i=0;i<l.n;i++)pts.push([l.buf[3*i],l.buf[3*i+1]]);
        if(rho>0){o+=V.cvLine(pts,MIR,3.2,'mirror-longitude',undefined,l.beta?[7,5]:null).replace('data-role="mirror-longitude"','data-role="mirror-longitude" data-beta="'+(l.beta?'pi':'0')+'"');
          let j=0;for(let i=1;i<l.n;i++)if(l.buf[3*i]>l.buf[3*j])j=i;
          o+=V.text(l.buf[3*j]+6,l.buf[3*j+1]+(l.beta?14:-6),l.beta?'β = π':'β = 0','fill="'+MIR+'" data-role="mirror-label"');}
        }
      if(M.mirror&&M.mirror.collapsed)o+=V.text(10,44,'ρ = 0: collapsed leaf; no reference longitudes and no same-time events are drawn.','fill="'+P.warn+'" data-role="degenerate"');}
    // v0.4.1 carrier foliation (display register; design: merged viewer v0.8.8-fix.5): the longitudes (a e^{i theta}, b e^{i beta}) of the carrier action's orbit
    // foliation, K of them at beta = 2 pi j/K (faint), the selected beta (white, solid) and beta + pi (white, dashed). No branch, no head, no export field.
    if(fol&&fol.collapsed)o+=V.text(10,30,'collapsed leaf (ρ = 0): the carrier foliation is not drawn.','fill="'+P.warn+'" data-role="degenerate"');
    if(G.fol){const g=G.fol,ctx3=V.layer.ctx;
      const curve=(c,col,w,role,dash,rec)=>{V.projectInto(c.xyz,c.n,cm,fit,cx,cy,c.buf);
        if(c.n===1){const x=c.buf[0],y=c.buf[1];if(ctx3){ctx3.globalAlpha=1;ctx3.setLineDash([]);ctx3.beginPath();ctx3.arc(x,y,role==='foliation'?2.2:4,0,6.283185307179586);ctx3.fillStyle=col;ctx3.fill();}
          V.layer.marks.push({role:role+'-point',beta:root.FVExact.text(c.beta),x,y,xyz:[c.xyz[0],c.xyz[1],c.xyz[2]]});return '';}
        const pts=[];for(let i=0;i<c.n;i++)pts.push([c.buf[3*i],c.buf[3*i+1]]);const s=V.cvLine(pts,col,w,role,undefined,dash);V.layer.runs[V.layer.runs.length-1].beta=root.FVExact.text(c.beta);
        return rec?s.replace('data-role="'+role+'"','data-role="'+role+'" data-beta="'+root.FVExact.text(c.beta)+'"'):'';};
      for(const c of g.fam)curve(c,g.stationary?'rgba(226,232,240,0.75)':'rgba(226,232,240,0.30)',1,'foliation',null,false);   // t1 = 0: the points are drawn brighter than the faint curves
      o+='<g data-role="foliation" data-n="'+g.fam.length+'"></g>';
      o+=curve(g.comp,FOLSEL,2,'foliation-companion',[6,5],true)+curve(g.sel,FOLSEL,2.4,'foliation-selected',null,true);
      if(!g.stationary){let j=0;const b=g.sel.buf;for(let i=1;i<g.sel.n;i++)if(b[3*i+1]<b[3*j+1])j=i;o+=V.text(b[3*j]+6,b[3*j+1]-6,'β = '+fol.F.betaText,'fill="'+FOLSEL+'" data-role="foliation-label"');}
      if(g.stationary)o+=V.text(10,30,'t₁ = 0: the carrier is stationary; each orbit of the carrier action is a point (the foliation is drawn as points).','fill="'+P.warn+'" data-role="degenerate"');
      V.abt('Carrier foliation (v0.4.1; design from the merged viewer v0.8.8-fix.5): the orbit foliation of the carrier action (λz₁, z₂) on the leaf, the longitudes (a·e^{iθ}, b·e^{iβ}), θ ∈ [0, 2π), one per transverse phase β. '+fol.F.K+' leaves at β = 2πj/'+fol.F.K+'; selected β = '+fol.F.betaText+' (white) and β + π = '+fol.F.companionText+' (white, dashed). β = 0 and β = π are the mirror’s fixed longitudes. A raw gcd d > 1 changes traversal multiplicity only; it does not quotient the transverse β-circle. Display register only: no branch, no head, no export field.');}
    // v0.4.9 full stack lifted (SCHEMA_ADDENDUM_17): each point on its own leaf rho_N, stereographic as the tooth dots; canvas dots batched per tooth colour (host radius 1.25)
    if(vs.cs==='1'){const RCL=vs.cr==='1',SL=RCL?M.stackLiftHalf:M.stackLift,SP=M.stack,SV=root.FVStackView;let sb=SBUF.get(SL);if(!sb){sb=new Float64Array(3*SL.n);SBUF.set(SL,sb);}
      V.projectInto(SL.xyz,SL.n,cm,fit,cx,cy,sb);const offs=SP.offsets,bv=V.branchVis(vs.ch);let drawn=0;
      if(ctx){ctx.setLineDash([]);ctx.globalAlpha=1;for(const c of offs){if(!bv(c))continue;ctx.fillStyle=V.toothRgba(c,m,SV.opacOf(vs));
        for(let j=0;j<SL.n;j++){if(SL.c[j]!==c||!SL.ok[j])continue;ctx.fillRect(sb[3*j]-1.6,sb[3*j+1]-1.6,3.2,3.2);drawn++;}}}   // squares (fillRect), as the Fourier stack
      else for(let j=0;j<SL.n;j++)if(SL.ok[j]&&bv(SL.c[j]))drawn++;
      o+='<g data-role="full-stack" data-layer="canvas" data-n="'+SL.n+'" data-raw="'+SL.raw+'" data-drawn="'+drawn+'" data-bad="'+SL.bad+'" data-levels="'+SL.levels+'" data-key="'+V.esc(SP.key)+'"></g>';
      V.cap(SV.stackCaption(SP,M.R,' · lifted '+SV.nf(SL.n)+(SL.thinned?'/'+SV.nf(SL.raw)+' (budget 12,000 − m, host selection)':'')+' · '+SL.levels+' ρ-levels'+(SL.bad?' · '+SL.bad+' at the projection pole (not finite, not drawn'+(SL.atInfinity?'; '+SL.atInfinity+' exactly at ∞':'')+')':'')),P.mid,'stack-caption');
      V.abt(SV.STACK_ABOUT+' Clifford: each stack point is lifted on its own leaf ρ_N = |n₆|·N^α (z₁ = a·e^{iπ(t₁s+f)}, z₂ = b·e^{−iπc·t₂s/N}, a = ρ_N/√(1+ρ_N²), b = 1/√(1+ρ_N²)) and projected from x₄ = +1 like the tooth dots; for integer t₁·s the cloud is the page arg z₁ ∈ {0, π}. At most 12,000 − m points (the host head budget less the current teeth), selected ⌊i(L−1)/(max−1)⌋; hidden branches hide their stack points.');V.abt(SV.OPAC_ABOUT);
      if(RCL){const SR=M.stackLiftR;let sr=SBUFR.get(SR);if(!sr){sr=new Float64Array(3*SR.n);SBUFR.set(SR,sr);}   // v0.4.11: leaf 1/rho_N, amplitudes swapped, phases kept; the two halves share the head budget
        V.projectInto(SR.xyz,SR.n,cm,fit,cx,cy,sr);let drawnR=0;
        if(ctx){ctx.setLineDash([]);ctx.globalAlpha=1;for(const c of offs){if(!bv(c))continue;ctx.fillStyle=V.toothRgba(c,m,SV.opacOf(vs));
          for(let j=0;j<SR.n;j++){if(SR.c[j]!==c||!SR.ok[j])continue;ctx.fillRect(sr[3*j]-1.6,sr[3*j+1]-1.6,3.2,3.2);drawnR++;}}}
        else for(let j=0;j<SR.n;j++)if(SR.ok[j]&&bv(SR.c[j]))drawnR++;
        o+='<g data-role="reciprocal" data-layer="canvas" data-n="'+SR.n+'" data-raw="'+SR.raw+'" data-drawn="'+drawnR+'" data-bad="'+SR.bad+'" data-undef="'+SR.undef+'" data-levels="'+SR.levels+'" data-half="'+SL.n+'"></g>';
        V.cap(SV.recipCaption(SP,M.R,{undef:SR.undef},' · lifted on leaf 1/ρ_N (amplitudes swapped, phases kept) · the two halves share the head budget 12,000 − m: '+SV.nf(SL.n)+' + '+SV.nf(SR.n)+' of '+SV.nf(SR.raw)+' each'+(SR.thinned?' (thinned, host selection)':' (not thinned)')+(SR.bad?' · '+SR.bad+' of the reciprocal half at the projection pole (clipped, not drawn)':'')),P.mid,'recip-caption');
        V.abt(SV.RECIP_ABOUT+' Clifford: this is not an isometric copy; ρ ↦ 1/ρ with phases kept swaps the two circle lengths, so the two leaves are congruent only at ρ = 1 (the reciprocal leaves ρ = 1/N pinch onto the vertical axis and run off toward infinity).');}}
    // fraction stack (addendum 3): generated points, display only
    if(vs.cf==='1'){
      if(M.fracIdle)V.cap(M.fracCaption,P.warn,'fraction-warning');
      else{o+='<g data-role="fraction-stack">';for(const h of M.fracPts){if(!h.p)continue;const q=prj(h.p);
        o+='<circle cx="'+V.f2(q[0])+'" cy="'+V.f2(q[1])+'" r="'+(h.zero?2.2:1.6)+'" fill="'+(h.zero?'#e0faff':V.rgba(P.spine,0.55))+'"/>';}
        o+='</g>';V.cap(M.fracCaption,P.spine,'fraction-caption');V.abt(M.fracAbout);}}
    // s-orbits (canvas; the cached 3D points are only rotated and projected). One SVG proxy per branch orbit: data-role / data-c / data-branch / data-t at the orbit's bounding box.
    // The reduced register strokes every k-th point of a long orbit.
    let partialN=0;const vis=V.branchVis(vs.ch);
    if(vs.co==='1')G.orbs.forEach(ob=>{if(!vis(ob.c))return;const sel=ui.sel!==null&&Number(ui.sel)===Number(ob.c);
      const gh=!!GBm&&!GBm.teeth[ob.t].kept,orole=gh?'orbit-ghost':'orbit';   // ghosted: removed by the prime filter
      const col=V.toothRgba(ob.c,m,gh?0.13:sel?1:0.9),wd=gh?0.8:sel?2.8:1.6,k=lod?Math.max(1,Math.ceil(ob.total/500)):1;
      let bb=null;
      for(const r0 of ob.runs){const r=V.lodOf(r0,k);V.projectInto(r.xyz,r.n,cm,fit,cx,cy,r.buf);const run=V.cvRun(r.buf,0,r.n-1,1,col,wd,orole,ob.c);
        if(run){const q=run.bb;bb=bb?[Math.min(bb[0],q[0]),Math.min(bb[1],q[1]),Math.max(bb[2],q[2]),Math.max(bb[3],q[3])]:q.slice();}}
      o+=V.orbitProxy(orole,ob.c,ob.t,col,bb,ob.total);
      if(ob.partial)partialN++;});
    if(vs.co==='1'&&partialN)o+=V.text(10,72,'partial orbit: '+partialN+' orbit(s) need more than 4,000 points at 2° steps; a 4,000-point window centred on the current s is drawn','fill="'+P.warn+'" data-role="degenerate"');
    // v0.4 mirror axis (R2, review §5): same-time tip coincidences of each pair +-c (they lie on the reference longitudes; image intersections are not marked); filled on beta = 0, hollow on beta = pi. Drawn on the canvas;
    // each is recorded in FVViews.layerMarks() with its 3D point (role mirror-crossing); one SVG group carries the count. A pair is marked when both its branches are shown.
    if(G.mir){const g=G.mir,ctx2=V.layer.ctx;V.projectInto(g.xyz,g.ms.length,cm,fit,cx,cy,g.buf);let nm=0;
      g.ms.forEach((q,i)=>{if(!vis(q.c)||!vis(-q.c))return;if(gbKept&&!gbKept.has(Number(q.c)))return;const x=g.buf[3*i],y=g.buf[3*i+1];nm++;
        if(ctx2){ctx2.globalAlpha=1;ctx2.setLineDash([]);ctx2.beginPath();ctx2.arc(x,y,5.2,0,6.283185307179586);ctx2.fillStyle=q.beta?P.bgDeep:MIR;ctx2.fill();ctx2.lineWidth=1.8;ctx2.strokeStyle=q.beta?MIR:P.bgDeep;ctx2.stroke();}
        V.layer.marks.push({role:'mirror-crossing',c:String(q.c),pair:String(q.c),k:String(q.k),s:q.s,beta:q.beta,x,y,r:5.2,xyz:[q.p[0],q.p[1],q.p[2]]});});
      o+='<g data-role="mirror-crossings" data-n="'+nm+'"></g>';}
    // tooth dots on the canvas, depth sorted (the SVG gets a transparent proxy at the same position, plus the hit target)
    const dd=G.dots,vd=[];for(let i=0;i<dd.c.length;i++)if(vis(dd.c[i]))vd.push(i);
    V.projectInto(dd.xyz,dd.c.length,cm,fit,cx,cy,dd.buf);
    vd.sort((x,y)=>(dd.ok[x]?dd.buf[3*x+2]:-9)-(dd.ok[y]?dd.buf[3*y+2]:-9));
    let bad=0;
    for(const i of vd){if(!dd.ok[i]){bad++;continue;}const c=dd.c[i],sel=ui.sel!==null&&Number(ui.sel)===Number(c),col=V.toothHex(c,m),x=dd.buf[3*i],y=dd.buf[3*i+1];
      o+=GBm&&!GBm.teeth[i].kept?V.cvDot(x,y,2.8,col,0.28,null,0,'tooth-dot-ghost',c,i):V.cvDot(x,y,sel?6.5:4.2,col,1,sel?'#fff':null,1.4,'tooth-dot',c,i);
      o+=V.circle(x,y,11,'fill="transparent" data-role="hit" data-c="'+c+'"');}
    // overlays
    V.abt('Orbit branches (Layers menu, Advanced): tap a chip to show or hide that branch; long-press or shift-click isolates it; All / None toggles every branch. Hidden branches hide the s-orbit and the tooth dot.');
    V.abt('Clifford torus: the S³ lift (z₁, z₂) of each tooth, stereographic projection from the north pole x₄ = +1 with (x₁,x₂,x₃,x₄) = (Re z₁, Im z₁, Re z₂, Im z₂). Clifford reference surface · guide only (|z₁| = |z₂| = 1/√2).');
    if(M.R&&M.R.tilt&&M.R.tilt.n!==0n)V.abt('α_Tilt does not apply here: it weights the walk, and the S³ lift has no walk, so this view does not depend on α_Tilt.');
    V.cap('ρ '+rho.toExponential(2)+' (numerical) · '+(vd.length-bad)+' of '+vd.length+' points drawn · '+(bad?bad+' not finite':'ok')+(mir?' · mirror axis β = 0, π: '+mir.parity.label:''),P.z1,'line');
    if(GBm){V.cap('Goldbach prime-pair mask · N = '+GBm.N+' · all '+GBm.m+' branches share one leaf ρ = 1 (the balanced Clifford torus): the '+GBm.kept+' masked branches c = ±a_p/t₂ are drawn solid (raw winding (N/2, ∓a_p), primitive ×1; a_p = 1 is an unknot), the '+GBm.removed+' removed ones are ghosted — '+GB.GHOST_LABEL,P.good,'gb-caption');
      V.abt('Goldbach prime-pair mask (v0.4.14, track "Goldbach N ▸"): the pen is the kernel’s G_N(s) = Σ over P_N of (e^{2πips/N} + e^{2πi(N−p)s/N}) = e^{iπs}·R_N(s) (Cor II.23.5c), because the mask is a walk weight: w_c = 1 on the teeth with N/2 ± c·t₂ both prime, w = 2 on the c = 0 tooth (the equal pair p = N/2, counted twice in G_N), w = 0 elsewhere. Teeth removed by the prime filter are drawn ghosted and do not enter the pen; the tooth rays shown are the unweighted z_c, and the walk step of the c = 0 tooth is 2·z₀. ALIGN / SPREAD and the K_m kernel describe the unmasked comb. '+GB.GUARDS.closure+' The prime filter is the only input that does not come from the Fourier construction. '+GB.PRIOR_ART);}
    if(mir){V.abt('Mirror axis (v0.4, from saphir’s observations; feature note by Claude Fable 5.1): the comb’s mirror c ↦ −c is z₂ ↦ z̄₂ on the leaf. Its fixed set is the two reference longitudes arg z₂ = 0 (β = 0, solid: the carrier orbit, z₂ = b) and arg z₂ = π (β = π, dashed). '+mir.parity.readout+'. Label: '+mir.parity.label+'. “Pants” and “line” are a display mnemonic for this reflection picture, not a proof of a pair-of-pants surface or of the Seifert base topology; no Y is drawn. The longitudes are drawn whether or not a tooth traverses them; they are display objects: no comb branch, no head, no export field.');
      V.abt('Same-time tip coincidences per common period: teeth c and −c share z₁, so at the same s they coincide exactly where c·t₂·s/N is an integer k: s_k = k·N/|c·t₂|, 0 ≤ k < M, M = P·|c·t₂|/N with P = lcm(2/|t₁|, 2N/|c·t₂|), on β = 0 for even k (filled marks) and on β = π for odd k (hollow marks). This is not the number of intersections of the two orbit images: with primitive windings (p, q) and (p, −q) the images meet in 2|p·q| points (image intersections, a separate count in the Layers menu; N = 5, t₁ = t₂ = 1, c = ±1: 2 same-time events, 10 image intersections). Only the same-time events lie on the reference longitudes, and only they are marked. c·t₂ = 0: the two trajectories coincide continuously (no isolated events). t₁ = 0: both images are the same transverse circle.');
      if(mir.capped)o+=V.text(10,86,'same-time events: more than '+mir.cap+' in the drawn windows; the first '+mir.cap+' are marked (exact counts in the Layers menu)','fill="'+P.warn+'" data-role="degenerate"');}
    V.abt('Leaf ρ = '+rho.toExponential(3)+' · main radius √(1+ρ²)/ρ = '+(rho>0?(Math.sqrt(1+rho*rho)/rho).toPrecision(5):'∞')+', tube radius 1/ρ = '+(rho>0?(1/rho).toPrecision(5):'∞')+' (numerical).');
    if(bad)o+=V.text(10,58,bad+' tooth point(s) AT_INFINITY or CLIPPED_NEAR_POLE: not drawn as finite points (labelled, not hidden)','fill="'+P.warn+'" data-role="degenerate"');
    if(rho===0)o+=V.text(W/2,H-8,'ρ = 0: the leaf collapses to the circle z₁ = 0; it passes through the projection pole, so its image is the x₃ axis (a line through the origin, closed at ∞), drawn as that axis.','text-anchor="middle" fill="'+P.warn+'" data-role="degenerate"');
    {const st0=M.orbits.filter(x=>x.stationary).map(x=>x.c);if(st0.length)V.cap('stationary: c = '+st0.join(', ')+' (no orbit)',P.warn,'degenerate');
     const bf=M.orbits.filter(x=>x.baseFixed&&!x.stationary).map(x=>x.c);if(bf.length)V.cap('base fixed: c = '+bf.join(', ')+' (k_c = 0; orbit runs along the Hopf fiber)',P.warn,'degenerate');}
    svg.innerHTML=o;
  }
};
V.register(view);
})(typeof globalThis!=='undefined'?globalThis:this);
