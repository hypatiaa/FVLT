'use strict';
// First render, A/B interleaved: page load to the first frame presented after the first full render (rAF after FVPanel.perf.n > 0), per tab, 1x and 4x CPU throttle.
// Usage: node perf-first.cjs <urlA> [urlB] ; load order alternates A, B, A, B ... (9 loads each) so machine noise hits both alike; medians.
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const urls=process.argv.slice(2);if(!urls.length)throw Error('usage: node perf-first.cjs urlA [urlB]');
const REPRO={shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'};
const med=a=>{const s=[...a].sort((x,y)=>x-y);return s[Math.floor(s.length/2)];};
(async()=>{
  const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800},deviceScaleFactor:1});
  const hashes={default_fourier:''};
  {const p=await ctx.newPage();await p.goto(urls[urls.length-1]);await p.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
   for(const t of ['clifford','fourier','hopf','panels'])hashes['repro_'+t]=await p.evaluate(([R,t])=>{FVPanel.dial(R);FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));return FVCombCore.encodeAddress({...FVPanel.state,tab:t});},[REPRO,t]);await p.close();}
  const out={};
  for(const thr of [1,4])for(const [name,h] of Object.entries(hashes)){
    const r=urls.map(()=>({ff:[],init:[],n:[]}));
    for(let i=0;i<9;i++)for(let u=0;u<urls.length;u++){
      const p=await ctx.newPage(),c=await ctx.newCDPSession(p);await c.send('Emulation.setCPUThrottlingRate',{rate:thr});
      await p.addInitScript(()=>{window.__ff=null;const poll=()=>{if(window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0)requestAnimationFrame(()=>{window.__ff=performance.now();});else requestAnimationFrame(poll);};requestAnimationFrame(poll);});
      await p.goto(urls[u].split('#')[0]+h);await p.waitForFunction(()=>window.__ff!==null);await p.waitForTimeout(300);
      const v=await p.evaluate(()=>({ff:window.__ff,init:(performance.getEntriesByName('fv-init')[0]||{}).duration,n:FVPanel.perf.n}));
      r[u].ff.push(v.ff);r[u].init.push(v.init);r[u].n.push(v.n);await p.close();}
    out[(thr===1?'x1 ':'x4 ')+name]=r.map(x=>({firstFrameMs:Math.round(med(x.ff)),initJsMs:Math.round(med(x.init)),rendersAfterLoad:med(x.n)}));
  }
  console.log(JSON.stringify(out,null,1));await b.close();})();
