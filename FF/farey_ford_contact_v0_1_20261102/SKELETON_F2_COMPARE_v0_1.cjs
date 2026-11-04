// Skeleton F2 audit: frozen headers and definitions vs FVLTFareyCertificatesV1.lean.
// Accepted differences: erratum S1 binder annotations only; `private` helpers are listed, not compared.
"use strict";
const fs=require("fs");
const sig=fs.readFileSync("SIGNATURE_FREEZE_DRAFT_v0_1.md","utf8");
const tpl=JSON.parse(fs.readFileSync("F2_JOB_TEMPLATE_v0_1.json","utf8"));
const src=fs.readFileSync("FVLTFareyCertificatesV1.lean","utf8");
const S1=[["(fun c => (c : ℚ) / (q : ℚ))","(fun c : ℕ => (c : ℚ) / (q : ℚ))"],["(fun e => (e : ℚ) / ((a + 1 : ℕ) : ℚ))","(fun e : ℕ => (e : ℚ) / ((a + 1 : ℕ) : ℚ))"]];
let sigS1=sig; for(const [a,b] of S1) sigS1=sigS1.split(a).join(b);
let fails=0; const say=(ok,m)=>{ console.log((ok?"OK   ":"FAIL ")+m); if(!ok) fails++; };
const hs=Object.values(tpl.frozen_headers);
for(const h of hs) say(src.includes(h), "header verbatim in source: "+h.split("\n")[0]);
// every top-level def / theorem / lemma (not private): its full text up to ':=' must be in the frozen file (S1 reading)
const re=/^(noncomputable\s+)?(def|theorem|lemma|abbrev|instance)\b[\s\S]*?(?=:=)/gm; let m;
while((m=re.exec(src))){ const head=m[0].replace(/^noncomputable\s+/,"").replace(/\s+$/,""); say(sigS1.includes(head), "frozen (S1 reading): "+head.split("\n")[0]); }
// definition bodies: each line of each top-level def block must be a frozen line (S1 reading), whitespace-trimmed
const sigLines=new Set(sigS1.split("\n").map(l=>l.trim()));
const lines=src.split("\n"); let inDef=false;
for(const l of lines){ if(/^(noncomputable\s+)?def\b/.test(l)) inDef=true; else if(inDef && (l.trim()===""||/^(theorem|lemma|private|def|noncomputable|instance|#|end|namespace|open|section)\b/.test(l))) inDef=/^(noncomputable\s+)?def\b/.test(l);
  if(inDef && l.trim()) say(sigLines.has(l.trim().replace(/^noncomputable\s+/,"")), "def line: "+l.trim().slice(0,90)); }
const priv=[...src.matchAll(/^private\s+(theorem|lemma|def)\s+(\S+)/gm)].map(x=>x[2]); console.log("private helpers:", priv.join(", ")||"none");
for(const bad of ["sorry","admit","native_decide","unsafe","partial def","axiom "]) say(!src.includes(bad), "no '"+bad.trim()+"'");
const imps=[...src.matchAll(/^import\s+(\S+)/gm)].map(x=>x[1]); say(imps.every(i=>i==="Mathlib"||i.startsWith("Mathlib.")||i==="FVLTFareyContactV1"), "imports "+imps.join(", "));
console.log(JSON.stringify({fails}));
process.exitCode=fails?1:0;
