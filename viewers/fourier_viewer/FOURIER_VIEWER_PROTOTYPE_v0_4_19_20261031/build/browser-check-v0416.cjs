'use strict';
// v0.4.16 browser check (SCHEMA_ADDENDUM_23): the D1 Rule 30 ladder card on the Clifford tab, 1280x800 and 375x812.
// Cases: rule 30 j = 3 (doubling), rule 30 j = 5 (stall), rule 90 j = 3 (density 0), each at q = 1, 2, 4, 8. Expected values come from the core (itself checked against the pinned rule30 fixture by test-rule30-ladder).
// D1 off: the page is compared with the v0.4.14 build (stage, canvas, caption, about, cards, address) on 8 states, and the visible-control counts are compared.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const CC=require('../host-core/comb-core.js'),RL=require('../host-core/rule30-ladder-core.js');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url414=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021/dist/comb-hopf.html');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o)=>CC.encodeAddress(CC.initial(o));
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:(document.getElementById('about')||{innerHTML:''}).innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent}));
const d1=pg=>pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="r30-curve"]'),at=g?Object.fromEntries([...g.attributes].map(a=>[a.name,a.value])):null;
  const cv=document.getElementById('stagecv'),cx=cv.getContext('2d'),im=cx.getImageData(0,0,cv.width,cv.height).data;let amber=0,cyan=0;
  for(let i=0;i<im.length;i+=4){const r=im[i],g2=im[i+1],b=im[i+2];if(r>200&&g2>120&&g2<190&&b<60)amber++;if(r<60&&g2>180&&b>200)cyan++;}
  const tx=s=>[...document.querySelectorAll(s)].map(e=>e.textContent);
  return {at,caps:tx('#caption p'),turns:document.querySelector('#stage [data-role="r30-turns"]')?.getAttribute('data-n'),card:!!document.querySelector('.r30-card'),
    S:tx('[data-role="r30-S"]')[0],k:tx('[data-role="r30-k"]')[0],per:tx('[data-role="r30-per"]')[0],mono:tx('[data-role="r30-mono"]')[0],f1:tx('[data-role="r30-f1"]')[0],dens:tx('[data-role="r30-density"]')[0],
    deg:[...document.querySelectorAll('[data-role="r30-degenerate"]')].map(e=>e.getAttribute('data-kind')),rows:document.querySelectorAll('[data-role="r30-row"]').length,
    amber,cyan,hscroll:document.documentElement.scrollWidth>document.documentElement.clientWidth,addr:document.getElementById('addr').textContent,view:FVPanel.state.view};});
const view=(r,j,q)=>['rl=1',r!==30?'rlr='+r:'',j!==3?'rlj='+j:'',q!==2?'rlq='+q:''].filter(Boolean).join(';');
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- the D1 cases
    for(const [r,j,why] of [[30,3,'doubling'],[30,5,'stall'],[90,3,'density 0']])for(const q of RL.QS){
      const cd=RL.card(r,j,q),cu=RL.curve(r,j,q,{sub:Math.max(1,Math.ceil(720/RL.perN(r,j)))}),nm=tag+' rule '+r+' j = '+j+' ('+why+') q = '+q;
      await gopen(pg,addr({tab:'clifford',view:view(r,j,q)}));const s=await d1(pg);
      ok(nm+': curve data = core (per '+cd.per+', S '+cd.S+', k '+cd.k+', steps '+cu.steps+', ends at base '+cd.k+', fibre '+cd.fibreTotal.join('/')+')',s.at&&s.at['data-rule']===String(r)&&s.at['data-j']===String(j)&&s.at['data-q']===String(q)&&s.at['data-per']===String(cd.per)&&s.at['data-s']===String(cd.S)&&s.at['data-k']===String(cd.k)&&s.at['data-steps']===String(cu.steps)&&s.at['data-n']===String(cu.points.length)&&s.at['data-end-base']===cd.k+'/1'&&s.at['data-end-fibre']===cd.fibreTotal.join('/'),JSON.stringify(s.at));
      ok(nm+': event / base segments = core ('+cu.points.filter(p=>p.event).length+' / '+cu.points.slice(0,-1).filter(p=>!p.event).length+')',s.at&&+s.at['data-event-segments']===cu.points.filter(p=>p.event).length&&+s.at['data-base-segments']===cu.points.slice(0,-1).filter(p=>!p.event).length);
      ok(nm+': caption label "'+cd.label+'" and "'+cd.monodromy+'"',s.caps[0]===cd.label&&s.caps[1].startsWith(cd.monodromy+' · '),s.caps.slice(0,2).join(' | '));
      const wantDeg=cd.degenerate.map(x=>x.kind);
      ok(nm+': degenerate labels drawn ['+wantDeg.join(', ')+'] in the caption and the card',s.deg.join()===wantDeg.join()&&cd.degenerate.every(x=>s.caps.some(c=>c.startsWith(x.label))),s.deg.join()+' | '+s.caps.join(' | '));
      ok(nm+': card S_j, k, per_j, monodromy, density, F1',s.card&&s.S===('S_'+j+' = '+cd.S+' ('+(cd.odd?'odd':'even')+')')&&s.k===('k = '+cd.k+' turn'+(cd.k===1?'':'s'))&&s.per===('per_'+j+' = '+cd.per)&&s.mono===cd.monodromy&&s.f1.startsWith('holds for every t < per_35')&&s.rows===Math.min(cd.perNext,16),JSON.stringify([s.S,s.k,s.per,s.mono,s.f1,s.dens,s.rows]));
      ok(nm+': returns to base angle 0 marked: '+(cd.k+1)+' (i = 0 … k)',s.turns===String(cd.k+1),s.turns);
      ok(nm+': ink on the canvas ('+(cu.points.some(p=>p.event)?'amber events and ':'')+'cyan base steps; amber '+s.amber+', cyan '+s.cyan+')',s.cyan>5&&(cu.points.some(p=>p.event)?s.amber>50:s.amber===0));
      ok(nm+': no horizontal page scroll',!s.hscroll);}
    // ---- the dials through the Layers menu (clicks and selects), and the address
    await gopen(pg,addr({tab:'clifford'}));
    await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.click('#menu_layers [data-v="rladder"]');await pg.waitForTimeout(300);
    let s=await d1(pg);ok(tag+' Layers: "Rule 30 ladder (D1)" switches the card on (rule 30, j = 3, q = 2; address view=rl=1)',s.at&&s.at['data-j']==='3'&&s.view==='rl=1'&&/view=rl(=|%3D)1(&|$)/.test(s.addr),s.view+' '+s.addr);
    await pg.click('#menu_layers [data-v="rlj_up"]');await pg.waitForTimeout(250);await pg.click('#menu_layers [data-v="rlj_up"]');await pg.waitForTimeout(250);
    s=await d1(pg);ok(tag+' j ▶ twice: j = 5, trivial (stall)',s.at['data-j']==='5'&&s.mono==='trivial (stall)');
    await pg.click('#menu_layers [data-v="rlj_dn"]');await pg.waitForTimeout(250);s=await d1(pg);ok(tag+' ◀ j: j = 4',s.at['data-j']==='4');
    await pg.selectOption('#menu_layers select[data-vsel="rl_j"]','rlj3');await pg.waitForTimeout(250);
    await pg.selectOption('#menu_layers select[data-vsel="rl_q"]','rlq8');await pg.waitForTimeout(250);
    await pg.selectOption('#menu_layers select[data-vsel="rl_rule"]','rlr150');await pg.waitForTimeout(250);
    s=await d1(pg);const c150=RL.card(150,3,8);ok(tag+' selects: rule 150, j = 3, q = 8 → '+c150.label,s.at['data-rule']==='150'&&s.at['data-j']==='3'&&s.at['data-q']==='8'&&s.caps[0]===c150.label,s.caps[0]);
    const a=s.addr;await gopen(pg,a.slice(a.indexOf('#')));const s2=await d1(pg);ok(tag+' address round trip (reload): same card',s2.at&&s2.at['data-rule']==='150'&&s2.at['data-q']==='8'&&s2.caps[0]===c150.label);
    await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.click('#menu_layers [data-v="rladder"]');await pg.waitForTimeout(300);
    s=await d1(pg);ok(tag+' switch off: the comb picture is back, no D1 card, the dial values stay in the view string',!s.at&&!s.card&&!s.view.includes('rl=1'));
    // ---- refused dials are labelled, not hidden
    await gopen(pg,addr({tab:'clifford',view:'rl=1;rlj=99;rlq=3'}));s=await d1(pg);
    ok(tag+' refused dials (j = 99, q = 3): labelled, defaults drawn',s.caps.filter(c=>c.startsWith('D1 dial refused:')).length===2&&s.at['data-j']==='3'&&s.at['data-q']==='2',s.caps.join(' | '));
    // ---- other tabs are not changed by D1 (D1 is a Clifford card)
    for(const tab of ['fourier','hopf']){await gopen(pg,addr({tab,view:'rl=1'}));const on=await snap(pg);await gopen(pg,addr({tab}));const off=await snap(pg);
      ok(tag+' '+tab+' with rl=1 draws the same picture as without it',on.stage===off.stage&&on.cv===off.cv&&on.caption===off.caption&&on.cards===off.cards);}
    // ---- D1 off: same page as v0.4.14 and the same control counts
    const OFF=[{tab:'clifford'},{tab:'fourier'},{tab:'hopf'},{tab:'panels'},{tab:'clifford',shellMode:'integer',B:'24'},{tab:'clifford',shellMode:'factorial',n1:'5',m:'5'},{tab:'clifford',view:'cm=0;cff=1'},{tab:'fourier',shellMode:'integer',B:'5040'}];
    let same=0,diff=[];for(const o of OFF){await gopen(pg,addr(o));const x=await snap(pg);await gopen(pg,addr(o),url414);const y=await snap(pg);
      const ks=['stage','cv','caption','about','cards','addr'].filter(k=>x[k]!==y[k]);if(!ks.length)same++;else diff.push(o.tab+':'+ks.join('+'));}
    ok(tag+' D1 off: stage, canvas, caption, about, cards and address identical to v0.4.14 on '+same+' of '+OFF.length+' states',same===OFF.length,diff.join(' '));
    const cn=[];for(const tab of ['fourier','clifford','hopf'])for(const o of [{shellMode:'integer',B:'24',tab},{shellMode:'factorial',n1:'4',tab}]){await gopen(pg,addr(o));cn.push(await count(pg));await gopen(pg,addr(o),url414);cn.push(await count(pg));}
    ok(tag+' visible-control counts = v0.4.14 (pairs: '+cn.join('/')+')',cn.every((v,i)=>i%2||v===cn[i+1]));
    {const c=[];for(const v of ['rl=1','rl=1;rlr=90;rlq=8']){await gopen(pg,addr({tab:'clifford',view:v}));c.push(await count(pg));}ok(tag+' visible controls with D1 on (menus closed): '+c.join('/')+' (≤ 41)',c.every(x=>x<=41));}
    ok(tag+' no page errors or console errors',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();}
  await browser.close();
  console.log('SUMMARY browser-check-v0416: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
})().catch(e=>{console.error(e);process.exit(1);});
