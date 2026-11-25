# U1/P1 implementation decisions

The saved U1_P1_BUILD_PROMPT_CLAUDE_OPUS_20260923.md remains the controlling prompt. The following are the agreed clarifications from Robin and Opus; they do not reopen the design.

1. **Adapted versus marked addresses.** beta in {0, 1/2} applies only to the real-adapted basis. Store the component indicator separately. Marked addresses use the inherited inverse-transpose SL2 coordinate transport and may have any beta. Preserve both records and the exact marking matrix.
2. **Acceptance tolerances.** A printed PARI decimal is a rounded reference, never proof input. Its interval is one half-unit in the last printed decimal place on either side (about half of 10^-30 at the specified precision, with the decimal exponent accounted for). The independently produced enclosure must intersect that reference interval. The addresses 1/3, 2/3, 1/6, 5/6 and 1/2 on y^2=x^3+1, and the half-periods on y^2=x^3-x, are exact rational references: the produced enclosure must contain the exact fraction. Never round an enclosure to a rational or use a reference to alter a computed enclosure.

## Implementation choices

- Use 192-bit outward-rounded dyadic intervals. Cubic roots are isolated by exact rational sign changes; periods use real AGM bounds and a rigorously bounded Machin series for pi.
- Positive-discriminant and negative-discriminant formulas use one documented engine. The negative-discriminant formulas include the formerly special rotated square.
- U1 computes on the exact final model chosen by the current T4 transport. Its model differential is Neron-normalized only when the current signed T4 response certifies global reduction. Signed selected differentials remain separate from the positive total real measure.
- U1 may supply a Neron total real-period interval to the actual comparison. This path computes no L-value, ratio or Sha; missing inputs remain missing.
- Scope is bounded: inputs outside the documented rational, coefficient, marking, width or work limits return UNAVAILABLE. No finite-precision promise covers every possible coefficient size.
- For B>0 at j=0, the positive primitive-real adapted basis can have tau=1/2+i/(2*sqrt(3)); this is a hexagonal lattice, modularly equivalent to the familiar hexagonal basis. Do not force tau=e^(i*pi/3) while keeping the wrong real primitive period.
- Build began on 2026-09-23; completion receipts carry their actual execution dates. The package name retains its start date.

## Deferred

P1 follows sealed U1. M4 (atom adapter) is a separate later deliverable and has not been started. Heights, regulator, exact rank/basis/saturation, L-values, Sha, Fourier coefficients, twists/characters, a general torsion fallback, and the irrational-step slider remain out of scope.

## P1 implementation choices

- Real logs use the sealed U1 Taylor/Cauchy interval integration primitive with the explicit real substitutions in P1_PROOF.md. The precision/work limits refuse honestly.
- The marked torus is shown in its flat square representation with opposite edges identified, beside the actual period parallelogram. Both show uncertainty boxes; the inherited Clifford display remains separate.
- The comparison orbit is a separately pinned/replayed C6 example with model-differential periods, never active-curve arithmetic.
- M4 remains a separate later deliverable. Its deferred design retains character-order spectral laws weighted by phi(d), odd/even conditions and the L-I union rule (m=1 nullity q), explicit noncyclic subgroup identities, W_Q only for exact divisors Q || N on the newform, a separate verified root-number path, and the vertical-coordinate name exponent sum. No M4 implementation was started.
