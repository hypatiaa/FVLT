'use strict';
// v0.4 browser check of the mirror axis (T-MA in the page; R1–R4 as amended by the S0 design review §5). Playwright from s6_atom/node_modules, dist page over file://.
// The v0.3 suite build/browser-check.cjs runs unchanged beside this one.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const B={shellMode:'integer',B:'24',nMode:'integer',n6:'1',alpha:'0'};
const ODD={...B,phi3:'20',m:'5',t1:'1',t2:'1',s:'1/3'},EVEN={...B,phi3:'20',m:'6',t1:'1',t2:'1',s:'1/3'};     // N = 5; EVEN is the Z6 comb of the feature note (inner pair ±1)
const PRESETS=[ODD,EVEN,{...B,phi3:'20',m:'6',t1:'1',t2:'1',s:'0'},{...B,phi3:'21',m:'7',t1:'1',t2:'1',s:'4/7'},{...B,phi3:'17',m:'4',t1:'1/2',t2:'1',s:'1'},
  {...B,phi3:'19',m:'3',t1:'2',t2:'1/3',s:'-5/2'},{...B,phi3:'22',m:'8',t1:'3/2',t2:'-3/2',s:'7/3',n6:'-1'},{...B,phi3:'23',m:'2',t1:'1',t2:'1',s:'1'},
  {...B,phi3:'15',m:'5',t1:'-1',t2:'2',s:'0',alpha:'1'},{...B,nMode:'continuous',phi3:'7/2',m:'4',t1:'1',t2:'1',s:'1/3'},{...B,phi3:'20',m:'5',t1:'0',t2:'1',s:'1/3'}];
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[375,812,'375x812'],[1280,800,'1280x800']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},acceptDownloads:true,deviceScaleFactor:1,hasTouch:w<500});
    const pg=await ctx.newPage(),errs=[];pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});pg.on('pageerror',e=>errs.push(String(e)));
    await pg.goto(url);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
    const set=async(o,tab)=>{await pg.evaluate(([o,tab])=>{const {s,...d}=o;FVPanel.dial({...d,tab,view:''});FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,s));},[o,tab]);await pg.waitForTimeout(250);};
    const fonts=()=>pg.evaluate(()=>{const bad=[];let mn=1e9;const svg=document.getElementById('stage'),k=svg.getBoundingClientRect().width/svg.viewBox.baseVal.width;
      document.querySelectorAll('body *').forEach(e=>{if(['SCRIPT','STYLE','OPTION'].includes(e.tagName))return;const own=[...e.childNodes].some(c=>c.nodeType===3&&c.textContent.trim());if(!own)return;
        const r=e.getBoundingClientRect(),cs=getComputedStyle(e);if(cs.display==='none'||cs.visibility==='hidden'||(r.width===0&&r.height===0))return;let fs=parseFloat(cs.fontSize);if(e.closest('svg'))fs*=k;mn=Math.min(mn,fs);if(fs<13-1e-6)bad.push(e.textContent.trim().slice(0,20)+' '+fs.toFixed(2));});return {mn,bad};});
    // ---- T-MA in the page, Clifford tab, every preset
    const tma=()=>pg.evaluate(()=>{
      const st=FVPanel.state,O=FVOrbit,NUM=FVCombNumeric,M=FVPanel.model,num=M.num,rho=num.rho,a=rho/Math.sqrt(1+rho*rho),b=1/Math.sqrt(1+rho*rho);
      const marks=FVViews.layerMarks().filter(m=>m.role==='mirror-crossing'),pairs=O.mirrorPairs(st),orbs=M.orbits,out={pairs:[],bad:[],worst:0,n:marks.length};
      const cv=document.getElementById('stagecv'),svg=document.getElementById('stage'),cr=cv.getBoundingClientRect(),vb=svg.viewBox.baseVal,k=Math.min(cr.width/vb.width,cr.height/vb.height),sx=cv.width/cr.width,g2=cv.getContext('2d');
      let unlit=0;
      for(const p of pairs){const mk=marks.filter(m=>m.pair===String(p.c)),ob=orbs.find(o=>o.c===p.c);
        out.pairs.push({c:String(p.c),status:p.status,M:p.count===null?null:String(p.count),drawn:mk.length,partial:!!(ob&&ob.partial)});
        if(p.status==='defined'&&!(ob&&ob.partial)&&BigInt(mk.length)!==p.count)out.bad.push('count c='+p.c+' drawn '+mk.length+' M '+p.count);
        for(const m of mk){const d=NUM.longitudeDistance(m.xyz);out.worst=Math.max(out.worst,d.dist,Math.abs(d.z1abs-a),Math.abs(d.z2abs-b));
          if(d.dist>1e-9||d.beta!==m.beta||Math.abs(d.z1abs-a)>1e-9||Math.abs(d.z2abs-b)>1e-9||Number(((BigInt(m.k)%2n)+2n)%2n)!==m.beta)out.bad.push('off c='+p.c+' k='+m.k);
          const at=dx=>g2.getImageData(Math.round(((cr.width-vb.width*k)/2+(m.x+dx)*k)*sx),Math.round(((cr.height-vb.height*k)/2+m.y*k)*sx),1,1).data,bg=p=>p[0]===12&&p[1]===12&&p[2]===24;if(bg(at(0))&&bg(at(m.r-0.2)))unlit++;}}
      out.unlit=unlit;
      const lon=[...svg.querySelectorAll('[data-role="mirror-longitude"]')].map(e=>e.getAttribute('data-beta')),runs=FVViews.layerRuns().filter(r=>r.role==='mirror-longitude');
      out.lon=lon;out.runs=runs.map(r=>r.pts.length);out.labels=[...svg.querySelectorAll('[data-role="mirror-label"]')].map(e=>e.textContent);
      out.cap=[...document.querySelectorAll('#caption p')].map(p=>p.textContent);out.odd=FVPanel.model.R.m%2===1;return out;});
    for(const [i,o] of PRESETS.entries()){
      await set(o,'clifford');const r=await tma();
      const lab=tag+' T-MA preset '+i+' (N = '+(o.nMode==='continuous'?'43/2':String(25-Number(o.phi3)))+', m = '+o.m+', t₁ = '+o.t1+', t₂ = '+o.t2+', s = '+o.s+(o.n6==='-1'?', n₆ = −1':'')+')';
      ok(lab+': drawn same-time events per pair equal the exact M = P·|c·t₂|/N ('+r.pairs.map(p=>'±'+p.c+': '+p.drawn+(p.partial?' in a partial window':'')+' of M = '+p.M).join(', ')+')',r.bad.filter(x=>x.startsWith('count')).length===0&&r.n>0,r.bad.join(' | '));
      ok(lab+': every drawn event lies on a reference longitude within 1e-9 (worst '+r.worst.toExponential(2)+'), on β = 0 for even k and β = π for odd k, and it is drawn on the canvas (its centre or ring pixel; marks of different pairs can share a point and overlap)',r.bad.filter(x=>x.startsWith('off')).length===0&&r.unlit===0,JSON.stringify(r).slice(0,300));
      ok(lab+': both reference longitudes drawn (β = 0 and β = π stubs, two canvas runs of 361 points, labels "β = 0" and "β = π"), independent of whether a tooth traverses them',r.lon.join()==='0,pi'&&r.runs.join()==='361,361'&&r.labels.join()==='β = 0,β = π',JSON.stringify({lon:r.lon,runs:r.runs,labels:r.labels}));
      ok(lab+': caption line carries the label "'+(r.odd?'c = 0 · carrier tooth':'reference carrier · no tooth')+'"',r.cap.some(c=>c.includes('mirror axis β = 0, π: '+(r.odd?'c = 0 · carrier tooth':'reference carrier · no tooth'))),r.cap.join(' | '));
    }
    // ---- odd and even screenshots, Layers menu text
    for(const [lab,o,par,inner] of [['odd',ODD,'mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic) · c = 0 · carrier tooth','±1 · 2 same-time tip coincidences per common period P = 10 (M = P·|c·t₂|/N, exact) · image intersections: 10 = 2|p·q|, separate count, not all on β = 0, π · 2 marked'],
                                    ['even',EVEN,'mirror c ↦ −c fixes 0 teeth: line between c = ∓1 (mnemonic) · reference carrier · no tooth','±1 · 2 same-time tip coincidences per common period P = 10 (M = P·|c·t₂|/N, exact) · image intersections: 10 = 2|p·q|, separate count, not all on β = 0, π · 2 marked']]){
      await set(o,'clifford');await pg.evaluate(()=>window.scrollTo(0,0));
      await pg.screenshot({path:path.join(root,'shot_v04_'+tag+'_clifford_'+lab+'.png')});
      await pg.click('[data-menu="layers"]');await pg.waitForTimeout(150);
      const L=await pg.evaluate(()=>({btn:(document.querySelector('#menu_layers [data-v="mirror"]')||{}).outerHTML||'',pressed:document.querySelector('#menu_layers [data-v="mirror"]')?.getAttribute('aria-pressed'),par:document.getElementById('mirror_parity')?.textContent,p1:document.querySelector('[data-mirror-pair="1"]')?.textContent}));
      ok(tag+' '+lab+' comb: Layers menu has the "Mirror axis" toggle (pressed by default), the parity line "'+par+'" and the ±1 line',L.pressed==='true'&&/Mirror axis/.test(L.btn)&&L.par===par&&L.p1===inner,JSON.stringify(L));
      const f=await fonts();ok(tag+' '+lab+' comb with the Layers menu open: no visible text below 13 px (smallest '+f.mn.toFixed(3)+' px)',f.bad.length===0,f.bad.slice(0,4).join(' | '));
      await pg.screenshot({path:path.join(root,'shot_v04_'+tag+'_clifford_'+lab+'_layers.png'),fullPage:true});
      await pg.click('[data-menu="layers"]');await pg.waitForTimeout(100);}
    // ---- toggle: off removes every mirror object and the caption phrase; exports unchanged; on restores
    {await set(EVEN,'clifford');const ex0=await pg.evaluate(()=>FVCombCore.exportExact(FVPanel.state,null,{}));
     await pg.click('[data-menu="layers"]');await pg.click('#menu_layers [data-v="mirror"]');await pg.waitForTimeout(200);
     const off=await pg.evaluate(()=>({lon:document.querySelectorAll('#stage [data-role="mirror-longitude"]').length,marks:FVViews.layerMarks().filter(m=>m.role==='mirror-crossing').length,cap:[...document.querySelectorAll('#caption p')].map(p=>p.textContent).join('|'),view:FVPanel.state.view,ex:FVCombCore.exportExact(FVPanel.state,null,{}),pr:document.querySelector('#menu_layers [data-v="mirror"]').getAttribute('aria-pressed'),line:document.querySelector('[data-mirror-pair="1"]').textContent}));
     ok(tag+' toggle off: no longitudes, no event marks, no caption phrase, view key cm=0 in the address, the exact export byte-identical, the pair line still gives the exact M and says "layer off"',off.lon===0&&off.marks===0&&!/mirror axis/.test(off.cap)&&/cm=0/.test(off.view)&&off.ex===ex0&&off.pr==='false'&&/· layer off$/.test(off.line)&&/2 same-time tip coincidences/.test(off.line),JSON.stringify(off).slice(0,400));
     await pg.click('#menu_layers [data-v="mirror"]');await pg.waitForTimeout(200);
     const on=await pg.evaluate(()=>({lon:document.querySelectorAll('#stage [data-role="mirror-longitude"]').length,marks:FVViews.layerMarks().filter(m=>m.role==='mirror-crossing').length,view:FVPanel.state.view}));
     ok(tag+' toggle on again: longitudes and the 10 event marks of the Z6 comb back, cm back to its default (not in the address)',on.lon===2&&on.marks===10&&!/cm=/.test(on.view),JSON.stringify(on));
     await pg.click('[data-menu="layers"]');await pg.waitForTimeout(100);}
    // ---- camera drag: the marks follow the camera and stay on the longitudes
    {await set(EVEN,'clifford');const before=await pg.evaluate(()=>FVViews.layerMarks().filter(m=>m.role==='mirror-crossing').map(m=>[m.x,m.y]));
     const bb=await pg.locator('#stage').boundingBox();await pg.mouse.move(bb.x+bb.width/2,bb.y+bb.height/2);await pg.mouse.down();for(let i=0;i<10;i++)await pg.mouse.move(bb.x+bb.width/2+8*i,bb.y+bb.height/2+3*i);await pg.mouse.up();await pg.waitForTimeout(300);
     const r=await tma(),after=await pg.evaluate(()=>FVViews.layerMarks().filter(m=>m.role==='mirror-crossing').map(m=>[m.x,m.y]));
     ok(tag+' after a camera drag: still '+after.length+' event marks, moved on screen, each on a reference longitude within 1e-9',after.length===10&&before.length===10&&after.some((p,i)=>Math.hypot(p[0]-before[i][0],p[1]-before[i][1])>1)&&r.bad.length===0&&r.unlit===0,JSON.stringify(r.bad));}
    // ---- guards
    {await set({...EVEN,t2:'0'},'clifford');const r=await pg.evaluate(()=>({marks:FVViews.layerMarks().filter(m=>m.role==='mirror-crossing').length,lon:document.querySelectorAll('#stage [data-role="mirror-longitude"]').length}));
     await pg.click('[data-menu="layers"]');await pg.waitForTimeout(120);const l1=await pg.evaluate(()=>document.querySelector('[data-mirror-pair="1"]').textContent);await pg.click('[data-menu="layers"]');
     ok(tag+' guard t₂ = 0: no event marks, the longitudes still drawn, the pair line says the trajectories coincide continuously',r.marks===0&&r.lon===2&&/coincide continuously/.test(l1),JSON.stringify({r,l1}));}
    {await set({...ODD,t1:'0'},'clifford');await pg.click('[data-menu="layers"]');await pg.waitForTimeout(120);
     const r=await pg.evaluate(()=>({par:document.getElementById('mirror_parity').textContent,l1:document.querySelector('[data-mirror-pair="1"]').textContent,cap:[...document.querySelectorAll('#caption p')].map(p=>p.textContent).join('|')}));await pg.click('[data-menu="layers"]');
     ok(tag+' guard t₁ = 0: the c = 0 tooth is labelled stationary (a point, not the whole longitude); the pair line says both images are the same transverse circle and gives no image-intersection number',/stationary, a point, not the whole longitude/.test(r.par)&&/same transverse circle/.test(r.l1)&&/image sets coincide/.test(r.l1),JSON.stringify(r));}
    {await set({...EVEN,n6:'0'},'clifford');const r=await pg.evaluate(()=>({lon:document.querySelectorAll('#stage [data-role="mirror-longitude"]').length,marks:FVViews.layerMarks().filter(m=>m.role==='mirror-crossing').length,cap:[...document.querySelectorAll('#caption p[data-role="degenerate"]')].map(p=>p.textContent)}));
     ok(tag+' guard ρ = 0 (collapsed leaf): no longitudes, no events, a full degenerate caption line says so',r.lon===0&&r.marks===0&&r.cap.some(c=>/collapsed leaf; no reference longitudes/.test(c)),JSON.stringify(r));}
    // ---- R4: Plane (Fourier) tab, carrier-relative axis
    {await set({...EVEN,s:'1'},'fourier');
     const r=await pg.evaluate(()=>{const e=document.querySelector('#stage [data-role="mirror-axis"]');return {n:document.querySelectorAll('#stage [data-role="mirror-axis"]').length,onReal:e&&e.getAttribute('data-on-real'),y1:e&&+e.getAttribute('y1'),y2:e&&+e.getAttribute('y2'),cap:document.querySelector('#caption p[data-role="line"]').textContent};});
     ok(tag+' R4 t₁·s ∈ ℤ (N = 5, m = 6, t₁ = t₂ = 1, s = 1): the mirror axis is drawn on the real axis (horizontal) and the caption says "mirror axis = real axis (t₁·s ∈ ℤ)" after Q-res',r.n===1&&r.onReal==='true'&&Math.abs(r.y1-r.y2)<1e-6&&/Q-res .* \(numerical\) · mirror axis = real axis \(t₁·s ∈ ℤ\)$/.test(r.cap),JSON.stringify(r));
     await pg.evaluate(()=>window.scrollTo(0,0));await pg.screenshot({path:path.join(root,'shot_v04_'+tag+'_fourier.png')});}
    {await set({...EVEN,t1:'1/2',s:'1'},'fourier');
     const r=await pg.evaluate(()=>{const e=document.querySelector('#stage [data-role="mirror-axis"]'),M=FVPanel.model,W=M.num.W[M.num.W.length-1];return {onReal:e.getAttribute('data-on-real'),x1:+e.getAttribute('x1'),x2:+e.getAttribute('x2'),y1:+e.getAttribute('y1'),y2:+e.getAttribute('y2'),cap:document.querySelector('#caption p[data-role="line"]').textContent,W:[W.re,W.im],bound:M.num.bound};});
     ok(tag+' R4 review counterexample (N = 5, offsets ±1, ±3, ±5, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): resultant −i (numerical), the drawn mirror axis is the carrier line e^{iπ/2}·ℝ (vertical), not the real axis, and the caption makes no real-axis claim',r.onReal==='false'&&Math.abs(r.x1-r.x2)<1e-6&&Math.abs(r.y1-r.y2)>100&&!/mirror axis/.test(r.cap)&&Math.abs(r.W[0])<=r.bound&&Math.abs(r.W[1]+1)<=r.bound,JSON.stringify(r));
     await pg.evaluate(()=>window.scrollTo(0,0));await pg.screenshot({path:path.join(root,'shot_v04_'+tag+'_fourier_counterexample.png')});
     const f=await fonts();ok(tag+' Fourier tab with the mirror axis: no visible text below 13 px (smallest '+f.mn.toFixed(3)+' px)',f.bad.length===0,f.bad.join(' | '));
     await pg.click('[data-menu="layers"]');await pg.click('#menu_layers [data-v="maxis"]');await pg.waitForTimeout(150);
     const n=await pg.evaluate(()=>({n:document.querySelectorAll('#stage [data-role="mirror-axis"]').length,view:FVPanel.state.view}));await pg.click('[data-menu="layers"]');
     ok(tag+' R4 Fourier "Mirror axis" toggle off removes the line (view key fm=0)',n.n===0&&/fm=0/.test(n.view),JSON.stringify(n));}
    // ---- the v0.4 menu inventory (successor of the two v0.3 inventory assertions, which count the v0.3 items and now see one more)
    {await set(EVEN,'fourier');await pg.click('[data-menu="layers"]');await pg.waitForTimeout(80);
     const f=await pg.evaluate(()=>[...document.querySelectorAll('#menu .menu [data-act="vtool"]')].map(b=>b.textContent));await pg.click('[data-menu="layers"]');
     await set(EVEN,'clifford');await pg.click('[data-menu="layers"]');await pg.waitForTimeout(80);
     const c=await pg.evaluate(()=>[...document.querySelectorAll('#menu button[aria-pressed="true"]')].filter(b=>b.querySelector('.sws')).map(b=>b.getAttribute('data-v')));await pg.click('[data-menu="layers"]');
     ok(tag+' v0.4 menu inventory: Fourier Layers = Teeth, Walk, Amber polygon, ÷ Divisors, Mirror axis (5); Clifford pressed layers with swatches = leaf, s-orbits, Grid, Mirror axis (4)',f.length===5&&/Mirror axis/.test(f[4])&&c.join()==='leaf,orb,grid,mirror',JSON.stringify({f,c}));}
    // ---- no horizontal scroll, no errors
    ok(tag+' no horizontal scroll',await pg.evaluate(()=>document.documentElement.scrollWidth<=document.documentElement.clientWidth));
    ok(tag+' no console or page errors in the mirror checks',errs.length===0,errs.join(' | '));
    await ctx.close();
  }
  await browser.close();
  console.log(`browser-check-mirror: ${pass} passed, ${fail} failed`);
  process.exit(fail?1:0);
})();
