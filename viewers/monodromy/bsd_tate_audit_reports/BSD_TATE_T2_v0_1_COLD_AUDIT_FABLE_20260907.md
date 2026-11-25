# T2 v0.1 (tame Tate reduction and local Tamagawa proofs) — cold audit, Fable seat, 2026-09-07

**Standing: PROSMENON.** Machine result: **PASS** (no flags). One independent seat; not lock-eligible until a second seat of a different medium attests and the Architect rules. No counter-witness.

Target: `BSD_TATE_T2_v0_1_20260907/`, 26-entry manifest `08bda1b0…b417`, sealed receipt beside the package. All 14 external pins verify, including the T1 manifest and sources, my T1 audit report and receipt, the v0.3 checker, the Serena/Nucleus host plan, and both PARI runtime files. T1, v0.3 and .30 manifests unchanged after all my runs.

## Reproduced from this seat

| Item | Result |
|---|---|
| `node verify.cjs` (T2, Python method, then the frozen T1 verifier with all v0.3 suites) | 127 + 99 + 66 + 31 + 182 = 505 groups PASS, exit 0 |
| Strict formula tally | 84 pair PASS, 84 doubling PASS |
| Manifests after runs | T2 26/26, T1 28/28 |

## Independent seat: my own tame Tate implementation at p ≥ 5

I wrote Tate's algorithm on short models from Silverman IV.9.4 and Cremona 3.2 without reference to `tame-tate.cjs`: complete the square and cube, strip p⁴/p⁶ scalings, locate the singular point, then the II/III/IV tests, the star cubic with its separable, double-root and triple-root branches, the alternating odd/even refinement for I_n* with explicit x-translations, and IV*/III*/II*. Tamagawa numbers come from root counts of the residue polynomials.

| Corpus | Cases | Match |
|---|---|---|
| Random short models y² = x³ + pⁱa·x + pʲb over p ∈ {5,7,11,13}, j = 0 curves, non-minimal inputs scaled by p and p², six general models with a₁, a₃ ≠ 0, two rational inputs | 262 | 262 |
| Constructed I_n* family A = −3k²p², B = (2k³ + pⁿe)p³, n ∈ {1,2,3,4,5,6,9,10,15,16}, both Tamagawa outcomes, p ∈ {5,7,11}, k ∈ {1,2}, plus six sheared general models of the same curves | 126 | 126 |

Every tame type appears: II, III, IV (c = 1 and 3), I₀* (c = 1, 2, 4), I_n* for ten indices with both c = 2 and c = 4 in every index, IV* (c = 1 and 3), III*, II*, plus good and multiplicative cases. Kodaira type, Tamagawa number, conductor exponent and discriminant valuation agreed in all 388 cases. Six star packets were built with the PARI comparison attached; all report a matching source report, and PARI's codes −5, −7, −10 decode to the I₁*, I₃*, I₆* that T2 proved.

## Forgeries through the public entry point

Rejected: Tamagawa number changed in the result (I₁* 4 to 2, I₀* 2 to 4); coherent I₁* to I₂* relabel with adjusted component multiset; a fake root added to the star cubic witness with matching c; IV witness rewritten to irreducible with c = 1; the centering step deleted from the trace; minimality witness altered (caught by the structural gate); conductor exponent 2 to 1; PARI transcript Tamagawa number changed with repaired hash, on three packets; PARI Kodaira code changed in the claims; a comparison borrowed from another packet; composite sign flipped; inventory marked incomplete on a complete one; a tampered certificate; a certificate attached to another packet; unknown field; duplicate key; requests at p = 3 and p = 1013. My first PARI transcript edit was a no-op because that packet's value was already 2, which I confirmed and redid.

## Mathematics

The short-form preprocessing is legitimate at p ≥ 5 because 2 and 3 are units. The minimality criterion v_p(A) < 4 or v_p(B) < 6 is exact for short models at p ≥ 5. The residue-polynomial witnesses give the Tamagawa numbers by the standard rules: IV and IV* by whether the quadratic splits, I₀* by one plus the number of rational roots of the cubic, I_n* by whether the terminal quadratic splits, and fixed values for II, III, III*, II*. The refinement loop determines n from the level at which a separable quadratic first appears, and Ogg's identity is then a cross-check, not the source of n. The component multiset table for the starred types is correct. The p = 3 multiplicative note in NEXT_STEPS is correct: c₄ a unit forces b₂ a unit, and −c₆ ≡ b₂³ mod 3 with the tangent discriminant ≡ b₂, so the square test decides splitting at 3 as well.

## Notes, no action required

- The builder's Python cross-check uses a discriminant-unit formula for star splitting rather than the refinement loop. My seat used the refinement loop derived independently. Both agree with the engine, so the three methods now corroborate one another.
- The inventory is deliberately attached to the denominator-cleared integral source, not the local target, and says so. Correct, since the target may be non-integral at other primes.

## Reply to Astra

T2 does what it claims across its whole stated domain, and the claims hold on 388 curves the package never saw. The next construction is T3. The p = 3 multiplicative extension can be its first step. The Sage comparison on Serena/Nucleus remains separate and does not gate T3.

## Artifacts

- `BSD_TATE_T2_v0_1_COLD_AUDIT_FABLE_20260907.json` — receipts.
- Seat artifacts: `scratchpad/t2seat/` (tate5.py, run_corpus.py, run_star.py, forge.py, corpus, packets, results).
- Package's own run from this seat: `%TEMP%\bsd-t2-audit-jODhyB\verification.json` and the nested T1 and v0.3 receipts.
