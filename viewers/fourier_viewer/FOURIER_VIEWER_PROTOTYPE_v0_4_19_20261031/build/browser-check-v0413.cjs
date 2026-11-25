'use strict';
// v0.4.13 browser check (SCHEMA_ADDENDUM_21): in log mode only the stack is log-mapped; pen, teeth, carrier on a linear scale with a scale bar. 1280x800 and 375x812.
const fs=require('fs'),path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url412=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(450);};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,hstage:(document.getElementById('htmlstage')||{innerHTML:''}).innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:(document.getElementById('about')||{innerHTML:''}).innerHTML,cards:(document.getElementById('cards')||{innerHTML:''}).innerHTML,hash:location.hash}));
const exportsOf=pg=>pg.evaluate(async()=>{const r={};for(const k of ['xstats','xjson','xstate','xcsv','xlift']){await FVPanel.onAct(k);await new Promise(z=>setTimeout(z,60));r[k]=document.getElementById('xout').value;}return r;});
const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
const STATE={shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:'1',n6:'1',t1:'1',t2:'1'};   // n1 = 4, N = 3, m = 2, s = 1, alpha = 1
const S1209={sTyped:'1209/1000',sEff:'1209/1000'};
const FL='fs=1;fr=1;fl=1';
// pen geometry read from the drawn SVG: centre, vertices, tooth tip vectors, scale bar
const penOf=pg=>pg.evaluate(()=>{const g=document.querySelector('[data-role="log-radius"]');const cx=+(g?g.dataset.cx:NaN),cy=+(g?g.dataset.cy:NaN);
  const V=[...document.querySelectorAll('[data-role="vertex"]')].sort((a,b)=>+a.dataset.t-+b.dataset.t).map(e=>[+e.getAttribute('cx'),+e.getAttribute('cy')]);
  const T=[...document.querySelectorAll('[data-role="tooth"]')].map(e=>({c:e.dataset.c,x:+e.getAttribute('x2'),y:+e.getAttribute('y2')}));
  const sb=document.querySelector('[data-role="pen-scale"]'),bar=document.querySelector('[data-role="pen-scale-bar"]');
  return {g:g?{...g.dataset}:null,cx,cy,V,T,sb:sb?{u:+sb.dataset.u,len:+sb.dataset.len,sc:+sb.dataset.penSc,text:sb.textContent}:null,bar:bar?{x1:+bar.getAttribute('x1'),x2:+bar.getAttribute('x2')}:null};});
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- counts
    for(const tab of ['fourier','clifford','hopf']){const r=[];
      for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){
        await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr({...o,view:FL})+x);r.push(await count(pg));await gopen(pg,addr(o)+x,url412);r.push(await count(pg));}
      ok(tag+' '+tab+': counts 39/41/39/41 unchanged (v0.4.13 off / log on / v0.4.12 = '+r.join('/')+')',r.join('/')==='39/39/39/41/41/41/39/39/39/41/41/41',r.join('/'));}
    // ---- fl off byte identity against v0.4.12
    const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',alpha:'1/2',m:'2',tab:'clifford'},
      {shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'},{shellMode:'factorial',n1:'4',phi3:'25',m:'2',tab:'fourier'},
      {...STATE,tab:'fourier',view:'fs=1'},{...STATE,tab:'fourier',view:'fs=1;fr=1'},{...STATE,alpha:'-1',tab:'fourier',view:'fs=1;fr=1'},{...STATE,tab:'fourier',view:'fs=1;ff=1;so=0.3'},{...STATE,n6:'0',tab:'fourier',view:'fs=1;fr=1'},
      {...STATE,...S1209,tab:'fourier',view:'fs=1;fr=1'},{...STATE,tab:'clifford',view:'cs=1;cr=1'},{...STATE,tab:'hopf',view:'hs=1;hr=1'},{...STATE,tab:'hopf',view:'hs=1',chart:'comb'}];
    {let same=0,exSame=0;const bad=[];
      for(const o of S){for(const t of [null,'-1/2']){const hh=addr(o,t?'&tilt='+t:'');const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url412);await gopen(pb,hh);
          const x=await snap(pa),y=await snap(pb),dif=[];for(const k of Object.keys(x))if(x[k]!==y[k])dif.push(k);
          const ea=await exportsOf(pa),eb=await exportsOf(pb);const exeq=JSON.stringify(ea)===JSON.stringify(eb);if(exeq)exSame++;else dif.push('exports');
          if(!dif.length)same++;else bad.push(o.tab+' '+hh.slice(0,70)+' '+dif.join(','));await pa.close();await pb.close();}}
      ok(tag+' fl off: byte-identical to v0.4.12 for '+S.length*2+' states (tilt -1/2 too): stage, canvas, caption, about, cards, address, hash and the five exports ('+exSame+'/'+S.length*2+')',same===S.length*2,bad.join(' | '));}
    {let same=0,n=0;for(const o of S.filter(o=>o.tab!=='panels').slice(0,9).concat(S.slice(9,12))){n++;const hh=addr(o);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url412);await gopen(pb,hh);if(await pngHash(pa)===await pngHash(pb))same++;await pa.close();await pb.close();}
      ok(tag+' fl off: PNG export byte-identical to v0.4.12 ('+same+'/'+n+')',same===n);}
    // ---- fl on: stack canvas vs v0.4.12; exports equal fl off
    {let eqcv=0,n=0;const diffs=[];for(const o of [{...STATE},{...STATE,alpha:'-1'},{...STATE,...S1209},{...STATE,n6:'2'},{...STATE,alpha:'1/2',n6:'3'},{...STATE,m:'5',n1:'5',phi3:'100'}]){
        n++;const hh=addr({...o,tab:'fourier',view:FL});const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url412);await gopen(pb,hh);const a=await snap(pa),b=await snap(pb);if(a.cv===b.cv)eqcv++;else diffs.push(JSON.stringify(o).slice(0,50));await pa.close();await pb.close();}
      ok(tag+' fl on: stack canvas identical to v0.4.12 in '+eqcv+' of '+n+' states'+(diffs.length?' (differs: '+diffs.join(' | ')+')':''),eqcv===n,diffs.join(' | '));}
    {let eq=0,n=0;for(const o of [{...STATE},{...STATE,alpha:'-1'},{...STATE,n6:'2'}]){n++;await gopen(pg,addr({...o,tab:'fourier',view:'fs=1;fr=1'}));const a=await exportsOf(pg);await gopen(pg,addr({...o,tab:'fourier',view:FL}));const b=await exportsOf(pg);
        const strip=e=>JSON.stringify(e).replace(/fl(=|%3D)1/g,'').replace(/fs(=|%3D)1(;|%3B)fr(=|%3D)1(;|%3B)?/g,'');if(strip(a)===strip(b))eq++;}
      ok(tag+' fl on: the five exports equal the fl off exports (key aside) in '+eq+' of '+n+' states',eq===n);}
    // ---- the pen is linear: similarity image, tip-to-tail, scale bar, caption
    {const PS=[{...STATE},{...STATE,alpha:'-1'},{...STATE,...S1209},{...STATE,...S1209,alpha:'-1'},{...STATE,m:'5',n1:'5',phi3:'100'},{...STATE,m:'6',n1:'6',phi3:'700',alpha:'1/2',n6:'3'},{...STATE,nMode:'continuous',phi3:'43/2'}];
      let nSim=0,nStep=0,nBar=0,nCap=0,nExt=0,worstStep=0,worstDev=0;const bad=[];
      for(const o of PS){const hh=v=>addr({...o,tab:'fourier',view:v});
        await gopen(pg,hh('fs=1;fr=1'));const lin=await pg.evaluate(()=>({V:[...document.querySelectorAll('[data-role="vertex"]')].sort((a,b)=>+a.dataset.t-+b.dataset.t).map(e=>[+e.getAttribute('cx'),+e.getAttribute('cy')])}));
        const linCx=lin.V[0][0],linCy=lin.V[0][1];
        await gopen(pg,hh(FL));const p=await penOf(pg);const caps=await pg.evaluate(()=>document.getElementById('caption').innerText);
        const V=p.V;let okSim=V.length===lin.V.length&&V.length>1&&Math.abs(V[0][0]-p.cx)<0.02&&Math.abs(V[0][1]-p.cy)<0.02;
        const ratios=[];for(let i=1;i<V.length;i++){const a=[V[i][0]-p.cx,V[i][1]-p.cy],b=[lin.V[i][0]-linCx,lin.V[i][1]-linCy],nb=Math.hypot(b[0],b[1]);if(nb>1){ratios.push(Math.hypot(a[0],a[1])/nb);if(a[0]*b[0]+a[1]*b[1]<=0)okSim=false;}}
        const k=ratios.length?ratios.reduce((a,b)=>a+b)/ratios.length:NaN;let maxdev=0;for(let i=1;i<V.length;i++)maxdev=Math.max(maxdev,Math.hypot(V[i][0]-p.cx-k*(lin.V[i][0]-linCx),V[i][1]-p.cy-k*(lin.V[i][1]-linCy)));
        worstDev=Math.max(worstDev,maxdev);okSim=okSim&&Number.isFinite(k)&&maxdev<0.05+1e-3*Math.max(...V.map(v=>Math.hypot(v[0]-p.cx,v[1]-p.cy)));
        if(okSim)nSim++;else bad.push('sim '+JSON.stringify(o).slice(0,60)+' k '+k+' maxdev '+maxdev);
        const steps=[];for(let i=1;i<V.length;i++)steps.push([V[i][0]-V[i-1][0],V[i][1]-V[i-1][1]]);
        const teeth=p.T.map(t=>[t.x-p.cx,t.y-p.cy]);let okStep=steps.length===teeth.length;let sd=0;
        if(okStep){const used=new Set();for(const s of steps){let bi=-1,bd=1e9;teeth.forEach((t,j)=>{if(used.has(j))return;const d=Math.hypot(t[0]-s[0],t[1]-s[1]);if(d<bd){bd=d;bi=j;}});used.add(bi);sd=Math.max(sd,bd);}okStep=sd<0.05;}
        worstStep=Math.max(worstStep,sd);if(okStep)nStep++;else bad.push('step '+JSON.stringify(o).slice(0,60)+' dev '+sd+' n '+steps.length+'/'+teeth.length);
        const sb=p.sb;const barOk=!!sb&&sb.u>0&&/^pen [0-9.e-]+$/.test(sb.text)&&caps.includes('pen scale bar (bottom right, labelled "pen u")')&&Math.abs(sb.len-sb.u*sb.sc)<1e-6&&p.bar&&Math.abs((p.bar.x2-p.bar.x1)-sb.len)<0.02&&Math.abs(sb.sc-+p.g.penSc)<1e-9&&sb.len>20&&sb.len<w-20;
        if(barOk)nBar++;else bad.push('bar '+JSON.stringify(o).slice(0,60)+' '+JSON.stringify(sb));
        if(caps.includes('log radius applies to the stack only; the pen, teeth and carrier are drawn on a linear scale (their own scale bar)'))nCap++;else bad.push('caption '+JSON.stringify(o).slice(0,60));
        const ext=Math.max(...V.map(v=>Math.hypot(v[0]-p.cx,v[1]-p.cy)),...teeth.map(t=>Math.hypot(t[0],t[1])));
        if(Math.abs(ext-0.5*+p.g.rt)<0.5+0.002*+p.g.rt)nExt++;else bad.push('ext '+ext+' vs '+0.5*+p.g.rt);}
      const N=PS.length;
      ok(tag+' pen is a linear (similarity) image of the linear walk: one scale k, same directions, max deviation '+worstDev.toFixed(4)+' px, '+nSim+'/'+N+' states',nSim===N,bad.join(' | '));
      ok(tag+' tip to tail: each drawn step vector equals a drawn tooth vector (multiset match), max mismatch '+worstStep.toFixed(4)+' px, '+nStep+'/'+N+' states',nStep===N,bad.join(' | '));
      ok(tag+' scale bar present, labelled "pen u" (+ caption line), length = u x pen scale, '+nBar+'/'+N+' states',nBar===N,bad.join(' | '));
      ok(tag+' caption carries the required sentence, '+nCap+'/'+N+' states',nCap===N,bad.join(' | '));
      ok(tag+' pen largest extent = 1/2 throat radius (to 0.5 px), '+nExt+'/'+N+' states',nExt===N,bad.join(' | '));}
    // ---- the layer (as v0.4.12)
    {await gopen(pg,addr({...STATE,tab:'fourier',view:'fs=1;fr=1'}));const off=await snap(pg);
      ok(tag+' address has no fl key while the layer is off',!decodeURIComponent(off.hash).includes('fl='));
      await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.locator('#menu_layers button:has-text("Log radius (throat at |z| = 1)")').click();await pg.waitForTimeout(500);
      const on=await snap(pg);const caps=await pg.evaluate(()=>document.getElementById('caption').innerText);
      ok(tag+' toggle writes fl=1, shows log-radius, throat, rings, pen-scale; caption has the v0.4.12 wording',decodeURIComponent(on.hash).includes('fl=1')&&/data-role="log-radius"/.test(on.stage)&&/data-role="throat"/.test(on.stage)&&/data-role="log-ring"/.test(on.stage)&&/data-role="pen-scale"/.test(on.stage)&&caps.includes('log radius display: radius drawn as ln|z| about the throat |z| = 1 (display only; exact values unchanged)'));
      const geo=await pg.evaluate(()=>{const g=document.querySelector('[data-role="log-radius"]'),t=document.querySelector('[data-role="throat"]');return {rt:+g.dataset.rt,tr:+t.getAttribute('r'),L:+g.dataset.lmax,clamp:g.dataset.clamp,undef:g.dataset.undef,rings:[...document.querySelectorAll('[data-role="log-ring"]')].map(e=>[+e.dataset.k,+e.getAttribute('r')])};});
      ok(tag+' R(1) = R_t: throat radius '+geo.tr+' = '+geo.rt+'; log rings R_t(1 + k/L)',Math.abs(geo.tr-geo.rt)<1e-9&&geo.rings.length>0&&geo.rings.every(([k,r])=>Math.abs(r-geo.rt*(1+k/geo.L))<0.011));
      await pg.reload();await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(450);const rel=await snap(pg);
      ok(tag+' reload restores the log view',rel.cv===on.cv&&rel.stage===on.stage);
      await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.locator('#menu_layers button:has-text("Log radius (throat at |z| = 1)")').click();await pg.waitForTimeout(500);const back=await snap(pg);
      ok(tag+' toggling off restores the off state byte for byte',back.stage===off.stage&&back.cv===off.cv&&back.caption===off.caption&&back.about===off.about&&back.hash===off.hash);
      await gopen(pg,addr({...STATE,tab:'fourier',view:'fl=1'}));const st2=await snap(pg);await gopen(pg,addr({...STATE,tab:'fourier'}));const st3=await snap(pg);
      ok(tag+' fl inert with the Full stack off',st2.cv===st3.cv&&st2.stage===st3.stage&&st2.caption===st3.caption&&!/pen-scale/.test(st2.stage));
      await gopen(pg,addr({...STATE,n6:'0',tab:'fourier',view:FL}));const z=await pg.evaluate(()=>({c:document.getElementById('caption').innerText,u:document.querySelector('[data-role="log-radius"]').dataset.undef}));
      ok(tag+' n6 = 0: stack points at r = 0 counted ('+z.u+') and labelled',Number(z.u)>0&&/r = 0 \(n₆ = 0\) have no log image/.test(z.c));
      for(const o of [{...STATE,m:'5',n1:'5',phi3:'100'},{...STATE,alpha:'1/2',n6:'3'},{...STATE,alpha:'-1',n6:'1/2'},{...STATE,nMode:'continuous',phi3:'43/2'}])
        for(const v of [FL,FL+';ff=1',FL+';fp=1;fd=1']){await gopen(pg,addr({...o,tab:'fourier',view:v},'&tilt=1/2'));const e=await pg.evaluate(()=>({t:document.querySelectorAll('[data-role="tooth"]').length,wk:!!document.querySelector('[data-role="walk"]'),l:!!document.querySelector('[data-role="pen-scale"]')}));
          ok(tag+' extra state '+JSON.stringify(o).slice(0,50)+' view '+v+' (tilt 1/2): teeth '+e.t+', walk '+e.wk+', scale bar '+e.l,e.t>0&&e.wk&&e.l);}
    }
    // ---- pixel probe: stack ink at the log positions of both halves, mirror symmetry (as v0.4.12)
    for(const alpha of ['1','-1']){
      await gopen(pg,addr({...STATE,alpha,tab:'fourier',view:FL+';ft=0;fw=0;fm=0;fp=0'}));
      const res=await pg.evaluate((ALPHA)=>{
        const st=FVCombCore.initial({shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:ALPHA,n6:'1',t1:'1',t2:'1'});
        const P=FVStack.build(st),RC=FVStack.reciprocal(P),LM=FVStackView.logModel(P,RC),g=document.querySelector('[data-role="log-radius"]'),sc=+g.dataset.rt,cx=+g.dataset.cx,cy=+g.dataset.cy;
        const c=document.getElementById('stagecv'),ctx2=c.getContext('2d'),d=ctx2.getImageData(0,0,c.width,c.height).data,Wd=640,Hd=480,k=Math.min(c.width/Wd,c.height/Hd),ox=(c.width-Wd*k)/2,oy=(c.height-Hd*k)/2;
        const probe=xy=>{let n=0,hit=0;for(let i=0;i<xy.length;i+=2){if((i/2)%7)continue;const x=Math.round(ox+k*(cx+sc*xy[i])),y=Math.round(oy+k*(cy-sc*xy[i+1]));if(x<2||y<2||x>c.width-3||y>c.height-3)continue;n++;let f=false;for(let yy=y-2;yy<=y+2&&!f;yy++)for(let xx=x-2;xx<=x+2;xx++){if(d[4*(yy*c.width+xx)+3]>0){f=true;break;}}if(f)hit++;}return [hit,n];};
        let mm=0;for(let i=0;i<LM.xy.length;i+=2){const a=Math.hypot(LM.xy[i],LM.xy[i+1]),b=Math.hypot(LM.xr[i],LM.xr[i+1]);mm=Math.max(mm,Math.abs(a+b-2));}
        return {prim:probe(LM.xy),recip:probe(LM.xr),mirrorErr:mm,L:LM.L};},alpha).catch(e=>({err:String(e)}));
      ok(tag+' alpha = '+alpha+' stack still at R(r): ink at log positions, primary '+res.prim+' reciprocal '+res.recip+'; mirror error '+(res.mirrorErr!==undefined&&res.mirrorErr.toExponential(1)),!!res.prim&&res.prim[1]>50&&res.prim[0]>=0.9*res.prim[1]&&res.recip[0]>=0.9*res.recip[1]&&res.mirrorErr<1e-12,JSON.stringify(res));
    }
    for(const tab of ['clifford','hopf']){const k2=tab==='clifford'?'cs=1;cr=1':'hs=1;hr=1';await gopen(pg,addr({...STATE,tab,view:k2}));const a=await snap(pg);await gopen(pg,addr({...STATE,tab,view:k2+';fl=1'}));const b=await snap(pg);
      ok(tag+' '+tab+': fl changes nothing in this view',a.cv===b.cv&&a.stage===b.stage&&a.caption===b.caption);}
    {await gopen(pg,addr({...STATE,tab:'fourier',view:FL}));await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);
      const sw=await pg.evaluate(()=>[document.documentElement.scrollWidth,window.innerWidth]);ok(tag+' no horizontal scroll with the Layers menu open and log on ('+sw.join(' <= ')+')',sw[0]<=sw[1]);}
    // ---- shots
    const SH=[['alphap1',{...STATE}],['alpham1',{...STATE,alpha:'-1'}],['s1209_alphap1',{...STATE,...S1209}],['s1209_alpham1',{...STATE,...S1209,alpha:'-1'}]];
    for(const [nm,o] of SH){await gopen(pg,addr({...o,tab:'fourier',view:FL}));await pg.waitForTimeout(300);
      await pg.screenshot({path:path.join(root,'shot_v0413_'+tag+'_fourier_log_'+nm+'.png'),fullPage:true});}
    ok(tag+' no page errors',errs.length===0,errs.join(' | ').slice(0,300));
    await ctx.close();
  }
  await browser.close();
  console.log('\nSUMMARY browser-check-v0413: '+pass+' pass, '+fail+' fail');process.exit(fail?1:0);
})();
