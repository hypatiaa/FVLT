(function(root){
'use strict';
// Fourier tab: the planar phasor comb and its head-to-tail walk (host Plane view, renderPhasorSvg). DRAWING register.
const V=root.FVViews,GB=root.FVGoldbach,W=640,H=480;
const DEF={fz:'1',fx:'0',fy:'0',fk:'0',fp:'1',fd:'0',fn:'0',ft:'1',fw:'1',fm:'1',fs:'0',ff:'0',so:'0.5',fr:'0',fl:'0'};   // v0.4.9: fs full stack, ff fraction stack (Layers menu, default off; written to the view string only when on)   // fm (v0.4): mirror axis layer (carrier-relative line), default on
const MIR='#c084fc';
// v0.4.9 (SCHEMA_ADDENDUM_17) full stack on the canvas layer: one fillRect per point (host Plane draw), tooth colour, batched per tooth.
// Signature-cached: the dots are drawn into an offscreen bitmap that is redrawn only when the stack key, the frame (scale, centre) or the canvas size changes; an s or phi3 change only copies it.
const STACK_ALPHA=0.5;   // the host default stack opacity; the Stack opacity item cycles 0.50 / 0.30 / 0.15 / 0.06 (host state.stackAlpha, view key so)
const OPAC=[0.5,0.3,0.15,0.06],opacOf=vs=>{const x=parseFloat(vs.so);return OPAC.includes(x)?x:STACK_ALPHA;};
const opacNext=vs=>String(OPAC[(OPAC.indexOf(opacOf(vs))+1)%OPAC.length]);
const opacItem=vs=>({id:'sopac',label:'Stack opacity '+opacOf(vs).toFixed(2),menu:'layers',title:'opacity of the stack dots (display only; not the amplitude exponent α)'});
const OPAC_ABOUT='Stack opacity (Layers menu, while a full stack is on): opacity of the stack dots (display only; not the amplitude exponent α); cycles 0.50 / 0.30 / 0.15 / 0.06, default 0.50 (host “▒ α 0.50”, state.stackAlpha).';
const SDOT={sig:null,cv:null,draws:0};
function stackLayer(ctx,P,sc,cx,cy,m,op,RC,LM){
  if(!ctx)return;
  const cv=ctx.canvas,tr=ctx.getTransform(),k=tr.a,sig=P.key+'|'+op+'|'+sc+'|'+cx+'|'+cy+'|'+cv.width+'x'+cv.height+'|'+tr.e+','+tr.f+(RC?'|R':'')+(LM?'|L'+LM.L:'');
  if(SDOT.sig!==sig){const o=SDOT.cv||(SDOT.cv=document.createElement('canvas'));o.width=cv.width;o.height=cv.height;const g=o.getContext('2d');g.setTransform(1,0,0,1,0,0);g.clearRect(0,0,o.width,o.height);
    const px=Math.max(2,2.2*k),h=px/2,xy=LM?LM.xy:P.xy,nc=P.lattice.cells;
    for(let t=0;t<m;t++){g.fillStyle=V.toothRgba(P.offsets[t],m,op);for(let i=0;i<nc;i++){const j=2*(i*m+t),x=tr.a*(cx+sc*xy[j])+tr.e,y=tr.d*(cy-sc*xy[j+1])+tr.f;if(x>-px&&y>-px&&x<o.width+px&&y<o.height+px)g.fillRect(x-h,y-h,px,px);}}
    if(RC){const xr=LM?LM.xr:RC.xy;for(let t=0;t<m;t++){g.fillStyle=V.toothRgba(P.offsets[t],m,op);for(let i=0;i<nc;i++){const j=2*(i*m+t),x=tr.a*(cx+sc*xr[j])+tr.e,y=tr.d*(cy-sc*xr[j+1])+tr.f;if(x>-px&&y>-px&&x<o.width+px&&y<o.height+px)g.fillRect(x-h,y-h,px,px);}}}
    SDOT.sig=sig;SDOT.draws++;}
  ctx.save();ctx.setTransform(1,0,0,1,0,0);ctx.globalAlpha=1;ctx.drawImage(SDOT.cv,0,0);ctx.restore();
}
// v0.4.12 (SCHEMA_ADDENDUM_20) log radius display: a point z (r = |z|, phase exact) is drawn at radius R(r) = R_t(1 + ln r / L) about the throat r = 1 (R_t = 1 plane unit); display only.
const LOGC={P:null,RC:null,v:null};
const logR=(r,L)=>1+Math.log(r)/L;
function logModel(P,RC){
  if(LOGC.P===P&&LOGC.RC===RC&&LOGC.v)return LOGC.v;
  let L=0,undef=0;const scan=xy=>{for(let i=0;i<xy.length;i+=2){const x=xy[i],y=xy[i+1];if(x!==x)continue;const r=Math.hypot(x,y);if(r===0){undef++;continue;}const a=Math.abs(Math.log(r));if(a>L)L=a;}};
  scan(P.xy);if(RC)scan(RC.xy);const degenerate=!(L>0);if(degenerate)L=1;
  let maxRd=0;const map=xy=>{const o=new Float64Array(xy.length);for(let i=0;i<xy.length;i+=2){const x=xy[i],y=xy[i+1];if(x!==x){o[i]=NaN;o[i+1]=NaN;continue;}const r=Math.hypot(x,y);if(r===0)continue;const d=Math.max(0,logR(r,L)),f=d/r;o[i]=x*f;o[i+1]=y*f;if(d>maxRd)maxRd=d;}return o;};
  const xy=map(P.xy),xr=RC?map(RC.xy):null;
  const v={L,degenerate,xy,xr,undef,maxRd};LOGC.P=P;LOGC.RC=RC;LOGC.v=v;return v;
}
const LOG_ITEM=vs=>({id:'logr',label:(vs.fl==='1'?'◐ ':'○ ')+'Log radius (throat at |z| = 1)',pressed:vs.fl==='1',menu:'layers',title:'draw radius as ln|z| about the throat |z| = 1 (display only; exact values unchanged)',sw:['#00e5ff','#ff5e6c']});
const LOG_ABOUT='Log radius (throat at |z| = 1) (v0.4.12, pen repaired in v0.4.13): display only, while a full stack is on. The STACK layers (Full stack, Reciprocal winding) keep their exact phase arg z and are drawn at radius R(r) = R_t·(1 + ln r / L), r = |z|, R_t the on-screen throat radius, L the largest |ln r| among the drawn stack points (both halves when Reciprocal winding is on, otherwise the shown half). So r = 1 sits on the throat circle, r = e^{±L} at 0 and 2R_t, and with Reciprocal winding on the two halves are exact mirror images about the throat circle (R(1/r) = 2R_t − R(r)). After saphir’s Farey helix explorer v2/v3 (value x drawn at radius |ln x| about the throat 1/1), laid flat. The pen (the Gauss-sum walk, its vertices, trace, endpoint ring, the amber polygon and radius circle), the teeth and the carrier are NOT log-mapped, because the walk adds tooth vectors tip to tail and a log map destroys vector addition: they are drawn on the ordinary linear scale about the same origin, with their own scale s_pen chosen so that the pen’s largest extent (max of ρ, |W_t|, |z_c|) is half the throat radius; a labelled scale bar (bottom right) gives s_pen. Stack points at r = 0 (n₆ = 0) have no log image: counted, drawn at the origin and labelled. The grid circles are replaced by log rings at r = e^k. No exact readout, caption number, card, export, Lift JSON or address changes (apart from the view key fl).';
const nf=n=>Number(n).toLocaleString('en-US');
const ord=k=>k+(k%10===1&&k%100!==11?'st':k%10===2&&k%100!==12?'nd':k%10===3&&k%100!==13?'rd':'th');
// the caption of the full stack (register and degenerate cases labelled, never hidden); shared by the three views
function stackCaption(P,R,where){const L=P.lattice,aInt=R.alpha.d===1n;
  return '✦ full stack: s, φ₃ ∈ {0 … '+L.spanN+'}'+(L.thinned?', every '+ord(L.step)+' value':'')+' · '+nf(L.cells)+' cells × m = '+nf(P.n)+' points'+(where||'')+' · phases exact, amplitude n₆·N^α '+(aInt?'exact (α integer)':'numerical')+', drawn float64'
    +(L.thinned?' · thinned: cap '+nf(L.gridCap)+' cells'+(L.mBucket?' (m > 30 budget)':'')+', deterministic':'')+(L.zeroCells?' · φ₃ = '+L.spanN+' column: N = 0, no comb ('+L.zeroCells+' cells, not drawn)':'')+(P.zeroAmplitude?' · n₆ = 0: every stack point at the origin':'');}
const STACK_ABOUT='Full stack (v0.4.9, ported from the merged FVLT monodromy instrument, buildFullStack): every integer layer s and every integer shell position φ₃ in 0 … B+1, N = B+1−φ₃, and every tooth c: the tooth z_c = n₆·N^α·exp(iπ(N·t₁ + c·t₂)·s/N) of the comb at that state (“the hand-built rosette”; in the host’s words N = B+1−φ₃ ties radius and phase along the φ₃ sweep, “the Archimedean arms are forced, not chosen”; a fixed s, c curve with the carrier removed is r = N, θ = π·c·t₂·s/N, not an Archimedean spiral). Exact register: each phase (N·t₁ + c·t₂)·s/N mod 2 (integer arithmetic, the same k_c and phase as the tooth table). The amplitude n₆·N^α is exact only for integer α; drawn values are float64. The stack follows this viewer’s exact α, n₆, t₁, t₂, m and the shell; it does not depend on φ₃ or s (they move the current comb) and not on α_Tilt (it weights the walk; the stack is made of teeth). In N∈ℚ mode the stack is still the integer lattice. Lattice: step 1 while (B+2)² ≤ 58,081 = 241², else every ⌈(B+1)/241⌉-th s and φ₃ (m > 30: budget ⌊58,081·30/m⌋ cells); m-independent through m = 30. Display only: not in teeth, walk, readouts, cards or exports.';
const FRAC_ABOUT='Fraction stack in the plane (v0.4.9): the heads of the fraction stack (current shell, s = j/q, certified exact phases; the same heads as the Clifford tab) drawn as planar teeth z_c = n₆·N^α·exp(iπ·k_c·s/N); they all lie on the current radius circle |z| = |ρ|. Spread-zero columns bright. The old instrument drew this population only in the Clifford lift. Display only: not in teeth, walk, readouts, cards or exports.';
const RECIP_ITEM=(vs,key)=>({id:'recip',label:(vs[key]==='1'?'◐ ':'○ ')+'Reciprocal winding (throat at 1/1)',pressed:vs[key]==='1',menu:'layers',title:'the other half of the full stack: its image under w ↦ 1/w̄ (display only)',sw:['#00e5ff','#ff5e6c']});
const RECIP_ABOUT='Reciprocal winding (throat at 1/1) (v0.4.11): the other half of the full stack: its image under the inversion w ↦ 1/w̄ (radius 1/ρ = N^−α/|n₆|; phases unchanged, so exact). On the Hopf base it is the exact reflection through the equator plane (heights −(ρ²−1)/(ρ²+1)); it is the Farey half x = 1/n → 0, i.e. t = ln x < 0. The equator |w| = 1 is the throat. It coincides with the α ↦ −α stack only when |n₆| = 1, and both halves start on the equator only when |n₆| = 1 (otherwise at heights ±(n₆²−1)/(n₆²+1), mirror images). Prior work: saphir’s Farey helix explorer v2/v3 (toggle “Reciprocal winding (throat at 1/1)”, x ↦ 1/x). Arithmetic: x ↦ 1/x is the divisor ↔ cofactor exchange m ↔ (n²+1)/m, the same involution as the dashed diameter of the Poincaré disk card (the disk card is unchanged in this version). It is not the “Mirror axis” of this viewer (c ↦ −c, a fibre-side involution). Display only: no export, readout or card. Radius 1/(n₆·N^α) is an exact rational for integer α and numerical otherwise; drawn values are float64.';
const recipCaption=(P,R,RC,where)=>'◐ Reciprocal winding (throat at 1/1): w ↦ 1/w̄ of every stack point'+(where||'')+' · phases exact, radius 1/(n₆·N^α) '+(R.alpha.d===1n?'exact (α integer)':'numerical')+', drawn float64'+(RC&&RC.undef?' · '+nf(RC.undef)+' points have no image (n₆ = 0), not drawn':'');
root.FVStackView={logModel,logR,RECIP_ITEM,RECIP_ABOUT,recipCaption,stackCaption,STACK_ABOUT,FRAC_ABOUT,STACK_ALPHA,OPAC,opacOf,opacNext,opacItem,OPAC_ABOUT,SDOT,nf};   // the carrier's violet, as on the Clifford tab
function nice(x){const e=Math.pow(10,Math.floor(Math.log10(x))),m=x/e;return (m<1.5?1:m<3.5?2:m<7.5?5:10)*e;}
function regularPolygon(n,r,cx,cy,sc){const pts=[];for(let j=0;j<=n;j++){const a=-Math.PI/2+2*Math.PI*j/n;pts.push([cx+sc*r*Math.cos(a),cy-sc*r*Math.sin(a)]);}return pts;}
const view={
  id:'fourier',label:'Fourier',W,H,defaults:DEF,
  // items: menu 'strip' (always visible), 'layers' or 'camera' (inside the Layers / Camera menu)
  toolbar(vs){return [
    {id:'zin',label:'+',menu:'strip'},{id:'zout',label:'−',menu:'strip'},{id:'reset',label:'⟲',menu:'strip',title:'reset zoom and pan'},{id:'full',label:'⛶',menu:'strip',title:'full view'},
    {id:'teeth',label:'Teeth',pressed:vs.ft==='1',menu:'layers'},{id:'walk',label:'Walk',pressed:vs.fw==='1',menu:'layers'},{id:'poly',label:'Amber polygon',pressed:vs.fp==='1',menu:'layers'},{id:'div',label:'÷ Divisors',pressed:vs.fd==='1',menu:'layers'},{id:'maxis',label:'Mirror axis',pressed:vs.fm==='1',menu:'layers',sw:[MIR]},
    {id:'fstack',label:vs.fs==='1'?'✦ Full stack':'○ Full stack',pressed:vs.fs==='1',menu:'layers',title:'every integer s and φ₃ in 0 … B+1: every tooth of every shell (display only)',sw:['#00e5ff','#ff5e6c']},{id:'ffrac',label:vs.ff==='1'?'⅟ Fraction stack':'○ Fraction stack',pressed:vs.ff==='1',menu:'layers',title:'current shell on the fraction lattice s = j/q (certified exact spins only)',sw:['#f59e0b','#e0faff']},...(vs.fs==='1'?[opacItem(vs),RECIP_ITEM(vs,'fr'),LOG_ITEM(vs)]:[]),
    {id:'lock',label:vs.fk==='1'?'🔒 zoom lock':'🔓 zoom lock',pressed:vs.fk==='1',title:'zoom lock',menu:'camera'}];},
  act(id,vs){
    const z=V.num(vs.fz,1);
    if(id==='zin'&&vs.fk!=='1')return {vs:{fz:String(V.clamp(z*1.25,0.5,1000))}};
    if(id==='zout'&&vs.fk!=='1')return {vs:{fz:String(V.clamp(z/1.25,0.5,1000))}};
    if(id==='reset')return {vs:{fz:'1',fx:'0',fy:'0'}};
    if(id==='lock')return {vs:{fk:vs.fk==='1'?'0':'1'}};
    if(id==='teeth')return {vs:{ft:vs.ft==='1'?'0':'1'}};if(id==='walk')return {vs:{fw:vs.fw==='1'?'0':'1'}};
    if(id==='poly')return {vs:{fp:vs.fp==='1'?'0':'1'}};if(id==='div')return {vs:{fd:vs.fd==='1'?'0':'1'}};if(id==='maxis')return {vs:{fm:vs.fm==='1'?'0':'1'}};
    if(id==='fstack')return {vs:{fs:vs.fs==='1'?'0':'1'}};if(id==='sopac')return {vs:{so:opacNext(vs)}};if(id==='recip')return {vs:{fr:vs.fr==='1'?'0':'1'}};if(id==='logr')return {vs:{fl:vs.fl==='1'?'0':'1'}};if(id==='ffrac')return {vs:{ff:vs.ff==='1'?'0':'1'}};
    return {};
  },
  gesture(kind,arg,vs){
    const z=V.num(vs.fz,1);
    if(kind==='drag'){return {vs:{fx:String(V.num(vs.fx,0)+arg.dx),fy:String(V.num(vs.fy,0)+arg.dy)}};}
    if((kind==='wheel'||kind==='pinch')&&vs.fk!=='1'){const f=kind==='wheel'?(arg>0?1.15:1/1.15):arg;return {vs:{fz:String(V.clamp(z*f,0.5,1000))}};}
    return {};
  },
  render(svg,M,vs,ui,cvs){
    const P=V.palette(),m=M.R.m;let o='';
    svg.setAttribute('viewBox','0 0 '+W+' '+H);
    const stackOn=vs.fs==='1';   // v0.4.9: with the full stack off nothing below differs from v0.4.8 (the opaque background rect, no canvas use)
    o+=stackOn?'<rect x="0" y="0" width="'+W+'" height="'+H+'" fill="none" data-role="bg"/>':'<rect x="0" y="0" width="'+W+'" height="'+H+'" fill="'+P.bgDeep+'"/>';
    const ctx=stackOn?V.layerBegin(cvs,W,H):null;
    if(stackOn&&(M.rd.empty||M.num.refused))V.cap('✦ full stack not drawn: the current state has no comb to frame it (N = 0 or refused); move φ₃',P.warn,'degenerate');
    const lab=(y,s,col)=>V.text(10,y,s,'fill="'+(col||P.mid)+'"');
    if(M.rd.empty){o+=V.text(W/2,H/2,'N = 0: the Fourier comb has no angular denominator, so no walk is defined (empty state, drawn and labelled).','text-anchor="middle" fill="'+P.warn+'" data-role="degenerate"');svg.innerHTML=o;return;}
    const num=M.num;
    if(num.refused){o+=V.text(W/2,H/2,num.refused,'text-anchor="middle" fill="'+P.defend+'" data-role="degenerate"');svg.innerHTML=o;return;}
    const SP=stackOn?M.stack:null,RC=SP&&vs.fr==='1'?M.stackR:null;   // v0.4.9: the frame is fitted to include the full stack; v0.4.11 the reciprocal half
    const GBm=M.gb||null;   // v0.4.14: the Goldbach prime-pair mask (null with the track off: every line below is then the v0.4.13 code path)
    const LG=!!(SP&&vs.fl==='1');const D=num;let LM=null,ext,penExt=0,penFrac=0.5;   // v0.4.13: in log mode only the stack is log-mapped; the pen (walk, trace, endpoint, polygons, radius circle, fraction points), teeth and carrier stay on their exact linear values, drawn with their own scale scP
    if(LG){LM=logModel(SP,RC);
      penExt=num.rho;for(const w of num.W)penExt=Math.max(penExt,Math.hypot(w.re,w.im));for(const z of num.z)penExt=Math.max(penExt,Math.hypot(z.re,z.im));
      ext=Math.max(1,LM.maxRd);}
    else{ext=num.rho;for(const w of num.W)ext=Math.max(ext,Math.hypot(w.re,w.im));
      if(SP&&Number.isFinite(SP.maxRadius))ext=Math.max(ext,SP.maxRadius);
      if(RC&&RC.maxRadius>0)ext=Math.max(ext,RC.maxRadius);}
    if(!(ext>0))ext=1;
    const sc=0.42*Math.min(W,H)/ext*V.num(vs.fz,1),cx=W/2+V.num(vs.fx,0),cy=H/2+V.num(vs.fy,0);
    const X=re=>cx+sc*re,Y=im=>cy-sc*im;
    const scP=LG?(penExt>0?penFrac*sc/penExt:sc):sc,XP=re=>cx+scP*re,YP=im=>cy-scP*im;   // v0.4.13 pen scale: the pen's own largest extent (max of rho, |W_t|, |z_c|) is drawn at 1/2 of the throat radius R_t; scP = sc with fl off
    if(SP){stackLayer(ctx,SP,sc,cx,cy,m,opacOf(vs),RC,LM);
      o+='<g data-role="full-stack" data-layer="canvas" data-n="'+SP.n+'" data-cells="'+SP.lattice.cells+'" data-step="'+SP.lattice.step+'" data-sc="'+sc+'" data-cx="'+cx+'" data-cy="'+cy+'" data-key="'+V.esc(SP.key)+'"></g>';
      V.cap(stackCaption(SP,M.R,'')+' · frame fitted to the stack',P.mid,'stack-caption');V.abt(STACK_ABOUT);V.abt(OPAC_ABOUT);
      if(RC){o+='<g data-role="reciprocal" data-layer="canvas" data-n="'+(SP.n-RC.undef)+'" data-undef="'+RC.undef+'"></g>'+V.circle(cx,cy,sc,'fill="none" stroke="'+P.mid+'" stroke-opacity="0.6" stroke-dasharray="2,4" data-role="throat"')+V.text(cx+sc*0.72+4,cy-sc*0.72-4,'throat |z| = 1','fill="'+P.mid+'" data-role="throat-label"');
        V.cap(recipCaption(SP,M.R,RC,LG?' · the two halves are mirror images about the throat circle (log radius: R(1/r) = 2R_t − R(r))':' · inversion in |z| = 1 (the Fourier plane: the mirror points crowd toward the origin like 1/N; their planar separation is not a certificate)'),P.mid,'recip-caption');V.abt(RECIP_ABOUT);}
      if(LG){const kmax=Math.floor(LM.L),kst=Math.max(1,Math.ceil(kmax/6)),nu=LM.undef;
        if(!RC)o+=V.circle(cx,cy,sc,'fill="none" stroke="'+P.mid+'" stroke-opacity="0.6" stroke-dasharray="2,4" data-role="throat"')+V.text(cx+sc*0.72+4,cy-sc*0.72-4,'throat |z| = 1','fill="'+P.mid+'" data-role="throat-label"');
        o+='<g data-role="log-radius" data-lmax="'+LM.L+'" data-rt="'+sc+'" data-cx="'+cx+'" data-cy="'+cy+'" data-clamp="0" data-pen-sc="'+scP+'" data-pen-ext="'+penExt+'" data-undef="'+nu+'"></g>';
        V.cap('◐ log radius display: radius drawn as ln|z| about the throat |z| = 1 (display only; exact values unchanged) · stack: R = R_t·(1 + ln r / L), L = '+LM.L.toFixed(4)+' = largest |ln r| among the drawn stack points ('+(RC?'both halves':'the shown half')+'); r = 1 on the throat, r = e^{±L} at 0 and 2R_t · log rings at r = e^k, k = 0, ±'+kst+', ±'+2*kst+' …'+(LM.degenerate?' · every stack point has r = 1: L set to 1':'')+(nu?' · '+nf(nu)+' points at r = 0 (n₆ = 0) have no log image: drawn at the origin, not on the log scale':''),P.mid,'log-caption');
        V.cap('log radius applies to the stack only; the pen, teeth and carrier are drawn on a linear scale (their own scale bar)',P.spine,'log-pen-caption');V.cap('pen scale bar (bottom right, labelled "pen u"): u in linear |z| units, drawn u × s_pen pixels long; the pen’s largest extent is drawn at 1/2 of the throat radius R_t, so s_pen = '+(scP/sc).toFixed(4)+' R_t per unit |z|',P.spine,'log-pen-scale');V.abt(LOG_ABOUT);}}
    // grid: polar circles at nice radii, axes
    const rv=Math.max(W,H)/sc,step=nice(rv/8);let g='';
    if(LG){const kmax=Math.floor(LM.L),kst=Math.max(1,Math.ceil(kmax/6));for(let k=-kmax;k<=kmax;k++){if(k===0||k%kst!==0)continue;const rd=1+k/LM.L;if(!(rd>0.02))continue;g+=V.circle(cx,cy,rd*sc,'fill="none" stroke="'+P.grid+'" stroke-width="0.8" data-role="log-ring" data-k="'+k+'"')+V.text(cx+rd*sc+2,cy+11,'e^'+(k<0?'−':'')+Math.abs(k),'fill="'+P.dim+'" data-role="log-ring-label"');}}
    else for(let k=1;k*step<=rv&&k<=40;k++)g+=V.circle(cx,cy,k*step*sc,'fill="none" stroke="'+P.grid+'" stroke-width="0.8" data-role="grid"');
    o+=g+V.line(0,cy,W,cy,'stroke="'+P.axis+'" stroke-width="1" data-role="axis"')+V.line(cx,0,cx,H,'stroke="'+P.axis+'" stroke-width="1" data-role="axis"');
    o+=V.text(W-6,cy-4,'Re','text-anchor="end" fill="'+P.dim+'"')+V.text(cx+4,12,'Im','fill="'+P.dim+'"')+V.text(W-6,H-6,LG?'log rings r = e^k (throat r = 1)':'grid step '+step,'text-anchor="end" fill="'+P.dim+'"');
    // v0.4 mirror axis (R4, as amended by the S0 design review §5): the phasors z_c = rho e^{i pi t1 s} e^{i pi c t2 s/N} of each pair +-c are reflections of each other in the
    // carrier line e^{i pi (t1 s + f)} R at EVERY s (the sum divided by the carrier phase is real for symmetric offsets). That rotating line is drawn, dashed violet.
    // It is the real axis exactly when t1 s is an integer (exact, orbit-core mirrorConjugate); only then is the lab-frame sum real, and the caption says that they coincide.
    // The lab-frame Q-residual is not a certificate for the axis.
    let onReal=false;
    if(vs.fm==='1'){const O=root.FVOrbit,ph=O.mirrorCarrierPhase(M.st),th=Math.PI*Number(ph.n)/Number(ph.d),L=2*Math.max(W,H),dx=Math.cos(th)*L,dy=-Math.sin(th)*L;onReal=O.mirrorConjugate(M.st);
      o+=V.line(cx-dx,cy-dy,cx+dx,cy+dy,'stroke="'+MIR+'" stroke-width="2" stroke-dasharray="7,5" stroke-opacity="0.9" data-role="mirror-axis" data-on-real="'+onReal+'"');
      const lx=cx+Math.cos(th)*0.75*Math.min(W,H)/2,ly=cy-Math.sin(th)*0.75*Math.min(W,H)/2;
      o+=V.text(lx+6,ly-6,'mirror axis','fill="'+MIR+'" data-role="mirror-label"');
      V.abt('Mirror axis (v0.4): the plane mirror of c ↦ −c is the line through the carrier e^{iπ·(t₁·s + f)} (f = 1 if n₆ < 0); the phasors of each pair ±c are reflections of each other in it at every s, so the sum divided by the carrier phase is real. This rotating line is drawn. It is the real axis exactly when t₁·s ∈ ℤ (exact); only then is the lab-frame sum real. Integer s alone is not enough with rational t₁ (N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1 gives the resultant −i). The lab-frame Q-res is not a certificate for the axis.'+(M.num&&M.num.tilt?' (teeth only; the tilted walk is not mirror-symmetric.)':'')+' Now: carrier phase '+root.FVExact.text(ph)+' (units of π, exact)'+(onReal?'; the axis is the real axis.':'; the axis is not the real axis.'));}
    // radius circle (dashed) and resident / witness polygons
    if(num.rho>0)o+=V.circle(cx,cy,D.rho*scP,'fill="none" stroke="'+P.mid+'" stroke-opacity="0.45" stroke-dasharray="3,4" data-role="radius"');
    const gb=M.rd.gearbox;
    if(vs.fp==='1'&&gb.resident){const col=gb.code==='WILSON_PRIME_RESIDENT'?P.good:P.polyStroke;
      o+=V.poly(regularPolygon(m,Math.max(D.rho,0),cx,cy,scP),'stroke="'+col+'" stroke-width="1.4" stroke-dasharray="5,4" data-role="resident-polygon"');
      o+=V.text(10,H-22,(gb.code==='WILSON_PRIME_RESIDENT'?'Wilson prime witness':'Resident cycle')+' polygon (m = '+m+')','fill="'+(gb.code==='WILSON_PRIME_RESIDENT'?P.good:P.polyText)+'"');}
    else if(gb.resident&&vs.fp!=='1')o+=V.text(10,H-22,'Amber polygon overlay switched off; the divisibility m | N still holds.','fill="'+P.dim+'"');
    if(M.witness){const w=M.witness;
      if(w.lod)o+=V.circle(cx,cy,Math.max(D.rho,0)*scP,'fill="none" stroke="'+P.z0+'" stroke-dasharray="1,3" data-role="witness-lod"')+V.text(10,H-34,'LOD p-gon (p = '+w.p+'): exact order, vertices below display resolution','fill="'+P.z0+'"');
      else o+=V.poly(regularPolygon(Number(w.p),Math.max(D.rho,0),cx,cy,scP),'stroke="'+P.z0+'" stroke-width="1.2" data-role="witness-polygon"')+V.text(10,H-34,'FULL p-gon (p = '+w.p+', '+w.p+' vertices)','fill="'+P.z0+'"');}
    if(vs.ff==='1'){   // v0.4.9 fraction stack in the plane
      if(M.fpIdle)V.cap(M.fpCaption,P.warn,'fraction-warning');
      else{o+='<g data-role="fraction-stack">';for(const h of M.fpPts)o+='<circle cx="'+V.f2(XP(h.re))+'" cy="'+V.f2(YP(h.im))+'" r="'+(h.zero?2.4:1.8)+'" fill="'+(h.zero?'#e0faff':V.rgba(P.spine,0.8))+'"/>';
        o+='</g>';V.cap(M.fpCaption+' · on |z| = |ρ| (plane)',P.spine,'fraction-caption');V.abt(FRAC_ABOUT);}}
    // walk
    if(vs.fw==='1'){
      o+=V.poly(D.W.filter((w,t)=>!GBm||t===0||GBm.teeth[t-1].kept).map(w=>[XP(w.re),YP(w.im)]),'stroke="'+P.spine+'" stroke-width="1.6" stroke-opacity="0.85" data-role="walk"');
      D.W.forEach((w,t)=>{if(GBm&&t>0&&!GBm.teeth[t-1].kept)return;o+=V.circle(XP(w.re),YP(w.im),t===0?3:1.8,'fill="'+(t===0?'#fff':P.spine)+'" data-role="vertex" data-t="'+t+'"');});
      const e=D.W[D.W.length-1];o+=V.circle(XP(e.re),YP(e.im),7,'fill="none" stroke="'+P.spine+'" stroke-width="1.4" data-role="endpoint"')+V.circle(XP(e.re),YP(e.im),3,'fill="'+P.spine+'"');
    }
    // teeth and carrier
    if(vs.ft==='1'){
      o+=V.line(cx,cy,XP(D.z0.re),YP(D.z0.im),'stroke="'+P.z0+'" stroke-width="2.5" stroke-dasharray="6,4" data-role="carrier"');
      D.z.forEach((z,zi)=>{const col=V.toothHex(z.c,m),sel=ui.sel!==null&&Number(ui.sel)===Number(z.c);
        if(GBm&&!GBm.teeth[zi].kept){   // ghosted: removed by the prime filter (drawn, labelled in the caption, not in the pen)
          o+=V.line(cx,cy,XP(z.re),YP(z.im),'stroke="'+col+'" stroke-width="1" stroke-opacity="0.18" stroke-dasharray="2,4" data-role="tooth-ghost" data-c="'+z.c+'"')+V.circle(XP(z.re),YP(z.im),2.2,'fill="none" stroke="'+col+'" stroke-opacity="0.4" data-role="tooth-ghost-dot" data-c="'+z.c+'"')+V.circle(XP(z.re),YP(z.im),11,'fill="transparent" data-role="hit" data-c="'+z.c+'"');return;}
        o+=V.line(cx,cy,XP(z.re),YP(z.im),'stroke="'+col+'" stroke-width="'+(sel?4.5:Math.abs(Number(z.c))===1?3:2.2)+'" stroke-opacity="0.9" data-role="tooth" data-c="'+z.c+'"');
        o+=V.circle(XP(z.re),YP(z.im),sel?6:3,'fill="none" stroke="'+col+'" data-role="tooth-ring" data-c="'+z.c+'"')+V.circle(XP(z.re),YP(z.im),2.2,'fill="'+col+'" stroke="#fff" stroke-width="0.8" data-role="tooth-dot" data-c="'+z.c+'"');
        o+=V.circle(XP(z.re),YP(z.im),11,'fill="transparent" data-role="hit" data-c="'+z.c+'"');});
    }
    if(LG){   // v0.4.13 pen scale bar: u = a nice length in linear |z| units, drawn u*scP pixels long
      let u=nice(90/scP);const len=u*scP;const bx=W-6-len,by=H-24;
      o+=V.line(bx,by,bx+len,by,'stroke="'+P.spine+'" stroke-width="2.2" data-role="pen-scale-bar"')+V.line(bx,by-4,bx,by+4,'stroke="'+P.spine+'" stroke-width="1.2"')+V.line(bx+len,by-4,bx+len,by+4,'stroke="'+P.spine+'" stroke-width="1.2"')
        +V.text(bx+len,by-8,'pen '+u,'text-anchor="end" fill="'+P.spine+'" data-role="pen-scale" data-u="'+u+'" data-len="'+len+'" data-pen-sc="'+scP+'"');}
    o+=V.circle(cx,cy,3,'fill="#fff" data-role="origin"');
    // overlays
    const q=num.qres,sInt=M.labReal;   // v0.4.1: the star is keyed on t1*s in Z (the lab-frame sum is then real), not on s in Z (SCHEMA_ADDENDUM_9 §2)
    const tl=num.tilt;   // v0.4.7: present only when alpha_Tilt != 0
    V.cap('ALIGN '+(M.rd.flagAlign?'yes':'no')+' · SPREAD '+(M.rd.flagSpread?'yes':'no')+(sInt?(tl?' ★ teeth conjugate (t₁·s ∈ ℤ); walk not real':' ★ lab sum real'):'')+' · Q-res '+q.value.toExponential(1)+' (numerical)'+(onReal?' · mirror axis = real axis (t₁·s ∈ ℤ)':''),sInt?P.good:P.z1,'line');
    if(GBm){V.cap('Goldbach prime-pair mask · N = '+GBm.N+' · g(N) = '+GBm.g+' · G_N(0) = 2g(N) = '+GBm.G0+' · the pen is G_N(s) exactly: '+GBm.kept+' of '+GBm.m+' teeth in the pen (weight 2 on the c = 0 tooth, the equal pair, when N/2 is prime), '+GBm.removed+' ghosted — '+GB.GHOST_LABEL+' · ALIGN / SPREAD describe the unmasked comb',P.good,'gb-caption');
      V.abt('Goldbach prime-pair mask (v0.4.14, track "Goldbach N ▸"): the pen is the kernel’s G_N(s) = Σ over P_N of (e^{2πips/N} + e^{2πi(N−p)s/N}) = e^{iπs}·R_N(s) (Cor II.23.5c), because the mask is a walk weight: w_c = 1 on the teeth with N/2 ± c·t₂ both prime, w = 2 on the c = 0 tooth (the equal pair p = N/2, counted twice in G_N), w = 0 elsewhere. Teeth removed by the prime filter are drawn ghosted and do not enter the pen; the tooth rays shown are the unweighted z_c, and the walk step of the c = 0 tooth is 2·z₀. ALIGN / SPREAD and the K_m kernel describe the unmasked comb. '+GB.GUARDS.closure+' The prime filter is the only input that does not come from the Fourier construction. '+GB.PRIOR_ART);}
    if(tl){V.cap('α_Tilt = '+root.FVExact.text(M.R.tilt)+': walk step t weighted t^α_Tilt (walk only; teeth unchanged)'+(tl.exactWeights?'':' · weights numerical')+' · instrument-tier, no theorem standing',P.warn,'tilt');
      if(m===2)V.cap('m = 2, α_Tilt ≠ 0: W₂ = z₋₁ + 2^α_Tilt·z₊₁ is not the Vernier sum of II.5 (needs equal amplitudes); the factorization still applies to the teeth',P.warn,'tilt-m2');
      V.abt('α_Tilt (v0.4.7): the walk goes W_t = W_{t−1} + w_t·z_{c_t}, w_t = t^α_Tilt, t = 1 … m the position in offset order (w₁ = 1, so W₁ = z_{c₁} at every tilt). Only the walk, its endpoint and the numbers computed from it change; the teeth, the carrier, the polygons and every exact readout do not. Notation w_k = k^{α_Tilt} is a kernel parameter (v3.2.7); the comb walk for m ≥ 3 is outside the kernel, so this is an instrument-tier use with no theorem standing, and the Helix, Circle and Spiral preset names are not claims about the comb walk. '+(tl.exactWeights?'The weights are exact rationals; the walk values drawn are float64.':'The weights t^(p/q) are irrational in general, so the walk values are numerical.'));}
    if(num.rhoZero)o+=V.text(W/2,H-8,'ρ = 0: every tooth sits at the origin (drawn, labelled).','text-anchor="middle" fill="'+P.warn+'" data-role="degenerate"');
    V.abt('★ lab sum real (v0.4.1): shown exactly when t₁·s ∈ ℤ. Then the phasors of each pair ±c are complex conjugates and W is real (Q-res 0 up to the numerical bound). Integer s alone is not enough with rational t₁: at N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1 the resultant is −i and no ★ is shown. At every s, W·e^{−iπ(t₁s+f)} is real for the symmetric offsets (an identity, not a lab-frame statement): see the exact-flags card.');V.abt('Zoom ×'+V.num(vs.fz,1).toFixed(2)+'.');V.abt('Plane view of the host phasor comb: tooth rays z_c = n6·N^α·exp(i·k_c·s·π/N), the carrier ray z₀, the head-to-tail walk and its endpoint. Drag pans; wheel or pinch zooms (0.5–1000).');V.abt('Numerical register: float64 display, absolute bound ±'+num.bound.toExponential(1)+' = '+(tl?'8·(m + 2 + |α|(1 + |ln N|) + |α_Tilt|(1 + ln m))·ε·max(ρ·w_max, 1), w_max = m^α_Tilt for α_Tilt > 0 and 1 otherwise, ':'8·(m + 2 + |α|(1 + |ln N|))·ε·max(ρ,1), ')+'ε = 2⁻⁵² (|ln N| = ln N on every shell).');
    svg.innerHTML=o;
  }
};
V.register(view);
})(typeof globalThis!=='undefined'?globalThis:this);
