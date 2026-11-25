# SCHEMA ADDENDUM 15: comb-hopf v0.4.7, alpha_Tilt as a walk weight (2026-10-20)

**Status:** builder's record, additive successor of v0.4.6. Not reviewed yet.
**Credits:** saphir: the request and the decisions Q1 to Q7 ("go with your leans"). Design note `FOURIER_VIEWER_ATILT_DESIGN_NOTE_v0_1_20261020/NOTE.md` (sha256 b7e811289784e1fc1b13028f075ca442c637e659555d9570babb28f32b12814b): the specification. Claude Sonnet 5.5: v0.4.7.
**Amends:** nothing. At alpha_Tilt = 0 every output of v0.4.6 is byte-identical.

## 1. Standing (kernel)
alpha_Tilt is a kernel parameter (notation w_k = k^alpha_Tilt, walk weight at step k; cited at kernel v3.2.7, locked, where the alpha_Tilt items are unchanged from v3.2.6). The comb walk for m >= 3 is outside the kernel, so the viewer's tilted walk is an instrument-tier use with no theorem standing. The dial's about text, the Fourier and Hopf captions and the exact export say so. Helix, Circle and Spiral are preset names only (Rmk 9.4a, empirical, observed on the Explorer walk); no regime label is shown (Q5). Nothing here is built on Def 5.2 (erratum W1, in kernel v3.2.7 (locked)). The kernel's unresolved referents (Rmk 5.1a, Def 5.1b, Rmk 5.4b have no body) and the L1443 / VII.8 tension are not used by the viewer.

## 2. The weight (Q1, Q2, Q6)
Walk step t = 1 ... m, in the existing ascending offset order, is weighted w_t = t^alpha_Tilt: W_t = W_{t-1} + w_t * z_{c_t}. w_1 = 1, so W_1 = z_{c_1} at every tilt. Only the walk is weighted: the drawn teeth z_c are unchanged. Walk order is fixed (no reversed order).
- alpha_Tilt = 0: the code path is the v0.4.6 path (no multiplication by 1).
- all-aligned (q = 1): the walk is a segment on the ray of z_{c_1} at every tilt.
- m = 2: W_2 = z_{-1} + 2^alpha_Tilt z_{+1}; not the Vernier sum of II.5 (labelled).

## 3. State and address (Q3)
Optional state field `tilt`: canonical exact rational text, range [-1, 1]. Absent means 0; 0 is never stored or written. `comb-core.js` keeps `ADDRESS_KEYS` unchanged (tilt is a separate optional key). The address id stays `fv-comb-hopf/0.2`.
- Writing: `...&view=<view>&tilt=-1/2`, then (when CA mode is on) `&ca=1`. Example key: `tilt=-1/2`.
- Reading: absent = 0. `tilt=0`, a non-canonical value (`2/4`), a value outside [-1, 1], or a repeated `tilt` refuses the whole state with the reason. A v0.4.6 reader refuses a tilt address visibly ("Unknown key tilt.").
- `resolve()` returns `tilt` (exact rational, 0 when absent). State JSON and exact JSON carry `tilt` only when nonzero.

## 4. Exactness
- The input is an exact rational (slider two decimals read exactly: 0.37 is 37/100).
- Integer tilt (-1, 0, 1): weights are exact rationals (t, 1, 1/t); the exact export lists them with `register: "exact"`. The viewer has no exact walk readout, so the drawn walk is float64 as before.
- Fractional tilt p/q: t^(p/q) is irrational in general; the export lists the weights as `numerical ...` with `register: "numerical"`, and the cyclotomic note gains "with alpha_Tilt = p/q not an integer, walk values also need the radicals j^(p/q) (j <= m), so they are numerical".
- Nothing exact changes: phases, ALIGN, SPREAD, pair and all-aligned flags, the star key, Wilson, gearbox, shells, divisors, cyclotomic orders and field values, stops (R20), s_eff and E (R21), the wrap gate, the Lift JSON, the fraction stack.
- Numerical bound (README states it): at tilt != 0, bound = 8 (m + 2 + |alpha|(1 + |ln N|) + |alpha_Tilt|(1 + ln m)) eps max(rho w_max, 1), w_max = m^alpha_Tilt for alpha_Tilt > 0 and 1 otherwise; at 0 it is the v0.4.6 formula.

## 5. Per view
- Fourier: walk polyline, vertices, endpoint change. Teeth, carrier, polygons, radius circle, grid and the mirror-axis line do not. Captions at tilt != 0: the star reads "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general"; the mirror-axis about gains "(teeth only; the tilted walk is not mirror-symmetric.)"; a tilt line (role `tilt`) and, at m = 2, the Vernier line (role `tilt-m2`); the numerical-register about gives the tilted bound.
- Hopf base: walk curve and vertices change; tooth dots, latitude circle, trails, selection, chart agreement and the gate do not.
- Clifford: unchanged (SVG and canvas identical); one about line "α_Tilt does not apply here", and the visible dial says so on that tab.
- Panels: the numerical rows (|W|, |W|/ρ, Q-res, gate residual) change in value; the lab-frame row reads "pair phases conjugate (t₁·s ∈ ℤ, exact); tilted walk not real in general"; the carrier-relative row gains "(teeth only; the tilted walk is not mirror-symmetric)" and its value is the tilted walk's (nonzero in general: a departure from the note's card list, which did not name this row); a new row "α_Tilt (walk weight t^α_Tilt)"; the Phasors card note gains the radicals sentence for a fractional tilt; Copy formula appends "W_t = sum_{j<=t} j^tilt * z_{c_j} (walk order), tilt = x". G. Robin: unchanged (`panel-g-robin.js` untouched).

## 6. Controls (Q4)
Second, separately labelled dial inside the α drawer: "α_Tilt (walk weight t^α_Tilt)", with ◀ ▶ (step 1/10, clamped to ±1), an exact box, presets "−1 Helix", "0 Circle", "+1 Spiral", a slider −1 ... 1 (step 0.01, read exactly) and an ⓘ. The α chip reads "α 1" at tilt 0 and "α 1 · tilt -1/2" otherwise. No chip is added: counts stay 41 (n! base) / 39 (integer) / 39 (CA) / 41 (continuous) with the drawers closed. The first row keeps its label "α" (unchanged from v0.4.6) so tilt-0 pages stay identical; the two rows are separately labelled.
