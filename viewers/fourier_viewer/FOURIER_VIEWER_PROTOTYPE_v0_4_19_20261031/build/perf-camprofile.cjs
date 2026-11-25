'use strict';
// CDP Profiler + trace categories while rotating the camera 60 frames on one tab (reproduction state). Usage: node perf-camprofile.cjs [tab] [throttle] [kind]
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist',process.env.F||'comb-hopf.html').split(path.sep).join('/'),tab=process.argv[2]||'hopf',thr=+process.argv[3]||4,kind=process.argv[4]||'rotate';
(async()=>{
  const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
  await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
  await page.evaluate(tab=>{FVPanel.dial({shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3',tab});FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));},tab);
  await cdp.send('Emulation.setCPUThrottlingRate',{rate:thr});await cdp.send('Profiler.enable');await cdp.send('Profiler.setSamplingInterval',{interval:200});
  await cdp.send('Tracing.start',{categories:'devtools.timeline,disabled-by-default-devtools.timeline',transferMode:'ReturnAsStream'});
  await cdp.send('Profiler.start');
  const r=await page.evaluate(async(kind)=>{const frame=()=>new Promise(r=>requestAnimationFrame(()=>r()));
    const svg=document.getElementById('stage'),rc=svg.getBoundingClientRect(),x0=rc.left+rc.width/2,y0=rc.top+rc.height/2;
    const pe=(type,x,y)=>svg.dispatchEvent(new PointerEvent(type,{pointerId:1,clientX:x,clientY:y,bubbles:true,cancelable:true,button:0,buttons:1,pointerType:'mouse'}));
    pe('pointerdown',x0,y0);let x=x0,y=y0;const t0=performance.now();let cam=0;
    for(let i=0;i<60;i++){x+=3;y+=(i%2?1.5:-1.5);pe('pointermove',x,y);await frame();cam+=FVPanel.perf.cam;}
    const te=performance.now();pe('pointerup',x,y);return {fps:60/((te-t0)/1000),camMs:cam/60};},kind);
  const {profile}=await cdp.send('Profiler.stop');
  const done=new Promise(r=>cdp.on('Tracing.tracingComplete',r));await cdp.send('Tracing.end');const tc=await done;
  let txt='';let h=tc.stream;for(;;){const c=await cdp.send('IO.read',{handle:h});txt+=c.data;if(c.eof)break;}
  const ev=JSON.parse(txt);const evs=Array.isArray(ev)?ev:ev.traceEvents;
  const cat={};for(const e of evs)if(e.ph==='X'&&e.dur&&['Layout','UpdateLayoutTree','Paint','PrePaint','Layerize','Commit','FunctionCall','EvaluateScript','HitTest','RunTask','RasterTask','UpdateLayer','CompositeLayers','FireAnimationFrame','Decode Image','GPUTask'].includes(e.name))cat[e.name]=(cat[e.name]||0)+e.dur/1000/60;
  const self={},byId=new Map(profile.nodes.map(n=>[n.id,n]));const dt=profile.timeDeltas;profile.samples.forEach((id,i)=>{const n=byId.get(id),k=n.callFrame.functionName+':'+n.callFrame.lineNumber;self[k]=(self[k]||0)+(dt[i]||0)/1000/60;});
  console.log(tab,'x'+thr,JSON.stringify(r),'\nms per frame by trace event:',JSON.stringify(Object.fromEntries(Object.entries(cat).map(([k,v])=>[k,+v.toFixed(2)]))));
  console.log('self ms/frame top 12:',JSON.stringify(Object.entries(self).sort((a,b)=>b[1]-a[1]).slice(0,12).map(([k,v])=>[k,+v.toFixed(2)])));
  await b.close();})();
