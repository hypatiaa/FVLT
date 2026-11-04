# FF-2 skin data declaration repair

Status: proposed successor, awaiting review before any changed-namespace retry. All earlier freezes and attempts remain preserved. There is no mathematical counterexample and no theorem proof has failed: the first posted targeted compile reached definition elaboration and diagnosed declaration/instance problems.

## Actual posted Data02 results

- Skin data compile started1793757688.0175, after the exact1453/1456postingreceipt. Exit1 after0.967s, no timeout; source/review pins unchanged;392librarychecksums pass. No dependent skin call launched.
- Independent pillowcase data compile started1793757727.6225, after the same receipt. Exit0 after0.867s, empty error log;392checksums pass; object6b656127d20b65964d65f11e234e6123a7324cc499f7f40c733f144de9f4d58d. Its successful receipt is172c8926e9246a5a72316ca8412596c82c5ac0511998c10c9abc666ee52234fa. This is compile evidence only, not strict replay, axiom clearance, or B1/B2 proof.

## Proposed changes

`FF2_DEFINITIONS_PROPOSED_v0_3.lean.txt` changes only:

1. Adds targeted `Mathlib.Data.Fintype.Prod` import, which defines the finite product instance needed under the Edge/Square subtypes. Existing abstract subtype and cardinality formulas remain unchanged. This is an API remedy, not a restriction of omega.
2. Marks `boundary` and `coefficient` noncomputable, because the pinned Finsupp subtraction instance is noncomputable. Both mathematical definition bodies are byte-identical. This changes code-generation standing, not the integer chain group or its boundary equation. No claim that these Finsupp definitions are executable certificates remains. The separately executable pen and pillowcase key definitions are unaffected.
3. Removes only `Fintype` from Sign's deriving list, retaining the exact two constructors and `DecidableEq`. The deriving handler generated an ill-typed finite-enumeration witness in this environment. No accepted theorem uses an Fintype Sign instance or a sign cardinality. This avoids adding a substitute witness/extra proof obligation while preserving the sign domain exactly.

All28targetheaders remain b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a. No positivity guard, subtype, arithmetic definition body, pen rule, boundary signs, quotient key, claimed theorem, runner or resource limit changes. Pillowcase's namespace remains byte-identical to the original freeze. Import boilerplate can remain separately pinned for that successful independent module.

Please accept/reject this exact additive declaration successor and authorize its comparison/binding against the original freeze plus this reviewed delta. No changed namespace compile will run before the review. The unchanged successful pillowcase data line can independently proceed to posted axiom/replay jobs. Batch01 retains origin1793757115/deadline1793758915 without extension; fresh capacity/binding is required if the current600swindow expires.
