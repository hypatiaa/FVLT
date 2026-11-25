# T4 v0.1 cold audit — Fable seat, 2026-09-23

**Verdict: PROSMENON — PASS, no flags, no counter-witness.**
Candidate `BSD_TATE_T4_v0_1_20260923`, manifest `269a052593babfef65a7fe4529f9db42dae48176bf985e7796b63022337d9f39` (26 entries, 26 external pins); engine `global-reduction.cjs` 0406bcaf…301a. T3 predecessor at `ea0d0bbe…10be` (my PASS report of this date). Node v24.13.0, Python 3.14.0, pinned PARI 2.17.4 wasm.

## 1. Reproduction

- `check-integrity.cjs`: PASS, recursive predecessor manifests match.
- `node verify.cjs` (scratch `bsd-t4-audit-kEdxIA`) exits 0 with receipt PASS and scope `T4_PLUS_T3_T2_T1_AND_V03`. Sources, audits, host plan and runtimes are unchanged.

| Suite | Groups |
| --- | ---: |
| T4 (42 explicit PASS fixtures, 2 UNAVAILABLE controls) / T4 Python | 76 / 44 |
| T3 / T3 Python | 225 / 190 |
| T2 / T2 Python | 127 / 99 |
| T1 / T1 Python | 66 / 31 |
| v0.3 chain | 182 |
| **Total** | **1,040** |

These are the same numbers as the build report.

## 2. Mathematics (handoff priorities 1–4)

**Integral lift.** Using the composition law (u₁,r₁,s₁,t₁)∘(u₂,r₂,s₂,t₂) = (u₁u₂, r₁+u₁²r₂, s₁+u₁s₂, t₁+u₁³t₂+s₁u₁²r₂), I solved w∘m = v by hand. The solution is m = (1, (R−r)/u², (S−s)/u, (T−t−s(R−r))/u³). This matches the contract's transition, including the cross term s(R−r) and its direction: inverse(w) followed by v. The congruences R≡r (u²), S≡s (u), T≡t+s(R−r) (u³) are exactly the conditions for m to be p-integral. The residues are taken p-adically, and denominators at other primes are inverted by extended Euclid.

**Other primes.** v has scale p^k, a unit at every q≠p, and integral R, S, T. So q-integrality and v_q(Δ) are unchanged, and each earlier stage's map to the final model is a q-integral unit isomorphism. The code does not rely on this argument alone. It asserts every step at run time:
- the lifted model is integral;
- the local-to-integral coefficients agree;
- Δ drops by exactly 12k;
- every stage-to-final map has v_p(u)=0 and p-integral r, s, t;
- the selected differential agrees along the composite route.

**Completeness gate.** The inventory is marked complete only when the trial-division cofactor is exactly 1. Otherwise the result is UNAVAILABLE, with `certificate:null` and products scoped `ONLY_LISTED_PRIMES`. On a complete inventory, bad primes are the support of the final discriminant; source exclusions that become good are listed as `recoveredGood`.

**Normalization.**
- c_min = c_sel / u_total keeps the sign; only the real-measure factors take |·|.
- The Néron differential is the differential of the global minimal model, up to sign.
- `realComponents` is 2 if Δ > 0 and 1 otherwise, and is never multiplied into the Tamagawa product.
- `periodValue` is `NOT_COMPUTED`, and the schema rejects an inserted value.

## 3. Independent seat (my own curves)

`scratchpad/t4seat/global.cjs` (32ab13cc…) generates general base curves (nonzero a1/a3 in about 60% of cases) and hides them behind random transformations:
- u = ±1/m, with m a random product of powers of 2, 3, 5, 7, 11, 13 (mixed-prime scalings; negative u in half the cases);
- rational r/s/t with denominators 5, 7 or 35;
- signed rational selected multipliers.

Each result is compared with:
- **PARI, run on the original base curve** (so independent of every transformation): `ellglobalred` N and c-product, `ellminimalmodel` discriminant, and equal c4 and c6. Between minimal models, equal c4 and c6 force u = ±1.
- **My own `minimal.py` (30fe3442…) on T4's final model:** minimality at p ≥ 5 via ¬(v(c4)≥4 ∧ v(c6)≥6) with f = 1/2 from c4; at p = 2, 3 via my T3-seat `tate23.py` (0 rescalings, f from Ogg). I multiply these into my own N.
- **Hand composition:** c_min = c_sel / signedPullbackToInput, and the real-component count.

**Result:** 600 curves (seeds 13/29/41/57/73). 496 were certified with 0 mismatches on any check. The other 104 were UNAVAILABLE. `unav.cjs` confirmed that each of these has a remaining cofactor with no prime factor ≤ 1009 (the smallest seen was 1129). Every refusal is genuine, and no curve was certified with unseen support.

Named checks:
- y² = x³ − 16x + 16 → [0,0,1,−1,0], N = 37, c = 1, matching the build report.
- 26b1 = [1,−1,1,−3,3], transformed by u = −1/30, r = 1/7, s = 2, t = −3/7 with selected multiplier −5, gives N = 26 and c-product 7 (split I₇ at 2). The signed selected multiplier is −1/6 = −5/30, and the stage scales are 2:2, 3:3, 5:5, 7:343, 13:1.

## 4. Public-gate probes (`probe.cjs` c6a12f3a…, `probe2.cjs` ae4c7a60…)

**Rejected:**
- a global certificate presented with a partial packet ("Unavailable result cannot carry a global certificate");
- a certificate transplanted from A to B;
- a falsely completed inventory;
- a global result grafted onto a partial packet;
- a local certificate borrowed from another curve;
- a t representative shifted by u³ (an equivalent lift, but not the canonical one);
- the signed pullback's sign flipped;
- the real-component count flipped;
- real components multiplied consistently into the c-product;
- a period value inserted;
- a stale record from another curve;
- a repaired parent hash;
- panel binding changes: intermediate model, context, marking, normalization ID, dropped panel;
- the selected-multiplier sign dropped.

**Accepted as designed:** both baselines together with their certificates, and the partial control, which comes back UNAVAILABLE.

**Probe note.** In probe.cjs the first "intermediate model" panel test on curve A passed. The test was void: for A the stage-2 target already is the final model, so nothing changed. I re-ran it on B with the bytes asserted to change, and it was rejected.

## 5. Observations for V1 (not flags)

- **O1.** The v0.3 structural/consistency gate accepts the bare T4 `record` on its own. As the contract states, the evidence is the packet run through the T4 replay. V1 must keep the packet and call the T4 gate; displaying the record's `CERTIFIED` text is not enough.
- **O2.** Completeness is deliberately conservative. A cofactor that is prime but larger than 1009, even at exponent 1, blocks the global result. About 17% of my random small curves hit this. This is expected under the declared domain, but V1 will show "unresolved" for many ordinary curves until a successor extends factorization and the local engines.

## 6. Viewer baseline intake (read-only check)

`mcomb-cayley-m3-camera2-lf1` (preview ebaaa765…). After stripping CRs, the preview and every file under `cayley/`, `seated/` and `baseline/` are identical to camera2 (`7ce6cf28…`, which I audited PASS on 2026-09-22). The real changes are build tooling only: the LF normalizer in `build-viewer.cjs`, the CRLF-invariance test, the version bump to 0.3.5 and `lf-record.cjs`. I did not rerun its browser suites; its seating remains separate.

## Scope

Global reduction over Q, within the declared bounds. Heights, periods, regulator, rank, L-function and BSD are NOT_COMPUTED. Sage on Serena/Nucleus has not been run. This seat gives cold standing to T4 v0.1; it is not a lock ruling.
