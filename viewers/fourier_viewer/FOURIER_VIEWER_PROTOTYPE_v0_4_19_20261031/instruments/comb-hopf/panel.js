(function(root){
'use strict';
// fv-comb-hopf panel 0.1.0: renders and holds controls only. One shared state `st` (comb-core address object) drives every tab.
// Exact values come from comb-core / gearbox-core / shell-core / fraction-stack-core; numerical from comb-numeric; drawing is in the view modules.
const GB=root.FVGoldbach;
const X=root.FVExact,C=root.FVCombCore,NUM=root.FVCombNumeric,SH=root.FVShell,O=root.FVOrbit,FS=root.FVFractionStack,V=root.FVViews,SC=root.FVStack;
const $=id=>document.getElementById(id),P=X.parse,T=X.text;
const ALLDEF=Object.assign({},...V.registry.map(v=>v.defaults));
const SCALE_KEY='fv-comb-hopf-text-scale',SCALES=[1,1.1,1.2,1.3,1.4,1.5,1.6];
const UI={ca:false,sq:false,gb:false,gbMsg:'',gbExpand:false,capOpen:false,minfo:false,exp:false,imp:false,menu:null,scale:1,sel:null,witnessP:null,dt1:'4',dt2:'2',speed:1,play:null,sinfo:false,drawer:null,msg:'',expand:false,bannerReason:'',lastExport:''};
let st=C.initial(),last=null,M=null,lastPng=null;
// ---------------------------------------------------------------- state plumbing
// v0.4.5: CA mode in the address. An optional last field `&ca=1`, written only while the CA overlay is effectively on (integer mode, B a CA preset); every other state's address is exactly C.encodeAddress(st).
// Reading: the field is split off before comb-core sees the address (comb-core and the state schema are unchanged). A field that is not exactly ca=1, repeated, or on a B that is not a CA preset
// (or a non-integer state) is refused: the state loads in integer/n! mode as the address says, the CA button stays unpressed and a label says so.
function caOn(){return !!UI.ca&&st.shellMode==='integer'&&FVCa.isPreset(st.B);}
// v0.4.10 (SCHEMA_ADDENDUM_18): the "shells n² + 1" preset track, a UI overlay on integer mode like CA. Optional last field `&sq=1`, written only while the track is effectively on (integer mode, B = n² with 1 <= n <= 359);
// refused (state loads as the address says, track off, a label says so) when repeated, not exactly sq=1, on another B, or together with ca=1. Every other state writes the address it wrote in v0.4.9.
const SQ_MAX=359n;
function sqRoot(Bs){try{const B=BigInt(Bs),n=X.isqrt(B);return n>=1n&&n<=SQ_MAX&&n*n===B?n:null;}catch(e){return null;}}
function sqOn(){return !!UI.sq&&st.shellMode==='integer'&&sqRoot(st.B)!==null;}
function splitSq(h){const t=String(h).replace(/^#/,'').split('&'),keep=[],vals=[];for(const p of t){if(p==='sq'||p.startsWith('sq='))vals.push(p.slice(3));else keep.push(p);}return {rest:'#'+keep.join('&'),vals};}
// v0.4.14 (SCHEMA_ADDENDUM_22): the Goldbach prime-pair track "Goldbach N ▸", a UI overlay on integer mode like CA and n²+1. Optional last field `&gb=1`, written only while the track is effectively on
// (the state sits exactly on the preset of some even N, 4 <= N <= 1,448, with alpha_Tilt = 0); refused (state loads as the address says, track off, a label says so) when repeated, not exactly gb=1,
// off the preset, with alpha_Tilt != 0, or together with ca=1 / sq=1. Every other state writes the address it wrote in v0.4.13.
function gbN(){if(!UI.gb)return null;const r=GB.match(st);return r.ok?r.N:null;}
function gbOn(){return gbN()!==null;}
function splitGb(h){const t=String(h).replace(/^#/,'').split('&'),keep=[],vals=[];for(const p of t){if(p==='gb'||p.startsWith('gb='))vals.push(p.slice(3));else keep.push(p);}return {rest:'#'+keep.join('&'),vals};}
function addrOf(){return C.encodeAddress(st)+(caOn()?'&ca=1':'')+(sqOn()?'&sq=1':'')+(gbOn()?'&gb=1':'');}
function splitCa(h){const t=String(h).replace(/^#/,'').split('&'),keep=[],vals=[];for(const p of t){if(p==='ca'||p.startsWith('ca='))vals.push(p.slice(3));else keep.push(p);}return {rest:'#'+keep.join('&'),vals};}
function readHash(h){const g0=splitGb(h),q=splitSq(g0.rest),s=splitCa(q.rest),r=C.importAny(s.rest);let ca=false,sq=false,gb=false,label='';
  if(r.ok&&s.vals.length){if(s.vals.length===1&&s.vals[0]==='1'){if(r.state.shellMode==='integer'&&FVCa.isPreset(r.state.B))ca=true;else label='CA flag refused: B = '+r.state.B+(r.state.shellMode==='integer'?' is not a CA preset':' (n! mode)')+'; loaded as an ordinary state without CA mode.';}else label='CA flag refused (the field must be exactly ca=1); loaded without CA mode.';}
  if(r.ok&&q.vals.length){const add=t=>{label=label?label+' '+t:t;};
    if(q.vals.length===1&&q.vals[0]==='1'){if(ca)add('n²+1 track flag refused: it cannot be combined with ca=1; loaded in CA mode.');else if(r.state.shellMode==='integer'&&sqRoot(r.state.B)!==null)sq=true;else add('n²+1 track flag refused: B = '+r.state.B+(r.state.shellMode==='integer'?' is not n² with 1 ≤ n ≤ 359':' (n! mode)')+'; loaded as an ordinary state without the track.');}
    else add('n²+1 track flag refused (the field must be exactly sq=1); loaded without the track.');}
  if(r.ok&&g0.vals.length){const add=t=>{label=label?label+' '+t:t;};
    if(g0.vals.length===1&&g0.vals[0]==='1'){if(ca||sq)add('Goldbach track flag refused: it cannot be combined with ca=1 or sq=1; loaded without it.');else{const mt=GB.match(r.state);if(mt.ok)gb=true;else add('Goldbach track flag refused: '+mt.reason+'; loaded as an ordinary state without the track.');}}
    else add('Goldbach track flag refused (the field must be exactly gb=1); loaded without the track.');}
  return {r,ca,sq,gb,label};}
function writeHash(){const h=addrOf();try{history.replaceState(null,'',h);}catch(e){try{location.hash=h;}catch(_){}}}
const shellKey=s=>{let N='?';try{N=X.text(C.resolve(s).Nq);}catch(e){}return (s.shellMode==='factorial'?'f'+s.n1:'i'+s.B)+'|N'+N;};      // the rendered shell: mode, base (n1 or B) and N (exact, so phi3 steps count, also between shells)
function setState(n){if(shellKey(n)!==shellKey(st))UI.witnessP=null;st=n;}   // order-m witness is hidden whenever the shell changes (Test again)
// Continuous input (range input events, camera drags) is coalesced: the state and every exact readout are updated at once, the render runs at most once per
// animation frame and draws the REDUCED drawing sample ("preview"); the full sample is drawn on release (change / pointer up) or after 200 ms without input.
let LIVE=false,raf=0,idleT=null,hashT=null;UI.cardsT=0;UI.moving=false;
function hashSoon(){if(hashT)return;hashT=setTimeout(()=>{hashT=null;writeHash();},250);}
// Camera moves (rotate, pan, wheel, pinch) change the view string only: no exact value, sample or model is recomputed. The cached 3D points are reprojected and the canvas redrawn (camMove / cameraFrame),
// at most once per animation frame; the full render (caption, cards, controls) runs on release or 200 ms after the last move.
let camRaf=0;
function camMove(patch){
  if(!patch||!patch.vs||patch.st||!M||activeView().kind==='html'){live(()=>viewApply(patch));return;}
  try{const next=vsClean({...vsAll(),...patch.vs});setState(C.dialChange(st,{view:V.vsStr(next,ALLDEF)}));UI.msg='';}catch(e){UI.msg=e.message;}
  UI.moving=true;hashSoon();clearTimeout(idleT);idleT=setTimeout(()=>{idleT=null;if(UI.moving||UI.preview)refresh();},200);
  if(raf||camRaf)return;camRaf=requestAnimationFrame(()=>{camRaf=0;cameraFrame();});
}
function cameraFrame(){
  if(raf||!M){return;}                                   // a full preview render is already pending and will draw the newest view string
  const av=activeView(),t0=now();
  V.setQuiet(true);V.layer.preview=false;V.layer.moving=true;
  try{av.render($('stage'),M,vsAll(),UI,$('stagecv'));}finally{V.setQuiet(false);}
  PERF.camN++;PERF.cam=now()-t0;
}
function refreshSoon(){
  if(!UI.preview){UI.preview=true;}
  clearTimeout(idleT);idleT=setTimeout(()=>{idleT=null;if(UI.preview)refresh();},200);
  if(raf)return;raf=requestAnimationFrame(()=>{raf=0;render();});
}
function apply(fn,lastStep){
  try{const n=fn();setState(n);last=lastStep||null;UI.msg='';}catch(e){UI.msg=e.message;}
  if(LIVE){hashSoon();refreshSoon();}else{writeHash();refresh();}
}
const GB_TILT_REFUSAL='α_Tilt is refused while the Goldbach track is on: the mask weights the walk 0, 1 or 2 and a product weight would not be G_N. Keep α_Tilt = 0, or leave the track first (change any dial or choose another shell base).';
function gbGuard(patch){if(!gbOn()||!patch||!('tilt' in patch))return;let nz=false;try{nz=P(patch.tilt).n!==0n;}catch(e){}if(nz)throw Error(GB_TILT_REFUSAL);}
const dial=(patch,lastStep)=>apply(()=>{gbGuard(patch);return C.dialChange(st,clampPhi(patch));},lastStep);
// entering the track sets the dials of the Goldbach shell N and switches alpha_Tilt off (with a status line if it was on)
function gbEnter(N){const was=st.tilt;UI.gb=true;UI.ca=false;UI.sq=false;UI.gbMsg=was!==undefined?'Goldbach track on: α_Tilt switched off (was '+was+'); the mask weights the walk 0, 1 or 2 and a product weight would not be G_N.':'';return dial({...GB.patchFor(N),tilt:'0'});}
function clampPhi(patch){                                // keep phi3 inside 0..B+1 when the shell changes; v0.4.2 (SCHEMA_ADDENDUM_10 §2): out of range -> phi3 = B (N = 1), was B + 1 (N = 0)
  const p={...patch};if(!('shellMode' in p||'n1' in p||'B' in p))return p;
  try{const t={...st,...p};const B=t.shellMode==='integer'?X.parseInteger(t.B):(()=>{let f=1n;for(let k=2n;k<=X.parseInteger(t.n1);k++)f*=k;return f;})();
    if(X.cmp(X.parse(p.phi3??st.phi3),X.rat(B+1n))>0)p.phi3=String(B);}catch(e){}   // exact comparison: phi3 may be a rational in continuous mode
  return p;
}
function pausePlay(){if(UI.play){clearInterval(UI.play.h);UI.play=null;}}
// ---------------------------------------------------------------- view state
const vsAll=()=>V.vsParse(st.view,ALLDEF);
function vsClean(o){const r={};for(const k in o){const x=parseFloat(o[k]);r[k]=(String(o[k])===String(x)||/^-?\d*\.\d+$/.test(String(o[k])))&&Number.isFinite(x)?String(+x.toFixed(4)):String(o[k]);}return r;}
function viewApply(patch){
  if(!patch)return;
  if(patch.st)dial(patch.st,last);
  if(patch.vs){const next=vsClean({...vsAll(),...patch.vs});dial({view:V.vsStr(next,ALLDEF)},last);}
}
const activeView=()=>V.registry.find(v=>v.id===st.tab)||V.registry[0];
// ---------------------------------------------------------------- model
// memo keys: the numerical model and the s-orbits depend only on the EXACT state (never on tab or camera), so a camera drag recomputes neither;
// the leaf mesh depends only on rho; the guide mesh on nothing. Exact values are not cached (they cost ~0.1 ms in total, measured).
const cache={contrast:new Map(),mesh:null,leaf:new Map(),nk:null,num:null,orb:null};
const exactKey=s=>{const o={...s};delete o.tab;delete o.view;return JSON.stringify(o);};
function contrastOf(N){
  if(N<2n)return null;if(!cache.contrast.has(N)){const c=SH.contrast(N),v=Number(c.n)/Number(c.d),b=SH.contrastBand(c);           // v is the decimal for DISPLAY only; band and lock are exact rational comparisons
    cache.contrast.set(N,{text:T(c),dec:v.toFixed(4),col:V.palette()[b.band],lock:b.lock});}
  return cache.contrast.get(N);
}
function buildModel(){
  const R=C.resolve(st),rd=C.readouts(st),set=C.stopSet(st),vs=vsAll(),gN=gbN(),nk=exactKey(st)+(gN?'|gb'+gN:'');   // v0.4.14: the Goldbach mask is part of the numerical key; with the track off nk is exactly the v0.4.13 key
  const gbm=gN?(cache.gbm&&cache.gbm.N===gN?cache.gbm:(cache.gbm=GB.model(gN))):null;
  if(cache.nk!==nk){cache.nk=nk;cache.num=gN?NUM.compute(st,{mask:gbm.w}):NUM.compute(st);cache.orb=null;}
  const num=cache.num;
  const m={st,R,rd,num,set,last,vs,gb:gbm,ca:!!UI.ca&&st.shellMode==='integer'&&FVCa.isPreset(st.B),sInt:X.isInt(P(st.sTyped)),labReal:R.Nq.n>0n&&X.isInt(X.mul(R.t1,P(st.sTyped))),contrast:R.Nint?contrastOf(R.N):null,
    witness:UI.witnessP?{p:UI.witnessP,lod:UI.witnessP>500}:null};
  Object.defineProperty(m,'orbits',{enumerable:true,get(){const ok=nk+(UI.preview?'|p':'');if(!cache.orb||cache.orbKey!==ok){cache.orb=NUM.orbits(st,num,UI.preview?8:1);cache.orbKey=ok;}return cache.orb;}});   // lazy: the Fourier and Panels tabs never read it
  Object.defineProperty(m,'foliation',{enumerable:true,get(){const fk=nk+'|'+vs.cfk+'|'+vs.cfb;if(!cache.fol||cache.folKey!==fk){cache.fol=NUM.foliationGeometry(st,num,Number(vs.cfk),Number(vs.cfb));cache.folKey=fk;}return cache.fol;}});   // v0.4.1 carrier foliation (display register)
  Object.defineProperty(m,'mirror',{enumerable:true,get(){if(!cache.mir||cache.mirKey!==nk){cache.mir=NUM.mirrorGeometry(st,num,m.orbits);cache.mirKey=nk;}return cache.mir;}});   // v0.4 mirror axis (display register): lazy, cached on the exact state; the partial-orbit window is the same in the preview sample
  if(!cache.mesh)cache.mesh=NUM.torusMesh(Math.SQRT1_2,Math.SQRT1_2,64,32);
  m.meshGuide=cache.mesh;
  m.meshLeaf=rho=>{const k=rho.toPrecision(10);if(!cache.leaf.has(k)){if(cache.leaf.size>8)cache.leaf.clear();cache.leaf.set(k,NUM.torusMesh(rho/Math.sqrt(1+rho*rho),1/Math.sqrt(1+rho*rho),64,32));}return cache.leaf.get(k);};
  m.commit={spin:raw=>apply(()=>C.enterSpin(st,raw)),dial:patch=>dial(patch)};   // panels change shared state only through these (R21)
  {const dv=C.divisorsOf(st,R);m.dv=dv;m.divList=dv.list||null;}   // exact; the Divisors card and the phi3 divisor marks both read it (between shells: the label, no list)
  m.fracIdle=true;m.fracPts=[];m.fracCaption='';
  if(vs.cf==='1'){m.fracCaption=FS.caption(st);m.fracAbout=FS.caption(st,true);const h=FS.heads(st);m.fracIdle=h.lattice.idle;if(!h.lattice.idle&&!num.refused&&!num.empty)m.fracPts=NUM.fractionPoints(st,h.heads,num);}
  // v0.4.9 (SCHEMA_ADDENDUM_17): the full stack (display only), lazy and cached on its own key (shell, n6, alpha, t1, t2, m: never phi3, s, alpha_Tilt or the camera); the lift on the same key
  Object.defineProperty(m,'stack',{enumerable:false,get(){const k=SC.key(st,R);if(!cache.stk||cache.stkKey!==k){cache.stk=SC.build(st);cache.stkKey=k;cache.stkLift=null;cache.stkLiftH=null;cache.stkLiftR=null;}return cache.stk;}});
  // v0.4.11 (SCHEMA_ADDENDUM_19): reciprocal half (lazy, same key); the Clifford halves share the head budget (12,000 - m) / 2 each
  Object.defineProperty(m,'stackR',{enumerable:false,get(){return SC.reciprocal(m.stack);}});
  Object.defineProperty(m,'stackLiftHalf',{enumerable:false,get(){const P=m.stack;m.stack;if(!cache.stkLiftH)cache.stkLiftH=SC.liftHalf(st,P,NUM.stereo,false,Math.floor((SC.LIFT_CAP-P.m)/2));return cache.stkLiftH;}});
  Object.defineProperty(m,'stackLiftR',{enumerable:false,get(){const P=m.stack;if(!cache.stkLiftR)cache.stkLiftR=SC.liftHalf(st,P,NUM.stereo,true,Math.floor((SC.LIFT_CAP-P.m)/2));return cache.stkLiftR;}});
  Object.defineProperty(m,'stackLift',{enumerable:false,get(){const P=m.stack;if(!cache.stkLift)cache.stkLift=SC.lift(st,P,NUM.stereo);return cache.stkLift;}});
  if(vs.ff==='1'||vs.hf==='1'){const h=FS.heads(st);m.fpIdle=h.lattice.idle;m.fpCaption=FS.caption(st);m.fpPts=(!h.lattice.idle&&!num.refused&&!num.empty)?SC.fractionPlane(st,h.heads,num.radius):[];}   // v0.4.9: fraction-stack heads in the plane (Fourier, Hopf)
  return m;
}
// ---------------------------------------------------------------- controls (built once, synced on refresh)
const DELTAS=[1,2,3,4,5,6,7];
function buildControls(){
  let n1o='';for(let k=1;k<=13;k++)n1o+='<option value="'+k+'">'+k+'</option>';
  // shell row (addendum 7): base, n1 as ONE select with its ◀ ▶ at every width, M box only for "integer", the one place that shows B and N
  $('shellrow').innerHTML='<button type="button" data-act="mode" data-v="factorial" id="mode_f" aria-label="shell base n factorial">n!</button><button type="button" data-act="mode" data-v="integer" id="mode_i">integer</button><button type="button" data-act="mode" data-v="ca" id="mode_ca" aria-label="shell base: colossally abundant presets" title="Colossally abundant numbers as preset bases B (display-only Robin readout)">CA</button>'
    +'<span class="n1grp" id="n1grp" role="group" aria-label="n1"><button type="button" data-act="n1dn" id="n1_dn" aria-label="n1 minus one">◀</button><select id="n1_sel" aria-label="n1 (B = n1!)">'+n1o+'</select><button type="button" data-act="n1up" id="n1_up" aria-label="n1 plus one">▶</button></span>'
    +'<select id="ca_sel" aria-label="colossally abundant base B" style="display:none">'+FVCa.CA_PRESETS.map(b=>'<option value="'+b+'">'+b+'</option>').join('')+'<option value="sq">n²+1 shells ▸</option><option value="gb">Goldbach N ▸</option></select>'
    +'<select id="sq_sel" aria-label="shells n squared plus one: n (B = n², φ₃ = 0, m = 2n + 1)" title="Shells n² + 1: B = n², φ₃ = 0, so N = n² + 1; m = 2n + 1" style="display:none"><option value="ca">◂ CA presets</option>'+(()=>{let o='';for(let n=1;n<=359;n++)o+='<option value="'+n+'">n = '+n+' → N = '+(n*n+1)+'</option>';return o;})()+'</select>'
    +'<select id="gb_sel" aria-label="Goldbach shell N: even N from 4 to 1448 (B = N/2 − 1, φ₃ = 0; the mask keeps the teeth whose pair N/2 ± c is prime)" title="Goldbach prime-pair mask: even N, 4 to 1448" style="display:none"><option value="ca">◂ CA presets</option>'+(()=>{let o='';for(let N=GB.GB_MIN;N<=GB.GB_MAX;N+=2)o+='<option value="'+N+'">N = '+N+'</option>';return o;})()+'</select>'
    +'<input type="text" id="Mbox" inputmode="numeric" aria-label="integer base M, 1 to 6227020800 (Enter applies)" placeholder="M">'
    +'<span class="read" id="shell_read"></span>';
  // gearbox chips (addendum 7 F1): each dial is ONE button "label value" that opens its drawer (◀ exact box ▶, slider, presets, Δ).
  // Exception: t₁ and t₂ keep their ◀ ▶ steppers beside the chip. Row: α · n₆ · ◀ t₁ ▶ · ◀ t₂ ▶ · m
  const lab=(k,l,t)=>'<button type="button" class="glab" data-act="drawer" data-v="'+k+'" id="lab_'+k+'" aria-expanded="false" aria-label="'+t+' (open its drawer)" title="'+t+'">'+l+'</button>';
  const chip=(k,l,t)=>'<div class="gchip" id="chip_'+k+'">'+lab(k,l,t)+'</div>';
  const chipS=(k,l,t)=>'<div class="gchip" id="chip_'+k+'"><button type="button" data-act="'+k+'dn" aria-label="'+t+' minus">◀</button>'+lab(k,l,t)+'<button type="button" data-act="'+k+'up" aria-label="'+t+' plus">▶</button></div>';
  $('gearrow').innerHTML='<div class="chips5" id="chips5">'+chip('alpha','α','α (radius exponent)')+chip('n6','n₆','n₆ (radius scale)')+chipS('t1','t₁','t₁ (carrier rate)')+chipS('t2','t₂','t₂ (spread rate)')+chip('m','m','m (teeth, 2 to 720)')+'</div><div id="drawer"></div>';
  // under the view: phi3 row (start, step, slider), s row (step, slider, set-s box, info), transport
  $('sliders').innerHTML=
   // step 2 (VERIFY F1, owner decision "drawer"): the φ₃ label is a chip like α / n₆ / m; it opens the φ₃ drawer (◀ exact box ▶) in both modes. Slider, ◀ ▶ and the N toggle stay on the row; ⏮ (start, N = 1) lives in the φ₃ drawer (amended 2026-10-14, saphir F1: keeps the cap of 40).
   '<div class="srow" id="phirow"><div class="gchip" id="chip_phi3"><button type="button" class="glab" data-act="drawer" data-v="phi3" id="lab_phi3" aria-expanded="false" aria-label="φ₃ (open its drawer: exact box)" title="φ₃ (open its drawer: exact box)">φ₃</button></div><button type="button" data-act="phidn" aria-label="N minus one (next integer shell)">◀</button><div class="track"><input type="range" min="0" max="25" step="1" id="phi_sl" aria-label="phi3 slider"><div id="phi_marks" class="marks"></div></div><button type="button" data-act="phiup" aria-label="N plus one (next integer shell)">▶</button>'
  +'<button type="button" data-act="nmode" id="nmode_btn" aria-pressed="false" aria-label="N continuous (pressed) or N integer (not pressed)" title="N integer | N continuous">N∈ℤ</button></div><div id="phidrawer"></div>'
  +'<div class="srow" id="srow"><span class="lab" id="s_lbl">s</span><button type="button" data-act="sdn" aria-label="step s backward">◀</button><div class="track"><input type="range" min="-1" max="1" step="0.001" id="s_sl" aria-label="spin slider"></div><button type="button" data-act="sup" aria-label="step s forward">▶</button>'
  +'<input type="text" id="s_tx" placeholder="−3/2, 49*1/2" aria-label="set s (Enter applies)"><button type="button" class="info" data-act="sinfo" id="sinfo_btn" aria-expanded="false" aria-label="About the spin readout" title="About s">ⓘ</button></div>'
  +'<div id="s_read" class="read"></div><div id="sinfo" class="about note"></div>';
  $('transport').innerHTML='<button type="button" data-act="playn" id="play_n">▶ N</button><button type="button" data-act="plays" id="play_s">▶ s</button><button type="button" data-act="speed" id="sp_btn" aria-label="play speed">1×</button><span class="read" id="play_note"></span>';
}
function stepGear(k,sign){
  const d=P('1/'+UI['d'+k]);return T(sign>0?X.add(P(st[k]),d):X.sub(P(st[k]),d));
}
function onAct(a,v){
  pausePlayIf(a);
  const R=C.resolve(st);
  switch(a){
    case 'mode':{if(v==='ca'){UI.sq=false;UI.gb=false;const keep=st.shellMode==='integer'&&FVCa.isPreset(st.B);UI.ca=true;return dial(keep?{shellMode:'integer'}:{shellMode:'integer',B:'5040'});}   // v0.4.4 CA track: a UI overlay on integer mode; B = a CA preset (5040 if the current B is not one)
      UI.ca=false;UI.sq=false;UI.gb=false;return dial({shellMode:v});}
    case 'n1':return dial({n1:v});
    case 'n1dn':case 'n1up':return dial({n1:String(Math.min(13,Math.max(1,Number(st.n1)+(a==='n1up'?1:-1))))});
    case 'minfo':UI.minfo=!UI.minfo;return refresh();
    case 'capx':UI.capOpen=!UI.capOpen;return refresh();
    case 'drawer':UI.drawer=UI.drawer===v?null:v;UI.phiMsg='';return refresh();   // one drawer at a time (gear dials and φ₃)
    case 'alphadn':case 'alphaup':case 'n6dn':case 'n6up':{const k=a.startsWith('alpha')?'alpha':'n6';return dial({[k]:T(a.endsWith('up')?X.add(P(st[k]),X.rat(1n)):X.sub(P(st[k]),X.rat(1n)))});}
    case 'tiltdn':case 'tiltup':{const n=X.add(C.tiltOf(st),X.rat(a==='tiltup'?1n:-1n,10n)),one=X.rat(1n);return dial({tilt:T(X.cmp(X.qabs(n),one)>0?(n.n>0n?one:X.rat(-1n)):n)});}
    case 'tiltp':return dial({tilt:v});case 'tinfo':UI.tinfo=!UI.tinfo;return refresh();
    case 'alphap':return dial({alpha:v});case 'n6p':return dial({n6:v});
    case 't1dn':case 't1up':case 't2dn':case 't2up':{const k=a.slice(0,2);return dial({[k]:stepGear(k,a.endsWith('up')?1:-1)});}
    case 'mdn':return dial({m:String(R.m-1)});case 'mup':return dial({m:String(R.m+1)});
    case 'phidn':return dial({phi3:C.shellStep(st,-1)});     // N - 1: next integer shell (integer mode: phi3 + 1, clamped)
    case 'phiup':return dial({phi3:C.shellStep(st,1)});      // N + 1: next integer shell (integer mode: phi3 - 1, clamped)
    case 'nmode':{let r;try{r=C.switchNMode(st,st.nMode==='continuous'?'integer':'continuous');}catch(e){UI.msg=e.message;return refresh();}
      setState(r.state);last=null;UI.msg=r.note;writeHash();return refresh();}   // continuous -> integer with a non-integer phi3: the rounding is said in the message line
    case 'start':return dial({phi3:String(R.B)});                                             // the old Reset: phi3 = B, so N = 1
    case 'sdn':case 'sup':{const r=C.step(st,a==='sup'?1:-1);return apply(()=>r.state,r);}
    case 'sinfo':UI.sinfo=!UI.sinfo;return refresh();
    case 'plays':return togglePlay('s');case 'playn':return togglePlay('n');
    case 'speed':UI.speed=UI.speed===0.5?1:UI.speed===1?2:0.5;return refresh();               // one button cycles 1/2x -> 1x -> 2x
    case 'tab':UI.menu=null;return dial({tab:v});
    case 'menu':UI.menu=UI.menu===v?null:v;return refresh();
    case 'gprev':return dial({phi3:v});case 'gnext':return dial({phi3:v});
    case 'mn1':return dial({m:String(R.n1+1n)});
    case 'g0':return dial({phi3:'0'});
    case 'wtest':{const p=parseInt($('w_p').value,10);try{SH.orderWitness(BigInt(p));UI.witnessP=p;UI.msg='';}catch(e){UI.msg=e.message;}return refresh();}
    case 'whide':UI.witnessP=null;return refresh();
    case 'expand':UI.expand=!UI.expand;return refresh();
    case 'gbexpand':UI.gbExpand=!UI.gbExpand;return refresh();
    case 'selrow':UI.sel=(UI.sel!==null&&String(UI.sel)===v)?null:v;return refresh();
    case 'vtool':if(v==='full')return toggleFull();if(v==='about'){V.aboutOpen['view:'+st.tab]=!V.aboutOpen['view:'+st.tab];return refresh();}return viewApply(activeView().act(v,vsAll(),M));
    case 'about':V.aboutOpen[v]=!V.aboutOpen[v];return refresh();
    case 'xjson':return doExport('json');case 'xstate':return doExport('state');case 'xcsv':return doExport('csv');case 'xstats':return doExport('stats');
    case 'xlift':return doExport('lift');case 'xpng':return doExport('png');case 'xpair':return doExport('pair');
    case 'ximport':return doImport();
    case 'expmenu':UI.exp=!UI.exp;return refresh();
    case 'impshow':UI.imp=!UI.imp;return refresh();
    case 'xformula':return doExport('formula');
  }
}
// ---- fullscreen: Fullscreen API on the view frame (webkit prefix as fallback); where unavailable or refused, a CSS "maximised" class with a close button
const fsEl=()=>document.fullscreenElement||document.webkitFullscreenElement||null;
function setMax(on){const f=$('frame');f.classList.toggle('maxed',!!on);document.body.classList.toggle('maxlock',!!on);refresh();}
function exitFull(){
  if(fsEl()){const x=document.exitFullscreen||document.webkitExitFullscreen;try{const p=x.call(document);if(p&&p.catch)p.catch(()=>{});}catch(e){}}
  if($('frame').classList.contains('maxed'))setMax(false);
}
function toggleFull(){
  const f=$('frame');
  if(fsEl()||f.classList.contains('maxed')){exitFull();return;}
  const req=f.requestFullscreen||f.webkitRequestFullscreen;
  if(req){try{const p=req.call(f);if(p&&p.catch){p.catch(()=>setMax(true));}return;}catch(e){}}
  setMax(true);
}
function pausePlayIf(a){if((a.startsWith('x')&&a!=='xx')||a==='start')pausePlay();}
function sliderDec(v,digits){return (+v).toFixed(digits);}
const live=fn=>{LIVE=true;try{fn();}finally{LIVE=false;}};
function onChange(el,liveIn){
  if(liveIn)return live(()=>onChange0(el,true));
  return onChange0(el,false);
}
function onChange0(el,live){
  const id=el.id;
  try{
    if(el.dataset&&el.dataset.vsel){if(el.value!=='')viewApply(activeView().act(el.value,vsAll(),M));return refresh();}
    if(id==='tilt_sl')return dial({tilt:sliderDec(el.value,2)});
    if(id==='tilt_tx')return dial({tilt:el.value});
    if(id==='alpha_sl'||id==='n6_sl')return dial({[id.slice(0,-3)]:sliderDec(el.value,2)});
    if(id==='alpha_tx'||id==='n6_tx')return dial({[id.slice(0,-3)]:el.value});
    if(id==='t1_tx'||id==='t2_tx')return dial({[id.slice(0,2)]:el.value});
    if(id==='t1_sl'||id==='t2_sl')return dial({[id.slice(0,2)]:sliderDec(el.value,2)});
    if(id==='t1_dl'||id==='t2_dl'){UI['d'+id.slice(0,2)]=el.value;return;}
    if(id==='m_sl'||id==='m_tx')return dial({m:String(Math.round(+el.value))});
    if(id==='n1_sel'&&!live)return dial({n1:el.value});
    if(id==='ca_sel'&&!live){if(el.value==='gb'){const mt=GB.match(st);return gbEnter(mt.N||24);}   // v0.4.14: enter the Goldbach track (the current N if the state already sits on a Goldbach shell, else N = 24)
      if(el.value==='sq'){UI.sq=true;UI.ca=false;UI.gb=false;const n0=sqRoot(st.B);return dial(n0!==null&&st.shellMode==='integer'?{shellMode:'integer'}:{shellMode:'integer',B:'9',phi3:'0',m:'7'});}   // v0.4.10: enter the n² + 1 track (n = 3: N = 10, m = 7 if the current B is not a square)
      UI.ca=true;UI.sq=false;UI.gb=false;return dial({shellMode:'integer',B:el.value});}
    if(id==='gb_sel'&&!live){if(el.value==='ca'){UI.ca=true;UI.sq=false;UI.gb=false;return dial({shellMode:'integer',B:'5040'});}return gbEnter(Number(el.value));}
    if(id==='sq_sel'&&!live){if(el.value==='ca'){UI.ca=true;UI.sq=false;UI.gb=false;return dial({shellMode:'integer',B:'5040'});}
      const n=BigInt(el.value);UI.sq=true;UI.ca=false;UI.gb=false;return dial({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2n*n+1n)});}
    if(id==='Mbox'&&!live)return dial({shellMode:'integer',B:el.value.trim()});            // Enter (or leaving the box) applies
    if(id==='phi_sl')return dial({phi3:st.nMode==='continuous'?sliderDec(el.value,2):String(Math.round(+el.value))});   // continuous: the slider's two-decimal value read exactly (step 1/100 of a shell)
    if(id==='phi_tx'&&!live)return phiBox(el.value.trim());                                       // φ₃ drawer box: Enter applies; refused with the reason outside 0 .. B + 1 (integer mode: integers only)
    if(id==='s_sl')return apply(()=>C.enterSpin(st,sliderDec(el.value,6)));
    if(id==='s_tx'&&!live)return apply(()=>C.enterSpin(st,el.value));                        // Enter applies
  }catch(e){UI.msg=e.message;refresh();}
}
// φ₃ drawer box (step 2, VERIFY F1). Continuous mode: decimal or fraction, stored as canonical exact text. Integer mode: an integer only; a fraction is
// refused with PHI_INT_REFUSAL (an integer written as 8/2 or 4.0 is read exactly as that integer). Outside 0 … B + 1: comb-core's range reason.
const PHI_INT_REFUSAL='N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions';
function phiBox(v){
  if(st.nMode==='integer'){let q=null;try{q=P(v);}catch(e){}
    if(q&&!X.isInt(q)){UI.msg=PHI_INT_REFUSAL;UI.phiMsg=PHI_INT_REFUSAL;return refresh();}
    if(q)v=String(q.n);}
  let why='';try{C.dialChange(st,clampPhi({phi3:v}));}catch(e){why=e.message;}   // the same validation as dial(): the reason is also shown inside the drawer
  UI.phiMsg=why;return dial({phi3:v});
}
function togglePlay(kind){
  if(UI.play&&UI.play.kind===kind){pausePlay();return refresh();}
  pausePlay();
  const h=setInterval(()=>{
    try{
      if(kind==='s'){const d=X.mul(P('1/120'),X.rat(BigInt(Math.round(UI.speed*2)),2n));st=C.enterSpin(st,T(X.add(P(st.sEff),d)));last=null;}
      else{const nx=C.playNStep(st);if(nx===null){pausePlay();return refresh();}setState(C.dialChange(st,{phi3:nx}));last=null;}   // one shell per tick, or 1/100 of a shell in continuous mode
      writeHash();refresh();
    }catch(e){UI.msg=e.message;pausePlay();refresh();}
  },120);
  UI.play={kind,h};refresh();
}
// v0.4.7 (SCHEMA_ADDENDUM_15): the second, separately labelled dial inside the α drawer: α_Tilt, the walk weight t^α_Tilt (not the amplitude exponent α above it)
const TILT_ABOUT='α_Tilt weights the walk, step t = 1 … m in offset order, by t^α_Tilt (range −1 to 1; the value is read exactly, so 0.37 is 37/100). Only the walk changes (Fourier and Hopf walks, |W|, |W|/ρ, Q-res, the endpoint, and the ★ and mirror captions); the teeth, the S³ lift, the leaf, the orbits and every exact readout do not. Clifford and G. Robin do not depend on it. The name is a kernel parameter (v3.2.7, notation w_k = k^{α_Tilt}); the comb walk for m ≥ 3 is outside the kernel, so this is an instrument-tier use with no theorem standing. Helix, Circle and Spiral are preset names only (Rmk 9.4a, empirical, observed on the Explorer walk); no regime is claimed for the comb walk. An integer tilt keeps exact rational weights; a fractional tilt makes the walk values numerical.';
function tiltRowHtml(){
  const cl=st.tab==='clifford'?'<span class="read warn" data-role="tilt-na">α_Tilt does not apply here (the Clifford lift has no walk)</span>':st.tab==='panels'?'<span class="read dim" data-role="tilt-na">α_Tilt reaches the walk readouts only; G. Robin does not apply</span>':'';
  const gbn=gbOn()?'<span class="read warn" data-role="tilt-gb">α_Tilt is refused on the Goldbach track (the mask is a 0, 1, 2 walk weight; a product weight would not be G_N)</span>':'';
  return '<div class="srow drawer" id="tilt_drawer"><span class="lab" title="walk weight t^α_Tilt, not the amplitude exponent α">α_Tilt (walk weight t^α_Tilt)</span><button type="button" data-act="tiltdn" aria-label="α_Tilt minus">◀</button><input type="text" id="tilt_tx" aria-label="α_Tilt exact value, −1 to 1" inputmode="decimal"><button type="button" data-act="tiltup" aria-label="α_Tilt plus">▶</button>'
    +'<button type="button" data-act="tiltp" data-v="-1" title="preset name only (Rmk 9.4a, empirical)">−1 Helix</button><button type="button" data-act="tiltp" data-v="0" title="preset name only (Rmk 9.4a, empirical)">0 Circle</button><button type="button" data-act="tiltp" data-v="1" title="preset name only (Rmk 9.4a, empirical)">+1 Spiral</button>'
    +'<div class="track"><input type="range" min="-1" max="1" step="0.01" id="tilt_sl" aria-label="α_Tilt slider"></div><button type="button" class="info" data-act="tinfo" id="tinfo_btn" aria-expanded="'+(!!UI.tinfo)+'" aria-label="About α_Tilt" title="About α_Tilt">ⓘ</button>'+cl+gbn+'</div>'
    +(UI.tinfo?'<div class="about note" id="tinfo">'+V.esc(TILT_ABOUT)+'</div>':'');
}
function drawerHtml(){
  const k=UI.drawer;if(!k||k==='phi3')return '';   // the φ₃ drawer opens under the φ₃ row (phiDrawerHtml)
  const name={alpha:'α',n6:'n₆',t1:'t₁',t2:'t₂',m:'m'}[k],T0={alpha:'α',n6:'n₆',t1:'t₁',t2:'t₂',m:'m'}[k];
  const box='<button type="button" data-act="'+k+'dn" aria-label="'+name+' minus">◀</button><input type="text" id="'+k+'_tx" aria-label="'+name+' exact value" inputmode="decimal"><button type="button" data-act="'+k+'up" aria-label="'+name+' plus">▶</button>';
  let body='';
  if(k==='alpha'||k==='n6')body=box+'<button type="button" data-act="'+k+'p" data-v="-1">−1</button><button type="button" data-act="'+k+'p" data-v="0">0</button><button type="button" data-act="'+k+'p" data-v="1">+1</button><div class="track"><input type="range" min="-8" max="8" step="0.01" id="'+k+'_sl" aria-label="'+name+' slider"></div>';
  else if(k==='m')body=box+'<div class="track"><input type="range" min="2" max="720" step="1" id="m_sl" aria-label="m slider"></div><button type="button" class="info" data-act="minfo" id="minfo_btn" aria-expanded="'+(!!UI.minfo)+'" aria-label="About m" title="About m">ⓘ</button>';
  else body='<input type="text" id="'+k+'_tx" aria-label="'+name+' exact value" inputmode="decimal"><label class="inl">Δ <select id="'+k+'_dl">'+DELTAS.map(d=>'<option value="'+d+'">Δ'+(d===1?'1':'1/'+d)+'</option>').join('')+'</select></label><div class="track"><input type="range" min="-100" max="100" step="0.01" id="'+k+'_sl" aria-label="'+name+' slider"></div>';
  let R=null;try{R=C.resolve(st);}catch(e){}
  const note=k==='m'&&UI.minfo&&R?'<div class="about note" id="minfo">'+mRegister(R.m)+'</div>':'';
  return '<div class="srow drawer"><span class="lab">'+T0+'</span>'+body+'</div>'+note+(k==='alpha'?tiltRowHtml():'');
}
// φ₃ drawer (step 2, VERIFY F1): ⏮ ◀ exact box ▶ under the φ₃ row (⏮ moved here, amended 2026-10-14, saphir F1), in both modes. ◀ ▶ are the row's shell steps (◀ = N − 1, ▶ = N + 1, snapping to the next
// integer shell), so ◀ means the same on the whole φ₃ dial. The range line states what the box accepts in the current mode.
function phiDrawerHtml(){
  if(UI.drawer!=='phi3')return '';
  let B1='B + 1';try{B1=String(C.resolve(st).B+1n);}catch(e){}
  const cont=st.nMode==='continuous';
  return '<div class="srow drawer" id="phi_drawer"><span class="lab">φ₃</span><button type="button" data-act="start" id="phi_start" aria-label="start: N = 1" title="start (N = 1)">⏮</button><button type="button" data-act="phidn" aria-label="N minus one (next integer shell)">◀</button>'
    +'<input type="text" id="phi_tx" inputmode="decimal" aria-label="φ₃ exact value, 0 to B + 1 (Enter applies)"><button type="button" data-act="phiup" aria-label="N plus one (next integer shell)">▶</button>'
    +'<span class="read" id="phi_range">0 … '+B1+(cont?' · decimal or fraction':' · integer (N∈ℤ)')+' · Enter applies</span></div>'
    +(UI.phiMsg?'<p class="warn note" data-role="phi-refusal">'+V.esc(UI.phiMsg)+'</p>':'');
}
// S16 (addendum 7 F5): the m register line, behind the m drawer's ⓘ
const mRegister=m=>'m (teeth, 2 to 720): '+m+(m===2?' · ζ₂ pair · ALG-5':'')+'. The m tooth set is the exact comb order; stop families and the gearbox follow it.';
function sinfoHtml(){
  const l=last;
  return '<div class="kv"><span>s_typed</span><b>'+st.sTyped+'</b><span>s_eff</span><b>'+st.sEff+'</b><span>E (range ±E)</span><b>'+st.E+'</b></div>'
    +'<p class="note">'+(M&&M.set.active?'Stepping: '+M.set.mode+' stop families (exact floor/ceil, no epsilon).':'<span class="warn">Stepping unavailable — '+(M?M.set.reason:'')+'</span>')+'</p>'
    +(M&&M.set.active&&M.set.refused?M.set.refused.map(f=>'<p class="note warn" data-role="sinfo-family-refused">'+V.esc(f.kind+' refused ('+f.source+'): '+f.reason)+'</p>').join(''):'')   // between shells: SPREAD (4e), stated here and on a step (step 2, F2)
    +(l?'<p class="note">last step: <b>'+l.direction+'</b> from '+l.from+' → <b>'+l.value+'</b> · '+l.label+'</p>':'<p class="note dim">no step yet</p>');
}
function syncControls(){
  const R=C.resolve(st),B1=R.B+1n,setv=(id,v)=>{const el=$(id);if(el&&document.activeElement!==el)el.value=v;};
  const pr=(id,on)=>{const el=$(id);if(el)el.setAttribute('aria-pressed',on?'true':'false');};
  const integer=st.shellMode==='integer';
  if(UI.gb&&!GB.match(st).ok){UI.gb=false;}      // v0.4.14: the Goldbach track ends when a dial leaves the preset (or alpha_Tilt becomes nonzero, e.g. by an import)
  if(UI.gb){UI.ca=false;UI.sq=false;}else UI.gbMsg='';
  if(UI.ca&&!(integer&&FVCa.isPreset(st.B)))UI.ca=false;      // the CA overlay ends if the state leaves the CA presets (import, hash change, typed M)
  if(UI.sq&&!(integer&&sqRoot(st.B)!==null))UI.sq=false;      // v0.4.10: the n² + 1 track ends if the state leaves B = n² (n <= 359)
  if(UI.sq&&UI.ca)UI.ca=false;
  const ca=UI.ca,sq=!!UI.sq,gb=!!UI.gb;
  pr('mode_f',!integer);pr('mode_i',integer&&!ca&&!sq&&!gb);pr('mode_ca',ca);
  setv('ca_sel',st.B);$('ca_sel').style.display=ca?'':'none';
  {const sqr=sqRoot(st.B);setv('sq_sel',sq&&sqr!==null?String(sqr):'ca');$('sq_sel').style.display=sq?'':'none';}
  {const gn=gbN();setv('gb_sel',gb&&gn!==null?String(gn):'ca');$('gb_sel').style.display=gb?'':'none';}
  $('n1grp').style.display=(ca||integer)?'none':'';      // v0.4.6: the n1 stepper is inert (disabled) in integer mode, so the whole group is hidden there (CA hides it too); n1 stays in the state and the address
  setv('n1_sel',st.n1);$('n1_sel').disabled=integer;$('n1_dn').disabled=integer||Number(st.n1)<=1;$('n1_up').disabled=integer||Number(st.n1)>=13;
  setv('Mbox',st.B);$('Mbox').style.display=integer&&!ca&&!sq&&!gb?'':'none';
  setHtml($('shell_read'),'B = '+(integer?'':'<span class="hide-s">n₁! = </span>')+'<b>'+R.B+'</b> · N = <b>'+X.text(R.Nq)+'</b>'+(R.N===0n?' (no shell)':''));
  for(const k of ['alpha','n6','t1','t2'])setv(k+'_tx',st[k]);
  setv('m_tx',String(R.m));$('lab_m').title=R.m===2?'m (ζ₂ pair · ALG-5)':'m (teeth, 2 to 720)';
  // each dial chip is one button "label value" (addendum 7 F1)
  {const sh=t=>String(t),lbl={alpha:'α',n6:'n₆',t1:'t₁',t2:'t₂',m:'m'},val={alpha:st.alpha+(st.tilt!==undefined?' · tilt '+st.tilt:''),n6:st.n6,t1:st.t1,t2:st.t2,m:String(R.m)};
   for(const k in lbl){const el=$('lab_'+k),t=lbl[k]+' '+sh(val[k]);if(el.textContent!==t)el.textContent=t;}}
  for(const k of ['alpha','n6','t1','t2','m'])$('lab_'+k).setAttribute('aria-expanded',String(UI.drawer===k));
  setHtml($('drawer'),drawerHtml());
  {const tq=C.tiltOf(st);setv('tilt_tx',st.tilt===undefined?'0':st.tilt);setv('tilt_sl',String(Number(tq.n)/Number(tq.d)));}
  for(const k of ['alpha','n6','t1','t2']){setv(k+'_sl',String(Number(P(st[k]).n)/Number(P(st[k]).d)));setv(k+'_dl',UI['d'+k]);}
  setv('m_sl',String(R.m));
  const cont=st.nMode==='continuous',ps=$('phi_sl'),nb=$('nmode_btn'),pl=$('lab_phi3');$('phirow').classList.toggle('cont',cont);
  if(ps.max!==String(B1))ps.max=String(B1);{const sp=cont?'0.01':'1';if(ps.step!==sp)ps.step=sp;}
  if(document.activeElement!==ps)ps.value=cont?String(Number(R.phi3q.n)/Number(R.phi3q.d)):String(R.phi3);   // the slider position is drawing register; the exact phi3 is in the box
  setText(pl,'φ₃ '+X.text(R.phi3q));pl.title='φ₃ = '+X.text(R.phi3q)+' of B + 1 = '+B1+' (tap: exact box)'+(cont&&B1>SHELL_MARK_CAP?' · integer shells not marked on the track: B + 1 > '+SHELL_MARK_CAP:'');   // the chip reads "φ₃ value" in both modes
  pl.setAttribute('aria-expanded',String(UI.drawer==='phi3'));setHtml($('phidrawer'),phiDrawerHtml());setv('phi_tx',st.phi3);
  pr('nmode_btn',cont);setText(nb,cont?'N∈ℚ':'N∈ℤ');
  const E=P(st.E),sl=$('s_sl'),Ef=Number(E.n)/Number(E.d),setA=(el,k,v)=>{if(el[k]!==v)el[k]=v;};setA(sl,'min',String(-Ef));setA(sl,'max',String(Ef));setA(sl,'step',String(Math.max(Ef/1000,1e-6)));if(document.activeElement!==sl)sl.value=String(Number(P(st.sEff).n)/Number(P(st.sEff).d));
  setv('s_tx',st.sTyped);
  // s_typed is always the box value; s_eff and E appear only when they differ (R21.2 labels)
  const parts=[];
  if(st.sTyped!==st.sEff)parts.push('typed s = '+st.sTyped+'; effective s = '+st.sEff+' (wrapped mod 2N, exactly invariant)');
  else if(C.wrapKept(st))parts.push('kept: wrap not invariant here');
  if(M&&!M.set.active)parts.push('<span class="warn" data-role="step-unavailable">stepping unavailable — '+V.esc(M.set.reason)+'</span>');
  if(last&&last.outcome==='refused')parts.push('<span class="warn" data-role="step-refusal">'+V.esc(last.label)+'</span>');   // a refusal is a warning: shown in full, never behind the (i)
  if(last&&last.refused)for(const f of last.refused)parts.push('<span class="warn" data-role="step-family-refused">'+V.esc(f.kind+' refused ('+f.source+'): '+f.reason)+'</span>');   // between shells: SPREAD (4e), in the stepper message when a step is made (step 2, F2: no longer a permanent line; also in the s ⓘ)
  if(X.cmp(E,R.Nq)>0)parts.push('range widened beyond N: E = '+st.E);
  const sr=$('s_read');setHtml(sr,parts.join('<br>'));{const d=parts.length?'':'none';if(sr.style.display!==d)sr.style.display=d;}
  $('sinfo_btn').setAttribute('aria-expanded',String(!!UI.sinfo));setHtml($('sinfo'),UI.sinfo?sinfoHtml():'');$('sinfo').style.display=UI.sinfo?'':'none';
  for(const b of document.querySelectorAll('#srow [data-act=sdn],#srow [data-act=sup]'))b.setAttribute('aria-disabled',String(!!(M&&!M.set.active)));
  pr('play_s',UI.play&&UI.play.kind==='s');pr('play_n',UI.play&&UI.play.kind==='n');
  $('expmenu').hidden=!UI.exp;$('expBtn').setAttribute('aria-expanded',String(!!UI.exp));$('imp').hidden=!UI.imp;$('impShow').setAttribute('aria-expanded',String(!!UI.imp));
  setText($('sp_btn'),UI.speed===0.5?'½×':UI.speed+'×');
  setText($('play_note'),UI.play&&UI.play.kind==='s'?'animated (exact increments): s_eff + '+(UI.speed/120)+'... committed as typed entries':UI.play?(cont?'animated: φ₃ advances 1/100 of a shell per tick':'animated: N changes by one per tick'):'');
  // marks on the phi3 track: integer shells in continuous mode (dim, B + 1 <= SHELL_MARK_CAP), divisor shells when ÷ Divisors is on (amber)
  {let mk='';if(cont&&B1<=BigInt(SHELL_MARK_CAP))for(let j=0n;j<=B1;j++)mk+='<i class="sh" style="left:'+(Number(j)/Number(B1)*100)+'%"></i>';
   if(vsAll().fd==='1'&&M&&M.divList)for(const d of M.divList){const phi=B1-d;mk+='<i style="left:'+(Number(phi)/Number(B1)*100)+'%"></i>';}setHtml($('phi_marks'),mk);}
}
const SHELL_MARK_CAP=1000;   // integer-shell marks are drawn when B + 1 <= 1000 (denser marks would be below one pixel apart on a phone track)
// ---------------------------------------------------------------- cards
const fmt9=x=>(x<0?'-':'+')+Math.abs(x).toFixed(9);
function phasorTable(){
  const rd=M.rd;if(rd.empty)return '<p class="warn">N = 0: no phasors (empty state).</p>';
  const T0=C.teeth(st,M.R),num=M.num,m=M.R.m,rows=[];
  const show=T0.map((t,i)=>({t,i}));
  let list=show,hidden=0;
  if(m>16&&!UI.expand){const keep=show.filter(x=>Math.abs(Number(x.t.c))<=3||x.i===0||x.i===m-1);hidden=m-keep.length;list=keep;}
  const ph=(q,o)=>T(q)+' <span class="dim">(order '+o+')</span>';
  if(m%2===0)rows.push('<tr class="c0"><td style="color:'+V.palette().z0text+'">carrier (not a tooth)</td><td>—</td><td>—</td><td>'+ph(T0[0].carrier,T0[0].carrierOrder)+'</td><td>—</td><td>'+(num&&!num.refused?fmt9(num.z0.re)+' '+fmt9(num.z0.im)+'i':'—')+'</td></tr>');
  for(const x of list){const t=x.t,gbt=M.gb?M.gb.teeth[x.i]:null,z=num&&!num.refused?num.z[x.i]:null,sel=UI.sel!==null&&String(UI.sel)===String(t.c);
    rows.push('<tr data-act="selrow" data-v="'+t.c+'" class="'+(sel?'sel':'')+'" style="color:'+V.toothText(t.c,m)+(gbt&&!gbt.kept?';opacity:.45':'')+'"'+(gbt?' data-gb="'+(gbt.kept?'kept':'ghost')+'"':'')+'><td>z['+(Number(t.c)>0?'+':'')+t.c+']'+(Number(t.c)===0?' (carrier)':'')+(gbt?(gbt.kept?' · weight '+gbt.w:' · ghost'):'')+'</td><td>'+T(t.k)+'</td><td>'+ph(t.phase,t.order)+'</td><td>'+ph(t.carrier,t.carrierOrder)+'</td><td>'+ph(t.offset,t.offsetOrder)+'</td><td>'+(z?fmt9(z.re)+' '+fmt9(z.im)+'i':'—')+'</td></tr>');}
  const more=hidden>0?'<tr class="more"><td colspan="6"><button type="button" data-act="expand">⋯ '+hidden+' more teeth — full set in the JSON export (tap to expand)</button></td></tr>':(m>16?'<tr class="more"><td colspan="6"><button type="button" data-act="expand">collapse</button></td></tr>':'');
  return '<div class="scroll"><table class="ph"><thead><tr><th>key</th><th>k<sub>c</sub></th><th>tooth φ (exact)</th><th>carrier (exact)</th><th>offset (exact)</th><th>z (numerical)</th></tr></thead><tbody>'+rows.join('')+more+'</tbody></table></div>';
}
function card(title,body,cls,about){return '<section class="panel card '+(cls||'')+'"><div class="panel-label">'+title+'</div>'+body+(about?V.aboutBlock('card:'+title,about):'')+'</section>';}
// ---- v0.4.14 (SCHEMA_ADDENDUM_22) Goldbach prime-pair mask card (exact register except R_N(s) and the page, which are numerical with the viewer bound)
const GB_ROWS=8;
function gbBranches(){if(!cache.gbBr||cache.gbBrK!==cache.nk){cache.gbBr=O.branches(st);cache.gbBrK=cache.nk;}return cache.gbBr;}
function gbCard(){
  const g=M.gb,num=M.num,numOk=num&&!num.refused&&!num.empty,G=GB.GUARDS;
  let R_N='—',page='—',bnd='';
  if(numOk){const ph=O.mirrorCarrierPhase(st),th=Math.PI*Number(ph.n)/Number(ph.d),W=num.W[num.W.length-1],r=W.re*Math.cos(th)+W.im*Math.sin(th);
    R_N=r.toExponential(9)+' ±'+num.bound.toExponential(1)+' <i>numerical</i>';bnd=num.bound;
    page=g.emptyFiber?'G_N ≡ 0 (empty fibre, exact)':num.endpoint.abs<=num.bound?'|W| ≤ bound ('+num.endpoint.abs.toExponential(2)+' ≤ '+num.bound.toExponential(1)+'): not certified zero (floats do not certify a zero)':r>0?'carrier page: arg G_N = πs':'antipodal page: arg G_N = πs + π (R_N(s) < 0)';}
  const bs=gbBranches(),by=new Map(bs.map(b=>[String(b.c),b])),chip=(b,mark)=>b?'<span data-role="gb-branch" data-c="'+b.c+'">'+V.esc(O.chipText(b))+' · k = '+T(b.k)+'</span>':'—';
  const rows=g.P.map(r=>{const c=r.a/g.t2,bm=by.get(String(-c)),bp=by.get(String(c));
    return '<tr data-role="gb-pair" data-p="'+r.p+'"><td>('+r.p+', '+r.q+')</td><td>'+r.a+'</td>'+(r.a===0?'<td colspan="2">'+chip(bp)+' · equal pair p = N/2, tooth weight 2</td>':'<td>'+chip(bm)+'</td><td>'+chip(bp)+'</td>')+'</tr>';});
  const shown=UI.gbExpand?rows:rows.slice(0,GB_ROWS),hid=rows.length-shown.length;
  const tab=g.g?'<div class="scroll"><table class="ph" data-role="gb-pairs"><thead><tr><th>pair (p, N−p)</th><th>a_p</th><th>branch c = −a_p/t₂</th><th>branch c = +a_p/t₂</th></tr></thead><tbody>'+shown.join('')
    +(hid>0?'<tr class="more"><td colspan="4"><button type="button" data-act="gbexpand">⋯ '+hid+' more pairs (tap to expand)</button></td></tr>':(rows.length>GB_ROWS?'<tr class="more"><td colspan="4"><button type="button" data-act="gbexpand">collapse</button></td></tr>':''))+'</tbody></table></div>'
    :'<p class="warn" data-role="gb-empty">P_N is empty at this N: the mask keeps no tooth and the pen is the origin (G_N ≡ 0, exact).</p>';
  const body='<div class="kv"><span>shell</span><b>N = '+g.N+' · viewer shell N/2 = '+g.n+' (B = '+(g.n-1)+', φ₃ = 0) · convention B: t₂ = '+g.t2+', m = '+g.m+', α_Tilt = 0</b>'
    +'<span>g(N) = #P_N (exact)</span><b data-role="gb-g">'+g.g+' · G_N(0) = 2g(N) = '+g.G0+'</b>'
    +'<span>pen (exact weights)</span><b>the masked pen is G_N(s) exactly (Cor II.23.5c): '+g.kept+' of '+g.m+' teeth are in the pen with weight 1 (weight 2 on the c = 0 tooth, the equal pair p = N/2, when N/2 is prime), '+g.removed+' are ghosted</b>'
    +'<span>s</span><b>'+V.esc(st.sTyped)+'</b>'
    +'<span>R_N(s) real, G_N = e^{iπs}·R_N</span><b data-role="gb-R">'+R_N+'</b>'
    +'<span>page</span><b data-role="gb-page">'+V.esc(page)+'</b></div>'
    +'<p class="note" data-role="gb-equal">'+(g.delta?'N/2 = '+g.n+' is prime: the equal pair p = N/2 is present (tooth c = 0, weight 2, branch raw ('+g.n+', 0) → primitive (1, 0) ×'+g.n+', an unknot: the carrier circle traversed '+g.n+' times, not a Hopf-fibre degeneration).':'N/2 = '+g.n+' is not prime: there is no equal pair'+(g.teeth.some(t=>t.c===0)?'; the c = 0 tooth is ghosted.':'.'))+'</p>'
    +'<div class="panel-sub">Pairs and their branches (all on one leaf ρ = 1)</div>'+tab
    +'<p class="note" data-role="gb-knots">Each branch c = ±a_p/t₂ has raw winding (N/2, ∓a_p) = ('+g.n+', ∓a_p), primitive ×1 (unit-fiber guard); k = p on the − branch and k = N−p on the + branch. A branch is an unknot iff a_p ≤ 1: a_p = 1 is exactly a twin pair (N/2 − 1, N/2 + 1). For a_p ≥ 2 the branch is the torus knot T(min(a_p, N/2), max(a_p, N/2)), the two signs being mirror images.</p>'
    +'<p class="note" data-role="gb-guard-interference">'+V.esc(G.interference)+'</p>'
    +'<p class="note" data-role="gb-guard-empty-fiber">'+V.esc(G.empty)+'</p>'
    +'<p class="note" data-role="gb-guard-unit">'+V.esc(G.unit)+'</p>'
    +'<p class="note" data-role="gb-guard-closure"><i>'+V.esc(G.closure)+'</i> (Rmk II.23.5b)</p>'
    +'<p class="note" data-role="gb-guard-status">'+V.esc(G.status)+'</p>'
    +'<p class="note dim" data-role="gb-walk-tier">The comb walk for m ≥ 3 is instrument-tier: the sum W = G_N is the kernel identity, but the order of the partial sums is not. No claim that the masked pen tracks, bounds or converges to anything.</p>';
  return card('Goldbach prime-pair mask',body,'wide gb-card','Goldbach prime-pair mask (v0.4.14, track "Goldbach N ▸"): the mask is a walk weight, w_c = 1 where N/2 ± c·t₂ are both prime and 2 on the c = 0 tooth (the equal pair), 0 elsewhere; the pen is then exactly the kernel’s G_N(s) = Σ over P_N of (e^{2πips/N} + e^{2πi(N−p)s/N}) = e^{iπs}·R_N(s), R_N(s) = 2·Σ cos(2πa_p s/N). Teeth the prime filter removes are drawn ghosted and do not enter the pen. Primality is exact trial division (N ≤ 1,448). The Λ_G(N) local factor and the coprime reference stay in the released v11.21.3 panel. '+GB.PRIOR_ART+' Design: GOLDBACH_PRIME_PAIR_MASK_DESIGN_NOTE_v0_1_20261021.');
}
function cardsHtml(){
  const rd=M.rd,R=M.R,num=M.num,P_=V.palette();let h='';
  const tl=num&&!num.refused&&!num.empty&&num.tilt?num.tilt:null;   // v0.4.7: present only when alpha_Tilt != 0
  // phasors: the table (with k_c) and the field line; the numerical readouts and exact flags are their own card
  let fl='',fq='';
  if(!rd.empty){
    fq='<div class="kv"><span>Exact neighbouring-tooth alignment (t₂s/N ∈ ℤ)</span><b>'+(rd.pairAligned?'yes':'no')+'</b>'
      +'<span>all teeth aligned</span><b>'+(rd.allAligned?'yes':'no')+'</b>'
      +'<span>spread t₂·s/N (exact)</span><b>'+T(rd.spread)+'</b>'
      +'<span>|W| (endpoint) <i>numerical</i></span><b>'+(num&&!num.refused?num.endpoint.abs.toExponential(6)+' ±'+num.bound.toExponential(1):'—')+'</b>'
      +'<span>|W|/ρ <i>numerical</i></span><b>'+(num&&!num.refused?(num.rhoZero?'|W|/ρ undefined (ρ = 0)':num.endpoint.absOverRho.toExponential(6)+' ±'+(num.bound/num.rho).toExponential(1)):'—')+'</b>'
      +'<span>W₁ latitude-gate residual <i>numerical</i></span><b>'+(num&&!num.refused?num.gate.residual.toExponential(3)+' ≤ bound '+num.gate.bound.toExponential(1)+(num.gate.ok?' (within bound)':' (EXCEEDS bound)'):'—')+'</b>'+'<span>carrier-relative W·e^{−iπ(t₁s+f)} real at every s '+(tl?'(teeth only; the tilted walk is not mirror-symmetric)':'(identity, symmetric offsets)')+'</span><b>Im '+(num&&!num.refused?carrierRelIm(num).toExponential(1)+' ±'+num.bound.toExponential(1)+' <i>numerical</i>':'—')+'</b>'+'<span>'+(tl?'pair phases conjugate (t₁·s ∈ ℤ, exact); tilted walk not real in general':'lab-frame W real (t₁·s ∈ ℤ, exact)')+'</span><b>'+(M.labReal?'yes ★':'no')+'</b>'+(tl?'<span>α_Tilt (walk weight t^α_Tilt)</span><b>'+T(R.tilt)+' · '+(tl.exactWeights?'exact rational weights; walk values float64':'weights numerical')+' · instrument-tier, no theorem standing</b>':'')+'</div>';
    fl='<p class="note" data-role="field">'+O.field(st).line+'</p>';
  }
  const fd=rd.empty?null:O.field(st),kern=R.m>=3?' Kernel. K_m(β) = '+(R.m%2?'sin(mβ/2)/sin(β/2)':'sin(mβ)/sin(β)')+', β = π·t₂s/N; its zeros '+(R.m%2?'e^{iβ}':'e^{2iβ}')+' ∈ μ_m∖{1} are the SPREAD stops.':'';
  const fdef=' Field line. generated by the phase factors ℚ(ζ_L): L = lcm, over the nonzero-amplitude teeth, of the order of e^{iπ·k_c·s/N}; it is the field generated by the phase factors, not necessarily the field of the phasor values z_c = ρ·e^{iπ·k_c·s/N}, because ρ = n₆·N^α can be irrational (N = 2, α = 1/2, n₆ = 1, s = 0 gives phase factors 1 but phasors √2). '+(fd&&fd.rhoIrrational?'Here ρ is irrational, so the phasor values themselves may need the further extension ℚ(ζ_L, ρ). ':'')+'phase container (convention) ℚ(ζ_C): for s = p/q in lowest terms, C = 2·q·N·L_k, where L_k is the lcm of the denominators of the k_c (L_k = 1 when every k_c is an integer). It is the fixed field that contains e^{iπ·k·s/N} for every k in (1/L_k)ℤ: a container convention, not a minimal field. When L_k = 1 it equals the old host’s “ambient” ℚ(ζ_{2qN}) (frozen host L6406) and the export says host_ambient_equivalent: true. Between shells, with N = a/b in lowest terms, the same derivation gives C = 2·q·a·L_k (every k_c·s/N lies in (1/(L_k·q·a))ℤ); a = N on a shell, and host_ambient_equivalent is true only on a shell with L_k = 1.'
    +(fd?' Now: q = '+X.parse(st.sTyped).d+', L_k = '+fd.L_k+', C = '+fd.phaseContainer+(R.Nint?'':' (a = '+R.Nq.n+')')+'. Shell reference ℚ(ζ_B) = '+fd.shellLabel+'.':'');
  {const av=activeView(),d1=av.d1Card?av.d1Card(vsAll()):null;if(d1)h+=card(d1.title,d1.body,'wide r30-card',d1.about);}   // v0.4.16 D1 Rule 30 ladder card (Clifford tab, D1 on only)
  if(M.gb)h+=gbCard();
  h+=card('Phasors',phasorTable()+fl,'wide',fdef.trim()+kern+(R.tilt.n!==0n&&R.tilt.d!==1n?' With α_Tilt = '+T(R.tilt)+' not an integer, walk values also need the radicals j^(α_Tilt) (j ≤ m), so they are numerical.':'')+' Columns. k_c = N·t₁ + c·t₂ (exact). tooth φ = k_c·s/N mod 2, in units of π, with the order of e^{iπφ} (exact). carrier = t₁·s (+1 if n₆ < 0) mod 2 (exact). offset = −c·t₂·s/N mod 2 (exact). z (numerical) = n₆·N^α·e^{iπφ}, float64, nine decimals. For odd m the carrier is the tooth c = 0; for even m there is no c = 0 tooth, so the carrier has its own row. The Gearbox card was merged here and into the Wilson card: N and k_c are in the table and the shell readout.');
  h+=card('Exact flags and numerical readouts',fq||'<p class="warn">N = 0: no phasors (empty state).</p>','','The |W| readouts are numerical (float64, stated bounds). The alignment flags and the spread t₂·s/N are exact: no float tolerance decides them. Q-res and the ALIGN / SPREAD flags are in the Fourier caption.');
  // between shells (addendum 8): Wilson (both readouts), gearbox, divisors and shell show the label instead of values
  if(!R.Nint){const lb='<p class="warn" data-role="between-shells">'+V.esc(rd.between)+'</p>';
    h+=card('Wilson',lb,'','Exact register. Between shells there is no integer N: the shell-N Wilson test, the order-m witness and the gearbox residency are not evaluated (addendum 8). Continuous N is the variable moved along at fixed s, not a new arithmetic object.');
    h+=card('Divisors',lb,'','Shells N′ in [1, B+1] that align at the current spin are listed on an integer shell only (addendum 8).');
    h+=card('Shell',lb,'','Shell contrast and the shell bracket B(N−1, N+1) need an integer shell N (addendum 8).');
    return h;}
  // wilson (with the gearbox rows, the resident-gear jumps and the order-m witness)
  const g=rd.gearbox,B1=R.B+1n;
  const w=rd.wilsonN;let gate;
  if(st.shellMode!=='factorial')gate='NOT ACTIVE · factorial shell required';
  else if(!g.eligible)gate='SHELL GATE INACTIVE · set m = n₁+1, g = 0';
  else gate='p = m = '+R.m+' · '+(g.prime?'PRIME':'COMPOSITE')+' · agreement '+(g.agreement===true?'✓ (m | n₁!+1 iff prime)':'✗');
  let ow='';
  if(UI.witnessP){const q=SH.orderWitness(BigInt(UI.witnessP));ow='<div class="kv"><span>n₁ = p − 1 = '+q.n1+'</span><b>p = '+q.p+' · '+(q.prime?'PRIME':'COMPOSITE')+'</b><span>φ relation</span><b>φ(p) = '+q.phi+'; Δ = '+q.delta+'</b><span>(n₁)! + 1 ≡ r (mod p)</span><b>r = '+q.residue+'</b><span>polygon</span><b>'+(q.lod?'LOD p-gon · exact order, vertices below display resolution':'FULL p-gon · '+q.p+' vertices')+'</b></div>';}
  h+=card('Wilson',
    '<div class="panel-sub">Shell-N primality (Wilson test on N)</div><p class="mono">'+w.label.replace(/^Shell N = \d+: /,'')+'</p><p class="note">'+gate+'</p>'
    +'<div class="panel-sub">Order-m witness (candidate p; Enter tests)</div><div class="row"><input type="text" id="w_p" value="'+(UI.witnessP||5)+'" inputmode="numeric" aria-label="candidate p (Enter tests)"><button type="button" data-act="whide">Hide</button></div>'+(UI.witnessP?ow:'')
    +'<div class="panel-sub">Gearbox</div><div class="kv"><span>order spectrum</span><b>φ(m) = '+g.phi+'; Δ = '+g.defect+'</b>'
    +'<span>first resident gear</span><b>g₁ = '+g.first+' · '+g.signature+'</b>'
    +'<span>residency</span><b>'+(g.resident===null?'UNDEFINED (N = 0)':g.resident?'RESIDENT · r = 0 · stride N/m = '+g.stride:'NOT RESIDENT · r = N mod m = '+g.remainder)+'</b>'
    +'<span>code</span><b>'+g.code+'</b></div>'
    +'<div class="row wrap"><button type="button" data-act="gprev" data-v="'+(g.previous===null?'':g.previous)+'" '+(g.previous===null?'disabled':'')+'>◀ gear'+(g.previous===null?'':' g = '+g.previous)+'</button><button type="button" data-act="gnext" data-v="'+(g.next===null?'':g.next)+'" '+(g.next===null?'disabled':'')+'>gear'+(g.next===null?'':' g = '+g.next)+' ▶</button><button type="button" data-act="mn1" title="set m = n₁ + 1">m = n₁+1</button><button type="button" data-act="g0" title="set the zero-gear state g = 0 (φ₃ = 0)">g = 0</button></div>',
    '','Exact register. Gearbox rows: port of the divisor-comb gearbox analysis. First resident gear g₁ = (B + 1) mod m; previous and next resident gears are the nearest gears with m | N. m = n₁+1 sets the comb order to n₁ + 1; g = 0 sets φ₃ = 0 (reading of the host button; INFERRED). Off-Wilson residency is not a primality certificate. Wilson card: FIX.3 candidate, not seated. '+g.label);
  // divisors
  const dv=M.dv;
  const open=vsAll().fd==='1';
  h+=card('Divisors',''
    +(open?'<p class="mono">'+dv.label+'</p>'+(num&&num.rhoZero?'<p class="note warn">ρ = 0: every tooth sits at the origin; the divisibility still holds.</p>':''):'<p class="note dim">Switch on ÷ Divisors (Fourier Layers menu) to show the list and mark the shells on the φ₃ slider.</p>'),'','Shells N′ in [1, B+1] that align with the real axis at the current spin: exact condition t₂·s/N′ ∈ ℤ. The host’s round(s) integer shadow is not used. Factorisation by Miller–Rabin and Pollard rho, declared limit |t₂·s| ≤ 10¹⁸.');
  // shell
  const cn=M.contrast;
  h+=card('Shell','<div class="kv"><span>contrast = (φ(N−1)+φ(N+1))/(2φ(N)) (exact)</span><b style="color:'+(cn?cn.col:P_.dim)+'">'+(cn?cn.text+' ≈ '+cn.dec+' (decimal is display)'+(cn.lock?' 🔒':''):'undefined (N &lt; 2)')+'</b>'
    +'<span>shell bracket B(N−1, N+1)</span><b>'+(R.N>=2n?SH.bracket(R.N):'—')+'</b></div>','','Primality of N±1 by deterministic Miller–Rabin (13 prime bases, proven for n < 3.3·10²⁴) with Pollard rho factorisation; totients from verified factorisations. Shell bracket: TWIN, LEFT_PRIME, RIGHT_PRIME or NULL by exact primality of N−1 and N+1.');
  return h;
}
// ---------------------------------------------------------------- S3 orbit branches card (Clifford tab; SCHEMA_ADDENDUM_5)
let lpT=null,lpDone=false;
const branchCs=()=>C.offsets(C.resolve(st).m);
function branchAct(kind,c){
  let cs;try{cs=branchCs();}catch(e){return;}
  const vis=V.branchVis(vsAll().ch),sc=c===undefined?null:String(c);
  let next;
  if(kind==='all')next=()=>true;
  else if(kind==='none')next=()=>false;
  else if(kind==='toggle_all'){const allOn=cs.every(x=>vis(x));next=()=>!allOn;}
  else if(kind==='isolate')next=x=>String(x)===sc;
  else next=x=>String(x)===sc?!vis(x):vis(x);
  viewApply({vs:{ch:V.branchStr(next,cs)}});
}
function branchesHtml(){
  const bs=O.branches(st),vis=V.branchVis(vsAll().ch),m=bs.length;
  const chips=bs.map(b=>{const on=vis(b.c),col=V.toothHex(b.c,m);
    return '<button type="button" class="chip" data-branch="'+b.c+'" aria-pressed="'+on+'" style="border-color:'+col+';color:'+V.toothText(b.c,m)+'" title="tap: show / hide · long-press or shift-click: isolate">'+(on?'● ':'○ ')+V.esc(O.chipText(b))+'</button>';}).join('');
  const nv=bs.filter(b=>vis(b.c)).length;
  return '<div class="panel-sub">Advanced · S³ orbit branches</div>'
    +'<div class="row wrap"><button type="button" data-bact="toggle_all" id="br_toggle" title="show all branches, or hide all when all are shown">All / None</button><span class="read" id="br_count">'+nv+' of '+m+' shown</span></div>'
    +'<div class="chips" id="br_chips">'+chips+'</div>'+mirrorHtml()+foliationHtml();
}
// v0.4 mirror axis (R2, R3; amended by the S0 design review §5): one parity line (mnemonic) and, per mirror pair ±c, the exact same-time tip coincidences per common period M = P·|c·t₂|/N, the separate image-intersection count 2|p·q| (orbit-core, BigInt) and how many events are marked
const MIRROR_LINES=8;
function mirrorHtml(){
  let pr,ps,R;try{R=C.resolve(st);pr=O.mirrorParity(st);ps=O.mirrorPairs(st);}catch(e){return '';}
  const bv=V.branchVis(vsAll().ch),on=vsAll().cm==='1',g=on&&M&&M.num&&!M.num.refused&&!M.num.empty?M.mirror:null,pm=MINUS_SIGN;
  const line=p=>{const gp=g?g.pairs.find(x=>x.c===p.c):null,col=V.toothText(p.c,R.m);
    let s='±'+p.c+' · ';if(p.status!=='defined')s+=p.reason;
    else{s+=p.count+' same-time tip coincidence'+(p.count===1n?'':'s')+' per common period P = '+T(p.period)+' (M = P·|c·t₂|/N, exact)'+(p.reason?' · '+p.reason:'')+' · image intersections: '+(p.imageIntersections===null?p.imageNote:p.imageIntersections+' = 2|p·q|, separate count, not all on β = 0, π');
      if(gp&&!(bv(p.c)&&bv(-p.c)))s+=' · not marked (a branch of the pair is hidden)';else if(gp)s+=' · '+gp.meetings.length+' marked'+(gp.partial?' (partial orbit window: '+gp.windowCount+' in it)':'')+(gp.capped?' (cap of '+g.cap+' reached)':'');else if(!on)s+=' · layer off';}
    return '<p class="note" data-mirror-pair="'+p.c+'" style="color:'+col+'">'+V.esc(s)+'</p>';};
  const shown=ps.slice(0,MIRROR_LINES),more=ps.length-shown.length;
  return '<div class="panel-sub">Mirror c ↦ '+pm+'c (v0.4)</div><p class="note" id="mirror_parity">'+V.esc(pr.readout)+' · '+V.esc(pr.label)+'</p>'
    +shown.map(line).join('')+(more>0?'<p class="note dim" data-role="mirror-more">⋯ '+more+' more pair'+(more===1?'':'s')+', same rule: M = P·|c·t₂|/N same-time tip coincidences per common period</p>':'');
}
const MINUS_SIGN='−';
// v0.4.1 carrier foliation readouts (display register; design: merged viewer v0.8.8-fix.5). Exact labels from orbit-core carrierFoliation.
function carrierRelIm(num){let th=0;try{const ph=O.mirrorCarrierPhase(st);th=Math.PI*Number(ph.n)/Number(ph.d);}catch(e){}const W=num.W[num.W.length-1];return Math.abs(W.im*Math.cos(th)-W.re*Math.sin(th));}
function foliationHtml(){
  const vs=vsAll();let F;try{F=O.carrierFoliation(st,Number(vs.cfk),Number(vs.cfb));}catch(e){return '';}
  const g=vs.cff==='1'&&M&&M.num&&!M.num.refused&&!M.num.empty?M.foliation:null,R=C.resolve(st);
  const on=F.teethOn.map(c=>(c>0n?'+':c<0n?MINUS_SIGN:'')+(c<0n?-c:c));
  const teeth=on.length===R.m?'every tooth runs along β = 0 (c·t₂ = 0 for all c)':on.length?'the c = 0 tooth runs along β = 0'+(F.t1Zero?' (t₁ = 0: as a point)':''):'no tooth lies on the foliation (even comb)';
  const st0=vs.cff!=='1'?'off (toggle in Layers)':!g?'not drawn (N = 0 or no numerical model)':g.collapsed?'collapsed leaf: nothing drawn':g.stationary?'t₁ = 0: the carrier is stationary; each orbit of the carrier action is a point, drawn as points':'drawn: '+F.K+' longitudes at β = 2πj/'+F.K;
  return '<div class="panel-sub">Carrier foliation (v0.4.1)</div>'
    +'<p class="note" id="fol_state">'+V.esc(st0)+'</p>'
    +'<p class="note" id="fol_beta">selected β = '+V.esc(F.betaText)+' (exact, β/π = k/120, k = '+F.k+') · companion β + π = '+V.esc(F.companionText)+' (dashed)'+(F.mirrorFixed?' · a fixed longitude of the mirror':'')+'</p>'
    +'<p class="note">The family is the orbit foliation of the carrier action (λz₁, z₂) on the leaf: the longitudes (a·e^{iθ}, b·e^{iβ}), θ ∈ [0, 2π), one per transverse phase β. β = 0 and β = π are the mirror’s fixed longitudes (the v0.4 reference longitudes).</p>'
    +'<p class="note" id="fol_teeth">'+V.esc(teeth)+'</p>'
    +'<p class="note">A raw gcd d > 1 changes traversal multiplicity only; it does not quotient the transverse β-circle (merged viewer v0.8.8-fix.5).</p>';
}
// ---------------------------------------------------------------- exports
function download(name,data,type){const blob=data instanceof Blob?data:new Blob([data],{type});const a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download=name;document.body.appendChild(a);a.click();setTimeout(()=>{URL.revokeObjectURL(a.href);a.remove();},500);}
function fname(ext){
  const R=C.resolve(st),shell=st.shellMode==='factorial'?'n'+st.n1+'f':'M'+st.B,s=st.sTyped.replace(/\//g,'o').replace(/-/g,'m').replace(/\./g,'p');
  return 'fvlt_fourier_'+st.tab+'_m'+R.m+'_'+shell+'_s'+s+'_'+X.sha256Text(C.exportState(st)).slice(0,8)+'.'+ext;
}
function csvText(){
  const rows=['c,k_c,tooth_phase,tooth_order,carrier_phase,carrier_order,offset_phase,offset_order,re_numerical,im_numerical'];
  if(!M.rd.empty){const T0=C.teeth(st,M.R);T0.forEach((t,i)=>{const z=M.num&&!M.num.refused?M.num.z[i]:null;rows.push([t.c,T(t.k),T(t.phase),t.order,T(t.carrier),t.carrierOrder,T(t.offset),t.offsetOrder,z?z.re:'',z?z.im:''].join(','));});}
  return rows.join('\n')+'\n';
}
function statsText(){
  const rd=M.rd,R=M.R,g=rd.gearbox;
  return ['Divisor comb · Fourier instrument','state: '+C.encodeAddress(st),'N = '+X.text(R.Nq)+(R.Nint?'':' ('+rd.between+')')+', m = '+R.m+', B = '+R.B,'s_typed = '+st.sTyped+', s_eff = '+st.sEff+', E = '+st.E,
    rd.empty?'N = 0: no walk':'spread t2*s/N = '+T(rd.spread)+' (exact); ALIGN '+rd.flagAlign+'; SPREAD '+rd.flagSpread+'; neighbouring-tooth alignment '+rd.pairAligned,
    'Wilson shell-N: '+rd.wilsonN.label,'Gearbox: '+g.code+' — '+g.label,M.contrast?'contrast = '+M.contrast.text+' (exact)':'contrast undefined',
    M.gb?'Goldbach prime-pair mask: N = '+M.gb.N+', g(N) = '+M.gb.g+', G_N(0) = 2g(N) = '+M.gb.G0+' (exact); '+M.gb.kept+' of '+M.gb.m+' teeth in the pen, '+M.gb.removed+' removed by the prime filter':'',
    M.num&&!M.num.refused&&!M.num.empty?'Q-residual (numerical) = '+M.num.qres.value+' +- '+M.num.qres.bound:''].filter(Boolean).join('\n')+'\n';
}
function liftJson(){
  const num=M.num,out={schema:'fv-comb-hopf-lift/0.3',nMode:st.nMode,N:X.text(M.R.Nq),N_integer:M.R.Nint,state:C.exportState(st).length?undefined:undefined,
    note:'numerical values are float64 strings with the stated bound; exact phases are reduced rationals (units of pi, mod 2)',comparableHostFormat:'fvlt-plane-clifford-lift-v2',teeth:[]};
  delete out.state;out.branches=O.branches(st).map(O.liftBranch);out.cyclotomic_field=C.cycloJson(st);out.gates=O.gates(st);
  if(M.rd.empty||num.refused)return X.canonicalFile({...out,status:M.rd.empty?'N = 0: no lift':num.refused});
  const T0=C.teeth(st,M.R);out.numericalBound=String(num.bound);out.rho=String(num.rho);
  T0.forEach((t,i)=>{const l=num.lift[i];out.teeth.push({c:String(t.c),k:T(t.k),carrier:T(t.carrier),carrierOrder:String(t.carrierOrder),offset:T(t.offset),offsetOrder:String(t.offsetOrder),
    z1:[String(l.z1.re),String(l.z1.im)],z2:[String(l.z2.re),String(l.z2.im)],projectionStatus:l.proj.status,projected:l.proj.vector?l.proj.vector.map(String):null,s2:l.s2.map(String)});});
  return X.canonicalFile(out);
}
function pngBlob(){
  return new Promise((resolve,reject)=>{
    if(activeView().kind==='html'){reject(Error('PNG export: the Panels tab has no drawing window; choose a drawing tab.'));return;}
    if(UI.preview||UI.moving||raf||camRaf)refresh();                        // never export a preview frame
    const svg=$('stage'),vb=svg.viewBox.baseVal,xml=new XMLSerializer().serializeToString(svg);
    const img=new Image(),url=URL.createObjectURL(new Blob([xml],{type:'image/svg+xml;charset=utf-8'}));
    img.onload=()=>{const caps=V.caps(),lh=34,pad=16,c=document.createElement('canvas');c.width=vb.width*2;c.height=vb.height*2+(caps.length?caps.length*lh+2*pad:0);const g=c.getContext('2d');
      g.fillStyle=getComputedStyle(document.body).backgroundColor||'#0c0c18';g.fillRect(0,0,c.width,c.height);{const cv=$('stagecv');if(cv&&cv.width>0&&(activeView().id!=='fourier'||vsAll().fs==='1')){const k=Math.min(cv.width/vb.width,cv.height/vb.height);g.drawImage(cv,(cv.width-vb.width*k)/2,(cv.height-vb.height*k)/2,vb.width*k,vb.height*k,0,0,vb.width*2,vb.height*2);}}   // canvas layer (meshes, orbits, trails) under the SVG overlay
      g.drawImage(img,0,0,vb.width*2,vb.height*2);
      g.font='26px '+V.palette().font;g.textBaseline='top';caps.forEach((cp,i)=>{g.fillStyle=V.readable(cp.col,'#0c0c18');g.fillText(cp.s,pad,vb.height*2+pad+i*lh,c.width-2*pad);});
      URL.revokeObjectURL(url);
      c.toBlob(b=>b?resolve(b):reject(Error('toBlob failed')),'image/png');};
    img.onerror=()=>{URL.revokeObjectURL(url);reject(Error('SVG could not be rasterised'));};
    img.src=url;
  });
}
async function sha256Blob(b){return X.sha256(new Uint8Array(await b.arrayBuffer()));}
function showOut(title,text,hash){
  $('xout').value=text;$('xhash').textContent=title+' · SHA-256 '+hash;
}
async function doExport(kind){
  pausePlay();M=buildModel();
  try{
    if(kind==='json'){const t=C.exportExact(st,last,{witnessP:UI.witnessP});download(fname('json'),t,'application/json');showOut('exact JSON',t,X.sha256Text(t));}
    else if(kind==='state'){const t=C.exportState(st);download(fname('state.json'),t,'application/json');showOut('state',t,X.sha256Text(t));}
    else if(kind==='csv'){const t=csvText();download(fname('csv'),t,'text/csv');showOut('CSV',t,X.sha256Text(t));}
    else if(kind==='lift'){const t=liftJson();download(fname('lift.json'),t,'application/json');showOut('lift JSON',t,X.sha256Text(t));}
    else if(kind==='formula'){const R=C.resolve(st),t='z_c = n6*N^alpha*exp(i*k_c*s*pi/N), k_c = N*t1 + c*t2\nwith n6 = '+st.n6+', alpha = '+st.alpha+', N = '+X.text(R.Nq)+', t1 = '+st.t1+', t2 = '+st.t2+', s = '+st.sTyped+', m = '+R.m+'\n'+(R.tilt.n!==0n?'W_t = sum_{j<=t} j^tilt * z_{c_j} (walk order), tilt = '+X.text(R.tilt)+'\n':'');showOut('formula',t,X.sha256Text(t));try{await navigator.clipboard.writeText(t);$('xhash').textContent+=' · copied to clipboard';}catch(e){$('xhash').textContent+=' · clipboard unavailable: copy from the export box (Export menu)';}}
    else if(kind==='stats'){const t=statsText();showOut('stats',t,X.sha256Text(t));try{await navigator.clipboard.writeText(t);$('xhash').textContent+=' · copied to clipboard';}catch(e){$('xhash').textContent+=' · clipboard unavailable: copy from the box';}}
    else if(kind==='png'){const b=await pngBlob(),h=await sha256Blob(b);lastPng={name:fname('png'),sha:h,size:b.size};download(lastPng.name,b);showOut('PNG ('+b.size+' bytes)','PNG '+lastPng.name+'\nSHA-256 '+h+'\n',h);}
    else if(kind==='pair'){
      const b=await pngBlob(),hp=await sha256Blob(b),je=C.exportExact(st,last,{witnessP:UI.witnessP}),js=C.exportState(st);
      const names={png:fname('png'),exact:fname('json'),state:fname('state.json')};
      const pair=X.canonicalFile({schema:'fv-comb-hopf-pair/0.2',address:C.encodeAddress(st),png:{file:names.png,sha256:hp},exact:{file:names.exact,sha256:X.sha256Text(je)},state:{file:names.state,sha256:X.sha256Text(js)}});
      lastPng={name:names.png,sha:hp,size:b.size};
      download(names.png,b);download(names.exact,je,'application/json');download(names.state,js,'application/json');download(fname('pair.json'),pair,'application/json');
      showOut('pair',pair,X.sha256Text(pair));
    }
    UI.msg='';
  }catch(e){UI.msg='Export failed: '+e.message;}
  setText($('msg'),UI.msg);
}
// ---- Import state (paste): the same R21.5 validation as a URL load (C.importAny). Refused as a whole with the reason, or restored exactly (sEff as stored, never re-derived).
function doImport(){
  pausePlay();const out=$('impmsg'),txt=$('imptxt').value;
  if(!txt.trim()){out.textContent='Nothing to load: paste a state address, an exported state JSON or an exact JSON first.';return;}
  const r=C.importAny(txt);
  if(!r.ok){setState(C.initial());last=null;UI.msg='';UI.bannerReason='Import refused: '+r.reason+' — showing defaults.';writeHash();refresh();out.textContent='Import refused: '+r.reason+' — showing defaults as a new state.';return;}
  setState({...C.initial(),...r.state});last=null;UI.msg='';UI.bannerReason='';writeHash();refresh();
  out.textContent='Loaded: s_typed = '+st.sTyped+', s_eff = '+st.sEff+', E = '+st.E+' (restored as stored).';
}
// ---------------------------------------------------------------- render
// Replace markup only when it changed: re-creating a button between mousedown and mouseup (a text box blurring into a click) would lose the click.
function setHtml(el,html){if(el._html!==html){el._html=html;el.innerHTML=html;}}
// morph: patch the live DOM towards new markup, touching only nodes whose text or attributes differ (a full innerHTML rewrite of the cards cost 3.3 ms of layout per step, measured)
function patchNode(a,b){
  const bc=b.childNodes;
  for(let i=0;i<bc.length;i++){
    const x=a.childNodes[i],y=bc[i];
    if(!x){a.appendChild(y.cloneNode(true));continue;}
    if(x.nodeType!==y.nodeType||x.nodeName!==y.nodeName){a.replaceChild(y.cloneNode(true),x);continue;}
    if(x.nodeType===3){if(x.data!==y.data)x.data=y.data;continue;}
    if(x.nodeType===1){for(const at of Array.from(x.attributes))if(!y.hasAttribute(at.name))x.removeAttribute(at.name);
      for(const at of Array.from(y.attributes))if(x.getAttribute(at.name)!==at.value)x.setAttribute(at.name,at.value);
      patchNode(x,y);}
  }
  while(a.childNodes.length>bc.length)a.removeChild(a.lastChild);
}
function morphHtml(el,html){if(el._html===html)return;el._html=html;const t=document.createElement('template');t.innerHTML=html;patchNode(el,t.content);}
function setText(el,t){t=String(t);if(el._txt!==t){el._txt=t;el.textContent=t;}}   // diff-aware: rewriting identical text still dirties layout
function renderTabs(){
  setHtml($('tabs'),V.registry.map(v=>'<button type="button" role="tab" data-act="tab" data-v="'+v.id+'" aria-pressed="'+(v.id===st.tab)+'" aria-selected="'+(v.id===st.tab)+'">'+v.label+'</button>').join(''));
}
const swHtml=a=>(a&&a.length?'<span class="sws" aria-hidden="true">'+a.map(c=>'<i style="background:'+c+'"></i>').join('')+'</span>':'');
function itemHtml(b){
  if(b.select)return '<label class="mi">'+b.label+' <select data-vsel="'+b.id+'" aria-label="'+b.label+'">'+b.select.map(o=>'<option value="'+o[0]+'"'+(o[0]===b.value?' selected':'')+'>'+o[1]+'</option>').join('')+'</select>'+swHtml(b.sw)+'</label>';
  return '<button type="button" data-act="vtool" data-v="'+b.id+'"'+(b.pressed!==undefined?' aria-pressed="'+b.pressed+'"':'')+(b.title?' title="'+b.title+'"':'')+'>'+b.label+(b.pressed?swHtml(b.sw):'')+'</button>';
}
// Layers and Camera: one menu each (one open at a time) under the strip; the strip itself keeps the zoom trio, full view and the info toggle
function renderToolbar(){
  const v=activeView(),items=v.toolbar(vsAll(),M),lay=items.filter(b=>b.menu==='layers'),cam=items.filter(b=>b.menu==='camera'),strip=items.filter(b=>b.menu==='strip');
  if((UI.menu==='layers'&&!lay.length)||(UI.menu==='camera'&&!cam.length))UI.menu=null;
  const mb=(k,l,n)=>n?'<button type="button" data-act="menu" data-v="'+k+'" data-menu="'+k+'" aria-expanded="'+(UI.menu===k)+'" aria-haspopup="true">'+l+'</button>':'';
  setHtml($('toolbar'),mb('layers','Layers',lay.length)+mb('camera','Camera',cam.length)+strip.map(itemHtml).join('')
    +'<button type="button" class="info" data-act="vtool" data-v="about" aria-expanded="'+(!!V.aboutOpen['view:'+st.tab])+'" aria-label="About this view" title="About this view">ⓘ</button>');
  let mh='';
  if(UI.menu==='layers')mh='<div class="menu" id="menu_layers">'+lay.filter(b=>!b.adv).map(itemHtml).join('')+(lay.some(b=>b.adv)?'<div class="panel-sub">Advanced</div>'+lay.filter(b=>b.adv).map(itemHtml).join(''):'')+(st.tab==='clifford'&&vsAll().rl!=='1'?branchesHtml():'')+'</div>';
  else if(UI.menu==='camera')mh='<div class="menu" id="menu_camera">'+cam.map(itemHtml).join('')+'</div>';
  setHtml($('menu'),mh);
}
// Text floor for SVG text: the CSS rule `#stage text` sizes it from --svgk (rendered px per user unit), so on-screen size is exactly max(13px, 13px*scale)
// whatever the layout; the font-size attribute (rounded up) is only the fallback for the PNG export, which serialises the SVG without the page CSS.
function svgK(){const svg=$('stage'),r=svg.getBoundingClientRect(),vb=svg.viewBox.baseVal;if(!r.width||!vb.width)return 1;return r.height>0?Math.min(r.width/vb.width,r.height/vb.height):r.width/vb.width;}
function setSvgK(){const k=svgK();$('stage').style.setProperty('--svgk',String(Math.max(Math.floor(k*1e4)/1e4,1e-4)));return k;}
const PERF={model:0,tabs:0,view:0,caption:0,cards:0,controls:0,total:0,n:0,cardsN:0,camN:0,cam:0,cardsAddr:''};
const now=()=>(typeof performance!=='undefined'?performance.now():Date.now());
function refresh(){                                     // full render now (discrete actions, release, idle): cancels any pending preview frame
  if(raf){cancelAnimationFrame(raf);raf=0;}clearTimeout(idleT);idleT=null;
  if(hashT){clearTimeout(hashT);hashT=null;writeHash();}
  UI.preview=false;UI.moving=false;render();
}
function render(){
  try{
    const q0=now();
    M=buildModel();const q1=now();
    renderTabs();renderToolbar();const av=activeView(),html=av.kind==='html';
    $('frame').style.display=html?'none':'';$('htmlstage').style.display=html?'':'none';$('about').style.display='';
    V.capReset();V.abtReset();
    if(M.rd.between)V.cap(C.BETWEEN_SHORT,V.palette().warn,'degenerate');   // addendum 8 (amended step 2, saphir F2): every tab's warning line carries the short form (role degenerate, never ellipsized); the fraction is in the shell readout, the full label in every card
    if(html)av.renderHtml($('htmlstage'),M,vsAll());
    else{const k=setSvgK();V.setFont(Math.ceil(13*UI.scale/k*1e4)/1e4);V.layer.preview=!!UI.preview;V.layer.moving=!!UI.moving;if(UI.preview)V.cap('preview: reduced drawing sample while input is moving; every readout is exact and current',V.palette().dim,'preview');av.render($('stage'),M,vsAll(),UI,$('stagecv'));}
    const q2=now();
    setHtml($('about'),V.aboutOpen['view:'+st.tab]?'<div class="panel about">'+(V.abouts().map(t=>'<p class="note">'+V.esc(t)+'</p>').join('')||'<p class="note">No further notes for this window.</p>')+'</div>':'');
    setHtml($('caption'),V.caps().map(c=>'<p style="color:'+V.readable(c.col,'#131321')+'"'+(c.role?' data-role="'+c.role+'"':'')+(c.role==='line'||c.role==='fraction-caption'?' class="ell" data-act="capx" role="button" tabindex="0" aria-expanded="'+UI.capOpen+'" title="tap to show the whole line"':' class="warnline"')+'>'+V.esc(c.s)+'</p>').join(''));
    $('caption').classList.toggle('open',!!UI.capOpen);
    const q3=now();
    // Cards (phasor table, flags, Wilson, divisors, shell) update at most 4 times per second while a slider drag is active (always from one consistent state) and exactly on release; while
    // a drag is active they carry the preview marker (data-preview) because they may be catching up with the state shown in the picture and the controls.
    {const cd=$('cards'),tc=now();if(!UI.preview||tc-UI.cardsT>=250){morphHtml(cd,cardsHtml());UI.cardsT=tc;PERF.cardsN++;PERF.cardsAddr=C.encodeAddress(st);}
     if(UI.preview){if(!cd.hasAttribute('data-preview'))cd.setAttribute('data-preview','1');}else if(cd.hasAttribute('data-preview'))cd.removeAttribute('data-preview');}
    const q4=now();syncControls();const q5=now();
    PERF.model=q1-q0;PERF.tabs=0;PERF.view=q2-q1;PERF.caption=q3-q2;PERF.cards=q4-q3;PERF.controls=q5-q4;PERF.total=q5-q0;PERF.n++;
    const rd=M.rd;
    setText($('status'),(UI.msg?UI.msg:'')+(UI.bannerReason?' '+UI.bannerReason:'')+(UI.gbMsg?' '+UI.gbMsg:''));
    setText($('msg'),UI.msg);
    setText($('addr'),addrOf());
  }catch(e){$('status').textContent='Render error: '+e.message;console.error(e);}
}
function onGestureTarget(target){const el=target&&target.closest?target.closest('[data-c]'):null;if(el){const c=el.getAttribute('data-c');UI.sel=String(UI.sel)===c?null:c;refresh();return true;}return false;}
function init(){
  const h=location.hash;
  if(h&&h.length>3){const rh=readHash(h),r=rh.r;if(r.ok){st={...C.initial(),...r.state};UI.ca=rh.ca;UI.sq=rh.sq;UI.gb=rh.gb;if(rh.label)UI.bannerReason=rh.label;if(r.upgraded||rh.ca||rh.sq||rh.gb)writeHash();/* a 0.1 address (no nMode) is read as nMode = integer and shown as its 0.2 address */}else{UI.bannerReason='Address refused: '+r.reason+' — showing defaults.';st=C.initial();}}
  try{performance.mark('fv-init-0');}catch(e){}
  buildControls();
  const bc=$('menu');
  bc.addEventListener('pointerdown',e=>{const b=e.target.closest('[data-branch]');if(!b)return;lpDone=false;clearTimeout(lpT);lpT=setTimeout(()=>{lpDone=true;branchAct('isolate',b.dataset.branch);},550);});
  ['pointerup','pointercancel','pointerleave'].forEach(ev=>bc.addEventListener(ev,()=>clearTimeout(lpT)));
  bc.addEventListener('click',e=>{const b=e.target.closest('[data-branch],[data-bact]');if(!b)return;
    if(b.dataset.bact)return branchAct(b.dataset.bact);
    if(lpDone){lpDone=false;return;}
    branchAct(e.shiftKey?'isolate':'toggle',b.dataset.branch);});
  const stage=$('stage');
  V.gestures(stage,{
    drag:(dx,dy,shift)=>camMove(activeView().gesture('drag',{dx,dy,shift},vsAll(),M)),
    wheel:d=>camMove(activeView().gesture('wheel',d,vsAll(),M)),
    pinch:f=>camMove(activeView().gesture('pinch',f,vsAll(),M)),
    end:()=>{if(UI.preview||UI.moving)refresh();},
    tap:(x,y,target)=>onGestureTarget(target)});
  document.body.addEventListener('click',e=>{const b=e.target.closest('[data-act]');if(b&&!b.disabled)onAct(b.dataset.act,b.dataset.v);});
  document.body.addEventListener('change',e=>onChange(e.target));
  document.body.addEventListener('input',e=>{if(e.target.type==='range')onChange(e.target,true);});
  document.body.addEventListener('keydown',e=>{if(e.key==='Enter'&&e.target.id==='w_p')onAct('wtest');if((e.key==='Enter'||e.key===' ')&&e.target.getAttribute&&e.target.getAttribute('data-act')==='capx'){e.preventDefault();onAct('capx');}});
  document.addEventListener('keydown',e=>{
    if(e.key==='Escape'&&$('frame').classList.contains('maxed')){exitFull();return;}
    if(/INPUT|SELECT|TEXTAREA/.test(document.activeElement.tagName)&&document.activeElement.type!=='range')return;
    if(e.key==='ArrowLeft'||e.key==='ArrowRight'){e.preventDefault();const right=e.key==='ArrowRight';
      if(e.shiftKey)onAct(right?'sup':'sdn');else onAct(right?'phiup':'phidn');}});
  try{const v=parseFloat(localStorage.getItem(SCALE_KEY));if(SCALES.includes(v))UI.scale=v;}catch(e){}
  const setScale=v=>{UI.scale=v;document.documentElement.style.setProperty('--scale',String(v));$('sizeVal').textContent=Math.round(v*100)+'%';try{localStorage.setItem(SCALE_KEY,String(v));}catch(e){}refresh();};
  $('sizeDn').addEventListener('click',()=>{const i=SCALES.indexOf(UI.scale);if(i>0)setScale(SCALES[i-1]);});
  $('sizeUp').addEventListener('click',()=>{const i=SCALES.indexOf(UI.scale);if(i<SCALES.length-1)setScale(SCALES[i+1]);});
  document.documentElement.style.setProperty('--scale',String(UI.scale));$('sizeVal').textContent=Math.round(UI.scale*100)+'%';
  let rt=null;window.addEventListener('resize',()=>{clearTimeout(rt);rt=setTimeout(refresh,120);});
  $('frameClose').addEventListener('click',exitFull);
  if(typeof ResizeObserver!=='undefined')new ResizeObserver(()=>{setSvgK();if(activeView().canvas&&!V.layerFit($('stagecv'))){if(!raf)raf=requestAnimationFrame(()=>{raf=0;render();});}}).observe($('stage'));
  const onFs=()=>{$('frame').classList.toggle('full',!!fsEl());refresh();};
  document.addEventListener('fullscreenchange',onFs);document.addEventListener('webkitfullscreenchange',onFs);
  window.addEventListener('hashchange',()=>{const rh=readHash(location.hash),r=rh.r;if(r.ok&&(C.encodeAddress(r.state)!==C.encodeAddress(st)||rh.ca!==caOn()||rh.sq!==sqOn()||rh.gb!==gbOn())){setState({...C.initial(),...r.state});UI.ca=rh.ca;UI.sq=rh.sq;UI.gb=rh.gb;if(rh.label)UI.bannerReason=rh.label;refresh();}});
  refresh();
  try{performance.measure('fv-init','fv-init-0');}catch(e){}
  root.FVPanel={perf:PERF,get state(){return st;},get model(){return M;},apply,dial,onAct,exportPng:()=>pngBlob(),get gbN(){return gbN();}};
}
if(document.readyState==='loading')document.addEventListener('DOMContentLoaded',init);else init();
})(typeof globalThis!=='undefined'?globalThis:this);
