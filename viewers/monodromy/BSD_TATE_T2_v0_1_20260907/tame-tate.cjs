'use strict';
// A short-form implementation of tame Tate over Q_p, with exact decision witnesses.
// It computes from the input equation; no backend result supplies a branch or c_p.
const T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs'),{polynomial}=require('./finite-field.cjs');
const {R,S,add,sub,mul,div,pow}=T;
const neg=x=>S(mul(R('-1'),R(x))),over=(s,p,e)=>S(div(R(s),pow(R(String(p)),e)));
const v=(s,p)=>T.valuation(s,p),ex=(s,p)=>{const a=v(s,p);return a.kind==='INFINITY'?Infinity:Number(a.exponent);};
function compute(ainvs,pString,selectedMultiplier='1'){
 const primeProof=T.primeProof(pString),p=Number(pString);if(p<5)throw Error('UNAVAILABLE: T2 is restricted to 5 <= p <= 1009; use T1 for its small-prime proofs');
 if(ainvs.some(s=>R(s)[1]%BigInt(p)===0n))throw Error('T2 source must be p-integral');
 let a=ainvs.slice(),composite={...T.ID},multiplier=selectedMultiplier;R(multiplier);if(multiplier==='0')throw Error('Zero differential');const events=[];
 const emit=e=>{if(events.length>=512)throw Error('UNAVAILABLE: 512-event trace cap');events.push(e);};
 const change=(purpose,w)=>{const from=a,to=T.transform(a,w),after=S(div(R(multiplier),R(w.u)));to.forEach(R);emit({operation:'MODEL_CHANGE',purpose,fromModelId:T.model(from).modelId,toModelId:T.model(to).modelId,fromAinvs:from,toAinvs:to,urst:w,selectedMultiplierBefore:multiplier,selectedMultiplierAfter:after});a=to;composite=T.compose(composite,w);multiplier=after;};
 const initial=T.model(a),r=S(div(R(neg(initial.invariants.b2)),R('12'))),s=S(div(R(neg(a[0])),R('2')));
 const t=S(div(sub(R('0'),add(R(a[2]),mul(R(a[0]),R(r)))),R('2')));
 change('SHORT_FORM',{u:'1',r,s,t});if(a.slice(0,3).some(s=>s!=='0'))throw Error('Short form failed');
 let scales=0;while(ex(a[3],p)>=4&&ex(a[4],p)>=6){if(++scales>32)throw Error('UNAVAILABLE: 32-rescaling cap');change('REMOVE_P_POWER',{u:pString,r:'0',s:'0',t:'0'});}
 const min=T.model(a),n=ex(min.invariants.discriminant,p),minimality={modelId:min.modelId,shortA:a[3],shortB:a[4],valuationA:v(a[3],p),valuationB:v(a[4],p),criterion:'V_A_LT_4_OR_V_B_LT_6_AT_P_GE_5'};
 emit({operation:'MINIMAL_SHORT',...minimality,discriminantValuation:String(n)});
 function test(name,value,threshold){const valuation=v(value,p),passes=ex(value,p)<threshold;emit({operation:'DIVISIBILITY_TEST',name,value,valuation,threshold:String(threshold),passes});return passes;}
 function poly(purpose,coefficients,xLevel='0',yLevel='0'){const witness=polynomial(coefficients,pString);emit({operation:'RESIDUE_POLYNOMIAL',purpose,xLevel,yLevel,witness});return witness;}
 function finish(kodaira,cp,split=null){
  let reduction,fp,ap,eulerPolynomial,multiplicities;
  if(kodaira==='I0'){reduction='GOOD';fp=0;const counted=T.count(a,p);emit({operation:'GOOD_FIBRE_COUNT',...counted});ap=counted.ap;eulerPolynomial=['1',String(-BigInt(ap)),pString];multiplicities=['1'];}
  else if(/^I[1-9][0-9]*$/.test(kodaira)){const k=Number(kodaira.slice(1));reduction=split?'SPLIT_MULTIPLICATIVE':'NONSPLIT_MULTIPLICATIVE';fp=1;ap=split?'1':'-1';eulerPolynomial=['1',split?'-1':'1'];multiplicities=Array(k).fill('1');}
  else{reduction='ADDITIVE';fp=2;ap='0';eulerPolynomial=['1'];multiplicities=({II:['1'],III:['1','1'],IV:['1','1','1'],'IV*':['1','1','1','2','2','2','3'],'III*':['1','1','2','2','2','3','3','4'],'II*':['1','2','2','3','3','4','4','5','6']})[kodaira];if(!multiplicities){const k=Number(/^I(\d+)\*$/.exec(kodaira)?.[1]);if(!Number.isSafeInteger(k)||k>128)throw Error('UNAVAILABLE: I_n* index cap');multiplicities=['1','1','1','1',...Array(k+1).fill('2')];}}
  if(multiplicities.length>256)throw Error('UNAVAILABLE: component count cap');
  const components=multiplicities.length;if(n+1-components!==fp)throw Error('Ogg conductor identity failed');
  const result={reduction,kodaira,split,discriminantValuation:String(n),conductorExponent:String(fp),wildConductorContribution:'0',tamagawaNumber:String(cp),ap,eulerPolynomial,geometricComponents:String(components),componentMultiplicities:multiplicities,localMinimality:'PROVED_AT_THIS_PRIME',minimalityWitness:minimality};
  return {schema:'BSD_TAME_TATE_TRACE_V1',p:pString,primeProof,sourceModelId:initial.modelId,sourceAinvs:ainvs,sourceSelectedMultiplier:selectedMultiplier,events,composite,targetModelId:T.model(a).modelId,targetAinvs:a,targetSelectedMultiplier:multiplier,result};
 }
 if(n===0)return finish('I0',1);
 if(ex(min.invariants.c4,p)===0){const w=poly('MULTIPLICATIVE_SPLIT',[min.invariants.c6,'0','1']);const split=w.roots.length===2;return finish('I'+n,split?n:n%2?1:2,split);}
 if(test('TYPE_II',a[4],2))return finish('II',1);
 if(test('TYPE_III',a[3],2))return finish('III',2);
 if(test('TYPE_IV',a[4],3)){const w=poly('TYPE_IV_COMPONENTS',[neg(over(a[4],p,2)),'0','1']);return finish('IV',w.roots.length===2?3:1);}
 const cubic=poly('STAR_CUBIC',[over(a[4],p,3),over(a[3],p,2),'0','1']);
 if(cubic.separable)return finish('I0*',1+cubic.roots.length);
 const repeated=cubic.roots.filter(r=>r.multiplicity!=='1');if(repeated.length!==1)throw Error('Invalid repeated-root cubic');
 const root=repeated[0];change(root.multiplicity==='2'?'CENTER_DOUBLE_ROOT':'CENTER_TRIPLE_ROOT',{u:'1',r:String(BigInt(root.root)*BigInt(p)),s:'0',t:'0'});
 if(root.multiplicity==='2'){
  let x=2,y=2;
  for(let round=0;round<64;round++){
   const wy=poly('STAR_ODD_COMPONENTS',[neg(over(a[4],p,x+y)),'0','1'],String(x),String(y));
   if(wy.separable)return finish('I'+(x+y-3)+'*',wy.roots.length===2?4:2);
   if(wy.roots.length!==1||wy.roots[0].root!=='0'||wy.roots[0].multiplicity!=='2')throw Error('Invalid odd double root');
   emit({operation:'ADVANCE_LEVEL',axis:'Y',from:String(y),to:String(y+1)});y++;
   const wx=poly('STAR_EVEN_COMPONENTS',[over(a[4],p,x+y),over(a[3],p,x+1),over(a[1],p,1)],String(x),String(y));
   if(wx.separable)return finish('I'+(x+y-3)+'*',wx.roots.length===2?4:2);
   if(wx.roots.length!==1||wx.roots[0].multiplicity!=='2')throw Error('Invalid even double root');
   change('REFINE_DOUBLE_ROOT',{u:'1',r:String(BigInt(wx.roots[0].root)*BigInt(p)**BigInt(x)),s:'0',t:'0'});
   emit({operation:'ADVANCE_LEVEL',axis:'X',from:String(x),to:String(x+1)});x++;
  }
  throw Error('UNAVAILABLE: 64 I_n* refinement rounds');
 }
 if(root.multiplicity!=='3')throw Error('Invalid triple root');
 const w=poly('TYPE_IV_STAR_COMPONENTS',[neg(over(a[4],p,4)),'0','1']);
 if(w.separable)return finish('IV*',w.roots.length===2?3:1);
 if(test('TYPE_III_STAR',a[3],4))return finish('III*',2);
 if(test('TYPE_II_STAR',a[4],6))return finish('II*',1);
 throw Error('Nonminimal terminal contradicts short-form minimality witness');
}
module.exports={compute};
