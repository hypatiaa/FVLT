'use strict';
// v0.4.16 screenshots (SCHEMA_ADDENDUM_23): the D1 Rule 30 ladder card on the Clifford tab, 1280x800 and 375x812. Page only (full page at 375 so the card shows).
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const CC=require('../host-core/comb-core.js');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
const addr=view=>CC.encodeAddress(CC.initial({tab:'clifford',view}));
const CASES=[['r30_j3_q2','rl=1'],['r30_j5_q2','rl=1;rlj=5'],['r90_j3_q2','rl=1;rlr=90'],['r30_j3_q1','rl=1;rlq=1'],['r30_j3_q4','rl=1;rlq=4'],['r30_j3_q8','rl=1;rlq=8'],['r30_j0_q2','rl=1;rlj=0'],['r30_j15_q8','rl=1;rlj=15;rlq=8'],['r150_j7_q4','rl=1;rlr=150;rlj=7;rlq=4']];
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    for(const [name,view] of CASES){await pg.goto('about:blank');await pg.goto(url+addr(view));await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(400);
      const f=path.join(root,'shot_v0416_'+tag+'_'+name+'.png');await pg.screenshot({path:f,fullPage:w<500});console.log('wrote '+path.basename(f));}
    // the Layers menu open with the D1 dials (both sizes)
    await pg.goto('about:blank');await pg.goto(url+addr('rl=1'));await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);
    await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(300);
    const f=path.join(root,'shot_v0416_'+tag+'_r30_layers_menu.png');await pg.screenshot({path:f});console.log('wrote '+path.basename(f));
    await ctx.close();}
  await browser.close();
})().catch(e=>{console.error(e);process.exit(1);});
