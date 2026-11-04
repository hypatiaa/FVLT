import FVLTConeSectorV1
import FVLTNaturalFanV1

/-! Column labels retain natural time. The radius n+1 is an explicitly chosen
positive radial schedule. The reference rate 2*pi/P gives the stated rulings;
no unique choice of angular rate and no metric isometry are asserted. -/
noncomputable section
namespace FVLT.ConeSpiralV1
open ConeSectorV1

def spiral (h omega : ℝ) (n : ℕ) : Space :=
  cone h ((n : ℝ)+1) (omega*(n : ℝ))

def fanPoint (h : ℝ) (P x b : ℕ) : Space :=
  cone h ((P*x+b : ℕ)+1) (2*Real.pi*(b : ℝ)/(P : ℝ))

theorem spiral_radius (h omega : ℝ) (n : ℕ) :
    (spiral h omega n 0)^2+(spiral h omega n 1)^2=((n : ℝ)+1)^2 :=
  cone_radial _ _ _

theorem spiral_injective (h omega : ℝ) : Function.Injective (spiral h omega) := by
  intro n m he
  have hr := radius_eq_of_cone_eq
    (show 0 ≤ (n : ℝ)+1 by positivity)
    (show 0 ≤ (m : ℝ)+1 by positivity) he
  have hn : (n : ℝ)=(m : ℝ) := by linarith
  exact_mod_cast hn

theorem cone_add_nat_turn (h r theta : ℝ) (x : ℕ) :
    cone h r (theta+(x : ℝ)*(2*Real.pi))=cone h r theta := by
  have hc := Real.cos_add_int_mul_two_pi theta (x : ℤ)
  have hs := Real.sin_add_int_mul_two_pi theta (x : ℤ)
  simp only [Int.cast_natCast] at hc hs
  ext i
  fin_cases i <;> simp [cone, hc, hs]

theorem reference_rate_fan (h : ℝ) (P x b : ℕ) (hP : 0<P) :
    spiral h (2*Real.pi/(P : ℝ)) (P*x+b)=fanPoint h P x b := by
  have hp : (P : ℝ)≠0 := by exact_mod_cast (Nat.ne_of_gt hP)
  have ha : 2*Real.pi/(P : ℝ)*((P*x+b : ℕ) : ℝ)=
      2*Real.pi*(b : ℝ)/(P : ℝ)+(x : ℝ)*(2*Real.pi) := by
    push_cast
    field_simp
    ring
  unfold spiral fanPoint
  rw [ha, cone_add_nat_turn]

theorem fan_label_injective (h : ℝ) (P : ℕ) [NeZero P] :
    Function.Injective (fun a : ℕ × Fin P => fanPoint h P a.1 a.2.val) := by
  intro a b he
  change fanPoint h P a.1 a.2.val=fanPoint h P b.1 b.2.val at he
  rw [← reference_rate_fan h P a.1 a.2.val (NaturalFanV1.period_pos P),
    ← reference_rate_fan h P b.1 b.2.val (NaturalFanV1.period_pos P)] at he
  have hn := spiral_injective h (2*Real.pi/(P : ℝ)) he
  have hab := NaturalFanV1.natural_address_unique P a.2.isLt b.2.isLt hn
  exact Prod.ext hab.1 (Fin.ext hab.2)

theorem radius_strictly_increases (P x b : ℕ) (hP : 0<P) :
    ((P*x+b : ℕ) : ℝ)+1 < ((P*(x+1)+b : ℕ) : ℝ)+1 := by
  exact_mod_cast (show P*x+b+1<P*(x+1)+b+1 by nlinarith)

theorem fixed_residue_ruling (h : ℝ) (P x b : ℕ) :
    fanPoint h P x b = (((P*x+b : ℕ) : ℝ)+1) •
      cone h 1 (2*Real.pi*(b : ℝ)/(P : ℝ)) := by
  simpa [fanPoint] using fixed_ray_scaling h 1
    (2*Real.pi*(b : ℝ)/(P : ℝ)) (((P*x+b : ℕ) : ℝ)+1)

end FVLT.ConeSpiralV1
