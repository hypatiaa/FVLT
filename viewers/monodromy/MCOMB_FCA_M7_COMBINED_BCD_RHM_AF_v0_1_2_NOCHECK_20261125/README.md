# M7 v0.1 — divisor contexts and order-aware walks
Additive successor to audited M6, manifest 71181e3f9a1076fd934d2c75de684dd507f198b754eb164108ffa74250e76d84.
Contract: pinned visualization schema v0.1-C §15 and implementation plan v3 M7. Robin authorized M7 on 2026-09-25.

Open the assembled monodromy-31-linked-reduction.html through server.cjs. Under the Cayley panel, select a finite M4 atom, then open “Divisor concepts · FCA and order-aware walks · M7”. The panel follows that atom; source changes invalidate old computations. Imported sidecars are held until explicit Follow.

Five exact contexts: Birkhoff non-divides, ordinal GE and LE, nominal equality, and complete-strand membership. Default LE preserves ascending divisor labels. Graph relation and transform have separate selectors. A concept extent is distinct from the selected divisor. Small concept cover diagrams use extent inclusion; exact concept tables and explicit budget standings remain available.

Three walk semantics retain their own transition operators. Group walks and order-annotated group walks use the original comb labels and multiplicities. Ascent uses directed coordinate covers with no wraps and no cyclic-Fourier applicability claim.

M6 audit observations: one timeout-only browser retry is recorded with first-attempt evidence retained; history cellLimit is explicitly cumulative across retained layers. M6/M5 arithmetic modules are byte-preserved.

Commands: node build.cjs (unsealed only); node verify.cjs m7 (focused scratch run); node verify.cjs (full scratch run); node seal.cjs <external qualifying preseal receipt>; node verify.cjs again after sealing; node check-integrity.cjs.
Builder PASS does not confer independent audit, seating or lock. No BSD promotion. 37a1 remains rank ≥ 1 only. Contact sweep is separate and not implemented here.
