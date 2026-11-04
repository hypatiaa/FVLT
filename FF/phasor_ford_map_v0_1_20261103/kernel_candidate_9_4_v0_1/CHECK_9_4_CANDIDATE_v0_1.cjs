// Check of kernel correction candidate FF3-FORD-9.4-ROW against the locked v3.4.0 kernel.
// Usage: node CHECK_9_4_CANDIDATE_v0_1.cjs KERNEL_v3_4_0.md CANDIDATE.md OUT_DIR
// Writes REPLACEMENT_FF3-FORD-9.4-ROW_v0_1.json beside the candidate and an applied copy to OUT_DIR. Never edits the kernel.
"use strict";
const fs = require('fs'), path = require('path'), crypto = require('crypto');
const [kp, cp, outDir] = process.argv.slice(2);
const sha = b => crypto.createHash('sha256').update(b).digest('hex');
const kb = fs.readFileSync(kp), k = kb.toString('utf8');
const OLD = '| **Ford circles** | Circle of radius $1/(2q^2)$ at $p/q$; tangent iff Farey neighbors [For38]. A map sending Vernier phasor paths to Ford-circle arcs has not been defined; this is an interpretive comparison only. |';
const cand = fs.readFileSync(cp, 'utf8').split('\n');
const NEW = cand.find(l => l.startsWith('| **Ford circles** |') && l.includes('Lifted-data map'));
const count = s => k.split(s).length - 1;
const out = { base_sha256: sha(kb), candidate_sha256: sha(fs.readFileSync(cp)), old_occurrences: count(OLD), new_found_in_candidate: !!NEW };
if (out.old_occurrences === 1 && NEW) {
  const applied = k.replace(OLD, NEW), a = k.split('\n'), b = applied.split('\n');
  const changed = a.map((l, i) => (l !== b[i] ? i + 1 : 0)).filter(Boolean);
  out.lines_before = a.length; out.lines_after = b.length; out.changed_lines = changed;
  out.new_occurrences_after = applied.split(NEW).length - 1;
  out.applied_sha256 = sha(Buffer.from(applied, 'utf8'));
  out.non_ascii_dollar_balance_ok = (NEW.match(/\$/g) || []).length % 2 === 0;
  out.ford_not_defined_mentions_after = (applied.match(/Ford-circle arcs/g) || []).length;
  fs.mkdirSync(outDir, { recursive: true });
  fs.writeFileSync(path.join(outDir, 'kernel_v3_4_0_with_FF3-FORD-9.4-ROW.md'), applied);
  const rep = { id: 'FF3-FORD-9.4-ROW', kind: 'mathematical correction (scope narrowing to the Lean-verified FF-3 construction)',
    note: 'Narrows the row\'s "not defined" to what remains open (arcs, unlabelled phasor paths, dynamics); the lifted-data map is Lean-verified in FF-3 (final audit #1554, library v23 #1556). No native item or tag changes.',
    base_sha256: out.base_sha256, old: OLD, new: NEW };
  fs.writeFileSync(path.join(path.dirname(cp), 'REPLACEMENT_FF3-FORD-9.4-ROW_v0_1.json'), JSON.stringify(rep, null, 1) + '\n');
}
console.log(JSON.stringify(out, null, 1));
