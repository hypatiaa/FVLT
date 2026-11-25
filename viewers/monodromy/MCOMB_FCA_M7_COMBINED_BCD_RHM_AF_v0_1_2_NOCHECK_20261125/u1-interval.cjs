'use strict';
// Fixed dyadic intervals. Every operation encloses the exact real result.
const BITS=192n,SCALE=1n<<BITS,Z=[0n,0n],ONE=[SCALE,SCALE];
class Resource extends Error{constructor(s){super(s);this.name='U1_RESOURCE';}}
const floor=(n,d)=>{if(d<0n){n=-n;d=-d;}if(!d)throw new Resource('Zero denominator');let q=n/d;if(n<0n&&n%d)q--;return q;};
const ceil=(n,d)=>-floor(-n,d),abs=n=>n<0n?-n:n;
const isqrt=n=>{if(n<0n)throw Error('Negative square root');if(n<2n)return n;let a=1n<<BigInt(Math.ceil(n.toString(2).length/2)),b=(a+n/a)>>1n;while(b<a){a=b;b=(a+n/a)>>1n;}return a;};
const q=(n,d=1n)=>{n=BigInt(n);d=BigInt(d);if(!d)throw Error('Zero denominator');return [floor(n*SCALE,d),ceil(n*SCALE,d)];};
const parse=s=>{if(typeof s!=='string'||! /^(0|-?[1-9][0-9]*)(\/[1-9][0-9]*)?$/.test(s)||s.length>196)throw Error('Rational syntax/cap');const [n,d='1']=s.split('/');return q(n,d);};
const add=(a,b)=>[a[0]+b[0],a[1]+b[1]],neg=a=>[-a[1],-a[0]],sub=(a,b)=>add(a,neg(b));
const mul=(a,b)=>{const v=[a[0]*b[0],a[0]*b[1],a[1]*b[0],a[1]*b[1]],lo=v.reduce((x,y)=>x<y?x:y),hi=v.reduce((x,y)=>x>y?x:y);return [floor(lo,SCALE),ceil(hi,SCALE)];};
const div=(a,b)=>{if(b[0]<=0n&&b[1]>=0n)throw new Resource('Division interval contains zero');return mul(a,[floor(SCALE*SCALE,b[1]),ceil(SCALE*SCALE,b[0])]);};
const sqrt=a=>{if(a[0]<0n)throw new Resource('Square-root sign unresolved');const l=isqrt(a[0]*SCALE),h=isqrt(a[1]*SCALE);return [l,h+(h*h===a[1]*SCALE?0n:1n)];};
const square=a=>a[0]>=0n?mul(a,a):a[1]<=0n?mul(neg(a),neg(a)):[0n,ceil((abs(a[0])>abs(a[1])?a[0]*a[0]:a[1]*a[1]),SCALE)];
const pow=(a,n)=>{let b=ONE;while(n){if(n%2)b=mul(b,a);n=Math.floor(n/2);if(n)a=mul(a,a);}return b;};
const hull=(a,b)=>[a[0]<b[0]?a[0]:b[0],a[1]>b[1]?a[1]:b[1]],mag=a=>q(abs(a[0])>abs(a[1])?abs(a[0]):abs(a[1]),SCALE);
const pack=a=>({lo:String(a[0])+'/'+SCALE,hi:String(a[1])+'/'+SCALE}),unpack=a=>{if(!a||Object.keys(a).sort().join('|')!=='hi|lo')throw Error('Interval fields');const l=parse(a.lo),h=parse(a.hi);if(l[0]!==l[1]||h[0]!==h[1]||l[0]>h[0])throw Error('Noncanonical dyadic interval');return [l[0],h[0]];};
const width=a=>q(a[1]-a[0],SCALE),mid=a=>Number(a[0]+a[1])/Number(2n*SCALE);
let piCache;
function pi(){if(piCache)return piCache;const atan=n=>{let s=Z;for(let k=0;k<180;k++){const t=q(1n,BigInt(2*k+1)*BigInt(n)**BigInt(2*k+1));s=k%2?sub(s,t):add(s,t);}const t=q(1n,361n*BigInt(n)**361n);return [s[0],s[1]+t[1]];};piCache=sub(mul(q(16),atan(5)),mul(q(4),atan(239)));return piCache;}
function K(m){if(m[0]<0n||m[1]>=SCALE)throw new Resource('Elliptic parameter unresolved');let a=ONE,b=sqrt(sub(ONE,m));for(let i=0;i<80;i++){if(a[1]-b[0]<(1n<<72n))return div(pi(),mul(q(2),[b[0],a[1]]));const na=div(add(a,b),q(2)),nb=sqrt(mul(a,b));a=na;b=nb;}throw new Resource('AGM iteration cap');}
// Taylor integration with a Cauchy tail: on |z-c|=4h, |Q/Q(c)-1| <= 1/2.
// The analytic inverse square root is bounded by sqrt(2/Q(c)).
function integrate(coeff,end){
 if(end[0]<0n||end[1]>2n*SCALE)throw new Resource('Integration range cap');if(!end[1])return Z;
 const c=coeff.map((v,j)=>mul(v,pow(end,j))),choose=(n,k)=>{let x=1;for(let j=1;j<=k;j++)x=x*(n-j+1)/j;return x;};let count=0;
 function part(l,r,depth){if(++count>2048||depth>18)throw new Resource('Integration subdivision cap');const center=div(add(l,r),q(2)),h=div(sub(r,l),q(2)),radius=mul(q(4),h),cs=[];
  for(let j=0;j<c.length;j++){let v=Z;for(let k=j;k<c.length;k++)v=add(v,mul(mul(q(choose(k,j)),c[k]),pow(center,k-j)));cs.push(v);}
  let deviation=Z;for(let j=1;j<cs.length;j++)deviation=add(deviation,mul(mag(cs[j]),pow(radius,j)));
  if(cs[0][0]<=0n||2n*deviation[1]>cs[0][0]){const midp=div(add(l,r),q(2));return add(part(l,midp,depth+1),part(midp,r,depth+1));}
  const f=[div(ONE,sqrt(cs[0]))];let sum=mul(mul(q(2),h),f[0]);const N=64;
  for(let n=1;n<N;n++){let t=Z;for(let j=1;j<=Math.min(n,cs.length-1);j++)t=add(t,mul(q(2*n-j),mul(cs[j],f[n-j])));f[n]=neg(div(t,mul(q(2*n),cs[0])));if(n%2===0)sum=add(sum,div(mul(q(2),mul(f[n],pow(h,n+1))),q(n+1)));}
  const M=sqrt(div(q(2),[cs[0][0],cs[0][0]])),tail=mul(mul(mul(q(2),h),M),q(4n,3n*4n**BigInt(N)));
  return [sum[0]-tail[1],sum[1]+tail[1]];
 }
 return mul(end,part(Z,ONE,0));
}
module.exports={BITS,SCALE,Z,ONE,Resource,floor,ceil,isqrt,q,parse,add,neg,sub,mul,div,sqrt,square,pow,hull,mag,pack,unpack,width,mid,pi,K,integrate};
