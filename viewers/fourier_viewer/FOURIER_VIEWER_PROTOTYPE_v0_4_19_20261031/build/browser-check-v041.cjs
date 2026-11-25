'use strict';
// v0.4.1 browser check (SCHEMA_ADDENDUM_9): shell range n1 = 1..13 / B >= 1, the star on t1*s in Z, the carrier foliation (display register).
// Playwright from s6_atom/node_modules; dist pages over file:// (v0.4 page read-only, for the byte-identity comparison with the foliation off).
const path=require('path'),crypto=require('crypto');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
const url04='file:///C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_20261019/dist/comb-hopf.html';
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const addr=o=>CC.encodeAddress(CC.enterSpin(CC.initial(o),o.sTyped||'1'));
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[375,812,'375x812'],[1280,800,'1280x800']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500});
    const pg=await ctx.newPage(),errs=[];pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});pg.on('pageerror',e=>errs.push(String(e)));
    await pg.goto(url);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
    const go=async(o)=>{await pg.goto(url+addr(o));await pg.reload();await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await pg.waitForTimeout(250);await pg.evaluate(()=>window.scrollTo(0,0));};
    const fonts=()=>pg.evaluate(()=>{const bad=[];let mn=1e9;const svg=document.getElementById('stage'),k=svg.getBoundingClientRect().width/svg.viewBox.baseVal.width;
      document.querySelectorAll('body *').forEach(e=>{if(['SCRIPT','STYLE','OPTION'].includes(e.tagName))return;const own=[...e.childNodes].some(c=>c.nodeType===3&&c.textContent.trim());if(!own)return;
        const r=e.getBoundingClientRect(),cs=getComputedStyle(e);if(cs.display==='none'||cs.visibility==='hidden'||(r.width===0&&r.height===0))return;let fs=parseFloat(cs.fontSize);if(e.closest('svg'))fs*=k;mn=Math.min(mn,fs);if(fs<13-1e-6)bad.push(e.textContent.trim().slice(0,20)+' '+fs.toFixed(2));});return {mn,bad};});
    const touch=()=>pg.evaluate(()=>{const bad=[];document.querySelectorAll('#menu button,#menu select').forEach(e=>{const r=e.getBoundingClientRect();if(r.width>0&&r.height<39.5)bad.push((e.textContent||e.id).trim().slice(0,16)+' '+r.height.toFixed(1));});return bad;});
    // ---------------- 1. shell range
    {const r=await pg.evaluate(()=>[...document.querySelectorAll('#n1_sel option')].map(o=>o.value));
     ok(tag+' shell range: the n₁ select offers 1 … 13 (13 options)',r.join()==='1,2,3,4,5,6,7,8,9,10,11,12,13',r.join());}
    for(const n1 of ['2','1']){
      await pg.selectOption('#n1_sel',n1);await pg.waitForTimeout(200);
      const r=await pg.evaluate(()=>({st:FVPanel.state,shell:document.getElementById('shell_read').textContent,status:document.getElementById('status').textContent,dn:document.getElementById('n1_dn').disabled,max:document.getElementById('phi_sl').max}));
      const B=n1==='1'?'1':'2';
      ok(tag+' shell range: selecting n₁ = '+n1+' gives B = '+B+' (φ₃ clamped into 0 … B + 1 = '+r.max+'), no refusal'+(n1==='1'?', and ◀ n₁ is disabled at the bottom':''),r.st.n1===n1&&r.st.B===B&&new RegExp('= '+B+' · N = ').test(r.shell)&&r.status===''&&r.max===String(Number(B)+1)&&(n1!=='1'||r.dn),JSON.stringify(r).slice(0,300));}
    {await pg.evaluate(()=>FVPanel.dial({shellMode:'integer',B:'1',phi3:'0'}));await pg.waitForTimeout(150);
     const r=await pg.evaluate(()=>({B:FVPanel.state.B,shell:document.getElementById('shell_read').textContent,status:document.getElementById('status').textContent}));
     ok(tag+' shell range: integer base B = 1 is accepted (shell readout B = 1 · N = 2)',r.B==='1'&&/B = 1 · N = 2/.test(r.shell)&&r.status==='',JSON.stringify(r));}
    // first screen and shots of the new shells; every tab renders; no text below 13 px
    for(const [lab,o] of [['n1_1',{shellMode:'factorial',n1:'1',phi3:'1',m:'2',t1:'1',t2:'1'}],['n1_2',{shellMode:'factorial',n1:'2',phi3:'0',m:'3',t1:'1',t2:'1'}],
                          ['n1_1_continuous',{shellMode:'factorial',n1:'1',nMode:'continuous',phi3:'1/2',m:'2',t1:'1',t2:'1'}],['B1_integer',{shellMode:'integer',B:'1',phi3:'0',m:'2',t1:'1',t2:'1'}]]){
      for(const tab of ['fourier','clifford','hopf','panels']){await go({...o,tab});
        const L=await pg.evaluate(()=>({tr:document.getElementById('transport').getBoundingClientRect().bottom,vh:innerHeight,status:document.getElementById('status').textContent,svg:document.querySelectorAll('#stage *').length}));
        const f=await fonts();
        ok(tag+' '+lab+' '+tab+': renders without a refusal or error'+(tab==='fourier'?', first screen holds (transport bottom '+Math.round(L.tr)+' ≤ '+L.vh+')':' (transport bottom '+Math.round(L.tr)+', informative)')+', no visible text below 13 px (smallest '+f.mn.toFixed(3)+')',L.status===''&&f.bad.length===0&&(tab!=='fourier'||w>500||L.tr<=L.vh),JSON.stringify({L,bad:f.bad.slice(0,3)}));
        if(tab==='clifford'||tab==='fourier')await pg.screenshot({path:path.join(root,'shot_v041_'+tag+'_'+lab+'_'+tab+'.png')});}}
    // ---------------- 2. the star
    {await go({shellMode:'integer',B:'24',phi3:'20',m:'6',t1:'1/2',t2:'1',n6:'1',alpha:'0',sTyped:'1',tab:'fourier'});
     const r=await pg.evaluate(()=>({cap:document.querySelector('#caption p[data-role="line"]').textContent,cards:document.getElementById('cards').textContent}));
     ok(tag+' ★ counterexample (N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1): no ★ in the caption (s ∈ ℤ but t₁·s ∉ ℤ), Q-res 1.0e+0; the card says "lab-frame W real (t₁·s ∈ ℤ, exact) no" and gives the carrier-relative Im within the bound',!/★/.test(r.cap)&&/Q-res 1\.0e\+0/.test(r.cap)&&/lab-frame W real \(t₁·s ∈ ℤ, exact\)no/.test(r.cards)&&/carrier-relative W·e\^\{−iπ\(t₁s\+f\)\} real at every s \(identity, symmetric offsets\)Im \d\.\de[-+]\d+ ±/.test(r.cards),JSON.stringify(r).slice(0,400));
     await pg.screenshot({path:path.join(root,'shot_v041_'+tag+'_star_counterexample.png')});}
    {await go({shellMode:'factorial',n1:'4',phi3:'23',m:'2',t1:'1',t2:'1',sTyped:'1',tab:'fourier'});
     const r=await pg.evaluate(()=>({cap:document.querySelector('#caption p[data-role="line"]').textContent,cards:document.getElementById('cards').textContent}));
     ok(tag+' ★ default state (t₁·s = 1 ∈ ℤ): "SPREAD … ★ lab sum real" precedes Q-res, and the card says "yes ★"',/SPREAD (yes|no) ★ lab sum real · Q-res/.test(r.cap)&&/lab-frame W real \(t₁·s ∈ ℤ, exact\)yes ★/.test(r.cards),r.cap);}
    // ---------------- 3. carrier foliation
    const FOLST={shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'1',n6:'1',alpha:'0',sTyped:'1/3',tab:'clifford'};
    {await go(FOLST);await pg.click('[data-menu="layers"]');await pg.waitForTimeout(120);
     const r=await pg.evaluate(()=>({btn:document.querySelector('#menu_layers [data-v="fol"]')?.getAttribute('aria-pressed'),sel:[...document.querySelectorAll('#menu_layers select[data-vsel="fol_k"] option')].map(o=>o.textContent),st:document.getElementById('fol_state')?.textContent,runs:FVViews.layerRuns().filter(r=>r.role.startsWith('foliation')).length}));
     ok(tag+' foliation: the "Carrier foliation" toggle is visible in the Clifford Layers menu, not pressed by default; leaf counts 6, 12, 24, 120 offered; readout says off; nothing drawn',r.btn==='false'&&r.sel.join()==='6,12,24,120'&&/^off/.test(r.st)&&r.runs===0,JSON.stringify(r));
     const t0=await touch();ok(tag+' foliation: every Layers-menu control is at least 40 px high',t0.length===0,t0.join(' | '));
     await pg.click('#menu_layers [data-v="fol"]');await pg.waitForTimeout(200);
     for(let i=0;i<3;i++){await pg.click('#menu_layers [data-v="fb_p10"]');await pg.waitForTimeout(80);}
     await pg.click('#menu_layers [data-v="fb_p1"]');await pg.waitForTimeout(80);await pg.click('#menu_layers [data-v="fb_m1"]');await pg.waitForTimeout(80);
     await pg.selectOption('#menu_layers select[data-vsel="fol_k"]','fk12');await pg.waitForTimeout(200);
     const g=await pg.evaluate(()=>{const F=FVPanel.model.foliation,NUM=FVCombNumeric,bad=[];let worst=0;const runs=FVViews.layerRuns().filter(r=>r.role.startsWith('foliation'));
       for(const c of [...F.family,F.selected,F.companion])for(const y of c.pts){const x=NUM.unproject(y),gg=Math.atan2(x[3],x[2])-Math.PI*Number(c.beta.n)/Number(c.beta.d),r=Math.abs(Math.atan2(Math.sin(gg),Math.cos(gg)));const d=Math.max(r,Math.abs(Math.hypot(x[0],x[1])-F.a),Math.abs(Math.hypot(x[2],x[3])-F.b));worst=Math.max(worst,d);if(d>1e-9)bad.push(d);}
       return {view:FVPanel.state.view,beta:document.getElementById('fol_beta').textContent,st:document.getElementById('fol_state').textContent,fam:runs.filter(r=>r.role==='foliation').length,sel:document.querySelectorAll('#stage [data-role="foliation-selected"][data-beta="1/4"]').length,comp:document.querySelectorAll('#stage [data-role="foliation-companion"][data-beta="5/4"]').length,lab:[...document.querySelectorAll('#stage [data-role="foliation-label"]')].map(e=>e.textContent),bad:bad.length,worst};});
     ok(tag+' foliation on, β ▶▶ ×3, β ▶, ◀ β, leaves 12: view cff=1, cfb=30, cfk=12; readout "selected β = 1/4·π (exact, β/π = k/120, k = 30) · companion β + π = 5/4·π (dashed)"; 12 family runs, the selected (β/π = 1/4) and companion (5/4) stubs, label "β = 1/4·π"; every drawn point has arg z₂ = β and |z₁|, |z₂| = a, b within 1e-9 (worst '+g.worst.toExponential(2)+')',/cff=1/.test(g.view)&&/cfb=30/.test(g.view)&&/cfk=12/.test(g.view)&&g.beta.startsWith('selected β = 1/4·π (exact, β/π = k/120, k = 30) · companion β + π = 5/4·π (dashed)')&&/^drawn: 12 longitudes/.test(g.st)&&g.fam===12&&g.sel===1&&g.comp===1&&g.lab.join()==='β = 1/4·π'&&g.bad===0,JSON.stringify(g).slice(0,400));
     const f=await fonts();ok(tag+' foliation with the Layers menu open: no visible text below 13 px (smallest '+f.mn.toFixed(3)+')',f.bad.length===0,f.bad.join(' | '));
     await pg.click('[data-menu="layers"]');await pg.waitForTimeout(100);await pg.evaluate(()=>window.scrollTo(0,0));await pg.screenshot({path:path.join(root,'shot_v041_'+tag+'_foliation_odd.png')});
     await pg.click('[data-menu="layers"]');await pg.waitForTimeout(100);await pg.screenshot({path:path.join(root,'shot_v041_'+tag+'_foliation_odd_layers.png'),fullPage:true});await pg.click('[data-menu="layers"]');}
    {await go({...FOLST,m:'6',view:'cff=1;cfb=10'});const r=await pg.evaluate(()=>({runs:FVViews.layerRuns().filter(r=>r.role==='foliation').length,teeth:null}));
     await pg.click('[data-menu="layers"]');await pg.waitForTimeout(120);const tt=await pg.evaluate(()=>document.getElementById('fol_teeth').textContent);await pg.click('[data-menu="layers"]');
     ok(tag+' foliation on an even comb (m = 6): 24 family runs, readout "no tooth lies on the foliation (even comb)"',r.runs===24&&tt==='no tooth lies on the foliation (even comb)',JSON.stringify({r,tt}));
     await pg.evaluate(()=>window.scrollTo(0,0));await pg.screenshot({path:path.join(root,'shot_v041_'+tag+'_foliation_even.png')});}
    {await go({shellMode:'factorial',n1:'4',phi3:'24',m:'2',t1:'1',t2:'1',sTyped:'1',tab:'clifford',view:'cff=1;cfb=20'});
     const r=await pg.evaluate(()=>({N:String(FVCombCore.resolve(FVPanel.state).N),runs:FVViews.layerRuns().filter(r=>r.role.startsWith('foliation')).length}));
     ok(tag+' N = 1 via φ₃ = B (n₁ = 4, m = 2, t₁ = t₂ = 1) with the foliation on: 24 + 2 runs drawn',r.N==='1'&&r.runs===26,JSON.stringify(r));
     await pg.screenshot({path:path.join(root,'shot_v041_'+tag+'_N1_foliation.png')});}
    {await go({...FOLST,t1:'0',view:'cff=1;cfb=30'});const r=await pg.evaluate(()=>({cap:[...document.querySelectorAll('#caption p[data-role="degenerate"]')].map(p=>p.textContent),pts:FVViews.layerMarks().filter(m=>m.role.startsWith('foliation')).length,runs:FVViews.layerRuns().filter(r=>r.role.startsWith('foliation')).length}));
     ok(tag+' foliation guard t₁ = 0: labelled (each carrier orbit is a point), drawn as 24 + 2 points, no curves',r.cap.some(c=>/t₁ = 0: the carrier is stationary; each orbit of the carrier action is a point/.test(c))&&r.pts===26&&r.runs===0,JSON.stringify(r));}
    {await go({...FOLST,n6:'0',view:'cff=1'});const r=await pg.evaluate(()=>({cap:[...document.querySelectorAll('#caption p[data-role="degenerate"]')].map(p=>p.textContent),n:FVViews.layerRuns().filter(r=>r.role.startsWith('foliation')).length+FVViews.layerMarks().filter(m=>m.role.startsWith('foliation')).length}));
     ok(tag+' foliation guard ρ = 0: nothing drawn, labelled "collapsed leaf (ρ = 0): the carrier foliation is not drawn."',r.n===0&&r.cap.includes('collapsed leaf (ρ = 0): the carrier foliation is not drawn.'),JSON.stringify(r));}
    // ---------------- 4. foliation off: the Clifford render equals the v0.4 page byte for byte (SVG overlay, caption, canvas pixels, recorded runs and marks)
    {const p4=await ctx.newPage();const states=[{shellMode:'factorial',n1:'4',phi3:'23',m:'2',t1:'1',t2:'1',sTyped:'1'},{...FOLST},{...FOLST,m:'6'},{shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',sTyped:'4/7'},
        {shellMode:'factorial',n1:'4',phi3:'6',m:'3',t1:'1',t2:'-21/4',alpha:'-1/50',sTyped:'-627/250'},{...FOLST,t1:'0'},{...FOLST,n6:'0'},{...FOLST,nMode:'continuous',phi3:'7/2',m:'4'}];
     let same=0;const diffs=[];
     const snap=async p=>p.evaluate(()=>{const cv=document.getElementById('stagecv');return {svg:document.getElementById('stage').innerHTML,cap:document.getElementById('caption').innerHTML,png:cv.toDataURL(),runs:JSON.stringify(FVViews.layerRuns().map(r=>[r.role,r.c,r.stroke,r.width,r.pts.length])),marks:JSON.stringify(FVViews.layerMarks().map(m=>[m.role,m.c,m.x,m.y]))};});
     for(const o of states){const a=addr({...o,tab:'clifford'});for(const p of [pg,p4]){await p.goto((p===pg?url:url04)+a);await p.reload();await p.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await p.waitForTimeout(300);}
       const A=await snap(pg),B=await snap(p4);const k=Object.keys(A).filter(x=>A[x]!==B[x]);if(k.length===0)same++;else diffs.push(o.m+':'+k.join('/'));}
     ok(tag+' foliation off: for '+states.length+' states the Clifford SVG overlay, caption, canvas pixels (PNG data URL), recorded runs and marks equal the v0.4 page byte for byte',same===states.length,diffs.join(' | '));
     await p4.close();}
    ok(tag+' no console or page errors in the v0.4.1 checks',errs.length===0,errs.join(' | '));
    ok(tag+' no horizontal scroll',await pg.evaluate(()=>document.documentElement.scrollWidth<=document.documentElement.clientWidth));
    await ctx.close();
  }
  await browser.close();
  console.log(`browser-check-v041: ${pass} passed, ${fail} failed`);
  process.exit(fail?1:0);
})();
