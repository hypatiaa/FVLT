'use strict';
// Dev-time only: inlines the module sources into one self-contained HTML file and writes dist/MANIFEST.sha256.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const root=path.join(__dirname,'..'),dir=path.join(root,'instruments','comb-hopf');
const sha=b=>crypto.createHash('sha256').update(b).digest('hex');
let html=fs.readFileSync(path.join(dir,'index.html'),'utf8');
const LIBSHA='3edfc8fb396fda90cfa945963eb18ccdf243f5a491e3ee49275b5c459a223a71',LIBSRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js';
const libCopy=path.join(root,'exact-lib','exact-lib-0.2.0.js');
if(sha(fs.readFileSync(libCopy))!==LIBSHA)throw Error('exact-lib 0.2.0 sha256 mismatch');
if(fs.existsSync(LIBSRC)&&sha(fs.readFileSync(LIBSRC))!==LIBSHA)throw Error('exact-lib 0.2.0 source sha256 mismatch');
const mods=[];
html=html.replace(/<script src="([^"]+)"><\/script>\n?/g,(m,src)=>{
  const file=path.resolve(dir,src),buf=fs.readFileSync(file),text=buf.toString('utf8');
  if(/<\/script/i.test(text))throw Error('source contains </script: '+src);
  mods.push({rel:path.relative(root,file).split(path.sep).join('/'),sha:sha(buf)});
  return '<script>\n'+text.replace(/\n$/,'')+'\n</script>\n';});
html=html.replace('</body>',()=>'<script type="application/json" id="fv-build-pins">'+JSON.stringify({schema:'fv-comb-hopf-build/0.1',viewer:'comb-hopf v0.4.19',exact_lib:{name:'exact-lib',version:'0.2.0',sha256:LIBSHA,source:'FOURIER_VIEWER_LIBS/exact-lib-0.2.0/dist/exact-lib.js',inlined_as:'exact-lib/exact-lib-0.2.0.js'},modules:mods.map(m=>({path:m.rel,sha256:m.sha}))})+'</script>'+String.fromCharCode(10)+'</body>');
if(/(src|href)\s*=\s*"https?:/i.test(html))throw Error('external src/href found');
if(html.indexOf('<meta charset="utf-8">')>1024)throw Error('charset not in first 1024 bytes');
const out=path.join(root,'dist','comb-hopf.html');fs.mkdirSync(path.dirname(out),{recursive:true});fs.writeFileSync(out,html);
const lines=mods.map(m=>m.sha+'  '+m.rel);lines.push(sha(fs.readFileSync(out))+'  dist/comb-hopf.html');
fs.writeFileSync(path.join(root,'dist','MANIFEST.sha256'),lines.join('\n')+'\n');
console.log(lines.join('\n'));
