# BUILD REPORT v0.4.6 (2026-10-20)

Builder: subagent (Claude Sonnet 5.5). Additive successor of v0.4.5 (`FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020`; its SHA256SUMS.txt checked before and after, 0 lines not OK; dist f6144c2e...d312 unchanged). Copy made without shot_*/export_* images. Stopping is shared. Node only, no git/download/install/PowerShell in programs.

## saphir's decision
v0.4.5 showed 42 controls on the integer base (B = 24, non-CA), over the cap 41. saphir: "trim the row by one". The integer row had no Apply button (the M box already applies on change/blur/Enter) and no duplicate control. The only controls with no function there were the n1 minus / select / plus (disabled in integer mode). I stopped and listed options; saphir chose option A: hide the whole `#n1grp` when the base is integer (CA already hid it). Note this removes 3 controls, not 1: 42 -> 39.

## Change
`instruments/comb-hopf/panel.js` line 272: `$('n1grp').style.display=(ca||integer)?'none':''`. `panel-g-robin.js` untouched (export source line 21 unchanged). n1 stays in the state and the address; no address changes. Switching integer -> n! shows the group again with the stored n1, enabled.

## Files
Changed: `instruments/comb-hopf/panel.js`, `instruments/comb-hopf/README.md` (title, v0.4.6 section, dial ledger), `build/package.cjs` (viewer string comb-hopf v0.4.6), `dist/comb-hopf.html`, `dist/MANIFEST.sha256`. New: `SCHEMA_ADDENDUM_14.md`, `build/browser-check-v046.cjs`, this report, `shot_v046_*.png` (4), `SHA256SUMS.txt`. Everything else byte-identical to v0.4.5.

## Checks (true counts)
exact-lib/test-exact 21/0; host-core/test-core 159/1; contrast-check 93/0; test-mirror 14/0; test-v041 10/1; test-v042 5/1 (the same expected failures as v0.4.5); test-v044 11/0. browser-check-mirror 122/0; v041 66/0; v042 46/0; v043 36/0; v044 222/0; v045 58/0; browser-check (v0.3) 545/20, identical to v0.4.5 (20 failures, same names: the 8 old ones plus the 12 "<= 40" cap ones). No old test counts or clicks the removed control differently: none changed result. No old test edited.
**browser-check-v046 16/0** (8 per viewport): counts per tab (fourier, clifford, hopf) at 1280x800 and 375x812: integer 39, n! 41, CA 39, continuous 41; n! shows the group, integer hides it, back to n! shows it with n1 = 6 enabled; n1 stays in state and integer-mode address; CA hides it and CA -> integer keeps it hidden; address line, URL and state identical to v0.4.5 for 7 sampled states (n!, integer, continuous, CA 55440 with `&ca=1`, B = 720720, integer with n1 = 5); no page errors.
Shots (looked at both integer rows; clean, M box right after the CA button, no gap): `shot_v046_{1280x800,375x812}_{integer_row,nfact_row}.png`.

## Uncertain
- The 3 removed controls were all disabled in integer mode; the stale n1 value is no longer displayed there (still in the address and state).
- I did not test a touch Apply fold, since no Apply button exists; the M box commits on change (Enter or blur) as in v0.4.5, unchanged.
