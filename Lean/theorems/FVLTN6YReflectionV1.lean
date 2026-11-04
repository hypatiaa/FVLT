import FVLTN6OrientationV1
import FVLTN6MirrorV1

/-! An explicitly new negative-N6 orientation for the actual selected modulus
and radial specialization. Old signed-scalar definitions and their half-turn
theorems remain unchanged. This successor has no locked-kernel standing. -/
noncomputable section
namespace FVLT.N6YReflectionV1
open YReflectionV1 CoupledPointV1

def point (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) : ℂ :=
  N6OrientationV1.point ((m.n3 : ℝ)^alpha) n6 (AlphaAmplitudeV1.phase m k s)

theorem point_zero (m : Modulus) (alpha : ℝ) (k s : ℤ) : point m alpha 0 k s=0 :=
  N6OrientationV1.point_zero _ _

theorem point_of_nonneg (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) (hn : 0≤n6) :
    point m alpha n6 k s=AlphaAmplitudeV1.point m alpha n6 k s := by
  exact N6OrientationV1.point_of_nonneg _ _ _ hn

theorem point_of_neg (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) (hn : n6<0) :
    point m alpha n6 k s=
      reflect (AlphaAmplitudeV1.point m alpha |n6| k s) := by
  exact N6OrientationV1.point_of_neg_reflect_abs _ _ _ hn

theorem point_sign_flip (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    point m alpha (-n6) k s=reflect (point m alpha n6 k s) :=
  N6OrientationV1.point_sign_flip _ _ _

theorem point_norm (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    ‖point m alpha n6 k s‖=|n6| * (m.n3 : ℝ)^alpha := by
  unfold point
  rw [N6OrientationV1.norm_point,AlphaAmplitudeV1.norm_phase,
    abs_of_pos (AlphaAmplitudeV1.radial_power_pos m alpha),mul_one]

theorem point_ne_zero_iff (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    point m alpha n6 k s≠0 ↔ n6≠0 := by
  unfold point
  rw [N6OrientationV1.point_ne_zero_iff]
  have hp : AlphaAmplitudeV1.phase m k s≠0 := Complex.exp_ne_zero _
  simp [ne_of_gt (AlphaAmplitudeV1.radial_power_pos m alpha),hp]

theorem point_im_eq_positive (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    (point m alpha n6 k s).im=(AlphaAmplitudeV1.point m alpha |n6| k s).im := by
  by_cases hn : n6<0
  · rw [point_of_neg m alpha n6 k s hn,reflect_im]
  · have hn0 : 0≤n6 := by linarith
    rw [point_of_nonneg m alpha n6 k s hn0,abs_of_nonneg hn0]

theorem phase_eq_phasor (m : Modulus) (k s : ℤ) :
    AlphaAmplitudeV1.phase m k s=PhaseAddressV1.phasor (PhaseAddressV1.address m k s : ℝ) := by
  unfold AlphaAmplitudeV1.phase PhaseAddressV1.phasor
  rw [PhaseAddressV1.angle_eq_pi_address]
  push_cast
  rfl

theorem reflect_phasor (x : ℝ) :
    reflect (PhaseAddressV1.phasor x)=PhaseAddressV1.phasor (1-x) := by
  rw [show 1-x=1+(-x) by ring,PhaseAddressV1.phasor_add,
    PhaseAddressV1.phasor_one,PhaseAddressV1.phasor_neg]
  simp [reflect]

theorem negative_phase_address (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) (hn : n6<0) :
    point m alpha n6 k s=
      ((|n6| * (m.n3 : ℝ)^alpha : ℝ) : ℂ)*
        PhaseAddressV1.phasor (1-(PhaseAddressV1.address m k s : ℝ)) := by
  rw [point_of_neg m alpha n6 k s hn,PhaseAddressV1.alpha_point_eq,reflect_mul,
    reflect_phasor]
  simp only [AlphaAmplitudeV1.radius]
  congr 1
  exact Complex.conj_ofReal _

theorem sign_flip_halfturn_iff (m : Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    point m alpha (-n6) k s= -point m alpha n6 k s ↔
      (point m alpha n6 k s).im=0 := by
  rw [point_sign_flip,reflect_eq_neg_iff_im_zero]

/-- The existing amplitude tilt has real weights, so it is not negated. -/
theorem walk_reflection (tilt : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    WalkTiltV1.walk tilt (fun j=>reflect (z j)) t=
      reflect (WalkTiltV1.walk tilt z t) := by
  induction t with
  | zero => simp [WalkTiltV1.walk]
  | succ t ih =>
    rw [WalkTiltV1.walk_succ,WalkTiltV1.walk_succ,reflect_add,ih,reflect_mul]
    simp

def pointWalk (m : Modulus) (alpha n6 tilt : ℝ) (k : ℕ → ℤ) (s : ℤ) (t : ℕ) : ℂ :=
  WalkTiltV1.walk tilt (fun j=>point m alpha n6 (k j) s) t

theorem pointWalk_sign_flip (m : Modulus) (alpha n6 tilt : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) :
    pointWalk m alpha (-n6) tilt k s t=reflect (pointWalk m alpha n6 tilt k s t) := by
  unfold pointWalk
  simp_rw [point_sign_flip]
  exact walk_reflection tilt _ t

end FVLT.N6YReflectionV1
