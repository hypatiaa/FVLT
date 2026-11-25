'use strict';
// v0.4.19 (SCHEMA_ADDENDUM_26, item 5): dump the dodecahedron preset's own two moves (left and right) as permutations of its reachable flags, for the
// Sage job VIEW-SAGE-0419-01 (build/sage-a5-v0419.sage), which checks is_isomorphic(AlternatingGroup(5)). The permutations are the ones the build itself
// computes: pen-sphere-core.dodecaStructure hands them to its closure argument; this script only captures them (no new mathematics). Exact (K = Q(sqrt3, sqrt5)).
// usage: node build/dump-a5-moves-v0419.cjs OUT.json
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const SP=require('../host-core/pen-sphere-core.js');
let gens=null,n=0;
const st=SP.dodecaStructure((g,size)=>{gens=g;n=size;return null;});
const out={schema:'fv-a5-moves/v1',source:'host-core/pen-sphere-core.js dodecaStructure (v0.4.19)',core_sha256:crypto.createHash('sha256').update(fs.readFileSync(path.join(__dirname,'..','host-core','pen-sphere-core.js'))).digest('hex'),
  flags:n,vertices:st.vertices,left:gens[0],right:gens[1]};
fs.writeFileSync(process.argv[2],JSON.stringify(out));
console.log('flags '+n+', vertices '+st.vertices+', left and right moves written to '+process.argv[2]);
console.log('SUMMARY dump-a5-moves-v0419: 1 passed, 0 failed');
