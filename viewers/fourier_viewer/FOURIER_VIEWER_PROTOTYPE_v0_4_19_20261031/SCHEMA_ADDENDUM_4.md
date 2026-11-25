# Schema addendum 4: Panels tab (placeholders in v0.1)

Date: 2026-10-13. Owner: Opus (B1-viewer owner session).

**Authority.** saphir, 2026-10-13:
- "the panels below here, with all the panels, need their own tab."
- "I am taking out the rank 4 work, it needs its own viewer".
- "it may be that eventually, the cat (0) - divisor atom needs its own tab also" and "it's kind of in there".

**Source.** A read-only inventory of the frozen host (L-numbers from `monodromy-31-linked-reduction.html`).

## Tab

`Panels` is the fourth tab, after Hopf.

**Toolbar.** "Collapse panels" and "Open panels", as in the host.

**Cards.**
- Each card is a collapsible `<details>`, grouped as below.
- The open/closed state is stored per viewer in localStorage. It is wrapped in try/catch, and the page works without it.
- v0.1 cards are placeholders, each with:
  - its title;
  - one line saying what it computes;
  - its register (exact, float or mixed);
  - its state coupling;
  - "not yet rebuilt — frozen source: host <block> L<range>".

**Module interface (for later rebuilds).**
- A panel is a module `{id, title, group, render(el, model), actions}`.
- It reads the shared model.
- A panel that changes shared state does so only through the state's commit functions, so the R21 rules apply. Setting s from a panel is a typed entry, and setting φ₃ is a dial change.
- A panel never writes another module's state directly (R9).

## Groups and cards (host order within each group)

### A. Comb and contacts (Fourier-native)

1. **Orbit point index**
   - Source: `OrbitPointIndexV26`, L11360+.
   - Shows nearby generated orbit addresses, with θ₁/π and β/π exact.
   - **Writes:** s (±Δs) and the foliation β.
2. **◎ Contact sweep**
   - Source: CONTACT_SWEEP_V0_1_1, L19032–19929. Schema `fourier_contact_sweep_snapshot` 0.2.0.
   - Exact real-axis contacts of the lower tooth over shells 2…Q+1.
   - **Writes:** s, t₁ and t₂ (Seek, Apply canonical).
3. **⋔ Tooth contacts**
   - Source: COMBINED_BCD_V0_1_TOOTH_CONTACT, L21926–23122.
   - Contacts for the selected teeth c (k = N + c).
   - **Writes:** s (Place, Seek).

### B. Shell and divisor arithmetic

4. **∑ Basel cone**
   - Source: BASEL_LINK_V0_1_2, L19930–20625.
   - Z_B(β) over the divisors of B, with the divisor lattice and the π(x) staircase.
   - Reads B only.
5. **Reciprocal record**
   - Source: COMBINED_BCD_V0_1_RECIPROCAL, L20626–21088.
   - Prime-labelled factors of the selected divisor. The schema is 0.1.0, exported as canonical JSON.
6. **π(B) shell prime count**
   - Source: COMBINED_BCD_V0_1_SHELL_PRIME_COUNT, L21089–21925. Schema `shell_prime_count_readout`.
   - Reads B, t₁, t₂ and n₆.
7. **G. Robin margin**
   - Source: RH_MARGIN_V0_1, L23123–23877. Schema `rh_atom_margins` 0.1.0.
   - σ(B)/B against the certified enclosure of e^γ ln ln B, plus the Nicolas test.

### C. Mcomb atom, Cayley and divisor concepts

8. **Cayley graph & kernel · M3**
   - Source: MCOMB_CAYLEY_V1, L17215–17409. Export `mcomb-cayley-m3-capture.json`.
   - Exact Cayley record of the host state.
9. **Atom explorer · exact divisor addresses (M4)**
   - Source: L18557–18732; summary at L18559.
   - **Divisor-atom tab candidate, together with card 12** (saphir, 2026-10-13: "under divisor concepts, and atom explorer").
10. **M5 structure**
    - Source: L18732+. Export `mcomb-m5-structure-setting.json`.
11. **M6 shell walk**
    - Source: L18813+. Export `mcomb-m6-walk-setting.json`.
12. **Divisor concepts · FCA and order-aware walks · M7 (the divisor atom)**
    - Source: `McombFCAV1` to L18951; `divisorPosition` L18955–18971; schema `MCOMB_FCA_CONTEXT_V1`.
    - The divisor lattice as exponent tuples.
    - FCA contexts: ordinal, Birkhoff, nominal and strand.
    - Hasse views in 2D and 3D.
    - Fixed-coordinate faces, where `*` is free.
    - **Candidate for its own tab** (saphir: possibly the CAT(0) / divisor-atom tab). The host has no explicit cube, median or link code. The box-face structure is implicit in the fixed-coordinate faces.

### D. Elliptic and BSD (placement pending saphir; see below)

13. **Mcomb → elliptic curve → BSD**
    - Source: MCOMB_ELLIPTIC_LINK_V1, L16721–16930.
14. **Carrier addition**
    - Source: MCOMB_CARRIER_ADDITION_V1, L17023–17193.
15. **Exact curve · BSD evidence, with its linked children**
    - Source: BSD_CURVE_RECORD_V1 L16444–16673 and BSD_LINKED_VIEW_V1 L17411–18908.
    - Children: prime counts, PT1, U1, P1 and Spectral.
16. **Clifford elliptic bridge**
    - Source: ELLIPTIC_BRIDGE_V27, L16100–16406.
    - **Writes:** the Clifford leaf.
17. **Arithmetic–Fourier**
    - Source: ARITHMETIC_FOURIER_V0_1, L23878–25361.
    - Reads the exact curve model. Its atom n is its own input.

## Not in the Panels tab

- **Alpöge rank-4 certificate card**, `#monodromy-ledger-card` (L3227): this goes to the separate Rank-4 viewer.
- **Spectral gearbox card** (L3276): this is already the v0.1 Gearbox card. Its paired M−/M+, theorem guard and joint degeneracy rows stay deferred (addendum 2).

## Open placement questions (saphir decides; v0.1 shows group D as placeholders either way)

- Does group D (elliptic / BSD) stay in this viewer, or go with the Rank-4 work to its own viewer?
- Do cards 9 and 12 (the atom explorer and the M7 divisor concepts, which together make up the divisor atom) move to their own tab now or later?
