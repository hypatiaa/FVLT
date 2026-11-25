'use strict';
// v0.4.8 check (SCHEMA_ADDENDUM_16): shorter tilt wording in the Fourier caption; Q-res visible at 1280x800; tilt 0 identical to v0.4.7; Panels relabel; shots.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url47=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_7_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(400);};
const A=(o,t)=>CC.encodeAddress(CC.initial(o))+(t?'&tilt='+t:'');
const base=tab=>({shellMode:'factorial',n1:'3',phi3:'2',m:'7',t1:'1',t2:'1',sTyped:'1',tab});
const cap=pg=>pg.evaluate(()=>{const p=document.querySelector('#caption p.ell');if(!p)return null;const tn=p.firstChild,i=tn.data.indexOf('Q-res'),k=tn.data.indexOf('(numerical)')+11;let vis=false;if(i>=0&&k>11){const r=document.createRange();r.setStart(tn,i);r.setEnd(tn,k);vis=r.getBoundingClientRect().right<=p.getBoundingClientRect().right+0.5;}return {t:p.innerText,over:!vis,full:p.scrollWidth>p.clientWidth+1};});
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    for(const [t,name] of [['-1','m1'],['-3/5','m0p6'],['1','p1']]){
      await gopen(pg,A(base('fourier'),t));const c=await cap(pg);
      ok(tag+' tilt '+t+': new wording, no old wording',c&&/★ teeth conjugate \(t₁·s ∈ ℤ\); walk not real · Q-res /.test(c.t)&&!/pair phases|in general/.test(c.t),c&&c.t);
      if(w===1280)ok(tag+' tilt '+t+': Q-res part "Q-res x (numerical)" fully visible (not cut by the ellipsis)',c&&!c.over,c&&c.t);
      if(t==='-1'||t==='1'){await pg.evaluate(()=>window.scrollTo(0,0));const el=await pg.$('#caption');await pg.screenshot({path:path.join(root,'shot_v048_'+tag+'_fourier_caption_tilt_'+name+'.png'),clip:{x:0,y:Math.max(0,(await el.boundingBox()).y-8),width:w,height:Math.min(h,(await el.boundingBox()).height+16)}});}
      await gopen(pg,A(base('hopf'),t));const hc=await pg.evaluate(()=>[...document.querySelectorAll('#caption p.ell')].map(p=>({t:p.innerText,over:p.scrollWidth>p.clientWidth+1})));
      ok(tag+' hopf tilt '+t+': one-line caption has no star/Q-res text and is not cut'+(w===1280?'':' (375: wraps/ellipsis not required)'),hc.every(x=>!/★|Q-res/.test(x.t))&&(w!==1280||hc.every(x=>!x.over)),JSON.stringify(hc));
    }
    // tilt 0: byte-identical to v0.4.7
    const S=[base('fourier'),base('hopf'),{shellMode:'factorial',n1:'6',phi3:'719',m:'7',t1:'1',t2:'1',sTyped:'1',tab:'fourier'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'}];
    let same=0;const bad=[];
    for(const s of S){const hh=A(s),pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url47);await gopen(pb,hh);
      const f=p=>p.evaluate(()=>({c:document.getElementById('caption').innerHTML,a:document.getElementById('about').innerHTML,st:document.getElementById('stage').innerHTML}));
      const x=await f(pa),y=await f(pb);if(JSON.stringify(x)===JSON.stringify(y))same++;else bad.push(hh);await pa.close();await pb.close();}
    ok(tag+' tilt 0: caption, about, stage byte-identical to v0.4.7 ('+same+'/'+S.length+')',same===S.length,bad.join('|'));
    // Panels relabel and long wording kept
    await gopen(pg,A(base('panels'),'1'));const pt=await pg.evaluate(()=>document.body.innerText);
    ok(tag+' Panels at tilt 1: relabel "(teeth only; the tilted walk is not mirror-symmetric)" present',/teeth only; the tilted walk is not mirror-symmetric/.test(pt));
    await pg.close();await ctx.close();
  }
  await browser.close();console.log('v0.4.8 browser check: '+pass+' pass / '+fail+' fail');process.exit(fail?1:0);
})();
