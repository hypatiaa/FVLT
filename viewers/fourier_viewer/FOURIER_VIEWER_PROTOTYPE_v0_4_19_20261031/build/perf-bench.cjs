'use strict';
// Performance bench (Playwright from s6_atom/node_modules). Usage: node perf-bench.cjs [url] ; prints JSON tables for 1x and 4x CPU throttle.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
async function run(throttle){
  const browser=await chromium.launch(),out={throttle};
  const ctx=await browser.newContext({viewport:{width:1280,height:800},deviceScaleFactor:1}),page=await ctx.newPage();
  const cdp=await ctx.newCDPSession(page);
  const errs=[];page.on('pageerror',e=>errs.push(String(e)));
  await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  // build the reproduction address through the page's own state plumbing
  const hash=await page.evaluate(([R])=>{FVPanel.dial(R);FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));FVPanel.dial({tab:'clifford'});return location.hash;},[REPRO]);
  out.reproHash=hash;
  const base=url.split('#')[0];
  await cdp.send('Emulation.setCPUThrottlingRate',{rate:throttle});
  const frame=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
  const load=async(h,reps=3)=>{const r=[];for(let i=0;i<reps;i++){const p=await ctx.newPage();const c=await ctx.newCDPSession(p);await c.send('Emulation.setCPUThrottlingRate',{rate:throttle});
    await p.goto(base+(h||''));await p.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await p.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));
    r.push(await p.evaluate(()=>{const m=performance.getEntriesByName('fv-init')[0];return m?m.duration:null;}));await p.close();}return med(r);};
  out.firstRender={};
  out.firstRender.default_fourier=await load('');
  out.firstRender.repro_clifford=await load(hash);
  for(const t of ['fourier','hopf','panels']){const h=await page.evaluate(([R,t])=>{return FVCombCore.encodeAddress({...FVPanel.state,tab:t});},[REPRO,t]);out.firstRender['repro_'+t]=await load(h);}
  for(const t of ['clifford','fourier','hopf','panels']){const h=await page.evaluate(([t])=>FVCombCore.encodeAddress({...FVCombCore.initial(),tab:t}),[t]);out.firstRender['default_'+t]=await load(h);}
  // state-change timings at the reproduction state, per tab
  await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  const timeOp=(op)=>page.evaluate(async([op,reps])=>{
    const frame=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
    const res={sync:[],frame:[]};
    for(let i=0;i<reps;i++){await frame();const t0=performance.now();op==='phi'?FVPanel.onAct(i%2?'phidn':'phiup'):op==='t2'?FVPanel.onAct(i%2?'t2dn':'t2up'):FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,i%2?'-627/250':'-5/3'));
      const t1=performance.now();await frame();const t2=performance.now();res.sync.push(t1-t0);res.frame.push(t2-t0);}
    return res;},[op,8]);
  out.change={};
  for(const t of ['clifford','fourier','hopf','panels']){
    await page.evaluate(t=>{FVPanel.dial({tab:t});},t);await page.evaluate(frame_=>0,0);
    out.change[t]={};
    for(const op of ['phi','t2','s']){await page.evaluate(()=>{FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));});const r=await timeOp(op);out.change[t][op]={sync:+med(r.sync).toFixed(1),toFrame:+med(r.frame).toFixed(1)};}
  }
  // reset to repro
  await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  // slider drag: (a) one event per animation frame; (b) 30 events in one synchronous burst
  const drag=(id,vals,mode)=>page.evaluate(async([id,vals,mode])=>{
    const frame=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
    const el=document.getElementById(id);await frame();const t0=performance.now();let longest=0;
    if(mode==='perframe'){let prev=performance.now();for(const v of vals){el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}));await frame();const n=performance.now();longest=Math.max(longest,n-prev);prev=n;}}
    else{for(const v of vals){el.value=v;el.dispatchEvent(new Event('input',{bubbles:true}));}}
    const tb=performance.now();await frame();const te=performance.now();
    return {total:te-t0,burstSync:tb-t0,fps:mode==='perframe'?vals.length/((te-t0)/1000):null,worstFrame:longest};},[id,vals,mode]);
  out.drag={};
  const phiVals=Array.from({length:30},(_,i)=>String(1+((i*3)%24))),sVals=Array.from({length:30},(_,i)=>(-2.4+0.16*i).toFixed(3));
  for(const [id,vals] of [['phi_sl',phiVals],['s_sl',sVals]]){
    for(const mode of ['perframe','burst']){await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);const r=await drag(id,vals,mode);out.drag[id+'_'+mode]=Object.fromEntries(Object.entries(r).map(([k,v])=>[k,v===null?null:+v.toFixed(1)]));}}
  // tab switching (reproduction state)
  await page.goto(base+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);
  out.tab={};
  for(const [a,b] of [['clifford','fourier'],['fourier','hopf'],['hopf','panels'],['panels','clifford'],['clifford','hopf'],['hopf','clifford']]){
    await page.evaluate(a=>FVPanel.dial({tab:a}),a);
    const r=await page.evaluate(async([b])=>{const frame=()=>new Promise(r=>requestAnimationFrame(()=>{const mc=new MessageChannel();mc.port1.onmessage=()=>r();mc.port2.postMessage(0);}));
      await frame();const t0=performance.now();FVPanel.onAct('tab',b);const t1=performance.now();await frame();return [t1-t0,performance.now()-t0];},[b]);
    out.tab[a+'->'+b]={sync:+r[0].toFixed(1),toFrame:+r[1].toFixed(1)};}
  out.errors=errs;
  await browser.close();return out;
}
(async()=>{const o=[];for(const t of [1,4])o.push(await run(t));console.log(JSON.stringify(o,null,1));})();
