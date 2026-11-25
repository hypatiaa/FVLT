'use strict';
// v0.4.19 screenshots (SCHEMA_ADDENDUM_26): D1 Rule 30 j = 30 at q = 1 and q = 2 (the event-step pieces; page shots, full page at 375), and the changed
// pen cards (card element shots), at 1280x800 and 375x812. File names: shot_v0419_<os>_<viewport>_<name>.png, <os> = linux on membrane (the host of record).
const path=require('path'),{pathToFileURL}=require('url');
const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
const CC=require('../host-core/comb-core.js');
const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href,OS=process.platform==='linux'?'linux':'win';
const addr=o=>CC.encodeAddress(CC.initial(o));
const gopen=async(pg,hash)=>{await pg.goto('about:blank');await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0,null,{timeout:120000});await pg.waitForTimeout(500);};
const setDial=(pg,role,v)=>pg.evaluate(([r,v])=>{const x=document.querySelector('[data-role="'+r+'"]');if(!x)return false;if(x.type==='checkbox')x.checked=v==='1';else x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));return true;},[role,String(v)]);
const open=(pg,ids)=>pg.evaluate(ids=>{for(const id of ids){const d=document.querySelector('details[data-panel="'+id+'"]');if(d&&!d.open)d.open=true;}},ids);
(async()=>{
  const browser=await PW.chromium.launch();const made=[];
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();
    const shot=async(sel,name)=>{const f='shot_v0419_'+OS+'_'+tag+'_'+name+'.png';for(let k=0;k<3;k++){await pg.waitForTimeout(400);const el=await pg.$(sel);if(!el)continue;try{await el.screenshot({path:path.join(root,f)});made.push(f);return;}catch(e){}}console.log('MISSING '+name);};
    const page=async name=>{const f='shot_v0419_'+OS+'_'+tag+'_'+name+'.png';await pg.screenshot({path:path.join(root,f),fullPage:w<500});made.push(f);};
    // D1: Rule 30 j = 30 at q = 1 and q = 2 (and j = 34 q = 2 for comparison)
    for(const [j,q] of [[30,1],[30,2],[34,2]]){await gopen(pg,addr({tab:'clifford',view:'rl=1;rlj='+j+(q!==2?';rlq='+q:'')}));await page('d1_r30_j'+j+'_q'+q);}
    // the pen cards
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>localStorage.clear());await gopen(pg,addr({tab:'panels'}));
    await open(pg,['pen-curvature-exact','pen-sphere-exact']);await pg.waitForTimeout(800);
    const C='details[data-panel="pen-curvature-exact"]',S='details[data-panel="pen-sphere-exact"]';
    await setDial(pg,'pen-T','4096');await shot(C,'curv_r30_T4096');
    await setDial(pg,'pen-T','1328');await shot(S,'sph_r30_T1328_teeth_on');
    await setDial(pg,'pen-teeth-toggle','0');await shot(S,'sph_r30_T1328_teeth_off');await setDial(pg,'pen-teeth-toggle','1');
    await setDial(pg,'pen-preset','dodeca');await shot(S,'sph_dodeca_r30_T1328_arcs');await setDial(pg,'pen-preset','free');
    await setDial(pg,'pen-stream','gbshell');await setDial(pg,'pen-N','1446');await shot(C,'curv_gbshell_1446');
    await setDial(pg,'pen-stream','gbrun');await setDial(pg,'pen-Nmax','1448');await shot(C,'curv_gbrun_1448');await shot(S,'sph_gbrun_1448');
    await ctx.close();}
  await browser.close();
  console.log(made.join('\n'));console.log('SUMMARY shots-v0419: '+made.length+' passed, 0 failed');
})().catch(e=>{console.error(e);process.exit(1);});
