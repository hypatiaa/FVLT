import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Tactic

/-!
Native Euclidean cone and an injective labelled row-sector realization.
The sector is a rendering of labels, not a closed cellular-automaton domain.
Parent values below are read from a full integer row, without clipping.
No isometry, recurrence equivalence, or forced variation is asserted here.
-/

noncomputable section
namespace FVLT.ConeSectorV1

abbrev Space := EuclideanSpace ℝ (Fin 3)

def cone (h r theta : ℝ) : Space :=
  !₂[r * Real.cos theta, r * Real.sin theta, h * r]

theorem cone_radial (h r theta : ℝ) :
    (cone h r theta 0)^2 + (cone h r theta 1)^2 = r^2 := by
  simp only [cone, PiLp.toLp_apply, Matrix.cons_val_zero, Matrix.cons_val_one]
  have hs := congrArg (fun x : ℝ => r^2 * x) (Real.sin_sq_add_cos_sq theta)
  nlinarith [hs]

theorem cone_height (h r theta : ℝ) : cone h r theta 2 = h*r := by
  simp [cone]

theorem cone_radius_sq (h r theta : ℝ) :
    (cone h r theta 0)^2 + (cone h r theta 1)^2 = r^2 :=
  cone_radial h r theta

theorem cone_apex (h theta : ℝ) : cone h 0 theta = 0 := by
  ext i
  fin_cases i <;> simp [cone]

/-- Scaling a fixed angular ruling scales its native Euclidean vector. -/
theorem fixed_ray_scaling (h r theta a : ℝ) :
    cone h (a*r) theta = a • cone h r theta := by
  ext i
  fin_cases i <;> simp [cone] <;> ring

theorem radius_eq_of_cone_eq {h r s theta phi : ℝ}
    (hr : 0 ≤ r) (hs : 0 ≤ s) (he : cone h r theta = cone h s phi) : r=s := by
  have hx := congrArg (fun p : Space => p 0) he
  have hy := congrArg (fun p : Space => p 1) he
  have hrr := cone_radial h r theta
  have hss := cone_radial h s phi
  rw [hx, hy] at hrr
  nlinarith

/-- Positive radius and an open 2*pi interval exclude the angular seam. -/
theorem angle_eq_of_cone_eq {h r theta phi : ℝ} (hr : 0 < r)
    (htheta : -Real.pi < theta ∧ theta < Real.pi)
    (hphi : -Real.pi < phi ∧ phi < Real.pi)
    (he : cone h r theta = cone h r phi) : theta=phi := by
  have hx := congrArg (fun p : Space => p 0) he
  have hy := congrArg (fun p : Space => p 1) he
  have hc : Real.cos theta = Real.cos phi :=
    mul_left_cancel₀ (ne_of_gt hr) (by simpa [cone] using hx)
  have hs : Real.sin theta = Real.sin phi :=
    mul_left_cancel₀ (ne_of_gt hr) (by simpa [cone] using hy)
  have hone : Real.cos (theta-phi)=1 := by
    rw [Real.cos_sub, hc, hs]
    nlinarith [Real.sin_sq_add_cos_sq phi]
  obtain ⟨k,hk⟩ := (Real.cos_eq_one_iff _).mp hone
  have hkloR : (-1 : ℝ) < (k : ℝ) := by nlinarith [Real.pi_pos, htheta.1, hphi.2]
  have hkhiR : (k : ℝ) < 1 := by nlinarith [Real.pi_pos, htheta.2, hphi.1]
  have hklo : (-1 : ℤ) < k := by exact_mod_cast hkloR
  have hkhi : k < (1 : ℤ) := by exact_mod_cast hkhiR
  have hkzero : k=0 := by omega
  subst k
  norm_num at hk
  linarith

theorem cone_sector_injective {h r : ℝ} (hr : 0 < r) :
    Function.Injective (fun theta : {theta : ℝ //
      -Real.pi < theta ∧ theta < Real.pi} => cone h r theta.val) := by
  intro theta phi he
  apply Subtype.ext
  exact angle_eq_of_cone_eq hr theta.property phi.property he

def rowAngle (alpha : ℝ) (t : ℕ) (i : ℤ) : ℝ := alpha * (i : ℝ) / (t : ℝ)

def rowPoint (h alpha : ℝ) (t : ℕ) (i : ℤ) : Space :=
  cone h (t : ℝ) (rowAngle alpha t i)

def RowLabel (t : ℕ) := {i : ℤ // |i| ≤ (t : ℤ)}

theorem row_angle_bound {alpha : ℝ} (ha : 0 < alpha)
    {t : ℕ} (ht : 1 ≤ t) {i : ℤ} (hi : |i| ≤ (t : ℤ)) :
    |rowAngle alpha t i| ≤ alpha := by
  have htR : 0 < (t : ℝ) := by exact_mod_cast (show 0<t by omega)
  have hiR : |(i : ℝ)| ≤ (t : ℝ) := by exact_mod_cast hi
  rw [rowAngle, abs_div, abs_mul, abs_of_pos ha, abs_of_pos htR]
  apply (div_le_iff₀ htR).mpr
  nlinarith

theorem row_angle_in_open_sector {alpha : ℝ} (ha : 0 < alpha)
    (hapi : alpha < Real.pi) {t : ℕ} (ht : 1 ≤ t)
    {i : ℤ} (hi : |i| ≤ (t : ℤ)) :
    -Real.pi < rowAngle alpha t i ∧ rowAngle alpha t i < Real.pi := by
  have hb := abs_le.mp (row_angle_bound ha ht hi)
  constructor <;> linarith [hb.1, hb.2]

theorem row_point_radial (h alpha : ℝ) (t : ℕ) (i : ℤ) :
    (rowPoint h alpha t i 0)^2 + (rowPoint h alpha t i 1)^2 = (t : ℝ)^2 :=
  cone_radial _ _ _

theorem row_point_injective {h alpha : ℝ} (ha : 0 < alpha)
    (hapi : alpha < Real.pi) {t : ℕ} (ht : 1 ≤ t) :
    Function.Injective (fun i : RowLabel t => rowPoint h alpha t i.val) := by
  intro i j he
  have htR : 0 < (t : ℝ) := by exact_mod_cast (show 0<t by omega)
  have hangle : rowAngle alpha t i.val = rowAngle alpha t j.val :=
    angle_eq_of_cone_eq htR
      (row_angle_in_open_sector ha hapi ht i.property)
      (row_angle_in_open_sector ha hapi ht j.property) he
  have hiA : rowAngle alpha t i.val * (t : ℝ) = alpha * (i.val : ℝ) := by
    unfold rowAngle
    field_simp [ne_of_gt htR]
  have hjA : rowAngle alpha t j.val * (t : ℝ) = alpha * (j.val : ℝ) := by
    unfold rowAngle
    field_simp [ne_of_gt htR]
  have hcoord : alpha * (i.val : ℝ) = alpha * (j.val : ℝ) := by
    rw [← hiA, ← hjA, hangle]
  have hreal : (i.val : ℝ) = (j.val : ℝ) := mul_left_cancel₀ (ne_of_gt ha) hcoord
  apply Subtype.ext
  exact_mod_cast hreal

theorem row_zero_is_apex (h alpha : ℝ) (i : ℤ) : rowPoint h alpha 0 i = 0 := by
  simpa only [rowPoint, Nat.cast_zero] using cone_apex h (rowAngle alpha 0 i)

/-- The labelled parent interface reads the full integer background. -/
def parentValues {A : Type*} (previous : ℤ → A) (i : ℤ) : A × A × A :=
  (previous (i-1), previous i, previous (i+1))

theorem parentValues_right {A : Type*} (previous : ℤ → A) (i : ℤ) :
    (parentValues previous i).2.2 = previous (i+1) := rfl

/-- Even a boundary child can ask for a parent outside the previous sector.
The rendering must not silently delete or clamp this full-row dependency. -/
theorem boundary_parent_outside_previous (t : ℕ) (ht : 1 ≤ t) :
    ¬ |(t : ℤ)+1| ≤ ((t-1 : ℕ) : ℤ) := by
  have hn : (0 : ℤ) ≤ (t : ℤ)+1 := by omega
  rw [abs_of_nonneg hn]
  omega

end FVLT.ConeSectorV1
