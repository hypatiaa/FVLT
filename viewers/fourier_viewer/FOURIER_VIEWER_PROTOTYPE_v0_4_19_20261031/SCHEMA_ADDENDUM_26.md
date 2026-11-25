# SCHEMA ADDENDUM 26 (v0.4.19, 2026-10-31): fix round on v0.4.18

No change to the state schema (`fv-comb-hopf-state/0.2`), the exact export, the Lift JSON, the address id (`fv-comb-hopf/0.2`), the PNG export or any readout of an existing state. No new mathematics and no new cards. The registers of addendum 25 (exact, guaranteed numerical, drawing) are unchanged. This addendum records the decisions and the changed rules of the v0.4.19 fix round (brief `BUILD_BRIEF_v0_4_19_FIX_ROUND.md`, the work list being the "Findings, ranked" of `VERIFY_REPORT_v0_4_18.md`).

## 1. Goldbach tooth order (decided by saphir, 2026-10-31: "both sides")

The order the v0.4.18 build used is now the specification of the Goldbach shell stream:

- The teeth of the shell's comb, ordered by |c| ascending, and for each |c| > 0, **+c before −c**.
- Odd m (N ≡ 2 mod 4, and N = 4, whose comb is m = 3): c = 0, 1, −1, 2, −2, ….
- Even m (N ≡ 0 mod 4, N ≥ 8): there is no c = 0 tooth, so c = 1, −1, 3, −3, ….
- One sign per tooth: + iff N/2 − |c|·t₂ and N/2 + |c|·t₂ are both prime. So every unordered prime pair {p, q} with p ≠ q is drawn **twice** (at +c and at −c) and the equal pair p = q = N/2 once: **#+ = 2·g(N) − δ** (δ = 1 when N/2 is prime).
- The Goldbach run to N_max concatenates the shells 4, 6, …, N_max, each in this order.
- The stream code (`pen-streams-core.js`, `goldbachShell`) is unchanged; `host-core/test-v0419-goldbach-order.cjs` checks it against an independent enumeration (own sieve, own comb, own sort) for N = 4, 6, 24, 100, 1448, every even N up to 1,448, and the full run.
- Both printed guards stay: "The pen draws the prime-pair mask; it proves nothing about Goldbach." and "Closure reaches conjugation, not Goldbach."

## 2. D1: event steps drawn with pieces

The D1 core (`rule30-ladder-core.js`) and its fixture are unchanged. The view cuts every **event** step t → t+1 of the lifted curve into e pieces, e = sub if sub ≥ need, else the smallest multiple of sub that is ≥ need, with **need = 32 at q = 1 and 16 otherwise** (`host-core/d1-event-pieces.js`, integers only). Point i of an event step: base (t·e + i)/(per_j·e), fibre (N_j(t)·e + i)/(q·e) turns, exact rationals; the fibre advances monotonically forward, as the declared lift rule says. Base steps keep the old subdivision sub = max(1, ⌈720/per_j⌉); the end point is the core's closing point (k, k·S_j/q), unchanged. Rows with sub ≥ need (every row with per_j ≤ 47 at q ≥ 2, per_j ≤ 23 at q = 1; per_j is a power of two, so per_j ≤ 32 and per_j ≤ 16) are drawn exactly as in v0.4.18.

The curve's group `r30-curve` carries, in addition to its v0.4.18 attributes: `data-event-steps`, `data-event-parts` (e), `data-event-need`, `data-event-pieces-min/max`, `data-event-forward`, `data-event-not-forward`, `data-event-base-forward` (exact audit by BigInt cross-multiplication), and `data-event-first` / `data-event-last` ("t:num/den,…": the exact fibre values of the first and last event steps).

The mapping of the exact rationals to canvas angles (`rlTurn`, `at` in `view-clifford.js`) is the inherited float mapping that the v0.4.16 brief permitted at the canvas; it is unchanged and remains an open float site (porting D1's projection to the integer register is a later decision for saphir).

## 3. Expected fails: host-tagged list with exit codes and summaries

`build/EXPECTED_FAILS_v0419.txt` lists **every suite** of the v0.4.19 `runall.sh` with its expected exit code, its expected SUMMARY line (and counts) and the exact multiset of its FAIL lines, each FAIL line labelled `[baseline]` (also in the Linux baseline run of the v0.4.18 build) or `[new card: …]`. The list is host-tagged (`HOST membrane linux`): membrane is the host of record (saphir, 2026-10-31). `build/check-expected-fails-v0419.cjs` passes only if all three match for every suite and no run suite is unlisted; on another host it prints the host and exits 2. Format:

```
HOST membrane linux
SUITE <name>
EXIT <code>
SUMMARY-LINE <the last log line reporting "<p> pass[ed] … <f> fail[ed]">
COUNTS <p> <f>
[baseline] FAIL …
[new card: …] FAIL …
```

## 4. Pixel certificates: two counts, and the doubling rule

- **"enclosure wider than ¼ px: n"**: drawn points whose enclosure is wider than a quarter pixel on an axis (the v0.4.18 count; `data-uncertified`, kept).
- **"pixel undecided: m"**: drawn points whose enclosure straddles an integer pixel edge on an axis, floor(lo) ≠ floor(hi) for the drawn coordinate (`data-undecided`, new; `pen-interval-core.pixelCert`). Then the drawn pixel (the floor of the midpoint) may differ by one from the true one. A true value can lie on an edge, so m need not be 0.
- Both counts are printed on the disk (k = −1) and on the sphere card.
- **Doubling rule (the code now matches the core's comment):** the curvature card doubles P, of the absolute run and of the follow-the-pen trail, while the distance has fewer than 6 guaranteed places **or** n > 0, at most `P_DOUBLINGS_MAX = 2` times (P ≤ 4 × the starting P). The card prints "P doubled k times"; when the cap is reached it says so ("Precision cap reached …"). The {5,4} patch and the exact runs (T ≤ 64) are drawn from the fixed 160-bit scale and are not affected by P. The sphere's P is fixed (96 bits).

## 5. Wording

- Dodecahedron preset: the moves generate a group **isomorphic to A₅**, by explicit isomorphism in Sage: the v0.4.18 verifier's job VERIFY-0418-18 (receipt 9a77f4ca…) and this build’s job VIEW-SAGE-0419-02 on the build’s own moves (`build/dump-a5-moves-v0419.cjs`, `build/sage-a5-v0419.sage`; receipt in the build report). The element-order statement is kept.
- Lean citation: "Codex-reviewed (PASS WITH FLAGS, #1310 / #1318)", #1310 the review of `FVLTS4sSqueezeCornersV1` (library v15), #1318 of `FVLTS4sRule150PenV1` (library v16), as confirmed by the Rule 30 skeleton seat from the rule30 ledger. The CREDIT line names the same reviews.

## 6. Minor visual items

- Sphere card: the shared dials that do not apply to it ("follow the pen", W) are shown **disabled** with "(not used on this card)".
- Strips: when shell ticks would be closer than 3 px, every k-th tick is drawn (k the smallest integer keeping consecutive drawn ticks ≥ 3 px apart; tick x = ⌊b·width/L⌋) and "ticks every k shells" is printed. `data-ticks` (the number of shell boundaries) is unchanged; `data-tick-every` and `data-ticks-drawn` are new.
- Sphere: a "tooth events" toggle (default on) and smaller dots (3 × 3 px in front, 1 px behind; v0.4.18: 5 × 5 and 3 × 3). The count is printed either way.
- Dodecahedron preset: every step is drawn as its great-circle arc, 8 pieces; the 7 interior points are m_k = (8 − k)·a + k·b exact in K = ℚ(√3, √5), normalised by intervals (|m_k|² exact, enclosed at P + 16 bits, square root and quotient rounded outward, rescaled outward to P = 96), and counted like every other drawn point. Free (α, θ) steps stay straight chords, and the card says "chords, not arcs".

## 7. Card state (display only)

One new card dial: `S.teeth` (the tooth-events toggle, default on). `FVPenCards.PREC.minPlaces` (default 6) is exposed only so that the browser check can exercise the doubling and its cap; no stream of the card needs a doubling at the starting P.
