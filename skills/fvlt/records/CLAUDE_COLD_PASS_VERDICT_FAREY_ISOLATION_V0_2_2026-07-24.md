# Claude cold-pass verdict — Farey Isolation v0.2

**Reviewer:** Claude (claude-opus-4-8), acting as an independent cold-pass reviewer
**Date:** 2026-07-24
**Review target:** Farey Isolation / Phase-Mode Contact-Connectivity candidate v0.2
(`KERNEL_CANDIDATE_farey_isolation_law_v0_2_REBASED_v3_2_5.md`)
**Handoff of record:** `CLAUDE_COLD_PASS_HANDOFF_FAREY_ISOLATION_V0_2_2026-07-24.md`
**Authority boundary:** review only. This verdict does not seat, number, ratify, lock,
splice, route, or authorize a registered run. Robin retains routing, seat, numbering,
and lock authority.

## Verdict

**PASS WITH NON-BLOCKING NOTES.**

The mathematics is correct and independently reproduced from definitions; the candidate is
consistent with the pinned v3.2.5 kernel and collides with no current kernel item; the
governed verifier was reviewed, executed from an isolated copy, and reproduced its pinned
expected output byte-for-byte. No kill condition (handoff §8) is triggered. The notes in
§5 below are write-up/robustness recommendations only and block nothing.

```yaml
candidate_sha256_match: true
kernel_sha256_match: true
manifest_all_match: true
verifier_reviewed: true
verifier_executed: true
verifier_exit_code: 0
expected_output_exact_match: true
independent_fixture_check: pass
registered_instance_evaluated: false
run_authorized: false
candidate_inputs_modified: false
kernel_inputs_modified: false
seat_status: candidate_unseated
lock_status: not_locked
```

## 1. Inputs and hashes (recomputed at intake)

Root: `C:\Users\robin\s6_atom\candidates`. Each governed file was copied read-only into an
isolated review workspace and hashed with a fresh SHA-256 pass. Device copies and the
chat-attached copies were both hashed and are byte-identical.

| Role | Relative path | Recomputed SHA-256 | Manifest / §2 | Match |
|---|---|---|---|---|
| candidate under review | `KERNEL_CANDIDATE_farey_isolation_law_v0_2_REBASED_v3_2_5.md` | `79aa00e9403f8493341753a0c26b877e95c4912b081686db0c49ced2be406104` | same | ✅ |
| deterministic verifier | `verify_farey_isolation_v0_2.py` | `ef7b9a61caeb8dc4ab6c793cdd57063b3eb40a3f67522c3347d2e4ecb3e4c2d6` | same | ✅ |
| pinned expected output | `verify_farey_isolation_v0_2_EXPECTED_OUTPUT.txt` | `a253a18d508a912e7d66d6e5492c3fac764e864d00804f1189b80344cf8a3bd9` | same | ✅ |
| comparison kernel | `fvlt\kernel_v3_2_5.md` | `ac53e75b73c42f185248464e3daf856a3dd3fd98b56dfff971341b80b10717ef` | same | ✅ |
| packet manifest | `MANIFEST_farey_isolation_v0_2_REBASED_v3_2_5.sha256` | `e2b8c9eb165b9c9d328553c84887c0dffd627f1f09445bca98bf01148240c775` | (does not self-pin) | n/a |

The manifest governs four files (candidate, verifier, expected output, kernel); all four
recomputed hashes match the manifest lines exactly. The manifest does not self-pin, as the
handoff states; its own recomputed hash is recorded above for provenance. The older
`KERNEL_CANDIDATE_farey_isolation_law.md`, `NOTE_farey_isolation_2026-07-07.md`, and
`verify_farey_isolation.py` were treated as provenance only and are not part of this review.

## 2. Mathematical cold pass (M1–M5)

Reviewed from definitions, then cross-checked with an independent reimplementation deliberately
structured differently from the governed verifier (`fractions.Fraction` values, brute-force
edge construction, and partner sets computed by exhaustive enumeration rather than by trusting
the modular formula). All counts below were produced by the independent code and agree with the
candidate and the verifier.

**M1 — phase-reduction lemma (unconditional; confirmed).** Both inclusions hold.
`red(e/n_i)` has denominator `n_i/gcd(e,n_i) | n_i`, hence `∈ D(a)`; conversely for reduced
`c/q` with `q | n_i`, `e = c·(n_i/q)` is interior (`1 ≤ e ≤ n_i−1`) and reduces to `c/q`.
Endpoints, repeated orders, and duplicate reductions are handled because `F(a)` is a set of
reduced values. Independent check: the two constructions of `F(a)` — reduce-every-`e/n_i`
vs. union-of-coprime-`c/q`-over-`D` — agree on all **714** profiles.

**M2 — contact graph and exact partner lemma (unconditional; confirmed).** For reduced
`a/q` and admissible `s`, contact `|as − cq| = 1` forces `ε = as − cq ∈ {−1,+1}`, hence
`c = (as − ε)/q`, giving the integrality, interior-range, and congruence conditions stated.
Coprimality is automatic: any common divisor of `c` and `s` divides `as − cq = ε = ±1`.
The enumeration is complete because contact admits no `ε` outside `{−1,+1}`. Independent
check: the modular partner set equals the brute-force neighbor-by-denominator set over all
**41,326** (vertex, denominator) queries, and the automatic-coprimality assertion held on
every produced partner.

**M3 — consequences (confirmed).** (1) Every edge is cross-denominator: for `s = q`,
`as ≡ 0 (mod q)` cannot be `≡ ±1`, so no intra-denominator edge exists — verified over all
profiles. (2) The isolation criterion is exactly the negation of partner existence
(immediate from M2). (3) For `1/n` the congruence becomes `s ≡ ±1 (mod n)` with the interior
condition retained; the independent modular predicate matches the graph isolation status of
`1/n` on every order occurrence. (4) The complement `a/q ↦ (q−a)/q` is a graph automorphism
(`|(q−a)s − (s−c)q| = |cq − as|`), verified on all **8,805** vertices. (5) Isolated vertices
therefore pair under complement; the only complement-fixed vertex found across all 714
profiles is exactly `1/2` (`2a = q ⇔ a/q = 1/2`), confirming the "1/2 is the only possible
fixed vertex" clause.

**M4 — exact fixtures (confirmed by independent reconstruction).**
- `(4,2,1)`: orders `(5,3,2)`, `D = {2,3,5}`, `|F| = 7`, `T = 6`, components `3`, isolated
  `{1/5, 4/5}`. ✅
- `(4,3,2,1)`: order `4` enters, both endpoint breaks close (`1/5~1/4` and `4/5~3/4` are
  each determinant-one contacts), graph connected, isolated set empty. ✅
- `(9,2)`: `D = {2,3,5,10}`, `(|F|,T) = (11,8)`, `(components, isolated) = (5,4)`, isolated
  `{1/10, 1/5, 4/5, 9/10}`. ✅
- `(8,3)`: `D = {2,3,4,9}`, `(|F|,T) = (11,8)`, `(components, isolated) = (3,2)`, isolated
  `{1/9, 8/9}`. ✅

On the word **"unconditional"** for the strict-refinement witness (§7): justified. The claim
is an existence statement — that `(|F|, T)` does not determine connectivity or isolation —
and it is established by an explicit pair of small graphs that are exactly reconstructible
from `D` and the determinant-one rule (reconstructed here without reference to the verifier).
It is not an extrapolation from the bounded census. See §5 note (a) for a non-blocking
self-containment suggestion.

**M5 — claims and firewalls (confirmed).** Proved statements (phase-reduction, partner,
isolation, cross-denominator, complement) are cleanly separated from the `[COMPUTED]` census
of §8, which is explicitly labeled bounded evidence over the declared range `1 ≤ m ≤ 4`,
`1 ≤ a_i ≤ 9` and is not extrapolated. The killed adjacent-order guess remains killed and is
retained only as a negative test (524 mismatches; reproduced independently). Determinant-one
contact is not conflated with the Vernier condition `n_3 | t_2 s` (Guard G-Vernier); the graph
is not conflated with Rmk II.5f or Lemma 9.2a (Guards G-II.5f, G-Stern–Brocot); no
divisor-lattice automorphism, higher crystal, conformal, or physical claim is inferred
(Guards G-register, G-geometry).

## 3. Kernel-consistency findings (against pinned `kernel_v3_2_5.md`)

1. **Rmk II.5b** supplies determinant-one Farey adjacency and classical Ford tangency —
   confirmed (mediant, `det = 1` adjacency, Ford tangency at ±1). ✅
2. **Rmk II.5d** supplies denominator-support/factorial-tower material and carries an explicit
   firewall (Guard **G-support**) that Farey adjacency is *not* identified with Hasse
   adjacency. The candidate does not cross this firewall. ✅
3. **Rmk II.5f** is occupied by the staircase Ford-chain graph on the exponent-value
   unit-fraction set `{1/a : a ∈ V}`. This is a different graph from the candidate's
   `G_ph(a)` (whose vertex set is `F(a)`, all reduced interior phases whose denominators
   divide a profile order). The candidate's §3 register table draws this distinction
   correctly; the shared `(4,2,1)`→`(4,3,2,1)` repair fixture does not identify the graphs. ✅
4. **Lemma 9.2a** governs finite order ideals (down-sets) of the Stern–Brocot tree. It does
   not automatically apply to an arbitrary gapped admissible set `D(a)`; the candidate's
   Guard **G-Stern–Brocot** states exactly this and does not silently import the lemma. ✅
5. **§9.7** uses phase/polygon orders `n_i = a_i + 1`; the candidate uses the same convention
   (Def §2). ✅
6. No current v3.2.5 definition supplies the candidate's phase-mode vertex set, contact graph,
   exact denominator-partner law, or isolation law. A full-text search of the kernel for
   `phase-mode`, `phase-contact`, `isolated phase bead`, `isolation law`, `farey isolation`,
   and `contact-connectivity` returns nothing. The construction is genuinely new. ✅
7. The candidate proposes routing (Part II / II.5, after Rmk II.5f) only as a suggestion and
   claims no label (`no II.5g or sublabel is claimed here`). ✅

No silent reuse, collision, or false implication from a current kernel statement was found.

## 4. Verifier findings and run transcript

**Source audit.** (1) Profile enumeration: `combinations_with_replacement(range(1,10), width)`
for widths 1..4, sorted descending — independently reproduced as exactly **714** nonincreasing
profile classes. (2) The two constructors of `F` (`fraction_set_from_orders` reducing `e/n`
vs. `fraction_set_from_denominators` taking coprime `c/q` over `D`) are genuinely distinct
implementations of the phase-reduction equivalence. (3) The graph is built directly from the
determinant-one predicate `abs(a*s − c*q) == 1`, and the modular criterion (`criterion_partners`)
is compared against the exact graph-neighbor set (`actual_partners_at_denominator`). (4) Every
counter and fixed total is asserted (V0–V7), not merely observed. (5) `fraction_key` is a
float `num/den` used **only** as a sort/traversal key in `graph`, `components`, and `isolated`;
set membership, edge counts, component counts, and isolated sets do not depend on it. Within
the bounded range (denominators ≤ 10, minimum spacing ≥ 1/90) floats separate all vertices,
so it controls display/traversal order only — the stated invariant holds. (6) Output is
ASCII-only; the module imports only `collections`, `itertools`, `math` (Windows-portable, no
`cp1252`-unencodable characters — the v0.2 portability repair). (7) Isolated-copy run below.
(8) The script exercises no registered FVLT instrument and creates no discovery record; it
imports no kernel or PennyLane material.

**Run.** Command: `python3 verify_farey_isolation_v0_2.py`
Runtime identity: CPython **3.11.15**, `/usr/bin/python3`, Anthropic cloud sandbox
(Linux x86_64) — an identified Python 3 runtime other than the local
`codex-primary-runtime` offered in the handoff; reported here per §5.
Isolated-copy verifier SHA-256 (pre-run): `ef7b9a61…406104` (matches pinned).
Exit code: **0**.

Complete emitted output:

```
[V0] phase reduction equals union of punctured Farey levels: 714/714 PASS
[V1] (4,2,1): |F|=7, T=6, components=3, isolated={1/5,4/5} PASS
[V2] (4,3,2,1): order 4 closes both endpoint breaks; connected PASS
[V3] modular criterion gives the exact partner set: 41326 queries PASS
[V3a] every contact edge joins distinct reduced denominators PASS
[V4] isolation census: 528/714 profiles have an isolated vertex PASS
[V4a] endpoint-pair criterion: 1980 order occurrences PASS
[V5] complement x->1-x preserves every graph: 8805 vertices PASS
[V6] strict refinement witness: profiles (9, 2) and (8, 3) both have (|F|,T)=(11, 8), but (components,isolated)=(5,4) vs (3,2) PASS
[V7] killed adjacent-order guess: 524/1980 mismatches retained PASS
RESULT: ALL PASS
BOUNDARY: computation verifies witnesses; it seats and locks nothing.
```

**Comparison result.** `diff` against `verify_farey_isolation_v0_2_EXPECTED_OUTPUT.txt` is
empty (identical line-for-line); the SHA-256 of the actual output equals the pinned
expected-output hash `a253a18d…a8a3bd9`. No source byte was changed to obtain PASS.

## 5. Corrections

No blocking corrections.

Non-blocking notes (write-up / robustness only):

(a) **§7 proof self-containment.** The §7 "Proof" cites the pinned verifier for the vertex,
edge, component, and isolated counts of the `(9,2)` / `(8,3)` witness. The claim does not
actually depend on the verifier — both graphs are small and exactly reconstructible from `D`
and the determinant-one rule (done here). For a fully self-contained proof, consider printing
the explicit edge (or component) sets of the two witness graphs alongside the isolated sets
that are already listed. This strengthens the write-up; it changes no result.

(b) **`fraction_key` intent comment.** The float sort key is safe in the bounded range but
its "display/traversal only" role is load-bearing for the reader's trust in V3–V6. A one-line
in-code note asserting that no mathematical decision reads `fraction_key` (only ordering does)
would make the guarantee explicit at the call sites. Cosmetic.

(c) **Runtime provenance.** This cold pass used CPython 3.11.15 on Linux, not the local
Windows `codex-primary-runtime`. Output matched the pinned expected file exactly, so the
result is runtime-independent within the tested pair; a confirming run on the local Windows
runtime would close the portability claim on the exact target platform. Optional.

## 6. Scope statement

This verdict is an evidence-backed mathematical and implementation review only. It determines
**no** routing, numbering, seating, or locking. Per the handoff and the candidate's own
front-matter: `registered_instance_evaluated: false`, `run_authorized: false`; the candidate
remains unseated and not locked. `candidates\pennylane` was not read, copied, entered, or
modified. No governed input, the kernel, its bibliography, or its skill was modified, and
nothing was deleted. The only files written by this review are this verdict and its SHA-256
sidecar, under `candidates\work`.
