'use strict';
// v0.4.6 browser check (SCHEMA_ADDENDUM_14): n1 group hidden in integer mode; counts; addresses identical to v0.4.5.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url45=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const addr=o=>CC.encodeAddress(CC.initial(o));
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(350);};
const grpVis=pg=>pg.evaluate(()=>{const g=document.getElementById('n1grp');return g.getBoundingClientRect().width>0&&getComputedStyle(g).display!=='none';});
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    for(const tab of ['fourier','clifford','hopf']){
      await gopen(pg,addr({shellMode:'integer',B:'24',tab}));const ni=await count(pg);
      await gopen(pg,addr({shellMode:'factorial',n1:'4',tab}));const nf=await count(pg);
      await gopen(pg,addr({shellMode:'integer',B:'5040',tab})+'&ca=1');const nc=await count(pg);
      await gopen(pg,addr({shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab}));const nn=await count(pg);
      console.log('COUNT '+tag+' '+tab+' integer '+ni+' n! '+nf+' CA '+nc+' continuous '+nn);
      ok(tag+' '+tab+': integer 39 (<=41), n! 41, CA 39, continuous 41',ni===39&&nf===41&&nc===39&&nn===41,[ni,nf,nc,nn].join('/'));
    }
    await gopen(pg,addr({shellMode:'factorial',n1:'6',tab:'fourier'}));
    const a=await grpVis(pg);await pg.click('#mode_i');await pg.waitForTimeout(400);const b=await grpVis(pg);
    const hi=await pg.evaluate(()=>location.hash),n1i=await pg.evaluate(()=>FVPanel.state.n1);
    await pg.click('#mode_f');await pg.waitForTimeout(400);const c=await grpVis(pg),v=await pg.evaluate(()=>({n1:document.getElementById('n1_sel').value,st:FVPanel.state.n1,dis:document.getElementById('n1_sel').disabled}));
    ok(tag+' n! shows group, integer hides it, back to n! shows it again with n1 = 6, enabled',a&&!b&&c&&v.n1==='6'&&v.st==='6'&&!v.dis,JSON.stringify([a,b,c,v]));
    ok(tag+' n1 stays in the state and the integer-mode address',n1i==='6'&&hi.includes(addr({shellMode:'integer',n1:'6',B:'720',tab:'fourier'}).split('&').find(p=>/^n1=/.test(p))),hi);
    await gopen(pg,addr({shellMode:'integer',B:'5040',tab:'fourier'})+'&ca=1');const g1=await grpVis(pg);await pg.click('#mode_i');await pg.waitForTimeout(400);const g2=await grpVis(pg);
    ok(tag+' CA hides group; CA -> integer keeps it hidden',!g1&&!g2);
    const S=[{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'integer',B:'55440',tab:'panels'},{shellMode:'integer',B:'720720',tab:'panels'}];
    let same=0;const bad=[];
    for(const s of S){const hh=addr(s)+(s.B==='55440'?'&ca=1':''),pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url45);await gopen(pb,hh);
      await pa.evaluate(()=>FVPanel.dial({view:''}));await pb.evaluate(()=>FVPanel.dial({view:''}));await pa.waitForTimeout(500);
      const rd=p=>p.evaluate(()=>({a:document.getElementById('addr').textContent,h:location.hash,st:JSON.stringify(FVPanel.state)}));
      const x=await rd(pa),y=await rd(pb);if(x.a===y.a&&x.h===y.h&&x.st===y.st)same++;else bad.push(hh);await pa.close();await pb.close();}
    ok(tag+' address line, URL and state identical to v0.4.5 ('+same+'/'+S.length+')',same===S.length,bad.join(' '));
    await gopen(pg,addr({shellMode:'integer',B:'24',tab:'fourier'}));await pg.evaluate(()=>window.scrollTo(0,0));await pg.waitForTimeout(200);
    await pg.screenshot({path:path.join(root,'shot_v046_'+tag+'_integer_row.png')});
    await gopen(pg,addr({shellMode:'factorial',n1:'4',tab:'fourier'}));await pg.screenshot({path:path.join(root,'shot_v046_'+tag+'_nfact_row.png')});
    ok(tag+' no page errors',errs.length===0,errs.join(' | '));
    await ctx.close();
  }
  await browser.close();console.log(pass+' passed, '+fail+' failed');process.exit(fail?1:0);
})();
