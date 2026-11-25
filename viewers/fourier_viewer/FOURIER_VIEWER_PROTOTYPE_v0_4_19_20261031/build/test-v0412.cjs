'use strict';
// v0.4.12 unit check (SCHEMA_ADDENDUM_20): log radius display of the Fourier view. Core level: the mapping R(r) = R_t(1 + ln r / L) on the real stack data (logModel of view-fourier.js).
const fs=require('fs'),path=require('path'),crypto=require('crypto');
globalThis.FVViews={register(){}};   // view-fourier.js only registers itself at load; logModel needs no DOM
const C=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
require('../instruments/comb-hopf/view-fourier.js');
const {logModel,logR}=globalThis.FVStackView;
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021';
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
const ST=[{alpha:'1',n6:'1',m:'2'},{alpha:'-1',n6:'1',m:'2'},{alpha:'2',n6:'1/2',m:'3'},{alpha:'1/2',n6:'3',m:'5'},{alpha:'-1',n6:'-1',m:'4'},{alpha:'3',n6:'-2',m:'2'},{alpha:'-2',n6:'2/3',m:'3'},{n1:'3',alpha:'1',n6:'1',m:'2',phi3:'5'},{n1:'4',phi3:'22',alpha:'1',n6:'1',m:'2'},{n1:'4',phi3:'22',alpha:'-1',n6:'1',m:'2'}];
// 1. R(1) = R_t
ok('R(1) = R_t exactly (log radius of r = 1 is 1 for every L)',[0.5,1,3.3,17].every(L=>logR(1,L)===1));
ok('r = e^L maps to 2R_t and r = e^-L to 0 (L = 2.5)',Math.abs(logR(Math.exp(2.5),2.5)-2)<1e-14&&Math.abs(logR(Math.exp(-2.5),2.5))<1e-14);
// 2. mirror about the throat with the reciprocal layer on, phases preserved, L = max |ln r| over both halves
let nPairs=0,maxMir=0,maxPh=0,maxLerr=0,rangeBad=0,noRCpairs=0,maxPhR=0;
for(const o of ST){const st=stOf(o),P=SC.build(st),RC=SC.reciprocal(P),LM=logModel(P,RC);
  let Lw=0;for(let i=0;i<P.xy.length;i+=2){const r=Math.hypot(P.xy[i],P.xy[i+1]);if(r>0)Lw=Math.max(Lw,Math.abs(Math.log(r)));}
  if(Lw>0)maxLerr=Math.max(maxLerr,Math.abs(LM.L-Lw));
  for(let i=0;i<P.xy.length;i+=2){const x=P.xy[i],y=P.xy[i+1],r=Math.hypot(x,y);if(!(r>0))continue;
    const a=LM.xy[i],b=LM.xy[i+1],c=LM.xr[i],d=LM.xr[i+1],R1=Math.hypot(a,b),R2=Math.hypot(c,d);
    nPairs++;maxMir=Math.max(maxMir,Math.abs(R1+R2-2));            // R(1/r) = 2 R_t - R(r)
    maxMir=Math.max(maxMir,Math.abs(R1-logR(r,LM.L)));
    // phase preserved: cross product of unit vectors ~ 0 and dot > 0 for both halves
    const cr=(x*b-y*a)/(r*R1||1),dt=x*a+y*b,cr2=(x*d-y*c)/(r*R2||1),dt2=x*c+y*d;
    if(R1>1e-9)maxPh=Math.max(maxPh,Math.abs(cr),dt>0?0:1);if(R2>1e-9)maxPhR=Math.max(maxPhR,Math.abs(cr2),dt2>0?0:1);
    if(R1<0||R1>2+1e-12||R2<0||R2>2+1e-12)rangeBad++;}}
ok('reciprocal on: R(1/r) = 2R_t − R(r) and R = 1 + ln r / L on '+nPairs+' point pairs in '+ST.length+' states: max error '+maxMir.toExponential(2),nPairs>1000&&maxMir<1e-12,maxMir);
ok('L equals the largest |ln r| of the stack points (error '+maxLerr.toExponential(1)+')',maxLerr<1e-12);
ok('phases preserved for both halves (cross product of the unit vectors, max '+maxPh.toExponential(1)+' / '+maxPhR.toExponential(1)+'; same direction)',maxPh<1e-12&&maxPhR<1e-12);
ok('all drawn stack radii inside [0, 2R_t]',rangeBad===0,rangeBad);
// 3. one half only: L from the shown half, throat at 1, extremum at 2 or 0
{const st=stOf({alpha:'1',n6:'1',m:'2',n1:'4',phi3:'22'}),P=SC.build(st),LM=logModel(P,null);let mx=0,mn=9;for(let i=0;i<LM.xy.length;i+=2){const R=Math.hypot(LM.xy[i],LM.xy[i+1]);mx=Math.max(mx,R);mn=Math.min(mn,R);}
  ok('one half (alpha = 1, no reciprocal): L = '+LM.L.toFixed(4)+' = ln max r; largest display radius = 2 R_t ('+mx.toFixed(6)+'), N = 1 layer on the throat ('+mn.toFixed(6)+')',Math.abs(mx-2)<1e-12&&Math.abs(mn-1)<1e-12&&Math.abs(LM.L-Math.log(P.maxRadius))<1e-12);}
// 4. alpha = -1 and alpha = +1 give mirror-image drawings of each other when |n6| = 1 and the reciprocal layer is on (saphir's two states)
{const A=logModel(SC.build(stOf({n1:'4',phi3:'22',alpha:'1',n6:'1',m:'2'})),SC.reciprocal(SC.build(stOf({n1:'4',phi3:'22',alpha:'1',n6:'1',m:'2'})))),
       B=logModel(SC.build(stOf({n1:'4',phi3:'22',alpha:'-1',n6:'1',m:'2'})),SC.reciprocal(SC.build(stOf({n1:'4',phi3:'22',alpha:'-1',n6:'1',m:'2'}))));
  let mx=0;for(let i=0;i<A.xy.length;i++)mx=Math.max(mx,Math.abs(A.xy[i]-B.xr[i]),Math.abs(A.xr[i]-B.xy[i]));
  ok('alpha = +1 and alpha = −1 (|n6| = 1, reciprocal on) draw the same picture with the halves exchanged: max coordinate difference '+mx.toExponential(1)+', L '+A.L.toFixed(4)+' / '+B.L.toFixed(4),mx<1e-12&&Math.abs(A.L-B.L)<1e-12,mx);}
// 5. n6 = 0: counted, not hidden
{const st=stOf({n6:'0',alpha:'1',m:'3'}),P=SC.build(st),RC=SC.reciprocal(P),LM=logModel(P,RC);ok('n6 = 0: '+LM.undef+' of '+P.n+' stack points at r = 0 counted (no log image), L degenerate -> 1: '+LM.degenerate,LM.undef===P.n&&LM.degenerate&&LM.L===1);}
// 6. source files: only view-fourier.js changed (against v0.4.11), the two named panels untouched
{const files=['panel-g-robin.js','panel-bd.js'];for(const f of files)ok(f+' byte-identical to v0.4.11',sha(path.join(root,'instruments/comb-hopf',f))===sha(path.join(OLD,'instruments/comb-hopf',f)));
  const same=[],diff=[];const walk=d=>{for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);if(e.isDirectory()){walk(p);continue;}const rel=path.relative(root,p).split(path.sep).join('/');if(!/\.(js|html)$/.test(rel)||rel.startsWith('build/')||rel.startsWith('dist/')||rel==='host-core/test-core.cjs')continue;const q=path.join(OLD,rel);if(fs.existsSync(q)&&sha(q)===sha(p))same.push(rel);else diff.push(rel);}};
  for(const d of ['host-core','instruments','exact-lib'])walk(path.join(root,d));
  ok('source files differing from v0.4.11: '+diff.join(', '),diff.length===1&&diff[0]==='instruments/comb-hopf/view-fourier.js',diff.join(','));}
console.log('\nSUMMARY test-v0412: '+pass+' pass, '+fail+' fail');process.exit(fail?1:0);
