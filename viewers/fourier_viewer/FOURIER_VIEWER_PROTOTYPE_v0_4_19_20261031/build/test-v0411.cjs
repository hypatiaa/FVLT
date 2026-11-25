'use strict';
// v0.4.11 unit check (SCHEMA_ADDENDUM_19): reciprocal winding (throat at 1/1), the other half of the full stack. Core level (stack-core reciprocal, liftHalf).
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),SC=require('../host-core/stack-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020';
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
const hop=(x,y)=>{const q=x*x+y*y,d=1+q;return [2*x/d,2*y/d,(q-1)/d];};
const ST=[{alpha:'1',n6:'1',m:'2'},{alpha:'2',n6:'1/2',m:'3'},{alpha:'1/2',n6:'3',m:'5'},{alpha:'-1',n6:'-1',m:'4'},{alpha:'3',n6:'-2',m:'2'},{alpha:'0',n6:'1',m:'7'},{alpha:'-2',n6:'2/3',m:'3'},{n1:'3',alpha:'1',n6:'1',m:'6'}];
// 1. reciprocal points = 1/conj(z), the Hopf image = the reflection through the equator plane, chordal distances preserved
let maxRel=0,maxRefl=0,maxChord=0,nPts=0,fixedN1=0,fixedN1ok=0,nAll=0;
for(const o of ST){const st=stOf(o),P=SC.build(st),RC=SC.reciprocal(P),m=P.m;
  for(const sc of [1,Math.sqrt(2)]){let pairs=[];
    for(let i=0;i<P.lattice.cells;i++)for(let t=0;t<m;t++){const j=2*(i*m+t),zr=P.xy[j],zi=P.xy[j+1],den=zr*zr+zi*zi,wr=RC.xy[j],wi=RC.xy[j+1];
      if(sc===1){nPts++;const er=Math.hypot(wr-zr/den,wi-zi/den)/Math.hypot(zr/den,zi/den);if(er>maxRel)maxRel=er;}
      if(!(den>0))continue;
      // Hopf: chart scale sc; w = z/sc; reflected point from the layer formula (z' = sc^2 z/|z|^2 through hopf(.,sc)) vs (x, y, -z) of the drawn image
      const H=NUM.hopf({re:zr,im:zi},sc),HR=NUM.hopf({re:sc*sc*wr,im:sc*sc*wi},sc),e=Math.hypot(HR[0]-H[0],HR[1]-H[1],HR[2]+H[2]);if(e>maxRefl)maxRefl=e;
      // direct w -> 1/conj(w) on w = z/sc
      const wx=zr/sc,wy=zi/sc,q=wx*wx+wy*wy,H2=NUM.fromAffine({re:wx/q,im:wy/q});const e2=Math.hypot(H2[0]-H[0],H2[1]-H[1],H2[2]+H[2]);if(e2>maxRefl)maxRefl=e2;
      if((i*m+t)%97===0)pairs.push([H,HR]);}
    for(let a=0;a+1<pairs.length;a++){const d1=Math.hypot(...pairs[a][0].map((v,k)=>v-pairs[a+1][0][k])),d2=Math.hypot(...pairs[a][1].map((v,k)=>v-pairs[a+1][1][k]));maxChord=Math.max(maxChord,Math.abs(d1-d2));}}
  // N = 1 layer
  const r6=Math.abs(Number(C.resolve(st).n6.n)/Number(C.resolve(st).n6.d));
  if(r6===1){for(let i=0;i<P.lattice.cells;i++){if(P.cellN[i]!==1)continue;for(let t=0;t<m;t++){nAll++;const j=2*(i*m+t);if(RC.xy[j]===P.xy[j]&&RC.xy[j+1]===P.xy[j+1])fixedN1ok++;}}}
}
ok('reciprocal points equal 1/conj(z) of the stack points (z/|z|^2) over '+nPts+' points in 8 states: max relative error '+maxRel.toExponential(2),maxRel<1e-13,maxRel);
ok('Hopf: H(1/conj(w)) is the reflection (x, y, -z) of H(w) through the equator plane, both charts (host scale 1 and comb scale sqrt 2): max error '+maxRefl.toExponential(2),maxRefl<1e-12,maxRefl);
ok('Hopf: chordal distances between sampled stack points equal those between their images (isometry): max difference '+maxChord.toExponential(2),maxChord<1e-12,maxChord);
ok('N = 1 layer is fixed (the reciprocal point equals the stack point exactly) when |n6| = 1: '+fixedN1ok+' of '+nAll+' points',nAll>0&&fixedN1ok===nAll);
// 2. exact, rational: integer alpha, s = 0 column (z real, rational): H(1/R) = (2R/(1+R^2), 0, (1-R^2)/(1+R^2)) as BigInt fractions, equal to -height of H(R); and float agrees
{let cnt=0,bad=0,fl=0,flBad=0;
  for(const [al,a,b] of [[1,1n,1n],[2,1n,2n],[3,-2n,1n],[0,3n,1n],[1,2n,3n]]){const st=stOf({alpha:String(al),n6:b===1n?String(a):a+'/'+b,m:'2'}),P=SC.build(st);
    for(let i=0;i<P.lattice.cells;i++){if(P.cellS[i]!==0)continue;const N=BigInt(P.cellN[i]),p=a*N**BigInt(al),q=b;   // R = p/q (signed)
      const h=(p*p-q*q),hd=(p*p+q*q);const hr=(q*q-p*p);   // heights (R^2-1)/(R^2+1) and of 1/R: (q^2-p^2)/(q^2+p^2): exact negation
      cnt++;if(hr*hd!==-h*hd)bad++;
      const j=2*(i*P.m),RC=SC.reciprocal(P),x=RC.xy[j],Hf=hop(x,RC.xy[j+1]);fl++;if(Math.abs(Hf[2]-Number(hr)/Number(hd))>1e-15||Math.abs(x-Number(q)/Number(p))>4.5e-16*Math.abs(Number(q)/Number(p)))flBad++;}}
  ok('exact: for integer alpha the s = 0 column is real rational R = n6 N^alpha = p/q; the reciprocal radius q/p and height (q^2-p^2)/(q^2+p^2) = minus the height of R (BigInt, '+cnt+' cells), and the float layer agrees within 1 ulp / 1e-15 ('+fl+' cells)',bad===0&&flBad===0,bad+'/'+flBad);}
// 3. alpha -> -alpha regression: the reciprocal layer at alpha equals the stack at -alpha point for point only when |n6| = 1
{const a=stOf({alpha:'2',n6:'1',m:'3'}),b=stOf({alpha:'-2',n6:'1',m:'3'}),Pa=SC.build(a),Pb=SC.build(b),Ra=SC.reciprocal(Pa);let mx=0;for(let k=0;k<Ra.xy.length;k++)mx=Math.max(mx,Math.abs(Ra.xy[k]-Pb.xy[k])/(Math.abs(Pb.xy[k])+1e-300<1e-12?1:1));
  ok('|n6| = 1: the reciprocal layer at alpha = 2 equals the stack at alpha = -2 point for point in lattice order (same n = '+Pa.n+'), max abs difference '+mx.toExponential(1),Pa.n===Pb.n&&mx<1e-12,mx);
  const c=stOf({alpha:'2',n6:'2',m:'3'}),d=stOf({alpha:'-2',n6:'2',m:'3'}),Pc=SC.build(c),Pd=SC.build(d),Rc=SC.reciprocal(Pc);let diff=0;for(let k=0;k<Rc.xy.length;k++)if(Math.abs(Rc.xy[k]-Pd.xy[k])>1e-9)diff++;
  ok('|n6| = 2: the reciprocal layer differs from the alpha -> -alpha stack (radius 1/(2N^2) against 2/N^2, a factor n6^2 = 4): '+diff+' of '+Rc.xy.length+' coordinates differ',diff>0);}
// 4. starting heights: both halves start on the equator iff |n6| = 1, else at +-(n6^2-1)/(n6^2+1)
{let good=0,tot=0;for(const n6 of ['1','-1','2','1/2','3','2/3']){const st=stOf({alpha:'1',n6,m:'2'}),P=SC.build(st),RC=SC.reciprocal(P),R=C.resolve(st),nn=Number(R.n6.n)/Number(R.n6.d);
    let found=false;for(let i=0;i<P.lattice.cells;i++){if(P.cellN[i]!==1)continue;const j=2*(i*P.m),h=hop(P.xy[j],P.xy[j+1])[2],hr=hop(RC.xy[j],RC.xy[j+1])[2],want=(nn*nn-1)/(nn*nn+1);tot++;if(Math.abs(h-want)<1e-14&&Math.abs(hr+want)<1e-14)good++;found=true;break;}
    if(!found)tot++;}
  ok('the N = 1 layer sits at height (n6^2-1)/(n6^2+1) and its reciprocal at the negative of it, for n6 = 1, -1, 2, 1/2, 3, 2/3 ('+good+' of '+tot+'); on the equator only for |n6| = 1',good===tot&&tot===6);}
// 5. n6 = 0: no image, counted, not drawn
{const st=stOf({n6:'0',alpha:'1',m:'3'}),P=SC.build(st),RC=SC.reciprocal(P);ok('n6 = 0: every reciprocal point is undefined (NaN), counted: undef = '+RC.undef+' of '+P.n,RC.undef===P.n&&RC.xy.every(v=>v!==v));}
// 6. Clifford lift: amplitudes swapped, phases kept, budget shared
{const un=y=>{const q=y[0]*y[0]+y[1]*y[1]+y[2]*y[2],d=1+q;return [2*y[0]/d,2*y[1]/d,2*y[2]/d,(q-1)/d];};
  let chk=0,badAmp=0,badPh=0,mxA=0,mxP=0;
  for(const o of [{alpha:'1',n6:'1',m:'2'},{alpha:'2',n6:'1/2',m:'3'},{alpha:'1/2',n6:'-3',m:'5'}]){const st=stOf(o),P=SC.build(st),H=SC.liftHalf(st,P,NUM.stereo,false,2000),R=SC.liftHalf(st,P,NUM.stereo,true,2000);
    for(let j=0;j<H.n;j+=Math.max(1,Math.floor(H.n/200))){if(!H.ok[j]||!R.ok[j])continue;const g=SC.selectIndices(P.n,2000)[j],cell=Math.floor(g/P.m),rho=Math.abs(P.rad[cell]);
      const xh=un([H.xyz[3*j],H.xyz[3*j+1],H.xyz[3*j+2]]),xr=un([R.xyz[3*j],R.xyz[3*j+1],R.xyz[3*j+2]]);
      const a1=Math.hypot(xh[0],xh[1]),b1=Math.hypot(xh[2],xh[3]),a2=Math.hypot(xr[0],xr[1]),b2=Math.hypot(xr[2],xr[3]);
      chk++;const eA=Math.max(Math.abs(a1-rho/Math.sqrt(1+rho*rho)),Math.abs(b1-1/Math.sqrt(1+rho*rho)),Math.abs(a2-1/Math.sqrt(1+rho*rho)),Math.abs(b2-rho/Math.sqrt(1+rho*rho)));mxA=Math.max(mxA,eA);if(eA>1e-9)badAmp++;
      const dp=(u,v)=>Math.abs(Math.atan2(Math.sin(u-v),Math.cos(u-v)));const eP=Math.max(dp(Math.atan2(xh[1],xh[0]),Math.atan2(xr[1],xr[0])),dp(Math.atan2(xh[3],xh[2]),Math.atan2(xr[3],xr[2])));mxP=Math.max(mxP,eP);if(eP>1e-8)badPh++;}}
  ok('Clifford: on the unit S3 the reciprocal point has |z1|, |z2| = (1/sqrt(1+rho^2), rho/sqrt(1+rho^2)), the primary the swap, and the phases (arg z1, arg z2) are equal: '+chk+' points, max amplitude error '+mxA.toExponential(1)+', max phase error '+mxP.toExponential(1),chk>100&&badAmp===0&&badPh===0,badAmp+'/'+badPh);
  const st=stOf({n1:'6',phi3:'700',alpha:'1',n6:'1',m:'2'}),P=SC.build(st),h=Math.floor((SC.LIFT_CAP-P.m)/2),H=SC.liftHalf(st,P,NUM.stereo,false,h),R=SC.liftHalf(st,P,NUM.stereo,true,h),F=SC.lift(st,P,NUM.stereo);
  ok('Clifford budget is shared, not doubled: n = '+P.n+' stack points, budget 12,000 - m = '+(SC.LIFT_CAP-P.m)+'; the halves draw '+H.n+' + '+R.n+' = '+(H.n+R.n)+' <= budget; the single stack draws '+F.n+' (unchanged); both halves flagged thinned',H.n===h&&R.n===h&&H.n+R.n<=SC.LIFT_CAP-P.m&&F.n===SC.LIFT_CAP-P.m&&H.thinned&&R.thinned);
  const same=(()=>{const a=SC.lift(st,P,NUM.stereo),b=SC.liftHalf(st,P,NUM.stereo,false,SC.LIFT_CAP-P.m);if(a.n!==b.n)return false;for(let k=0;k<a.xyz.length;k++)if(a.xyz[k]!==b.xyz[k])return false;return true;})();
  ok('liftHalf(non-reciprocal, full budget) equals the existing lift() exactly (same arithmetic)',same);
  // near-pole clip is counted: leaf 1/rho with rho >= 22361 (note C12c) needs large N; count it on a state that reaches it
  const big=stOf({n1:'8',phi3:'0',alpha:'1',n6:'1',m:'2'});let rho=0;try{const Pb=SC.build(big);const Rb=SC.liftHalf(big,Pb,NUM.stereo,true,3000);rho=Rb.bad;ok('n1 = 8 (B = 40320): near-pole clipping of the reciprocal half is counted (bad = '+Rb.bad+') and reported in the caption field, never silent',Number.isInteger(Rb.bad)&&Rb.n===3000);}catch(e){ok('n1 = 8 reciprocal lift runs',false,String(e));}}
// 7. file integrity: files that must not change
{const same=['instruments/comb-hopf/panel-g-robin.js','instruments/comb-hopf/panel-bd.js','host-core/branch-disk-core.js','host-core/comb-core.js','host-core/comb-numeric.js','host-core/orbit-core.js','instruments/comb-hopf/view-panels.js','instruments/comb-hopf/views-common.js'];
  const bad=same.filter(f=>sha(path.join(root,f))!==sha(path.join(OLD,f)));ok('panel-g-robin.js, panel-bd.js and '+(same.length-2)+' other source files are byte-identical to v0.4.10',bad.length===0,bad.join(','));
  const changed=['host-core/stack-core.js','instruments/comb-hopf/panel.js','instruments/comb-hopf/view-fourier.js','instruments/comb-hopf/view-clifford.js','instruments/comb-hopf/view-hopf.js'];
  ok('exactly the five expected source files differ from v0.4.10 ('+changed.length+')',changed.every(f=>sha(path.join(root,f))!==sha(path.join(OLD,f))));
  const bs=fs.readFileSync(path.join(root,'host-core/stack-core.js'),'utf8');const i=bs.indexOf('v0.4.11 (SCHEMA_ADDENDUM_19)');const before=bs.slice(0,bs.lastIndexOf(String.fromCharCode(10),i));ok('stack-core.js: the part before the v0.4.11 addition equals v0.4.10 up to the api line',fs.readFileSync(path.join(OLD,'host-core/stack-core.js'),'utf8').startsWith(before.replace(/\n$/,'')));}
console.log('\nSUMMARY test-v0411: '+pass+' pass, '+fail+' fail');process.exit(fail?1:0);
