# Divisor comb · Fourier instrument — prototype v0.4.11 (reciprocal winding (throat at 1/1), the other half of the full stack), additive successor of v0.4.10 (two Panels cards: branch primitivity by trial division and the Poincaré disk with Astra's divisor orbit; the "shells n² + 1" track), additive successor of v0.4.9 (full stack and fraction stack from the old FVLT monodromy instrument, with full exact α), additive successor of v0.4.8 (shorter tilt wording in the Fourier caption), additive successor of v0.4.7 (alpha_Tilt as a walk weight, second dial in the alpha drawer), additive successor of v0.4.6 (n1 group hidden in integer mode, integer base 39 controls), v0.4.5 (CA mode in the page address, control cap 41), v0.4.4 (colossally abundant preset track, rebuilt G. Robin margin card), v0.4.3 (full-resolution wireframe while the camera moves), v0.4.2 (N = 0 Wilson wording, shell-switch clamp to N = 1), v0.4.1 (shell range, ★, carrier foliation), v0.4 (mirror axis) and v0.3 step 1 (continuous N, option B), built on v0.2 Release A

Source folder for `dist/comb-hopf.html`. One shared state drives four tabs: **Fourier | Clifford | Hopf base | Panels**. Not a release, not an R18 parity claim, no review status. The frozen references are read-only.

## Registers

- **Exact** (`exact-lib/exact-lib-0.2.0.js` (shared library, inlined; `exact.js` 0.1 is history), `host-core/comb-core.js`, `gearbox-core.js`, `shell-core.js`, `fraction-stack-core.js`): BigInt rationals. Every exact statement (phases, orders, flags, stops, gearbox, Wilson, divisors, contrast, lattice) comes from here. No epsilon anywhere in stop selection.
- **Numerical** (`host-core/comb-numeric.js`): floats with a stated bound. Tooth/partial-sum bound = `8·(m + 2 + |α|(1 + |ln N|))·ε·max(ρ,1)`, ε = 2⁻⁵² (v0.3: N is the float of the exact rational N; |ln N| = ln N on every shell, so the bound is unchanged there). Hopf-sphere values carry `2·bound/scale`. Every numerical value is labelled "numerical" where shown.
- **Drawing** (`instruments/comb-hopf/view-*.js`, `panel.js`): screen coordinates, rotation, cos/sin for display only. Camera and layer state is drawing register: it travels in the URL address (`view` key) and is excluded from the exact export.

## Dial ledger

Every control, where it enters. "Exact" = drives exact core; "address" = part of the URL fragment `#v=fv-comb-hopf/0.2&…` (the address schema; v0.3 reads a 0.1 address as `nMode = integer`, the only upgrade rule, SCHEMA_ADDENDUM_8 §9).

| Control | Sets | Enters |
|---|---|---|
| Shell base `n!` / `integer` | `shellMode` | B (n₁! or integer M); N = B + 1 − φ₃. Exact, address |
| n₁: one select with ◀ ▶ (same at every width; greyed in integer mode) | `n1` | B in factorial mode; gearbox Wilson eligibility. Exact, address |
| M box (visible only in `integer` mode; Enter applies, no Apply button) | `B`, `shellMode = integer` | B. Exact, address |
| (v0.2) Presets/Continuous switch | removed: every dial is one chip "label ◀ exact box ▶"; presets, slider and delta live in that dial's drawer | nothing |
| α chip (one button "α value") → drawer: ◀ exact box ▶, −1/0/+1, slider −8…8 | `alpha` | ρ = n₆·N^α (numerical); Hopf latitude; Clifford leaf; orbits. Address |
| n₆ chip (one button) → drawer: ◀ exact box ▶, −1/0/+1, slider −8…8 | `n6` | ρ, sign of the carrier (+π when n₆ < 0). Address |
| t₁: ◀ chip ▶ stay beside the chip; the chip opens a drawer with the exact box, Δ, slider −100…100 | `t1` | k_c = N·t₁ + c·t₂; ALIGN stops; wrap gate. Exact, address |
| Δ selector (t₁, t₂) | none | step size of ◀ ▶ only (not in the address) |
| t₂: ◀ chip ▶ beside the chip; drawer with the exact box, Δ, slider | `t2` | k_c; SPREAD stops and flag; offset phase; divisors; fraction lattice. Exact, address |
| m chip (button "m value") → drawer: ◀ exact box ▶, slider 2…720, ⓘ (register line) | `m` | tooth set, stop families, gearbox. Exact, address |
| φ₃ slider, ◀ ▶, ← → | `phi3` | N. ◀ means N − 1, ▶ means N + 1. Exact, address. v0.3: in continuous mode ◀ ▶ snap to the next integer shell in their direction and the slider steps 1/100 of a shell (rows below) |
| (v0.3) N mode switch `N∈ℤ` / `N∈ℚ` (one toggle button, `aria-pressed` = continuous, in the φ₃ row) | `nMode` | integer: φ₃ an integer (as before). continuous: φ₃ an exact rational, N = B + 1 − φ₃ rational. continuous → integer with a non-integer φ₃ rounds to the nearest shell (tie j + 1/2 → j + 1) and says so in the message line; integer → continuous changes no value. Exact, address |
| (v0.3) φ₃ exact box (continuous mode only, beside the label; Enter applies) **(amended 2026-10-14, step 2, saphir F1: the box is no longer on the row; it is in the φ₃ drawer, next row)** | `phi3` | decimal or fraction (`7/2`, `3.5`), stored as canonical exact text; refused with the reason outside 0 … B+1. Exact, address |
| (v0.3 step 2) φ₃ chip "φ₃ value" (one button, the row's label) → φ₃ drawer under the row: ◀ exact box ▶ and a range line; both modes | `phi3` | continuous mode: decimal or fraction; integer mode: integers only, a fraction is refused with "N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions"; outside 0 … B+1 refused with the reason; Enter applies. The drawer's ◀ ▶ are the row's shell steps (◀ = N − 1, ▶ = N + 1). One drawer at a time (gear dials and φ₃). Exact, address |
| (v0.3) φ₃ slider in continuous mode | `phi3` | step 1/100 of a shell (declared); the slider's two-decimal value is read exactly (12.37 → 1237/100); finer values by the box. Integer shells are marked on the track (dim marks) when B + 1 ≤ 1000. Exact, address |
| s slider | typed entry of the slider's exact decimal | `sTyped`, `sEff`, `E` |
| s ◀ ▶, Shift+← / → | R20 stepper | nearest stop in the direction; commits `sTyped = sEff`, keeps `E`. Refusal / no movement change nothing |
| Set s + text | typed entry (decimal, fraction, product with `*`) | `sTyped`, then `sEff` (wrap mod 2N only when exactly invariant), then `E` |
| Play ▶ s | typed entry `sEff + speed/120` per tick | as typed entry; labelled "animated (exact increments)" |
| Play ▶ N | dial change, φ₃ + 1 per tick (integer mode); φ₃ + 1/100 per tick (continuous mode, one slider step) | N; stops at N = 0 |
| Speed ½× 1× 2× | none | play rate only |
| Tabs | `tab` | which window is shown; **never changes any setting**. In the address, not in the exact export |
| Chart toggle (Hopf toolbar) | `chart` | Hopf walk chart: host `w = W` (default) or comb-page `w = W/ρ`. Does not touch spin |
| View buttons (zoom, pan, reset, lock, camera presets) | `view` | drawing only; address, not exact export |
| Layer toggles: Teeth, Walk, Amber polygon, ÷ Divisors, Tρ leaf, s-orbits, Grid, Four circles, Fraction stack | `view` | drawing only. ÷ Divisors also shows the Divisors card and marks the φ₃ track |
| Order-m witness p (Enter applies; no Test button) + Hide | none (local) | the p-gon on the Fourier view; Wilson card; exact JSON `orderWitness`. Hidden whenever the shell (n₁!, or integer B) changes; press Enter in the p box again |
| Import state (paste) + Load | replaces the whole state | same R21.5 validation as a URL load: refused as a whole with the reason (defaults shown as a new state), or restored exactly (`sEff` as stored) |
| ✥ pan (Clifford) | `view` (`cp`) | one-finger drag pans instead of rotating (Shift + drag still pans); drawing only |
| ⛶ fullscreen (Fourier, Clifford, Hopf) | none (local) | Fullscreen API on the view frame (webkit prefix fallback); without it a CSS maximised view with a Close button (Esc also closes) |
| Tooth tap / table row | none (local) | highlights one tooth in all views |
| Text size A− / A+ | none (localStorage, `fv-comb-hopf-text-scale`) | whole page via `--scale`; not in any export |
| ⓘ (per view / per card) | none (local) | shows or hides provenance notes |
| Exports | — | see below |

Dials that enter **nothing** (listed on purpose): Δ selectors, speed buttons, the Panels tab's cards (placeholders), `n₁` while `integer` base is on (B comes from M; n₁ still feeds the gearbox Wilson eligibility check only).

## Spin address

`sTyped` is the last committed spin and alone drives the walk and every exact readout. `sEff` is the derived representative (wrap mod 2N into (−N, N]) used for the slider, the range and as the start of a step. The wrap applies **only** when it is exactly invariant: N > 0 and, for every drawn tooth, `k_c`, `N·t₁` and `c·t₂` are all integers (the S³ lift is drawn on the Clifford tab). The gate is decided over the drawn objects, never over the active tab. `E = max(N, |sEff|)`, recomputed on typed entry, N change and any dial change that re-derives `sEff`, never by a step. A state that fails validation on load is refused as a whole.

## Stepping (exact)

Families: ALIGN `t₁·s ∈ ℤ`; SPREAD (odd m: numerators `2N|t₁|r`, even m: `N|t₁|k`, over `m|t₁||t₂|`); PAIR (m = 2) the integer lattice ℤ, with its own guard (see **Declared PAIR guard** below). Comb mode with a non-integer gear, t₁ = 0, t₂ = 0 or N ≤ 0 is **refused (4e)** with the reason; there is no integer-snap fallback. ALIGN wins ties; coincident families are reported. No stepping wrap. No size limit is declared (BigInt throughout).

**v0.3, between shells (N = p/q not an integer):** SPREAD stops need an integer gearbox, so in comb mode the SPREAD families are **refused (4e)** with the reason "SPREAD needs an integer gearbox: N = p/q", never approximated; ALIGN stays active and ◀ ▶ land on ALIGN stops. The refusal is shown in the s row before any press ("SPREAD refused (4e): …"), carried in the step record (`refused`) and appended to the step label. **(Amended 2026-10-14, step 2, saphir F2:** the refusal line is no longer permanently under the view; it appears in the s-row stepper message when a step is made, where the other 4e refusals are shown, and in the s ⓘ text; the step record and label are unchanged.) PAIR (m = 2) works as before. The R21 wrap gate uses the same rule over the rational N (wrap by 2N only when every drawn k_c, N·t₁ and c·t₂ is an integer); with rational N it usually closes: s_eff = s_typed, "kept: wrap not invariant here".

### Declared PAIR guard (R20.2: "PAIR declares its own guards")

**Owner decision, 2026-10-13:** PAIR (m = 2) stepping uses the integer lattice ℤ and is active whenever N > 0, whatever t₁ and t₂ are (including 0 and non-integer gears). It is refused only at N ≤ 0 (4e). The guards of the comb mode (integer t₁, t₂, both nonzero) do not apply to PAIR. This replaces the earlier "chosen reading"; behaviour is unchanged.

## Degenerate cases (drawn and labelled, never hidden)

N = 0 (empty state, no walk, no lift); ρ = 0 (all vertices at the south pole / origin; the Clifford leaf collapses to the circle z₁ = 0, which passes through the projection pole x₄ = +1, so its stereographic image is the x₃ axis, a line through the origin closed at ∞; drawn as that axis and labelled; the leaf mesh is not drawn); n₆ ≠ 0 with ρ underflowing to 0 (refused with the reason); non-finite numerical walk (refused); stepping unavailable (reason shown, 4e); stationary teeth (N·t₁ = 0 and c·t₂ = 0: no trail, no orbit); base-fixed teeth (k_c = 0 with a nonzero lifted rate: no base trail, S³ orbit drawn along the fiber) (corrected 2026-10-14); Clifford points AT_INFINITY / CLIPPED_NEAR_POLE (counted and labelled); fraction stack idle (reason shown); divisors: s = 0 or t₂ = 0, t₂·s ∉ ℤ, size-limit refusal above 10¹⁸.

**v0.3, between shells.** When N = p/q is not an integer (continuous mode), the shell arithmetic is undefined and every integer-only readout is switched off with one label, verbatim: "between shells: N = p/q; shell arithmetic undefined". It is on every tab's warning line (role `degenerate`, never ellipsized) **(amended 2026-10-14, step 2, saphir F2: the warning line carries the short form "between shells: shell arithmetic undefined", one line at 375 px; the fraction is in the shell readout "N = p/q" and the full wording stays in every card and record listed here)** and replaces the values of the Wilson card (shell-N test, order-m witness, gearbox rows; gearbox code `BETWEEN_SHELLS`), the Divisors card, the Shell card (contrast and bracket), the fraction stack (idle) and the Lift JSON integrality gate (`integral_frequencies`: `NOT_EVALUATED`, reason = the label). Continuous N is the variable moved along at fixed s, not a new arithmetic object: it recovers ratios of shells, not k. The phasor table, the exact flags, the field line, the orbits and the S³ lift keep working with exact fractions; long rational closure periods are drawn as a partial window and the exact period stays in the record. N = 0 (φ₃ = B + 1 exactly) is the empty state as before.

## Exports

Export JSON (canonical exact, schema `fv-comb-hopf/0.2` since v0.3, includes `liveFormula`, tooth set, gearbox, Wilson, shell, divisors, and (v0.3) `nMode`, `N` as exact text, `N_integer`, `betweenShells`; excludes tab and view), Export state (canonical state address, `fv-comb-hopf-state/0.2`, `nMode` inside `state`), Export CSV, Copy Stats, Export Lift JSON (`fv-comb-hopf-lift/0.3` since v0.3, adds `nMode`, `N`, `N_integer`; earlier `fv-comb-hopf-lift/0.2`: branches, `cyclotomic_field`, computed `gates`: exact_rational_lift, closed_orbits, integral_frequencies PASS/FAIL; prime_pair SEPARATE_GATE; rank4_smith_monodromy OUT_OF_SCOPE; the comparable host format is `fvlt-plane-clifford-lift-v2`, the host's schema ids are not reused), Export PNG (active drawing tab, 2× canvas, serialised SVG with literal colours, caption lines drawn under the picture), Export pair (PNG + exact JSON + state + a pair JSON naming all three SHA-256; `fv-comb-hopf-pair/0.2` since v0.3). Every export shows its SHA-256. Filenames: `fvlt_fourier_<tab>_m<m>_<shellTag>_s<s>_<stateHash8>.<ext>`.

## Primality method

Deterministic Miller–Rabin with the first 13 primes as bases (proven for n < 3.3·10²⁴) after trial division by those primes; Pollard rho (Brent-style cycle) for factorisation, every factorisation verified by multiplication. Shell-N Wilson readout is evaluated for N ≤ 10,000 by direct product.

## Class (a) differences from the frozen host / v0.3.2 (mandated by the requirements)

- Integer-snap fallback removed: refused with a reason (R20.2/4e).
- Typed-entry wrap applied only when exactly invariant, `s_typed` kept (R21); the range is not recomputed by a step.
- Divisors: exact `t₂·s/N′ ∈ ℤ`; the host's `round(s)` integer shadow is not used.
- Contrast: exact rational from exact totients (host: float).

## Out of scope / deferred (as of v0.2 Release A)

- Rank-4 monodromy: separate future viewer (saphir, 2026-10-13).
- Fourier tab: rosette (about 520K dots), full stack, stems, dots, stack α, pinch markers, the "contrast" overlay beyond the exact value line, noise-minima markers and the trail (the host `buildTrail` port was not attempted; both deferred).
- Clifford tab: Hopf and opposite weaves with Fill and Play, the S³ leaf sweep (η), the slice grid (the Clifford orbit-branch filter is built: chips under Layers → Advanced, one All / None toggle). The four circles are one reading (meridian, parallel, Hopf, opposite circle on the leaf) since the addendum gives colours and widths only.
- Gearbox: the host's M−/M+ rows, theorem guard, joint degeneracy.
- Panels tab: all 17 cards are placeholders (no panel mathematics). The Alpöge rank-4 card is excluded.
- Offline certificate verifier (only the exact export exists).
- Gearbox "current comb order" wording (`matches shell p` / `shell successor is n₁+1`) is the builder's reading of the host phrase.

## v0.2 Release A (addendum 6): layout and dial ledger additions

Order: header (title + formula line) → shell row → gearbox chips (α, n₆, t₁, t₂, m) → view row → caption line → view → strip (Layers, Camera, + − ⟲, ⛶, ⓘ) → φ₃ row (⏮ start, ◀ slider ▶) → s row (◀ slider ▶, set-s box, ⓘ) → transport (▶ N, ▶ s, speed) → Export ▾ (PNG one tap). Cards: right column (380 px) on desktop, below on a phone.

New or changed dials, all accounted for:
| Dial | Enters | Notes |
|---|---|---|
| α, n₆ drawer ◀ ▶ | exact state (alpha, n6) | step ±1 inside the drawer (no chip arrows); the box takes any rational; the drawer holds −1/0/+1 and the −8…8 slider |
| t₁, t₂ ◀ ▶ beside the chip | exact state | step ±Δ (Δ-select in the drawer, default 1/4 and 1/2 as before); drawer slider −100…100 |
| m drawer ◀ ▶ | exact state | step ±1 inside the drawer (no chip arrows); drawer slider 2…720; the box reaches every m |
| n₁ select with ◀ ▶ (every width) | exact state | greyed in integer mode |
| M box | exact state | only visible in integer mode; Enter applies |
| ⏮ start | exact state (φ₃ = B, N = 1) | the old Reset |
| set-s box | typed s (R21) | Enter applies; s_eff and E shown only when they differ or E is widened beyond N |
| Layers / Camera menus, Guides, Camera select, View-from select, tooth-trails switch | view key (address only) | the branch chips are under Layers → Advanced; All / None is one toggle |
| Wilson card: m = n₁+1, g = 0 | exact state (m; φ₃ = 0) | g = 0 is the reading φ₃ = 0 (INFERRED) |
| Copy formula | nothing | copies z_c = n6*N^alpha*exp(i*k_c*s*pi/N), k_c = N*t1 + c*t2, and the current values |
| Text size A− / A+ | nothing (localStorage) | 100–160 %; every font-size is wrapped in max(13px, …); SVG text is sized from the rendered scale by CSS (`--svgk`) |

Cyclotomic readout: "generated by the phase factors ℚ(ζ_L)" (the field generated by e^{iπ·k_c·s/N}; where ρ = n₆·N^α is irrational the phasor values may need ℚ(ζ_L, ρ)) and "phase container (convention) ℚ(ζ_C)", C = 2·q·N·L_k (L_k = lcm of the k_c denominators; equals the host's "ambient" ℚ(ζ_{2qN}) when L_k = 1). In the exact JSON (`exact.cyclotomic_field`) and the Lift JSON: `generated`, `phase_container`, `host_ambient_equivalent`.

Not built (owner decisions): pinch markers, float entropy/regime readouts; the noise minima come in Release B.

## v0.2 Release A fix round (addendum 7): dial ledger as it now exists

| Control | Enters |
|---|---|
| Text size A− / A+ and readout (one line) | nothing (localStorage) |
| n! / integer | `shellMode`; exact, address |
| n₁ ◀ select ▶ | `n1`; exact, address |
| M box (integer mode) | `B`; exact, address |
| Shell readout "B = … · N = …" (the only place N is shown) | nothing |
| α, n₆, m chips (button "label value") | open that dial's drawer (drawer state is local) |
| t₁, t₂ ◀ ▶ beside their chips | `t1`, `t2` by ±Δ; exact, address |
| t₁, t₂ chips | open the drawer: exact box, Δ select (step size only), slider |
| α, n₆, m drawers: ◀ ▶, exact box, presets (α, n₆), sliders | `alpha`, `n6`, `m`; exact, address |
| m drawer ⓘ | shows the m register line; nothing else |
| Tabs Fourier / Clifford / Hopf base / Panels | `tab`; never changes a setting |
| Caption line (one line; tap expands the informational line; warnings are never ellipsized) | nothing |
| Layers, Camera menus and their items | `view`; drawing only |
| + − ⟲ ⛶ | `view` / fullscreen; drawing only |
| ⓘ (view, card, s row) | local |
| φ₃ ⏮ ◀ slider ▶ | `phi3` (N); exact, address |
| s ◀ slider ▶, set-s box (Enter), s ⓘ | R20 step / typed entry (R21); exact, address |
| ▶ N, ▶ s, speed | animation; speed enters nothing |
| Export PNG, Export ▾ (JSON, state, CSV, Lift JSON, pair, Copy stats, Copy formula, Import…) | nothing (exports); Import replaces the state under R21.5 |
| Wilson card: candidate p box, Hide, ◀ gear, gear ▶, m = n₁+1, g = 0 | local witness / `m` / `phi3` |
| Phasors card: row tap | local highlight |

Each value is shown once: N in the shell readout only; Q-res and the ALIGN / SPREAD flags in the Fourier caption only; t₂·s/N in the card's flag line only; the K_m kernel and the field definitions sit behind the Phasors ⓘ. The "generated" field is the field generated by the phase factors e^{iπ·k_c·s/N}; where ρ = n₆·N^α is irrational the phasor values may need ℚ(ζ_L, ρ).

## v0.2 Release A fix round 2 (Sol's conditions, owner decisions 2026-10-13)

| Control or line | Behaviour |
|---|---|
| Stationary-teeth and base-fixed-teeth warnings (Clifford, Hopf) (corrected 2026-10-14) | truly stationary (N·t₁ = 0 and c·t₂ = 0): "stationary: c = … (no orbit)" / "(no trail)"; base fixed (k_c = 0, lifted rate nonzero): Hopf "base fixed: c = … (k_c = 0; the fiber moves — see Clifford)", Clifford "base fixed: c = … (k_c = 0; orbit runs along the Hopf fiber)"; on the warning line under the view, full, never ellipsized, never only behind ⓘ |
| s ◀ ▶ when the stop set is inactive | look disabled (`aria-disabled`, dimmed) and a line "stepping unavailable — <reason>" shows in the s row before any press; pressing still gives the R20 refusal and leaves the state unchanged |
| Fourier caption order | ALIGN / SPREAD (with ★) first, Q-res (numerical) last, so the ellipsis on a phone can cut only the numerical tail |

## v0.3 step 1 (SCHEMA_ADDENDUM_8, 2026-10-14): continuous N, dial ledger additions

| Control | Enters |
|---|---|
| N mode switch `N∈ℤ` / `N∈ℚ` (one toggle, `aria-pressed`, end of the φ₃ row) | `nMode`; exact, address. One toggle rather than two buttons: two would make 41 visible controls at the default state (cap 40, ⓘ excluded) |
| φ₃ exact box (continuous mode only; Enter applies) | `phi3` as an exact rational (decimal or fraction); refused with the reason outside 0 … B+1 |
| φ₃ slider (continuous mode) | `phi3` in steps of 1/100 of a shell (declared); integer shells marked on the track when B + 1 ≤ 1000 |
| φ₃ ◀ ▶, ← → (continuous mode) | snap to the next integer shell in their direction (integer mode: φ₃ ± 1, unchanged) |
| ⏮ start | unchanged: φ₃ = B (N = 1) in both modes |
| Play ▶ N | one shell per tick (integer mode); 1/100 of a shell per tick (continuous mode); the play note says which |

Counts: the instrument panel shows 40 visible controls without ⓘ at the default state (integer mode) and 41 in continuous mode, where the φ₃ box is shown (measured by browser-check, CONTROLS line). The φ₃ box is the 41st; see BUILD_REPORT "v0.3 step 1" for the open question. **(Superseded by step 2 below: 41 in both modes.)**

Phase container between shells (a convention, not a minimal field): with N = a/b and s = p/q in lowest terms and L_k the lcm of the denominators of the k_c, the exponent k_c·s/N of every phase factor e^{iπ·k_c·s/N} lies in (1/(L_k·q·a))·ℤ, so every phase factor lies in ℚ(ζ_C) with **C = 2·q·a·L_k**; on an integer shell a = N and this is the C = 2·q·N·L_k above. Labelled "phase container (convention)"; `host_ambient_equivalent` is true only on a shell with L_k = 1 (SCHEMA_ADDENDUM_8 §6).

## v0.3 step 2 (fix round after VERIFY, 2026-10-14): dial ledger and surface changes

| Control or line | Enters / behaviour |
|---|---|
| φ₃ chip "φ₃ value" (replaces the plain φ₃ label; both modes) | opens the φ₃ drawer; enters nothing itself |
| φ₃ drawer: ◀ exact box ▶, range line "0 … B+1 · decimal or fraction" (continuous) or "· integer (N∈ℤ)" (integer), refusal line | `phi3`; exact, address. Enter applies. Integer mode refuses a fraction with "N integer mode: φ₃ must be an integer; switch to N∈ℚ for fractions" (an integer written as 8/2 is that integer). ◀ ▶ = the row's shell steps |
| φ₃ row | chip, ⏮, ◀, slider, ▶, N∈ℤ / N∈ℚ toggle (the box left the row) **(amended 2026-10-14, saphir F1: ⏮ moved into the φ₃ drawer; the row is now chip, ◀, slider, ▶, toggle)** |
| ⏮ start (N = 1) **(amended 2026-10-14, saphir F1)** | lives in the φ₃ drawer (first button, before ◀ exact box ▶), no longer on the φ₃ row; sets φ₃ = B, so N = 1, in both modes (unchanged action); pauses Play. Moved so that the instrument panel keeps the cap of 40 visible controls (ⓘ excluded) in both modes |
| Warning line between shells | the short form "between shells: shell arithmetic undefined" (one line at 375 px, never ellipsized); the fraction is in the shell readout; cards, exports and gate reasons keep "between shells: N = p/q; shell arithmetic undefined" |
| SPREAD refusal between shells | in the s-row stepper message after a step and in the s ⓘ ("SPREAD refused (4e): SPREAD needs an integer gearbox: N = p/q"); no longer a permanent line under the view |
| Build-pins block in the page | its own id `fv-comb-hopf-build/0.1` (was `fv-comb-hopf/0.2`, the exact-export id) |

Counts (browser-check CONTROLS lines): the instrument panel shows **41** visible controls without ⓘ in both modes, nothing opened: the φ₃ chip is a button where the plain label was not, and the box left the surface. The cap of 40 is not met in either mode (see BUILD_REPORT "v0.3 step 2").

**Amended 2026-10-14, saphir F1 (resolution of the stop):** with ⏮ in the φ₃ drawer the count is **40** in both modes (nothing opened, ⓘ excluded); the paragraph above records the state before the move.

**First-screen rule (amended 2026-10-14, saphir F2):** the rule (view frame, φ₃ row, s row and transport inside the first 812 px at 375×812, nothing opened) is asserted at the default state, on shells with m = 2, and between shells at N = 11/4 for m = 2 and m = 5 (transport 811 px, after a phone-only trim of the caption margins to 1 px when a warning line is present); on Clifford and Hopf with m ≥ 3 the orbit warnings can push the transport below 812 px (e.g. 830 at N = 2, m = 5 in integer mode, 835 before the trim), which is not asserted. Informational: between shells at N = 43/2, m = 5, s = 1/3 the transport ends at 811 (Fourier) and 870 (Clifford, Hopf; 876 before the trim), because of the three-line partial-orbit warning.

## v0.4 (2026-10-19): the comb's mirror axis (display register)

Additive successor of v0.3 in its own folder (`FOURIER_VIEWER_PROTOTYPE_v0_4_20261019`). It adds one display feature, the mirror axis of the comb. Exact readouts, export fields, the lift and the address schema are unchanged. The test `host-core/test-mirror.cjs` checks this against the v0.3 modules, read-only.

Sources:
- the feature note `FEATURE_NOTE_EVEN_COMB_MIRROR_AXIS_FOR_V06_20261019.md` (9267e39f…), written by Claude Fable 5.1 from saphir's observations;
- the exact check `V06_REQUIREMENT_MIRROR_AXIS_20261019/`;
- the amendments of the S0 design review §5 (`SEIFERT_S0_DESIGN_REVIEW_20261019/REVIEW.md`, 01262856…, Codex, review #539). Where the review and the note differ, the review's wording is used.

**Lift convention (checked against `orbit-core.js` and `comb-numeric.js` `orbits`):** z₁ = a·e^{iπ(t₁s + f)} with f = 1 when n₆ < 0, and z₂ = b·e^{−iπ·c·t₂·s/N}. This is the feature note's convention plus the viewer's n₆ sign flip, which lives in the carrier. The plane phasors are z_c = ρ·e^{iπ·t₁·s}·e^{iπ·c·t₂·s/N}, so k_c = N·t₁ + c·t₂. This agrees with the review's §5 R4.

### What is drawn

- **Clifford tab, reference longitudes (R1).** These are the fixed set of the mirror c ↦ −c, which acts as z₂ ↦ z̄₂ on a positive finite leaf. β = 0 is z₂ = b and is drawn solid. β = π is z₂ = −b and is drawn dashed. Both are drawn in the carrier's violet with the short labels "β = 0" and "β = π". They are drawn for every comb, whether or not a tooth traverses them.
  - They are display objects: no comb branch, no head, no export field.
  - The caption line ends with "mirror axis β = 0, π: c = 0 · carrier tooth" (odd m) or "… reference carrier · no tooth" (even m).
  - At t₁ = 0 the odd-m label adds "(t₁ = 0: stationary, a point, not the whole longitude)".
  - Collapsed leaf (ρ = 0): no longitudes and no events are drawn. A full degenerate caption line says so.
- **Clifford tab, same-time tip coincidences per common period (R2, review wording).** Teeth c and −c share z₁, so they are at the same point at the same s exactly when c·t₂·s/N is an integer k.
  - Per pair: P = lcm_Q(2/|t₁|, 2N/|c·t₂|), M = P·|c·t₂|/N, and s_k = k·N/|c·t₂| for 0 ≤ k < M. M is an even integer.
  - The events alternate between β = 0 (filled marks) and β = π (hollow marks).
  - Exact counts come from `FVOrbit.mirrorPairs` (BigInt). Points come from the exact reduced phases, converted once, as for the tooth dots.
  - The marks live on the canvas and are recorded in `FVViews.layerMarks()` (role `mirror-crossing`, with the 3D point). One SVG group carries the count.
  - A pair is marked only when both of its branches are shown.
  - A partial orbit (more than 4,000 points per period) keeps only the events inside its drawn window, and the pair line says so.
  - At most 2,000 events are drawn per state; a degenerate caption line says when that cap is reached.
- **Image intersections (separate count, review §5).** The closed images of c and −c, with primitive windings (p, q) and (p, −q), meet in 2|p·q| points. Example: N = 5, t₁ = t₂ = 1, c = ±1 gives M = 2 same-time events but 10 image intersections. Only the same-time events lie on the reference longitudes, and only they are marked.
  - c·t₂ = 0: "the trajectories coincide continuously"; no events and no division.
  - t₁ = 0: "both images are the same transverse circle"; no image-intersection number.
- **Parity line (R3), in Layers, Advanced, under the branch chips.** It reads "mirror c ↦ −c fixes 1 tooth (c = 0): pants (mnemonic)" or "… fixes 0 teeth: line between c = ∓1 (mnemonic)", followed by the label.
  - "Pants" and "line" are a display mnemonic for the reflection picture. They do not prove a pair-of-pants surface or the Seifert base topology. No Y is drawn.
  - One line per pair follows: M, P, the image-intersection count and how many events are marked. At most 8 pair lines are shown, then "⋯ n more pairs".
  - The chips themselves are unchanged.
- **Fourier tab, mirror axis (R4 as amended).** The phasors of each pair ±c are reflections of each other in the carrier line e^{iπ(t₁s + f)}·ℝ at every s. That rotating line is drawn dashed violet and labelled "mirror axis".
  - It is the real axis exactly when t₁·s ∈ ℤ (exact). Only then does the Q-res caption add "· mirror axis = real axis (t₁·s ∈ ℤ)". The lab-frame Q-res is not used as a certificate for the axis.
  - Integer s alone is not enough. The review's example N = 5, m = 6, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1 has resultant −i, and the drawn axis is then vertical.
- **R5 (braid tab): not applicable.** v0.3 has no braid tab, and none was invented. If a braid display is built later, keep it separate (review §5 R5): braid strands separated onto distinct leaves are not the intersecting mirror pair. They are no longer conjugate under z₂ ↦ z̄₂, and they cannot carry the pair's same-time count as strand intersections.

### Dial ledger additions (v0.4)

| Control | Sets | Enters |
|---|---|---|
| (v0.4) Mirror axis (Clifford, Layers menu; toggle, `aria-pressed`, default on) | `view` key `cm` (default `1`, so absent from the address; `cm=0` when off) | drawing only: the two reference longitudes, the same-time event marks, the caption phrase and the mirror (i) notes. The parity line and the exact pair counts stay in the Layers menu (marked counts read "layer off"). No exact readout and no export field. **Used.** |
| (v0.4) Mirror axis (Fourier, Layers menu; toggle, default on) | `view` key `fm` (default `1`) | drawing only: the carrier-relative mirror line, its label, the caption phrase (only when t₁·s ∈ ℤ) and its (i) note. **Used.** |

Both toggles sit in the Layers menus, where every v0.3 layer toggle lives. They add no control to the instrument panel when nothing is opened, so the cap of 40 and the first-screen rule are untouched. The v0.3 checks of those pass unchanged. Dials that enter nothing in v0.4: none were added. Existing dials feed the mirror readouts as follows: m (parity and the pairs), N, t₁, t₂ and s (counts, periods, event points, the plane axis), n₆ (the carrier flip f, ρ = 0), and α (ρ).

### Tests (v0.4)

- `node host-core/test-mirror.cjs` (T-MA, exact and numerical).
- `node build/browser-check-mirror.cjs` (T-MA in the page, both viewports, screenshots `shot_v04_*.png`).
- The v0.3 suites run unchanged; see BUILD_REPORT "v0.4" for their results.

Credits:
- saphir: the observations;
- Claude Fable 5.1: the feature note;
- Codex (discipline coordinator): the S0 design review amendments;
- the v0.1–v0.3 builders: as recorded above and in BUILD_REPORT;
- Claude Opus 5.5: v0.4.

## v0.4.1 (2026-10-19): shell range, the ★, carrier foliation

Additive successor of v0.4 in `FOURIER_VIEWER_PROTOTYPE_v0_4_1_20261019`. The domain changes are specified in `SCHEMA_ADDENDUM_9.md`.

Credits:
- saphir: the requests;
- the merged viewer's v0.8.8-fix.5: the foliation design;
- Claude Fable 5.1: the feature note;
- Codex: review #539;
- Claude Opus 5.5: v0.4.1.

- **Shell range.** n₁ = 1…13 in factorial mode (B = 1! = 1 and 2! = 2), and B ≥ 1 in integer mode. The B = 1 and B = 2 readouts are listed in addendum 9 §1. States that were valid before give byte-identical exact output.
- **★.** The star now reads "★ lab sum real" and is shown exactly when t₁·s ∈ ℤ. It is no longer shown at every integer s.
  - The exact-flags card has two new rows. One carries the carrier-relative identity (W·e^{−iπ(t₁s+f)} is real at every s for the symmetric offsets) with its numerical imaginary part. The other is the exact "lab-frame W real (t₁·s ∈ ℤ)".
- **Carrier foliation.** On the Clifford tab, the carrier's transverse-phase foliation of the active leaf: the longitudes (a·e^{iθ}, b·e^{iβ}).
  - The family has K leaves at β = 2πj/K.
  - The selected β, on the lattice β/π = k/120, is drawn white and solid; β + π is drawn white and dashed.
  - The readouts are in the Layers menu: exact β, companion, the teeth on the foliation, β = 0 and π as the mirror's fixed longitudes, and the gcd sentence.
  - t₁ = 0 draws points, labelled. A collapsed leaf draws nothing, labelled.
  - **Hopf base: Clifford only.** Every carrier longitude projects onto the same latitude circle of S², so β cannot be seen there (addendum 9 §3).

### Dial ledger additions (v0.4.1)

| Control | Sets | Enters |
|---|---|---|
| n₁ select and ◀ ▶ (now 1…13) | `n1` | B = n₁! (1, 2, 6, …). Exact, address. **Used.** |
| M box (now 1 … 6,227,020,800) | `B` | B. Exact, address. **Used.** |
| (v0.4.1) Carrier foliation (Clifford Layers menu; toggle, `aria-pressed`, default off) | `view` key `cff` | drawing only: the family, the selected and companion curves, their label, the guard captions and the (i) note. **Used.** |
| (v0.4.1) foliation leaves select (Clifford Layers, Advanced; 6 / 12 / 24 / 120, default 24) | `view` key `cfk` | the number K of family curves drawn. Drawing only. **Used** when the layer is on; with the layer off it changes only the readout. |
| (v0.4.1) ◀◀ β, ◀ β, β ▶, β ▶▶ (Clifford Layers, Advanced) | `view` key `cfb` (k, mod 240) | the selected β = k/120·π and its companion; steps of 10 or 1. Drawing only, with an exact readout. **Used** when the layer is on; with the layer off it changes only the readout. |

None of the new controls enter the exact export. The instrument panel count, with nothing opened, is unchanged.

## v0.4.2 (2026-10-19): the N = 0 Wilson wording and the shell-switch clamp

Additive successor of v0.4.1 in `FOURIER_VIEWER_PROTOTYPE_v0_4_2_20261019`. Both changes are specified in `SCHEMA_ADDENDUM_10.md`; the defects were recorded by the v0.4.1 build report (addendum 9 §1).

Credits:
- saphir: the decision;
- the v0.4.1 build report: both defects;
- Claude Opus 5.5: v0.4.2.

- **Wilson at N = 0.** The Wilson card, the stats export and the exact field `exact.wilsonN` now read "N = 0: no comb, so the Wilson test does not apply." (was "N = 1 is not prime."). N = 1 still reads "N = 1 is not prime.". Every N ≠ 0 state gives byte-identical output.
- **Shell switch.** When a shell switch leaves φ₃ above the new B + 1, φ₃ is set to B (N = 1), not B + 1 (N = 0). The same rule holds in both N modes (one exact clamp). N = 0 is still chosen directly with φ₃ = B + 1.

### Dial ledger additions (v0.4.2)

| Control | Sets | Enters |
|---|---|---|
| (v0.4.2) n₁ select and ◀ n₁ ▶, when φ₃ > new B + 1 | `n1`, and `phi3` := B | B = n₁!; N = 1 (was φ₃ := B + 1, N = 0). Exact, address. **Used.** |
| (v0.4.2) shell mode factorial / integer, when φ₃ > new B + 1 | `shellMode`, and `phi3` := B | B; N = 1 (was N = 0). Exact, address. **Used.** |
| (v0.4.2) M box, when φ₃ > new B + 1 | `B` (integer mode), and `phi3` := B | B; N = 1 (was N = 0). Exact, address. **Used.** |
| (v0.4.2) any shell switch with φ₃ ≤ new B + 1 | unchanged: `phi3` kept | unchanged. **Used.** |
| (v0.4.2) φ₃ box, ◀ (N − 1), slider at its maximum | `phi3` = B + 1 (unchanged) | N = 0, the empty state; the Wilson card reads "N = 0: no comb, so the Wilson test does not apply." **Used.** |

No control was added or removed. No change enters a new export field, and the address and state format is unchanged.

## v0.4.3 (2026-10-19): wireframe at full resolution while the camera moves

Additive successor of v0.4.2 in `FOURIER_VIEWER_PROTOTYPE_v0_4_3_20261019`; see `SCHEMA_ADDENDUM_11.md`. Display only. While the camera moves, the Clifford and Hopf canvas is now drawn at full resolution (it was half). The half-resolution mechanism is kept as the `surface` kind (`MOVING_RES` in `views-common.js`) for future filled-surface rendering; no current view uses it. Exact readouts, exports and the reduced point sample are unchanged.

Credits: saphir: the decision; Claude Sonnet 5.5: v0.4.3.

### Dial ledger additions (v0.4.3)

No new dial. The camera drag, pinch and wheel are unchanged; only the pixel count of the moving frame changed. **Used** as before.

## v0.4.4 (2026-10-20): colossally abundant (CA) preset track and the rebuilt G. Robin margin card

Additive successor of v0.4.3 in `FOURIER_VIEWER_PROTOTYPE_v0_4_4_20261020`; see `SCHEMA_ADDENDUM_12.md` and `BUILD_REPORT_v0_4_4.md`. Display only; no state, address or export schema change.

- Top bar: a third base button **CA** beside n! and integer. In CA mode a menu of the ten CA numbers (2, 6, 12, 60, 120, 360, 2520, 5040, 55440, 720720) replaces the M box and the n1 stepper; a choice sets the integer base B exactly as typing it in the integer M box does. No readout in the top bar.
- Panels tab: the card **G. Robin margin** (group B) is now a port of the previous merged FVLT viewer's G. Robin / RH margin panel (frozen host block RH_MARGIN_V0_1), reading B from the shared model in any base mode, with the CA index and the holds/fails line added. Its exact core is `host-core/rhm-core.js`, a byte copy of the accepted package's rhm-core.js. All other Panels cards stay placeholders.

### Dial ledger additions (v0.4.4)
- CA base button: new, live; sets shellMode integer and B. UI overlay (not in the state address): leaving the presets (typed M, import, hash change) ends it.
- CA preset menu: new, live; sets B.
- Card precision_bits select (2, 3, 4, 5, 6, 16, 64, 128 default, 256): new, display only (card-local, not in the state); changes the enclosure grid of the record.
- Card export button: new, writes a download of the canonical record bytes; changes no state.
- Unused: none of the existing dials is changed.

## v0.4.5 (2026-10-20): CA mode in the page address; visible-control cap 41

Additive successor of v0.4.4 in `FOURIER_VIEWER_PROTOTYPE_v0_4_5_20261020`; see `SCHEMA_ADDENDUM_13.md` and `BUILD_REPORT_v0_4_5.md`. saphir's decisions 2026-10-20.

- The page address gains an optional last field `&ca=1`, written only while CA mode is on (integer mode, B a CA preset). A shared link with it reopens in CA mode at that B. Every address without it loads exactly as in v0.4.4, and every non-CA state writes the same address as v0.4.4.
- An address with `ca=1` and a B that is not a CA preset (or n! mode, or a field that is not exactly `ca=1`, or repeated) refuses the CA flag only: the state loads as the address says, CA unpressed, and the status line says "CA flag refused: ...".
- The visible-control cap is 41 (the CA button of v0.4.4 is the 41st). The old v0.3 browser-check is unedited; `build/browser-check-v045.cjs` asserts the cap 41.

### Dial ledger additions (v0.4.5)
- CA base button and preset menu: now also read from and written to the address (`ca=1`).
- No new control. Unused: none of the existing dials is changed.

## v0.4.6 (2026-10-20): n1 group hidden in integer mode
Additive successor of v0.4.5 in `FOURIER_VIEWER_PROTOTYPE_v0_4_6_20261020`; see `SCHEMA_ADDENDUM_14.md` and `BUILD_REPORT_v0_4_6.md`. saphir chose option A.
- In integer mode (CA or not) the n1 minus / select / plus group is hidden; it was disabled there and did nothing. Switching to n! shows it again with the current n1. n1 stays in the state and the address; every address is unchanged.
- Integer base, non-CA: 42 to 39 visible controls. n! base 41, CA 39, continuous 41, as in v0.4.5.

### Dial ledger (v0.4.6)
- n1 stepper (minus, select, plus): shown in n! mode only; hidden in integer and CA modes. No new control; unused dials: none.


## v0.4.7 (2026-10-20): alpha_Tilt as a walk weight
Additive successor of v0.4.6 in `FOURIER_VIEWER_PROTOTYPE_v0_4_7_20261020`; see `SCHEMA_ADDENDUM_15.md`, `BUILD_REPORT_v0_4_7.md` and the design note (sha256 b7e81128...2814b). saphir answered Q1 to Q7 with the note's leans.
- **What it is.** The kernel's spectral tilt alpha_Tilt (notation w_k = k^alpha_Tilt, kernel v3.2.7) used as a weight on the **walk step** t = 1 ... m in offset order: W_t = W_{t-1} + t^alpha_Tilt z_{c_t}. Range [-1, 1], an exact rational (slider value read exactly, 0.37 is 37/100). The teeth are not weighted. w_1 = 1, so W_1 = z_{c_1} at every tilt.
- **Standing.** The comb walk for m >= 3 is outside the kernel: this is an instrument-tier use of a kernel parameter with no theorem standing. Helix / Circle / Spiral are preset names only (Rmk 9.4a, empirical, observed on the Explorer walk); no regime is claimed or labelled. Nothing is built on Def 5.2 (erratum W1, in kernel v3.2.7 (locked)).
- **Where.** Second dial in the alpha drawer (the alpha chip shows "α 1 · tilt x" when nonzero). Changes: Fourier walk and endpoint, Hopf walk curve and vertices, |W|, |W|/ρ, Q-res, the star and mirror captions, the m = 2 label, the exact export's weights, Copy formula. Does not change: teeth, lift, leaf, orbits, every exact readout, Clifford (says "α_Tilt does not apply here"), G. Robin.
- **Exactness.** Integer tilt: exact rational weights (t, 1, 1/t). Fractional tilt: weights t^(p/q) numerical, labelled; the cyclotomic note adds the radicals sentence. Drawn walk values are float64 either way.
- **Numerical bound.** At alpha_Tilt != 0: 8 (m + 2 + |alpha|(1 + |ln N|) + |alpha_Tilt|(1 + ln m)) eps max(rho w_max, 1), w_max = m^alpha_Tilt for alpha_Tilt > 0, else 1. At 0 it is the previous formula exactly.
- **Address.** Optional key `tilt` after `view` and before `&ca=1`, written only when nonzero (example `&tilt=-1/2`), id `fv-comb-hopf/0.2` unchanged. `tilt=0`, a non-canonical value, an out-of-range value or a repeat refuses the state. A v0.4.6 reader refuses a tilt address ("Unknown key tilt.").
- **At alpha_Tilt = 0 every output is byte-identical to v0.4.6** (compute, state and exact export, address, stage, canvas, caption, cards).
- Controls: counts stay 41 / 39 / 39 / 41 (drawer closed).

### Dial ledger (v0.4.7)
| Control | Sets | Enters |
|---|---|---|
| α_Tilt dial in the α drawer: ◀ exact box ▶, −1 Helix / 0 Circle / +1 Spiral (names only), slider −1…1 (step 1/100, read exactly), ⓘ | `tilt` (absent = 0) | walk steps w_t z_{c_t}, w_t = t^α_Tilt, t = position in offset order: Fourier walk, Hopf walk, \|W\|, \|W\|/ρ, Q-res, endpoint; ★, mirror and carrier-relative captions; exact export weights; Copy formula. Not the teeth, lift, leaf, orbits, any exact readout, Clifford or G. Robin. Address (only when ≠ 0) |
- Unused dials: none; every existing dial is unchanged.

## v0.4.8 (2026-10-20): shorter tilt wording in the Fourier caption
Additive successor of v0.4.7 in `FOURIER_VIEWER_PROTOTYPE_v0_4_8_20261020`; see `SCHEMA_ADDENDUM_16.md`, `BUILD_REPORT_v0_4_8.md`. saphir (2026-10-20): "Yes, do both".
- **Adopted, unchanged:** the Panels row "carrier-relative W·e^{−iπ(t₁s+f)} real" keeps its v0.4.7 label "(teeth only; the tilted walk is not mirror-symmetric)".
- **Shortened:** at alpha_Tilt != 0 the Fourier one-line caption's star part reads "★ teeth conjugate (t₁·s ∈ ℤ); walk not real" (was "★ pair phases conjugate (t₁·s ∈ ℤ); tilted walk not real in general"), so Q-res is no longer cut by the ellipsis at 1280x800. The Panels row keeps the long wording. The Hopf caption has no star or Q-res part and needed no change.
- At alpha_Tilt = 0 every caption is byte-identical to v0.4.7. Dial ledger and control counts unchanged.

## v0.4.9 (2026-10-20): full stack and fraction stack (the old instrument's stack coordinate system)
Additive successor of v0.4.8 in `FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020`; see `PORT_NOTE.md`, `SCHEMA_ADDENDUM_17.md`, `BUILD_REPORT_v0_4_9.md`. saphir: "I want to see the full stack coordinates. can you put the coordinate system into the new viewer?"
- **Full stack.** Every integer s and integer φ₃ in 0 … B+1, N = B+1−φ₃, every tooth c: z_c = n₆·N^α·exp(iπ(N·t₁ + c·t₂)·s/N) (the old `buildFullStack`, "the hand-built rosette"). New module `host-core/stack-core.js` on this viewer's exact core. Follows the viewer's exact α (any accepted value, |α| ≤ 8), n₆, t₁, t₂, m and shell (n!, integer, CA); not φ₃, s or α_Tilt.
- **Registers.** Phases exact (integer arithmetic, the same k_c and phase as the tooth table); amplitude n₆·N^α exact only for integer α, else numerical; drawn float64. Display only: no tooth, walk, readout, card or export.
- **Where.** Fourier: planar dots on the canvas layer, frame fitted to include the stack. Clifford: each point lifted on its own leaf ρ_N and projected like the tooth dots (budget 12,000 − m, host selection). Hopf base: each point through the chart (host chart: its exact Hopf base image; comb chart: divided by the current ρ, labelled). Fraction stack (the s = j/q heads of the current shell, already on Clifford) now also on Fourier (on |z| = |ρ|) and Hopf (on the current latitude).
- **Lattice and thinning.** Host rule: step 1 while (B+2)² ≤ 58,081 = 241², else every ⌈(B+1)/241⌉-th value of s and φ₃; m-independent through m = 30, bucketed by m above. Deterministic; the caption says when thinned. The N = 0 column (φ₃ = B+1) is counted and labelled, never drawn; n₆ = 0 is labelled; at current N = 0 the stack is not drawn, labelled.
- **Speed.** The stack is cached on (shell, n₆, α, t₁, t₂, m); the Fourier dots are drawn into a signature-cached bitmap (an s or φ₃ change only copies it). Dots are squares (fillRect), as in the host Plane view.
- **Off by default.** With every new toggle off the viewer is byte-identical to v0.4.8 (stage, canvas, captions, about, cards, address, PNG export). Counts stay 39 / 41 / 39 / 41.
- **Not ported:** travel marks / coverage rings (they need the meridional sweep, which this viewer does not have); the old S³ leaf sweep's display copies.

### Dial ledger additions (v0.4.9)
| Control | Where | Sets | Enters |
|---|---|---|---|
| ✦/○ Full stack | Layers menu of Fourier, Clifford, Hopf | view key `fs` / `cs` / `hs` (written only when on) | the full-stack dots of that view and their caption; nothing exact |
| ⅟/○ Fraction stack | Layers menu of Fourier, Hopf (Clifford: the existing `cf`) | view key `ff` / `hf` | the fraction-stack heads in that view and their caption |
| Stack opacity 0.50 | Layers menu, shown only while that view's full stack is on | view key `so` (default 0.5, not written; cycles 0.50 / 0.30 / 0.15 / 0.06) | opacity of the stack dots (display only; not the amplitude exponent α); the host "▒ α 0.50" (state.stackAlpha) |
- Couplings: the stack reads α, n₆, t₁, t₂, m and the shell (mode, n₁ or B, CA presets). Deliberately unused by the stack: φ₃, s, N mode, α_Tilt, camera; the chart only on Hopf. Every existing dial is unchanged.

## v0.4.10 (2026-10-20): Branch primitivity card, Poincaré disk card, "shells n² + 1" track
Additive successor of v0.4.9 in `FOURIER_VIEWER_PROTOTYPE_v0_4_10_20261020`; see `SCHEMA_ADDENDUM_18.md`, `BUILD_REPORT_v0_4_10.md`. Sources: the branch-primitivity design note (sha256 518e209c…) and the Poincaré-disk investigation note (07ef1142…), with saphir's decisions.
- **Two new Panels cards (group B, collapsed, display only, no buttons).** *Branch primitivity (trial division)*: at integer N, gears (1, 1) and an odd m with comb(m) ⊇ {2, …, ⌊√N⌋}, N is prime iff every branch c = 2…⌊√N⌋ has g_c = 1 (equivalently no UNKNOT among them); any integer N, with N = n² + 1 highlighted; refuses with the reason at other gears, even m, m too small (missing c listed), non-integer N, N ≤ 0. Notes: c = ±1 is a primitive unknot for every N (refuted criterion); c = 0 repeats N times; n₆ = 0 makes ×g a formal label. *Poincaré disk · Farey layer and divisor orbit*: the Cayley disk ζ = (z − i)/(z + i) (gauge w = i, no recentring), the two-coloured modular tessellation (drawing), the current shell's Farey layer F(a) with its contact edges, isolated beads and Ford horocycles, and Astra's points (n + i)/m for m | n² + 1 when N − 1 = n² (else a labelled idle caption); exact readouts (cusp images, edge centres and radii, ζ, cosh d, an SL(2, ℤ) matrix) beside the drawing. The disk idea is saphir's; the divisor-orbit construction is Astra's written mathematics. Each card says in one line that the two cards show the same divisors of N two ways.
- **Track "shells n² + 1".** Base selector: the CA preset menu gains a last option "n²+1 shells ▸"; the n menu that replaces it sets B = n², φ₃ = 0, m = 2n + 1 (N = n² + 1; n = 1…359). Address key `&sq=1`, written only while the track is on.
- **Unchanged.** State, address of every existing state, exact export, Lift JSON, PNG export, Fourier / Clifford / Hopf tabs: byte-identical to v0.4.9; the Panels tab differs only by the two new collapsed card elements. Visible control counts 39 / 41 / 39 / 41 (39 on the track). `panel-g-robin.js` untouched.

### Dial ledger additions (v0.4.10)
| Control | Where | Sets | Enters |
|---|---|---|---|
| CA preset menu, last option "n²+1 shells ▸" | shell row (CA mode only) | UI overlay `sq`; B = 9, φ₃ = 0, m = 7 if the current B is not a square | enters the track |
| n menu (◂ CA presets, n = 1…359) | shell row, in the place of the CA menu while the track is on | B = n², φ₃ = 0, m = 2n + 1; address `&sq=1` | the shell N = n² + 1 and the comb c = 2…n |
| Branch primitivity card | Panels, group B | nothing (read only) | reads N, t₁, t₂, m, n₆ (not α, s, α_Tilt, the camera) |
| Poincaré disk card | Panels, group B | nothing (read only) | reads the shell N only; deliberately unused: t₁, t₂, α, n₆, m, s, α_Tilt, φ₃ except through N |
- Unused dials: every existing dial is unchanged; the gears t₁, t₂ are read by the branch card only as a gate.


## v0.4.11 (2026-10-21): reciprocal winding (throat at 1/1), the other half of the full stack
Additive successor of v0.4.10 in `FOURIER_VIEWER_PROTOTYPE_v0_4_11_20261021`; see `SCHEMA_ADDENDUM_19.md`, `BUILD_REPORT_v0_4_11.md`. Sources: `FULL_STACK_MIRROR_HALF_DESIGN_NOTE_v0_1_20261021` (NOTE.md 0f2dc093…) and its addendum v0.1.1 (3591c7dd…), saphir's decision.
- **The layer.** The other half of the full stack: its image under the inversion w ↦ 1/w̄ (radius 1/ρ = N^−α/|n₆|; phases unchanged and exact). On the Hopf base the exact reflection through the equator plane (heights −(ρ²−1)/(ρ²+1)); the Farey half x = 1/n → 0, i.e. t = ln x < 0; the equator |w| = 1 is the throat. It coincides with the α ↦ −α stack only when |n₆| = 1, and both halves start on the equator only when |n₆| = 1 (otherwise at heights ±(n₆²−1)/(n₆²+1)). Prior work: saphir's Farey helix explorer v2/v3. Arithmetic: the divisor ↔ cofactor exchange m ↔ (n²+1)/m, the same involution as the Poincaré disk card's dashed diameter (that card is unchanged). Not the "Mirror axis".
- **Controls.** Layers menu of Fourier, Clifford, Hopf base: "Reciprocal winding (throat at 1/1)", shown only while that view's Full stack is on, off by default; view keys `fr`, `cr`, `hr` (written only when on). Counts stay 39 / 41 / 39 / 41.
- **Unchanged.** With the keys absent: byte-identical to v0.4.10 (state, address, exports, captions, about, canvas, PNG). `panel-g-robin.js`, `panel-bd.js` untouched.

### Dial ledger additions (v0.4.11)
| Control | Where | Sets | Enters |
|---|---|---|---|
| ○/◐ Reciprocal winding (throat at 1/1) | Layers menu of Fourier / Clifford / Hopf base, only while that view's Full stack is on | view key `fr` / `cr` / `hr` (written only when on) | the reciprocal dots of that view and its caption; nothing exact, no export |
- Couplings: reads exactly what the Full stack reads (α, n₆, t₁, t₂, m, shell) and, on the Hopf base, the chart (host: reflection of the image; comb: image of ρ_cur²/z̄). Deliberately unused: φ₃, s, N mode, α_Tilt, camera, the Stack opacity aside (the reciprocal dots follow it). Every existing dial is unchanged.


## v0.4.12 (2026-10-21): log radius display of the Fourier view
Additive successor of v0.4.11 in `FOURIER_VIEWER_PROTOTYPE_v0_4_12_20261021`; see `SCHEMA_ADDENDUM_20.md`, `BUILD_REPORT_v0_4_12.md`. saphir's log mirror (Farey helix explorer v2/v3), laid flat.
- **The item.** Fourier Layers menu, "Log radius (throat at |z| = 1)", only while Full stack is on, off by default; view key `fl` (written only when on). Every drawn point keeps its exact phase and is drawn at radius R_t(1 + ln r / L), L = largest |ln r| of the drawn stack points; r = 1 on the throat circle; with Reciprocal winding on the halves are exact mirror images (R(1/r) = 2R_t - R(r)). Log rings at r = e^k replace the grid circles. Clamped and r = 0 points are counted in the caption. Display only: no exact readout, card, export or address changes (apart from `fl`). Counts stay 39 / 41 / 39 / 41; `fl` off is byte-identical to v0.4.11.

### Dial ledger additions (v0.4.12)
| Control | Where | Sets | Enters |
|---|---|---|---|
| ○/◐ Log radius (throat at |z| = 1) | Fourier Layers menu, only while the Full stack is on | view key `fl` (written only when on) | the drawn radius of every Fourier-view point, the throat/ring layer and its caption; nothing exact, no export |
- Couplings: reads what the Full stack and the Reciprocal winding read, plus the current comb (teeth, walk, carrier, polygons, fraction stack) for the mapped drawing. Deliberately unused: the Clifford and Hopf views, every export, the cards. Every other dial is unchanged.


## v0.4.13 (2026-10-21): the pen stays linear in the log radius display
Additive successor of v0.4.12 in `FOURIER_VIEWER_PROTOTYPE_v0_4_13_20261021`; see `SCHEMA_ADDENDUM_21.md`, `BUILD_REPORT_v0_4_13.md`. With Log radius on, only the stack (Full stack, Reciprocal winding, throat, log rings) is log-mapped; the pen (walk, trace, endpoint, polygons, radius circle, fraction points), the teeth and the carrier are drawn linearly about the same origin with their own scale (largest pen extent = 1/2 throat radius), shown by a scale bar labelled "pen u" bottom right and a caption line. `fl` off: byte-identical to v0.4.12.

### Dial ledger additions (v0.4.13)
| Control | Where | Sets | Enters |
|---|---|---|---|
| none new | Log radius item as in v0.4.12 | view key `fl` (only when on) | stack mapping as before; the pen scale s_pen is derived (pen extent, R_t), not a dial |
- Couplings: s_pen reads the current comb (rho, walk, teeth) and the throat radius; nothing exact, no export. Deliberately unused: a user dial for s_pen (fixed at 1/2 R_t). Every other dial is unchanged.

## v0.4.14 (2026-10-21): the Goldbach prime-pair track "Goldbach N ▸"
Additive successor of v0.4.13 in `FOURIER_VIEWER_PROTOTYPE_v0_4_14_20261021`; see `SCHEMA_ADDENDUM_22.md`, `BUILD_REPORT_v0_4_14.md`, and the design note `GOLDBACH_PRIME_PAIR_MASK_DESIGN_NOTE_v0_1_20261021/NOTE.md`. A preset track (last option of the CA preset menu, then a menu of even N = 4 … 1,448) sets the dials of the Goldbach shell N (integer mode, B = N/2 − 1, φ₃ = 0, t₁ = n₆ = 1, α = α_Tilt = 0, convention B: t₂ = 2 when N/2 is odd, else 1) and switches on a **walk-weight mask** (0 / 1 / 2): the teeth whose pair N/2 ± c is not both prime are ghosted and labelled, the c = 0 tooth (equal pair) counts twice, and the pen is exactly the kernel's G_N(s) = e^{iπs}R_N(s) (Cor II.23.5c). A card gives N, g(N) = #P_N, G_N(0) = 2g(N), R_N(s), the pair list with both mirror branches (raw (N/2, ∓a_p), primitive ×1, twin pair = unknot) and the kernel guards (Interference register, Empty-fiber guard, Unit-fiber guard, "Closure reaches conjugation, not Goldbach."). Address flag `&gb=1`, written only while on. α_Tilt is refused on the track (and switched off, with a status line, on entry). Prior art: GOLDBACH_COMB_CORRESPONDENCE_v0.2.md (2026-07-20) and Codex's goldbach_clifford_adapter_v0_7_1.html; nothing ported. Track off: byte-identical to v0.4.13.

### Dial ledger additions (v0.4.14)
| Control | Where | Sets | Enters |
|---|---|---|---|
| CA preset menu, last option "Goldbach N ▸" | shell row (CA mode only) | UI overlay `gb`; N = 24 (or the current Goldbach N); α_Tilt off | enters the track |
| Goldbach menu (◂ CA presets, N = 4 … 1,448) | shell row, in the place of the CA menu while the track is on | B = N/2 − 1, φ₃ = 0, t₁ = 1, t₂ ∈ {1, 2}, m, n₆ = 1, α = 0, α_Tilt off; address `&gb=1` | the shell N/2, the comb that holds every ±a_p, the walk weights |
| Goldbach card, ghosted teeth, captions | cards column; Fourier, Clifford, Hopf | nothing (read only) | read N, s (R_N(s), the page), the mask derived from N |
| α_Tilt (drawer) | α drawer | refused while the track is on | no longer enters the walk on the track (the mask is a 0 / 1 / 2 weight) |
- Couplings: s drives the pen and R_N(s); the Layers items (Teeth, Walk, Mirror axis, branch chips) act as before on the kept and ghost teeth; ch (branch visibility) still hides branches. Deliberately unused: a weight-1 equal-pair option (the pen would be G_N − δe^{iπs}), Λ_G(N), the coprime reference, a free mask, convention A. Every other dial is unchanged.

## v0.4.16 (2026-10-28): D1, the Rule 30 ladder-monodromy card (Clifford tab)
Additive successor of v0.4.14 in `FOURIER_VIEWER_PROTOTYPE_v0_4_16_20261028` (v0.4.15 is skipped: reserved for the held scene-model / Landau design); see `SCHEMA_ADDENDUM_23.md` and `BUILD_REPORT_v0_4_16.md`. The idea of writing Rule 30 on surfaces is saphir's; the exact facts F1–F3 come from the rule30 track and its kit. New exact module `host-core/rule30-ladder-core.js` (integers, BigInt x): the T-functions of rules 30, 90 and 150 on x(0) = 1, A(j, t), ψ_j, N_j(t), per_n, S_j, the doubling set, k(q, S_j) and the lifted curve as exact rationals of a turn. Fixture: `fixtures/rule30-ladder-fixture.json`, transcribed from the pinned rule30 outputs (densities 72d0bd14…, lemma check fa24e806…, manifest 677bfe28…), checked by `host-core/test-rule30-ladder.cjs`.

Layers ▸ "Rule 30 ladder (D1)" switches the Clifford tab to one torus leaf (the Clifford torus, ρ = 1) carrying row j of the rule: base angle 2π·t/per_j, where **per_j is the cycle of the rows below j (mod 2^j)**, fibre angle 2π·N_j(t)/q, drawn from t = 0 to t = k·per_j, k = q/gcd(q, S_j), S_j = N_j(per_j): the first return of the lifted curve. The caption reads "row j, rule R, q = q: S_j = …, closes after k turn(s)" and "monodromy nontrivial" (S_j odd, per_{j+1} = 2·per_j) or "trivial (stall)" (S_j even). With q = 2, "closes after two turns" is exactly odd monodromy. A D1 card gives the exact registers. Switching D1 off returns the comb picture unchanged.

**Declared lift rule (a stated convention).** Within a base step t → t+1 the base angle advances by 2π/per_j. If ψ_j(t) = 1 (an event) the fibre advances monotonically forward by 2π/q across that same step, interpolated linearly in the step parameter; otherwise the fibre is constant. The fibre never goes backwards and never takes the short way round: the drawn curve is the lift of N_j, not its shadow mod 2. Event steps are amber, the other steps cyan; violet rings mark the returns to base angle 0 after each whole base cycle (fibre i·S_j/q turns).

Degenerate cases are drawn and labelled: q = 1 "fibre constant (q = 1)" (the sampled fibre is 0 mod 1; the lift rule still draws each event as one full forward fibre loop: SCHEMA_ADDENDUM_23 §5.1); S_j = 0 (no events: a pure base circle); j = 0 (per_0 = 1, ψ_0 ≡ 0); rows of density 0 (rule 90, odd j). Not claimed: D1 displays F2 and F3; it is not evidence about the centre column, and nothing here concerns Problems 1 or 2.

### Dial ledger additions (v0.4.16)
| Control | Where | Sets | Enters |
|---|---|---|---|
| "Rule 30 ladder (D1)" | Clifford Layers menu | view key `rl` (0 / 1, default 0) | switches the Clifford picture to D1 (comb state kept, not drawn) and adds the D1 card |
| rule (select 30 / 90 / 150) | Clifford Layers menu, D1 on | `rlr` (default 30) | the T-function F and ψ_j |
| ◀ j, row (select j = 0 … 34, each marked doubling / stall at q = 2), j ▶ | Clifford Layers menu, D1 on | `rlj` (default 3), clamped to 0 … 34 | the row j, its base cycle per_j and S_j |
| lift q (select 1 / 2 / 4 / 8) | Clifford Layers menu, D1 on | `rlq` (default 2) | the fibre angle 2π·N_j/q and k = q/gcd(q, S_j) |
| Tρ leaf | Clifford Layers menu (also with D1 on) | `cl` | the torus mesh behind the curve |
| camera (drag, zoom, pan, Camera menu) | Clifford view | `ca`, `ce`, `cz`, `cx`, `cy`, `cp` | the projection only |
- Fixed, not dials: the leaf ρ = 1; the seed x(0) = 1; J_max = 34 (per_35 is the last cycle carried); sub = ⌈720/per_j⌉ drawn points per base step; the projection pole x₄ = +1.
- Couplings: none with the comb dials (φ₃, s, m, t₁, t₂, n₆, α, α_Tilt, the tracks): they keep their values while D1 is on and act again when it is off. The Fourier, Hopf and Panels tabs ignore the D1 keys. While D1 is on the comb Layers items and branch chips are hidden. Refused values in an address are labelled ("D1 dial refused: …") and the default is drawn.
- Deliberately unused: D2 (Hopf pen) and D3 (not in scope); q > 8; j > 34; a seed other than 1; exports of the D1 state other than the address and the PNG.

## v0.4.17 (2026-10-29): group D exact, "Elliptic points (exact)" and "Period lattice (exact intervals)" (Panels tab)

Additive successor of v0.4.16 in `FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029`; see `SCHEMA_ADDENDUM_24.md` and `BUILD_REPORT_v0_4_17.md`. Two new cards at the end of group D of the Panels tab, both collapsed on a fresh page. The legacy group-D placeholders (`mcomb-elliptic-bsd`, `clifford-elliptic-bridge` and the others) are unchanged. saphir: "No floating point".

- **Registers.** The exact register is BigInt (integers, rationals {num, den}, residues mod p): every number on the points card and the curve data of the period card (`host-core/elliptic-exact-core.js`). The interval enclosures of the period card are the *numerical register with guarantees* (dyadic intervals [lo, hi]·2^−W, outward rounding; `host-core/elliptic-period-core.js`). Canvas pixels are the *drawing register* (integers from BigInt division).
- Both cards are display only: they read nothing from the host state and write nothing; their dials live in the card module, not in the address, the exports or the PNG.

### Dial ledger: group D exact (v0.4.17)
| Control | Card | Sets | Enters |
|---|---|---|---|
| curve preset (select, 37a1 only) | Elliptic points (exact) | the curve [0, 0, 1, −1, 0] and P = (0, −1) | every readout of the card |
| k (range 1 … 20, default 5) | Elliptic points (exact) | the multiple k | kP over ℚ and the double-and-add trace with case labels |
| p (select, the 25 primes below 100, default 5; 37 marked "bad") | Elliptic points (exact) | the prime p | the E(F_p) scatter, the P1 / P2 lists, the enc collision count, the highlighted a_p row |
| P1, P2 (selects over E_ns(F_p), default both P mod p) | Elliptic points (exact) | the summands | P1 + P2 and the highlighted row of the five-case table; reset to P mod p when p changes |
| curve (select 37a1 / 11a1) | Period lattice (exact intervals) | the curve | 37a1 (Δ > 0) computes; 11a1 (Δ < 0) shows the refusal label "Δ < 0: not implemented in the exact register" |
| D (range 10 … 100, default 50) | Period lattice (exact intervals) | decimal places D, working bits W = ⌈33220·D/10000⌉ + 48 | the guaranteed digits of e1, e2, e3, ω1, ω2/i, τ/i, Ω, the AGM step tables; cached per (curve, D) |
- Fixed, not dials: the AGM stop bound (a_n.hi − b_n.lo ≤ 16·2^−W); the 48 guard bits; Machin's formula for π; the scatter grid 300 px; the cell drawing (the larger period = 130 px).
- Couplings: none with the comb dials or the other cards.
- Deliberately unused: a free ainvs input; other curves for the points card; the complex AGM (Δ < 0); exports of the card state.

## v0.4.18 (2026-10-31): group E "Surface pens (exact)" with the Goldbach stream, and the v0.4.17 fix-ups (Panels tab)

Additive successor of v0.4.17 in `FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031`; see `SCHEMA_ADDENDUM_25.md` and `BUILD_REPORT_v0_4_18.md`. Ordered by saphir 2026-10-31 ("go"; "these new viewer will also integrate our goldbach work"; "No floating point"). The pen rule and the four pen pages are the Rule 30 skeleton seat's (floats); this build re-implements them without floating point. Idea credit: saphir (Rule 30 written on surfaces; the spherical Fourier pen; the sphere squeeze; the Goldbach work).

- **Group E (new, last):** "Curvature pen (exact)" (k = +1 octahedron, k = 0 lattice, k = −1 Poincaré disk {5,4}, side by side; stacked at 375 px) and "Squeezed-sphere pen (exact)". Both collapsed on a fresh page; they compute only when opened.
- **Registers.** Exact: signs, integer lattice positions, octahedron flags (integer vectors), F = ℚ(√2, √5, τ) with τ² = √5 − 1 (the disk, short runs and the step matrices), K = ℚ(√3, √5) (the dodecahedron preset). Guaranteed numerical: BigInt interval enclosures (the disk, from exact chunk products of 64 steps) and balls (the sphere: a midpoint frame and a rigorous radius that grows linearly in T). Drawing: integer canvas pixels from the enclosures by BigInt division; "pixels not certified" counts drawn points whose enclosure is wider than ¼ pixel.
- **Group D fix-ups:** heading "D. Elliptic and BSD"; the five-case table is stacked (no word breaks at 375 px); the scatter has zoom 1×/2×/4× with a window and pan arrows, dots at least 3 px; when P1 = P2 the P2 outline is drawn 6 px larger, so both stay visible; "ν (nu)"; U+2212 in the refused 11a1 Δ; additive reduction is labelled "additive" (F3).
- **D1 link:** the D1 card (Clifford tab) has one added "see also" paragraph that opens the pen cards; the pen cards link back to D1. D1 is otherwise byte-identical (checked by `browser-check-legacy-panels-v0418`).
- Display only: the pen dials live in `FVPenCards.S`, not in the host state, the address or the exports.

### Dial ledger: group E surface pens (v0.4.18)
| Control | Card | Sets | Enters |
|---|---|---|---|
| stream (select: Rule 30, Rule 150, fair coin, Goldbach shell N, Goldbach run 4 … N_max; default Rule 30) | both (shared) | the sign stream | every pen, every strip, the Goldbach readouts and guards |
| T (range 0 … 4096, step 8, default 512) | both (shared) | the number of steps for Rule 30, Rule 150 and the coin | all panels; disabled for the Goldbach streams (they use their whole length; label shown) |
| seed (text, 1 … 2³² − 1, default 1) and "New seed" (crypto.getRandomValues; switches the stream to the coin) | both (shared) | the xorshift32 seed | the coin stream |
| N (select, even 4 … 1,448, default 24) | both (shared) | the Goldbach shell | the shell stream (one sign per tooth, order c = 0, 1, −1, 2, −2, …) |
| N_max (select, even 4 … 1,448, default 100) | both (shared) | the end of the Goldbach run | the run stream (the shells 4, 6, …, N_max concatenated; amber ticks at the shell boundaries) |
| follow the pen (checkbox, default on) | both (shared; acts on k = −1) | the disk view | on: the pen at the centre, the last W steps; off: the absolute view from the start |
| W (range 20 … 600, step 10, default 200) | both (shared; acts on k = −1) | the trail length when following | the k = −1 panel |
| lift λ (range 0 … 40, default 15, read as λ/100) | Curvature pen | the trail lift radius 1 + λ·t/T on the octahedron (a drawing device only) | the k = +1 panel |
| preset (select: free / dodecahedron θ = 60°, cos α = √5/3) | Squeezed-sphere pen | the register (free: balls; dodecahedron: exact in K) | the sphere panel and its readouts |
| α (select 1/96 … 24/96 turn, default 3/96) | Squeezed-sphere pen (free only) | the step length | the sphere panel |
| θ (select 1/24 … 11/24 turn, default 2/24) | Squeezed-sphere pen (free only) | the turn | the sphere panel |
- Fixed, not dials: the caps (k = −1 and the sphere draw at most 4,096 steps, with a visible label "… drawn to T = 4096; the rest is not drawn"); the exact register for the disk at T ≤ 64; the chunk of 64 exact steps; P = 128 + 8 bits per chunk join (doubled when the distance has fewer than 6 guaranteed places); the ball register's 96 bits; the {5,4} patch (exact BFS, depth 8); the display quaternion (7, 3, −2, −1); 432 coverage cells (24 z-bands × 18 sectors).
- Couplings: the two cards share every stream dial; nothing couples to the comb dials, the host state or the other cards.
- Deliberately unused: exports of the pen state; a free quaternion (camera); Q(ζ₉₆) for the sphere (benchmarked and not chosen; see the report); T beyond 4,096 for the CA streams.

### Dial ledger additions: group D fix-ups (v0.4.18)
| Control | Card | Sets | Enters |
|---|---|---|---|
| zoom (select 1×, 2×, 4×, default 1×) | Elliptic points (exact) | the scatter window size ⌈p/z⌉ cells | the scatter; reset to the corner when p changes |
| ◀ ▶ ▼ ▲ (buttons, zoom > 1 only) | Elliptic points (exact) | the window origin, by half a window, clamped | the scatter |

## v0.4.19 (2026-10-31): fix round on v0.4.18 (SCHEMA_ADDENDUM_26)
No new cards and no new mathematics. Goldbach tooth order decided (both sides; |c| ascending, +c before −c); D1 event steps drawn with at least 16 pieces (32 at q = 1) from exact rationals; two pixel counts ("enclosure wider than ¼ px", "pixel undecided") and the P-doubling rule with its cap; the A₅ and Codex wording; the sphere card's disabled disk dials, the tooth-events toggle, thinned shell ticks, dodecahedron edges as great-circle arcs; the host-tagged expected-fails list with exit codes and summaries.

### Dial ledger additions (v0.4.19)
| Control | Card | Sets | Enters |
|---|---|---|---|
| tooth events (checkbox, default on) | Squeezed-sphere pen | whether the tooth events (q = r = 1, Rule 30) are drawn | the sphere panel (dots 3 × 3 px in front, 1 px behind); the count is printed either way |
| follow the pen, W | Squeezed-sphere pen | nothing: shown disabled, "(not used on this card)" | — (they act on the curvature card's k = −1 panel, as before) |
- Fixed, not dials: event-step pieces in D1 (need 16, 32 at q = 1); the doubling cap (P doubled at most twice); the shell-tick spacing (≥ 3 px); 8 arc pieces per dodecahedron edge.
- Couplings: unchanged.
- Deliberately unused: a dial for the arc pieces or the tick spacing; arcs for free (α, θ) steps (they stay chords, labelled).
