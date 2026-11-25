'use strict';
// Independent R20 reference for the tests. Shares NO code with comb-core.js or exact.js (own gcd, own integer arithmetic).
// Method: scale everything to integers over L = D * den(s0), enumerate family elements in a small window around s0
// by brute force, and take the nearest one strictly in the direction. Fractions are [num, den] BigInt pairs, den > 0.
const g=(a,b)=>{a=a<0n?-a:a;b=b<0n?-b:b;while(b){[a,b]=[b,a%b];}return a;};
const md=(a,m)=>((a%m)+m)%m;
function refStep({N,m,t1,t2,s0,dir,E,mode}){
  const [sn,sd]=s0,[en,ed]=E,M=BigInt(m);
  let D,L,fams=[]; // each family: {kind,order,O,H} meaning integers x = O + H*u over L
  if(mode==='PAIR'){D=1n;L=sd;fams.push({kind:'PAIR',order:'',O:0n,H:sd});}
  else{
    const A=t1<0n?-t1:t1,B=t2<0n?-t2:t2;D=M*A*B;L=D*sd;
    fams.push({kind:'ALIGN',order:'',O:0n,H:M*B*sd});
    for(let j=1n;j<M;j++){
      if(m%2)fams.push({kind:'SPREAD',order:String(M/g(j,M)),O:2n*N*A*j*sd,H:2n*M*N*A*sd});
      else fams.push({kind:'SPREAD',order:String(M/g(j,M)),O:N*A*j*sd,H:M*N*A*sd});
    }
  }
  const S=sn*(L/sd);                                      // s0 as an integer over L
  const inRange=(x,sign)=>sign>0?x*ed<=en*L:x*ed>=-en*L;  // x/L <= E  or  x/L >= -E
  let best=null;
  for(const f of fams){
    const est=(S-f.O)/f.H;                                // truncating estimate of u
    for(let u=est-3n;u<=est+3n;u++){
      const x=f.O+f.H*u;
      if(dir>0?x>S:x<S){if(best===null||(dir>0?x<best:x>best))best=x;}
    }
  }
  const lim=dir>0?{n:en,d:ed}:{n:-en,d:ed};              // the limit as a fraction
  const inside=best!==null&&inRange(best,dir);
  const out=(x,L2)=>{const k=g(x,L2)||1n;return [x/k,L2/k];};
  if(inside){
    const kinds=fams.filter(f=>md(best-f.O,f.H)===0n).map(f=>f.kind+(f.order?':'+f.order:'')).sort();
    return {outcome:'stop',value:out(best,L),kinds};
  }
  const atLimit=dir>0?S*ed>=en*L:S*ed<=-en*L;
  if(atLimit)return {outcome:'none',value:out(S,L),kinds:[]};
  return {outcome:'range-limit',value:[lim.n,lim.d],kinds:[]};
}
module.exports={refStep};
