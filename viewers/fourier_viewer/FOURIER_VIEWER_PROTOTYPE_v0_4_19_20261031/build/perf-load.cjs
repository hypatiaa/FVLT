'use strict';
// Where the page-load time goes: CDP trace of one load (throttle via argv[2]), main-thread events by name. Usage: node perf-load.cjs [throttle] [hash]
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url='file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/'),thr=+process.argv[2]||4,hash=process.argv[3]||'';
(async()=>{
  const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage(),cdp=await ctx.newCDPSession(page);
  await page.goto('about:blank');await cdp.send('Emulation.setCPUThrottlingRate',{rate:thr});
  await cdp.send('Tracing.start',{categories:'devtools.timeline,v8,disabled-by-default-devtools.timeline,blink.user_timing',transferMode:'ReturnAsStream'});
  await page.goto(url+hash);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);await page.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));
  const done=new Promise(r=>cdp.on('Tracing.tracingComplete',r));await cdp.send('Tracing.end');const tc=await done;
  let txt='';let h=tc.stream;for(;;){const c=await cdp.send('IO.read',{handle:h});txt+=c.data;if(c.eof)break;}
  const ev=JSON.parse(txt),evs=Array.isArray(ev)?ev:ev.traceEvents;
  const names=['ParseHTML','EvaluateScript','v8.compile','v8.run','FunctionCall','Layout','UpdateLayoutTree','Paint','Commit','CompileScript','v8.parseOnBackground','ScheduleStyleRecalculation'];
  const t={};for(const e of evs)if(e.ph==='X'&&e.dur&&names.includes(e.name))t[e.name]=(t[e.name]||0)+e.dur/1000;
  const marks=evs.filter(e=>e.name==='fv-init'||e.name==='fv-init-0'||e.name==='firstContentfulPaint'||e.name==='domContentLoadedEventEnd'||e.name==='loadEventEnd'||e.name==='navigationStart'||e.name==='FirstMeaningfulPaint');
  const t0=Math.min(...marks.filter(m=>m.name==='navigationStart').map(m=>m.ts));
  console.log('x'+thr,JSON.stringify(Object.fromEntries(Object.entries(t).map(([k,v])=>[k,+v.toFixed(1)]))));
  console.log(marks.map(m=>m.name+' '+((m.ts-t0)/1000).toFixed(0)).join(' | '));
  const scripts=evs.filter(e=>e.name==='EvaluateScript'&&e.dur>2000).map(e=>(e.dur/1000).toFixed(1)+'ms '+((e.args&&e.args.data&&e.args.data.url)||'').slice(-40));console.log('EvaluateScript >2ms:',scripts.join(' ; '));
  const comp=evs.filter(e=>(e.name==='v8.compile'||e.name==='V8.CompileCode'||e.name==='v8.compile')&&e.dur>1000).map(e=>(e.dur/1000).toFixed(1));console.log('compile >1ms:',comp.join(','));
  await b.close();})();
