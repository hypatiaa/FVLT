'use strict';
// Camera / drag / first-render bench (performance round 2). Usage: node perf-camera.cjs [url] ; JSON for 1x and 4x CPU throttle.
// Camera: 60 synthetic pointer/wheel events, one per animation frame, at the reproduction state. fps = 60 / total seconds (frame-rate limited at about 58 on this harness).
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
async function run(throttle){
  const browser=await chromium.launch(),out={throttle};
  const ctx=await browser.newContext({viewport:{width:1280,height:800},deviceScaleFactor:1}),page=await ctx.newPage();
  const cdp=await ctx.newCDPSession(page);const errs=[];page.on('pageerror',e=>errs.push(String(e)));
  await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  const hash=await page.evaluate(([R])=>{FVPanel.dial(R);FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));FVPanel.dial({tab:'clifford'});return location.hash;},[REPRO]);
  const base=url.split('#')[0];
  // ---- first render: page load to the first frame presented after the first full render, per tab
  const tabs=['clifford','fourier','hopf','panels'];
  const firstFrame=async(h)=>{const r=[];for(let i=0;i<3;i++){const p=await ctx.newPage();const c=await ctx.newCDPSession(p);await c.send('Emulation.setCPUThrottlingRate',{rate:throttle});
    await p.addInitScript(()=>{window.__ff=null;const poll=()=>{if(window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0)requestAnimationFrame(()=>{window.__ff=performance.now();});else requestAnimationFrame(poll);};requestAnimationFrame(poll);});
    await p.goto(base+h);await p.waitForFunction(()=>window.__ff!==null);
    r.push(await p.evaluate(()=>({ff:window.__ff,init:(performance.getEntriesByName('fv-init')[0]||{}).duration,init0:(performance.getEntriesByName('fv-init')[0]||{}).startTime})));await p.close();}
    return {firstFrame:+med(r.map(x=>x.ff)).toFixed(0),initJs:+med(r.map(x=>x.init)).toFixed(0),initStart:+med(r.map(x=>x.init0)).toFixed(0)};};
  out.first={};
  out.first.default_fourier=await firstFrame('');
  for(const t of tabs){const h=await page.evaluate(([t])=>FVCombCore.encodeAddress({...FVPanel.state,tab:t}),[t]);out.first['repro_'+t]=await firstFrame(h);}
  await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  await cdp.send('Emulation.setCPUThrottlingRate',{rate:throttle});
  const cam=(kind)=>page.evaluate(async([kind])=>{
    const frame=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
    const svg=document.getElementById('stage'),rc=svg.getBoundingClientRect(),x0=rc.left+rc.width/2,y0=rc.top+rc.height/2;
    const pe=(type,id,x,y,sh)=>svg.dispatchEvent(new PointerEvent(type,{pointerId:id,clientX:x,clientY:y,bubbles:true,cancelable:true,shiftKey:!!sh,button:0,buttons:type==='pointerup'?0:1,isPrimary:id===1,pointerType:'mouse'}));
    await frame();const per=[];const n=60;let x=x0,y=y0,x2=x0+40,y2=y0;
    if(kind==='rotate'||kind==='pan')pe('pointerdown',1,x,y,kind==='pan');
    if(kind==='pinch'){pe('pointerdown',1,x0,y0);pe('pointerdown',2,x2,y2);}
    const t0=performance.now();
    for(let i=0;i<n;i++){const a=performance.now();
      if(kind==='rotate'||kind==='pan'){x+=3;y+=(i%2?1.5:-1.5);pe('pointermove',1,x,y,kind==='pan');}
      else if(kind==='wheel')svg.dispatchEvent(new WheelEvent('wheel',{deltaY:(Math.floor(i/6)%2)?100:-100,bubbles:true,cancelable:true,clientX:x0,clientY:y0}));
      else{x2+=(Math.floor(i/6)%2)?-3:3;pe('pointermove',2,x2,y2);}
      per.push(performance.now()-a);await frame();}
    const tEnd=performance.now();
    if(kind==='pinch'){pe('pointerup',2,x2,y2);pe('pointerup',1,x0,y0);}else if(kind!=='wheel')pe('pointerup',1,x,y);
    const r0=performance.now();await frame();const rel=performance.now()-r0;
    const s=[...per].sort((a,b)=>a-b);
    return {fps:60/((tEnd-t0)/1000),syncMed:s[30],syncMax:s[59],release:rel};},[kind]);
  out.camera={};
  for(const tab of ['clifford','hopf','fourier']){
    out.camera[tab]={};
    for(const kind of (tab==='hopf'?['rotate','wheel','pinch']:['rotate','wheel','pinch','pan'])){
      await page.evaluate(([R,tab])=>{FVPanel.dial({tab});FVPanel.dial({view:''});},[REPRO,tab]);
      if(tab==='fourier'&&kind==='rotate')continue;
      const rs=[];for(let i=0;i<3;i++)rs.push(await cam(kind));const f=k=>med(rs.map(r=>r[k]));out.camera[tab][kind]={fps:+f('fps').toFixed(1),fpsMin:+Math.min(...rs.map(r=>r.fps)).toFixed(1),syncMedMs:+f('syncMed').toFixed(1),syncMaxMs:+f('syncMax').toFixed(1),releaseMs:+f('release').toFixed(1)};}}
  // ---- slider drag fps (one input event per frame)
  const drag=(id,vals)=>page.evaluate(async([id,vals])=>{
    const frame=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
    const el=document.getElementById(id);await frame();const t0=performance.now();let n0=FVPanel.perf.cardsN||0;
    for(const v of vals){el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}));await frame();}
    const te=performance.now();el.dispatchEvent(new Event('change',{bubbles:true}));await frame();
    return {fps:vals.length/((te-t0)/1000),cardUpdates:(FVPanel.perf.cardsN||0)-n0,seconds:(te-t0)/1000};},[id,vals]);
  out.drag={};
  const phiVals=Array.from({length:30},(_,i)=>String(1+((i*3)%24))),sVals=Array.from({length:30},(_,i)=>(-2.4+0.16*i).toFixed(3));
  for(const tab of ['clifford','hopf','fourier'])for(const [id,vals] of [['phi_sl',phiVals],['s_sl',sVals]]){
    await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
    await page.evaluate(tab=>FVPanel.dial({tab}),tab);await cdp.send('Emulation.setCPUThrottlingRate',{rate:throttle});
    const rs=[];for(let i=0;i<3;i++){await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await page.evaluate(tab=>FVPanel.dial({tab}),tab);await cdp.send('Emulation.setCPUThrottlingRate',{rate:throttle});rs.push(await drag(id,vals));}
    out.drag[tab+'_'+id]={fps:+med(rs.map(r=>r.fps)).toFixed(1),fpsMin:+Math.min(...rs.map(r=>r.fps)).toFixed(1),cardUpdates:med(rs.map(r=>r.cardUpdates)),seconds:+med(rs.map(r=>r.seconds)).toFixed(2)};}
  out.errors=errs;await browser.close();return out;
}
(async()=>{const o=[];for(const t of [1,4])o.push(await run(t));console.log(JSON.stringify(o,null,1));})();
