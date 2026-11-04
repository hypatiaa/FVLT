# Computable Ford bridge: signature freeze draft v0.1

2026-11-03. **Awaiting review; no bridge proof source or build.** Implements the accepted design direction `e0593acc1fc921151d52333104d4d58a9e5c758239278a72e6c566055ce7bcd0`, under the sequencing decision `d5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526`. F2's outcome must be recorded before this bridge's proof/build phase starts.

## Modules and definitions

All definitions are in `FVLT.FordExactCoordinatesV1`. Propose two additive modules: `FVLTFordRationalV1` contains only executable rational/integer definitions and standard Mathlib rational dependencies; `FVLTFordExactCoordinatesV1` imports it and the exact accepted F1 geometry for the noncomputable embedding and link proofs. No predecessor file is modified. The following snippets are declarations/headers for review, not executable source or admitted proofs.

Executable producer:

```lean
abbrev RatPlane := ℚ × ℚ
def radiusQ (x : ℚ) : ℚ := 1 / (2 * (x.den : ℚ)^2)
def centreQ (x : ℚ) : RatPlane := (x, radiusQ x)
def kissNQ (x y : ℚ) : ℤ :=
  x.num * (x.den : ℤ) + y.num * (y.den : ℤ)
def kissMQ (x y : ℚ) : ℕ := x.den^2 + y.den^2
def kissQ (x y : ℚ) : RatPlane :=
  ((kissNQ x y : ℚ) / (kissMQ x y : ℚ), 1 / (kissMQ x y : ℚ))
def sqDistanceQ (u v : RatPlane) : ℚ :=
  (u.1 - v.1)^2 + (u.2 - v.2)^2
def boundaryQ (x : ℚ) (z : RatPlane) : Prop :=
  sqDistanceQ z (centreQ x) = (radiusQ x)^2
def boundaryCheckQ (x : ℚ) (z : RatPlane) : Bool := decide (boundaryQ x z)
```

Producer declarations must compile as computable. They deliberately use local integer formulas, avoiding reliance on code generation for predecessor definitions inside its noncomputable section. The first two links below prove agreement with those predecessor formulas. Producer runtime imports no Real/Complex-valued calculation, classical-choice implementation or geometric embedding. No global noncomputable section is permitted around the producer.

Proof-module embedding:

```lean
noncomputable def embedQ (z : RatPlane) : ℂ :=
  (z.1 : ℂ) + (z.2 : ℂ) * Complex.I
```

## Twelve frozen links proposed

These use actual fully qualified predecessor names, not prose aliases. All hypotheses are explicit binders; denominator positivity is proved rather than assumed through hidden context.

```lean
theorem kissNQ_eq (x y : ℚ) : kissNQ x y = FVLT.FordGeometryV1.kissN x y
theorem kissMQ_eq (x y : ℚ) : kissMQ x y = FVLT.FordGeometryV1.kissM x y
theorem kissMQ_pos (x y : ℚ) : 0 < kissMQ x y
theorem radiusQ_pos (x : ℚ) : 0 < radiusQ x
theorem radiusQ_cast (x : ℚ) :
  (radiusQ x : ℝ) = FVLT.FordGeometryV1.radius x
theorem embedQ_injective : Function.Injective embedQ
theorem centreQ_embed (x : ℚ) :
  embedQ (centreQ x) = FVLT.FordGeometryV1.centre x
theorem kissQ_embed (x y : ℚ) :
  embedQ (kissQ x y) = FVLT.FordGeometryV1.kiss x y
theorem sqDistanceQ_cast (u v : RatPlane) :
  (sqDistanceQ u v : ℝ) = ‖embedQ u - embedQ v‖^2
theorem boundaryQ_iff (x : ℚ) (z : RatPlane) :
  boundaryQ x z ↔ embedQ z ∈ FVLT.FordGeometryV1.boundary x
theorem boundaryCheckQ_correct (x : ℚ) (z : RatPlane) :
  boundaryCheckQ x z = true ↔ embedQ z ∈ FVLT.FordGeometryV1.boundary x
theorem adjacent_kissQ (x y : ℚ) (h : FVLT.FareyContactV1.fareyAdj x y) :
  boundaryCheckQ x (kissQ x y) = true ∧
  boundaryCheckQ y (kissQ x y) = true
```

Construction/cast links are valid for all rational pairs, including equal and negative rationals; adjacency is required only for the last membership result. Boundary decidability is for a supplied rational point, not arbitrary ℂ input. Scalar positivity justifies passing from squared distances to nonnegative norms. The exact geometric link refers to F1's actual definitions, not a fresh real model.

The manager's optional distinct-rational converse is **deferred**, not a thirteenth target silently added. It can be separately proposed if needed after these twelve links. No kiss uniqueness, arbitrary real computability, viewer serialization theorem, kernel standing, Dirichlet or Rule 30 claim is made.

## API inspection

Metadata/source-only inspection on the pinned v19 Mathlib (no Lean invocation) confirmed `Rat.cast_injective`, `Rat.cast_inj`, `Rat.cast_mul`, `Rat.cast_div` in `Data/Rat/Cast/CharZero.lean`, with `Complex.ratCast_re/im` and `div_ofReal_re/im`, `div_natCast_re/im` in `Basic/Complex/Basic.lean`. F1 already used the pinned norm-square and coordinate APIs. These support the stated types without any change of representation. No executable tests or proof were run for this freeze draft.
