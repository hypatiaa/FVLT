'use strict';
// v0.4.9 unit check (SCHEMA_ADDENDUM_17): the full stack and the fraction stack ported from the merged FVLT monodromy instrument.
// The old instrument's own functions (computeVernier, buildFullStack, PlaneCliffordLiftCore, ContinuousRadialDisplayV1) are read from the frozen file (never edited)
// and run in a Node vm; their point sets are compared with host-core/stack-core.js, which uses this viewer's exact core.
const fs=require('fs'),vm=require('vm'),path=require('path'),crypto=require('crypto');
const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
const OLD_SHA='b4cee4e30a753eda7c62f72e8043d6d5c9b3f69c3c2e1dd0da9a3f9ab5b8e248';
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('../host-core/comb-core.js'),NUM=require('../host-core/comb-numeric.js'),SC=require('../host-core/stack-core.js'),FS=require('../host-core/fraction-stack-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const src=fs.readFileSync(OLD,'utf8');
ok('frozen old instrument sha256 '+OLD_SHA.slice(0,12)+'… (read only)',crypto.createHash('sha256').update(fs.readFileSync(OLD)).digest('hex')===OLD_SHA);
// ---- extract old code by brace matching
function block(startText){const i=src.indexOf(startText);if(i<0)throw Error('not found: '+startText);let j=src.indexOf('{',i),d=0;
  for(;j<src.length;j++){const ch=src[j];if(ch==='{')d++;else if(ch==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
const parts=['function selectedShellBase(','function selectedShellSpan(','function combOffsets(','function combKernel(','function reducedHalfTurns(','function stableGearboxAngle(','function computeVernier(','function buildFullStack('].map(block);
const lift=block('const PlaneCliffordLiftCore = (() => {')+')();',cont=block('const ContinuousRadialDisplayV1 = (() => {')+')();';
const ctx={Math,Number,BigInt,String,Object,Array,Set,Map,RangeError,TypeError,Error,JSON,isFinite};vm.createContext(ctx);
vm.runInContext('var state={};function factorial(n){let f=1;for(let k=2;k<=n;k++)f*=k;return f;}function gearboxExactText(k){return state[k+"Exact"];}let _stackCache=null,_stackCacheKey=null,_stackDrawSig=null;\n'
  +parts.join('\n')+'\n'+lift.replace('const PlaneCliffordLiftCore','var PlaneCliffordLiftCore')+'\n'+cont.replace('const ContinuousRadialDisplayV1','var ContinuousRadialDisplayV1')+'\nthis.PlaneCliffordLiftCore=PlaneCliffordLiftCore;this.ContinuousRadialDisplayV1=ContinuousRadialDisplayV1;',ctx);
const oldState=o=>{vm.runInContext('state='+JSON.stringify(o)+';_stackCache=null;_stackCacheKey=null;',ctx);};
const qn=t=>{const q=X.parse(t);return Number(q.n)/Number(q.d);};
// ---- 1. plane: old buildFullStack() point set == stack-core build() point set
const samples=[];
for(const n1 of ['3','4','5'])for(const alpha of ['-1','0','1','1/2'])for(const m of ['2','3','7'])samples.push({n1,alpha,m,n6:'1',t1:'1',t2:'1'});
samples.push({n1:'4',alpha:'1',m:'2',n6:'-1',t1:'1',t2:'1'},{n1:'4',alpha:'-1/3',m:'5',n6:'1/2',t1:'1/2',t2:'2'},{n1:'3',alpha:'2',m:'4',n6:'1',t1:'3',t2:'-1'});
let worst=0,cmpN=0,planeOk=0;
for(const o of samples){
  const st=C.initial({shellMode:'factorial',phi3:'2',n1:o.n1,m:o.m,alpha:o.alpha,n6:o.n6,t1:o.t1,t2:o.t2});
  oldState({showStack:true,shellMode:'factorial',directBase:24,n1:Number(o.n1),n6:qn(o.n6),alpha:qn(o.alpha),t1:qn(o.t1),t2:qn(o.t2),t1Exact:o.t1,t2Exact:o.t2,m:Number(o.m)});
  const old=vm.runInContext('buildFullStack()',ctx),P=SC.build(st),m=Number(o.m);
  let good=old.length===P.lattice.cells;
  for(let i=0;good&&i<old.length;i++)for(let t=0;t<m;t++){const a=old[i][t],re=P.xy[2*(i*m+t)],im=P.xy[2*(i*m+t)+1],sc=Math.max(1,Math.abs(P.rad[i]));
    if(a[2]!==P.offsets[t]){good=false;break;}const d=Math.hypot(a[0]-re,a[1]-im)/sc;cmpN++;if(d>worst)worst=d;if(!(d<=1e-12))good=false;}
  if(good)planeOk++;else console.log('  plane mismatch',JSON.stringify(o));
}
ok('plane: old buildFullStack() = new stack points for '+samples.length+' states (n1 3/4/5 × α −1/0/1/1/2 × m 2/3/7, +3 with n6 −1, 1/2, t1 1/2, 3, t2 2, −1): '+cmpN+' points, max |Δ|/max(1,|ρ_N|) = '+worst.toExponential(2),planeOk===samples.length,planeOk+'/'+samples.length);
// ---- 2. exact: the BigInt recurrence equals comb-core teeth() phases exactly (sampled cells)
{let n=0,bad=0;for(const o of [samples[5],samples[20],samples[37],samples[38]]){const st=C.initial({shellMode:'factorial',phi3:'2',n1:o.n1,m:o.m,alpha:o.alpha,n6:o.n6,t1:o.t1,t2:o.t2}),L=SC.lattice(st);
  for(const s of L.sVals.filter((_,i)=>i%3===0))for(const ph of L.phiVals.filter((_,i)=>i%4===1)){const r=SC.residues(st,s,ph);if(!r)continue;
    for(const x of r){const e=SC.exactPhase(st,s,ph,x.c);n++;if(!X.eq(C.phaseRep(X.rat(x.n,x.d)),e))bad++;}}}
 ok('exact: stack residues (N t1 + c t2) s/N mod 2 equal comb-core teeth() phases exactly ('+n+' points)',bad===0&&n>0,bad+' differ');}
// ---- 3. Clifford lift: old PlaneCliffordLiftCore (exact lane) / ContinuousRadialDisplayV1 (continuous α) == new stack lift
{let ok3=0,tot=0,worstL=0;
 for(const o of samples){
  const st=C.initial({shellMode:'factorial',phi3:'2',n1:o.n1,m:o.m,alpha:o.alpha,n6:o.n6,t1:o.t1,t2:o.t2}),m=Number(o.m),P=SC.build(st),Lf=SC.lift(st,P,NUM.stereo);
  const integerLane=['-1','0','1'].includes(o.alpha)&&['-1','0','1'].includes(o.n6)&&/^-?\d+$/.test(o.t1)&&/^-?\d+$/.test(o.t2);
  const ss={showStack:true,n1:Number(o.n1),m,t1:qn(o.t1),t2:qn(o.t2),alpha:qn(o.alpha),n6:qn(o.n6)};
  const out=vm.runInContext('(function(ss){const offs=combOffsets(ss.m);const specs=PlaneCliffordLiftCore.buildLiftFullStackSpecs(ss,offs);const idx=PlaneCliffordLiftCore.selectHeadIndices(specs.length,'+(12000-m)+');const sel=idx.map(i=>specs[i]);return '+(integerLane?'PlaneCliffordLiftCore.projectLiftSpecs(sel)':'ContinuousRadialDisplayV1.projectSpecs(sel)')+';})('+JSON.stringify(ss)+')',ctx);
  let good=out.length===Lf.n;tot++;
  for(let j=0;good&&j<out.length;j++){const a=out[j];if(a.c!==Lf.c[j]){good=false;break;}
    if(!a.stereographic){if(Lf.ok[j])good=false;continue;}if(!Lf.ok[j]){good=false;break;}
    const v=[Lf.xyz[3*j],Lf.xyz[3*j+1],Lf.xyz[3*j+2]],sc=Math.max(1,Math.hypot(...a.stereographic)),d=Math.hypot(a.stereographic[0]-v[0],a.stereographic[1]-v[1],a.stereographic[2]-v[2])/sc;if(d>worstL)worstL=d;if(!(d<=1e-9))good=false;}
  if(good)ok3++;else console.log('  lift mismatch',JSON.stringify(o),out.length,Lf.n);}
 ok('Clifford: old lift stack (PlaneCliffordLiftCore exact lane where it applies, ContinuousRadialDisplayV1 otherwise; host head selection, budget 12,000 − m) = new stack lift, '+tot+' states, max rel |Δ| '+worstL.toExponential(2),ok3===tot,ok3+'/'+tot);}
// ---- 4. lattice m-independence (m <= 30) and the m bucket above
{const L=m=>{const st=C.initial({n1:'6',m:String(m)});const P=SC.build(st);return JSON.stringify([Array.from(P.cellS),Array.from(P.cellN)]);};
 const ref=L(2);ok('lattice: (s, φ₃) cells identical for m = 2, 3, 7, 30 at n1 = 6 (step 3, 241² cells)',[3,7,30].every(m=>L(m)===ref)&&SC.lattice(C.initial({n1:'6',m:'2'})).step===3);
 ok('lattice: above m = 30 the host bucket thins it (m = 31: gridCap '+SC.lattice(C.initial({n1:'6',m:'31'})).gridCap+', step '+SC.lattice(C.initial({n1:'6',m:'31'})).step+'), deterministic',L(31)!==ref&&L(31)===L(31));
 for(const n1 of ['3','4','5']){const a=SC.lattice(C.initial({n1,phi3:'2',m:'2'})),b=SC.lattice(C.initial({n1,phi3:'2',m:'7'}));ok('lattice n1 = '+n1+': m 2 vs 7 identical (step '+a.step+', '+a.cells+' cells, '+a.zeroCells+' N = 0 cells)',JSON.stringify(a.sVals)===JSON.stringify(b.sVals)&&a.cells===b.cells);}}
// ---- 5. thinning deterministic, cap stated
{const st=C.initial({shellMode:'integer',B:'6227020800',m:'30',t1:'1/3',t2:'5/7'});const a=SC.build(st),b=SC.build(st);
 ok('thinning: B = 6,227,020,800, m = 30: step '+a.lattice.step+', '+a.lattice.cells+' cells ≤ cap '+SC.GRID_CAP+', two builds byte-identical',a.lattice.cells<=SC.GRID_CAP&&Buffer.from(a.xy.buffer).equals(Buffer.from(b.xy.buffer)));
 const s7=C.initial({n1:'7',m:'2'}),l7=SC.lattice(s7);ok('thinning: n1 = 7 (B = 5040): step '+l7.step+' (ceil(5041/241)), '+l7.ns+'² lattice values',l7.step===Math.ceil(5041/241)&&l7.cells<=SC.GRID_CAP);}
// ---- 6. key: depends on shell, n6, α, t1, t2, m only; not on φ₃, s, nMode, tilt, tab, view
{const b=C.initial({n1:'4',m:'3'});const k=SC.key(b);
 ok('key ignores φ₃, s, α_Tilt, nMode, tab and view',[{phi3:'7'},{sTyped:'1/3'},{tilt:'1/2'},{nMode:'continuous',phi3:'7/2'},{tab:'clifford'},{view:'fs=1'}].every(p=>SC.key(C.normalise({...b,...p}))===k));
 const P1=SC.build(b),P2=SC.build(C.normalise({...b,tilt:'1/2'}));ok('α_Tilt does not change the stack (teeth only)',Buffer.from(P1.xy.buffer).equals(Buffer.from(P2.xy.buffer)));
 ok('key changes with α, n6, t1, t2, m, shell',[{alpha:'1/2'},{n6:'2'},{t1:'2'},{t2:'1/2'},{m:'4'},{n1:'5'}].every(p=>SC.key(C.normalise({...b,...p}))!==k));}
// ---- 7. degenerate cases
{const st=C.initial({n1:'4',n6:'0'}),P=SC.build(st);ok('n6 = 0: every stack point at the origin (zeroAmplitude flagged)',P.zeroAmplitude&&P.xy.every(v=>v===0));
 const L=SC.lattice(C.initial({n1:'4'}));ok('N = 0 column (φ₃ = B + 1) counted, not drawn: 26 cells',L.zeroCells===26&&L.cells===650);
 const s1=C.initial({shellMode:'integer',B:'1',phi3:'1'}),P1=SC.build(s1);ok('B = 1: lattice {0,1,2}², 6 cells with N > 0',P1.lattice.cells===6);}
// ---- 8. fraction stack in the plane: heads = fraction-stack-core heads, points on the current radius circle, phases = comb-core teeth at s = j/q
{const st=C.initial({n1:'4',phi3:'21',m:'3',sTyped:'1/3'}),h=FS.heads(st),num=NUM.compute(st),F=SC.fractionPlane(st,h.heads,num.radius);
 ok('fraction stack (plane): '+F.length+' heads, all on |z| = |ρ| (N = 4)',F.length===h.heads.length&&F.length>0&&F.every(p=>Math.abs(Math.hypot(p.re,p.im)-num.rho)<1e-12*Math.max(1,num.rho)));
 let bad=0;for(const p of F.filter((_,i)=>i%7===0)){const sj=X.text(X.rat(p.j,h.lattice.q));const t=C.teeth({...st,sTyped:sj}).find(x=>x.c===p.c),th=Math.PI*Number(t.phase.n)/Number(t.phase.d);if(Math.hypot(p.re-num.radius*Math.cos(th),p.im-num.radius*Math.sin(th))>1e-12)bad++;}
 ok('fraction stack (plane): each head equals the comb-core tooth at its s = j/q',bad===0);
 const idle=C.initial({n1:'4',t1:'1/2',sTyped:'1/3'});ok('fraction stack idle with reason for a non-integer gearbox: '+FS.caption(idle),FS.lattice(idle).idle);}
// ---- 9. STACK_LABEL_RESOLUTION v0.11 (another session's note, not externally reviewed): fixed integer layer at α = n6 = t1 = t2 = 1, after carrier removal V_N = e^{-iπs} w = N e^{iπa/N}, a = c s
{const st=C.initial({n1:'5',phi3:'2',m:'3'}),P=SC.build(st),L=P.lattice,m=3;let exactR=0,nR=0,sepBad=0,sepN=0,chBad=0,chN=0,chMax=0,LnBad=0,LnN=0;
 for(const s of [1,2,3,7]){const ci=P.offsets.indexOf(1);const V=[];
  for(let i=0;i<L.cells;i++)if(P.cellS[i]===s){const N=P.cellN[i],sg=s%2?-1:1;V.push({N,re:sg*P.xy[2*(i*m+ci)],im:sg*P.xy[2*(i*m+ci)+1]});}
  // exact part: |V_N| = N (alpha = 1, n6 = 1 exact) and the phase of V_N is exactly pi*a/N mod 2 (residue check)
  for(const v of V){const res=SC.residues(st,s,Number(L.span)-v.N).find(x=>x.c===1n),want=X.rat(BigInt(v.N)*BigInt(s)+BigInt(s),BigInt(v.N));nR++;if(X.eq(C.phaseRep(X.rat(res.n,res.d)),C.phaseRep(want)))exactR++;}
  for(let i=0;i<V.length;i++)for(let j=i+1;j<V.length;j++){const d=Math.hypot(V[i].re-V[j].re,V[i].im-V[j].im);sepN++;if(!(d>=Math.abs(V[i].N-V[j].N)*(1-1e-12)))sepBad++;
    const H=w=>NUM.hopf(w,1),hi=H(V[i]),hj=H(V[j]),lhs=Math.hypot(hi[0]-hj[0],hi[1]-hj[1],hi[2]-hj[2]),rhs=2*d/(Math.sqrt(1+V[i].N**2)*Math.sqrt(1+V[j].N**2));chN++;const e=Math.abs(lhs-rhs)/rhs;if(e>chMax)chMax=e;if(e>1e-9)chBad++;}
  for(const v of V){const n=v.N,Ln=2/(Math.sqrt(1+n*n)*Math.sqrt(1+(n+1)**2)),hv=NUM.hopf(v,1);for(const w of V){if(w===v)continue;LnN++;const hw=NUM.hopf(w,1);if(!(Math.hypot(hv[0]-hw[0],hv[1]-hw[1],hv[2]-hw[2])>=Ln*(1-1e-9)))LnBad++;}}}
 ok('label note (2): planar separation |V_N − V_M| ≥ |N − M| on 4 fixed layers (s = 1, 2, 3, 7; c = +1; N = 1 … 121): '+sepN+' pairs (numerical, float64)',sepBad===0,sepBad);
 ok('label note: the phase of each layer point is exactly π·a/N + π·s mod 2 (carrier e^{iπs}), from the exact residues ('+exactR+'/'+nR+' points, exact)',exactR===nR&&nR>0);
 ok('label note (3): chordal identity |H(w) − H(v)| = 2|w − v|/(√(1+|w|²)√(1+|v|²)) with this viewer’s host chart (comb-numeric hopf, scale 1): '+chN+' pairs, max rel deviation '+chMax.toExponential(1)+' (numerical)',chBad===0,chBad);
 ok('label note (6): nearest-point separation ≥ L_N = 2/(√(1+N²)√(1+(N+1)²)) on the sphere: '+LnN+' ordered pairs (numerical)',LnBad===0,LnBad);
 const H1=NUM.hopf({re:0.3,im:-0.7},1),q=0.3*0.3+0.49;ok('host chart = H of the note: H(w) = (2Re w, 2Im w, |w|² − 1)/(1+|w|²)',Math.abs(H1[0]-0.6/(1+q))<1e-15&&Math.abs(H1[1]+1.4/(1+q))<1e-15&&Math.abs(H1[2]-(q-1)/(1+q))<1e-15);}
console.log('v0.4.9 unit check: '+pass+' pass / '+fail+' fail');process.exit(fail?1:0);
