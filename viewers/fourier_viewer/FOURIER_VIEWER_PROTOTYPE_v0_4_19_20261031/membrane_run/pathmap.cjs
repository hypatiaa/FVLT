'use strict';
// membrane run copies: rewrite only the Windows root and the playwright require, in the .cjs and .sh files of build/, host-core/, exact-lib/ of one build-folder copy.
// usage: node pathmap.cjs <build folder copy> <mirror root>; prints the files changed (diffs are made with diff -u against an untouched copy)
const fs=require('fs'),path=require('path');
const [dir,mirror]=process.argv.slice(2);
const RULES=[["require('C:/Users/robin/s6_atom/node_modules/playwright')","require('playwright')"],['file:///C:/Users/robin/s6_atom','file://'+mirror],['C:/Users/robin/s6_atom',mirror]];
let changed=[];
for(const sub of ['build','host-core','exact-lib'])for(const f of fs.readdirSync(path.join(dir,sub))){if(!/\.(cjs|sh)$/.test(f))continue;const p=path.join(dir,sub,f);let s=fs.readFileSync(p,'utf8'),t=s;
  for(const [a,b] of RULES)t=t.split(a).join(b);if(t!==s){fs.writeFileSync(p,t);changed.push(sub+'/'+f);}}
console.log(changed.join('\n'));console.log('CHANGED '+changed.length);
