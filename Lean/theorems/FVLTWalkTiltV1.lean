import FVLTAlphaAmplitudeV1

/-!
# Ordered Fourier-pen walk tilt

The viewer's one-based weight is j^alphaTilt for j=1,...,m. We use a
zero-based sequence, so weight a j = (j+1)^a. The input sequence retains
offset order and repeated terms. No midpoint or L2 normalization is applied.
This is distinct from radial alpha and conductor-energy alpha_ch.
-/
namespace FVLT.WalkTiltV1

noncomputable section
open scoped BigOperators

def weight (a : ℝ) (j : ℕ) : ℝ := ((j + 1 : ℕ) : ℝ) ^ a

def walk (a : ℝ) (z : ℕ → ℂ) (t : ℕ) : ℂ :=
  ∑ j ∈ Finset.range t, (weight a j : ℂ) * z j

theorem weight_pos (a : ℝ) (j : ℕ) : 0 < weight a j := by
  apply Real.rpow_pos_of_pos
  positivity

theorem weight_ne_zero (a : ℝ) (j : ℕ) : weight a j ≠ 0 :=
  ne_of_gt (weight_pos a j)

@[simp] theorem weight_zero (j : ℕ) : weight 0 j = 1 := by simp [weight]

@[simp] theorem weight_one (j : ℕ) : weight 1 j = (j + 1 : ℕ) := by simp [weight]

@[simp] theorem weight_neg_one (j : ℕ) : weight (-1) j = 1 / ((j + 1 : ℕ) : ℝ) := by
  simp [weight, Real.rpow_neg_one, one_div]

@[simp] theorem weight_first (a : ℝ) : weight a 0 = 1 := by simp [weight]

@[simp] theorem walk_empty (a : ℝ) (z : ℕ → ℂ) : walk a z 0 = 0 := by
  simp [walk]

theorem walk_succ (a : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    walk a z (t+1) = walk a z t + (weight a t : ℂ) * z t := by
  exact Finset.sum_range_succ _ _

theorem walk_increment (a : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    walk a z (t+1) - walk a z t = (weight a t : ℂ) * z t := by
  rw [walk_succ]
  ring

theorem increment_recovers_term (a : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    (walk a z (t+1) - walk a z t) / (weight a t : ℂ) = z t := by
  have hw : (weight a t : ℂ) ≠ 0 := by exact_mod_cast weight_ne_zero a t
  rw [walk_increment]
  exact mul_div_cancel_left₀ _ hw

theorem increment_real_iff (a : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    (walk a z (t+1) - walk a z t).im = 0 ↔ (z t).im = 0 := by
  rw [walk_increment]
  simp [Complex.mul_im, weight_ne_zero]

theorem walk_zero_tilt (z : ℕ → ℂ) (t : ℕ) :
    walk 0 z t = ∑ j ∈ Finset.range t, z j := by simp [walk]

theorem walk_one_tilt (z : ℕ → ℂ) (t : ℕ) :
    walk 1 z t = ∑ j ∈ Finset.range t, ((j+1 : ℕ) : ℂ) * z j := by
  simp [walk]

theorem walk_mul (a : ℝ) (z : ℕ → ℂ) (r : ℂ) (t : ℕ) :
    walk a (fun j => r * z j) t = r * walk a z t := by
  simp only [walk, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem walk_add (a : ℝ) (z v : ℕ → ℂ) (t : ℕ) :
    walk a (fun j => z j + v j) t = walk a z t + walk a v t := by
  simp [walk, mul_add, Finset.sum_add_distrib]

theorem walk_congr_prefix (a : ℝ) (z v : ℕ → ℂ) (t : ℕ)
    (h : ∀ j, j < t → z j = v j) : walk a z t = walk a v t := by
  apply Finset.sum_congr rfl
  intro j hj
  rw [h j (Finset.mem_range.mp hj)]

/-- The full path, unlike its final point, determines every input term. -/
theorem path_injective (a : ℝ) (z v : ℕ → ℂ)
    (h : ∀ t, walk a z t = walk a v t) : z = v := by
  funext j
  rw [← increment_recovers_term a z j, h (j+1), h j, increment_recovers_term]

theorem walk_two (a : ℝ) (z : ℕ → ℂ) :
    walk a z 2 = z 0 + (((2 : ℝ) ^ a : ℝ) : ℂ) * z 1 := by
  rw [show 2 = 0+1+1 by omega, walk_succ, walk_succ]
  simp [weight]

theorem two_term_order_difference (a : ℝ) (x y : ℂ) :
    walk a (fun j => if j=0 then x else y) 2 -
      walk a (fun j => if j=0 then y else x) 2 =
      (1 - (((2 : ℝ)^a : ℝ) : ℂ)) * (x-y) := by
  simp only [walk_two]
  norm_num
  ring

/-- Explicitly refutes transport of individual-step contact to the endpoint. -/
theorem endpoint_contact_changes_with_tilt :
    (walk 0 (fun j => if j=0 then Complex.I else -Complex.I) 2).im = 0 ∧
    (walk 1 (fun j => if j=0 then Complex.I else -Complex.I) 2).im ≠ 0 := by
  norm_num [walk_two]

theorem norm_walk_le (a : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    ‖walk a z t‖ ≤ ∑ j ∈ Finset.range t, weight a j * ‖z j‖ := by
  unfold walk
  calc
    _ ≤ ∑ j ∈ Finset.range t, ‖(weight a j : ℂ) * z j‖ := norm_sum_le _ _
    _ = _ := by
      apply Finset.sum_congr rfl
      intro j _
      simp [abs_of_pos (weight_pos a j)]

/-- Exact positive-modulus specialization; radial alpha and walk tilt independent. -/
def pointWalk (m : CoupledPointV1.Modulus) (alpha n6 tilt : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) : ℂ :=
  walk tilt (fun j => AlphaAmplitudeV1.point m alpha n6 (k j) s) t

theorem pointWalk_factor_radius (m : CoupledPointV1.Modulus) (alpha n6 tilt : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) :
    pointWalk m alpha n6 tilt k s t = (AlphaAmplitudeV1.radius m alpha n6 : ℂ) *
      walk tilt (fun j => AlphaAmplitudeV1.phase m (k j) s) t := by
  exact walk_mul tilt _ _ t

theorem pointWalk_zero_scale (m : CoupledPointV1.Modulus) (alpha tilt : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) : pointWalk m alpha 0 tilt k s t = 0 := by
  simp [pointWalk, AlphaAmplitudeV1.point_zero_scale, walk]

theorem pointWalk_zero_tilt (m : CoupledPointV1.Modulus) (alpha n6 : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) :
    pointWalk m alpha n6 0 k s t =
      ∑ j ∈ Finset.range t, AlphaAmplitudeV1.point m alpha n6 (k j) s :=
  walk_zero_tilt _ _

end
end FVLT.WalkTiltV1
