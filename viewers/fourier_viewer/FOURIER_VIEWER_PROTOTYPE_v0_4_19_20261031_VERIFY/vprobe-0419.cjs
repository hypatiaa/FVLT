'use strict';
// Verifier's own browser probe for v0.4.19 (membrane, Playwright via NODE_PATH). Reads DOM / data attributes and takes screenshots; asserts little,
// prints everything (the verdicts are made in the report). usage: node vprobe-0419.cjs <v0.4.19 folder> <out dir>
const path=require('path'),fs=require('fs'),{pathToFileURL}=require('url');
const PW=require('playwright');
const [B,OUT]=process.argv.slice(2).map(p=>path.resolve(p));
const CC=require(path.join(B,'host-core/comb-core.js')),PS=require(path.join(B,'host-core/pen-streams-core.js')),RL=require(path.join(B,'host-core/rule30-ladder-core.js'));
const url=pathToFileURL(path.join(B,'dist','comb-hopf.html')).href;
const addr=o=>CC.encodeAddress(CC.initial(o));
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(!c&&x!==undefined?' :: '+x:''));c?pass++:fail++;};
const gopen=async(pg,hash)=>{await pg.goto('about:blank');await pg.goto(url+hash);await pg.waitForFunction(()=>window.FVPanel&&FVPanel.perf&&FVPanel.perf.n>0,null,{timeout:180000});await pg.waitForTimeout(500);};
const IDS=['pen-curvature-exact','pen-sphere-exact'];
const waitPens=pg=>pg.waitForFunction(()=>!!document.querySelector('[data-role="pen-disk-reg"]')&&!!document.querySelector('[data-role="pen-sph-read"]'),null,{timeout:180000});
const set=(pg,role,v,k)=>pg.evaluate(([r,v,k])=>{const x=[...document.querySelectorAll('[data-role="'+r+'"]')][k||0];if(!x)return 'none';if(x.type==='checkbox')x.checked=v==='1';else x.value=v;x.dispatchEvent(new Event('change',{bubbles:true}));return 'ok';},[role,String(v),k||0]);
const T=(pg,r)=>pg.evaluate(r=>[...document.querySelectorAll('[data-role="'+r+'"]')].map(e=>e.textContent),r);
const DS=(pg,r)=>pg.evaluate(r=>{const e=document.querySelector('[data-role="'+r+'"]');return e?Object.assign({},e.dataset):null;},r);
// own amber count: any pixel with r > 200, 150 < g < 220, b < 80 (tooth colour family)
const amber=(pg,r)=>pg.evaluate(r=>{const cv=document.querySelector('[data-role="'+r+'"]'),d=cv.getContext('2d').getImageData(0,0,cv.width,cv.height).data;let n=0;for(let i=0;i<d.length;i+=4)if(d[i]>200&&d[i+1]>150&&d[i+1]<220&&d[i+2]<80)n++;return n;},r);
// v2 (after a crash of v1: the card re-rendered under the element handle): wait, use a locator, retry, never throw
const shot=async(pg,sel,name)=>{for(let i=0;i<3;i++){try{await pg.waitForTimeout(1500);const lo=pg.locator(sel).first();if(await lo.count()){await lo.screenshot({path:path.join(OUT,name),timeout:30000});}else await pg.screenshot({path:path.join(OUT,name)});console.log('SHOT '+name);return;}catch(e){console.log('SHOT-RETRY '+name+' '+String(e.message).split('\n')[0]);}}console.log('SHOT-FAILED '+name);};
let BR=null;
(async()=>{
  const br=await PW.chromium.launch();BR=br;
  for(const [w,h,tag] of [[1280,800,'1280x800'],[375,812,'375x812']]){
    const ctx=await br.newContext({viewport:{width:w,height:h},deviceScaleFactor:1,hasTouch:w<500}),pg=await ctx.newPage(),errs=[];
    pg.on('pageerror',e=>errs.push(String(e)));
    // ---------------- D1: j = 30 at q = 1 and q = 2, j = 34 q = 2
    for(const [j,q] of [[30,1],[30,2],[34,2],[26,1]]){
      await gopen(pg,addr({tab:'clifford',view:'rl=1;rlj='+j+(q!==2?';rlq='+q:'')}));
      const at=await pg.evaluate(()=>{const g=document.querySelector('#stage [data-role="r30-curve"]');return g?Object.fromEntries([...g.attributes].map(a=>[a.name,a.value])):null;});
      const caps=await pg.evaluate(()=>[...document.querySelectorAll('#caption p, #caption div')].map(e=>e.textContent).filter(t=>/q = 1|loop|fibre/.test(t)));
      console.log('D1 '+tag+' j='+j+' q='+q+' attrs '+JSON.stringify(at&&{per:at['data-per'],sub:at['data-sub'],n:at['data-n'],evsteps:at['data-event-steps'],parts:at['data-event-parts'],min:at['data-event-pieces-min'],fwd:at['data-event-forward'],notfwd:at['data-event-not-forward'],endB:at['data-end-base'],endF:at['data-end-fibre']}));
      console.log('D1 '+tag+' j='+j+' q='+q+' captions '+JSON.stringify(caps));
      const sub=Math.max(1,Math.ceil(720/RL.perN(30,j))),c=RL.curve(30,j,q,{sub}),last=c.points[c.points.length-1];
      ok('D1 '+tag+' j='+j+' q='+q+': pieces min '+(at&&at['data-event-pieces-min'])+' >= '+(q===1?32:16)+', not-forward 0, end = core end '+last.base.join('/')+' | '+last.fibre.join('/'),
        !!at&&+at['data-event-pieces-min']>=(q===1?32:16)&&at['data-event-not-forward']==='0'&&at['data-end-base']===last.base.join('/')&&at['data-end-fibre']===last.fibre.join('/'));
      await shot(pg,'#stage','v_'+tag+'_d1_r30_j'+j+'_q'+q+'.png');
      await pg.screenshot({path:path.join(OUT,'v_'+tag+'_d1_r30_j'+j+'_q'+q+'_page.png')});
    }
    // ---------------- pens
    await gopen(pg,addr({tab:'panels'}));await pg.evaluate(()=>{try{localStorage.clear();}catch(e){}});await gopen(pg,addr({tab:'panels'}));
    await pg.evaluate(ids=>{for(const id of ids){const d=document.querySelector('details[data-panel="'+id+'"]');if(d)d.open=true;}},IDS);await waitPens(pg);
    // sphere dials disabled + note
    const dial=await pg.evaluate(()=>{const s=document.querySelector('details[data-panel="pen-sphere-exact"]');if(!s)return null;
      const f=s.querySelector('[data-role="pen-follow"]'),W=s.querySelector('[data-role="pen-W"]');return {follow:f?{dis:f.disabled,vis:f.offsetParent!==null}:null,W:W?{dis:W.disabled,vis:W.offsetParent!==null}:null,notes:[...s.querySelectorAll('[data-role="pen-unused"]')].map(e=>e.textContent)};});
    ok('6a '+tag+' sphere card: follow and W shown disabled with "not used on this card"',!!dial&&dial.follow&&dial.follow.dis&&dial.follow.vis&&dial.W&&dial.W.dis&&dial.W.vis&&dial.notes.length===2&&dial.notes.every(t=>/not used on this card/.test(t)),JSON.stringify(dial));
    // Rule 30 T = 1328: sphere, teeth on/off
    await set(pg,'pen-T','1328');await waitPens(pg);
    const sr=(await T(pg,'pen-sph-read'))[0],sd=await DS(pg,'pen-cv-sph'),aOn=await amber(pg,'pen-cv-sph');
    console.log('SPH '+tag+' T1328 read: '+sr);console.log('SPH '+tag+' ds '+JSON.stringify(sd)+' amber '+aOn);
    await shot(pg,'details[data-panel="pen-sphere-exact"]','v_'+tag+'_sph_r30_T1328_teeth_on.png');
    const st=await set(pg,'pen-teeth-toggle','0');await waitPens(pg);
    const sd2=await DS(pg,'pen-cv-sph'),aOff=await amber(pg,'pen-cv-sph'),sr2=(await T(pg,'pen-sph-read'))[0];
    ok('6c '+tag+' tooth-events toggle '+st+': on draws '+(sd&&sd.teeth)+' dots ('+aOn+' amber px), off draws 0 ('+aOff+' amber px), event count still printed',sd&&+sd.teeth>0&&sd2.teeth==='0'&&sd2.events===sd.events&&aOff<aOn&&/not drawn: toggle off/.test(sr2),JSON.stringify([sd&&sd.teeth,sd2.teeth,aOn,aOff]));
    await shot(pg,'details[data-panel="pen-sphere-exact"]','v_'+tag+'_sph_r30_T1328_teeth_off.png');
    await set(pg,'pen-teeth-toggle','1');await waitPens(pg);
    // counts: disk and sphere
    for(const Tv of ['512','4096']){await set(pg,'pen-T',Tv);await waitPens(pg);const r=(await T(pg,'pen-disk-reg'))[0],d=await DS(pg,'pen-cv-m1');console.log('DISK '+tag+' T'+Tv+' '+r);console.log('DISK '+tag+' T'+Tv+' ds '+JSON.stringify({u:d.uncertified,und:d.undecided,pts:d.points,dbl:d.doublings,cap:d.pcap}));
      ok('4a '+tag+' disk T='+Tv+': "enclosure wider than ¼ px: '+d.uncertified+'" and "pixel undecided: '+d.undecided+'" printed and equal to attributes',r.includes('enclosure wider than ¼ px: '+d.uncertified+' of '+d.points)&&r.includes('pixel undecided: '+d.undecided)&&d.uncertified==='0');}
    // doubling: raise threshold to an unreachable value
    await pg.evaluate(()=>{FVPenCards.PREC.minPlaces=50n;FVPenCards.rerender();});await waitPens(pg);
    {const d=await DS(pg,'pen-cv-m1'),cap=await T(pg,'pen-pcap-m1'),r=(await T(pg,'pen-disk-reg'))[0];ok('4b '+tag+' threshold 50 places: doublings '+d.doublings+', cap '+d.pcap+', cap note shown',d.doublings==='2'&&d.pcap==='1'&&cap.length===1&&/Precision cap reached/.test(cap[0]),r+' | '+cap);}
    await pg.evaluate(()=>{FVPenCards.PREC.minPlaces=6n;FVPenCards.rerender();});await waitPens(pg);
    // dodecahedron arcs
    await set(pg,'pen-T','1328');await set(pg,'pen-preset','dodeca');await waitPens(pg);
    {const d=await DS(pg,'pen-cv-sph'),note=(await T(pg,'pen-dodeca'))[0]||'',r=(await T(pg,'pen-sph-read'))[0];console.log('DODECA '+tag+' ds '+JSON.stringify(d));console.log('DODECA '+tag+' note: '+note);console.log('DODECA '+tag+' read: '+r);
      ok('5a/6d '+tag+' dodecahedron: edges = arcs, 7 interior points per step (arcPoints = 7·T), note says "isomorphic to A₅" with VERIFY-0419-?? no: cites VERIFY-0418-18 and the build job; element orders kept',d.edges==='arcs'&&d.arcPoints===String(7*1328)&&/isomorphic to A₅/.test(note)&&/VERIFY-0418-18/.test(note)&&/9a77f4ca/.test(note)&&/1, 15, 20, 24/.test(note));}
    await shot(pg,'details[data-panel="pen-sphere-exact"]','v_'+tag+'_sph_dodeca_T1328_arcs.png');
    await set(pg,'pen-preset','free');await waitPens(pg);
    // Codex / credit
    {const lean=(await T(pg,'pen-lean'))[0]||'',cr=(await T(pg,'pen-credit'))[0]||'';console.log('LEAN '+lean);console.log('CREDIT '+cr);
      ok('5b '+tag+' Codex wording: "Codex-reviewed (PASS WITH FLAGS, #1310 / #1318)", "both Codex-reviewed" gone, credit consistent',lean.includes('Codex-reviewed (PASS WITH FLAGS, #1310 / #1318)')&&!/both Codex-reviewed/.test(lean)&&/#1310/.test(cr)&&/#1318/.test(cr));}
    // Goldbach run to 1448: ticks
    await set(pg,'pen-stream','gbrun');await waitPens(pg);await set(pg,'pen-Nmax','1448');await waitPens(pg);
    {const info=await pg.evaluate(()=>[...document.querySelectorAll('canvas')].filter(c=>c.dataset.tickEvery!==undefined).map(c=>({role:c.dataset.role,w:c.width,k:c.dataset.tickEvery,n:c.dataset.ticksDrawn})));
      const notes=[...(await T(pg,'pen-ticks-note-curv')),...(await T(pg,'pen-ticks-note-sph'))],ord=await T(pg,'pen-gb-order'),rd=(await T(pg,'pen-gb-readout'))[0]||'';
      console.log('GB '+tag+' strips '+JSON.stringify(info));console.log('GB '+tag+' notes '+JSON.stringify(notes));console.log('GB '+tag+' order '+JSON.stringify(ord));console.log('GB '+tag+' readout '+rd);
      // own k: run bounds, tick x = floor(b W / L), smallest k with all consecutive drawn ticks >= 3 px
      const run=PS.goldbachRun(1448),L=BigInt(run.len);let good=info.length>0;
      for(const s of info){const W=BigInt(s.w),xs=run.bounds.map(b=>BigInt(b)*W/L);let k=1;for(;k<xs.length;k++){let g=true;for(let i=k;i<xs.length;i+=k)if(xs[i]-xs[i-k]<3n){g=false;break;}if(g)break;}
        const drawn=Math.ceil(xs.length/k);console.log('GB own k for '+s.role+' (W '+s.w+'): '+k+', drawn '+drawn);if(String(k)!==s.k||String(drawn)!==s.n)good=false;}
      ok('6b '+tag+' run to 1448: every strip k = own smallest k and drawn count; note "ticks every k shells" printed; order sentence on card',good&&notes.some(t=>/ticks every \d+ shells/.test(t))&&ord.some(t=>/counted twice/.test(t)),JSON.stringify(info));}
    await shot(pg,'details[data-panel="pen-curvature-exact"]','v_'+tag+'_curv_gbrun_1448.png');
    await shot(pg,'details[data-panel="pen-sphere-exact"]','v_'+tag+'_sph_gbrun_1448.png');
    ok(tag+' no page errors',errs.length===0,errs.slice(0,3).join(' | '));
    await ctx.close();
  }
  await br.close();
  console.log('SUMMARY vprobe-0419: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
})().catch(async e=>{console.log('CRASH '+e.stack);process.exitCode=2;try{if(BR)await BR.close();}catch(x){}});
