'use strict';
// TRANSCRIPTION (v0.4.18 test aid, not viewer code): the functions caSigns, coinSigns, DIRS, planePen, cross and spherePen copied verbatim
// (lines 87-120, unchanged) from the skeleton seat's squeeze_pen_v0_2/curvature_pen_v0_2_1.html, sha256 c0f6926d6a0c37aa56dadb93778373bdc8e3acd4603c1796564b812b3e43b141.
// Used only by host-core/test-pen-curvature.cjs to compare the v0.4.18 pens with the skeleton's own rule. The one non-integer token is spherePen's
// rounding map (Math dot round), applied by the skeleton to integer vectors (allowlisted, by its exact line, in build/no-float-v0418.cjs).
function caSigns(rule, T){
  const W=2*T+5, mid=T+2; let a=new Uint8Array(W), b=new Uint8Array(W); a[mid]=1;
  const s=new Int8Array(T);
  for(let t=0;t<T;t++){
    s[t] = (a[mid]^a[mid+1]) ? -1 : 1;
    for(let i=1;i<W-1;i++){ const L=a[i-1],C=a[i],R=a[i+1]; b[i]= rule===150 ? (L^C^R) : (L^(C|R)); }
    b[0]=0; b[W-1]=0; const tmp=a; a=b; b=tmp;
  }
  return s;
}
function coinSigns(T, seed){
  let x=(seed>>>0)||1; const s=new Int8Array(T);
  for(let t=0;t<T;t++){ x^=x<<13; x>>>=0; x^=x>>>17; x^=x<<5; x>>>=0; s[t]=(x&1)?1:-1; }
  return s;
}
// ---- k = 0: exact integer lattice pen ----
const DIRS=[[1,0],[0,1],[-1,0],[0,-1]];
function planePen(s){
  let h=0,x=0,y=0; const pts=[[0,0]];
  for(const v of s){ h=(h+(v>0?1:3))&3; x+=DIRS[h][0]; y+=DIRS[h][1]; pts.push([x,y]); }
  return pts;
}
// ---- k = +1: geodesic turtle on S^2 with alpha = theta = pi/2 ----
const cross=(u,v)=>[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]];
function spherePen(s){
  let x=[0,0,1], v=[1,0,0]; const pts=[x.slice()];
  for(const sg of s){
    const w=cross(x,v); v = sg>0 ? w : w.map(c=>-c);          // turn by +-90 deg: v <- +-(x x v)
    const nx=v.slice(), nv=x.map(c=>-c);                      // step 90 deg: x' = v, v' = -x
    x=nx.map(Math.round); v=nv.map(Math.round);               // octahedron vertices are exact unit vectors
    pts.push(x.slice());
  }
  return pts;
}
module.exports={caSigns,coinSigns,DIRS,planePen,cross,spherePen,SOURCE_SHA256:'c0f6926d6a0c37aa56dadb93778373bdc8e3acd4603c1796564b812b3e43b141',SOURCE_LINES:'87-120'};
