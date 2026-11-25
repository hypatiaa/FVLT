# T1 v0.1 (exact model adapter and local proofs) — cold audit, Fable seat, 2026-09-07

**Standing: PROSMENON.** Machine result: **PASS** (no flags). One independent seat; not lock-eligible until a second seat of a different medium attests and the Architect rules. No counter-witness.

Target: `BSD_TATE_T1_v0_1_20260907/`, 28-entry manifest `de4467a5…6032`, sealed receipt beside the package. Twelve external pins verify, including the v0.3, v0.2, v0.1 and .30 manifests, the v0.3 checker and schema bytes, the .30.1 viewer, my v0.3 audit report and receipt, and the two PARI GP WebAssembly runtime files. All four predecessor manifests still verify after my runs.

## Reproduced from this seat

| Item | Result |
|---|---|
| `node verify.cjs` (T1 suites, then the frozen v0.3 verifier from a staged tree) | 66 T1 groups, 31 Python fixture groups, 182 inherited groups, exit 0 |
| Strict formula tally | 84 pair PASS, 84 doubling PASS |
| PARI runtime | GP 2.17.4 WebAssembly, both files hash-pinned, version string asserted on every run |
| Source packages, audit reports, runtime bytes before and after | unchanged |

## Independent seat: twelve curves, expectations computed in Python, packets built through PARI and replayed through `assess.cjs`

For each curve I computed v_p(Δ), v_p(c₄), the Legendre symbol of −c₆, the point count, and the resulting split/nonsplit type, Tamagawa number and a_p by my own formulas, then compared with the certificate.

| Case | Expected | T1 certificate | Match |
|---|---|---|---|
| 11.a1 at 11 | split I₅, c=5, a=1 | same | yes |
| 14.a1 at 7 | split I₃, c=3 | same | yes |
| 15.a1 at 5 | split I₄, c=4 | same | yes |
| y²=x³−x²−6x at 5 | nonsplit I₂, c=2, a=−1 | same | yes |
| y²+y=x³−x²+4x+1 at 5 | nonsplit I₃, c=1 | same | yes |
| y²+y=x³−6x+3 at 7 | split I₃, c=3 | same | yes |
| y²=x³+7 at 7 | additive, no certificate | UNAVAILABLE, T2 reason | yes |
| y²=x³−16x+16 at 2 and 3 | good on the recovered minimal model, a₂=−2, a₃=−3 | CERTIFIED on y²+y=x³−x | yes |
| y²=x³−x/16 at 5 | good after denominator clearing and re-minimisation, a₅=−2 on y²=x³−x | CERTIFIED | yes |
| y²=x³−x/16 at 2 | bad at 2, no certificate | UNAVAILABLE, T3 reason; PARI reports III, f=5, c=2 as a source report | yes |

The two nonsplit parities and the split case with n ≥ 2 exercise every branch of the Tamagawa formula.

## Forgeries through the public entry point

Rejected: trace Tamagawa number changed; coherent nonsplit rewrite of roots, type, Euler factor and c_p; sign of a tuple's u; parent multiplier with repaired parent hash; PARI transcript c_p with repaired stdout hash; panel marking id; an attached certificate from another packet; a tampered certificate; unknown top-level field; duplicate JSON key; composite prime; prime above the 1009 domain. On a discriminant with the factor 1013² above the trial bound, forging the inventory as complete, with or without a fabricated prime proof for 1013, is rejected. My first inventory forgery on 11.a1 was accepted because −11⁵ is already fully factored, which is correct behaviour, not a gap.

## Mathematics of the two local proofs

Both are exact and complete within their stated scope. A p-integral model with v_p(Δ)=0 is p-minimal and has good reduction. A p-integral model with v_p(Δ)>0 and v_p(c₄)=0 is p-minimal, because any rescaling with v_p(u)>0 would make c₄/u⁴ non-integral, and has multiplicative reduction I_n with n = v_p(Δ). For p ≥ 5, split reduction is exactly the condition that −c₆ is a nonzero square mod p, and the Tamagawa number is n for split, 1 for nonsplit odd n, and 2 for nonsplit even n. The a_p = ±1 count on the nodal cubic is consistent with the enumeration used. The PARI Kodaira-code decoding table in the adapter is correct, and the tuple direction is verified by replay on all five coefficients rather than assumed.

## Notes, no action required

- The builder retrieved the PARI WebAssembly runtime from the official site and pinned both files by hash. That is the portable-PARI arrangement I recommended, in a form that needs no installer or WSL. A pin mismatch fails without fallback.
- The Sage producer is syntax-checked only, and the package says so everywhere it matters. Serena/Nucleus is the designated host per Robin's note.
- The unit-c₄ criterion and the −c₆ square test also hold at p = 3, so the multiplicative proof could later extend to p = 3 within T3. The p ≥ 5 restriction is conservative and correct.

## Reply to Astra

T1 does what the plan asked and holds up on curves the package never saw. The next construction is T2. The Sage comparison stays a separate line item and does not gate T2.

## Artifacts

- `BSD_TATE_T1_v0_1_COLD_AUDIT_FABLE_20260907.json` — receipts.
- Package's own run from this seat: `%TEMP%\bsd-t1-audit-lIuJkg\verification.json` and `%TEMP%\bsd-reduction-audit-KvzwLo\verification.json`. Seat artifacts: `scratchpad/t1seat/` (cases, packets, results, forgeries).
