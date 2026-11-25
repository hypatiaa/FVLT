'use strict';
// v0.4.18 browser check (SCHEMA_ADDENDUM_25): group E "Surface pens (exact)" of the Panels tab, the "see also" links with D1, and the v0.4.17 fix-ups,
// at 1280x800 and 375x812. Expected values come from the cores run here in Node (themselves checked by test-pen-*). Portable: playwright through
// NODE_PATH (or PLAYWRIGHT_DIR), with Neo's path as the fallback. No floating point: counts are integers, times integer milliseconds from Date.now.
const path=require('path'),fs=require('fs'),{pathToFileURL}=require('url');
const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
const CC=require('../host-core/comb-core.js'),ST=require('../host-core/pen-streams-core.js'),CV=require('../host-core/pen-curvature-core.js'),SP=require('../host-core/pen-sphere-core.js'),EX=require('../host-core/elliptic-exact-core.js');
const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const timing=[];
const addr=o=>CC.encodeAddress(CC.initial(o));
const gopen=async(pg,hash)=>{await pg.goto('about:blank');await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);};
const IDS=['pen-curvature-exact','pen-sphere-exact'];
const openPens=pg=>pg.evaluate(ids=>{for(const id of ids){const d=document.querySelector('details[data-panel="'+id+'"]');if(d&&!d.open)d.open=true;}},IDS);
const setDial=(pg,role,v,ev)=>pg.evaluate(([r,v,ev])=>{const xs=[...document.querySelectorAll('[data-role="'+r+'"]')];if(!xs.length)return false;const x=xs[0];if(x.type==='checkbox')x.checked=v==='1';else x.value=v;x.dispatchEvent(new Event(ev,{bubbles:true}));return true;},[role,String(v),ev||'change']);
const txt=(pg,sel)=>pg.evaluate(s=>[...document.querySelectorAll(s)].map(e=>e.textContent),sel);
const ds=(pg,role)=>pg.evaluate(r=>{const e=document.querySelector('[data-role="'+r+'"]');return e?{...e.dataset}:null;},role);
const hscroll=pg=>pg.evaluate(()=>document.documentElement.scrollWidth>document.documentElement.clientWidth);
const ink=(pg,role)=>pg.evaluate(r=>{const cv=document.querySelector('[data-role="'+r+'"]');if(!cv)return -1;const im=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let n=0;for(let i=0;i<im.length;i+=4)if(im[i]+im[i+1]+im[i+2]>300)n++;return n;},role);
const colorCount=(pg,role,rgb)=>pg.evaluate(([r,c])=>{const cv=document.querySelector('[data-role="'+r+'"]');const im=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let n=0;for(let i=0;i<im.length;i+=4)if(im[i]===c[0]&&im[i+1]===c[1]&&im[i+2]===c[2])n++;return n;},[role,rgb]);
const waitPens=pg=>pg.waitForFunction(()=>!!document.querySelector('[data-role="pen-read-m1"] [data-role="pen-disk"]')&&!!document.querySelector('[data-role="pen-sph-read"]'),null,{timeout:120000});
// expected values from the cores
function expect(kind,o){const st=ST.stream(kind,o),len=st.len,dn=len<CV.DISK_T_CAP?len:CV.DISK_T_CAP,P=CV.planePen(st.s,len),ps=CV.planeStats(P),os=CV.octStats(CV.octPen(st.s,len));
  let d;if(dn<=CV.EXACT_T_MAX)d=CV.distanceExact(CV.diskExact(st.s,dn)[dn]);else{d=CV.distance(CV.diskIntervalRun(st.s,dn,CV.workingBits(dn),false).g);}
  return {st,len,dn,ps,os,d};}
(async()=>{
  const browser=await PW.chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>localStorage.clear());await gopen(pg,addr({tab:'panels'}));
    // ---- placement
    {const labels=await txt(pg,'#htmlstage .panel-label'),st=await pg.evaluate(()=>[...document.querySelectorAll('details.pmod')].map(d=>d.dataset.panel+':'+d.open));
      const ids=st.map(s=>s.split(':')[0]),i1=ids.indexOf(IDS[0]),i2=ids.indexOf(IDS[1]);
      ok(tag+' group headings: "D. Elliptic and BSD" (placement decided) and "E. Surface pens (exact)" last',labels.includes('D. Elliptic and BSD')&&labels[labels.length-1]==='E. Surface pens (exact)'&&!labels.some(l=>/placement pending/.test(l)),labels.join(' | '));
      ok(tag+' the two pen cards are the last two cards (group E), collapsed on a fresh page; the v0.4.17 group-D cards still close group D ('+ids.length+' cards)',i1===ids.length-2&&i2===ids.length-1&&st[i1].endsWith(':false')&&st[i2].endsWith(':false')&&ids[i1-1]==='period-lattice-exact',st.join(' '));
      ok(tag+' a collapsed pen card computes nothing ("Open the card to compute.")',await pg.evaluate(()=>/Open the card to compute/.test(document.querySelector('[data-body="pen-curvature-exact"]').textContent)));}
    await openPens(pg);await waitPens(pg);
    // ---- default: Rule 30, T = 512
    for(const [label,kind,o,set] of [['Rule 30 T = 512','30',{T:512},[]],['Rule 150 T = 4096','150',{T:4096},[['pen-stream','150'],['pen-T','4096']]],['coin seed 5 T = 304','coin',{T:304,seed:5n},[['pen-stream','coin'],['pen-T','304'],['pen-seed','5']]],
      ['Goldbach shell N = 1448','gbshell',{N:1448},[['pen-stream','gbshell'],['pen-N','1448']]],['Goldbach run N_max = 1448','gbrun',{Nmax:1448},[['pen-stream','gbrun'],['pen-Nmax','1448']]],['T = 0','30',{T:0},[['pen-stream','30'],['pen-T','0']]]]){
      const t0=Date.now();for(const [r,v] of set){await setDial(pg,r,v);await waitPens(pg);}const ms=Date.now()-t0;
      const e=expect(kind,{T:o.T||0,seed:o.seed||1n,N:o.N||24,Nmax:o.Nmax||100});
      const lat=(await txt(pg,'[data-role="pen-lat"]'))[0]||'',oct=(await txt(pg,'[data-role="pen-oct"]'))[0]||'',dtx=(await txt(pg,'[data-role="pen-d"]'))[0]||'',un=(await txt(pg,'[data-role="pen-uncert-m1"]'))[0];
      ok(tag+' '+label+': lattice readout = core ('+e.ps.points+' points, max |x| '+e.ps.maxX+', |y| '+e.ps.maxY+')',lat.startsWith('lattice points visited '+e.ps.points+' · max |x| '+e.ps.maxX+', |y| '+e.ps.maxY),lat);
      ok(tag+' '+label+': octahedron readout = core ('+e.os.flags+' flags of 24; group order 12, A₄)',oct.startsWith('flags reached '+e.os.flags+' of 24')&&/order 12 \(A₄, not S₄/.test(oct),oct);
      ok(tag+' '+label+': k = −1 distance d = core '+e.d.dText+' (drawn to T = '+e.dn+'), pixels not certified 0',dtx===e.d.dText&&un==='0',dtx+' / '+un);
      const caps=await txt(pg,'[data-role="pen-cap-m1"],[data-role="pen-cap-sph"]');
      if(e.len>4096)ok(tag+' '+label+': the caps are visible labels: "k = −1 drawn to T = 4096; the rest is not drawn" and the sphere likewise',caps.some(c=>c.startsWith('k = −1 drawn to T = 4096; the rest is not drawn'))&&caps.some(c=>c.startsWith('sphere drawn to T = 4096; the rest is not drawn')),caps.join(' | '));
      else ok(tag+' '+label+': no cap label (stream length '+e.len+' ≤ 4096)',caps.length===0,caps.join(' | '));
      if(kind==='150'&&o.T===4096)ok(tag+' Rule 150 T = 4096: the confinement line cites FVLTS4sRule150PenV1.pen_confined and shows 13 points',((await txt(pg,'[data-role="pen-r150"]'))[0]||'').includes('13 lattice points visited by T = 4096')&&((await txt(pg,'[data-role="pen-r150"]'))[0]||'').includes('FVLTS4sRule150PenV1.pen_confined'));
      if(kind==='gbshell'||kind==='gbrun'){const g=((await txt(pg,'[data-role="pen-gb-readout"]'))[0]||''),guard=((await txt(pg,'[data-role="pen-gb-guard"]'))[0]||''),bias=((await txt(pg,'[data-role="pen-gb-bias"]'))[0]||''),sd=await ds(pg,'pen-strip-0');
        const gb=e.st.gb;ok(tag+' '+label+': exact readouts (g = '+(gb.g!==undefined?gb.g:gb.gsum)+', + signs '+gb.plus+', relation holds) and both guards printed',g.includes('+ signs: '+gb.plus)&&g.includes('holds (exact)')&&guard.includes('The pen draws the prime-pair mask; it proves nothing about Goldbach.')&&guard.includes('Closure reaches conjugation, not Goldbach.')&&/Drawing-register observation only/.test(bias),g);
        ok(tag+' '+label+': strip carries '+e.st.bounds.length+' shell tick(s) and all '+e.len+' signs',sd&&sd.ticks===String(e.st.bounds.length)&&sd.len===String(e.len),JSON.stringify(sd));}
      if(o.T===0&&kind==='30')ok(tag+' T = 0: the label is drawn and the pens stay at the start (0 lattice steps)',((await txt(pg,'[data-role="pen-T0"]'))||[]).length===2&&lat.startsWith('lattice points visited 1 '),lat);
      ok(tag+' '+label+': ink on the three canvases and the sphere',(await ink(pg,'pen-cv-0'))>0&&(await ink(pg,'pen-cv-p1'))>0&&(await ink(pg,'pen-cv-m1'))>0&&(await ink(pg,'pen-cv-sph'))>0);
      ok(tag+' '+label+': no horizontal page scroll',!(await hscroll(pg)));
      timing.push('TIMING '+tag+' '+label+': both cards recomputed and drawn in '+ms+' ms (dial change to readouts)');
      const lt=(await txt(pg,'[data-role="pen-lat"]'))[0]||'',ot=(await txt(pg,'[data-role="pen-oct"]'))[0]||'',dr=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'',sr=(await txt(pg,'[data-role="pen-sph-read"]'))[0]||'';
      timing.push('TIMING '+tag+' '+label+': lattice '+((/· (\d+) ms/.exec(lt)||[])[1])+' ms, octahedron '+((/· (\d+) ms/.exec(ot)||[])[1])+' ms, disk '+((/compute (\d+) ms, draw (\d+) ms/.exec(dr)||[]).slice(1).join(' + '))+' ms, sphere '+((/compute (\d+) ms, draw (\d+) ms/.exec(sr)||[]).slice(1).join(' + '))+' ms');}
    // ---- k = -1: exact register for short runs, absolute view, T = 1024 and 4096 timings
    await setDial(pg,'pen-stream','30');await waitPens(pg);
    for(const T of [48,1024,4096]){await setDial(pg,'pen-T',T);await waitPens(pg);const r=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'';
      ok(tag+' k = −1, Rule 30, T = '+T+': register '+(T<=64?'exact over F[i]':'guaranteed intervals')+'; pixels not certified 0',(T<=64?/exact over F\[i\]/.test(r):/guaranteed intervals, block floating, P = \d+ bits/.test(r))&&/pixels not certified: 0 of/.test(r),r);
      timing.push('TIMING '+tag+' k = −1 T = '+T+': '+((/compute (\d+) ms, draw (\d+) ms/.exec(r)||[]).slice(1).join(' ms compute + '))+' ms draw ('+((/P = (\d+) bits/.exec(r)||[])[1]||'exact')+')');}
    await setDial(pg,'pen-follow','0');await waitPens(pg);{const r=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'';ok(tag+' follow off, T = 4096: absolute view from the start, pixels not certified 0',/absolute view from the start/.test(r)&&/pixels not certified: 0 of/.test(r),r);timing.push('TIMING '+tag+' k = −1 T = 4096 absolute view: '+((/compute (\d+) ms, draw (\d+) ms/.exec(r)||[]).slice(1).join(' ms compute + '))+' ms draw');}
    await setDial(pg,'pen-follow','1');await waitPens(pg);
    // ---- the sphere card
    await setDial(pg,'pen-T','1328');await waitPens(pg);
    {const s=ST.caRun(30,1328),r=SP.penBall(s.s,1328,[3n,96n],[2n,24n]),P=r.P,cov=SP.coverage(r.pts,P);let teeth=0;for(const v of s.tooth)teeth+=v;
      const t=(await txt(pg,'[data-role="pen-sph-read"]'))[0]||'';
      ok(tag+' sphere, Rule 30, T = 1328, α = 3/96, θ = 2/24: coverage '+cov.cells+'/432 and uncertain '+cov.uncertain+' = core; tooth events '+teeth+'; pixels not certified 0',t.includes('coverage '+cov.cells+'/432 cells')&&t.includes('uncertain cells: '+cov.uncertain)&&t.includes('tooth events (q = r = 1): '+teeth)&&/pixels not certified: 0 of/.test(t),t);
      timing.push('TIMING '+tag+' sphere T = 1328: '+((/compute (\d+) ms, draw (\d+) ms/.exec(t)||[]).slice(1).join(' ms compute + '))+' ms draw (ball register, P = '+P+' bits)');}
    await setDial(pg,'pen-preset','dodeca');await waitPens(pg);
    {const t=(await txt(pg,'[data-role="pen-sph-read"]'))[0]||'',d=(await txt(pg,'[data-role="pen-dodeca"]'))[0]||'';
      ok(tag+' sphere dodecahedron preset (exact in ℚ(√3, √5)): coverage 20/432, uncertain 0, the exact statement shown (five lefts close a face; 60 flags, 20 vertices; order 60, A₅ profile)',/exact in K = ℚ\(√3, √5\)/.test(t)&&t.includes('coverage 20/432')&&t.includes('uncertain cells: 0')&&/five lefts \(or five rights\) close a pentagonal face/.test(d)&&/order 60/.test(d),t);}
    await setDial(pg,'pen-preset','free');await waitPens(pg);
    // ---- see-also links (both directions)
    await pg.click('[data-role="pen-curv"] a[data-pen-goto="d1"]');await pg.waitForTimeout(800);
    {const s=await pg.evaluate(()=>({tab:FVPanel.state.tab,view:FVPanel.state.view,card:!!document.querySelector('.r30-card'),link:!!document.querySelector('[data-role="r30-seealso"] a[data-pen-goto="pens"]')}));
      ok(tag+' pen card "see also" opens D1 (Clifford tab, rl = 1, D1 card shown, with its link back)',s.tab==='clifford'&&/(^|;)rl=1(;|$)/.test(s.view)&&s.card&&s.link,JSON.stringify(s));}
    await pg.evaluate(()=>localStorage.clear());await pg.click('[data-role="r30-seealso"] a[data-pen-goto="pens"]');await pg.waitForTimeout(800);
    {const s=await pg.evaluate(()=>({tab:FVPanel.state.tab,open:!!(document.querySelector('details[data-panel="pen-curvature-exact"]')||{}).open}));ok(tag+' D1 "see also" opens the Panels tab with the curvature pen card open',s.tab==='panels'&&s.open,JSON.stringify(s));}
    // ---- v0.4.17 fix-ups on the group-D cards
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>{for(const id of ['elliptic-points-exact','period-lattice-exact']){const d=document.querySelector('details[data-panel="'+id+'"]');if(d&&!d.open)d.open=true;}});await pg.waitForTimeout(400);
    {await setDial(pg,'ell-p','5');const s=await pg.evaluate(()=>{const cs=[...document.querySelectorAll('[data-role="ell-case"]')];
        // every word of the case blocks sits on one line (no break inside a word): each word's range has one client rect
        let broken=[];for(const c of cs){const tw=document.createTreeWalker(c,NodeFilter.SHOW_TEXT);let n;while((n=tw.nextNode())){const re=/\S+/g;let m;while((m=re.exec(n.data))){const r=document.createRange();r.setStart(n,m.index);r.setEnd(n,m.index+m[0].length);const rects=[...r.getClientRects()].filter(x=>x.width>0);if(rects.length>1)broken.push(m[0]);}}}
        return {n:cs.length,tags:cs.map(c=>c.tagName).join(),active:cs.filter(c=>c.dataset.active==='1').length,broken,text:cs.map(c=>c.textContent).join(' | ')};});
      ok(tag+' fix-up 2: the case table is stacked (5 blocks, one active) and no word is broken across lines'+(s.broken.length?' (broken: '+s.broken.join(', ')+')':''),s.n===5&&!/TR/.test(s.tags)&&s.active===1&&s.broken.length===0&&s.text.includes('not 2-torsion'),JSON.stringify(s));}
    {await setDial(pg,'ell-p','97');let d=await ds(pg,'ell-scatter');ok(tag+' fix-up 3: p = 97 at zoom 1×: the whole grid, dots of 3 px (minimum), all affine points drawn (n = '+d.n+' counts O too)',d.zoom==='1'&&d.dot==='3'&&d.drawn===String(BigInt(d.n)-1n)&&d.span==='97',JSON.stringify(d));
      await setDial(pg,'ell-zoom','2');d=await ds(pg,'ell-scatter');ok(tag+' fix-up 3: zoom 2×: a window of 49 cells, larger dots, part of the points drawn',d.zoom==='2'&&d.span==='49'&&+d.dot>3&&+d.drawn<+d.n&&+d.drawn>0,JSON.stringify(d));
      await pg.click('[data-role="ell-pan"][data-d="r"]');await pg.waitForTimeout(150);d=await ds(pg,'ell-scatter');ok(tag+' fix-up 3: the ▶ arrow pans the window (x from '+d.wx+')',d.wx==='24',JSON.stringify(d));
      await setDial(pg,'ell-zoom','4');d=await ds(pg,'ell-scatter');ok(tag+' fix-up 3: zoom 4×: a window of 25 cells',d.zoom==='4'&&d.span==='25'&&d.wx==='0',JSON.stringify(d));await setDial(pg,'ell-zoom','1');}
    {await setDial(pg,'ell-p','5');await pg.evaluate(()=>{const a=document.querySelector('[data-role="ell-p1"]'),b=document.querySelector('[data-role="ell-p2"]');a.selectedIndex=1;a.dispatchEvent(new Event('change',{bubbles:true}));});await pg.waitForTimeout(150);
      await pg.evaluate(()=>{const b=document.querySelector('[data-role="ell-p2"]');b.selectedIndex=1;b.dispatchEvent(new Event('change',{bubbles:true}));});await pg.waitForTimeout(150);
      const d=await ds(pg,'ell-scatter'),amber=await colorCount(pg,'ell-scatter',[251,191,36]),violet=await colorCount(pg,'ell-scatter',[168,85,247]);
      ok(tag+' fix-up 4: P1 = P2: both outlines visible (amber '+amber+' px, violet '+violet+' px; violet drawn 6 px larger)',d.same==='1'&&amber>0&&violet>0,JSON.stringify(d));
      const sum=(await txt(pg,'[data-role="ell-sum"]'))[0]||'';ok(tag+' fix-up 5: "ν (nu)" in the sum line',sum.includes('ν (nu) = '),sum);}
    {await setDial(pg,'per-curve','11a1');const t=(await txt(pg,'[data-role="per-card"]'))[0]||'';ok(tag+' fix-up 6: the refused 11a1 Δ prints −161051 with U+2212',t.includes('Δ = −161051')&&!t.includes('-161051'));await setDial(pg,'per-curve','37a1');}
    {const r=await pg.evaluate(()=>[FVEllipticCards.redLabel({type:'additive'}),FVEllipticCards.redLabel({type:'nonsplit'}),FVEllipticCards.redLabel({type:'split'}),FVEllipticCards.redLabel({type:'good'}),FVEllipticCards.redShort({type:'additive'})]);
      const row=await pg.evaluate(()=>{const e=document.querySelector('[data-role="ell-ap-row"][data-p="37"] [data-role="ell-red"]');return e?e.textContent:'';});
      ok(tag+' fix-up 7 (F3): the label rule gives "additive" (not "additive multiplicative"), "nonsplit multiplicative", "split multiplicative", "good"; p = 37 row reads "nonsplit multiplicative"',r.join('|')==='additive|nonsplit multiplicative|split multiplicative|good|additive'&&row==='nonsplit multiplicative',r.join('|')+' / '+row);}
    await openPens(pg);await waitPens(pg);
    ok(tag+' no horizontal page scroll with the group-D and group-E cards open',!(await hscroll(pg)));
    ok(tag+' no page errors and no console errors',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();}
  await browser.close();
  for(const t of timing)console.log(t);
  console.log('SUMMARY browser-check-v0418: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
})().catch(e=>{console.error(e);process.exit(1);});
