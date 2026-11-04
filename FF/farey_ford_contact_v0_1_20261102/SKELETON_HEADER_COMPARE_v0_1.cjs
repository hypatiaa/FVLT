// Skeleton I3 audit helper: every definition and theorem header in the F1 sources must occur verbatim
// in the frozen signature file; the template's frozen F1 headers must occur verbatim in both.
// Usage: node SKELETON_HEADER_COMPARE_v0_1.cjs <signature.md> <template.json> <source.lean>...
"use strict";
const fs=require("fs");
const [sigPath, tplPath, ...srcs]=process.argv.slice(2);
const sig=fs.readFileSync(sigPath,"utf8"), tpl=JSON.parse(fs.readFileSync(tplPath,"utf8"));
let fails=0; const say=(ok,msg)=>{ console.log((ok?"OK   ":"FAIL ")+msg); if(!ok) fails++; };
for(const h of tpl.frozen_F1_headers) say(sig.includes(h), "template header in signature file: "+h.split("\n")[0]);
const all=srcs.map(p=>fs.readFileSync(p,"utf8")).join("\n");
for(const h of tpl.frozen_F1_headers) say(all.includes(h), "template header in sources: "+h.split("\n")[0]);
// each top-level def/theorem/lemma statement in the sources, up to ":=" (bodies excluded)
for(const p of srcs){
  const t=fs.readFileSync(p,"utf8"), re=/^(def|theorem|lemma|abbrev|instance|axiom|opaque)\b[\s\S]*?(?=:=)/gm; let m;
  while((m=re.exec(t))){ const head=m[0].replace(/\s+$/,"");
    if(/^(axiom|opaque)/.test(head)){ say(false, p+": forbidden declaration "+head.split("\n")[0]); continue; }
    say(sig.includes(head), p+": frozen verbatim: "+head.split("\n")[0]); }
  for(const bad of ["sorry","admit","native_decide","unsafe","partial def","axiom "]) say(!t.includes(bad), p+": no '"+bad.trim()+"'");
  const imps=[...t.matchAll(/^import\s+(\S+)/gm)].map(x=>x[1]);
  say(imps.every(i=>i==="Mathlib"||i.startsWith("Mathlib.")||i==="FVLTFareyContactV1"), p+": imports "+imps.join(", "));
}
console.log(JSON.stringify({fails}));
process.exitCode=fails?1:0;
