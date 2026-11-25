require('./worker-guard.cjs')();
const fs=require('node:fs'),path=require('node:path'),Module=require('node:module');
// Run the immediate predecessor's 20 connected-panel tests against .30; retain all source files.
let code=fs.readFileSync(path.join(__dirname,'../MCOMB_CONNECTED_PANELS_v0_1_20260907/check-browser.cjs'),'utf8');
code=code.replace(/require\(['"]C:\/Users\/[^'"]+\/node_modules\/playwright['"]\)/g,"require('./runtime-browser.cjs')");
code=code.replaceAll('monodromy-29-1-mcomb-connected.html','monodromy-30-1-reduction-audit.html').replaceAll('browser-verification.json','regression-verification.json').replaceAll('connected-export-fixture.json','regression-export-fixture.json');
for(const name of ['elliptic-mcomb-desktop.png','bsd-mcomb-desktop.png','elliptic-mcomb-mobile.png','bsd-mcomb-mobile.png'])code=code.replaceAll(name,'regression-'+name);
// The inherited predecessor-import fixture has an explicit parent path; that path remains valid here.
const m=new Module(__filename,module);m.filename=__filename;m.paths=module.paths;m._compile(code,__filename);
