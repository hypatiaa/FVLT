# T2: tame Tate reduction and local Tamagawa proofs

Additive audit candidate, 2026-09-07. The baseline is Fable's cold-audited T1 v0.1. That standing stays with T1; this successor requires its own cold review.

T2 computes the local minimal model and all tame Kodaira branches from the exact five-coefficient equation for **5 <= p <= 1009**, within the arithmetic and trace caps below. It includes good and multiplicative reduction, II, III, IV, I0*, every supported I_n* index, IV*, III*, and II*. The actual Tamagawa number follows from exact branch and residue-polynomial witnesses. A source report's permitted value is not used to choose c_p.

The trace carries denominator clearing, the short-form change, every p-scaling and refinement translation, complete finite-field roots/factors, local minimality, and the terminal conductor/component data. The composite map transports the selected differential and exact points into a child curve record with all six panel contract bindings updated. Original source bytes, twist lineage, markings and repeated point visits survive.

The optional PARI comparison uses the pinned T1 producer and retains its full packet. Sage and PARI may choose different representatives from T2's local model, so a verified comparison isomorphism and differential map relate them. T2 computation and proof replay also work without a backend. Sage on Serena/Nucleus is a separate comparison line item and does not gate T2.

## Use

From this folder:

```powershell
node verify.cjs
node verify.cjs --t2-only
node build.cjs --input example-input.json 5 > candidate.json
node build.cjs --input example-input.json 5 --without-pari > candidate-offline.json
node assess.cjs candidate.json
```

`--record` accepts the exact curve-record schema used by v0.3/T1 instead of custom input. Custom input has exactly `ainvs`, `selectedMultiplier`, and `points`; numbers are canonical rational strings. `assess.cjs packet.json certificate.json` replays a claimed certificate. Public gates reject unknown fields and duplicate JSON keys before arithmetic. Internal helpers expect structurally validated inputs.

The default verifier checks pins and manifests, stages dependencies and runtime files in scratch, runs T2 and the separate Python method, then runs the entire frozen T1 verifier, including its v0.3/browser regressions. Workers refuse in-place verification. No runtime is downloaded or installed. Node, Python/jsonschema and browser discovery/overrides remain the T1 ones. `BSD_T1_PARI_DIR` selects the existing pinned portable arithmetic runtime.

T2 supports primes 5..1009; small-prime requests fail explicitly. The unchanged T1 tool still supplies its good-prime certificates at 2 and 3. Bad-prime work at 2/3 belongs to T3. Other limits are inherited rational/intermediate bounds, 32 p-rescalings, 64 star-refinement rounds, I_n* index at most 128, 512 trace events, 256 components, two added curve-record transforms and the inherited record-size limits. Resource limits cannot yield a certificate.

## Evidence boundary

These are **local** certificates. Global minimality, a Neron differential, certified curve-level bad-prime inventory, full conductor/Tamagawa products and heights are T4/later work. The inventory is explicitly attached to the denominator-cleared integral source model, before local minimization. Its unresolved cofactor remains exact and visible.

The viewer is unchanged. All six panel contracts are transported in the packet; live panel consumption remains V1. Exact point membership remains usable without reduction work. No rank, regulator, L-function or Sha assertion is promoted.

See `CONTRACT.md`, `HANDOFF.md`, `NEXT_STEPS.md` and `receipts/`. The final post-seal receipt is stored beside the package so its manifest has no self-reference.
