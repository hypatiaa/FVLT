(function(root){
'use strict';
// Panels-tab cards of v0.4.10 (SCHEMA_ADDENDUM_18): "Branch primitivity (trial division)" and "Poincaré disk · Farey layer and divisor orbit".
// Panel module rules (view-panels.js header): each card reads the shared model M and writes nothing. Both start collapsed (collapsed:true) and are display only:
// not in the state, the address, the exact export, the Lift JSON or the PNG export. Every verdict and readout comes from host-core/branch-disk-core.js (BigInt, exact).
// The disk canvas is the DRAWING register: arcs, fills and the tessellation are float64 and sampled; the canvas records its drawn geometry in cv.__bd for the browser check.
const V=root.FVViews,BD=root.FVBranchDisk,esc=V.esc,MINUS='−';
const sg=n=>(n<0n?MINUS:'')+(n<0n?-n:n);
const cache={prim:null,primKey:null,disk:null,diskKey:null};
function primFor(st){
  const k=JSON.stringify([st.shellMode,st.n1,st.B,st.nMode,st.phi3,st.t1,st.t2,st.m,st.n6]);
  if(cache.primKey!==k){let r;try{r=BD.primitivity(st);}catch(e){r={applies:false,reason:'refused state: '+e.message,rows:[]};}cache.prim=r;cache.primKey=k;}
  return cache.prim;
}
function diskFor(st){
  const k=JSON.stringify([st.shellMode,st.n1,st.B,st.nMode,st.phi3]);
  if(cache.diskKey!==k){let r;try{r=BD.disk(st);}catch(e){r={idle:true,reason:'refused state: '+e.message};}cache.disk=r;cache.diskKey=k;}
  return cache.disk;
}
const PAIR_BRANCH='These two cards show the same divisors of N two ways: here as winding repetition of the branches (g_c = gcd(N, c)); in the Poincaré disk card as orbit points on Farey edges.';
const PAIR_DISK='These two cards show the same divisors of N two ways: here as orbit points (n + i)/m on Farey edges; in the Branch primitivity card as winding repetition of the branches.';
// ---------------------------------------------------------------- card 1: branch primitivity
function renderBranch(el,M){
  const r=primFor(M.st);let h='<p class="note" data-role="bp-pair">'+esc(PAIR_BRANCH)+'</p>';
  if(!r.applies){
    h+='<p class="note warn" data-role="bp-nogo">no verdict: '+esc(r.reason)+'</p>';
    if(r.quadratic&&r.N)h+='<p class="note dim" data-role="bp-head">N = '+r.N+' = '+r.n+'² + 1 (the quadratic-shell case), ⌊√N⌋ = '+r.r+'.</p>';
  }else{
    const q=r.quadratic;
    h+='<p class="read" data-role="bp-head">'+(q?'<b>N = n² + 1 = '+r.N+', n = '+r.n+'</b> (quadratic shell)':'<b>N = '+r.N+'</b>, ⌊√N⌋ = '+r.r)+' · gears (1, 1) · comb(m) ⊇ {2, …, '+r.r+'}'+(q?'':' · N − 1 is not a square')+'</p>';
    h+='<p class="read" data-role="bp-count">'+(r.total===0?'the range c = 2…'+r.r+' is empty (N = 2 or 3)':'<b>'+r.primitiveCount+' of '+r.total+'</b> branches c = 2…'+r.r+' primitive (×1)')+'</p>';
    if(r.repeatedRows.length){
      h+='<p class="lbl">repeated branches ('+r.repeatedRows.length+')</p>';
      for(const x of r.repeatedRows.slice(0,BD.REPEAT_LINES))h+='<p class="mono" data-role="bp-rep">'+esc('gcd(N, '+x.c+') = '+x.g+' · '+x.chip)+'</p>';
      if(r.repeatedRows.length>BD.REPEAT_LINES)h+='<p class="note dim" data-role="bp-more">⋯ '+(r.repeatedRows.length-BD.REPEAT_LINES)+' more</p>';
    }
    h+='<p class="read" data-role="bp-verdict">'+(r.prime?'<b>N prime</b>: every branch c = 2…'+r.r+' is primitive':'<b>N composite</b>: branch c = '+r.least.c+' is repeated ×'+r.least.g+' (least such c)')+'</p>';
    h+='<p class="note" data-role="bp-label">trial division up to ⌊√N⌋ = '+r.r+', read off the branch windings at gears (1, 1). Equivalent form, checked here: '+(r.formNoUnknot?'no':'some')+' UNKNOT among c = 2…'+r.r+(r.formsAgree?' (agrees).':' (DISAGREES: report this).')+'</p>';
    h+='<p class="note" data-role="bp-unit">c = ±1: '+esc((r.unit.plus||'—')+(r.unit.minus?' ; '+r.unit.minus:''))+' — the same for every N, composite or not: a primitive unknot at c = ±1 says nothing about primality (the refuted criterion; N = 10 and 26 are examples).</p>';
    h+='<p class="note">The c = 0 branch repeats N = '+r.N+' times and −c mirrors c (same ×g, opposite sign).'+(r.n6zero?' <span class="warn" data-role="bp-n6">n₆ = 0: the first circle has collapsed, so ×g is a formal phase label, not a geometric covering count; the numbers are unchanged.</span>':'')+'</p>';
  }
  h+='<p class="note dim" data-role="bp-scope">Scope: trial division of N by c = 2…⌊√N⌋ shown as branch windings, exact integer arithmetic (BigInt gcd; no float). No prime-counting claim, no claim about infinitely many primes n² + 1 (Landau), no novelty claim. A finite readout limited to odd m ≤ 719 (n ≤ 359, N ≤ 128 882); it is not an execution of the unbounded family. At gears other than (1, 1) the multiplicity is g_c = gcd(L·N·t₁, L·c·t₂), no longer gcd(N, c), so no verdict is given there; even m has only odd offsets, so no verdict there either. Display only: not in the exact export. α and n₆ choose the leaf, not the windings. This is not the kernel contact rule (stops in s); branch repetition is a statement about the winding of branch c at fixed N.</p>';
  h+='<p class="note dim" data-role="bp-kernel">Kernel (FVLT v3.2.6, locked): Def II.23.9 (every branch c ∈ comb(m) is lifted with the same (N, t₁, t₂, α, n₆); raw pair (p, q)_c = (N·t₁, −c·t₂)); Lemma II.23.9a guard G3 (d = gcd(|p|, |q|), reduced type (p/d, q/d), the unparametrised image covered d times; unknot iff a reduced coordinate has magnitude ≤ 1). v3.2.7 (locked) erratum G4 = the Lemma II.23.9a G4 winding note: the unreduced k_c equals the rendered k_c/d iff d = 1 or k_c = 0; cited here as supporting the ×g reading. The equivalence “N prime iff g_c = 1 for c = 2…⌊√N⌋” is elementary trial division (re-proved in the design note); the source results (v0.13) are another session’s, not externally reviewed.</p>';
  el.innerHTML=h;
}
// ---------------------------------------------------------------- card 2: Poincare disk
const SIZE=480,PAD=30,RIM=SIZE/2-PAD,CX=SIZE/2,CY=SIZE/2;
let tess=null;
// Two-coloured modular tessellation (drawing): each Farey triangle is six (2,3,inf) triangles; the colour is the parity of the number of reflections of PGL(2,Z) that carry the pixel's
// half-plane point z = -2v/D + i(1-|zeta|^2)/D (D = |1-zeta|^2) into the fundamental triangle 0 <= Re z <= 1/2, |z| >= 1. Float64; the iteration cap is the depth cut-off.
function tessellation(){
  if(tess)return tess;
  const cv=document.createElement('canvas');cv.width=SIZE;cv.height=SIZE;const c=cv.getContext('2d'),img=c.createImageData(SIZE,SIZE),u32=new Uint32Array(img.data.buffer);
  const col=(r,g,b)=>(255<<24)|(b<<16)|(g<<8)|r,A=col(22,22,44),B=col(40,40,84),Z=col(14,14,26);
  for(let py=0;py<SIZE;py++)for(let px=0;px<SIZE;px++){
    const u=(px+0.5-CX)/RIM,v=-(py+0.5-CY)/RIM,n2=u*u+v*v;if(n2>=1)continue;
    const D=(1-u)*(1-u)+v*v;let x=-2*v/D,y=(1-n2)/D,par=0,it=0,done=false;
    for(;it<64;it++){x-=Math.round(x);if(x<0){x=-x;par^=1;}const r2=x*x+y*y;if(r2<1){x/=r2;y/=r2;par^=1;}else{done=true;break;}}
    u32[py*SIZE+px]=done&&n2<0.9985?(par?B:A):Z;
  }
  tess={img};return tess;
}
const toPx=(re,im)=>[CX+RIM*re,CY-RIM*im];
function draw(cv,D){
  const c=cv.getContext('2d'),rec={edges:[],cusps:[],ford:[],astra:[],mirror:true,R:RIM,cx:CX,cy:CY};
  c.setTransform(1,0,0,1,0,0);c.fillStyle='#08080f';c.fillRect(0,0,SIZE,SIZE);
  c.putImageData(tessellation().img,0,0);
  c.lineWidth=1.5;c.strokeStyle='#9a9ab8';c.beginPath();c.arc(CX,CY,RIM,0,2*Math.PI);c.stroke();
  // mirror m <-> k: the imaginary diameter (zeta -> -conj zeta)
  c.setLineDash([4,4]);c.strokeStyle='rgba(180,180,204,0.45)';c.lineWidth=1;c.beginPath();c.moveTo(CX,CY-RIM);c.lineTo(CX,CY+RIM);c.stroke();c.setLineDash([]);
  c.fillStyle='#b4b4cc';c.beginPath();c.arc(CX,CY,2.5,0,2*Math.PI);c.fill();c.font='13px ui-monospace,Consolas,monospace';c.fillText('i',CX+5,CY-5);
  if(!D||D.idle){c.fillStyle='#fbbf24';c.textAlign='center';c.fillText(D&&D.reason?D.reason:'idle',CX,CY+RIM*0.5);c.textAlign='start';cv.__bd=rec;return rec;}
  const arc=(a,b,c2,d)=>{ // geodesic between cusps a/b and c2/d (Farey pair): the circle of the exact data, the arc inside the unit disk
    const e=BD.edge(a,b,c2,d),p1=BD.cusp(a,b),p2=BD.cusp(c2,d),z1=[Number(p1.re)/Number(p1.den),Number(p1.im)/Number(p1.den)],z2=[Number(p2.re)/Number(p2.den),Number(p2.im)/Number(p2.den)];
    if(e.diameter){c.beginPath();c.moveTo(...toPx(...z1));c.lineTo(...toPx(...z2));c.stroke();rec.edges.push({diameter:true});return;}
    const cr=Number(e.cre)/Number(e.den),ci=Number(e.cim)/Number(e.den),r=1/Math.abs(Number(e.s)),a1=Math.atan2(z1[1]-ci,z1[0]-cr),a2=Math.atan2(z2[1]-ci,z2[0]-cr);
    let d2=a2-a1;while(d2>Math.PI)d2-=2*Math.PI;while(d2<=-Math.PI)d2+=2*Math.PI;
    // canvas y runs down: angles negate
    c.beginPath();c.arc(CX+RIM*cr,CY-RIM*ci,RIM*r,-a1,-a1-d2,d2>0);c.stroke();rec.edges.push({cx:cr,cy:ci,r});};
  // Ford horocycles at the cusps of the shell's Farey layer (drawing; exact radius 1/(p^2+q^2+1))
  c.lineWidth=1;c.strokeStyle='rgba(0,229,255,0.30)';
  for(const k of D.cusps){const r=1/Number(k.p*k.p+k.q*k.q+1n),zr=Number(k.re)/Number(k.den),zi=Number(k.im)/Number(k.den);c.beginPath();c.arc(CX+RIM*(1-r)*zr,CY-RIM*(1-r)*zi,RIM*r,0,2*Math.PI);c.stroke();rec.ford.push({cx:(1-r)*zr,cy:(1-r)*zi,r});}
  c.strokeStyle='#00e5ff';c.lineWidth=1.6;
  for(const x of D.edges){const a=D.F[x.i],b=D.F[x.j];arc(a[0],a[1],b[0],b[1]);}
  const lab=D.cusps.length<=16;
  D.cusps.forEach((k,i)=>{const zr=Number(k.re)/Number(k.den),zi=Number(k.im)/Number(k.den),[px,py]=toPx(zr,zi),iso=D.G.deg[i]===0;
    c.fillStyle=iso?'#ff5e6c':'#00e5ff';c.beginPath();c.arc(px,py,3.4,0,2*Math.PI);c.fill();
    if(iso){c.strokeStyle='#ff5e6c';c.lineWidth=1;c.beginPath();c.arc(px,py,6,0,2*Math.PI);c.stroke();}
    if(lab){c.fillStyle='#d4d4e8';c.textAlign=px<CX?'right':'left';c.fillText(k.p+'/'+k.q,px+(px<CX?-8:8),py+(py<CY?-6:14));c.textAlign='start';}
    rec.cusps.push({x:zr,y:zi,iso});});
  if(D.orbit&&D.orbit.square){
    c.strokeStyle='rgba(251,191,36,0.55)';c.lineWidth=1.2;
    for(const p of D.orbit.pts)if(p.edgeCusps)arc(p.edgeCusps[0][0],p.edgeCusps[0][1],p.edgeCusps[1][0],p.edgeCusps[1][1]);
    const labA=D.orbit.pts.length<=14;
    for(const p of D.orbit.pts){const zr=Number(p.re)/Number(p.den),zi=Number(p.im)/Number(p.den),[px,py]=toPx(zr,zi);
      c.fillStyle='#fbbf24';c.beginPath();c.arc(px,py,4.2,0,2*Math.PI);c.fill();c.strokeStyle='#08080f';c.lineWidth=1;c.stroke();
      if(labA){c.fillStyle='#fbbf24';c.fillText('m='+p.m,px+6,py-6);}
      rec.astra.push({m:String(p.m),x:zr,y:zi});}
  }
  cv.__bd=rec;return rec;
}
const mat=m=>m?'('+sg(m[0])+' '+sg(m[1])+'; '+sg(m[2])+' '+sg(m[3])+')':'(not searched: m above '+BD.MATRIX_CAP+')';
function renderDisk(el,M){
  const D=diskFor(M.st);let h='<p class="note" data-role="pd-pair">'+esc(PAIR_DISK)+'</p>';
  h+='<p class="note dim" data-role="pd-credit">The disk idea is saphir’s; the divisor-orbit construction z = (n + i)/m over m | n² + 1 is Astra’s written mathematics (the parametrisation is classical: Musicantov–Zehavi, arXiv:2112.07494, §1.2–1.3, as Astra cites).</p>';
  if(D.idle)h+='<p class="note warn" data-role="pd-idle">idle: '+esc(D.reason)+'</p>';
  else{
    const prof=D.prof.map(([p,e])=>p+(e>1n?'^'+e:'')).join(' · ')||'1';
    h+='<p class="read" data-role="pd-head"><b>N = '+D.N+'</b> = '+esc(prof)+' · orders n_i = '+(D.prof.map(([,e])=>e+1n).join(', ')||'—')+' · |F(a)| = '+D.F.length+' cusps, '+D.edges.length+' contact edges, '+D.G.isolated+' isolated bead'+(D.G.isolated===1?'':'s')+'</p>';
    if(D.farey&&D.farey.refused)h+='<p class="note warn">'+esc(D.farey.reason)+'</p>';
  }
  h+='<canvas class="pd-canvas" data-role="pd-canvas" width="'+SIZE+'" height="'+SIZE+'" role="img" aria-label="Poincaré disk: modular tessellation, the cusps and Farey contact edges of the current shell, and the divisor orbit points when N − 1 is a square" style="display:block;width:100%;max-width:'+SIZE+'px;aspect-ratio:1/1;background:var(--bg-inset);border:1px solid var(--line-grid);border-radius:4px;margin:6px 0"></canvas>';
  h+='<p class="note" data-role="pd-cap">Genuine Poincaré disk by the Cayley map ζ = (z − i)/(z + i), gauge w = i (the point i is the centre; no recentring). Background (drawing): the modular tessellation, each Farey triangle cut into six (2, 3, ∞) triangles coloured by the parity of the PGL(2, ℤ) reflection word; the dashed diameter is the mirror m ↔ k (ζ ↦ −ζ̄). Cyan: the cusps F(a) of this shell’s exponent profile (Lemma II.5g), their Farey contact edges (Def II.5h) and Ford horocycles; red: isolated phase beads. Cusps p/q sit at the Pythagorean points ((p² − q²) − 2pq·i)/(p² + q²), not at roots of unity: they crowd towards ±1.</p>';
  if(!D.idle){
    h+='<p class="lbl">cusps (exact, first '+Math.min(D.cusps.length,BD.CUSP_LINES)+' of '+D.cusps.length+')</p>';
    for(const k of D.cusps.slice(0,BD.CUSP_LINES))h+='<p class="mono" data-role="pd-cusp">'+esc(k.p+'/'+k.q+' ↦ '+k.text)+'</p>';
    if(D.cusps.length>BD.CUSP_LINES)h+='<p class="note dim">⋯ '+(D.cusps.length-BD.CUSP_LINES)+' more</p>';
    if(D.edges.length){h+='<p class="lbl">contact edges: centre (a − ib)(c − id)/(ac + bd), radius 1/|ac + bd| (exact, first '+Math.min(D.edges.length,BD.EDGE_LINES)+' of '+D.edges.length+')</p>';
      for(const x of D.edges.slice(0,BD.EDGE_LINES)){const a=D.F[x.i],b=D.F[x.j];h+='<p class="mono" data-role="pd-edge">'+esc(a[0]+'/'+a[1]+' — '+b[0]+'/'+b[1]+' : centre '+x.e.ctext+', radius '+x.e.rtext)+'</p>';}
      if(D.edges.length>BD.EDGE_LINES)h+='<p class="note dim">⋯ '+(D.edges.length-BD.EDGE_LINES)+' more</p>';}
    if(D.orbit.square){
      const O=D.orbit;h+='<p class="read" data-role="pd-orbit-head"><b>N − 1 = '+O.n+'²</b>, n = '+O.n+': one point (n + i)/m per divisor m of N, ζ = (k − m − 2n·i)/(k + m + 2), k = N/m, cosh d(0, ζ) = (k + m)/2 (amber; each lies on a Farey edge, the edge γ∞ — γ0 where γ = (a b; c d), γi = (n + i)/m)</p>';
      for(const p of O.pts.slice(0,BD.ORBIT_LINES))h+='<p class="mono" data-role="pd-orbit">'+esc('m = '+p.m+', k = '+p.k+' · ζ = '+p.text+' · cosh d = '+p.coshText+' · γ = '+mat(p.matrix))+'</p>';
      if(O.pts.length>BD.ORBIT_LINES)h+='<p class="note dim">⋯ '+(O.pts.length-BD.ORBIT_LINES)+' more</p>';
      h+='<p class="note">Only the representative point per divisor is drawn (no Γ∞ translates n + jm). The exchange m ↔ k is the mirror ζ ↦ −ζ̄; n ↦ −n is ζ ↦ ζ̄.</p>';
    }else h+='<p class="note warn" data-role="pd-orbit-idle">N − 1 = '+(D.N-1n)+' is not a square: no point (n + i)/m on this shell (idle, labelled). The shells n² + 1 are N = 2, 5, 10, 17, 26, …; the base selector has a “shells n² + 1” track.</p>';
  }
  h+='<p class="note dim" data-role="pd-scope">Registers: exact (BigInt over ℚ(i)): the cusp images, the edge centres and radii, Astra’s ζ and cosh d; drawing (float64): the arcs, the horocycles, the tessellation and its colours, the depth cut-off. Claim scope: the Cayley map, the Farey tessellation, Ford horocycles, the i-orbit parametrisation and cosh d(i, γi) = ‖γ‖²/2 are classical; no novelty is claimed. Nothing about cancellation, sieve weights, Landau’s problem or primes of the form n² + 1 is shown by any drawing. Note 9.4b is interpretive: the disk does not show rational descent or the carrier axis as a Farey spine. Astra’s cautions: spherical and hyperbolic metrics differ (the Hopf picture gives no hyperbolic estimate); existing equidistribution results do not automatically cover the Landau sieve family; boundary accumulation is the setting, not a proof. The (3, 4, ∞) orbifold belongs to the S⁶ track and is not drawn here (it is not contained in PSL(2, ℤ)). Display only: not in the exact export.</p>';
  el.innerHTML=h;
  const cv=el.querySelector('canvas[data-role="pd-canvas"]');
  if(cv){try{const rec=draw(cv,D);cv.dataset.cusps=String(rec.cusps.length);cv.dataset.edges=String(rec.edges.length);cv.dataset.astra=String(rec.astra.length);}catch(e){cv.dataset.error=String(e);}}
}
V.registerPanel({id:'branch-primitivity',title:'Branch primitivity (trial division)',group:'B',collapsed:true,register:'exact',coupling:'reads N, t₁, t₂, m, n₆; writes nothing',
  description:'N prime iff every branch c = 2…⌊√N⌋ is primitive, read off the Clifford branch windings at gears (1, 1).',source:'design note BRANCH_PRIMITIVITY v0.1 (option a); kernel Def II.23.9, Lemma II.23.9a G3',actions:[],
  about:'register: exact · state coupling: reads the shared state · display only',render:(el,M)=>renderBranch(el,M)});
V.registerPanel({id:'poincare-disk',title:'Poincaré disk · Farey layer and divisor orbit',group:'B',collapsed:true,register:'mixed',coupling:'reads the shell N; writes nothing',
  description:'The Cayley disk with the modular tessellation, the shell’s Farey contact graph and Astra’s divisor points (n + i)/m when N − 1 = n².',source:'design note POINCARE_DISK_VIEW_INVESTIGATION v0.1 (option A′, §3b iii)',actions:[],
  about:'register: exact (readouts) and drawing (arcs, fills) · state coupling: reads the shell · display only',render:(el,M)=>renderDisk(el,M)});
root.FVBranchDiskCards={draw,tessellation,SIZE,RIM,primFor,diskFor};
})(typeof globalThis!=='undefined'?globalThis:this);
