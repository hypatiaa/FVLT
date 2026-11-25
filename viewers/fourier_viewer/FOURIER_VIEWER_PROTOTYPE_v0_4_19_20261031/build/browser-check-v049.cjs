'use strict';
// v0.4.9 browser check (SCHEMA_ADDENDUM_17): full stack and fraction stack. 1280x800 and 375x812.
// (1) toggles off: byte-identical to v0.4.8 (stage, canvas, caption, about, cards, address, hash, state, PNG export); (2) counts 39/41/39/41 unchanged, also with stacks on;
// (3) the page's stack equals stack-core in Node and the OLD instrument's buildFullStack (frozen file, run in a Node vm); (4) dots really drawn; (5) address key only when on;
// (6) signature cache: an s change does not redraw the stack bitmap; (7) no horizontal scroll at 375; (8) shots shot_v049_*.
const fs=require('fs'),vm=require('vm'),path=require('path'),crypto=require('crypto');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url48=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_8_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o,extra)=>CC.encodeAddress(CC.initial(o))+(extra||'');
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(350);};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hash:location.hash,st:JSON.stringify(FVPanel.state)}));
const pngHash=pg=>pg.evaluate(async()=>{const b=await FVPanel.exportPng();const a=new Uint8Array(await b.arrayBuffer());const d=await crypto.subtle.digest('SHA-256',a);return [...new Uint8Array(d)].map(x=>x.toString(16).padStart(2,'0')).join('');});
// ---- the old instrument's buildFullStack in a vm (read only)
const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
function block(t){const i=src.indexOf(t);let j=src.indexOf('{',i),d=0;for(;j<src.length;j++){if(src[j]==='{')d++;else if(src[j]==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
const vctx={Math,Number,String,Object,Array,JSON};vm.createContext(vctx);
vm.runInContext('var state={};function factorial(n){let f=1;for(let k=2;k<=n;k++)f*=k;return f;}function gearboxExactText(k){return state[k+"Exact"];}let _stackCache=null,_stackCacheKey=null,_stackDrawSig=null;\n'+['function selectedShellBase(','function selectedShellSpan(','function combOffsets(','function combKernel(','function reducedHalfTurns(','function stableGearboxAngle(','function computeVernier(','function buildFullStack('].map(block).join('\n'),vctx);
const near=(a,b)=>a.length===b.length&&a.every((v,i)=>Math.abs(v-b[i])<=1e-13*Math.max(1,Math.abs(b[i])));   // page (Chromium V8) vs Node (V8): float64 cos/sin/pow may differ in the last bits
const qn=t=>{const q=t.split('/');return Number(q[0])/(q[1]?Number(q[1]):1);};
function oldStack(o){vm.runInContext('state='+JSON.stringify({showStack:true,shellMode:'factorial',directBase:24,n1:Number(o.n1),n6:qn(o.n6||'1'),alpha:qn(o.alpha),t1:qn(o.t1||'1'),t2:qn(o.t2||'1'),t1Exact:o.t1||'1',t2Exact:o.t2||'1',m:Number(o.m)})+';_stackCache=null;_stackCacheKey=null;',vctx);return vm.runInContext('buildFullStack()',vctx);}
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- (2) counts, toggles off and on
    for(const [tab,on] of [['fourier','fs=1;ff=1'],['clifford','cs=1'],['hopf','hs=1;hf=1']]){
      const r=[];for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){
        await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr({...o,view:on})+x);r.push(await count(pg));}
      ok(tag+' '+tab+': counts 39/41/39/41 unchanged, also with the stack toggles on ('+on+')',r.join('/')==='39/39/41/41/39/39/41/41',r.join('/'));}
    // ---- (1) toggles off: identical to v0.4.8
    const S=[{shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',alpha:'1/2',m:'2',tab:'clifford'},
      {shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'},{shellMode:'factorial',n1:'4',phi3:'25',m:'2',tab:'fourier'},{shellMode:'factorial',n1:'4',phi3:'21',m:'3',sTyped:'1/3',view:'cf=1',tab:'clifford'}];
    {let same=0;const bad=[];for(const o of S){for(const t of [null,'-1/2']){const hh=addr(o,t?'&tilt='+t:'');const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url48);await gopen(pb,hh);
        const x=await snap(pa),y=await snap(pb);if(JSON.stringify(x)===JSON.stringify(y))same++;else bad.push(o.tab+' '+hh.slice(0,90)+' '+Object.keys(x).filter(k=>x[k]!==y[k]).join(','));await pa.close();await pb.close();}}
      ok(tag+' toggles off: stage, canvas, caption, about, cards, address, hash, state byte-identical to v0.4.8 ('+same+'/'+2*S.length+' states incl. tilt −1/2)',same===2*S.length,bad.join(' | '));}
    {let same=0;const n=4;for(const o of S.filter(o=>o.tab!=='panels').slice(0,n)){const hh=addr(o);const pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url48);await gopen(pb,hh);if(await pngHash(pa)===await pngHash(pb))same++;await pa.close();await pb.close();}
      ok(tag+' toggles off: PNG export byte-identical to v0.4.8 ('+same+'/'+n+')',same===n);}
    // ---- (3) the page's stack = stack-core (Node) = the OLD buildFullStack
    {let good=0,tot=0;const bad=[];
      for(const o of [{n1:'3',alpha:'-1',m:'2'},{n1:'4',alpha:'1',m:'2'},{n1:'4',alpha:'1/2',m:'3'},{n1:'4',alpha:'0',m:'7'},{n1:'5',alpha:'1',m:'3'},{n1:'5',alpha:'1/2',m:'7'},{n1:'4',alpha:'-1',m:'2',n6:'-1'}]){tot++;
        const st={shellMode:'factorial',n1:o.n1,phi3:'2',m:o.m,alpha:o.alpha,n6:o.n6||'1',tab:'fourier',view:'fs=1'};await gopen(pg,addr(st));
        const pageXY=await pg.evaluate(()=>Array.from(FVPanel.model.stack.xy));const node=SC.build(CC.initial(st)),old=oldStack(o),m=Number(o.m);
        let same=near(pageXY,Array.from(node.xy)),dmax=0;
        if(old.length*m*2!==pageXY.length)same=false;else for(let i=0;i<old.length;i++)for(let t=0;t<m;t++){const d=Math.hypot(old[i][t][0]-pageXY[2*(i*m+t)],old[i][t][1]-pageXY[2*(i*m+t)+1])/Math.max(1,Math.hypot(old[i][t][0],old[i][t][1]));if(d>dmax)dmax=d;}
        if(same&&dmax<=1e-12)good++;else bad.push(JSON.stringify(o)+' '+dmax);}
      ok(tag+' page stack = stack-core (≤ 1e-13 relative, Chromium vs Node float64) = old buildFullStack (≤ 1e-12 relative) for '+tot+' states (n1 3/4/5, α −1/0/1/1/2, m 2/3/7, n6 −1)',good===tot,bad.join(' | '));}
    // saphir's N = 5, s = 0 comparison state: the same point set as the old instrument's (lattice s, φ3 in 0..25, no thinning)
    for(const sv of ['0','1']){const o={shellMode:'factorial',n1:'4',phi3:'20',m:'2',alpha:'1',sTyped:sv,tab:'fourier',view:'fs=1'};const T=sv==='0'?[[5,0],[5,0]]:[[-4.045084972,2.938926261],[-4.045084972,-2.938926261]];await gopen(pg,addr(o));
      const info=await pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="full-stack"]');return {n:g&&g.getAttribute('data-n'),cells:g&&g.getAttribute('data-cells'),step:g&&g.getAttribute('data-step'),xy:Array.from(FVPanel.model.stack.xy),teeth:FVPanel.model.num.z.map(z=>[z.re,z.im])};});
      const old=oldStack({n1:'4',alpha:'1',m:'2'});let d=0;for(let i=0;i<old.length;i++)for(let t=0;t<2;t++)d=Math.max(d,Math.hypot(old[i][t][0]-info.xy[4*i+2*t],old[i][t][1]-info.xy[4*i+2*t+1]));
      ok(tag+' saphir state (n1 4, N 5, s '+sv+', α 1, m 2): 650 cells × 2 = 1,300 points, step 1, equal to the old buildFullStack (max |Δ| '+d.toExponential(1)+'); teeth as the old readout '+JSON.stringify(T),info.n==='1300'&&info.cells==='650'&&info.step==='1'&&d<1e-12&&info.teeth.every((z,i)=>Math.abs(z[0]-T[i][0])<1e-8&&Math.abs(z[1]-T[i][1])<1e-8),JSON.stringify(info.teeth));
      if(w===1280){await pg.evaluate(()=>window.scrollTo(0,0));await shotView(pg,'shot_v049_1280x800_fourier_fullstack_N5_s'+sv+'_alpha_1');}}
    // ---- (4) dots drawn: sampled stack points carry ink on the canvas (Fourier), and the Clifford / Hopf groups record drawn points
    {await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',alpha:'1',tab:'fourier',view:'fs=1'}));
      const r=await pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="full-stack"]'),sc=+g.dataset.sc,cx=+g.dataset.cx,cy=+g.dataset.cy,cv=document.getElementById('stagecv'),c2=cv.getContext('2d'),k=Math.min(cv.width/640,cv.height/480),ox=(cv.width-640*k)/2,oy=(cv.height-480*k)/2,P=FVPanel.model.stack;
        let inked=0,tried=0;const bg=c2.getImageData(1,1,1,1).data;for(let i=0;i<P.n;i+=37){const x=Math.round(k*(cx+sc*P.xy[2*i])+ox),y=Math.round(k*(cy-sc*P.xy[2*i+1])+oy);if(x<1||y<1||x>=cv.width-1||y>=cv.height-1)continue;tried++;const d=c2.getImageData(x,y,1,1).data;if(Math.abs(d[0]-bg[0])+Math.abs(d[1]-bg[1])+Math.abs(d[2]-bg[2])>40)inked++;}return {inked,tried};});
      ok(tag+' Fourier: sampled stack points carry ink on the canvas ('+r.inked+'/'+r.tried+')',r.tried>10&&r.inked===r.tried,JSON.stringify(r));
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',alpha:'1',tab:'clifford',view:'cs=1'}));const c=await pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="full-stack"]');return g&&{n:g.dataset.n,drawn:g.dataset.drawn,levels:g.dataset.levels};});
      ok(tag+' Clifford: 1,300 lifted stack points drawn, 25 ρ-levels',c&&c.n==='1300'&&c.drawn==='1300'&&c.levels==='25',JSON.stringify(c));
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',alpha:'1',tab:'hopf',view:'hs=1'}));const hp=await pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="full-stack"]');return g&&g.dataset.n;});
      ok(tag+' Hopf: 1,300 stack points on the base',hp==='1300',hp);}
    // ---- α follows the viewer's exact α (any accepted value): the drawn stack changes with α = 3/7, −5/2 and matches stack-core
    {const vals=[];for(const a of ['3/7','-5/2','8']){await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',alpha:a,tab:'fourier',view:'fs=1'}));const x=await pg.evaluate(()=>Array.from(FVPanel.model.stack.xy));const n=SC.build(CC.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'2',alpha:a}));vals.push(near(x,Array.from(n.xy))?JSON.stringify(x.slice(0,8)):'MISMATCH');}
      ok(tag+' α 3/7, −5/2, 8: page stack = stack-core, and differs between the three',vals.every(v=>v!=='MISMATCH')&&new Set(vals).size===3);}
    // ---- (5) address: toggling through the Layers menu writes fs=1 into the view field only while on; off restores the old address
    {await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier'}));const h0=await pg.evaluate(()=>location.hash);
      await pg.click('[data-act="menu"][data-v="layers"]');await pg.click('[data-act="vtool"][data-v="fstack"]');await pg.waitForTimeout(400);const h1=await pg.evaluate(()=>location.hash);
      const lab=await pg.evaluate(()=>{const b=document.querySelector('[data-act="vtool"][data-v="fstack"]');return b&&b.textContent;});
      await pg.click('[data-act="vtool"][data-v="fstack"]');await pg.waitForTimeout(400);const h2=await pg.evaluate(()=>location.hash);
      ok(tag+' Layers ✦ Full stack: address gets view=fs=1 only while on (id unchanged); off restores the v0.4.8 address',/[&]view=fs%3D1(&|$)/.test(h1)&&h1.startsWith('#v=fv-comb-hopf/0.2&')&&h2===h0&&/Full stack/.test(lab||''),h0+' | '+h1+' | '+h2);
      await pg.click('[data-act="vtool"][data-v="fstack"]');await pg.waitForTimeout(300);const o1=await pg.evaluate(()=>{const b=document.querySelector('[data-act="vtool"][data-v="sopac"]');return b&&b.textContent;});
      await pg.click('[data-act="vtool"][data-v="sopac"]');await pg.waitForTimeout(300);const o2=await pg.evaluate(()=>({t:document.querySelector('[data-act="vtool"][data-v="sopac"]').textContent,h:location.hash}));
      ok(tag+' Stack opacity item (only while the stack is on): 0.50 → 0.30, address view fs=1;so=0.3; absent with the stack off',o1==='Stack opacity 0.50'&&o2.t==='Stack opacity 0.30'&&/view=fs%3D1%3Bso%3D0.3/.test(o2.h)&&!/sopac/.test(await pg.evaluate(()=>{FVPanel.dial({view:''});return document.getElementById('menu').innerHTML;})),JSON.stringify([o1,o2]));
      const v48=await ctx.newPage();await gopen(v48,h1,url48);const st48=await v48.evaluate(()=>FVPanel.state.view);ok(tag+' a v0.4.8 reader accepts the address (view key ignored there): view = '+st48,st48==='fs=1');await v48.close();}
    // ---- (6) signature cache: an s change does not redraw the stack bitmap; an α change does
    {await gopen(pg,addr({shellMode:'factorial',n1:'5',phi3:'115',m:'3',tab:'fourier',view:'fs=1'}));const d0=await pg.evaluate(()=>FVStackView.SDOT.draws);
      await pg.evaluate(()=>FVPanel.onAct('sup'));await pg.waitForTimeout(300);await pg.evaluate(()=>FVPanel.onAct('sup'));await pg.waitForTimeout(300);const d1=await pg.evaluate(()=>FVStackView.SDOT.draws);
      await pg.evaluate(()=>FVPanel.dial({alpha:'1/2'}));await pg.waitForTimeout(300);const d2=await pg.evaluate(()=>FVStackView.SDOT.draws);
      ok(tag+' signature cache: two s steps redraw nothing ('+d0+' → '+d1+'), an α change redraws once ('+d2+')',d1===d0&&d2===d0+1);
      const t=await pg.evaluate(()=>{const t0=performance.now();FVPanel.dial({alpha:'2/3'});return performance.now()-t0;});ok(tag+' n1 = 5, m = 3 (14,762 cells, 44,286 points): rebuild + draw '+t.toFixed(0)+' ms (< 1500)',t<1500);}
    // ---- degenerate labels
    {await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',n6:'0',tab:'fourier',view:'fs=1'}));const c=await pg.evaluate(()=>document.getElementById('caption').innerText);ok(tag+' n6 = 0 labelled',/n₆ = 0: every stack point at the origin/.test(c));
      await gopen(pg,addr({shellMode:'factorial',n1:'7',phi3:'5000',m:'2',tab:'fourier',view:'fs=1'}));const c7=await pg.evaluate(()=>document.getElementById('caption').innerText);ok(tag+' B = 5040: thinning labelled (every 21st value, cap 58,081)',/every 21st value/.test(c7)&&/thinned: cap 58,081 cells, deterministic/.test(c7),c7.slice(0,300));
      await gopen(pg,addr({shellMode:'factorial',n1:'7',phi3:'5000',m:'2',tab:'hopf',view:'hs=1'}));const ch=await pg.evaluate(()=>document.getElementById('caption').innerText);ok(tag+' Hopf, thinned stack: caption says indices are skipped and pixel resolution does not certify labels at large N',/thinned: integer s, φ₃ are skipped, and pixel resolution does not certify labels at large N/.test(ch),ch.slice(0,300));
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'25',m:'2',tab:'fourier',view:'fs=1'}));const c0=await pg.evaluate(()=>document.getElementById('caption').innerText);ok(tag+' current N = 0: stack not drawn, labelled',/full stack not drawn/.test(c0));
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',tab:'fourier',view:'fs=1'}));const ca=await pg.evaluate(()=>document.getElementById('caption').innerText);ok(tag+' N = 0 column labelled and register stated',/N = 0, no comb \(26 cells, not drawn\)/.test(ca)&&/phases exact/.test(ca));
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'3',sTyped:'1/3',tab:'fourier',view:'ff=1'}));const fr=await pg.evaluate(()=>({n:document.querySelectorAll('#stage [data-role="fraction-stack"] circle').length,c:document.getElementById('caption').innerText}));ok(tag+' Fourier fraction stack: heads drawn on |z| = |ρ| with caption',fr.n>0&&/fraction stack s ∈ \(1\/3\)·ℤ/.test(fr.c),JSON.stringify(fr).slice(0,200));
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',tilt:undefined,tab:'fourier',view:'fs=1'},'&tilt=1'));const tl=await pg.evaluate(()=>Array.from(FVPanel.model.stack.xy));const n0=SC.build(CC.initial({shellMode:'factorial',n1:'4',phi3:'21',m:'2'}));const tl0=await pg.evaluate(()=>{FVPanel.dial({tilt:'0'});return Array.from(FVPanel.model.stack.xy);});ok(tag+' α_Tilt = 1: the stack is unchanged (bitwise against tilt 0 in the page; ≤ 1e-13 against Node)',tl.every((v,i)=>v===tl0[i])&&near(tl,Array.from(n0.xy)));}
    // ---- (7) no horizontal scroll, every tab with stacks on
    {const r=[];for(const [tab,v] of [['fourier','fs=1;ff=1'],['clifford','cs=1;cf=1'],['hopf','hs=1;hf=1']]){await gopen(pg,addr({shellMode:'factorial',n1:'5',phi3:'115',m:'7',tab,view:v}));r.push(await pg.evaluate(()=>document.documentElement.scrollWidth<=window.innerWidth));}
      ok(tag+' no horizontal scroll with the stacks on (Fourier, Clifford, Hopf)',r.every(Boolean),r.join(','));}
    // ---- (8) shots: saphir's state n1 4, N 4 (phi3 21), m 2, n6 1, t1 = t2 = 1; alpha 1, 1/2, -1
    for(const [a,nm] of [['1','1'],['1/2','1_2'],['-1','m1']])for(const [tab,v] of [['fourier','fs=1'],['clifford','cs=1']]){
      await gopen(pg,addr({shellMode:'factorial',n1:'4',phi3:'21',m:'2',alpha:a,tab,view:v}));await shotView(pg,'shot_v049_'+tag+'_'+tab+'_fullstack_alpha_'+nm);}
    ok(tag+' no page errors',errs.length===0,errs.slice(0,3).join(' | '));
    await pg.close();await ctx.close();
  }
  await browser.close();console.log('v0.4.9 browser check: '+pass+' pass / '+fail+' fail');process.exit(fail?1:0);
})();
async function shotView(pg,name){await pg.evaluate(()=>window.scrollTo(0,0));const r=await pg.evaluate(()=>{const a=document.getElementById('caption').getBoundingClientRect(),b=document.getElementById('frame').getBoundingClientRect();return {x0:Math.min(a.left,b.left)+scrollX,x1:Math.max(a.right,b.right)+scrollX,y0:Math.min(a.top,b.top)+scrollY,y1:Math.max(a.bottom,b.bottom)+scrollY};});
  const x=Math.max(0,r.x0-6),y=Math.max(0,r.y0-6);await pg.screenshot({path:path.join(root,name+'.png'),clip:{x,y,width:Math.min(r.x1+6,pg.viewportSize().width)-x,height:r.y1+6-y},fullPage:true});}
