# T3 v0.1 cold audit — Fable seat, 2026-09-23

**Verdict: PROSMENON — PASS, no flags, no counter-witness.**
Candidate `BSD_TATE_T3_v0_1_20260907`, manifest `ea0d0bbe2939610e5d2405eba1ef9d548288f122f779566f2fe5ba1e596c10be` (27 entries). Engine `small-prime-tate.cjs` d42c27aa…a84, wrapper `t3.cjs` 3fd7c6e1…b386. Runtime: Node v24.13.0, Python 3.14.0, pinned PARI 2.17.4 wasm.

## 1. Integrity and reproduction

- `check-integrity.cjs`: exact 27-entry inventory, 19 source pins, T2 → T1 predecessor chain: PASS.
- `node verify.cjs` (scratch `bsd-t3-audit-J48elW`), exit 0, receipt status PASS, scope `T3_PLUS_T2_T1_AND_V03`:

| Suite | Groups |
| --- | ---: |
| T3 (incl. 190 explicit PASS fixtures) | 225 |
| Builder Python small-prime method | 190 |
| Frozen T2 / T2 Python | 127 / 99 |
| Frozen T1 / T1 Python | 66 / 31 |
| Inherited v0.3 (ten suites) | 182 |
| **Total** | **920** |

This matches the build report exactly. The post-run source/audit/host-plan/runtime invariance check passes.

## 2. Hand-reading of the engine (against Silverman ATAEC IV.9 / Cremona 3.2)

- **Singular point.** An F=Fx=Fy=0 search over p² points is correct in characteristics 2 and 3. The singular point of a reduced Weierstrass cubic is unique, hence Galois-fixed, hence F_p-rational, so `roots.length!==1` can never fire on a genuinely singular fibre.
- **Multiplicative.** The test is unit c4, with the tangent quadratic T² + a1T − a2 at the centred node; c_p = n / 1 / 2. The p=3 extension is correct.
- **II / III / IV.** The tests v(a6)<2, v(b8)<3, v(b6)<3 are correct, and the IV polynomial Y² + a3,1·Y − a6,2 is correct.
- **Step-6 normalization.** A search over s mod p and t/p mod p is exhaustive: shifting s by p changes a4 only by multiples of p², and shifting t by p² changes a6 only by multiples of p³. With r=0 this is the standard move. At p=2, 4 | a3 follows from the failed IV test.
- **Star cubic.** T³ + a2,1T² + a4,2T + a6,3 is the correct cubic. I0* has c = 1 + #roots.
- **I_n\* refinement.** Y-quadratic [−a6/p^(x+y), a3/p^y, 1]; X-quadratic [a6/p^(x+y), a4/p^(x+1), a2/p]; translations t = root·p^y and r = root·p^x; index n = x+y−3 from (2,2). All agree with Cremona's (ix,iy) loop. The leading coefficient a2,1 is a unit, and translations by r ∈ p²Z preserve it.
- **Triple-root branch.** The thresholds [1,2,2,3,4] and [1,2,3,3,5] are correct. IV\*, III\* (v(a4)<4) and II\* (v(a6)<6) are tested in the right order. The rescaling precondition [1,2,3,4,6] is correct, and the rescaled model re-enters at `BEGIN_TATE_PASS` with the discriminant and singular point recomputed.
- **Conductor.** Ogg f = v(Δ)+1−m is applied only after the terminal type is known, with the correct component counts. The caps f₂≤8 and f₃≤5 are enforced as checks only, as the contract states.
- **Builder minimality exhaust.** Representatives r mod p², s mod p, t mod p³ are complete. Composing with integral target-side translations shifts the tuple by (p²r′, ps′, p³t′ + p²sr′), so every u=p solution reduces to one of these representatives.

## 3. Independent seat

`scratchpad/t3seat/tate23.py` (sha256 38498426…7c21) is my own implementation, written from the algorithm statement.

- Separability uses gcd(f, f′) over F_p, and root multiplicities use synthetic division.
- The multiplicative test uses v(b2)=0 rather than c4.
- Every normalization is searched directly against its valuation conditions.
- Step 6 deliberately takes the **last** admissible (r,s,t), whereas the package takes the first. Agreement therefore also tests invariance under that choice.

**Results**
- **Fixtures.** All 190 builder fixtures agree with my seat on type, c_p, f and v(Δ_min), with 0 mismatches; the largest hidden rescaling count is 9.
- **Three-way fuzz** (`fuzz.cjs` f62697f8…, seeds 7/11/23/37/51). 2,060 new curves at p=2,3: small random coefficients, deep p-adic coefficients, hidden rescalings up to p^(3·weight), and random integral translations. Package vs my seat vs pinned PARI `elllocalred` plus `ellminimalmodel` gave **0 mismatches** on Kodaira type, c_p, conductor exponent, minimal v(Δ) and rescaling count. The curves cover 75 (p, type, c_p) classes, including I_n up to I12 and I_n\* up to I9\*.
- **p-integral rational input** to the internal `compute` (e.g. a4=1/5, a6=1/7 at p=2) agrees with the denominator-cleared integral model.

## 4. Adversarial probes through the public `assess.cjs` (`probe.cjs` 97f63694…)

Rejected: a p=3 nonsplit curve rewritten coherently as split (split, reduction, c_p, a_p and Euler polynomial all changed together); a deleted REMOVE_P_POWER event; the terminal model swapped for its u=−1 isomorph; the trace prime changed 2→3; prime 5; a `localMinimality` relabel; inventory completeness flipped; a self-consistent fabricated PARI version; a certificate with an altered verifier hash; and a certificate claiming `globalMinimality=PROVED`. Accepted as designed: the baseline III\* packet at 2 (`MATCHING_SOURCE_REPORT`), and packets with no comparison, including a fresh backend-free one (`ABSENT`).

**Observation (not a flag).** The PARI comparison is an unauthenticated source report. Disagreement blocks certification; agreement confers nothing, because the certificate is fully recomputed from the parent bytes. This is as stated in the contract.

## 5. Scope as audited

The certificate is ONE_PRIME_2_OR_3_ONLY. Global minimality, the Néron differential, curve-level products, heights and BSD remain NOT_ASSESSED, and the viewer is unchanged. The Sage comparison on Serena/Nucleus remains a separate line item that has not been run. This seat confers cold standing on T3 v0.1. It is not a lock ruling.

Next per plan: T4 (global reconciliation of the T2/T3 local certificates).
