// Compare delivered public theorem statements with the frozen headers (b4484f6e...).
// Usage: node SKELETON_FF2_HEADER_COMPARE_v0_1.cjs HEADERS SRC...
"use strict";
const fs = require('fs');
const [hdrPath, ...srcs] = process.argv.slice(2);
const frozen = {};
{ const lines = fs.readFileSync(hdrPath, 'utf8').split('\n'); let cur = null;
  for (const l of lines) {
    const m = l.match(/^theorem (\S+)/);
    if (m) { cur = m[1]; frozen[cur] = [l]; continue; }
    if (cur && /^\s+\S/.test(l)) frozen[cur].push(l); else cur = null;
  } }
const out = { frozenCount: Object.keys(frozen).length, results: [] };
for (const s of srcs) {
  const text = fs.readFileSync(s, 'utf8');
  out.results.push({ file: s, forbidden: (text.match(/\bsorry\b|\badmit\b|^\s*axiom\b|unsafe|implemented_by|@\[extern/mg) || []) });
  const lines = text.split('\n');
  for (let i = 0; i < lines.length; i++) {
    const m = lines[i].match(/^(private\s+)?(theorem|lemma|def|instance|abbrev|structure|inductive)\s+(\S+)/);
    if (!m) continue;
    const priv = !!m[1], kind = m[2], name = m[3];
    if (priv) { out.results.push({ file: s, name, kind, private: true }); continue; }
    if (kind !== 'theorem') { out.results.push({ file: s, name, kind, PUBLIC_NON_THEOREM: true }); continue; }
    const blk = [lines[i]]; let j = i + 1;
    while (!/:=/.test(blk[blk.length - 1])) blk.push(lines[j++]);
    const last = blk.length - 1; blk[last] = blk[last].replace(/\s*:=.*$/, '');
    const f = frozen[name];
    out.results.push({ file: s, name, inFreeze: !!f, exactBytes: !!f && f.join('\n') === blk.join('\n'),
      sameTokens: !!f && f.join(' ').split(/\s+/).join(' ').trim() === blk.join(' ').split(/\s+/).join(' ').trim() });
  }
}
console.log(JSON.stringify(out, null, 1));
