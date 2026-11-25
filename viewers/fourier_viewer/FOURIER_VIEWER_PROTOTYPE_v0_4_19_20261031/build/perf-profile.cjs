'use strict';
// Where does a render go? Per-phase wall times (performance.now) at the reproduction state, per tab, plus DOM/SVG size.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),url=process.argv[2]||'file:///'+path.join(root,'dist','comb-hopf.html').split(path.sep).join('/');
(async()=>{
  const b=await chromium.launch(),ctx=await b.newContext({viewport:{width:1280,height:800}}),page=await ctx.newPage();
  await page.goto(url);await page.waitForFunction(()=>window.FVPanel&&FVPanel.perf.n>0);
  const out=await page.evaluate(()=>{
    FVPanel.dial({shellMode:'factorial',n1:'4',phi3:'6',alpha:'-1/50',n6:'1',t1:'1',t2:'-21/4',m:'3'});FVPanel.apply(()=>FVCombCore.enterSpin(FVPanel.state,'-627/250'));
    const C=FVCombCore,N=FVCombNumeric,st=FVPanel.state,T=(f,n=20)=>{const t=performance.now();for(let i=0;i<n;i++)f();return +((performance.now()-t)/n).toFixed(2);};
    const res={},num=N.compute(st);
    res.exact_resolve=T(()=>C.resolve(st));res.exact_readouts=T(()=>C.readouts(st));res.exact_stopSet=T(()=>C.stopSet(st));
    res.numeric_compute=T(()=>N.compute(st));res.numeric_orbits=T(()=>N.orbits(st,num),5);
    res.meshLeaf=T(()=>N.torusMesh(0.7,0.7,64,32),5);
    res.fieldOrbit=T(()=>FVOrbit.field(st));res.branches=T(()=>FVOrbit.branches(st));
    res.divisors=T(()=>FVShell.divisorsReport(C.resolve(st).t2,FVExact.parse(st.sTyped),C.resolve(st).B+1n));
    const orb=N.orbits(st,num);res.orbitPoints=orb.map(o=>o.s3.length);res.partial=orb.map(o=>!!o.partial);
    res.perf={};
    for(const t of ['clifford','fourier','hopf','panels']){FVPanel.dial({tab:t});const acc={model:0,view:0,caption:0,cards:0,controls:0,total:0};
      for(let i=0;i<10;i++){FVPanel.onAct(i%2?'phidn':'phiup');for(const k in acc)acc[k]+=FVPanel.perf[k]/10;}
      const svg=document.getElementById('stage');
      res.perf[t]={...Object.fromEntries(Object.entries(acc).map(([k,v])=>[k,+v.toFixed(2)])),svgElements:svg.querySelectorAll('*').length,pathChars:[...svg.querySelectorAll('path,polyline')].reduce((a,e)=>a+(e.getAttribute('d')||e.getAttribute('points')||'').length,0),
        pathPoints:[...svg.querySelectorAll('polyline')].reduce((a,e)=>a+(e.getAttribute('points')||'').split(' ').length,0)+[...svg.querySelectorAll('path')].reduce((a,e)=>a+((e.getAttribute('d')||'').match(/M/g)||[]).length*2,0),domNodes:document.getElementsByTagName('*').length};}
    FVPanel.dial({tab:'clifford'});res.caption=[...document.querySelectorAll('#caption p')].map(p=>p.textContent);
    return res;});
  console.log(JSON.stringify(out,null,1));await b.close();
})();
