# FF-2 API inspection

Metadata/source-only inspection on nucleus over Tailscale. No Lean invocation, definition elaboration, theorem proof or executable mathematical test was performed. The first source-search attempt used rg, unavailable on nucleus (exit 1); subsequent searches used grep. A search with no matching declaration also exited 1; neither was a mathematical failure. No files were changed remotely.

The proposed complete definitions use the pinned `Mathlib` root import, two Finset-based subtypes, concrete four-term Finsupp boundaries and an integer-modulo cyclic direction. These avoid reliance on an uninspected graph-isomorphism API or a surface-realization library.

Observed APIs:

- Lean Init/Data/Fin/Basic.lean:54: `Fin.ofNat (n : Nat) [NeZero n] (a : Nat) : Fin n`. The definition includes a local NeZero witness derived from the explicit `3≤ω` binder. Negative direction steps reduce modulo positive ω in Int before conversion to Nat.
- Lean Init/Data/Int/Order.lean:702: `Int.toNat_lt`, supporting later conversion proofs if needed.
- Mathlib/Data/Finset/Powerset.lean:102: `Finset.card_powerset`.
- Mathlib/Data/Finsupp/Single.lean:47 and :57: `Finsupp.single` and its evaluation formula `single_apply`.
- Mathlib/Data/Finset/SymmDiff.lean:43: `Finset.mem_symmDiff`; the frozen definition instead uses the explicit erase/insert toggle, so no scoped symmetric-difference notation is required.

| Inspected source/executable | SHA-256 |
|---|---|
| Lean executable | bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38 |
| Init/Data/Fin/Basic.lean | bb3d4e46cb40a24f5a09e6e003c76f2b84140a598df81233f0bffe3afe08cbf4 |
| Init/Data/Int/Order.lean | a92a3e1832b1c0b7e5dd8a66f3b101b0a4ba5abc2bedffd31d767a09f448d753 |
| Mathlib/Data/Finset/Powerset.lean | cff2d246934cd2c1eb4d264985c863d6d5f1e364a65b62eceb695dadd0098be3 |
| Mathlib/Data/Finsupp/Single.lean | 9013e1947b29d16d7e1aec37fc449c6e09da12c55fdac740908f1a07812ca7a7 |

A directory-only `find` probe, sorted by version, confirmed v20 as latest at this inspection. The runner repeats that check before execution and refuses a later version until rebinding review. Capacity and contention are deliberately re-observed only at concrete job binding; this source inspection is not a resource reservation.
