# PT1 implementation report

The mathematical and browser-local implementation, fixtures and public gate are complete in this candidate. Actual pre-seal suite counts are recorded by PRESEAL_SUMMARY.json when the seal is issued; post-seal full execution and final builder standing are recorded outside the seal in BSD_POINTS_TORSION_PT1_POSTSEAL_20260923/SUMMARY.json. A successful pre-seal receipt alone does not assert a successful post-seal run.

Exact five-coefficient membership and group law, O, signed scalar arithmetic, minimal-order witnesses, finite-subgroup enumeration/closure, odd-good-prime divisibility bounds, the non-tight x³+x exhaustion branch, and complete-group Mazur guard are implemented. All 18 expected torsion fixtures are replayed independently of backend output. The required 37a1 certificate supplies rank ≥ 1 as a separate status only.

The actual BSD comparison receives only replayed complete torsion. Imported/source-reported values remain visible. Viewer v0.8 family, interaction, spectral and security behavior is retained. New tests exposed and repaired the held-address import path: current exported evidence is restored after linked-source restoration, preventing old capture records from overwriting later edits.

Intentional test expectation changes: inherited assertions that torsion must remain absent now permit the separately replayed PT1 component; T4-only row checks explicitly filter the Tamagawa component; hostile export edits follow the new full wrapper. Assertions about ranks, regulator, missing Tamagawa on partial T4, spectral behavior and all security boundaries remain. The six scratch-harness checks replace a sealed mutable benchmark fixture with a portable pre-seal summary.

Limitations: automatic x search is bounded; high-order/rational fixtures use untrusted pinned-PARI candidate coordinates and their full proof is replayed locally. Generic non-tight division-polynomial exhaustion is not implemented. The specialized x³+x proof is the sole fallback. Good-prime proofs do not require global minimality. Exact points do not acquire numerical elliptic-log placement. Optional bad-prime counting cross-check and all later stages in the Opus addendum are deferred.

The final status remains BUILDER_VERIFIED only when the external post-seal receipt says PASS; no independent cold-audit, seating, lock or full BSD claim is made here.
