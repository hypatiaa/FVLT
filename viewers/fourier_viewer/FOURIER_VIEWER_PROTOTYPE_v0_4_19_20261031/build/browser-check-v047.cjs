'use strict';
// v0.4.7 browser check (SCHEMA_ADDENDUM_15): alpha_Tilt as a walk weight. Design note section 9, tests 1 (browser part), 6, 7, 8, 10, 11, and the shots.
const path=require('path');
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright');
const root=path.join(__dirname,'..'),u=p=>'file:///'+p.split(path.sep).join('/');
const url=u(path.join(root,'dist','comb-hopf.html')),url46=u('C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020/dist/comb-hopf.html');
const CC=require('../host-core/comb-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x&&!c?' '+x:''));c?pass++:fail++;};
const addr=(o,tilt)=>CC.encodeAddress(CC.initial(o))+(tilt?'&tilt='+tilt:'');
const count=pg=>pg.evaluate(()=>{const vis=e=>{const r=e.getBoundingClientRect(),cs=getComputedStyle(e);return r.width>0&&r.height>0&&cs.display!=='none'&&cs.visibility!=='hidden'&&!e.closest('[style*="display: none"]')&&!e.closest('[hidden]');};
  return [...document.querySelectorAll('button,input,select')].filter(vis).filter(e=>e.closest('#inst')||e.closest('.header')).filter(e=>!e.classList.contains('info')).length;});
const gopen=async(pg,hash,base)=>{await pg.goto((base||url)+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(350);};
const snap=pg=>pg.evaluate(()=>({stage:document.getElementById('stage').innerHTML,cv:(()=>{try{return document.getElementById('stagecv').toDataURL();}catch(e){return '';}})(),caption:document.getElementById('caption').innerHTML,about:document.getElementById('about').innerHTML,cards:document.getElementById('cards').innerHTML,addr:document.getElementById('addr').textContent,hash:location.hash,st:JSON.stringify(FVPanel.state)}));
const capText=pg=>pg.evaluate(()=>document.getElementById('caption').innerText);
(async()=>{
  const browser=await chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    // ---- 10. cap: counts with drawers closed, with and without a tilt
    for(const tab of ['fourier','clifford','hopf']){
      const r=[];for(const [o,x] of [[{shellMode:'integer',B:'24',tab},''],[{shellMode:'factorial',n1:'4',tab},''],[{shellMode:'integer',B:'5040',tab},'&ca=1'],[{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab},'']]){
        await gopen(pg,addr(o)+x);r.push(await count(pg));await gopen(pg,addr(o,'-1/2')+x);r.push(await count(pg));}
      ok(tag+' '+tab+': counts 39/41/39/41 unchanged, also with tilt in the address',r[0]===39&&r[1]===39&&r[2]===41&&r[3]===41&&r[4]===39&&r[5]===39&&r[6]===41&&r[7]===41,r.join('/'));
    }
    // ---- 1 (browser). at tilt 0 the page is identical to v0.4.6: stage, canvas, caption, about, cards, address, hash, state
    const S=[{shellMode:'factorial',n1:'4',phi3:'6',m:'3',tab:'fourier'},{shellMode:'factorial',n1:'7',phi3:'1',m:'8',tab:'panels'},{shellMode:'integer',B:'24',phi3:'20',m:'5',t1:'1',t2:'2',tab:'hopf'},
      {shellMode:'integer',n1:'5',B:'5040',phi3:'5000',m:'7',t1:'1/2',tab:'clifford'},{shellMode:'factorial',n1:'4',nMode:'continuous',phi3:'7/2',m:'5',tab:'fourier'},{shellMode:'integer',B:'55440',tab:'panels'},
      {shellMode:'factorial',n1:'6',phi3:'719',m:'7',t1:'1',t2:'1',sTyped:'1',tab:'fourier'},{shellMode:'factorial',n1:'6',phi3:'700',m:'7',tab:'hopf'}];
    let same=0;const bad=[];
    for(const s of S){const hh=addr(s)+(s.B==='55440'?'&ca=1':''),pa=await ctx.newPage(),pb=await ctx.newPage();await gopen(pa,hh,url46);await gopen(pb,hh);
      await pa.waitForTimeout(400);const x=await snap(pa),y=await snap(pb);const diff=Object.keys(x).filter(k=>x[k]!==y[k]);
      if(!diff.length)same++;else bad.push(hh+' differs in '+diff.join(','));await pa.close();await pb.close();}
    ok(tag+' tilt 0: stage, canvas, caption, about, cards, address, URL, state identical to v0.4.6 ('+same+'/'+S.length+')',same===S.length,bad.join(' | '));
    // ---- 10/11. the alpha drawer: two separately labelled dials
    await gopen(pg,addr({shellMode:'factorial',n1:'6',phi3:'719',m:'7',tab:'fourier'}));
    await pg.click('#lab_alpha');await pg.waitForTimeout(300);
    const dr=await pg.evaluate(()=>({labs:[...document.querySelectorAll('#drawer .lab')].map(e=>e.textContent),hasTx:!!document.getElementById('tilt_tx'),hasA:!!document.getElementById('alpha_tx'),hasSl:!!document.getElementById('tilt_sl'),presets:[...document.querySelectorAll('#drawer [data-act=tiltp]')].map(e=>e.textContent)}));
    ok(tag+' the α drawer holds two separately labelled dials (α, α_Tilt) with presets',dr.hasA&&dr.hasTx&&dr.hasSl&&dr.labs.length===2&&/α_Tilt/.test(dr.labs[1])&&dr.labs[0]==='α'&&dr.presets.length===3,JSON.stringify(dr));
    ok(tag+' drawer open: tilt box shows 0',await pg.inputValue('#tilt_tx')==='0');
    // slider 0.37 -> 37/100 (exact)
    await pg.evaluate(()=>{const s=document.getElementById('tilt_sl');s.value='0.37';s.dispatchEvent(new Event('input',{bubbles:true}));s.dispatchEvent(new Event('change',{bubbles:true}));});await pg.waitForTimeout(500);
    const t37=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,hash:location.hash,chip:document.getElementById('lab_alpha').textContent,box:document.getElementById('tilt_tx').value}));
    ok(tag+' slider 0.37 stored as 37/100, address has tilt=37/100, chip shows it, box shows it',t37.tilt==='37/100'&&/&tilt=37\/100$/.test(t37.hash)&&/tilt 37\/100/.test(t37.chip)&&t37.box==='37/100',JSON.stringify(t37));
    // typed box, step buttons, preset
    await pg.fill('#tilt_tx','-1/2');await pg.press('#tilt_tx','Enter');await pg.waitForTimeout(400);
    let hs=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,hash:location.hash,chip:document.getElementById('lab_alpha').textContent}));
    ok(tag+' typed -1/2: state, address (tilt after view) and chip',hs.tilt==='-1/2'&&/view=&tilt=-1\/2$/.test(hs.hash)&&/α 1 · tilt -1\/2/.test(hs.chip),JSON.stringify(hs));
    await pg.click('[data-act=tiltup]');await pg.waitForTimeout(300);ok(tag+' ▶ steps by 1/10 (-1/2 -> -2/5)',await pg.evaluate(()=>FVPanel.state.tilt)==='-2/5');
    await pg.click('[data-act=tiltp][data-v="1"]');await pg.waitForTimeout(300);await pg.click('[data-act=tiltup]');await pg.waitForTimeout(300);ok(tag+' ▶ stops at +1 (clamped)',await pg.evaluate(()=>FVPanel.state.tilt)==='1');
    await pg.fill('#tilt_tx','3');await pg.press('#tilt_tx','Enter');await pg.waitForTimeout(400);
    const rj=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,msg:document.getElementById('msg').textContent}));ok(tag+' out-of-range 3 refused with the reason, state unchanged',rj.tilt==='1'&&/between −1 and 1/.test(rj.msg),JSON.stringify(rj));
    await pg.click('[data-act=tiltp][data-v="0"]');await pg.waitForTimeout(300);
    const z0=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,hash:location.hash}));ok(tag+' preset 0 removes tilt from the state and the address',z0.tilt===undefined&&!/tilt/.test(z0.hash),JSON.stringify(z0));
    // ---- 8. address round trip through the URL, both orders with ca
    await gopen(pg,addr({shellMode:'integer',B:'5040',m:'5',tab:'fourier'},'-1/2')+'&ca=1');
    const r1=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,ca:document.getElementById('mode_ca').getAttribute('aria-pressed'),hash:location.hash}));
    ok(tag+' tilt + &ca=1 read: tilt kept, CA on, hash writes tilt before &ca=1',r1.tilt==='-1/2'&&r1.ca==='true'&&/&tilt=-1\/2&ca=1$/.test(r1.hash),JSON.stringify(r1));
    const base=addr({shellMode:'integer',B:'5040',m:'5',tab:'fourier'});
    await gopen(pg,base+'&ca=1&tilt=-1/2');const r2=await pg.evaluate(()=>({tilt:FVPanel.state.tilt,ca:document.getElementById('mode_ca').getAttribute('aria-pressed')}));
    ok(tag+' &ca=1 before &tilt= reads the same',r2.tilt==='-1/2'&&r2.ca==='true',JSON.stringify(r2));
    const pz=await ctx.newPage();await gopen(pz,base+'&tilt=0');const r3=await pz.evaluate(()=>({tilt:FVPanel.state.tilt,banner:document.body.innerText.includes('tilt = 0 is not written')}));await pz.close();
    ok(tag+' &tilt=0 refused with the reason (defaults shown)',r3.tilt===undefined&&r3.banner,JSON.stringify(r3));
    // ---- 6. meaning changes on the Fourier tab
    const star={shellMode:'factorial',n1:'6',phi3:'719',m:'6',t1:'1',t2:'1',sTyped:'1',tab:'fourier'};   // N = 2, t1*s = 1
    await gopen(pg,addr(star));let c0=await capText(pg);await gopen(pg,addr(star,'1'));let c1=await capText(pg);
    const qres=await pg.evaluate(()=>{const t=document.getElementById('caption').innerText.match(/Q-res ([0-9.e+-]+)/);return t?Number(t[1]):null;});
    ok(tag+' t1*s in Z: tilt 0 caption "★ lab sum real"; tilt 1 caption "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general"',/★ lab sum real/.test(c0)&&/★ pair phases conjugate \(t₁·s ∈ ℤ\); tilted walk not real in general/.test(c1)&&!/lab sum real/.test(c1),c0+' || '+c1);
    const qb=await pg.evaluate(()=>({q:FVPanel.model?null:null}));
    const cx={shellMode:'factorial',n1:'4',phi3:'20',m:'6',t1:'1/2',t2:'1',sTyped:'1',tab:'fourier'};
    await gopen(pg,addr(cx,'1'));const c2=await capText(pg);ok(tag+' v0.4.1 counterexample (N=5, m=6, t1=1/2, t2=1, s=1) still shows no ★ at tilt 1',!/★/.test(c2),c2);
    await gopen(pg,addr({shellMode:'factorial',n1:'6',phi3:'719',m:'2',tab:'fourier'},'1'));const c3=await capText(pg);
    ok(tag+' m = 2 and tilt != 0: the Vernier-sum label appears',/m = 2, α_Tilt ≠ 0: W₂ = z₋₁ \+ 2\^α_Tilt·z₊₁ is not the Vernier sum/.test(c3),c3);
    await gopen(pg,addr({shellMode:'factorial',n1:'6',phi3:'719',m:'2',tab:'fourier'}));ok(tag+' m = 2 at tilt 0: no such label',!/Vernier sum/.test(await capText(pg)));
    // mirror caption (about) and the cards rows
    await gopen(pg,addr(star,'1'));await pg.evaluate(()=>{});
    const ab=await pg.evaluate(()=>FVViews.abouts?FVViews.abouts().join('\n'):'');
    ok(tag+' mirror-axis about gains "teeth only; the tilted walk is not mirror-symmetric" at tilt != 0 and the instrument-tier statement',/teeth only; the tilted walk is not mirror-symmetric/.test(ab)&&/no theorem standing/.test(ab)&&/v3\.2\.7/.test(ab),ab.slice(0,200));
    await gopen(pg,addr(star));const ab0=await pg.evaluate(()=>FVViews.abouts().join('\n'));ok(tag+' at tilt 0 those sentences are absent',!/teeth only|α_Tilt/.test(ab0));
    // ---- 7. Clifford and G. Robin unaffected
    const clf={shellMode:'factorial',n1:'6',phi3:'700',m:'7',t1:'1',t2:'1',sTyped:'1',tab:'clifford'};
    await gopen(pg,addr(clf));const k0=await snap(pg);await gopen(pg,addr(clf,'1'));const k1=await snap(pg);
    const abk=await pg.evaluate(()=>FVViews.abouts().join('\n'));
    ok(tag+' Clifford: stage SVG, canvas and caption identical at tilt 0 and 1; one ⓘ line says α_Tilt does not apply',k0.stage===k1.stage&&k0.cv===k1.cv&&k0.caption===k1.caption&&/α_Tilt does not apply here/.test(abk),['stage','cv','caption'].filter(k=>k0[k]!==k1[k]).join(','));
    if(!(await pg.evaluate(()=>!!document.getElementById('tilt_tx'))))await pg.click('#lab_alpha');await pg.waitForTimeout(300);ok(tag+' Clifford: the visible α_Tilt dial says "α_Tilt does not apply here"',await pg.evaluate(()=>/α_Tilt does not apply here/.test(document.getElementById('drawer').innerText)));
    const pn={shellMode:'integer',B:'5040',phi3:'5000',m:'7',tab:'panels'};
    const robin=async(h)=>{await gopen(pg,h+'&ca=1');return pg.evaluate(()=>{const h=document.getElementById('htmlstage');return /G\. Robin/.test(h.innerText)?h.innerHTML:null;});};
    const g0=await robin(addr(pn)),g1=await robin(addr(pn,'1'));ok(tag+' G. Robin card present and identical at tilt 0 and 1',g0&&g0===g1);
    // panels cards that change
    await gopen(pg,addr({...pn,B:'24',phi3:'20',m:'5',sTyped:'1'},'1'));const ct=await pg.evaluate(()=>document.getElementById('cards').innerText);
    ok(tag+' Panels at tilt 1: α_Tilt row, ★ wording and carrier-relative caption changed',/α_Tilt \(walk weight t\^α_Tilt\)/.test(ct)&&/pair phases conjugate/.test(ct)&&/teeth only; the tilted walk is not mirror-symmetric/.test(ct),ct.slice(0,300));
    // copy formula
    await gopen(pg,addr({shellMode:'factorial',n1:'6',phi3:'719',m:'7',tab:'fourier'},'-1/2'));await pg.click('#expBtn');await pg.waitForTimeout(200);
    await pg.click('[data-act=xformula]');await pg.waitForTimeout(300);const fm=await pg.inputValue('#xout');ok(tag+' Copy formula appends the walk line only at tilt != 0',/W_t = sum_\{j<=t\} j\^tilt \* z_\{c_j\} \(walk order\), tilt = -1\/2/.test(fm));
    await pg.click('[data-act=xjson]');await pg.waitForTimeout(300);const xj=JSON.parse(await pg.inputValue('#xout'));ok(tag+' exact JSON carries state.tilt and exact.tilt (numerical weights for -1/2)',xj.state.tilt==='-1/2'&&xj.exact.tilt.register==='numerical'&&/radicals/.test(xj.exact.cyclotomic_field.note));
    // ---- Hopf: walk changes, teeth do not
    const hp={shellMode:'factorial',n1:'6',phi3:'719',m:'7',t1:'1',t2:'1',sTyped:'1/3',tab:'hopf'};
    await gopen(pg,addr(hp));const h0=await pg.evaluate(()=>({dots:[...document.querySelectorAll('#stage [data-role=tooth-dot]')].map(e=>e.getAttribute('cx')+','+e.getAttribute('cy')).join(';'),verts:[...document.querySelectorAll('#stage [data-role=vertex]')].map(e=>e.getAttribute('cx')+','+e.getAttribute('cy')).join(';')}));
    await gopen(pg,addr(hp,'1'));const h1=await pg.evaluate(()=>({dots:[...document.querySelectorAll('#stage [data-role=tooth-dot]')].map(e=>e.getAttribute('cx')+','+e.getAttribute('cy')).join(';'),verts:[...document.querySelectorAll('#stage [data-role=vertex]')].map(e=>e.getAttribute('cx')+','+e.getAttribute('cy')).join(';'),cap:document.getElementById('caption').innerText}));
    ok(tag+' Hopf: tooth dots identical, walk vertices change at tilt 1; gate line still passes',h0.dots===h1.dots&&h0.verts!==h1.verts&&!/FAILED/.test(h1.cap)&&/α_Tilt = 1/.test(h1.cap),h1.cap);
    // ---- 9. degenerate N = 0 at a tilt
    await gopen(pg,addr({shellMode:'factorial',n1:'3',phi3:'7',m:'7',tab:'fourier'},'-1'));ok(tag+' N = 0 at tilt -1: the empty state is drawn and labelled',await pg.evaluate(()=>/N = 0: the Fourier comb has no angular denominator/.test(document.getElementById('stage').textContent+document.getElementById('caption').innerText+FVViews.abouts().join(' '))));
    ok(tag+' no page errors',errs.length===0,errs.join(' | '));
    await ctx.close();
  }
  await browser.close();console.log('browser-check-v047: '+pass+' passed, '+fail+' failed');process.exit(fail?1:0);
})();
