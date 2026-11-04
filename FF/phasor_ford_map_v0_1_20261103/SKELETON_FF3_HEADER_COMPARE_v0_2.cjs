// Successor of SKELETON_FF2_HEADER_COMPARE_v0_1.cjs: strips CR, and ends a statement at a
// line ending in ":=" or ":= by" (not at the first ":=", which breaks on `let x := ...`).
"use strict";
const fs = require('fs');
const [hdr, ...srcs] = process.argv.slice(2);
const rd = p => fs.readFileSync(p, 'utf8').replace(/\r/g, '').split('\n');
const frozen = {}; { let cur = null; for (const l of rd(hdr)) { const m = l.match(/^theorem (\S+)/);
  if (m) { cur = m[1]; frozen[cur] = [l]; continue; } if (cur && /^\s+\S/.test(l)) frozen[cur].push(l); else cur = null; } }
const out = { frozen: Object.keys(frozen).length, publics: [], privates: 0, nonThm: [], forbidden: [], crFiles: [] };
for (const s of srcs) {
  const raw = fs.readFileSync(s, 'utf8'); if (raw.includes('\r')) out.crFiles.push(s);
  const t = raw.replace(/\r/g, ''); out.forbidden.push(...(t.match(/\bsorry\b|\badmit\b|^\s*axiom\b|\bunsafe\b|implemented_by|@\[extern/mg) || []));
  const L = t.split('\n');
  for (let i = 0; i < L.length; i++) { const m = L[i].match(/^(private\s+)?(theorem|lemma|def|instance|abbrev|structure|inductive)\s+(\S+)/); if (!m) continue;
    if (m[1]) { out.privates++; continue; } if (m[2] !== 'theorem') { out.nonThm.push(m[3]); continue; }
    const b = [L[i]]; let j = i; while (!/:=\s*(by)?\s*$/.test(b[b.length - 1])) b.push(L[++j]);
    b[b.length - 1] = b[b.length - 1].replace(/\s*:=\s*(by)?\s*$/, '');
    const f = frozen[m[3]]; out.publics.push([m[3], !!f && f.join('\n') === b.join('\n')]); }
}
const names = out.publics.map(p => p[0]);
out.allExact = out.publics.every(p => p[1]); out.distinct = new Set(names).size; out.missing = Object.keys(frozen).filter(n => !names.includes(n));
console.log(JSON.stringify(out, null, 1));
