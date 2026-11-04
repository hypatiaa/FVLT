# FF-3 v0.2 design review

2026-11-03. **ACCEPT for the stated discrete first pass**, with the signature-freeze precisions below. No FF-3 proof drafting, computation, preregistration, build, viewer work or kernel change was performed. FF-1 Stage A retains execution priority. This is a design verdict, not a proof or execution-input freeze.

## Exact input and changes

Read the complete `phasor_ford_map_v0_1_20261103/WORK_ORDER_v0_2.md`, independently matched SHA256 `5b41c955e35478f7eeca169586384c0dffe63c45e1fa3a5488886bb03610c035`. The prior review `REVIEW_v0_1.md` and the cited Lemma 6a candidate retain their prior pins. The candidate is unaudited and is not assumed as a theorem. The manager's Sage observations are finite evidence; this review did not re-execute them.

All four mathematical corrections requested in the prior review are incorporated:

- **M1:** rational-spin shell contacts and integer-spin integer-address contacts have distinct domains. The general real-axis criterion uses the full phase address with nonzero amplitude. The Farey sweep deduplicates a finite address set before ordering it.
- **M2:** denominator guards and gcd conventions are explicit, multiplication identities precede quotient corollaries, the signed column law uses absolute value, zero is a stall, and the divisor-recovery claim separates the positive and zero cases.
- **M3:** the construction is a function of lifted rosette data. It does not assert inverse recovery of an unwrapped address from an unlabelled complex value or identification of Hasse/harmonic spaces.
- **M4:** P6 supplies per-edge exact rational endpoint certificates. It does not claim oriented arcs or continuity. Stalls and breaks have explicit roles and the flanks of the rosette are not assumed adjacent.

These resolve the substantive objections to v0.1. The accepted computable bridge now supplies `kissQ`, `boundaryCheckQ` and their links to the complex geometry, under the exact audited source pins. That prerequisite is available; it does not prove FF-3's new address and determinant laws.

## Required precision at the already mandatory signature freeze

1. **P5:** explicitly bind `B : ℕ` and `hB : 1 ≤ B`, matching the cited Lemma 6a setting. Bind `N ≥ 2`, the finite index `0 ≤ m ≤ N−1`, and rational spins in the closed interval. Define the finite Farey set and its strictly ordered enumeration before the neighbour theorem. Do not silently extend the statement to a zero-order convention.
2. **Integer versus rational parameters:** represent integer-spin specialization with an explicit integer spin or an explicit equality to an integer cast; use the integer exponent convention for the parity factor, including negative spins. Bind the positive reference spin separately from the signed column parameter. The general rational-spin law must not inherit an integer-parity assumption.
3. **P6:** use a nonempty finite circle sequence, for example `Fin (m+1) → ℚ`, with edges `k < m`; `m = 0` has one circle and no edges. The three edge classes must be mutually exclusive and exhaustive. Only tangent edges get kiss-point boundary certificates; a stall gets its own equality event and a break gets the determinant lower bound. No certificate for an unconstructed arc is inferred.
4. **Circle equality and address labels:** define the map through the exact rational address and the audited Ford definitions. If a record contains amplitude although the circle map ignores it, state that dependency explicitly. Keep the phase relation and the circle-address map as separate named results.

These specify intended domains and interfaces within v0.2's declared construction. They are obligations for the signature review, not permission to bypass it. Any altered proposition or newly requested continuous/dynamical conclusion returns for review. A broader P5 zero-case theorem, if wanted, is a separate explicitly stated extension.

## Feasibility and boundary

P1–P4 are exact rational reduction, gcd and determinant arithmetic; the new R1 canonicalization lemmas should be reusable after their independent audit. P5 is the larger obligation: contact parametrization, set equality and the classical Farey neighbour result must be proved, rather than inferred from the finite B=40 check. P6 should reuse the exact bridge for endpoint certificates but still needs a proof of edge classification, including determinant zero iff equal addresses. No completion-time promise is made.

No factoring advantage, Rule 30 forcing theorem, register identification, unlabelled-phasor inverse, canonical continuous arc correspondence or new kernel standing is established by this verdict. A future §9.4 candidate must say exactly what discrete map has been constructed and retain the continuous-dynamics limitation. Historical locked bytes remain untouched; adoption requires the separate fidelity/mathematical review process.

Robin's advance execution go is recorded in `CONDITIONAL_EXECUTION_GO_20261103.md`, SHA256 `1035988d640204a3fa4f6ce6c316aa2b07b0e365541e2c838e9bfba220048365`. That go need not be requested again for the same scope. Once FF-1 Stage A is delivered and the agreed sequence reaches FF-3, prepare its own current input freeze, explicit signatures, capped template and concrete manifests. This design acceptance does not authorize starting those proof/build calls now. Placement relative to FF-2 remains Robin's decision.
