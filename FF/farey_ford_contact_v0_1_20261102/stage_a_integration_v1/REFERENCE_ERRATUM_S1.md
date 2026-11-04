# Signature freeze erratum S1 (binder annotation)

2026-11-03. Skeleton seat (Claude Opus 5.5). Answers #1397. Additive: `SIGNATURE_FREEZE_DRAFT_v0_1.md` (`a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7`) is unchanged.

## Decision: **ACCEPTED**, annotation only

In the frozen definition `phases`, the image lambda is read as

```lean
(fun c : ℕ => (c : ℚ) / (q : ℚ))
```

in place of `(fun c => (c : ℚ) / (q : ℚ))`. The lambda is applied to elements of `(Finset.Icc 1 (q - 1)).filter …`, a `Finset ℕ`. So the intended binder type is ℕ, and the intended set is unchanged: the fractions c/q with 1 ≤ c ≤ q − 1 and gcd(c, q) = 1, over admissible q. Lean elaborated the ascription `(c : ℚ)` first and inferred c : ℚ, which is an elaboration artefact, not a different definition.

**Same reading, pre-cleared:** if `unreducedPhases` meets the same error, its lambda may be annotated `(fun e : ℕ => (e : ℚ) / ((a + 1 : ℕ) : ℚ))`. No other change to either body.

**Scope.** Only the binder annotation `: ℕ` on these two lambdas. Every other frozen byte stays verbatim, and every theorem header is unchanged. Skeleton's comparison script at the report accepts exactly these annotations as the only differences, besides the D2-style `noncomputable` marker if one is ever needed.

**Evidence the meaning is unchanged.** Skeleton's scripted check (`SKELETON_SIGNATURE_CHECK_20261103.cjs`, job SKEL-FF-SIGCHECK-0001) and Sage both computed `phases` with c ranging over naturals. The fixture counts (4,2,1) 7/6/3 and (9,2) 11/8/5 are for that reading.

**Timing.** The review wait, from the owner's request to this erratum, is excluded from the F2 active cap.

**Other items in #1397.**
- Instance and constructor work (`Std.Symm`, `Std.Irrefl`, `DecidableRel` for `fareyAdj`) and proof goals are ordinary bounded iteration, already accepted for F2.
- Using Mathlib's proved bounded-walk decider (walk length < card V) under kernel `decide` for the small induced-connectedness checks is accepted. It changes no definition or proposition, and `native_decide` stays forbidden. Report its cost.
- `spanning_tree_connected` stays a frozen target and must be proved as stated.
