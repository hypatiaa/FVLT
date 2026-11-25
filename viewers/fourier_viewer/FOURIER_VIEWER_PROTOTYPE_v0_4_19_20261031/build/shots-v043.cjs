'use strict';
// v0.4.3: mid-drag screenshots of v0.4.2 vs v0.4.3, Clifford view, same state and same drag. The 200 ms idle timer that ends "moving" is held off during the shot (page setTimeout wrapper), so the picture is the moving frame.
// Usage: node shots-v043.cjs <outdir>
const path=require('path');const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const out=process.argv[2],S='C:/Users/robin/s6_atom/';
const U={v042:'file:///'+S+'FOURIER_VIEWER_PROTOTYPE_v0_4_2_20261019/dist/comb-hopf.html',v043:'file:///'+S+'FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019/dist/comb-hopf.html'};
const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,dsf,tag] of [[1280,800,1,'1280x800'],[375,812,2,'375x812']]){
    for(const v of ['v042','v043']){
      const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:dsf,hasTouch:w<500}),page=await ctx.newPage();
      await page.goto(U[v]);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
      await page.evaluate(([R])=>{FVPanel.dial(R);FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));FVPanel.dial({tab:'clifford'});
        const st=window.setTimeout;window.setTimeout=function(f,d,...a){if(d===200&&window.__hold)return 0;return st.call(window,f,d,...a);};},[REPRO]);
      await page.waitForTimeout(500);
      const box=await page.evaluate(()=>{const r=document.getElementById('stage').getBoundingClientRect();return {x:r.left+r.width/2,y:r.top+r.height/2,l:r.left,t:r.top,w:r.width,h:r.height};});
      await page.evaluate(()=>{window.__hold=true;});
      await page.mouse.move(box.x,box.y);await page.mouse.down();
      for(let i=1;i<=14;i++)await page.mouse.move(box.x+i*7,box.y+i*3);
      await page.waitForTimeout(250);
      const st=await page.evaluate(()=>{const cv=document.getElementById('stagecv');return {moving:FVViews.layer.moving,bm:cv.width+'x'+cv.height};});
      const f=path.join(out,'shot_v043_'+tag+'_clifford_middrag_'+v+'.png');
      await page.screenshot({path:f});
      // zoomed crop: the middle of the stage, 3x nearest-neighbour
      const cx=Math.max(0,Math.round(box.x-80)),cy=Math.max(0,Math.round(box.y-60));
      const buf=await page.screenshot({clip:{x:cx,y:cy,width:160,height:120}});
      const pg2=await ctx.newPage();await pg2.setViewportSize({width:160*3,height:120*3});
      await pg2.setContent('<body style="margin:0;background:#000"><canvas id=c></canvas></body>');
      await pg2.evaluate(async(b64)=>{const im=new Image();im.src='data:image/png;base64,'+b64;await im.decode();const c=document.getElementById('c');c.width=480;c.height=360;const x=c.getContext('2d');x.imageSmoothingEnabled=false;x.drawImage(im,0,0,480,360);},buf.toString('base64'));
      await pg2.screenshot({path:path.join(out,'shot_v043_'+tag+'_clifford_middrag_zoom3x_'+v+'.png'),clip:{x:0,y:0,width:480,height:360}});
      console.log(tag,v,JSON.stringify(st));
      await page.mouse.up();await ctx.close();
    }
  }
  await browser.close();
})();
