'use strict';
// v0.4.2 browser check (SCHEMA_ADDENDUM_10): (1) the N = 0 Wilson wording on the page and in the exports; (2) the shell-switch clamp phi3 -> B (N = 1).
// Playwright from s6_atom/node_modules; dist pages over file://. The v0.4.1 page is opened read-only, for the comparisons.
const path=require('path'),crypto=require('crypto');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').replace(/\\/g,'/');
const url41='file:///C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019/dist/comb-hopf.html';
const CC=require('../host-core/comb-core.js');
const NEW='N = 0: no comb, so the Wilson test does not apply.',OLD='N = 1 is not prime.';
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const info=s=>console.log('INFO '+s);
const addr=o=>CC.encodeAddress(CC.enterSpin(CC.initial(o),o.sTyped||'1'));
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[375,812,'375x812'],[1280,800,'1280x800']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500,acceptDownloads:true});
    const mk=async u=>{const p=await ctx.newPage(),errs=[];p.on('console',m=>{if(m.type()==='error')errs.push(m.text());});p.on('pageerror',e=>errs.push(String(e)));
      await p.goto(u);await p.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);return {p,errs};};
    const A=await mk(url),B=await mk(url41),pg=A.p;
    const go=async(p,u,o)=>{await p.goto(u+addr(o||{}));await p.reload();await p.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await p.waitForTimeout(200);await p.evaluate(()=>window.scrollTo(0,0));};
    const read=p=>p.evaluate(()=>({st:{...FVPanel.state},shell:document.getElementById('shell_read').textContent,status:document.getElementById('status').textContent,max:document.getElementById('phi_sl').max}));
    const wilsonText=p=>p.evaluate(()=>{const s=[...document.querySelectorAll('#cards .panel-sub')].find(e=>e.textContent.startsWith('Shell-N primality'));return s&&s.nextElementSibling?s.nextElementSibling.textContent:null;});
    // ---------------- 1. Fix 2: shell switch from the default state
    for(const [n1,Bv] of [['1','1'],['2','2']]){
      for(const nMode of ['integer','continuous']){
        await go(pg,url,nMode==='integer'?null:{nMode:'continuous'});
        const r0=await read(pg);
        await pg.selectOption('#n1_sel',n1);await pg.waitForTimeout(200);
        const r=await read(pg);
        ok(tag+' Fix 2: from the default state'+(nMode==='continuous'?' in continuous N mode (N∈ℚ)':'')+' (n₁ = 4, φ₃ = '+r0.st.phi3+', N = 2), picking n₁ = '+n1+' in the select gives B = '+Bv+', φ₃ = B = '+Bv+', N = 1 (shell readout "'+r.shell.replace(/\s+/g,' ').trim()+'"), no refusal',
          r0.st.phi3==='23'&&r.st.n1===n1&&r.st.phi3===Bv&&r.st.nMode===nMode&&/· N = 1$/.test(r.shell.trim())&&r.status==='',JSON.stringify(r));
        if(nMode==='integer'){const wt=await wilsonText(pg);ok(tag+' Fix 2: n₁ = '+n1+' landing on N = 1 shows the Wilson card "'+wt+'"',wt===OLD,wt);
          await pg.screenshot({path:path.join(root,'shot_v042_'+tag+'_n1_'+n1+'_from_default.png')});}
        // the same transition on the v0.4.1 page lands on N = 0 (the defect, recorded for comparison)
        await go(B.p,url41,nMode==='integer'?null:{nMode:'continuous'});await B.p.selectOption('#n1_sel',n1);await B.p.waitForTimeout(200);
        const q=await read(B.p);info(tag+' v0.4.1 page, same transition: φ₃ = '+q.st.phi3+', shell readout "'+q.shell.replace(/\s+/g,' ').trim()+'"');
        ok(tag+' Fix 2 control: on the v0.4.1 page the same transition gives φ₃ = B + 1 = '+(Number(Bv)+1)+' (N = 0); the two states differ in φ₃ only',q.st.phi3===String(Number(Bv)+1)&&JSON.stringify({...q.st,phi3:Bv})===JSON.stringify(r.st),JSON.stringify(q.st));
      }
    }
    // continuous mode with a fractional phi3 above the new range: 47/2 -> n1 = 2 gives phi3 = 2
    {await go(pg,url,{nMode:'continuous',phi3:'47/2'});await pg.selectOption('#n1_sel','2');await pg.waitForTimeout(200);const r=await read(pg);
     ok(tag+' Fix 2 continuous mode: φ₃ = 47/2 (N = 3/2), picking n₁ = 2 gives φ₃ = 2, N = 1 (exact comparison 47/2 > B + 1 = 3)',r.st.phi3==='2'&&/· N = 1$/.test(r.shell.trim())&&r.status==='',JSON.stringify(r));}
    // integer B = 1 from the default: mode integer (B = 24, no clamp), then M box 1 + Enter
    {await go(pg,url,null);await pg.click('[data-act="mode"][data-v="integer"]');await pg.waitForTimeout(150);const r1=await read(pg);
     await pg.fill('#Mbox','1');await pg.press('#Mbox','Enter');await pg.waitForTimeout(200);const r=await read(pg);
     ok(tag+' Fix 2 integer base: from the default, integer mode (B = 24, φ₃ = '+r1.st.phi3+' kept, N = 2), then M box 1 + Enter gives B = 1, φ₃ = 1, N = 1 ("'+r.shell.replace(/\s+/g,' ').trim()+'")',
       r1.st.phi3==='23'&&r1.st.shellMode==='integer'&&r.st.B==='1'&&r.st.phi3==='1'&&/· N = 1$/.test(r.shell.trim())&&r.status==='',JSON.stringify({r1,r}));
     await pg.screenshot({path:path.join(root,'shot_v042_'+tag+'_B1_integer_from_default.png')});
     await go(B.p,url41,null);await B.p.click('[data-act="mode"][data-v="integer"]');await B.p.waitForTimeout(150);await B.p.fill('#Mbox','1');await B.p.press('#Mbox','Enter');await B.p.waitForTimeout(200);
     const q=await read(B.p);info(tag+' v0.4.1 page, same transition: φ₃ = '+q.st.phi3+', shell readout "'+q.shell.replace(/\s+/g,' ').trim()+'"');}
    // the rule fires only above the range: default -> n1 = 2 (phi3 = 2, N = 1) -> n1 = 1 keeps phi3 = 2 = B + 1 (in range), so N = 0 (recorded for saphir)
    {await go(pg,url,null);await pg.selectOption('#n1_sel','2');await pg.waitForTimeout(150);await pg.selectOption('#n1_sel','1');await pg.waitForTimeout(150);const r=await read(pg);
     ok(tag+' Fix 2 rule boundary (as specified): default → n₁ = 2 (φ₃ = 2, N = 1) → n₁ = 1: φ₃ = 2 is inside 0 … B + 1 = 2, so no clamp fires and the state is N = 0 ("'+r.shell.replace(/s+/g,' ').trim()+'"); recorded for decision',r.st.phi3==='2'&&/N = 0/.test(r.shell),JSON.stringify(r));}
    // N = 0 is still reachable by setting phi3 = B + 1 directly: the phi3 drawer box, the N - 1 arrow and the slider
    {await go(pg,url,null);await pg.selectOption('#n1_sel','1');await pg.waitForTimeout(150);
     await pg.click('#lab_phi3');await pg.waitForTimeout(100);await pg.fill('#phi_tx','2');await pg.press('#phi_tx','Enter');await pg.waitForTimeout(200);
     const r=await read(pg),wt=await wilsonText(pg);
     ok(tag+' N = 0 still reachable: after n₁ = 1 (φ₃ = 1), typing φ₃ = 2 = B + 1 in the φ₃ box gives N = 0 ("'+r.shell.replace(/\s+/g,' ').trim()+'"), no refusal; Wilson card "'+wt+'"',r.st.phi3==='2'&&/N = 0/.test(r.shell)&&r.status===''&&wt===NEW,JSON.stringify({r,wt}));
     await go(pg,url,{shellMode:'factorial',n1:'1',phi3:'1'});await pg.evaluate(()=>FVPanel.onAct('phidn'));await pg.waitForTimeout(150);const r2=await read(pg);
     ok(tag+' N = 0 still reachable: from n₁ = 1, φ₃ = 1 (N = 1), ◀ (N − 1) gives φ₃ = 2, N = 0',r2.st.phi3==='2'&&/N = 0/.test(r2.shell),JSON.stringify(r2));
     await go(pg,url,null);await pg.evaluate(()=>{const s=document.getElementById('phi_sl');s.value=s.max;s.dispatchEvent(new Event('input',{bubbles:true}));s.dispatchEvent(new Event('change',{bubbles:true}));});await pg.waitForTimeout(200);const r3=await read(pg);
     ok(tag+' N = 0 still reachable: on the default shell the φ₃ slider at its maximum gives φ₃ = 25 = B + 1, N = 0',r3.st.phi3==='25'&&/N = 0/.test(r3.shell),JSON.stringify(r3));}
    // ---------------- 2. Fix 2 scope: every other transition is unchanged (battery, both pages, FVPanel API = the handlers' own calls)
    {const starts=[{},{nMode:'continuous'},{nMode:'continuous',phi3:'47/2'},{phi3:'0'},{phi3:'25'},{phi3:'5'},{n1:'5',phi3:'121'},{n1:'5',phi3:'100'},{n1:'6',phi3:'700'},{n1:'6',nMode:'continuous',phi3:'1401/2'},
        {n1:'1',phi3:'2'},{n1:'2',phi3:'1'},{n1:'3',phi3:'7'},{shellMode:'integer',B:'61',phi3:'40'},{shellMode:'integer',B:'2',phi3:'3'},{shellMode:'integer',B:'1',phi3:'0'},{shellMode:'integer',B:'30',phi3:'31',n1:'4'},
        {shellMode:'integer',B:'30',nMode:'continuous',phi3:'61/2',n1:'3'},{shellMode:'integer',B:'6227020800',phi3:'6227020801',n1:'13'}].map(o=>({m:'3',t1:'1',t2:'1',...o}));
     const acts=[];for(let k=1;k<=13;k++)acts.push(['n1',String(k)]);acts.push(['n1up'],['n1dn'],['mode','integer'],['mode','factorial']);
     for(const b of ['1','2','3','5','24','100','6227020800'])acts.push(['B',b]);acts.push(['phidn'],['phiup'],['start'],['g0'],['nmode'],['mup'],['mdn'],['t1up'],['sup']);
     const run=(p,a0,acts)=>p.evaluate(([a0,acts])=>{const out=[];for(const a of acts){FVPanel.apply(()=>FVCombCore.importAny(a0).state);const before={...FVPanel.state};
         if(a[0]==='B')FVPanel.dial({shellMode:'integer',B:a[1]});else FVPanel.onAct(a[0],a[1]);out.push({before,after:{...FVPanel.state}});}return out;},[a0,acts]);
     let n=0,same=0,clamp=0,bad=[],clampBad=0;
     for(const o of starts){const a0=addr(o);const ra=await run(pg,a0,acts),rb=await run(B.p,a0,acts);
       acts.forEach((a,i)=>{n++;const x=ra[i].after,y=rb[i].after,bf=ra[i].before;
         const isShell=a[0]==='n1'||a[0]==='n1up'||a[0]==='n1dn'||a[0]==='mode'||a[0]==='B';
         if(JSON.stringify(x)===JSON.stringify(y)){same++;
           if(isShell&&x.shellMode!==undefined){const Bn=x.shellMode==='integer'?BigInt(x.B):[...Array(Number(x.n1)).keys()].reduce((f,k)=>f*BigInt(k+1),1n);const pf=bf.phi3.split('/');const over=BigInt(pf[0])>(Bn+1n)*BigInt(pf[1]||'1');if(over)clampBad++;}
           return;}
         const Bn=x.shellMode==='integer'?BigInt(x.B):[...Array(Number(x.n1)).keys()].reduce((f,k)=>f*BigInt(k+1),1n);
         const expected=isShell&&y.phi3===String(Bn+1n)&&x.phi3===String(Bn)&&JSON.stringify({...y,phi3:x.phi3})===JSON.stringify(x);
         if(expected)clamp++;else if(bad.length<4)bad.push(JSON.stringify({a0:o,a,x,y}));else bad.push('…');});}
     ok(tag+' Fix 2 scope: '+n+' transitions ('+starts.length+' start states × '+acts.length+' actions: n₁ = 1…13, n₁ ◀ ▶, shell mode both ways, M box B ∈ {1, 2, 3, 5, 24, 100, 6227020800}, φ₃ ◀ ▶, start, g = 0, N mode, m ◀ ▶, t₁ ▶, s ▶) on the v0.4.2 and v0.4.1 pages: '+same+' give the same state; '+clamp+' differ, every one a shell switch with the old φ₃ above the new B + 1, where v0.4.1 gives φ₃ = B + 1 and v0.4.2 gives φ₃ = B, nothing else differing; 0 others',
       bad.length===0&&clampBad===0&&clamp>0&&same+clamp===n,bad.slice(0,4).join(' | ')+(clampBad?' clamp-condition states that did not differ: '+clampBad:''));}
    // ---------------- 3. Fix 1 on the page and in the exports; byte identity of the page outputs for N != 0
    const outs=async(p,u,o,tab)=>{await go(p,u,{...o,tab});return p.evaluate(async()=>{
        const r={cards:document.getElementById('cards').textContent,stage:document.getElementById('stage').innerHTML,shell:document.getElementById('shell_read').textContent};
        for(const k of ['xstats','xjson','xstate','xcsv','xlift']){await FVPanel.onAct(k);await new Promise(z=>setTimeout(z,60));r[k]=document.getElementById('xout').value;}
        let png=null;try{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);png=[...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');}catch(e){png='refused: '+e.message;}
        r.png=png;return r;});};
    {const cases=[['default',{}],['N1 n1=1',{shellMode:'factorial',n1:'1',phi3:'1'}],['N2 n1=1',{shellMode:'factorial',n1:'1',phi3:'0'}],['N3/2 between',{shellMode:'factorial',n1:'1',nMode:'continuous',phi3:'1/2'}],
        ['N13 B24',{shellMode:'integer',B:'24',phi3:'12',m:'5'}],['N5 star',{shellMode:'integer',B:'24',phi3:'20',m:'6',t1:'1/2',t2:'1'}],['N10001',{shellMode:'integer',B:'10001',phi3:'1'}],
        ['N0 default shell',{phi3:'25'}],['N0 n1=1',{shellMode:'factorial',n1:'1',phi3:'2'}],['N0 n1=2 continuous',{shellMode:'factorial',n1:'2',nMode:'continuous',phi3:'3'}],['N0 integer B=1',{shellMode:'integer',B:'1',phi3:'2'}],['N0 n1=13',{shellMode:'factorial',n1:'13',phi3:'6227020801'}]];
     for(const tab of ['fourier','clifford','panels']){let n=0,n0=0,bad=[],png0=0;
       for(const [lab,o] of cases){const a=await outs(pg,url,o,tab),b=await outs(B.p,url41,o,tab);n++;const isN0=lab.startsWith('N0');
         for(const k of Object.keys(a)){let want=b[k];if(isN0&&(k==='cards'||k==='xstats'||k==='xjson'))want=want.split(OLD).join(NEW);
           if(k==='png'&&tab==='panels'){if(!/^refused/.test(a.png)||a.png!==b.png)bad.push(lab+' png');continue;}
           if(k==='png'&&!/^[0-9a-f]{64}$/.test(a.png))bad.push(lab+' png not computed: '+a.png);if(k==='stage'&&tab!=='panels'&&a.stage.length<200)bad.push(lab+' stage empty');
           if(a[k]!==want)bad.push(lab+' '+k);}
         if(isN0){n0++;if(!(a.cards.includes(NEW)&&!a.cards.includes(OLD)&&a.xstats.includes('Wilson shell-N: '+NEW)&&JSON.parse(a.xjson).exact.wilsonN===NEW&&b.cards.includes(OLD)))bad.push(lab+' N0 wording');
           if(b.cards.split(OLD).length-1!==1||b.xstats.split(OLD).length-1!==1||b.xjson.split(OLD).length-1!==1)bad.push(lab+' old label count');}}
       ok(tag+' Fix 1 page outputs, '+tab+' tab: '+n+' states ('+(n-n0)+' with N ≠ 0, '+n0+' with N = 0) on the v0.4.2 and v0.4.1 pages — cards text, drawing (SVG stage), shell readout, stats, exact JSON, state JSON, CSV, Lift JSON and the PNG export (sha256'+(tab==='panels'?'; the Panels tab refuses the PNG on both pages':'')+') are byte-identical for N ≠ 0; for N = 0 they are identical except that the one occurrence of "'+OLD+'" in the Wilson card, the stats line "Wilson shell-N: …" and the exact field exact.wilsonN reads "'+NEW+'"',bad.length===0,bad.join(', '));}}
    // N = 0 screenshot with the Wilson card in view
    {await go(pg,url,{phi3:'25',tab:'fourier'});
     const loc=pg.locator('#cards section.card',{hasText:'Shell-N primality'});await loc.scrollIntoViewIfNeeded();await pg.waitForTimeout(150);
     const wt=await wilsonText(pg),r=await read(pg);
     ok(tag+' N = 0 (default shell, φ₃ = 25): the Wilson card reads "'+wt+'" and the shell readout "'+r.shell.replace(/\s+/g,' ').trim()+'"',wt===NEW&&/N = 0/.test(r.shell),wt);
     await pg.screenshot({path:path.join(root,'shot_v042_'+tag+'_N0_wilson.png')});}
    ok(tag+' no console or page errors in the v0.4.2 checks (v0.4.2 page)',A.errs.length===0,A.errs.join(' | '));
    info(tag+' v0.4.1 page console/page errors: '+B.errs.length);
    {const sx=await pg.evaluate(()=>document.documentElement.scrollWidth<=innerWidth);ok(tag+' no horizontal scroll',sx);}
    await ctx.close();
  }
  await browser.close();
  console.log(`browser-check-v042: ${pass} passed, ${fail} failed`);
  process.exit(fail?1:0);
})().catch(e=>{console.error(e);process.exit(2);});
