'use strict';
// Independent verifier, Fourier viewer v0.4.19 (2026-10-31). Own code; uses the build's modules only as the objects under test,
// and the D1 core (unchanged since v0.4.16) for per_j and psi only. Integers / BigInt only.
// usage: node verify_0419.cjs <v0.4.19 folder> <v0.4.18 folder> <out dir>
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const [B19,B18,OUT]=process.argv.slice(2).map(p=>path.resolve(p));
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(!c&&x!==undefined?' :: '+x:''));c?pass++:fail++;};
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');

// ------------------------------------------------------------------ A. Goldbach tooth order (own enumeration)
{
  const PS=require(path.join(B19,'host-core/pen-streams-core.js'));
  // own primality: trial division by every integer 2..sqrt (no sieve, different from the builder's test)
  const isP=k=>{if(k<2)return false;for(let d=2;d*d<=k;d++)if(k%d===0)return false;return true;};
  function mine(N){
    const n=N/2;let g=0,amax=0;for(let p=2;p<=n;p++)if(isP(p)&&isP(N-p)){g++;if(n-p>amax)amax=n-p;}
    const t2=(n%2===1)?2:1,m=amax===0?3:amax+1;
    // own order generator: walk |c| upward; odd m: |c| = 0..(m-1)/2 ; even m: |c| = 1,3,..,m-1 ; emit +|c| then -|c|
    const c=[];
    if(m%2===1){c.push(0);for(let d=1;d<=(m-1)/2;d++){c.push(d,-d);}}
    else{for(let d=1;d<=m-1;d+=2){c.push(d,-d);}}
    const s=c.map(x=>{const a=x<0?-x:x;return isP(n-a*t2)&&isP(n+a*t2)?1:-1;});
    const plus=s.filter(v=>v===1).length,delta=isP(n)?1:0;
    return {N,n,t2,m,g,delta,c,s,plus};
  }
  const show=[];
  for(const N of [4,6,24,100,1448]){
    const r=mine(N),b=PS.goldbachShell(N);
    const same=JSON.stringify(b.c)===JSON.stringify(r.c)&&JSON.stringify(Array.from(b.s))===JSON.stringify(r.s);
    ok('A1 N='+N+' m='+r.m+' t2='+r.t2+' order '+r.c.slice(0,8).join(',')+(r.c.length>8?',…':'')+' len '+r.c.length+' g='+r.g+' δ='+r.delta+' #+='+r.plus,same&&b.plus===r.plus&&r.plus===2*r.g-r.delta,JSON.stringify(b.c.slice(0,8)));
    show.push([N,r.m,r.t2,r.g,r.delta,r.c.length,r.plus,r.c.slice(0,6).join(' ')]);
  }
  // N = 4 is the comb special case: a_max = 0 so m = 3 (odd) although N = 0 mod 4
  {const r=mine(4);ok('A2 N=4: m=3, t2=1, order 0,1,-1, signs +,-,-, #+ = 1 = 2·1 − 1',r.m===3&&r.t2===1&&r.c.join()==='0,1,-1'&&r.s.join()==='1,-1,-1'&&r.plus===1);}
  // every pair p != q at +c and -c with sign +, the equal pair once
  let badAll=[];let tot=0,gs=0,ds=0;const allS=[],bnd=[];
  for(let N=4;N<=1448;N+=2){const r=mine(N),b=PS.goldbachShell(N);
    if(JSON.stringify(b.c)!==JSON.stringify(r.c)||JSON.stringify(Array.from(b.s))!==JSON.stringify(r.s))badAll.push(N);
    // pair-level check: for each prime pair p<q, find its tooth +c and -c in the order; both +
    const idx=new Map(r.c.map((c,i)=>[c,i]));
    for(let p=2;p<=r.n;p++)if(isP(p)&&isP(N-p)){const a=(r.n-p)/r.t2;if(!Number.isInteger(a)){badAll.push('frac'+N);continue;}
      if(a===0){if(r.s[idx.get(0)]!==1)badAll.push('eq'+N);}else{const i1=idx.get(a),i2=idx.get(-a);if(i1===undefined||i2!==i1+1||r.s[i1]!==1||r.s[i2]!==1)badAll.push('pair'+N+':'+p);}}
    bnd.push(allS.length);for(const v of r.s)allS.push(v);gs+=r.g;ds+=r.delta;}
  ok('A3 every even N 4..1448 (723 shells): build order and signs = own enumeration; every pair p≠q at +c then −c (adjacent, both +), equal pair at c=0',badAll.length===0,badAll.slice(0,10).join(' '));
  const run=PS.goldbachRun(1448),plus=allS.filter(v=>v===1).length;
  ok('A4 run to 1448: shells '+run.shells+', len '+run.len+', #+ '+run.plus+' = 2·'+gs+' − '+ds+'; bounds and every sign equal',run.shells===723&&run.len===allS.length&&JSON.stringify(run.bounds)===JSON.stringify(bnd)&&JSON.stringify(Array.from(run.s))===JSON.stringify(allS)&&run.plus===plus&&plus===2*gs-ds,run.len+' '+allS.length);
  console.log('A-table N m t2 g δ teeth #+ first: '+JSON.stringify(show));
  // stream code unchanged from v0.4.18
  ok('A5 pen-streams-core.js and goldbach-core.js byte-identical to v0.4.18',sha(path.join(B19,'host-core/pen-streams-core.js'))===sha(path.join(B18,'host-core/pen-streams-core.js'))&&sha(path.join(B19,'host-core/goldbach-core.js'))===sha(path.join(B18,'host-core/goldbach-core.js')));
  // card text
  const pp=fs.readFileSync(path.join(B19,'instruments/comb-hopf/panel-pens.js'),'utf8');
  ok('A6 card text states the order with the twice/once rule; both v0.4.18 guards still printed',/Tooth order \(decided by saphir, 2026-10-31: both sides\)/.test(pp)&&/counted twice, at \+c and at −c, and the equal pair p = N\/2 once/.test(pp)&&pp.includes('GUARDS.pen')&&pp.includes('GUARDS.closure')?true:false,
    'pen:'+pp.includes('GUARDS.pen')+' closure:'+pp.includes('GUARDS.closure'));
}

// ------------------------------------------------------------------ B. D1 event pieces (own construction against the D1 core)
{
  const RL=require(path.join(B19,'host-core/rule30-ladder-core.js'));
  const RL18=require(path.join(B18,'host-core/rule30-ladder-core.js'));
  const PC=require(path.join(B19,'host-core/d1-event-pieces.js'));
  ok('B0 D1 core and fixture byte-identical to v0.4.18',sha(path.join(B19,'host-core/rule30-ladder-core.js'))===sha(path.join(B18,'host-core/rule30-ladder-core.js'))
    &&fs.readdirSync(path.join(B19,'fixtures')).every(f=>!fs.existsSync(path.join(B18,'fixtures',f))||sha(path.join(B19,'fixtures',f))===sha(path.join(B18,'fixtures',f))));
  const lt=(a,b)=>BigInt(a[0])*BigInt(b[1])<BigInt(b[0])*BigInt(a[1]);
  const eqr=(a,b)=>BigInt(a[0])*BigInt(b[1])===BigInt(b[0])*BigInt(a[1]);
  const rows=[];
  function one(rule,j,q){
    const per=RL.perN(rule,j),sub=Math.max(1,Math.ceil(720/per)),need=q===1?32:16;
    let e=sub;if(e<need)e=sub*Math.ceil(need/sub);
    const S=RL.S(rule,j),g=(a,b)=>b?g(b,a%b):a,k=q/g(q,S),steps=k*per;
    // own N via cumulative psi
    const psi=t=>RL.psi(rule,j,t);
    const exp=[];let Ncum=0;const starts=[];
    for(let t=0;t<steps;t++){starts.push(exp.length);const ev=psi(t);
      const parts=ev?e:sub;
      for(let i=0;i<parts;i++)exp.push({base:[t*parts+i,per*parts],fibre:ev?[Ncum*parts+i,q*parts]:[Ncum,q],ev});
      Ncum+=ev;}
    starts.push(exp.length);exp.push({base:[steps,per],fibre:[Ncum,q],ev:0});
    const c=RL.curve(rule,j,q,{sub}),b=PC.build(c,t=>RL.N(rule,j,t));
    let same=b.pts.length===exp.length;
    if(same)for(let i=0;i<exp.length;i++){if(!eqr(b.pts[i].base,exp[i].base)||!eqr(b.pts[i].fibre,exp[i].fibre)){same=false;break;}}
    // per event step: pieces >= need, strictly forward fibre and base, through to next step's first point
    let evs=0,minP=1e9,fwd=true;
    for(let t=0;t<steps;t++){if(!psi(t))continue;evs++;const a=starts[t],z=starts[t+1],n=z-a;if(n<minP)minP=n;
      for(let i=a;i<z;i++)if(!lt(exp[i].fibre,exp[i+1].fibre)||!lt(exp[i].base,exp[i+1].base))fwd=false;
      // fibre advance over an event step is exactly 1/q
      if(!eqr([exp[z].fibre[0]*exp[a].fibre[1]-exp[a].fibre[0]*exp[z].fibre[1],exp[a].fibre[1]*exp[z].fibre[1]],[1,q]))fwd=false;}
    // end point = v0.4.18 core's curve end (with v0.4.18 view's sub)
    const c18=RL18.curve(rule,j,q,{sub}),e18=c18.points[c18.points.length-1],eB=b.pts[b.pts.length-1];
    const endSame=eqr(eB.base,e18.base)&&eqr(eB.fibre,e18.fibre);
    // base-step points identical to the v0.4.18 curve
    let baseSame=true;for(let t=0;t<steps;t++){if(psi(t))continue;for(let i=0;i<sub;i++){const o=c18.points[t*sub+i],m=b.pts[b.starts[t]+i];if(!eqr(o.base,m.base)||!eqr(o.fibre,m.fibre)){baseSame=false;break;}}if(!baseSame)break;}
    const au=PC.audit(b);
    rows.push({rule,j,q,per,sub,e,evs,minP,steps,k,end:e18.base.join('/')+' | '+e18.fibre.join('/')});
    return {same,evs,minP,need,fwd,endSame,baseSame,au,e,sub,per};
  }
  for(const [j,q] of [[26,1],[26,2],[30,1],[30,2],[34,1],[34,2],[3,1],[3,2]]){
    const r=one(30,j,q);
    ok('B1 rule 30 j='+j+' q='+q+': per '+r.per+', sub '+r.sub+', e '+r.e+', event steps '+r.evs+', min pieces '+r.minP+' ≥ '+r.need+'; build points = own construction; fibre and base strictly forward on every event step (+1/q per step); base steps = v0.4.18 points; end = v0.4.18 end; build audit agrees',
      r.same&&r.minP>=r.need&&r.fwd&&r.endSame&&r.baseSame&&r.au.pmin===r.minP&&r.au.notForward===0&&r.au.forward===r.evs&&r.au.baseForward===r.evs,
      JSON.stringify({same:r.same,fwd:r.fwd,end:r.endSame,base:r.baseSame,au:r.au}));
  }
  // wider sweep: every j 0..34, rules 30/90/150, q in {1,2,4,8}
  let bad=[];for(const rule of [30,90,150])for(let j=0;j<=34;j++)for(const q of [1,2,4,8]){
    let r;try{r=one(rule,j,q);}catch(e){bad.push(rule+'/'+j+'/'+q+':'+e.message);continue;}
    if(!(r.same&&(r.evs===0||r.minP>=r.need)&&r.fwd&&r.endSame&&r.baseSame))bad.push(rule+'/'+j+'/'+q);}
  ok('B2 sweep rules 30/90/150, j 0..34, q 1/2/4/8 (420 curves): same checks',bad.length===0,bad.slice(0,8).join(' '));
  fs.writeFileSync(path.join(OUT,'d1_rows.json'),JSON.stringify(rows.slice(0,8),null,1));
  console.log('B-table '+JSON.stringify(rows.slice(0,8).map(r=>[r.j,r.q,r.per,r.sub,r.e,r.evs,r.minP,r.steps,r.end])));
}

// ------------------------------------------------------------------ C. pixelCert against own definitions
{
  const IV=require(path.join(B19,'host-core/pen-interval-core.js'));
  // own floor division for BigInt
  const fl=(a,b)=>{let q=a/b;if((a%b!==0n)&&((a<0n)!==(b<0n)))q-=1n;return q;};
  let seed=12345n;const rnd=m=>{seed=(seed*6364136223846793005n+1442695040888963407n)&((1n<<64n)-1n);return (seed>>11n)%m;};
  let bad=0,flipDecidedOff=0,flipDecided=0,nonflipDecidedOff=0,nonflipDecided=0,tot=0,und=0;
  for(let it=0;it<200000;it++){
    const W=BigInt(8+Number(rnd(40n))),S=1n<<W,R=BigInt(1+Number(rnd(400n))),off=rnd(500n)-50n,flip=rnd(2n)===1n;
    const lo=rnd(4n*S)-2n*S,w=rnd(it%3===0?S:S/8n+1n),hi=lo+w,a={lo,hi};
    const r=IV.pixelCert(a,W,R,off,flip);tot++;
    // own: coordinate interval [off + lo R/S, off + hi R/S] (or flipped), wide iff width*R > S/4, undecided iff floor ends differ
    const wide=4n*(hi-lo)*R>S;
    const L=flip?off*S-hi*R:off*S+lo*R,H=flip?off*S-lo*R:off*S+hi*R;
    const f0=fl(L,S),f1=fl(H,S),undec=f0!==f1;
    if(r.wide!==wide||r.ok===wide||r.undecided!==undec)bad++;
    if(undec)und++;
    if(!undec){if(flip){flipDecided++;if(r.p!==f0)flipDecidedOff++;}else{nonflipDecided++;if(r.p!==f0)nonflipDecidedOff++;}}
  }
  ok('C1 pixelCert: wide and undecided equal own definitions on 200,000 random enclosures (both axes, flip and not)',bad===0,bad);
  console.log('C2 info: decided points where drawn p != floor(true): non-flipped axis '+nonflipDecidedOff+' of '+nonflipDecided+'; flipped (y) axis '+flipDecidedOff+' of '+flipDecided);
  const CV=require(path.join(B19,'host-core/pen-curvature-core.js'));
  ok('C3 P_DOUBLINGS_MAX = 2 exported',CV.P_DOUBLINGS_MAX===2);
}

// ------------------------------------------------------------------ D. dodecahedron: dump the build's own moves for Sage, and arcs
{
  const SP=require(path.join(B19,'host-core/pen-sphere-core.js'));
  // BFS over flags with the build's own dodecaStep, both moves
  const keys=new Map(),fl=[];const add=f=>{const k=SP.dFlagKey(f);if(!keys.has(k)){keys.set(k,fl.length);fl.push(f);}return keys.get(k);};
  add(SP.DSTART);for(let i=0;i<fl.length;i++){add(SP.dodecaStep(fl[i],1));add(SP.dodecaStep(fl[i],-1));if(fl.length>1000)break;}
  const L=fl.map(f=>keys.get(SP.dFlagKey(SP.dodecaStep(f,1)))),R=fl.map(f=>keys.get(SP.dFlagKey(SP.dodecaStep(f,-1))));
  ok('D1 BFS from the start flag with the build\'s dodecaStep: '+fl.length+' flags, both moves are permutations',fl.length===60&&new Set(L).size===60&&new Set(R).size===60);
  // exact K coordinates of all flags (x and v), for the Sage cross-check: each coord = [n0,n1,n2,n3,d] in basis 1, √3, √5, √15
  const kc=x=>x.n.map(String).concat([String(x.d)]);
  const K=require(path.join(B19,'host-core/field-q2-q5-tau.js')).K;
  ok('D2 K basis order is (1, gen0, gen1, gen0·gen1) with gens √3, √5 (by squaring the generators)',K.key(K.mul(K.gen(0),K.gen(0)))===K.key(K.fromInt(3n))&&K.key(K.mul(K.gen(1),K.gen(1)))===K.key(K.fromInt(5n))&&K.gen(0).n[1]===1n&&K.gen(1).n[2]===1n);
  // arcs of all 30 undirected edges, at P = 96 (the card's SPH_DRAW)
  const arcs=[];const seen=new Set();
  for(const f of fl){for(const sg of [1,-1]){const g=SP.dodecaStep(f,sg),ka=SP.kKey(f.x),kb=SP.kKey(g.x),e=ka<kb?ka+'|'+kb:kb+'|'+ka;if(seen.has(e))continue;seen.add(e);
    const pts=SP.dodecaArc(f.x,g.x,96n);arcs.push({a:f.x.map(kc),b:g.x.map(kc),pts:pts.map(p=>p.map(c=>[String(c.lo),String(c.hi)]))});}}
  ok('D3 30 undirected edges, each with '+(SP.ARC_PIECES-1)+' interior arc points',arcs.length===30&&arcs.every(a=>a.pts.length===SP.ARC_PIECES-1));
  fs.writeFileSync(path.join(OUT,'a5_moves.json'),JSON.stringify({L,R,flags:fl.map(f=>({x:f.x.map(kc),v:f.v.map(kc)})),arcs,P:96}));
}

// ------------------------------------------------------------------ E. own float scan of the changed/added code
{
  const files=['host-core/pen-interval-core.js','host-core/pen-curvature-core.js','host-core/pen-sphere-core.js','host-core/d1-event-pieces.js','instruments/comb-hopf/panel-pens.js',
    'host-core/test-v0419-goldbach-order.cjs','host-core/test-v0419-fixups.cjs','host-core/test-v0419-pens.cjs','build/check-expected-fails-v0419.cjs','build/browser-check-d1-v0419.cjs','build/browser-check-v0419.cjs','build/make-expected-fails-v0419.cjs','build/selftest-expected-fails-v0419.cjs','build/dump-a5-moves-v0419.cjs','build/shots-v0419.cjs'];
  // my patterns: decimal literal (digit . digit) outside strings is hard to separate lexically; I strip string literals and comments first
  const strip=s=>s.replace(/\/\*[\s\S]*?\*\//g,'').replace(/(^|[^:\\])\/\/.*$/gm,'$1').replace(/'(?:\\.|[^'\\\n])*'/g,"''").replace(/"(?:\\.|[^"\\\n])*"/g,'""').replace(/`(?:\\.|[^`\\])*`/g,'``');
  const pats=[['Math.',/\bMath\./],['decimal literal',/(^|[^\w.])\d+\.\d+/],['exponent literal',/\b\d+e[+-]?\d+\b/i],['Float*Array',/Float(32|64)Array/],['parseFloat',/parseFloat/],['toFixed/toPrecision',/to(Fixed|Precision|Exponential)\(/],['performance.now',/performance\.now/],['Number(',/\bNumber\s*\(/],['Number.',/\bNumber\./],['/ on non-BigInt?',/[^\/*]\/[^\/*=]/]];
  const rep=[];
  for(const f of files){const src=strip(fs.readFileSync(path.join(B19,f),'utf8'));const hits={};
    src.split('\n').forEach((l,i)=>{for(const [n,re] of pats)if(re.test(l)){(hits[n]=hits[n]||[]).push(i+1);}});
    rep.push([f,hits]);}
  // view-clifford: only the lines added in v0.4.19
  const a=fs.readFileSync(path.join(B18,'instruments/comb-hopf/view-clifford.js'),'utf8').split('\n'),b=fs.readFileSync(path.join(B19,'instruments/comb-hopf/view-clifford.js'),'utf8').split('\n');
  const A=new Set(a),added=b.filter(l=>!A.has(l));const vc={};added.forEach(l=>{const s=strip(l);for(const [n,re] of pats)if(re.test(s))(vc[n]=vc[n]||[]).push(s.trim().slice(0,140));});
  rep.push(['view-clifford.js (added lines: '+added.length+')',vc]);
  fs.writeFileSync(path.join(OUT,'float_scan.json'),JSON.stringify(rep,null,1));
  for(const [f,h] of rep)console.log('E '+f+' '+JSON.stringify(h));
  const hard=rep.filter(([f,h])=>Object.keys(h).some(k=>['Math.','decimal literal','exponent literal','Float*Array','parseFloat','toFixed/toPrecision','performance.now','Number.'].includes(k)));
  ok('E1 no Math./float literal/Float array/parseFloat/toFixed/performance.now/Number. in the changed/added code (strings and comments stripped)',hard.length===0,JSON.stringify(hard));
}
console.log('SUMMARY verify_0419: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
