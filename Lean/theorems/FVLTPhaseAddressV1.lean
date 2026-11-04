import FVLTAlphaAmplitudeV1
import FVLTWalkTiltV1
import Mathlib.Analysis.SpecialFunctions.Complex.Log
import Mathlib.Analysis.SpecificLimits.Basic

/-!
# Dimensionless phase addresses and exact subdivision

The coordinate x is a scalar, with no physical-angle unit or conversion input.
The fixed normalization is exp(i*pi*x), so its period in x is two.
Rational gearbox addresses remain exact; pi is not approximated.
Dyadic subdivision is mathematical halving, not a physical Zeno claim.
-/
namespace FVLT.PhaseAddressV1

noncomputable section
open scoped BigOperators Topology

def phasor (x : ℝ) : ℂ := Complex.exp ((Real.pi : ℂ) * (x : ℂ) * Complex.I)

@[simp] theorem phasor_zero : phasor 0 = 1 := by simp [phasor]

@[simp] theorem phasor_one : phasor 1 = -1 := by
  simp [phasor]

theorem phasor_add (x y : ℝ) : phasor (x+y) = phasor x * phasor y := by
  unfold phasor
  rw [show (Real.pi : ℂ) * ((x+y : ℝ) : ℂ) * Complex.I =
    (Real.pi : ℂ)*(x:ℂ)*Complex.I + (Real.pi : ℂ)*(y:ℂ)*Complex.I by push_cast; ring]
  exact Complex.exp_add _ _

theorem norm_phasor (x : ℝ) : ‖phasor x‖ = 1 := by
  simp [phasor, Complex.norm_exp]

theorem phasor_ne_zero (x : ℝ) : phasor x ≠ 0 := Complex.exp_ne_zero _

/-- Exact phase equivalence, including the converse; no rounded angle comparison. -/
theorem phasor_eq_iff (x y : ℝ) :
    phasor x = phasor y ↔ ∃ n : ℤ, x = y + 2*(n:ℝ) := by
  rw [phasor, phasor, Complex.exp_eq_exp_iff_exists_int]
  constructor
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    have hi := congrArg Complex.im hn
    simp at hi
    apply mul_left_cancel₀ Real.pi_ne_zero
    calc
      Real.pi*x = Real.pi*y + (n:ℝ)*(2*Real.pi) := hi
      _ = Real.pi*(y+2*(n:ℝ)) := by ring
  · rintro ⟨n, hn⟩
    refine ⟨n, ?_⟩
    rw [hn]
    push_cast
    ring

theorem phasor_period (x : ℝ) (n : ℤ) : phasor (x+2*(n:ℝ)) = phasor x :=
  (phasor_eq_iff _ _).mpr ⟨n, rfl⟩

theorem phasor_int (s : ℤ) : phasor (s:ℝ) = (-1:ℂ)^s := by
  unfold phasor
  rw [show (Real.pi:ℂ)*((s:ℝ):ℂ)*Complex.I =
    (s:ℂ)*((Real.pi:ℂ)*Complex.I) by push_cast; ring]
  rw [Complex.exp_int_mul, Complex.exp_pi_mul_I]

theorem phasor_neg (x : ℝ) : phasor (-x) = star (phasor x) := by
  unfold phasor
  change _ = (starRingEnd ℂ) (Complex.exp _)
  rw [← Complex.exp_conj]
  congr 1
  simp

theorem phasor_finite_sum (x : ℕ → ℝ) (t : ℕ) :
    phasor (∑ j ∈ Finset.range t, x j) = ∏ j ∈ Finset.range t, phasor (x j) := by
  induction t with
  | zero => simp
  | succ t ih => rw [Finset.sum_range_succ, Finset.prod_range_succ, phasor_add, ih]

/-- The exact gearbox coordinate before multiplying by pi or evaluating exp. -/
def address (m : CoupledPointV1.Modulus) (k s : ℤ) : ℚ :=
  (k:ℚ)*(s:ℚ)/(m.n3:ℚ)

theorem angle_eq_pi_address (m : CoupledPointV1.Modulus) (k s : ℤ) :
    CoupledPointV1.angle m k s = Real.pi * (address m k s : ℝ) := by
  unfold CoupledPointV1.angle address
  push_cast
  ring

theorem coupled_point_eq (m : CoupledPointV1.Modulus) (k s : ℤ) :
    CoupledPointV1.point m k s = (m.n3:ℂ) * phasor (address m k s : ℝ) := by
  unfold CoupledPointV1.point phasor
  rw [angle_eq_pi_address]
  push_cast
  rfl

theorem alpha_point_eq (m : CoupledPointV1.Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    AlphaAmplitudeV1.point m alpha n6 k s =
      (AlphaAmplitudeV1.radius m alpha n6 : ℂ) * phasor (address m k s : ℝ) := by
  unfold AlphaAmplitudeV1.point AlphaAmplitudeV1.phase phasor
  rw [angle_eq_pi_address]
  push_cast
  rfl

theorem pointWalk_eq_address_walk (m : CoupledPointV1.Modulus) (alpha n6 tilt : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) :
    WalkTiltV1.pointWalk m alpha n6 tilt k s t =
      (AlphaAmplitudeV1.radius m alpha n6 : ℂ) *
        WalkTiltV1.walk tilt (fun j => phasor (address m (k j) s : ℝ)) t := by
  unfold WalkTiltV1.pointWalk
  simp_rw [alpha_point_eq]
  exact WalkTiltV1.walk_mul tilt _ _ t

theorem address_tooth1 (m : CoupledPointV1.Modulus) (t1 t2 s : ℤ) :
    address m (CoupledPointV1.tooth1 m t1 t2) s =
      (t1:ℚ)*(s:ℚ) - (t2:ℚ)*(s:ℚ)/(m.n3:ℚ) := by
  have hn : (m.n3:ℚ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt m.positive
  unfold address CoupledPointV1.tooth1 GearboxV1.k1
  push_cast
  field_simp [hn]

theorem address_tooth2 (m : CoupledPointV1.Modulus) (t1 t2 s : ℤ) :
    address m (CoupledPointV1.tooth2 m t1 t2) s =
      (t1:ℚ)*(s:ℚ) + (t2:ℚ)*(s:ℚ)/(m.n3:ℚ) := by
  have hn : (m.n3:ℚ) ≠ 0 := by exact_mod_cast Nat.ne_of_gt m.positive
  unfold address CoupledPointV1.tooth2 GearboxV1.k2
  push_cast
  field_simp [hn]

/-- Exact repeated halving, with no minimum positive subdivision. -/
def dyadic (x : ℝ) (n : ℕ) : ℝ := x*(1/2:ℝ)^n

@[simp] theorem dyadic_zero (x : ℝ) : dyadic x 0 = x := by simp [dyadic]

theorem dyadic_succ (x : ℝ) (n : ℕ) : dyadic x (n+1) = dyadic x n / 2 := by
  simp [dyadic, pow_succ]
  ring

theorem phasor_dyadic_square (x : ℝ) (n : ℕ) :
    phasor (dyadic x (n+1)) ^ 2 = phasor (dyadic x n) := by
  rw [pow_two, ← phasor_add]
  congr 1
  rw [dyadic_succ]
  ring

theorem dyadic_finite_sum (x : ℝ) (n : ℕ) :
    (∑ j ∈ Finset.range n, dyadic x (j+1)) = x-dyadic x n := by
  induction n with
  | zero => simp
  | succ n ih => rw [Finset.sum_range_succ, ih, dyadic_succ]; ring

theorem dyadic_pos (x : ℝ) (hx : 0 < x) (n : ℕ) : 0 < dyadic x n := by
  unfold dyadic
  positivity

theorem dyadic_succ_lt (x : ℝ) (hx : 0 < x) (n : ℕ) :
    dyadic x (n+1) < dyadic x n := by
  rw [dyadic_succ]
  have hp := dyadic_pos x hx n
  linarith

theorem dyadic_tendsto_zero (x : ℝ) :
    Filter.Tendsto (dyadic x) Filter.atTop (nhds 0) := by
  have h : Filter.Tendsto (fun n : ℕ => (1/2:ℝ)^n) Filter.atTop (nhds 0) :=
    tendsto_pow_atTop_nhds_zero_of_lt_one (by norm_num) (by norm_num)
  change Filter.Tendsto (fun n : ℕ => x*(1/2:ℝ)^n) Filter.atTop (nhds 0)
  simpa only [mul_zero] using h.const_mul x

theorem dyadic_sums_tendsto (x : ℝ) :
    Filter.Tendsto (fun n => ∑ j ∈ Finset.range n, dyadic x (j+1))
      Filter.atTop (nhds x) := by
  simpa only [dyadic_finite_sum, sub_zero] using
    (tendsto_const_nhds.sub (dyadic_tendsto_zero x))

theorem continuous_phasor : Continuous phasor := by
  unfold phasor
  fun_prop

theorem dyadic_phasors_tendsto_one (x : ℝ) :
    Filter.Tendsto (fun n => phasor (dyadic x n)) Filter.atTop (nhds 1) := by
  simpa only [Function.comp_def, phasor_zero] using
    (continuous_phasor.tendsto 0).comp (dyadic_tendsto_zero x)

theorem dyadic_phase_products_tendsto (x : ℝ) :
    Filter.Tendsto (fun n => ∏ j ∈ Finset.range n, phasor (dyadic x (j+1)))
      Filter.atTop (nhds (phasor x)) := by
  simpa only [Function.comp_def, phasor_finite_sum] using
    (continuous_phasor.tendsto x).comp (dyadic_sums_tendsto x)

end
end FVLT.PhaseAddressV1
