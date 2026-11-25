/* M5 exact local structure. No geometry, DOM or BSD dependency. */
(function(root){'use strict';
const C=root.McombCayleyCoreV1,VERSION='M5_0.1.0',LIMITS=Object.freeze({neighbors:1024,searchVertices:32,totalSteps:250000,packetBytes:16000000});
const fail=s=>{throw Error(s);},eq=(a,b)=>C.canonical(a)===C.canonical(b),key=x=>Array.isArray(x)?x.join(','):x;
function z(s){const n=C.integer(s);if(C.abs(n).toString(2).length>256)fail('M5 integer limit: 256 bits');return n;}
const sorted=a=>a.slice().sort((x,y)=>BigInt(x)<BigInt(y)?-1:BigInt(x)>BigInt(y)?1:0);
function frequencies(p){if(!Array.isArray(p)||p.length>360)fail('Frequency list limit');const ns=p.map(z);if(ns.some(n=>n<=0n)||!eq(p,sorted([...new Set(p)])))fail('Distinct ascending positive frequencies required');return ns;}
function definition(input){
 if(!input||typeof input!=='object')fail('Graph definition required');
 if(input.context==='ATOM_STRAND'){
  C.shape(input,['context','orders','origin','t']);if(!Array.isArray(input.orders)||input.orders.length>16)fail('Atom coordinate limit');
  const ns=input.orders.map(z);if(ns.some(n=>n<2n||n>65n))fail('Atom orders must be 2..65');
  const tuple=v=>{if(!Array.isArray(v)||v.length!==ns.length)fail('Atom tuple length');return v.map((s,i)=>{const n=z(s);if(n<0n||n>=ns[i])fail('Noncanonical exponent address');return n;});};
  const origin=tuple(input.origin),t=tuple(input.t),zero=ns.map(()=>0n),S=[];
  for(let i=0;i<ns.length;i++)for(let n=1n;n<ns[i];n++){const v=zero.slice();v[i]=n;S.push(v);}
  if(S.length>LIMITS.neighbors)fail('Neighborhood work limit');
  const add=(a,b)=>a.map((x,i)=>C.mod(x+b[i],ns[i])),neg=a=>a.map((x,i)=>C.mod(-x,ns[i])),member=a=>a.filter(x=>x!==0n).length===1;
  return {input:C.clone(input),S,origin,t,zero,add,neg,member,serialize:a=>a.map(String),ambientSize:ns.reduce((a,b)=>a*b,1n).toString(),relation:'COMPLETE_PRIME_STRANDS',lifting:null};
 }
 if(!['INTEGER_LABEL','QUOTIENT_SIMPLE'].includes(input.context))fail('Unknown graph context');
 C.shape(input,['context','positiveFrequencies','canonicalM','q','origin','t','u','comparisonQ']);const p=frequencies(input.positiveFrequencies),integer=input.context==='INTEGER_LABEL';
 const q=input.q===null?null:z(input.q);if(integer?q!==null:q===null||q<1n)fail('Ambient modulus/context mismatch');
 if(input.canonicalM!==null){const m=z(input.canonicalM);if(m<1n||m>720n)fail('Canonical comb range');const pos=Array.from({length:Number(m/2n)},(_,i)=>String(m%2n?i+1:2*i+1));if(!eq(pos,input.positiveFrequencies))fail('Canonical frequency mismatch');}
 const raw=[...p.map(x=>-x).reverse(),...p],S=integer?raw:raw.map(x=>C.mod(x,q));
 if(!integer&&(S.some(n=>n===0n)||new Set(S.map(String)).size!==S.length))fail('Simple conversion unavailable: loops or colliding signed labels; weighted L is not a simple graph');
 const origin=z(input.origin),t=z(input.t),u=z(input.u);if(!integer&&[origin,t].some(x=>x<0n||x>=q))fail('Quotient address must be canonical');
 const cq=input.comparisonQ===null?null:z(input.comparisonQ);if(cq!==null&&cq<1n)fail('Comparison modulus must be positive');
 if(!integer&&cq!==null&&cq!==q)fail('Quotient comparison must use its own modulus');
 const add=integer?(a,b)=>a+b:(a,b)=>C.mod(a+b,q),neg=integer?a=>-a:a=>C.mod(-a,q),set=new Set(S.map(String)),member=a=>set.has(String(a));
 return {input:C.clone(input),S,raw,origin,t,zero:0n,add,neg,member,serialize:String,ambientSize:integer?'INFINITE':String(q),relation:integer?'INTEGER_DIFFERENCE_SET':'QUOTIENT_DERIVED_SIMPLE',lifting:comparison(p,cq??q,u,t)};
}
function comparison(p,q,u,t){
 if(q===null)return {status:'NOT_REQUESTED'};if(!p.length)return {status:'TRIVIAL_EMPTY_FREQUENCIES',q:String(q),spectralEqualityClaim:false};
 const M=p.at(-1),S=[...p.map(x=>-x),...p],set=new Set(S.map(String)),res=new Set(S.map(x=>String(C.mod(x,q)))),pos=Array.from({length:5},(_,i)=>u+BigInt(i-2)*t),max=xs=>xs.reduce((a,b)=>C.abs(b)>a?C.abs(b):a,0n),boundaryPositions=S.flatMap(a=>[a-t,a+t]),fiveThreshold=M+max(pos),boundaryThreshold=M+max(boundaryPositions);
 return {status:'EXACT_COMPARISON',q:String(q),M:String(M),regime:q<=3n*M?'MODULAR_COMPARISON_MAY_DIFFER':q<=4n*M?'BOUNDARY_CLIQUE_UNIFORM_SCOPE_SAFE':'FIVE_POSITION_UNIFORM_SCOPE_SAFE',uniformBoundaryCliqueSafe:q>3n*M,uniformFivePositionSafe:q>4n*M,selectedFive:{u:String(u),t:String(t),positions:pos.map(String),integerPattern:pos.map(x=>set.has(String(x))?'1':'0').join(''),quotientPattern:pos.map(x=>res.has(String(C.mod(x,q)))?'1':'0').join(''),strictModulusThreshold:String(fiveThreshold),sufficient:q>fiveThreshold},generalBoundary:{testedPositions:boundaryPositions.map(String),strictModulusThreshold:String(boundaryThreshold),sufficient:q>boundaryThreshold},spectralEqualityClaim:false,spectralCaveat:'Graph lifting does not identify a sampled spectral minimum with the continuous minimum.'};
}
function graph(input){const d=definition(input),vertices=d.S.map(d.serialize),adj=vertices.map(()=>[]),edges=[];
 for(let i=0;i<d.S.length;i++)for(let j=i+1;j<d.S.length;j++)if(d.member(d.add(d.S[j],d.neg(d.S[i])))){adj[i].push(j);adj[j].push(i);edges.push([String(i),String(j)]);}
 const plus=d.S.filter(v=>d.member(d.add(v,d.neg(d.t)))),minus=d.S.filter(v=>d.member(d.add(v,d.t))),ps=new Set(plus.map(v=>key(d.serialize(v)))),ms=new Set(minus.map(v=>key(d.serialize(v)))),boundary=plus.filter(v=>!ms.has(key(d.serialize(v)))),reverse=minus.filter(v=>!ps.has(key(d.serialize(v))));
 const output={definitionVersion:VERSION,input:d.input,relation:d.relation,ambientSize:d.ambientSize,degree:String(vertices.length),origin:d.serialize(d.origin),neighborOffsets:vertices,neighborAddresses:d.S.map(v=>d.serialize(d.add(d.origin,v))),edges,edgeCount:String(edges.length),trianglesThroughOrigin:String(edges.length),orderedAdjacentPairs:String(2*edges.length),boundary:{t:d.serialize(d.t),scope:d.member(d.t)?'VERTEX_OF_H':'GENERAL_T_FULL_GRAPH',plus:plus.map(d.serialize),minus:minus.map(d.serialize),difference:boundary.map(d.serialize),size:String(boundary.length),symmetricDifferenceSize:String(boundary.length+reverse.length)},signedLabelMap:d.raw?d.raw.map((v,i)=>({label:String(v),neighborOffset:vertices[i]})):null,lifting:d.lifting};
 return {d,adj,output};
}
function color(candidates,adj){const sets=adj.map(xs=>new Set(xs)),classes=[];for(const v of candidates){let c=classes.find(xs=>xs.every(u=>!sets[v].has(u)));if(!c){c=[];classes.push(c);}c.push(v);}return classes;}
function greedy(candidates,adj){const sets=adj.map(xs=>new Set(xs)),out=[];for(const v of candidates)if(out.every(u=>sets[v].has(u)))out.push(v);return out;}
function createSearch(input,stepLimit=LIMITS.totalSteps){if(!Number.isSafeInteger(stepLimit)||stepLimit<1||stepLimit>LIMITS.totalSteps)fail("Local step limit");const g=graph(input),all=g.adj.map((_,i)=>i),colors=color(all,g.adj),a=greedy(all,g.adj),b=greedy(all.slice().reverse(),g.adj),best=a.length>=b.length?a:b;return {stepLimit,g,best,stack:all.length?[{clique:[],candidates:all}]:[],steps:0,colors,limitReason:all.length>LIMITS.searchVertices?'SEARCH_VERTEX_LIMIT':null};}
function advance(state,maxSteps=2000,milliseconds=200){if(!Number.isSafeInteger(maxSteps)||maxSteps<0||maxSteps>LIMITS.totalSteps||!Number.isFinite(milliseconds)||milliseconds<0)fail('Search slice budget');
 const start=Date.now(),sets=state.g.adj.map(xs=>new Set(xs));let done=0;
 while(!state.limitReason&&state.stack.length&&state.steps<state.stepLimit&&done<maxSteps&&Date.now()-start<milliseconds){
  const frame=state.stack.pop();state.steps++;done++;const {clique,candidates}=frame;
  if(clique.length>state.best.length)state.best=clique.slice();if(clique.length+color(candidates,state.g.adj).length<=state.best.length)continue;
  const rest=candidates.slice(),v=rest.pop(),inc=clique.concat(v);if(inc.length>state.best.length)state.best=inc;
  if(rest.length)state.stack.push({clique,candidates:rest});const eligible=rest.filter(u=>sets[v].has(u));if(eligible.length)state.stack.push({clique:inc,candidates:eligible});
 }
 return searchResult(state);
}
function searchResult(state){const {g}=state;let upper=state.best.length;
 if(state.limitReason)upper=Math.max(upper,state.colors.length);else for(const f of state.stack)upper=Math.max(upper,f.clique.length+color(f.candidates,g.adj).length);
 const exact=upper===state.best.length,off=state.best.map(i=>g.d.S[i]),full=[g.d.origin,...off.map(v=>g.d.add(g.d.origin,v))].map(g.d.serialize);
 return {status:exact?'EXACT':'PARTIAL',method:'DETERMINISTIC_BRANCH_AND_COLOR_BOUND_REPLAY',processedSteps:String(state.steps),searchVertexLimit:String(LIMITS.searchVertices),totalStepLimit:String(state.stepLimit),reason:exact?null:state.limitReason||(state.steps>=state.stepLimit?'TOTAL_STEP_LIMIT':'SLICE_OR_CANCELLED'),neighborhood:{lower:String(state.best.length),upper:String(upper),witnessIndices:state.best.map(String),witnessOffsets:off.map(g.d.serialize)},fullGraph:{lower:String(state.best.length+1),upper:String(upper+1),witness:full,justification:'Translation invariance: every clique can be translated to contain the origin; omega(G)=1+omega(H).'},rootColorClasses:state.colors.map(xs=>xs.map(String))};
}
function inspect(input,steps='0'){const n=z(steps);if(n<0n||n>BigInt(LIMITS.totalSteps))fail('Replay step limit');const s=createSearch(input);if(n)advance(s,Number(n),Number.MAX_SAFE_INTEGER);if(BigInt(s.steps)!==n)fail('Noncanonical search step count');return {structure:s.g.output,clique:searchResult(s)};}
function verifyWitness(input,witness){const {d}=graph(input);if(!Array.isArray(witness)||!witness.length||witness.length>LIMITS.neighbors+1)fail('Witness size');
 const parse=x=>{if(input.context==='ATOM_STRAND'){if(!Array.isArray(x)||x.length!==input.orders.length)fail('Witness tuple');return x.map((v,i)=>{const n=z(v);if(n<0n||n>=BigInt(input.orders[i]))fail('Witness coordinate');return n;});}const n=z(x);if(input.context==='QUOTIENT_SIMPLE'&&(n<0n||n>=BigInt(input.q)))fail('Witness residue');return n;};
 const vs=witness.map(parse);if(new Set(witness.map(key)).size!==vs.length)fail('Duplicate witness vertex');for(let i=0;i<vs.length;i++)for(let j=i+1;j<vs.length;j++)if(!d.member(d.add(vs[i],d.neg(vs[j]))))fail('Witness is not a clique');return true;
}
function preset(name){const common={canonicalM:null,origin:'0',t:'5',u:'5'};if(name==='S1')return {context:'INTEGER_LABEL',positiveFrequencies:['4','5'],q:null,comparisonQ:'19',...common};if(name==='S2_INTEGER')return {context:'INTEGER_LABEL',positiveFrequencies:['2','3','8'],q:null,comparisonQ:'19',...common,t:'3',u:'0'};if(name==='S2_QUOTIENT')return {...preset('S2_INTEGER'),context:'QUOTIENT_SIMPLE',q:'19'};fail('Unknown detached structure fixture');}

// Additional comparison; never replaces the canonical representative's positions.
function representativeComparison(input){if(input.context!=='QUOTIENT_SIMPLE')return {status:'NOT_APPLICABLE'};definition(input);const q=z(input.q),symmetric=n=>{const r=C.mod(n,q);return 2n*r>q?r-q:r;},u=symmetric(z(input.u)),t=symmetric(z(input.t));return {status:'ADDITIONAL_REPRESENTATIVE_COMPARISON',convention:'SIGNED_MINIMUM_ABSOLUTE_POSITIVE_HALF_TIE',canonical:{u:input.u,t:input.t},representatives:{u:String(u),t:String(t)},comparison:comparison(frequencies(input.positiveFrequencies),q,u,t),scope:'Integer patterns refer to these signed representatives only; quotient endpoints agree modulo q.'};}
root.McombStructureV1=Object.freeze({representativeComparison,VERSION,LIMITS,definition,graph,inspect,createSearch,advance,searchResult,verifyWitness,preset});
})(globalThis);
