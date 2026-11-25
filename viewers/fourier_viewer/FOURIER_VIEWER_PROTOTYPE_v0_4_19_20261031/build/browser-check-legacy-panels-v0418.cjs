'use strict';
// v0.4.18 legacy-panels check (brief part F; after the verifier's stripped variant of v0.4.17): the v0.4.18 page equals the v0.4.16 page once every card
// added in v0.4.17 or v0.4.18 is removed. Removed from the v0.4.18 Panels tab before the comparison, and nothing else:
//   the <details> elements of elliptic-points-exact, period-lattice-exact (v0.4.17), pen-curvature-exact, pen-sphere-exact (v0.4.18);
//   the group heading element "E. Surface pens (exact)" (v0.4.18);
//   and the decided group-D heading text "D. Elliptic and BSD" is mapped back to v0.4.16's "D. Elliptic and BSD (placement pending saphir)" (fix-up 1).
// Also: the other tabs are identical (stage, caption, cards, address), and with D1 on, the cards differ only by the one "see also" paragraph.
// Both pages render in the same browser on the same host. The v0.4.16 page is read only (sha256 pinned). Location: FV_ROOT (default C:/Users/robin/s6_atom).
const path=require('path'),fs=require('fs'),crypto=require('crypto'),{pathToFileURL}=require('url');
const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
const CC=require('../host-core/comb-core.js');
const root=path.join(__dirname,'..'),FV_ROOT=process.env.FV_ROOT||'C:/Users/robin/s6_atom';
const OLD=path.join(FV_ROOT,'FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028','dist','comb-hopf.html'),OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
const url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href,url416=pathToFileURL(OLD).href;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=o=>CC.encodeAddress(CC.initial(o));
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);};
const NEW=/<details class="pmod" data-panel="(elliptic-points-exact|period-lattice-exact|pen-curvature-exact|pen-sphere-exact)"[^>]*>[\s\S]*?<\/details>/g;
const EHEAD='<div class="panel-label" style="margin-top:10px">E. Surface pens (exact)</div>';
const strip=h=>h.replace(NEW,'').split(EHEAD).join('').split('>D. Elliptic and BSD<').join('>D. Elliptic and BSD (placement pending saphir)<');
const SEEALSO=/<p class="note dim" data-role="r30-seealso">[\s\S]*?<\/p>/;
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,caption:document.getElementById('caption').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hstage:document.getElementById('htmlstage').innerHTML}));
(async()=>{
  ok('v0.4.16 reference page present and unchanged (sha256 1da7dc8f…) at '+OLD,fs.existsSync(OLD)&&crypto.createHash('sha256').update(fs.readFileSync(OLD)).digest('hex')===OLDSHA);
  const browser=await PW.chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500});
    const ST=[{tab:'panels'},{tab:'panels',shellMode:'integer',B:'24'},{tab:'panels',shellMode:'factorial',n1:'7',B:'5040'},{tab:'fourier'},{tab:'clifford'},{tab:'hopf'},{tab:'clifford',shellMode:'factorial',n1:'4'}];
    let same=0;const bad=[];
    for(const o of ST){const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,addr(o),url416);await gopen(pb,addr(o));const x=await snap(pa),y=await snap(pb);
      const removed=(y.hstage.match(NEW)||[]).length,ks=['stage','caption','cards','addr'].filter(k=>x[k]!==y[k]),hs=o.tab==='panels'?x.hstage===strip(y.hstage)&&removed===4&&y.hstage.includes(EHEAD):x.hstage===y.hstage;
      if(!ks.length&&hs)same++;else bad.push(JSON.stringify(o)+' fields:'+ks.join('+')+(hs?'':' hstage')+' removed='+removed);await pa.close();await pb.close();}
    ok(tag+' identical to v0.4.16 on '+ST.length+' states (stage, caption, cards, address, html stage); on the Panels tab after removing the 4 cards of v0.4.17/v0.4.18, the group-E heading, and mapping the decided D heading back',same===ST.length,bad.join(' | '));
    {const pa=await ctx.newPage(),pb=await ctx.newPage(),o={tab:'clifford',view:'rl=1'};await gopen(pa,addr(o),url416);await gopen(pb,addr(o));const x=await snap(pa),y=await snap(pb);
      ok(tag+' D1 on: stage, caption, address identical to v0.4.16; the cards differ only by the one "see also" paragraph of D1',x.stage===y.stage&&x.caption===y.caption&&x.addr===y.addr&&x.cards===y.cards.replace(SEEALSO,'')&&SEEALSO.test(y.cards)&&x.cards!==y.cards);await pa.close();await pb.close();}
    await ctx.close();}
  await browser.close();
  console.log('SUMMARY browser-check-legacy-panels-v0418: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
})().catch(e=>{console.error(e);process.exit(1);});
