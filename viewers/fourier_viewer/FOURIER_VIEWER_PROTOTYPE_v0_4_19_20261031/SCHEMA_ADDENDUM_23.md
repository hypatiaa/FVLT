# SCHEMA ADDENDUM 23 (v0.4.16, 2026-10-28): D1, the Rule 30 ladder-monodromy card (Clifford tab, display only)

No change to the state schema (`fv-comb-hopf-state/0.2`), the exact export, the Lift JSON, the address id (`fv-comb-hopf/0.2`) or any readout of an existing state. The card's state lives in the view string (the drawing register) only. Brief: `FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028_BRIEF/BUILD_BRIEF_v0_4_16_RULE30_D1.md`; scope: `RULE30_SURFACES_VIEWER_TRACK_REPLY_v0_1_20261028.md` §1–2 (D1 only; D2 and D3 are not in scope). v0.4.15 is skipped: that number is reserved for the held scene-model / Landau design. The idea of writing Rule 30 on surfaces is saphir's; the exact facts F1–F3 come from the rule30 track and its kit.

## 1. Module

`host-core/rule30-ladder-core.js` (fv-rule30-ladder-core 0.1.0, global `FVRule30Ladder`). EXACT register: integers only, BigInt for the state x (bits 0 … 34 are carried, x mod 2^35), plain integers for t, N, per, S (all below 2^16 here). No DOM and no float token (checked lexically by the test).

- T-functions on the seed x(0) = 1: rule 30 F(x) = x ⊕ ((x≪1) ∨ (x≪2)); rule 90 F(x) = x ⊕ (x≪2); rule 150 F(x) = x ⊕ (x≪1) ⊕ (x≪2). Bit j of x(t) is A(j, t).
- Events: ψ_j(s) = x_{j−1} ∨ x_{j−2} (30), x_{j−2} (90), x_{j−1} ⊕ x_{j−2} (150); negative indices are 0. N_j(t) = #{s < t : ψ_j(s) = 1}.
- per_n = length of the orbit of 1 mod 2^n (per_0 = 1). Base cycle of row j = per_j. S_j = N_j(per_j). The table build **throws** if lift_iff (per_{j+1} = 2·per_j iff S_j odd, else per_{j+1} = per_j) fails for any j ≤ 34.
- Exports: `step, table, orbit, perN, A, psi, N, S, doublingSet, kTurns, gcd, ones, curve, card`, constants `RULES = [30, 90, 150]`, `J_MAX = 34`, `QS = [1, 2, 4, 8]`.
- `kTurns(q, S_j) = q / gcd(q, S_j)` (gcd(q, 0) = q, so S_j = 0 gives k = 1).
- `curve(rule, j, q, {sub})`: points for t = 0 … k·per_j, each base step cut into `sub` equal parts; point i/sub of step t is `{base: [num, den], fibre: [num, den], event, t}` with base = (t + i/sub)/per_j and fibre = (N_j(t) + ψ_j(t)·i/sub)/q, both **reduced rationals of a turn**. The last point is (k, k·S_j/q), integers: the closure.
- `card(rule, j, q)`: `{per, perNext, S, k, odd, monodromy, doubling, density, fibreTotal, label, degenerate[]}`; label = "row j, rule R, q = q: S_j = …, closes after k turn(s)"; monodromy = "monodromy nontrivial" (S_j odd) or "trivial (stall)" (S_j even).

## 2. View state (Clifford view keys; defaults are not written to the address)

| key | default | values | meaning |
|---|---|---|---|
| `rl` | `0` | `0`, `1` | D1 card on; while on, the Clifford tab draws D1 instead of the comb picture (the comb state is kept, not drawn) |
| `rlr` | `30` | `30`, `90`, `150` | rule |
| `rlj` | `3` | integer 0 … 34 | row j |
| `rlq` | `2` | `1`, `2`, `4`, `8` | lift dial q |

Example address tail: `…&tab=clifford&view=rl%3D1%3Brlj%3D5` (the view string is percent-encoded by comb-core, as for every view key). A value outside its range is **refused with a label** ("D1 dial refused: …") and the default is drawn; nothing else in the address is affected. The keys are ignored by the Fourier, Hopf and Panels tabs.

## 3. Drawing (one torus leaf, the declared lift rule)

- Leaf: the Clifford torus |z₁| = |z₂| = 1/√2 (ρ = 1), z₁ = (1/√2)e^{i·base}, z₂ = (1/√2)e^{i·fibre}, projected stereographically from x₄ = +1 like every Clifford drawing (the pole is not on this leaf).
- Base angle 2π·t/per_j (per_j = the cycle of the rows below j, mod 2^j); fibre angle 2π·N_j(t)/q; drawn for t = 0 … k·per_j.
- **Declared lift rule.** Within a base step t → t+1 the base angle advances by 2π/per_j. If ψ_j(t) = 1 the fibre advances monotonically forward by 2π/q across that same step, linearly in the step parameter; otherwise the fibre is constant. Never backwards, never the short way round: the drawn curve is the lift of N_j, not its shadow mod 2.
- sub = ⌈720/per_j⌉ (at least 1): at least 720 drawn points per base turn. The rationals become floats only in the view (angles, stereographic projection, canvas).
- Marks: event steps amber, non-event steps cyan; dashed grey = the base circle (fibre 0); dotted violet = the fibre circle at base angle 0; violet rings = the returns to base angle 0 after i = 0 … k base cycles (fibre i·S_j/q turns), the white ring is t = 0 (= the closure at i = k). Integer-t sample dots only when k·per_j ≤ 128.
- Degenerate cases, drawn and labelled (caption, role `degenerate`, and the card): q = 1 "fibre constant (q = 1)" (see §5); S_j = 0 "no events over the base cycle, so the curve is a pure base circle"; j = 0 "per_0 = 1 and ψ_0 ≡ 0"; a row of density 0 over per_{j+1} (rule 90 odd rows).

## 4. The card (cards column, Clifford tab, D1 on only)

Exact register: the T-function, ψ_j, per_j, S_j (parity), per_{j+1} (doubling / stall), the monodromy line, q, k, the fibre at base angle 0 after i base cycles (exact, turns mod 1), the density of row j over per_{j+1}, F1 checked live for every t < per_35, the doubling set j ≤ 34, the label, the degenerate labels, a table t / A(j,t) / ψ_j(t) / N_j(t) for t < min(per_{j+1}, 16), the declared lift rule and the not-claimed line.

SVG data element for checks: `<g data-role="r30-curve" data-rule data-j data-q data-per data-s data-k data-steps data-sub data-n data-event-segments data-base-segments data-end-base data-end-fibre>`; `<g data-role="r30-turns" data-n data-k>`; `r30-samples`, `r30-turn` marks in `FVViews.layerMarks()`.

## 5. Stated choices

1. **q = 1.** The brief asks for the label "fibre constant (q = 1)" and also for the lift rule "fibre advances by 2π/q on an event". At q = 1 these differ: the sampled fibre N_j(t)/1 is 0 mod 1 at every integer t, but the lift rule draws each event as one full forward fibre loop (2π). The build follows the lift rule (the curve is the lift of N, not its shadow) and labels both facts: "fibre constant (q = 1): the sampled fibre N_j(t)/1 is 0 mod 1 at every t; the declared lift still draws each event as one full forward fibre loop (2π/q = 2π)". Left open for the track owner.
2. Base on z₁, fibre on z₂ (the comb's carrier / offset convention).
3. While D1 is on, the Layers menu shows only the D1 items, Tρ leaf (the torus mesh) and the camera; the comb layer items and branch chips are hidden; they return unchanged when D1 is switched off.
4. Exports (JSON, state, CSV, Lift JSON, pair) do not carry D1; the PNG export captures the D1 picture; the address carries the view keys.

## 6. Not claimed

D1 displays F2 and F3 (the monodromy of the lifted rows). It is not evidence about the centre column, and nothing here concerns Problems 1 or 2.
