// FF-2 fidelity review: textual comparison of delivered statements and definitions
// against the frozen headers / accepted definitions; declaration inventory.
// Read-only on inputs. Usage: node compare_statements_v0_1.cjs <atom_skin_root>
'use strict';
const fs = require('fs'), path = require('path'), crypto = require('crypto');
const root = process.argv[2];
const P = (...a) => path.join(root, ...a);
const rd = p => fs.readFileSync(p, 'utf8');
const out = [];
const log = s => { out.push(s); console.log(s); };
let fail = 0;
const ok = (c, m) => { log((c ? 'OK   ' : 'FAIL ') + m); if (!c) fail++; };
const norm = s => s.replace(/\s+/g, ' ').trim();

// 1. Frozen headers
const H = rd(P('freeze_packet_v0_1', 'FF2_HEADERS_PROPOSED_v0_1.lean.txt')).split(/\r?\n/);
const frozen = {}; let cur = null, ns = null;
for (const line of H) {
  const mns = line.match(/^namespace (\S+)/); if (mns) { ns = mns[1]; continue; }
  const m = line.match(/^theorem (\S+)/);
  if (m) { cur = m[1]; frozen[cur] = { ns, text: line }; continue; }
  if (cur && (line.trim() === '' || /^(--|end|theorem|namespace)/.test(line))) { cur = null; continue; }
  if (cur) frozen[cur].text += '\n' + line;
}
const names = Object.keys(frozen);
ok(names.length === 28, `frozen header count = ${names.length}`);

// 2. Delivered statements
const src = P('batch07', 'producer_complete_v0_1', 'src');
const mods = ['FVLTAtomSkinCountsV1.lean', 'FVLTAtomSkinPenV1.lean', 'FVLTPillowcaseV1.lean'];
const delivered = {}; const inventory = {};
for (const f of mods) {
  const t = rd(path.join(src, f));
  inventory[f] = { public: [], private: [] };
  const re = /^(private\s+)?(theorem|lemma|def|abbrev|instance|axiom|opaque|structure|inductive|class|example)\s+(\S+)/gm;
  let m;
  while ((m = re.exec(t))) {
    (m[1] ? inventory[f].private : inventory[f].public).push(`${m[2]} ${m[3]}`);
    if (!m[1] && m[2] === 'theorem') {
      const start = m.index; const end = t.indexOf(':=', start);
      // namespace in force at that point
      const before = t.slice(0, start);
      const nsAll = [...before.matchAll(/^namespace (\S+)/gm)];
      delivered[m[3]] = { module: f, ns: nsAll.length ? nsAll[nsAll.length - 1][1] : null, text: t.slice(start, end) };
    }
  }
}
for (const n of names) {
  const d = delivered[n];
  if (!d) { ok(false, `${n}: not delivered`); continue; }
  ok(norm(d.text) === norm(frozen[n].text) && d.ns === frozen[n].ns,
     `${n} [${d.module}] statement equals frozen header (whitespace-normalised), namespace ${d.ns}`);
}
const extraPublic = Object.keys(delivered).filter(n => !frozen[n]);
ok(extraPublic.length === 0, `extra public theorems: ${JSON.stringify(extraPublic)}`);
let priv = 0;
for (const f of mods) {
  const pubNonThm = inventory[f].public.filter(x => !x.startsWith('theorem '));
  ok(pubNonThm.length === 0, `${f}: public non-theorem declarations ${JSON.stringify(pubNonThm)}`);
  log(`     ${f}: ${inventory[f].public.length} public, ${inventory[f].private.length} private`);
  priv += inventory[f].private.length;
}
ok(priv === 98, `private helper total = ${priv}`);
// risky constructs
for (const f of mods.concat(['FVLTAtomSkinDataV1.lean', 'FVLTPillowcaseDataV1.lean'])) {
  const t = rd(path.join(src, f));
  const hits = t.split(/\r?\n/).filter(l => /\b(sorry|admit|axiom|instance|attribute|set_option|macro|notation|unsafe|implemented_by|extern|native_decide|opaque|variable)\b|@\[|local /.test(l));
  ok(hits.length === 0, `${f}: no sorry/axiom/instance/attribute/notation/variable/native_decide lines (${hits.length} hits)`);
}

// 3. Data namespace blocks
const block = (t, ns) => { const a = t.indexOf(`namespace ${ns}`); const b = t.indexOf(`end ${ns}`, a); return t.slice(a, b + `end ${ns}`.length); };
const d3 = rd(P('definition_repair_v0_1', 'FF2_DEFINITIONS_PROPOSED_v0_3.lean.txt'));
const d1 = rd(P('freeze_packet_v0_1', 'FF2_DEFINITIONS_PROPOSED_v0_1.lean.txt'));
const sd = rd(path.join(src, 'FVLTAtomSkinDataV1.lean'));
const pd = rd(path.join(src, 'FVLTPillowcaseDataV1.lean'));
ok(block(sd, 'FVLT.AtomSkinV1') === block(d3, 'FVLT.AtomSkinV1'), 'AtomSkinData namespace block byte-equal to definitions v0.3');
ok(block(pd, 'FVLT.PillowcaseV1') === block(d1, 'FVLT.PillowcaseV1'), 'PillowcaseData namespace block byte-equal to definitions v0.1');
ok(block(d1, 'FVLT.PillowcaseV1') === block(d3, 'FVLT.PillowcaseV1'), 'Pillowcase block identical in v0.1 and v0.3');
const outsideS = sd.replace(block(sd, 'FVLT.AtomSkinV1'), '');
const outsideP = pd.replace(block(pd, 'FVLT.PillowcaseV1'), '');
log('     AtomSkinData outside namespace:\n' + outsideS.trim().split('\n').map(l => '       | ' + l).join('\n'));
log('     PillowcaseData outside namespace:\n' + outsideP.trim().split('\n').map(l => '       | ' + l).join('\n'));
log(`RESULT: ${fail === 0 ? 'ALL OK' : fail + ' FAIL'}`);
fs.writeFileSync(path.join(__dirname, 'compare_statements_v0_1.out.txt'), out.join('\n') + '\n');
