'use strict';
// v0.4.4 browser check (SCHEMA_ADDENDUM_12): the compact CA base option in the top bar (no readout there), the rebuilt Panels card g-robin-margin
// (port of the accepted RH margin panel) read from the DOM and compared with rhm-core.js, no horizontal scroll at 375,
// non-CA states unchanged against the v0.4.3 dist, and the shot_v044_* screenshots.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url43=u(path.join('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019','dist','comb-hopf.html'));
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const EXP={2:['3/2','2.152786','fails'],6:['2','0.961281','fails'],12:['7/3','0.712138','fails'],60:['14/5','0.289388','fails'],120:['3','0.210828','fails'],360:['13/4','0.092881','fails'],2520:['26/7','0.048447','fails'],5040:['403/105','0.021217','fails'],55440:['1612/385','\u22120.071311','holds'],720720:['248/55','\u22120.124905','holds']};
const SAMPLES=[{shellMode:'factorial',n1:'4',phi3:'6',m:'3',t1:'1',t2:'1',tab:'fourier'},{shellMode:'factorial',n1:'5',phi3:'0',m:'6',t1:'1',t2:'-21/4',tab:'clifford'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
  {shellMode:'integer',B:'5040',phi3:'5000',m:'7',t1:'1/2',t2:'1',tab:'clifford'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',t1:'1',t2:'1',tab:'panels'},{shellMode:'integer',B:'100',nMode:'continuous',phi3:'7/2',m:'4',t1:'1',t2:'1',tab:'fourier'}];
const snap=async(pg,st)=>{await pg.evaluate(s=>{FVPanel.dial({...s,view:''});},st);await pg.waitForTimeout(350);
  return pg.evaluate(()=>({addr:document.getElementById('addr')?document.getElementById('addr').textContent:'',stage:document.getElementById('stage').outerHTML,cards:document.getElementById('cards').innerHTML,caption:document.getElementById('caption').innerHTML,shell:document.getElementById('shell_read').innerHTML,state:JSON.stringify(FVPanel.state,(k,v)=>typeof v==='bigint'?v+'n':v)}));};
const openCard=pg=>pg.evaluate(()=>{const d=document.querySelector('details[data-panel="g-robin-margin"]');if(!d.open)d.open=true;d.scrollIntoView();});
// everything the card shows, read from the DOM, plus the rhm-core record for the same inputs
const cardRead=(pg,mode,idx)=>pg.evaluate(([mode,idx])=>{const q=id=>document.getElementById(id),core=McombRhMarginCoreV1,B=String(FVPanel.model.R.B),
  rec=core.buildAtom({B,mode,factorial_index:idx,precision_bits:'128'});
  return {B,rec:{c1v:rec.c1.value,c2v:rec.c2.value,m:rec.c1.margin,t:rec.c1.threshold,side:rec.c1.side,m2:rec.c2.margin,side2:rec.c2.side,app1:rec.c1.applicability,app2:rec.c2.applicability,k:rec.c2.primorial_k,
    bytes:core.canonicalText(core.withSource(rec,FVRobinCard.SOURCE)),gam:rec.constants.gamma,eg:rec.constants.exp_gamma,lnB:rec.constants.ln_B,lnlnB:rec.constants.ln_ln_B},
  dom:{c1v:q('rhm-c1-value').dataset.value,c2v:q('rhm-c2-value').dataset.value,mlo:q('rhm-c1-margin').dataset.lo,mhi:q('rhm-c1-margin').dataset.hi,tlo:q('rhm-c1-threshold').dataset.lo,thi:q('rhm-c1-threshold').dataset.hi,side:q('rhm-c1-side').dataset.side,
    m2lo:q('rhm-c2-margin').dataset.lo,side2:q('rhm-c2-side').dataset.side,app1:q('rhm-c1-applicability').dataset.applicability,app2:q('rhm-c2-applicability').dataset.applicability,k:q('rhm-c2-k').textContent,
    bytes:q('rhm-bytes-text').textContent,gamlo:q('rhm-const-gamma').dataset.lo,egl:q('rhm-const-exp-gamma').dataset.lo,lnBl:q('rhm-const-ln-b').dataset.lo,lnlnBl:q('rhm-const-ln-ln-b').dataset.lo,
    verdict:q('rhm-ca-verdict').textContent,idx:q('rhm-ca-index').textContent,atom:q('rhm-atom-line').textContent,caut:q('rhm-ca-caution').innerText,cvis:q('rhm-ca-caution').offsetParent!==null,
    scope:q('rhm-scope').textContent,rhs:q('rhm-rh-status').textContent,credits:q('rhm-credits').textContent,port:q('rhm-credits-port').textContent,factorCheck:q('rhm-factor-check').dataset.equal,
    c1txt:q('rhm-c1-margin').innerText,sw:document.documentElement.scrollWidth,iw:window.innerWidth,
    stack:(()=>{const a=q('rhm-c1').getBoundingClientRect(),b=q('rhm-c2').getBoundingClientRect();return {sameRow:Math.abs(a.top-b.top)<4,w:Math.round(a.width)};})()}};},[mode,idx]);
const eqCard=(r)=>{const d=r.dom,c=r.rec;return d.c1v===c.c1v&&d.c2v===c.c2v&&d.mlo===c.m.lo&&d.mhi===c.m.hi&&d.tlo===c.t.lo&&d.thi===c.t.hi&&d.side===c.side&&d.m2lo===c.m2.lo&&d.side2===c.side2&&d.app1===c.app1&&d.app2===c.app2&&d.bytes===c.bytes&&d.gamlo===c.gam.lo&&d.egl===c.eg.lo&&d.lnBl===c.lnB.lo&&d.lnlnBl===c.lnlnB.lo&&d.factorCheck==='true';};
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    await pg.goto(url);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
    ok(tag+' CA button present beside n! and integer, not pressed at load; ca_sel hidden',await pg.evaluate(()=>{const b=document.getElementById('mode_ca');return !!b&&b.textContent==='CA'&&b.getAttribute('aria-pressed')==='false'&&document.getElementById('ca_sel').style.display==='none';}));
    ok(tag+' the preset menu lists exactly 2,6,12,60,120,360,2520,5040,55440,720720',JSON.stringify(await pg.evaluate(()=>[...document.getElementById('ca_sel').options].map(o=>o.value)))==='["2","6","12","60","120","360","2520","5040","55440","720720"]');
    const rowBefore=await pg.evaluate(()=>Math.round(document.getElementById('shellrow').getBoundingClientRect().height));
    await pg.click('#mode_ca');await pg.waitForTimeout(300);
    ok(tag+' CA click: integer base B = 5040 (current B 24 not a preset), button pressed, select shown, Mbox and n1 stepper hidden',await pg.evaluate(()=>{const s=FVPanel.state;return s.shellMode==='integer'&&s.B==='5040'&&document.getElementById('mode_ca').getAttribute('aria-pressed')==='true'&&document.getElementById('mode_i').getAttribute('aria-pressed')==='false'&&document.getElementById('ca_sel').style.display!=='none'&&document.getElementById('Mbox').style.display==='none'&&document.getElementById('n1grp').style.display==='none';}));
    ok(tag+' top bar: no readout in the preset area, no horizontal scroll',await pg.evaluate(()=>!document.getElementById('ca_read')&&!/σ\(B\)|Robin|Δ/.test(document.getElementById('shellrow').innerText)&&document.documentElement.scrollWidth<=window.innerWidth));
    const g=await pg.evaluate(()=>{const kids=[...document.getElementById('shellrow').children].filter(e=>e.offsetParent);return {h:Math.round(document.getElementById('shellrow').getBoundingClientRect().height),tops:new Set(kids.map(e=>Math.round(e.getBoundingClientRect().top))).size,sel:Math.round(document.getElementById('ca_sel').getBoundingClientRect().width)};});
    console.log('INFO '+tag+' top bar: height before CA '+rowBefore+', in CA mode '+g.h+', distinct rows '+g.tops+', select width '+g.sel);
    await pg.screenshot({path:path.join(root,'shot_v044_'+tag+'_topbar_CA5040.png'),clip:{x:0,y:0,width:w,height:Math.min(h,200)}});
    await pg.evaluate(()=>FVPanel.dial({tab:'panels'}));await pg.waitForTimeout(300);
    for(const B of Object.keys(EXP)){
      await pg.selectOption('#ca_sel',B);await pg.waitForTimeout(250);await openCard(pg);await pg.waitForTimeout(250);
      const r=await cardRead(pg,'direct',null),d=r.dom,[sig,mg,vd]=EXP[B],idx=Object.keys(EXP).indexOf(B)+1;
      ok(tag+' card B='+B+': exact sigma(B)/B = '+sig+' (reduced), verdict '+vd+', CA #'+idx+', atom line says mode CA',d.c1v===sig&&d.verdict.startsWith(vd)&&d.idx.startsWith('CA track: CA #'+idx+' ')&&/mode CA/.test(d.atom),JSON.stringify(d).slice(0,300));
      ok(tag+' card B='+B+': every exact output equals rhm-core.js (c1, c2, margin, threshold endpoints, sides, applicability, constants, canonical record bytes, factor product check)',eqCard(r));
      ok(tag+' card B='+B+': margin shows '+mg+'; verdict agrees with side/applicability ('+d.side+', '+d.app1+')',d.c1txt.includes(mg.slice(0,-1))&&((vd==='holds')===(d.side==='BELOW'))&&(B==='5040'||Number(B)>5040?true:d.app1==='OUT_OF_RANGE')&&(Number(B)>5040?d.app1==='IN_RANGE':d.app1==='OUT_OF_RANGE'),d.c1txt+' '+d.side+' '+d.app1);
      ok(tag+' card B='+B+': scope, rh_status, Sol caution merged in the one box; credits verbatim; port line separate',d.rhs==='rh_status: NOT_EVIDENCE'&&/Finitely many satisfied cases/.test(d.scope)&&d.cvis&&/particular numbers only/.test(d.caut)&&/general case/.test(d.caut)&&/RH/.test(d.caut)&&d.credits==='Idea: saphir. Criteria mapping: Opus. Specification, corrections and audits: Astra. Handoff: fable (Claude). Panel: RH margin builder (Claude). Record schema 0.1.0, unchanged.'&&d.port==='Port into the Fourier viewer v0.4.4: builder (Claude).');
      ok(tag+' card B='+B+': no horizontal scroll'+(w<500?'; C1 and C2 stack in one column':'; C1 and C2 side by side'),d.sw<=d.iw&&(w<500?!d.stack.sameRow:d.stack.sameRow),JSON.stringify(d.stack)+' '+d.sw+'/'+d.iw);
    }
    // host-panel anchor values: B = 24 (4!, factorial) at 128 bits, from saphir's screenshots of the previous viewer
    await pg.evaluate(()=>FVPanel.dial({shellMode:'factorial',n1:'4',phi3:'6',tab:'panels'}));await pg.waitForTimeout(300);await openCard(pg);await pg.waitForTimeout(250);
    {const r=await cardRead(pg,'factorial','4'),d=r.dom;
     ok(tag+' card B=24 equals the previous viewer panel: C1 5/2, C2 3, threshold [2.059398835087633225937464, ...465], margins 0.4406011649123667740625 35 / 0.94060116491236677406253 6 prefix; ABOVE/ABOVE; OUT_OF_RANGE / NOT_IN_FAMILY; primorial_k null; factors 2^3*3',
       d.c1v==='5/2'&&d.c2v==='3'&&await pg.evaluate(()=>document.getElementById('rhm-c1-threshold').innerText.startsWith('[2.059398835087633225937464, 2.059398835087633225937465]'))&&await pg.evaluate(()=>document.getElementById('rhm-c1-margin').innerText.startsWith('[0.440601164912366774062535, 0.440601164912366774062536]'))&&await pg.evaluate(()=>document.getElementById('rhm-c2-margin').innerText.startsWith('[0.940601164912366774062535, 0.940601164912366774062536]'))
       &&d.side==='ABOVE'&&d.side2==='ABOVE'&&d.app1==='OUT_OF_RANGE'&&d.app2==='NOT_IN_FAMILY'&&/null/.test(d.k)&&/B = 4! = 24 = 2\u00b3\u00b73 \u00b7 mode factorial/.test(d.atom)&&/factorial_index 4 \u00b7 precision_bits 128/.test(d.atom)&&eqCard(r),JSON.stringify({c1v:d.c1v,c2v:d.c2v,s:d.side,s2:d.side2,a1:d.app1,a2:d.app2,k:d.k,atom:d.atom,eq:eqCard(r),fc:d.factorCheck}));}
    // round 2: layout of the value cells (C1, C2, constants) at B = 24, 5040, 55440, 720720
    for(const [lab,patch] of [['24',{shellMode:'factorial',n1:'4',phi3:'6'}],['5040',{shellMode:'integer',B:'5040',phi3:'5000'}],['55440',{shellMode:'integer',B:'55440',phi3:'55000'}],['720720',{shellMode:'integer',B:'720720',phi3:'720000'}]]){
      await pg.evaluate(p=>FVPanel.dial({...p,tab:'panels'}),patch);await pg.waitForTimeout(300);await openCard(pg);await pg.waitForTimeout(300);
      const L=await pg.evaluate(()=>{const bad=[],info=[];let cells=0;
        for(const id of ['rhm-c1','rhm-c2','rhm-constants']){const card=document.getElementById(id),cr=card.getBoundingClientRect(),cs=getComputedStyle(card),inner=cr.width-parseFloat(cs.paddingLeft)-parseFloat(cs.paddingRight);
          for(const dd of card.querySelectorAll('dd')){cells++;const r=dd.getBoundingClientRect(),dt=dd.previousElementSibling.getBoundingClientRect(),own=r.top>=dt.bottom-2&&Math.abs(r.left-dt.left)<4;
            const txt=dd.innerText.replace(/\s+/g,' ').trim();
            if(r.left<cr.left-0.5||r.right>cr.right+0.5)bad.push(id+' cell outside card: '+txt.slice(0,30));
            if(r.width<0.4*inner&&!own&&txt.length>1)bad.push(id+' cell narrow '+Math.round(r.width)+'/'+Math.round(inner)+': '+txt.slice(0,30));
            // lines: group character rects by top
            const walker=document.createTreeWalker(dd,NodeFilter.SHOW_TEXT);let n;const lines=new Map();
            while(n=walker.nextNode()){if(n.parentElement.closest('details')&&!n.parentElement.closest('summary')&&n.parentElement.closest('details')!==dd&&!n.parentElement.closest('details').open)continue;
              for(let i=0;i<n.length;i++){const g=document.createRange();g.setStart(n,i);g.setEnd(n,i+1);const q=g.getClientRects()[0];if(!q||q.width===0)continue;if(/\s/.test(n.data[i]))continue;const k=n.parentElement.tagName+Math.round(q.top/3);lines.set(k,(lines.get(k)||0)+1);if(q.right>cr.right+0.5)bad.push(id+' glyph outside card');}}
            if(txt.length>3)for(const [k,c] of lines)if(c===1&&lines.size>2)bad.push(id+' single-character line in '+txt.slice(0,30));}
          const sr=card.scrollWidth>card.clientWidth+1;if(sr)bad.push(id+' scrolls horizontally');}
        return {bad:[...new Set(bad)].slice(0,8),cells,sw:document.documentElement.scrollWidth,iw:window.innerWidth};});
      ok(tag+' layout B='+lab+': '+L.cells+' value cells in C1/C2/constants lie inside their card, are >= 40% of the card inner width (or on their own row), no single-character lines, no page scroll',L.bad.length===0&&L.sw<=L.iw,JSON.stringify(L));
    }
    // n! mode Bs vs rhm-core (factorial mode)
    for(const n1 of [3,5,7,10,13]){
      await pg.evaluate(n1=>FVPanel.dial({shellMode:'factorial',n1:String(n1),phi3:'1'}),n1);await pg.waitForTimeout(250);await openCard(pg);await pg.waitForTimeout(200);
      const r=await cardRead(pg,'factorial',String(n1));ok(tag+' card in n! mode n1='+n1+': every exact output equals rhm-core.js (factorial mode); atom line says mode factorial',eqCard(r)&&/mode factorial/.test(r.dom.atom),r.dom.atom);}
    // B = 1
    await pg.evaluate(()=>FVPanel.dial({shellMode:'factorial',n1:'1',phi3:'1'}));await pg.waitForTimeout(250);await openCard(pg);await pg.waitForTimeout(200);
    ok(tag+' card B=1: domain unavailable, no crash',await pg.evaluate(()=>document.getElementById('rhm-c1-applicability').dataset.applicability==='DOMAIN_UNAVAILABLE'));
    // B with a prime factor above 10^6: refusal shown, caution kept
    await pg.evaluate(()=>FVPanel.dial({shellMode:'integer',B:'2000006',phi3:'1'}));await pg.waitForTimeout(250);await openCard(pg);await pg.waitForTimeout(200);
    ok(tag+' card B with a prime above 10^6: refusal shown with the domain, no record, no crash',await pg.evaluate(()=>/refusal|build error/.test(document.getElementById('rhm-status').textContent)&&!document.getElementById('rhm-c1')&&document.getElementById('rhm-export').disabled));
    // precision + export
    await pg.evaluate(()=>FVPanel.dial({shellMode:'integer',B:'5040',phi3:'5000'}));await pg.waitForTimeout(250);await openCard(pg);await pg.waitForTimeout(200);
    await pg.selectOption('#rhm-bits','16');await pg.waitForTimeout(250);
    ok(tag+' precision_bits 16: record rebuilt (working bits 80)',await pg.evaluate(()=>document.getElementById('rhm-const-wb').textContent.startsWith('80')));
    await pg.selectOption('#rhm-bits','128');await pg.waitForTimeout(200);
    const dl=pg.waitForEvent('download',{timeout:4000});await pg.click('#rhm-export');const dn=await dl.catch(()=>null);
    ok(tag+' export record: downloads rh-atom-margins-B5040-direct-bits128.json',!!dn&&dn.suggestedFilename()==='rh-atom-margins-B5040-direct-bits128.json');
    ok(tag+' exactly 16 other Panels cards remain placeholders ("not yet rebuilt"); the g-robin card is not one',await pg.evaluate(()=>{const ds=[...document.querySelectorAll('details[data-panel]')],ph=ds.filter(d=>/not yet rebuilt/.test(d.innerText));return ds.length===17&&ph.length===16&&!ph.some(d=>d.dataset.panel==='g-robin-margin');}));
    // factorial coincidence through the page
    const co=await pg.evaluate(()=>{const out=[],j=o=>JSON.parse(JSON.stringify(o,(k,v)=>typeof v==='bigint'?v+'n':v));for(const [n1,B] of [[2,2],[3,6],[5,120],[7,5040]]){
      FVPanel.dial({shellMode:'factorial',n1:String(n1),phi3:'1',m:'3',tab:'fourier'});const f=j(FVPanel.state);FVPanel.onAct('mode','ca');FVPanel.dial({B:String(B),phi3:'1',m:'3'});const i=j(FVPanel.state);
      out.push(B+':'+Object.keys(f).filter(k=>JSON.stringify(f[k])!==JSON.stringify(i[k])).join('|'));}return out;});
    ok(tag+' factorial coincidence through the page: CA preset state differs from the n! state only in shellMode for 2, 6, 120, 5040',co.every(s=>s.endsWith(':shellMode')),co.join(' '));
    await pg.click('#mode_i');await pg.waitForTimeout(250);
    ok(tag+' integer button: select hidden, Mbox shown, B kept, CA unpressed',await pg.evaluate(()=>document.getElementById('ca_sel').style.display==='none'&&document.getElementById('Mbox').style.display!=='none'&&FVPanel.state.shellMode==='integer'&&document.getElementById('mode_ca').getAttribute('aria-pressed')==='false'));
    await pg.fill('#Mbox','24');await pg.press('#Mbox','Enter');await pg.click('#mode_ca');await pg.waitForTimeout(250);
    ok(tag+' typed M=24 is no preset: the CA button moves B to 5040',await pg.evaluate(()=>FVPanel.state.B==='5040'));
    await pg.click('#mode_f');await pg.waitForTimeout(250);
    ok(tag+' n! button: factorial mode, CA overlay off',await pg.evaluate(()=>FVPanel.state.shellMode==='factorial'&&document.getElementById('ca_sel').style.display==='none'));
    await pg.click('#mode_ca');await pg.waitForTimeout(200);await pg.evaluate(()=>FVPanel.dial({B:'7'}));await pg.waitForTimeout(250);
    ok(tag+' state leaves the presets (B=7): CA overlay ends',await pg.evaluate(()=>document.getElementById('mode_ca').getAttribute('aria-pressed')==='false'&&document.getElementById('ca_sel').style.display==='none'));
    ok(tag+' no page errors',errs.length===0,errs.join(' | '));
    // screenshots of the Panels tab with the card open
    for(const B of ['5040','55440','720720']){
      await pg.evaluate(B=>{FVPanel.onAct('mode','ca');FVPanel.dial({B,phi3:String(Number(B)-2),m:'6',tab:'panels',view:''});},B);await pg.waitForTimeout(400);
      await openCard(pg);await pg.waitForTimeout(400);
      await pg.screenshot({path:path.join(root,'shot_v044_'+tag+'_panels_robin_CA'+B+'.png')});
      if(B==='55440')for(const [id,nm] of [['rhm-c1','c1c2'],['rhm-factors','factors'],['rhm-constants','constants']]){await pg.evaluate(id=>document.getElementById(id).scrollIntoView({block:'start'}),id);await pg.waitForTimeout(250);await pg.screenshot({path:path.join(root,'shot_v044_'+tag+'_panels_robin_CA55440_'+nm+'.png')});}}
    await ctx.close();
  }
  // non-CA identity against v0.4.3 (the rebuilt card is on the Panels tab: sample 4 compares its closed-card page; the cards of other tabs are untouched)
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const run=async(U)=>{const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage();await pg.goto(U);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);const o=[];for(const s of SAMPLES)o.push(await snap(pg,s));await ctx.close();return o;};
    const a=await run(url43),b=await run(url);
    SAMPLES.forEach((s,i)=>{for(const k of ['addr','stage','cards','caption','shell','state'])ok(tag+' non-CA sample '+i+' ('+s.shellMode+' '+s.tab+') '+k+' byte-identical to v0.4.3',a[i][k]===b[i][k],k==='addr'?a[i][k]+' vs '+b[i][k]:'');});
  }
  await browser.close();
  console.log('\n'+pass+' passed, '+fail+' failed');process.exit(fail?1:0);
})();
