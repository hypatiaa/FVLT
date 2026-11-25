'use strict';
// v0.4.3 browser check (SCHEMA_ADDENDUM_11): the canvas bitmap is full resolution while the camera moves (Clifford and Hopf), and after release;
// the 'surface' kind still yields half size (unit level, through FVViews.resFactor and a probe canvas).
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,dsf,tag] of [[1280,800,1,'1280x800 dsf1'],[375,812,2,'375x812 dsf2'],[1280,800,2,'1280x800 dsf2'],[375,812,1,'375x812 dsf1']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:dsf,hasTouch:w<500}),page=await ctx.newPage(),errs=[];
    page.on('pageerror',e=>errs.push(String(e)));
    await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
    // unit level
    const u=await page.evaluate(()=>({w:FVViews.resFactor('wireframe',true),d:FVViews.resFactor(undefined,true),s:FVViews.resFactor('surface',true),sIdle:FVViews.resFactor('surface',false),res:FVViews.MOVING_RES}));
    ok(tag+' unit: wireframe moving = 1, default kind = 1, surface moving = 0.5, surface at rest = 1',u.w===1&&u.d===1&&u.s===0.5&&u.sIdle===1,JSON.stringify(u));
    // surface kind through layerBegin/layerFit on a probe canvas of the stage size, moving
    const probe=await page.evaluate(()=>{const cv=document.getElementById('stagecv'),r=cv.getBoundingClientRect(),V=FVViews,save={m:V.layer.moving,rw:V.layer.rw,rh:V.layer.rh};
      const pc=document.createElement('canvas');pc.style.cssText='position:fixed;left:0;top:0;width:'+r.width+'px;height:'+r.height+'px;visibility:hidden';document.body.appendChild(pc);
      V.layer.moving=true;V.layer.rw=0;V.layer.rh=0;
      V.layerBegin(pc,100,100,'surface');const sw=pc.width,sh=pc.height,fitS=V.layerFit(pc,'surface'),fitW=V.layerFit(pc);
      V.layerBegin(pc,100,100);const ww=pc.width,wh=pc.height,fitW2=V.layerFit(pc),fitS2=V.layerFit(pc,'surface');
      const d=Math.min(window.devicePixelRatio||1,2);pc.remove();V.layer.moving=save.m;V.layer.rw=save.rw;V.layer.rh=save.rh;
      return {sw,sh,ww,wh,ew:Math.round(r.width*d),eh:Math.round(r.height*d),hw:Math.max(1,Math.round(r.width*d*0.5)),hh:Math.max(1,Math.round(r.height*d*0.5)),fitS,fitW,fitW2,fitS2};});
    ok(tag+' unit: layerBegin(...,"surface") while moving gives round(size*dpr*0.5), layerBegin default gives round(size*dpr); layerFit agrees with the kind it was begun with',
      probe.sw===probe.hw&&probe.sh===probe.hh&&probe.ww===probe.ew&&probe.wh===probe.eh&&probe.fitS&&!probe.fitW&&probe.fitW2&&!probe.fitS2,JSON.stringify(probe));
    for(const tab of ['clifford','hopf']){
      await page.evaluate(([R,tab])=>{FVPanel.dial(R);FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));FVPanel.dial({tab});},[REPRO,tab]);
      await page.waitForTimeout(400);
      const size=()=>page.evaluate(()=>{const cv=document.getElementById('stagecv'),r=cv.getBoundingClientRect(),d=Math.min(window.devicePixelRatio||1,2);
        return {bw:cv.width,bh:cv.height,ew:Math.max(1,Math.round(r.width*d)),eh:Math.max(1,Math.round(r.height*d)),moving:!!FVViews.layer.moving,preview:!!FVViews.layer.preview,dpr:window.devicePixelRatio};});
      const s0=await size();
      ok(tag+' '+tab+' at rest: bitmap = round(displayed*min(dpr,2)) ('+s0.bw+'x'+s0.bh+')',s0.bw===s0.ew&&s0.bh===s0.eh,JSON.stringify(s0));
      const box=await page.evaluate(()=>{const r=document.getElementById('stage').getBoundingClientRect();return {x:r.left+r.width/2,y:r.top+r.height/2};});
      await page.mouse.move(box.x,box.y);await page.mouse.down();
      let allOk=true,seen=0,last=null;
      for(let i=1;i<=12;i++){await page.mouse.move(box.x+i*6,box.y+(i%2?4:-4));const s=await size();last=s;if(s.moving||s.preview)seen++;if(!(s.bw===s.ew&&s.bh===s.eh))allOk=false;}
      ok(tag+' '+tab+' mid-drag (mouse held, 12 moves): layer.moving/preview true in '+seen+' of 12 samples, and the bitmap is full resolution in all 12 ('+last.bw+'x'+last.bh+' vs expected '+last.ew+'x'+last.eh+')',seen>0&&allOk,JSON.stringify(last));
      await page.mouse.up();await page.waitForTimeout(500);
      const s2=await size();
      ok(tag+' '+tab+' after release: bitmap = round(displayed*min(dpr,2)), not moving ('+s2.bw+'x'+s2.bh+')',s2.bw===s2.ew&&s2.bh===s2.eh&&!s2.moving,JSON.stringify(s2));
    }
    ok(tag+' no page errors',errs.length===0,errs.join('|'));
    await ctx.close();
  }
  await browser.close();
  console.log('browser-check-v043: '+pass+' passed, '+fail+' failed');process.exit(fail?1:0);
})();
