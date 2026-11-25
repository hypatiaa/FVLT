# Fourier viewer prototype v0.1: build schema

Date: 2026-10-13. Owner: Opus (B1-viewer owner session "Fourier viewer track", `local_e47d17a4…`).
Authority: saphir, 2026-10-13: "we need to get a working prototype of the new viewer coded. Just build a quick schema, and let's just rock it out", then "use subagents to save compute".

**Status:** a working prototype that follows the draft requirements v0.1.7 (`cold audit fourier/VIEWER_REDESIGN_REQUIREMENTS_v0_1_7_20261012/`, unadopted, discipline HOLD #383). It is not a release, it does not replace the frozen references, and it does not claim R18 parity. The frozen references are read, never edited (R19).

## 1. Scope: first instrument

**Comb walk → Hopf base S².** This is the divisor comb walk of `cubic_Fourier/DIVISOR_COMB_RIEMANN_v0_3_2_20261012/` (frozen reference), rebuilt on the new structure. It is drawn on the host's Hopf base sphere at scale A (fit review `cubic_Fourier/OPUS_FIT_REVIEW_COMB_TO_HOST_HOPF_20261011/REPORT.md` §3).

**Out of scope for v0.1:**
- the S³ lift and the gcd orbit;
- the energy workbench;
- the other cores;
- the offline certificate verifier, beyond a stub that the exact export can be checked by.

## 2. Tree (requirements §5)

```
FOURIER_VIEWER_PROTOTYPE_v0_1_20261013/
  SCHEMA.md                      this file (never edited by the builder)
  exact-lib/exact.js             R6 subset: BigInt rationals, exact parse, floor/ceil,
                                 canonical serializer, strict JSON parser, SHA-256 (pure JS)
  exact-lib/test-exact.cjs
  host-core/comb-core.js         exact register only: shell, teeth k_c, phases, stop
                                 families, R20 stepper, R21 spin address, wrap gate
  host-core/comb-numeric.js      numerical register: tooth coordinates, walk partial sums,
                                 Hopf points, each with an error bound
  host-core/test-core.cjs        node, no browser
  host-core/reference-stops.cjs  independent R20 reference for the tests; shares no code
  instruments/comb-hopf/panel.js     renders and holds controls only (drawing register)
  instruments/comb-hopf/index.html   multi-file dev page
  instruments/comb-hopf/README.md    dial ledger plus degenerate cases (R5d)
  build/package.cjs              dev-time only: inlines sources into one HTML file
  dist/comb-hopf.html            delivered single file (R1–R4)
  dist/MANIFEST.sha256           digest per module plus the dist page (R13, R13a)
  BUILD_REPORT.md                what was built, the commands run, and the test output
```

Every module is a UMD-style IIFE (`module.exports` in node, one global in the browser), as in the v0.3.2 sources. There are no dependencies and no npm installs.

## 3. Registers (R7)

- **Exact** (`exact.js`, `comb-core.js`): BigInt rationals {n, d}, with d > 0 and gcd = 1. No `Number` arithmetic sources any exact statement.
  - A phase is an exact rational q taken mod 2 (meaning exp(iπq)). Its representative lies in (−1, 1].
  - The cyclotomic order of exp(iπq) is the reduced denominator of q/2 = q.n / (2·q.d) after reduction.
- **Numerical** (`comb-numeric.js`): floats derived from exact phases.
  - Every value carries a field `bound`, a stated absolute error bound. A simple, conservative bound such as 8·m·ε·max(ρ,1) is enough for v0.1, provided the formula is stated in the README.
  - Numerical values are labelled "numerical" wherever they are shown.
- **Drawing** (`panel.js` only): screen coordinates, rotation, cos and sin used for display.

## 4. Mathematics (unchanged from v0.3.2)

- **Shell:**
  - B = n₁! (n₁ = 3–13), or an integer B (2 … 6,227,020,800).
  - Gear φ₃ ∈ [0, B+1], and N = B + 1 − φ₃.
  - N = 0: no walk. Draw the empty state, labelled.
- **Offsets c:** for odd m, c runs over −(m−1)/2 … (m−1)/2. For even m, c runs over −m+1, −m+3, …, m−1. The tooth count m is 2 … 720.
- **Teeth:**
  - k_c = N·t₁ + c·t₂, phase φ_c = k_c·s/N (exact, mod 2), and z_c = ρ·exp(iπφ_c), with ρ = n₆·N^α.
  - ρ is numerical; α and n₆ are exact inputs with |α|, |n₆| ≤ 8.
  - Underflow or overflow is refused visibly (v0.3.2 D3).
- **Walk:** W₀ = 0 and W_t = W_{t−1} + z_{c_t}, in offset order.
- **Exact readouts:**
  - N, m, k_c, φ_c, the order of each tooth phase;
  - spread t₂·s/N, and pair alignment (spread ∈ ℤ);
  - all-aligned: for odd m, spread ∈ 2ℤ; for even m, spread ∈ ℤ;
  - the Wilson readout on N for N ≤ 10,000.
  - These come from v0.3.2 `comb-core.js` / `gearbox.js`; port the logic, do not copy the file.
- **Hopf base S², scale A (host chart):**
  - A point w maps to (2 Re w, 2 Im w, |w|² − 1) / (|w|² + 1).
  - That is the host's (2 Re z₁z̄₂, 2 Im z₁z̄₂, |z₁|² − |z₂|²) with (z₁, z₂) = (w, 1)/√(1+|w|²). South pole w = 0, north pole w = ∞.
  - **Drawn:**
    - the walk vertices W_t;
    - each walk edge, sampled in the plane and mapped;
    - the tooth latitude circle at height (ρ² − 1)/(ρ² + 1), which is where every z_c sits;
    - the equator.
  - **Gate:** W₁ = z_{c₁} lies on the tooth latitude to within its numerical bound. Report this as a numerical check.
  - **Chart toggle:** "host chart w = W" (default) or "comb-page chart w = W/ρ" (v0.3.2 scale B), labelled.

## 5. Spin stepping: R20 exactly

Implement R20 parts 1–6 as written in REQUIREMENTS v0.1.7 l.185–239.

**Stop families:**
- **ALIGN:** s ∈ (1/|t₁|)ℤ.
- **SPREAD:**
  - Guard: n₃ = N > 0, m ≥ 3, t₁ ≠ 0, t₂ ≠ 0, and t₁, t₂ integers.
  - Odd m: numerators 2N|t₁|r mod 2mN|t₁|, r = 1 … m−1.
  - Even m: numerators N|t₁|k mod mN|t₁|, k = 1 … m−1.
  - All over D = m|t₁||t₂|. Label each stop with its order m/gcd(r, m).
  - This is the family set of v0.3.2 `control-math.js nextSpin`, which is the reference definition. Check it against that code; do not copy it.
- **PAIR (m = 2):** the integer lattice ℤ, with its own guards.

**Inactive stop sets:**
- A comb mode with non-integer gears, t₁ = 0, t₂ = 0, or N ≤ 0 is **refused (4e)** with the reason.
- There is no integer-snap fallback. This is a class (a) difference from v0.3.2 and the host.

**Selection:**
- floor and ceil on exact rationals, taking the extreme over the families.
- No epsilon anywhere.
- ALIGN wins ties, and coincident families are reported (4b).

**Range and outcomes:**
- Range [−E, E]. Outcome order: refused, then stop, then range-limit landing, then no movement.
- No stepping wrap.
- Size: BigInt throughout, so no size limit is declared. If one is ever needed, it is declared and refuses visibly.

## 6. Spin address: R21 exactly

**State:** s_typed, s_eff, E, all exact.

**Typed entry:**
- An exact decimal, a fraction, or a product written with `*`, as in v0.3.2 `spin()`.
- A wrap mod 2N into (−N, N] applies only if N > 0 and every k_c ∈ ℤ.
- That is the planar-walk gate. It is kept as a conservative gate at ρ = 0 too (Astra #383).
- s_eff is the representative; s_typed is kept. Both are shown and labelled when they differ.
- When the gate is closed: s_eff = s_typed, labelled "kept: wrap not invariant here".

**E:**
- E = max(N, |s_eff|).
- Recomputed on typed entry, on N change, and on any dial change that re-derives s_eff.
- Never recomputed by a step.

**A step:**
- It starts from s_eff.
- A stop or range-limit landing commits the exact value to both s_typed and s_eff and keeps E. No wrap is applied.
- A refusal or no movement changes nothing.

**Dials:** a dial change never rewrites s_typed. s_eff is re-derived by the gate, then E is recomputed.

## 7. State address and export (R9, R10)

**URL fragment:** `#v=fv-comb-hopf/0.1&…`. Keys:
- shellMode, n1, B, phi3, m, t1, t2, n6, alpha, chart;
- sTyped, sEff, E.

All values are exact strings ("p/q" or an integer).

**Load validation (R21.5):**
- E is exact, E ≥ N, and E ≥ |sEff|.
- sEff = sTyped, or sEff is the declared representative of sTyped under an invariant wrap.
- sEff is restored as stored and never re-derived.
- Any failure refuses the whole state: show defaults plus the reason.

**"Export state":**
- Canonical JSON (R18.2): sorted keys, compact, ASCII, integers and rationals as decimal strings, one trailing LF. The file holds the state address plus a schema id.
- **"Export exact"** adds the exact readouts: k_c, φ_c, orders, spread, flags, and the last step outcome with its families.
- Both show SHA-256 of the bytes.
- The page offers a download (Blob). It also shows the text in a copyable box, because phones vary.

## 8. Panel (R3, R17)

**Layout:**
- Phone first at 375 px: controls in a collapsible card, two views stacked, and no horizontal scroll. At 1280 px, the views sit side by side.
- Dark and light follow `prefers-color-scheme`.

**Views:**
- **(1)** The planar walk: teeth as vectors, partial sums, the endpoint, and the radius circle ρ.
- **(2)** The Hopf base sphere, orthographic, rotated by drag or touch, with the walk, the tooth latitude circle and the equator. The front and back hemispheres are styled differently.

**Controls:**
- shell mode, n₁, B, φ₃ with ±;
- m, t₁, t₂, n₆, α;
- the s typed field with Apply;
- spin ◀ / ▶;
- the chart toggle, Export state, Export exact, Import state (paste).

**Readouts:**
- **Exact:** N, k list (first and last few when m is large), spread, alignment flags, s_typed / s_eff / E, and the last step outcome with its label.
- **Numerical:** |W|, |W|/ρ and the gate residual, each with its bound and labelled "numerical".

**Rendered elements:** SVG elements carry `data-role` and `data-c` / `data-t` attributes (R17).

**Degenerate cases are drawn and labelled, never hidden:**
- N = 0;
- ρ = 0, where every vertex is at the south pole: label it;
- stepping unavailable, with the reason;
- underflow refusal.

## 9. Tests (`test-core.cjs` and `test-exact.cjs`; node only; one PASS/FAIL line each)

**exact-lib:**
- rational normalisation, parse round-trips, floor/ceil signs;
- canonical serializer bytes;
- the strict parser rejects duplicate keys;
- SHA-256 known vectors ("", "abc").

**R20:**
- The #245 named cases:
  - N=1, m=720, t₁=−3, t₂=−2, s=−1, forward → −1439/1440;
  - N=13!+1, m=7, t₁=t₂=3, s=10⁶, both directions: no ALIGN stop skipped.
- Endpoint cases (i)–(v), at l.234–238.
- A no-skip property check on every case.
- A random sweep of at least 5,000 states, including m up to 720 and dense settings, against `reference-stops.cjs`.
  - The reference is independent: it enumerates the family elements near s₀ and takes the nearest strictly in the direction, with no shared code.

**R21:**
- the D1 witness: B = 4!, N = 24, m = 3, t₁ = 1/3, t₂ = 1/2, typed 49 → kept, s_typed = 49;
- an invariant-wrap case showing both values;
- the dial-change cases, including play through N = 0, and a t₁ change that closes the gate (s_eff back to s_typed, E grows);
- R21-S, R21-R, the R21-EFF-REPLAY round trip, the mirror case, and the two histories;
- the unchanged-outcome byte-identity case;
- the import refusal controls.

**Numerical:** for 500 random states, the gate residual lies within its bound and the Hopf points have unit norm within 1e-12.

**Parity sample (informative, not R18):**
- for 2,000 random integer-gear states, compare the exact phases and stop values with v0.3.2 `comb-core.js` / `control-math.js`, loaded read-only from the frozen folder;
- list every difference with its class: (a) mandated by R20/R21, or otherwise unexplained (report it, do not hide it).

## 10. Build (R1, R2, R4, R13)

- `node build/package.cjs` inlines exact.js, comb-core.js, comb-numeric.js and panel.js into `dist/comb-hopf.html`.
- `<meta charset="utf-8">` is in the first 1024 bytes. There is no changelog in `<head>`.
- The page contains no `http(s)://` in any `src` or `href`.
- `dist/MANIFEST.sha256` lists every module and the dist page.
- Node is dev-time only. The delivered page needs nothing.
