'use strict';
// v0.4.17 browser check (SCHEMA_ADDENDUM_24): the two group-D exact cards of the Panels tab, at 1280x800 and 375x812.
// Cases: Elliptic points (exact) at k = 1, 5, 10 and p = 5, 37 (bad), 97, the five cases of the addition table at p = 5; Period lattice
// (exact intervals) at D = 10, 50, 100 and the refused curve 11a1. Expected values come from the cores run here in Node (themselves checked against
// the Sage fixture by test-elliptic-exact and test-elliptic-period). Regression: the Panels tab equals the v0.4.16 build once the two new card
// elements are removed, and the other tabs are identical to v0.4.16 (stage, caption, cards, address). The v0.4.16 page is read only (sha256 pinned).
// No floating point: pixel counts are integers; times are integer milliseconds from Date.now.
const path=require('path'),fs=require('fs'),crypto=require('crypto');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const CC=require('../host-core/comb-core.js'),EX=require('../host-core/elliptic-exact-core.js'),PE=require('../host-core/elliptic-period-core.js');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028/dist/comb-hopf.html',OLDSHA='1da7dc8f8cad8c31f22e302a92e763fdc95b71abf4d3dc559fcad33df88c1b71';
const url=u(path.join(root,'dist','comb-hopf.html')),url416=u(OLD);
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=o=>CC.encodeAddress(CC.initial(o));
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);};
const NEWRE=/<details class="pmod" data-panel="(elliptic-points-exact|period-lattice-exact)"[^>]*>[\s\S]*?<\/details>/g;
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,caption:document.getElementById('caption').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hstage:document.getElementById('htmlstage').innerHTML}));
const openCards=pg=>pg.evaluate(()=>{for(const id of ['elliptic-points-exact','period-lattice-exact']){const d=document.querySelector('details[data-panel="'+id+'"]');if(d&&!d.open)d.open=true;}});
const setDial=(pg,role,v,ev)=>pg.evaluate(([r,v,ev])=>{const x=document.querySelector('[data-role="'+r+'"]');if(!x)return false;if(x.tagName==='SELECT'&&/^#/.test(v))x.selectedIndex=+v.slice(1);else x.value=v;x.dispatchEvent(new Event(ev,{bubbles:true}));return true;},[role,String(v),ev||'change']);
const hscroll=pg=>pg.evaluate(()=>document.documentElement.scrollWidth>document.documentElement.clientWidth);
const ink=(pg,role)=>pg.evaluate(r=>{const cv=document.querySelector('[data-role="'+r+'"]');if(!cv)return -1;const im=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let n=0;for(let i=0;i<im.length;i+=4)if(im[i]<60&&im[i+1]>180&&im[i+2]>200)n++;return n;},role);
const A=[0n,0n,1n,-1n,0n],CQ=EX.curveQ(A),PQ=EX.pt(EX.Q(0n),EX.Q(-1n));
(async()=>{
  ok('v0.4.16 reference page present and unchanged (sha256 1da7dc8f…)',fs.existsSync(OLD)&&crypto.createHash('sha256').update(fs.readFileSync(OLD)).digest('hex')===OLDSHA);
  const browser=await chromium.launch();const timing=[];
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- regression against v0.4.16
    {let same=0,bad=[];const ST=[{tab:'panels'},{tab:'panels',shellMode:'integer',B:'24'},{tab:'fourier'},{tab:'clifford'},{tab:'hopf'},{tab:'clifford',shellMode:'factorial',n1:'4'}];
      for(const o of ST){const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,addr(o),url416);await gopen(pb,addr(o));const x=await snap(pa),y=await snap(pb);
        const nNew=(y.hstage.match(NEWRE)||[]).length,eq=x.stage===y.stage&&x.caption===y.caption&&x.cards===y.cards&&x.addr===y.addr&&(o.tab==='panels'?(x.hstage===y.hstage.replace(NEWRE,'')&&nNew===2):x.hstage===y.hstage);
        if(eq)same++;else bad.push(JSON.stringify(o)+' new='+nNew);await pa.close();await pb.close();}
      ok(tag+' identical to v0.4.16 on '+ST.length+' states (stage, caption, cards, address, html stage); on the Panels tab the only difference is the two new card elements',same===ST.length,bad.join(' | '));}
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>localStorage.clear());await gopen(pg,addr({tab:'panels'}));
    {const st=await pg.evaluate(()=>[...document.querySelectorAll('details.pmod')].map(d=>d.dataset.panel+':'+d.open+':'+/not yet rebuilt/.test(d.innerText)));
      const ids=st.map(s=>s.split(':')[0]),iA=ids.indexOf('arithmetic-fourier'),iP=ids.indexOf('elliptic-points-exact'),iL=ids.indexOf('period-lattice-exact');
      ok(tag+' both cards in group D after the legacy D placeholders, adjacent, collapsed on a fresh page ('+ids.length+' cards)',iP===iA+1&&iL===iP+1&&iL===ids.length-1&&st[iP].split(':')[1]==='false'&&st[iL].split(':')[1]==='false',st.join(' '));
      ok(tag+' the legacy group-D placeholders mcomb-elliptic-bsd and clifford-elliptic-bridge are still present and still "not yet rebuilt"',['mcomb-elliptic-bsd','clifford-elliptic-bridge'].every(id=>{const s=st.find(x=>x.startsWith(id+':'));return s&&s.endsWith(':true');}));
      ok(tag+' card titles carry the word "exact"',await pg.evaluate(()=>['elliptic-points-exact','period-lattice-exact'].every(id=>/exact/.test(document.querySelector('details[data-panel="'+id+'"] summary').textContent))));}
    await openCards(pg);await pg.waitForTimeout(400);
    ok(tag+' opened cards render (points card and period card bodies present)',await pg.evaluate(()=>!!document.querySelector('[data-role="ell-points"]')&&!!document.querySelector('[data-role="per-card"]')));
    // ---- k
    for(const k of [1n,5n,10n]){await setDial(pg,'ell-k',k);const s=await pg.evaluate(()=>({kp:document.querySelector('[data-role="ell-kP"]').textContent,steps:[...document.querySelectorAll('[data-role="ell-step"]')].map(e=>e.dataset.case),kval:document.querySelector('[data-role="ell-kval"]').textContent}));
      const m=EX.mul(CQ,k,PQ),want=k+'P = '+EX.ptStr(CQ,m.R)+' (exact, over \u211a)';
      ok(tag+' k = '+k+': '+want+', '+m.steps.length+' steps with case labels '+m.steps.map(x=>x.key).join('>'),s.kp===want&&s.steps.join('>')===m.steps.map(x=>x.key).join('>')&&s.kval==='k = '+k,JSON.stringify(s));}
    ok(tag+' k = 10 matches the Sage fixture 10P = (161/16, 2001/64)',await pg.evaluate(()=>document.querySelector('[data-role="ell-kP"]').textContent.includes('(161/16, 2001/64)')));
    // ---- p
    for(const p of [5n,37n,97n]){await setDial(pg,'ell-p',p);
      const s=await pg.evaluate(()=>{const cv=document.querySelector('[data-role="ell-scatter"]');return {p:cv.dataset.p,n:cv.dataset.n,sing:cv.dataset.singular,red:cv.dataset.reduction,err:cv.dataset.error||'',bad:(document.querySelector('[data-role="ell-bad"]')||{}).textContent||'',count:document.querySelector('[data-role="ell-count"]').textContent,opts:document.querySelector('[data-role="ell-p1"]').options.length,sel:(document.querySelector('[data-role="ell-ap-row"].sel')||{dataset:{}}).dataset.p};});
      const E=EX.curveFp(A,p),all=EX.points(E),rt=EX.reductionType(A,p),ns=rt.type==='good'?all.length:all.length-1,cy=await ink(pg,'ell-scatter');
      ok(tag+' p = '+p+': scatter of '+all.length+' points drawn (O as the marker outside the grid), P1/P2 lists '+ns+' points of the group, no draw error, cyan ink '+(cy>0?'present':'absent'),s.p===String(p)&&s.n===String(all.length)&&s.opts===ns&&!s.err&&cy>0&&s.sel===String(p),JSON.stringify(s));
      if(p===37n)ok(tag+' p = 37 (bad): singular point (5, 18) drawn and labelled; reduction nonsplit multiplicative; warning line present; count line states 39 points in all, 38 nonsingular',s.sing==='5,18'&&s.red==='nonsplit'&&/bad prime/.test(s.bad)&&/nonsplit multiplicative/.test(s.bad)&&/39 points in all = 38 nonsingular/.test(s.count),JSON.stringify(s));
      else ok(tag+' p = '+p+': good reduction, no singular mark, #E(F_'+p+') = '+all.length,s.sing===''&&s.red==='good'&&s.bad===''&&s.count==='#E(F_'+p+') = '+all.length,JSON.stringify(s));
      ok(tag+' p = '+p+': no horizontal page scroll',!(await hscroll(pg)));}
    // ---- the five cases at p = 5
    {await setDial(pg,'ell-p',5n);const E=EX.curveFp(A,5n),pts=EX.points(E),ix=Q=>pts.findIndex(R=>EX.ptEq(E,R,Q));
      const T=pts.find(Q=>!Q.inf&&(2n*Q.y+1n)%5n===0n),P5=EX.reduce(CQ,PQ,5n).R,Q5=pts.find(Q=>!Q.inf&&Q.x!==P5.x);
      const C5=[['p1inf',0,ix(P5)],['p2inf',ix(P5),0],['opposite',ix(T),ix(T)],['generic',ix(P5),ix(Q5)],['doubling',ix(P5),ix(P5)]];
      for(const [key,i1,i2] of C5){await setDial(pg,'ell-p1','#'+i1);await setDial(pg,'ell-p2','#'+i2);
        const s=await pg.evaluate(()=>({act:[...document.querySelectorAll('[data-role="ell-case"][data-active="1"]')].map(e=>e.dataset.key),lab:document.querySelector('[data-role="ell-case-active"]').textContent,sum:document.querySelector('[data-role="ell-sum"]').textContent}));
        const r=EX.add(E,pts[i1],pts[i2]);
        ok(tag+' p = 5, P1 = '+EX.ptStr(E,pts[i1])+', P2 = '+EX.ptStr(E,pts[i2])+': exactly one highlighted row, the case "'+r.case+'" ('+key+'), sum '+EX.ptStr(E,r.R),s.act.length===1&&s.act[0]===key&&r.key===key&&s.lab===r.case&&s.sum.includes('= '+EX.ptStr(E,r.R)+' over F_5'),JSON.stringify(s));}}
    // ---- a_p table
    {const rows=await pg.evaluate(()=>[...document.querySelectorAll('[data-role="ell-ap-row"]')].map(r=>[...r.children].map(c=>c.textContent).concat([r.querySelector('[data-role="ell-red"]').dataset.type])));
      const want=EX.primesBelow(100n).map(p=>{const i=EX.apNaive(A,p),ii=p===2n?null:EX.apCharSum(A,p);return [String(p),String(i.count),String(i.ap).replace('-','\u2212'),ii?String(ii.ap).replace('-','\u2212'):'\u2014',ii?(ii.ap===i.ap?'yes':'NO'):'route (i) only'];});
      ok(tag+' a_p table: 25 rows equal to both core routes; agree = yes on 24 odd p, "route (i) only" at p = 2',rows.length===25&&rows.every((r,i)=>r.slice(0,5).join('|')===want[i].join('|'))&&rows.filter(r=>r[4]==='yes').length===24,JSON.stringify(rows.slice(0,3)));
      ok(tag+' a_p table: p = 37 labelled nonsplit multiplicative, every other row good',rows.every(r=>r[6]===(r[0]==='37'?'nonsplit':'good'))&&rows.find(r=>r[0]==='37')[5]==='nonsplit multiplicative');}
    // ---- period card
    for(const D of [10n,50n,100n]){const t0=Date.now();await setDial(pg,'per-D',D);const t1=Date.now();
      const s=await pg.evaluate(()=>({rows:[...document.querySelectorAll('[data-role="per-row"]')].map(e=>({k:e.dataset.key,pl:e.dataset.places,d:e.querySelector('[data-role="per-digits"]').textContent,w:e.querySelector('[data-role="per-width"]').textContent})),
        a1:document.querySelectorAll('[data-role="per-agm1-row"]').length,a2:document.querySelectorAll('[data-role="per-agm2-row"]').length,Dv:document.querySelector('[data-role="per-Dval"]').textContent,ms:document.querySelector('[data-role="per-ms"]').textContent,
        cw:document.querySelector('[data-role="per-cell"]').dataset.w,ch:document.querySelector('[data-role="per-cell"]').dataset.h,err:document.querySelector('[data-role="per-cell"]').dataset.error||'',reason:document.querySelector('[data-role="per-reason"]').textContent}));
      const R=PE.periods(A,D),K=[['e1',R.e1],['e2',R.e2],['e3',R.e3],['w1',R.w1],['w2',R.w2_over_i],['tau',R.tau_over_i],['Omega',R.Omega]];
      ok(tag+' D = '+D+': the seven readouts equal the core digits and widths, each with '+D+' guaranteed places',s.rows.length===7&&K.every(([k,x],i)=>s.rows[i].k===k&&s.rows[i].d===x.digits&&s.rows[i].w===x.width&&s.rows[i].pl===String(D))&&s.Dv==='D = '+D,JSON.stringify(s.rows.slice(0,2)));
      ok(tag+' D = '+D+': AGM step tables have '+R.agm1.steps.length+' and '+R.agm2.steps.length+' rows; the cell is drawn ('+s.cw+' × '+s.ch+' px); Ω reason shown',s.a1===R.agm1.steps.length&&s.a2===R.agm2.steps.length&&+s.cw>0&&+s.ch>0&&!s.err&&/two components/.test(s.reason),JSON.stringify(s).slice(0,200));
      const m=/computed in ([0-9]+) ms/.exec(s.ms);timing.push(tag+' D = '+D+': page compute '+(m?m[1]:'?')+' ms, dial round trip '+(t1-t0)+' ms');
      ok(tag+' D = '+D+': compute time shown ('+(m?m[1]:'?')+' ms) and under 2000 ms; no horizontal scroll',!!m&&+m[1]<2000&&!(await hscroll(pg)));}
    {await setDial(pg,'per-curve','11a1');const s=await pg.evaluate(()=>({ref:(document.querySelector('[data-role="per-refused"]')||{}).textContent,rows:document.querySelectorAll('[data-role="per-row"]').length}));
      ok(tag+' curve 11a1: the refusal label "'+PE.REFUSE_NEG+'" is visible and no readout is shown',s.ref===PE.REFUSE_NEG&&s.rows===0,JSON.stringify(s));
      await setDial(pg,'per-curve','37a1');}
    ok(tag+' no horizontal page scroll with both cards open',!(await hscroll(pg)));
    // ---- the cards survive a host re-render (state kept in the module) and Fourier is unaffected
    {await pg.click('[data-act="vtool"][data-v="collapse"]');await pg.waitForTimeout(300);await pg.click('[data-act="vtool"][data-v="open"]');await pg.waitForTimeout(400);
      const s=await pg.evaluate(()=>({k:(document.querySelector('[data-role="ell-kval"]')||{}).textContent,D:(document.querySelector('[data-role="per-Dval"]')||{}).textContent}));
      ok(tag+' Collapse / Open panels: both cards reopen with their dials kept (k = 10, D = 100)',s.k==='k = 10'&&s.D==='D = 100',JSON.stringify(s));}
    ok(tag+' no page errors and no console errors',errs.length===0,errs.join(' | '));
    await ctx.close();}
  await browser.close();
  for(const t of timing)console.log('TIMING '+t);
  console.log('SUMMARY browser-check-v0417: '+pass+' passed, '+fail+' failed');
  process.exit(fail?1:0);
})().catch(e=>{console.error(e);process.exit(1);});
