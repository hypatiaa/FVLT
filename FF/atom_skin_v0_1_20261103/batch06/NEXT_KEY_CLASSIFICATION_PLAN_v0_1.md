# Remaining pillowcase key theorem: proof decomposition

Development plan only. No new theorem is claimed here, and no definition or frozen header changes.

The frozen obligation is `key a b v = key a b w ↔ pillowRel a b v w`, for all positive natural a and b and all integer points v and w. The existing six pillowcase results establish the equivalence relation and its half-turn fixed-point structure, but do not establish this complete key classification.

The proof should separate three exact steps:

1. **Residue-pair orbit criterion.** Reduce both coordinates modulo 2a and 2b. Translation gives the same residue pair; a half-turn gives simultaneous negation of both residues. Prove the converse by extracting the two integer quotients. The negation is simultaneous: independently flipping only one coordinate is not the group relation.
2. **Net normalization.** Prove the actual frozen `net` maps each residue pair into the rectangle 0 <= x < 2a, 0 <= y <= b, and preserves its orbit. On y = 0 or b, both simultaneous-negation representatives remain on the same boundary and must be identified. Prove the modular expression `(2a-x) % (2a)` is 0 when x = 0 and 2a-x otherwise, using the strict residue bounds.
3. **Key separation.** On the normalized rectangle, the front/back constructors distinguish the two interior halves. The boundary constructor identifies x with 2a-x exactly on the declared boundary. Prove equality of these actual constructor values is equivalent to equality or simultaneous negation of the original residue pairs. Compose with steps 1 and 2.

Keep every hypothesis an explicit binder. Keep intermediate helpers private in the existing pillowcase module. Preserve the actual `net`, `key`, translation, and half-turn definitions; a simpler replacement classifier would need a separately reviewed bridge and would not itself discharge the frozen theorem.

Preregistered illustrative values for a = b = 2, to check the intended statement when the next bounded batch is bound:

- (1,1) and (3,3) should have the same front key and be half-turn related.
- (1,1) and (3,1) should have different front/back keys and be unrelated.
- (1,0) and (3,0) should have the same boundary key and be half-turn related.
- (0,0) remains a permitted half-turn centre; no nonzero-centre restriction is introduced.

These are intended examples, not recorded computations or a proof. The universal theorem, not an example sweep, is the target. Compilation, named axiom reporting, strict all-constant replay, and independent review remain separate gates. Exclude G1; use nucleus over Tailscale with a fresh posted binding before any next-batch Lean execution.
