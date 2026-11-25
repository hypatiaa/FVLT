'use strict';
// v0.4.14 shots: the Goldbach track, Fourier (pen = G_N, ghosted teeth) and Clifford (Goldbach tori on one leaf), N = 24 (s = 4/3, near-zero pen) and N = 30 (s = 15/4), at 1280x800 and 375x812.
const path=require('path');const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
const CC=require('../host-core/comb-core.js'),GB=require('../host-core/goldbach-core.js');
(async()=>{const b=await chromium.launch();
  for(const [w,h] of [[1280,800],[375,812]]){const ctx=await b.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    for(const [N,s] of [[24,'4/3'],[30,'15/4'],[60,'1/7']])for(const tab of ['fourier','clifford']){
      const a=CC.encodeAddress(CC.initial({...GB.patchFor(N),sTyped:s,sEff:s,tab}))+'&gb=1';await pg.goto('about:blank');await pg.goto(url+a);
      await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(700);
      const bx=await pg.evaluate(()=>{const c=document.getElementById('caption').getBoundingClientRect(),f=document.getElementById('frame').getBoundingClientRect(),sy=window.scrollY;return {x:0,y:Math.max(0,c.top+sy-4),w:document.documentElement.clientWidth,h:f.bottom-c.top+8};});
      await pg.screenshot({path:path.join(root,'shot_v0414_'+w+'x'+h+'_'+tab+'_N'+N+'.png'),fullPage:true,clip:{x:bx.x,y:bx.y,width:bx.w,height:bx.h}});}
    await ctx.close();}
  await b.close();console.log('shots done');})();
