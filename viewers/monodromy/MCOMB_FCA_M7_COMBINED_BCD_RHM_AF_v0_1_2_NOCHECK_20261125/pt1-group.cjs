'use strict';
const T=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs');
const CAPS=Object.freeze({scalar:4096,additions:50000,subgroup:32,primes:32,visits:24,operations:32,bytes:2000000});
class Resource extends Error{constructor(s){super(s);this.name='PT1_RESOURCE';}}
const shape=(x,keys)=>{if(!x||typeof x!=='object'||Array.isArray(x)||Object.keys(x).sort().join('|')!==keys.slice().sort().join('|'))throw Error('PT1 unexpected fields');};
const same=(x,y,s='PT1 mismatch')=>{if(T.canonical(x)!==T.canonical(y))throw Error(s);};
const O=()=>({infinity:true}),eq=(x,y)=>T.canonical(x)===T.canonical(y),gcd=(a,b)=>{a=a<0n?-a:a;b=b<0n?-b:b;while(b)[a,b]=[b,a%b];return a;};
function scalar(n){if(typeof n!=='string'||! /^(0|-?[1-9][0-9]*)$/.test(n)||n.length>5)throw Error('Scalar syntax/cap');const k=Number(n);if(Math.abs(k)>CAPS.scalar)throw new Resource('Scalar cap');return k;}
function engine(ainvs){const model=T.model(ainvs),aa=ainvs.map(T.R);let additions=0;const {R,S,add,sub,mul,div,pow}=T;
 const on=p=>{if(!T.pointOn(ainvs,p))throw Error('Off-curve point');return p;};
 const neg=p=>{on(p);if(p.infinity)return O();return {x:p.x,y:S(sub(sub(R('0'),R(p.y)),add(mul(aa[0],R(p.x)),aa[2])))};};
 function plus(p,q){if(++additions>CAPS.additions)throw new Resource('Group operation cap');on(p);on(q);if(p.infinity)return {...q};if(q.infinity)return {...p};const [a1,a2,a3,a4]=aa,x=R(p.x),y=R(p.y),X=R(q.x),Y=R(q.y);let slope;
  if(p.x===q.x){if(eq(q,neg(p)))return O();same(p,q,'Equal-x points must coincide or be inverses');const d=add(add(mul(R('2'),y),mul(a1,x)),a3);if(!d[0])return O();slope=div(sub(add(add(mul(R('3'),pow(x,2)),mul(mul(R('2'),a2),x)),a4),mul(a1,y)),d);}
  else slope=div(sub(Y,y),sub(X,x));
  const nu=sub(y,mul(slope,x)),xx=sub(sub(sub(add(pow(slope,2),mul(a1,slope)),a2),x),X),yy=sub(sub(mul(sub(R('0'),add(slope,a1)),xx),nu),a3);return on({x:S(xx),y:S(yy)});
 }
 function times(p,n){let k=scalar(n);on(p);if(k<0){p=neg(p);k=-k;}let out=O();while(k){if(k%2)out=plus(out,p);k=Math.floor(k/2);if(k)p=plus(p,p);}return out;}
 function order(p,n){const k=scalar(n);if(k<1)throw Error('Positive order required');if(!times(p,n).infinity)throw Error('Order annihilator false');const factors=[];let m=k;for(let d=2;d<=m;d++)if(m%d===0){factors.push(String(d));if(times(p,String(k/d)).infinity)throw Error('Nonminimal order');while(m%d===0)m/=d;}return {point:p,order:n,primeDivisors:factors};}
 return {model,on,neg,plus,times,order,get additions(){return additions;}};
}
function sqrtInt(n){if(n<0n)return null;if(n<2n)return n;let x=1n<<BigInt(Math.ceil(n.toString(2).length/2)),y=(x+n/x)>>1n;while(y<x){x=y;y=(x+n/x)>>1n;}return x*x===n?x:null;}
function sqrtQ(s){const [n,d]=T.R(s),a=sqrtInt(n),b=sqrtInt(d);return a===null||b===null?null:T.S([a,b]);}
function lift(ainvs,x){T.R(x);const [a1,a2,a3,a4,a6]=ainvs.map(T.R),X=T.R(x),L=T.add(T.mul(a1,X),a3),rhs=T.add(T.add(T.add(T.pow(X,3),T.mul(a2,T.pow(X,2))),T.mul(a4,X)),a6),D=T.add(T.pow(L,2),T.mul(T.R('4'),rhs)),s=sqrtQ(T.S(D));if(s===null)return [];const ys=[T.S(T.div(T.sub(T.R(s),L),T.R('2'))),T.S(T.div(T.sub(T.mul(T.R('-1'),T.R(s)),L),T.R('2')))];return [...new Set(ys)].map(y=>({x,y}));}
function prime(s){if(typeof s!=='string'||! /^[1-9][0-9]{0,3}$/.test(s))throw Error('Prime syntax');const p=+s;if(p<3||p>1009||p%2===0)throw Error('Odd good-prime domain 3..1009');for(let d=3;d*d<=p;d+=2)if(p%d===0)throw Error('Composite prime');return p;}
function residue(s,p){const P=BigInt(p),[n,d]=T.R(s);let b=Number(d%P);if(!b)throw Error('Model not p-integral');let k=1;while(b*k%p!==1)k++;return Number((n%P+P)%P)*k%p;}
function count(ainvs,s){const p=prime(s),m=T.model(ainvs),a=ainvs.map(x=>residue(x,p)),unit=residue(m.invariants.discriminant,p);if(!unit)throw Error('Singular reduction');const squares=new Uint16Array(p);for(let y=0;y<p;y++)squares[y*y%p]++;let n=1;for(let x=0;x<p;x++){const l=(a[0]*x+a[2])%p,r=(x*x%p*x+a[1]*x*x+a[3]*x+a[4])%p;n+=squares[(l*l+4*r)%p];}return {p:s,modelId:m.modelId,unitDiscriminant:String(unit),pointsIncludingInfinity:String(n)};}
function mazur(invariants){const n=invariants.map(Number);if(n.length===0)return true;if(n.length===1&&[2,3,4,5,6,7,8,9,10,12].includes(n[0]))return true;if(n.length===2&&n[0]===2&&[2,4,6,8].includes(n[1]))return true;throw Error('MAZUR_CONSISTENCY_IMPLEMENTATION_ERROR');}
module.exports={T,CAPS,Resource,shape,same,O,eq,gcd,scalar,engine,sqrtQ,lift,prime,residue,count,mazur};
