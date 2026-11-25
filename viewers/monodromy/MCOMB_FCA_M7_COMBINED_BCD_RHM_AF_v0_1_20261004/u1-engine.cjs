'use strict';
const I=require('./u1-interval.cjs'),T=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs');
const {q,Z,ONE,parse,add,sub,mul,div,sqrt,square,K,pack,width}=I;
const exactSign=(x,A,B)=>{const y=x*x*x*A[1]*B[1]+A[0]*x*I.SCALE**2n*B[1]+B[0]*I.SCALE**3n*A[1];return y<0n?-1:y>0n?1:0;};
const cache=new Map();
function short(ainvs){const m=T.model(ainvs),v=m.invariants;return {model:m,A:T.S(T.div(T.R(v.c4),T.R('-48'))),B:T.S(T.div(T.R(v.c6),T.R('-864'))),shift:T.S(T.div(T.R(v.b2),T.R('12')))};}
function isolate(A,B,l,r){let sl=exactSign(l,A,B),sr=exactSign(r,A,B);if(!sl)return [l,l];if(!sr)return [r,r];if(sl===sr)throw new I.Resource('Root bracket unresolved');for(let k=0;k<260;k++){if(r-l<=1n<<48n)return [l,r];const c=(l+r)>>1n,s=exactSign(c,A,B);if(!s)return [c,c];if(s===sl){l=c;sl=s;}else{r=c;sr=s;}}throw new I.Resource('Root isolation cap');}
function modelData(ainvs){
 const key=JSON.stringify(ainvs);if(cache.has(key))return cache.get(key);
 for(const c of ainvs){const [n,d]=T.R(c);if((n<0n?-n:n)>1n<<80n||d>1n<<80n)throw new I.Resource('Coefficient range exceeds 80-bit numerator/denominator cap');}
 const s=short(ainvs),A=parse(s.A),B=parse(s.B),disc=T.R(s.model.invariants.discriminant)[0];if(!disc)throw Error('Singular curve');
 if(I.mag(A)[1]>I.SCALE*(1n<<40n)||I.mag(B)[1]>I.SCALE*(1n<<60n))throw new I.Resource('Short coefficient magnitude cap');
 const bound=I.ceil((I.mag(A)[1]>I.mag(B)[1]?I.mag(A)[1]:I.mag(B)[1]),I.SCALE)+2n,M=bound*I.SCALE,ar=T.R(s.A),br=T.R(s.B);let roots,h,m,omega1,imag;
 if(disc>0n){const c=sqrt(div(I.neg(A),q(3)));roots=[isolate(ar,br,-M,-c[1]),isolate(ar,br,-c[0],c[0]),isolate(ar,br,c[1],M)];h=sub(roots[2],roots[0]);m=div(sub(roots[1],roots[0]),h);omega1=div(mul(q(2),K(m)),sqrt(h));imag=div(mul(q(2),K(sub(ONE,m))),sqrt(h));}
 else{roots=[isolate(ar,br,-M,M)];h=sqrt(add(mul(q(3),square(roots[0])),A));m=div(sub(ONE,div(mul(q(3),roots[0]),mul(q(2),h))),q(2));omega1=div(mul(q(2),K(m)),sqrt(h));imag=div(K(sub(ONE,m)),sqrt(h));}
 if(omega1[0]<=0n||imag[0]<=0n)throw new I.Resource('Positive period not resolved');
 const data={...s,roots,h,m,omega1,imag,shape:disc>0n?'RECTANGULAR':'RHOMBIC',components:disc>0n?2:1};if(cache.size>=32)cache.delete(cache.keys().next().value);cache.set(key,data);return data;
}
function marking(matrix){if(!Array.isArray(matrix)||matrix.length!==2||matrix.some(r=>!Array.isArray(r)||r.length!==2||r.some(x=>typeof x!=='string')))throw Error('Marking must be a 2 by 2 matrix');T.phaseMap(['0','0'],matrix);return matrix.map(row=>row.map(s=>{if(T.R(s)[1]!==1n||BigInt(s)<-4096n||BigInt(s)>4096n)throw new I.Resource('Marking cap 4096');return parse(s);}));}
function uniform(ainvs,matrix=[['1','0'],['0','1']],selectedMultiplier='1'){
 const d=modelData(ainvs),M=marking(matrix),c=parse(selectedMultiplier);if(c[0]<=0n&&c[1]>=0n)throw Error('Zero selected differential');
 const base=[[d.omega1,Z],[d.shape==='RHOMBIC'?div(d.omega1,q(2)):Z,d.imag]],marked=M.map(row=>[0,1].map(j=>add(mul(row[0],base[0][j]),mul(row[1],base[1][j])))),selected=marked.map(row=>row.map(z=>mul(c,z))),realTotal=mul(q(d.components),d.omega1),tau=[d.shape==='RHOMBIC'?q(1,2):Z,div(d.imag,d.omega1)];
 for(const x of [d.omega1,d.imag,realTotal,...marked.flat(),...selected.flat()])if(width(x)[1]>I.mag(x)[1]/(1n<<80n)+I.SCALE/(1n<<80n))throw new I.Resource('Enclosure width target not reached');
 return {shape:d.shape,realComponents:d.components,shortModel:{A:d.A,B:d.B,xShift:d.shift},realRoots:d.roots.map(pack),primitiveReal:pack(d.omega1),omega2:base[1].map(pack),tau:tau.map(pack),conjugation:d.shape==='RHOMBIC'?[['1','0'],['1','-1']]:[['1','0'],['0','-1']],realAdaptedBasis:base.map(row=>row.map(pack)),marking:matrix,markedBasis:marked.map(row=>row.map(pack)),selectedMultiplier,selectedMarkedBasis:selected.map(row=>row.map(pack)),realTotal:pack(realTotal),widths:{primitiveReal:pack(width(d.omega1)),omega2Imag:pack(width(d.imag)),realTotal:pack(width(realTotal))},orientation:'omega1 positive real; Im(omega2)>0; selected differential sign recorded separately',method:'EXACT_DYADIC_ROOT_ISOLATION_AND_REAL_AGM',precisionBits:Number(I.BITS),scope:'RIGOROUS_NUMERICAL_ENCLOSURES_NO_RANK_LVALUES_OR_SHA'};
}
module.exports={uniform,modelData,short,marking,T,I};
