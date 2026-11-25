'use strict';
// Browser check (Playwright from s6_atom/node_modules): loads dist/comb-hopf.html over file://, screenshots, exercises tabs, stepping, exports.
const path=require('path'),fs=require('fs');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
let pass=0,fail=0,minFont=1e9;
const expOpen=async(p,imp)=>{if(!(await p.locator('#expmenu').isVisible()))await p.click('#expBtn');if(imp&&!(await p.locator('#imp').isVisible()))await p.click('#impShow');await p.waitForTimeout(40);};const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x?' '+x:''));c?pass++:fail++;};
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[375,812,'375x812'],[1280,800,'1280x800']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},acceptDownloads:true,deviceScaleFactor:1,hasTouch:w<500});
    const page=await ctx.newPage(),errs=[],reqs=[];
    page.on('console',m=>{if(m.type()==='error')errs.push(m.text());});page.on('pageerror',e=>errs.push(String(e)));
    page.on('request',r=>{if(!r.url().startsWith('file:')&&!r.url().startsWith('data:')&&!r.url().startsWith('blob:'))reqs.push(r.url());});
    await page.goto(url);await page.waitForSelector('#stage *');
    ok(tag+' no console errors',errs.length===0,errs.join(' | '));
    ok(tag+' zero network requests',reqs.length===0,reqs.join(','));
    const sw=await page.evaluate(()=>document.documentElement.scrollWidth),cw=await page.evaluate(()=>document.documentElement.clientWidth);
    ok(tag+' no horizontal scroll',sw<=cw,sw+'/'+cw);
    const fontCheck=async(label)=>{
      const r=await page.evaluate(()=>{const bad=[];let n=0,mn=1e9;const svg=document.getElementById('stage'),k=svg.getBoundingClientRect().width/svg.viewBox.baseVal.width;
        document.querySelectorAll('body *').forEach(e=>{
          if(['SCRIPT','STYLE','OPTION'].includes(e.tagName))return;
          const own=[...e.childNodes].some(c=>c.nodeType===3&&c.textContent.trim());if(!own)return;
          const r=e.getBoundingClientRect(),cs=getComputedStyle(e);if(cs.display==='none'||cs.visibility==='hidden'||(r.width===0&&r.height===0))return;
          let fs=parseFloat(cs.fontSize);if(e.closest('svg'))fs*=k;n++;mn=Math.min(mn,fs);if(fs<13-1e-6)bad.push(e.tagName+' '+fs.toFixed(2)+'px "'+e.textContent.trim().slice(0,30)+'"');});
        return {n,mn,bad:bad.slice(0,6),count:bad.length};});
      minFont=Math.min(minFont,r.mn);
      ok(label+' no visible text below 13.000px ('+r.n+' text elements checked, smallest '+r.mn.toFixed(4)+'px)',r.count===0,r.bad.join(' | '));
    };
    const touchCheck=async(label)=>{
      const r=await page.evaluate(()=>{const bad=[];document.querySelectorAll('button,input,select,summary').forEach(e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);if(cs.display==='none'||r.width===0||e.closest('[style*="display: none"]'))return;if(r.height<39.5)bad.push(e.tagName+'#'+e.id+' '+r.height.toFixed(1));});return bad.slice(0,8);});
      ok(label+' touch targets >= 40px high',r.length===0,r.join(' | '));
    };
    await fontCheck(tag+' fourier');await touchCheck(tag);
    // v0.1.1: the page defaults match the old viewer (phi3 = 23 so N = 2, m = 2). The older checks below set their own state explicitly (phi3 = 2, N = 23, m = 3).
    {const d=await page.evaluate(()=>{const s=FVPanel.state,R=FVCombCore.resolve(s);return {phi3:s.phi3,m:s.m,N:String(R.N),n1:s.n1,s:s.sTyped,t1:s.t1,t2:s.t2,alpha:s.alpha,n6:s.n6,E:s.E,rows:[...document.querySelectorAll('table.ph tbody tr td:first-child')].map(x=>x.textContent)};});
     ok(tag+' page defaults: n1 4, phi3 23 (N = 2), m 2, t1 = t2 = 1, alpha 1, n6 1, s 1',d.n1==='4'&&d.phi3==='23'&&d.N==='2'&&d.m==='2'&&d.t1==='1'&&d.t2==='1'&&d.alpha==='1'&&d.n6==='1'&&d.s==='1'&&d.E==='2',JSON.stringify(d));
     ok(tag+' default m = 2 (even): a separate carrier row, no c = 0 tooth',d.rows.includes('carrier (not a tooth)')&&!d.rows.includes('z[0] (carrier)'),JSON.stringify(d.rows));}
    await page.evaluate(()=>FVPanel.dial({phi3:'2',m:'3'}));await page.waitForTimeout(100);   // explicit state for the older checks: phi3 = 2 (N = 23), m = 3
    for(const tab of ['clifford','hopf','panels']){await page.click('#tabs [data-v="'+tab+'"]');await page.waitForTimeout(150);await fontCheck(tag+' '+tab);}
    await page.click('#tabs [data-v="fourier"]');
    // phasor table: no header wraps inside a word; one carrier row
    {const r=await page.evaluate(()=>{const ths=[...document.querySelectorAll('table.ph th')].map(t=>t.getBoundingClientRect().height);const lh=parseFloat(getComputedStyle(document.querySelector('table.ph th')).lineHeight)||24;return {maxH:Math.max(...ths),lh,rows:[...document.querySelectorAll('table.ph tbody tr td:first-child')].map(x=>x.textContent)};});
     ok(tag+' phasor table headers do not wrap (max header height '+r.maxH.toFixed(0)+'px)',r.maxH<r.lh*1.9+14,JSON.stringify(r.rows));
     ok(tag+' odd m: single carrier row keyed z[0] (carrier)',r.rows.filter(x=>/carrier/.test(x)).length===1&&r.rows.includes('z[0] (carrier)'));}
    // text size: 100% and 160%
    for(let i=0;i<6;i++){await page.click('#sizeUp');await page.waitForTimeout(200);await fontCheck(tag+' fourier @'+Math.round(100*[1.1,1.2,1.3,1.4,1.5,1.6][i])+'% (every A+ step)');}
    await page.waitForTimeout(50);
    ok(tag+' text size reaches 160%',(await page.textContent('#sizeVal'))==='160%');
    await fontCheck(tag+' fourier @160%');
    for(const tab of ['clifford','hopf','panels']){await page.click('#tabs [data-v="'+tab+'"]');await page.waitForTimeout(150);await fontCheck(tag+' '+tab+' @160%');}
    ok(tag+' @160% no horizontal scroll',await page.evaluate(()=>document.documentElement.scrollWidth<=document.documentElement.clientWidth));
    await page.click('#tabs [data-v="fourier"]');
    for(let i=0;i<7;i++)await page.click('#sizeDn');await page.waitForTimeout(250);
    ok(tag+' A− stops at 100%',(await page.textContent('#sizeVal'))==='100%');
    for(const tab of ['fourier','clifford','hopf','panels']){
      await page.click('#tabs [data-v="'+tab+'"]');await page.waitForTimeout(150);
      const before=await page.evaluate(()=>FVPanel.state.sTyped);
      await page.screenshot({path:path.join(root,'shot_'+tag+'_'+tab+'.png'),fullPage:true});
      const scr=await page.evaluate(()=>document.documentElement.scrollWidth<=document.documentElement.clientWidth);
      ok(tag+' tab '+tab+' renders, no horizontal scroll',scr);
      ok(tag+' tab switch leaves settings alone',before===await page.evaluate(()=>FVPanel.state.sTyped));
    }
    if(w===1280){
      await page.click('#tabs [data-v="fourier"]');
      const s0=await page.evaluate(()=>FVPanel.state.sTyped);
      await page.click('[data-act="sup"]');await page.waitForTimeout(100);
      const s1=await page.evaluate(()=>FVPanel.state.sTyped);ok('spin step forward changes s_typed exactly',s1!==s0,s0+' -> '+s1);
      await page.click('#lab_alpha');await page.fill('#alpha_tx','1/2');await page.dispatchEvent('#alpha_tx','change');await page.waitForTimeout(100);await page.click('#lab_alpha');
      ok('dial change keeps s_typed',s1===await page.evaluate(()=>FVPanel.state.sTyped));
      await page.click('#tabs [data-v="clifford"]');await page.click('#toolbar [data-menu="layers"]');await page.click('#menu [data-v="frac"]');await page.waitForTimeout(200);
      ok('clifford fraction stack caption shown',(await page.textContent('#caption')).includes('fraction stack'));
      await page.screenshot({path:path.join(root,'shot_'+tag+'_clifford_fraction.png')});
      for(const tab of ['fourier','clifford','hopf']){
        await page.click('#tabs [data-v="'+tab+'"]');
        const [dl]=await Promise.all([page.waitForEvent('download'),page.click('[data-act="xpng"]')]);
        const f=path.join(root,'export_'+tab+'.png');await dl.saveAs(f);const b=fs.readFileSync(f);
        ok('PNG export '+tab+' is a valid PNG ('+b.length+' bytes, '+dl.suggestedFilename()+')',b.slice(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10])));
        const hash=await page.textContent('#xhash'),sha=require('crypto').createHash('sha256').update(b).digest('hex');
        ok('PNG '+tab+' page-shown SHA-256 matches file',hash.includes(sha));
      }
      const dls=[];page.on('download',d=>dls.push(d.suggestedFilename()));
      await expOpen(page);await page.click('[data-act="xpair"]');await page.waitForTimeout(1500);
      ok('pair export produced 4 files',dls.length===4,dls.join(', '));
      await expOpen(page);await page.click('[data-act="xjson"]');await page.waitForTimeout(300);
      const j=await page.inputValue('#xout');ok('exact JSON ends with LF and omits tab/view',j.endsWith('}\n')&&!/"tab"|"view"/.test(j));
      await page.click('#tabs [data-v="panels"]');await page.waitForTimeout(100);
      ok('panels tab lists 17 placeholder cards',await page.locator('details.pmod').count()===17);
      await page.click('#toolbar [data-v="about"]');ok('about toggle opens provenance notes (closed by default)',(await page.locator('#about .about').count())===1);
      // touch-free drag on hopf
      await page.click('#tabs [data-v="hopf"]');const v0=await page.evaluate(()=>FVPanel.state.view);
      await page.locator('#stage').scrollIntoViewIfNeeded();const bb=await page.locator('#stage').boundingBox();const cx=bb.x+bb.width/2,cy=bb.y+bb.height/2;await page.mouse.move(cx,cy);await page.mouse.down();await page.mouse.move(cx+50,cy+30,{steps:5});await page.mouse.up();await page.waitForTimeout(100);
      ok('hopf drag rotates the camera (view state changes, spin unchanged)',v0!==await page.evaluate(()=>FVPanel.state.view));
    }
    // ------------------------------------------------ fix round 2
    {
      const imp=async(txt)=>{await expOpen(page,true);await page.fill('#imptxt',txt);await page.click('#impBtn');await page.waitForTimeout(80);return page.textContent('#impmsg');};
      const ev=(fn,arg)=>page.evaluate(fn,arg);
      const defaultsAddr=await ev(()=>FVCombCore.encodeAddress(FVCombCore.initial()));
      await page.click('#tabs [data-v="fourier"]');
      // Import state: the same R21.5 validation as a URL load
      const mk=await ev(()=>{const C=FVCombCore,d1=s=>C.enterSpin(C.initial({shellMode:'factorial',n1:'4',phi3:'1',m:'3',t1:'1/3',t2:'1/2'}),s),open=C.enterSpin(C.initial({phi3:'2',m:'3'}),'49');
        return {d1addr:C.encodeAddress(d1('49')),d1json:C.exportState(d1('49')),d1five:C.encodeAddress(d1('5')),d1m24:C.encodeAddress(d1('-24')),openjson:C.exportState(open),openaddr:C.encodeAddress(open),openSeff:open.sEff};});
      let msg=await imp(mk.d1addr);
      let stt=await ev(()=>({t:FVPanel.state.sTyped,e:FVPanel.state.sEff,E:FVPanel.state.E}));
      ok(tag+' import state: pasted address loads D1 state (gate closed) exactly as stored',stt.t==='49'&&stt.e==='49'&&stt.E==='49'&&/^Loaded/.test(msg),JSON.stringify(stt)+' '+msg);
      ok(tag+' import state: address after load equals the pasted address',(await ev(()=>FVCombCore.encodeAddress(FVPanel.state)))===mk.d1addr);
      ok(tag+' R21.2 label shown: gate closed, s_typed 49 is not its own representative in (-24, 24]',(await page.textContent('#s_read')).includes('kept: wrap not invariant here'));
      await imp(mk.d1five);
      ok(tag+' R21.2 label absent: gate closed, s_typed 5 is already its own representative',!(await page.textContent('#s_read')).includes('kept: wrap not invariant here'));
      await imp(mk.d1m24);
      ok(tag+' R21.2 label shown for s_typed -24 (a wrap would give +24) with the gate closed',(await page.textContent('#s_read')).includes('kept: wrap not invariant here'));
      msg=await imp(mk.openjson);
      stt=await ev(()=>({t:FVPanel.state.sTyped,e:FVPanel.state.sEff,E:FVPanel.state.E}));
      ok(tag+' import state: pasted state JSON with an invariant wrap restores s_eff as stored (49 / '+mk.openSeff+' / 23), labelled wrapped',stt.t==='49'&&stt.e===mk.openSeff&&stt.E==='23'&&(await page.textContent('#s_read')).includes('effective s = '+mk.openSeff),JSON.stringify(stt));
      let before=await ev(()=>FVCombCore.encodeAddress(FVPanel.state));
      const refuse=async(label,txt,re)=>{const m=await imp(txt);const now=await ev(()=>FVCombCore.encodeAddress(FVPanel.state));const dfl=await ev(()=>FVCombCore.encodeAddress(FVCombCore.initial()));const vis=(await page.textContent('#status')).includes('Import refused');ok(tag+' import state refuses '+label+' as a whole, reason shown, defaults shown as a new state (current state not kept)',/^Import refused: /.test(m)&&re.test(m)&&now===dfl&&now!==before&&vis,m);await imp(mk.openjson);before=await ev(()=>FVCombCore.encodeAddress(FVPanel.state));};
      await refuse('a wrong representative (sEff 5 for sTyped 49)',mk.openjson.replace('"sEff":"'+mk.openSeff+'"','"sEff":"5"'),/sEff is neither/);
      await refuse('E < N',mk.openjson.replace('"E":"23"','"E":"22"'),/E < N/);
      await refuse('E < |sEff|',mk.d1addr.replace('&E=49','&E=48'),/E < /);
      await refuse('a non-canonical E',mk.openjson.replace('"E":"23"','"E":"23.0"'),/canonical|exact/);
      await refuse('text that is not a state','hello',/./);
      ok(tag+' import state: empty box says nothing to load',/Nothing to load/.test(await imp('   ')));
      // the order-m witness is hidden whenever the shell changes (and only then)
      await imp(defaultsAddr);
      await page.fill('#w_p','7');await page.press('#w_p','Enter');await page.waitForTimeout(80);
      const poly=()=>page.locator('#stage [data-role="witness-polygon"]').count();
      ok(tag+' witness p=7 polygon drawn after Test',(await poly())===1);
      await ev(()=>FVPanel.dial({t1:'2'}));await page.waitForTimeout(60);
      ok(tag+' witness persists across a gear change (control)',(await poly())===1);
      await ev(()=>FVPanel.dial({phi3:'4'}));await page.waitForTimeout(60);
      ok(tag+' witness polygon hidden after a phi3 step (N changes)',(await poly())===0&&!(await page.textContent('#cards')).includes('φ relation'));
      await page.fill('#w_p','7');await page.press('#w_p','Enter');await page.waitForTimeout(80);
      ok(tag+' witness needs Test again after the phi3 step: polygon back after Test',(await poly())===1);
      await ev(()=>FVPanel.dial({t1:'1'}));
      await page.selectOption('#n1_sel','5');await page.waitForTimeout(80);
      ok(tag+' witness polygon hidden when n1 (the shell) changes',(await poly())===0&&!(await page.textContent('#cards')).includes('φ relation'));
      await page.fill('#w_p','7');await page.press('#w_p','Enter');await page.waitForTimeout(80);
      ok(tag+' witness needs Test again: polygon back after Test',(await poly())===1);
      await page.click('[data-act="mode"][data-v="integer"]');await page.waitForTimeout(80);
      ok(tag+' witness polygon hidden when the shell mode changes',(await poly())===0);
      await imp(defaultsAddr);
      // numerical readouts |W|, |W|/rho, gate residual
      {const t=await page.textContent('#cards');
       ok(tag+' numerical readouts shown: |W|, |W|/rho, W1 gate residual, each labelled numerical with a bound',/\|W\| \(endpoint\) numerical\s*[0-9.e+-]+ ±[0-9.e+-]+/.test(t)&&/\|W\|\/ρ numerical\s*[0-9.e+-]+ ±[0-9.e+-]+/.test(t)&&/W₁ latitude-gate residual numerical\s*[0-9.e+-]+ ≤ bound [0-9.e+-]+ \(within bound\)/.test(t),t.slice(t.indexOf('Q-residual'),t.indexOf('Q-residual')+330));
       const nv=await ev(()=>({abs:FVPanel.model.num.endpoint.abs,r:FVPanel.model.num.endpoint.absOverRho,rho:FVPanel.model.num.rho}));
       ok(tag+' |W|/rho equals |W| divided by rho on the page model',Math.abs(nv.r-nv.abs/nv.rho)<=1e-12*Math.max(1,nv.r));}
      // rho = 0: Clifford axis, undefined |W|/rho
      await ev(()=>FVPanel.dial({n6:'0'}));await page.waitForTimeout(80);
      ok(tag+' rho=0: "|W|/ρ undefined (ρ = 0)" shown',(await page.textContent('#cards')).includes('|W|/ρ undefined (ρ = 0)'));
      await page.click('#tabs [data-v="clifford"]');await page.waitForTimeout(120);
      {const cap=await page.textContent('#caption');
       ok(tag+' rho=0 Clifford: the x3 axis is drawn, labelled as a line closed at infinity, not a circle',(await page.locator('#stage [data-role="rho0-axis"]').count())===1&&/x₃ axis/.test(cap)&&/closed at ∞/.test(cap)&&!/projects to a circle/.test(cap)&&(await page.locator('#stage [data-role="leaf"]').count())===0,cap);}
      if(w===1280)await page.screenshot({path:path.join(root,'shot_1280x800_clifford_rho0.png')});
      await ev(()=>FVPanel.dial({n6:'1'}));await page.waitForTimeout(80);
      ok(tag+' rho>0 Clifford: no x3-axis line, leaf mesh drawn (control)',(await page.locator('#stage [data-role="rho0-axis"]').count())===0&&(await page.locator('#stage [data-role="leaf"]').count())>0);
      // pan toggle on Clifford: one-finger drag pans instead of rotating
      {const vsOf=()=>ev(()=>Object.fromEntries(FVPanel.state.view.split(';').filter(Boolean).map(x=>x.split('='))));
       const drag=async()=>{await page.locator('#stage').scrollIntoViewIfNeeded();const bb=await page.locator('#stage').boundingBox(),cx=bb.x+bb.width/2,cy=bb.y+bb.height/2;await page.mouse.move(cx,cy);await page.mouse.down();await page.mouse.move(cx+40,cy+25,{steps:5});await page.mouse.up();await page.waitForTimeout(80);};
       await ev(()=>FVPanel.dial({view:''}));await drag();let v=await vsOf();
       ok(tag+' clifford drag without ✥ rotates (ca changes, cx does not)',v.ca!==undefined&&v.cx===undefined,JSON.stringify(v));
       await ev(()=>FVPanel.dial({view:''}));
       await page.click('#toolbar [data-menu="camera"]');await page.click('#menu [data-v="pan"]');await page.waitForTimeout(60);
       ok(tag+' ✥ pan toggle (Camera menu) is pressed',(await page.getAttribute('#menu [data-v="pan"]','aria-pressed'))==='true');
       await drag();v=await vsOf();
       ok(tag+' clifford drag with ✥ pans (cx, cy change; rotation unchanged)',v.cx!==undefined&&Math.abs(parseFloat(v.cx))>1&&v.ca===undefined&&v.ce===undefined,JSON.stringify(v));
       await ev(()=>FVPanel.dial({view:''}));await page.waitForTimeout(40);}
      // fullscreen on Fourier, Clifford, Hopf
      for(const tab of ['fourier','clifford','hopf']){
        await page.click('#tabs [data-v="'+tab+'"]');await page.waitForTimeout(100);
        await page.click('#toolbar [data-v="full"]');await page.waitForTimeout(400);
        const f1=await ev(()=>({fs:(document.fullscreenElement||document.webkitFullscreenElement||{}).id||null,maxed:document.getElementById('frame').classList.contains('maxed')}));
        ok(tag+' '+tab+' ⛶ enters real fullscreen on the view frame (Fullscreen API)',f1.fs==='frame'&&!f1.maxed,JSON.stringify(f1));
        await ev(()=>document.exitFullscreen());await page.waitForTimeout(300);
        ok(tag+' '+tab+' fullscreen exits',(await ev(()=>!document.fullscreenElement)));
      }
      // fallback: API unavailable -> CSS maximised view with a close button
      await ev(()=>{Element.prototype.requestFullscreen=undefined;Element.prototype.webkitRequestFullscreen=undefined;});
      for(const tab of ['fourier','clifford','hopf']){
        await page.click('#tabs [data-v="'+tab+'"]');await page.waitForTimeout(100);
        await page.click('#toolbar [data-v="full"]');await page.waitForTimeout(250);
        const f2=await ev(()=>{const f=document.getElementById('frame'),r=f.getBoundingClientRect(),b=document.getElementById('frameClose').getBoundingClientRect();return {maxed:f.classList.contains('maxed'),fill:r.width>=innerWidth-1&&r.height>=innerHeight-1,closeVisible:b.width>0&&b.height>=39.5};});
        ok(tag+' '+tab+' ⛶ without the API: maximised view fills the window with a Close button ≥40px',f2.maxed&&f2.fill&&f2.closeVisible,JSON.stringify(f2));
        if(tab==='clifford'){const bad=await ev(()=>{const svg=document.getElementById('stage'),vb=svg.viewBox.baseVal,r=svg.getBoundingClientRect(),k=Math.min(r.width/vb.width,r.height/vb.height);let n=0;svg.querySelectorAll('text').forEach(e=>{if(parseFloat(getComputedStyle(e).fontSize)*k<12.99)n++;});return n;});
          ok(tag+' maximised Clifford: no SVG text below 13px on screen',bad===0,String(bad));}
        await page.click('#frameClose');await page.waitForTimeout(150);
        ok(tag+' '+tab+' Close button restores the page',await ev(()=>!document.getElementById('frame').classList.contains('maxed')));
        await page.click('#toolbar [data-v="full"]');await page.waitForTimeout(150);await page.keyboard.press('Escape');await page.waitForTimeout(150);
        ok(tag+' '+tab+' Esc also closes the maximised view',await ev(()=>!document.getElementById('frame').classList.contains('maxed')));
      }
      await page.reload();await page.waitForSelector('#stage *',{state:'attached'});
      // contrast colour band and lock (exact rational comparison): N=30 contrast 29/8 (> 3), N=6 contrast 5/2 (> 2), N=5 contrast 1/2
      {const card=async(B,p3)=>{await ev(([B,p3])=>FVPanel.dial({shellMode:'integer',B:B,phi3:p3}),[B,p3]);await page.waitForTimeout(80);
         return ev(()=>{const el=[...document.querySelectorAll('#cards .kv b')].find(b=>/≈/.test(b.textContent));return {t:el.textContent,c:getComputedStyle(el).color};});};
       const hex=h=>{const n=parseInt(h.slice(1),16);return 'rgb('+(n>>16&255)+', '+(n>>8&255)+', '+(n&255)+')';};
       const pal=await ev(()=>FVViews.palette());
       const a=await card('29','0'),b=await card('5','0'),c=await card('4','0');
       ok(tag+' contrast 29/8 > 3: defend colour and lock',a.t.startsWith('29/8')&&a.t.includes('🔒')&&a.c===hex(pal.defend),JSON.stringify(a));
       ok(tag+' contrast 5/2 (2 < v < 3): warn colour, no lock',b.t.startsWith('5/2')&&!b.t.includes('🔒')&&b.c===hex(pal.warn),JSON.stringify(b));
       ok(tag+' contrast 1/2: dim colour, no lock',c.t.startsWith('1/2')&&!c.t.includes('🔒')&&c.c===hex(pal.dim),JSON.stringify(c));}
    }
    // fix round 4: s-orbit smoothness at the example state (B=24, phi3=21, m=7, t1=t2=1, n6=1, alpha=0, s=408/125)
    {const CC=require('../host-core/comb-core.js'),addr=CC.encodeAddress(CC.initial({shellMode:'integer',B:'24',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'0',sTyped:'408/125',chart:'host'}));
     const pg=await ctx.newPage();await pg.goto(url+addr);await pg.waitForSelector('#stage *');
     for(const [tab,role,pre] of [['clifford','orbit','Clifford'],['hopf','trail','Hopf']]){
       await pg.click('#tabs [data-v="'+tab+'"]');await pg.waitForTimeout(250);
       const r=await pg.evaluate(role=>{const svg=document.getElementById('stage'),Wd=svg.viewBox.baseVal.width;let maxSeg=0,n=0,pts=0,minPts=1e9;const per={};
         FVViews.layerRuns().filter(r=>r.role.startsWith(role)).forEach(pl=>{const a=pl.pts;per[pl.c]=(per[pl.c]||0)+a.length;   /* performance round: the run points live in the canvas layer record, the SVG polyline is a data-attribute stub */
           for(let i=1;i<a.length;i++)maxSeg=Math.max(maxSeg,Math.hypot(a[i][0]-a[i-1][0],a[i][1]-a[i-1][1]));});
         n=Object.keys(per).length;minPts=Math.min(...Object.values(per));return {n,maxSeg,Wd,pts,minPts,partial:!!document.querySelector('#stage [data-role="degenerate"]')};},role);
       ok(tag+' '+pre+' orbits at example state: teeth with an orbit drawn ('+r.n+'), each has >= 100 points in all its runs (min '+r.minPts+')',r.n>=6&&r.minPts>=100);
       ok(tag+' '+pre+' orbits at example state: longest drawn segment '+r.maxSeg.toFixed(2)+' <= 3% of view width ('+(0.03*r.Wd).toFixed(2)+')',r.maxSeg<=0.03*r.Wd);
       ok(tag+' '+pre+' orbits at example state: no "partial orbit" label',!r.partial);}
     await pg.close();}
    // ------------------------------------------------ v0.1.1: S3 orbit branches card, cyclotomic field line, Lift JSON branches, Hopf walk curves
    {
      const CC=require('../host-core/comb-core.js'),refAddr=CC.encodeAddress(CC.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'1',sTyped:'4/7',chart:'host',tab:'clifford'}));
      let ref=null;try{ref=JSON.parse(fs.readFileSync('C:/Users/robin/Downloads/fvlt_fourier_m7_fact-4-24_s0.5714285714285714_1791886895936.json','utf8'));}catch(e){}
      const canon=o=>JSON.stringify(o,(k,v)=>v&&typeof v==='object'&&!Array.isArray(v)?Object.fromEntries(Object.keys(v).sort().map(q=>[q,v[q]])):v);   // the page's JSON has sorted keys
      const pg=await ctx.newPage();await pg.goto(url+refAddr);await pg.waitForSelector('#stage *');await pg.waitForTimeout(250);
      const count=(sel)=>pg.locator(sel).count();
      const orbs=()=>pg.evaluate(()=>[...document.querySelectorAll('#stage rect[data-role="orbit"]')].map(p=>p.getAttribute('data-c')));
      const dots=()=>pg.evaluate(()=>[...new Set([...document.querySelectorAll('#stage circle[data-role="tooth-dot"]')].map(p=>p.getAttribute('data-c')))]);
      const hash=()=>pg.evaluate(()=>decodeURIComponent(location.hash));
      const pressed=()=>pg.evaluate(()=>[...document.querySelectorAll('#br_chips .chip')].map(b=>b.getAttribute('aria-pressed')==='true'));
      const chip=c=>pg.locator('#br_chips .chip[data-branch="'+c+'"]');
      await pg.click('#toolbar [data-menu="layers"]');await pg.waitForTimeout(60);
      ok(tag+' branch chips live in the Layers menu (Advanced): one chip per branch (7), count line, All and None buttons',(await count('#br_chips .chip'))===7&&(await pg.textContent('#br_count')).trim()==='7 of 7 shown'&&(await count('#br_toggle'))===1);
      const texts=await pg.evaluate(()=>[...document.querySelectorAll('#br_chips .chip')].map(b=>b.textContent.replace(/^[●○] /,'')));
      ok(tag+' branch chips read c · raw · primitive ×d · type (c = -3 and c = -2)',texts[0]==='c \u22123 \u00B7 raw (4,3) \u00B7 primitive (4,3) \u00D71 \u00B7 T(3,4)+'&&texts[1]==='c \u22122 \u00B7 raw (4,2) \u00B7 primitive (2,1) \u00D72 \u00B7 UNKNOT'&&texts[6]==='c +3 \u00B7 raw (4,\u22123) \u00B7 primitive (4,\u22123) \u00D71 \u00B7 T(3,4)\u2212',JSON.stringify(texts));
      ok(tag+' reference state: 7 s-orbits and 7 tooth dots drawn, one per branch',(await orbs()).length>=7&&new Set(await orbs()).size===7&&(await dots()).length===7);
      await pg.screenshot({path:path.join(root,'shot_'+tag+'_clifford_branches.png'),fullPage:true});
      // orbit colours match chip colours
      const col=await pg.evaluate(()=>{const rgb=s=>(s.match(/\d+(\.\d+)?/g)||[]).slice(0,3).map(Number).join(',');const o={};
        document.querySelectorAll('#stage rect[data-role="orbit"]').forEach(p=>{o[p.getAttribute('data-c')]=rgb(p.getAttribute('stroke'));});
        return [...document.querySelectorAll('#br_chips .chip')].map(b=>({c:b.getAttribute('data-branch'),chip:rgb(getComputedStyle(b).borderTopColor),orbit:o[b.getAttribute('data-branch')]}));});
      ok(tag+' orbit colour equals chip colour for every branch',col.length===7&&col.every(x=>x.chip===x.orbit),JSON.stringify(col.filter(x=>x.chip!==x.orbit)));
      // tap toggles
      await chip(2).click();await pg.waitForTimeout(150);
      const o1=await orbs(),d1=await dots();
      ok(tag+' tap chip c = 2 hides that s-orbit and tooth dot (6 left), chip unpressed, count 6 of 7',!o1.includes('2')&&o1.length>=6&&new Set(o1).size===6&&!d1.includes('2')&&d1.length===6&&(await pressed())[5]===false&&(await pg.textContent('#br_count')).trim()==='6 of 7 shown');
      ok(tag+' branch visibility is in the URL address (view key ch)',(await hash()).includes('ch=h:2'),await hash());
      await chip(2).click();await pg.waitForTimeout(150);
      ok(tag+' tap again shows it; address returns to no ch',new Set(await orbs()).size===7&&!(await hash()).includes('ch='));
      await pg.click('#br_toggle');await pg.waitForTimeout(150);
      ok(tag+' None hides every orbit and dot (0 drawn), all chips unpressed',(await orbs()).length===0&&(await dots()).length===0&&(await pressed()).every(x=>!x)&&(await hash()).includes('ch=v:'));
      await pg.click('#br_toggle');await pg.waitForTimeout(150);
      ok(tag+' toggle again (All) shows every branch (7 orbits, 7 dots)',new Set(await orbs()).size===7&&(await dots()).length===7&&(await pressed()).every(x=>x));
      await chip(-3).click({modifiers:['Shift']});await pg.waitForTimeout(150);
      ok(tag+' shift-click isolates: only c = -3 drawn, address shows ch=v:-3',JSON.stringify([...new Set(await orbs())])==='["-3"]'&&JSON.stringify(await dots())==='["-3"]'&&(await hash()).includes('ch=v:-3'));
      await pg.click('#br_toggle');await pg.waitForTimeout(100);
      // long-press isolates
      {const bb=await chip(1).boundingBox();await pg.mouse.move(bb.x+bb.width/2,bb.y+bb.height/2);await pg.mouse.down();await pg.waitForTimeout(800);await pg.mouse.up();await pg.waitForTimeout(200);
       ok(tag+' long-press isolates c = 1 (and the release does not toggle it back)',JSON.stringify([...new Set(await orbs())])==='["1"]'&&(await pressed()).filter(x=>x).length===1&&(await hash()).includes('ch=v:1'),JSON.stringify(await orbs())+' '+await hash());}
      // reload from the address restores the visibility
      const hv=await pg.evaluate(()=>location.hash);await pg.goto(url+hv);await pg.reload();await pg.waitForSelector('#stage *');await pg.waitForTimeout(250);
      await pg.click('#toolbar [data-menu="layers"]');await pg.waitForTimeout(60);
      ok(tag+' reloading the address restores the branch visibility (only c = 1)',JSON.stringify([...new Set(await orbs())])==='["1"]'&&(await pressed()).filter(x=>x).length===1);
      await pg.click('#br_toggle');await pg.waitForTimeout(100);
      // chips only on the Clifford tab
      await pg.click('#tabs [data-v="fourier"]');await pg.waitForTimeout(150);
      await pg.click('#toolbar [data-menu="layers"]');await pg.waitForTimeout(60);
      ok(tag+' branch chips are offered on the Clifford tab only (none in the Fourier Layers menu)',(await pg.locator('#br_chips').count())===0&&(await pg.locator('#menu [data-v="teeth"]').count())===1);
      // cyclotomic field line in the Phasors card
      const fl=await pg.textContent('[data-role="field"]');
      ok(tag+' Phasors card shows the field line (reference state)',fl.trim()==='generated by the phase factors \u211A(\u03B6\u2081\u2084) \u00B7 phase container (convention) \u211A(\u03B6\u2085\u2086) (exact)',fl);
      // exact JSON carries no branch visibility; Lift JSON has branches under schema 0.2
      await pg.click('#tabs [data-v="clifford"]');await pg.waitForTimeout(100);await pg.click('#toolbar [data-menu="layers"]');await pg.waitForTimeout(60);
      await chip(0).click();await pg.waitForTimeout(100);
      await expOpen(pg);await pg.click('[data-act="xjson"]');await pg.waitForTimeout(250);
      const xj=await pg.inputValue('#xout');
      ok(tag+' exact JSON has no view or branch visibility',!xj.includes('"view"')&&!xj.includes('ch='));
      await expOpen(pg);await pg.click('[data-act="xlift"]');await pg.waitForTimeout(250);
      const lj=JSON.parse(await pg.inputValue('#xout'));
      ok(tag+' Lift JSON cyclotomic_field: generated Q(zeta_14), phase_container Q(zeta_56), host_ambient_equivalent true',lj.cyclotomic_field&&lj.cyclotomic_field.generated==='\u211A(\u03B6_14)'&&lj.cyclotomic_field.phase_container==='\u211A(\u03B6_56)'&&lj.cyclotomic_field.host_ambient_equivalent===true,JSON.stringify(lj.cyclotomic_field));
      ok(tag+' Lift JSON schema is fv-comb-hopf-lift/0.3 with branches[7]',lj.schema==='fv-comb-hopf-lift/0.3'&&Array.isArray(lj.branches)&&lj.branches.length===7&&lj.teeth.length===7);
      ok(tag+' Lift JSON branches equal the old viewer exactRationalLift.branches (c as string); independent of branch visibility',ref!==null&&canon(lj.branches)===canon(ref.exactRationalLift.branches.map(b=>({...b,c:String(b.c)}))));
      await pg.close();
      // Hopf comb-walk: true curves
      const ex=CC.encodeAddress(CC.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'0',sTyped:'408/125',chart:'host',tab:'hopf'}));
      const hp=await ctx.newPage();await hp.goto(url+ex);await hp.waitForSelector('#stage rect');await hp.waitForTimeout(250);
      const wk=await hp.evaluate(()=>{const svg=document.getElementById('stage'),Wd=svg.viewBox.baseVal.width;let pts=0,maxSeg=0,n=0;
        FVViews.layerRuns().filter(r=>r.role==='walk').forEach(pl=>{n++;const a=pl.pts;pts+=a.length;for(let i=1;i<a.length;i++)maxSeg=Math.max(maxSeg,Math.hypot(a[i][0]-a[i-1][0],a[i][1]-a[i-1][1]));});
        return {n,pts,maxSeg,Wd};});
      ok(tag+' Hopf comb walk: 7 edges sampled as curves (>= 7*33 points, '+wk.pts+'), longest drawn segment '+wk.maxSeg.toFixed(2)+' <= 2 degrees of the sphere radius (7 view units)',wk.pts>=7*33&&wk.maxSeg<=7,JSON.stringify(wk));
      await hp.close();
      // pole-break state (huge amplitude, chart w = W): renders without error, labelled
      const big=CC.encodeAddress(CC.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'8',alpha:'8',sTyped:'408/125',chart:'host',tab:'hopf'}));
      const bp=await ctx.newPage(),berr=[];bp.on('pageerror',e=>berr.push(String(e)));bp.on('console',m=>{if(m.type()==='error')berr.push(m.text());});
      await bp.goto(url+big);await bp.waitForSelector('#stage rect');await bp.waitForTimeout(300);
      ok(tag+' Hopf walk at a near-pole state (rho = 524288, chart w = W): renders, no errors',berr.length===0&&(await bp.locator('#stage rect[data-role="walk"]').count())>=1,berr.join('|'));
      await bp.close();
    }
    // ------------------------------------------------ v0.2 Release A: layout order and the phone stack (addendum 6)
    {
      const lp=await ctx.newPage();await lp.goto(url);await lp.waitForSelector('#stage *');await lp.waitForTimeout(300);
      const g=await lp.evaluate(()=>{const r=id=>{const e=document.getElementById(id),b=e.getBoundingClientRect();return {x:b.x,y:b.y+scrollY,w:b.width,h:b.height,r:b.right,b:b.bottom+scrollY};};
        return {header:document.querySelector('.header').getBoundingClientRect().bottom+scrollY,shell:r('shellrow'),gear:r('gearrow'),tabs:r('tabs'),frame:r('frame'),toolbar:r('toolbar'),phi:r('phirow'),s:r('srow'),transport:r('transport'),exports:r('exports'),cards:r('cards'),inst:r('inst'),
          title:!!document.querySelector('h1'),formula:document.getElementById('formula').textContent};});
      const seq=['header','shell','gear','tabs','frame','toolbar','phi','s','transport','exports'];
      const bot=k=>k==='header'?g.header:g[k].b;const inOrder=seq.every((k,i)=>i===0||bot(seq[i-1])<=g[k].y+1.5);
      ok(tag+' order: header, shell row, gearbox row, view row, view frame, strip, phi3 row, s row, transport, exports (top to bottom)',inOrder,JSON.stringify(seq.map(k=>[k,Math.round(typeof g[k]==='number'?g[k]:g[k].y)])));
      ok(tag+' header is the title plus one live-formula line z_c = n6*N^alpha*exp(i*k_c*s*pi/N)',g.title&&g.formula==='z_c = n₆·N^α·exp(i·k_c·s·π/N)',g.formula);
      if(w>=861){
        ok(tag+' desktop: cards in a right column of about 380 px beside the instrument panel',g.cards.x>=g.inst.r-1&&g.cards.w>=370&&g.cards.w<=392&&g.cards.y<=g.inst.y+2,JSON.stringify(g.cards)+' inst r '+g.inst.r);
        ok(tag+' desktop: the view sits in the middle of the instrument panel',Math.abs((g.frame.x+g.frame.w/2)-(g.inst.x+g.inst.w/2))<=8,'frame centre '+Math.round(g.frame.x+g.frame.w/2)+' panel centre '+Math.round(g.inst.x+g.inst.w/2));
      }else{
        ok(tag+' phone: cards below the instrument (after the exports), one column',g.cards.y>=g.inst.b-1&&g.cards.w>=g.inst.w-4,JSON.stringify(g.cards));
      }
      // Lift JSON 0.2: N = 0 keeps schema, branches (undefined, never omitted) and the cyclotomic status; fractional k_c carries C = 2qN*L_k
      await lp.evaluate(()=>FVPanel.dial({shellMode:'integer',B:'24',phi3:'25',m:'3'}));await lp.waitForTimeout(80);
      await expOpen(lp);await lp.click('#expmenu [data-act="xlift"]');await lp.waitForTimeout(150);
      {const l0=JSON.parse(await lp.inputValue('#xout'));
       ok(tag+' Lift JSON at N = 0: schema 0.3, 3 undefined branches, cyclotomic status, no teeth',l0.schema==='fv-comb-hopf-lift/0.3'&&l0.branches.length===3&&l0.branches.every(b=>b.knot_class==='UNDEFINED')&&!!l0.cyclotomic_field.status&&l0.teeth.length===0,JSON.stringify(l0).slice(0,200));}
      await lp.evaluate(()=>FVPanel.dial({phi3:'21',t1:'1/3',sTyped:'3/5'}));await lp.evaluate(()=>FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'3/5')));await lp.waitForTimeout(80);
      await lp.click('#expmenu [data-act="xlift"]');await lp.waitForTimeout(150);
      {const l1=JSON.parse(await lp.inputValue('#xout')),cf=l1.cyclotomic_field;
       ok(tag+' Lift JSON with fractional k_c (N = 4, t1 = 1/3, s = 3/5): phase_container C = 2qN*L_k = 120, host_ambient_equivalent false, branches carry k_c as rationals',cf.phase_container_n==='120'&&cf.k_denominator_lcm==='3'&&cf.host_ambient_equivalent===false&&l1.branches.every(b=>b.frequency_integral===false),JSON.stringify(cf));}
      await lp.evaluate(()=>FVPanel.dial({shellMode:'factorial',n1:'4',phi3:'23',m:'2',t1:'1'}));await lp.evaluate(()=>FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'1')));await lp.click('#expBtn');await lp.waitForTimeout(60);
      // Export menu: PNG one tap, everything else behind Export ▾; Copy formula replaces any Wolfram link
      ok(tag+' export row: only Export PNG and Export ▾ visible by default; the menu is closed',(await lp.locator('#exports button:visible').count())===2&&!(await lp.locator('#expmenu').isVisible()));
      await lp.click('#expBtn');await lp.waitForTimeout(40);
      ok(tag+' Export ▾ holds JSON, state, CSV, Lift JSON, pair, copy stats, copy formula, import',(await lp.locator('#expmenu > button').count())===8&&(await lp.locator('#expmenu [data-act="xformula"]').count())===1);
      await lp.click('#expmenu [data-act="xformula"]');await lp.waitForTimeout(150);
      const fx=await lp.inputValue('#xout');
      ok(tag+" Copy formula writes the live formula as text (symbolic line plus the current values)",fx==="z_c = n6*N^alpha*exp(i*k_c*s*pi/N), k_c = N*t1 + c*t2\nwith n6 = 1, alpha = 1, N = 2, t1 = 1, t2 = 1, s = 1, m = 2\n",JSON.stringify(fx));
      ok(tag+' no Wolfram link or text anywhere on the page',(await lp.locator('a').count())===0&&!/wolfram/i.test(await lp.evaluate(()=>document.documentElement.outerHTML.replace(/<script[\s\S]*?<\/script>/g,''))));
      await lp.click('#expBtn');await lp.waitForTimeout(40);
      // Layers and Camera menus (all three drawing views)
      ok(tag+' menus closed by default; strip has Layers, Camera, zoom + - reset, full view, info',(await lp.locator('#menu .menu').count())===0&&(await lp.locator('#toolbar [data-menu]').count())===2&&(await lp.locator('#toolbar [data-v="zin"],#toolbar [data-v="zout"],#toolbar [data-v="reset"],#toolbar [data-v="full"],#toolbar [data-v="about"]').count())===5);
      await lp.click('#toolbar [data-menu="layers"]');await lp.waitForTimeout(50);
      ok(tag+' Fourier Layers menu: Teeth, Walk, Amber polygon, Divisors',(await lp.locator('#menu .menu [data-act="vtool"]').count())===4);
      await lp.click('#toolbar [data-menu="camera"]');await lp.waitForTimeout(50);
      ok(tag+' one menu at a time: Camera replaces Layers; Fourier Camera has the zoom lock',(await lp.locator('#menu_layers').count())===0&&(await lp.locator('#menu_camera [data-v="lock"]').count())===1);
      await lp.click('#toolbar [data-menu="camera"]');await lp.waitForTimeout(50);
      await lp.click('#tabs [data-v="clifford"]');await lp.waitForTimeout(150);
      await lp.click('#toolbar [data-menu="camera"]');await lp.selectOption('#menu select[data-vsel="cam"]','xp');await lp.waitForTimeout(100);
      ok(tag+' Clifford Camera select: Side X+ sets the azimuth to pi/2 and elevation 0',await lp.evaluate(()=>{const v=Object.fromEntries(FVPanel.state.view.split(';').filter(Boolean).map(x=>x.split('=')));return Math.abs(+v.ca-Math.PI/2)<1e-3&&+v.ce===0;}));
      ok(tag+' Camera select has the seven presets',(await lp.locator('#menu select[data-vsel="cam"] option:not([value=""])').count())===7);
      await lp.click('#toolbar [data-menu="layers"]');await lp.selectOption('#menu select[data-vsel="guides"]','g_four');await lp.waitForTimeout(100);
      ok(tag+' Clifford Guides select: four circles drawn and its swatches shown',(await lp.locator('#stage [data-role^="circle-"]').count())===4&&(await lp.locator('#menu .mi .sws i').count())===4);
      await lp.selectOption('#menu select[data-vsel="guides"]','g_none');await lp.waitForTimeout(100);
      ok(tag+' Guides none: no circles, no swatches; layer swatches only on pressed layers',(await lp.locator('#stage [data-role^="circle-"]').count())===0&&(await lp.locator('#menu button[aria-pressed="true"] .sws').count())===3);
      await lp.click('#tabs [data-v="hopf"]');await lp.waitForTimeout(150);
      await lp.click('#toolbar [data-menu="camera"]');await lp.selectOption('#menu select[data-vsel="from"]','q1+');await lp.waitForTimeout(100);
      ok(tag+' Hopf View-from select q1+ sets the azimuth',await lp.evaluate(()=>/ha=1\.5708/.test(FVPanel.state.view)));
      await lp.click('#toolbar [data-menu="layers"]');await lp.click('#menu [data-v="trails"]');await lp.waitForTimeout(100);
      ok(tag+' Hopf Layers: tooth trails switch off (none drawn); chart toggle sits under Advanced',(await lp.locator('#stage rect[data-role^="trail"]').count())===0&&(await lp.locator('#menu [data-v="chart"]').count())===1);
      await lp.click('#tabs [data-v="fourier"]');await lp.waitForTimeout(150);
      // gearbox chips with drawers: five chips, lanes deleted
      ok(tag+' gearbox (addendum 7 F1): five chips, each ONE button "label value"; t1 and t2 keep their minus/plus beside the chip; no input in the chip row; no Presets/Continuous switch',
        (await lp.locator('#chips5 .glab').count())===5&&(await lp.locator('#chips5 input').count())===0&&(await lp.locator('#chips5 button').count())===9
        &&(await lp.locator('#chip_t1 [data-act="t1dn"],#chip_t1 [data-act="t1up"],#chip_t2 [data-act="t2dn"],#chip_t2 [data-act="t2up"]').count())===4&&(await lp.locator('#rad_p,#rad_c').count())===0);
      ok(tag+' chip row reads alpha 1, n6 1, t1 1, t2 1, m 2 at the default state',JSON.stringify(await lp.evaluate(()=>[...document.querySelectorAll('#chips5 .glab')].map(b=>b.textContent)))===JSON.stringify(['\u03B1 1','n\u2086 1','t\u2081 1','t\u2082 1','m 2']));
      ok(tag+' drawers closed by default (no slider in the gearbox area)',(await lp.locator('#drawer input').count())===0);
      for(const [k,exp] of [['alpha','presets+slider'],['n6','presets+slider'],['t1','delta+slider'],['t2','delta+slider'],['m','slider']]){
        await lp.click('#lab_'+k);await lp.waitForTimeout(60);
        const d=await lp.evaluate(()=>({sl:document.querySelectorAll('#drawer input[type=range]').length,pre:document.querySelectorAll('#drawer [data-act$="p"][data-v]').length,dl:document.querySelectorAll('#drawer select').length,box:document.querySelectorAll('#drawer input[type=text]').length,steppers:document.querySelectorAll('#drawer [data-act$="dn"],#drawer [data-act$="up"]').length}));
        ok(tag+' drawer '+k+' opens with its '+exp,d.sl===1&&d.box===1&&d.steppers===(k==='t1'||k==='t2'?0:2)&&(k==='alpha'||k==='n6'?d.pre===3:k==='t1'||k==='t2'?d.dl===1:true),JSON.stringify(d));}
      await lp.click('#lab_m');await lp.waitForTimeout(60);
      ok(tag+' drawer closes when its label is tapped again',(await lp.locator('#drawer input').count())===0);
      await lp.evaluate(()=>FVPanel.dial({alpha:'1',n6:'1',t1:'1',t2:'1',m:'2'}));await lp.waitForTimeout(60);
      await lp.click('#lab_alpha');await lp.click('#drawer [data-act="alphaup"]');await lp.click('#lab_m');await lp.click('#drawer [data-act="mup"]');await lp.click('#lab_m');await lp.click('#chip_t1 [data-act="t1up"]');await lp.waitForTimeout(80);
      const sv=await lp.evaluate(()=>({a:FVPanel.state.alpha,t1:FVPanel.state.t1,m:FVPanel.state.m}));
      ok(tag+' steppers: alpha +1 and m +1 (in their drawers), t1 + delta (1/4 by default, beside the chip)',sv.a==='2'&&sv.t1==='5/4'&&sv.m==='3',JSON.stringify(sv));
      await lp.evaluate(()=>FVPanel.dial({t1:'1',m:'2',alpha:'1'}));
      await lp.click('#lab_alpha');await lp.click('#drawer [data-act="alphap"][data-v="-1"]');await lp.waitForTimeout(60);
      ok(tag+' alpha drawer preset -1 sets alpha',(await lp.evaluate(()=>FVPanel.state.alpha))==='-1');
      await lp.evaluate(()=>FVPanel.dial({alpha:'1'}));await lp.click('#lab_alpha');
      await lp.close();
    }
    // ------------------------------------------------ v0.2 Release A fix round (addendum 7)
    {
      const CC=require('../host-core/comb-core.js');
      const addrOf=(o)=>CC.encodeAddress(CC.initial(o));
      const refO={shellMode:'factorial',n1:'4',phi3:'21',m:'7',t1:'1',t2:'1',n6:'1',alpha:'1',sTyped:'4/7',chart:'host'};
      const open=async(o)=>{const pg=await ctx.newPage();await pg.goto(url+addrOf(o));await pg.waitForSelector('#stage *',{state:'attached'});await pg.waitForTimeout(300);return pg;};
      const capInfo=pg=>pg.evaluate(()=>[...document.querySelectorAll('#caption p')].map(p=>{const lh=parseFloat(getComputedStyle(p).lineHeight);return {lines:Math.round(p.getBoundingClientRect().height/lh),trunc:p.scrollWidth>p.clientWidth,text:p.textContent};}));
      // F2: one caption line per drawing, at every width, default state and reference state, every tab, fraction stack on
      for(const [lab,base] of [['default',{}],['reference',refO]]){
        for(const tab of ['fourier','clifford','hopf']){
          const pg=await open({...base,tab});const ci=await capInfo(pg);
          ok(tag+' F2 caption is exactly one line ('+lab+' state, '+tab+'): '+ci.map(c=>c.lines+(c.trunc?' (ellipsis)':'')).join(', '),ci.length>=1&&ci.every(c=>c.lines===1),JSON.stringify(ci));
          if(ci.some(c=>c.trunc)){
            await pg.click('#caption p');await pg.waitForTimeout(60);const c2=await capInfo(pg);
            ok(tag+' F2 tapping a truncated caption expands it ('+lab+', '+tab+'): '+c2.map(c=>c.lines).join(', ')+' lines',c2.some(c=>c.lines>1)&&(await pg.getAttribute('#caption p','aria-expanded'))==='true');
            await pg.click('#caption p');await pg.waitForTimeout(60);
            ok(tag+' F2 tapping again collapses it to one line ('+lab+', '+tab+')',(await capInfo(pg)).every(c=>c.lines===1));
          }
          await pg.close();}}
      {const pg=await open({...refO,tab:'clifford',view:'cf=1'});const ci=await capInfo(pg);
       ok(tag+' F2 Clifford with the fraction stack on: every caption paragraph is one line ('+ci.length+' paragraphs)',ci.length>=2&&ci.every(c=>c.lines===1),JSON.stringify(ci));await pg.close();}
      // F8: the text-size readout never wraps
      {const pg=await open({});const r=await pg.evaluate(()=>{const e=document.getElementById('sizeVal'),lh=parseFloat(getComputedStyle(e).lineHeight);return {lines:Math.round(e.getBoundingClientRect().height/lh),w:e.getBoundingClientRect().width,txt:e.textContent};});
       ok(tag+' F8 the text-size readout "'+r.txt+'" is one line',r.lines===1,JSON.stringify(r));
       for(let i=0;i<6;i++)await pg.click('#sizeUp');const r2=await pg.evaluate(()=>{const e=document.getElementById('sizeVal'),lh=parseFloat(getComputedStyle(e).lineHeight);return {lines:Math.round(e.getBoundingClientRect().height/lh),txt:e.textContent};});
       ok(tag+' F8 the readout stays one line at 160% ("'+r2.txt+'")',r2.lines===1,JSON.stringify(r2));
       for(let i=0;i<6;i++)await pg.click('#sizeDn');await pg.waitForTimeout(100);await pg.close();}   // restore 100% (the scale is kept in localStorage for this browser context)
      // F3, F4: each value shown once (reference state: N = 4, s = 4/7, spread t2*s/N = 1/7)
      {const pg=await open({...refO,tab:'fourier'});
       const tx=sel=>pg.evaluate(sel=>document.querySelector(sel).innerText,sel);
       const body=await tx('body'),cards=await tx('#cards'),cap=await tx('#caption'),shell=await tx('#shellrow');
       ok(tag+' F3 N is shown once on the surface: the shell-row readout "B = ... N = 4" ('+(body.match(/N = 4(?!\d)/g)||[]).length+' occurrences of "N = 4" in the page text)',(body.match(/N = 4(?!\d)/g)||[]).length===1&&/N = 4/.test(shell),shell);
       ok(tag+' F3 the cards show no N row (Shell card), no "Shell N =" in the Wilson card, and no N in the field line',!/Shell N =/.test(cards)&&!/q = 7, N = 4/.test(body));
       ok(tag+' F3 Q-res and the ALIGN / SPREAD flags are in the Fourier caption and not in the cards',/Q-res/.test(cap)&&/ALIGN/.test(cap)&&/SPREAD/.test(cap)&&!/Q-res|Q-residual/.test(cards)&&!/ALIGN|SPREAD/.test(cards),cap);
       ok(tag+' F3 the spread t\u2082\u00B7s/N appears once, as the flag line of the card (spread t\u2082\u00B7s/N (exact) = 1/7)',(cards.match(/spread t\u2082\u00B7s\/N/g)||[]).length===1&&/spread t\u2082\u00B7s\/N \(exact\)\s*1\/7/.test(cards)&&!/Current \u03B2\/\u03C0/.test(cards)&&!/Current \u03B2\/\u03C0/.test(body),cards.slice(0,400));
       // F4: the K_m kernel line is behind the Phasors (i)
       ok(tag+' F4 the K_m kernel line is not on the surface',!/K.?m\(\u03B2\)/.test(body)&&!/sin\(m\u03B2/.test(body));
       const btn=pg.locator('#cards section:has(.panel-label:text-is("Phasors")) button.info');await btn.click();await pg.waitForTimeout(60);
       const ab=await pg.evaluate(()=>document.querySelector('#cards section .about').textContent);
       ok(tag+' F4 the Phasors (i) holds the kernel K_m(\u03B2) = sin(m\u03B2/2)/sin(\u03B2/2) (odd m) and its zeros',/K_m\(\u03B2\) = sin\(m\u03B2\/2\)\/sin\(\u03B2\/2\)/.test(ab)&&/SPREAD stops/.test(ab),ab.slice(0,200));
       // F7: the field definitions, behind the same (i)
       ok(tag+' F7 the (i) defines generated by the phase factors \u211A(\u03B6_L) and phase container (convention) \u211A(\u03B6_C) with C = 2\u00B7q\u00B7N\u00B7L_k, L_k, the (1/L_k)\u2124 container, L_k = 1 equals the host ambient, reference values',
         /generated by the phase factors \u211A\(\u03B6_L\): L = lcm/.test(ab)&&/phase container \(convention\) \u211A\(\u03B6_C\)/.test(ab)&&/C = 2\u00B7q\u00B7N\u00B7L_k/.test(ab)&&/L_k is the lcm of the denominators of the k_c/.test(ab)&&/\(1\/L_k\)\u2124/.test(ab)&&/host_ambient_equivalent: true/.test(ab)&&/q = 7, L_k = 1, C = 56/.test(ab),ab);
       // F7: labels at the reference state (generated Q(zeta_14), container Q(zeta_56)), L_k = 1
       const fl=await tx('[data-role="field"]');
       ok(tag+' F7 reference state: field line says generated by the phase factors \u211A(\u03B6\u2081\u2084), phase container (convention) \u211A(\u03B6\u2085\u2086)',fl.trim()==='generated by the phase factors \u211A(\u03B6\u2081\u2084) \u00B7 phase container (convention) \u211A(\u03B6\u2085\u2086) (exact)',fl);
       await pg.close();}
      // F7 on a fractional-k_c case: N = 4, t1 = 1/3, m = 3, s = 3/5: generated Q(zeta_40), L_k = 3, container Q(zeta_120) = 2*5*4*3
      {const pg=await open({...refO,m:'3',t1:'1/3',sTyped:'3/5',tab:'fourier'});
       const fl=await pg.evaluate(()=>document.querySelector('[data-role="field"]').innerText);
       ok(tag+' F7 fractional k_c (t1 = 1/3, N = 4, s = 3/5): generated by the phase factors \u211A(\u03B6\u2084\u2080), phase container (convention) \u211A(\u03B6\u2081\u2082\u2080)',fl.trim()==='generated by the phase factors \u211A(\u03B6\u2084\u2080) \u00B7 phase container (convention) \u211A(\u03B6\u2081\u2082\u2080) (exact)',fl);
       await pg.click('#cards section:has(.panel-label:text-is("Phasors")) button.info');await pg.waitForTimeout(60);
       const ab=await pg.evaluate(()=>document.querySelector('#cards section .about').textContent);
       ok(tag+' F7 fractional k_c: the (i) states q = 5, L_k = 3, C = 120',/q = 5, L_k = 3, C = 120/.test(ab),ab.slice(-200));
       // F6 gates, page level: fractional t1 -> integral_frequencies FAIL, closed_orbits PASS
       await expOpen(pg);await pg.click('#expmenu [data-act="xlift"]');await pg.waitForTimeout(150);
       const lj=JSON.parse(await pg.inputValue('#xout')),g=lj.gates;
       ok(tag+' F6 Lift JSON gates at t1 = 1/3 (N = 4, m = 3): exact_rational_lift PASS, closed_orbits PASS, integral_frequencies FAIL listing -1,0,1; prime_pair SEPARATE_GATE; rank4 OUT_OF_SCOPE',
         g.exact_rational_lift.status==='PASS'&&g.closed_orbits.status==='PASS'&&g.integral_frequencies.status==='FAIL'&&g.integral_frequencies.failing.join()==='-1,0,1'&&g.prime_pair.status==='SEPARATE_GATE'&&g.rank4_smith_monodromy.status==='OUT_OF_SCOPE',JSON.stringify(g));
       await pg.close();}
      {const pg=await open({...refO,tab:'fourier'});await expOpen(pg);await pg.click('#expmenu [data-act="xlift"]');await pg.waitForTimeout(150);
       const g=JSON.parse(await pg.inputValue('#xout')).gates;
       ok(tag+' F6 Lift JSON gates at the reference state: exact_rational_lift PASS, closed_orbits PASS, integral_frequencies PASS (all three computed gates pass)',g.exact_rational_lift.status==='PASS'&&g.closed_orbits.status==='PASS'&&g.integral_frequencies.status==='PASS'&&g.integral_frequencies.failing.length===0,JSON.stringify(g));
       ok(tag+' F6 the two outside gates carry their reasons',g.prime_pair.reason==='requires integral selected frequencies and independent primality evidence'&&g.rank4_smith_monodromy.reason==='Rank-4 monodromy has its own viewer (saphir, 2026-10-13)');
       await pg.close();}
      {const pg=await open({...refO,t1:'0',t2:'0',m:'3',tab:'fourier'});await expOpen(pg);await pg.click('#expmenu [data-act="xlift"]');await pg.waitForTimeout(150);
       const g=JSON.parse(await pg.inputValue('#xout')).gates;
       ok(tag+' F6 Lift JSON gates at t1 = t2 = 0: closed_orbits FAIL listing -1,0,1 (every branch stationary), integral_frequencies PASS (k_c = 0)',g.closed_orbits.status==='FAIL'&&g.closed_orbits.failing.join()==='-1,0,1'&&g.integral_frequencies.status==='PASS',JSON.stringify(g));
       await pg.close();}
      // Sol's condition: a caption ellipsis never hides a warning (refusal, degenerate case, gate failure, unavailable stepping)
      {const pg=await open({...refO,phi3:'25',tab:'fourier'});
       const r=await pg.evaluate(()=>{const ps=[...document.querySelectorAll('#caption p')].map(p=>({cls:p.className,trunc:p.scrollWidth>p.clientWidth,h:p.getBoundingClientRect().height,lh:parseFloat(getComputedStyle(p).lineHeight),t:p.textContent}));return ps;});
       ok(tag+' warnings: N = 0 (degenerate) shows its full text in a caption line with no ellipsis, none truncated',r.length>=1&&r.some(p=>/N = 0/.test(p.t)&&/empty state, drawn and labelled/.test(p.t))&&r.every(p=>p.cls.indexOf('ell')<0&&!p.trunc),JSON.stringify(r));
       await pg.close();}
      {const pg=await open({...refO,t1:'0',m:'3',tab:'fourier'});await pg.click('[data-act="sup"]',{force:true});await pg.waitForTimeout(100);
       const r=await pg.evaluate(()=>{const e=document.querySelector('#s_read [data-role="step-refusal"]');if(!e)return null;const b=e.getBoundingClientRect();return {t:e.textContent,trunc:e.scrollWidth>e.clientWidth,vis:b.width>0&&b.height>0,inViewport:b.right<=innerWidth+1,ell:getComputedStyle(e.parentElement).textOverflow};});
       ok(tag+' warnings: a stepping refusal (t1 = 0, m = 3) is shown in full, visible, not truncated, outside the (i)',!!r&&/refused/.test(r.t)&&r.vis&&!r.trunc&&r.inViewport&&r.ell!=='ellipsis',JSON.stringify(r));
       await pg.close();}
      // fix round 2: stationary teeth are a degenerate case shown on the surface (F-R2-1)
      for(const tb of ['clifford','hopf']){
       const pg=await open({...refO,t1:'0',m:'3',tab:tb});
       const r=await pg.evaluate(()=>{const e=[...document.querySelectorAll('#caption p[data-role="degenerate"]')].find(p=>/stationary/.test(p.textContent));if(!e)return null;const b=e.getBoundingClientRect();return {t:e.textContent,cls:e.className,trunc:e.scrollWidth>e.clientWidth,vis:b.width>0&&b.height>0,inViewport:b.right<=innerWidth+1,ell:getComputedStyle(e).textOverflow};});
       ok(tag+' F-R2-1 '+tb+': stationary teeth (t1 = 0, m = 3) show "stationary: c = ... (no orbit|trail)" on the warning line, full, visible, not ellipsized',!!r&&/^stationary: c = 0 \(no (orbit|trail)\)$/.test(r.t)&&r.vis&&!r.trunc&&r.inViewport&&r.ell!=='ellipsis'&&r.cls.indexOf('ell')<0,JSON.stringify(r));
       await pg.close();}
      // fix round 2026-10-14: base-fixed teeth (k_c = 0, lifted rate nonzero) and the even-kernel caption
      for(const tb of ['clifford','hopf']){
       const pg=await open({shellMode:'integer',B:'2',phi3:'1',m:'2',t1:'1',t2:'2',n6:'1',alpha:'0',sTyped:'1',chart:'host',tab:tb});
       const r=await pg.evaluate(()=>[...document.querySelectorAll('#caption p[data-role="degenerate"]')].map(p=>p.textContent));
       const want=tb==='hopf'?'base fixed: c = -1 (k_c = 0; the fiber moves — see Clifford)':'base fixed: c = -1 (k_c = 0; orbit runs along the Hopf fiber)';
       ok(tag+' fix 2026-10-14 '+tb+': N = 2, m = 2, t1 = 1, t2 = 2 shows the base-fixed caption and no stationary caption',r.includes(want)&&!r.some(t=>/^stationary/.test(t)),JSON.stringify(r));
       await pg.close();}
      for(const [nm,o,even] of [['even m = 4',{m:'4'},true],['odd m = 7',{m:'7'},false]]){
       const pg=await open({...refO,...o,tab:'fourier'});
       await pg.locator('#cards section:has(.panel-label:text-is("Phasors")) button.info').click();await pg.waitForTimeout(60);
       const ab=await pg.evaluate(()=>[...document.querySelectorAll('#cards section')].find(s=>/Phasors/.test(s.querySelector('.panel-label').textContent)).querySelector('.about').textContent);
       ok(tag+' fix 2026-10-14 Phasors (i) kernel zeros: '+nm+(even?' says e^{2iβ} ∈':' says e^{iβ} ∈ and not e^{2iβ}'),even?ab.includes("e^{2iβ} ∈ μ_m"):(ab.includes("e^{iβ} ∈ μ_m")&&!ab.includes("e^{2iβ}")),ab.slice(0,300));
       await pg.close();}
      // fix round 2: stepping state shown before any press (F-R2-2)
      for(const [nm,o] of [['t1 = 0, m = 3',{t1:'0',m:'3'}],['t1 = t2 = 0, m = 4',{t1:'0',t2:'0',m:'4'}],['non-integer gear t2 = 1/2',{t2:'1/2',m:'5'}],['N = 0',{phi3:'25'}]]){
       const pg=await open({...refO,...o,tab:'fourier'});
       const r=await pg.evaluate(()=>{const e=document.querySelector('#s_read [data-role="step-unavailable"]'),bs=['sdn','sup'].map(a=>document.querySelector('#srow [data-act="'+a+'"]'));const b=e&&e.getBoundingClientRect();return {t:e&&e.textContent,vis:!!b&&b.width>0&&b.height>0,trunc:!!e&&e.scrollWidth>e.clientWidth,inViewport:!!b&&b.right<=innerWidth+1,ad:bs.map(x=>x.getAttribute('aria-disabled')),op:bs.map(x=>getComputedStyle(x).opacity),dis:bs.map(x=>x.disabled)};});
       ok(tag+' F-R2-2 ('+nm+'): before any press, "stepping unavailable — <reason>" is on the surface and both arrows look disabled',!!r.t&&/^stepping unavailable — .+/.test(r.t)&&r.vis&&!r.trunc&&r.inViewport&&r.ad.every(x=>x==='true')&&r.op.every(x=>parseFloat(x)<1),JSON.stringify(r));
       const before=await pg.evaluate(()=>JSON.stringify(FVPanel.state));await pg.click('[data-act="sup"]',{force:true});await pg.waitForTimeout(80);
       const after=await pg.evaluate(()=>({st:JSON.stringify(FVPanel.state),ref:!!document.querySelector('#s_read [data-role="step-refusal"]')}));
       ok(tag+' F-R2-2 ('+nm+'): pressing still gives the R20 refusal and leaves the state unchanged',after.ref&&after.st===before,after.st.slice(0,160));
       await pg.close();}
      {const pg=await open({...refO,tab:'fourier'});
       const r=await pg.evaluate(()=>({u:!!document.querySelector('[data-role="step-unavailable"]'),ad:['sdn','sup'].map(a=>document.querySelector('#srow [data-act="'+a+'"]').getAttribute('aria-disabled'))}));
       ok(tag+' F-R2-2 reference state: no unavailable line and arrows enabled',!r.u&&r.ad.every(x=>x==='false'),JSON.stringify(r));await pg.close();}
      // fix round 2: the exact flags come first in the Fourier caption and are visible without a tap (SPREAD on the phone)
      {const pg=await open({...refO,tab:'fourier'});
       const r=await pg.evaluate(()=>{const p=document.querySelector('#caption p[data-role="line"]'),tn=p.firstChild,tx=tn.textContent,i=tx.indexOf('Q-res'),e=/SPREAD (yes|no)( ★)?/.exec(tx),rg=document.createRange();rg.setStart(tn,0);rg.setEnd(tn,e.index+e[0].length);const rr=rg.getBoundingClientRect(),pb=p.getBoundingClientRect();return {t:tx,flagsFirst:tx.indexOf('ALIGN')<i&&tx.indexOf('SPREAD')<i,flagRight:rr.right,pRight:pb.right,exp:p.getAttribute('aria-expanded')};});
       ok(tag+' SPREAD: the Fourier caption puts ALIGN and SPREAD (with the value and star) before Q-res, and the flag text is fully inside the line without tapping',r.flagsFirst&&r.flagRight<=r.pRight+0.5&&r.exp==='false',JSON.stringify(r));await pg.close();}
      {const pg=await open({...refO,m:'3',alpha:'1/2',phi3:'22',tab:'fourier'});   // N = 3 (irrational sqrt 3)
       await pg.click('#cards section:has(.panel-label:text-is("Phasors")) button.info');await pg.waitForTimeout(60);
       const ab=await pg.evaluate(()=>document.querySelector('#cards section .about').textContent);
       ok(tag+' F7 irrational rho: the (i) says the phasor values may need the extension ℚ(ζ_L, ρ) and that the field is generated by the phase factors',/phasor values themselves may need the further extension ℚ\(ζ_L, ρ\)/.test(ab)&&/generated by the phase factors/.test(ab)&&!/minimal field of the current phasor values/.test(ab),ab.slice(0,300));
       await pg.close();}
      // F5: the m drawer (i) carries the m register line
      {const pg=await open({tab:'fourier'});await pg.click('#lab_m');await pg.waitForTimeout(40);
       ok(tag+' F5 S16: the m register line is not on the surface; the m drawer has an (i)',!/ALG-5/.test(await pg.evaluate(()=>document.body.innerText))&&(await pg.locator('#drawer #minfo_btn').count())===1);
       await pg.click('#minfo_btn');await pg.waitForTimeout(40);const t=await pg.evaluate(()=>document.getElementById('minfo').innerText);
       ok(tag+' F5 S16: the m drawer (i) says "m (teeth, 2 to 720): 2 \u00B7 \u03B6\u2082 pair \u00B7 ALG-5" at m = 2',/m \(teeth, 2 to 720\): 2 \u00B7 \u03B6\u2082 pair \u00B7 ALG-5/.test(t),t);
       await pg.close();}
    }
    // ------------------------------------------------ v0.3 step 1: continuous N, option B (SCHEMA_ADDENDUM_8)
    {
      const CC=require('../host-core/comb-core.js'),XX=require('../exact-lib/exact-lib-0.2.0.js');
      const addrOf=o=>CC.encodeAddress(CC.initial(o)),reqs=[];
      const open=async(o)=>{const pg=await ctx.newPage();pg.on('request',r=>{if(!r.url().startsWith('file:')&&!r.url().startsWith('data:')&&!r.url().startsWith('blob:'))reqs.push(r.url());});
        await pg.goto(url+(o?addrOf(o):''));await pg.waitForSelector('#stage *',{state:'attached'});await pg.waitForTimeout(250);return pg;};
      const LBL=n=>'between shells: N = '+n+'; shell arithmetic undefined';
      const btwO={shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',t1:'1',t2:'1',n6:'1',alpha:'1',sTyped:'1/3',chart:'host'};   // N = 43/2
      const layout=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]');};
        const inst=[...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')),noInfo=inst.filter(e=>!e.classList.contains('info'));
        const box=id=>{const r=document.getElementById(id).getBoundingClientRect();return {t:r.top,b:r.bottom,vis:r.height>0};};
        return {instNoInfo:noInfo.length,frame:box('frame'),phi:box('phirow'),s:box('srow'),tr:box('transport'),vh:innerHeight};});
      const fonts=pg=>pg.evaluate(()=>{const bad=[];let n=0,mn=1e9;const svg=document.getElementById('stage'),k=svg.getBoundingClientRect().width/svg.viewBox.baseVal.width;
        document.querySelectorAll('body *').forEach(e=>{if(['SCRIPT','STYLE','OPTION'].includes(e.tagName))return;const own=[...e.childNodes].some(c=>c.nodeType===3&&c.textContent.trim());if(!own)return;
          const r=e.getBoundingClientRect(),cs=getComputedStyle(e);if(cs.display==='none'||cs.visibility==='hidden'||(r.width===0&&r.height===0))return;let fs=parseFloat(cs.fontSize);if(e.closest('svg'))fs*=k;n++;mn=Math.min(mn,fs);if(fs<13-1e-6)bad.push(e.tagName+' '+fs.toFixed(2));});return {n,mn,bad};});
      // the switch, its control count and the first screen in both modes
      {const pg=await open(null);const b=await pg.evaluate(()=>{const e=document.getElementById('nmode_btn'),c=document.getElementById('lab_phi3');return e&&{inRow:!!e.closest('#phirow'),pressed:e.getAttribute('aria-pressed'),txt:e.textContent,box:!!document.getElementById('phi_tx'),chip:c&&c.closest('#phirow')?c.textContent:null};});
       const L0=await layout(pg);
       // step 2 (F1 drawer): "no φ₃ box in integer mode" became "no φ₃ box on the surface in either mode; the φ₃ label is a chip" (the box is in the φ₃ drawer)
       ok(tag+' v0.3 the N mode switch (one toggle button, aria-pressed) is in the φ₃ row, not pressed by default ("N∈ℤ"); step 2: the φ₃ label is a chip "φ₃ 23" in the row and no φ₃ box is on the surface (it is in the φ₃ drawer); the instrument panel keeps the cap: '+L0.instNoInfo+' visible controls (ⓘ excluded) <= 40',!!b&&b.inRow&&b.pressed==='false'&&b.txt==='N∈ℤ'&&!b.box&&b.chip==='φ₃ 23'&&L0.instNoInfo<=40,JSON.stringify(b)+' '+JSON.stringify(L0));
       await pg.click('#nmode_btn');await pg.waitForTimeout(120);
       const L1=await layout(pg),s1=await pg.evaluate(()=>({nMode:FVPanel.state.nMode,phi3:FVPanel.state.phi3,pr:document.getElementById('nmode_btn').getAttribute('aria-pressed'),txt:document.getElementById('nmode_btn').textContent,box:!!document.getElementById('phi_tx'),chip:document.getElementById('lab_phi3').textContent,msg:document.getElementById('msg').textContent}));
       // step 2 (F1 drawer): "the φ₃ exact box appears holding 23" became "no box appears on the surface; the chip reads φ₃ 23" (the box is checked in the drawer below)
       ok(tag+' v0.3 integer → continuous: aria-pressed true ("N∈ℚ"), φ₃ unchanged (23), no message; step 2: no φ₃ box appears on the surface, the chip reads "φ₃ 23"',s1.nMode==='continuous'&&s1.phi3==='23'&&s1.pr==='true'&&s1.txt==='N∈ℚ'&&!s1.box&&s1.chip==='φ₃ 23'&&s1.msg==='',JSON.stringify(s1));
       console.log('CONTROLS '+tag+' v0.3: instrument panel without ⓘ: integer mode '+L0.instNoInfo+', continuous mode (φ₃ drawer closed) '+L1.instNoInfo);
       ok(tag+' v0.3 step 2 (F1): visible controls in the instrument panel in continuous mode (default φ₃, nothing opened, ⓘ excluded): '+L1.instNoInfo+' <= 40',L1.instNoInfo<=40,JSON.stringify(L1));
       // the φ₃ drawer: opens from the chip, holds ◀ exact box ▶, applies 89/4, closes from the chip
       await pg.click('#lab_phi3');await pg.waitForTimeout(100);
       const d0=await pg.evaluate(()=>{const dr=document.getElementById('phi_drawer');return dr&&{exp:document.getElementById('lab_phi3').getAttribute('aria-expanded'),box:dr.querySelectorAll('input[type=text]#phi_tx').length,val:document.getElementById('phi_tx').value,dn:dr.querySelectorAll('[data-act="phidn"]').length,up:dr.querySelectorAll('[data-act="phiup"]').length,range:document.getElementById('phi_range').textContent,afterRow:!!(document.getElementById('phirow').compareDocumentPosition(dr)&Node.DOCUMENT_POSITION_FOLLOWING),gear:document.querySelectorAll('#drawer input').length};});
       ok(tag+' v0.3 step 2 (F1): tapping the φ₃ chip opens the φ₃ drawer under the φ₃ row: ◀ exact box ▶ (box holds 23), range line "0 … 25 · decimal or fraction · Enter applies", aria-expanded true, no gear drawer open',!!d0&&d0.exp==='true'&&d0.box===1&&d0.val==='23'&&d0.dn===1&&d0.up===1&&d0.range==='0 … 25 · decimal or fraction · Enter applies'&&d0.afterRow&&d0.gear===0,JSON.stringify(d0));
       {const f=await fonts(pg),tt=await pg.evaluate(()=>[...document.querySelectorAll('#phi_drawer button,#phi_drawer input')].map(e=>e.getBoundingClientRect().height).filter(h=>h<39.5));
        ok(tag+' v0.3 step 2 (F1): with the φ₃ drawer open no visible text is below 13 px (smallest '+f.mn.toFixed(3)+' px) and its controls are >= 40 px high',f.bad.length===0&&tt.length===0,JSON.stringify({bad:f.bad.slice(0,3),tt}));}
       // resolution of stop 1 (amended 2026-10-14, saphir F1): ⏮ (start, N = 1) lives in the φ₃ drawer, not on the row
       {const p0=await pg.evaluate(()=>({row:document.querySelectorAll('#phirow [data-act="start"]').length,drawer:document.querySelectorAll('#phi_drawer [data-act="start"]').length}));
        await pg.click('#phi_drawer [data-act="start"]');await pg.waitForTimeout(100);
        const p1=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,shell:document.getElementById('shell_read').textContent,open:!!document.getElementById('phi_drawer')}));
        ok(tag+' v0.3 step 2 resolution (F1): ⏮ is in the φ₃ drawer (not on the φ₃ row) and sets φ₃ = B = 24 (N = 1); the drawer stays open',p0.row===0&&p0.drawer===1&&p1.phi3==='24'&&/N = 1(?!\d)/.test(p1.shell)&&p1.open,JSON.stringify({p0,p1}));
        await pg.evaluate(()=>FVPanel.dial({phi3:'23'}));await pg.waitForTimeout(80);}
       await pg.fill('#phi_tx','89/4');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(120);
       const d1=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,shell:document.getElementById('shell_read').textContent,chip:document.getElementById('lab_phi3').textContent,open:!!document.getElementById('phi_drawer'),val:document.getElementById('phi_tx')&&document.getElementById('phi_tx').value,msg:document.getElementById('msg').textContent}));
       ok(tag+' v0.3 step 2 (F1): the drawer box applies 89/4 (Enter): φ₃ = 89/4 exactly, shell readout "N = 11/4", chip "φ₃ 89/4", drawer stays open with the box holding 89/4, no message',d1.phi3==='89/4'&&/N = 11\/4/.test(d1.shell)&&d1.chip==='φ₃ 89/4'&&d1.open&&d1.val==='89/4'&&d1.msg==='',JSON.stringify(d1));
       await pg.click('#phi_drawer [data-act="phidn"]');await pg.waitForTimeout(80);const dd=await pg.evaluate(()=>FVPanel.state.phi3);
       await pg.evaluate(()=>FVPanel.dial({phi3:'89/4'}));await pg.click('#phi_drawer [data-act="phiup"]');await pg.waitForTimeout(80);const du=await pg.evaluate(()=>FVPanel.state.phi3);
       ok(tag+' v0.3 step 2 (F1): the drawer ◀ ▶ are the row\'s shell steps: from φ₃ = 89/4, ◀ (N − 1) -> 23, ▶ (N + 1) -> 22',dd==='23'&&du==='22',dd+','+du);
       await pg.evaluate(()=>FVPanel.dial({phi3:'89/4'}));await pg.waitForTimeout(60);
       await pg.click('#lab_phi3');await pg.waitForTimeout(100);
       const d2=await pg.evaluate(()=>({open:!!document.getElementById('phi_drawer'),box:!!document.getElementById('phi_tx'),exp:document.getElementById('lab_phi3').getAttribute('aria-expanded'),phi3:FVPanel.state.phi3}));
       ok(tag+' v0.3 step 2 (F1): tapping the chip again closes the φ₃ drawer (no box on the page, aria-expanded false), φ₃ stays 89/4',!d2.open&&!d2.box&&d2.exp==='false'&&d2.phi3==='89/4',JSON.stringify(d2));
       await pg.evaluate(()=>FVPanel.dial({phi3:'23'}));await pg.waitForTimeout(60);await pg.click('#lab_phi3');await pg.waitForTimeout(80);
       if(w<500){for(const [lab,L] of [['integer mode',L0],['continuous mode',L1]])ok(tag+' v0.3 first screen in '+lab+' (default φ₃): view frame, φ₃ row (to '+Math.round(L.phi.b)+'), s row (to '+Math.round(L.s.b)+') and transport (to '+Math.round(L.tr.b)+') inside the first '+L.vh+' px',L.frame.vis&&L.frame.t>=0&&L.phi.b<=L.vh&&L.s.b<=L.vh&&L.tr.b<=L.vh,JSON.stringify(L));}
       // slider step and integer-shell marks
       const sl=await pg.evaluate(()=>{const s=document.getElementById('phi_sl'),mk=[...document.querySelectorAll('#phi_marks i.sh')].map(i=>parseFloat(i.style.left));return {step:s.step,max:s.max,n:mk.length,pos:mk};});
       ok(tag+' v0.3 continuous mode: φ₃ slider step 0.01 (1/100 of a shell), max B + 1 = 25, the 26 integer shells 0..25 marked on the track at j/25',sl.step==='0.01'&&sl.max==='25'&&sl.n===26&&sl.pos.every((x,j)=>Math.abs(x-j*4)<1e-9),JSON.stringify({step:sl.step,max:sl.max,n:sl.n}));
       // the box: 7/2 and 3.5, a refusal outside 0..B+1
       await pg.fill('#phi_tx','7/2');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(120);
       const b1=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,shell:document.getElementById('shell_read').textContent,addr:location.hash}));
       ok(tag+' v0.3 the φ₃ box accepts 7/2 (Enter): φ₃ = 7/2 exactly, the shell readout shows N = 43/2, the address carries nMode=continuous&phi3=7/2',b1.phi3==='7/2'&&/N = 43\/2/.test(b1.shell)&&b1.addr.includes('nMode=continuous&phi3=7/2'),JSON.stringify(b1));
       await pg.fill('#phi_tx','6.25');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(120);const b2=await pg.evaluate(()=>FVPanel.state.phi3);
       await pg.fill('#phi_tx','26');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(120);const b3=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,msg:document.getElementById('msg').textContent}));
       ok(tag+' v0.3 the φ₃ box accepts a decimal (6.25 -> 25/4) and refuses 26 (outside 0..B+1) with the reason, state unchanged',b2==='25/4'&&b3.phi3==='25/4'&&/φ₃ must be 0 through B \+ 1/.test(b3.msg),JSON.stringify({b2,b3}));
       // slider move in continuous mode reads the two-decimal value exactly
       await pg.evaluate(()=>{const s=document.getElementById('phi_sl');s.value='12.37';s.dispatchEvent(new Event('change',{bubbles:true}));});await pg.waitForTimeout(120);
       ok(tag+' v0.3 continuous slider: value 12.37 is committed as φ₃ = 1237/100 (exact)',(await pg.evaluate(()=>FVPanel.state.phi3))==='1237/100');
       // ◀ ▶ snap to shells
       await pg.evaluate(()=>FVPanel.dial({phi3:'7/2'}));await pg.click('#phirow [data-act="phidn"]');await pg.waitForTimeout(80);const a1=await pg.evaluate(()=>FVPanel.state.phi3);
       await pg.evaluate(()=>FVPanel.dial({phi3:'7/2'}));await pg.click('#phirow [data-act="phiup"]');await pg.waitForTimeout(80);const a2=await pg.evaluate(()=>FVPanel.state.phi3);
       await pg.click('#phirow [data-act="phiup"]');await pg.waitForTimeout(80);const a3=await pg.evaluate(()=>FVPanel.state.phi3);
       ok(tag+' v0.3 ◀ ▶ snap to the next integer shell: from φ₃ = 7/2, ◀ (N − 1) -> 4, ▶ (N + 1) -> 3, then ▶ -> 2',a1==='4'&&a2==='3'&&a3==='2',[a1,a2,a3].join());
       // Play N: 1/100 of a shell per tick
       await pg.evaluate(()=>FVPanel.dial({phi3:'7/2'}));await pg.click('#play_n');await pg.waitForTimeout(420);const pn=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,note:document.getElementById('play_note').textContent}));await pg.click('#play_n');await pg.waitForTimeout(60);
       const dq=XX.sub(XX.parse(pn.phi3),XX.parse('7/2'));
       ok(tag+' v0.3 Play ▶ N in continuous mode advances φ₃ by 1/100 of a shell per tick ('+XX.text(dq)+' after about 3 ticks) and says so',XX.cmp(dq,XX.rat(0n))>0&&XX.isInt(XX.mul(dq,XX.rat(100n)))&&XX.cmp(dq,XX.rat(1n,10n))<0&&/1\/100 of a shell per tick/.test(pn.note),JSON.stringify(pn));
       // continuous -> integer with a non-integer phi3: rounded, said in the message line
       await pg.evaluate(()=>FVPanel.dial({phi3:'27/4'}));await pg.click('#nmode_btn');await pg.waitForTimeout(100);
       const r4=await pg.evaluate(()=>({nMode:FVPanel.state.nMode,phi3:FVPanel.state.phi3,msg:document.getElementById('msg').textContent}));
       ok(tag+' v0.3 continuous → integer at φ₃ = 27/4: rounded to the nearest shell φ₃ = 7 and said in the message line (never silently)',r4.nMode==='integer'&&r4.phi3==='7'&&r4.msg==='N continuous → integer: φ₃ = 27/4 rounded to the nearest shell φ₃ = 7 (N = 18).',JSON.stringify(r4));
       // step 2 (F1): the drawer in integer mode accepts integers only; a fraction is refused with the stated reason
       {const open0=await pg.evaluate(()=>!!document.getElementById('phi_drawer'));if(!open0){await pg.click('#lab_phi3');await pg.waitForTimeout(80);}
        const rg=await pg.evaluate(()=>document.getElementById('phi_range').textContent);
        await pg.fill('#phi_tx','7/2');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(120);
        const r5=await pg.evaluate(()=>({nMode:FVPanel.state.nMode,phi3:FVPanel.state.phi3,msg:document.getElementById('msg').textContent,inDrawer:(document.querySelector('#phidrawer [data-role="phi-refusal"]')||{}).textContent||null}));
        const want='N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions';
        ok(tag+' v0.3 step 2 (F1): in integer mode the φ₃ drawer (range line "0 … 25 · integer (N∈ℤ) · Enter applies") refuses 7/2 with "'+want+'" in the message line and in the drawer; state unchanged (φ₃ = 7, integer mode)',rg==='0 … 25 · integer (N∈ℤ) · Enter applies'&&r5.nMode==='integer'&&r5.phi3==='7'&&r5.msg===want&&r5.inDrawer===want,JSON.stringify({rg,r5}));
        await pg.fill('#phi_tx','8/2');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(100);const a8=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,msg:document.getElementById('msg').textContent,inDrawer:!!document.querySelector('#phidrawer [data-role="phi-refusal"]')}));
        await pg.fill('#phi_tx','26');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(100);const a26=await pg.evaluate(()=>({phi3:FVPanel.state.phi3,msg:document.getElementById('msg').textContent}));
        ok(tag+' v0.3 step 2 (F1): integer mode drawer: 8/2 is the integer 4 (applied, refusal cleared); 26 is refused with the range reason, state unchanged',a8.phi3==='4'&&a8.msg===''&&!a8.inDrawer&&a26.phi3==='4'&&/φ₃ must be 0 through B \+ 1/.test(a26.msg),JSON.stringify({a8,a26}));}
       await pg.close();}
      // between shells: caption, cards, stepping, exports, text size, tab switches
      {const pg=await open(btwO);
       if(w<500){const L=await layout(pg);console.log('FIRSTSCREEN '+tag+' v0.3 between shells (N = 43/2, m = 5, Fourier): transport bottom '+Math.round(L.tr.b)+' of '+L.vh+' px; φ₃ row to '+Math.round(L.phi.b)+'; s row to '+Math.round(L.s.b));}
       {const L=await layout(pg);ok(tag+' v0.3 step 2 (F1): visible controls in the instrument panel between shells (N = 43/2, continuous mode, nothing opened, ⓘ excluded): '+L.instNoInfo+' <= 40',L.instNoInfo<=40,JSON.stringify(L));}
       for(const tab of ['fourier','clifford','hopf','panels']){
         await pg.evaluate(t=>FVPanel.dial({tab:t}),tab);await pg.waitForTimeout(150);
         const r=await pg.evaluate(()=>{const ps=[...document.querySelectorAll('#caption p[data-role="degenerate"]')].filter(p=>/^between shells/.test(p.textContent));const p=ps[0];if(!p)return null;const b=p.getBoundingClientRect(),lh=parseFloat(getComputedStyle(p).lineHeight);
           return {n:ps.length,t:p.textContent,lines:Math.round(b.height/lh),cls:p.className,trunc:p.scrollWidth>p.clientWidth,vis:b.width>0&&b.height>0,inView:b.right<=innerWidth+1,ell:getComputedStyle(p).textOverflow,shell:document.getElementById('shell_read').textContent};});
         // step 2 (F2, addendum 8 amendment): the warning line carries the short form (was the full label with the fraction); the fraction stays in the shell readout
         ok(tag+' v0.3 '+tab+': the warning line carries the short form "between shells: shell arithmetic undefined" once, in full, on one line, role degenerate, not ellipsized; the shell readout shows N = 43/2',!!r&&r.n===1&&r.t==='between shells: shell arithmetic undefined'&&r.lines===1&&r.cls.indexOf('ell')<0&&!r.trunc&&r.vis&&r.inView&&r.ell!=='ellipsis'&&/N = 43\/2/.test(r.shell),JSON.stringify(r));
         const f=await fonts(pg);ok(tag+' v0.3 '+tab+' between shells: no visible text below 13 px ('+f.n+' elements, smallest '+f.mn.toFixed(3)+' px)',f.bad.length===0,f.bad.slice(0,4).join(' | '));}
       await pg.evaluate(()=>FVPanel.dial({tab:'fourier'}));await pg.waitForTimeout(120);
       const cards=await pg.evaluate(()=>{const sec=n=>{const s=[...document.querySelectorAll('#cards section')].find(x=>x.querySelector('.panel-label').textContent.trim().toLowerCase()===n);return s?s.innerText:null;};
         return {wilson:sec('wilson'),div:sec('divisors'),shell:sec('shell'),phasors:!!sec('phasors'),flags:sec('exact flags and numerical readouts')};});
       const L=LBL('43/2');
       ok(tag+' v0.3 cards between shells: Wilson (both readouts and the gearbox), Divisors and Shell show the label instead of values; Phasors and the exact flags keep working with exact fractions (spread 2/129)',[cards.wilson,cards.div,cards.shell].every(t=>t&&t.includes(L)&&!/Shell N =|Gearbox|residency|contrast =|Div\(s\)/.test(t))&&cards.phasors&&/2\/129/.test(cards.flags),JSON.stringify(cards).slice(0,500));
       // step 2 (F2): the SPREAD refusal moved from a permanent line under the view to the s-row stepper message (on a step) and the s ⓘ text
       const SR='SPREAD refused (4e): SPREAD needs an integer gearbox: N = 43/2';
       const sr=await pg.evaluate(()=>({line:!!document.querySelector('#s_read [data-role="step-family-refused"]'),sread:document.getElementById('s_read').textContent}));
       await pg.click('#sinfo_btn');await pg.waitForTimeout(80);
       const si=await pg.evaluate(()=>{const e=document.querySelector('#sinfo [data-role="sinfo-family-refused"]');return e&&{t:e.textContent,vis:e.getBoundingClientRect().height>0,trunc:e.scrollWidth>e.clientWidth};});
       await pg.click('#sinfo_btn');await pg.waitForTimeout(60);
       ok(tag+' v0.3 step 2 (F2): s row between shells (m = 5): before any press there is no SPREAD line under the view; the s ⓘ states "'+SR+'" in full',!sr.line&&!/SPREAD/.test(sr.sread)&&!!si&&si.t===SR&&si.vis&&!si.trunc,JSON.stringify({sr,si}));
       for(const [act,want] of [['sup','1'],['sdn','0']]){await pg.evaluate(()=>FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'1/3')));await pg.click('#srow [data-act="'+act+'"]');await pg.waitForTimeout(80);
         const st=await pg.evaluate(()=>({s:FVPanel.state.sTyped,lbl:document.getElementById('sinfo_btn')&&FVPanel.model&&FVPanel.model.last?FVPanel.model.last.label:''}));
         ok(tag+' v0.3 s '+(act==='sup'?'▶':'◀')+' between shells lands on the ALIGN stop '+want+' (SPREAD refused, not approximated)',st.s===want&&/ALIGN stop/.test(st.lbl)&&/SPREAD refused \(4e\)/.test(st.lbl),JSON.stringify(st));
         const sm=await pg.evaluate(()=>{const e=document.querySelector('#s_read [data-role="step-family-refused"]');if(!e)return null;const b=e.getBoundingClientRect();return {t:e.textContent,trunc:e.scrollWidth>e.clientWidth,vis:b.width>0&&b.height>0,inView:b.right<=innerWidth+1};});
         ok(tag+' v0.3 step 2 (F2): after the s '+(act==='sup'?'▶':'◀')+' step the s-row stepper message shows "'+SR+'" in full, visible, not truncated',!!sm&&sm.t===SR&&sm.vis&&!sm.trunc&&sm.inView,JSON.stringify(sm));}
       // exports
       await expOpen(pg);await pg.click('#expmenu [data-act="xlift"]');await pg.waitForTimeout(150);const lj=JSON.parse(await pg.inputValue('#xout'));
       ok(tag+' v0.3 Lift JSON between shells: schema fv-comb-hopf-lift/0.3, nMode continuous, N "43/2", N_integer false; integral_frequencies NOT_EVALUATED with the label as reason; closed_orbits PASS',lj.schema==='fv-comb-hopf-lift/0.3'&&lj.nMode==='continuous'&&lj.N==='43/2'&&lj.N_integer===false&&lj.gates.integral_frequencies.status==='NOT_EVALUATED'&&lj.gates.integral_frequencies.reason===L&&lj.gates.closed_orbits.status==='PASS'&&lj.gates.prime_pair.reason.endsWith(L),JSON.stringify(lj.gates));
       await expOpen(pg);await pg.click('#expmenu [data-act="xjson"]');await pg.waitForTimeout(150);const ej=JSON.parse(await pg.inputValue('#xout'));
       ok(tag+' v0.3 exact JSON between shells: schema fv-comb-hopf/0.2, state.nMode continuous, exact.N "43/2", N_integer false, gearbox BETWEEN_SHELLS, shell contrast null with the label',ej.schema==='fv-comb-hopf/0.2'&&ej.state.nMode==='continuous'&&ej.exact.N==='43/2'&&ej.exact.N_integer===false&&ej.exact.gearboxCode==='BETWEEN_SHELLS'&&ej.exact.shell.contrast===null&&ej.exact.shell.status===L,JSON.stringify(ej.exact.shell));
       // tab switches change no setting, in both modes
       for(const mode of ['continuous','integer']){
         if(mode==='integer')await pg.evaluate(()=>FVPanel.dial({nMode:'integer',phi3:'4'}));await pg.waitForTimeout(80);
         const strip=s=>{const o={...s};delete o.tab;return JSON.stringify(o);};const s0=await pg.evaluate(()=>FVPanel.state);let same=true;
         for(const tab of ['clifford','hopf','panels','fourier']){await pg.click('#tabs [data-v="'+tab+'"]');await pg.waitForTimeout(100);if(strip(await pg.evaluate(()=>FVPanel.state))!==strip(s0))same=false;}
         ok(tag+' v0.3 tab switches change no setting in '+mode+' mode',same&&s0.nMode===mode);}
       await pg.close();}
      // ---- step 2 (VERIFY F2): first screen at 375x812 between shells on all four tabs, N = 11/4 (B = 24, φ₃ = 89/4), m = 2 and m = 5, nothing opened
      if(w<500){
        for(const m of ['2','5'])for(const tab of ['fourier','clifford','hopf','panels']){
          const pg=await ctx.newPage();pg.on('request',r=>{if(!r.url().startsWith('file:')&&!r.url().startsWith('data:')&&!r.url().startsWith('blob:'))reqs.push(r.url());});
          await pg.goto(url+addrOf({nMode:'continuous',phi3:'89/4',m,tab}));await pg.waitForSelector('#tabs button');await pg.waitForTimeout(350);   // the Panels tab draws no #stage children
          const L=await pg.evaluate(()=>{const box=id=>{const r=document.getElementById(id).getBoundingClientRect();return {t:Math.round(r.top*10)/10,b:Math.round(r.bottom*10)/10,vis:r.height>0&&r.width>0};};
            return {frame:box('frame'),html:box('htmlstage'),phi:box('phirow'),s:box('srow'),tr:box('transport'),vh:innerHeight,y:scrollY,shell:document.getElementById('shell_read').textContent,
              opened:{phiDrawer:!!document.getElementById('phi_drawer'),gearDrawer:document.querySelectorAll('#drawer input').length,menu:document.querySelectorAll('#menu .menu').length,sinfo:getComputedStyle(document.getElementById('sinfo')).display!=='none',about:document.querySelectorAll('#about .about').length,exp:!document.getElementById('expmenu').hidden}};});
          const view=tab==='panels'?L.html:L.frame,closed=!L.opened.phiDrawer&&L.opened.gearDrawer===0&&L.opened.menu===0&&!L.opened.sinfo&&L.opened.about===0&&!L.opened.exp;
          console.log('FIRSTSCREEN '+tag+' step 2 between shells N = 11/4, m = '+m+', '+tab+': φ₃ row to '+L.phi.b+', s row to '+L.s.b+', transport to '+L.tr.b+' of '+L.vh+' px');
          ok(tag+' v0.3 step 2 (F2) first screen between shells (N = 11/4, B = 24, φ₃ = 89/4, m = '+m+', '+tab+', nothing opened): '+(tab==='panels'?'panel stage top ('+view.t+')':'view frame ('+view.t+'-'+view.b+')')+', φ₃ row (to '+L.phi.b+'), s row (to '+L.s.b+') and transport (to '+L.tr.b+') inside the first '+L.vh+' px',
            closed&&L.y===0&&/N = 11\/4/.test(L.shell)&&(tab==='panels'?view.vis&&view.t<L.vh:view.vis&&view.t>=0)&&L.phi.b<=L.vh&&L.s.b<=L.vh&&L.tr.b<=L.vh,JSON.stringify(L));
          await pg.close();}
        // the φ₃ slider width at 375 px (step 2, F1): at least the s slider's width minus the toggle's width
        for(const [lab,o] of [['integer mode, default',{}],['continuous mode, default φ₃',{nMode:'continuous'}],['between shells N = 11/4',{nMode:'continuous',phi3:'89/4'}]]){
          const pg=await open({...o,tab:'fourier'});
          const sw=await pg.evaluate(()=>{const W=id=>Math.round(document.getElementById(id).getBoundingClientRect().width*10)/10;return {phi:W('phi_sl'),s:W('s_sl'),toggle:W('nmode_btn'),chip:W('lab_phi3')};});
          console.log('SLIDERS '+tag+' step 2 '+lab+': φ₃ slider '+sw.phi+' px, s slider '+sw.s+' px, N toggle '+sw.toggle+' px, φ₃ chip '+sw.chip+' px');
          ok(tag+' v0.3 step 2 (F1) '+lab+': φ₃ slider '+sw.phi+' px >= s slider '+sw.s+' px − N toggle '+sw.toggle+' px',sw.phi>=sw.s-sw.toggle&&sw.phi>0,JSON.stringify(sw));
          await pg.close();}
      }
      // ---- step 2 (VERIFY F6): the build-pins id, the exact-export id and the state-export id are pairwise distinct (read from the page and from real exports)
      {const pg=await open(null);await expOpen(pg);await pg.click('#expmenu [data-act="xjson"]');await pg.waitForTimeout(120);const ex=JSON.parse(await pg.inputValue('#xout'));
       await pg.click('#expmenu [data-act="xstate"]');await pg.waitForTimeout(120);const sx=JSON.parse(await pg.inputValue('#xout'));
       const pins=await pg.evaluate(()=>JSON.parse(document.getElementById('fv-build-pins').textContent).schema);
       const ids=[pins,ex.schema,sx.schema];
       ok(tag+' v0.3 step 2 (F6): build pins "'+ids[0]+'", exact export "'+ids[1]+'", state export "'+ids[2]+'" are pairwise distinct; the pins id is fv-comb-hopf-build/0.1',ids[0]==='fv-comb-hopf-build/0.1'&&new Set(ids).size===3,JSON.stringify(ids));
       await pg.close();}
      // a 0.1 address (v0.2 era) still opens, read as integer mode
      {const pg=await ctx.newPage();await pg.goto(url+'#v=fv-comb-hopf/0.1&shellMode=factorial&n1=4&B=24&phi3=6&m=3&t1=1&t2=-21/4&n6=1&alpha=-1/50&chart=host&sTyped=-627/250&sEff=-627/250&E=19&tab=clifford&view=');await pg.waitForSelector('#stage *',{state:'attached'});await pg.waitForTimeout(250);
       const r=await pg.evaluate(()=>({nMode:FVPanel.state.nMode,phi3:FVPanel.state.phi3,tab:FVPanel.state.tab,status:document.getElementById('status').textContent,hash:location.hash}));
       ok(tag+' v0.3 a 0.1 address opens as nMode = integer (no refusal banner) and is rewritten as a 0.2 address',r.nMode==='integer'&&r.phi3==='6'&&r.tab==='clifford'&&!/refused/.test(r.status)&&r.hash.startsWith('#v=fv-comb-hopf/0.2&')&&r.hash.includes('&nMode=integer&phi3=6&'),JSON.stringify(r));await pg.close();}
      ok(tag+' v0.3 zero network requests in the continuous-N pages',reqs.length===0,reqs.join(','));
    }
    // ------------------------------------------------ performance round: reproduction state (owner screenshot), canvas layer, preview, clipped-text fix
    {
      const pg=await ctx.newPage(),perr=[];pg.on('pageerror',e=>perr.push(String(e)));await pg.goto(url);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
      const hash=await pg.evaluate(()=>{FVPanel.dial({shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3',tab:'clifford'});FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));return location.hash;});
      await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await pg.waitForTimeout(300);
      const cap=await pg.evaluate(()=>[...document.querySelectorAll('#caption p')].map(p=>p.textContent));
      ok(tag+' PERF reproduction state reached (partial-orbit caption, 2 orbits)',cap.some(c=>/^partial orbit: 2 orbit\(s\)/.test(c)),cap.join(' | '));
      // generous regression bound: median of 7 state changes (sync call + next frame), threshold 250 ms on the unthrottled run (measured: ~15 ms desktop, ~100 ms at 4x throttle)
      const tm=await pg.evaluate(async()=>{const fr=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
        const a=[];for(let i=0;i<7;i++){await fr();const t0=performance.now();FVPanel.onAct(i%2?'phidn':'phiup');await fr();a.push(performance.now()-t0);}a.sort((x,y)=>x-y);return {med:a[3],all:a.map(x=>+x.toFixed(1))};});
      ok(tag+' PERF state change at the reproduction state: median '+tm.med.toFixed(1)+' ms to next frame (< 250 ms regression bound)',tm.med<250,JSON.stringify(tm.all));
      // the canvas layer carries the heavy geometry; the SVG keeps stubs with data attributes
      const lay=await pg.evaluate(()=>{const svg=document.getElementById('stage'),cv=document.getElementById('stagecv'),d=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let lit=0;for(let i=0;i<d.length;i+=4*97)if(d[i]!==12||d[i+1]!==12||d[i+2]!==24)lit++;
        const pl=[...svg.querySelectorAll('rect[data-role="orbit"]')];return {cv:[cv.width,cv.height],lit,svgEls:svg.querySelectorAll('*').length,stubs:pl.length,stubPts:0,dataC:pl.every(e=>e.hasAttribute('data-c')&&e.hasAttribute('data-branch')&&e.hasAttribute('data-t')&&e.hasAttribute('stroke')),runs:new Set(FVViews.layerRuns().filter(r=>r.role==='orbit').map(r=>r.c)).size,leaf:svg.querySelectorAll('[data-role="leaf"]').length};});
      ok(tag+' PERF canvas layer drawn (non-background pixels), SVG overlay small: '+lay.svgEls+' elements, orbit stubs carry data-c and stroke, no geometry in the SVG',lay.lit>20&&lay.svgEls<60&&lay.stubs>=2&&lay.stubPts===0&&lay.dataC&&lay.runs===lay.stubs&&lay.leaf>=1,JSON.stringify(lay));
      // clipped text: the left-edge degenerate label starts inside the frame (it was centred on x = 10 and clipped)
      const clip=await pg.evaluate(()=>{const svg=document.getElementById('stage'),sr=svg.getBoundingClientRect(),t=[...svg.querySelectorAll('text')].filter(e=>/see note/.test(e.textContent)).map(e=>{const r=e.getBoundingClientRect();return {l:r.left-sr.left,r:sr.right-r.right,anchor:e.getAttribute('text-anchor')};});return t;});
      ok(tag+' PERF clipped-text fix: the "(see note)" stand-in at the left edge lies fully inside the Clifford frame',clip.length>=1&&clip.every(c=>c.l>=0&&c.r>=0&&c.anchor==='start'),JSON.stringify(clip));
      // preview: a burst of s-slider input events coalesces to a reduced draw while readouts stay exact, then the full sample is drawn on release / after 200 ms
      const pv=await pg.evaluate(async()=>{const fr=()=>new Promise(r=>requestAnimationFrame(()=>r()));const el=document.getElementById('s_sl'),n0=FVPanel.perf.n,full=FVViews.layerRuns().filter(r=>r.role==='orbit').reduce((a,r)=>a+r.pts.length,0);
        for(let i=0;i<30;i++){el.value=(-2.4+0.16*i).toFixed(3);el.dispatchEvent(new Event('input',{bubbles:true}));}
        const sync={state:FVPanel.state.sTyped,renders:FVPanel.perf.n-n0};
        await fr();await fr();const during={renders:FVPanel.perf.n-n0,cap:[...document.querySelectorAll('#caption p[data-role="preview"]')].map(p=>p.textContent),exactBox:document.getElementById('s_tx').value,state:FVPanel.state.sTyped,
          pts:FVViews.layerRuns().filter(r=>r.role==='orbit').reduce((a,r)=>a+r.pts.length,0),eff:FVPanel.state.sEff,cardsS:document.getElementById('cards').textContent.includes(FVPanel.state.sTyped)||true};
        await new Promise(r=>setTimeout(r,450));const after={cap:document.querySelectorAll('#caption p[data-role="preview"]').length,pts:FVViews.layerRuns().filter(r=>r.role==='orbit').reduce((a,r)=>a+r.pts.length,0),exactBox:document.getElementById('s_tx').value,state:FVPanel.state.sTyped};
        return {full,sync,during,after};});
      ok(tag+' PERF preview: 30 input events in one task coalesce to one render (<= 2), state and the exact s box current at once, caption says "preview"',pv.sync.renders===0&&pv.during.renders>=1&&pv.during.renders<=2&&/preview/.test(pv.during.cap.join(' '))&&pv.during.exactBox===pv.during.state&&pv.during.state===pv.sync.state,JSON.stringify(pv));
      ok(tag+' PERF preview draws fewer orbit points than the full sample and the full sample returns (no preview label) after 200 ms',pv.during.pts<pv.after.pts&&pv.after.cap===0&&pv.after.exactBox===pv.after.state,JSON.stringify(pv));
      ok(tag+' PERF no page errors in the performance block',perr.length===0,perr.join('|'));
      // PNG export in the middle of a preview is a full frame (export flushes the preview first)
      await pg.evaluate(()=>{const el=document.getElementById('s_sl');el.value='0.5';el.dispatchEvent(new Event('input',{bubbles:true}));});
      const png=await pg.evaluate(async()=>{const b=await FVPanel.exportPng();return {size:b.size,preview:document.querySelectorAll('#caption p[data-role="preview"]').length};});
      ok(tag+' PERF PNG export (canvas layer + SVG overlay composited) is non-trivial and not a preview frame',png.size>20000&&png.preview===0,JSON.stringify(png));
      // ---- performance round 2 ----------------------------------------------------------------------------------------------------------------------------------------------
      {
        // helpers run inside the page
        const lib=`window.__t={fr:()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);})),
          canon:el=>{const f=n=>n.nodeType===3?n.data:n.nodeType===1?'<'+n.nodeName+[...n.attributes].map(a=>a.name+'='+a.value).sort().join(',')+'>'+[...n.childNodes].map(f).join('')+'</>':'';return [...el.childNodes].map(f).join('');},   /* the children of the container: its own data-preview marker is not card content */
          pe:(type,id,x,y,sh)=>document.getElementById('stage').dispatchEvent(new PointerEvent(type,{pointerId:id,clientX:x,clientY:y,bubbles:true,cancelable:true,shiftKey:!!sh,button:0,buttons:type==='pointerup'?0:1,pointerType:'mouse'})),
          centre:()=>{const r=document.getElementById('stage').getBoundingClientRect();return [r.left+r.width/2,r.top+r.height/2];}};`;
        await pg.evaluate(lib);
        // camera moves: no sample, no model and no full render; exact state, cards and exports unchanged
        for(const tab of ['clifford','hopf']){
          await pg.evaluate(t=>{FVPanel.dial({tab:t});FVPanel.dial({view:''});},tab);await pg.waitForTimeout(300);
          const r=await pg.evaluate(async()=>{const T=window.__t,NUM=FVCombNumeric,cnt={orbits:0,compute:0,torusMesh:0},orig={};
            for(const k of Object.keys(cnt)){orig[k]=NUM[k];NUM[k]=function(){cnt[k]++;return orig[k].apply(this,arguments);};}
            const ex0=FVCombCore.exportExact(FVPanel.state,null,{witnessP:null}),sh0=FVExact.sha256Text(ex0),st0=JSON.stringify({...FVPanel.state,view:''}),cards0=T.canon(document.getElementById('cards'));
            const n0=FVPanel.perf.n,c0=FVPanel.perf.camN,[x0,y0]=T.centre();let x=x0,y=y0;
            T.pe('pointerdown',1,x,y);const t0=performance.now();
            for(let i=0;i<60;i++){x+=3;y+=(i%2?1.5:-1.5);T.pe('pointermove',1,x,y);await T.fr();}
            const dt=performance.now()-t0,during={full:FVPanel.perf.n-n0,cam:FVPanel.perf.camN-c0,cnt:{...cnt},state:JSON.stringify({...FVPanel.state,view:''})===st0,cards:T.canon(document.getElementById('cards'))===cards0,cvMoving:document.getElementById('stagecv').width};
            T.pe('pointerup',1,x,y);await T.fr();await T.fr();
            const after={full:FVPanel.perf.n-n0,viewMoved:FVPanel.state.view!=='',sha:FVExact.sha256Text(FVCombCore.exportExact(FVPanel.state,null,{witnessP:null}))===sh0,cardsSame:T.canon(document.getElementById('cards'))===cards0,cvFull:document.getElementById('stagecv').width};
            for(const k of Object.keys(cnt))NUM[k]=orig[k];
            return {during,after,fps:60/(dt/1000)};});
          ok(tag+' PERF2 '+tab+' rotate (60 moves): camera frames drawn ('+r.during.cam+'), no full render, no orbit/model/mesh recomputation, exact state and cards unchanged',r.during.cam>=20&&r.during.full===0&&r.during.cnt.orbits===0&&r.during.cnt.compute===0&&r.during.cnt.torusMesh===0&&r.during.state&&r.during.cards,JSON.stringify(r.during));
          ok(tag+' PERF2 '+tab+' release: one full render, view moved, exact JSON hash unchanged by the camera, cards identical, canvas back at full resolution (was '+r.during.cvMoving+', now '+r.after.cvFull+')',r.after.full===1&&r.after.viewMoved&&r.after.sha&&r.after.cardsSame&&r.after.cvFull>r.during.cvMoving,JSON.stringify(r.after));
          ok(tag+' PERF2 '+tab+' rotate frame rate '+r.fps.toFixed(1)+' fps (regression bound >= 30; target 50 desktop)',r.fps>=30,String(r.fps));
        }
        // wheel, pinch and pan take the same path
        {await pg.evaluate(()=>{FVPanel.dial({tab:'clifford'});FVPanel.dial({view:''});});await pg.waitForTimeout(300);
         const r=await pg.evaluate(async()=>{const T=window.__t,svg=document.getElementById('stage');const n0=FVPanel.perf.n,c0=FVPanel.perf.camN,v0=FVPanel.state.view;
           for(let i=0;i<10;i++){svg.dispatchEvent(new WheelEvent('wheel',{deltaY:-100,bubbles:true,cancelable:true}));await T.fr();}
           const z1=FVPanel.state.view;const [x0,y0]=T.centre();T.pe('pointerdown',1,x0,y0);T.pe('pointerdown',2,x0+40,y0);
           for(let i=0;i<10;i++){T.pe('pointermove',2,x0+40+3*(i+1),y0);await T.fr();}T.pe('pointerup',2,x0,y0);T.pe('pointerup',1,x0,y0);
           const z2=FVPanel.state.view;T.pe('pointerdown',1,x0,y0,true);for(let i=0;i<10;i++){T.pe('pointermove',1,x0+4*(i+1),y0+2*(i+1),true);await T.fr();}
           const pan=FVPanel.state.view;T.pe('pointerup',1,x0+40,y0+20,true);await T.fr();await T.fr();
           return {v0,z1,z2,pan,cam:FVPanel.perf.camN-c0,full:FVPanel.perf.n-n0};});
         ok(tag+' PERF2 Clifford wheel zoom, pinch zoom and pan change the view string (zoom '+r.z1+' / '+r.z2+', pan '+r.pan+') on the camera path',/cz=/.test(r.z1)&&r.z2!==r.z1&&/cx=/.test(r.pan)&&r.cam>=15&&r.full<=4,JSON.stringify(r));}
        // R17: every tooth dot, walk vertex and branch orbit has an SVG element at the canvas-drawn position
        const reproAddr=await pg.evaluate(()=>FVCombCore.encodeAddress(FVPanel.state));
        for(const [tab,extra,lbl] of [['clifford',{},''],['hopf',{},''],['clifford',{m:'7',phi3:'21',t1:'1',t2:'1',alpha:'1'},' m=7'],['hopf',{m:'7',phi3:'21',t1:'1',t2:'1',alpha:'1'},' m=7']]){
          await pg.evaluate(([t,x])=>{FVPanel.dial({tab:t,...x});FVPanel.dial({view:''});},[tab,extra]);await pg.waitForTimeout(300);
          const chk=async(label0)=>{const label=label0+lbl;
            const r=await pg.evaluate(()=>{
              const cv=document.getElementById('stagecv'),svg=document.getElementById('stage'),cr=cv.getBoundingClientRect(),vb=svg.viewBox.baseVal,k=Math.min(cr.width/vb.width,cr.height/vb.height),ox=cr.left+(cr.width-vb.width*k)/2,oy=cr.top+(cr.height-vb.height*k)/2;
              const marks=FVViews.layerMarks(),ctx=cv.getContext('2d'),sx=cv.width/cr.width;
              const px=(x,y)=>ctx.getImageData(Math.round((x-cr.left)*sx),Math.round((y-cr.top)*sx),1,1).data;
              const out={dots:[],verts:[],orbs:[],bad:[],attrs:true};
              const centre=e=>{const b=e.getBoundingClientRect();return [b.left+b.width/2,b.top+b.height/2];};
              for(const mk of marks.filter(m=>m.role==='tooth-dot'||m.role==='vertex')){
                const sel='[data-role="'+mk.role+'"]'+(mk.role==='tooth-dot'?'[data-c="'+mk.c+'"]':'[data-t="'+mk.t+'"]'),el=document.querySelector('#stage '+sel);
                if(!el){out.bad.push('missing '+sel);continue;}
                const c=centre(el),dx=Math.abs(c[0]-(ox+mk.x*k)),dy=Math.abs(c[1]-(oy+mk.y*k));
                if(mk.role==='tooth-dot'&&(!el.hasAttribute('data-c')||!el.hasAttribute('data-t')))out.attrs=false;
                if(mk.role==='vertex'&&(!el.hasAttribute('data-t')))out.attrs=false;
                const p=px(ox+mk.x*k,oy+mk.y*k);(mk.role==='tooth-dot'?out.dots:out.verts).push({c:mk.c,t:mk.t,err:Math.max(dx,dy),lit:!(p[0]===12&&p[1]===12&&p[2]===24)});}
              for(const mk of marks.filter(m=>m.branch!==undefined)){
                const el=document.querySelector('#stage [data-role="'+mk.role+'"][data-branch="'+mk.branch+'"]');
                if(!el){out.bad.push('missing orbit '+mk.branch);continue;}
                const b=el.getBoundingClientRect(),ex=[ox+mk.x0*k,oy+mk.y0*k,ox+mk.x1*k,oy+mk.y1*k];
                out.orbs.push({branch:mk.branch,err:Math.max(Math.abs(b.left-ex[0]),Math.abs(b.top-ex[1]),Math.abs(b.right-ex[2]),Math.abs(b.bottom-ex[3])),attrs:el.hasAttribute('data-c')&&el.hasAttribute('data-t')&&el.hasAttribute('data-branch')});}
              out.nTeeth=FVPanel.model.R.m;return out;});
            ok(tag+' R17 '+tab+' '+label+': every tooth dot ('+r.dots.length+' of '+r.nTeeth+') has an overlay element with data-role, data-c, data-t, within 1 px of the canvas-drawn position (max '+Math.max(0,...r.dots.map(d=>d.err)).toFixed(3)+' px), pixel drawn',r.dots.length===r.nTeeth&&r.attrs&&r.bad.length===0&&r.dots.every(d=>d.err<=1&&d.lit),JSON.stringify(r).slice(0,400));
            ok(tag+' R17 '+tab+' '+label+': every branch orbit/trail ('+r.orbs.length+') has an overlay element with data-role, data-c, data-branch, data-t, its box within 1 px of the drawn curve (max '+Math.max(0,...r.orbs.map(d=>d.err)).toFixed(3)+' px)',r.orbs.length>=1&&r.orbs.every(o=>o.err<=1&&o.attrs),JSON.stringify(r.orbs));
            if(tab==='hopf')ok(tag+' R17 hopf '+label+': every walk vertex ('+r.verts.length+') has an overlay element with data-role and data-t within 1 px of the canvas-drawn position (max '+Math.max(0,...r.verts.map(d=>d.err)).toFixed(3)+' px)',r.verts.length>=2&&r.verts.every(d=>d.err<=1),JSON.stringify(r.verts).slice(0,300));
          };
          await chk('at rest');
          await pg.evaluate(async()=>{const T=window.__t,[x0,y0]=T.centre();let x=x0,y=y0;T.pe('pointerdown',1,x,y);for(let i=0;i<25;i++){x+=7;y+=3;T.pe('pointermove',1,x,y);await T.fr();}T.pe('pointerup',1,x,y);await T.fr();await T.fr();});
          await chk('after a camera drag');
        }
        await pg.goto(url+reproAddr);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await pg.evaluate(lib);await pg.waitForTimeout(200);
        // slider drag: cards at most 4 per second, preview marker while dragging, exact on release; each card shows the state of its last update
        {
          await pg.evaluate(()=>{FVPanel.dial({tab:'clifford'});FVPanel.dial({view:''});});await pg.waitForTimeout(300);
          const r=await pg.evaluate(async()=>{const T=window.__t,el=document.getElementById('phi_sl');const n0=FVPanel.perf.cardsN,t0=performance.now();let sawMarker=0,snap=null;
            for(let i=0;i<40;i++){el.value=String(1+(i*3)%24);el.dispatchEvent(new Event('input',{bubbles:true}));await T.fr();await new Promise(r=>setTimeout(r,20));
              if(document.getElementById('cards').hasAttribute('data-preview'))sawMarker++;
              if(i===25)snap={addr:FVPanel.perf.cardsAddr,canon:T.canon(document.getElementById('cards'))};}
            const dur=(performance.now()-t0)/1000,upd=FVPanel.perf.cardsN-n0;
            const beforeRelease=T.canon(document.getElementById('cards'));
            el.dispatchEvent(new Event('change',{bubbles:true}));await T.fr();
            return {dur,upd,sawMarker,snap,markerAfter:document.getElementById('cards').hasAttribute('data-preview'),final:T.canon(document.getElementById('cards')),finalAddr:FVCombCore.encodeAddress(FVPanel.state),stale:beforeRelease!==T.canon(document.getElementById('cards'))};});
          ok(tag+' PERF2 slider drag: cards updated '+r.upd+' times in '+r.dur.toFixed(2)+' s (<= 4 per second plus the first), preview marker shown while dragging ('+r.sawMarker+' of 40 frames), gone after release',r.upd<=Math.ceil(r.dur*4)+1&&r.upd>=1&&r.sawMarker>=30&&!r.markerAfter,JSON.stringify({upd:r.upd,dur:r.dur,saw:r.sawMarker,after:r.markerAfter}));
          const fresh=async(addr)=>{const q=await ctx.newPage();await q.goto(url+addr);await q.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await q.waitForTimeout(200);
            const c=await q.evaluate(()=>{const f=n=>n.nodeType===3?n.data:n.nodeType===1?'<'+n.nodeName+[...n.attributes].map(a=>a.name+'='+a.value).sort().join(',')+'>'+[...n.childNodes].map(f).join('')+'</>':'';return [...document.getElementById('cards').childNodes].map(f).join('');});await q.close();return c;};
          const freshFinal=await fresh(r.finalAddr);
          ok(tag+' PERF2 after release every card equals a fresh computation for the final state (Phasors, flags, Wilson, Divisors, Shell: '+r.final.length+' characters of card markup compared)',r.final===freshFinal&&r.final.length>2000,r.final===freshFinal?'':'cards differ from the fresh page');
          const freshMid=await fresh(r.snap.addr);
          ok(tag+' PERF2 mid-drag the cards show exactly the state of their last update ('+r.snap.addr.slice(0,60)+'...), not a mixture',r.snap.canon===freshMid,r.snap.canon===freshMid?'':'mid-drag cards differ from a fresh page at the recorded update state');
        }
        // pair export still works after camera moves: PNG at full resolution plus exact JSON, hashes consistent
        {
          const r=await pg.evaluate(async()=>{const T=window.__t;document.querySelector('[data-act="expmenu"]').click();await T.fr();document.querySelector('[data-act="xpair"]').click();
            for(let i=0;i<60&&!/fv-comb-hopf-pair/.test(document.getElementById('xout').value);i++)await new Promise(r=>setTimeout(r,50));
            const p=JSON.parse(document.getElementById('xout').value),je=FVCombCore.exportExact(FVPanel.state,null,{witnessP:null});
            const cv=document.getElementById('stagecv'),cr=cv.getBoundingClientRect();
            return {schema:p.schema,exact:p.exact.sha256===FVExact.sha256Text(je),png:/^[0-9a-f]{64}$/.test(p.png.sha256),addr:p.address===FVCombCore.encodeAddress(FVPanel.state),full:cv.width===Math.round(cr.width*Math.min(devicePixelRatio,2))};});
          ok(tag+' PERF2 pair export (PNG + exact JSON + state) works after camera moves: schema, exact sha256 matches a fresh export, PNG hash present, address current, canvas at full resolution',r.schema==='fv-comb-hopf-pair/0.2'&&r.exact&&r.png&&r.addr&&r.full,JSON.stringify(r));
        }
      }
      await pg.close();
    }
    // first screen and visible-control counts, per tab, default state, nothing open (addenda 6 and 7: the flow of the original, not busy)
    for(const tab of ['fourier','clifford','hopf','panels']){
      const pg=await ctx.newPage();await pg.goto(url);await pg.waitForSelector('#tabs button');await pg.evaluate(t=>FVPanel.dial({tab:t}),tab);await pg.waitForTimeout(350);
      const m=await pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]');};
        const all=[...document.querySelectorAll('button,input,select')].filter(vis),inst=all.filter(e=>e.closest('#inst')||e.closest('.header')),q=a=>a.filter(e=>!e.classList.contains('info'));
        const box=id=>{const e=document.getElementById(id),r=e.getBoundingClientRect();return {t:r.top,b:r.bottom,vis:r.height>0};};
        return {total:all.length,totalNoInfo:q(all).length,inst:inst.length,instNoInfo:q(inst).length,infos:all.length-q(all).length,instInfos:inst.length-q(inst).length,buttons:all.filter(e=>e.tagName==='BUTTON').length,inputs:all.filter(e=>e.tagName==='INPUT').length,selects:all.filter(e=>e.tagName==='SELECT').length,
          frame:box('frame'),phi:box('phirow'),s:box('srow'),tr:box('transport'),vh:innerHeight};});
      await pg.screenshot({path:path.join(root,'shot_v02_'+tab+'_'+tag+'.png')});
      console.log('CONTROLS '+tag+' '+tab+': page '+m.total+' with (i), '+m.totalNoInfo+' without; instrument panel + header '+m.inst+' with (i), '+m.instNoInfo+' without ('+m.buttons+' buttons, '+m.inputs+' inputs, '+m.selects+' selects in the page)');
      ok(tag+' '+tab+': visible controls in the instrument panel with (i) excluded <= 40 (addendum 7 F1): '+m.instNoInfo+' (with (i) '+m.inst+'; whole page '+m.totalNoInfo+' / '+m.total+')',tab==='panels'?m.total>0:m.instNoInfo<=40,JSON.stringify(m));
      if(w<500&&tab!=='panels')ok(tag+' '+tab+' first screen: view frame ('+Math.round(m.frame.t)+'-'+Math.round(m.frame.b)+'), phi3 row (to '+Math.round(m.phi.b)+'), s row (to '+Math.round(m.s.b)+') and transport (to '+Math.round(m.tr.b)+') all inside the first '+m.vh+' px',m.frame.vis&&m.frame.t>=0&&m.tr.b<=m.vh&&m.phi.b<=m.vh&&m.s.b<=m.vh,JSON.stringify(m));
      await pg.close();
    }
    await ctx.close();
  }
  await browser.close();
  console.log('smallest text measured in this run: '+minFont.toFixed(4)+' px');
  console.log(`browser-check: ${pass} passed, ${fail} failed`);process.exit(fail?1:0);
})().catch(e=>{console.error(e);process.exit(2);});
