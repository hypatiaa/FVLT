'use strict';
// v0.4.18 screenshots: the group E pen cards and the fixed group-D cards, at 1280x800 and 375x812 (card element shots; groupE_closed is a viewport shot).
// File names: shot_v0418_<os>_<viewport>_<name>.png, <os> = linux on membrane, win on Neo. Portable playwright resolution as in browser-check-v0418.
const path=require('path'),{pathToFileURL}=require('url');
const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
const CC=require('../host-core/comb-core.js');
const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href,OS=process.platform==='linux'?'linux':'win';
const addr=o=>CC.encodeAddress(CC.initial(o));
const gopen=async(pg,hash)=>{await pg.goto('about:blank');await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);};
const setDial=(pg,role,v)=>pg.evaluate(([r,v])=>{const x=document.querySelector('[data-role="'+r+'"]');if(!x)return false;if(x.type==='checkbox')x.checked=v==='1';else x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));return true;},[role,String(v)]);
const open=(pg,ids)=>pg.evaluate(ids=>{for(const id of ids){const d=document.querySelector('details[data-panel="'+id+'"]');if(d&&!d.open)d.open=true;}},ids);
(async()=>{
  const browser=await PW.chromium.launch();const made=[];
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    // the element is looked up again for every attempt (a re-render may replace it); three attempts, 300 ms apart
    const shot=async(sel,name)=>{const f='shot_v0418_'+OS+'_'+tag+'_'+name+'.png';for(let k=0;k<3;k++){await pg.waitForTimeout(300);const el=await pg.$(sel);if(!el)continue;try{await el.screenshot({path:path.join(root,f)});made.push(f);return;}catch(e){}}console.log('MISSING '+name);};
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>localStorage.clear());await gopen(pg,addr({tab:'panels'}));
    await pg.evaluate(()=>{const l=[...document.querySelectorAll('#htmlstage .panel-label')].find(e=>/^E\./.test(e.textContent));if(l)l.scrollIntoView();});await pg.waitForTimeout(200);
    {const f='shot_v0418_'+OS+'_'+tag+'_panels_groupE_closed.png';await pg.screenshot({path:path.join(root,f)});made.push(f);}
    await open(pg,['pen-curvature-exact','pen-sphere-exact']);await pg.waitForTimeout(500);
    const C='details[data-panel="pen-curvature-exact"]',S='details[data-panel="pen-sphere-exact"]';
    await shot(C,'curv_r30_T512');await shot(S,'sph_r30_T512');
    await setDial(pg,'pen-stream','150');await setDial(pg,'pen-T','4096');await shot(C,'curv_r150_T4096');
    await setDial(pg,'pen-stream','30');await shot(C,'curv_r30_T4096');
    await setDial(pg,'pen-follow','0');await shot(C,'curv_r30_T4096_absolute');await setDial(pg,'pen-follow','1');
    await setDial(pg,'pen-T','1328');await shot(S,'sph_r30_T1328');
    await setDial(pg,'pen-preset','dodeca');await shot(S,'sph_dodeca_r30_T1328');await setDial(pg,'pen-preset','free');
    await setDial(pg,'pen-stream','gbshell');await setDial(pg,'pen-N','1448');await shot(C,'curv_gbshell_1448');
    await setDial(pg,'pen-N','24');await shot(C,'curv_gbshell_24');
    await setDial(pg,'pen-stream','gbrun');await setDial(pg,'pen-Nmax','1448');await shot(C,'curv_gbrun_1448');await shot(S,'sph_gbrun_1448');
    await setDial(pg,'pen-stream','30');await setDial(pg,'pen-T','0');await shot(C,'curv_T0');await setDial(pg,'pen-T','512');
    // group D fix-ups
    await gopen(pg,addr({tab:'panels'}));await open(pg,['elliptic-points-exact','period-lattice-exact']);await pg.waitForTimeout(300);
    const E='details[data-panel="elliptic-points-exact"]';
    await setDial(pg,'ell-p','5');await shot('[data-role="ell-cases"]','ell_cases_p5');
    await pg.evaluate(()=>{for(const r of ['ell-p1','ell-p2']){const x=document.querySelector('[data-role="'+r+'"]');x.selectedIndex=1;x.dispatchEvent(new Event('change',{bubbles:true}));}});await shot('[data-role="ell-scatter"]','ell_p5_P1eqP2');
    await setDial(pg,'ell-p','97');await shot('[data-role="ell-scatter"]','ell_p97_zoom1');
    await setDial(pg,'ell-zoom','2');await shot('[data-role="ell-scatter"]','ell_p97_zoom2');
    await setDial(pg,'ell-zoom','4');await shot('[data-role="ell-scatter"]','ell_p97_zoom4');await setDial(pg,'ell-zoom','1');
    await setDial(pg,'per-curve','11a1');await shot('details[data-panel="period-lattice-exact"]','per_11a1_refused');await setDial(pg,'per-curve','37a1');
    await shot(E,'ell_points_card_p97');
    await ctx.close();}
  await browser.close();console.log(made.join('\n'));console.log('SUMMARY shots-v0418: '+made.length+' screenshots');
})().catch(e=>{console.error(e);process.exit(1);});
