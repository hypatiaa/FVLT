# BUILD REPORT v0.4.5 (2026-10-20)

Builder: subagent (Claude Sonnet 5.5). Additive successor of v0.4.4 (`FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020`; its SHA256SUMS.txt checked before and after, 0 lines not OK; dist sha256 db2d0af2...7760 unchanged). Copy made without shot_*/export_* images and dist_round1. Stopping is shared. Node only, no git/download/install/PowerShell in programs.

## saphir's decisions (2026-10-20) and what was done
1. **Cap 41.** Old `build/browser-check.cjs` is unedited. New `build/browser-check-v045.cjs` counts with the old method verbatim (visible button/input/select inside #inst or .header, minus .info) and asserts <= 41 on fourier, clifford, hopf at both sizes, in the n! base (the old test's state), in CA mode, and in continuous mode. It supersedes the 12 failing "<= 40" assertions of the old file (6 per viewport: the fourier, clifford and hopf "visible controls ... <= 40 (addendum 7 F1)" assertions, the two continuous-mode inventory assertions ("in continuous mode", "between shells"), and the "N mode switch ... keeps the cap" assertion). Measured: n! base 41, CA mode 39 (preset menu replaces M box and n1 stepper), continuous (n! base) 41.
2. **CA mode in the address.** Optional last field `&ca=1`.

## Address field format
`#v=<id>&<the existing keys in the existing order>` and, only while CA is effectively on (integer mode, B in the ten presets), `&ca=1` appended. Every other state's address is `C.encodeAddress(st)` exactly (checked identical to v0.4.4, URL and address line). comb-core.js is untouched: the panel splits every `ca`/`ca=...` part off before `C.importAny`, which still refuses unknown keys. The hashchange handler honours the field. The address line, the URL (replaceState) carry it; exports (state file, exact file, pair address, stats text) keep the plain address, since CA is a display overlay.
Refusals (CA flag only, state kept as named; I chose refusing over the UI's B = 5040 fallback so an address never changes its B): `ca=1` with a non-preset B, or n! mode, or a value other than exactly `1`, or the field repeated: state loads as the address says, CA unpressed, the status line says "CA flag refused: ...". An invalid state part is refused as before ("Address refused ...").

## Files
Changed: `instruments/comb-hopf/panel.js` (caOn, addrOf, splitCa, readHash; writeHash, address line, init, hashchange), `instruments/comb-hopf/README.md` (title, v0.4.5 section with dial ledger), `build/package.cjs` (viewer string comb-hopf v0.4.5), `dist/comb-hopf.html`, `dist/MANIFEST.sha256`. New: `SCHEMA_ADDENDUM_13.md`, `build/browser-check-v045.cjs`, this report, `shot_v045_*.png` (6), `SHA256SUMS.txt`. Everything else byte-identical to v0.4.4.

## Checks (true counts)
exact-lib/test-exact 21/0; host-core/test-core 159/1; contrast-check 93/0; test-mirror 14/0; test-v041 10/1; test-v042 5/1; test-v044 11/0 (all as v0.4.4, same expected failures). browser-check-mirror 122/0; v041 66/0; v042 46/0; v043 36/0; v044 222/0; browser-check (v0.3) 545/20 (identical to v0.4.4: 8 old failures plus the 12 cap failures, left unedited and superseded). **browser-check-v045 58/0** (29 per viewport): counts; every one of the ten presets loaded fresh from its address (CA pressed, B correct, select shows B, card atom line "mode CA", "CA #k of the 10 presets", address line and URL keep `&ca=1`); UI -> address -> reload round trip (same state JSON and address); leaving CA drops the field; six non-CA states (n! and integer, tabs, continuous, integer B = 5040 and 55440) give identical URL, address line and state against v0.4.4's dist; an old-style address of a preset B without the field loads CA unpressed as before; four refusal cases and the B = 100 case (stays 100); invalid state still refused; hashchange adds/removes CA; no page errors.
Shots (looked at 1280 panels CA55440 and 375 fourier CA5040, both correct): `shot_v045_{1280x800,375x812}_{panels_CA5040,panels_CA55440,fourier_CA5040}_fresh.png`.

## Uncertain / findings
- **Integer base, non-CA, same counting method: 42 controls** (B = 24, all three tabs, both sizes), over the cap 41. This is not new: v0.4.4 gives 42 too (M box and n1 stepper both visible), and the old test only measured the n! base. I did not assert it and did not change it (nothing else changes). saphir may want the cap or that row looked at.
- After a refused CA flag the URL keeps its `&ca=1` until the next state change rewrites it (the address line shows the plain address).
- Exports/pair addresses carry no `ca` field (decision: display overlay); say if the pair address should.
