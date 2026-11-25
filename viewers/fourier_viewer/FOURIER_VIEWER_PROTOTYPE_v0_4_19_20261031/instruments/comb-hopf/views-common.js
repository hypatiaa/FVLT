(function(root){
'use strict';
// fv-views-common 0.1.0: DRAWING register helpers shared by every view window, plus the view registry.
// A view module registers { id, label, W, H, defaults, toolbar(vs), act(id,vs,M), gesture(kind,arg,vs,M), render(svg,M,vs,ui) }.
//   render writes svg.innerHTML from the shared model M (never its own state). toolbar/act/gesture return patches {vs:{...}, st:{...}}.
// New tabs (e.g. the cubic Fourier viewer) plug in by registering another view; they read the same shared model.
const registry=[];
function register(v){registry.push(v);}
let PAL=null;
function palette(){                                      // colours are read from the CSS variable block once; SVG gets literal values
  if(PAL)return PAL;const cs=getComputedStyle(document.documentElement),g=n=>cs.getPropertyValue(n).trim();
  PAL={bgDeep:g('--bg-deep'),bgPanel:g('--bg-panel'),grid:g('--line-grid'),axis:g('--line-axis'),dim:g('--text-dim'),mid:g('--text-mid'),bright:g('--text-bright'),
    z1:g('--accent-z1'),z2:g('--accent-z2'),z0:g('--accent-z0'),warn:g('--accent-warn'),good:g('--accent-good'),defend:g('--accent-defend'),spine:g('--accent-spine'),
    font:g('--font-mono'),z0text:g('--accent-z0-text'),polyText:g('--poly-text'),polyStroke:g('--poly-stroke')};
  return PAL;
}
const TOOTH=[['#00e5ff','#ff5e6c'],['#10b981','#fbbf24'],['#3b82f6','#f472b6'],['#84cc16','#fb923c'],['#2dd4bf','#e879f9'],['#a3a3c2','#eab308']];
// rank by |c|: odd m -> |c| = 1,2,3...; even m -> |c| = 1,3,5... gives rank (|c|+1)/2 (pairs of the same distance from the centre)
function toothHex(c,m){c=Number(c);if(c===0)return palette().bright;const a=Math.abs(c),rank=m%2?a:(a+1)/2;return TOOTH[(rank-1)%6][c<0?0:1];}
function rgba(hex,a){const n=parseInt(hex.slice(1),16);return 'rgba('+(n>>16&255)+','+(n>>8&255)+','+(n&255)+','+a+')';}
const toothRgba=(c,m,a)=>rgba(toothHex(c,m),a);
const f2=n=>(Math.round(n*100)/100).toString();
function esc(s){return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function line(x1,y1,x2,y2,a){return '<line x1="'+f2(x1)+'" y1="'+f2(y1)+'" x2="'+f2(x2)+'" y2="'+f2(y2)+'" '+a+'/>';}
function circle(x,y,r,a){return '<circle cx="'+f2(x)+'" cy="'+f2(y)+'" r="'+f2(r)+'" '+a+'/>';}
// ---- text: SVG text is sized from the rendered scale so it is never below 13 CSS px on screen (setFont); long overlay lines
// (more than 14 characters) are not drawn inside the picture: they go to the HTML caption under the view (cap/caps).
let fontUser=13,CAPS=[],quiet=false;     // quiet: a camera-only redraw re-emits the picture but not the captions / notes (they cannot change when only the camera moves)
const setQuiet=q=>{quiet=!!q;};
const setFont=px=>{fontUser=px;},capReset=()=>{CAPS=[];},caps=()=>CAPS.slice();
const aboutOpen={};
function aboutBlock(key,text){const o=aboutOpen[key];return '<div class="aboutwrap"><button type="button" class="info" data-act="about" data-v="'+key+'" aria-expanded="'+(!!o)+'" aria-label="About this" title="About">ⓘ</button>'+(o?'<div class="about note">'+esc(text)+'</div>':'')+'</div>';}
let ABOUT=[];const abtReset=()=>{ABOUT=[];},abouts=()=>ABOUT.slice();
function abt(s){if(quiet)return '';ABOUT.push(String(s));return '';}   // provenance / ids / formulas: shown only behind the (i) toggle
function cap(s,col,role){if(quiet)return;CAPS.push({s:String(s),col:col||palette().mid,role:role||''});}
function rawText(x,y,s,a){return '<text x="'+f2(x)+'" y="'+f2(y)+'" font-family="'+esc(palette().font)+'" font-size="'+(Math.ceil(fontUser*1e4)/1e4)+'" '+(a||'')+'>'+esc(s)+'</text>';}
function text(x,y,s,a){
  a=a||'';s=String(s);
  if(s.length>14){const f=/fill="(#[0-9a-fA-F]{6})"/.exec(a),r=/data-role="([^"]+)"/.exec(a);
    if(!(r&&r[1]==='degenerate')){abt(s);return '';}      // long overlay text is not drawn and not on the surface: it goes behind the (i); only degenerate-case labels stay visible
    cap(s,f?f[1]:palette().mid,r?r[1]:'');
    const an=/text-anchor="(start|middle|end)"/.exec(a);   // the stand-in keeps the caller's anchor: a label at x = 10 must start there, not be centred on it (it was clipped at the left edge)
    return r&&r[1]==='degenerate'?rawText(x,y,'(see note)','text-anchor="'+(an?an[1]:'start')+'" fill="'+(f?f[1]:palette().warn)+'"'):'';}
  return rawText(x,y,s,a);
}
// contrast helpers: tooth colours used as TEXT are lightened until they reach WCAG AA (4.5:1) on the card background
const lum=h=>{const n=parseInt(h.slice(1),16),c=[n>>16&255,n>>8&255,n&255].map(v=>{v/=255;return v<=0.03928?v/12.92:Math.pow((v+0.055)/1.055,2.4);});return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2];};
const ratio=(a,b)=>{const x=lum(a),y=lum(b);return (Math.max(x,y)+0.05)/(Math.min(x,y)+0.05);};
function readable(hex,bg){let h=hex;for(let i=0;i<20&&ratio(h,bg)<4.5;i++){const n=parseInt(h.slice(1),16),c=[n>>16&255,n>>8&255,n&255].map(v=>Math.min(255,Math.round(v+(255-v)*0.12)));h='#'+c.map(v=>v.toString(16).padStart(2,'0')).join('');}return h;}
const toothText=(c,m)=>readable(toothHex(c,m),'#0e0e1a');
function poly(pts,a){return '<polyline points="'+pts.map(p=>f2(p[0])+','+f2(p[1])).join(' ')+'" fill="none" '+a+'/>';}

// ---- canvas layer (performance round): heavy geometry (meshes, orbits, trails, grids) is drawn on a 2D canvas UNDER the thin SVG overlay.
// The canvas uses the SVG viewBox coordinates (same meet transform), so a view draws in one coordinate system. Semantic elements keep living in the SVG:
// stubs carry the R17 data attributes (data-role, data-c, stroke, data-n); the projected points of every drawn run are recorded in layer.runs (see runs()).
// v0.4.3 (SCHEMA_ADDENDUM_11): resolution factor while the camera moves, by kind of drawing. 'wireframe' (every current view: strokes, points, grids, meshes drawn as lines) is FULL resolution.
// 'surface' (0.5) is kept, unused by any current view, for filled-surface rendering if it is ever added: a view opts in by passing 'surface' to layerBegin and layerFit.
const MOVING_RES={wireframe:1,surface:0.5};
const resFactor=(kind,moving)=>moving?(MOVING_RES[kind||'wireframe']):1;
const layer={rw:0,rh:0,ctx:null,cv:null,runs:[],marks:[],preview:false,moving:false,W:0,H:0};
function layerBegin(cv,W,H,kind){
  layer.runs=[];layer.marks=[];layer.cv=cv;layer.W=W;layer.H=H;layer.ctx=null;if(!cv)return null;
  // while the camera moves the displayed size cannot change: reuse the size measured by the last full render (getBoundingClientRect after an innerHTML write forces a layout), and draw at LOWRES of the pixels
  // (a moving picture; the full-resolution frame is drawn on release). The canvas bitmap is reallocated only when its size changes.
  let rw=layer.rw,rh=layer.rh;if(!(layer.moving&&rw>0&&rh>0)){const r=cv.getBoundingClientRect();rw=layer.rw=r.width;rh=layer.rh=r.height;}
  if(!(rw>0&&rh>0))return null;
  const dpr=Math.min(window.devicePixelRatio||1,2)*resFactor(kind,layer.moving||layer.preview),pw=Math.max(1,Math.round(rw*dpr)),ph=Math.max(1,Math.round(rh*dpr));
  if(cv.width!==pw||cv.height!==ph){cv.width=pw;cv.height=ph;}
  const ctx=cv.getContext('2d');ctx.setTransform(1,0,0,1,0,0);ctx.globalAlpha=1;ctx.fillStyle=palette().bgDeep;ctx.fillRect(0,0,pw,ph);
  const k=Math.min(pw/W,ph/H);ctx.setTransform(k,0,0,k,(pw-W*k)/2,(ph-H*k)/2);
  layer.ctx=ctx;return ctx;
}
function layerFit(cv,kind){                                   // does the canvas bitmap match its displayed size?
  if(!cv)return true;const r=cv.getBoundingClientRect(),dpr=Math.min(window.devicePixelRatio||1,2)*resFactor(kind,layer.moving||layer.preview);
  return !(r.width>0&&r.height>0)||(cv.width===Math.max(1,Math.round(r.width*dpr))&&cv.height===Math.max(1,Math.round(r.height*dpr)));
}
// draw one polyline run on the canvas; pts are view-space [x,y,...]; returns an SVG stub carrying the semantic attributes (no geometry)
function cvLine(pts,stroke,w,role,c,dash){
  const ctx=layer.ctx;if(ctx&&pts.length>1){ctx.beginPath();let lx=pts[0][0],ly=pts[0][1];ctx.moveTo(lx,ly);const n=pts.length-1;   // vertices closer than 0.25 view units to the last drawn one are not sent to the rasteriser (drawing only; the recorded run keeps every point)
    for(let i=1;i<n;i++){const x=pts[i][0],y=pts[i][1];if((x-lx)*(x-lx)+(y-ly)*(y-ly)>=0.0625){ctx.lineTo(x,y);lx=x;ly=y;}}ctx.lineTo(pts[n][0],pts[n][1]);ctx.strokeStyle=stroke;ctx.setLineDash(dash||[]);
    if(w>1&&w<=2&&!dash){const d=(w-1)/2*Math.SQRT1_2;ctx.lineWidth=1;   // a 1.6 px stroke on a 4000-point curve costs ~10x a 1 px stroke in the rasteriser (measured), so widths in (1, 2] are two 1 px passes offset by +-(w-1)/2 px: the same ink within 0.1 px
      ctx.save();ctx.translate(-d,-d);ctx.stroke();ctx.translate(2*d,2*d);ctx.stroke();ctx.restore();}
    else{ctx.lineWidth=w;ctx.stroke();}}
  if(pts.length>1)layer.runs.push({role,c:c===undefined?null:String(c),stroke,width:w,pts});
  return '<polyline points="" fill="none" stroke="'+stroke+'" stroke-width="'+w+'" data-role="'+role+'"'+(c===undefined?'':' data-c="'+c+'"')+' data-n="'+pts.length+'" data-layer="canvas"/>';
}
const layerRuns=()=>layer.runs.slice();
// ---- performance round 2: typed-array geometry. A view packs its 3D points ONCE per exact-state change into Float64Arrays (xyz, stride 3); a camera change only rotates and projects
// them (projectInto) and strokes the canvas. Nothing exact and no sample is recomputed.
function packXYZ(list){const a=new Float64Array(list.length*3);for(let i=0;i<list.length;i++){const p=list[i];a[3*i]=p[0];a[3*i+1]=p[1];a[3*i+2]=p[2];}return a;}
// the same rotation as rot() followed by the view's orthographic scaling: out = [cx + fit*h, cy - fit*v, depth]
function camMat(az,el){return {ca:Math.cos(az),sa:Math.sin(az),ce:Math.cos(el),se:Math.sin(el)};}
function projectInto(xyz,n,cm,fit,cx,cy,out){
  const ca=cm.ca,sa=cm.sa,ce=cm.ce,se=cm.se;
  for(let i=0,j=0;i<n;i++,j+=3){const x=xyz[j],y=xyz[j+1],z=xyz[j+2],d0=x*sa+y*ca;out[j]=cx+fit*(x*ca-y*sa);out[j+1]=cy-fit*(ce*z-se*d0);out[j+2]=se*z+ce*d0;}
}
// stroke points i0..i1 (inclusive, every `step`-th, always the last) of a projected buffer; records the run (lazy `pts`) and its bounding box of the drawn points
function cvRun(buf,i0,i1,step,stroke,w,role,c,record){
  if(!(i1>i0))return null;
  const ctx=layer.ctx,rec=record!==false;let x0=buf[3*i0],y0=buf[3*i0+1],x1=x0,y1=y0,lx=x0,ly=y0;
  if(ctx){ctx.beginPath();ctx.moveTo(lx,ly);}
  for(let i=i0+step;;i+=step){
    const last=i>=i1;if(last)i=i1;const x=buf[3*i],y=buf[3*i+1];
    if(rec){if(x<x0)x0=x;else if(x>x1)x1=x;if(y<y0)y0=y;else if(y>y1)y1=y;}      // bounding box of the drawn points (only for recorded runs)
    if(ctx&&(last||(x-lx)*(x-lx)+(y-ly)*(y-ly)>=0.0625)){ctx.lineTo(x,y);lx=x;ly=y;}   // vertices closer than 0.25 view units to the last drawn one are not sent to the rasteriser (the recorded run keeps every drawn point)
    if(last)break;}
  if(ctx){ctx.strokeStyle=stroke;ctx.setLineDash([]);
    if(w>1&&w<=2){const d=(w-1)/2*Math.SQRT1_2;ctx.lineWidth=1;ctx.save();ctx.translate(-d,-d);ctx.stroke();ctx.translate(2*d,2*d);ctx.stroke();ctx.restore();}   // two 1 px passes instead of one 1.6 px stroke (10x cheaper in the rasteriser, measured)
    else{ctx.lineWidth=w;ctx.stroke();}}
  if(!rec)return null;
  const run={role,c:c===undefined?null:String(c),stroke,width:w,buf,i0,i1,step,bb:[x0,y0,x1,y1],
    get pts(){const o=[];for(let i=i0;;i+=step){const l=i>=i1;if(l)i=i1;o.push([buf[3*i],buf[3*i+1]]);if(l)break;}return o;}};
  layer.runs.push(run);
  return run;
}
// a dot drawn on the canvas; the SVG gets a transparent proxy at the same position carrying the semantic attributes (data-role, data-c, data-t); the position is recorded (layerMarks)
function cvDot(x,y,r,fill,alpha,ring,ringW,role,c,t){
  const ctx=layer.ctx;
  if(ctx){ctx.globalAlpha=alpha;ctx.fillStyle=fill;ctx.beginPath();ctx.arc(x,y,r,0,6.283185307179586);ctx.fill();
    if(ring){ctx.globalAlpha=1;ctx.strokeStyle=ring;ctx.lineWidth=ringW;ctx.setLineDash([]);ctx.stroke();}ctx.globalAlpha=1;}
  layer.marks.push({role,c:c===undefined?null:String(c),t:t===undefined?null:t,x,y,r});
  return '<circle cx="'+f2(x)+'" cy="'+f2(y)+'" r="'+f2(r)+'" fill="transparent" data-role="'+role+'"'+(c===undefined?'':' data-c="'+c+'"')+(t===undefined?'':' data-t="'+t+'"')+' data-layer="canvas"/>';
}
// the hit-test proxy of a drawn curve (a whole branch orbit or trail): its bounding box (view units); invisible, never takes the pointer
function orbitProxy(role,c,t,stroke,bb,n){
  if(!bb)return '';layer.marks.push({role,c:String(c),t,branch:String(c),x0:bb[0],y0:bb[1],x1:bb[2],y1:bb[3]});
  return '<rect x="'+f2(bb[0])+'" y="'+f2(bb[1])+'" width="'+f2(bb[2]-bb[0])+'" height="'+f2(bb[3]-bb[1])+'" fill="none" stroke="'+stroke+'" stroke-opacity="0" pointer-events="none" data-role="'+role+'" data-c="'+c+'" data-branch="'+c+'" data-t="'+t+'" data-n="'+n+'" data-layer="canvas"/>';
}
const layerMarks=()=>layer.marks.slice();
// reduced register: every k-th point (and the last) of a packed curve, as its own packed array with its own projection buffer; built once per curve and k, so a moving camera projects ~300 points instead of 4000
function lodOf(ln,k){
  if(!(k>1))return ln;if(ln.lod&&ln.lod.k===k)return ln.lod;
  const idx=[];for(let i=0;i<ln.n;i+=k)idx.push(i);if(idx[idx.length-1]!==ln.n-1)idx.push(ln.n-1);
  const xyz=new Float64Array(3*idx.length);idx.forEach((i,q)=>{xyz[3*q]=ln.xyz[3*i];xyz[3*q+1]=ln.xyz[3*i+1];xyz[3*q+2]=ln.xyz[3*i+2];});
  ln.lod={k,xyz,n:idx.length,buf:new Float64Array(3*idx.length)};return ln.lod;
}
// every k-th index of 0..n-1, always keeping the last: the preview register coarsens the drawing only
function strideIdx(n,k){const a=[];for(let i=0;i<n;i+=k)a.push(i);if(a[a.length-1]!==n-1)a.push(n-1);return a;}
// ---- view state string  "fz=1.5;fx=0;..."  (characters limited to the address-safe set)
function vsParse(str,defaults){
  const o={...defaults};for(const part of String(str||'').split(';')){const i=part.indexOf('=');if(i>0){const k=part.slice(0,i);if(k in defaults)o[k]=part.slice(i+1);}}return o;
}
function vsStr(o,defaults){return Object.keys(o).filter(k=>String(o[k])!==String(defaults[k])).map(k=>k+'='+o[k]).join(';');}
const num=(v,d)=>{const x=parseFloat(v);return Number.isFinite(x)?x:d;};
const clamp=(x,a,b)=>Math.min(b,Math.max(a,x));
// ---- gestures: drag (with shift), wheel, two-finger pinch, tap. Calls back with plain numbers.
function gestures(el,cb){
  const ptr=new Map();let moved=0,pinch0=0,down=null,box=null;   // box: the element's rectangle, measured when a gesture starts (it cannot change during the gesture; measuring after every redraw would force a layout per move)
  const pos=e=>{const r=box||el.getBoundingClientRect(),vb=el.viewBox.baseVal;return [(e.clientX-r.left)*vb.width/r.width,(e.clientY-r.top)*vb.height/r.height];};
  el.addEventListener('pointerdown',e=>{try{el.setPointerCapture(e.pointerId);}catch(_){}if(ptr.size===0)box=el.getBoundingClientRect();ptr.set(e.pointerId,[e.clientX,e.clientY]);moved=0;down=pos(e);
    if(ptr.size===2){const [a,b]=[...ptr.values()];pinch0=Math.hypot(a[0]-b[0],a[1]-b[1]);}});
  el.addEventListener('pointermove',e=>{
    if(!ptr.has(e.pointerId))return;const prev=ptr.get(e.pointerId);ptr.set(e.pointerId,[e.clientX,e.clientY]);
    const r=box||el.getBoundingClientRect(),vb=el.viewBox.baseVal,kx=vb.width/r.width,ky=vb.height/r.height;
    if(ptr.size===2){const [a,b]=[...ptr.values()],d=Math.hypot(a[0]-b[0],a[1]-b[1]);if(pinch0>0&&d>0){cb.pinch&&cb.pinch(d/pinch0);pinch0=d;}moved+=9;}
    else{const dx=(e.clientX-prev[0])*kx,dy=(e.clientY-prev[1])*ky;moved+=Math.abs(dx)+Math.abs(dy);cb.drag&&cb.drag(dx,dy,e.shiftKey);}});
  const up=e=>{if(ptr.has(e.pointerId)){ptr.delete(e.pointerId);if(ptr.size===0&&moved<4&&down&&cb.tap)cb.tap(down[0],down[1],e.target);if(ptr.size===0&&cb.end)cb.end();}};
  el.addEventListener('pointerup',up);el.addEventListener('pointercancel',e=>{ptr.delete(e.pointerId);if(ptr.size===0&&cb.end)cb.end();});
  el.addEventListener('wheel',e=>{e.preventDefault();cb.wheel&&cb.wheel(e.deltaY<0?1:-1);},{passive:false});
}
// ---- 3D helpers: yaw about z, tilt/pitch about x, orthographic. Returns [screenX, screenY(up), depth(+ toward viewer)].
function rot(p,az,el){
  const ca=Math.cos(az),sa=Math.sin(az),ce=Math.cos(el),se=Math.sin(el);
  const h=p[0]*ca-p[1]*sa,d0=p[0]*sa+p[1]*ca;
  return [h,ce*p[2]-se*d0,se*p[2]+ce*d0];
}
function runs(pts,isFront){                              // split a projected polyline into front/back runs
  const out=[];let cur=null;
  for(const p of pts){const fr=isFront(p);if(!cur||cur.front!==fr){if(cur)cur.pts.push(p);cur={front:fr,pts:[p]};out.push(cur);}else cur.pts.push(p);}
  return out;
}
// ---- branch visibility (drawing register, Clifford tab): view key `ch`. '' = all visible; 'v:-3,2' = only those visible; 'h:0' = those hidden.
function branchVis(str){str=String(str||'');if(str.length<2||str[1]!==':')return ()=>true;const l=new Set(str.slice(2).split(',').filter(x=>x!==''));
  return str[0]==='v'?c=>l.has(String(c)):str[0]==='h'?c=>!l.has(String(c)):()=>true;}
function branchStr(vis,cs){const v=cs.filter(vis);if(v.length===cs.length)return '';return v.length*2<=cs.length?'v:'+v.map(String).join(','):'h:'+cs.filter(c=>!vis(c)).map(String).join(',');}
const api={MOVING_RES,resFactor,layer,layerBegin,layerFit,cvLine,layerRuns,layerMarks,packXYZ,lodOf,camMat,projectInto,cvRun,cvDot,orbitProxy,setQuiet,strideIdx,branchVis,branchStr,aboutOpen,aboutBlock,abt,abtReset,abouts,setFont,capReset,caps,cap,ratio,readable,toothText,register,registry,palette,toothHex,toothRgba,rgba,f2,esc,line,circle,text,poly,vsParse,vsStr,num,clamp,gestures,rot,runs};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVViews=api;
})(typeof globalThis!=='undefined'?globalThis:this);
