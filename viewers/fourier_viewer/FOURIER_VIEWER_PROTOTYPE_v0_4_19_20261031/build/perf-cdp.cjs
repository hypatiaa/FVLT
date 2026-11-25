'use strict';
// CDP Profiler + Tracing: self time by function and main-thread event categories while stepping phi3 40 times on one tab at the reproduction state.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/'),tab=process.argv[3]||'clifford',mode=process.argv[4]||'step',thr=+process.argv[5]||1;
(async()=>{
  const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
  await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
  await page.evaluate(tab=>{FVPanel.dial({shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3',tab});FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));},tab);
  await cdp.send('Emulation.setCPUThrottlingRate',{rate:thr});await cdp.send('Profiler.enable');await cdp.send('Profiler.setSamplingInterval',{interval:200});
  await cdp.send('Tracing.start',{categories:'devtools.timeline,disabled-by-default-devtools.timeline',transferMode:'ReturnAsStream'});
  await cdp.send('Profiler.start');
  await page.evaluate(async(mode)=>{const frame=()=>new Promise(r=>requestAnimationFrame(()=>r()));for(let i=0;i<40;i++){if(mode==='drag'){const el=document.getElementById('phi_sl');el.value=String(1+(i*3)%24);el.dispatchEvent(new Event('input',{bubbles:true}));}else FVPanel.onAct(i%2?'phidn':'phiup');await frame();}},mode);
  const {profile}=await cdp.send('Profiler.stop');
  const done=new Promise(r=>cdp.on('Tracing.tracingComplete',r));await cdp.send('Tracing.end');const tc=await done;
  let txt='';let h=tc.stream;for(;;){const c=await cdp.send('IO.read',{handle:h});txt+=c.data;if(c.eof)break;}
  const ev=JSON.parse(txt);const evs=Array.isArray(ev)?ev:ev.traceEvents;
  const cat={};for(const e of evs)if(e.ph==='X'&&e.dur&&['Layout','UpdateLayoutTree','Paint','PrePaint','Layerize','Commit','FunctionCall','EvaluateScript','HitTest','ParseHTML','RunTask','RasterTask','UpdateLayer'].includes(e.name))cat[e.name]=(cat[e.name]||0)+e.dur/1000/40;
  const self={},total=profile.samples.length,byId=new Map(profile.nodes.map(n=>[n.id,n]));
  const dt=profile.timeDeltas;profile.samples.forEach((id,i)=>{const n=byId.get(id),k=n.callFrame.functionName+':'+n.callFrame.lineNumber;self[k]=(self[k]||0)+(dt[i]||0)/1000/40;});
  console.log('tab',tab,'ms per step by trace event (X events; nested, not additive):',JSON.stringify(Object.fromEntries(Object.entries(cat).map(([k,v])=>[k,+v.toFixed(2)]))));
  console.log('self time ms per step, top 14:',JSON.stringify(Object.entries(self).sort((a,b)=>b[1]-a[1]).slice(0,14).map(([k,v])=>[k,+v.toFixed(2)])));
  await b.close();})();
