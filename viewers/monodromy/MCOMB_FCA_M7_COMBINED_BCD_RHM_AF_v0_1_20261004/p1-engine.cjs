'use strict';
const U=require('./u1-engine.cjs'),G=require('./pt1-group.cjs'),{I,T}=U;
const {q,Z,ONE,parse,add,sub,mul,div,sqrt,pack}=I;
function incomplete(r,m){
 if(r[0]<0n||r[1]>I.SCALE)throw new I.Resource('Incomplete-integral endpoint unresolved');
 if(r[1]===0n)return Z;if(r[0]===I.SCALE)return I.K(m);
 if(r[1]<=I.SCALE/2n){const t=sqrt(div(r,sub(ONE,r)));return I.integrate([ONE,Z,sub(q(2),m),Z,sub(ONE,m)],t);}
 const t=sqrt(div(sub(ONE,r),r));return sub(I.K(m),I.integrate([sub(ONE,m),Z,sub(q(2),m),Z,ONE],t));
}
function wrap(a){
 const first=I.floor(a[0],I.SCALE)-(a[0]%I.SCALE===0n?1n:0n),last=I.floor(a[1],I.SCALE);if(last-first>3n)throw new I.Resource('Wrapped enclosure too wide');const out=[];
 for(let k=first;k<=last;k++){const l=a[0]>k*I.SCALE?a[0]:k*I.SCALE,h=a[1]<(k+1n)*I.SCALE?a[1]:(k+1n)*I.SCALE;if(l<=h)out.push({interval:pack([l-k*I.SCALE,h-k*I.SCALE]),shift:String(k)});}
 return out;
}
function locate(ainvs,point,matrix=[['1','0'],['0','1']],selectedMultiplier='1'){
 if(!T.pointOn(ainvs,point))throw Error('P1 off-curve exact point');const d=U.modelData(ainvs),M=U.marking(matrix);let alpha=Z,beta=Z,component='IDENTITY',log=Z;
 if(!point.infinity){const X=add(parse(point.x),parse(d.shift)),rr=T.R,aa=ainvs.map(rr),Y=T.add(rr(point.y),T.div(T.add(T.mul(aa[0],rr(point.x)),aa[2]),rr('2'))),positive=Y[0]>0n;
  if(!Y[0]){
   const which=d.roots.findIndex(r=>r[0]<=X[1]&&X[0]<=r[1]);if(which<0)throw new I.Resource('Exact root not isolated');
   if(d.components===1||which===2){alpha=q(1,2);}else{component='SECOND';beta=q(1,2);alpha=which===1?q(1,2):Z;}log=mul(alpha,d.omega1);
  }else if(d.components===2){
   let F;if(X[0]>d.roots[2][1]){const s=div(d.h,sub(X,d.roots[0]));F=div(incomplete(s,d.m),sqrt(d.h));log=positive?sub(d.omega1,F):F;}
   else if(X[0]>d.roots[0][1]&&X[1]<d.roots[1][0]){component='SECOND';beta=q(1,2);const s=div(sub(X,d.roots[0]),sub(d.roots[1],d.roots[0]));F=div(incomplete(s,d.m),sqrt(d.h));log=positive?F:sub(d.omega1,F);}
   else throw new I.Resource('Real component not separated from a root');
   alpha=div(log,d.omega1);
  }else{
   const t2=div(sub(X,d.roots[0]),d.h),coeff=[ONE,Z,div(mul(q(3),d.roots[0]),d.h),Z,ONE];let z;
   if(t2[0]>=I.SCALE)z=div(I.integrate(coeff,sqrt(div(ONE,t2))),sqrt(d.h));
   else{if(t2[0]<0n)throw new I.Resource('Rhombic endpoint unresolved');z=sub(div(d.omega1,q(2)),div(I.integrate(coeff,sqrt(t2)),sqrt(d.h)));}
   log=positive?sub(d.omega1,z):z;alpha=div(log,d.omega1);
  }
 }
 const marked=[sub(mul(M[1][1],alpha),mul(M[1][0],beta)),sub(mul(M[0][0],beta),mul(M[0][1],alpha))];
 for(const x of [alpha,beta,...marked])if(x[1]-x[0]>I.SCALE/(1n<<70n))throw new I.Resource('Point-placement width target not reached');
 const representatives=wrap(marked[0]).flatMap(a=>wrap(marked[1]).map(b=>({address:[a.interval,b.interval],shift:[a.shift,b.shift]})));
 return {component,realLog:pack(log),selectedRealLog:pack(mul(log,parse(selectedMultiplier))),realAdaptedAddress:[pack(alpha),pack(beta)],markedUnwrapped:marked.map(pack),representatives,wrapBoundary:representatives.length>1,method:'ENCLOSED_REAL_INTEGRAL_PLUS_EXACT_COMPONENT',scope:'NUMERICAL_ENCLOSURE_NOT_AN_ORDER_OR_RANK_PROOF'};
}
function integerIn(a){return I.ceil(a[0],I.SCALE)<=I.floor(a[1],I.SCALE);}
function consistency(out,base,n){const nn=parse(n);return out.markedUnwrapped.every((x,j)=>integerIn(sub(mul(nn,I.unpack(base.markedUnwrapped[j])),I.unpack(x))));}
module.exports={locate,wrap,integerIn,consistency,incomplete,U,G};
