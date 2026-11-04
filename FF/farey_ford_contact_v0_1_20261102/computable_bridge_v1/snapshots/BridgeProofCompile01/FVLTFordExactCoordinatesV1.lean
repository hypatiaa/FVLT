import FVLTFordRationalV1
import FVLTFordGeometryV1
import Mathlib.Tactic

/-! Exact links to the frozen F1 specification; no predecessor is modified. -/
namespace FVLT.FordExactCoordinatesV1

noncomputable def embedQ (z : RatPlane) : ℂ :=
  (z.1 : ℂ) + (z.2 : ℂ) * Complex.I

theorem kissNQ_eq (x y : ℚ) : kissNQ x y = FVLT.FordGeometryV1.kissN x y := rfl
theorem kissMQ_eq (x y : ℚ) : kissMQ x y = FVLT.FordGeometryV1.kissM x y := rfl
theorem kissMQ_pos (x y : ℚ) : 0 < kissMQ x y := by
  have hx := x.den_pos
  unfold kissMQ
  positivity
theorem radiusQ_pos (x : ℚ) : 0 < radiusQ x := by
  have hx : (0 : ℚ) < x.den := by exact_mod_cast x.den_pos
  unfold radiusQ
  positivity
theorem radiusQ_cast (x : ℚ) :
  (radiusQ x : ℝ) = FVLT.FordGeometryV1.radius x := by
  simp [radiusQ, FVLT.FordGeometryV1.radius]
theorem embedQ_injective : Function.Injective embedQ := by
  intro u v h
  apply Prod.ext
  · have hr := congrArg Complex.re h
    simpa [embedQ] using hr
  · have hi := congrArg Complex.im h
    simpa [embedQ] using hi
theorem centreQ_embed (x : ℚ) :
  embedQ (centreQ x) = FVLT.FordGeometryV1.centre x := by
  apply Complex.ext <;>
    simp [embedQ, centreQ, FVLT.FordGeometryV1.centre, radiusQ_cast]
theorem kissQ_embed (x y : ℚ) :
  embedQ (kissQ x y) = FVLT.FordGeometryV1.kiss x y := by
  have hr : (FVLT.FordGeometryV1.kiss x y).re =
      (FVLT.FordGeometryV1.kissN x y : ℝ) / (FVLT.FordGeometryV1.kissM x y : ℝ) := by
    simp [FVLT.FordGeometryV1.kiss]
  have hi : (FVLT.FordGeometryV1.kiss x y).im =
      1 / (FVLT.FordGeometryV1.kissM x y : ℝ) := by simp [FVLT.FordGeometryV1.kiss]
  apply Complex.ext <;> simp [embedQ, kissQ, hr, hi, kissNQ_eq, kissMQ_eq]
theorem sqDistanceQ_cast (u v : RatPlane) :
  (sqDistanceQ u v : ℝ) = ‖embedQ u - embedQ v‖^2 := by
  simp [sqDistanceQ, embedQ, Complex.sq_norm, Complex.normSq_apply, pow_two]
theorem boundaryQ_iff (x : ℚ) (z : RatPlane) :
  boundaryQ x z ↔ embedQ z ∈ FVLT.FordGeometryV1.boundary x := by
  have hd := sqDistanceQ_cast z (centreQ x)
  rw [centreQ_embed] at hd
  change sqDistanceQ z (centreQ x) = (radiusQ x)^2 ↔
    ‖embedQ z - FVLT.FordGeometryV1.centre x‖ = FVLT.FordGeometryV1.radius x
  constructor
  · intro h
    have hh : (sqDistanceQ z (centreQ x) : ℝ) = (radiusQ x : ℝ)^2 := by exact_mod_cast h
    rw [hd, radiusQ_cast] at hh
    exact (sq_eq_sq₀ (norm_nonneg _) (FVLT.FordGeometryV1.radius_pos x).le).mp hh
  · intro h
    have hh : (sqDistanceQ z (centreQ x) : ℝ) = (radiusQ x : ℝ)^2 := by
      rw [hd, radiusQ_cast, h]
    exact_mod_cast hh
theorem boundaryCheckQ_correct (x : ℚ) (z : RatPlane) :
  boundaryCheckQ x z = true ↔ embedQ z ∈ FVLT.FordGeometryV1.boundary x := by
  simpa only [boundaryCheckQ, decide_eq_true_eq] using boundaryQ_iff x z
theorem adjacent_kissQ (x y : ℚ) (h : FVLT.FareyContactV1.fareyAdj x y) :
  boundaryCheckQ x (kissQ x y) = true ∧
  boundaryCheckQ y (kissQ x y) = true := by
  have hm := FVLT.FordGeometryV1.kiss_membership x y h
  constructor
  · apply (boundaryCheckQ_correct x (kissQ x y)).mpr
    simpa only [kissQ_embed] using hm.1
  · apply (boundaryCheckQ_correct y (kissQ x y)).mpr
    simpa only [kissQ_embed] using hm.2

#print axioms FVLT.FordExactCoordinatesV1.kissNQ_eq
#print axioms FVLT.FordExactCoordinatesV1.kissMQ_eq
#print axioms FVLT.FordExactCoordinatesV1.kissMQ_pos
#print axioms FVLT.FordExactCoordinatesV1.radiusQ_pos
#print axioms FVLT.FordExactCoordinatesV1.radiusQ_cast
#print axioms FVLT.FordExactCoordinatesV1.embedQ_injective
#print axioms FVLT.FordExactCoordinatesV1.centreQ_embed
#print axioms FVLT.FordExactCoordinatesV1.kissQ_embed
#print axioms FVLT.FordExactCoordinatesV1.sqDistanceQ_cast
#print axioms FVLT.FordExactCoordinatesV1.boundaryQ_iff
#print axioms FVLT.FordExactCoordinatesV1.boundaryCheckQ_correct
#print axioms FVLT.FordExactCoordinatesV1.adjacent_kissQ
end FVLT.FordExactCoordinatesV1
