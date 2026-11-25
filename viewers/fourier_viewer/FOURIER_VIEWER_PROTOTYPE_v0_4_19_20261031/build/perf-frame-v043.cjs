'use strict';
// v0.4.3: frame time while rotating (Clifford and Hopf). Usage: node perf-frame-v043.cjs <url> <width> <height> <dsf> <throttle> [runs]
// 90 synthetic pointer moves per run, one per animation frame, as perf-camera.cjs does; per-frame time = interval between consecutive frames. Reports median and p95 over all frames of all runs.
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const [url,W,H,DSF,THR,RUNS]=[process.argv[2],+process.argv[3],+process.argv[4],+process.argv[5],+process.argv[6],+(process.argv[7]||5)];
const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
const q=(a,p)=>{const s=[...a].sort((x,y)=>x-y);return s[Math.min(s.length-1,Math.floor(p*s.length))];};
(async()=>{
  const browser=await chromium.launch(),ctx=await browser.newContext({viewport:{width:W,height:H},deviceScaleFactor:DSF,hasTouch:W<500}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
  await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  await page.evaluate(([R])=>{FVPanel.dial(R);FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));},[REPRO]);
  await cdp.send('Emulation.setCPUThrottlingRate',{rate:THR});
  const out={url:url.split('/').slice(-3).join('/'),W,H,DSF,THR};
  for(const tab of ['clifford','hopf']){
    await page.evaluate(([tab])=>{FVPanel.dial({tab});},[tab]);await page.waitForTimeout(500);
    const all=[];let bm=null;
    for(let r=0;r<RUNS;r++){
      const res=await page.evaluate(async()=>{
        const frame=()=>new Promise(r=>requestAnimationFrame(()=>r()));
        const svg=document.getElementById('stage'),rc=svg.getBoundingClientRect(),x0=rc.left+rc.width/2,y0=rc.top+rc.height/2;
        const pe=(type,x,y)=>svg.dispatchEvent(new PointerEvent(type,{pointerId:1,clientX:x,clientY:y,bubbles:true,cancelable:true,button:0,buttons:type==='pointerup'?0:1,isPrimary:true,pointerType:'mouse'}));
        await frame();let x=x0,y=y0;pe('pointerdown',x,y);const fr=[];let last=performance.now(),bw=null;
        for(let i=0;i<90;i++){x+=3;y+=(i%2?1.5:-1.5);pe('pointermove',x,y);await frame();const t=performance.now();fr.push(t-last);last=t;}
        const cv=document.getElementById('stagecv');bw=cv.width+'x'+cv.height;pe('pointerup',x,y);await frame();await frame();
        return {fr:fr.slice(5),bw};});
      all.push(...res.fr);bm=res.bw;await page.waitForTimeout(300);}
    out[tab]={medianMs:+q(all,0.5).toFixed(1),p95Ms:+q(all,0.95).toFixed(1),frames:all.length,movingBitmap:bm};
  }
  console.log(JSON.stringify(out));await browser.close();
})();
