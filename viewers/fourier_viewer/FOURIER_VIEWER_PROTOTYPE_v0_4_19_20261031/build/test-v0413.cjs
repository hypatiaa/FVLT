'use strict';
// v0.4.13 unit check (SCHEMA_ADDENDUM_21): core level only. (1) the v0.4.12 base is untouched; (2) logModel (the stack mapping) gives identical arrays in v0.4.12 and v0.4.13;
// (3) the two named panel files and every source file except view-fourier.js equal v0.4.12. The pen drawing is checked in browser-check-v0413.
const fs=require('fs'),path=require('path'),crypto=require('crypto'),vm=require('vm');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const root=path.join(__dirname,'..'),OLD='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021';
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
ok('v0.4.12 dist sha256 unchanged (b6e0e6e8…)',sha(OLD+'/dist/comb-hopf.html')==='b6e0e6e839b26bfd6304b9f5a273ca171d6a606fb416d663fc1c5da12debf090');
ok('v0.4.12 SHA256SUMS.txt sha256 unchanged (7d90774e…)',sha(OLD+'/SHA256SUMS.txt')==='7d90774ea9c7f33069df594ad429ae312fb7d30e7eecff5172f260f5f5b7379f');
const C=require('../host-core/comb-core.js'),SC=require('../host-core/stack-core.js');
const load=dir=>{const g={FVViews:{register(){}}};g.globalThis=g;const code=fs.readFileSync(dir+'/instruments/comb-hopf/view-fourier.js','utf8');vm.runInNewContext(code,Object.assign(g,{console,Math,Float64Array,Number,Object,Array,String,JSON,Date,Error,BigInt,Map,Set,Uint8Array}));return g.FVStackView;};
let A,B;try{A=load(OLD);B=load(root);}catch(e){console.log('load error '+e);}
const stOf=o=>C.initial({shellMode:'factorial',n1:'4',phi3:'2',m:'2',...o});
const ST=[{alpha:'1',n6:'1',m:'2'},{alpha:'-1',n6:'1',m:'2'},{alpha:'2',n6:'1/2',m:'3'},{alpha:'1/2',n6:'3',m:'5'},{alpha:'-1',n6:'-1',m:'4'},{alpha:'3',n6:'-2',m:'2'},{alpha:'-2',n6:'2/3',m:'3'},{n1:'3',alpha:'1',n6:'1',m:'2',phi3:'5'},{n1:'4',phi3:'22',alpha:'1',n6:'1',m:'2'},{n6:'0',alpha:'1',m:'3'}];
let same=0,pts=0;
for(const o of ST){const P=SC.build(stOf(o)),R=SC.reciprocal(P);for(const RC of [R,null]){const a=A.logModel(P,RC),b=B.logModel(P,RC);const eq=a.L===b.L&&a.undef===b.undef&&a.maxRd===b.maxRd&&a.xy.every((v,i)=>Object.is(v,b.xy[i]))&&(!RC||a.xr.every((v,i)=>Object.is(v,b.xr[i])));pts+=a.xy.length/2;if(eq)same++;}}
ok('logModel arrays (stack mapping) identical in v0.4.12 and v0.4.13: '+same+'/'+ST.length*2+' model runs, '+pts+' points',same===ST.length*2);
const diff=[];const walk=d=>{for(const e of fs.readdirSync(d,{withFileTypes:true})){const p=path.join(d,e.name);if(e.isDirectory()){walk(p);continue;}const rel=path.relative(root,p).split(path.sep).join('/');if(!/\.(js|html)$/.test(rel)||rel.startsWith('dist/'))continue;const q=path.join(OLD,rel);if(!fs.existsSync(q)||sha(p)!==sha(q))diff.push(rel);}};
for(const d of ['host-core','instruments','exact-lib'])walk(path.join(root,d));
ok('source files differing from v0.4.12: '+diff.join(', '),diff.length===1&&diff[0]==='instruments/comb-hopf/view-fourier.js',diff.join(','));
for(const f of ['panel-g-robin.js','panel-bd.js'])ok(f+' byte-identical to v0.4.12',sha(path.join(root,'instruments/comb-hopf',f))===sha(path.join(OLD,'instruments/comb-hopf',f)));
console.log('\nSUMMARY test-v0413: '+pass+' pass, '+fail+' fail');process.exit(fail?1:0);
