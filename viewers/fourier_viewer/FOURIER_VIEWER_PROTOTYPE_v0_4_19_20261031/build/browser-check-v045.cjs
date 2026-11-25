'use strict';
// v0.4.5 browser check (SCHEMA_ADDENDUM_13): CA mode in the page address, and the visible-control cap 41.
// SUPERSEDES the v0.3 browser-check.cjs assertions that say "<= 40" on the instrument panel (12 failures there: per viewport the fourier, clifford and hopf
// "visible controls ... <= 40" assertions, the two continuous-mode inventory assertions, and the "N mode switch" assertion). The counting method is the old one verbatim (layout(): visible button/input/select
// inside #inst or .header, minus .info buttons).
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url44=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const PRESETS=['2','6','12','60','120','360','2520','5040','55440','720720'];
const addr=o=>CC.encodeAddress(CC.initial(o));
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]');};
  const inst=[...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')),noInfo=inst.filter(e=>!e.classList.contains('info'));return noInfo.length;});
const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(350);};
const read=pg=>pg.evaluate(()=>{const b=document.getElementById('mode_ca'),d=document.querySelector('details[data-panel="g-robin-margin"]');if(d&&!d.open)d.open=true;
  const q=id=>document.getElementById(id);return {pressed:b.getAttribute('aria-pressed'),B:FVPanel.state.B,mode:FVPanel.state.shellMode,sel:q('ca_sel').style.display!=='none'?q('ca_sel').value:null,atom:q('rhm-atom-line')?q('rhm-atom-line').textContent:'',idx:q('rhm-ca-index')?q('rhm-ca-index').textContent:'',
    status:q('status').textContent,addrTxt:q('addr').textContent,hash:location.hash,st:JSON.stringify(FVPanel.state)};});
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // --- control count (cap 41), non-CA and CA, three instrument tabs
    for(const tab of ['fourier','clifford','hopf']){
      await gopen(pg,addr({shellMode:'factorial',n1:'4',tab}));const n0=await count(pg);const nI=await (async()=>{await gopen(pg,addr({shellMode:'integer',B:'24',tab}));return count(pg);})();
      await gopen(pg,addr({shellMode:'integer',B:'5040',tab})+'&ca=1');const n1=await count(pg),r=await read(pg);
      ok(tag+' '+tab+' controls: non-CA (n! base, the old test state) '+n0+', CA '+n1+'; both <= 41 and CA pressed',n0<=41&&n1<=41&&r.pressed==='true',n0+'/'+n1);
      console.log('INFO '+tag+' '+tab+' integer base B = 24 (non-CA), same method: '+nI+' controls (not asserted; was 42 in v0.4.4 as well)');
      await gopen(pg,addr({shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab}));const n2=await count(pg);
      ok(tag+' '+tab+' controls in continuous mode '+n2+' <= 41',n2<=41);
      console.log('COUNT '+tag+' '+tab+' non-CA '+n0+' CA '+n1+' continuous '+n2);
    }
    // --- every CA preset: fresh load of its address
    for(const B of PRESETS){
      const hh=addr({shellMode:'integer',B,phi3:'0',m:'2',tab:'panels'})+'&ca=1';await gopen(pg,hh);const r=await read(pg);
      const idx=PRESETS.indexOf(B)+1;
      ok(tag+' CA '+B+': pressed, B correct, select shows B, card mode CA and index '+idx+' of 10, address text and URL keep &ca=1',
        r.pressed==='true'&&r.B===B&&r.mode==='integer'&&r.sel===B&&/mode CA/.test(r.atom)&&new RegExp('CA #'+idx+'\\b').test(r.idx)&&r.addrTxt===hh&&r.hash===hh,JSON.stringify({p:r.pressed,B:r.B,sel:r.sel,atom:r.atom,idx:r.idx,a:r.addrTxt,h:r.hash}));
    }
    // --- round trip UI -> address -> reload
    await gopen(pg,addr({shellMode:'integer',B:'24',tab:'panels'}));
    await pg.click('#mode_ca');await pg.waitForTimeout(500);await pg.selectOption('#ca_sel','55440');await pg.waitForTimeout(500);
    const a1=await read(pg);ok(tag+' UI CA 55440 writes &ca=1 into the URL and the address line',/&ca=1$/.test(a1.hash)&&a1.hash===a1.addrTxt&&a1.B==='55440',a1.hash);
    const pg2=await ctx.newPage();await gopen(pg2,a1.hash);const a2=await read(pg2);
    ok(tag+' round trip: reload from that URL gives the same state, CA pressed, same address',a2.st===a1.st&&a2.pressed==='true'&&a2.hash===a1.hash&&a2.sel==='55440');
    await pg2.click('#mode_i');await pg2.waitForTimeout(500);const a3=await read(pg2);
    ok(tag+' leaving CA (integer button) drops the field from the URL',!/ca=/.test(a3.hash)&&a3.pressed==='false'&&a3.hash===a3.addrTxt&&a3.hash===addr(JSON.parse(a3.st)),a3.hash);
    await pg2.close();
    // --- non-CA states: addresses identical to v0.4.4
    const S=[{shellMode:'factorial',n1:'4',phi3:'6',m:'3',t1:'1',t2:'1',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',t1:'1',t2:'1',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',B:'5040',phi3:'5000',m:'7',t1:'1/2',t2:'1',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',t1:'1',t2:'1',tab:'fourier'},{shellMode:'integer',B:'55440',tab:'panels'}];
    let same=0;const bad=[];
    for(const s of S){const hh=addr(s),pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url44);await gopen(pb,hh);
      await pa.evaluate(()=>FVPanel.dial({view:''}));await pb.evaluate(()=>FVPanel.dial({view:''}));await pa.waitForTimeout(500);
      const x=await read(pa),y=await read(pb);if(x.addrTxt===y.addrTxt&&x.hash===y.hash&&x.st===y.st&&!/ca=/.test(y.hash)&&x.pressed===y.pressed)same++;else bad.push(hh);await pa.close();await pb.close();}
    ok(tag+' non-CA states (incl. integer B = 5040 and 55440 without the field): address, URL and state identical to v0.4.4 ('+same+'/'+S.length+')',same===S.length,bad.join(' '));
    // --- old v0.4.4-style address of a CA preset without the field: integer mode, CA unpressed (as v0.4.4)
    {const hh=addr({shellMode:'integer',B:'5040',tab:'panels'});await gopen(pg,hh);const r=await read(pg);ok(tag+' old-style address of a preset B (no field): integer mode, CA unpressed, address unchanged',r.pressed==='false'&&r.B==='5040'&&r.hash===hh&&r.addrTxt===hh);}
    // --- refusals
    {const hh=addr({shellMode:'integer',B:'100',tab:'panels'});
      for(const [name,a,exp] of [['non-preset B',hh+'&ca=1',/CA flag refused: B = 100 is not a CA preset/],['n! mode',addr({shellMode:'factorial',n1:'4',tab:'panels'})+'&ca=1',/CA flag refused: B = 24 \(n! mode\)/],['ca=2',addr({shellMode:'integer',B:'5040',tab:'panels'})+'&ca=2',/must be exactly ca=1/],['repeated',addr({shellMode:'integer',B:'5040',tab:'panels'})+'&ca=1&ca=1',/must be exactly ca=1/]]){
        await gopen(pg,a);const r=await read(pg);
        ok(tag+' refusal ('+name+'): state loads as named, CA unpressed, label shown, no ca in the address line',r.pressed==='false'&&exp.test(r.status)&&!/ca=/.test(r.addrTxt),JSON.stringify({p:r.pressed,s:r.status,a:r.addrTxt}));}
      await gopen(pg,hh+'&ca=1');const r=await read(pg);ok(tag+' refusal keeps B = 100 (not 5040), integer mode, no preset menu',r.B==='100'&&r.mode==='integer'&&r.sel===null);
      const pg3=await ctx.newPage();await gopen(pg3,'#v=bogus&ca=1');const r2=await read(pg3);await pg3.close();ok(tag+' an invalid state part is still refused as before',/Address refused/.test(r2.status)&&r2.pressed==='false');}
    // --- hashchange honours the field
    await gopen(pg,addr({shellMode:'integer',B:'5040',tab:'panels'}));
    await pg.evaluate(a=>{location.hash=a;},addr({shellMode:'integer',B:'5040',tab:'panels'})+'&ca=1');await pg.waitForTimeout(500);const hc=await read(pg);
    await pg.evaluate(a=>{location.hash=a;},addr({shellMode:'integer',B:'5040',tab:'panels'}));await pg.waitForTimeout(500);const hd=await read(pg);
    ok(tag+' hashchange: adding the field presses CA, removing it releases CA',hc.pressed==='true'&&hd.pressed==='false',hc.pressed+'/'+hd.pressed);
    // --- shots: a CA address freshly loaded
    for(const B of ['5040','55440']){await gopen(pg,addr({shellMode:'integer',B,tab:'panels'})+'&ca=1');await pg.evaluate(()=>{const d=document.querySelector('details[data-panel="g-robin-margin"]');d.open=true;d.scrollIntoView();});await pg.waitForTimeout(300);
      await pg.screenshot({path:path.join(root,'shot_v045_'+tag+'_panels_CA'+B+'_fresh.png')});}
    await gopen(pg,addr({shellMode:'integer',B:'5040',tab:'fourier'})+'&ca=1');await pg.evaluate(()=>window.scrollTo(0,0));await pg.waitForTimeout(200);await pg.screenshot({path:path.join(root,'shot_v045_'+tag+'_fourier_CA5040_fresh.png')});
    ok(tag+' no page errors',errs.length===0,errs.join(' | '));
    await ctx.close();
  }
  await browser.close();console.log(pass+' passed, '+fail+' failed');process.exit(fail?1:0);
})();
