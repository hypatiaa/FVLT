// Fidelity reviewer: compare delivered theorem statements against the 37 frozen headers,
// confirm the data module equals the accepted v0.2 definitions, and inventory declarations.
// Read-only on inputs. Usage: node statement_compare.cjs
'use strict';
const fs = require('fs');
const path = require('path');
const ROOT = path.resolve(__dirname, '..');
const rd = (p) => fs.readFileSync(path.join(ROOT, p), 'utf8').replace(/\r\n/g, '\n');
const norm = (s) => s.replace(/--[^\n]*/g, '').replace(/\s+/g, ' ').trim();

const headers = rd('freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt');
const mods = {
  FVLTRosetteFordPhaseV1: 'final_source_packet_v0_1/sources/FVLTRosetteFordPhaseV1.lean',
  FVLTRosetteFordArithmeticV1: 'final_source_packet_v0_1/sources/FVLTRosetteFordArithmeticV1.lean',
  FVLTRosetteFordSweepV1: 'final_source_packet_v0_1/sources/FVLTRosetteFordSweepV1.lean',
  FVLTRosetteFordEndpointsV1: 'final_source_packet_v0_1/sources/FVLTRosetteFordEndpointsV1.lean',
};

// headers: split on "theorem " at line starts; module from preceding "-- FVLT..." comment
const hdr = [];
let curMod = null;
const hLines = headers.split('\n');
let buf = null;
for (const ln of hLines) {
  const m = ln.match(/^-- (FVLTRosetteFord\w+):/);
  if (m) { if (buf) { hdr.push(buf); buf = null; } curMod = m[1]; continue; }
  if (/^theorem /.test(ln)) { if (buf) hdr.push(buf); buf = { mod: curMod, text: ln }; continue; }
  if (/^end /.test(ln)) { if (buf) hdr.push(buf); buf = null; continue; }
  if (buf) buf.text += '\n' + ln;
}
if (buf) hdr.push(buf);
const headerMap = new Map();
for (const h of hdr) {
  const name = h.text.match(/^theorem (\S+)/)[1];
  headerMap.set(name, { mod: h.mod, stmt: norm(h.text) });
}

// sources: extract each top-level declaration; statement = text up to first ":= by" or ":=" at decl level
const delivered = new Map();
const privates = [];
const otherDecls = [];
for (const [mod, p] of Object.entries(mods)) {
  const src = rd(p);
  const re = /^(private theorem|theorem|lemma|def|instance|axiom|abbrev|noncomputable def|structure|inductive)\s+(\S+)/gm;
  const starts = [];
  let mm;
  while ((mm = re.exec(src))) starts.push({ kind: mm[1], name: mm[2], idx: mm.index });
  for (let i = 0; i < starts.length; i++) {
    const s = starts[i];
    const end = i + 1 < starts.length ? starts[i + 1].idx : src.length;
    const body = src.slice(s.idx, end);
    // statements containing 'let x := ...' need the proof-start ':= by'; fall back to ':='
    let cut = body.search(/:=\s*by\b/);
    if (cut < 0) cut = body.indexOf(':=');
    const stmt = norm(body.slice(0, cut));
    if (s.kind === 'theorem') delivered.set(s.name, { mod, stmt });
    else if (s.kind === 'private theorem') privates.push({ mod, name: s.name, stmt });
    else otherDecls.push({ mod, kind: s.kind, name: s.name });
  }
}

const rows = [];
let ok = 0;
for (const [name, h] of headerMap) {
  const d = delivered.get(name);
  const match = !!d && d.stmt === h.stmt && d.mod === h.mod;
  if (match) ok++;
  rows.push({ name, header_module: h.mod, delivered_module: d ? d.mod : null, statement_identical: match });
}
const extraPublic = [...delivered.keys()].filter((n) => !headerMap.has(n));

const dataSrc = fs.readFileSync(path.join(ROOT, 'final_source_packet_v0_1/sources/FVLTRosetteFordDataV1.lean'));
const dataV2 = fs.readFileSync(path.join(ROOT, 'definition_repair_v0_1/FF3_DEFINITIONS_PROPOSED_v0_2.lean.txt'));
const dataDefs = [...dataSrc.toString('utf8').matchAll(/^(structure|def|noncomputable def|inductive)\s+(\S+)/gm)].map((m) => m[2]);

const imports = {};
for (const [mod, p] of Object.entries({ ...mods, FVLTRosetteFordDataV1: 'final_source_packet_v0_1/sources/FVLTRosetteFordDataV1.lean' })) {
  imports[mod] = [...rd(p).matchAll(/^import\s+(\S+)/gm)].map((m) => m[1]);
}
const out = {
  headers_found: headerMap.size,
  delivered_public_theorems: delivered.size,
  statements_identical: ok,
  extra_public_theorems_not_in_headers: extraPublic,
  rows,
  data_module_bytes_equal_v0_2: Buffer.compare(dataSrc, dataV2) === 0,
  data_definitions: dataDefs,
  data_definition_count: dataDefs.length,
  private_helpers: privates,
  non_theorem_declarations_in_proof_modules: otherDecls,
  imports,
};
console.log(JSON.stringify(out, null, 2));
