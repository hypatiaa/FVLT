'use strict';
// v0.4.10 browser check (SCHEMA_ADDENDUM_18): the two Panels cards, the "shells n² + 1" track. 1280x800 and 375x812.
// (1) counts 39/41/39/41 unchanged, also on the n² + 1 track; (2) every v0.4.9 check state: state, address, exact export (JSON, state, CSV, Lift JSON, stats), caption, cards, about, canvas and PNG export byte-identical to v0.4.9;
// the Panels tab differs only by the two new (collapsed) card elements; (3) the cards: contents, gates, idle captions, canvas geometry, tessellation parity, pairing lines; (4) the preset track and its address key; (5) no horizontal scroll at 375; (6) shots shot_v0410_*.
const fs=require('fs'),path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url49=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js'),BD=require('../host-core/branch-disk-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
const shellAddr=(n,o,extra)=>addr({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2*n+1),t1:'1',t2:'1',tab:'panels',...(o||{})},extra);
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(350);};
const NEWRE=/<details class="pmod" data-panel="(branch-primitivity|poincare-disk)"[^>]*>[\s\S]*?<\/details>/g;
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,hstage:(document.getElementById('htmlstage')||{innerHTML:''}).innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hash:location.hash,st:JSON.stringify(FVPanel.state)}));
const exportsOf=pg=>pg.evaluate(async()=>{const r={};for(const k of ['xstats','xjson','xstate','xcsv','xlift']){await FVPanel.onAct(k);await new Promise(z=>setTimeout(z,60));r[k]=document.getElementById('xout').value;}return r;});
const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
const openCards=async(pg)=>{await pg.evaluate(()=>{document.querySelectorAll('details.pmod').forEach(d=>{if(d.dataset.panel==='branch-primitivity'||d.dataset.panel==='poincare-disk')d.open=true;});});await pg.waitForTimeout(250);};
const body=(pg,id)=>pg.evaluate(id=>{const e=document.querySelector('[data-body="'+id+'"]');return e?e.innerText:null;},id);
const cardShot=async(pg,name)=>{await pg.evaluate(()=>window.scrollTo(0,0));const box=await pg.evaluate(()=>{const a=document.querySelector('details[data-panel="branch-primitivity"]').getBoundingClientRect(),b=document.querySelector('details[data-panel="poincare-disk"]').getBoundingClientRect();
    const x=Math.min(a.left,b.left)+window.scrollX,y=Math.min(a.top,b.top)+window.scrollY,r=Math.max(a.right,b.right)+window.scrollX,bt=Math.max(a.bottom,b.bottom)+window.scrollY;return {x:Math.max(0,x-6),y:Math.max(0,y-6),width:r-x+12,height:bt-y+12};});
  await pg.screenshot({path:path.join(root,name+'.png'),fullPage:true,clip:box});};
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- (1) counts
    {const r=[],r49=[];for(const tab of ['fourier','clifford','hopf','panels']){for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr(o)+x,url49);r49.push(await count(pg));}}
      ok(tag+' counts unchanged: the 16 states (4 tabs × integer / n! / CA / continuous) give '+r.join('/')+', equal to v0.4.9 ('+r49.join('/')+'); the drawing tabs are 39/41/39/41',r.join('/')===r49.join('/')&&r.slice(0,12).join('/')==='39/41/39/41/39/41/39/41/39/41/39/41',r.join('/')+' vs '+r49.join('/'));
      const q=[],q49=[];for(const tab of ['fourier','panels']){await gopen(pg,shellAddr(7,{tab},'&sq=1'));q.push(await count(pg));await gopen(pg,addr({shellMode:'integer',B:'5040',phi3:'0',m:'5',tab},'&ca=1'),url49);q49.push(await count(pg));}
      ok(tag+' counts on the n² + 1 track equal the CA counts of v0.4.9 ('+q.join('/')+' vs '+q49.join('/')+')',q.join('/')===q49.join('/'),q.join('/'));}
    // ---- (2) byte identity against v0.4.9
    const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',alpha:'1/2',m:'2',tab:'clifford'},
      {shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'},{shellMode:'factorial',n1:'4',phi3:'25',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',m:'3',sTyped:'1/3',view:'cf=1',tab:'clifford'},
      {shellMode:'integer',B:'49',phi3:'0',m:'15',t1:'1',t2:'1',tab:'panels'},{shellMode:'integer',B:'9',phi3:'0',m:'7',tab:'panels'},{shellMode:'integer',B:'5040',phi3:'12',m:'9',tab:'panels',extra:'&ca=1'},{shellMode:'factorial',n1:'4',phi3:'20',m:'5',alpha:'1',n6:'1',tab:'fourier',view:'fs=1'}];
    {let same=0,bad=[],panelsDiff=0,panelsN=0,exSame=0;
      for(const o of S){for(const t of [null,'-1/2']){const ex=o.extra||'',oo={...o};delete oo.extra;const hh=addr(oo,(t?'&tilt='+t:'')+ex);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url49);await gopen(pb,hh);
          const x=await snap(pa),y=await snap(pb);let eq=true;const dif=[];
          if(o.tab==='panels'){panelsN++;const yb=y.hstage.replace(NEWRE,'');const nNew=(y.hstage.match(NEWRE)||[]).length,collapsed=!/<details class="pmod" data-panel="(branch-primitivity|poincare-disk)"[^>]* open/.test(y.hstage);
            if(yb!==x.hstage||nNew!==2||!collapsed){eq=false;dif.push('hstage('+nNew+(collapsed?'':' open')+')');}else panelsDiff++;}
          for(const k of Object.keys(x)){if(k==='hstage'&&o.tab==='panels')continue;if(x[k]!==y[k]){eq=false;dif.push(k);}}
          const ea=await exportsOf(pa),eb=await exportsOf(pb);const exeq=JSON.stringify(ea)===JSON.stringify(eb);if(exeq)exSame++;else dif.push('exports');
          if(eq&&exeq)same++;else bad.push(o.tab+' '+hh.slice(0,80)+' '+dif.join(','));await pa.close();await pb.close();}}
      ok(tag+' byte-identical to v0.4.9 for '+S.length*2+' states (incl. tilt −1/2): stage, canvas, caption, about, cards, address, hash, state AND exact JSON, state JSON, CSV, Lift JSON, stats ('+exSame+'/'+S.length*2+' exports); Panels tab ('+panelsN+' states) differs only by the two new collapsed card elements ('+panelsDiff+')',same===S.length*2&&panelsDiff===panelsN,bad.join(' | '));}
    {let same=0;const n=4;for(const o of S.filter(o=>o.tab!=='panels'&&!o.extra).slice(0,n)){const hh=addr(o);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url49);await gopen(pb,hh);if(await pngHash(pa)===await pngHash(pb))same++;await pa.close();await pb.close();}
      ok(tag+' PNG export byte-identical to v0.4.9 ('+same+'/'+n+')',same===n);}
    // ---- (3) the cards
    {await gopen(pg,shellAddr(3));const st=await pg.evaluate(()=>[...document.querySelectorAll('details.pmod')].map(d=>d.dataset.panel+':'+d.open));
      const ids=st.map(s=>s.split(':')[0]),iB=ids.indexOf('branch-primitivity'),iD=ids.indexOf('poincare-disk'),iG=ids.indexOf('g-robin-margin');
      ok(tag+' both cards present in group B after the G. Robin card, adjacent, and collapsed on a fresh page; all other cards unchanged (open)',iB===iG+1&&iD===iB+1&&st[iB].endsWith('false')&&st[iD].endsWith('false')&&st.filter((s,i)=>i!==iB&&i!==iD).every(s=>s.endsWith('true')),st.join(' '));}
    const shots=[[3,10,'composite 2·5'],[4,17,'prime'],[5,26,'composite 2·13'],[10,101,'prime']];
    for(const [n,N,what] of shots){
      await gopen(pg,shellAddr(n));await openCards(pg);
      const bt=await body(pg,'branch-primitivity'),dt=await body(pg,'poincare-disk'),r=BD.primitivity(CC.initial({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2*n+1),t1:'1',t2:'1'})),D=BD.disk(CC.initial({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2*n+1)}));
      const verd=r.prime?'N prime: every branch c = 2…'+r.r+' is primitive':'N composite: branch c = '+r.least.c+' is repeated ×'+r.least.g+' (least such c)';
      ok(tag+' N = '+N+' ('+what+') branch card: header, '+r.primitiveCount+' of '+r.total+' primitive, verdict "'+verd+'", label, c = ±1 note, same-divisors line',bt.includes('N = n² + 1 = '+N+', n = '+n)&&bt.includes(r.primitiveCount+' of '+r.total+' branches')&&bt.includes(verd)&&bt.includes('trial division up to ⌊√N⌋ = '+n+', read off the branch windings at gears (1, 1)')&&/c = ±1: c \+1 · raw/.test(bt)&&bt.includes('as winding repetition of the branches')&&bt.includes('Poincaré disk card'));
      const rows=await pg.evaluate(()=>[...document.querySelectorAll('[data-body="branch-primitivity"] [data-role="bp-rep"]')].map(e=>e.innerText));
      ok(tag+' N = '+N+' branch card repeated lines = core ('+r.repeatedRows.length+', capped at '+BD.REPEAT_LINES+')',rows.length===Math.min(r.repeatedRows.length,BD.REPEAT_LINES)&&rows.every((t,i)=>t==='gcd(N, '+r.repeatedRows[i].c+') = '+r.repeatedRows[i].g+' · '+r.repeatedRows[i].chip),JSON.stringify(rows));
      const info=await pg.evaluate(()=>{const cv=document.querySelector('canvas[data-role="pd-canvas"]');return {w:cv.width,cusps:cv.dataset.cusps,edges:cv.dataset.edges,astra:cv.dataset.astra,err:cv.dataset.error||'',css:cv.getBoundingClientRect().width};});
      const orows=await pg.evaluate(()=>[...document.querySelectorAll('[data-body="poincare-disk"] [data-role="pd-orbit"]')].map(e=>e.innerText));
      ok(tag+' N = '+N+' disk card: '+D.orbit.pts.length+' Astra points (m | N), '+D.cusps.length+' cusps, '+D.edges.length+' edges drawn; exact rows ζ, cosh d = core; credit, pairing, scope lines; no canvas error',info.astra===String(D.orbit.pts.length)&&info.cusps===String(D.cusps.length)&&info.edges===String(D.edges.length+D.orbit.pts.length)&&info.err===''&&
        orows.length===Math.min(D.orbit.pts.length,BD.ORBIT_LINES)&&D.orbit.pts.every((p,i)=>i>=orows.length||(orows[i].includes('ζ = '+p.text)&&orows[i].includes('cosh d = '+p.coshText)&&orows[i].includes('m = '+p.m+', k = '+p.k)))&&dt.includes('saphir’s')&&dt.includes('Astra’s written mathematics')&&dt.includes('as orbit points (n + i)/m on Farey edges')&&dt.includes('Branch primitivity card')&&dt.includes('no novelty')&&dt.includes('(3, 4, ∞) orbifold belongs to the S⁶ track and is not drawn here'),JSON.stringify(info)+' '+orows.length);
      // drawn geometry: float checks on the canvas record
      const geo=await pg.evaluate(()=>{const rec=document.querySelector('canvas[data-role="pd-canvas"]').__bd;const orth=rec.edges.filter(e=>!e.diameter).map(e=>Math.abs(e.cx*e.cx+e.cy*e.cy-1-e.r*e.r));return {maxOrth:Math.max(0,...orth),nEdges:rec.edges.length,cuspOnRim:Math.max(0,...rec.cusps.map(c=>Math.abs(Math.hypot(c.x,c.y)-1))),astraIn:rec.astra.every(a=>Math.hypot(a.x,a.y)<1)};});
      ok(tag+' N = '+N+' drawn geodesics orthogonal to the rim (max | |C|² − 1 − r² | '+geo.maxOrth.toExponential(1)+'), cusp images on the unit circle (≤ '+geo.cuspOnRim.toExponential(1)+'), Astra points inside',geo.maxOrth<1e-9&&geo.cuspOnRim<1e-12&&geo.astraIn);
      // ink at the Astra points
      const ink=await pg.evaluate(()=>{const cv=document.querySelector('canvas[data-role="pd-canvas"]'),rec=cv.__bd,c=cv.getContext('2d');let n=0,t=0;for(const a of rec.astra){t++;const d=c.getImageData(Math.round(rec.cx+rec.R*a.x),Math.round(rec.cy-rec.R*a.y),1,1).data;if(d[0]>200&&d[1]>150&&d[2]<100)n++;}return [n,t];});
      ok(tag+' N = '+N+' amber ink at every Astra point ('+ink.join('/')+')',ink[0]===ink[1]&&ink[1]===D.orbit.pts.length,JSON.stringify(ink));
      const hs=await pg.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth+1);
      ok(tag+' N = '+N+' no horizontal scroll with both cards open',hs);
      await cardShot(pg,'shot_v0410_'+tag+'_N'+N);
    }
    // tessellation parity: the two mirrors flip the colour, the half-turn about i keeps it
    {await gopen(pg,shellAddr(3));await openCards(pg);
      const r=await pg.evaluate(()=>{const img=FVBranchDiskCards.tessellation().img,S=img.width,u=new Uint32Array(img.data.buffer),RIM=FVBranchDiskCards.RIM,CX=S/2;const col=(x,y)=>u[y*S+x];
        let n=0,fmx=0,fmy=0,frot=0,bad=0;for(let py=0;py<S;py+=1)for(let px=0;px<S;px+=1){const a=(px+0.5-CX)/RIM,b=-(py+0.5-CX)/RIM;if(a*a+b*b>0.9)continue;n++;
          const c0=col(px,py),mx=col(S-1-px,py),my=col(px,S-1-py),rot=col(S-1-px,S-1-py);if(c0===mx)fmx++;if(c0===my)fmy++;if(c0!==rot)frot++;}
        const cols=new Set();for(let i=0;i<u.length;i+=997)cols.add(u[i]);return {n,sameAsMx:fmx,sameAsMy:fmy,rotDiff:frot,ncol:cols.size};});
      ok(tag+' tessellation colours: across both mirrors (ζ ↦ ζ̄ and ζ ↦ −ζ̄) the parity flips, under the half-turn ζ ↦ −ζ it is kept ('+r.n+' interior pixels; violations (float64 rounding on a tile edge, tolerance 20): '+r.sameAsMx+', '+r.sameAsMy+', '+r.rotDiff+'); two tile colours',r.sameAsMx<=20&&r.sameAsMy<=20&&r.rotDiff<=20&&r.ncol<=4,JSON.stringify(r));}
    // gates in the page
    {const G=async(o,re,what)=>{await gopen(pg,addr({shellMode:'integer',phi3:'0',tab:'panels',...o}));await openCards(pg);const t=await body(pg,'branch-primitivity');const nov=await pg.evaluate(()=>!document.querySelector('[data-role="bp-verdict"]')&&!!document.querySelector('[data-role="bp-nogo"]'));const ok1=re.test(t)&&nov;ok(tag+' gate: '+what+' → no verdict with the reason',ok1,t.slice(0,300));};
      await G({B:'9',m:'7',t1:'2',t2:'2'},/no verdict: gears are \(t₁, t₂\) = \(2, 2\), not \(1, 1\)/,'t₁ = t₂ = 2 at N = 10');
      await G({B:'9',m:'7',t1:'1',t2:'2'},/not \(1, 1\)/,'t₁ = 1, t₂ = 2');
      await G({B:'9',m:'7',t1:'1/2',t2:'2/3'},/not \(1, 1\)/,'t₁ = 1/2, t₂ = 2/3');
      await G({B:'25',m:'5',t1:'1',t2:'1'},/m = 5 is too small: comb\(m\) = \{−2, …, 2\} lacks the branches c = 3, 4, 5/,'m = 5 at N = 26 (missing c = 3, 4, 5)');
      await G({B:'25',m:'8',t1:'1',t2:'1'},/m = 8 is even/,'even m = 8 at N = 26');
      await G({B:'9',phi3:'10',m:'7',t1:'1',t2:'1'},/N = 0/,'N = 0');
      await G({B:'9',nMode:'continuous',phi3:'7/2',m:'7',t1:'1',t2:'1'},/not an integer/,'continuous non-integer N');
      await gopen(pg,addr({shellMode:'integer',B:'23',phi3:'0',m:'9',t1:'1',t2:'1',tab:'panels'}));await openCards(pg);const t24=await body(pg,'branch-primitivity'),d24=await body(pg,'poincare-disk');
      ok(tag+' N = 24 (N − 1 not a square): the branch card still gives its verdict (composite, c = 2 ×2) without the quadratic mark; the disk card says N − 1 = 23 is not a square (idle caption, layer still drawn)',/N composite: branch c = 2 is repeated ×2/.test(t24)&&/N = 24, ⌊√N⌋ = 4/.test(t24)&&!/n² \+ 1 = 24/.test(t24)&&/N − 1 = 23 is not a square: no point \(n \+ i\)\/m on this shell/.test(d24),t24.slice(0,200));
      await gopen(pg,addr({shellMode:'integer',B:'9',phi3:'0',m:'7',t1:'1',t2:'1',n6:'0',tab:'panels'}));await openCards(pg);const t6=await body(pg,'branch-primitivity');
      ok(tag+' n₆ = 0: same verdict, the formal-label note appears',/N composite/.test(t6)&&/n₆ = 0: the first circle has collapsed, so ×g is a formal phase label/.test(t6));
      await gopen(pg,addr({shellMode:'integer',B:'9',nMode:'continuous',phi3:'7/2',m:'7',tab:'panels'}));await openCards(pg);const dc=await body(pg,'poincare-disk');
      ok(tag+' continuous non-integer N: the disk card is idle with the reason and the empty disk is still drawn',/idle: between shells: shell arithmetic undefined/.test(dc)&&await pg.evaluate(()=>!!document.querySelector('canvas[data-role="pd-canvas"]').__bd));
      await gopen(pg,addr({shellMode:'integer',B:'6',phi3:'0',m:'2',tab:'panels'}));await openCards(pg);const te=await body(pg,'branch-primitivity');
      ok(tag+' even m = 2 (default-like): no verdict, reason given',/m = 2 is even/.test(te));}
    // the strip buttons "Open panels" / "Collapse panels" reach the two new cards as well
    {await gopen(pg,shellAddr(3));await pg.evaluate(()=>localStorage.clear());await gopen(pg,shellAddr(3));
      const cnt=()=>pg.evaluate(()=>[...document.querySelectorAll('details.pmod')].filter(d=>d.open).length+'/'+document.querySelectorAll('details.pmod').length);
      await pg.click('[data-act="vtool"][data-v="collapse"]');await pg.waitForTimeout(300);const c0=await cnt();
      await pg.click('[data-act="vtool"][data-v="open"]');await pg.waitForTimeout(300);const c1=await cnt();
      const tot=c1.split('/')[1];
      ok(tag+' strip buttons: Collapse panels closes all ('+c0+'), Open panels opens all including the two new cards ('+c1+')',c0==='0/'+tot&&c1===tot+'/'+tot,c0+' '+c1);
      await pg.evaluate(()=>localStorage.clear());await gopen(pg,shellAddr(3));}
    // ---- (4) the preset track
    {await gopen(pg,addr({shellMode:'integer',B:'5040',phi3:'0',m:'5',tab:'fourier'},'&ca=1'));
      const before=await pg.evaluate(()=>document.getElementById('ca_sel').innerHTML.split('</option>').length-1);
      await pg.selectOption('#ca_sel','sq');await pg.waitForTimeout(400);
      const s1=await pg.evaluate(()=>({st:FVPanel.state,hash:location.hash,sqv:document.getElementById('sq_sel').value,sqd:getComputedStyle(document.getElementById('sq_sel')).display,cad:getComputedStyle(document.getElementById('ca_sel')).display,mbox:getComputedStyle(document.getElementById('Mbox')).display,sr:document.getElementById('shell_read').innerText}));
      ok(tag+' track entry via the CA preset menu (its last option “n²+1 shells ▸”, '+before+' options): B = 9, φ₃ = 0, m = 7 (N = 10), address ends &sq=1, the n menu shows n = 3, CA menu and M box hidden',s1.st.B==='9'&&s1.st.phi3==='0'&&s1.st.m==='7'&&/&sq=1$/.test(s1.hash)&&s1.sqv==='3'&&s1.sqd!=='none'&&s1.cad==='none'&&s1.mbox==='none'&&/N = 10/.test(s1.sr),JSON.stringify(s1));
      await pg.selectOption('#sq_sel','10');await pg.waitForTimeout(400);
      const s2=await pg.evaluate(()=>({st:FVPanel.state,hash:location.hash,sr:document.getElementById('shell_read').innerText}));
      ok(tag+' choosing n = 10: B = 100, φ₃ = 0, m = 21, N = 101; the address is the integer address plus &sq=1',s2.st.B==='100'&&s2.st.phi3==='0'&&s2.st.m==='21'&&/N = 101/.test(s2.sr)&&s2.hash===CC.encodeAddress(CC.initial({...s2.st}))+'&sq=1',s2.hash);
      await pg.selectOption('#sq_sel','359');await pg.waitForTimeout(500);const s3=await pg.evaluate(()=>({st:FVPanel.state,sr:document.getElementById('shell_read').innerText}));
      ok(tag+' n = 359 (the cap): B = 128881, m = 719, N = 128 882',s3.st.B==='128881'&&s3.st.m==='719'&&/N = 128882/.test(s3.sr),JSON.stringify(s3.st.B)+s3.sr);
      await pg.reload();await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);
      const s4=await pg.evaluate(()=>({sqd:getComputedStyle(document.getElementById('sq_sel')).display,sqv:document.getElementById('sq_sel').value,hash:location.hash}));
      ok(tag+' reloading the address with &sq=1 restores the track (menu shown at n = 359)',s4.sqd!=='none'&&s4.sqv==='359'&&/&sq=1$/.test(s4.hash));
      await pg.click('#mode_i');await pg.waitForTimeout(300);const s5=await pg.evaluate(()=>({hash:location.hash,sqd:getComputedStyle(document.getElementById('sq_sel')).display,mbox:getComputedStyle(document.getElementById('Mbox')).display}));
      ok(tag+' the integer button ends the track: no &sq=1, n menu hidden, M box back',!/sq=/.test(s5.hash)&&s5.sqd==='none'&&s5.mbox!=='none',JSON.stringify(s5));
      await pg.click('#mode_ca');await pg.waitForTimeout(300);await pg.selectOption('#ca_sel','sq');await pg.waitForTimeout(300);await pg.selectOption('#sq_sel','ca');await pg.waitForTimeout(300);
      const s6=await pg.evaluate(()=>({hash:location.hash,st:FVPanel.state,cad:getComputedStyle(document.getElementById('ca_sel')).display}));
      ok(tag+' the n menu’s first option returns to the CA presets (B = 5040, address &ca=1, no &sq)',s6.st.B==='5040'&&/&ca=1$/.test(s6.hash)&&!/sq=/.test(s6.hash)&&s6.cad!=='none',JSON.stringify(s6.hash));
      // typed M leaves the track
      await gopen(pg,shellAddr(5,{tab:'fourier'},'&sq=1'));await pg.fill('#Mbox','7').catch(()=>{});
      await gopen(pg,shellAddr(5,{tab:'fourier'},'&sq=1'));await pg.evaluate(()=>FVPanel.dial({B:'30'}));await pg.waitForTimeout(300);const s7=await pg.evaluate(()=>({hash:location.hash,sqd:getComputedStyle(document.getElementById('sq_sel')).display}));
      ok(tag+' a B that is not n² (30) ends the track: address without &sq, menu hidden',!/sq=/.test(s7.hash)&&s7.sqd==='none',JSON.stringify(s7));
      // refusals
      const ref=[];for(const [h,re,nm] of [[addr({shellMode:'integer',B:'10',phi3:'0',m:'7'},'&sq=1'),/n²\+1 track flag refused: B = 10 is not n² with 1 ≤ n ≤ 359/,'B = 10'],[addr({shellMode:'factorial',n1:'4',phi3:'0',m:'7'},'&sq=1'),/n²\+1 track flag refused: B = .* \(n! mode\)/,'n! mode'],[addr({shellMode:'integer',B:'9',phi3:'0',m:'7'},'&sq=2'),/must be exactly sq=1/,'sq=2'],[addr({shellMode:'integer',B:'9',phi3:'0',m:'7'},'&sq=1&sq=1'),/must be exactly sq=1/,'repeated'],[addr({shellMode:'integer',B:'129600',phi3:'0',m:'7'},'&sq=1'),/not n² with 1 ≤ n ≤ 359/,'n = 360'],[addr({shellMode:'integer',B:'5040',phi3:'0',m:'7'},'&ca=1&sq=1'),/not n² with 1 ≤ n ≤ 359|cannot be combined/,'ca=1 and sq=1 on a CA B']]){
        await gopen(pg,h);const r=await pg.evaluate(()=>({sqd:getComputedStyle(document.getElementById('sq_sel')).display,hash:location.hash,banner:(document.getElementById('status').innerText.match(/n²\+1 track flag refused[^\n]*/)||[''])[0]}));
        if(!(re.test(r.banner)&&r.sqd==='none'))ref.push(nm+' '+JSON.stringify(r));}
      ok(tag+' refusals: B not n², n! mode, sq=2, repeated sq, n = 360, ca+sq: the state loads, track off (menu hidden), a label says why (the raw address stays in the bar, as for a refused ca=1)',ref.length===0,ref.join(' | '));
      // what a v0.4.9 reader does with an &sq=1 address (reported, not a pass condition)
      const pa=await ctx.newPage();await gopen(pa,addr({shellMode:'integer',B:'9',phi3:'0',m:'7',tab:'fourier'},'&sq=1'),url49).catch(()=>{});const old=await pa.evaluate(()=>({st:window.FVPanel?FVPanel.state.B:null,txt:(document.body.innerText.match(/Address refused[^\n]*/)||[''])[0]})).catch(()=>({}));await pa.close();
      console.log('INFO '+tag+' v0.4.9 reader on an &sq=1 address: '+JSON.stringify(old));}
    // preset track + both cards at once, timing at the cap
    {await gopen(pg,shellAddr(359));await openCards(pg);const t0=Date.now();const info=await pg.evaluate(()=>{let t=performance.now();FVBranchDisk.primitivity(FVPanel.state);const a=performance.now()-t;t=performance.now();FVBranchDisk.disk(FVPanel.state);const b=performance.now()-t;return 'primitivity '+a.toFixed(1)+' ms, disk data '+b.toFixed(1)+' ms (uncached, m = 719)';});
      const bt=await body(pg,'branch-primitivity'),dt=await body(pg,'poincare-disk');
      ok(tag+' n = 359 (N = 128 882, m = 719) both cards render: composite, c = 2 ×2; disk: orbit points for the divisors of 128 882 ('+BD.disk(CC.initial({shellMode:'integer',B:'128881',phi3:'0',m:'719'})).orbit.pts.length+')',/N composite: branch c = 2 is repeated ×2 \(least such c\)/.test(bt)&&/⋯ \d+ more/.test(bt)&&/N − 1 = 359²/.test(dt),bt.slice(0,160));
      console.log('INFO '+tag+' n = 359: '+info);}
    ok(tag+' no page errors',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();
  }
  await browser.close();
  console.log('\nSUMMARY browser-check-v0410: '+pass+' pass / '+fail+' fail');process.exit(fail?1:0);
})();
