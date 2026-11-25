'use strict';
// Builder-only finalization. Never called by a verifier. Refuses to reseal an existing manifest.
const fs=require('node:fs'),path=require('node:path'),T=require('./t1.cjs'),{inventory}=require('../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/verify.cjs');
if(process.argv.length!==3||process.argv[2]!=='--seal-new-candidate')throw Error('Use only when authoring: node seal-authoring.cjs --seal-new-candidate');
if(fs.existsSync(path.join(__dirname,'MANIFEST.sha256')))throw Error('Already sealed; create an additive successor');
const pinPaths=['../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/MANIFEST.sha256','../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/model-replay.cjs','../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/minimal-tate-record.schema.json','../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/IMPLEMENTATION_PLAN.md','../MINIMAL_TATE_SCHEMA_v0_3_COLD_AUDIT_FABLE_20260907.md','../MINIMAL_TATE_SCHEMA_v0_3_COLD_AUDIT_FABLE_20260907.json','../BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907/MANIFEST.sha256','../BSD_MINIMAL_TATE_SCHEMA_v0_1_20260907/MANIFEST.sha256','../MCOMB_CARRIER_ADDITION_v0_1_20260907/MANIFEST.sha256','../BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/monodromy-30-1-reduction-audit.html','../.bsd-arithmetic-runtime/gp-sta.js','../.bsd-arithmetic-runtime/gp-sta.wasm'];
const pins=pinPaths.map(p=>({path:p,sha256:T.shaFile(path.resolve(__dirname,p))}));
fs.writeFileSync(path.join(__dirname,'SOURCE_PINS.json'),JSON.stringify(pins,null,2)+'\n');
const files=inventory(__dirname);fs.writeFileSync(path.join(__dirname,'MANIFEST.sha256'),Object.entries(files).map(([n,h])=>h+'  '+n).join('\n')+'\n');
console.log(JSON.stringify(require('./check-integrity.cjs').check(),null,2));
