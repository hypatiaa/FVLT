# FF-2 import-only repair request

Status: awaiting Skeleton review; no retry launched. Batch01 original origin 1793757115 and deadline 1793758915 remain unchanged. The original frozen packet and failed attempt are preserved.

The first authorized data compile exited 1 after 3.428 seconds, before any definition elaboration. Log SHA c4e43a379956e03c3ebc83efc59f14184070aaf6490ee7d53686b5e880e1a3d0 reports a missing cached object:

    Mathlib/Analysis/Distribution/SchwartzSpace/Basic.olean

This is pulled by the all-Mathlib root import, not an FF-2 dependency needed by the definitions. Source and reviewed files remained unchanged; all 392 library checksum entries still passed. No mathematical verdict, definition-type verdict or theorem proof was produced. No dependent call or repeat compile was launched; the independent pillowcase data compile was also held because it uses the same known failing import.

## Requested repair

Replace only `import Mathlib` in proposed scaffolding by these cached narrow imports:

```lean
import Mathlib.Data.Fintype.Powerset
import Mathlib.Data.Fintype.Card
import Mathlib.Data.Finsupp.Basic
import Mathlib.Logic.Function.Iterate
import Mathlib.Tactic.DeriveFintype
import Lean.Elab.Tactic.Omega
```

The six root object files were confirmed present read-only in the pinned dependency/toolchain cache (Lean's core object has its normal toolchain permissions). Their full transitive closure has not been independently elaborated or rebuilt. A subsequent missing-object failure would still be a tooling result, not evidence against a theorem. No download or library-cache write is proposed.

The additive successor definition text has SHA 6b013b45bfafad44641edfab88d6a17c8de98581e1acf4d8b78cfde19e872623. COMPARISON_v0_1.json (SHA 3c391636931c7e0c180c585ae8f01432f3940db9b0463b1349016593e87d7000) confirms that everything from the first namespace onward is byte-identical to the original definition freeze. All 28 headers remain b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a. The runner is unchanged.

Please review this import-only successor and specify its binding as an additive accepted repair to the original manifest22650c5b, or require a newly pinned packet/template binding. No new time budget, definition change, theorem change, Neo compute or FF-3 build is requested. If the existing batch expires while awaiting review, it ends without a mathematical conclusion and a later batch needs its own posted fresh binding.
