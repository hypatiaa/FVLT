# Two Fourier readings of the unit orbits modulo seven

The doubling orbits of units are A = {1, 2, 4} and B = {3, 5, 6}. This package uses them on two different inputs.

* **Seventh-root phasors.** For a primitive seventh root ζ, sum ζᵃ over each triangle. The two values add to −1, multiply to 2, and their difference squares to −7. These identities hold in every commutative integral domain containing such a root. [Phasor theorems](FareyOrbitPhasors.lean)
* **Farey ranks.** Let A_N(a/7) count all positive reduced fractions up to a/7 with denominator at most N, including an endpoint when present. Write m = A_N(1) and D_N(a/7) = A_N(a/7) − ma/7. The difference of the two triangle totals, divided by six, is the quadratic Fourier coefficient of these six rank errors. [Rank counts and exact order-40 data](FareyOrbitSeven.lean)

For every natural order N the coefficient is

$$
\frac{1}{6}\sum_{k=1}^N \left(\frac{k}{7}\right) M(\lfloor N/k\rfloor),
\qquad M(t)=\sum_{j=1}^t\mu(j).
$$

Here the symbol is the Legendre symbol from Mathlib, including value zero at multiples of seven. The inversion uses the trivial character of modulus one so all original denominators enter. The factor 1/6 averages over the six units. The factor seven inside the integer proof clears the denominator of each rank error. [Inversion from primitive pairs](FareyRankInversion.lean) · [Character coefficient and energy inequality](FareyQuadraticProjection.lean)

At N = 40 there are 490 positive fractions. In increasing numerator order the six errors are (0, 1, 0, 0, −1, 0). The A-minus-B contrast is 2 and the normalized coefficient is 1/3. The square of this coefficient is at most the mean squared error of the six anchors. A uniform upper estimate on the joint energy as the denominator grows remains open. The other odd-character components and the all-modulus Parseval expansion in the catalog are outside these declarations.

## Replay

On November 28, 2026, Nucleus compiled all five source modules in a fresh directory with warnings treated as errors. All five passed `leanchecker`. The 15 public theorems added here use only subsets of `propext`, `Classical.choice`, and `Quot.sound`. The integer calculation `order40` has an empty axiom list. [Nucleus replay record](NUCLEUS_REPLAY.log)

With Lean 4.35.0 and the built Mathlib revision `56a005855ea17e0b0958f73ec801ae140b0a1679`, run `python replay.py`. On another machine, pass `--bin` pointing to the Lean binaries and `--packages` pointing to the project's built `.lake/packages`. The script compiles the five source modules in an empty temporary directory, audits the new public theorem declarations, and runs the kernel checker on each module. [Replay script](replay.py)

The included [TwistedCount.lean](TwistedCount.lean) is the byte-identical dependency from the November 22 twisted Franel package, with SHA-256 `25b6b49f5b1e14a170dfcae5d6c82fc98a6cc746bdb6fbc745dc7fa4fd2aeb60`.
