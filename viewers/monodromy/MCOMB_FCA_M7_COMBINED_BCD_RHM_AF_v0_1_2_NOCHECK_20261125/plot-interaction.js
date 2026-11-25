/* Display-only cameras and point inspection. No writes to curve, source or evidence APIs. */
(()=>{
 'use strict';
 const $=id=>document.getElementById(id),ns='http://www.w3.org/2000/svg',scenes=new Map();
 const names={C:'C · carrier',Pplus:'P+ · positive tooth',Pminus:'P− · negative tooth',sum:'S = 2C',R:'R = −2C'},roles=Object.keys(names);
 let complexCache=null;
 const number=q=>{if(q&&typeof q==='object')return Number(q.num)/Number(q.den);const [n,d='1']=String(q).split('/');return Number(n)/Number(d);};
 const fraction=q=>typeof q==='object'?q.den==='1'?q.num:q.num+'/'+q.den:String(q);
 const fmt=n=>Number.isFinite(n)?String(Number(n.toPrecision(12))):String(n);
 const complex=z=>z?fmt(z[0])+(z[1]<0?' − ':' + ')+fmt(Math.abs(z[1]))+'i':'O / unavailable';
 const el=(name,attrs={})=>{const e=document.createElementNS(ns,name);for(const[k,v]of Object.entries(attrs))e.setAttribute(k,v);return e;};
 const json=x=>JSON.stringify(x),coeff=()=>{const m=BSDEvidenceV1.snapshot().curve.model;return [number(m.A),number(m.B)];};
 const point=(x,y,title,lines)=>({x,y,title,lines});
 const style=document.createElement('style');style.textContent=`
 .plot-explorer{min-width:0;position:relative;margin:6px 0 10px;font:12px/1.5 system-ui;color:#dcecf4}
 .plot-tools{display:flex;flex-wrap:wrap;gap:4px;align-items:center;margin:5px 0}
 .plot-tools button{min-width:32px;min-height:32px;padding:4px 8px!important;border:1px solid #64818b;border-radius:4px;background:#142c3a;color:#e1f3f5;font:inherit;cursor:pointer}
 .plot-tools button:disabled{opacity:.4;cursor:default}.plot-tools :focus-visible,.plot-surface:focus-visible{outline:2px solid #ffda7a;outline-offset:2px}
 .plot-surface{touch-action:none;cursor:grab;overflow:hidden}.plot-surface:active{cursor:grabbing}
 .plot-surface svg,svg.plot-surface{display:block!important;width:100%!important;min-width:0!important;max-width:none!important;height:auto!important;overflow:hidden}
 .plot-help{color:#a9c6d1;margin:4px 0}.plot-tools output{font-variant-numeric:tabular-nums;color:#a6efda}
 #plot-point-tooltip{position:fixed;z-index:100000;max-width:min(410px,calc(100vw - 20px));box-sizing:border-box;padding:12px 14px;border:1px solid #ffda7a;border-radius:7px;background:#0c1b28;color:#e9f4fc;box-shadow:0 6px 28px #0009;font:13px/1.5 system-ui;max-height:min(430px,65vh);overflow:auto;overflow-wrap:anywhere}
 #plot-point-tooltip[hidden]{display:none}#plot-point-tooltip h4{margin:5px 36px 5px 0;color:#ffda7a}#plot-point-tooltip p{margin:3px 0;white-space:pre-wrap}#plot-point-tooltip hr{border:0;border-top:1px solid #426071}
 #plot-point-tooltip button{float:right;background:#183244;color:#fff;border:1px solid #64818b;border-radius:4px;padding:3px 8px;cursor:pointer}
 #cy-kernel{min-width:0!important}#fp-plot svg{background:#081620;border-radius:5px}
 `;document.head.append(style);
 const tip=document.createElement('aside');tip.id='plot-point-tooltip';tip.hidden=true;tip.setAttribute('role','dialog');tip.setAttribute('aria-label','Plot point details');
 const close=document.createElement('button');close.type='button';close.textContent='×';close.setAttribute('aria-label','Close point details');tip.append(close);const content=document.createElement('div');tip.append(content);document.body.append(tip);let pinned=null;
 function dismiss(){if(pinned?.scene)pinned.scene.selected=-1;pinned=null;tip.hidden=true;content.replaceChildren();}
 let tooltipEscape=false;
 close.onclick=dismiss;document.addEventListener('keydown',e=>{if(e.key==='Escape'&&pinned){tooltipEscape=true;dismiss();e.preventDefault();e.stopPropagation();}},true);
 // The inherited viewer toggles fullscreen on Escape keyup, so consume the paired release too.
 window.addEventListener('keyup',e=>{if(e.key==='Escape'&&tooltipEscape){tooltipEscape=false;e.preventDefault();e.stopImmediatePropagation();}},true);
 function screen(scene,p){return new DOMPoint(p.x,p.y).matrixTransform(scene.svg.getScreenCTM());}
 function place(){if(!pinned)return;const {scene,points}=pinned;if(!scene.svg?.isConnected||!scene.svg.getClientRects().length){dismiss();return;}const p=screen(scene,points[0]),r=scene.svg.getBoundingClientRect();if(p.x<r.left-5||p.x>r.right+5||p.y<r.top-5||p.y>r.bottom+5||r.bottom<0||r.top>innerHeight){tip.hidden=true;return;}tip.hidden=false;const w=tip.offsetWidth,h=tip.offsetHeight;tip.style.left=Math.max(10,Math.min(innerWidth-w-10,p.x+14))+'px';tip.style.top=Math.max(10,Math.min(innerHeight-h-10,p.y+14))+'px';}
 window.addEventListener('scroll',place,true);window.addEventListener('resize',place);
 function inspect(scene,points){if(!points.length)return;content.replaceChildren();for(const [i,p]of points.entries()){if(i)content.append(document.createElement('hr'));const title=document.createElement('h4');title.textContent=p.title;content.append(title);for(const text of p.lines){const e=document.createElement('p');e.textContent=text;content.append(e);}}const end=document.createElement('p');end.textContent='Inspection only · no evidence is recorded.';end.style.color='#a9c6d1';content.append(end);pinned={scene,points,key:scene.key};tip.hidden=false;place();}
 function record(role,p){return [names[role]||role,[`Exact period address: (α, β) = (${p.phase.alpha}, ${p.phase.beta})`,p.exactPoint?p.exactPoint.infinity?'Exact lattice origin: O at infinity':`Exactly checked rational point: (${p.exactPoint.x}, ${p.exactPoint.y})`:'Rational coordinates not established',`Numerical cubic x ≈ ${complex(p.numerical.x)}\ny ≈ ${complex(p.numerical.y)}`]];}
 function cubic(a,b,ox,oy,sx,sy){return {a,b,ox,oy,sx,sy,xy:(x,y)=>[ox+sx*x,oy-sy*y]};}
 function mapPoint(c,x,y,title,lines){return point(...c.xy(x,y),title,lines);}
 function real(n){return n?.x&&n?.y&&Math.abs(n.x[1])+Math.abs(n.y[1])<1e-8*(1+Math.abs(n.x[0])+Math.abs(n.y[0]));}
 function descriptor(id,svg,base){
  const out={key:'',points:[],cubic:null,note:'Coordinates on screen are numerical; exact fields are labelled.'};
  if(id==='family-plot'){
   const q=BSDCurveFamilyPanelV1.snapshot().preview,p=BSDCurveFamilyV1.plot(q.a,q.b),w=base[2];
   out.key='family:'+q.key;const sx=(w-85)/(p.xDomain[1]-p.xDomain[0]),sy=215/(p.yDomain[1]-p.yDomain[0]);out.cubic=cubic(q.a,q.b,65-p.xDomain[0]*sx,235+p.yDomain[0]*sy,sx,sy);out.note='Click the curve for numerical coordinates. O lies at infinity.';return out;
  }
  if(id==='cy-kernel'){
   const state=McombCayleyInspectorV1.state,q=McombCayleyAdapterV1.store.record?.quotientRecord;if(!q)throw Error('No current spectral capture');
   const subtract=state.operator==='SIMPLE'?Number(q.simpleConversion.subtractIdentity):0,m=Number(q.rowSum);
   out.key=json([state.packetDigest,state.grid,state.operator]);
   for(const s of (state.result?.values||[]).slice(0,256))out.points.push(point(45+680*number(s.turns),120-85*(s.value-subtract)/Math.max(m,1),'Fourier sample '+s.index,[`Grid: ${state.grid.kind}, modulus ${state.grid.modulus}`,`Exact index ${s.index}; exact turns ${fraction(s.turns)}`,`Operator: ${state.operator==='SIMPLE'?'L − '+subtract+'I (collision guard passed)':'L · weighted translations'}`,`Eigenvalue ≈ ${fmt(s.value-subtract)} (Float64, not a bound)`,'Spectral register only; no elliptic rank or BSD inference.']));
   out.note='Click a plotted Fourier sample. Curve is a finite numerical drawing.';return out;
  }
  if(id==='v1-lattice'){
   const q=BSDLinkedReductionV1.current;if(!q)throw Error('Verifier unavailable');const v=q.packet.view;out.key=v.contextId;
   out.points=[point(30+340*number(v.phase.marked[0]),230-210*number(v.phase.marked[1]),'Selected marked phase',[`Exact marked address: (${v.phase.marked.join(', ')})`,`Original address: (${v.phase.original.join(', ')})`,`Basis matrix: ${json(v.binding.basisMatrix)}`,'Exact phase does not establish rational cubic coordinates.'])];return out;
  }
  if(BSDEvidenceV1.stale)throw Error('Curve edit pending');const curve=BSDEvidenceV1.snapshot().curve;
  if(id==='fp-plot'){
   const q=FinitePrimeProductV1.current;if(!q)throw Error('Counts unavailable');out.key=json([q.contextId,q.cutoff]);
   const values=[1,...q.samples.map(s=>number(s.product))],lo=Math.min(...values)*.85,hi=Math.max(...values)*1.15;
   out.points=q.samples.map(s=>{const f=q.factors.find(r=>r.p===s.p);return point(50+620*(Number(s.p)-1)/Math.max(1,q.cutoff-1),190-145*(number(s.product)-lo)/(hi-lo||1),'Good prime p = '+s.p,[`Exact Nₚ = ${f.points} (including O); aₚ = ${f.ap}`,`Exact local factor Lₚ(1) = ${s.p}/${f.points}`,`Exact partial product = ${s.product.num}/${s.product.den}`,`Product ≈ ${fmt(number(s.product))} (Float64 label)`,'Displayed-model good primes only. Finite product; no limit or rank claimed.']);});out.note='Click a prime sample for exact counts and its finite partial product.';return out;
  }
  const carrier=CarrierAdditionV1.current;
  if(id==='ca-torus'||id==='ca-cubic'){
   if(!carrier||carrier.contextId!==curve.contextId)throw Error('Carrier unavailable');const q=carrier.addition;out.key=json([carrier.contextId,carrier.capture,q.exact.pairOffset]);
   if(id==='ca-torus')for(const role of roles){const p=q.points[role],[title,lines]=record(role,p);out.points.push(point(45+345*number(p.phase.alpha),255-220*number(p.phase.beta),title,lines));}
   else{const [a,b]=coeff(),scale=Math.max(1,Math.sqrt(Math.abs(a)),Math.cbrt(Math.abs(b))),rs=roles.map(r=>[r,q.points[r]]).filter(([,p])=>real(p.numerical)),xr=Math.max(2.5*scale,...rs.map(([,p])=>Math.min(8*scale,Math.abs(p.numerical.x[0])*1.2))),yr=Math.sqrt(xr**3+Math.abs(a)*xr+Math.abs(b))*1.05;
    out.cubic=cubic(a,b,220,150,185/xr,122/yr);out.realLine=q.numerical.line.realLine;
    for(const[role,p]of rs){const [title,lines]=record(role,p);out.points.push(mapPoint(out.cubic,p.numerical.x[0],p.numerical.y[0],title,lines));}
   }out.note='Click a marked point or curve. Coincident roles remain separate records.';return out;
  }
  if(id==='eb-chart'){
   const s=CliffordEllipticBridgeV27.snapshot(),r=svg.querySelector('rect');if(!r)throw Error('Marked period unavailable');const x=+r.getAttribute('x'),y=+r.getAttribute('y'),w=+r.getAttribute('width'),h=+r.getAttribute('height'),p=s.selectedPoint;
   out.key=json([curve.contextId,s.marking,p]);
   if(p){const coords=p.coordinates.map(fraction);out.points.push(point(x+w*number(p.coordinates[0]),y+h-h*number(p.coordinates[1]),'Mcomb marked phase',[`Exact displayed address: (${coords.join(', ')})`,`Exact complex torsion order: ${p.order}`,'Cubic-coordinate rationality is not inferred.',`Marking: ${s.marking.folded?'folded':'model basis'}`]));}
   if(svg.querySelector('[data-carrier-overlay]')&&carrier?.contextId===curve.contextId)for(const role of roles){const p=carrier.addition.points[role],[title,lines]=record(role,p);let a=number(p.phase.alpha),b=number(p.phase.beta);if(s.marking.folded)[a,b]=[b,((1-a)%1+1)%1];out.points.push(point(x+w*a,y+h-h*b,title,[...lines,`Displayed in ${s.marking.folded?'folded':'model'} marking.`]));}
   return out;
  }
  const q=McombEllipticLink.current;if(!q||q.contextId!==curve.contextId)throw Error('Mcomb image unavailable');out.key=json([q.contextId,q.capture]);
  const selected=q.transport.rows.find(r=>r.address.c===q.capture.selection.c)||q.transport.rows[0];
  const rowDetails=r=>[`Exact phase: (${r.phase.alpha}, ${r.phase.beta})`,`Address: c=${r.address.c}, s=${q.transport.source.s}, N=${q.transport.source.N}`,`Numerical x ≈ ${complex(r.numerical.x)}\ny ≈ ${complex(r.numerical.y)}`,'Numerical image is not rational-point evidence.'];
  if(id==='me-real'){
   const [a,b]=coeff(),xr=2.5*Math.max(1,Math.sqrt(Math.abs(a)),Math.cbrt(Math.abs(b))),yr=Math.sqrt(xr**3+Math.abs(a)*xr+Math.abs(b))*1.08;out.cubic=cubic(a,b,205,140,175/xr,120/yr);
   for(const t of q.transport.rational.rationalTwoTorsion)out.points.push(mapPoint(out.cubic,number(t.point.x),0,'Exact rational two-torsion',[`Exact point: (${t.point.x}, 0)`,`Exact period address: (${t.phase.alpha}, ${t.phase.beta})`,'Rational polynomial check; inspection does not add a BSD record.']));
   if(real(selected.numerical))out.points.push(mapPoint(out.cubic,selected.numerical.x[0],selected.numerical.y[0],'Selected c = '+selected.address.c,rowDetails(selected)));
  }else if(id==='me-complex'){
   if(complexCache?.key===out.key)return complexCache;
   const E=McombElliptic,model=E.curve(curve.effectiveInput),paths=q.capture.visibleOffsets.map(c=>({c,...E.path(model,q.transport.source,c,96)}));
   const vals=paths.flatMap(p=>p.points.filter(x=>x.x).map(x=>Math.max(Math.abs(x.x[0]),Math.abs(x.x[1])))).filter(Number.isFinite).sort((a,b)=>a-b),lim=Math.max(1,Math.min(50,Math.max(vals[Math.floor(vals.length*.8)]||3,selected.numerical.x?1.15*Math.max(...selected.numerical.x.map(Math.abs)):0)));
   if(selected.numerical.x)out.points.push(point(205+170*selected.numerical.x[0]/lim,140-115*selected.numerical.x[1]/lim,'Selected c = '+selected.address.c,rowDetails(selected)));
   for(const path of paths)for(const [i,p]of path.points.entries())if(p.x&&Math.abs(p.x[0])<=lim&&Math.abs(p.x[1])<=lim)out.points.push(point(205+170*p.x[0]/lim,140-115*p.x[1]/lim,'Branch c = '+path.c+' · sampled position '+i,[`Numerical complex x ≈ ${complex(p.x)}`,p.y?`Numerical complex y ≈ ${complex(p.y)}`:'Projection retains x only at this sample.','Inherited finite path sample; not exact point membership.']));
   out.note='Click a branch sample or selected point. Paths retain their original finite sampling.';complexCache=out;
  }
  return out;
 }
 function roots(a,b){const d=4*a*a*a+27*b*b;if(d>0){const t=Math.sqrt(d/108);return [Math.cbrt(-b/2+t)+Math.cbrt(-b/2-t)];}if(a===0)return [0];const r=2*Math.sqrt(-a/3),t=Math.acos(Math.max(-1,Math.min(1,3*b/(2*a)*Math.sqrt(-3/a))))/3;return [0,1,2].map(k=>r*Math.cos(t-2*Math.PI*k/3)).sort((x,y)=>x-y);}
 function redrawCubic(scene){
  const c=scene.data?.cubic;if(!c)return;const box=scene.box,xlo=Math.max(-1e6,(box[0]-c.ox)/c.sx),xhi=Math.min(1e6,(box[0]+box[2]-c.ox)/c.sx),rs=roots(c.a,c.b),intervals=rs.length===3?[[rs[0],rs[1]],[rs[2],xhi]]:[[rs[0],xhi]],paths=[];
  for(const [start,end]of intervals){const l=Math.max(start,xlo),r=Math.min(end,xhi);if(r<l)continue;let upper='',lower='';for(let i=0;i<=320;i++){const x=l+(r-l)*Math.sin(i*Math.PI/640)**2,v=x*x*x+c.a*x+c.b;if(v< -1e-8*(1+Math.abs(x*x*x)))continue;const y=Math.sqrt(Math.max(0,v)),p=c.xy(x,y),n=c.xy(x,-y);upper+=(upper?'L':'M')+p.join(',')+' ';lower+=(lower?'L':'M')+n.join(',')+' ';}paths.push(upper+' '+lower);}
  const old=[...scene.svg.querySelectorAll(':scope > path')];if(old.length){old[0].setAttribute('d',paths.join(' '));for(const p of old.slice(1))p.setAttribute('d','');}
  const label=[...scene.svg.querySelectorAll(':scope > text')].find(e=>e.textContent.startsWith('x ∈ ['));if(label){const text=`x ∈ [${fmt(xlo)}, ${fmt(xhi)}] · numerical view`;if(label.textContent!==text)label.textContent=text;}
  const line=scene.svg.querySelector(':scope > line[stroke="#c69aff"]');if(line&&scene.data.realLine){const[a,b,d]=scene.data.realLine,ylo=(c.oy-box[1]-box[3])/c.sy,yhi=(c.oy-box[1])/c.sy,ps=[];if(Math.abs(b)>1e-10)for(const x of [xlo,xhi]){const y=-(a*x+d)/b;if(y>=ylo&&y<=yhi)ps.push(c.xy(x,y));}if(Math.abs(a)>1e-10)for(const y of [ylo,yhi]){const x=-(b*y+d)/a;if(x>=xlo&&x<=xhi)ps.push(c.xy(x,y));}line.setAttribute('visibility',ps.length>=2?'visible':'hidden');if(ps.length>=2)for(const[k,v]of Object.entries({x1:ps[0][0],y1:ps[0][1],x2:ps[1][0],y2:ps[1][1]}))line.setAttribute(k,v);}
 }
 function mount(id){
  const host=$(id);if(!host)return;const shell=document.createElement('div');shell.className='plot-explorer';shell.dataset.plot=id;host.before(shell);shell.append(host);
  const tools=document.createElement('div');tools.className='plot-tools';tools.setAttribute('role','group');tools.setAttribute('aria-label','Plot camera and point inspection');shell.prepend(tools);
  const help=document.createElement('p');help.className='plot-help';help.textContent='Drag to pan · wheel / pinch to zoom · click a point for details.';host.after(help);
  const scene={id,host,shell,tools,help,svg:null,key:null,data:null,base:null,zoom:1,cx:.5,cy:.5,box:null,selected:-1,pointers:new Map(),drag:null,suppress:false};scenes.set(id,scene);
  const buttons={};for(const [action,label,aria]of [['in','+','Zoom in'],['out','−','Zoom out'],['reset','Reset view','Reset view'],['left','←','Pan left'],['right','→','Pan right'],['up','↑','Pan up'],['down','↓','Pan down'],['previous','‹ Point','Previous point'],['next','Point ›','Next point']]){const b=document.createElement('button');b.type='button';b.dataset.plotAction=action;b.textContent=label;b.setAttribute('aria-label',aria);b.onclick=()=>actionRun(action);tools.append(b);buttons[action]=b;}
  const status=document.createElement('output');tools.append(status);host.classList.add('plot-surface');host.tabIndex=0;host.setAttribute('aria-label',(host.getAttribute('aria-label')||id)+' · drag to pan, wheel to zoom, arrow keys and Home');
  function paint(){if(!scene.svg||!scene.base)return;const[x,y,w,h]=scene.base;scene.box=[x+scene.cx*w-w/scene.zoom/2,y+scene.cy*h-h/scene.zoom/2,w/scene.zoom,h/scene.zoom];scene.svg.setAttribute('viewBox',scene.box.join(' '));status.textContent=fmt(scene.zoom)+'×';redrawCubic(scene);place();}
  function reset(){scene.zoom=1;scene.cx=scene.cy=.5;paint();}
  function world(x,y){return new DOMPoint(x,y).matrixTransform(scene.svg.getScreenCTM().inverse());}
  function zoom(f,x,y){if(!scene.svg)return;const [bx,by,bw,bh]=scene.base,anchor=x==null?{x:bx+scene.cx*bw,y:by+scene.cy*bh}:world(x,y),old=scene.zoom,next=Math.max(.05,Math.min(256,old*f)),c={x:bx+scene.cx*bw,y:by+scene.cy*bh};scene.cx=(anchor.x+(c.x-anchor.x)*old/next-bx)/bw;scene.cy=(anchor.y+(c.y-anchor.y)*old/next-by)/bh;scene.zoom=next;paint();}
  function pan(x,y){if(!scene.svg)return;scene.cx=Math.max(-1e4,Math.min(1e4,scene.cx+x/scene.zoom));scene.cy=Math.max(-1e4,Math.min(1e4,scene.cy+y/scene.zoom));paint();}
  function choose(i){const ps=scene.data?.points||[];if(!ps.length)return;scene.selected=(i+ps.length)%ps.length;const p=ps[scene.selected];scene.cx=(p.x-scene.base[0])/scene.base[2];scene.cy=(p.y-scene.base[1])/scene.base[3];paint();const s=screen(scene,p),same=ps.filter(q=>{const t=screen(scene,q);return Math.hypot(s.x-t.x,s.y-t.y)<3;});inspect(scene,same);}
  function actionRun(a){refresh();if(!scene.svg)return;if(a==='in')zoom(1.4);else if(a==='out')zoom(1/1.4);else if(a==='reset'){dismiss();reset();}else if(a==='previous'||a==='next')choose(scene.selected+(a==='next'?1:-1));else pan(a==='left'?-.15:a==='right'?.15:0,a==='up'?-.15:a==='down'?.15:0);}
  scene.actions={reset,zoom,pan,choose};
  host.addEventListener('wheel',e=>{if(!scene.svg)return;e.preventDefault();e.stopPropagation();zoom(Math.exp(-Math.max(-150,Math.min(150,e.deltaY))*.004),e.clientX,e.clientY);},{passive:false});
  const gesture=()=>{const p=[...scene.pointers.values()];return p.length<2?null:{x:(p[0].x+p[1].x)/2,y:(p[0].y+p[1].y)/2,d:Math.hypot(p[0].x-p[1].x,p[0].y-p[1].y)};};
  host.addEventListener('pointerdown',e=>{if(!scene.svg||e.button!==0)return;scene.pointers.set(e.pointerId,{x:e.clientX,y:e.clientY});scene.suppress=false;scene.drag={x:e.clientX,y:e.clientY,startX:e.clientX,startY:e.clientY,moved:false,pinch:gesture()};if(e.pointerType==='touch'){host.setPointerCapture(e.pointerId);e.preventDefault();}});
  host.addEventListener('pointermove',e=>{if(!scene.pointers.has(e.pointerId))return;const d=scene.drag;if(e.pointerType==='mouse'&&(e.buttons&1)===0){end(e);return;}const before=gesture();scene.pointers.set(e.pointerId,{x:e.clientX,y:e.clientY});const after=gesture();if(before&&after){d.moved=true;const w0=world(before.x,before.y),w1=world(after.x,after.y);scene.cx-=(w1.x-w0.x)/scene.base[2];scene.cy-=(w1.y-w0.y)/scene.base[3];paint();if(before.d>1&&after.d>1)zoom(after.d/before.d,after.x,after.y);e.preventDefault();return;}if(!d.moved&&Math.hypot(e.clientX-d.startX,e.clientY-d.startY)<4)return;d.moved=true;if(!host.hasPointerCapture(e.pointerId))host.setPointerCapture(e.pointerId);const w0=world(d.x,d.y),w1=world(e.clientX,e.clientY);scene.cx-=(w1.x-w0.x)/scene.base[2];scene.cy-=(w1.y-w0.y)/scene.base[3];d.x=e.clientX;d.y=e.clientY;paint();e.preventDefault();});
  function end(e){if(!scene.pointers.has(e.pointerId))return;scene.pointers.delete(e.pointerId);scene.suppress=!!scene.drag?.moved;if(host.hasPointerCapture(e.pointerId))host.releasePointerCapture(e.pointerId);if(!scene.pointers.size)scene.drag=null;else{const p=[...scene.pointers.values()][0];scene.drag={...p,startX:p.x,startY:p.y,moved:true};}setTimeout(()=>{scene.suppress=false;},0);}
  window.addEventListener('pointerup',end);window.addEventListener('pointercancel',end);window.addEventListener('blur',()=>{for(const id of scene.pointers.keys())end({pointerId:id});});
  host.addEventListener('click',e=>{if(scene.suppress){e.preventDefault();e.stopImmediatePropagation();return;}refresh();if(!scene.svg||!scene.data)return;const ps=scene.data.points,near=ps.map(p=>({p,s:screen(scene,p)})).map(q=>({...q,d:Math.hypot(q.s.x-e.clientX,q.s.y-e.clientY)})).filter(q=>q.d<=12).sort((a,b)=>a.d-b.d);let selected=[];
   if(near.length){const s=near[0].s;selected=near.filter(q=>Math.hypot(q.s.x-s.x,q.s.y-s.y)<3).map(q=>q.p);scene.selected=ps.indexOf(selected[0]);}
   else if(scene.data.cubic){const c=scene.data.cubic,w=world(e.clientX,e.clientY),x=(w.x-c.ox)/c.sx,v=x*x*x+c.a*x+c.b;if(v>=0&&Math.abs(x)<=1e6){const y=(w.y>c.oy?-1:1)*Math.sqrt(v),p=mapPoint(c,x,y,'Numerical point on the real curve',[`x ≈ ${fmt(x)}\ny ≈ ${fmt(y)}`,'Float64 evaluation of y² = x³ + ax + b.','No exact rational coordinates or period address are inferred.']);const s=screen(scene,p);if(Math.hypot(s.x-e.clientX,s.y-e.clientY)<=14)selected=[p];}}
   if(selected.length){e.preventDefault();if(id!=='me-real')e.stopImmediatePropagation();inspect(scene,selected);}else if(pinned?.scene===scene)dismiss();
  },true);
  shell.addEventListener('keydown',e=>{const actions={ArrowLeft:'left',ArrowRight:'right',ArrowUp:'up',ArrowDown:'down','+':'in','=':'in','-':'out',Home:'reset','[':'previous',']':'next'};if(actions[e.key]&&(e.target===host||e.target===scene.svg)){e.preventDefault();e.stopPropagation();actionRun(actions[e.key]);}else if(['ArrowLeft','ArrowRight','ArrowUp','ArrowDown'].includes(e.key))e.stopPropagation();});
  let queued=false;function later(){if(queued)return;queued=true;requestAnimationFrame(()=>{queued=false;refresh();});}
  function refresh(){
   const svg=host.tagName.toLowerCase()==='svg'?host:host.querySelector('svg');let data=null,base=null;try{if(svg){const raw=svg.getAttribute('viewBox').split(/[ ,]+/).map(Number);base=!scene.base||json(raw)!==json(scene.box)?raw:scene.base;data=descriptor(id,svg,base);}}catch{}
   if(!svg||!data){if(pinned?.scene===scene)dismiss();scene.svg=null;scene.key=null;scene.data=null;for(const b of Object.values(buttons))b.disabled=true;status.textContent='Unavailable';return;}
   const changed=scene.key!==data.key,replaced=scene.svg!==svg;scene.data=data;
   scene.svg=svg;scene.base=base;svg.style.aspectRatio=base[2]+'/'+base[3];
   if(changed){if(pinned?.scene===scene)dismiss();scene.key=data.key;scene.selected=-1;scene.zoom=1;scene.cx=scene.cy=.5;}
   for(const b of Object.values(buttons))b.disabled=false;buttons.previous.disabled=buttons.next.disabled=!data.points.length;
   help.textContent='Drag to pan · wheel / pinch to zoom · click for details. '+data.note;
   paint();
  }
  scene.refresh=refresh;new MutationObserver(later).observe(host,{childList:true,subtree:true});new ResizeObserver(()=>{if(scene.svg)paint();}).observe(host);refresh();
 }
 for(const id of ['ca-cubic','ca-torus','me-real','me-complex','eb-chart','fp-plot','cy-kernel','v1-lattice','family-plot'])mount(id);
 // Context edits clear details before any delayed redraw can reuse old coordinates.
 const refreshAll=()=>{for(const s of scenes.values())s.refresh();};
 window.addEventListener('mcomb:curve',()=>{dismiss();requestAnimationFrame(refreshAll);});
 window.addEventListener('mcomb:cayley-source',()=>{dismiss();requestAnimationFrame(refreshAll);});
 setInterval(()=>{if(document.visibilityState!=='hidden')refreshAll();},700);
 window.BSDPlotInteractionV1=Object.freeze({refresh:refreshAll,snapshot(id){const s=scenes.get(id);return s?{id,key:s.key,zoom:s.zoom,center:[s.cx,s.cy],viewBox:s.box,points:s.data?.points||[],tooltip:pinned?.scene===s?pinned.points:null,arithmeticPromotion:false}:null;},get ids(){return [...scenes.keys()];}});
})();
