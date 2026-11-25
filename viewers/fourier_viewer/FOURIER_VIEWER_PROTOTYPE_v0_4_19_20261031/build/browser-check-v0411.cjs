'use strict';
// v0.4.11 browser check (SCHEMA_ADDENDUM_19): reciprocal winding (throat at 1/1). 1280x800 and 375x812.
// (1) counts 39/41/39/41 unchanged, also with stack + reciprocal on; (2) toggles off: byte-identical to v0.4.10 (stage, canvas, caption, about, cards, address, hash, state, five exports, PNG);
// (3) the layer: view keys fr/cr/hr only when on, menu item only while the Full stack is on, toggle round trip, reload restores, data attributes, canvas changes;
// (4) Hopf: ink at the expected reflected positions (control: the primary positions); (5) no key collision; (6) no horizontal scroll at 375; (7) shots shot_v0411_*.
const fs=require('fs'),path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url410=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto('about:blank');await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(450);};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,hstage:(document.getElementById('htmlstage')||{innerHTML:''}).innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about').innerHTML,cards:document.getElementById('cards').innerHTML,hash:location.hash}));
const exportsOf=pg=>pg.evaluate(async()=>{const r={};for(const k of ['xstats','xjson','xstate','xcsv','xlift']){await FVPanel.onAct(k);await new Promise(z=>setTimeout(z,60));r[k]=document.getElementById('xout').value;}return r;});
const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
const STATE={shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:'1',n6:'1',t1:'1',t2:'1'};   // n1 = 4, N = 3, alpha = 1, m = 2 (saphir's "spiders" state)
const KEY={fourier:['fs=1','fr'],clifford:['cs=1','cr'],hopf:['hs=1','hr']};
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- (1) counts
    for(const tab of ['fourier','clifford','hopf']){const [fsk,rk]=KEY[tab];const r=[];
      for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){
        await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr({...o,view:fsk+';'+rk+'=1'})+x);r.push(await count(pg));await gopen(pg,addr(o)+x,url410);r.push(await count(pg));}
      ok(tag+' '+tab+': counts 39/41/39/41 unchanged (v0.4.11 off / stack+reciprocal on / v0.4.10 = '+r.join('/')+')',r.join('/')==='39/39/39/41/41/41/39/39/39/41/41/41',r.join('/'));}
    // ---- (2) byte identity against v0.4.10, toggles off (and stack on, reciprocal off)
    const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',alpha:'1/2',m:'2',tab:'clifford'},
      {shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'},{shellMode:'factorial',n1:'4',phi3:'25',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',m:'3',sTyped:'1/3',view:'cf=1',tab:'clifford'},
      {shellMode:'integer',B:'9',phi3:'0',m:'7',tab:'panels'},{...STATE,tab:'fourier',view:'fs=1'},{...STATE,tab:'clifford',view:'cs=1'},{...STATE,tab:'hopf',view:'hs=1'},{...STATE,tab:'hopf',view:'hs=1',chart:'comb'},{...STATE,tab:'clifford',view:'cs=1;so=0.15'}];
    {let same=0,exSame=0;const bad=[];
      for(const o of S){for(const t of [null,'-1/2']){const hh=addr(o,t?'&tilt='+t:'');const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url410);await gopen(pb,hh);
          const x=await snap(pa),y=await snap(pb),dif=[];for(const k of Object.keys(x))if(x[k]!==y[k])dif.push(k);
          const ea=await exportsOf(pa),eb=await exportsOf(pb);const exeq=JSON.stringify(ea)===JSON.stringify(eb);if(exeq)exSame++;else dif.push('exports');
          if(!dif.length)same++;else bad.push(o.tab+' '+hh.slice(0,70)+' '+dif.join(','));await pa.close();await pb.close();}}
      ok(tag+' byte-identical to v0.4.10 for '+S.length*2+' states (incl. tilt −1/2, stack on / reciprocal off): stage, canvas, caption, about, cards, address, hash AND exact JSON, state JSON, CSV, Lift JSON, stats ('+exSame+'/'+S.length*2+' exports)',same===S.length*2,bad.join(' | '));}
    {let same=0,n=0;for(const o of S.filter(o=>o.tab!=='panels').slice(0,10)){n++;const hh=addr(o);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url410);await gopen(pb,hh);if(await pngHash(pa)===await pngHash(pb))same++;await pa.close();await pb.close();}
      ok(tag+' PNG export byte-identical to v0.4.10 ('+same+'/'+n+')',same===n);}
    // ---- (3) the layer, per tab
    for(const tab of ['fourier','clifford','hopf']){const [fsk,rk]=KEY[tab];
      await gopen(pg,addr({...STATE,tab,view:fsk}));const off=await snap(pg);
      ok(tag+' '+tab+': address has no '+rk+' key while the layer is off',!decodeURIComponent(off.hash).includes(rk+'='));
      // menu item only while the Full stack is on
      const hasItem=async()=>{await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);const r=await pg.locator('#menu_layers button:has-text("Reciprocal winding (throat at 1/1)")').count();await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(100);return r;};
      ok(tag+' '+tab+': Layers menu offers "Reciprocal winding (throat at 1/1)" while the Full stack is on',(await hasItem())===1);
      await gopen(pg,addr({...STATE,tab}));ok(tag+' '+tab+': ... and not while the Full stack is off',(await hasItem())===0);
      // toggle through the UI
      await gopen(pg,addr({...STATE,tab,view:fsk}));await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.locator('#menu_layers button:has-text("Reciprocal winding (throat at 1/1)")').click();await pg.waitForTimeout(500);
      const on=await snap(pg);
      ok(tag+' '+tab+': toggle writes '+rk+'=1 to the address; stage/canvas/caption change; data-role="reciprocal" present',decodeURIComponent(on.hash).includes(rk+'=1')&&on.cv!==off.cv&&on.caption!==off.caption&&/data-role="reciprocal"/.test(on.stage)&&/Reciprocal winding \(throat at 1\/1\)/.test(on.caption)&&(await pg.evaluate(()=>FVViews.abouts().join('|').includes('the other half of the full stack'))));
      const nAttr=await pg.evaluate(()=>{const g=document.querySelector('[data-role="reciprocal"]');return g?[g.dataset.n,g.dataset.undef,g.dataset.raw,g.dataset.drawn,g.dataset.half]:null;});
      console.log('INFO '+tag+' '+tab+' reciprocal data: n/undef/raw/drawn/half = '+JSON.stringify(nAttr));
      const SP=SC.build(CC.initial({...STATE}));ok(tag+' '+tab+': reciprocal point count = stack points ('+SP.n+') or its lifted half',tab==='clifford'?Number(nAttr[0])===SP.n&&Number(nAttr[3])>0:Number(nAttr[0])===SP.n&&Number(nAttr[1])===0);
      await pg.reload();await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(450);const rel=await snap(pg);
      ok(tag+' '+tab+': reload restores the layer (canvas and stage equal)',rel.cv===on.cv&&rel.stage===on.stage);
      await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);await pg.locator('#menu_layers button:has-text("Reciprocal winding (throat at 1/1)")').click();await pg.waitForTimeout(500);const back=await snap(pg);
      ok(tag+' '+tab+': toggling off again restores the off state byte for byte (stage, canvas, caption, about, hash)',back.stage===off.stage&&back.cv===off.cv&&back.caption===off.caption&&back.about===off.about&&back.hash===off.hash);
      // switch the Full stack off with the layer on: the layer is inert (nothing drawn), the key stays
      await gopen(pg,addr({...STATE,tab,view:fsk+';'+rk+'=1'}));const st1=await snap(pg);
      await gopen(pg,addr({...STATE,tab,view:rk+'=1'}));const st2=await snap(pg);await gopen(pg,addr({...STATE,tab}));const st3=await snap(pg);
      ok(tag+' '+tab+': with the Full stack off the '+rk+' key is inert (view equals the plain off view)',st2.cv===st3.cv&&st2.stage===st3.stage&&st2.caption===st3.caption&&!/data-role="reciprocal"/.test(st2.stage));
      // unthinned/thinned states and n6 = 0 labelled
      await gopen(pg,addr({...STATE,n6:'0',tab,view:fsk+';'+rk+'=1'}));const z=await snap(pg);
      ok(tag+' '+tab+': n6 = 0 (no image) is labelled, not hidden',/no image|have no image/.test(z.caption)||/n₆ = 0/.test(z.caption),z.caption.slice(0,200));
    }
    // ---- Clifford: thinned state says so and halves share the budget
    {await gopen(pg,addr({shellMode:'factorial',n1:'6',phi3:'700',m:'2',tab:'clifford',view:'cs=1;cr=1'}));const c=await pg.evaluate(()=>document.getElementById('caption').innerText);
      ok(tag+' Clifford thinned state (n1 = 6): caption says the halves share the 12,000 − m budget and are thinned',c.includes('share the head budget')&&c.includes('thinned, host selection'),c.slice(0,400));}
    // ---- Fourier frame includes the reciprocal when it is the larger (alpha = -1: stack radii 1/N, reciprocal N)
    {await gopen(pg,addr({...STATE,alpha:'-1',tab:'fourier',view:'fs=1'}));const a=await pg.evaluate(()=>document.querySelector('[data-role="full-stack"]').dataset.sc);
      await gopen(pg,addr({...STATE,alpha:'-1',tab:'fourier',view:'fs=1;fr=1'}));const b=await pg.evaluate(()=>document.querySelector('[data-role="full-stack"]').dataset.sc);
      ok(tag+' Fourier at alpha = −1 (stack inside the unit circle): the frame grows to include the reciprocal half (scale '+Number(a).toFixed(3)+' → '+Number(b).toFixed(3)+')',Number(b)<Number(a));}
    // ---- (4) Hopf: ink at the expected reflected positions
    for(const chart of ['host','comb']){
      await gopen(pg,addr({...STATE,tab:'hopf',chart,view:'hs=1;ha=0.5;ht=0.35'}));const offI=await pg.evaluate(()=>{const c=document.getElementById('stagecv');const g=c.getContext('2d');return {w:c.width,h:c.height,d:g.getImageData(0,0,c.width,c.height).data};});
      await gopen(pg,addr({...STATE,tab:'hopf',chart,view:'hs=1;hr=1;ha=0.5;ht=0.35'}));
      const res=await pg.evaluate(async({offArr,ow,oh,CHART})=>{
        const V=FVViews,N_=FVCombNumeric,C=FVCombCore,st=C.initial({shellMode:'factorial',n1:'4',phi3:'22',m:'2',alpha:'1',n6:'1',t1:'1',t2:'1',chart:CHART});
        const num=N_.compute(st),sc=num.scale,P=FVStack.build(st),RC=FVStack.reciprocal(P);
        const c=document.getElementById('stagecv'),g=c.getContext('2d'),cur=g.getImageData(0,0,c.width,c.height).data;
        const az=0.5,tl=0.35,Wd=640,Hd=480,R0=Math.min(Wd,Hd)*0.385,cx=Wd/2,cy=Hd/2+3,cm=V.camMat(az,tl),k=Math.min(c.width/Wd,c.height/Hd),ox=(c.width-Wd*k)/2,oy=(c.height-Hd*k)/2;
        const pts=(xy)=>{const n=P.n,xyz=new Float64Array(3*n),buf=new Float64Array(3*n);for(let i=0;i<n;i++){const p=N_.hopf({re:xy[2*i],im:xy[2*i+1]},sc);xyz.set(p,3*i);}V.projectInto(xyz,n,cm,R0,cx,cy,buf);return buf;};
        const bufR=pts(RC.xy.map?Float64Array.from(RC.xy,(v,i)=>v*sc*sc):RC.xy),bufP=pts(P.xy);
        const probe=(buf,diffAgainst)=>{let n=0,hit=0;for(let i=0;i<P.n;i+=Math.max(1,Math.floor(P.n/300))){if(buf[3*i+2]<0)continue;const x=Math.round(ox+k*buf[3*i]),y=Math.round(oy+k*buf[3*i+1]);if(x<2||y<2||x>c.width-3||y>c.height-3)continue;n++;let d=false;
          for(let yy=y-2;yy<=y+2&&!d;yy++)for(let xx=x-2;xx<=x+2;xx++){const j=4*(yy*c.width+xx);if(diffAgainst){if(cur[j]!==diffAgainst[j]||cur[j+1]!==diffAgainst[j+1]||cur[j+2]!==diffAgainst[j+2]){d=true;break;}}else if(cur[j+3]>0){d=true;break;}}
          if(d)hit++;}return [hit,n];};
        return {recip:probe(bufR,new Uint8ClampedArray(offArr)),primary:probe(bufP,null),size:[c.width,c.height,ow,oh]};
      },{offArr:Array.from(offI.d),ow:offI.w,oh:offI.h,CHART:chart}).catch(e=>({err:String(e)}));
      console.log('INFO '+tag+' hopf '+chart+' ink probe '+JSON.stringify(res));
      ok(tag+' Hopf ('+chart+' chart): ink at ≥ 90% of the expected reflected (front-facing, sampled) positions: '+(res.recip?res.recip.join('/'):'?')+'; control (primary positions): '+(res.primary?res.primary.join('/'):'?'),res.recip&&res.recip[1]>20&&res.recip[0]>=0.9*res.recip[1]&&res.primary[0]>=0.9*res.primary[1],JSON.stringify(res));}
    // ---- (5) key collision
    {const dup=await pg.evaluate(()=>{const seen={},d=[];for(const v of FVViews.registry)for(const k of Object.keys(v.defaults)){if(seen[k])d.push(k);seen[k]=1;}return {d,has:['fr','cr','hr'].map(k=>k in Object.assign({},...FVViews.registry.map(v=>v.defaults)))};});
      ok(tag+' view keys fr, cr, hr are new and unique across all views (duplicates: '+JSON.stringify(dup.d)+')',dup.d.length===0&&dup.has.every(Boolean));}
    // ---- (6) no horizontal scroll with everything on
    for(const tab of ['fourier','clifford','hopf']){const [fsk,rk]=KEY[tab];await gopen(pg,addr({...STATE,tab,view:fsk+';'+rk+'=1'}));await pg.click('button[data-menu="layers"]');await pg.waitForTimeout(150);
      const sw=await pg.evaluate(()=>[document.documentElement.scrollWidth,window.innerWidth]);ok(tag+' '+tab+': no horizontal scroll with the Layers menu open and the layer on ('+sw.join(' ≤ ')+')',sw[0]<=sw[1]);}
    // ---- (7) shots
    for(const tab of ['hopf','clifford','fourier']){const [fsk,rk]=KEY[tab];await gopen(pg,addr({...STATE,tab,view:fsk+';'+rk+'=1'}));await pg.waitForTimeout(300);
      await pg.screenshot({path:path.join(root,'shot_v0411_'+tag+'_'+tab+'_reciprocal.png'),fullPage:true});}
    ok(tag+' no page errors',errs.length===0,errs.join(' | ').slice(0,300));
    await ctx.close();
  }
  await browser.close();
  console.log('\nSUMMARY browser-check-v0411: '+pass+' pass, '+fail+' fail');process.exit(fail?1:0);
})();
