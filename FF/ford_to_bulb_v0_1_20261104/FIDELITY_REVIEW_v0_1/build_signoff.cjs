// Builds FIDELITY_SIGNOFF_v0_1.json from the verdict table below plus fresh SHA-256 of reviewed files.
'use strict';
const fs = require('fs'), path = require('path'), crypto = require('crypto');
const base = path.resolve(__dirname, '..');
const sha = f => crypto.createHash('sha256').update(fs.readFileSync(path.join(base, f))).digest('hex');
const reviewed = [
  'WORK_ORDER_v0_2.md',
  'owner_review_v0_1/REVIEW_v0_1.md',
  'owner_review_v0_1/C1_PROOF_ROUTE_v0_1.md',
  'owner_review_v0_1/ACCEPTANCE_v0_2.md',
  'freeze_packet_v0_1/FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt',
  'freeze_packet_v0_1/FF4_HEADERS_PROPOSED_v0_1.lean.txt',
  'freeze_packet_v0_1/API_AND_SCOPE_NOTES_v0_1.md',
  'FF4_FREEZE_DECISION_v0_1.md',
  'final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyContactV1.lean',
  'final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyCertificatesV1.lean',
  'final_source_packet_v0_1/accepted_original_freeze/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean',
  'final_source_packet_v0_1/sources/FVLTFordBulbDataV1.lean',
  'final_source_packet_v0_1/sources/FVLTFordBulbParameterV1.lean',
  'final_source_packet_v0_1/sources/FVLTFordBulbCombinatoricsV1.lean',
];
const own = ['fidelity_check.cjs', 'header_compare.cjs', 'build_signoff.cjs', 'check_none.json', 'check_reversed_weight.json',
  'check_lower_index_plus.json', 'check_wrap_no_modulus.json', 'check_c3_midpoint.json', 'check_swap_hasderiv.json',
  'header_compare_output.json', 'header_compare_negative_control.json'].map(f => 'FIDELITY_REVIEW_v0_1/' + f);
const C = 'FVLTFordBulbCombinatoricsV1', P = 'FVLTFordBulbParameterV1', D = 'FVLTFordBulbDataV1';
const T = (name, module, verdict, work_order_locator, scope_note) => ({ name, module, verdict, scope_note, work_order_locator });
const targets = [
  T('address_canonical', C, 'MATCH', '§3 "The map" bridge; change 3; review item 3', 'num(p/q)=p and den=q for every guarded record: the proved bridge to the canonical rational p/q.'),
  T('address_interval', C, 'MATCH', '§1, change 2 (Psi undefined at 0 and 1)', 'Every address lies strictly in (0,1); no endpoint value.'),
  T('address_injective', C, 'MATCH', '§3 "The map"; change 3', 'Record equality from equal rationals (proof fields are Props). With surjective, records biject with rationals in (0,1).'),
  T('address_surjective', C, 'MATCH', '§1; change 5 (C1 for all reduced fractions in (0,1))', 'Every rational in (0,1) has an address, so statements over RotationAddress cover every reduced fraction in (0,1).'),
  T('q_at_least_two', C, 'MATCH', 'B0; change 2', 'q >= 2.'),
  T('modulus_pos', C, 'MATCH', 'B0; change 2', 'M = 2^q - 1 > 0 (Nat subtraction harmless since q >= 2).'),
  T('word_sum', C, 'MATCH', '§3 Mechanical words; change 2 (Fin q, weight 2^(q-1-i))', 'Range-sum implementation equals the Fin q sum with weight 2^(q-1-i). Negative control reversed_weight fails this target.'),
  T('upper_digit_equiv', C, 'MATCH', '§3 Characteristic numerators (b+_j, j=i+1)', 'Digit of W(p) at Fin index i equals [((i+1)p mod q) >= q-p], the order\'s one-based plus rule.'),
  T('lower_digit_equiv', C, 'MATCH', '§3 Characteristic numerators (b-_j); change 2 (j*p >= 1 before subtraction)', 'Conjunct 1 <= (i+1)p is proved, then digit of W(p-1) equals [(((i+1)p - 1) mod q) >= q-p]. The data itself uses u = p-1 (p >= 1 from the record), so no underflow is used anywhere.'),
  T('word_bounds', C, 'MATCH', 'B0 (bounds); §5 B5 architecture (0 < W(0), W(q-1) < M)', '0 < W(u) < M for every u : Fin q. Supporting B0 target; more than the B0 cell lists, used for the wrap gap.'),
  T('characteristic_bounds', C, 'MATCH', 'B0', '0 < N- < N+ < M. N- = W(p-1) and N+ = W(p) hold by definition (lowerNumerator/upperNumerator), not as separate theorems.'),
  T('characteristic_adjacent', C, 'MATCH', 'B1', 'N+ = N- + 1 in Nat.'),
  T('characteristic_angle_gap', C, 'MATCH', 'B1', 'theta+ - theta- = 1/M in Q.'),
  T('characteristic_period_return', C, 'MATCH', 'B2 (return); change 1', '(2^q * n) mod M = n for n in {N-, N+}; equivalent to 2^q N == N (mod M) because N < M.'),
  T('characteristic_period_minimal', C, 'MATCH', 'B2 (minimality); change 1', '(2^k * n) mod M != n for 0 < k < q, n in {N-, N+}; equivalent to non-congruence because n < M.'),
  T('same_cycle', C, 'MATCH', 'B3; change 1', 'Exists i : Fin q with 2^i N+ mod M = N-, i.e. N- in O.'),
  T('word_strict', C, 'MATCH', 'B4 (sorted enumeration); §5', 'StrictMono W on Fin q; supporting B4 (rank(W(u)) = u needs it).'),
  T('orbit_set_eq', C, 'MATCH', 'B4 "O = {W(u) : u < q}"', 'orbitSet (q iterates of N+) equals the image of W over Fin q.'),
  T('orbit_card', C, 'MATCH', 'B4 "O has exactly q elements"; change 4', 'card O = q: distinct-point set has q points before rank is used.'),
  T('orbit_length', C, 'MATCH', 'B4/B5; change 4 (q directed edges)', 'Sorted list length = q, so the Fin-indexed edges number q.'),
  T('rank_word', C, 'MATCH', 'B4 "rank(W(u)) = u"; change 4', 'rank counts distinct orbit points strictly below.'),
  T('double_word', C, 'MATCH', 'B4 "doubling sends W(u) to W((u+p) mod q)"', 'Exact equality, (2 W(u)) mod M = W((u+p) mod q).'),
  T('rank_step', C, 'MATCH', 'B4 rank shift mod q including the return edge; change 4', 'For every x in O: rank((2x) mod M) = (rank x + p) mod q. Equality with the canonical residue is equivalent to the congruence since rank < q on O; universal over O, so the return edge is included.'),
  T('unique_unit_gap', C, 'MATCH', 'B5; change 4', 'Some edge i has start N-, end N+, gap 1, and every other edge j != i (wrap edge included, gap = (M + first) - last) has gap >= 2. Nat truncation in directedGap could only shrink a gap, so it cannot make the >= 2 clause easier. Negative control wrap_no_modulus fails this target.'),
  T('angle_order', C, 'MATCH', 'C1; change 5; owner C1 route', 'For all addresses d, e with p/q < p\'/q\': theta+(d) < theta-(e). Fully general: with address_surjective this covers all reduced fractions in (0,1); no denominator or neighbour narrowing.'),
  T('intervals_disjoint', C, 'MATCH', 'C1 "intervals are disjoint and ordered like the fractions"', 'Disjointness of the rational Icc combinatorial angle intervals; order is angle_order.'),
  T('mediant_interval', C, 'MATCH', 'C2; change 5', 'Both endpoints are RotationAddresses (in Psi\'s domain); fareyAdj is FF-1\'s |det| = 1 on canonical num/den; conclusion asserts the FF-1 mediant is itself an address m and states both strict separations theta+(x) < theta-(m) and theta+(m) < theta-(y). The existential is unique by address_injective, so it names the mediant\'s own interval.'),
  T('farey_denominator_min', C, 'MATCH', 'C3; change 6', 'Over canonical rationals (Lean Q), x<y, fareyAdj x y, x<z<y: x.den + y.den <= z.den. Quantified over all of Q, not only (0,1). The C3 cell and owner item 6 say "canonical rationals" with no interval bound, so this is the literal order statement; under a reading where the table preamble (guarded domain) also governs C3, it would be a harmless generalization that implies the restricted form. Evidence includes negative rationals and integers.'),
  T('farey_denominator_eq_iff', C, 'MATCH', 'C3 equality case; change 6', 'Same binders; z.den = x.den + y.den iff z = FF-1 mediant x y. Same all-of-Q remark as farey_denominator_min. Uses no FF-3 private API (only FF-1 public defs; helpers are private to this module). Negative control c3_midpoint fails this target.'),
  T('parameter_fixed_point', P, 'MATCH', 'A1a; change 7', 'For all lambda : C: alpha^2 + root(lambda) = alpha, with root = lambda/2 - lambda^2/4, alpha = lambda/2.'),
  T('parameter_multiplier', P, 'MATCH', 'A1b (explicit multiplier 2*alpha = lambda); acceptance v0.2', 'quadraticMultiplier is the explicit formula 2z; alone this is a bare equation, but it is paired with parameter_derivative, so no derivative claim rests on it.'),
  T('parameter_derivative', P, 'MATCH', 'A1b; acceptance v0.2 ("a derivative theorem")', 'HasDerivAt f f\' x in Mathlib is (function, derivative value, point). Here f = z |-> z^2 + root(lambda), f\' = lambda, x = alpha(lambda): the derivative at alpha equals lambda, as ordered. Negative control swap_hasderiv (reading f\'=alpha at x=lambda) fails.'),
  T('canonical_multiplier_primitive', P, 'MATCH', 'A1c; acceptance v0.2 scope clarification', 'IsPrimitiveRoot (exp(2 pi i (p/q : Q -> R -> C))) q, i.e. primitive root of order exactly q, with the record\'s guards bound. "Parabolic" appears nowhere in the sources.'),
];
const Dd = (name, verdict, note) => ({ name, module: D, verdict, scope_note: note });
const defs = [
  Dd('RotationAddress', 'MATCH', 'p, q : Nat with 0 < p, p < q, Nat.Coprime p q as record fields; Psi undefined at 0 and 1.'),
  Dd('address', 'MATCH', 'p/q as an exact rational.'),
  Dd('modulus', 'MATCH', 'M = 2^q - 1 in Nat; truncation inert since q >= 2 (q_at_least_two).'),
  Dd('upperIndex', 'MATCH', 'Fin q index p.'),
  Dd('lowerIndex', 'MATCH', 'Fin q index p - 1; p >= 1 from the record, so no underflow.'),
  Dd('rawDigit', 'MATCH', '[q - p <= (u + i p) mod q]; total helper, standing only under the guards.'),
  Dd('blockValue', 'MATCH', 'Sum over i < n of digit * 2^(n-1-i); n-1-i never truncates for i < n >= 1.'),
  Dd('digit', 'MATCH', 'rawDigit on Fin q intercept and index.'),
  Dd('wordValue', 'MATCH', 'W(u) = blockValue at length q.'),
  Dd('upperDigit', 'MATCH', 'digit of W(p).'),
  Dd('lowerDigit', 'MATCH', 'digit of W(p-1).'),
  Dd('upperNumerator', 'MATCH', 'N+ = W(p).'),
  Dd('lowerNumerator', 'MATCH', 'N- = W(p-1).'),
  Dd('upperAngle', 'MATCH', 'theta+ = N+/M in Q.'),
  Dd('lowerAngle', 'MATCH', 'theta- = N-/M in Q.'),
  Dd('psi', 'MATCH', 'Psi(d) = (theta-, theta+). Note: no public target mentions psi by name; all statements use lowerAngle/upperAngle, which are its components by definition. Cosmetic, not a defect.'),
  Dd('angleInterval', 'MATCH', 'Set.Icc theta- theta+ in Q: the combinatorial angle interval (rational representatives), not the complex wake.'),
  Dd('doubleNum', 'MATCH', 'k |-> 2k mod M.'),
  Dd('iterateNum', 'MATCH', 'k |-> 2^i k mod M.'),
  Dd('orbitPoint', 'MATCH', '2^i N+ mod M.'),
  Dd('orbitSet', 'MATCH', 'Finset image of range q: the distinct-point set O = {2^i N+ mod M : i < q}.'),
  Dd('rank', 'MATCH', '#{y in O : y < n}.'),
  Dd('orderedOrbit', 'MATCH', 'O sorted ascending (Finset.sort, so strictly increasing).'),
  Dd('edgeStart', 'MATCH', 'x_i via bounded get.'),
  Dd('edgeEnd', 'MATCH', 'x_{i+1}, or x_0 at the final index (the wrap edge).'),
  Dd('directedGap', 'MATCH', 'x_{i+1} - x_i for non-final i; (M + x_0) - x_{q-1} at the wrap. Nat subtraction: non-wrap terms are positive on a strictly sorted list, wrap term positive since x_{q-1} < M; truncation could only make B5 harder, never vacuous.'),
  Dd('cardioidParameter', 'MATCH', 'root(lambda) = lambda/2 - lambda^2/4 (renamed, formula unchanged).'),
  Dd('alpha', 'MATCH', 'lambda/2.'),
  Dd('quadratic', 'MATCH', 'z^2 + c.'),
  Dd('quadraticMultiplier', 'MATCH', 'explicit 2z; the derivative standing comes from parameter_derivative.'),
  Dd('canonicalMultiplier', 'MATCH', 'exp(2 pi (p/q) i) via Q -> R -> C coercion; lambda_{p/q} of §3.'),
];
const count = rows => rows.reduce((a, r) => (a[r.verdict] = (a[r.verdict] || 0) + 1, a), {});
const ev = JSON.parse(fs.readFileSync(path.join(__dirname, 'check_none.json'), 'utf8'));
const negs = ['reversed_weight', 'lower_index_plus', 'wrap_no_modulus', 'c3_midpoint', 'swap_hasderiv'].map(m => {
  const r = JSON.parse(fs.readFileSync(path.join(__dirname, `check_${m}.json`), 'utf8'));
  return { mutation: m, failed_checks: r.failed_checks, failed_targets: r.failed_targets };
});
const hc = JSON.parse(fs.readFileSync(path.join(__dirname, 'header_compare_output.json'), 'utf8'));
const hn = JSON.parse(fs.readFileSync(path.join(__dirname, 'header_compare_negative_control.json'), 'utf8'));
const out = {
  review: 'FF-4 Ford-to-bulb statement-fidelity review v0.1',
  date: '2026-11-04',
  reviewer: 'independent fidelity reviewer subagent, Claude Opus, spawned by skeleton 2026-11-05',
  reviewer_model: 'claude-opus-5-5',
  date_note: 'Local machine date at review time was 2026-11-04; the reviewer identity string is as specified by the spawning seat.',
  scope: 'Meaning only: each of the 33 frozen public statements read with the 31 frozen data declarations and the inherited FF-1 definitions, against WORK_ORDER_v0_2. Compilation, axioms and replay are the auditor\'s job and are not assessed here. No Lean run, no network, no posting.',
  reviewed_files_sha256: Object.fromEntries(reviewed.map(f => [f, sha(f)])),
  source_state: {
    data_module_byte_identical_to_frozen_definitions: sha('final_source_packet_v0_1/sources/FVLTFordBulbDataV1.lean') === sha('freeze_packet_v0_1/FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt'),
    public_headers_matching_frozen_whitespace_normalized: `${hc.match}/33`,
    extra_public_declarations: hc.extra_public,
    public_targets_by_module: { [C]: hc.combinatorics_public, [P]: hc.parameter_public },
    private_helpers: { [C]: hc.private_helpers_combinatorics, [P]: hc.private_helpers_parameter },
    proof_module_extra_imports: { [C]: ['Mathlib.Data.Nat.ModEq'], [P]: ['Mathlib.Analysis.Calculus.Deriv.Add'] },
    sorry_admit_axiom_native_decide_tokens: 'none found by text search (not a substitute for the axiom report)',
    out_of_scope_terms: 'no occurrence of Goldberg, landing, ray, wake, limb, Rule 30, attracting, parabolic, B6 or Mandelbrot in the three sources',
  },
  targets,
  definitions: defs,
  verdict_counts: { targets: count(targets), definitions: count(defs) },
  scope_confirmations: {
    B6_absent: true,
    no_ray_landing_wake_limb_analytic_dynamics_or_Rule30_claim: true,
    C1_general_over_all_reduced_fractions_in_0_1: true,
    C2_both_endpoints_in_domain_and_both_strict_separations: true,
    C3_over_canonical_rationals_with_equality_case: true,
    C3_quantified_over_all_of_Q: 'yes; faithful to the C3 cell wording; at worst a harmless generalization',
  },
  finite_evidence: {
    label: 'finite evidence, not proof',
    script: 'FIDELITY_REVIEW_v0_1/fidelity_check.cjs (BigInt, exact rationals, Lean Nat truncated subtraction mirrored)',
    range: `${ev.addresses} addresses (all coprime 0<p<q<=${ev.QMAX}); C1/C2 on all ordered pairs with q<=${ev.QPAIR}; C3 on all ${ev.c3_rationals} rationals in [-2,2] with den<=${ev.C3DEN} (${ev.c3_adjacent_pairs} adjacent pairs, ${ev.c3_equality_hits} equality hits); A1 exact divisibility criterion plus float sanity checks`,
    baseline: { total_checks: ev.total_checks, failed_checks: ev.failed_checks, targets_checked: ev.targets_checked },
    harness_correction: 'First baseline run failed 22 mediant_interval checks because the script looked the mediant address up only among q<=16 while mediants of q<=12 pairs reach den 23; the lookup was replaced by constructing the address from the canonical mediant. This was a script defect, not a statement failure; recorded here rather than hidden.',
    negative_controls: negs,
    header_compare: { baseline_match: `${hc.match}/33`, negative_control_mutating_rank_step_detected: hn.mismatch.map(x => x.k) },
  },
  own_output_sha256_before_signoff: Object.fromEntries(own.map(f => [f, sha(f)])),
  overall_result: 'PASS: 33/33 targets MATCH, 31/31 definitions MATCH; no TRANSLATION_DEFECT, no UNRESOLVED. Advisory notes only (C3 over all of Q; psi unused by name; Nat subtraction in directedGap inert).',
};
fs.writeFileSync(path.join(__dirname, 'FIDELITY_SIGNOFF_v0_1.json'), JSON.stringify(out, null, 2) + '\n');
console.log(JSON.stringify(out.verdict_counts), out.source_state.data_module_byte_identical_to_frozen_definitions);
