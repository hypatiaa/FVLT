'use strict';
// v0.4.19 browser check of the group-E pen cards after the fix round (SCHEMA_ADDENDUM_26, items 1, 4, 5, 6), at 1280x800 and 375x812:
// the Goldbach order sentence; the two pixel counts on the disk and the sphere and their data attributes; the P-doubling rule and its cap (exercised by
// raising FVPenCards.PREC.minPlaces, since no stream of the card needs a doubling at the starting P); the sphere card's disabled disk dials; the
// tooth-events toggle and the smaller dots; thinned shell ticks; dodecahedron edges as arcs; the A5 and Codex wording.
// Expected values come from the cores run here in Node. No floating point: counts are integers, BigInt for pixel arithmetic, times integer ms.
const path=require('path'),{pathToFileURL}=require('url');
const PW=(()=>{try{return require('playwright');}catch(e){return require(process.env.PLAYWRIGHT_DIR||'C:/Users/robin/s6_atom/node_modules/playwright');}})();
const CC=require('../host-core/comb-core.js'),ST=require('../host-core/pen-streams-core.js'),CV=require('../host-core/pen-curvature-core.js'),SP=require('../host-core/pen-sphere-core.js');
const root=path.join(__dirname,'..'),url=pathToFileURL(path.join(root,'dist','comb-hopf.html')).href;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const addr=o=>CC.encodeAddress(CC.initial(o));
const gopen=async(pg,hash)=>{await pg.goto('about:blank');await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0);await pg.waitForTimeout(300);};
const IDS=['pen-curvature-exact','pen-sphere-exact'];
const openPens=pg=>pg.evaluate(ids=>{for(const id of ids){const d=document.querySelector('details[data-panel="'+id+'"]');if(d&&!d.open)d.open=true;}},IDS);
const setDial=(pg,role,v,nth)=>pg.evaluate(([r,v,k])=>{const xs=[...document.querySelectorAll('[data-role="'+r+'"]')];if(!xs.length)return false;const x=xs[k];if(x.type==='checkbox')x.checked=v==='1';else x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));return true;},[role,String(v),nth||0]);
const txt=(pg,sel)=>pg.evaluate(s=>[...document.querySelectorAll(s)].map(e=>e.textContent),sel);
const ds=(pg,role)=>pg.evaluate(r=>{const e=document.querySelector('[data-role="'+r+'"]');return e?{...e.dataset}:null;},role);
const hscroll=pg=>pg.evaluate(()=>document.documentElement.scrollWidth>document.documentElement.clientWidth);
const amberPx=(pg,role)=>pg.evaluate(r=>{const cv=document.querySelector('[data-role="'+r+'"]');const im=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let n=0;for(let i=0;i<im.length;i+=4)if(im[i]===251&&im[i+1]===191&&im[i+2]===36)n++;return n;},role);
const waitPens=pg=>pg.waitForFunction(()=>!!document.querySelector('[data-role="pen-read-m1"] [data-role="pen-disk"]')&&!!document.querySelector('[data-role="pen-sph-read"]'),null,{timeout:120000});
// the smallest k keeping consecutive drawn ticks >= 3 px apart (own transcription of the rule: tick x = floor(b * width / L))
function ownTickEvery(bounds,W,L){if(bounds.length<2)return 1n;const xs=bounds.map(b=>BigInt(b)*W/L);let k=1;
  for(;k<xs.length;k++){let good=true;for(let i=k;i<xs.length;i+=k)if(xs[i]-xs[i-k]<3n){good=false;break;}if(good)break;}return BigInt(k);}
const counts=t=>{const a=/enclosure wider than ¼ px: (\d+) of (\d+)/.exec(t),b=/pixel undecided: (\d+)/.exec(t);return a&&b?{wide:a[1],pts:a[2],und:b[1]}:null;};
(async()=>{
  const browser=await PW.chromium.launch();
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await browser.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));pg.on('console',m=>{if(m.type()==='error')errs.push(m.text());});
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>localStorage.clear());await gopen(pg,addr({tab:'panels'}));
    await openPens(pg);await waitPens(pg);
    // ---- item 4: the two pixel counts, on the disk and the sphere, at several T and both disk views
    for(const T of ['48','512','1024','4096']){await setDial(pg,'pen-T',T);await waitPens(pg);
      const r=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'',c=counts(r),d=await ds(pg,'pen-cv-m1');
      ok(tag+' disk, Rule 30, T = '+T+' (follow): "enclosure wider than ¼ px: '+(c?c.wide:'?')+' of '+(c?c.pts:'?')+'" and "pixel undecided: '+(c?c.und:'?')+'" printed; equal to data-uncertified / data-undecided; the wide count is 0; P doubled 0 times; the old wording is gone',
        !!c&&c.wide==='0'&&d.uncertified===c.wide&&d.undecided===c.und&&d.points===c.pts&&/P doubled 0 times/.test(r)&&!/pixels not certified/.test(r),r);
      console.log('INFO '+tag+' disk T = '+T+' follow: pixel undecided '+(c?c.und:'?')+' of '+(c?c.pts:'?'));}
    await setDial(pg,'pen-follow','0');await waitPens(pg);
    {const r=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'',c=counts(r);ok(tag+' disk, T = 4096, absolute view: both counts printed, wide 0',!!c&&c.wide==='0'&&/absolute view from the start/.test(r),r);console.log('INFO '+tag+' disk T = 4096 absolute: pixel undecided '+(c?c.und:'?')+' of '+(c?c.pts:'?'));}
    await setDial(pg,'pen-follow','1');await waitPens(pg);
    // ---- item 4: the doubling rule and its cap (threshold raised through the exposed PREC; 13 places can never be reached, the distance prints at most 12)
    await setDial(pg,'pen-T','1024');await waitPens(pg);
    {await pg.evaluate(()=>{FVPenCards.PREC.minPlaces=13n;FVPenCards.rerender();});await waitPens(pg);
      const r=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'',cap=(await txt(pg,'[data-role="pen-pcap-m1"]'))[0]||'',d=await ds(pg,'pen-cv-m1'),P0=CV.workingBits(1024);
      ok(tag+' doubling rule exercised (threshold 13 places, never met): P doubled 2 times, P = 4 × '+P0+' = '+(4n*P0)+' bits, the cap note is shown',/P doubled 2 times/.test(r)&&r.includes('P = '+(4n*P0)+' bits')&&d.doublings==='2'&&d.pcap==='1'&&/Precision cap reached: P was doubled 2 times/.test(cap)&&/fewer than 13 guaranteed places/.test(cap),r+' | '+cap);
      await pg.evaluate(()=>{FVPenCards.PREC.minPlaces=6n;FVPenCards.rerender();});await waitPens(pg);
      const r2=(await txt(pg,'[data-role="pen-disk-reg"]'))[0]||'',cap2=await txt(pg,'[data-role="pen-pcap-m1"]');
      ok(tag+' threshold back to 6 places: P = '+P0+' bits, doubled 0 times, no cap note',r2.includes('P = '+P0+' bits')&&/P doubled 0 times/.test(r2)&&cap2.length===0,r2);
      ok(tag+' the pixel rule is stated on the card',((await txt(pg,'[data-role="pen-pixel-rule"]'))[0]||'').includes('floor(lo) ≠ floor(hi)'));}
    // ---- the sphere: two counts
    await setDial(pg,'pen-T','1328');await waitPens(pg);
    {const t=(await txt(pg,'[data-role="pen-sph-read"]'))[0]||'',c=counts(t),d=await ds(pg,'pen-cv-sph');
      ok(tag+' sphere, Rule 30, T = 1328: both counts printed (wide '+(c?c.wide:'?')+', undecided '+(c?c.und:'?')+' of '+(c?c.pts:'?')+'), equal to the data attributes, wide 0',!!c&&c.wide==='0'&&d.uncertified===c.wide&&d.undecided===c.und&&!/pixels not certified/.test(t),t);
      console.log('INFO '+tag+' sphere T = 1328 free: pixel undecided '+(c?c.und:'?')+' of '+(c?c.pts:'?'));
    // ---- item 6: tooth events toggle (default on), smaller dots
      const s=ST.caRun(30,1328);let ev=0;for(const v of s.tooth)ev+=v;const on=await amberPx(pg,'pen-cv-sph');
      ok(tag+' tooth events: toggle present and on by default; '+ev+' events counted and drawn (data-teeth = data-events = '+ev+')',d.teeth===String(ev)&&d.events===String(ev)&&await pg.evaluate(()=>{const x=document.querySelector('[data-role="pen-teeth-toggle"]');return !!x&&x.checked;})&&t.includes('tooth events (q = r = 1): '+ev),JSON.stringify(d));
      await setDial(pg,'pen-teeth-toggle','0');await waitPens(pg);
      const t2=(await txt(pg,'[data-role="pen-sph-read"]'))[0]||'',d2=await ds(pg,'pen-cv-sph'),off=await amberPx(pg,'pen-cv-sph');
      ok(tag+' tooth events off: none drawn (data-teeth 0), the count still printed with "(not drawn: toggle off)"; amber pixels '+on+' → '+off,d2.teeth==='0'&&d2.events===String(ev)&&t2.includes('tooth events (q = r = 1): '+ev+' (not drawn: toggle off)')&&off<on,t2);
      ok(tag+' smaller dots: the amber added by the '+ev+' dots is at most 9 px per dot (3 × 3 front, 1 px back): '+(on-off)+' px',on-off<=9*ev&&on-off>0);
      await setDial(pg,'pen-teeth-toggle','1');await waitPens(pg);}
    // ---- item 6: the disk dials on the sphere card: disabled, "not used on this card"; live on the curvature card
    {const st=await pg.evaluate(()=>{const c=document.querySelector('[data-role="pen-curv"]'),s=document.querySelector('[data-role="pen-sph"]');const g=(b,r)=>{const x=b.querySelector('[data-role="'+r+'"]');return x?{dis:x.disabled,vis:x.getBoundingClientRect().width>0}:null;};
        return {cf:g(c,'pen-follow'),cw:g(c,'pen-W'),sf:g(s,'pen-follow'),sw:g(s,'pen-W'),notes:[...s.querySelectorAll('[data-role="pen-unused"]')].map(e=>e.textContent),cnotes:c.querySelectorAll('[data-role="pen-unused"]').length};});
      ok(tag+' sphere card: "follow the pen" and W shown disabled, each with "(not used on this card)"; the curvature card keeps them enabled',st.sf&&st.sw&&st.sf.dis&&st.sw.dis&&st.sf.vis&&st.sw.vis&&st.notes.length===2&&st.notes.every(n=>n==='(not used on this card)')&&st.cf&&!st.cf.dis&&st.cw&&!st.cw.dis&&st.cnotes===0,JSON.stringify(st));}
    // ---- item 6: dodecahedron edges as great-circle arcs; item 5: A5 wording
    await setDial(pg,'pen-preset','dodeca');await waitPens(pg);
    {const t=(await txt(pg,'[data-role="pen-sph-read"]'))[0]||'',d=await ds(pg,'pen-cv-sph'),note=(await txt(pg,'[data-role="pen-dodeca"]'))[0]||'',c=counts(t);
      ok(tag+' dodecahedron preset: edges drawn as arcs ('+d.arcPoints+' interior points = 1328 × '+(SP.ARC_PIECES-1)+'), counted with the other points ('+(c?c.pts:'?')+' = 1329 + '+d.arcPoints+'), wide 0',d.edges==='arcs'&&d.arcPoints===String(1328*(SP.ARC_PIECES-1))&&!!c&&c.pts===String(1329+1328*(SP.ARC_PIECES-1))&&c.wide==='0',JSON.stringify(d)+' '+t);
      console.log('INFO '+tag+' dodecahedron T = 1328: pixel undecided '+(c?c.und:'?')+' of '+(c?c.pts:'?'));
      ok(tag+' A₅ wording: "isomorphic to A₅", the verifier’s job VERIFY-0418-18 (9a77f4ca…) and this build’s job VIEW-SAGE-0419-02 with its receipt; the element-order statement kept; arcs stated',/order 60 isomorphic to A₅/.test(note)&&note.includes('VERIFY-0418-18')&&note.includes('9a77f4ca…')&&/VIEW-SAGE-0419-02 on the build’s own two moves, receipt [0-9a-f]{8}…/.test(note)&&note.includes('1, 15, 20, 24 elements of order 1, 2, 3, 5')&&/great-circle arcs/.test(note),note);}
    await setDial(pg,'pen-preset','free');await waitPens(pg);
    {const d=await ds(pg,'pen-cv-sph'),t=(await txt(pg,'[data-role="pen-read-sph"]'))[0]||'';ok(tag+' free preset: steps drawn as chords, and the card says so',d.edges==='chords'&&/chords, not arcs/.test(t));}
    // ---- item 5: Codex wording
    {const L=await txt(pg,'.pen .note'),lean=L.filter(x=>x.startsWith('Lean: ')),cr=L.filter(x=>x.startsWith('Idea credit: '));
      ok(tag+' Codex wording on both cards: "Codex-reviewed (PASS WITH FLAGS, #1310 / #1318)", no "both Codex-reviewed"; the credit line names the same reviews',lean.length===2&&lean.every(x=>x.includes('Codex-reviewed (PASS WITH FLAGS, #1310 / #1318)')&&!x.includes('both Codex-reviewed'))&&cr.length===2&&cr.every(x=>x.includes('#1310 for library v15, #1318 for library v16')),lean.concat(cr).join(' | '));}
    // ---- item 1: the Goldbach order sentence; item 6: thinned shell ticks
    for(const [label,set,kind,o] of [['Goldbach shell N = 24',[['pen-stream','gbshell'],['pen-N','24']],'gbshell',{N:24}],['Goldbach shell N = 1446',[['pen-N','1446']],'gbshell',{N:1446}],['Goldbach run N_max = 100',[['pen-stream','gbrun'],['pen-Nmax','100']],'gbrun',{Nmax:100}],['Goldbach run N_max = 1448',[['pen-Nmax','1448']],'gbrun',{Nmax:1448}]]){
      for(const [r,v] of set){await setDial(pg,r,v);await waitPens(pg);}
      const st=ST.stream(kind,o),ord=await txt(pg,'[data-role="pen-gb-order"]'),guard=(await txt(pg,'[data-role="pen-gb-guard"]'))[0]||'';
      ok(tag+' '+label+': the order sentence (decided by saphir, 2026-10-31; |c| ascending, +c before −c; pairs twice, the equal pair once; #+ = 2·g(N) − δ) on both cards, both guards kept',ord.length===2&&ord.every(x=>x.includes('decided by saphir, 2026-10-31')&&x.includes('+c before −c')&&x.includes('counted twice')&&x.includes('the equal pair p = N/2 once')&&x.includes('#+ = 2·g(N) − δ'))&&guard.includes('it proves nothing about Goldbach')&&guard.includes('Closure reaches conjugation, not Goldbach.'),ord.join(' | '));
      if(kind==='gbshell'){const c=((await txt(pg,'[data-role="pen-gb-order"]'))[0]||'');ok(tag+' '+label+': the listed teeth follow the order ('+st.gb.c.slice(0,4).join(', ')+', …)',c.includes('c = '+st.gb.c.slice(0,6).join(', ').replace(/-/g,'−')),c);}
      for(const [role,note,W] of [['pen-strip-0','pen-ticks-note-curv',260n],['pen-strip-sph','pen-ticks-note-sph',320n]]){
        const d=await ds(pg,role),k=ownTickEvery(st.bounds,W,BigInt(st.len)),n=(await txt(pg,'[data-role="'+note+'"]'))[0]||'',drawn=(BigInt(st.bounds.length)+k-1n)/k;
        ok(tag+' '+label+' '+role+': ticks every '+k+' shell(s) (own rule: the smallest k keeping drawn ticks ≥ 3 px apart on '+W+' px), '+drawn+' of '+st.bounds.length+' drawn'+(k>1n?', "ticks every '+k+' shells" printed':', no note'),d.tickEvery===String(k)&&d.ticksDrawn===String(drawn)&&d.ticks===String(st.bounds.length)&&(k>1n?n.includes('ticks every '+k+' shells'):n===''),JSON.stringify(d)+' '+n);}}
    ok(tag+' no horizontal page scroll',!(await hscroll(pg)));
    ok(tag+' no page errors and no console errors',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();}
  await browser.close();
  console.log('SUMMARY browser-check-v0419: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
})().catch(e=>{console.error(e);process.exit(1);});
