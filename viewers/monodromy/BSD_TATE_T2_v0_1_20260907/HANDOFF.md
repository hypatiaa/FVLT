# Cold-seat entry: T2 v0.1

Read `README.md`, `CONTRACT.md`, `tame-tate.cjs`, `finite-field.cjs`, `t2.cjs`, the schemas/public gate and both test sources. This is an additive successor to the frozen T1 package. Fable's T1 audit report and receipt, T1's manifest and the Serena/Nucleus host plan are pinned. No predecessor or viewer bytes are patched.

Run `node verify.cjs`. It stages all inputs in scratch, executes T2 and the Python calculation, then runs the complete T1 verifier and its inherited v0.3 suites. Workers refuse in-place runs; inventories and hashes are checked before and after. `--t2-only` is explicitly narrower. No backend installation or download occurs. Existing runtime overrides continue to work.

The principal new claim is actual local c_p certification for tame additive branches. Audit the construction and complete factor/root witnesses for IV, I0*, I_n* and IV*. For the star refinement branch, check the alternating levels, nonzero translations, and independent determination of n before the Ogg cross-check. Do not accept a discriminant valuation table or allowed c_p set as a substitute for the component polynomial.

Fixtures cover every tame Kodaira family and each Tamagawa value, three odd primes, both star parities through n=18, nonzero refinements, repeated scaling, j=0, general rational inputs, signed differential transport, exact repeated point visits, twists/markings and the prime bound. Python uses an independent discriminant-unit formula for star splitting instead of the main refinement loop. This remains a builder-method cross-check, not a separate cold seat. The optional PARI packet remains a source report, and the test that repairs a false-but-allowed PARI c_p must fail against T2's proof.

Adversarial targets include branch deletion/reordering, root multiplicities and residual irreducibility, altered levels or shifts, false minimality/normalization/component data, a coherent wrong c_p rewrite, a borrowed or repaired backend comparison, certificate substitution, unknown/duplicate fields and a forged complete inventory above the factorization bound. Require actual rejection at the public entry point for structural and certificate attacks.

The inventory names the **denominator-cleared integral source**, not the locally minimal target. The target can be nonintegral elsewhere. The child record stores two additional composite steps; the full trace preserves every intermediate local transformation. Verify the map between T2 and PARI targets, since equal coefficients are not required.

T2 is limited to 5..1009 and documented resource bounds; it is not full Tate at 2/3, global minimal/Neron certification, a live viewer adapter or a height implementation. The p=3 multiplicative note is verified in `NEXT_STEPS.md` and remains T3 work. The Sage installation/comparison on Serena/Nucleus is a separate line item and does not gate T2.

The sealed builder receipt is stored beside the package as `../BSD_TATE_T2_v0_1_SEALED_VERIFICATION_20260907.json`. Builder verification is not cold standing or a lock ruling.
