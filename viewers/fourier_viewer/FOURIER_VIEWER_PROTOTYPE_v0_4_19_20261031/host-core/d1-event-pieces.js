(function(root){
'use strict';
// fv-d1-event-pieces 0_1_0 (v0.4.19, SCHEMA_ADDENDUM_26, verify finding 4 of v0.4.18). EXACT register: integers only (all far below 2^53).
// D1 (v0.4.16) cuts every base step of the lifted curve into sub = max(1, ceil(720/per_j)) parts. For Rule 30 rows j = 26 ... 34 (per_j >= 1024) that is
// sub = 1, so an event step was one straight chord: at q = 2 it joined antipodal fibre points (no visible direction), and at q = 1 it had length zero
// (the full forward fibre loop promised by the q = 1 caption was not drawn).
// Here, without changing the D1 core (host-core/rule30-ladder-core.js) or its fixture: every EVENT step t -> t+1 is cut into e pieces, with
//   e = sub when sub >= need, else e = sub * ceil(need/sub) (a multiple of sub, so every point of the old subdivision is kept),
//   need = 32 when q = 1 (the whole loop is visible), need = 16 otherwise.
// Point i of event step t (i = 0 ... e-1): base = (t*e + i)/(per_j*e) turns, fibre = (N_j(t)*e + i)/(q*e) turns, as exact (unreduced) pairs [num, den];
// the declared lift rule of D1 (forward on an event, linear in the step parameter) is unchanged, only drawn with more points.
// Base steps (no event) keep the old points of the core (sub parts). The last point is the core's own last point (k, k*S_j/q): the end is unchanged.
const NEED=16,NEED_Q1=32;
const needFor=q=>q===1?NEED_Q1:NEED;
// the smallest multiple of sub that is >= need (integer arithmetic only)
function eventParts(sub,q){const need=needFor(q);let e=sub;while(e<need)e+=sub;return e;}
// curve: the record of RL.curve(rule, j, q, {sub}); Nfn(t) = N_j(t) (the core's exact count)
function build(curve,Nfn){
  const sub=curve.sub,p=curve.per,q=curve.q,e=eventParts(sub,q),pts=[],starts=[];let evSteps=0;
  for(let t=0;t<curve.steps;t++){const first=curve.points[t*sub];starts.push(pts.length);
    if(!first.event||e===sub){for(let i=0;i<sub;i++)pts.push(curve.points[t*sub+i]);if(first.event)evSteps++;continue;}
    evSteps++;const n0=Nfn(t);
    for(let i=0;i<e;i++)pts.push({base:[t*e+i,p*e],fibre:[n0*e+i,q*e],event:1,t});}
  starts.push(pts.length);pts.push(curve.points[curve.points.length-1]);
  return {pts,starts,sub,e,need:needFor(q),evSteps,steps:curve.steps};
}
// a < b for exact pairs [num, den] (den > 0), by BigInt cross-multiplication
const lt=(a,b)=>BigInt(a[0])*BigInt(b[1])<BigInt(b[0])*BigInt(a[1]);
const eq=(a,b)=>BigInt(a[0])*BigInt(b[1])===BigInt(b[0])*BigInt(a[1]);
// the audit the view writes into the curve's data attributes: for every event step, the number of pieces, whether the fibre is strictly forward along
// every piece (from the step's first point to the next step's first point), and whether the base is strictly forward too.
function audit(b){
  let pmin=-1,pmax=-1,forward=0,notForward=0,baseForward=0;
  for(let s=0;s<b.steps;s++){const a=b.starts[s],z=b.starts[s+1];if(!b.pts[a].event)continue;
    const n=z-a;if(pmin<0||n<pmin)pmin=n;if(n>pmax)pmax=n;
    let f=true,g=true;for(let i=a;i<z;i++){if(!lt(b.pts[i].fibre,b.pts[i+1].fibre))f=false;if(!lt(b.pts[i].base,b.pts[i+1].base))g=false;}
    if(f)forward++;else notForward++;if(g)baseForward++;}
  return {pmin,pmax,forward,notForward,baseForward};
}
// the exact fibre values of one event step (its pieces' start points and the next step's first point), as "num/den" strings
function stepFibres(b,s){const a=b.starts[s],z=b.starts[s+1],out=[];for(let i=a;i<=z;i++)out.push(b.pts[i].fibre[0]+'/'+b.pts[i].fibre[1]);return out;}
function eventSteps(b){const out=[];for(let s=0;s<b.steps;s++)if(b.pts[b.starts[s]].event)out.push(s);return out;}
const api={VERSION:'fv-d1-event-pieces 0_1_0',NEED,NEED_Q1,needFor,eventParts,build,audit,stepFibres,eventSteps,lt,eq};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVD1Pieces=api;
})(typeof globalThis!=='undefined'?globalThis:this);
