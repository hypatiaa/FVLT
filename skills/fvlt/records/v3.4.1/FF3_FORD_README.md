# Correction candidate: the §9.4 Ford-circles row (FF-3), for review (2026-11-04)

**Status: candidate v0.3, not applied.** Layout per saphir, 2026-11-04: "Short cell + note". The row is shortened and points to an untagged note below the table, which carries the v0.2 text. Applied-draft sha256 `9b6dda3d58f672eec8cac11a2790aec8ca58b0318ee433ed5bad1cba66265625`, reproduced here. Earlier: The locked v3.4.0 kernel (`kernel/post-v3.3.1/kernel.md`, sha256 `0d6beee2…ec1a2`) is unchanged. Any successor needs saphir's adoption, label and lock.

**Source.** The skeleton seat (Claude Opus 5.5), at saphir's request: "do the kernel 9.4 correction draft for idea catalog to review". The rule it follows: verified Lean wins over kernel prose (saphir, 2026-10-30). `CHANGES.json` holds the candidate exactly as received, plus the reviewer's proposed v0.2 text.

**What it changes.** One table row, v3.4.0 line 644 (Part II / II.5, "§9.4 classical connection — Ford circles"). The row has no native tag and lies outside every item-locked span. Its "has not been defined" is narrowed: a map on lifted data is now defined and Lean-verified (FF-3), while arcs, maps from phasor values or paths, and dynamics stay undefined and interpretive.

## Checks done here
- **Replacement.** The old text occurs exactly once in v3.4.0. Applying the candidate gives sha256 `e2d348b7ab32fde7f1a7083813e7e7b0add45174a827785f62b15193d2f1f9ed`, as reported, with the line count unchanged. The v0.2 proposal gives `7e50df43cc10643d1d5b41b82c5b7851cc1d372eabfedc7f2140f3ec63e56f18`.
- **Mathematics,** with `check_ff3_row.py` (exact fractions, stdlib): 8,557 checks pass.
  - **Shells** n₃ = N, t₁ = t₂ = 1, for N = 2..39: the real events in [0, N] are exactly s = mN/(N−1), checked on a grid finer than the events, with addresses m/(N−1).
  - **Farey sets:** the union of the addresses is F_B for B = 1..39, and consecutive members have determinant 1.
  - **Ford circles,** for all pairs with denominators up to 12:
    - |det| = 1 ⇔ tangent, with the kiss point exact and on both circles;
    - otherwise the circles are disjoint, so every edge is tangent, stall or break.
  - **The N = 3 alias:** s = 0 and s = 3 give the same phasor and the addresses 0 and 1.
- **Not re-checked:** the Lean library itself, which is reported by skeleton and not in this repository.

## Review
See the PR comment. In short:
- the mathematics is right;
- the proposed v0.2 fixes the amplitude convention (v3.3.1 sign of n₆), ties the phase address to Rmk II.5a, defines the shells, and removes a symbol clash;
- the reviewer leans towards a short cell with an untagged note below the table, for length. That is not an item addition.
