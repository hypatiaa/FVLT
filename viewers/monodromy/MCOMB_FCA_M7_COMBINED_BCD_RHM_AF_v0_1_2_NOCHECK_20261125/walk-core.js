/* Exact shell-walk sidecar. The audited atom and spectral engines are unchanged. */
(function(root){'use strict';
 const C=root.McombCayleyCoreV1,A=root.McombAtomCoreV1,SCHEMA='MCOMB_ATOM_SHELL_WALK_V1',CAP=12000000;
 const pins=Object.freeze({definition:'M4_WALK_0.3.0',predecessorManifest:'3f328133f351849a2accae002b7ac8b28ef8e8def8beaff88baa57dee27e2ab5'});
 const fail=s=>{throw Error(s);},str=String,zero=C.rat(0n),one=C.rat(1n),Q=C.json;
 const rational=s=>{const r=C.parse(s);if(C.text(r)!==s)fail('Noncanonical exact rational');return r;};
 const same=(a,b)=>C.canonical(a)===C.canonical(b);
 function context(h){
  C.shape(h,['schema','shell','position','s','t1','t2','m','amplitudeSign']);if(h.schema!=='M4_HOST_SHELL_CONTEXT_V1')fail('Shell context schema');
  C.shape(h.shell,['mode','base','factorialIndex']);const B=C.integer(h.shell.base);if(B<2n||B>6227020800n)fail('Shell base outside host domain');
  if(h.shell.mode==='factorial'){const n=C.integer(h.shell.factorialIndex);if(n<3n||n>13n)fail('Factorial index');let f=1n;for(let i=2n;i<=n;i++)f*=i;if(f!==B)fail('Factorial base mismatch');}
  else if(h.shell.mode!=='integer'||h.shell.factorialIndex!==null)fail('Direct base provenance');
  const p=h.position;let N=null;
  if(p.kind==='INTEGER_SHELL'){C.shape(p,['kind','phi3','N']);const phi=C.integer(p.phi3);N=C.integer(p.N);if(phi<0n||phi>B+1n||N!==B+1n-phi)fail('Shell position mismatch');}
  else if(p.kind==='BETWEEN_SHELLS'){
   C.shape(p,['kind','phi3Display','NDisplay']);const phi=Number(p.phi3Display),n=Number(p.NDisplay);
   if(!Number.isFinite(phi)||str(phi)!==p.phi3Display||Number.isInteger(phi)||phi<0||phi>Number(B+1n)||!Number.isFinite(n)||str(n)!==p.NDisplay||n!==Number(B+1n)-phi)fail('Between-shell display mismatch');
  }else fail('Shell position kind');
  const s=h.s===null?null:rational(h.s),t1=rational(h.t1),t2=rational(h.t2),m=C.integer(h.m);if(m<1n||m>720n)fail('Comb order');if(![-1,0,1].includes(h.amplitudeSign))fail('Amplitude sign');
  return {B,N,s,t1,t2,m};
 }
 function facts(h){
  const {B,N,s,t1,t2,m}=context(h),P=s===null?null:C.mul(t2,s),a=s===null?null:C.mul(t1,s),k=P!==null&&N!==null&&N>0n?C.div(P,C.rat(N)):null;
  const target=P===null?null:P.d===1n&&P.n!==0n?str(C.abs(P.n)):null;
  const targetStatus=P===null?'EXACT_SPIN_UNAVAILABLE':P.n===0n?'UNIVERSAL_ALIGNMENT':P.d!==1n?'NO_INTEGER_ATOM':'INTEGER_ATOM';
  const hit=!!(target&&k&&k.d===1n),universal=!!(P&&P.n===0n),axisCondition=a!==null&&a.d===1n,physical=h.amplitudeSign!==0;
  let state=N===null?'BETWEEN_SHELLS':N===0n?'OUTSIDE_POSITIVE_SHELL':P===null?'EXACT_SPIN_UNAVAILABLE':universal?'UNIVERSAL_ALIGNMENT':target===null?'NO_INTEGER_ATOM':hit?'DIVISOR_ENCOUNTER':'NO_DIVISOR_ENCOUNTER';
  const shift=C.rat(h.amplitudeSign<0?1n:0n),teeth=k===null?[]:C.offsets(Number(m)).map(c=>{
   const displacement=C.mul(C.rat(BigInt(c)),k),phasePi=C.add(C.add(a,displacement),shift),onAxis=physical&&phasePi.d===1n;
   return {c,phasePi:Q(phasePi),phaseTurns:Q(C.phase(C.div(phasePi,C.rat(2n)))),onRealAxis:onAxis,axisSide:!physical?'UNDEFINED_ZERO_AMPLITUDE':onAxis?(C.mod(phasePi.n,2n)===0n?'POSITIVE':'NEGATIVE'):'OFF_REAL_AXIS',carrierRelation:!physical?'UNDEFINED_ZERO_AMPLITUDE':displacement.d!==1n?'OFF_CARRIER_LINE':C.mod(displacement.n,2n)===0n?'AT_CARRIER':'OPPOSITE_CARRIER'};
  });
  const phases=new Set(teeth.map(t=>C.canonical(t.phaseTurns)));
  return {status:state,targetStatus,target,signedProduct:P===null?null:Q(P),carrierPi:a===null?null:Q(a),quotient:k===null?null:Q(k),shellMaximum:str(B+1n),divisorEncounter:hit,universalAlignment:universal,realAxisCondition:axisCondition,realAxisContact:(hit||universal&&N!==null&&N>0n)&&axisCondition&&physical,physicalStatus:physical?'NONZERO_AMPLITUDE':'ZERO_AMPLITUDE_NO_AXIS_EVIDENCE',teeth,allTeethCoincident:physical&&teeth.length>0?phases.size===1:null,allTeethOnCarrierLine:physical&&teeth.length>0?teeth.every(t=>t.carrierRelation!=='OFF_CARRIER_LINE'):null,arithmeticPromotion:false};
 }
 const geometryCache=new Map();
 function geometry(target,m,options){
  const key=C.canonical({target,m,options});if(geometryCache.has(key))return geometryCache.get(key);
  let input=A.preset(target);if(options!==null){C.shape(options,['start','step','character','chirality']);input={...input,...C.clone(options)};}
  // q=1 is only an internal assembly context. Its character-order outputs are
  // discarded; the displayed host spectral view is separately built below.
  const value=A.derive(input,A.sourceFor('1',m));value.characterOrders=null;value.characterOrdersMinusIdentity=null;
  const out=C.freeze({input,value});geometryCache.set(key,out);if(geometryCache.size>8)geometryCache.delete(geometryCache.keys().next().value);return out;
 }
 function source(h){const z=context(h);if(h.s===null||z.N===null||z.N<=0n||h.amplitudeSign===0)return null;return C.validateSource({N:str(z.N),s:h.s,t1:h.t1,t2:h.t2,m:h.m,amplitudeSign:h.amplitudeSign,offsets:C.offsets(Number(h.m))});}
 function exponentAddress(a,d){let n=BigInt(d);const x=a.factors.map(f=>{let e=0n,p=BigInt(f.prime);while(n%p===0n&&n>1n){e++;n/=p;}if(e>BigInt(f.exponent))fail('Encounter exponent exceeds atom');return str(e);});if(n!==1n)fail('Encounter not in atom');return x;}
 function derive(h,options=null){
  const walk=facts(h);let input=null,value=null,atomStatus=walk.targetStatus,reason=null;
  if(walk.target!==null){try{const g=geometry(walk.target,h.m,options);input=C.clone(g.input);value=C.clone(g.value);atomStatus='AVAILABLE';}catch(e){atomStatus='UNAVAILABLE';reason=e.message;}}
  let hostSpectrum=null;const s=source(h);if(s){try{hostSpectrum={source:s,L:A.spectralOrders(s),minus:Number(h.m)%2?A.spectralOrders(s,'L_MINUS_I'):null};}catch(e){hostSpectrum={status:'UNAVAILABLE',reason:e.message};}}
  if(value){value.characterOrders=hostSpectrum?.L||null;value.characterOrdersMinusIdentity=hostSpectrum?.minus||null;}
  const a=value?.atomRecord,selected=walk.divisorEncounter&&a?exponentAddress(a,h.position.N):null;
  const reachability=!a?{status:'NO_AVAILABLE_ATOM',limit:walk.shellMaximum,divisors:null}:BigInt(a.groupSize)>4096n?{status:'NOT_ENUMERATED',limit:walk.shellMaximum,rule:'d <= B+1',divisors:null}:{status:'COMPLETE',limit:walk.shellMaximum,divisors:A.allTuples(a.orders).map(x=>{const r=A.address(a,x,input.character);return {divisor:r.integerValue,exponents:x,reachable:BigInt(r.integerValue)<=BigInt(walk.shellMaximum)};}).sort((x,y)=>BigInt(x.divisor)<BigInt(y.divisor)?-1:1)};
  return {input,atomRecord:a||null,certificate:{status:'EXACT_SHELL_WALK_WITH_SEPARATE_NUMERICAL_GEOMETRY',value},selection:{atomAddress:selected,cosetRepresentative:value?.cosets.selectedRepresentative||null},walk:{...walk,atomStatus,reason,reachability},hostSpectrum};
 }
 function validateVisits(log,target){C.shape(log,['dropped','entries']);if(C.integer(log.dropped)<0n||!Array.isArray(log.entries)||log.entries.length>64)fail('Observed encounter log limit');for(const h of log.entries){const w=facts(h);if(!w.divisorEncounter||w.target!==target)fail('Observed encounter does not match current atom');}}
 async function construct(h,options=null,visits={dropped:'0',entries:[]}){
  const d=derive(h,options);validateVisits(visits,d.walk.target);const p={schema:SCHEMA,pins,context:C.clone(h),options:C.clone(options),visits:C.clone(visits),...d,exactDigest:''};p.exactDigest=await C.hash(C.canonical({...p,exactDigest:''}));if(new TextEncoder().encode(C.canonical(p)).length>CAP)fail('UNAVAILABLE: shell-walk packet exceeds 12000000-byte replay limit');return C.freeze(p);
 }
 function compare(a,b,path='$'){
  if(typeof a==='number'&&typeof b==='number'){if(!Number.isFinite(a)||!Number.isFinite(b)||Math.abs(a-b)>64*Number.EPSILON*Math.max(1,Math.abs(a),Math.abs(b)))fail('Shell-walk numerical mismatch '+path);return;}
  if(a&&b&&typeof a==='object'&&typeof b==='object'){if(Array.isArray(a)!==Array.isArray(b)||Object.keys(a).sort().join('|')!==Object.keys(b).sort().join('|'))fail('Shell-walk shape mismatch '+path);for(const k of Object.keys(b))compare(a[k],b[k],path+'.'+k);return;}if(a!==b)fail('Shell-walk exact mismatch '+path);
 }
 async function replay(bytes){
  if(typeof bytes!=='string'||new TextEncoder().encode(bytes).length>CAP)fail('Shell-walk byte cap');const parse=root.BSDStrictJSON||root.strictJSON;if(typeof parse!=='function')fail('Strict JSON parser required');const p=parse(bytes,CAP);
  C.shape(p,['schema','pins','context','options','visits','input','atomRecord','certificate','selection','walk','hostSpectrum','exactDigest']);if(p.schema!==SCHEMA||!same(p.pins,pins))fail('Shell-walk schema or definition pins');
  if(p.exactDigest!==await C.hash(C.canonical({...p,exactDigest:''})))fail('Shell-walk digest');const fresh=await construct(p.context,p.options,p.visits);compare({...p,exactDigest:''},{...fresh,exactDigest:''});return {status:'PASS',packet:fresh,arithmeticPromotion:false};
 }
 root.McombShellWalkV1=Object.freeze({SCHEMA,pins,context,facts,derive,construct,replay,source,exponentAddress});if(typeof module==='object')module.exports=root.McombShellWalkV1;
})(globalThis);
