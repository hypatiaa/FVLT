// Builds FIDELITY_SIGNOFF_v0_1.json from the reviewer's verdict table, hashing every reviewed file
// and the reviewer's own scripts/outputs. Usage: node build_signoff.cjs
'use strict';
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const ROOT = path.resolve(__dirname, '..');
const sha = (p) => crypto.createHash('sha256').update(fs.readFileSync(path.join(ROOT, p))).digest('hex');

const reviewed = [
  'WORK_ORDER_v0_2.md',
  'freeze_packet_v0_1/FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt',
  'definition_repair_v0_1/FF3_DEFINITIONS_PROPOSED_v0_2.lean.txt',
  'definition_repair_v0_1/REPAIR_DECISION_v0_1.md',
  'freeze_packet_v0_1/FF3_HEADERS_PROPOSED_v0_1.lean.txt',
  'FF3_FREEZE_DECISION_v0_1.md',
  'freeze_packet_v0_1/inputs/library_sources/FVLTFareyContactV1.lean',
  'freeze_packet_v0_1/inputs/library_sources/FVLTFareyCertificatesV1.lean',
  'freeze_packet_v0_1/inputs/library_sources/FVLTFareyArithmeticCompletionV1.lean',
  'freeze_packet_v0_1/inputs/library_sources/FVLTFordRationalV1.lean',
  'freeze_packet_v0_1/inputs/library_sources/FVLTFordGeometryV1.lean',
  'freeze_packet_v0_1/inputs/library_sources/FVLTFordExactCoordinatesV1.lean',
  'freeze_packet_v0_1/inputs/UNAUDITED_REFERENCE_LEMMA_6a.md',
  'final_source_packet_v0_1/sources/FVLTRosetteFordDataV1.lean',
  'final_source_packet_v0_1/sources/FVLTRosetteFordPhaseV1.lean',
  'final_source_packet_v0_1/sources/FVLTRosetteFordArithmeticV1.lean',
  'final_source_packet_v0_1/sources/FVLTRosetteFordSweepV1.lean',
  'final_source_packet_v0_1/sources/FVLTRosetteFordEndpointsV1.lean',
];
const own = [
  'FIDELITY_REVIEW_v0_1/statement_compare.cjs',
  'FIDELITY_REVIEW_v0_1/statement_compare_output.json',
  'FIDELITY_REVIEW_v0_1/semantic_check.cjs',
  'FIDELITY_REVIEW_v0_1/semantic_check_output.json',
  'FIDELITY_REVIEW_v0_1/semantic_check_negative_output.json',
  'FIDELITY_REVIEW_v0_1/build_signoff.cjs',
];

const P = 'FVLTRosetteFordPhaseV1', A = 'FVLTRosetteFordArithmeticV1', S = 'FVLTRosetteFordSweepV1', E = 'FVLTRosetteFordEndpointsV1';
const M = 'MATCH';
const targets = [
  [P, 'phasor_real_iff', M, 'Im(r*e^{i*pi*a}) = 0 iff a in Z, with r != 0 explicit; hn3 present but not needed for truth (order domain has 0 < n3).', '§3 phase law (general, nonzero amplitude)'],
  [P, 'integer_spin_phase_iff', M, 's : Z cast to Q; a in Z iff x in Z. The further link x in Z iff n3 | t2*s is integer_address_integral_iff.', '§3 integer-spin specialization'],
  [P, 'integer_spin_parity', M, '(-1 : C)^(t1*s) is zpow with integer exponent; negative exponents give the same sign. Stated only under s : Z, as the order requires.', '§3 integer-spin specialization, e^{i*pi*a} = (-1)^{t1 s} e^{-i*pi*x}'],
  [P, 'circleMap_amplitude_independent', M, 'True by definition (circleMap reads only fordAddress t2 s n3); this is the intended content: Phi is a function of (t2, s, n3), independent of r and of t1 (t1 left unconstrained).', '§3 the map Phi(t1,t2,s,n3) := C(x)'],
  [P, 'phasor_alias_not_address_alias', M, 'M3 example exactly: t1 = t2 = 1, n3 = 3, s = 0 and s = 3 give equal phasors (phase addresses 0 and 2) and Ford addresses 0 and 1. Does not claim any general non-descent theorem, only the example, as the order does.', '§3 M3 note; M3'],
  [A, 'integer_address_iff', M, 'den(t2*s/n3) = 1 iff (n3 : Z) | t2*s, for t2, s : Z, 0 < n3.', '§4 P1 first sentence'],
  [A, 'integer_address_integral_iff', M, 'Same as P1 with IsIntegral (exists k : Z, x = k).', '§4 P1; §3 a in Z <=> x in Z <=> n3 | t2 s'],
  [A, 'integer_address_radius', M, 'Integer address has F1 radius 1/(2*1^2) = 1/2 in R.', '§3 integer-address event, radius 1/2'],
  [A, 'divisor_recovery_window', M, 'Reference case t1 = t2 = 1, s : N with s > 0; window filter over Icc 1 M equals Nat.divisors s ∩ Icc 1 M.', '§4 P1 reference divisor recovery'],
  [A, 'zero_spin_address', M, 's = 0 gives address 0 with denominator 1 for every t2 and 0 < n3.', '§4 P1, the case s = 0 is separate'],
  [A, 'zero_spin_window', M, 'Every n3 in [1, M] is a contact at s = 0 (whereas Nat.divisors 0 = ∅, which is why s = 0 is kept separate).', '§4 P1, the case s = 0 is separate'],
  [A, 'reduced_det_mul', M, 'det is FF-1 det on reduced num/den of rawValue a q = a/q; multiplication form |det|*g(a,q)*g(c,r) = |a r - c q| for a, c : Z, 0 < q, r.', '§4 P2'],
  [A, 'reduced_det_quotient', M, 'Uses Lean Z `/` (Euclidean division). Safe: divisor g(a,q)*g(c,r) >= 1 and reduced_det_mul shows the division is exact, so it equals the rational quotient. Stated as a corollary after the multiplication form, as the order requires.', '§4 conventions (multiplication form first, quotient corollary); P2'],
  [A, 'row_law', M, 's : N, 0 < N, s < N (order: 0 <= s < N); right side N.', '§4 P3'],
  [A, 'row_tangent_iff', M, 'fareyAdj iff N = g(s,N)*g(s+1,N) in N.', '§4 P3 "tangent iff"'],
  [A, 'signed_column_law', M, 'Right side |u| for every u : Z (M2 fix). Quantifying over all u : Z is the same set as u = t2*s.', '§4 P4; M2'],
  [A, 'signed_column_tangent_iff', M, 'fareyAdj iff |u| = g(u,n)*g(u,n+1).', '§4 P4 "tangent iff"'],
  [A, 'zero_column_stall', M, 'u = 0: equal addresses, det 0, not fareyAdj.', '§4 P4 stall at u = 0'],
  [A, 'reference_column_tangent_iff', M, 'Reference case t2 = 1, s > 0 (s : N): fareyAdj(s/n, s/(n+1)) iff s | n(n+1).', '§4 P4 reference criterion'],
  [A, 'unit_fraction_spine', M, 'rawValue 1 n = unitFrac n (definitional) and 1/n, 1/(n+1) adjacent for n >= 1.', '§4 P4 s = 1 column, II.5b/II.5f'],
  [S, 'shell_contact_parameterization', M, 't1 = t2 = 1, N >= 2, rational s in [0, N]: phase address integral iff s = mN/(N-1), m <= N-1 (N-1 is safe Nat subtraction since N >= 2). Guards s >= 0 and s <= N are needed (negative control NC6).', '§4 P5 (i)'],
  [S, 'shell_phasor_contact_iff', M, 'Same with the phasor itself and r != 0 (guard needed: negative control NC5).', '§4 P5 (i), nonzero amplitude'],
  [S, 'shell_contact_address', M, 'Ford address of the m-th event is m/(N-1).', '§4 P5 (i) x = s/N = m/(N-1)'],
  [S, 'mem_shellEvents', M, 'Ties the parameterized Finset shellEvents to the order\'s event condition (2 <= N <= B+1, 0 <= s <= N, phase address integral). Guard 1 <= B is not needed for truth (B = 0 gives empty on both sides); it matches the order\'s shell base with at least one shell.', '§4 P5 (i)-(ii), "shells N = 2..B+1"'],
  [S, 'mem_fareySet', M, 'fareySet B = {x : 0 <= x <= 1, den x <= B} = standard F_B. Guard 1 <= B unnecessary but harmless (B = 0 empty on both sides).', '§4 P5 (ii) F_B'],
  [S, 'shell_addresses_eq_farey', M, 'Finset equality, so deduplicated; the raw 860-event count at B = 40 is not claimed to be Farey (reviewer script: 860 events, 491 addresses = |F_40|).', '§4 P5 (ii)'],
  [S, 'fareyList_membership', M, 'fareyList B = sort of fareySet B has the same members.', '§4 P5 (iii) "sorted"'],
  [S, 'fareyList_strict', M, 'List.Pairwise (<): strictly increasing.', '§4 P5 (iii) "sorted strictly increasingly"'],
  [S, 'farey_consecutive_det', M, 'For consecutive x = a/b < y = c/d (reduced num/den): b*c - a*d = 1, the signed form (stronger than |det| = 1). hk0 is implied by hk1; harmless.', '§4 P5 (iii)'],
  [E, 'det_zero_iff_address_equal', M, 'det x y = 0 iff x = y (reduced num/den); grounds "stall = determinant 0".', '§4 P4 stall; §4 P6 stall'],
  [E, 'classify_stall_iff', M, 'stall iff equal addresses.', '§4 P6 stall'],
  [E, 'classify_tangent_iff', M, 'tangent iff fareyAdj (classifyEdge tests |det| = 1 after excluding equality; fareyAdj x x is false).', '§4 P6 tangent'],
  [E, 'classify_break_iff', M, 'EdgeKind.gap is the order\'s "break"; IsBreak carries the label |det| >= 2, so this theorem proves every non-tangent, non-stall edge has |det| >= 2.', '§4 P6 break labelled with abs(det) >= 2'],
  [E, 'path_edge_trichotomy', M, 'Edges indexed by k : Fin m joining circles castSucc k and succ k of x : Fin (m+1) -> Q; exactly one of tangent / stall / break (one disjunction plus three pairwise exclusions).', '§4 P6 "exactly one"; §5 edges and circles indexed separately'],
  [E, 'path_kind_tangent_iff', M, 'Per-edge tangent classification on paths; only the per-edge condition is used, no mutual adjacency of three circles.', '§4 P6; §5'],
  [E, 'tangent_endpoint_certificate', M, 'On a tangent edge the certificate is some (kissQ u v) in RatPlane = Q x Q and boundaryCheckQ holds on both circles (via inherited adjacent_kissQ).', '§4 P6 tangent certificate; §5 endpoint lift'],
  [E, 'nontangent_no_certificate', M, 'No certificate on stall or break edges.', '§4 P6 (certificate only on tangent edges); §5'],
];

const definitions = [
  ['LiftedData', M, 'Record (t1 t2 : Z, s : Q, n3 : N, 0 < n3, r : R, r != 0) as in §3. Fields hn3, hr are used only through circleMap_amplitude_independent; other targets take unbundled arguments with explicit guards.'],
  ['fordAddress', M, 'x = t2*s/n3 in Q (§3).'],
  ['phaseAddress', M, 'a = t1*s - t2*s/n3 in Q (§3).'],
  ['IsIntegral', M, 'exists k : Z, x = k. Shadows Mathlib root IsIntegral only by name: inside namespace FVLT.PhasorFordV1 the local name is meant, and Mathlib\'s IsIntegral takes a ring type as its first explicit argument, so IsIntegral (q : Q) could not elaborate to it. Even IsIntegral Z (x : Q) would be equivalent (Z is integrally closed). No meaning change. Advisory only: a downstream file that opens this namespace may see an ambiguity.'],
  ['phasorValue', M, 'z1 = (r : C) * exp((pi * a : R) * I), §3 z1 = r e^{i pi a}.'],
  ['liftedPhasor', M, 'phasorValue on a LiftedData record. Not used by any target statement (no inverse/recovery claim made with it).'],
  ['circleMap', M, 'FF-1 boundary(fordAddress) = {z : |z - centre x| = radius x}, centre x + i/(2q^2), radius 1/(2q^2), q = reduced den; §3 Phi = C(x). Depends only on (t2, s, n3).'],
  ['gcdFactor', M, 'g(a,q) = Nat.gcd a.natAbs q (§4 conventions).'],
  ['integerContactWindow', M, '{N in [1, M] : den(s/N) = 1}, reference t2 = 1 (§4 P1).'],
  ['divisorWindow', M, 'Nat.divisors s ∩ [1, M] (§4 P1 Div(s) ∩ [1, M]).'],
  ['fareySet', M, 'm/q, 1 <= q <= B, 0 <= m <= q, gcd(m,q) = 1; = F_B (characterized by mem_fareySet). v0.2 binder (m : N) is the meant type.'],
  ['shellEvents', M, '(N, mN/(N-1)), 2 <= N <= B+1, 0 <= m < N; pairs keep events of different shells distinct (860 at B = 40, as in the order\'s raw count). v0.2 binder (m : N).'],
  ['shellEventAddresses', M, 'Image of (N, s) -> s/N, deduplicated Finset (§4 P5 (ii)).'],
  ['fareyList', M, 'Finset.sort (<=) of fareySet (§4 P5 (iii)).'],
  ['EdgeKind', M, 'tangent / stall / gap; "gap" names the order\'s "break" (tied by classify_break_iff to IsBreak). Naming difference only.'],
  ['IsBreak', M, 'x != y and not fareyAdj and 2 <= |det|. The third conjunct is implied by the first two; including it makes the order\'s label part of the predicate, and classify_break_iff proves it holds for every gap edge.'],
  ['classifyEdge', M, 'stall if x = y, else tangent if |det| = 1, else gap (§4 P6).'],
  ['pathEdgeKind', M, 'Edge k : Fin m joins x (castSucc k) and x (succ k), x : Fin (m+1) -> Q (§5 indexing).'],
  ['endpointCertificate', M, 'some (kissQ u v) iff |det u v| = 1 (= fareyAdj, definitionally), else none; exact rational RatPlane. No arc data (§5).'],
];

const sc = JSON.parse(fs.readFileSync(path.join(__dirname, 'statement_compare_output.json'), 'utf8'));
const pos = JSON.parse(fs.readFileSync(path.join(__dirname, 'semantic_check_output.json'), 'utf8'));
const neg = JSON.parse(fs.readFileSync(path.join(__dirname, 'semantic_check_negative_output.json'), 'utf8'));

const counts = {};
for (const t of targets) counts[t[2]] = (counts[t[2]] || 0) + 1;
const dcounts = {};
for (const d of definitions) dcounts[d[1]] = (dcounts[d[1]] || 0) + 1;

const out = {
  review: 'FF-3 statement-fidelity review v0.1 (lifted rosette-address to Ford-circle map)',
  reviewer: 'independent fidelity reviewer subagent, Claude Opus, spawned by skeleton 2026-11-04',
  model: 'Claude Opus 5.5 (claude-opus-5-5)',
  date: '2026-11-04',
  scope: 'Meaning only: each of the 37 frozen statements read with the definitions it uses (FF-3 data v0.2 and inherited FF-1), against WORK_ORDER_v0_2.md. No Lean was run; compilation, axioms and replay are the auditor\'s separate step. No network; no file outside FIDELITY_REVIEW_v0_1 written.',
  files_reviewed_sha256: Object.fromEntries(reviewed.map((p) => [p, sha(p)])),
  reviewer_artifacts_sha256: Object.fromEntries(own.map((p) => [p, sha(p)])),
  mechanical_findings: {
    headers_found: sc.headers_found,
    delivered_public_theorems: sc.delivered_public_theorems,
    delivered_statements_identical_to_frozen_headers: sc.statements_identical,
    extra_public_theorems_not_in_headers: sc.extra_public_theorems_not_in_headers,
    data_module_bytes_equal_definitions_v0_2: sc.data_module_bytes_equal_v0_2,
    data_definition_count: sc.data_definition_count,
    private_helpers: sc.private_helpers.map((p) => `${p.mod}.${p.name}`),
    private_helpers_note: 'All eight are `private theorem` (not exported); each is an auxiliary arithmetic/order fact (normalization of a/q, gcd nonzero, product-one cancellation, numerator bounds, bounded Bezout, mediant denominator bound, bounded successor in F_B). None introduces a public claim, an axiom, or Lemma 6a content.',
    imports: sc.imports,
    lemma_6a: 'Not imported, not named, no axiom/sorry/opaque/native_decide token in any delivered source; P5 (iii) is proved from bounded Bezout plus the interval denominator bound inside the Sweep module. Lemma 6a is a markdown candidate, not a Lean module.',
    arcs_and_inversion: 'No statement constructs arcs, parameterizes arcs, or recovers an address from a phasor value; the only phasor-to-address statement is the M3 non-descent example.',
  },
  computational_evidence: {
    label: 'finite evidence, not proof',
    positive: { statement_groups: pos.statement_groups, total_checks: pos.total_checks, total_failures: pos.total_failures, B40_sizes: pos.results._sizes },
    negative_controls: { groups: neg.statement_groups, total_checks: neg.total_checks, total_failures: neg.total_failures, per_control: Object.fromEntries(Object.entries(neg.results).map(([k, v]) => [k, v.failures])) },
    note: 'Phase statements ([float] rows) reduce the rational address mod 2 exactly and then use floating-point sin/cos with tolerance 1e-12 (1e-9 for the parity identity); all other rows are exact BigInt rationals with Lean semantics.',
  },
  targets: targets.map(([module, name, verdict, scope_note, work_order_locator]) => ({ name, module, verdict, scope_note, work_order_locator })),
  definitions: definitions.map(([name, verdict, note]) => ({ name, module: 'FVLTRosetteFordDataV1', verdict, note })),
  verdict_counts: { targets: counts, definitions: dcounts },
  advisories: [
    'IsIntegral shadows Mathlib\'s root IsIntegral by name only; no meaning change (see definition row). A rename would be a definition change under the freeze rules; not requested.',
    'Unneeded but harmless guards: hn3 in phasor_real_iff / integer_spin_parity / phasor_alias (order domain has 0 < n3); 1 <= B in the Sweep membership statements (B = 0 is the empty case); hk0 in farey_consecutive_det (implied by hk1). None makes a statement vacuous: every guard set is satisfiable and matches the order\'s domain.',
    'EdgeKind.gap is the order\'s "break"; a prose note in any later write-up should say so.',
    'liftedPhasor is defined but not used by any target; it carries no claim.',
  ],
  overall_result: 'PASS: all 37 targets MATCH and all 19 definitions MATCH WORK_ORDER_v0_2 §3-§6 (with M1-M4). Meaning review only; final FF-3 PASS also needs the auditor\'s independent rebuild, named-axiom report and strict replay.',
};
fs.writeFileSync(path.join(__dirname, 'FIDELITY_SIGNOFF_v0_1.json'), JSON.stringify(out, null, 2) + '\n');
console.log(JSON.stringify(out.verdict_counts), out.mechanical_findings.delivered_statements_identical_to_frozen_headers);
