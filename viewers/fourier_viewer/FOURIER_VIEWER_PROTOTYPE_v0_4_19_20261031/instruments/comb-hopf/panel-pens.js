(function(root){
'use strict';
// Panels-tab group E of v0.4.18 (SCHEMA_ADDENDUM_25): "Curvature pen" and "Squeezed-sphere pen", the surface pens with the Goldbach stream.
// Idea (Rule 30 written on surfaces; the spherical Fourier pen; the sphere squeeze; the Goldbach work): saphir. Pen pages and the curvature-pen rule:
// the Rule 30 skeleton seat (four pages, floats); re-implemented here without floating point (saphir: "No floating point").
// Registers: EXACT (signs, integers, flags, the fields F = Q(sqrt2, sqrt5, tau) and K = Q(sqrt3, sqrt5)), GUARANTEED NUMERICAL (BigInt interval enclosures),
// DRAWING (integer canvas pixels from the enclosures by BigInt division, handed to canvas by the helper px below).
// Display only: the dials live in this module (FVPenCards.S), not in the host state, the address or the exports.
// v0.4.19 fix round (SCHEMA_ADDENDUM_26): the Goldbach tooth order as decided; two pixel counts (wider than 1/4 px; undecided) and the P-doubling rule;
// the sphere card shows the disk dials disabled, a tooth-events toggle with smaller dots, dodecahedron edges as great-circle arcs; thinned shell ticks;
// the A5 and Codex wording.
const V=root.FVViews,ST=root.FVPenStreams,CV=root.FVPenCurvature,SP=root.FVPenSphere,IV=root.FVPenIv,FQ=root.FVFieldQ2Q5Tau,esc=V.esc,MINUS='−';
const px=b=>{if(typeof b!=='bigint')throw Error('px needs a BigInt');return Number(b);};
const B=x=>BigInt(x);
const S={stream:'30',T:512n,seed:1n,N:24n,Nmax:100n,follow:true,W:200n,lam:15n,preset:'free',a:3n,th:2n,teeth:true};   // v0.4.19: teeth = the sphere card's tooth-events toggle
const KEY='fv-comb-hopf-panels-open',IDS=['pen-curvature-exact','pen-sphere-exact'];
const SPHERE_T_CAP=4096n,TILING_DEPTH=8;
const STREAM_LABEL={'30':'Rule 30','150':'Rule 150','coin':'Fair coin (control)','gbshell':'Goldbach shell N','gbrun':'Goldbach run 4 … N_max'};
const COL={bg:'#08080f',grid:'#2e2e4a',axis:'#45456a',disk:'#131321',plus:'#00e5ff',minus:'#ff5e6c',tick:'#fbbf24',pen:'#00e5ff',start:'#10b981',ink:'#d4d4e8',tooth:'#fbbf24',back:'#3a4a66'};
const AGE=['#7dd3fc','#22d3ee','#f59e0b','#f97316'];   // oldest ... newest (four buckets by step index; no division on Numbers)
const ageCol=(i,n)=>{let k=0;while(k<3&&4*i>=(k+1)*n)k++;return AGE[k];};
// ---------------------------------------------------------------- streams (cached)
const SC=new Map();
function curStream(){
  const key=S.stream+'|'+S.T+'|'+S.seed+'|'+S.N+'|'+S.Nmax;if(SC.has(key))return SC.get(key);
  const o={T:px(S.T),seed:S.seed,N:px(S.N),Nmax:px(S.Nmax)};const st=ST.stream(S.stream,o);
  if(SC.size>12)SC.clear();SC.set(key,st);return st;
}
// ---------------------------------------------------------------- drawing helpers (integer pixels only)
function ctxOf(cv){const c=cv.getContext('2d');c.setTransform(1,0,0,1,0,0);c.fillStyle=COL.bg;c.fillRect(0,0,cv.width,cv.height);return c;}
function poly(c,P,col,w){if(P.length<2)return;c.strokeStyle=col;c.lineWidth=w;c.beginPath();c.moveTo(px(P[0][0]),px(P[0][1]));for(let i=1;i<P.length;i++)c.lineTo(px(P[i][0]),px(P[i][1]));c.stroke();}
function dot(c,x,y,r,col){c.fillStyle=col;c.fillRect(px(x-r),px(y-r),px(2n*r+1n),px(2n*r+1n));}
function discFill(c,cx,cy,r,col){c.fillStyle=col;for(let dy=-r;dy<=r;dy++){const dx=IV.isqrt(r*r-dy*dy);c.fillRect(px(cx-dx),px(cy+dy),px(2n*dx+1n),1);}}
function circleLine(c,cx,cy,r,col){c.fillStyle=col;for(let dy=-r;dy<=r;dy++){const dx=IV.isqrt(r*r-dy*dy);for(const [x,y] of [[cx-dx,cy+dy],[cx+dx,cy+dy],[cx+dy,cy-dx],[cx+dy,cy+dx]])c.fillRect(px(x),px(y),1,1);}}
function strip(cv,s,n,bounds,cap){
  const c=ctxOf(cv),Wd=B(cv.width),H=B(cv.height),L=B(s.length);cv.dataset.len=String(s.length);cv.dataset.drawn=String(n);cv.dataset.ticks=String(bounds.length);
  if(s.length===0){c.fillStyle=COL.ink;c.font='13px ui-monospace,Consolas,monospace';c.fillText('T = 0: empty stream',6,18);cv.dataset.tickEvery='1';cv.dataset.ticksDrawn='0';return {k:1,drawn:0};}
  const pre=new Int32Array(s.length+1);for(let i=0;i<s.length;i++)pre[i+1]=pre[i]+(s[i]>0?1:0);
  for(let x=0n;x<Wd;x++){const a=x*L/Wd,b0=(x+1n)*L/Wd,b=b0>a?b0:a+1n;if(a>=L)break;const bb=b>L?L:b,cnt=bb-a,pl=B(pre[px(bb)]-pre[px(a)]),hp=(H-8n)*pl/cnt;
    c.fillStyle=COL.minus;c.fillRect(px(x),2,1,px(H-8n));c.fillStyle=COL.plus;c.fillRect(px(x),px(H-6n-hp),1,px(hp));}
  // v0.4.19: when shell ticks would be closer than 3 px, draw every k-th tick (k the smallest integer keeping consecutive drawn ticks >= 3 px apart)
  const k=tickEvery(bounds,Wd,L);let drawn=0;
  c.fillStyle=COL.tick;for(let i=0;i<bounds.length;i+=k){const x=B(bounds[i])*Wd/L;c.fillRect(px(x),px(H-5n),1,5);drawn++;}
  cv.dataset.tickEvery=String(k);cv.dataset.ticksDrawn=String(drawn);
  if(cap!==null&&cap<s.length){const x=B(cap)*Wd/L;c.fillStyle=COL.ink;c.fillRect(px(x),0,2,px(H));}
  return {k,drawn};
}
// the tick pixel of every shell boundary, and the smallest k with every pair of consecutive drawn ticks (0, k, 2k, ...) at least 3 px apart
function tickEvery(bounds,Wd,L){
  if(bounds.length<2||L===0n)return 1;const xs=bounds.map(b=>B(b)*Wd/L);
  const okK=k=>{for(let i=k;i<xs.length;i+=k)if(xs[i]-xs[i-k]<3n)return false;return true;};
  let k=1;while(k<xs.length&&!okK(k))k++;return k;
}
const tickNote=k=>k>1?'Shell ticks: ticks every '+k+' shells (consecutive shell ticks would be closer than 3 px).':'';
// ---------------------------------------------------------------- k = 0 lattice (exact)
function drawLattice(cv,P){
  const c=ctxOf(cv),Wd=B(cv.width),cx=Wd/2n;let mx=3n;for(let i=0;i<=P.n;i++){const x=B(P.X[i]<0?-P.X[i]:P.X[i]),y=B(P.Y[i]<0?-P.Y[i]:P.Y[i]);if(x>mx)mx=x;if(y>mx)mx=y;}
  const num=Wd*9n,den=20n*mx,X=x=>cx+B(x)*num/den,Y=y=>cx-B(y)*num/den;
  if(num>=6n*den){c.strokeStyle=COL.grid;c.lineWidth=1;c.beginPath();for(let k=-mx;k<=mx;k++){c.moveTo(px(X(k)),px(Y(-mx)));c.lineTo(px(X(k)),px(Y(mx)));c.moveTo(px(X(-mx)),px(Y(k)));c.lineTo(px(X(mx)),px(Y(k)));}c.stroke();}
  const n=P.n,parts=4;for(let q=0;q<parts;q++){const a=(q*n)>>2,b=((q+1)*n)>>2;const pts=[];for(let i=a;i<=b;i++)pts.push([X(P.X[i]),Y(P.Y[i])]);poly(c,pts,AGE[q],2);}
  dot(c,X(0),Y(0),3n,COL.start);dot(c,X(P.X[n]),Y(P.Y[n]),3n,COL.ink);cv.dataset.mx=String(mx);
}
// ---------------------------------------------------------------- k = +1 octahedron (exact rationals; display by an integer quaternion)
const QM=SP.quatMatrix(...SP.VIEW_Q);
function drawOct(cv,fl,lam){
  const c=ctxOf(cv),Wd=B(cv.width),cx=Wd/2n,R=Wd*44n/100n,n=fl.length-1,Tn=B(n>0?n:1),L=lam,sub=n<=8192?4n:2n,step=4n/sub;
  discFill(c,cx,cx,R*100n/(100n+L),COL.disk);
  // a point of the arc from a to b (orthogonal unit integer vectors): (a (16 - k^2) + b 8k) / (16 + k^2), k = 0 ... 4 (t = k/4: rational point on the circle)
  const proj=(a,b,k,lift)=>{const v=[0,1,2].map(i=>B(a[i])*(16n-k*k)+B(b[i])*8n*k),dn=16n+k*k,row=r=>QM.m[r][0]*v[0]+QM.m[r][1]*v[1]+QM.m[r][2]*v[2];
    const rad=lift;   // {n, d}: radius 1 + lam*t/T
    const scale=num=>R*100n*rad.n*num,den=(100n+L)*rad.d*QM.den*dn;return {x:cx+IV.fdiv(scale(row(0)),den),y:cx-IV.fdiv(scale(row(2)),den),front:row(1)>=0n};};
  // the 12 edges, faint
  const VS=[[1,0,0],[-1,0,0],[0,1,0],[0,-1,0],[0,0,1],[0,0,-1]];c.strokeStyle=COL.grid;c.lineWidth=1;
  for(let i=0;i<6;i++)for(let j=i+1;j<6;j++){const a=VS[i],b=VS[j];if(a[0]*b[0]+a[1]*b[1]+a[2]*b[2]!==0)continue;const P=[];for(let k=0n;k<=4n;k++){const p=proj(a,b,k,{n:1n,d:1n});P.push([p.x,p.y]);}poly(c,P,COL.grid,1);}
  let back=0,front=0;
  for(let i=0;i<n;i++){const a=fl[i].x,b=fl[i+1].x,col=ageCol(i,n);const P=[];let fr=true;
    for(let k=0n;k<=4n;k+=step){const lift={n:400n*Tn+L*(4n*B(i)+k),d:400n*Tn},p=proj(a,b,k,lift);if(k===2n)fr=p.front;P.push([p.x,p.y]);}
    if(fr){front++;poly(c,P,col,2);}else{back++;poly(c,P,COL.back,1);}}
  const e=fl[n].x,pe=proj(e,e,0n,{n:400n*Tn+L*4n*B(n),d:400n*Tn});dot(c,pe.x,pe.y,3n,COL.ink);
  cv.dataset.front=String(front);cv.dataset.back=String(back);
}
// ---------------------------------------------------------------- k = -1 disk (exact F[i] for short runs, intervals otherwise)
const DISK_PX=118n;let TILE=null;
// v0.4.19: two counts per drawn point (SCHEMA_ADDENDUM_26): bad = enclosure wider than 1/4 px (the v0.4.18 count), und = pixel undecided (floor(lo) != floor(hi) on an axis)
function diskPixel(z,P,cx,R,stats){const a=IV.pixelCert(z.re,P,R,cx,false),b=IV.pixelCert(z.im,P,R,cx,true);stats.pts++;if(a.wide||b.wide)stats.bad++;if(a.undecided||b.undecided)stats.und++;return [a.p,b.p];}
// v0.4.19 (SCHEMA_ADDENDUM_26, verify finding 5): the precision multiplier mul (1, 2, 4) scales P of the absolute run and of the follow-the-pen trail;
// the caller (renderCurv) doubles it when the distance has fewer than 6 guaranteed places or the count "enclosure wider than 1/4 px" is non-zero,
// at most CV.P_DOUBLINGS_MAX times. (v0.4.18 doubled P once, on the distance alone, inside this function.)
function diskModel(s,n,mul){
  // the absolute run and its distance
  mul=mul||1n;const t0=Date.now();let reg,P=null,dist,frames=null,exact=null;
  if(n<=CV.EXACT_T_MAX){exact=CV.diskExact(s,n);reg='exact over F[i] (F = ℚ(√2, √5, τ))';dist=CV.distanceExact(exact[n]);}
  else{P=mul*CV.workingBits(n);const run=CV.diskIntervalRun(s,n,P,!S.follow);dist=CV.distance(run.g);
    frames=run.frames;reg='guaranteed intervals, block floating, P = '+P+' bits';}
  return {reg,P,dist,frames,exact,mul,ms:Date.now()-t0};
}
function drawDisk(cv,s,n,dm){
  const c=ctxOf(cv),Wd=B(cv.width),cx=Wd/2n,R=DISK_PX,stats={pts:0,bad:0,und:0,trailP:null};
  discFill(c,cx,cx,R,COL.disk);circleLine(c,cx,cx,R,COL.axis);
  if(!TILE)TILE=CV.tilingGeometry(TILING_DEPTH);
  for(const e of TILE)poly(c,e.map(z=>diskPixel(z,CV.DRAW_BITS,cx,R,stats)),COL.grid,1);
  let geo;
  if(S.follow){const w=px(S.W)<n?px(S.W):n;let fr;
    if(dm.exact){let Q=FQ.SU.I;const ex=[Q];for(let j=0;j<w;j++){Q=FQ.SU.mul(Q,FQ.SU.inv(s[n-j-1]>0?FQ.ML:FQ.MR));ex.push(Q);}fr=ex.map(g=>CV.mIv(g,CV.DRAW_BITS));}
    else{stats.trailP=(dm.mul||1n)*CV.workingBits(w);fr=CV.trailFrames(s,n,w,stats.trailP);}
    geo=CV.pathGeometry(fr,j=>s[n-j-1],true);
    // newest edges last: edge j is j steps ago
    for(let j=geo.edges.length-1;j>=0;j--)poly(c,geo.edges[j].map(z=>diskPixel(z,geo.P,cx,R,stats)),ageCol(geo.edges.length-1-j,geo.edges.length),2);
    const p=diskPixel(geo.pts[0],geo.P,cx,R,stats);dot(c,p[0],p[1],3n,COL.ink);
  }else{const fr=dm.exact?dm.exact.map(g=>CV.mIv(g,CV.DRAW_BITS)):dm.frames;geo=CV.pathGeometry(fr,j=>s[j],false);
    for(let j=0;j<geo.edges.length;j++)poly(c,geo.edges[j].map(z=>diskPixel(z,geo.P,cx,R,stats)),ageCol(j,geo.edges.length),2);
    const p0=diskPixel(geo.pts[0],geo.P,cx,R,stats);dot(c,p0[0],p0[1],3n,COL.start);const p=diskPixel(geo.pts[geo.pts.length-1],geo.P,cx,R,stats);dot(c,p[0],p[1],3n,COL.ink);}
  cv.dataset.points=String(stats.pts);cv.dataset.uncertified=String(stats.bad);cv.dataset.undecided=String(stats.und);cv.dataset.tilingEdges=String(TILE.length);
  return stats;
}
// ---------------------------------------------------------------- the sphere pen
const SPH_DRAW=96n;
function sphereModel(s,n){
  const t0=Date.now();
  if(S.preset==='dodeca'){const fl=SP.dodecaPen(s,n),pts=SP.dodecaToIv(fl,SPH_DRAW),cov=SP.coverageExact(fl),arcs=SP.dodecaArcs(fl,SPH_DRAW);return {reg:'exact in K = ℚ(√3, √5)',P:null,pts,arcs,Pd:SPH_DRAW,cov,ms:Date.now()-t0,fl};}
  const r=SP.penBall(s,n,[S.a,96n],[S.th,24n]),P=r.P,pts=r.pts.map(p=>p.map(e=>IV.rescale(e,P,SPH_DRAW))),cov=SP.coverage(r.pts,P);
  return {reg:'guaranteed balls (one orthogonal step matrix per sign, radius linear in T), P = '+P+' bits, final radius '+r.eps+'·2^−'+P,P,pts,Pd:SPH_DRAW,cov,ms:Date.now()-t0};
}
function drawSphere(cv,sm,tooth){
  const c=ctxOf(cv),Wd=B(cv.width),cx=Wd/2n,R=Wd*44n/100n,Pd=sm.Pd,stats={pts:0,bad:0,und:0};
  discFill(c,cx,cx,R,COL.disk);circleLine(c,cx,cx,R,COL.axis);
  const prj=p=>{const row=r=>{let s=IV.pt(0n);for(let k=0;k<3;k++)s=IV.add(s,IV.mulInt(p[k],QM.m[r][k]));return IV.iv(IV.fdiv(s.lo,QM.den),IV.cdiv(s.hi,QM.den));};
    const X=IV.pixelCert(row(0),Pd,R,cx,false),Y=IV.pixelCert(row(2),Pd,R,cx,true),dp=IV.sign(row(1));stats.pts++;if(X.wide||Y.wide)stats.bad++;if(X.undecided||Y.undecided)stats.und++;return {x:X.p,y:Y.p,front:dp===null||dp>=0};};
  const Q=sm.pts.map(prj),n=Q.length-1;let teeth=0,events=0,arcPts=0;
  // v0.4.19: the dodecahedron preset draws every step as its great-circle arc (SP.dodecaArc: interval-normalised points, counted like every other point);
  // free (alpha, theta) steps stay straight chords between the step's end points (labelled on the card)
  for(let i=0;i<n;i++){const a=Q[i],b=Q[i+1];
    if(sm.arcs){const P=[a].concat(sm.arcs[i].map(prj),[b]);arcPts+=P.length-2;for(let k=0;k+1<P.length;k++){const u=P[k],v=P[k+1],fr=u.front||v.front;poly(c,[[u.x,u.y],[v.x,v.y]],fr?ageCol(i,n):COL.back,fr?2:1);}}
    else{const fr=a.front||b.front;poly(c,[[a.x,a.y],[b.x,b.y]],fr?ageCol(i,n):COL.back,fr?2:1);}}
  // v0.4.19: tooth events behind a toggle (default on) and drawn smaller (3 px front, 1 px back; v0.4.18: 5 px and 3 px)
  if(tooth)for(let i=0;i<n&&i<tooth.length;i++)if(tooth[i]){events++;if(S.teeth){teeth++;dot(c,Q[i].x,Q[i].y,Q[i].front?1n:0n,COL.tooth);}}
  dot(c,Q[0].x,Q[0].y,3n,COL.start);dot(c,Q[n].x,Q[n].y,3n,COL.ink);
  cv.dataset.points=String(stats.pts);cv.dataset.uncertified=String(stats.bad);cv.dataset.undecided=String(stats.und);cv.dataset.teeth=String(teeth);cv.dataset.events=String(events);cv.dataset.arcPoints=String(arcPts);cv.dataset.edges=sm.arcs?'arcs':'chords';
  return {stats,teeth,events,arcPts};
}
// ---------------------------------------------------------------- shared dials
const NOPTS=(()=>{let h='';for(let N=4;N<=1448;N+=2)h+='<option value="'+N+'">'+N+'</option>';return h;})();
function sharedDials(card){
  const gb=S.stream==='gbshell'||S.stream==='gbrun';
  let h='<div class="rhm-row" data-role="pen-dials">';
  h+='<label>stream <select data-role="pen-stream" aria-label="stream">'+Object.keys(STREAM_LABEL).map(k=>'<option value="'+k+'"'+(k===S.stream?' selected':'')+'>'+esc(STREAM_LABEL[k])+'</option>').join('')+'</select></label>';
  h+='<label>T <input type="range" min="0" max="4096" step="8" value="'+S.T+'" data-role="pen-T" aria-label="steps T"'+(gb?' disabled':'')+'></label><b data-role="pen-Tval">T = '+S.T+'</b>';
  h+='<label>seed <input type="text" inputmode="numeric" value="'+S.seed+'" data-role="pen-seed" aria-label="coin seed" style="width:8.5rem"></label><button type="button" data-role="pen-newseed">New seed</button>';
  h+='<label>N <select data-role="pen-N" aria-label="Goldbach shell N">'+NOPTS.replace('value="'+S.N+'"','value="'+S.N+'" selected')+'</select></label>';
  h+='<label>N_max <select data-role="pen-Nmax" aria-label="Goldbach run N max">'+NOPTS.replace('value="'+S.Nmax+'"','value="'+S.Nmax+'" selected')+'</select></label>';
  // v0.4.19: on the sphere card the two disk dials are shown disabled with "not used on this card" (v0.4.18 showed them live)
  const un=card==='sph',dis=un?' disabled data-unused="1"':'',nu=un?' <span class="note dim" data-role="pen-unused">(not used on this card)</span>':'';
  h+='<label><input type="checkbox" data-role="pen-follow"'+(S.follow?' checked':'')+dis+' style="min-height:0"> follow the pen (k = '+MINUS+'1)'+nu+'</label>';
  h+='<label>W <input type="range" min="20" max="600" step="10" value="'+S.W+'" data-role="pen-W" aria-label="trail W"'+dis+'></label><b data-role="pen-Wval">W = '+S.W+'</b>'+nu;
  if(card==='curv')h+='<label>lift λ <input type="range" min="0" max="40" step="1" value="'+S.lam+'" data-role="pen-lam" aria-label="trail lift lambda"></label><b data-role="pen-lamval">λ = '+S.lam+'/100</b>';
  if(card==='sph')h+='<label><input type="checkbox" data-role="pen-teeth-toggle"'+(S.teeth?' checked':'')+' style="min-height:0"> tooth events</label>';
  if(card==='sph'){h+='<label style="display:flex;gap:4px;align-items:center;flex:1 1 100%;min-width:0;max-width:100%"><span style="white-space:nowrap">preset</span> <select data-role="pen-preset" aria-label="preset" style="min-width:0;max-width:100%;flex:1 1 auto"><option value="free"'+(S.preset==='free'?' selected':'')+'>free (α, θ)</option><option value="dodeca"'+(S.preset==='dodeca'?' selected':'')+'>dodecahedron (θ 60°, cos α = √5/3)</option></select></label>';
    if(S.preset==='free'){h+='<label>α <select data-role="pen-a" aria-label="step alpha">';for(let j=1n;j<=24n;j++)h+='<option value="'+j+'"'+(j===S.a?' selected':'')+'>'+j+'/96 turn</option>';h+='</select></label>';
      h+='<label>θ <select data-role="pen-th" aria-label="turn theta">';for(let j=1n;j<=11n;j++)h+='<option value="'+j+'"'+(j===S.th?' selected':'')+'>'+j+'/24 turn</option>';h+='</select></label>';}}
  return h+'</div>';
}
function gbBlock(st){
  if(!st.gb)return '';const g=st.gb;let h='<div class="rhm-box" data-role="pen-gb">';
  if(S.stream==='gbshell'){h+='<p class="read" data-role="pen-gb-readout">Goldbach shell N = '+g.N+' (t₂ = '+g.t2+', m = '+g.m+' teeth): g(N) = #P_N = <b>'+g.g+'</b>; + signs: <b>'+g.plus+'</b>, '+MINUS+' signs: '+g.minus+'; '+esc(g.relation.text)+' — '+(g.relation.holds?'holds (exact)':'FAILS')+'; net turning (#+ '+MINUS+' #'+MINUS+')·90° = '+(g.netQuarterTurns<0?MINUS:'')+(g.netQuarterTurns<0?-g.netQuarterTurns:g.netQuarterTurns)+'·90°.</p>';
    if(g.empty)h+='<p class="note warn" data-role="pen-gb-empty">'+esc(g.emptyLabel)+'</p>';
    h+='<p class="note dim" data-role="pen-gb-order">'+esc(GB_ORDER)+' The teeth: c = '+g.c.slice(0,24).join(', ').replace(/-/g,MINUS)+(g.c.length>24?', …':'')+'.</p>';}
  else{h+='<p class="read" data-role="pen-gb-readout">Goldbach run N = 4, 6, … '+g.Nmax+': '+g.shells+' shells, '+g.len+' teeth; + signs: <b>'+g.plus+'</b>, '+MINUS+' signs: '+g.minus+'; Σg(N) = '+g.gsum+'; '+esc(g.relation.text)+' — '+(g.relation.holds?'holds (exact)':'FAILS')+'; net turning '+(g.netQuarterTurns<0?MINUS:'')+(g.netQuarterTurns<0?-g.netQuarterTurns:g.netQuarterTurns)+'·90°. Shell boundaries: amber ticks on the strips (not signs).</p><p class="note dim" data-role="pen-gb-order">'+esc(GB_ORDER)+' Each shell is drawn in this order, shell after shell.</p>';}
  h+='<p class="note" data-role="pen-gb-guard">'+esc(ST.GUARDS.pen)+' '+esc(ST.GUARDS.closure)+'</p><p class="note dim" data-role="pen-gb-bias">'+esc(ST.GUARDS.bias)+'</p></div>';
  return h;
}
// v0.4.19 (SCHEMA_ADDENDUM_26): the tooth order, decided by saphir on 2026-10-31 ("both sides")
const GB_ORDER='Tooth order (decided by saphir, 2026-10-31: both sides): the teeth of the shell’s comb by |c| ascending with +c before −c (odd m, N ≡ 2 mod 4 and N = 4: c = 0, 1, −1, 2, −2, …; even m, N ≡ 0 mod 4 with N ≥ 8, has no c = 0 tooth: 1, −1, 3, −3, …), so every prime pair p ≠ N − p is counted twice, at +c and at −c, and the equal pair p = N/2 once: #+ = 2·g(N) − δ.';
const GB_T_NOTE='Goldbach streams use their whole length; the T dial does not apply.';
function effLen(st){return st.len;}
// ---------------------------------------------------------------- card 1: curvature pen
const PRIOR='Prior art: the skeleton seat’s four pen pages (squeeze_sphere_pen_v0_1.html 1266e83d…, squeeze_sphere_pen_v0_1_1.html 83b015d8…, curvature_pen_v0_2.html 941838ad…, curvature_pen_v0_2_1.html c0f6926d…; floats, browser-verified by the seat, not seat-reviewed), handoff PEN_VIEWERS_HANDOFF_v0_1.md (9df5796d…). The library module FVLTTurnFourierPenV1 is a different, older object: FVLTS4sRule150PenV1 (the planar ±90° Rule 150 pen, v16) is not FVLTTurnFourierPenV1.';
// v0.4.19 (SCHEMA_ADDENDUM_26): the Codex reviews named as confirmed by the Rule 30 skeleton seat from the rule30 ledger: #1310 = FVLTS4sSqueezeCornersV1
// (library v15), #1318 = FVLTS4sRule150PenV1 (library v16), both PASS WITH FLAGS.
const LEAN='Lean: FVLTS4sSqueezeCornersV1 (library v15: the squeeze glues the corners along XOR fibres), FVLTS4sRule150PenV1.pen_confined (library v16: the planar Rule 150 pen stays in |x| ≤ 3, |y| ≤ 2); Codex-reviewed (PASS WITH FLAGS, #1310 / #1318).';
const CREDIT='Idea credit: saphir (Rule 30 written on surfaces; the spherical Fourier pen; the sphere squeeze; the Goldbach work). Pen pages and the curvature-pen rule: the Rule 30 skeleton seat. Lean reviews: Codex (PASS WITH FLAGS; #1310 for library v15, #1318 for library v16).';
// v0.4.19: the Sage job of this build that checks is_isomorphic(AlternatingGroup(5)) for the dodecahedron preset's own two moves (membrane, capped runner)
const A5_JOB='VIEW-SAGE-0419-02',A5_RECEIPT='46dd9ccc…';   // RECEIPT.json sha256 46dd9ccce1dcaf55ecaf353bcb9b4c7bb8a4e82517054eece4d86da82cde2272 (job -01 ran the same checks, all PASS, but exited 1 on a Sage sys.exit detail)
const CLAIMS='Not claimed: no periodicity claim; the frontier dimension and the escape speeds are FINITE readouts of the runs drawn; the pens are drawings of the sign streams, not proofs about Rule 30 or Goldbach.';
let CACHE_OCT=null;
function renderCurv(body,M){
  if(!lazy(body,M,renderCurv))return;BODIES.curv=body;
  const st=curStream(),s=st.s,len=effLen(st),gb=!!st.gb;let h='<div class="rhm pen" data-role="pen-curv">';
  h+=sharedDials('curv');
  if(gb)h+='<p class="note dim">'+esc(GB_T_NOTE)+'</p>';
  if(len===0)h+='<p class="note warn" data-role="pen-T0">T = 0: the stream is empty; every pen stays at its start (drawn).</p>';
  h+=gbBlock(st);
  const dn=len<CV.DISK_T_CAP?len:CV.DISK_T_CAP;
  h+='<div class="rhm-grid" data-role="pen-panels" style="grid-template-columns:repeat(auto-fit,minmax(min(230px,100%),1fr))">';
  for(const [k,t] of [['p1','k = +1 · octahedron {3,4}'],['0','k = 0 · lattice {4,4}'],['m1','k = '+MINUS+'1 · Poincaré disk {5,4}']])
    h+='<div class="rhm-box" data-role="pen-panel" data-k="'+k+'"><p class="rhm-h3">'+t+'</p><canvas data-role="pen-cv-'+k+'" width="260" height="260" role="img" aria-label="pen at curvature '+k+'" style="display:block;width:100%;max-width:260px;height:auto"></canvas><canvas data-role="pen-strip-'+k+'" width="260" height="28" role="img" aria-label="stream strip" style="display:block;width:100%;max-width:260px;height:auto;margin-top:4px"></canvas><div data-role="pen-read-'+k+'"></div></div>';
  h+='</div>';
  h+='<p class="note dim">Strips: cyan = +, red = '+MINUS+' (each pixel column stacks the signs it covers); amber ticks: Goldbach shell boundaries (not signs); a white bar marks where a capped panel stops.</p><p class="note dim" data-role="pen-ticks-note-curv"></p>';
  h+='<p class="note dim" data-role="pen-seealso"><a href="#" data-pen-goto="d1">See also: the Rule 30 ladder card D1 (Clifford tab, Layers menu)</a>.</p>';
  h+='<p class="note dim" data-role="pen-lean">'+esc(LEAN)+'</p><p class="note dim" data-role="pen-claims">'+esc(CLAIMS)+'</p><p class="note dim" data-role="pen-credit">'+esc(CREDIT)+'</p>'+V.aboutBlock('panel:'+IDS[0],ABOUT)+'</div>';
  body.innerHTML=h;bindShared(body);
  const q=r=>body.querySelector('[data-role="'+r+'"]');
  // k = +1
  {const t0=Date.now(),fl=CV.octPen(s,len),os=CV.octStats(fl);if(!CACHE_OCT)CACHE_OCT=CV.octGroup();const ms=Date.now()-t0;
    drawOct(q('pen-cv-p1'),fl,S.lam);strip(q('pen-strip-p1'),s,len,st.bounds,null);
    q('pen-read-p1').innerHTML='<p class="read" data-role="pen-oct">flags reached <b>'+os.flags+'</b> of 24 · vertices '+os.vertices+'/6 · the two moves generate a group of order <b data-role="pen-oct-order">'+CACHE_OCT.order+'</b> (A₄, not S₄; each move has order 3; computed by closure) · '+ms+' ms</p><p class="note dim">Exact: flags (x, v) with integer vectors. Display: the integer quaternion ('+SP.VIEW_Q.join(', ').replace(/-/g,MINUS)+'), an exact rational rotation; trail lifted to radius 1 + λ·t/T (a drawing device only).</p>';}
  // k = 0
  {const t0=Date.now(),P=CV.planePen(s,len),ps=CV.planeStats(P),ms=Date.now()-t0;drawLattice(q('pen-cv-0'),P);strip(q('pen-strip-0'),s,len,st.bounds,null);
    let r150='';if(S.stream==='150')r150='<p class="note" data-role="pen-r150">Rule 150: |x| ≤ 3 and |y| ≤ 2 for all time (Lean, library v16, FVLTS4sRule150PenV1.pen_confined); here max |x| = '+ps.maxX+', max |y| = '+ps.maxY+', '+ps.points+' lattice points visited by T = '+len+(len===4096?' (13 at T = 4,096: a FINITE count)':'')+'.</p>';
    q('pen-read-0').innerHTML='<p class="read" data-role="pen-lat">lattice points visited <b>'+ps.points+'</b> · max |x| '+ps.maxX+', |y| '+ps.maxY+' · end ('+String(ps.end[0]).replace('-',MINUS)+', '+String(ps.end[1]).replace('-',MINUS)+'), |end|² = '+ps.end2+' (exact) · '+ms+' ms</p>'+r150;}
  // k = -1
  {const cv=q('pen-cv-m1');let dm,stt,dms,mul=1n,doublings=0,capHit=false,ms=0;
    // v0.4.19: double P while the distance has fewer than 6 guaranteed places or an enclosure is wider than 1/4 px, at most CV.P_DOUBLINGS_MAX times
    for(;;){dm=diskModel(s,dn,mul);ms+=dm.ms;const t1=Date.now();stt=drawDisk(cv,s,dn,dm);dms=Date.now()-t1;
      const want=dm.P!==null&&(dm.dist.dPlaces<PREC.minPlaces||stt.bad>0);if(!want)break;if(doublings>=CV.P_DOUBLINGS_MAX){capHit=true;break;}mul=2n*mul;doublings++;}
    dm.ms=ms;cv.dataset.doublings=String(doublings);cv.dataset.pcap=capHit?'1':'0';
    strip(q('pen-strip-m1'),s,len,st.bounds,dn<len?dn:null);
    const sp=dn>0?IV.iv(IV.fdiv(dm.dist.d.lo,B(dn)),IV.cdiv(dm.dist.d.hi,B(dn))):IV.pt(0n);
    let r='<p class="read" data-role="pen-disk">cosh d = <b data-role="pen-cosh">'+esc(dm.dist.coshText)+'</b> · d = <b data-role="pen-d">'+esc(dm.dist.dText)+'</b> (guaranteed digits; cosh d = |a|² + |b|² = (1 + |z|²)/(1 '+MINUS+' |z|²) since |a|² '+MINUS+' |b|² = 1 exactly) · speed d/T = '+esc(IV.digits(sp,dm.dist.W,4n).text)+' (FINITE readout)</p>';
    r+='<p class="read" data-role="pen-disk-reg">register: '+esc(dm.reg)+' · '+(S.follow?'follow the pen, last W = '+(px(S.W)<dn?px(S.W):dn)+' steps'+(stt.trailP!==null?' (trail P = '+stt.trailP+' bits)':''):'absolute view from the start')+' · enclosure wider than ¼ px: <b data-role="pen-uncert-m1">'+stt.bad+'</b> of '+stt.pts+' · pixel undecided: <b data-role="pen-undecided-m1">'+stt.und+'</b> · P doubled '+doublings+' time'+(doublings===1?'':'s')+' · {5,4} patch: '+TILE.length+' edges (exact BFS, depth '+TILING_DEPTH+') · compute '+dm.ms+' ms, draw '+dms+' ms</p>';
    if(capHit)r+='<p class="note warn" data-role="pen-pcap-m1">Precision cap reached: P was doubled '+doublings+' times (the cap, P ≤ 4 × the starting P) and '+(stt.bad>0?stt.bad+' enclosure(s) are still wider than ¼ px':'the distance still has fewer than '+PREC.minPlaces+' guaranteed places')+'.</p>';
    r+='<p class="note dim" data-role="pen-pixel-rule">Pixels: “enclosure wider than ¼ px” counts drawn points whose enclosure is wider than a quarter pixel on an axis (P is doubled, up to twice, while it is not 0 or the distance has fewer than 6 guaranteed places); “pixel undecided” counts points whose enclosure straddles an integer pixel edge (floor(lo) ≠ floor(hi) on an axis), so the drawn pixel, the floor of the midpoint, may be one off the true one. A true value can lie on an edge, so this count need not be 0. The {5,4} patch and exact runs (T ≤ 64) are drawn from a fixed 160-bit scale.</p>';
    if(dn<len)r+='<p class="note warn" data-role="pen-cap-m1">k = '+MINUS+'1 drawn to T = '+dn+'; the rest is not drawn (stream length '+len+').</p>';
    r+='<p class="note dim">One step: M = R(±90°)·T(ℓ), cosh(ℓ/2) = cos 36°/sin 45° = (√2 + √10)/4, sinh(ℓ/2) = τ/2, τ² = √5 '+MINUS+' 1 (exact in F = ℚ(√2, √5, τ), degree 8). Edges drawn through the points tanh(kℓ/8), k = 0 … 4.</p>';
    q('pen-read-m1').innerHTML=r;cv.dataset.d=dm.dist.dText;}
  q('pen-ticks-note-curv').textContent=tickNote(tickEvery(st.bounds,B(q('pen-strip-0').width),B(len)));
}
// ---------------------------------------------------------------- card 2: squeezed-sphere pen
function renderSph(body,M){
  if(!lazy(body,M,renderSph))return;BODIES.sph=body;
  const st=curStream(),s=st.s,len=effLen(st),gb=!!st.gb,n=B(len)<SPHERE_T_CAP?len:px(SPHERE_T_CAP);let h='<div class="rhm pen" data-role="pen-sph">';
  h+=sharedDials('sph');if(gb)h+='<p class="note dim">'+esc(GB_T_NOTE)+'</p>';
  if(len===0)h+='<p class="note warn" data-role="pen-T0">T = 0: the stream is empty; the pen stays at its start (drawn).</p>';
  h+=gbBlock(st);
  h+='<canvas data-role="pen-cv-sph" width="320" height="320" role="img" aria-label="squeezed-sphere pen" style="display:block;width:100%;max-width:320px;height:auto"></canvas><canvas data-role="pen-strip-sph" width="320" height="28" role="img" aria-label="stream strip" style="display:block;width:100%;max-width:320px;height:auto;margin-top:4px"></canvas><p class="note dim" data-role="pen-ticks-note-sph"></p><div data-role="pen-read-sph"></div>';
  h+='<p class="note dim" data-role="pen-seealso"><a href="#" data-pen-goto="d1">See also: the Rule 30 ladder card D1 (Clifford tab, Layers menu)</a>.</p>';
  h+='<p class="note dim">'+esc(LEAN)+'</p><p class="note dim">'+esc(CLAIMS)+'</p><p class="note dim">'+esc(CREDIT)+'</p>'+V.aboutBlock('panel:'+IDS[1],ABOUT)+'</div>';
  body.innerHTML=h;bindShared(body);
  const q=r=>body.querySelector('[data-role="'+r+'"]');
  const sm=sphereModel(s,n),t1=Date.now(),dr=drawSphere(q('pen-cv-sph'),sm,st.tooth),dms=Date.now()-t1;const sk=strip(q('pen-strip-sph'),s,len,st.bounds,n<len?n:null);q('pen-ticks-note-sph').textContent=tickNote(sk.k);
  let r='<p class="read" data-role="pen-sph-read">register: '+esc(sm.reg)+' · coverage '+sm.cov.cells+'/432 cells (certain) · uncertain cells: <b data-role="pen-uncertain">'+sm.cov.uncertain+'</b> · enclosure wider than ¼ px: <b data-role="pen-uncert-sph">'+dr.stats.bad+'</b> of '+dr.stats.pts+' · pixel undecided: <b data-role="pen-undecided-sph">'+dr.stats.und+'</b> · '+(st.tooth?'tooth events (q = r = 1): <b data-role="pen-teeth">'+dr.events+'</b>'+(S.teeth?'':' (not drawn: toggle off)')+' · ':'')+'compute '+sm.ms+' ms, draw '+dms+' ms</p>';
  if(S.preset==='dodeca')r+='<p class="note" data-role="pen-dodeca">Dodecahedron preset, exact in ℚ(√3, √5): cos θ = 1/2, sin θ = √3/2, cos α = √5/3, sin α = 2/3. Shown exactly (host-core/test-pen-sphere.cjs): five lefts (or five rights) close a pentagonal face; the moves reach exactly 60 flags on 20 vertices, every vertex with three neighbours at cos α = √5/3; they generate a group of order 60 isomorphic to A₅ (explicit isomorphism, is_isomorphic(AlternatingGroup(5)) in Sage: the v0.4.18 verifier’s job VERIFY-0418-18, receipt 9a77f4ca…, and this build’s job '+A5_JOB+' on the build’s own two moves, receipt '+A5_RECEIPT+'); its element orders (1, 15, 20, 24 elements of order 1, 2, 3, 5) are those of A₅. So every stream walks the edges of a spherical dodecahedron. Edges are drawn as great-circle arcs ('+SP.ARC_PIECES+' pieces each; the interior points are normalised by intervals and counted with the other points).</p>';
  else r+='<p class="note dim">θ = '+S.th+'/24 turn, α = '+S.a+'/96 turn; cos and sin of the rational turns by an outward-rounded series (π by Machin); the frame (x, v, x × v) moves by one orthogonal matrix per sign; its midpoint is rounded and a rigorous error radius is carried (it grows linearly in T). Steps are drawn as straight chords between their end points (chords, not arcs).</p>';
  if(n<len)r+='<p class="note warn" data-role="pen-cap-sph">sphere drawn to T = '+n+'; the rest is not drawn (stream length '+len+').</p>';
  r+='<p class="note dim">Coverage: 24 z-bands × 18 sectors (equal area, as the skeleton); a point whose enclosure meets a cell boundary is counted as uncertain, not placed. Tooth events: steps with q = r = 1 (Rule 30 only), small amber dots, shown while the “tooth events” toggle is on (the count is printed either way). Pixels: “enclosure wider than ¼ px” counts drawn points whose enclosure is wider than a quarter pixel on an axis; “pixel undecided” counts points whose enclosure straddles an integer pixel edge (floor(lo) ≠ floor(hi) on an axis), so the drawn pixel may be one off the true one; a true value can lie on an edge, so this count need not be 0. The sphere’s P is fixed (96 bits).</p>';
  q('pen-read-sph').innerHTML=r;
}
// ---------------------------------------------------------------- binding, lazy rendering, links
const BODIES={curv:null,sph:null};
// v0.4.19: the doubling threshold (6 guaranteed places of d). Exposed as FVPenCards.PREC only so that build/browser-check-v0419.cjs can raise it and see the
// doubling and the cap at work (no stream of the card triggers a doubling at the starting P; see the report).
const PREC={minPlaces:6n};
function rerender(){for(const [k,fn] of [['curv',renderCurv],['sph',renderSph]]){const b=BODIES[k];if(b&&b.isConnected)fn(b,null);}}
function lazy(body,M,fn){
  const det=body.closest('details'),open=!det||det.open;
  if(det&&!det._penBound){det._penBound=true;det.addEventListener('toggle',()=>{if(det.open)fn(body,M);});}
  if(!open){body.innerHTML='<p class="note dim">Open the card to compute.</p>';return false;}
  return true;
}
function bindShared(body){
  const on=(role,ev,fn)=>{const x=body.querySelector('[data-role="'+role+'"]');if(!x||x.dataset.unused==='1')return;x.addEventListener(ev,()=>fn(x));x.addEventListener('keydown',e=>e.stopPropagation());};
  const big=(v,lo,hi)=>{let b;try{b=BigInt(v);}catch(e){return null;}return b<lo||b>hi?null:b;};
  on('pen-stream','change',x=>{S.stream=x.value;rerender();});
  on('pen-T','input',x=>{const b=body.querySelector('[data-role="pen-Tval"]');if(b)b.textContent='T = '+x.value;});
  on('pen-T','change',x=>{const v=big(x.value,0n,4096n);if(v!==null){S.T=v;rerender();}});
  on('pen-seed','change',x=>{const v=big(x.value,1n,ST.SEED_MAX);if(v!==null){S.seed=v;rerender();}else x.value=String(S.seed);});
  on('pen-newseed','click',()=>{let v=1n;try{const a=new Uint32Array(1);crypto.getRandomValues(a);v=BigInt(a[0])||1n;}catch(e){v=1n;}S.seed=v;S.stream='coin';rerender();});
  on('pen-N','change',x=>{S.N=BigInt(x.value);rerender();});
  on('pen-Nmax','change',x=>{S.Nmax=BigInt(x.value);rerender();});
  on('pen-follow','change',x=>{S.follow=!!x.checked;rerender();});
  on('pen-W','input',x=>{const b=body.querySelector('[data-role="pen-Wval"]');if(b)b.textContent='W = '+x.value;});
  on('pen-W','change',x=>{S.W=BigInt(x.value);rerender();});
  on('pen-lam','input',x=>{const b=body.querySelector('[data-role="pen-lamval"]');if(b)b.textContent='λ = '+x.value+'/100';});
  on('pen-lam','change',x=>{S.lam=BigInt(x.value);rerender();});
  on('pen-teeth-toggle','change',x=>{S.teeth=!!x.checked;rerender();});
  on('pen-preset','change',x=>{S.preset=x.value==='dodeca'?'dodeca':'free';rerender();});
  on('pen-a','change',x=>{S.a=BigInt(x.value);rerender();});
  on('pen-th','change',x=>{S.th=BigInt(x.value);rerender();});
}
// "see also" links: the pen cards open the D1 card (Clifford tab, rl = 1); the D1 card opens the pen cards (Panels tab, card opened)
function goto(where){
  const P=root.FVPanel,CC=root.FVCombCore;if(!P||!CC)return;const st=P.state;
  if(where==='d1'){const parts=String(st.view||'').split(';').filter(p=>p&&!/^rl=/.test(p));parts.push('rl=1');location.hash=CC.encodeAddress({...st,tab:'clifford',view:parts.join(';')});return;}
  try{const o=JSON.parse(localStorage.getItem(KEY)||'{}')||{};o[IDS[0]]=true;localStorage.setItem(KEY,JSON.stringify(o));}catch(e){}
  location.hash=CC.encodeAddress({...st,tab:'panels'});
}
if(typeof document!=='undefined')document.addEventListener('click',e=>{const a=e.target&&e.target.closest?e.target.closest('[data-pen-goto]'):null;if(!a)return;e.preventDefault();goto(a.getAttribute('data-pen-goto'));});
const ABOUT='register: exact (signs, flags, lattice points, F[i] and K) · guaranteed numerical (BigInt intervals) · drawing (integer pixels) · display only. '+PRIOR;
V.registerPanel({id:IDS[0],title:'Curvature pen (exact)',group:'E',collapsed:true,register:'mixed',coupling:'reads nothing from the host; writes nothing',
  description:'One sign stream, one rule (turn ±90°, walk one edge) at k = +1, 0, −1.',source:'build brief v0.4.18 part B',actions:[],about:ABOUT,render:(el,M)=>renderCurv(el,M)});
V.registerPanel({id:IDS[1],title:'Squeezed-sphere pen (exact)',group:'E',collapsed:true,register:'mixed',coupling:'reads nothing from the host; writes nothing',
  description:'A geodesic turtle on S² with free α and θ, exact or with guaranteed intervals.',source:'build brief v0.4.18 part C',actions:[],about:ABOUT,render:(el,M)=>renderSph(el,M)});
root.FVPenCards={S,curStream,diskModel,sphereModel,rerender,IDS,TILING_DEPTH,SPHERE_T_CAP,PREC,tickEvery};
})(typeof globalThis!=='undefined'?globalThis:this);
