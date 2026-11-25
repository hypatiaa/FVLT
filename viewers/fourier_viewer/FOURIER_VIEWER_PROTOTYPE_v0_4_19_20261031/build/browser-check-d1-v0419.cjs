'use strict';
// v0.4.19 browser check of the D1 event-step pieces (SCHEMA_ADDENDUM_26, item 2; verify finding 4 of v0.4.18), at 1280x800 and 375x812.
// For Rule 30 rows j = 26, 30, 34 at q = 1 and q = 2, and the control j = 3 (q = 1, 2): the curve's data attributes say that every event step has at least
// 16 pieces (32 at q = 1), that the fibre (and the base) is strictly forward along every piece of every event step, and that the end point is unchanged:
// equal to the core's closing point and to the v0.4.18 page's (opened read only, sha256 pinned) for the same state. The expected numbers come from the
// D1 core in Node (rule30-ladder-core.js) with this file's own piece rule; the exact fibre values of the first and last event steps (printed by the page)
// are checked here one by one: (N_j(t) e + i)/(q e), i = 0 ... e, by BigInt cross-multiplication. The control row keeps every v0.4.18 attribute.
// Also: the q = 1 caption ("full forward fibre loop") is present, amber (event) ink is drawn, and v0.4.18 drew less of it at j = 30, q = 1.
// No floating point: counts are integers; BigInt for the rational comparisons.
const path=require('path'),fs=require('fs'),crypto=require('crypto'),{pathToFileURL}=require('url');
const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
const CC=require('../host-core/comb-core.js'),RL=require('../host-core/rule30-ladder-core.js');
const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href;
const OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/dist/comb-hopf.html',OLDSHA='0ccc87aef5612d572bdf4459eeeb5b00014b3b63b3c90dd66548a5f1225968e8';
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=o=>CC.encodeAddress(CC.initial(o));
const view=(r,j,q)=>['rl=1',r!==30?'rlr='+r:'',j!==3?'rlj='+j:'',q!==2?'rlq='+q:''].filter(Boolean).join(';');
const gopen=async(pg,base,hash)=>{await pg.goto('about:blank');await pg.goto(base+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0,null,{timeout:120000});await pg.waitForTimeout(400);};
const d1=pg=>pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="r30-curve"]'),at=g?Object.fromEntries([...g.attributes].map(a=>[a.name,a.value])):null;
  const cv=document.getElementById('stagecv'),im=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let amber=0;
  for(let i=0;i<im.length;i+=4){const r=im[i],g2=im[i+1],b=im[i+2];if(r>200&&g2>120&&g2<190&&b<60)amber++;}
  return {at,amber,caps:[...document.querySelectorAll('#caption p')].map(e=>e.textContent),hscroll:document.documentElement.scrollWidth>document.documentElement.clientWidth};});
// the expected pieces, from the core and this file's own rule
const subOf=p=>p>=720?1n:(720n+BigInt(p)-1n)/BigInt(p);
function expect(r,j,q){
  const sub=subOf(RL.perN(r,j)),cu=RL.curve(r,j,q,{sub}),need=q===1?32n:16n;let e=sub;while(e<need)e+=sub;
  let ev=0;for(let t=0;t<cu.steps;t++)if(RL.psi(r,j,t))ev++;
  const n=BigInt(cu.steps-ev)*sub+BigInt(ev)*(sub>=need?sub:e)+1n,last=cu.points[cu.points.length-1];
  return {sub,cu,need,e:sub>=need?sub:e,ev,n,endBase:last.base.join('/'),endFibre:last.fibre.join('/')};
}
// "t:f0,f1,...,fe" -> check f_i = (N_j(t) e + i)/(q e) exactly, strictly increasing
function checkStep(r,j,q,e,attr){
  if(!attr)return {ok:false,why:'missing'};const [ts,list]=attr.split(':'),t=BigInt(ts),fs=list.split(',').map(x=>x.split('/').map(BigInt));
  const n0=BigInt(RL.N(r,j,t)),Q=BigInt(q);if(BigInt(fs.length)!==e+1n)return {ok:false,why:'length '+fs.length};
  for(let i=0;i<fs.length;i++){const [a,b]=fs[i];if(a*Q*e!==(n0*e+BigInt(i))*b)return {ok:false,why:'value '+i};if(i>0){const [c,d]=fs[i-1];if(!(c*b<a*d))return {ok:false,why:'not forward at '+i};}}
  if(RL.psi(r,j,t)!==1)return {ok:false,why:'t is not an event'};
  return {ok:true,t,n0};
}
(async()=>{
  const old=fs.readFileSync(OLD),oldSha=crypto.createHash('sha256').update(old).digest('hex');
  ok('the v0.4.18 page (read only) has its pinned sha256 '+OLDSHA.slice(0,16)+'…',oldSha===OLDSHA,oldSha);
  const urlOld=pathToFileURL(OLD).href,browser=await PW.chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    for(const [j,q] of [[26,1],[26,2],[30,1],[30,2],[34,1],[34,2],[3,1],[3,2]]){
      const r=30,x=expect(r,j,q),nm=tag+' rule 30 j = '+j+' q = '+q+(j===3?' (control)':'');
      const t0=Date.now();await gopen(pg,url,addr({tab:'clifford',view:view(r,j,q)}));const ms=Date.now()-t0;const s=await d1(pg);
      await gopen(pg,urlOld,addr({tab:'clifford',view:view(r,j,q)}));const o=await d1(pg);
      const a=s.at||{},b=o.at||{};
      ok(nm+': per '+x.cu.per+', steps '+x.cu.steps+', base sub '+x.sub+', event steps '+x.ev+'; every event step has '+x.e+' pieces (need ≥ '+x.need+'): min = max = '+a['data-event-pieces-min'],
        a['data-sub']===String(x.sub)&&a['data-steps']===String(x.cu.steps)&&a['data-event-steps']===String(x.ev)&&a['data-event-pieces-min']===String(x.e)&&a['data-event-pieces-max']===String(x.e)&&BigInt(a['data-event-pieces-min']||'0')>=x.need&&a['data-event-need']===String(x.need),JSON.stringify(a));
      ok(nm+': the fibre is strictly forward along every piece of all '+x.ev+' event steps (and the base too); none backward',a['data-event-forward']===String(x.ev)&&a['data-event-not-forward']==='0'&&a['data-event-base-forward']===String(x.ev));
      ok(nm+': points n = (steps − events)·sub + events·e + 1 = '+x.n,a['data-n']===String(x.n),a['data-n']);
      for(const which of ['first','last']){const c=checkStep(r,j,q,x.e,a['data-event-'+which]);
        ok(nm+': the '+which+' event step'+(c.ok?' (t = '+c.t+', N_j(t) = '+c.n0+')':'')+': '+x.e+' pieces with exact fibre values (N_j(t)·e + i)/(q·e), strictly increasing, from N_j(t)/q to (N_j(t) + 1)/q',c.ok,c.why);}
      ok(nm+': end point unchanged: base '+x.endBase+', fibre '+x.endFibre+' = the core’s = the v0.4.18 page’s',a['data-end-base']===x.endBase&&a['data-end-fibre']===x.endFibre&&b['data-end-base']===x.endBase&&b['data-end-fibre']===x.endFibre,JSON.stringify([a['data-end-base'],a['data-end-fibre'],b['data-end-base'],b['data-end-fibre']]));
      ok(nm+': per, S, k, steps and sub equal v0.4.18’s',['data-per','data-s','data-k','data-steps','data-sub','data-rule','data-j','data-q'].every(k=>a[k]===b[k]));
      if(j===3)ok(nm+': control row (sub = '+x.sub+' ≥ '+x.need+'): every v0.4.18 attribute unchanged (n, event and base segments included)',Object.keys(b).every(k=>a[k]===b[k]),JSON.stringify(Object.keys(b).filter(k=>a[k]!==b[k])));
      else ok(nm+': v0.4.18 drew each event step as '+b['data-sub']+' chord(s) ('+b['data-event-segments']+' event segments); v0.4.19 draws '+a['data-event-segments']+' event pieces',b['data-event-segments']===String(x.ev)&&a['data-event-segments']===String(BigInt(x.ev)*x.e));
      if(q===1)ok(nm+': the q = 1 caption states the full forward fibre loop',s.caps.some(c=>/full forward fibre loop/.test(c)),s.caps.join(' | '));
      ok(nm+': amber (event) ink drawn: '+s.amber+' px (v0.4.18: '+o.amber+' px)',s.amber>0&&(j===3?s.amber===o.amber||s.amber>0:true));
      if(j===30&&q===1)ok(nm+': more event ink than v0.4.18 (whose event steps had zero length at q = 1)',s.amber>o.amber,s.amber+' vs '+o.amber);
      ok(nm+': no horizontal page scroll',!s.hscroll);
      console.log('TIMING '+nm+': page load to first render '+ms+' ms');}
    ok(tag+' no page errors and no console errors',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();}
  await browser.close();
  console.log('SUMMARY browser-check-d1-v0419: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
})().catch(e=>{console.error(e);process.exit(1);});
