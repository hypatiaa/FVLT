'use strict';
// Authoring command: writes a new manifest. Use check-integrity.cjs for read-only audit checks.
const fs=require('node:fs'),path=require('node:path'),crypto=require('node:crypto'),assert=require('node:assert/strict'),{inventory,manifest}=require('./verify.cjs');
const read=n=>fs.readFileSync(path.join(__dirname,n)),hash=b=>crypto.createHash('sha256').update(b).digest('hex');
const names=['schema-semantic','schema-python','local-gates','good-certificates','valuation-gates','math','browser','regression','maintenance','runtime'];
const expectedTotals=[40,23,22,4,25,17,19,20,3,9];
const receipts=names.map(name=>({name,...JSON.parse(read('receipts/'+name+'-verification.json'))}));
for(const [i,r] of receipts.entries()){assert.equal(r.total,expectedTotals[i]);assert.equal(r.total,r.checks.length);assert(r.checks.every(x=>x.status==='PASS'));if(r.pageErrors)assert.deepEqual(r.pageErrors,[]);}
const math=receipts.find(x=>x.name==='math');assert.equal(math.formulaCases,84);assert.deepEqual(math.formulaTally,{pairPASS:84,doublingPASS:84});
const run=JSON.parse(read('receipts/scratch-verification.json'));assert.equal(run.status,'PASS');assert.equal(run.suite,'all');
assert.deepEqual(run.checks.map(x=>x.name),[...names,'Candidate and all staged source dependencies unchanged']);assert(run.checks.every(x=>x.status==='PASS'));
const tested=run.inputInventories[path.basename(__dirname)],now=inventory(__dirname);for(const [file,pin] of Object.entries(tested))assert.equal(now[file],pin,'Changed since scratch run: '+file);
const authoringFiles=o=>Object.fromEntries(Object.entries(o).filter(([n])=>!n.startsWith('receipts/')&&!['MANIFEST.sha256','package-verification.json'].includes(n)));
assert.deepEqual(authoringFiles(now),authoringFiles(tested),'Source files added, removed or changed since scratch run');
const pins=JSON.parse(read('SOURCE_PINS.json'));assert.equal(hash(read('monodromy-30-1-reduction-audit.html')),pins.candidateSha256);
const predecessor=manifest(path.join(__dirname,'../MCOMB_CARRIER_ADDITION_v0_1_20260907'));assert.equal(predecessor.sha256,pins.predecessorManifestSha256);
const schemaPredecessor=manifest(path.join(__dirname,'../BSD_MINIMAL_TATE_SCHEMA_v0_2_20260907'));assert.equal(schemaPredecessor.sha256,pins.schemaPredecessorManifestSha256);
const schemaAncestor=manifest(path.join(__dirname,'../BSD_MINIMAL_TATE_SCHEMA_v0_1_20260907'));assert.equal(schemaAncestor.sha256,pins.schemaAncestorManifestSha256);
const entries=Object.entries(now).filter(([n])=>!['MANIFEST.sha256','package-verification.json'].includes(n)).sort(([a],[b])=>a.localeCompare(b));
const content=entries.map(([name,pin])=>pin+'  '+name).join('\n')+'\n';fs.writeFileSync(path.join(__dirname,'MANIFEST.sha256'),content);
const summary={standing:'AUDIT_CANDIDATE_WITH_LOCAL_VERIFICATION',version:'0.3',fileCount:entries.length,manifestSha256:hash(content),schemaPredecessorManifestSha256:schemaPredecessor.sha256,schemaAncestorManifestSha256:schemaAncestor.sha256,predecessorManifestSha256:predecessor.sha256,implementedAuditRepairs:['H1_TAME_KODAIRA_VALUATIONS','H2_Q_CONDUCTOR_BOUNDS'],goodPrimeLocalCertificationImplemented:true,badPrimeTamagawaCertificationImplemented:false,tateEngineImplemented:false,heightsImplemented:false,liveGeneralModelAdapterImplemented:false,independentAuditClaimed:false,lockEligible:false,checks:receipts.map(r=>({name:r.name,total:r.total,status:'PASS'})),strictFormulaTally:math.formulaTally,verifiedScratch:run.scratchPackage};
fs.writeFileSync(path.join(__dirname,'package-verification.json'),JSON.stringify(summary,null,2)+'\n');console.log(entries.length+' files pinned; scoped good-prime assessment implemented; full Tate and heights remain planned.');
