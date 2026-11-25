'use strict';
// v0.4.9 read-only probe (PORT_NOTE §7): does the OLD instrument's lift stack change with alpha, and what does its camera autofit (prepareCameraScreen) do with it?
// Runs the old PlaneCliffordLiftCore (read from the frozen file, never edited) in a Node vm for saphir's state n1 = 4, m = 2, t1 = t2 = 1, n6 = 1.
const fs=require('fs'),vm=require('vm');
const OLD='C:/Users/robin/s6_atom/cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html',src=fs.readFileSync(OLD,'utf8');
function block(t){const i=src.indexOf(t);let j=src.indexOf('{',i),d=0;for(;j<src.length;j++){if(src[j]==='{')d++;else if(src[j]==='}'){d--;if(d===0)break;}}return src.slice(i,j+1);}
const ctx={Math,Number,BigInt,String,Object,Array,Set,Map,RangeError,TypeError,Error,JSON,isFinite};vm.createContext(ctx);
vm.runInContext(block('function combOffsets(')+'\nvar PlaneCliffordLiftCore='+block('const PlaneCliffordLiftCore = (() => {').replace('const PlaneCliffordLiftCore = ','')+')();this.L=PlaneCliffordLiftCore;',ctx);
for(const alpha of [-1,0,1]){
  const r=vm.runInContext(`(function(){const ss={showStack:true,n1:4,m:2,t1:1,t2:1,alpha:${alpha},n6:1};const offs=combOffsets(2);
    const cur=L.projectLiftSpecs(L.buildCurrentLiftSpecs?[]:[]);
    const specs=L.buildLiftFullStackSpecs(ss,offs),pts=L.projectLiftSpecs(specs).map(p=>({...p,sourceIndex:0}));
    const guide=L.createReferenceGuide();const scr=L.prepareCameraScreen(pts,guide,640,480,L.DEFAULT_CLIFFORD_CAMERA);
    const fin=pts.filter(p=>p.projection_status==='FINITE'),norms=fin.map(p=>Math.hypot(...p.stereographic)).sort((a,b)=>a-b);
    const gN=guide.vertices.map(v=>Math.hypot(...v)),gmax=Math.max(...gN);
    const onScreenGuide=gmax*scr.fit;   // guide radius on screen, px
    return {points:pts.length,finite:fin.length,clipped:pts.length-fin.length,median:norms[norms.length>>1],p99:norms[Math.floor(norms.length*0.99)],max:norms[norms.length-1],fit:scr.fit,guidePx:onScreenGuide,
      xRange:[scr.bounds.minX,scr.bounds.maxX],yRange:[scr.bounds.minY,scr.bounds.maxY]};})()`,ctx);
  console.log('alpha '+alpha+': '+JSON.stringify(r));
}
