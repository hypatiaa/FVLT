(function(root){
'use strict';
// Panels-tab cards of v0.4.17 (SCHEMA_ADDENDUM_24), group D exact: "Elliptic points (exact)" and "Period lattice (exact intervals)".
// Placement (owner's lean, asked for by saphir): group D of the comb-hopf Panels tab. The legacy group-D placeholders stay as they are.
// Registers: EXACT (BigInt points, rationals, residues; host-core/elliptic-exact-core.js), NUMERICAL WITH GUARANTEES (dyadic interval enclosures;
// host-core/elliptic-period-core.js), DRAWING (canvas pixels: integers from BigInt division, handed to canvas by the helper px below).
// No floating point (saphir). Both cards are display only: their dials live in this module, not in the host state, the address or the exports.
// v0.4.18 fix-ups (verify report v0.4.17): stacked case table, scatter zoom 1x/2x/4x with a window and a 3 px minimum dot, P1 = P2 offset outline,
// "ν (nu)", U+2212 in the refused Δ, and the reduction label of additive reduction (F3: it read "additive multiplicative").
const V=root.FVViews,EX=root.FVEllipticExact,PE=root.FVEllipticPeriod,esc=V.esc,MINUS='−';
const px=b=>{if(typeof b!=='bigint')throw Error('px needs a BigInt');return Number(b);};
const PRE=EX.PRESETS['37a1'],A=PRE.ainvs,CQ=EX.curveQ(A),PQ=EX.pt(PRE.P[0],PRE.P[1]);
const PRIMES=EX.primesBelow(100n);
const S={k:5n,p:5n,i1:-1,i2:-1,D:50n,curve:'37a1',zoom:1n,wx:0n,wy:0n};
// F3 fix: the reduction label; additive reduction is not a kind of multiplicative reduction
const redLabel=rt=>rt.type==='good'?'good':rt.type==='additive'?'additive':rt.type+' multiplicative';
const redShort=rt=>rt.type==='additive'?'additive':rt.type+' mult.';
const PCURVES={'37a1':{label:'37a1 (Δ = 37 > 0)',ainvs:A},'11a1':{label:'11a1 (Δ = −161051 < 0: refused)',ainvs:[0n,-1n,1n,-10n,-20n]}};
const cache={ap:null,pts:new Map()};
const sgn=n=>(n<0n?MINUS:'')+(n<0n?-n:n);
const caseCls=['p1inf','p2inf','opposite','generic','doubling'];
function apTable(){
  if(cache.ap)return cache.ap;
  cache.ap=PRIMES.map(p=>{const i=EX.apNaive(A,p),ii=p===2n?null:EX.apCharSum(A,p),rt=EX.reductionType(A,p);return {p,i,ii,rt,agree:ii?ii.ap===i.ap:null};});
  return cache.ap;
}
function ptsAt(p){if(!cache.pts.has(p)){const E=EX.curveFp(A,p),all=EX.points(E),bad=EX.reductionType(A,p),ns=bad.type==='good'?all:all.filter(Q=>Q.inf||!EX.ptEq(E,Q,bad.singular));cache.pts.set(p,{E,all,pts:ns,bad});}return cache.pts.get(p);}   /* pts: E_ns(F_p), the group; all: every projective point */
function bindDial(el,role,ev,fn){const x=el.querySelector('[data-role="'+role+'"]');if(!x)return;x.addEventListener(ev,()=>fn(x));x.addEventListener('keydown',e=>e.stopPropagation());}
function lazy(body,M,fn){
  const det=body.closest('details'),open=!det||det.open;
  if(det&&!det._ellBound){det._ellBound=true;det.addEventListener('toggle',()=>{if(det.open)fn(body,M);});}
  if(!open){body.innerHTML='<p class="note dim">Open the card to compute.</p>';return false;}
  return true;
}
// ---------------------------------------------------------------- card 1: points
const G=300n,ML=34n,MT=10n,CW=380n,CH=340n;
function drawScatter(cv,p,pts,bad,sel,view){
  // zoom z in {1, 2, 4}: a window of ceil(p/z) cells starting at (wx, wy); the dot is at least 3 px (v0.4.18)
  const z=view?view.zoom:1n,span=(p+z-1n)/z,wx=view?view.wx:0n,wy=view?view.wy:0n;
  const c=cv.getContext('2d'),cell=G/span,gw=cell*span,dot0=cell>=9n?cell/3n+2n:cell>=3n?cell-1n:cell,dot=dot0<3n?3n:dot0;
  const inW=(x,y)=>x>=wx&&x<wx+span&&y>=wy&&y<wy+span;
  c.setTransform(1,0,0,1,0,0);c.fillStyle='#08080f';c.fillRect(0,0,px(CW),px(CH));
  const X=x=>ML+(x-wx)*cell,Y=y=>MT+(span-1n-(y-wy))*cell;
  c.strokeStyle='#2e2e4a';c.lineWidth=1;
  if(cell>=6n){c.beginPath();for(let i=0n;i<=span;i++){c.moveTo(px(ML+i*cell),px(MT));c.lineTo(px(ML+i*cell),px(MT+gw));c.moveTo(px(ML),px(MT+i*cell));c.lineTo(px(ML+gw),px(MT+i*cell));}c.stroke();}
  c.strokeStyle='#45456a';c.strokeRect(px(ML),px(MT),px(gw),px(gw));
  c.fillStyle='#9a9ab8';c.font='13px ui-monospace,Consolas,monospace';
  c.fillText(String(wy),px(ML-30n),px(MT+gw));c.fillText(String(wy+span-1n),px(ML-30n),px(MT+13n));c.fillText('x '+wx+' → '+(wx+span-1n),px(ML+gw-110n),px(MT+gw+16n));
  const box=(x,y,col,big)=>{const s=big?dot+4n:dot,off=(cell-s)/2n;c.fillStyle=col;c.fillRect(px(X(x)+off),px(Y(y)+off),px(s),px(s));};
  let n=0,drawn=0;
  for(const P of pts){if(P.inf)continue;n++;if(inW(P.x,P.y)){box(P.x,P.y,'#00e5ff',false);drawn++;}}
  // the point at infinity: a labelled marker outside the grid (right of it)
  const ox=ML+gw+14n,oy=MT+16n;c.strokeStyle='#d4d4e8';c.lineWidth=2;c.beginPath();c.moveTo(px(ox),px(oy-8n));c.lineTo(px(ox+8n),px(oy));c.lineTo(px(ox),px(oy+8n));c.lineTo(px(ox-8n),px(oy));c.closePath();c.stroke();
  c.fillStyle='#d4d4e8';c.fillText('O',px(ox-4n),px(oy+26n));n++;
  // grow: extra pixels for an outline drawn around another one (P1 = P2: the P2 box is drawn 6 px larger, so both stay visible)
  const mark=(P,col,grow)=>{if(!P)return;const g=grow||0n;if(P.inf){c.strokeStyle=col;c.lineWidth=2;c.strokeRect(px(ox-12n-g/2n),px(oy-12n-g/2n),px(24n+g),px(24n+g));return;}if(!inW(P.x,P.y))return;const s=dot+8n+g,off=(cell-s)/2n;c.strokeStyle=col;c.lineWidth=2;c.strokeRect(px(X(P.x)+off),px(Y(P.y)+off),px(s),px(s));};
  const same=!!(sel.P1&&sel.P2&&(sel.P1.inf?sel.P2.inf:(!sel.P2.inf&&sel.P1.x===sel.P2.x&&sel.P1.y===sel.P2.y)));
  mark(sel.P1,'#fbbf24');mark(sel.P2,'#a855f7',same?6n:0n);mark(sel.R,'#10b981');
  let sing=null;
  if(bad&&bad.type!=='good'){sing=bad.singular;if(inW(sing.x,sing.y)){const s=dot+6n,off=(cell-s)/2n;c.fillStyle='#ff5e6c';c.fillRect(px(X(sing.x)+off),px(Y(sing.y)+off),px(s),px(s));
    c.strokeStyle='#ff5e6c';c.lineWidth=2;c.beginPath();c.moveTo(px(X(sing.x)+cell/2n),px(Y(sing.y)));c.lineTo(px(X(sing.x)+cell/2n),px(MT+gw+20n));c.stroke();}
    c.fillStyle='#ff5e6c';c.fillText('singular ('+sing.x+', '+sing.y+'): '+redShort(bad),px(ML),px(MT+gw+32n));}
  cv.dataset.zoom=String(z);cv.dataset.wx=String(wx);cv.dataset.wy=String(wy);cv.dataset.span=String(span);cv.dataset.dot=String(dot);cv.dataset.drawn=String(drawn);cv.dataset.same=same?'1':'0';
  cv.dataset.p=String(p);cv.dataset.n=String(n);cv.dataset.cell=String(cell);cv.dataset.singular=sing?sing.x+','+sing.y:'';cv.dataset.reduction=bad?bad.type:'';
}
function renderPoints(body,M){
  if(!lazy(body,M,renderPoints))return;
  const k=S.k,p=S.p,{E,all,pts,bad}=ptsAt(p),Pp=EX.reduce(CQ,PQ,p).R;
  const idxOf=Q=>pts.findIndex(R=>EX.ptEq(E,R,Q));
  if(S.i1<0||S.i1>=pts.length)S.i1=idxOf(Pp);if(S.i2<0||S.i2>=pts.length)S.i2=idxOf(Pp);
  const P1=pts[S.i1],P2=pts[S.i2],sum=EX.add(E,P1,P2),m=EX.mul(CQ,k,PQ);
  let h='<div class="rhm ell" data-role="ell-points">';
  h+='<p class="note" data-role="ell-head">Curve <select data-role="ell-preset" aria-label="curve preset"><option value="37a1" selected>37a1</option></select> '+esc(PRE.note)+' · ainvs [0, 0, 1, '+MINUS+'1, 0] · b2, b4, b6, b8 = '+[CQ.b2,CQ.b4,CQ.b6,CQ.b8].map(EX.qstr).join(', ')+' · c4 = '+EX.qstr(CQ.c4)+', c6 = '+EX.qstr(CQ.c6)+' · <b>Δ = '+EX.qstr(CQ.disc)+'</b> · short model y² = x³ '+MINUS+' 16x + 16 by (u, r, s, t) = (1/2, 0, 0, '+MINUS+'1/2).</p>';
  // k dial
  h+='<div class="rhm-row"><label>k <input type="range" min="1" max="20" step="1" value="'+k+'" data-role="ell-k" aria-label="multiple k"></label><b data-role="ell-kval">k = '+k+'</b></div>';
  h+='<p class="read" data-role="ell-kP">'+k+'P = <span class="rhm-exact">'+esc(EX.ptStr(CQ,m.R))+'</span> (exact, over ℚ)</p>';
  h+='<div class="rhm-scroll"><table data-role="ell-trace" style="white-space:nowrap"><tr><th>step</th><th>operation</th><th>case</th><th>result</th></tr>';
  m.steps.forEach((s,i)=>{h+='<tr data-role="ell-step" data-case="'+s.key+'"><td>'+(i+1)+'</td><td>'+esc(s.op)+'</td><td>'+esc(s.case)+'</td><td class="rhm-exact" style="text-align:left">'+esc(EX.ptStr(CQ,s.R))+'</td></tr>';});
  h+='</table></div><p class="note dim">[k]P by left-to-right double-and-add on the bits of k = '+k.toString(2)+'₂ (the first step is O + P). Every step names its case of the five-case table.</p>';
  // p dial and scatter
  h+='<div class="rhm-row"><label>p <select data-role="ell-p" aria-label="prime p">'+PRIMES.map(q=>'<option value="'+q+'"'+(q===p?' selected':'')+'>'+q+(q===37n?' (bad)':'')+'</option>').join('')+'</select></label>';
  h+='<span data-role="ell-count">#E(F_'+p+') = '+(bad.type==='good'?pts.length:all.length+' points in all = '+pts.length+' nonsingular (the group E_ns(F_'+p+')) + 1 singular')+'</span></div>';
  if(bad.type!=='good')h+='<p class="note warn" data-role="ell-bad">p = '+p+' is the bad prime (p | Δ): reduction '+esc(bad.label)+'; singular point '+esc(EX.ptStr(E,bad.singular))+' drawn in red and labelled. The count of route (i) includes it; the P1 / P2 lists do not (they list the group E_ns).</p>';
  h+='<canvas data-role="ell-scatter" width="'+CW+'" height="'+CH+'" role="img" aria-label="E(F_p) on the p by p grid, O as a marker outside the grid" style="display:block;width:100%;max-width:'+CW+'px;height:auto;background:var(--bg-inset);border:1px solid var(--line-grid);border-radius:4px"></canvas>';
  {const z=S.zoom,sp=(p+z-1n)/z;h+='<div class="rhm-row" data-role="ell-zoomrow"><label>zoom <select data-role="ell-zoom" aria-label="scatter zoom">'+[1n,2n,4n].map(v=>'<option value="'+v+'"'+(v===z?' selected':'')+'>'+v+'×</option>').join('')+'</select></label>'+(z>1n?'<button type="button" data-role="ell-pan" data-d="l" aria-label="pan left">◀</button><button type="button" data-role="ell-pan" data-d="r" aria-label="pan right">▶</button><button type="button" data-role="ell-pan" data-d="d" aria-label="pan down">▼</button><button type="button" data-role="ell-pan" data-d="u" aria-label="pan up">▲</button><span class="rhm-dim" data-role="ell-window">window x '+S.wx+' … '+(S.wx+sp-1n)+', y '+S.wy+' … '+(S.wy+sp-1n)+'</span>':'')+'</div>';}
  h+='<p class="note dim">Cyan: the affine points (x, y) of E(F_'+p+'), y upward. The diamond right of the grid is O. Amber box: P1; violet: P2 (drawn larger when P2 = P1, so both stay visible); green: P1 + P2. Zoom 2× or 4× shows a window of the grid; the arrows move it by half a window. Dots are at least 3 px.</p>';
  // P1, P2
  const opt=(sel)=>pts.map((Q,i)=>'<option value="'+i+'"'+(i===sel?' selected':'')+'>'+esc(EX.ptStr(E,Q))+'</option>').join('');
  h+='<div class="rhm-row"><label>P1 <select data-role="ell-p1" aria-label="P1">'+opt(S.i1)+'</select></label><label>P2 <select data-role="ell-p2" aria-label="P2">'+opt(S.i2)+'</select></label></div>';
  h+='<p class="read" data-role="ell-sum">'+esc(EX.ptStr(E,P1))+' + '+esc(EX.ptStr(E,P2))+' = <b>'+esc(EX.ptStr(E,sum.R))+'</b> over F_'+p+' · case <b data-role="ell-case-active">'+esc(sum.case)+'</b>'+(sum.lambda!==undefined?' · λ = '+sum.lambda+', ν (nu) = '+sum.nu:'')+'</p>';
  const rows=[['P1 = O','','P2'],['P2 = O (P1 ≠ O)','','P1'],['P2 = '+MINUS+'P1','x1 = x2 and y1 + y2 + a1x2 + a3 = 0','O'],['generic','x1 ≠ x2','λ = (y2 '+MINUS+' y1)/(x2 '+MINUS+' x1)'],['doubling','P1 = P2, not 2-torsion','λ = (3x1² + 2a2x1 + a4 '+MINUS+' a1y1)/(2y1 + a1x1 + a3)']];
  // v0.4.18: one stacked block per case (no table columns to wrap inside words at 375 px)
  h+='<div data-role="ell-cases" style="display:grid;gap:4px">';
  rows.forEach((r,i)=>{const on=i===sum.index;h+='<div data-role="ell-case" data-key="'+caseCls[i]+'"'+(on?' data-active="1" style="background:#10b98133;outline:2px solid #10b981;border-radius:3px;padding:3px 6px"':' style="border:1px solid var(--line-grid);border-radius:3px;padding:3px 6px"')+'><div><b>'+(on?'▶ ':'')+esc(r[0])+'</b></div>'+(r[1]?'<div class="rhm-dim" style="overflow-wrap:normal;word-break:normal">if '+esc(r[1])+'</div>':'')+'<div style="overflow-wrap:normal;word-break:normal">→ '+esc(r[2])+'</div></div>';});
  h+='</div><p class="note dim">In both λ cases ν (nu) = y1 '+MINUS+' λx1, x3 = λ² + a1λ '+MINUS+' a2 '+MINUS+' x1 '+MINUS+' x2, y3 = '+MINUS+'(λ + a1)x3 '+MINUS+' ν '+MINUS+' a3. Exactly one case applies (asserted). Inverses mod p by the extended Euclidean algorithm. Table: Akshima et al. (2026), sec. 3 (first subsection), as given in the build brief.</p>';
  // enc
  {let coll=0;const seen=new Set();for(const Q of pts){const e=EX.enc(E,Q);if(seen.has(e))coll++;seen.add(e);}
   h+='<p class="note" data-role="ell-enc">enc(A) = 2x + (y mod 2): injective whenever a1 = a3 = 0 (the two points over one x have y and p '+MINUS+' y, of opposite parity for odd p). Not so on 37a1 for odd p: a3 = 1 pairs y with y′ = '+MINUS+'y '+MINUS+' 1, and y + y′ = p '+MINUS+' 1 is even, so both have the same parity. Collisions here, p = '+p+': <b data-role="ell-enc-coll">'+coll+'</b>'+(p===2n?' (p = 2: y and y + 1 differ in parity, so enc is injective)':'')+'.</p>';}
  // a_p table
  const T=apTable();
  h+='<p class="lbl">a_p by two routes, p &lt; 100</p><div class="rhm-scroll" style="max-height:320px"><table data-role="ell-ap" style="white-space:nowrap"><tr><th>p</th><th>#E (i)</th><th>a_p (i) naive</th><th>a_p (ii) χ-sum</th><th>agree</th><th>reduction</th></tr>';
  for(const r of T){const isBad=r.rt.type!=='good';h+='<tr data-role="ell-ap-row" data-p="'+r.p+'"'+(isBad?' style="background:#ff5e6c26"':'')+(r.p===p?' class="sel"':'')+'><td>'+r.p+'</td><td>'+r.i.count+'</td><td>'+sgn(r.i.ap)+'</td><td>'+(r.ii?sgn(r.ii.ap):'—')+'</td><td data-role="ell-agree">'+(r.ii?(r.agree?'yes':'NO'):'route (i) only')+'</td><td style="text-align:left" data-role="ell-red" data-type="'+r.rt.type+'">'+esc(redLabel(r.rt))+'</td></tr>';}
  h+='</table></div><p class="note dim">Route (i): all projective points of the reduction mod p, the singular point included, a_p = p + 1 '+MINUS+' #. Route (ii), odd p: (2y + a1x + a3)² = 4x³ + b2x² + 2b4x + b6 and a_p = '+MINUS+'Σ (f(x)/p), each symbol by Jacobi reciprocity. p = 2 has route (i) only. The bad prime 37 is a row like any other, labelled with its reduction type.</p>';
  h+='<p class="note dim" data-role="ell-scope">Registers: exact (BigInt over ℚ and F_p) for every number on this card; drawing (canvas pixels, integers) for the scatter. Fixture: Sage 37a1 reference (sha256 599c6855…), checked by host-core/test-elliptic-exact.cjs. Not claimed: anything about ECDL; the card is a finite exact readout.</p></div>';
  body.innerHTML=h;
  const cv=body.querySelector('[data-role="ell-scatter"]');if(cv){try{drawScatter(cv,p,all,bad,{P1,P2,R:sum.R},{zoom:S.zoom,wx:S.wx,wy:S.wy});}catch(e){cv.dataset.error=String(e);}}
  const re=()=>renderPoints(body,M);
  bindDial(body,'ell-k','input',x=>{const b=body.querySelector('[data-role="ell-kval"]');if(b)b.textContent='k = '+x.value;});
  bindDial(body,'ell-k','change',x=>{S.k=BigInt(x.value);re();});
  bindDial(body,'ell-p','change',x=>{S.p=BigInt(x.value);S.i1=-1;S.i2=-1;S.wx=0n;S.wy=0n;re();});
  bindDial(body,'ell-zoom','change',x=>{S.zoom=BigInt(x.value);S.wx=0n;S.wy=0n;re();});
  body.querySelectorAll('[data-role="ell-pan"]').forEach(b=>b.addEventListener('click',()=>{const span=(p+S.zoom-1n)/S.zoom,st=span/2n>0n?span/2n:1n,mx=p-span,cl=v=>v<0n?0n:v>mx?mx:v,d=b.dataset.d;
    if(d==='l')S.wx=cl(S.wx-st);if(d==='r')S.wx=cl(S.wx+st);if(d==='d')S.wy=cl(S.wy-st);if(d==='u')S.wy=cl(S.wy+st);re();}));
  bindDial(body,'ell-p1','change',x=>{S.i1=x.selectedIndex;re();});
  bindDial(body,'ell-p2','change',x=>{S.i2=x.selectedIndex;re();});
}
// ---------------------------------------------------------------- card 2: period lattice
const LW=360n,LH=300n;
function drawCell(cv,R){
  const c=cv.getContext('2d');c.setTransform(1,0,0,1,0,0);c.fillStyle='#08080f';c.fillRect(0,0,px(LW),px(LH));
  const w1=R.raw.w1.lo,w2=R.raw.w2.lo,mx=w1>w2?w1:w2,L=130n,W=w1*L/mx,H=w2*L/mx,x0=(LW-W)/2n,y0=(LH+H)/2n;
  // neighbouring cells, dashed (drawing)
  c.setLineDash([4,4]);c.strokeStyle='#45456a';c.lineWidth=1;
  for(const [i,j] of [[-1n,0n],[1n,0n],[0n,-1n],[0n,1n]])c.strokeRect(px(x0+i*W),px(y0-H-j*H),px(W),px(H));
  c.setLineDash([]);c.strokeStyle='#00e5ff';c.lineWidth=2;c.strokeRect(px(x0),px(y0-H),px(W),px(H));
  c.fillStyle='#d4d4e8';for(const [i,j] of [[0n,0n],[1n,0n],[0n,1n],[1n,1n]])c.fillRect(px(x0+i*W-3n),px(y0-j*H-3n),6,6);
  c.font='13px ui-monospace,Consolas,monospace';c.fillStyle='#00e5ff';c.fillText('ω₁',px(x0+W/2n-8n),px(y0+18n));c.fillStyle='#ff5e6c';c.fillText('ω₂',px(x0-28n),px(y0-H/2n));
  c.fillStyle='#9a9ab8';c.fillText('0',px(x0-12n),px(y0+14n));
  cv.dataset.w=String(W);cv.dataset.h=String(H);
}
function agmTable(role,G,D){
  let h='<div class="rhm-scroll" style="max-height:260px"><table data-role="'+role+'"><tr><th>n</th><th>a_n (guaranteed digits)</th><th>b_n (guaranteed digits)</th></tr>';
  for(const s of G.steps)h+='<tr data-role="'+role+'-row"><td>'+s.n+'</td><td class="rhm-exact" style="text-align:left">'+esc(s.a.digits)+'</td><td class="rhm-exact" style="text-align:left">'+esc(s.b.digits)+'</td></tr>';
  return h+'</table></div>';
}
function renderPeriod(body,M){
  if(!lazy(body,M,renderPeriod))return;
  const D=S.D,cu=PCURVES[S.curve],t0=Date.now(),R=PE.periods(cu.ainvs,D),ms=Date.now()-t0;
  let h='<div class="rhm ell" data-role="per-card">';
  h+='<div class="rhm-row"><label>curve <select data-role="per-curve" aria-label="curve">'+Object.keys(PCURVES).map(k=>'<option value="'+k+'"'+(k===S.curve?' selected':'')+'>'+esc(PCURVES[k].label)+'</option>').join('')+'</select></label></div>';
  h+='<div class="rhm-row"><label>D <input type="range" min="10" max="100" step="1" value="'+D+'" data-role="per-D" aria-label="decimal digits D"></label><b data-role="per-Dval">D = '+D+'</b><span class="rhm-dim" data-role="per-ms">'+(R.refused?'':'W = '+R.W+' working bits · computed in '+ms+' ms (cached per D)')+'</span></div>';
  if(R.refused){h+='<p class="note warn" data-role="per-refused">'+esc(R.label)+'</p><p class="note dim">Δ = '+esc(String(R.disc).replace(/-/g,MINUS))+'. One real root: the complex AGM would be needed, and it is not built in exact interval arithmetic here. No floating-point fallback.</p></div>';body.innerHTML=h;bindPer(body,M);return;}
  const rows=[['e1','e₁',R.e1],['e2','e₂',R.e2],['e3','e₃',R.e3],['w1','ω₁',R.w1],['w2','ω₂/i',R.w2_over_i],['tau','τ/i = ω₂/(iω₁)',R.tau_over_i],['Omega','Ω = 2ω₁',R.Omega]];
  h+='<dl class="rhm-kv">';
  for(const [k,l,x] of rows)h+='<dt>'+esc(l)+'</dt><dd data-role="per-row" data-key="'+k+'" data-places="'+x.places+'"><span class="rhm-exact" data-role="per-digits">'+esc(x.digits)+'</span><br><span class="rhm-dim" data-role="per-width">'+esc(x.width)+'</span></dd>';
  h+='</dl>';
  h+='<p class="note" data-role="per-reason">'+esc(R.omega_reason)+'. Lattice '+esc(R.lattice)+'; τ = i · (τ/i).</p>';
  h+='<p class="note dim">Guaranteed digits: each value is an interval [lo, hi]·2^−W with outward rounding; only the places on which lo and hi agree after rounding (half up) are printed, up to D. Roots of 4x³ + b2x² + 2b4x + b6 by a Sturm sequence and exact sign bisection; square roots by BigInt isqrt; '+esc(R.pi.method)+' ('+R.pi.terms.join(' + ')+' terms).</p>';
  h+='<canvas data-role="per-cell" width="'+LW+'" height="'+LH+'" role="img" aria-label="rectangular fundamental cell with sides omega 1 and omega 2" style="display:block;width:100%;max-width:'+LW+'px;height:auto;background:var(--bg-inset);border:1px solid var(--line-grid);border-radius:4px"></canvas>';
  h+='<p class="note dim">Fundamental cell 0, ω₁, ω₂, ω₁ + ω₂ (cyan) and its four neighbours (dashed). Pixel sides from the lower endpoints by BigInt division (drawing register).</p>';
  h+='<p class="lbl">AGM(√(e₁ '+MINUS+' e₃), √(e₁ '+MINUS+' e₂)) → ω₁ = π/M₁</p>'+agmTable('per-agm1',R.agm1,D)+'<p class="note dim" data-role="per-bound1">'+esc(R.agm1.bound)+'</p>';
  h+='<p class="lbl">AGM(√(e₁ '+MINUS+' e₃), √(e₂ '+MINUS+' e₃)) → ω₂/i = π/M₂</p>'+agmTable('per-agm2',R.agm2,D)+'<p class="note dim">'+esc(R.agm2.bound)+'</p>';
  h+='<p class="note dim" data-role="per-scope">Registers: the exact register is BigInt (the curve, Δ, the cubic and its Sturm sequence); the interval enclosures are the numerical register with guarantees; canvas pixels are the drawing register. Reference: Sage 37a1 strings (sha256 599c6855…), checked by host-core/test-elliptic-period.cjs at D = 50 and 100.</p></div>';
  body.innerHTML=h;
  const cv=body.querySelector('[data-role="per-cell"]');if(cv){try{drawCell(cv,R);}catch(e){cv.dataset.error=String(e);}}
  bindPer(body,M);
}
function bindPer(body,M){const re=()=>renderPeriod(body,M);
  bindDial(body,'per-D','input',x=>{const b=body.querySelector('[data-role="per-Dval"]');if(b)b.textContent='D = '+x.value;});
  bindDial(body,'per-D','change',x=>{S.D=BigInt(x.value);re();});
  bindDial(body,'per-curve','change',x=>{S.curve=x.value;re();});}
V.registerPanel({id:'elliptic-points-exact',title:'Elliptic points (exact)',group:'D',collapsed:true,register:'exact',coupling:'reads nothing from the host; writes nothing',
  description:'37a1 over ℚ and F_p: kP with the case of every step, E(F_p) on the p × p grid, P1 + P2 with the five-case table, a_p by two routes.',source:'build brief v0.4.17 (group D exact, part 1); host-core/elliptic-exact-core.js',actions:[],
  about:'register: exact (BigInt) and drawing (canvas pixels) · display only',render:(el,M)=>renderPoints(el,M)});
V.registerPanel({id:'period-lattice-exact',title:'Period lattice (exact intervals)',group:'D',collapsed:true,register:'mixed',coupling:'reads nothing from the host; writes nothing',
  description:'Guaranteed digits of e1, e2, e3, ω₁, ω₂/i, τ and Ω for 37a1 by interval AGM, with the AGM step table and the fundamental cell.',source:'build brief v0.4.17 (group D exact, part 2); host-core/elliptic-period-core.js',actions:[],
  about:'register: numerical with guarantees (BigInt interval enclosures), exact (the curve), drawing (canvas pixels) · display only',render:(el,M)=>renderPeriod(el,M)});
root.FVEllipticCards={S,apTable,ptsAt,drawScatter,drawCell,PRIMES,redLabel,redShort};
})(typeof globalThis!=='undefined'?globalThis:this);
