const fs=require("fs");const B="../mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031/build/_logs/",N="../mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/build/_logs/";
const WHY={"test-v042":"new card: item 2 and 4-6 source changes (d1-event-pieces.js added; pen-interval-core, pen-curvature-core, pen-sphere-core, view-clifford, panel-pens, index.html changed), listed by the provenance comparison with v0.4.1",
"test-v0412":"new card: item 2, host-core/d1-event-pieces.js (new) now appears in the list of source files differing from v0.4.11",
"test-v0413":"new card: item 2, host-core/d1-event-pieces.js (new) now appears in the list of source files differing from v0.4.12",
"check-expected-fails-v0418":"new card: item 2, cascade: the v0.4.18 list holds the old test-v0412 / test-v0413 provenance lines, which now also name host-core/d1-event-pieces.js",
"browser-check-v0418":"new card: item 4, the readout says \"enclosure wider than ¼ px\" and \"pixel undecided\" instead of \"pixels not certified\" (the regex of the old check no longer matches; the wide count is 0)",
"browser-check-legacy-panels-v0418":"new card: item 2, the D1 curve group carries the new event-piece data attributes, so the D1-on stage HTML differs from v0.4.16"};
const out={};for(const s of Object.keys(WHY)){const nw=fs.readFileSync(N+s+".run.log","utf8").split("\n").filter(l=>l.startsWith("FAIL "));const bs=fs.existsSync(B+s+".run.log")?fs.readFileSync(B+s+".run.log","utf8").split("\n").filter(l=>l.startsWith("FAIL ")):[];
 out[s]={};for(const l of nw)if(!bs.includes(l))out[s][l]=WHY[s];}
fs.writeFileSync("labels_v0419_final.json",JSON.stringify(out,null,1));for(const s in out)console.log(s,Object.keys(out[s]).length);
