# SCHEMA ADDENDUM 25 (v0.4.18, 2026-10-31): group E "Surface pens (exact)", the Goldbach stream, and the group-D fix-ups

No change to the state schema (`fv-comb-hopf-state/0.2`), the exact export, the Lift JSON, the address id (`fv-comb-hopf/0.2`), the PNG export or any readout of an existing state. The two new cards hold their own dials in `instruments/comb-hopf/panel-pens.js` (global `FVPenCards.S`); they read nothing from the host model and write nothing (panel rule R9). saphir: **"No floating point"**.

## 1. Registers

| Register | What lives there | Where |
|---|---|---|
| **Exact** | Signs s_t ∈ {+1, −1}; Uint8 CA bit rows; xorshift32 states (BigInt in [0, 2³²)); integer lattice positions and the heading in ℤ/4; octahedron flags (x, v), integer unit vectors; the field F = ℚ(√2, √5, τ), τ² = √5 − 1, degree 8, with F[i] and SU(1,1) over F; the field K = ℚ(√3, √5), degree 4; finite permutation groups (closure under the moves). | `pen-streams-core.js`, `field-q2-q5-tau.js`, `pen-curvature-core.js`, `pen-sphere-core.js` |
| **Guaranteed numerical** | Intervals [lo, hi]·2^−P of BigInt with outward rounding (`pen-interval-core.js`): π by Machin; cos and sin of rational turns by an outward-rounded series after an exact quadrant reduction; ln by atanh series; square roots by isqrt. The disk: interval products of exact 64-step chunk products, with a shared power-of-two exponent. The sphere: balls (a rounded midpoint frame and a rigorous Frobenius radius, growing linearly in T). | same files |
| **Drawing** | Integer canvas pixels obtained from the enclosures by BigInt division, handed to canvas by the one helper `px` (BigInt → Number). A drawn point whose enclosure is wider than ¼ pixel is counted in "pixels not certified: n" (expected 0). | `panel-pens.js` |

The octahedron display rotation is exact: the integer quaternion (7, 3, −2, −1), normalised by its integer norm 63. Great-circle arcs between octahedron vertices use the rational points ((16 − k²)/(16 + k²), 8k/(16 + k²)), k = 0 … 4. The trail lift 1 + λ·t/T is rational and is a drawing device only.

## 2. Streams (exact)

- **Rule 30 / Rule 150**, from a single black cell; s_t = −1 when x_t(0) ⊕ x_t(1) = 1, else +1 (the skeleton's `caSigns`). Tooth events (Rule 30): q = r = 1.
- **Fair coin**: xorshift32 (13, 17, 5), s = +1 on an odd state (the skeleton's `coinSigns`), seed 1 … 2³² − 1.
- **Goldbach shell N** (even, 4 … 1,448): the prime-pair mask of `goldbach-core.js` (v0.4.14, addendum 22 item 2), read unchanged. One sign per tooth of the shell's comb (m teeth): +1 when N/2 ± c·t₂ are both prime (the equal pair at c = 0 included), −1 when ghosted. Order: c = 0 first, then |c| = 1, 2, 3, … with +c before −c. Exact readouts: g(N) = #P_N, #+ = 2g(N) − δ (δ = 1 when N/2 is prime: the equal pair counted once), net turning (#+ − #−)·90°. Guard for g(N) = 0 (unreachable for 4 ≤ N ≤ 1,448).
- **Goldbach run to N_max**: the shells 4, 6, …, N_max concatenated in order; the shell boundaries are tick marks on the strips, not signs. N_max = 1,448 gives 257,430 signs.
- Printed guards: "The pen draws the prime-pair mask; it proves nothing about Goldbach." and "Closure reaches conjugation, not Goldbach." The bias toward − is stated as a drawing-register observation only.

## 3. Pens

- **k = 0, lattice {4,4}:** exact integers (the skeleton's `planePen`).
- **k = +1, octahedron {3,4}:** exact flags (the skeleton's `spherePen`). The two moves generate A₄ (order 12, computed by closure); a start flag has an orbit of 12 of the 24 flags.
- **k = −1, Poincaré disk {5,4}:** one step M = R(±90°)·T(ℓ), cosh(ℓ/2) = (√2 + √10)/4, sinh(ℓ/2) = τ/2. Exact over F[i] for T ≤ 64. Longer runs: exact products of 64 steps (integer matrices over 4^j), multiplied as intervals, P = 128 + 8 bits per chunk join (doubled if the distance shows fewer than 6 guaranteed places). Follow the pen: frames Q_j = g_u⁻¹ g_(u−j), the last W steps. Distance: cosh d = |a|² + |b|² (= (1 + |z|²)/(1 − |z|²), since |a|² − |b|² = 1 exactly), d = log(cosh d + √(cosh² d − 1)), both as intervals. Edges are drawn through tanh(kℓ/8), k = 0 … 4. Cap: 4,096 steps, with a visible label.
- **Squeezed sphere:** θ = k/24 turn, α = j/96 turn (ball register, 96 bits), or the dodecahedron preset θ = 60°, cos α = √5/3 (exact in K). Coverage: 432 equal-area cells; a point whose enclosure meets a cell boundary is counted as "uncertain". Cap: 4,096 steps, with a visible label.

## 4. Card state (display only)

`FVPenCards.S = {stream, T, seed, N, Nmax, follow, W, lam, preset, a, th}`; BigInt for every number. Defaults: Rule 30, T = 512, seed 1, N = 24, N_max = 100, follow on, W = 200, λ = 15/100, preset free, α = 3/96, θ = 2/24. Not in the address, the exports or the PNG.

## 5. Group D fix-ups (v0.4.17 verify report)

Heading "D. Elliptic and BSD"; stacked case blocks; the scatter zoom `S.zoom` ∈ {1, 2, 4} with the window origin `S.wx`, `S.wy` (card state of `panel-elliptic.js`, display only); minimum dot 3 px; P1 = P2 offset outline; "ν (nu)"; U+2212 in the refused Δ; the reduction label "additive" for additive reduction.
