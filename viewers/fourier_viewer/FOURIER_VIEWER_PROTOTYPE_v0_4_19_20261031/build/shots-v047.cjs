'use strict';
// v0.4.7 shots: Fourier and Hopf base at alpha_Tilt = -1, -0.6, 0, +1 for B = 6 (n1 = 3), m = 7, N = 5, s = 1; 1280x800 and 375x812.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
const CC=require('../host-core/comb-core.js');
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    for(const tab of ['fourier','hopf'])for(const [t,name] of [['-1','m1'],['-3/5','m0p6'],['','0'],['1','p1']]){
      const hash=CC.encodeAddress(CC.initial({shellMode:'factorial',n1:'3',phi3:'2',m:'7',t1:'1',t2:'1',sTyped:'1',tab}))+(t?'&tilt='+t:'');
      await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(500);
      await pg.evaluate(()=>window.scrollTo(0,0));
      await pg.screenshot({path:path.join(root,'shot_v047_'+tag+'_'+tab+'_tilt_'+name+'.png')});
    }
    await ctx.close();
  }
  await browser.close();console.log('shots done');
})();
