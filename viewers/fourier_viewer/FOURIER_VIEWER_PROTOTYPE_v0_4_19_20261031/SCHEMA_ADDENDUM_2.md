# Schema addendum 2: readouts, classical controls, view controls, exports

Date: 2026-10-13. Owner: Opus (B1-viewer owner session). This extends SCHEMA.md and SCHEMA_ADDENDUM_1.md, and governs where they differ.

**Authority:** saphir's messages 5 and 6, quoted in addendum 1.

**Source:** a read-only extraction of the frozen host `cold audit fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html`. "L" is a line in that file. Read the cited ranges with Read and an offset only.

**Rule (addendum 1 §E):** keep the host's look, but follow the current mathematics. Each place below where the host is float-sourced or ambiguous says what replaces it.

## 1. Classical controls (host L2690–3225, in host order)

The controls go in one shared panel above the tabs. It is collapsible on a phone.

1. **Shell base:** `n!` (default) | `integer`.
2. **n₁:** factorial buttons 3…13, default 4 (B = 24).
3. **Integer base M:** a text box and Apply. Range 2…6,227,020,800, default 24.
4. **Radial mode:** `presets` (default) | `continuous`.
   - Presets show the trinary buttons −1 / 0 / +1 for α and n₆.
   - Continuous shows the sliders.
5. **α:** buttons −1 / 0 / +1 (default +1), or a slider −8…8, step 0.01 (default 1).
   - The slider value is committed as an exact decimal string, for example "0.37" → 37/100.
   - A text box accepts an exact rational.
6. **n₆:** the same layout as α (default 1).
7. **t₁:** ◀ ▶ steppers, an exact text box (default 1), a Δ selector Δ1, Δ1/2 … Δ1/7 (default Δ1/4), and a slider −100…100.
   - ◀ ▶ add or subtract Δ exactly.
8. **t₂:** the same layout as t₁, with default 1 and default Δ1/2.
9. **m:** ◀ ▶, a select, and a direct input. Range 2…720, default 3.
10. **Tabs:** Fourier | Clifford | Hopf (addendum 1). Default tab Fourier.
11. **φ₃:** a slider 0…B+1 with ◀ ▶. Show `φ₃ = …` and `N = …`.
    - ◀ means N − 1 (φ₃ + 1) and ▶ means N + 1 (φ₃ − 1), as in the host.
    - Keyboard: ← and → do the same.
    - Default φ₃ = 2.
12. **s:**
    - A slider over [−E, E]. Moving the slider commits as a typed entry of the slider's exact decimal value.
    - **◀ ▶ are the R20 stepper. They replace the host's integer snap.** Keyboard: Shift + ← / →.
    - A "set s" text box with Apply takes fractions and products such as −3/2, 5/4 and 49*1/2.
    - Show s_typed, s_eff and E (R21).
13. **Play:**
    - **▶ s:** each tick commits s_eff + δ as a typed entry, with δ = 1/120 exact × speed. It is labelled "animated (exact increments)".
    - **▶ N:** each tick moves φ₃ by one, with the R21.4 dial rules.
    - Speed buttons: ½× / 1× / 2×.
    - Play pauses on any export (host: "Pause spin animation before exact capture").

Every control is listed in the README dial ledger: what it sets, and where it enters.

## 2. Readout cards (shared, beside or below the tabs)

### 2.1 Phasors (host `updateCards` L12340–12420)

**Rows:** `z₀ (carrier)`, then `z[±j]`, each in its tooth colour, at 11px.

**Host columns, kept:**
- the key;
- the numerical z as `re ± im i` to 9 decimals.

**Exact columns, added:**
- k_c;
- the tooth phase k_c·s/N mod 2, with its order;
- the carrier phase t₁·s (+1 if n₆ < 0) mod 2;
- the offset phase −c·t₂·s/N mod 2.

The numerical column is headed "numerical".

**More than 16 teeth:** show |c| ≤ 3 plus the two outermost, then "⋯ n more teeth — full set in the JSON export". Tapping the line expands the table.

**Q-residual card:**
- Label: `Q-residual = |Im(Σ m phasors)|`, numerical, with its bound.
- The exact SPREAD and ALIGN flags (addendum 1 §A) sit beside it.

**Comb-rule footer (m ≥ 3):** the K_m kernel formula, its zeros e^{iβ} ∈ μ_m∖{1}, and the exact current β/π = t₂·s/N.

### 2.2 Gearbox (host L12206 plus v0.3.2 `gearbox.js`)

Port v0.3.2 `analyze()` into `host-core/gearbox-core.js` (exact). Show these rows in the host's order:
- **current comb order:** `m = … · matches shell p`, or `m = … · shell successor is n₁+1`;
- **order spectrum:** `φ(m) = …; Δ = …`, where Δ = m − 1 − φ(m) is the defect;
- **first resident gear:** `g₁ = …` with the signature class (v0.3.2 `signature`);
- **ambient A = B + 1 − g;**
- **residency:** `RESIDENT` / `NOT RESIDENT` / `UNDEFINED (N = 0)`, plus `· r = N mod m`, and the stride N/m when resident;
- **code and label:** the v0.3.2 `code` and `label`;
- **gear navigation:** prev and next resident gear, as v0.3.2 `previous` / `next`, with ± buttons that set φ₃.

**Deferred to v0.2:** the host's M−/M+, theorem guard and joint degeneracy rows. Their definitions were not extracted. List them in the README as deferred.

**Resident cycle overlay on the Fourier tab:**
- The m-gon (v0.3.2 `cycle(m)`) is drawn dashed when resident: green `--accent-good` for a Wilson prime witness, amber `#a08000` stroke with `#c9a227` text otherwise.
- An "Amber polygon" toggle switches it. With the toggle off, the card says the overlay is switched off and the divisibility still holds.

### 2.3 Wilson: two distinct readouts (v0.3.2 W9 wording)

**Shell-N primality (Wilson test on N):**
- The text reads `Shell N = 7: (N−1)! mod N = 6 · N is prime`.
- It is evaluated for N ≤ 10,000. Above that it says it was not evaluated, and the comb still draws.
- The host gate line follows: `p = m · result · agreement`, or `SHELL GATE INACTIVE · set m = n₁+1, g = 0`, or `NOT ACTIVE · factorial shell required`.
- Note: "Off-Wilson residency is not a primality certificate."

**Order-m witness (independent candidate; host L6141–6188):**
- Input p, with Test and Hide. The default input 5 is shown, but it is not active until Test is pressed.
- Rows:
  - `n₁ = p − 1 = … → p = … · PRIME|COMPOSITE`;
  - `φ relation; Δ = …`;
  - `(n₁)! + 1 ≡ r (mod p)`;
  - `FULL p-gon · p vertices`, or `LOD p-gon · exact order, vertices below display resolution`.
- The p-gon is drawn on the Fourier tab while active. It is hidden when the shell changes, as in the host.
- All of it is BigInt and exact, for p ≤ 10,000.

### 2.4 Divisors (host `divisorsOnAxis` L9429, `positiveDivisorsAtMost` L9401, L12580–12620)

**Meaning:** the shells N′ ∈ [1, B+1] that align with the real axis at the current spin. A ÷ Divisors toggle shows the card and marks the shells on the φ₃ slider track.

**Current mathematics.** This replaces the host's integer shadow.
- **Exact condition:** t₂·s/N′ ∈ ℤ.
- **If t₂·s is not an integer:**
  - No shell aligns. Show `t₂·s = p/q ∉ ℤ: no shell N has t₂·s/N ∈ ℤ`.
  - The host's `round(s)` "integer shadow" is not used. It is a class (a) difference; note it in the README.
- **If t₂·s = T ∈ ℤ∖{0}:** the list is {N′ ≤ B+1 : N′ | |T|}, from the exact factorisation of |T|.
  - **Size limit.** Trial division with a declared limit of |T| ≤ 10¹⁸. Above it, the readout refuses visibly.
  - **Labels:**
    - When |t₂| = 1 and s > 0: `Div(s):`, tagged `— s is PRIME`, `— unit`, or `τ(s) = …, composite`.
    - Otherwise: `shell contacts N | |t₂·s| = T — NOT Div(s):`, tagged `— shell-truncated` when T > B+1.
- **Degenerate cases:**
  - s = 0 or t₂ = 0: "all shell N align because t₂·s = 0 — no finite Div(0) or τ(0)".
  - n₆ = 0: the divisibility list is still shown, with the note "ρ = 0: every tooth sits at the origin; the divisibility still holds". This follows v0.3.2 W7: draw and label, never hide.

### 2.5 Shell card

- **contrast:** (φ(N−1) + φ(N+1)) / (2φ(N)) (host `getHarmonicContrast` L7146).
  - It is computed **exactly as a rational** from exact totients (factor N ± 1 by trial division; N ≤ 6,227,020,801 is fine).
  - It is shown as a fraction and as a labelled decimal.
  - It is undefined for N < 2.
  - Colour: above 3, `--accent-defend` with 🔒; above 2, `--accent-warn`; otherwise `--text-dim`.
  - The same value appears in the Fourier overlay, as in the host.
- **Shell bracket B(N−1, N+1):** TWIN / LEFT_PRIME / RIGHT_PRIME / NULL, by exact primality of N ± 1.
  - Use deterministic Miller–Rabin with the bases that are proven for n < 3.3·10²⁴, or trial division.
  - State the method in the README.

## 3. Fourier overlays

- **Kept from the host:**
  - `N = …`;
  - `Q-res = …` (numerical), with ★ and green at s ∈ ℤ, cyan otherwise;
  - `contrast = …` (exact, as in §2.5);
  - `s ∈ ℤ → sin(sπ) = 0`.
- **Noise minima and the trail** (host `buildTrail` L7808):
  - The builder may read L7808–7900 and port them into `comb-numeric.js`.
  - Both are numerical register. Label them "numerical minima of Q-res along the trail".
  - Both are disabled at exact ALIGN.
  - If the port is unclear, defer both and say so.
- **Deferred to v0.2,** listed in the README:
  - the rosette (about 520K dots; phone performance);
  - full stack, fraction stack, stems, dots, stack α;
  - pinch markers.

## 4. View controls, per tab

- **Fourier:**
  - drag pan, wheel and pinch zoom (0.5–1000);
  - `+ / − / ⟲`, ✥ pan, 🔓/🔒 zoom lock, ⛶ fullscreen, and a zoom readout;
  - toggles: Amber polygon, ÷ Divisors, Noise minima (if ported), Teeth, Walk.
- **Clifford:**
  - drag rotate; Shift + drag or ✥ to pan; wheel and pinch zoom (0.25–8);
  - presets Top, Side X+, X−, Y+, Y−, and Reset; ⛶ fullscreen;
  - toggles: Tρ leaf (on), s-orbits (on), Grid (on), Four circles (off).
  - **Deferred to v0.2:** the Hopf and opposite weaves with Fill and Play, the S³ leaf sweep (η), the slice grid, and the orbit-branch filter.
- **Hopf:**
  - drag rotate, wheel and pinch zoom (0.65–1.45);
  - q₁±, q₂±, q₃± (view from that axis), and Reset; ⛶ fullscreen;
  - the chart toggle (addendum 1 §C); tap to select a tooth.

View state goes in the URL address (drawing register) and stays out of the exact export.

## 5. Exports (export bar; host L3215–3219, `buildExportData` L14715)

All exports pause play first.

| Button | Content |
|---|---|
| 📄 Export JSON | Canonical exact export (SCHEMA §7, "Export exact"), schema id `fv-comb-hopf/0.1`. It includes `liveFormula` = `z_c = n₆·N^α·exp(i·(N·t₁+c·t₂)·s·π/N)`, the full tooth set, and the gearbox, Wilson, divisors and shell records |
| Export state | The state address alone, canonical |
| 📊 Export CSV | One row per tooth: c, k_c, tooth phase, order, carrier phase, offset phase, and numerical re and im |
| 📋 Copy Stats | A plain-text summary of the cards, sent to the clipboard, with a fallback text box |
| ⬡ Export Lift JSON | Per-tooth S³ lift: exact phases plus numerical z₁, z₂, the projected point and its status, and the S² point. Schema id `fv-comb-hopf-lift/0.1`. **Do not reuse the host's schema ids**; the README names the host's `fvlt-plane-clifford-lift-v2` as the comparable format |
| 🖼 Export PNG | The active tab, as in the host. The SVG is serialised, `var(--x)` values are replaced by their computed values, and it is drawn into a 2× canvas filled with the body background, then `toBlob` |
| Export pair (R17) | PNG + exact JSON + state, plus a small pair JSON naming all three SHA-256 values |

- **Filenames:** `fvlt_fourier_<tab>_m<m>_<shellTag>_s<s-sanitised>_<stateHash8>.<ext>`.
  - shellTag is `n4f` for a factorial shell or `M24` for an integer one.
  - The state hash replaces the host's Date.now(), so names are reproducible.
- Every export shows its SHA-256 in the page.

## 6. Tests to add (`test-core.cjs`)

- **Gearbox:** analyze() against v0.3.2 `gearbox.js` on 2,000 random states. Load it read-only, compare, and list any difference.
- **Wilson:** the shell-N test for N = 2…200 against trial-division primality. The order-m witness for p = 2…200.
- **Divisors:**
  - exact cases: T = 12, B = 24 → {1, 2, 3, 4, 6, 12}; non-integer t₂·s; s = 0; t₂ = 0; shell truncation;
  - the refusal above the size limit.
- **Contrast:** exact values at N = 5, 6, 7, 30 against hand-computed totients.
- **Shell bracket:** N = 4 (3, 5 → TWIN) and N = 8 (7, 9 → LEFT_PRIME).
- **SPREAD flag:** the exact K_m = 0 condition against numerical |K_m| < 1e-9 at 2,000 random states. Any disagreement fails.
