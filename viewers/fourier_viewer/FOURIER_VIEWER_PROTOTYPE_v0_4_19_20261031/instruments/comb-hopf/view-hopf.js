(function(root){
'use strict';
// Hopf tab: the Hopf base S2 = CP1 (host HopfBaseDisplayV1 / renderHopfBase), with the comb walk. DRAWING register.
// Performance round 2: every curve (grid, latitude, tooth trails, walk), the walk vertices and the tooth dots are packed ONCE per exact-state change into Float64Arrays;
// a camera change only rotates and projects them and strokes the canvas.
const V=root.FVViews,GB=root.FVGoldbach,N_=root.FVCombNumeric,W=640,H=480;
const WALK=new WeakMap(),DEF={hz:'1',ha:'-0.72',ht:'0.24',hl:'1',hs:'0',hf:'0',hr:'0'};   // v0.4.9: hs full stack, hf fraction stack (default off)
const HS=new WeakMap(),HR=new WeakMap();   // v0.4.9: packed Hopf image of the full stack per (stack, chart scale)
const line3=(list,extra)=>{const xyz=V.packXYZ(list),n=list.length;return Object.assign({xyz,n,buf:new Float64Array(3*n),sbuf:null},extra||{});};
// constant geometry: 7 latitudes and 12 longitudes of the sphere grid
let GRID=null;
function gridLines(){
  if(GRID)return GRID;GRID=[];
  for(const z of [0,0.25,-0.25,0.5,-0.5,0.75,-0.75]){const r=Math.sqrt(1-z*z),pts=[];for(let i=0;i<=72;i++){const a=2*Math.PI*i/72;pts.push([r*Math.cos(a),r*Math.sin(a),z]);}
    GRID.push(line3(pts,{front:z===0?'rgba(148,163,184,0.48)':'rgba(148,163,184,0.28)',back:'rgba(100,116,139,0.12)',w:z===0?1.15:0.8}));}
  for(let k=0;k<12;k++){const a=Math.PI*k/6,pts=[];for(let i=0;i<=48;i++){const ph=-Math.PI/2+Math.PI*i/48;pts.push([Math.cos(ph)*Math.cos(a),Math.cos(ph)*Math.sin(a),Math.sin(ph)]);}
    GRID.push(line3(pts,{front:'rgba(148,163,184,0.28)',back:'rgba(100,116,139,0.12)',w:0.8}));}
  return GRID;
}
// geometry cache: valid while the numerical model and the orbit sample are the same objects (they change only with the exact state)
let GEO=null;
function geometry(M,num){
  const orbs=M.orbits;
  if(GEO&&GEO.num===num&&GEO.src===orbs)return GEO;
  const L=num.lat,rl=Math.sqrt(Math.max(0,1-L*L)),lp=[];for(let i=0;i<=96;i++){const a=2*Math.PI*i/96;lp.push([rl*Math.cos(a),rl*Math.sin(a),L]);}
  const trails=[];orbs.forEach((ob,t)=>{if(ob.stationary||!ob.s2.length)return;trails.push({c:ob.c,t,partial:!!ob.partial,ln:line3(ob.s2.map(w=>N_.hopf(w,num.scale)))});});
  let wc=WALK.get(num);                                  // memoised on the numerical model (a new one is built only when the exact state changes), not on the camera
  if(!wc){let cur=[];wc=[];
    for(let t=0;t<num.W.length-1;t++){if(num.mask&&!num.mask.w[t])continue;for(const p of N_.edgeCurve(num.W[t],num.W[t+1],num.scale)){if(p)cur.push(p);else{if(cur.length>1)wc.push(cur);cur=[];}}}
    if(cur.length>1)wc.push(cur);WALK.set(num,wc);}
  const dots={c:num.z.map(z=>z.c),ln:line3(num.z.map(z=>N_.hopf(z,num.scale)))};
  GEO={num,src:orbs,lat:line3(lp),trails,walk:wc.map(ch=>line3(ch)),verts:line3(num.H),dots};
  return GEO;
}
const view={
  id:'hopf',label:'Hopf base',W,H,defaults:DEF,canvas:true,
  toolbar(vs,M){return [
    {id:'zin',label:'+',menu:'strip'},{id:'zout',label:'−',menu:'strip'},{id:'reset',label:'⟲',menu:'strip',title:'reset camera and zoom'},{id:'full',label:'⛶',menu:'strip',title:'full view'},
    {id:'trails',label:'Tooth trails',pressed:vs.hl!=='0',menu:'layers'},
    {id:'hstack',label:vs.hs==='1'?'✦ Full stack':'○ Full stack',pressed:vs.hs==='1',menu:'layers',title:'the full stack on the Hopf base: each stack tooth through the chart (display only)',sw:['#00e5ff','#ff5e6c']},...(vs.hs==='1'?[root.FVStackView.opacItem(vs),root.FVStackView.RECIP_ITEM(vs,'hr')]:[]),{id:'hfrac',label:vs.hf==='1'?'⅟ Fraction stack':'○ Fraction stack',pressed:vs.hf==='1',menu:'layers',title:'current shell on the fraction lattice s = j/q (certified exact spins only)',sw:['#f59e0b','#e0faff']},
    {id:'from',label:'View from',menu:'camera',select:[['','view from…'],['q1+','q₁+'],['q1-','q₁−'],['q2+','q₂+'],['q2-','q₂−'],['q3+','q₃+'],['q3-','q₃−']],value:''},
    {id:'chart',label:M&&M.st.chart==='comb'?'chart w = W/ρ (comb page)':'chart w = W (host)',pressed:M&&M.st.chart==='comb',title:'Advanced: chart toggle',menu:'layers',adv:true}];},
  act(id,vs,M){
    const z=V.num(vs.hz,1),hp=Math.PI/2;
    const set=(a,t)=>({vs:{ha:String(a),ht:String(t)}});
    if(id==='q1+')return set(Math.PI/2,0);if(id==='q1-')return set(-Math.PI/2,0);if(id==='q2+')return set(0,0);if(id==='q2-')return set(Math.PI,0);
    if(id==='q3+')return set(V.num(vs.ha,0),hp);if(id==='q3-')return set(V.num(vs.ha,0),-hp);
    if(id==='zin')return {vs:{hz:String(V.clamp(z*1.1,0.65,1.45))}};if(id==='zout')return {vs:{hz:String(V.clamp(z/1.1,0.65,1.45))}};
    if(id==='reset')return {vs:{hz:'1',ha:'-0.72',ht:'0.24'}};
    if(id==='trails')return {vs:{hl:vs.hl==='0'?'1':'0'}};
    if(id==='hstack')return {vs:{hs:vs.hs==='1'?'0':'1'}};if(id==='sopac')return {vs:{so:root.FVStackView.opacNext(vs)}};if(id==='recip')return {vs:{hr:vs.hr==='1'?'0':'1'}};if(id==='hfrac')return {vs:{hf:vs.hf==='1'?'0':'1'}};
    if(id==='chart')return {st:{chart:M.st.chart==='comb'?'host':'comb'}};
    return {};
  },
  gesture(kind,arg,vs){
    if(kind==='drag')return {vs:{ha:String(V.num(vs.ha,-0.72)+0.008*arg.dx),ht:String(V.clamp(V.num(vs.ht,0.24)-0.008*arg.dy,-Math.PI/2,Math.PI/2))}};
    if(kind==='wheel'||kind==='pinch'){const f=kind==='wheel'?(arg>0?1.08:1/1.08):arg;return {vs:{hz:String(V.clamp(V.num(vs.hz,1)*f,0.65,1.45))}};}
    return {};
  },
  render(svg,M,vs,ui,cvs){
    const P=V.palette();let o='';
    svg.setAttribute('viewBox','0 0 '+W+' '+H);
    const ctx=V.layerBegin(cvs,W,H),lod=!!V.layer.preview||!!V.layer.moving;     // canvas under the SVG: background, sphere disc, grid, latitude, trails, walk curves, vertices and tooth dots
    o+='<rect x="0" y="0" width="'+W+'" height="'+H+'" fill="none" data-role="bg"/>';
    if(vs.hs==='1'&&(M.rd.empty||M.num.refused))V.cap('✦ full stack not drawn: the current state has no comb to frame it (N = 0 or refused); move φ₃',P.warn,'degenerate');   // v0.4.9
    if(M.rd.empty){o+=V.text(W/2,H/2,'N = 0: no walk and no lift are defined (empty state, drawn and labelled).','text-anchor="middle" fill="'+P.warn+'" data-role="degenerate"');svg.innerHTML=o;return;}
    const num=M.num;
    if(num.refused){o+=V.text(W/2,H/2,num.refused,'text-anchor="middle" fill="'+P.defend+'" data-role="degenerate"');svg.innerHTML=o;return;}
    const az=V.num(vs.ha,-0.72),tl=V.num(vs.ht,0.24),R0=Math.min(W,H)*0.385*V.num(vs.hz,1),cx=W/2,cy=H/2+3,cm=V.camMat(az,tl),G=geometry(M,num);
    const prj=p=>{const r=V.rot(p,az,tl);return [cx+R0*r[0],cy-R0*r[1],r[2]];};     // small point sets only (axes)
    if(ctx){const R2=2*R0,g=ctx.createRadialGradient(cx-R0+0.38*R2,cy-R0+0.32*R2,0,cx-R0+0.38*R2,cy-R0+0.32*R2,0.75*R2);   // the old SVG radial gradient, same stops
      g.addColorStop(0,'rgba(226,232,240,0.22)');g.addColorStop(0.55,'rgba(71,85,105,0.17)');g.addColorStop(1,'rgba(15,23,42,0.52)');
      ctx.fillStyle=g;ctx.beginPath();ctx.arc(cx,cy,R0,0,2*Math.PI);ctx.fill();}
    o+=V.circle(cx,cy,R0,'fill="none" stroke="rgba(203,213,225,0.58)" stroke-width="1.4" data-role="sphere"');
    // draw one packed curve: project, split into front / back runs (depth >= 0 is front; the run boundary point belongs to both), stroke each run on the canvas.
    // Returns the bounding box of the drawn points. The reduced register strokes every k-th point of a long curve.
    const draw=(ln,front,back,w,role,c,record)=>{
      const L=V.lodOf(ln,lod&&ln.n>400?Math.ceil(ln.n/300):1),buf=L.buf,n=L.n;     // the reduced register projects and strokes only every k-th point
      V.projectInto(L.xyz,n,cm,R0,cx,cy,buf);
      let bb=null;const emit=(a,b,fr)=>{const r=V.cvRun(buf,a,b,1,fr?front:back,w,role,c,record);if(r){const q=r.bb;bb=bb?[Math.min(bb[0],q[0]),Math.min(bb[1],q[1]),Math.max(bb[2],q[2]),Math.max(bb[3],q[3])]:q.slice();}};
      let s=0,cf=buf[2]>=0;for(let i=1;i<n;i++){const f=buf[3*i+2]>=0;if(f!==cf){emit(s,i,cf);s=i;cf=f;}}emit(s,n-1,cf);
      return bb;};
    // grid: 7 latitudes, 12 longitudes (constant geometry, packed once)
    gridLines().forEach((ln,i)=>draw(ln,ln.front,ln.back,ln.w,i===0?'equator':'grid',undefined,false));
    // axes
    [[1,0,0,'q₁'],[0,1,0,'q₂'],[0,0,1,'q₃']].forEach(a=>{const e=prj([a[0]*1.2,a[1]*1.2,a[2]*1.2]),s=prj([-a[0]*1.2,-a[1]*1.2,-a[2]*1.2]);
      o+=V.line(s[0],s[1],e[0],e[1],'stroke="rgba(165,180,252,0.48)" stroke-width="1" data-role="axis"')+V.text(e[0]+3,e[1]-3,a[3],'fill="rgba(165,180,252,0.8)"');});
    const nP=prj([0,0,1.08]),sP=prj([0,0,-1.08]);
    o+=V.text(nP[0]+4,nP[1],'N · w=∞','fill="'+P.mid+'"')+V.text(sP[0]+4,sP[1]+10,'S · w=0','fill="'+P.mid+'"');
    // v0.4.9 full stack on the Hopf base (SCHEMA_ADDENDUM_17): w = z_c/scale through fromAffine, front dots brighter than back ones, batched per tooth colour
    if(vs.hs==='1'){const SP=M.stack,SV=root.FVStackView,sc0=num.scale;let byS=HS.get(SP);if(!byS){byS=new Map();HS.set(SP,byS);}
      let pk=byS.get(sc0);if(!pk){const n=SP.n,xyz=new Float64Array(3*n);for(let i=0;i<n;i++){const p=N_.hopf({re:SP.xy[2*i],im:SP.xy[2*i+1]},sc0);xyz[3*i]=p[0];xyz[3*i+1]=p[1];xyz[3*i+2]=p[2];}pk={n,xyz,buf:new Float64Array(3*n)};byS.set(sc0,pk);}
      V.projectInto(pk.xyz,pk.n,cm,R0,cx,cy,pk.buf);const mm=SP.m;
      if(ctx){ctx.setLineDash([]);ctx.globalAlpha=1;for(const back of [true,false])for(let t=0;t<mm;t++){ctx.fillStyle=V.toothRgba(SP.offsets[t],mm,SV.opacOf(vs)*(back?0.4:1));
        for(let i=t;i<pk.n;i+=mm){const z=pk.buf[3*i+2];if((z<0)!==back)continue;ctx.fillRect(pk.buf[3*i]-1.6,pk.buf[3*i+1]-1.6,3.2,3.2);}}}   // squares (fillRect): a path of tens of thousands of arcs is far too slow to fill
      o+='<g data-role="full-stack" data-layer="canvas" data-n="'+pk.n+'" data-key="'+V.esc(SP.key)+'" data-chart="'+M.st.chart+'"></g>';
      V.cap(SV.stackCaption(SP,M.R,M.st.chart==='comb'?' · comb chart: every stack point divided by the current ρ':' · host chart: each point’s exact Hopf base image')+(SP.lattice.thinned?' · thinned: integer s, φ₃ are skipped, and pixel resolution does not certify labels at large N':''),P.mid,'stack-caption');
      V.abt(SV.STACK_ABOUT+' Hopf base: each stack tooth z_c through the chart in use and fromAffine; in the host chart (w = W) this is the Hopf base point of the point’s own S³ lift (chart agreement); in the comb chart (w = W/ρ) every stack point is divided by the CURRENT ρ, not by its own ρ_N. The host chart is H(w) = (2 Re w, 2 Im w, |w|² − 1)/(1 + |w|²), with the chordal identity |H(w) − H(v)| = 2|w − v|/(√(1+|w|²)√(1+|v|²)): near the north pole neighbouring shells N, N+1 of a fixed layer are only about 2/N² apart on the sphere (STACK_LABEL_RESOLUTION v0.11, another session’s note, not externally reviewed). '+(SP.lattice.thinned?'This stack is thinned (every '+SP.lattice.step+'-th s and φ₃): thinning drops integer indices, and a fixed screen-pixel resolution is not a certificate for labels at arbitrarily large N.':'No thinning at this shell.')+'');V.abt(SV.OPAC_ABOUT);
      if(vs.hr==='1'){const RC=M.stackR;let byR=HR.get(RC);if(!byR){byR=new Map();HR.set(RC,byR);}   // v0.4.11: w -> 1/conj(w); comb chart: z' = sc^2 z/|z|^2 (the reflection of the drawn image)
        let pr=byR.get(sc0);if(!pr){const n=SP.n,xyz=new Float64Array(3*n);for(let i=0;i<n;i++){const x=RC.xy[2*i],y=RC.xy[2*i+1];if(x!==x){xyz[3*i]=xyz[3*i+1]=xyz[3*i+2]=NaN;continue;}const p=N_.hopf({re:sc0*sc0*x,im:sc0*sc0*y},sc0);xyz[3*i]=p[0];xyz[3*i+1]=p[1];xyz[3*i+2]=p[2];}pr={n,xyz,buf:new Float64Array(3*n)};byR.set(sc0,pr);}
        V.projectInto(pr.xyz,pr.n,cm,R0,cx,cy,pr.buf);
        if(ctx){ctx.setLineDash([]);ctx.globalAlpha=1;for(const back of [true,false])for(let t=0;t<mm;t++){ctx.fillStyle=V.toothRgba(SP.offsets[t],mm,SV.opacOf(vs)*(back?0.4:1));
          for(let i=t;i<pr.n;i+=mm){const z=pr.buf[3*i+2];if(z!==z||(z<0)!==back)continue;ctx.fillRect(pr.buf[3*i]-1.6,pr.buf[3*i+1]-1.6,3.2,3.2);}}}
        o+='<g data-role="reciprocal" data-layer="canvas" data-n="'+(pr.n-RC.undef)+'" data-undef="'+RC.undef+'" data-chart="'+M.st.chart+'"></g>';
        V.cap(SV.recipCaption(SP,M.R,RC,M.st.chart==='comb'?' · comb chart: the reflection through the equator plane of the drawn image, i.e. the image of ρ_cur²/z̄ (not of 1/z̄)':' · host chart: the exact reflection (x, y, −z) of each point’s Hopf base image, the equator |w| = 1 is the throat')+' · label separation transfers unchanged (reflection is an isometry)',P.mid,'recip-caption');V.abt(SV.RECIP_ABOUT);}}
    if(vs.hf==='1'){if(M.fpIdle)V.cap(M.fpCaption,P.warn,'fraction-warning');
      else{for(const h of M.fpPts){const p=N_.hopf({re:h.re,im:h.im},num.scale),q=prj(p);if(ctx){ctx.globalAlpha=q[2]>=0?1:0.4;ctx.fillStyle=h.zero?'#e0faff':'rgba(245,158,11,0.85)';ctx.beginPath();ctx.arc(q[0],q[1],h.zero?2.4:1.8,0,6.283185307179586);ctx.fill();ctx.globalAlpha=1;}}
        o+='<g data-role="fraction-stack" data-layer="canvas" data-n="'+M.fpPts.length+'"></g>';V.cap(M.fpCaption+' · on the current latitude',P.spine,'fraction-caption');V.abt(root.FVStackView.FRAC_ABOUT.replace('on the current radius circle |z| = |ρ|','on the current latitude (|w| fixed)'));}}
    // current latitude circle (amber)
    draw(G.lat,'rgba(251,191,36,0.74)','rgba(251,191,36,0.3)',1.8,'latitude',undefined,false);
    // tooth trails: one SVG proxy per branch trail (bounding box, data-role / data-c / data-branch / data-t)
    const m=M.R.m,GBm=M.gb||null;   // v0.4.14: the Goldbach prime-pair mask (null with the track off)
    let partialN=0;if(vs.hl!=='0')G.trails.forEach(tr=>{if(tr.partial)partialN++;const sel=ui.sel!==null&&Number(ui.sel)===Number(tr.c);
      const gh=!!GBm&&!GBm.teeth[tr.t].kept,trole=gh?'trail-ghost':'trail';
      const col=V.toothRgba(tr.c,m,gh?0.1:sel?0.98:0.72),bb=draw(tr.ln,col,V.toothRgba(tr.c,m,gh?0.04:0.25),gh?0.8:sel?3:1.55,trole,tr.c,true);
      o+=V.orbitProxy(trole,tr.c,tr.t,col,bb,tr.ln.n);});
    if(partialN)o+=V.text(10,72,'partial orbit: '+partialN+' trail(s) need more than 4,000 points at 2° steps; a 4,000-point window centred on the current s is drawn','fill="'+P.warn+'" data-role="degenerate"');
    // comb walk (partial sums): each planar edge W_{t-1} -> W_t is sampled (>= 32 intervals, bisected until consecutive sphere points are <= 2 degrees apart)
    // and mapped through fromAffine, so it is drawn as the true curve on S2; the polyline is broken near the north pole (w -> infinity), never joined across it
    G.walk.forEach((ln,i)=>{const bb=draw(ln,P.spine,'rgba(245,158,11,0.3)',1.6,'walk',undefined,true);
      if(bb)o+='<rect x="'+V.f2(bb[0])+'" y="'+V.f2(bb[1])+'" width="'+V.f2(bb[2]-bb[0])+'" height="'+V.f2(bb[3]-bb[1])+'" fill="none" stroke="'+P.spine+'" stroke-opacity="0" pointer-events="none" data-role="walk" data-t="'+i+'" data-n="'+ln.n+'" data-layer="canvas"/>';});
    // walk vertices W_t (vertex t >= 1 is the end of the step of tooth t-1, so it carries that tooth's c; vertex 0 is the start and has no tooth)
    V.projectInto(G.verts.xyz,G.verts.n,cm,R0,cx,cy,G.verts.buf);
    for(let t=0;t<G.verts.n;t++){if(GBm&&t>0&&!GBm.teeth[t-1].kept)continue;const x=G.verts.buf[3*t],y=G.verts.buf[3*t+1],z=G.verts.buf[3*t+2],c=t>0&&t-1<G.dots.c.length?G.dots.c[t-1]:undefined;
      o+=V.cvDot(x,y,t===0?3:1.8,P.spine,z>=0?1:0.4,null,0,'vertex',c,t);}
    // tooth dots
    V.projectInto(G.dots.ln.xyz,G.dots.ln.n,cm,R0,cx,cy,G.dots.ln.buf);
    for(let i=0;i<G.dots.c.length;i++){const c=G.dots.c[i],sel=ui.sel!==null&&Number(ui.sel)===Number(c),col=V.toothHex(c,m),b=G.dots.ln.buf,x=b[3*i],y=b[3*i+1],z=b[3*i+2];
      o+=GBm&&!GBm.teeth[i].kept?V.cvDot(x,y,2.8,col,z>=0?0.28:0.14,null,0,'tooth-dot-ghost',c,i):V.cvDot(x,y,sel?7.2:5.2,col,z>=0?0.98:0.48,sel?'#fff':null,1.4,'tooth-dot',c,i);
      if(sel)o+=V.circle(x,y,11,'fill="none" stroke="#fff" stroke-dasharray="3,3" data-role="selection"')+V.text(x+12,y-8,'c = '+(Number(c)>0?'+':'')+c,'fill="#fff"');
      o+=V.circle(x,y,11,'fill="transparent" data-role="hit" data-c="'+c+'"');}
    // overlays
    const gate=N_.gateFixtures().every(Boolean)&&num.chartCompat.ok;
    V.abt('Hopf base S² ≅ CP¹ · '+m+' current teeth. Map HOPF_BASE_S2_Z1_Z2_V1, chart CP1_AFFINE_Z1_OVER_Z2_V1 (w = z₁/z₂; north w = ∞, south w = 0). Chart agreement S³ lift vs plane tooth: max '+num.chartCompat.maxDiff.toExponential(1)+'.');
    V.cap('latitude q₃ '+num.lat.toFixed(4)+' (numerical)'+(ui.sel!==null?' · tooth c = '+(Number(ui.sel)>0?'+':'')+ui.sel:'')+' · same object',P.warn,'line');
    V.abt('ρ = '+num.rho.toExponential(3)+' (numerical).');
    if(GBm){V.cap('Goldbach prime-pair mask · N = '+GBm.N+' · the amber walk is the pen on the carrier page: G_N(s), '+GBm.kept+' of '+GBm.m+' teeth (weight 2 on c = 0 when N/2 is prime), '+GBm.removed+' ghosted — '+GB.GHOST_LABEL+' · no new claim',P.good,'gb-caption');
      V.abt('Goldbach prime-pair mask (v0.4.14, track "Goldbach N ▸"): the pen is the kernel’s G_N(s) = Σ over P_N of (e^{2πips/N} + e^{2πi(N−p)s/N}) = e^{iπs}·R_N(s) (Cor II.23.5c), because the mask is a walk weight: w_c = 1 on the teeth with N/2 ± c·t₂ both prime, w = 2 on the c = 0 tooth (the equal pair p = N/2, counted twice in G_N), w = 0 elsewhere. Teeth removed by the prime filter are drawn ghosted and do not enter the pen; the tooth rays shown are the unweighted z_c, and the walk step of the c = 0 tooth is 2·z₀. ALIGN / SPREAD and the K_m kernel describe the unmasked comb. '+GB.GUARDS.closure+' The prime filter is the only input that does not come from the Fourier construction. '+GB.PRIOR_ART);}
    if(num.tilt){V.cap('α_Tilt = '+root.FVExact.text(M.R.tilt)+': the amber walk is tilted (walk step t weighted t^α_Tilt; teeth unchanged)'+(num.tilt.exactWeights?'':' · weights numerical')+' · instrument-tier, no theorem standing',P.warn,'tilt');
      if(m===2)V.cap('m = 2, α_Tilt ≠ 0: W₂ = z₋₁ + 2^α_Tilt·z₊₁ is not the Vernier sum of II.5; the factorization still applies to the teeth',P.warn,'tilt-m2');
      V.abt('α_Tilt (v0.4.7): the walk curve and vertices follow W_t = W_{t−1} + t^α_Tilt·z_{c_t} (w₁ = 1, so W₁ = z_{c₁} still lies on the tooth latitude). Tooth dots, the latitude circle, trails and the chart-agreement check do not change. A kernel parameter (v3.2.7, notation w_k = k^{α_Tilt}) used here at instrument tier; the comb walk for m ≥ 3 is outside the kernel; no theorem standing.');}
    V.abt('Chart in use: '+(M.st.chart==='comb'?'comb-page w = W/ρ (scale B)':'host w = W (scale A)')+'. The amber curve is the comb walk (partial sums W_t), sampled in the plane and mapped.');
    if(ui.sel!==null){const i=num.z.findIndex(z=>Number(z.c)===Number(ui.sel));if(i>=0){const q=num.lift[i].s2,w=num.z[i];o+=V.text(10,58,'selection q = ('+q.map(x=>x.toFixed(5)).join(', ')+'); plane chart w = Z₁/Z₂ = '+w.re.toFixed(6)+(w.im<0?' − ':' + ')+Math.abs(w.im).toFixed(6)+'i','fill="'+P.mid+'"');}}
    if(num.rhoZero)o+=V.text(W/2,H-24,'ρ = 0: every vertex sits at the south pole (drawn, labelled).','text-anchor="middle" fill="'+P.warn+'" data-role="degenerate"');
    {const st0=M.orbits.filter(x=>x.stationary).map(x=>x.c);if(st0.length)V.cap('stationary: c = '+st0.join(', ')+' (no trail)',P.warn,'degenerate');
     const bf=M.orbits.filter(x=>x.baseFixed&&!x.stationary).map(x=>x.c);if(bf.length)V.cap('base fixed: c = '+bf.join(', ')+' (k_c = 0; the fiber moves — see Clifford)',P.warn,'degenerate');}
    if(gate)V.abt('G-HOPF-BASE-S2-01 PASS · each complete Hopf fibre maps to one base point · DISPLAY ONLY.');
    else{V.cap('Hopf gate FAILED — this display is not trustworthy.',P.defend,'gate-banner');o+=V.text(W/2,H-8,'GATE FAILED','text-anchor="middle" fill="'+P.defend+'" data-role="gate-banner"');}
    svg.innerHTML=o;
  }
};
V.register(view);
})(typeof globalThis!=='undefined'?globalThis:this);
