'use strict';
// v0.4.17 screenshots (SCHEMA_ADDENDUM_24): the two group-D exact cards of the Panels tab, 1280x800 and 375x812. Card element shots, plus the group-D list.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const CC=require('../host-core/comb-core.js');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/')+CC.encodeAddress(CC.initial({tab:'panels'}));
const setDial=(pg,role,v)=>pg.evaluate(([r,v])=>{const x=document.querySelector('[data-role="'+r+'"]');x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));},[role,String(v)]);
const PTS=[['points_k1_p5',[['ell-k',1],['ell-p',5]]],['points_k5_p5',[['ell-k',5]]],['points_k10_p5',[['ell-k',10]]],['points_k10_p37_bad',[['ell-p',37]]],['points_k10_p97',[['ell-p',97]]]];
const PER=[['period_D10',[['per-D',10]]],['period_D50',[['per-D',50]]],['period_D100',[['per-D',100]]],['period_11a1_refused',[['per-curve','11a1']]]];
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    await pg.goto(url);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.evaluate(()=>localStorage.clear());
    await pg.goto('about:blank');await pg.goto(url);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);
    // the group-D list, cards closed (fresh page)
    {const f=path.join(root,'shot_v0417_'+tag+'_panels_groupD_closed.png');await pg.locator('details[data-panel="mcomb-elliptic-bsd"]').scrollIntoViewIfNeeded();await pg.screenshot({path:f});console.log('wrote '+path.basename(f));}
    await pg.evaluate(()=>{for(const id of ['elliptic-points-exact','period-lattice-exact'])document.querySelector('details[data-panel="'+id+'"]').open=true;});await pg.waitForTimeout(400);
    for(const [card,list] of [['elliptic-points-exact',PTS],['period-lattice-exact',PER]])for(const [name,dials] of list){
      for(const [r,v] of dials)await setDial(pg,r,v);await pg.waitForTimeout(200);
      const f=path.join(root,'shot_v0417_'+tag+'_'+name+'.png');await pg.locator('details[data-panel="'+card+'"]').screenshot({path:f});console.log('wrote '+path.basename(f));}
    await ctx.close();}
  await browser.close();
})().catch(e=>{console.error(e);process.exit(1);});
