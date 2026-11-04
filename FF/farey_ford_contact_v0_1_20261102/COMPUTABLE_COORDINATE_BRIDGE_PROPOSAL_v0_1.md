# Exact computable Ford coordinates: additive bridge proposal

2026-11-03. Robin asks: "Can we translate them to computable and link them?" Relayed by the coordinator as a direct request concerning the Ford radius, centre and kiss definitions. **Design proposal; not yet frozen, compiled or proved.** Preserve all current F1 source/object bytes and its pending audit. This adds a separate module and does not dispatch F2, alter Stage A standing, or authorize synchronization.

## Intended outcome

The existing geometric values have rational coordinates. Compute those coordinates exactly in Lean's executable ℚ arithmetic, then prove their embeddings equal the existing values in ℝ/ℂ. This makes the rational producer executable while preserving the classical geometry specification. It does not make arbitrary real arithmetic, arbitrary complex norms, or arbitrary real equality executable.

Proposed module: `FVLTFordExactCoordinatesV1.lean`, namespace `FVLT.FordExactCoordinatesV1`. It imports only standard Mathlib and the exact accepted F1 module pair. Every hypothesis remains an explicit binder. Its own input/signature/source/template gates must be reviewed before proof execution.

## Proposed definitions

The following is a signature/definition draft, not a compiled source file:

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

noncomputable def embedQ (z : RatPlane) : ℂ :=
  (z.1 : ℂ) + (z.2 : ℂ) * Complex.I
```

All producers and the Boolean test are intended to be computable, with no classical choice or real/complex runtime dependency. ℚ arithmetic normalizes exact fractions. `embedQ` is deliberately noncomputable: it is the specification bridge to the existing geometric model, not a step in the rational producer or test.

The duplicated integer formulas avoid a premature claim that definitions inside the predecessor's `noncomputable section` have executable code. If Lean inspection shows the predecessor's `kissN` and `kissM` are executable dependencies, those can be reused instead after review. Until then, define local executable versions and prove the following definitional equalities; this changes no predecessor byte.

## Proposed link statements

Use `G := FVLT.FordGeometryV1` and `A := FVLT.FareyContactV1` as prose aliases below; actual Lean names will be fully qualified or imported explicitly.

```lean
theorem kissNQ_eq (x y : ℚ) : kissNQ x y = G.kissN x y
theorem kissMQ_eq (x y : ℚ) : kissMQ x y = G.kissM x y
theorem kissMQ_pos (x y : ℚ) : 0 < kissMQ x y
theorem radiusQ_pos (x : ℚ) : 0 < radiusQ x
theorem radiusQ_cast (x : ℚ) : (radiusQ x : ℝ) = G.radius x
theorem embedQ_injective : Function.Injective embedQ
theorem centreQ_embed (x : ℚ) : embedQ (centreQ x) = G.centre x
theorem kissQ_embed (x y : ℚ) : embedQ (kissQ x y) = G.kiss x y
theorem sqDistanceQ_cast (u v : RatPlane) :
  (sqDistanceQ u v : ℝ) = ‖embedQ u - embedQ v‖^2
theorem boundaryQ_iff (x : ℚ) (z : RatPlane) :
  boundaryQ x z ↔ embedQ z ∈ G.boundary x
theorem boundaryCheckQ_correct (x : ℚ) (z : RatPlane) :
  boundaryCheckQ x z = true ↔ embedQ z ∈ G.boundary x
theorem adjacent_kissQ (x y : ℚ) (h : A.fareyAdj x y) :
  boundaryCheckQ x (kissQ x y) = true ∧
  boundaryCheckQ y (kissQ x y) = true
```

Every division guard is explicit in the mathematics: rational canonical denominators are positive; `kissMQ_pos` proves the kiss denominator is nonzero. No adjacency hypothesis is needed to construct `kissQ`, to embed it, or to prove its denominator positive. Adjacency is needed for the boundary-membership conclusion. `boundaryQ_iff` uses positivity to pass between squared distance and the unsquared nonnegative norm. It decides membership for a supplied rational point; it does not decide equality or membership for an arbitrary complex input.

If a future viewer consumes the data, serialize exact numerator/positive-denominator pairs for each coordinate. Raster positions are a later rendering map, not the mathematical data. Viewer transport/serialization correctness and UI edits are separate work, not claimed by these Lean bridges.

## Executability and validation obligations

1. Verify the latest released library and full pins at this extension's freeze. F1's historical verification stays tied to v19. If F1 is not in that library, pin its accepted exact source/object pair as isolated dependencies; do not silently promote it.
2. Review and freeze exact signatures/definitions after API inspection. This draft uses prose namespace aliases and is not advertised as parser-checked Lean.
3. Compile the exact rational producer/test without marking it noncomputable and without relying on predecessor noncomputable definitions. Audit that it has no real/complex/classical runtime dependencies. Successful theorem compilation alone does not prove producer executability.
4. Run separately scoped executable smoke checks on exact fixtures, keeping evaluation artifacts out of theorem target modules so generated evaluator code is not mistaken for a proof or an unsafe theorem. Suggested fixtures: x=0, x=1, x=1/2, a negative rational, the adjacent pair (1/2,1/3), and nonadjacent (1/3,1/5). Fixture expected values are preregistered before running. No floating point, `native_decide`, or extra axioms.
5. Print axioms for every theorem and run the pinned strict all-target-constant checker on the theorem module. Preserve executable output separately from proof/replay evidence.
6. Independently check that the embedding theorems connect to the actual predecessor definitions rather than a duplicate real geometry model. All scope, comparison, capacity and failure rules remain explicit in the accepted extension order/template.

## Sequence and decision requested from Opus

First finish the current F1 audit without replacing its sources. Opus should decide whether this rational-coordinate bridge is a separately bounded extension before F2 or queued immediately after the current Stage A sequence. Then issue or accept the extension's exact scope, pins, signature and job-template gates. Robin's request authorizes pursuing the computable link; it does not waive those existing execution gates. No extension proof, compute, library write, or viewer edit has been performed by this proposal.
