'use strict';
// verifier's own path map (v0.4.19 verify): in build/, host-core/, exact-lib/ (.cjs, .sh, .sage) of one copy, rewrite the Neo root to the membrane root
// and the playwright require. Prints every changed file.
const fs=require('fs'),path=require('path');
const [dir,root]=process.argv.slice(2);
const R=[["require('C:/Users/robin/s6_atom/node_modules/playwright')","require('playwright')"],['file:///C:/Users/robin/s6_atom','file://'+root],['C:/Users/robin/s6_atom',root]];
let n=0;
for(const sub of ['build','host-core','exact-lib']){const d=path.join(dir,sub);if(!fs.existsSync(d))continue;
  for(const f of fs.readdirSync(d)){if(!/\.(cjs|sh|sage)$/.test(f))continue;const p=path.join(d,f),s=fs.readFileSync(p,'utf8');let t=s;for(const [a,b] of R)t=t.split(a).join(b);
    if(t!==s){fs.writeFileSync(p,t);console.log('mapped '+sub+'/'+f);n++;}}}
console.log('MAPPED '+n);
