'use strict';
// v0.4.19 test-v0419-pens (SCHEMA_ADDENDUM_26, items 4 and 6): node-side checks of the two pixel certificates (pen-interval-core pixelCert) and of the
// dodecahedron edges drawn as great-circle arcs (pen-sphere-core dodecaArc). Integers and BigInt only.
const IV=require('./pen-interval-core.js'),SP=require('./pen-sphere-core.js'),FQ=require('./field-q2-q5-tau.js'),ST=require('./pen-streams-core.js');
const K=FQ.K;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
// ---- pixelCert on hand-made enclosures at W = 8 (1 unit = 1/256), R = 1 px per unit value, offset 100
{const W=8n,R=1n,S=256n;
  const c1=IV.pixelCert(IV.iv(10n*S+64n,10n*S+96n),W,R,100n,false);   // [2624, 2656]/256 px: narrow, inside pixel 10
  ok('pixelCert: [2624, 2656]/256 px is ≤ ¼ px wide and decided (pixel 110 = 100 + floor 10)',c1.ok&&!c1.wide&&!c1.undecided&&c1.p===110n,JSON.stringify(c1,(k,v)=>typeof v==='bigint'?String(v):v));
  const c2=IV.pixelCert(IV.iv(10n*S+224n,11n*S+16n),W,R,100n,false); // [2784, 2832]/256: narrow but straddles the edge 11
  ok('pixelCert: [2784, 2832]/256 px is ≤ ¼ px wide but undecided (straddles the edge at 11)',c2.ok&&!c2.wide&&c2.undecided);
  const c3=IV.pixelCert(IV.iv(10n*S,11n*S),W,R,100n,false);           // 1 px wide
  ok('pixelCert: a 1 px wide enclosure is counted wider than ¼ px (and undecided: [10, 11] reaches the edge 11)',!c3.ok&&c3.wide&&c3.undecided);
  const c4=IV.pixelCert(IV.pt(11n*S),W,R,100n,false);                  // an exact value on an edge
  ok('pixelCert: an exact point on an edge is decided (floor(lo) = floor(hi))',c4.ok&&!c4.undecided&&c4.p===111n);
  const c5=IV.pixelCert(IV.iv(10n*S+16n,10n*S+48n),W,R,100n,true);    // flipped: 100 - [2576, 2608]/256
  ok('pixelCert, flipped axis: 100 − [2576, 2608]/256 is decided',!c5.undecided&&!c5.wide);
  const c6=IV.pixelCert(IV.iv(10n*S-16n,10n*S+16n),W,R,100n,true);    // flipped: 100 - [2544, 2576]/256 straddles 90
  ok('pixelCert, flipped axis: 100 − [2544, 2576]/256 is undecided (edge 90)',c6.undecided&&!c6.wide);
  const c7=IV.pixelCert(IV.pt(10n*S),W,R,100n,true);                  // flipped exact: 90 exactly
  ok('pixelCert, flipped axis: an exact 100 − 10 = 90 is decided',!c7.undecided);
  const old=IV.pixel(IV.iv(10n*S+64n,10n*S+96n),W,R,100n,false);ok('pixelCert agrees with the v0.4.18 pixel (same p, same ok)',old.p===c1.p&&old.ok===c1.ok);}
// ---- dodecahedron arcs
{const st=SP.dodecaStructure(null),P=96n,S=1n<<P,cosA=SP.DODECA.ca;
  // all 60 directed edges (flag x -> x of its two successors)
  const edges=new Map();let f=SP.DSTART;const q=[f],seen=new Set([SP.dFlagKey(f)]);
  while(q.length){const g=q.shift();for(const sg of [1,-1]){const h=SP.dodecaStep(g,sg);edges.set(SP.kKey(g.x)+'|'+SP.kKey(h.x),[g.x,h.x]);if(!seen.has(SP.dFlagKey(h))){seen.add(SP.dFlagKey(h));q.push(h);}}}
  ok('the dodecahedron preset has 60 directed edges (30 edges, both directions), each joining two vertices at x·y = √5/3',edges.size===60&&[...edges.values()].every(([a,b])=>K.eq(SP.kDot(a,b),cosA)));
  let pts=0,unit=true,plane=true,between=true,wide=0,und=0,cached=true;const R=140n,cx=160n;
  const dotIv=(x,a)=>[0,1,2].reduce((s,i)=>IV.add(s,IV.mul(x[i],K.toIv(a[i],P),P)),IV.pt(0n));
  const cosIv=K.toIv(cosA,P);
  for(const [a,b] of edges.values()){const arc=SP.dodecaArc(a,b,P);if(arc!==SP.dodecaArc(a,b,P))cached=false;
    const n=[K.sub(K.mul(a[1],b[2]),K.mul(a[2],b[1])),K.sub(K.mul(a[2],b[0]),K.mul(a[0],b[2])),K.sub(K.mul(a[0],b[1]),K.mul(a[1],b[0]))];   // a x b, exact
    for(const x of arc){pts++;
      const n2=x.reduce((s,e)=>IV.add(s,IV.sqr(e,P)),IV.pt(0n));if(!(n2.lo<=S&&S<=n2.hi))unit=false;
      const d=dotIv(x,n);if(!(d.lo<=0n&&0n<=d.hi))plane=false;
      const da=dotIv(x,a),db=dotIv(x,b);if(da.hi<cosIv.lo||db.hi<cosIv.lo)between=false;
      for(const [e,fl] of [[x[0],false],[x[2],true]]){const c=IV.pixelCert(e,P,R,cx,fl);if(c.wide)wide++;if(c.undecided)und++;}}}
  ok('every arc point ('+pts+' = 60 × '+(SP.ARC_PIECES-1)+'): |x|² ∋ 1 (on the sphere)',unit&&pts===60*(SP.ARC_PIECES-1));
  ok('every arc point lies on the great circle of its edge: (a × b)·x ∋ 0',plane);
  ok('every arc point lies on the minor arc: x·a and x·b are not below cos α = √5/3 (enclosures)',between);
  ok('arc points at the card scale (R = 140 px, world axes): enclosure wider than ¼ px on an axis: '+wide+' (expected 0); pixel-edge straddles counted: '+und,wide===0);
  ok('the arcs are cached per (a, b, P): a second call returns the same object',cached);
  // the card's run: Rule 30, T = 1328 on the preset; arcs per step
  const s=ST.caRun(30,1328).s,fl=SP.dodecaPen(s,1328),arcs=SP.dodecaArcs(fl,P);
  ok('Rule 30, T = 1328 on the preset: '+arcs.length+' steps, each drawn with '+(SP.ARC_PIECES-1)+' interior arc points',arcs.length===1328&&arcs.every(a=>a.length===SP.ARC_PIECES-1));}
console.log('SUMMARY test-v0419-pens: '+pass+' passed, '+fail+' failed');process.exitCode=fail?1:0;
