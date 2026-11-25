/* Finite family display: exact integer invariants, separate Float64 paths. */
(function(root,factory){if(typeof module==='object'&&module.exports)module.exports=factory();else root.BSDCurveFamilyV1=factory();})(typeof window==='object'?window:globalThis,()=>{
 'use strict';
 const gcd=(a,b)=>{a=a<0n?-a:a;b=b<0n?-b:b;while(b)[a,b]=[b,a%b];return a;};
 const fraction=(n,d)=>{if(d<0n){n=-n;d=-d;}const g=gcd(n,d);return d/g===1n?String(n/g):`${n/g}/${d/g}`;};
 const equation=(a,b)=>`y² = x³${a?` ${a<0?'−':'+'} ${Math.abs(a)===1?'':Math.abs(a)}x`:''}${b?` ${b<0?'−':'+'} ${Math.abs(b)}`:''}`;
 function model(a,b){
  if(![-2,-1,0,1].includes(a)||![-1,0,1,2].includes(b))throw Error('Choose one of the 16 family tiles');
  const A=BigInt(a),B=BigInt(b),D=4n*A**3n+27n*B**2n,delta=-16n*D;
  return {a,b,key:`${a},${b}`,equation:equation(a,b),ainvs:['0','0','0',String(a),String(b)],discriminant:String(delta),j:D===0n?null:fraction(1728n*4n*A**3n,D),singular:D===0n,realComponents:D===0n?null:delta>0n?2:1,method:'EXACT_INTEGER_SHORT_MODEL_INVARIANTS',arithmeticPromotion:false};
 }
 const models=()=>[-2,-1,0,1].flatMap(a=>[-1,0,1,2].map(b=>model(a,b)));
 function relation(a,b){const c=model(a,b),peers=models().filter(k=>c.j!==null&&k.j===c.j&&k.key!==c.key);return {peers:peers.map(k=>k.key),kind:c.singular?'SINGULAR':c.j==='0'?'SEXTIC_TWISTS':c.j==='1728'?'QUARTIC_TWISTS':peers.length?'QUADRATIC_TWIST_MINUS_ONE':'NO_SAME_J_IN_GRID'};}
 function roots(a,b){
  const c=model(a,b),D=4*a*a*a+27*b*b;if(c.singular)return [0];
  if(D>0){const r=Math.sqrt(D/108);return [Math.cbrt(-b/2+r)+Math.cbrt(-b/2-r)];}
  const r=2*Math.sqrt(-a/3),t=Math.acos((3*b/(2*a))*Math.sqrt(-3/a))/3;
  return [0,1,2].map(k=>r*Math.cos(t-2*Math.PI*k/3)).sort((x,y)=>x-y);
 }
 const allRoots=models().flatMap(c=>roots(c.a,c.b)),lo=Math.min(...allRoots),hi=Math.max(...allRoots),span=hi-lo;
 const xDomain=[lo-.17*span,hi+.17*span];
 function paths(a,b){
  const r=roots(a,b),branch=(left,right)=>{const upper=Array.from({length:241},(_,i)=>{const x=left+(right-left)*Math.sin(i*Math.PI/480)**2;return [x,Math.sqrt(Math.max(0,x*x*x+a*x+b))];});return upper.slice().reverse().map(([x,y])=>[x,-y]).concat(upper);};
  return r.length===3?[branch(r[0],r[1]),branch(r[2],xDomain[1])]:[branch(r[0],xDomain[1])];
 }
 const ymax=Math.max(...models().flatMap(c=>paths(c.a,c.b).flat().map(p=>Math.abs(p[1]))))*1.08;
 function plot(a,b){model(a,b);return {status:'NUMERICAL_FLOAT64_DISPLAY',xDomain:[...xDomain],yDomain:[-ymax,ymax],paths:paths(a,b),pointEvidence:[],arithmeticPromotion:false};}
 return Object.freeze({model,models,relation,plot});
});
