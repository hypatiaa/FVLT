import FVLTS4qSpinGateV1

/-! Four-corner squeeze lemma.

The torus of revolution with major radius `R` and tube radius `r`, squeezed to `R = 0`,
glues `(θ, φ)` to `(π - θ, φ + π)`. On the four Boolean corners of the pair torus
(white ↦ 0, black ↦ π) it glues exactly along the XOR (Rule 150) fibres: the image of a
corner is `(r · σ_q σ_r, 0, 0)`. The tooth corner `(π, π)` is glued to the all-white
corner, which Rule 30's OR keeps apart.

Exact on four points only. No claim about Rule 30 dynamics, and the squeeze is a display
deformation, not a topological collapse theorem.
Credits: saphir (sphere/collapse picture), Codex (identification formula). -/
noncomputable section
namespace FVLT.S4sSqueezeCornersV1
open Real

abbrev spin := FVLT.S4qSpinGateV1.spin

/-- Torus of revolution with major radius `R`, tube radius `r`. -/
def F (R r θ φ : ℝ) : ℝ × ℝ × ℝ :=
  ((R + r * cos θ) * cos φ, (R + r * cos θ) * sin φ, r * sin θ)

/-- Boolean phase: white ↦ 0, black ↦ π. -/
def ang (b : Bool) : ℝ := if b then π else 0

theorem cos_ang (b : Bool) : cos (ang b) = spin b := by
  cases b <;> simp [ang, spin, FVLT.S4qSpinGateV1.spin_false, FVLT.S4qSpinGateV1.spin_true]

theorem sin_ang (b : Bool) : sin (ang b) = 0 := by
  cases b <;> simp [ang]

theorem spin_inj {a b : Bool} (h : spin a = spin b) : a = b := by
  cases a <;> cases b <;> first
    | rfl
    | (exfalso; norm_num [spin, FVLT.S4qSpinGateV1.spin_false,
        FVLT.S4qSpinGateV1.spin_true] at h)

/-- At `R = 0` the squeeze glues `(θ, φ)` to `(π - θ, φ + π)`. -/
theorem squeeze_identification (r θ φ : ℝ) :
    F 0 r (π - θ) (φ + π) = F 0 r θ φ := by
  unfold F
  rw [Real.cos_pi_sub, Real.sin_pi_sub, Real.cos_add_pi, Real.sin_add_pi]
  simp only [Prod.mk.injEq]
  exact ⟨by ring, by ring, trivial⟩

/-- The squeezed image of a Boolean corner is `(r · σ_q σ_s, 0, 0)`. -/
theorem corner_image (r : ℝ) (q s : Bool) :
    F 0 r (ang q) (ang s) = (r * (spin q * spin s), 0, 0) := by
  unfold F
  rw [cos_ang, cos_ang, sin_ang, sin_ang]
  simp only [Prod.mk.injEq]
  exact ⟨by ring, by ring, by ring⟩

/-- Equivalently, `r` times the Rule 150 (XOR) spin. -/
theorem corner_image_xor (r : ℝ) (q s : Bool) :
    F 0 r (ang q) (ang s) = (r * spin (xor q s), 0, 0) := by
  rw [corner_image, spin, FVLT.S4qSpinGateV1.spin_xor]

/-- For `r ≠ 0`, two corners are glued iff their XORs agree:
the squeeze fibres on the corners are exactly the Rule 150 fibres. -/
theorem corners_glued_iff (r : ℝ) (hr : r ≠ 0) (q s q' s' : Bool) :
    F 0 r (ang q) (ang s) = F 0 r (ang q') (ang s') ↔ xor q s = xor q' s' := by
  rw [corner_image_xor, corner_image_xor]
  constructor
  · intro h
    have h1 : r * spin (xor q s) = r * spin (xor q' s') := congrArg Prod.fst h
    exact spin_inj (mul_left_cancel₀ hr h1)
  · intro h
    rw [h]

/-- The tooth corner `(π, π)` is glued to the all-white corner `(0, 0)`,
while Rule 30's OR separates them. -/
theorem tooth_glued_to_white (r : ℝ) :
    F 0 r (ang true) (ang true) = F 0 r (ang false) (ang false) ∧
      (true || true) ≠ (false || false) := by
  refine ⟨?_, by decide⟩
  rw [corner_image_xor, corner_image_xor]
  rfl

end FVLT.S4sSqueezeCornersV1

#print axioms FVLT.S4sSqueezeCornersV1.squeeze_identification
#print axioms FVLT.S4sSqueezeCornersV1.corner_image
#print axioms FVLT.S4sSqueezeCornersV1.corner_image_xor
#print axioms FVLT.S4sSqueezeCornersV1.corners_glued_iff
#print axioms FVLT.S4sSqueezeCornersV1.tooth_glued_to_white
