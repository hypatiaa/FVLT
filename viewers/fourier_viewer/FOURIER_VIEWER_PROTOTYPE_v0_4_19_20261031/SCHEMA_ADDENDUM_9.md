# SCHEMA ADDENDUM 9: comb-hopf v0.4.1 (2026-10-19)

**Status:** builder's record for v0.4.1, an additive successor of v0.4 in its own folder. It is not reviewed yet.

**Credits:**
- saphir: the requests ("I want it. I also want the foliation controls for the carrier, which I don't see.");
- the merged viewer's v0.8.8-fix.5: the foliation design (read for meaning only; no code copied);
- Claude Fable 5.1: the mirror-axis feature note;
- Codex: review #539;
- Claude Opus 5.5: v0.4.1.

**Amends:**
- SCHEMA.md: the n₁ range 3–13;
- the integer-base lower bound 2;
- SCHEMA_ADDENDUM_2: "★ and green at s ∈ ℤ".

Everything else stands.

## 1. Shell range (domain change)

| Dial | v0.4 | v0.4.1 |
|---|---|---|
| n₁ (factorial mode) | 3–13 | **1–13**: B = 1! = 1 and B = 2! = 2 become selectable |
| B (integer mode) | 2–6,227,020,800 | **1–6,227,020,800** |

- **Refusal wording.**
  - n₁: "Factorial index n₁ must be 1–13." (was "3–13").
  - B: "Shell base must be 1–6,227,020,800." (was "2–").
  - Every other refusal is unchanged.
- **Schema ids are unchanged.** That covers address `fv-comb-hopf/0.2`, state, exact, Lift, pair and build pins.
  - The change is backward compatible: every state valid before is still valid, with byte-identical output (tested, §4).
  - It is not forward compatible: v0.4 and earlier refuse an address with n₁ ∈ {1, 2} or B = 1, with their old range reason.
- **The n₁ select** offers 1…13. ◀ n₁ stops at 1. Nothing else on the surface changed, so the cap of 40 visible controls and the first-screen rule are untouched.

### B = 1 and B = 2 audit

N = B + 1 − φ₃ ∈ [0, B + 1], so N ∈ [0, 2] at B = 1 and N ∈ [0, 3] at B = 2. Between shells (continuous mode), N can be any rational in that interval.

| Readout | At B = 1 or 2 |
|---|---|
| N = 0 (φ₃ = B + 1) | the empty state, unchanged: no walk; orbit-core branches `undefined`; comb-numeric `empty`; stepping inactive |
| Wilson shell-N | N = 1: "N = 1 is not prime." N = 2, 3: evaluated ((N − 1)! mod N) |
| Wilson gearbox (p = m = n₁ + 1, g = φ₃ = 0) | n₁ = 1, m = 2: N = 2 = 1! + 1, WILSON_PRIME_RESIDENT. n₁ = 2, m = 3: N = 3 = 2! + 1, WILSON_PRIME_RESIDENT. Other gears: the usual codes |
| Shell contrast | undefined for N < 2 ("undefined (N < 2)"); N = 2: 3/2; N = 3: 3/4 |
| Shell bracket B(N − 1, N + 1) | shown only for N ≥ 2 |
| Divisors | the list is limited to shells N′ ≤ B + 1 (unchanged rule) |
| Fraction stack | span B + 1, unchanged rules; idle between shells and at N = 0 |
| Shell reference field ℚ(ζ_B) | ℚ(ζ₁) or ℚ(ζ₂). Both equal ℚ; the label text is unchanged (it was already ℚ(ζ₂) at B = 2) |
| Between shells (e.g. B = 1, φ₃ = 1/2, N = 3/2) | the between-shells label in every shell readout, as in addendum 8 |
| Exports | exact, state, Lift and pair as before; no new field |

**Not changed (pre-existing, recorded here):** at N = 0, on every shell, `wilsonN` carries the label "N = 1 is not prime." That label is in the exact export. Correcting it would change the exact export of states that were already valid, which §4 forbids, so it is left for a decision.

**Interaction, unchanged rule:** changing the shell to a smaller B clamps φ₃ to at most B + 1. From the default φ₃ = 23, choosing n₁ = 1 or n₁ = 2 therefore lands on φ₃ = B + 1, that is N = 0, the empty state, labelled as such.

## 2. The ★ (amends SCHEMA_ADDENDUM_2)

- **Condition.** ★ and the green caption now mean **t₁·s ∈ ℤ** (exact), not s ∈ ℤ.
  - Then the phasors of each pair ±c are complex conjugates, the lab-frame sum W is real, and Q-res is 0 up to the numerical bound.
  - t₁·s ∈ ℤ is the exact ALIGN condition.
- **Caption wording:** "… SPREAD yes/no ★ lab sum real · Q-res …".
- **Counterexample (review #539):** N = 5, offsets ±1, ±3, ±5, t₁ = 1/2, t₂ = 1, s = 1, ρ = 1. Here s ∈ ℤ but t₁·s = 1/2, and the resultant is −i. The page shows no ★.
- **Two new rows in the exact-flags card:**
  - "carrier-relative W·e^{−iπ(t₁s+f)} real at every s (identity, symmetric offsets)", followed by its imaginary part. That value is labelled numerical and carries the bound.
  - "lab-frame W real (t₁·s ∈ ℤ, exact)", reading yes ★ or no.

## 3. Carrier foliation (display register)

**What it draws.** The orbit foliation of the carrier action (λz₁, z₂) on the active leaf |z₁| = a, |z₂| = b: the longitudes (a·e^{iθ}, b·e^{iβ}), θ ∈ [0, 2π), one per transverse phase β.
- Lift convention: z₁ = a·e^{iπ(t₁s + f)}, z₂ = b·e^{−iπ·c·t₂·s/N}.
- β = 0 and β = π are the mirror's fixed longitudes (the v0.4 reference longitudes).
- A tooth c runs along a carrier longitude exactly when c·t₂ = 0:
  - for an odd comb, the c = 0 tooth, along β = 0;
  - for an even comb, none;
  - at t₂ = 0, every tooth.

**View keys.** They are drawing register: they travel in the address `view` string and are excluded from the exact export.

| Key | Default | Meaning |
|---|---|---|
| `cff` | `0` | Carrier foliation layer, off by default; the toggle is visible in the Clifford Layers menu |
| `cfk` | `24` | leaf count K ∈ {6, 12, 24, 120}: the faint family at β = 2πj/K, j = 0…K − 1 |
| `cfb` | `0` | selected k, β/π = k/120, k mod 240 |

**Selected curve and readouts.**
- The selected β is drawn white and solid, and its companion β + π white and dashed. Both values are shown exactly as (k mod 240)/120·π reduced, for example k = 30 gives 1/4·π.
- The readouts in the Layers menu state the family, the selected and companion β, the teeth on the foliation, and the merged viewer's sentence: "A raw gcd d > 1 changes traversal multiplicity only; it does not quotient the transverse β-circle".
- There are no new branches, heads or export fields.

**Guards.**
- t₁ = 0: the carrier action is trivial, and each of its orbits is a point. The family is drawn as one point per β at the carrier phase, with a degenerate caption line.
- Collapsed leaf (a = 0 or b = 0, which means ρ = 0 within the drawable range): nothing is drawn, with a degenerate caption line.
- N = 0: no numerical model, so nothing is drawn.

**Hopf base: Clifford only.** Under the Hopf map, every carrier longitude, whatever its β, projects onto the same latitude circle |z₁|² − |z₂|² = (ρ² − 1)/(ρ² + 1). That circle is already the tooth latitude on the Hopf tab, so β cannot be seen on the base, and nothing was added there.

**Controls.** All of them sit in the Clifford Layers menu:
- the toggle;
- in Advanced, the leaf-count select and the steppers ◀◀ β (−π/12), ◀ β (−π/120), β ▶ and β ▶▶.

The instrument panel count (nothing opened) is unchanged.

## 4. Tests of record

- `host-core/test-v041.cjs`: the shell range, the B = 1, 2 audit over every shell position in both N modes, and the byte-identity with the v0.4 modules for previously valid states (the 408-state preset grid plus 1,600 random states); also the ★ and the foliation geometry, labels and guards.
- `build/browser-check-v041.cjs`: the n₁ select, the new shells on every tab at 375×812 and 1280×800, the ★ counterexample, and the foliation controls, geometry and guards. With the foliation off, the Clifford render is byte-identical to the v0.4 page.
- The v0.3 and v0.4 suites run unchanged. Their results are in BUILD_REPORT "v0.4.1".
