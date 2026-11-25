'use strict';
// v0.4.12 browser check (SCHEMA_ADDENDUM_20): log radius display of the Fourier view. 1280x800 and 375x812.
// (1) counts 39/41/39/41 (fl on and off); (2) fl off byte-identical to v0.4.11 (stage, canvas, caption, about, cards, address, hash, five exports, PNG), also with stack and reciprocal on;
// (3) the layer: key fl only when on, menu item only while the Full stack is on, toggle round trip, reload, inert with the stack off, data attributes, caption wording, throat circle, log rings, R(1) = R_t;
// (4) pixel probe: ink at the expected log positions of both halves; Clifford and Hopf unchanged by fl; (5) key unique; (6) no horizontal scroll; (7) shots shot_v0412_*.
const fs=require('fs'),path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url411=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(450);};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,hstage:(document.getElementById('htmlstage')||{innerHTML:''}).innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about')?document.getElementById('about').innerHTML:'',cards:(document.getElementById('cards')||{innerHTML:''}).innerHTML,hash:location.hash,title:document.title}));
const exportsOf=pg=>pg.evaluate(async()=>{const r={};for(const k of ['xstats','xjson','xstate','xcsv','xlift']){await FVPanel.onAct(k);await new Promise(z=>setTimeout(z,60));r[k]=document.getElementById('xout').value;}return r;});
const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
const STATE={shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:'1',n6:'1',t1:'1',t2:'1'};   // n1 = 4, N = 3, m = 2, s = 1 (default), alpha = 1
const FL='fs=1;fr=1;fl=1';
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- (1) counts
    for(const tab of ['fourier','clifford','hopf']){const r=[];
      for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){
        await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr({...o,view:FL})+x);r.push(await count(pg));await gopen(pg,addr(o)+x,url411);r.push(await count(pg));}
      ok(tag+' '+tab+': counts 39/41/39/41 unchanged (v0.4.12 off / stack+reciprocal+log on / v0.4.11 = '+r.join('/')+')',r.join('/')==='39/39/39/41/41/41/39/39/39/41/41/41',r.join('/'));}
    // ---- (2) byte identity against v0.4.11 with fl off
    const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',alpha:'1/2',m:'2',tab:'clifford'},
      {shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'},{shellMode:'factorial',n1:'4',phi3:'25',m:'2',tab:'fourier'},
      {...STATE,tab:'fourier',view:'fs=1'},{...STATE,tab:'fourier',view:'fs=1;fr=1'},{...STATE,alpha:'-1',tab:'fourier',view:'fs=1;fr=1'},{...STATE,tab:'fourier',view:'fs=1;ff=1;so=0.3'},{...STATE,n6:'0',tab:'fourier',view:'fs=1;fr=1'},
      {...STATE,tab:'clifford',view:'cs=1;cr=1'},{...STATE,tab:'hopf',view:'hs=1;hr=1'},{...STATE,tab:'hopf',view:'hs=1',chart:'comb'}];
    {let same=0,exSame=0;const bad=[];
      for(const o of S){for(const t of [null,'-1/2']){const hh=addr(o,t?'&tilt='+t:'');const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url411);await gopen(pb,hh);
          const x=await snap(pa),y=await snap(pb),dif=[];for(const k of Object.keys(x))if(x[k]!==y[k])dif.push(k);
          const ea=await exportsOf(pa),eb=await exportsOf(pb);const exeq=JSON.stringify(ea)===JSON.stringify(eb);if(exeq)exSame++;else dif.push('exports');
          if(!dif.length)same++;else bad.push(o.tab+' '+hh.slice(0,70)+' '+dif.join(','));await pa.close();await pb.close();}}
      ok(tag+' fl off: byte-identical to v0.4.11 for '+S.length*2+' states (incl. tilt −1/2, stack / reciprocal / fraction on): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats ('+exSame+'/'+S.length*2+' exports)',same===S.length*2,bad.join(' | '));}
    {let same=0,n=0;for(const o of S.filter(o=>o.tab!=='panels').slice(0,9).concat(S.slice(9,12))){n++;const hh=addr(o);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url411);await gopen(pb,hh);if(await pngHash(pa)===await pngHash(pb))same++;await pa.close();await pb.close();}
      ok(tag+' fl off: PNG export byte-identical to v0.4.11 ('+same+'/'+n+')',same===n);}
    // ---- exports with fl ON equal the fl off exports (display only), address aside
    {let eq=0,n=0;for(const o of [{...STATE},{...STATE,alpha:'-1'},{...STATE,n6:'2'}]){n++;await gopen(pg,addr({...o,tab:'fourier',view:'fs=1;fr=1'}));const a=await exportsOf(pg);await gopen(pg,addr({...o,tab:'fourier',view:FL}));const b=await exportsOf(pg);
        const strip=e=>JSON.stringify(e).replace(/fl(=|%3D)1/g,'').replace(/fs(=|%3D)1(;|%3B)fr(=|%3D)1(;|%3B)?/g,'');if(strip(a)===strip(b))eq++;}
      ok(tag+' fl on: the five exports equal the fl off exports (key aside) in '+eq+' of '+n+' states',eq===n);}
    // ---- (3) the layer
    {await gopen(pg,addr({...STATE,tab:'fourier',view:'fs=1;fr=1'}));const off=await snap(pg);
      ok(tag+' address has no fl key while the layer is off',!decodeURIComponent(off.hash).includes('fl='));
      const hasItem=async()=>{await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);const r=await pg.locator('#menu_layers button:has-text("Log radius (throat at |z| = 1)")').count();await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(100);return r;};
      ok(tag+' Layers menu offers "Log radius (throat at |z| = 1)" while the Full stack is on',(await hasItem())===1);
      await gopen(pg,addr({...STATE,tab:'fourier'}));ok(tag+' ... and not while the Full stack is off',(await hasItem())===0);
      for(const tab of ['clifford','hopf']){await gopen(pg,addr({...STATE,tab,view:tab==='clifford'?'cs=1':'hs=1'}));ok(tag+' '+tab+' Layers menu has no log radius item',(await hasItem())===0);}
      await gopen(pg,addr({...STATE,tab:'fourier',view:'fs=1;fr=1'}));await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.locator('#menu_layers button:has-text("Log radius (throat at |z| = 1)")').click();await pg.waitForTimeout(500);
      const on=await snap(pg);
      const caps=await pg.evaluate(()=>document.getElementById('caption').innerText);
      ok(tag+' toggle writes fl=1; canvas/caption change; data-role="log-radius", throat circle and log rings present',decodeURIComponent(on.hash).includes('fl=1')&&on.cv!==off.cv&&on.caption!==off.caption&&/data-role="log-radius"/.test(on.stage)&&/data-role="throat"/.test(on.stage)&&/data-role="log-ring"/.test(on.stage));
      ok(tag+' caption carries the required wording',caps.includes('log radius display: radius drawn as ln|z| about the throat |z| = 1 (display only; exact values unchanged)'),caps.slice(0,500));
      // R(1) = R_t: throat circle radius in the SVG equals data-rt; the N = 1 layer (r = 1 when n6 = 1) is drawn on it (probe below)
      const geo=await pg.evaluate(()=>{const g=document.querySelector('[data-role="log-radius"]'),t=document.querySelector('[data-role="throat"]');return {rt:+g.dataset.rt,tr:+t.getAttribute('r'),L:+g.dataset.lmax,clamp:g.dataset.clamp,undef:g.dataset.undef,rings:[...document.querySelectorAll('[data-role="log-ring"]')].map(e=>[+e.dataset.k,+e.getAttribute('r')]),labels:[...document.querySelectorAll('[data-role="log-ring-label"]')].map(e=>e.textContent)};});
      ok(tag+' R(1) = R_t: throat circle radius '+geo.tr+' = on-screen throat radius '+geo.rt+'; log rings at r = e^k radius R_t(1 + k/L) ('+geo.rings.map(r=>r[0]).join(',')+')',Math.abs(geo.tr-geo.rt)<1e-9&&geo.rings.length>0&&geo.rings.every(([k,r])=>Math.abs(r-geo.rt*(1+k/geo.L))<0.011)&&geo.labels.length===geo.rings.length,JSON.stringify(geo));
      ok(tag+' no clamped or undefined points in this state (clamp '+geo.clamp+', undef '+geo.undef+')',geo.clamp==='0'&&geo.undef==='0');
      await pg.reload();await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(450);const rel=await snap(pg);
      ok(tag+' reload restores the log radius view (canvas and stage equal)',rel.cv===on.cv&&rel.stage===on.stage);
      await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.locator('#menu_layers button:has-text("Log radius (throat at |z| = 1)")').click();await pg.waitForTimeout(500);const back=await snap(pg);
      ok(tag+' toggling off restores the off state byte for byte (stage, canvas, caption, about, hash)',back.stage===off.stage&&back.cv===off.cv&&back.caption===off.caption&&back.about===off.about&&back.hash===off.hash);
      await gopen(pg,addr({...STATE,tab:'fourier',view:'fl=1'}));const st2=await snap(pg);await gopen(pg,addr({...STATE,tab:'fourier'}));const st3=await snap(pg);
      ok(tag+' with the Full stack off the fl key is inert (view equals the plain view)',st2.cv===st3.cv&&st2.stage===st3.stage&&st2.caption===st3.caption);
      // single half (no reciprocal): works, caption says the shown half
      await gopen(pg,addr({...STATE,tab:'fourier',view:'fs=1;fl=1'}));const c1=await pg.evaluate(()=>document.getElementById('caption').innerText);
      ok(tag+' log radius without the reciprocal layer: L from the shown half',c1.includes('the shown half')&&!/data-role="reciprocal"/.test((await snap(pg)).stage));
      // n6 = 0 labelled
      await gopen(pg,addr({...STATE,n6:'0',tab:'fourier',view:FL}));const z=await pg.evaluate(()=>({c:document.getElementById('caption').innerText,u:document.querySelector('[data-role="log-radius"]')?document.querySelector('[data-role="log-radius"]').dataset.undef:null}));
      ok(tag+' n6 = 0: points at r = 0 counted ('+z.u+') and labelled in the caption',z.u&&Number(z.u)>0&&/r = 0 \(n₆ = 0\) have no log image/.test(z.c),JSON.stringify(z).slice(0,300));
      // teeth, walk, carrier, fraction stack, tilt, polygons at other states: no page error, drawn
      for(const o of [{...STATE,m:'5',n1:'5',phi3:'100'},{...STATE,alpha:'1/2',n6:'3'},{...STATE,alpha:'-1',n6:'1/2'},{...STATE,nMode:'continuous',phi3:'43/2'}])
        for(const v of [FL,FL+';ff=1',FL+';fp=1;fd=1']){await gopen(pg,addr({...o,tab:'fourier',view:v},'&tilt=1/2'));const e=await pg.evaluate(()=>({t:document.querySelectorAll('[data-role="tooth"]').length,wk:!!document.querySelector('[data-role="walk"]'),l:!!document.querySelector('[data-role="log-radius"]')}));
          ok(tag+' extra state '+JSON.stringify(o).slice(0,60)+' view '+v+': teeth '+e.t+', walk '+e.wk+', log layer '+e.l,e.t>0&&e.wk&&e.l);}
    }
    // ---- (4) pixel probe: ink at the expected log positions of both halves; mirror about the throat; Clifford and Hopf unchanged by fl
    for(const alpha of ['1','-1']){
      await gopen(pg,addr({...STATE,alpha,tab:'fourier',view:FL+';ft=0;fw=0;fm=0;fp=0'}));
      const res=await pg.evaluate((ALPHA)=>{
        const st=FVCombCore.initial({shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:ALPHA,n6:'1',t1:'1',t2:'1'});
        const P=FVStack.build(st),RC=FVStack.reciprocal(P),LM=FVStackView.logModel(P,RC),g=document.querySelector('[data-role="log-radius"]'),sc=+g.dataset.rt,cx=+g.dataset.cx,cy=+g.dataset.cy;
        const c=document.getElementById('stagecv'),ctx2=c.getContext('2d'),d=ctx2.getImageData(0,0,c.width,c.height).data,Wd=640,Hd=480,k=Math.min(c.width/Wd,c.height/Hd),ox=(c.width-Wd*k)/2,oy=(c.height-Hd*k)/2;
        const probe=xy=>{let n=0,hit=0;for(let i=0;i<xy.length;i+=2){if((i/2)%7)continue;const x=Math.round(ox+k*(cx+sc*xy[i])),y=Math.round(oy+k*(cy-sc*xy[i+1]));if(x<2||y<2||x>c.width-3||y>c.height-3)continue;n++;let f=false;for(let yy=y-2;yy<=y+2&&!f;yy++)for(let xx=x-2;xx<=x+2;xx++){if(d[4*(yy*c.width+xx)+3]>0){f=true;break;}}if(f)hit++;}return [hit,n];};
        // mirror about the throat: for sampled primary points, the reciprocal point sits at radius 2R_t - R (checked in the page on the same data used for drawing)
        let mm=0;for(let i=0;i<LM.xy.length;i+=2){const a=Math.hypot(LM.xy[i],LM.xy[i+1]),b=Math.hypot(LM.xr[i],LM.xr[i+1]);mm=Math.max(mm,Math.abs(a+b-2));}
        return {prim:probe(LM.xy),recip:probe(LM.xr),mirrorErr:mm,L:LM.L};},alpha).catch(e=>({err:String(e)}));
      ok(tag+' alpha = '+alpha+' pixel probe: ink at the log positions of the primary half '+(res.prim||'?').toString()+' and of the reciprocal half '+(res.recip||'?').toString()+'; mirror error '+(res.mirrorErr&&res.mirrorErr.toExponential(1)),res.prim&&res.prim[1]>50&&res.prim[0]>=0.9*res.prim[1]&&res.recip[0]>=0.9*res.recip[1]&&res.mirrorErr<1e-12,JSON.stringify(res));
    }
    // Clifford and Hopf unchanged by fl
    for(const tab of ['clifford','hopf']){const k2=tab==='clifford'?'cs=1;cr=1':'hs=1;hr=1';await gopen(pg,addr({...STATE,tab,view:k2}));const a=await snap(pg);await gopen(pg,addr({...STATE,tab,view:k2+';fl=1'}));const b=await snap(pg);
      ok(tag+' '+tab+': the fl key changes nothing in this view (stage, canvas, caption)',a.cv===b.cv&&a.stage===b.stage&&a.caption===b.caption);}
    // ---- (5) key collision
    {const dup=await pg.evaluate(()=>{const seen={},d=[];for(const v of FVViews.registry)for(const k of Object.keys(v.defaults)){if(seen[k])d.push(k);seen[k]=1;}return {d,has:'fl' in Object.assign({},...FVViews.registry.map(v=>v.defaults))};});
      ok(tag+' view key fl is new and unique across all views (duplicates: '+JSON.stringify(dup.d)+')',dup.d.length===0&&dup.has);}
    // ---- (6) no horizontal scroll
    {await gopen(pg,addr({...STATE,tab:'fourier',view:FL}));await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);
      const sw=await pg.evaluate(()=>[document.documentElement.scrollWidth,window.innerWidth]);ok(tag+' no horizontal scroll with the Layers menu open and the log radius on ('+sw.join(' ≤ ')+')',sw[0]<=sw[1]);}
    // ---- (7) shots
    for(const al of ['1','-1']){await gopen(pg,addr({...STATE,alpha:al,tab:'fourier',view:FL}));await pg.waitForTimeout(300);
      await pg.screenshot({path:path.join(root,'shot_v0412_'+tag+'_fourier_log_alpha'+(al==='1'?'p1':'m1')+'.png'),fullPage:true});}
    ok(tag+' no page errors',errs.length===0,errs.join(' | ').slice(0,300));
    await ctx.close();
  }
  await browser.close();
  console.log('\nSUMMARY browser-check-v0412: '+pass+' pass, '+fail+' fail');process.exit(fail?1:0);
})();
