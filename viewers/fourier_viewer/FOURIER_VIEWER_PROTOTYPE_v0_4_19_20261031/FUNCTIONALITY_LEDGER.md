# FUNCTIONALITY_LEDGER: old instrument vs prototype v0.1, and the plan to keep everything and simplify the surface

Date: 2026-10-13. Read-only analysis; this is the only file written. Authority: saphir (addendum 5): "I want to keep the base functionality of the entire instrument, but simplify it." and (coordinator, verbatim): "I really liked the design of the original. it flowed. but it was getting too busy".

**Old instrument (frozen, read-only):** `C:/Users/robin/fourier-viewer/reference/merged-viewer-release1/monodromy-31-linked-reduction.html` (25,363 lines by `wc -l`). Line references "L…" are lines of that file. **Prototype:** `dist/comb-hopf.html` of this folder, status from BUILD_REPORT.md (fix round 3, `browser-check` 156 passed) and `instruments/comb-hopf/README.md`. Addendum 5 (orbit branches, cyclotomic line) is **not built**: there is no `host-core/orbit-core.js` in the folder.

Scope: the main instrument (classical controls, Plane / Clifford / Hopf views, right-hand cards, exports) plus the lower panels at one row each. The rank-4 monodromy view (L2871-2971) and its ledger card are excluded.

## 0. How the counts were made (scripted, not eyeballed)

Scripts are in `C:/Users/robin/AppData/Local/Temp/claude/C--Users-robin-s6-atom/15ac8bc0-47a6-46b0-865c-c8a6ddc80b36/scratchpad/ledger/`:

- `walk2.cjs` parses the static HTML of the instrument panel and cards (L2689-3329) with a multi-line regex for `button`, `input`, `select`, `textarea`, `details`, and tags each hit with its line and region (`static_controls.json`). A raw `grep -o` over the same range gives the same totals (114 buttons, 20 inputs, 7 selects, 1 details, 1 anchor, 5 outputs, 1 summary).
- `rows1.cjs`, `rows2.cjs` hold the ledger rows; each row lists the control lines it covers. `gen.cjs` (writes this file) throws if any in-scope control line is not covered by a row, and prints the counts below. `cover.cjs` repeats the check.
- `oldgeom.cjs`, `oldcount.cjs` load the old host in Chromium (Playwright from `s6_atom/node_modules`) at 375 and 1280 px and measure positions and the number of visible controls per view. `v01walk.cjs`, `geom.cjs` do the same for `dist/comb-hopf.html`.
- `exp.cjs` walks the old export JSON (17 top-level keys).

| quantity | value |
|---|---|
| controls found in the host body L2689-3329 (button, input, select, textarea, details) | **142** ({"button":114,"input":20,"select":7,"details":1}) |
| of these in the rank-4 view L2871-2971 (excluded) | 16 ({"button":12,"select":2,"input":2}) |
| **controls in scope** | **126** ({"button":102,"input":18,"select":5,"details":1}); main instrument 118, right-hand cards 8. The count includes the "Rank-4 monodromy" switcher button (row V2) |
| ledger rows | **110**; **66** rows cover the 126 in-scope controls (every control line is in exactly one row; uncovered = 0); the other 44 rows cover items that are not static controls (overlays, readouts, cards, gestures, keyboard, export sections, injected controls) |
| controls created by script, not in the static count | n₁ buttons 3…13 (11, L13263), m select options (2…720 in the host), one orbit-branch chip per comb offset (L10858), covered by rows S2, S11, C17 |
| non-element interaction | keyboard (←/→, Shift, view-row ←/→, Esc), pointer drag, wheel, pinch, tap-to-pick, hold-to-repeat: rows T8, T9 |
| visible controls at default load, measured, Chromium, above the export bar | **Plane 83, Clifford 113, Hopf 91** (36 of the 113 are pressed-state toggles); the transport row alone has 26 buttons and the Clifford guide row 15 buttons + 3 sliders |
| caption, status and note elements in the instrument and cards (`busy.cjs`) | 28 ids ending note / help / caption / label / status / overlay, 30 caption-class elements; the Clifford overlay shows 6 text lines and the Hopf overlay 5 |

Registers in the table: **exact** (BigInt / rational), **numerical** (float, with a stated bound in v0.1), **drawing** (screen geometry). "Host float" means the host takes the decision from a float although the display calls it exact; those are listed in section 1b. Anything I did not read in the host is marked INFERRED.

## 1. Feature ledger (main instrument)

Columns: v0.1 status = done / partial / deferred / missing. Proposal classes: KEEP (as is), MERGE (into a named control), SIMPLIFY (how), BEHIND-MORE (advanced drawer), REDUNDANT (covered by a named feature), QUESTION (saphir decides). Build release (A, B, C) and extraction-step-2 dependence (Y/N) are in section 3.

### 1a-i. Shell and gearbox controls

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| S1 | base: n! / integer | L2694-2695 | Chooses the shell base B = n₁! or a direct integer M; the shell index is N = B + 1 − φ₃. | exact | done | **KEEP**: core choice; v0.1 matches. |
| S2 | n₁ = buttons 3…13 | L2699 (injected L13263-13274) | Sets n₁, so B = n₁! (factorial mode); also feeds the Wilson eligibility check. | exact | done | **SIMPLIFY**: 11 chips cost a full row on a phone; one row on desktop, one select on phone; greyed in integer mode. |
| S3 | M = box + Apply + range note | L2705-2708 | Sets the direct shell base B = M for 2 ≤ M ≤ 6,227,020,800 (host Number range; v0.1 is BigInt). | exact | done | **SIMPLIFY**: show the box inline only when "integer" is chosen; Enter applies; drop the Apply button and the range caption. |
| S4 | display: Presets / Continuous | L2721-2723, note L2858 | Switches α, n₆ (and t₁, t₂, m) between button lanes and slider lanes; the host continuous lane is FLOAT64 display only (state comment L7457). | drawing (host lane float) | done | **REDUNDANT**: v0.1 exact box accepts any rational and the slider commits an exact decimal, so the lane enters nothing (README dial ledger); remove the switch. |
| S5 | α = −1 / 0 / +1 | L2728-2730 | Sets the radial exponent α in ρ = n₆·N^α to a preset. | exact | done | **MERGE**: into the α chip: ◀ ▶ plus a drawer with the 3-way preset. |
| S6 | n₆ = −1 / 0 / +1 | L2734-2736 | Sets the radius sign n₆ (reflect through the origin, or collapse to 0). | exact | done | **MERGE**: into the n₆ chip, same pattern as α. |
| S7 | α continuous slider −8…8 + ▲ ▼ fine steps | L2740, 2745-2747 | Sets α on a grid of 0.01; the fine ▲▼ add ±0.01. | host float; v0.1 exact decimal | done | **MERGE**: slider into the α drawer; ▲▼ are the chip’s ◀ ▶. |
| S8 | n₆ continuous slider −8…8 + ▲ ▼ | L2753, 2758-2760 | Same as α for n₆. | host float; v0.1 exact decimal | done | **MERGE**: into the n₆ drawer. |
| S9 | t₁ = ◀ exact box Δ-select ▶ | L2766-2776 | Sets the carrier rate t₁ in k_c = N·t₁ + c·t₂; ◀ ▶ add or subtract Δ exactly. | exact | done | **SIMPLIFY**: keep ◀ box ▶ as one chip; the Δ-select (Δ1…Δ1/7) moves into the t₁ drawer. |
| S10 | t₂ = ◀ exact box Δ-select ▶ | L2780-2790 | Sets the spread rate t₂ (offset c·t₂/N). | exact | done | **SIMPLIFY**: same chip + drawer as t₁. |
| S11 | phasors m = ◀ select ▶ + direct box | L2794-2797 | Sets the comb order m (2…720): the tooth set c ∈ comb(m). | exact | done | **SIMPLIFY**: keep ◀ box ▶; drop the select (the direct box reaches every m; the v0.1 select lists only 2…23). |
| S12 | t₁ slider lane (−100…100) + Δ + ▲▼ | L2803-2817 | Slider form of t₁ with its own Δ-select and fine steps (a second lane). | host float; v0.1 exact | done | **REDUNDANT**: duplicates S9 (box, Δ, ◀ ▶); keep one slider in the t₁ drawer. |
| S13 | t₂ slider lane + Δ + ▲▼ | L2823-2837 | Slider form of t₂ (a second lane). | host float; v0.1 exact | done | **REDUNDANT**: duplicates S10; one slider in the t₂ drawer. |
| S14 | phasors slider lane 2…720 + ▲▼ | L2844-2851 | Slider form of m (a second lane). | exact integer | done | **REDUNDANT**: duplicates S11; slider in the m drawer. |
| S15 | radial-mode-note caption | L2858 | Caption "EXACT INPUT · t₁,t₂ accept reduced rationals…". | drawing (text) | done | **REDUNDANT**: the box placeholders say the same; cut (busy). |
| S16 | register tag "ζ₂ pair · ALG-5" (x2) | L2797, 2853 | Names the comb register for the current m (committed ALG-5 for m=2, EXT otherwise). | exact label | partial (INFERRED: not confirmed in v0.1) | **SIMPLIFY**: tooltip on the m chip and an ⓘ line, not a permanent tag. |
| S17 | B = n₁! = 24 · N=… readout | L2711-2716 (#info-fact, #info-N) | Shows B and N for the current shell. | exact | done | **KEEP**: the single place N is shown; copies in the slider row (L1), Gearbox card (K1) and Fourier overlay (F12) are REDUNDANT. |

### 1a-ii. View switch

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| V1 | view: Plane / Clifford lift / Hopf base S² | L2863-2865; ←/→ L13098 | Selects which projection of the same state is drawn; changes no setting. | drawing | done | **KEEP**: this is the original’s view row; v0.1 has it as tabs (Fourier, Clifford, Hopf base, Panels). |
| V2 | Rank-4 monodromy button | L2866 | Opens the Alpöge rank-4 certificate view (out of scope here). | exact (BigInt) | missing (excluded) | **SIMPLIFY**: remove from the switcher; one-line link to the Rank-4 viewer. |
| V3 | view-mode-note caption | L2868 (#view-mode-note) | Text per view: "EXT-VIS · per-tooth lift…", "DISPLAY ONLY · Hopf base…". | drawing (text) | partial | **REDUNDANT**: the ⓘ "About this view" in v0.1 covers it; cut from the surface. |

### 1a-iii. Fourier (Plane) view

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| F1 | Plane drawing: polar grid, radius circle, tooth rays, carrier ray, heads, walk W_t, sum endpoint | renderPhasorSvg L9735-10029 | Draws z_c = ρ·e^{iπ k_c s/N} for each tooth and the partial-sum walk to Σ z_c = ρ·e^{iπ t₁ s}·K_m(β). | drawing (from exact phases) | done | **KEEP**: the instrument’s core picture. |
| F2 | Teeth / Walk layer buttons (v0.1 only) | not in host | Show or hide tooth rays and the partial-sum walk. | drawing | done | **MERGE**: into the Fourier Layers menu. |
| F3 | 🔴 Pinch | L3134; PLANE_ONLY L12662 | Display-only markers where the resident pair c=±1 nearly coincide, weighted by contrast; the host tooltip calls it a visual analogy, not an Arnold-tongue claim. | drawing; float proximity | missing | **QUESTION**: saphir decides: drop (recommended) or build behind Layers. |
| F4 | ✿ Rosette | L3136 | Plots the phasor locus as s sweeps at fixed N (about 520K dots at the largest shell). | drawing (float) | deferred | **BEHIND-MORE**: Layers → Stack: rosette. |
| F5 | ✦ Full stack | L3137 | Plots the s×φ₃ stack of computeVernier points (the "hand-built rosette"). | drawing (float) | deferred | **MERGE**: one "Stack" choice: none / rosette / full / fraction (INFERRED: combinations add little). |
| F6 | ○ Fraction stack | L3138 | Shows the current shell’s row on the fraction lattice s = j/q (certified exact spins only); spread-zero columns are exact. | exact lattice, drawn | partial (Clifford only) | **MERGE**: into the Stack choice; one build for Fourier and Clifford. |
| F7 | ÷ Divisors | L3139 | Marks the shells N′ with N′ ∣ t₂·s on the φ₃ track and fills the Divisors readout. | host float round(s) shadow; v0.1 exact | done | **KEEP**: into Layers; v0.1 already replaced the integer shadow (class (a) difference). |
| F8 | ◇ Amber polygon | L3140; L14174 | Toggles the dashed resident m-gon (amber; green when a Wilson prime witness). | exact predicate, drawn | done | **MERGE**: into Layers; the Wilson card button "Resident cycles" (K7d) is the same toggle. |
| F9 | │ Stems | L3142 | Draws origin→tooth segments (heads always drawn). | drawing | missing | **BEHIND-MORE**: Layers; default on, no own button. |
| F10 | ● Dots | L3143 | Scales all markers by 0.45×. | drawing | missing | **MERGE**: with F11 into one "marker size" control in Layers. |
| F11 | ▒ α 0.50 (stack opacity) | L3144 | Cycles stack dot opacity 0.50 / 0.30 / 0.15 / 0.06. | drawing | missing | **MERGE**: shown in Layers only while a stack is on. |
| F12 | Overlay text on the drawing: N=, Q-res, ★, s∈ℤ → sin(sπ)=0 | renderPhasorSvg | Prints N, the numerical Q-residual ¦Im Σ¦ (green ★ at integer s) and the ALIGN note over the picture. | numerical (host SPREAD ★ uses float 1e-9, L12474-12480) | done | **SIMPLIFY**: one line over the drawing: Q-res (numerical) plus the exact ALIGN/SPREAD flags; drop N= (B/N readout shows it) and the s∈ℤ line. |
| F13 | Overlay "contrast = …" on the drawing | renderPhasorSvg | Repeats the shell contrast H(N) over the picture. | host float; v0.1 exact | partial (exact value line) | **REDUNDANT**: the Shell card (K5a) shows it; remove from the drawing. |
| F14 | Noise-minima markers + "Minima at N:" row | L3204; buildTrail L7808 | Marks local minima of Q-res along the φ₃ walk; at exact ALIGN the row states the degeneracy instead. | numerical (float-ranked noise; export key minimaRegister CLASSIC_LOCAL_MINIMA) | missing | **QUESTION**: saphir decides: drop (recommended; the exact ALIGN/SPREAD flags carry the information) or build labelled "numerical". |
| F15 | Trail (previous-N partial sums) | buildTrail L7808-7845 | Draws the walk’s earlier shells as a trail (export key trail). | drawing (float) | deferred | **BEHIND-MORE**: Layers: trail. |

### 1a-iv. Clifford view

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| C1 | Tρ leaf | L2976 | Draws the Clifford leaf T_ρ (¦z₁¦/¦z₂¦ = ρ) in stereographic projection. | drawing | done | **KEEP**: Layers. |
| C2 | s-orbits | L2977 | Draws each tooth’s s-orbit, one closure period, in branch colour. | drawing; closure period exact | done | **KEEP**: Layers. |
| C3 | Grid (ρ=1 boundary) | L2979 | Draws the ρ = 1 torus mesh as reference. | drawing | done | **KEEP**: Layers. |
| C4 | Four circles | L2980 | Draws meridian, parallel, Hopf and opposite circles on the leaf (the addendum gives colours only; the pairing is the builder’s reading). | drawing | done | **MERGE**: into one "Guides" choice with the weaves (C5). |
| C5 | Hopf weave / Opposite weave | L2981-2983 | Draws a family of Hopf fibres (gold) or opposite fibres (magenta) over the leaf. | drawing | deferred | **MERGE**: one 4-way choice (off / Hopf / opposite / both) in Advanced. |
| C6 | weave Fill slider + count | L2986-2988 | Chooses how many of 40 fibres are drawn. | drawing | deferred | **BEHIND-MORE**: Advanced; shown only while a weave is on. |
| C7 | weave ▶ Play | L2989 | Animates the Fill count. | drawing | deferred | **BEHIND-MORE**: Advanced, beside Fill. |
| C8 | Meridian sweep: Off / Slice / Volume | L2991-2995 | Chooses no sweep, one meridian slice at angle γ, or a volume of planes. | drawing (float) | deferred | **MERGE**: three buttons are already one 3-way choice; one radio in Advanced. |
| C9 | Follow s | L2997 | Makes γ track the live carrier azimuth, so s drives the plane. | drawing | deferred | **BEHIND-MORE**: Advanced, sweep group. |
| C10 | Slice grid | L3000 | Draws the bipolar coordinate net on the slice plane (ρ-circles through the Z₁ foci). | drawing | deferred | **BEHIND-MORE**: Advanced, sweep group. |
| C11 | Travel marks | L3004 | Draws cyan rings riding {γ, γ+π}; they brighten at ALIGN (γ/π ∈ ℤ). | drawing | deferred | **BEHIND-MORE**: Advanced, sweep group. |
| C12 | γ slider + value | L3009-3013 | Sets the slice angle γ = k/120·π, 0 ≤ k ≤ 240. | drawing; lattice exact | deferred | **BEHIND-MORE**: Advanced; shown only in Slice mode. |
| C13 | Planes slider + value | L3015-3018 | Sets the number of planes (2…24) in Volume mode. | drawing | deferred | **BEHIND-MORE**: Advanced; shown only in Volume mode. |
| C14 | sweep ▶ Play | L3020 | Animates γ (slice mode). | drawing | deferred | **BEHIND-MORE**: Advanced, beside γ. |
| C15 | Reset γ | L3023 | Sets γ = 0. | drawing | deferred | **REDUNDANT**: γ = 0 is the left end of the γ slider; fold into a double-tap on it (INFERRED). |
| C16 | colour legend (7 colours) | L3026-3034 | Names the colour of each layer. | drawing (text) | partial | **SIMPLIFY**: show only the colours of layers that are on, as swatches in the Layers menu. |
| C17 | Orbit-branch filter: All / None + one chip per branch + help line | L3036-3045 (All/None L3040-3041); chips L10858 | Shows or hides each branch c’s orbit and tooth dot; tap toggles, Shift-click isolates. | drawing; chip text exact (addendum 5) | deferred (addendum 5 planned) | **SIMPLIFY**: one chip row carrying the data (c, winding, ×d, type); All/None become one toggle; help line to ⓘ. |
| C18 | c₀ transverse phase: Foliation + β slider + help | L3046-3055 | Draws the c=0 branch’s S¹ family of phases at β = arg Z₂ (24 samples), selected solid and β+π dashed. | drawing | deferred | **BEHIND-MORE**: Advanced; shown only when m is odd (c₀ exists). |
| C19 | S³ leaf sweep: Arithmetic ρ / Sweep η | L3063-3064 | Chooses the leaf determined by the arithmetic ρ, or a display homotopy by η ∈ [0, π/2]. | drawing (float) | deferred | **MERGE**: one 2-way radio in Advanced. |
| C20 | Balance | L3065 | Sets η to the balanced torus (INFERRED: η = π/4). | drawing | deferred | **BEHIND-MORE**: Advanced, beside the η slider. |
| C21 | Play η + η slider + value + help line | L3066-3072 | Animates or sets η. | drawing | deferred | **BEHIND-MORE**: Advanced; help line to ⓘ. |
| C22 | Camera presets: Top, Side X+, X−, Y+, Y− (+ v0.1 ISO TOP, ISO SIDE) | L3147-3159 | Exact orthographic views of the S³ projection. | drawing | done | **MERGE**: into one Camera select (7 entries) with reset. |
| C23 | ✥ pan (Clifford) | L3165 | One-finger drag pans instead of rotating (Shift-drag always pans). | drawing | done | **KEEP**: Camera menu. |
| C24 | Clifford overlay: status, ρ label, orbit label, actual label, sweep label, guide label | L3099-3108 | Six text lines over the drawing: lift status, current ρ, s-orbit summary, generated-point counts, sweep plane, reference-surface note. | numerical text (counts exact) | partial | **SIMPLIFY**: one line (ρ, points drawn, status); the rest behind ⓘ. |

### 1a-v. Hopf view

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| H1 | S² camera: q₁± q₂± q₃± + Reset + caption | L3078-3090 | Views the base sphere from a coordinate axis; Reset restores the default camera. | drawing | done | **MERGE**: one "View from" select (6 entries) plus the shared Reset. |
| H2 | Hopf base drawing: sphere, latitude/longitude, tooth points w = Z₁/Z₂, gates | renderHopfBase L12018 | Draws the Hopf image of each lifted tooth on S² ≅ CP¹ (embedded float gate, tolerance 2e-12). | drawing with float gate | done | **KEEP**: the Hopf view. |
| H3 | Hopf chart toggle W / W/ρ (v0.1 only) | not in host | Selects the affine chart used for the walk (host w = W, comb page w = W/ρ). | drawing | done | **BEHIND-MORE**: Advanced; default stays the host chart. |
| H4 | Hopf overlay: status, latitude, selection, chart label, guide label | L3109-3117 | Five text lines over the drawing. | numerical text | partial | **SIMPLIFY**: one line (selected tooth, latitude); the rest behind ⓘ. |
| H5 | same-object label | L3118 | Names the tooth currently selected in all views. | drawing | partial | **MERGE**: into the one-line caption over the drawing (C24/H4). |

### 1a-vi. Transport and view controls

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| T1 | ▶ φ₃ (play the walk) | L3122 | Steps N down shell by shell (φ₃ + 1 per tick; host rate B/10 steps per second × speed). | exact N | done | **KEEP**: v0.1 calls it ▶ N. |
| T2 | ▶ s (play the spin) | L3123 | Advances s by speed/120 per tick; v0.1 commits exact increments. | host float; v0.1 exact | done | **KEEP** |
| T3 | Reset | L3124; handler L14214 | Sets φ₃ to the shell span (N = 1) and recomputes the s range. | exact | missing | **MERGE**: into the φ₃ row as a "⏮ start" end-button. |
| T4 | Speed ½× / 2× / 1× + value | L3128-3131 | Scales the play rate. | drawing (rate) | done | **SIMPLIFY**: one button that cycles ½× → 1× → 2×. |
| T5 | Zoom + / − / ⟲ + zoom value | L3162-3164, 3168 | Zooms the view (Fourier 0.5–1000, Clifford 0.25–8, Hopf 0.65–1.45); ⟲ resets. | drawing | done | **KEEP**: compact trio under the view; the zoom value goes to ⓘ. |
| T6 | 🔓 zoom lock | L3166 | Keeps visible size constant across φ₃ and α changes (Plane only). | drawing | done | **BEHIND-MORE**: Camera menu. |
| T7 | ⛶ fullscreen | L3167 | Fullscreen of the view frame. | drawing | done | **KEEP** |
| T8 | Keyboard: ← → (N), Shift ← → (s), view row ← →, Esc | L13323, 13098, 13353 | Steps N, steps s by the stepper, cycles views, leaves fullscreen. | exact (steppers) | done | **KEEP**: invisible, free. |
| T9 | Pointer and touch: drag pan/rotate, wheel zoom, pinch, tap picks a tooth, hold-to-repeat on steppers | L14460-14667, 13868 | Moves the camera; picking highlights tooth c in every view. | drawing | done | **KEEP** |

### 1a-vii. Sliders

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| L1 | φ₃ slider ◀ ▶ + "φ₃ = …, N = …" | L3174-3180 | Sets φ₃ (N = B + 1 − φ₃); ◀ is N−1, ▶ is N+1. | exact | done | **KEEP**: under the view, as in the original; show N only once (S17). |
| L2 | s slider with ◀ ▶ | L3186-3188 | Sets s on [−E, E]; the host ◀ ▶ moved to the neighbouring integer using a float epsilon (nextCombStop L13407-13409); v0.1 uses the exact R20 stepper. | host float; v0.1 exact | done | **KEEP**: the class (a) difference is intended. |
| L3 | s = … ● integer badge, range min → max | L3191-3194 | Shows the typed spin, whether it is an integer, and the slider range. | exact | done | **SIMPLIFY**: show s_typed; show s_eff and E only when they differ from it (needs Astra check against R21). |
| L4 | set s = box + Apply + note | L3197-3199 | Takes a rational or product such as −3/2 or 49*1/2 as the typed spin. | exact | done | **SIMPLIFY**: Enter applies; drop Apply and the caption. |

### 1a-viii. Exports

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| X1 | 📄 Export JSON | L3215; buildExportData L14715 | Writes the canonical state and readouts (old keys in rows X7a-X7h). | mixed (host export has float fields) | done (new schema fv-comb-hopf/0.1) | **KEEP** |
| X2 | 📊 Export CSV | L3216; handler L14984 | One row per tooth: c, k_c, phases, re, im. | exact + numerical columns | done | **KEEP** |
| X3 | 📋 Copy Stats | L3217; handler L15023 | Copies a text summary of the cards. | mixed | done | **KEEP** |
| X4 | ⬡ Export Lift JSON | L3218 | Per-tooth S³ lift with phases and projected points (hidden in Plane). | exact phases + numerical points | done (branches pending) | **KEEP**: adds branches[] in v0.2 of the lift schema (addendum 5). |
| X5 | 🖼 Export PNG | L3219 | Saves the current viewport as PNG. | drawing | done | **KEEP** |
| X6 | Export state, Export pair, Import state (v0.1 only) | not in host | Canonical state address; PNG+JSON+state with hashes; paste-and-load restore. | exact | done | **SIMPLIFY**: one "Export ▾" menu holding JSON, state, CSV, lift, PNG, pair, copy stats, import; PNG stays one tap. |
| X7a | Old export: parameters, formula, currentState (teeth, sum, qResidual, alignExact, spreadKernel) | export keys | The state, the live formula z_c = n₆·N^α·e^{iπ k_c s/N}, per-tooth k and numerical z. | exact + numerical | done (tooth set, formula) | **KEEP** |
| X7b | Old export: spectralWilsonGearbox, independentWilsonCandidate | export keys | Spectral order data, first resident gear, Wilson witness (BigInt-checked). | exact | done | **KEEP** |
| X7c | Old export: pairedModulus (M−, M+, detuning ν, theorem guard, joint degeneracy) | export keys | Paired moduli and a guarded divisibility theorem for the mirror point. | exact (guarded integer) | deferred | **BEHIND-MORE**: with K7e. |
| X7d | Old export: shellFlank, residentPair | export keys | Contrast, flank totients, bracket, c=±1 pair class. | exact in v0.1; host float contrast | partial | **KEEP**: with K5b and K6. |
| X7e | Old export: orbitBranches, exactRationalLift.branches/gates, cyclotomic_field(+detail) | export keys | Winding, divisor, closure period and knot type per tooth; generated field Q(ζ₁₄), ambient Q(ζ₅₆). | exact | missing (addendum 5) | **KEEP**: Release A. |
| X7f | Old export: fvltAnalysis (entropy, entropyRatio, arrow, regime/σ, μ(n), Ramanujan sums c_q) | export keys | Shell analytics; the channel is evaluated "at round(s)" (integer shadow), entropy is float. | host float / integer shadow | missing | **QUESTION**: keep the exact parts (μ, Ramanujan sums) in the Shell card’s Advanced and drop entropy and regime unless saphir wants them (INFERRED: no card shows them, JSON only). |
| X7g | Old export: trail, minima, minimaRegister | export keys | Walk samples and float minima. | numerical | missing | **QUESTION**: decided together with F14 and F15. |
| X7h | Old export: meta (instrument, alpogeGateEvidence "26/26 PASS", span hashes) | export keys; L14796 | Provenance of the host build; the pass banner is a hard-coded string with no reproducing code (HOST_LIBRARY_MAP HC-13). | provenance (not a measurement) | n/a | **REDUNDANT**: rank-4 evidence; v0.1 pins its own modules in fv-build-pins. |

### 1a-ix. Cards, readouts, header and footer

| id | feature (host label) | host line | what it shows or does | register | v0.1 | proposal |
|---|---|---|---|---|---|---|
| K1 | Gearbox card: N + per-tooth k rows | L3236-3241 | N and k_c = N·t₁ + c·t₂ for each tooth. | exact (host Number) | done (in the phasor table) | **REDUNDANT**: the Phasors table carries k_c; delete the separate card. |
| K2 | Phasors card: z rows | L3243-3245 | Numerical z_c = re ± im·i per tooth (more than 16 teeth: abridged). | numerical | done | **KEEP**: one table: key, k_c, tooth phase, z. |
| K3 | ↗ FullSimplify in Wolfram Alpha | L3246 | External link that sends the symbolic sum to a web service. | n/a | missing | **QUESTION**: saphir decides: drop (recommended; offline-first) or keep as "copy expression". |
| K4 | Q-residual card: label, big number, note | L3249-3253 | ¦Im Σ¦ with a note; the host note decides "SPREAD zero" by float tolerance 1e-9. | numerical (host classification float) | done (numerical + exact flags + bound) | **KEEP**: merge the note into the overlay line (F12) once the flags are exact. |
| K5a | Shell card: contrast H(N) big number, ★ twin | L3257 | H(N) = (φ(N−1) + φ(N+1)) / (2φ(N)); defend above 3, warn above 2. | host float; v0.1 exact rational | done | **KEEP** |
| K5b | Shell card: flank cells φ(N−1), φ(N), φ(N+1) | L3258-3262 | Three totient cells coloured prime or composite. | exact | missing | **KEEP**: Release B. |
| K5c | Shell card: bracket B(N−1,N+1) TWIN/LEFT/RIGHT/NULL | L3263 | Classifies N±1 by exact primality. | exact | done | **KEEP** |
| K5d | Shell card: channel type DEFENDED/MODERATE/LEAKY | L3264; L12520-12530 | A label from the contrast band (the export tags it "integer-shadow"). | host float band | missing | **SIMPLIFY**: derive it from the exact band (v0.1 SH.contrastBand); one line. |
| K6 | Resident c=±1 card: raw k[±1], ordered pair + gap, content D, classification | L3268-3275 | Classifies the c=±1 pair (TWIN etc.) from integer frequencies and the content D of the comb (BigInt). | exact | missing | **KEEP**: Release B. |
| K7 | Wilson p-gon witness · candidate (details, open) | L3276 | Collapsible group holding the Wilson witness and the gearbox rows. | n/a | done | **KEEP** |
| K7a | test p = box + Test + Hide + two notes | L3284-3289 | Tests an independent p: prime and (p−1)!+1 ≡ 0 mod p, and draws the p-gon only after Test. | exact (BigInt) | done | **SIMPLIFY**: Enter = Test; cut the two caption lines. |
| K7b | rows: candidate spectrum, Wilson congruence, polygon display | L3290-3292 | Spectrum of p, Wilson residue, FULL or LOD polygon. | exact | done | **KEEP** |
| K7c | rows: current comb order, order spectrum, first resident gear, ambient A, residency, Wilson gate + label | L3293-3300 | φ(m), defect Δ = m−1−φ(m), g₁, A = B+1−g, residency r = N mod m. | exact | done | **KEEP**: delete the label line that repeats the rows. |
| K7d | buttons: Resident cycles, m = n₁+1, g = 0 | L3302-3304 | Toggles the amber m-gon; sets m = n₁+1; sets the zero-gear state. | exact setters | partial (v0.1 has ◀ prev / next ▶ resident gear instead) | **MERGE**: Resident cycles = F8; m = n₁+1 and g = 0 join prev/next gear as preset jumps (INFERRED semantics of "g = 0"). |
| K7e | Paired mirror button + rows M−/M+, theorem guard, joint degeneracy, label | L3305-3312 | Draws the mirror points of the paired modulus and states the guarded divisibility theorem. | exact (guarded) | deferred | **BEHIND-MORE**: Advanced inside the Wilson card. |
| K7f | Wilson card footnote "FIX.3 CANDIDATE · NOT SEATED…" | L3313 | Provenance text. | n/a | n/a | **REDUNDANT**: provenance; belongs behind ⓘ. |
| K8 | Divisors readout row | L3209-3212; L12580-12620 | Div(s) or shell contacts N′ ∣ ¦t₂ s¦, size limit 10¹⁸ in v0.1. | host shadow; v0.1 exact | done | **KEEP** |
| K9 | Footer: live formula, canonical pair identity, comb rule, cyclotomic note | L3320-3329 | Prints z_c, Im(z₋+z₊) = 2r sin(t₁sπ)cos(t₂sπ/N), the K_m kernel and the cyclotomic field of the phases. | exact text | partial (comb rule and liveFormula in v0.1) | **SIMPLIFY**: one live-formula line; kernel and field behind ⓘ; the field line arrives with X7e. |
| K10 | Header: title, subtitle, header formula | L2675-2686 | Names the instrument and prints the model. | n/a | done | **SIMPLIFY**: title + one formula line; drop the 4-part subtitle. |

### 1b. Where the host's "exact" is float-sourced (flagged)

Each was read at the line shown. v0.1 already replaces the first four; the rest are either dropped in this plan or rebuilt exactly when ported.

| host place | what happens | consequence |
|---|---|---|
| `nextCombStop` L13407-13409 | `x = state.s*D; eps = 1e-6*max(1,|x|)` decides the stop | s ◀ ▶ (row L2); v0.1 R20 stepper is exact |
| `exactSpinString` L6317 | trusts `sExact` only if `|s − state.s| < 1e-10` | exact string is float-gated; v0.1 keeps the typed exact value |
| `sToFraction` L6319-6327 | falls back to `round(s*100)/100` | silent rounding of a "fraction"; v0.1 refuses instead |
| `divisorsOnAxis` L9429 and export `channel_register: integer-shadow` | evaluates at `round(s)` | rows F7, X7f; v0.1 uses exact t₂·s/N′ ∈ ℤ |
| Q-res SPREAD star L12474-12480 | `|K_m| < 1e-9·m` and `qResidual < 1e-7·…` | rows F12, K4; v0.1 has the exact flag |
| `getHarmonicContrast` L7146, channel band | float division and thresholds 2, 3 | rows K5a, K5d; v0.1 `contrastBand` is exact |
| `buildCurrentLiftPayload` L9343 | `point.k = Number(num)/Number(den)` beside `k_exact` | Lift JSON: keep `k_exact` only as the authority |
| `buildExportData` L14796 | literal `exactGates: '26/26 PASS'` with no code behind it | row X7h; do not carry into any export |

### 1c. Lower panels (Panels tab), one row each

These are rebuilt through the extraction plan (HOST_LIBRARY_MAP section 2D); v0.1 shows 17 placeholder cards. Nothing here is simplified now; the only surface rule is the one for all cards: provenance, hashes and candidate banners sit behind ⓘ.

| # | panel (host title) | host marker and lines | register | v0.1 | plan |
|---|---|---|---|---|---|
| 1 | Orbit point index | OrbitPointIndexV26 L11360-11543 (I15) | exact + float | placeholder | host-coupled (not a clean extract); rewrite on shared state; writes s and β |
| 2 | ◎ Contact sweep | CONTACT_SWEEP_V0_1_1 L19033-19928 (I8) | exact BigInt | placeholder | core + validate load headless; port; writes s, t₁, t₂ |
| 3 | ⋔ Tooth contacts | COMBINED_BCD_V0_1_TOOTH_CONTACT L21927-23121 (I12) | exact BigInt | placeholder | tooth-core + validate; port; writes s |
| 4 | ∑ Basel cone | BASEL_LINK_V0_1_2 L19931-20624 (I9) | exact + float log enclosure | placeholder | basel-core (35 exports); needs contact diagnostics; reads B |
| 5 | Reciprocal record | COMBINED_BCD_V0_1_RECIPROCAL L20627-21087 (I10) | exact BigInt | placeholder | reciprocal-record (14 exports) |
| 6 | π(B) shell prime count | COMBINED_BCD_V0_1_SHELL_PRIME_COUNT L21090-21924 (I11) | exact BigInt | placeholder | spc-core (32 exports); reads B, t₁, t₂, n₆ |
| 7 | G. Robin margin | RH_MARGIN_V0_1 L23124-23876 (I13) | exact BigInt | placeholder | rhm-core (31 exports) |
| 8 | Cayley graph & kernel (M2/M3) | MCOMB_CAYLEY_V1 L5-222, L2644-2670, L17216-17408 (I1, I1u) | exact BigInt; float layout | placeholder | all seven core blocks load headless; UI rewritten |
| 9 | Atom explorer (M4) | #m4-panel L18557-18632 (I6) | exact + float geometry | placeholder | atom-core needs the Cayley core; divisor-atom tab candidate (addendum 4) |
| 10 | M5 structure | L18635-18769 (I6) | exact BigInt | placeholder | structure-core |
| 11 | M6 shell walk | L18771-18831 (I6) | exact BigInt | placeholder | history-core, walk-core |
| 12 | M7 divisor concepts (FCA) | L18833-19031 (I6, I7) | exact BigInt; float 3D | placeholder | fca-core; own tab candidate |
| 13 | Mcomb → elliptic → BSD (+ connected panels) | MCOMB_ELLIPTIC_LINK_V1 L16722-16929; MCOMB_CONNECTED_PANELS_V1 L16933-17020 (I3, I4) | mixed (periods float) | placeholder | group D; placement pending saphir (addendum 4) |
| 14 | Carrier addition | MCOMB_CARRIER_ADDITION_V1 L17024-17192 (I5) | mixed | placeholder | group D |
| 15 | Exact curve · BSD evidence (+ children: linked arithmetic, PT1, U1, P1, spectral, curve family, prime data, prime product) | BSD_CURVE_RECORD_V1 L16445-16672; BSD_LINKED_VIEW_V1 L17411-18908 (I2, I6) | exact BigInt; float periods | placeholder | group D; 8 child panels move with it; 386 KB generator bundle |
| 16 | Clifford elliptic bridge | ELLIPTIC_BRIDGE_V27 L16100-16406 (I3) | mixed | placeholder | group D; writes the Clifford leaf |
| 17 | Arithmetic–Fourier | ARITHMETIC_FOURIER_V0_1 L23879-25360 (I14) | exact BigInt | placeholder | afp-core loads in plain node; needs the exact curve model |
| 18 | Panel disclosure bar ("Panels: Collapse / Open panels") | PANEL_CONTROLS_V1 L16676-16718 (I16) | n/a | replaced by the Panels tab | drop: the tab's per-card open state does the job |
| 19 | BSD reduction display correction | BSD_REDUCTION_AUDIT_V1 L17196-17212 (I16) | n/a | n/a | drop: a host patch, not a feature |

Rows 1-17 are the 17 v0.1 cards. Rows 18-19 are host chrome with no counterpart.

### 1d. Counts by proposal class (feature ledger, 110 rows)

| class | rows | in-scope controls covered by those rows |
|---|---|---|
| KEEP | 37 | 28 |
| MERGE | 19 | 41 |
| SIMPLIFY | 20 | 25 |
| BEHIND-MORE | 18 | 17 |
| REDUNDANT | 11 | 14 |
| QUESTION | 5 | 1 |
| total | 110 | 126 |

Reading the control column: of the 126 static controls, 14 go away because another control already does the job, 41 fold into a shared control, 17 move into an advanced drawer, 25 are simplified in place, 28 stay as they are and 1 await saphir. No mathematical capability is removed except the five QUESTION items, and those are saphir's call.

v0.1 status counts over all rows: done 62, partial 11, missing 14, deferred 21, n/a 2.

## 2. The simplified control model

### 2.1 What is kept of the original's flow

Measured on the old host (`oldgeom.cjs`): header, then one instrument panel. Inside it, top to bottom: shell row, gearbox row, view row, a per-view guide row, the view frame, the transport row, the φ₃ slider, the s slider with its set-s box, the export bar. The cards sit in a right-hand column on desktop (x = 860, 380 px wide at 1280) and below on a phone. Keep all of this:

1. **The order**: header → shell row → gearbox row → view row → view frame → transport → φ₃ and s sliders directly under the view → exports; cards beside on desktop. v0.1 departs from this (desktop: controls in a left column and the view at x = 430; phone: the view starts at y = 1870 of 5276 px, after about 1,600 px of controls). Restoring the original order is the first change.
2. **Compact control rows** with a small label and glued controls: "α ◀ 1 ▶", "t₁ ◀ 1 ▶ Δ", steppers attached to sliders.
3. **View switching** as one short row (Plane, Clifford lift, Hopf base S²; v0.1 names them Fourier, Clifford, Hopf base and adds Panels), with ← → on the row.
4. **Visual rhythm**: the view in the middle, one slider pair under it, one quiet strip of exports; dark palette and large type as built in v0.1.
5. **The two jobs of the sliders**: φ₃ moves the shell (N), s moves the spin; both with ◀ ▶. This is the instrument's heartbeat and does not change.

### 2.2 The clutter removed (named, with the measured size)

| clutter in the old surface | measured | what replaces it |
|---|---|---|
| always-visible toggle rows | 113 visible controls in Clifford (83 Plane, 91 Hopf), 36 pressed-state toggles; transport row 26 buttons; Clifford guide row 15 buttons + 3 sliders | per-view **Layers** and **Camera** menus; target about 40 visible controls in any view (INFERRED target, section 2.5) |
| two parallel lanes for the same five dials | presets vs continuous: rows S4-S8, S12-S14, 25 controls | one chip per dial (◀ exact box ▶); presets, slider and Δ in that dial's drawer |
| long status captions over the drawing | Clifford overlay 6 lines, Hopf overlay 5, plus the view-mode note, radial-mode note, three help lines (orbit filter, c₀ phase, leaf sweep) | one caption line per view; the rest behind ⓘ (v0.1 already has "About this view") |
| duplicated readouts | N shown 4 times (info block, slider row, Gearbox card, Fourier overlay); contrast shown twice (Shell card, drawing); amber polygon toggled from two places (transport row, Wilson card); Wilson label repeats the rows above it; Q-res in overlay and in its own card | each value shown once; the Gearbox card merges into the Phasors table |
| provenance and candidate text on the surface | header subtitle, register tags, "FIX.3 CANDIDATE · NOT SEATED…", "EXT-VIS / DISPLAY ONLY" notes, cyclotomic note, `26/26 PASS` in the export meta | ⓘ only; hashes already live in `fv-build-pins` and `MANIFEST.sha256` |
| six controls where one choice would do | Meridian sweep Off / Slice / Volume; Hopf weave / Opposite weave; leaf Arithmetic / Sweep η; five Clifford camera presets; six Hopf q± buttons; speed ½× / 1× / 2× | one select or one cycling button each (table 2.4) |

### 2.3 The primary controls (always visible, in the original order)

1. **Header**: title and one live-formula line z_c = n₆·N^α·exp(i·k_c·s·π/N). (Subtitle dropped.)
2. **Shell row**: [n! ¦ integer], n₁ (chips on desktop, select on phone), M box only when "integer"; the single B = … · N = … readout.
3. **Gearbox row**: five chips α, n₆, t₁, t₂, m, each "◀ exact box ▶"; tapping the label opens that dial's drawer (preset −1/0/+1 for α and n₆, slider, Δ for t₁ and t₂, slider for m). Nothing is lost: every lane of the old two-lane design is in a drawer.
4. **View row**: Fourier ¦ Clifford ¦ Hopf base ¦ Panels.
5. **Per-view strip** (replaces the guide rows): [Layers ▾] [Camera ▾] and the zoom trio + ⛶. One caption line above the drawing.
6. **View frame.**
7. **Transport**: ▶ N, ▶ s, speed (one cycling button).
8. **φ₃ row**: ⏮ start (the old Reset), ◀ slider ▶, "φ₃ = … N = …". **s row**: ◀ slider ▶ and the set-s box (Enter applies), s = typed value.
9. **Export ▾** (JSON, state, CSV, Lift JSON, PNG, pair, copy stats, import) with PNG one tap away.
10. **Cards** (right of the view on desktop, below on phone): Phasors table (with k_c), Q-residual + exact flags, Shell, Resident c=±1, Divisors, Wilson. Lower panels stay on the Panels tab.

### 2.4 What goes behind the advanced drawers, per view

| view | Layers menu (one menu replaces the toggle buttons) | Camera menu | Advanced drawer |
|---|---|---|---|
| Fourier | Teeth, Walk, Stems, Amber polygon, ÷ Divisors, Trail; **Stack** as one choice: none / rosette / full stack / fraction stack; marker size (normal / small) and stack opacity, shown only while a stack is on | zoom lock, pan | — (Pinch and noise minima are QUESTION items) |
| Clifford | Tρ leaf, s-orbits, Grid; **Guides** as one choice: none / four circles / Hopf weave / opposite weave / both; Fraction stack | one select: Top, Side X+, X−, Y+, Y−, ISO TOP, ISO SIDE, plus Reset; ✥ pan | meridian sweep (Off / Slice / Volume radio, Follow s, γ, planes, play, slice grid, travel marks), weave Fill + Play, S³ leaf sweep (Arithmetic ρ / Sweep η, η slider, Balance, Play), c₀ foliation + β (only for odd m), orbit-branch chips with a single All/None toggle |
| Hopf base | trails | "View from" select (q₁+ … q₃−) + Reset | chart W / W/ρ |
| cards | — | — | Wilson card: paired mirror + M−/M+, theorem guard, joint degeneracy; Shell card: exact μ and Ramanujan sums (from export `fvltAnalysis`, INFERRED worth showing) |

**Toggles that collapse into one choice** (a layers menu per view instead of separate buttons):

| old buttons | becomes | why one choice is enough |
|---|---|---|
| ✿ Rosette, ✦ Full stack, ○ Fraction stack | Stack: none / rosette / full / fraction | INFERRED: they are drawn in the same space and combining two adds little; saphir confirms (Q5) |
| ● Dots, ▒ α | marker size + opacity inside Layers | appearance only |
| Hopf weave, Opposite weave, Four circles | Guides: one choice | all three are reference families on the same leaf |
| Off / Slice / Volume + Follow s | one 3-way radio + one checkbox | already mutually exclusive |
| Arithmetic ρ / Sweep η | one 2-way radio | mutually exclusive |
| Top, X+, X−, Y+, Y− (+ ISO) | Camera select | mutually exclusive |
| q₁±, q₂±, q₃± | "View from" select | mutually exclusive |
| ½× / 2× / 1× | one cycling button | mutually exclusive |

### 2.5 The 375 px phone: above the fold, and where the view sits

| layout | view frame top → bottom (px) | controls above the view | source |
|---|---|---|---|
| old host, Plane | 936 → 1398 | shell row, gearbox row (369-654), view row (664-779) | measured, `oldgeom.cjs` (Clifford 1310, Hopf 1003) |
| prototype v0.1, Fourier | 1870 → 2109 | about 1,600 px of controls (shell, radial, t₁, t₂, m, φ₃, s, play, tabs all above the view) | measured, `geom.cjs` |
| **proposed** | **about 238 → 558** | header 40, shell row 44, gearbox chips 2 rows about 110, view row 44 | design target, INFERRED (not built, not measured) |

Proposed 375×812 stack, in this order: header (40) · shell row (44) · gearbox chips, two rows (about 110) · view row (44) · **view frame (about 320 square, from y ≈ 238)** · strip with Layers, Camera, zoom, ⛶ (44) · φ₃ row (52) · s row (52) · transport (44), ending near y = 750. So on a 812 px phone the view, both sliders and the transport are on the first screen; the set-s box, exports and cards are one scroll down. The view stays directly above its sliders, as in the original. On desktop (1280 px) the view stays in the middle of the instrument panel with the sliders under it and the cards in a 380 px right column, as in the old host.

## 3. Proposed build order

Items are the KEEP, MERGE, SIMPLIFY and BEHIND-MORE rows that are not finished in v0.1 (status other than done), plus the presentation work on rows that are done but whose surface changes. REDUNDANT rows are deletions (done with Release A). QUESTION rows wait for saphir. "Ext2" = depends on **extraction step 2** (the remaining host-core libraries, HOST_LIBRARY_MAP HC groups): Y = needs a port from the host to be correct, N = new exact code from the definition or layout only.

### Release A (smallest): restore the original flow and remove the clutter; plus the exact orbit-branch and cyclotomic readouts of addendum 5. No host port needed.

| id | feature | proposal | v0.1 | ext2 | note |
|---|---|---|---|---|---|
| S2 | n₁ = buttons 3…13 | SIMPLIFY | done | N | 11 chips cost a full row on a phone; one row on desktop, one select on phone; greyed in integer mode. |
| S3 | M = box + Apply + range note | SIMPLIFY | done | N | show the box inline only when "integer" is chosen; Enter applies; drop the Apply button and the range caption. |
| S4 | display: Presets / Continuous | REDUNDANT | done | N | v0.1 exact box accepts any rational and the slider commits an exact decimal, so the lane enters nothing (README dial ledger); remove the switch. |
| S5 | α = −1 / 0 / +1 | MERGE | done | N | into the α chip: ◀ ▶ plus a drawer with the 3-way preset. |
| S6 | n₆ = −1 / 0 / +1 | MERGE | done | N | into the n₆ chip, same pattern as α. |
| S7 | α continuous slider −8…8 + ▲ ▼ fine steps | MERGE | done | N | slider into the α drawer; ▲▼ are the chip’s ◀ ▶. |
| S8 | n₆ continuous slider −8…8 + ▲ ▼ | MERGE | done | N | into the n₆ drawer. |
| S9 | t₁ = ◀ exact box Δ-select ▶ | SIMPLIFY | done | N | keep ◀ box ▶ as one chip; the Δ-select (Δ1…Δ1/7) moves into the t₁ drawer. |
| S10 | t₂ = ◀ exact box Δ-select ▶ | SIMPLIFY | done | N | same chip + drawer as t₁. |
| S11 | phasors m = ◀ select ▶ + direct box | SIMPLIFY | done | N | keep ◀ box ▶; drop the select (the direct box reaches every m; the v0.1 select lists only 2…23). |
| S12 | t₁ slider lane (−100…100) + Δ + ▲▼ | REDUNDANT | done | N | duplicates S9 (box, Δ, ◀ ▶); keep one slider in the t₁ drawer. |
| S13 | t₂ slider lane + Δ + ▲▼ | REDUNDANT | done | N | duplicates S10; one slider in the t₂ drawer. |
| S14 | phasors slider lane 2…720 + ▲▼ | REDUNDANT | done | N | duplicates S11; slider in the m drawer. |
| S15 | radial-mode-note caption | REDUNDANT | done | N | the box placeholders say the same; cut (busy). |
| S16 | register tag "ζ₂ pair · ALG-5" (x2) | SIMPLIFY | partial (INFERRED: not confirmed in v0.1) | N | tooltip on the m chip and an ⓘ line, not a permanent tag. |
| V3 | view-mode-note caption | REDUNDANT | partial | N | the ⓘ "About this view" in v0.1 covers it; cut from the surface. |
| F2 | Teeth / Walk layer buttons (v0.1 only) | MERGE | done | N | into the Fourier Layers menu. |
| F7 | ÷ Divisors | KEEP | done | N | into Layers; v0.1 already replaced the integer shadow (class (a) difference). |
| F8 | ◇ Amber polygon | MERGE | done | N | into Layers; the Wilson card button "Resident cycles" (K7d) is the same toggle. |
| F12 | Overlay text on the drawing: N=, Q-res, ★, s∈ℤ → sin(sπ)=0 | SIMPLIFY | done | N | one line over the drawing: Q-res (numerical) plus the exact ALIGN/SPREAD flags; drop N= (B/N readout shows it) and the s∈ℤ line. |
| F13 | Overlay "contrast = …" on the drawing | REDUNDANT | partial (exact value line) | N | the Shell card (K5a) shows it; remove from the drawing. |
| C4 | Four circles | MERGE | done | N | into one "Guides" choice with the weaves (C5). |
| C16 | colour legend (7 colours) | SIMPLIFY | partial | N | show only the colours of layers that are on, as swatches in the Layers menu. |
| C17 | Orbit-branch filter: All / None + one chip per branch + help line | SIMPLIFY | deferred (addendum 5 planned) | N | one chip row carrying the data (c, winding, ×d, type); All/None become one toggle; help line to ⓘ. |
| C22 | Camera presets: Top, Side X+, X−, Y+, Y− (+ v0.1 ISO TOP, ISO SIDE) | MERGE | done | N | into one Camera select (7 entries) with reset. |
| C24 | Clifford overlay: status, ρ label, orbit label, actual label, sweep label, guide label | SIMPLIFY | partial | N | one line (ρ, points drawn, status); the rest behind ⓘ. |
| H1 | S² camera: q₁± q₂± q₃± + Reset + caption | MERGE | done | N | one "View from" select (6 entries) plus the shared Reset. |
| H3 | Hopf chart toggle W / W/ρ (v0.1 only) | BEHIND-MORE | done | N | Advanced; default stays the host chart. |
| H4 | Hopf overlay: status, latitude, selection, chart label, guide label | SIMPLIFY | partial | N | one line (selected tooth, latitude); the rest behind ⓘ. |
| H5 | same-object label | MERGE | partial | N | into the one-line caption over the drawing (C24/H4). |
| T3 | Reset | MERGE | missing | N | into the φ₃ row as a "⏮ start" end-button. |
| T4 | Speed ½× / 2× / 1× + value | SIMPLIFY | done | N | one button that cycles ½× → 1× → 2×. |
| T6 | 🔓 zoom lock | BEHIND-MORE | done | N | Camera menu. |
| L3 | s = … ● integer badge, range min → max | SIMPLIFY | done | N | show s_typed; show s_eff and E only when they differ from it (needs Astra check against R21). |
| L4 | set s = box + Apply + note | SIMPLIFY | done | N | Enter applies; drop Apply and the caption. |
| X4 | ⬡ Export Lift JSON | KEEP | done (branches pending) | N | adds branches[] in v0.2 of the lift schema (addendum 5). |
| X6 | Export state, Export pair, Import state (v0.1 only) | SIMPLIFY | done | N | one "Export ▾" menu holding JSON, state, CSV, lift, PNG, pair, copy stats, import; PNG stays one tap. |
| X7e | Old export: orbitBranches, exactRationalLift.branches/gates, cyclotomic_field(+detail) | KEEP | missing (addendum 5) | N | Release A. |
| K1 | Gearbox card: N + per-tooth k rows | REDUNDANT | done (in the phasor table) | N | the Phasors table carries k_c; delete the separate card. |
| K7a | test p = box + Test + Hide + two notes | SIMPLIFY | done | N | Enter = Test; cut the two caption lines. |
| K7d | buttons: Resident cycles, m = n₁+1, g = 0 | MERGE | partial (v0.1 has ◀ prev / next ▶ resident gear instead) | N | Resident cycles = F8; m = n₁+1 and g = 0 join prev/next gear as preset jumps (INFERRED semantics of "g = 0"). |
| K7f | Wilson card footnote "FIX.3 CANDIDATE · NOT SEATED…" | REDUNDANT | n/a | N | provenance; belongs behind ⓘ. |
| K9 | Footer: live formula, canonical pair identity, comb rule, cyclotomic note | SIMPLIFY | partial (comb rule and liveFormula in v0.1) | N | one live-formula line; kernel and field behind ⓘ; the field line arrives with X7e. |
| K10 | Header: title, subtitle, header formula | SIMPLIFY | done | N | title + one formula line; drop the 4-part subtitle. |

44 items; ext2 = Y for 0.

### Release B (medium): Fourier completeness. Stacks, trail, marker controls, resident c=±1 and the full Shell card.

| id | feature | proposal | v0.1 | ext2 | note |
|---|---|---|---|---|---|
| F4 | ✿ Rosette | BEHIND-MORE | deferred | Y | Layers → Stack: rosette. |
| F5 | ✦ Full stack | MERGE | deferred | Y | one "Stack" choice: none / rosette / full / fraction (INFERRED: combinations add little). |
| F6 | ○ Fraction stack | MERGE | partial (Clifford only) | N | into the Stack choice; one build for Fourier and Clifford. |
| F9 | │ Stems | BEHIND-MORE | missing | Y | Layers; default on, no own button. |
| F10 | ● Dots | MERGE | missing | Y | with F11 into one "marker size" control in Layers. |
| F11 | ▒ α 0.50 (stack opacity) | MERGE | missing | Y | shown in Layers only while a stack is on. |
| F15 | Trail (previous-N partial sums) | BEHIND-MORE | deferred | Y | Layers: trail. |
| X7d | Old export: shellFlank, residentPair | KEEP | partial | Y | with K5b and K6. |
| K5b | Shell card: flank cells φ(N−1), φ(N), φ(N+1) | KEEP | missing | Y | Release B. |
| K5d | Shell card: channel type DEFENDED/MODERATE/LEAKY | SIMPLIFY | missing | Y | derive it from the exact band (v0.1 SH.contrastBand); one line. |
| K6 | Resident c=±1 card: raw k[±1], ordered pair + gap, content D, classification | KEEP | missing | Y | Release B. |

11 items; ext2 = Y for 10.

### Release C (largest): Clifford and Hopf advanced drawer, paired mirror. The sweeps and weaves are the biggest single ports.

| id | feature | proposal | v0.1 | ext2 | note |
|---|---|---|---|---|---|
| C5 | Hopf weave / Opposite weave | MERGE | deferred | Y | one 4-way choice (off / Hopf / opposite / both) in Advanced. |
| C6 | weave Fill slider + count | BEHIND-MORE | deferred | Y | Advanced; shown only while a weave is on. |
| C7 | weave ▶ Play | BEHIND-MORE | deferred | Y | Advanced, beside Fill. |
| C8 | Meridian sweep: Off / Slice / Volume | MERGE | deferred | Y | three buttons are already one 3-way choice; one radio in Advanced. |
| C9 | Follow s | BEHIND-MORE | deferred | Y | Advanced, sweep group. |
| C10 | Slice grid | BEHIND-MORE | deferred | Y | Advanced, sweep group. |
| C11 | Travel marks | BEHIND-MORE | deferred | Y | Advanced, sweep group. |
| C12 | γ slider + value | BEHIND-MORE | deferred | Y | Advanced; shown only in Slice mode. |
| C13 | Planes slider + value | BEHIND-MORE | deferred | Y | Advanced; shown only in Volume mode. |
| C14 | sweep ▶ Play | BEHIND-MORE | deferred | Y | Advanced, beside γ. |
| C15 | Reset γ | REDUNDANT | deferred | Y | γ = 0 is the left end of the γ slider; fold into a double-tap on it (INFERRED). |
| C18 | c₀ transverse phase: Foliation + β slider + help | BEHIND-MORE | deferred | Y | Advanced; shown only when m is odd (c₀ exists). |
| C19 | S³ leaf sweep: Arithmetic ρ / Sweep η | MERGE | deferred | Y | one 2-way radio in Advanced. |
| C20 | Balance | BEHIND-MORE | deferred | Y | Advanced, beside the η slider. |
| C21 | Play η + η slider + value + help line | BEHIND-MORE | deferred | Y | Advanced; help line to ⓘ. |
| X7c | Old export: pairedModulus (M−, M+, detuning ν, theorem guard, joint degeneracy) | BEHIND-MORE | deferred | Y | with K7e. |
| K7e | Paired mirror button + rows M−/M+, theorem guard, joint degeneracy, label | BEHIND-MORE | deferred | Y | Advanced inside the Wilson card. |

17 items; ext2 = Y for 17.

Release A inner order (each step ships alone): (1) layout order and phone stack; (2) gearbox chips with drawers, delete the lanes; (3) Layers and Camera menus; (4) caption cuts and ⓘ moves; (5) Export ▾; (6) orbit-core and the cyclotomic line (addendum 5, tested against the old export at m = 7, N = 4, s = 4/7); (7) Lift JSON 0.2.

Dependencies on extraction step 2 by group: HC-3 (flank, resident pair) for K5b, K5d, K6, X7d; HC-11 (trail, rosette, stack builders) and HC-12 (scales) for F4, F5, F9-F11, F15; HC-9 (meridional sweep), HC-10 (S3LeafSweepDisplayV1) and HC-8 (orbit/knot records) for C5-C21; HC-4 (paired modulus) for K7e, X7c. Row F6 (fraction stack on Fourier) needs no host port: `fraction-stack-core.js` exists.

## 4. Questions for saphir (answerable in a word or two)

| # | question | recommended |
|---|---|---|
| 1 | Keep the gearbox row (α, n₆, t₁, t₂, m) above the view as in the original, as compact chips with drawers? | Yes |
| 2 | Remove the Presets / Continuous switch (one exact box plus a slider per dial)? | Yes |
| 3 | Pinch markers (display-only "visual analogy"): drop? | Drop |
| 4 | Noise-minima markers and the float entropy/regime in the export: drop (keep the trail)? | Drop |
| 5 | Rosette, full stack and fraction stack as one "Stack" choice? | Yes |
| 6 | Clifford weaves, meridian sweep, η leaf sweep and c₀ foliation: keep all, behind Advanced, in Release C? | Yes |
| 7 | Paired mirror (M−/M+, theorem guard): build behind the Wilson card's Advanced? | Yes |
| 8 | "FullSimplify in Wolfram Alpha" link: drop it? | Drop |

Not asked, but needs an Astra check: row L3 shows s_eff and E only when they differ from s_typed; SCHEMA R21 and addendum 2 say to show all three.

## 5. Limits of this ledger

- Per-view availability of the Fourier toggles (rosette, full stack, dots, α) is INFERRED beyond what `PLANE_ONLY_CONTROL_IDS` (L12662: pinch, stems, amber polygon, zoom lock) and the Clifford/Hopf show/hide in `syncViewMode` (L12979) say.
- v0.1 status comes from the README, BUILD_REPORT, and a headless walk of `dist/comb-hopf.html` (labels, not behaviour). I did not exercise v0.1 controls beyond that.
- The 375 px proposal is a layout budget, not a measurement of a built page.
- I did not read the lower panels' code; section 1c is from HOST_LIBRARY_MAP.md and the addenda.
