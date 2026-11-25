/* Display-only SVG cameras. No arithmetic, selection, or packet writes. */
(()=>{'use strict';
const targets=['m4-planar','m4-address-graph','m7-diagram'];
const notice=document.createElement('p');notice.textContent='Camera preview · pan / zoom / fit added to atom and FCA diagrams · sealed M7 remains unchanged';notice.style.cssText='padding:10px;border:1px solid #365969;color:#ffdb78';document.getElementById('m7-panel')?.prepend(notice);
const style=document.createElement('style');style.textContent=`
.diagram-camera-tools{display:flex;flex-wrap:wrap;gap:4px;align-items:center;margin:8px 0}.diagram-camera-tools button{min-width:36px;min-height:36px}.diagram-camera-tools output{font-size:12px;margin-left:5px}
#m4-planar,#m4-address-graph,#m7-diagram{overflow:hidden!important;max-height:none!important}
#m4-planar svg,#m4-address-graph svg,#m7-diagram svg{display:block;width:100%!important;min-width:0!important;height:360px!important;touch-action:none;cursor:grab;border:1px solid #365969;border-radius:5px;background:#081820}
#m7-diagram svg{height:480px!important} .diagram-camera-help{font-size:12px;color:#aac4cc;margin:5px 0}
`;document.head.append(style);
for(const id of targets){const box=document.getElementById(id);if(!box)continue;
let svg,base=null,view=null,signature='',zoom=1,suppressUntil=0;
const toolbar=document.createElement('div');toolbar.className='diagram-camera-tools';toolbar.setAttribute('role','group');toolbar.setAttribute('aria-label',id+' camera');toolbar.dataset.camera=id;
const out=document.createElement('output');out.setAttribute('aria-live','polite');
const help=document.createElement('p');help.className='diagram-camera-help';help.textContent='Drag to pan · wheel or pinch to zoom · arrows to pan, +/− to zoom, Home to fit when the diagram is focused.';
box.before(toolbar);box.after(help);
const buttons=[];function button(text,title,fn){const b=document.createElement('button');b.type='button';b.textContent=text;b.title=title;b.setAttribute('aria-label',title);b.onclick=fn;toolbar.append(b);buttons.push(b);return b;}
function paint(){if(!svg||!view)return;svg.setAttribute('viewBox',view.join(' '));out.textContent=Math.round(zoom*100)+'%';}
function fit(){if(!base)return;view=base.slice();zoom=1;paint();}
function pan(dx,dy){if(!view)return;view[0]+=dx*view[2];view[1]+=dy*view[3];paint();}
function point(x,y){const p=svg.createSVGPoint();p.x=x;p.y=y;return p.matrixTransform(svg.getScreenCTM().inverse());}
function scale(f,x,y){if(!view)return;const next=Math.max(.25,Math.min(20,zoom*f)),ratio=zoom/next;const cx=x??view[0]+view[2]/2,cy=y??view[1]+view[3]/2;view=[cx+(view[0]-cx)*ratio,cy+(view[1]-cy)*ratio,view[2]*ratio,view[3]*ratio];zoom=next;paint();}
function focus(){if(!svg)return;let node;
if(id.startsWith('m4-')){const address=window.McombAtomAdapterV1?.inspection()?.points?.[0]?.exponents?.join(',');node=[...svg.querySelectorAll('circle[data-address]')].find(n=>n.dataset.address===address);if(!node)node=svg.querySelector('circle[data-walk-hit="true"]');}
else{const select=document.getElementById('m7-divisor'),label=select?.selectedOptions[0]?.textContent.split(' · ')[0];const text=[...svg.querySelectorAll('text')].find(n=>n.textContent===label);if(text){const x=Number(text.getAttribute('x'))-10,y=Number(text.getAttribute('y'))-4;node=[...svg.querySelectorAll('circle')].find(n=>Number(n.getAttribute('cx'))===x&&Number(n.getAttribute('cy'))===y);}}
if(!node){out.textContent='Select a visible divisor first';return;}const x=Number(node.getAttribute('cx')),y=Number(node.getAttribute('cy'));zoom=Math.max(zoom,2);view=[x-base[2]/zoom/2,y-base[3]/zoom/2,base[2]/zoom,base[3]/zoom];paint();}
button('+','Zoom in',()=>scale(1.4));button('−','Zoom out',()=>scale(1/1.4));button('Fit / reset','Fit entire diagram and reset camera',fit);button('←','Pan left',()=>pan(-.15,0));button('→','Pan right',()=>pan(.15,0));button('↑','Pan up',()=>pan(0,-.15));button('↓','Pan down',()=>pan(0,.15));button('Focus divisor','Focus selected visible divisor',focus);toolbar.append(out);
function attach(){const next=box.querySelector('svg');if(next===svg)return;svg=next;buttons.forEach(b=>b.disabled=!svg);if(!svg){out.textContent='No diagram';return;}
const original=svg.getAttribute('viewBox').split(/\s+/).map(Number);const sig=original.join(',')+'|'+[...svg.querySelectorAll('circle')].map(n=>[n.getAttribute('cx'),n.getAttribute('cy'),n.dataset.address||''].join(',')).join(';')+'|'+[...svg.querySelectorAll('text')].map(n=>n.textContent).join(';');base=original;if(sig!==signature||!view){signature=sig;fit();}else paint();
svg.setAttribute('tabindex','0');svg.setAttribute('aria-description','Interactive diagram camera. Arrow keys pan, plus and minus zoom, Home fits.');
const pointers=new Map();let prior=null,moved=false,start=null;
svg.addEventListener('wheel',e=>{e.preventDefault();const p=point(e.clientX,e.clientY);scale(Math.exp(-Math.max(-100,Math.min(100,e.deltaY))*.005),p.x,p.y);},{passive:false});
svg.addEventListener('pointerdown',e=>{if(e.button!==0)return;pointers.set(e.pointerId,[e.clientX,e.clientY]);start=[e.clientX,e.clientY];prior=null;moved=false;});
svg.addEventListener('pointermove',e=>{if(!pointers.has(e.pointerId))return;const old=pointers.get(e.pointerId);pointers.set(e.pointerId,[e.clientX,e.clientY]);if(Math.hypot(e.clientX-start[0],e.clientY-start[1])>4){moved=true;svg.setPointerCapture(e.pointerId);}if(!moved&&pointers.size===1)return;
if(pointers.size===2){const [a,b]=[...pointers.values()],distance=Math.hypot(a[0]-b[0],a[1]-b[1]),center=[(a[0]+b[0])/2,(a[1]+b[1])/2];if(prior&&distance>0){const p=point(...center);scale(distance/prior.distance,p.x,p.y);const from=point(...prior.center),to=point(...center);view[0]+=from.x-to.x;view[1]+=from.y-to.y;paint();}prior={distance,center};moved=true;}else{const a=point(...old),b=point(e.clientX,e.clientY);view[0]+=a.x-b.x;view[1]+=a.y-b.y;paint();}});
const end=e=>{if(moved)suppressUntil=Date.now()+350;pointers.delete(e.pointerId);prior=null;if(svg.hasPointerCapture(e.pointerId))svg.releasePointerCapture(e.pointerId);};svg.addEventListener('pointerup',end);svg.addEventListener('pointercancel',end);svg.addEventListener('pointerleave',e=>{if(!svg.hasPointerCapture(e.pointerId))end(e);});
svg.addEventListener('click',e=>{if(Date.now()<suppressUntil){e.preventDefault();e.stopImmediatePropagation();}},true);
svg.addEventListener('keydown',e=>{if(e.target!==svg)return;const actions={ArrowLeft:()=>pan(-.1,0),ArrowRight:()=>pan(.1,0),ArrowUp:()=>pan(0,-.1),ArrowDown:()=>pan(0,.1),'+':()=>scale(1.4),'=':()=>scale(1.4),'-':()=>scale(1/1.4),Home:fit};if(actions[e.key]){e.preventDefault();e.stopPropagation();actions[e.key]();}});
}
new MutationObserver(attach).observe(box,{childList:true});attach();
}
})();
