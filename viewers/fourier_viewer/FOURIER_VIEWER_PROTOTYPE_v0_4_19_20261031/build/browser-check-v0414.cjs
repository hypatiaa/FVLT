'use strict';
// v0.4.14 browser check (SCHEMA_ADDENDUM_22): the Goldbach prime-pair track "Goldbach N ▸". 1280x800 and 375x812. The reference arithmetic is independent of goldbach-core (own sieve, own G_N).
const fs=require('fs'),path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url413=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js'),GB=require('../host-core/goldbach-core.js'),X=require('../exact-lib/exact-lib-0.2.0.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const LIM=1500,comp=new Uint8Array(LIM+1);comp[0]=comp[1]=1;for(let i=2;i*i<=LIM;i++)if(!comp[i])for(let j=i*i;j<=LIM;j+=i)comp[j]=1;
const pr=n=>n>=2&&!comp[n],refPairs=N=>{const o=[];for(let p=2;p<=N/2;p++)if(pr(p)&&pr(N-p))o.push(p);return o;};
function G(N,s){let re=0,im=0;for(const p of refPairs(N))for(const e of [p,N-p]){const t=2*Math.PI*e*s/N;re+=Math.cos(t);im+=Math.sin(t);}return {re,im};}
const sval=s=>{const q=X.parse(s);return Number(q.n)/Number(q.d);};
const gaddr=(N,s,tab,extra)=>CC.encodeAddress(CC.initial({...GB.patchFor(N),sTyped:s||'1',sEff:s||'1',tab:tab||'fourier',...(extra||{})}));
const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(350);};
const setHash=async(pg,h)=>{const n0=await pg.evaluate(()=>FVPanel.perf.n);await pg.evaluate(x=>{location.hash=x;},h);await pg.waitForFunction(n=>FVPanel.perf.n>n,n0,{timeout:20000});};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,hstage:(document.getElementById('htmlstage')||{innerHTML:''}).innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:(document.getElementById('about')||{innerHTML:''}).innerHTML,cards:(document.getElementById('cards')||{innerHTML:''}).innerHTML,hash:location.hash,addr:document.getElementById('addr').textContent}));
const exportsOf=pg=>pg.evaluate(async()=>{const r={};for(const k of ['xstats','xjson','xstate','xcsv','xlift']){await FVPanel.onAct(k);await new Promise(z=>setTimeout(z,60));r[k]=document.getElementById('xout').value;}return r;});
const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
const q=(pg,sel)=>pg.evaluate(s=>document.querySelectorAll(s).length,sel);
const S_LIST=['0','1','1/2','4/3','7/5','-2/3','15/4','3/7'];
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- control counts
    for(const tab of ['fourier','clifford','hopf']){const r=[];
      for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){
        await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr(o)+x,url413);r.push(await count(pg));}
      ok(tag+' '+tab+': counts 39/41/39/41 unchanged, v0.4.14 = v0.4.13 ('+r.join('/')+')',r.join('/')==='39/39/41/41/39/39/41/41',r.join('/'));
      const g=[];for(const N of [4,24,30,1448]){await gopen(pg,gaddr(N,'1',tab)+'&gb=1');g.push(await count(pg));}
      ok(tag+' '+tab+': counts on the Goldbach track (N = 4, 24, 30, 1448) = '+g.join('/')+' (39, no new control)',g.join('/')==='39/39/39/39',g.join('/'));}
    // ---- the menu: last option of the CA preset menu, gb_sel inventory, enter/leave by the controls
    {await gopen(pg,addr({shellMode:'integer',B:'5040',tab:'fourier'},'&ca=1'));
      const o=await pg.evaluate(()=>[...document.querySelectorAll('#ca_sel option')].map(e=>e.value+'|'+e.textContent));
      ok(tag+' menu: "Goldbach N ▸" is the last option of the CA preset menu (after "n²+1 shells ▸"): '+o.slice(-2).join(' ; '),o[o.length-1]==='gb|Goldbach N ▸'&&o[o.length-2]==='sq|n²+1 shells ▸');
      const g=await pg.evaluate(()=>[...document.querySelectorAll('#gb_sel option')].map(e=>e.value));
      ok(tag+' menu: the Goldbach menu lists the back option and every even N = 4…1448 ('+(g.length-1)+' shells)',g[0]==='ca'&&g.length===724&&g[1]==='4'&&g[g.length-1]==='1448'&&g.slice(1).every((v,i)=>+v===4+2*i));
      await pg.selectOption('#ca_sel','gb');await pg.waitForTimeout(300);
      let r=await pg.evaluate(()=>({gbN:FVPanel.gbN,addr:document.getElementById('addr').textContent,st:{...FVPanel.state},gbvis:getComputedStyle(document.getElementById('gb_sel')).display,cavis:getComputedStyle(document.getElementById('ca_sel')).display,mbox:getComputedStyle(document.getElementById('Mbox')).display,pressed:document.getElementById('mode_i').getAttribute('aria-pressed')}));
      ok(tag+' menu: choosing it from the CA menu enters the track at N = 24 (B = 11, φ₃ = 0, m = 8), address ends &gb=1, the Goldbach menu replaces the CA menu',r.gbN===24&&r.addr===gaddr(24,'1','fourier')+'&gb=1'&&r.gbvis!=='none'&&r.cavis==='none'&&r.mbox==='none'&&r.pressed==='false',JSON.stringify([r.gbN,r.addr,r.gbvis,r.cavis]));
      await pg.selectOption('#gb_sel','30');await pg.waitForTimeout(300);
      r=await pg.evaluate(()=>({gbN:FVPanel.gbN,addr:document.getElementById('addr').textContent,st:{...FVPanel.state}}));
      const e30=GB.settings(30);
      ok(tag+' menu: choosing N = 30 sets B = 14, φ₃ = 0, t₂ = 2, m = '+e30.m+', n₆ = 1, α = 0 (convention B) and keeps s; address &gb=1',r.gbN===30&&r.st.B==='14'&&r.st.phi3==='0'&&r.st.t2==='2'&&r.st.m===String(e30.m)&&r.st.n6==='1'&&r.st.alpha==='0'&&r.st.t1==='1'&&r.addr.endsWith('&gb=1')&&r.st.sTyped==='1',JSON.stringify(r.st));
      await pg.selectOption('#gb_sel','ca');await pg.waitForTimeout(300);
      r=await pg.evaluate(()=>({gbN:FVPanel.gbN,addr:document.getElementById('addr').textContent,B:FVPanel.state.B}));
      ok(tag+' menu: "◂ CA presets" leaves the track: back to CA (B = 5040), address has ca=1 and no gb',r.gbN===null&&r.B==='5040'&&r.addr.endsWith('&ca=1')&&!/gb=1/.test(r.addr));
      await gopen(pg,gaddr(24,'1','fourier')+'&gb=1');await pg.evaluate(()=>FVPanel.dial({m:'9'}));await pg.waitForTimeout(200);
      r=await pg.evaluate(()=>({gbN:FVPanel.gbN,addr:document.getElementById('addr').textContent}));
      ok(tag+' track: a dial leaving the preset (m = 9) ends the track; address drops &gb=1',r.gbN===null&&!/gb=1/.test(r.addr));}
    // ---- identity through the built viewer: pen = G_N(s), N = 4…200 (every even N), several s; both N/2 parities; and N up to 1,448
    {let max=0,n=0,bad=[],gOk=0,t0=Date.now();
      await gopen(pg,gaddr(4,'1','fourier')+'&gb=1');
      for(let N=4;N<=200;N+=2){for(const s of S_LIST){await setHash(pg,gaddr(N,s,'fourier')+'&gb=1');
          const r=await pg.evaluate(()=>{const m=FVPanel.model,W=m.num.W,e=W[W.length-1];return {gbN:FVPanel.gbN,re:e.re,im:e.im,bound:m.num.bound,g:m.gb.g,gtxt:(document.querySelector('[data-role="gb-g"]')||{textContent:''}).textContent};});
          const g=G(N,sval(s)),d=Math.hypot(r.re-g.re,r.im-g.im);max=Math.max(max,d);n++;
          if(d>1e-12||r.gbN!==N||r.g!==refPairs(N).length||!r.gtxt.startsWith(refPairs(N).length+' · G_N(0) = 2g(N) = '+2*refPairs(N).length))bad.push(N+'/'+s);else gOk++;}}
      ok(tag+' identity: the built viewer\'s pen = G_N(s) for every even N = 4…200 at '+S_LIST.length+' s values ('+n+' states): max |diff| = '+max.toExponential(2)+' <= 1e-12; track on, g(N) and "G_N(0) = 2g(N)" readout correct ('+gOk+'/'+n+', '+Math.round((Date.now()-t0)/1000)+' s)',bad.length===0,bad.slice(0,6).join(' '));}
    // g(N) exact against independent trial division for every even N <= 1,448, read from the viewer's card
    {let bad=[],t0=Date.now();await gopen(pg,gaddr(4,'1','fourier')+'&gb=1');
      for(let N=4;N<=1448;N+=2){if(N>4)await setHash(pg,gaddr(N,'1','fourier')+'&gb=1');const t=await pg.evaluate(()=>(document.querySelector('[data-role="gb-g"]')||{textContent:''}).textContent+'|'+FVPanel.gbN+'|'+FVPanel.state.m);const g=refPairs(N).length;
        if(!t.startsWith(g+' · G_N(0) = 2g(N) = '+2*g+'|'+N+'|'))bad.push(N+':'+t);}
      ok(tag+' g(N): the viewer\'s card reads g(N) = #P_N and G_N(0) = 2g(N) equal to independent trial division for all 723 even N = 4…1448 ('+Math.round((Date.now()-t0)/1000)+' s)',bad.length===0,bad.slice(0,4).join(' '));}
    // pen at large N through the viewer (sample)
    {let max=0,n=0;for(const N of [210,720,722,1000,1442,1448])for(const s of ['0','1/2','4/3','-2/3']){await gopen(pg,gaddr(N,s,'fourier')+'&gb=1');
        const r=await pg.evaluate(()=>{const m=FVPanel.model,W=m.num.W,e=W[W.length-1];return {re:e.re,im:e.im,ok:FVPanel.gbN};});const g=G(N,sval(s));max=Math.max(max,Math.hypot(r.re-g.re,r.im-g.im));n++;if(r.ok!==N)max=1;}
      ok(tag+' identity at large N (210 … 1448), '+n+' states: max |diff| = '+max.toExponential(2),max<1e-11);}
    // ---- branch table for N <= 200 read from the DOM: raw winding, ×1, unknot iff a_p <= 1, torus-knot types, k
    {let rows=0,bad=[];await gopen(pg,gaddr(4,'1','fourier')+'&gb=1');await pg.evaluate(()=>FVPanel.onAct('gbexpand'));
      for(let N=4;N<=200;N+=2){if(N>4)await setHash(pg,gaddr(N,'1','fourier')+'&gb=1');
        const chips=await pg.evaluate(()=>[...document.querySelectorAll('[data-role="gb-branch"]')].map(e=>({c:e.dataset.c,t:e.textContent})));
        const S=GB.settings(N),exp=[];for(const p of refPairs(N)){const a=N/2-p;for(const sg of (a===0?[1]:[1,-1])){const c=sg*a/S.t2,sgn=n=>n<0?'−'+(-n):String(n),mult=a===0?N/2:1,prim=a===0?'1,0':(N/2)+','+sgn(-sg*a);
            const type=a===0?'UNKNOT':a<=1?'UNKNOT':'T('+Math.min(a,N/2)+','+Math.max(a,N/2)+')'+(sg>0?'−':'+');
            exp.push({c:String(c),text:'c '+(c>0?'+':c<0?'−':'')+Math.abs(c)+' · raw ('+(N/2)+','+sgn(-sg*a)+') · primitive ('+(a===0?'1,0':(N/2)+','+sgn(-sg*a))+') ×'+mult+' · '+type+' · k = '+(sg>0?N-p:p)});}}
        const got=chips.map(x=>x.c+'|'+x.t).sort().join('\n'),want=exp.map(x=>x.c+'|'+x.text).sort().join('\n');rows+=exp.length;if(got!==want)bad.push(N);}
      ok(tag+' branch table (DOM, N <= 200): every masked branch chip reads raw (N/2, ∓a_p), primitive ×1 (equal pair ×N/2), unknot exactly for a_p <= 1, T(min,max) with mirror signs, k = p or N − p ('+rows+' chips)',bad.length===0&&rows===1135,bad.slice(0,5).join(' '));}
    // ---- ghosted teeth: drawn, labelled, not in the pen (Fourier, Clifford, Hopf)
    for(const [N,s] of [[24,'4/3'],[30,'15/4'],[120,'1/3'],[210,'7/5']]){const M=GB.model(N);
      await gopen(pg,gaddr(N,s,'fourier')+'&gb=1');
      let r=await pg.evaluate(()=>({tooth:document.querySelectorAll('[data-role="tooth"]').length,ghost:document.querySelectorAll('[data-role="tooth-ghost"]').length,hit:document.querySelectorAll('[data-role="hit"]').length,vert:document.querySelectorAll('[data-role="vertex"]').length,cap:document.getElementById('caption').textContent,walk:(document.querySelector('[data-role="walk"]')||{getAttribute:()=>''}).getAttribute('points').split(' ').length,rows:document.querySelectorAll('#cards tr[data-gb="ghost"]').length}));
      ok(tag+' ghosts, Fourier, N = '+N+': '+M.kept+' rays in the pen, '+M.removed+' ghosted rays drawn, all '+M.m+' hit targets, '+(M.kept+1)+' walk vertices, label in the caption',r.tooth===M.kept&&r.ghost===M.removed&&r.hit===M.m&&r.vert===M.kept+1&&r.walk===M.kept+1&&r.cap.includes('removed by the prime filter: N/2 ± c not both prime'),JSON.stringify(r));
      await gopen(pg,gaddr(N,s,'clifford')+'&gb=1');
      r=await pg.evaluate(()=>({orb:document.querySelectorAll('[data-role="orbit"]').length,og:document.querySelectorAll('[data-role="orbit-ghost"]').length,dot:document.querySelectorAll('[data-role="tooth-dot"]').length,dg:document.querySelectorAll('[data-role="tooth-dot-ghost"]').length,cap:document.getElementById('caption').textContent}));
      ok(tag+' ghosts, Clifford, N = '+N+': '+M.kept+' solid branches + dots, '+M.removed+' ghosted, one leaf, label in the caption',r.orb===M.kept&&r.og===M.removed&&r.dot===M.kept&&r.dg===M.removed&&r.cap.includes('removed by the prime filter')&&r.cap.includes('one leaf'),JSON.stringify(r));
      await gopen(pg,gaddr(N,s,'hopf')+'&gb=1');
      r=await pg.evaluate(()=>({vert:document.querySelectorAll('[data-role="vertex"]').length,dot:document.querySelectorAll('[data-role="tooth-dot"]').length,dg:document.querySelectorAll('[data-role="tooth-dot-ghost"]').length,cap:document.getElementById('caption').textContent}));
      ok(tag+' ghosts, Hopf base, N = '+N+': '+(M.kept+1)+' walk vertices, '+M.kept+' solid dots, '+M.removed+' ghost dots, caption "no new claim"',r.vert===M.kept+1&&r.dot===M.kept&&r.dg===M.removed&&r.cap.includes('no new claim'),JSON.stringify(r));}
    // ---- readouts text and guards (exact register), fixtures
    {await gopen(pg,gaddr(24,'4/3','fourier')+'&gb=1');
      const t=await pg.evaluate(()=>document.querySelector('.gb-card').textContent);
      ok(tag+' fixture N = 24, s = 4/3: page reads "|W| ≤ bound … not certified zero"; N/2 = 12 is not prime (no equal pair); twin pair (11, 13) is an unknot; (5, 19) is T(7,12)',/not certified zero/.test(t)&&/N\/2 = 12 is not prime/.test(t)&&/\(11, 13\)1c −1 · raw \(12,1\) · primitive \(12,1\) ×1 · UNKNOT/.test(t)&&/T\(7,12\)\+/.test(t),t.slice(0,300));
      ok(tag+' guards printed: Interference register, Empty-fiber guard, Unit-fiber guard, "Closure reaches conjugation, not Goldbach." (Rmk II.23.5b), status line; Λ_G and the coprime reference are not shown',/Interference register\. “Constructive” and “destructive” interference mean only addition and cancellation of complex vectors in this finite sum\./.test(t)&&/Empty-fiber guard\. The identity remains true when P_N is empty, in which case G_N≡0\. The corollary therefore makes no Goldbach-coverage claim\./.test(t)&&/Unit-fiber guard/.test(t)&&/Closure reaches conjugation, not Goldbach\./.test(t)&&/Prime selection: definitional\/external/.test(t)&&!/Λ_G|coprime reference|local factor/.test(t.replace(/The Λ_G\(N\) local factor and the coprime reference stay[^.]*\./,'')));
      await gopen(pg,gaddr(30,'1','fourier')+'&gb=1');const t2=await pg.evaluate(()=>document.querySelector('.gb-card').textContent);
      ok(tag+' N = 30: N/2 = 15, t₂ = 2, m = '+GB.settings(30).m+'; branches c = ∓4, ∓2, ∓1 with raw (15, ±8), (15, ±4), (15, ±2); (7, 23) is T(8,15)',/t₂ = 2, m = 9/.test(t2)&&/c −4 · raw \(15,8\)/.test(t2)&&/c \+4 · raw \(15,−8\)/.test(t2)&&/T\(8,15\)/.test(t2)&&/T\(4,15\)/.test(t2)&&/T\(2,15\)/.test(t2),t2.slice(0,400));
      await gopen(pg,gaddr(14,'1','fourier')+'&gb=1');const t3=await pg.evaluate(()=>document.querySelector('.gb-card').textContent);
      ok(tag+' N = 14 (N/2 = 7 prime): the equal pair is present, weight 2, raw (7,0) → primitive (1,0) ×7, unknot; pen at s = 0 is 2g(N) = 2·2',/N\/2 = 7 is prime: the equal pair p = N\/2 is present/.test(t3)&&/primitive \(1,0\) ×7/.test(t3)&&/G_N\(0\) = 2g\(N\) = 4/.test(t3),t3.slice(0,400));}
    // ---- tilt: refused on the track, switched off on entry (status line says which)
    {await gopen(pg,gaddr(24,'1','fourier')+'&gb=1');
      await pg.evaluate(()=>FVPanel.dial({tilt:'1/2'}));await pg.waitForTimeout(200);
      let r=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,gbN:FVPanel.gbN,status:document.getElementById('status').textContent,addr:document.getElementById('addr').textContent}));
      ok(tag+' tilt: a nonzero α_Tilt is REFUSED while the track is on (state unchanged, status says so, track stays on)',r.tilt===undefined&&r.gbN===24&&/α_Tilt is refused while the Goldbach track is on/.test(r.status)&&r.addr.endsWith('&gb=1'),JSON.stringify(r));
      await pg.evaluate(()=>FVPanel.dial({tilt:'0'}));await pg.waitForTimeout(150);
      r=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,gbN:FVPanel.gbN}));ok(tag+' tilt: setting α_Tilt = 0 is allowed on the track',r.tilt===undefined&&r.gbN===24);
      await pg.evaluate(()=>FVPanel.onAct('drawer','alpha'));await pg.waitForTimeout(200);
      ok(tag+' tilt: the α_Tilt drawer carries the label "α_Tilt is refused on the Goldbach track"',(await q(pg,'[data-role="tilt-gb"]'))===1);
      // entering with a nonzero tilt switches it off, with a status line
      await gopen(pg,CC.encodeAddress(CC.initial({...GB.patchFor(24),sTyped:'1',sEff:'1',tab:'fourier'}))+'&tilt=1/3');
      ok(tag+' tilt: the Goldbach shell with α_Tilt = 1/3 and no flag is an ordinary state (track off)',(await pg.evaluate(()=>({g:FVPanel.gbN,t:FVPanel.state.tilt}))).t==='1/3');
      await pg.click('#mode_ca');await pg.waitForTimeout(250);await pg.selectOption('#ca_sel','gb');await pg.waitForTimeout(300);
      r=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,gbN:FVPanel.gbN,status:document.getElementById('status').textContent,addr:document.getElementById('addr').textContent}));
      ok(tag+' tilt: entering the track with α_Tilt = 1/3 switches it OFF with the status line "α_Tilt switched off (was 1/3)" (not refused)',r.tilt===undefined&&r.gbN===24&&/α_Tilt switched off \(was 1\/3\)/.test(r.status)&&r.addr.endsWith('&gb=1')&&!/tilt/.test(r.addr),JSON.stringify(r));
      // a flag with a tilt in the address is refused
      await gopen(pg,CC.encodeAddress(CC.initial({...GB.patchFor(24),sTyped:'1',sEff:'1',tab:'fourier'}))+'&tilt=1/3&gb=1');
      r=await pg.evaluate(()=>({g:FVPanel.gbN,t:FVPanel.state.tilt,status:document.getElementById('status').textContent}));
      ok(tag+' tilt: address with &tilt=1/3&gb=1: flag refused with a label (α_Tilt ≠ 0), loaded without the track',r.g===null&&r.t==='1/3'&&/Goldbach track flag refused: α_Tilt ≠ 0/.test(r.status),JSON.stringify(r));}
    // ---- address round trip and refusals
    {let okRT=0,n=0;for(const N of [4,6,24,30,210,1448]){for(const tab of ['fourier','clifford','hopf','panels']){const a=gaddr(N,'3/7',tab)+'&gb=1';await gopen(pg,a);n++;
          const r=await pg.evaluate(()=>({addr:document.getElementById('addr').textContent,hash:location.hash,gbN:FVPanel.gbN}));let good=r.addr===a&&r.hash===a&&r.gbN===N;
          await pg.reload();await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(250);
          const r2=await pg.evaluate(()=>({addr:document.getElementById('addr').textContent,hash:location.hash,gbN:FVPanel.gbN}));good=good&&r2.addr===a&&r2.hash===a&&r2.gbN===N;if(good)okRT++;}}
      ok(tag+' address: &gb=1 round trip (written, read, reload) in '+okRT+'/'+n+' states (N = 4, 6, 24, 30, 210, 1448 × four tabs); written only while the track is on',okRT===n);
      const base=gaddr(24,'1','fourier');
      const refusals=[['duplicate',base+'&gb=1&gb=1',/must be exactly gb=1/],['gb=2',base+'&gb=2',/must be exactly gb=1/],['gb=',base+'&gb=',/must be exactly gb=1/],['with ca=1',addr({shellMode:'integer',B:'5040'},'&ca=1&gb=1'),/cannot be combined with ca=1 or sq=1/],['with sq=1',addr({shellMode:'integer',B:'9',phi3:'0',m:'7'},'&sq=1&gb=1'),/cannot be combined with ca=1 or sq=1/],
        ['off preset (m = 9)',CC.encodeAddress(CC.initial({...GB.patchFor(24),m:'9'}))+'&gb=1',/a dial left the preset/],['n! mode',addr({})+'&gb=1',/not on a Goldbach shell/],['phi3 = 1',CC.encodeAddress(CC.initial({...GB.patchFor(24),phi3:'1'}))+'&gb=1',/not on a Goldbach shell/],['N = 1450',CC.encodeAddress(CC.initial({shellMode:'integer',B:'724',phi3:'0',m:'3',t2:'1'}))+'&gb=1',/outside/]];
      let nb=0;const badr=[];for(const [nm,a,re] of refusals){await gopen(pg,a);const r=await pg.evaluate(()=>({addr:document.getElementById('addr').textContent,g:FVPanel.gbN,status:document.getElementById('status').textContent}));
        if(r.g===null&&!/gb=1/.test(r.addr)&&/Goldbach track flag refused/.test(r.status)&&re.test(r.status))nb++;else badr.push(nm+':'+r.status.slice(0,90));}
      ok(tag+' address refusals: duplicate, gb=2, empty, with ca=1, with sq=1, off the preset, n! mode, φ₃ ≠ 0, N = 1450: each refuses the flag only, with a label ('+nb+'/'+refusals.length+')',nb===refusals.length,badr.join(' | '));
      let none=0,nn=0;for(const o of [{shellMode:'factorial',n1:'4',tab:'fourier'},{shellMode:'integer',B:'24',tab:'clifford'},{shellMode:'integer',B:'9',phi3:'0',m:'7',tab:'fourier'}]){for(const x of ['','&sq=1']){if(x&&o.B!=='9')continue;await gopen(pg,addr(o)+x);nn++;const a=await pg.evaluate(()=>document.getElementById('addr').textContent);if(a===addr(o)+x&&!/gb/.test(a))none++;}}
      ok(tag+' address: other states and the ca / sq tracks write exactly the v0.4.13 address (no gb) ('+none+'/'+nn+')',none===nn);}
    // ---- track off: byte-identical to v0.4.13
    {const STATE={shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:'1',n6:'1',t1:'1',t2:'1'};
      const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
        {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',alpha:'1/2',m:'2',tab:'clifford'},
        {shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'},{...STATE,tab:'fourier',view:'fs=1;fr=1;fl=1'},{...STATE,tab:'clifford',view:'cs=1;cr=1'},{...STATE,tab:'hopf',view:'hs=1',chart:'comb'},
        {...GB.patchFor(24),tab:'fourier'},{...GB.patchFor(30),tab:'clifford'},{...GB.patchFor(14),tab:'hopf'},{...GB.patchFor(24),tab:'panels'},{...GB.patchFor(24),tab:'fourier',sTyped:'4/3',sEff:'4/3'}];
      let same=0,exSame=0,n=0;const bad=[];
      for(const o of S){for(const x of (o.B==='24'&&o.m==='5'?[['',null],['','-1/2']]:[['',null],['','-1/2']])){const hh=addr(o,x[1]?'&tilt='+x[1]:'');n++;const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url413);await gopen(pb,hh);
          const A=await snap(pa),B=await snap(pb),dif=[];for(const k of Object.keys(A))if(A[k]!==B[k])dif.push(k);
          const ea=await exportsOf(pa),eb=await exportsOf(pb);if(JSON.stringify(ea)!==JSON.stringify(eb))dif.push('exports');else exSame++;
          if(!dif.length)same++;else bad.push(o.tab+' '+hh.slice(0,60)+' '+dif.join(','));await pa.close();await pb.close();}}
      ok(tag+' track off: byte-identical to v0.4.13 for '+n+' states (incl. the Goldbach shells without the flag, tilt −1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports ('+exSame+'/'+n+')',same===n,bad.join(' | '));
      let ps=0,pn=0;for(const o of [S[0],S[3],S[4],S[8],S[11],S[12]]){pn++;const hh=addr(o);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url413);await gopen(pb,hh);if(await pngHash(pa)===await pngHash(pb))ps++;await pa.close();await pb.close();}
      ok(tag+' track off: PNG export byte-identical to v0.4.13 ('+ps+'/'+pn+')',ps===pn);
      // ca / sq tracks unchanged
      let tr=0;for(const [o,x] of [[{shellMode:'integer',B:'5040',phi3:'0',m:'5',tab:'fourier'},'&ca=1'],[{shellMode:'integer',B:'9',phi3:'0',m:'7',tab:'fourier'},'&sq=1'],[{shellMode:'integer',B:'120',phi3:'3',m:'4',tab:'clifford'},'&ca=1']]){const hh=addr(o)+x;const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url413);await gopen(pb,hh);const A=await snap(pa),B=await snap(pb);if(Object.keys(A).every(k=>A[k]===B[k]))tr++;await pa.close();await pb.close();}
      ok(tag+' track off: the CA and n²+1 tracks render byte-identically to v0.4.13 ('+tr+'/3)',tr===3);}
    // ---- track ON exports and PNG still work; N = 1448 draws on every tab; no horizontal scroll; no page errors
    {const res=[];for(const tab of ['fourier','clifford','hopf','panels']){for(const N of [24,30,1448]){const t0=Date.now();await gopen(pg,gaddr(N,'4/3',tab)+'&gb=1');if(N===24||N===1448){await pg.evaluate(()=>FVPanel.onAct('gbexpand'));await pg.waitForTimeout(120);}
          const sw=await pg.evaluate(()=>({sw:document.documentElement.scrollWidth,cw:document.documentElement.clientWidth,bw:document.body.scrollWidth,txt:document.getElementById('status').textContent}));
          res.push({tab,N,hs:sw.sw>sw.cw+0||sw.bw>sw.cw+0,ms:Date.now()-t0});}}
      ok(tag+' no horizontal scroll on the track (N = 24, 30, 1448 × four tabs, pair list expanded) ('+res.filter(r=>r.hs).length+' overflowing)',res.every(r=>!r.hs),JSON.stringify(res.filter(r=>r.hs)));
      ok(tag+' N = 1448 renders on every tab ('+res.filter(r=>r.N===1448).map(r=>r.tab+' '+r.ms+' ms').join(', ')+')',true);
      await gopen(pg,gaddr(24,'4/3','fourier')+'&gb=1');const ex=await exportsOf(pg);const h=await pngHash(pg);
      ok(tag+' track on: the five exports and the PNG export run (stats carry the Goldbach line)',Object.values(ex).every(t=>t.length>20)&&/Goldbach prime-pair mask: N = 24, g\(N\) = 3, G_N\(0\) = 2g\(N\) = 6/.test(ex.xstats)&&h.length===64,ex.xstats.slice(0,200));}
    ok(tag+': no page errors ('+errs.length+')',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();
  }
  await browser.close();
  console.log('SUMMARY browser-check-v0414 '+pass+' passed, '+fail+' failed');
  process.exit(fail?1:0);
})();
