# V1 v0.3 repair record — 2026-09-23

This additive successor addresses the four points in Robin's relayed Opus review of V1 v0.2. That review is attributed context; the receipts in this package record this builder's own checks. No new cold-audit, seating or lock claim is made.

## Busy verifier

The page serializes its authorization operations. Obsolete queued epochs are skipped. A request that receives HTTP 429 shows **Verifier busy — retrying**, together with the current linked context, and retries under the existing deadline. Changing context clears all six panels and aborts the previous browser request; a server child may still be finishing that request, and another tab can also occupy the server. Consequently, serialization within one page does not promise that all 429s disappear. It guarantees a visible retry path and rejects stale replies. The single-child server cap is unchanged.

The browser suite holds the latest curve's request behind repeated 429s after two switches 40 ms apart, observes all six panels unverified, then releases it and checks that every panel settles on y² = x³ − x + 1, conductor 92, Tamagawa product 3. Existing signed-response tampering, delayed-response, server-loss and file:// tests remain required.

## Record identities and visible hashes

The legacy short-model fingerprint, legacy context, exact five-coefficient input model, T4 final-model ID, T4 record context, certificate context and linked six-panel context have separate labels. Different schema hashes do not imply a coefficient mismatch. Exact input-to-plot and input-to-final tuples show their relationship. The client and register projector additionally require the certificate context to equal the full packet's T4 record context.

Each verdict card opens by default and visibly prints the packet hash, certificate ID, certificate model/context and linked context, followed by the complete mathematical verifier and public-gate/bridge SHA-256 hashes. Users can collapse cards or their parent panels. Full record mapping is also visible in the BSD identity area. Unverified states clear these identities and proof hashes.

## Euler product

The label explicitly reads **Partial good-prime Euler product**, with ∏ L_p(1) = ∏ p/#E(F_p), its cutoff and exact rational value. Bad Euler factors are listed separately. No limiting-product or analytic-rank conclusion is asserted.

## B1 reference benchmark; no live evidence promotion

For y² = x³ − x with ω = dx/(2y), the existing AGM component already represents the total Néron real integral Ω ≈ 5.24411510858424. Its displayed rational was 2622057554292119/500000000000000. There was no factor-of-two arithmetic error. The page now spells out the primitive real period ω₁ ≈ 2.62205755429212, two real components and Ω = 2ω₁. This is a numerical value, not a rigorously bounded enclosure. PARI's period convention is described in its [elliptic-curve reference](https://pari.math.u-bordeaux.fr/dochtml/ref-stable/Elliptic_curves.html).

`test-benchmark.worker.cjs` records a pinned PARI run at 50-digit working precision. It reproduces L(E,1) ≈ 0.655514388573030, torsion order 4, conductor 32 and Tamagawa product 2 as benchmark outputs. Independently structured quadratic-residue counts reproduce all 13 good-prime rows from 3 through 43 and the exact partial product 39644731308091/82463372083200.

The benchmark checks numerical agreement with L(E,1)/Ω = 1/8; it does not prove that exact identity. Substitution into BSD yields a reference Sha quotient near 1, labelled conditional. It neither establishes an independent Sha order nor inserts rank, full torsion, regulator, L-value or Sha records into the live viewer. The BSD comparison therefore remains INCOMPLETE until those inputs acquire their own evidence.

The next arithmetic deliverable remains PT1, exact rational-point operations and finite torsion certification, according to the separately sealed PT1 handoff. B1 supplies analytic data later; heights and full rank certification retain their own prerequisites.
