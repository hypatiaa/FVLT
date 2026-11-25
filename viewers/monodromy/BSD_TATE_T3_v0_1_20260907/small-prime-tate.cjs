'use strict';
// General-equation Tate at 2 and 3. Residue choices are exhaustive, never backend supplied.
const T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),{polynomial}=require('../BSD_TATE_T2_v0_1_20260907/finite-field.cjs');
const {R,S,div,mul,pow}=T,neg=x=>S(mul(R('-1'),R(x))),val=(x,p)=>T.valuation(x,p),ex=(x,p)=>{const v=val(x,p);return v.kind==='INFINITY'?Infinity:Number(v.exponent);};
function compute(ainvs,pString,selectedMultiplier='1'){
 const primeProof=T.primeProof(pString),p=Number(pString);if(![2,3].includes(p))throw Error('UNAVAILABLE: T3 supports only primes 2 and 3; use T2 for tame primes');
 if(ainvs.some(x=>R(x)[1]%BigInt(p)===0n))throw Error('T3 source must be p-integral');
 R(selectedMultiplier);if(selectedMultiplier==='0')throw Error('Zero differential');
 let a=ainvs.slice(),multiplier=selectedMultiplier,composite={...T.ID},scales=0;const initial=T.model(a),events=[];
 const emit=e=>{if(events.length>=2048)throw Error('UNAVAILABLE: 2048-event trace cap');events.push(e);};
 const over=(x,e)=>S(div(R(x),pow(R(pString),e))),times=(x,e)=>String(BigInt(x)*BigInt(p)**BigInt(e));
 const change=(purpose,w)=>{const to=T.transform(a,w),after=S(div(R(multiplier),R(w.u)));to.forEach(R);if(to.some(x=>ex(x,p)<0))throw Error('Nonintegral change');emit({operation:'MODEL_CHANGE',purpose,fromModelId:T.model(a).modelId,toModelId:T.model(to).modelId,fromAinvs:a,toAinvs:to,urst:w,selectedMultiplierBefore:multiplier,selectedMultiplierAfter:after});a=to;multiplier=after;composite=T.compose(composite,w);};
 const translate=(purpose,r='0',s='0',t='0')=>change(purpose,{u:'1',r,s,t});
 const divisibility=(name,value,threshold)=>{const passes=ex(value,p)<threshold;emit({operation:'DIVISIBILITY_TEST',name,value,valuation:val(value,p),threshold:String(threshold),passes});return passes;};
 const requireVal=(name,thresholds)=>{const valuations=a.map(x=>val(x,p));if(a.some((x,i)=>ex(x,p)<thresholds[i]))throw Error('Tate precondition: '+name);emit({operation:'COEFFICIENT_DIVISIBILITY',name,ainvs:a,valuations,thresholds:thresholds.map(String)});};
 const poly=(purpose,coefficients,x=0,y=0)=>{const witness=polynomial(coefficients,pString);emit({operation:'RESIDUE_POLYNOMIAL',purpose,xLevel:String(x),yLevel:String(y),witness});return witness;};
 const doubleRoot=w=>{if(w.separable||w.roots.length!==1||w.roots[0].multiplicity!=='2')throw Error('Expected one double root');return w.roots[0].root;};
 function finish(kodaira,cp,split=null){
  const target=T.model(a),d=ex(target.invariants.discriminant,p);let reduction,fp,ap,eulerPolynomial,multiplicities,criterion;
  if(kodaira==='I0'){reduction='GOOD';fp=0;const count=T.count(a,p);emit({operation:'GOOD_FIBRE_COUNT',...count});ap=count.ap;eulerPolynomial=['1',String(-BigInt(ap)),pString];multiplicities=['1'];criterion='UNIT_DISCRIMINANT';}
  else if(/^I[1-9][0-9]*$/.test(kodaira)){const n=Number(kodaira.slice(1));if(n>256)throw Error('UNAVAILABLE: 256-component cap');reduction=split?'SPLIT_MULTIPLICATIVE':'NONSPLIT_MULTIPLICATIVE';fp=1;ap=split?'1':'-1';eulerPolynomial=['1',split?'-1':'1'];multiplicities=Array(n).fill('1');criterion='UNIT_C4';}
  else{reduction='ADDITIVE';ap='0';eulerPolynomial=['1'];criterion='TATE_ADDITIVE_TERMINAL';multiplicities=({II:['1'],III:['1','1'],IV:['1','1','1'],'IV*':['1','1','1','2','2','2','3'],'III*':['1','1','2','2','2','3','3','4'],'II*':['1','2','2','3','3','4','4','5','6']})[kodaira];if(!multiplicities){const n=Number(/^I(\d+)\*$/.exec(kodaira)?.[1]);if(!Number.isSafeInteger(n)||n>128)throw Error('UNAVAILABLE: I_n* index cap');multiplicities=['1','1','1','1',...Array(n+1).fill('2')];}fp=d+1-multiplicities.length;}
  const m=multiplicities.length,tame=reduction==='GOOD'?0:reduction==='ADDITIVE'?2:1;
  if(fp!==d+1-m||fp<tame||fp>(p===2?8:5))throw Error('Ogg/conductor bound failed');
  const minimalityWitness={criterion,modelId:target.modelId,terminalBranch:kodaira,rescalingCount:String(scales),valuationC4:val(target.invariants.c4,p),valuationDiscriminant:val(target.invariants.discriminant,p)};
  const conductorWitness={method:'OGG_FROM_TATE_COMPONENT_TYPE',minimalDiscriminantValuation:String(d),geometricComponents:String(m),tameContribution:String(tame)};
  const result={reduction,kodaira,split,discriminantValuation:String(d),conductorExponent:String(fp),wildConductorContribution:String(fp-tame),tamagawaNumber:String(cp),ap,eulerPolynomial,geometricComponents:String(m),componentMultiplicities:multiplicities,localMinimality:'PROVED_AT_THIS_PRIME',minimalityWitness,conductorWitness};
  return {schema:'BSD_SMALL_PRIME_TATE_TRACE_V1',p:pString,primeProof,sourceModelId:initial.modelId,sourceAinvs:ainvs,sourceSelectedMultiplier:selectedMultiplier,events,composite,targetModelId:target.modelId,targetAinvs:a,targetSelectedMultiplier:multiplier,result};
 }
 for(;;){
  const model=T.model(a),d=ex(model.invariants.discriminant,p);emit({operation:'BEGIN_TATE_PASS',modelId:model.modelId,ainvs:a,discriminantValuation:String(d),rescalingCount:String(scales)});
  if(d===0)return finish('I0',1);
  // F=0, F_x=0, F_y=0 selects the singular point, including characteristic 2.
  const b=a.map(x=>T.mod(x,p)),mod=x=>(x%p+p)%p,rows=[],roots=[];
  for(let x=0;x<p;x++)for(let y=0;y<p;y++){const f=mod(y*y+b[0]*x*y+b[2]*y-x*x*x-b[1]*x*x-b[3]*x-b[4]),fx=mod(b[0]*y-3*x*x-2*b[1]*x-b[3]),fy=mod(2*y+b[0]*x+b[2]);rows.push({x:String(x),y:String(y),f:String(f),fx:String(fx),fy:String(fy)});if(!f&&!fx&&!fy)roots.push({x:String(x),y:String(y)});}
  if(roots.length!==1)throw Error('Expected unique rational singular point');emit({operation:'SINGULAR_POINT_SEARCH',reducedAinvs:b.map(String),rows,selected:roots[0]});translate('CENTER_SINGULAR_POINT',roots[0].x,'0',roots[0].y);requireVal('SINGULAR_AT_ORIGIN',[0,0,1,1,1]);
  if(ex(model.invariants.c4,p)===0){const w=poly('MULTIPLICATIVE_TANGENTS',[neg(a[1]),a[0],'1']);if(!w.separable)throw Error('Nonseparable node tangents');const split=w.roots.length===2;return finish('I'+d,split?d:d%2?1:2,split);}
  const inv=T.model(a).invariants;
  if(divisibility('TYPE_II',a[4],2))return finish('II',1);
  if(divisibility('TYPE_III',inv.b8,3))return finish('III',2);
  if(divisibility('TYPE_IV',inv.b6,3)){const w=poly('TYPE_IV_COMPONENTS',[neg(over(a[4],2)),over(a[2],1),'1']);if(!w.separable)throw Error('Type IV polynomial inseparable');return finish('IV',w.roots.length===2?3:1);}
  // Search the small finite residue choices for s and t/p, retaining each test.
  const trials=[],choices=[];for(let s=0;s<p;s++)for(let z=0;z<p;z++){const w={u:'1',r:'0',s:String(s),t:String(p*z)},aa=T.transform(a,w),thresholds=[1,1,2,2,3],passes=aa.every((v,i)=>ex(v,p)>=thresholds[i]);trials.push({s:w.s,t:w.t,passes});if(passes)choices.push(w);}
  if(!choices.length)throw Error('No additive normalization found');emit({operation:'ADDITIVE_NORMALIZATION_SEARCH',trials,selected:choices[0]});change('NORMALIZE_ADDITIVE',choices[0]);requireVal('STAR_PREPARATION',[1,1,2,2,3]);
  const cubic=poly('STAR_CUBIC',[over(a[4],3),over(a[3],2),over(a[1],1),'1']);
  if(cubic.separable)return finish('I0*',1+cubic.roots.length);
  const repeated=cubic.roots.filter(r=>r.multiplicity!=='1');if(repeated.length!==1)throw Error('Invalid star cubic');const root=repeated[0];
  translate(root.multiplicity==='2'?'CENTER_DOUBLE_ROOT':'CENTER_TRIPLE_ROOT',times(root.root,1));
  if(root.multiplicity==='2'){
   let x=2,y=2;for(let round=0;round<64;round++){
    const wy=poly('STAR_ODD_COMPONENTS',[neg(over(a[4],x+y)),over(a[2],y),'1'],x,y);
    if(wy.separable)return finish('I'+(x+y-3)+'*',wy.roots.length===2?4:2);
    translate('REFINE_Y','0','0',times(doubleRoot(wy),y));emit({operation:'ADVANCE_LEVEL',axis:'Y',from:String(y),to:String(y+1)});y++;
    const wx=poly('STAR_EVEN_COMPONENTS',[over(a[4],x+y),over(a[3],x+1),over(a[1],1)],x,y);
    if(wx.separable)return finish('I'+(x+y-3)+'*',wx.roots.length===2?4:2);
    translate('REFINE_X',times(doubleRoot(wx),x));emit({operation:'ADVANCE_LEVEL',axis:'X',from:String(x),to:String(x+1)});x++;
   }throw Error('UNAVAILABLE: 64 star-refinement rounds');
  }
  if(root.multiplicity!=='3')throw Error('Invalid triple root');requireVal('TRIPLE_ROOT_CENTERED',[1,2,2,3,4]);
  const w=poly('TYPE_IV_STAR_COMPONENTS',[neg(over(a[4],4)),over(a[2],2),'1']);if(w.separable)return finish('IV*',w.roots.length===2?3:1);
  translate('CENTER_FINAL_DOUBLE_ROOT','0','0',times(doubleRoot(w),2));requireVal('FINAL_STAR_PREPARATION',[1,2,3,3,5]);
  if(divisibility('TYPE_III_STAR',a[3],4))return finish('III*',2);
  if(divisibility('TYPE_II_STAR',a[4],6))return finish('II*',1);
  requireVal('RESCALING_ALLOWED',[1,2,3,4,6]);if(++scales>32)throw Error('UNAVAILABLE: 32-rescaling cap');change('REMOVE_P_POWER',{u:pString,r:'0',s:'0',t:'0'});
 }
}
module.exports={compute};
