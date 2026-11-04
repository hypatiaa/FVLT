# FF-4 freeze packet decision v0.1

2026-11-04. Skeleton (Claude Opus 5.5), on saphir's "Yes, review it" (reply to bus #1562). saphir's FF-4 go is in #1557. The accepted order is v0.2 `d28dfd0e…`, with owner acceptance `6e5c8b61…` (#1561). This is the technical review gate. It is not a new permission.

**Decision: ACCEPTED.** The input freeze on v23, the 31 data declarations, all 33 public statements with their module and target mapping, the runner, the strict checker and the job template are accepted. Both requested policies are decided below, for FF-4 itself.

## What was checked

| Item | SHA-256 | Result |
|---|---|---|
| `PACKET_MANIFEST_v0_1.json` | `115a6c7d…` | 43/43 entries re-hashed, all match |
| `FF4_DEFINITIONS_PROPOSED_v0_1.lean.txt` | `19fcd5d3…` | read in full; matches order v0.2 §3 |
| `FF4_HEADERS_PROPOSED_v0_1.lean.txt` | `c5b569b1…` | 33 theorems, read in full; match §4 |
| `TARGET_INDEX_v0_1.json` | `ac7cf6d2…` | three modules: Data, Parameter (4), Combinatorics (29) |
| Input freeze, template | `1b152ca6…`, `c2205216…` | v23 pins equal nucleus (see below) |
| `RUN_FF4_v0_1.py` | `56d69bfb…` | read as a full diff against the accepted FF-3 v22 runner `643fef34…` |
| `IndependentFVLTReplay435.lean` | `9c6f2ac1…` | the accepted checker, unchanged |

**v23 on nucleus.**
- Latest version = 23.
- Pins: `SHA256SUMS` `394e72c5…`, `LIBRARY_MANIFEST` `3b8ea550…`, `lake-manifest` `1f0e0c1c…`, `lakefile.toml` `23b30551…` and `lean-toolchain` `ca5f1f60…`, all equal to the template.
- 401 entries, 0 check failures, 0 writable.
- The inherited sources are byte-identical to the closure pins: `FVLTFareyArithmeticCompletionV1` `01abe886…` and `FVLTFareyContactV1` `2760392f…`.
- `mediant`, `adjacent_mediant`, `fareyAdj` and `det` live in `FVLT.FareyContactV1`, as the headers assume.
- No FF-4 execution root exists yet.

**Fidelity to order v0.2.** Each item of the order checked against the definitions and statements:
- **Words:**
  - W(u) is `rawDigit` + `blockValue`, with weight 2^{q−1−i} on a Fin q index;
  - N⁺ = W(p) and N⁻ = W(p−1);
  - the minus digit carries the explicit `1 ≤ (i+1)p` guard.
- **Address bridge:** canonical, injective and surjective onto (0, 1); Ψ is undefined at 0 and 1.
- **B0:** q ≥ 2, M > 0, and the word and characteristic bounds.
- **B1–B5:**
  - B1, adjacency, and B2, exact period, split into return and minimality;
  - B3, the common cycle, is separate;
  - B4, rank and doubling, holds on the q-element orbit set, with the rank step mod q;
  - B5 covers all directed gaps, including the wrap M + first − last, and names the ordered edge N⁻ → N⁺.
- **C1–C3:**
  - C1 is general;
  - the intervals are disjoint;
  - C2 is guarded, with both separations around the FF-1 mediant;
  - C3 holds over all of ℚ, with its equality case.
- **A1:** split into the fixed point, the explicit multiplier 2α = λ, a real `HasDerivAt`, and `IsPrimitiveRoot` for the canonical λ.
- **B6:** absent.
- **No analytic statements:** no ray, wake or limb statement.

## Scripted checks (finite evidence, not proofs)

**Combinatorial statements.** `SKELETON_FF4_SIGNATURE_CHECK_v0_1.cjs` mirrors the proposed definitions exactly in BigInt and exact rationals: `rawDigit`, `blockValue`, Fin indexing, `orbitSet`, `rank`, `orderedOrbit`, the wrap edge in `edgeEnd`, and `directedGap`. It covers:
- all 29 combinatorial statements for every coprime 0 < p < q ≤ 18;
- C1, the disjointness statement and C2 on all ordered pairs;
- C3 over all rationals in [−2, 2] with denominator ≤ 24, negatives included, since the statement is over all of ℚ.

**Result: 35,961 checks, 0 failures.** A negative control, a strict `<` in the digit rule, fails 5,109 checks across eleven statements, so the script can fail.

**Complex statements (A1), exact in Sage 10.9** (session `8fa71dc2…`):
- the fixed point, the multiplier and the derivative hold symbolically for every λ;
- `IsPrimitiveRoot` holds for every coprime p/q with q ≤ 40 in Q(ζ_q);
- the embedding of ζ_q^p equals exp(2πi p/q) to within 5.1×10⁻¹⁵, which confirms the canonical λ.

## Runner

The runner keeps every control of the FF-3 runner. It adds:
- **A frozen-source check:**
  - the data module must be byte-identical to the frozen definitions file;
  - every public theorem's header must equal the target index;
  - extra public declarations, attributes, duplicate or unknown names, and indentation wrappers are refused;
  - **UTF-8, LF and no BOM are required.** This makes FF-3's line-ending advisory a guard.
- **A present-target inventory,** recorded in the receipt and matched against the comparison.

## Policies decided for FF-4

1. **All-match binding, accepted on posting.** ACCEPTED.
   - A bound template that differs from `c2205216…` only in these fields is accepted when it is posted on the bus with all hashes, without another skeleton turn:
     - `status: BOUND_ACCEPTED`;
     - `signature_freeze_sha256`, naming manifest `115a6c7d…` or a reviewed successor;
     - the host reservation reference;
     - the fresh capacity file and its hash.
   - Every concrete job is posted before launch.
   - A library newer than v23 returns for review.
2. **Bounded proof-only retries.** ACCEPTED as requested.
   - A failed compile stops that item and everything that depends on it, and the attempt is kept.
   - Retries are fresh additive attempts, with unchanged data and public headers, a fresh comparison and a posted job.
   - These return for review:
     - any definition, header or scope change;
     - a wrong axiom set;
     - a genuine strict-replay failure.
   - A batch is 1800 s, counted from before proof writing. It is never reset or extended, and a new batch needs a fresh binding.

## Conditions and advisories

- **Condition.** The final PASS needs skeleton's own clean rebuild, the named-axiom report and strict replay of all introduced constants on nucleus, followed by a separate fidelity review. I read every raw axiom log.
- **Advisory: imports are frozen bytes here.** Unlike FF-3, where imports were job boilerplate, the runner requires the data module to equal the frozen definitions file byte for byte, imports included. Any import change at first elaboration, even one that looks harmless, is therefore a definition change and comes back for a quick review. This was the kind of repair FF-3 needed.
- **Advisory: the proof separator.** The runner extracts each header up to `' := by'`. Term-mode proofs (`:= term`) of public theorems would be refused; that is a harness constraint, not a mathematical one. No frozen header contains `' := by'`.
- **Scope unchanged.**
  - Not claimed: parameter-ray landing, the wake, limb geometry, analytic dynamics, B6, and any Rule 30 claim.
  - Not done: no viewer, kernel, commit, release or sync.

Credit: the observation and the instruments: saphir. The design review and the proof architecture: the formalization owner. "The framework was assembled by Robin Miller; its components are classical results of others."
