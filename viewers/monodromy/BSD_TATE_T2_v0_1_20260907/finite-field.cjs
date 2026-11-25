'use strict';
// Complete factor/root witnesses for degree <=3, over the inherited bounded prime domain.
const T=require('../BSD_TATE_T1_v0_1_20260907/t1.cjs');
function polynomial(rationals,pString){
 T.primeProof(pString);const p=Number(pString);if(rationals.length<2||rationals.length>4)throw Error('Polynomial degree cap');
 const mod=n=>(n%p+p)%p,trim=a=>{a=a.slice();while(a.length>1&&a.at(-1)===0)a.pop();return a;};
 const coeffs=trim(rationals.map(x=>T.mod(x,p)));if(coeffs.length!==rationals.length)throw Error('Nonunit polynomial leading coefficient');
 const evalAt=(a,x)=>a.reduceRight((v,c)=>mod(v*x+c),0);
 const quotient=(a,r)=>{const q=Array(a.length-1);q[q.length-1]=a.at(-1);for(let i=q.length-2;i>=0;i--)q[i]=mod(a[i+1]+r*q[i+1]);if(mod(a[0]+r*q[0]))throw Error('Inexact root division');return trim(q);};
 let rest=coeffs.slice();const evaluations=Array.from({length:p},(_,i)=>String(evalAt(coeffs,i))),roots=[];
 for(let x=0;x<p;x++){let multiplicity=0;while(rest.length>1&&evalAt(rest,x)===0){rest=quotient(rest,x);multiplicity++;}if(multiplicity)roots.push({root:String(x),multiplicity:String(multiplicity)});}
 const residualEvaluations=rest.length>1?Array.from({length:p},(_,i)=>String(evalAt(rest,i))):[];
 if(residualEvaluations.includes('0'))throw Error('Incomplete factorization');
 // In degrees 2 and 3, a polynomial with no linear factor is irreducible.
 const residualDegree=rest.length-1;
 return {p:pString,rationalCoefficients:rationals,coefficients:coeffs.map(String),evaluations,roots,residualCoefficients:rest.map(String),residualEvaluations,residualStatus:residualDegree===0?'CONSTANT':'IRREDUCIBLE_DEGREE_'+residualDegree,separable:roots.every(r=>r.multiplicity==='1')};
}
module.exports={polynomial};
