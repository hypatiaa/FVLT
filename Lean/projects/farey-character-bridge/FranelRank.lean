import FranelKernel

noncomputable section
namespace Ratioque.Franel
open Finset

private theorem bTwo_opposite {a x : ℚ} (hx : 0 < x) (hxa : x < a) (ha : a ≤ 1) :
    bTwo (a - x) = ((a : ℝ) - x)^2 - ((a : ℝ) - x) + 1/6 ∧
    bTwo (x - a) = ((a : ℝ) - x)^2 - ((a : ℝ) - x) + 1/6 := by
  have hf : Int.fract (a - x) = a - x := Int.fract_eq_self.mpr ⟨by linarith, by linarith⟩
  have hn : Int.fract (x - a) = (x - a) + 1 := by
    rw [← Int.fract_add_one]
    exact Int.fract_eq_self.mpr ⟨by linarith, by linarith⟩
  constructor <;> simp [bTwo, hf, hn]
  ring

private def rr (A : Finset ℚ) (x : ℚ) : ℝ := ((A.filter (· ≤ x)).card : ℝ)

private theorem rank_insert {a : ℚ} {A : Finset ℚ} (hm : ∀ x ∈ A, x < a) :
    rr (insert a A) a = (A.card : ℝ) + 1 ∧
    ∀ x ∈ A, rr (insert a A) x = rr A x := by
  have hna : a ∉ A := fun h => lt_irrefl _ (hm _ h)
  constructor
  · have h : (insert a A).filter (· ≤ a) = insert a A := by
      apply filter_true_of_mem
      intro x hx
      rcases mem_insert.mp hx with rfl | hx
      · rfl
      · exact (hm _ hx).le
    simp [rr, h, hna]
  · intro x hx
    have h : (insert a A).filter (· ≤ x) = A.filter (· ≤ x) := by
      ext y
      simp only [mem_filter, mem_insert]
      constructor
      · rintro ⟨rfl | hy, hyx⟩
        · exact False.elim ((not_le.mpr (hm x hx)) hyx)
        · exact ⟨hy, hyx⟩
      · exact fun h => ⟨Or.inr h.1, h.2⟩
    simp [rr, h]

private theorem rank_squares (A : Finset ℚ) :
    6 * (∑ x ∈ A, rr A x ^ 2) =
      (A.card : ℝ) * (A.card + 1) * (2 * A.card + 1) := by
  induction A using Finset.induction_on_max with
  | empty => simp
  | insert a A hm ih =>
    have hna : a ∉ A := fun h => lt_irrefl _ (hm _ h)
    obtain ⟨hn, ho⟩ := rank_insert hm
    rw [sum_insert hna, hn, card_insert_of_notMem hna, Nat.cast_add, Nat.cast_one]
    rw [sum_congr rfl (fun x hx => congrArg (· ^ 2) (ho x hx))]
    linarith only [ih]

private theorem cross_sum {a : ℚ} {A : Finset ℚ}
    (hm : ∀ x ∈ A, x < a) (hu : ∀ x ∈ A, 0 < x) (ha : a ≤ 1) :
    ∑ x ∈ A, bTwo (a - x) =
      (A.card : ℝ) * ((a : ℝ)^2 - a + 1/6) +
        (-2 * (a : ℝ) + 1) * (∑ x ∈ A, (x : ℝ)) + (∑ x ∈ A, (x : ℝ)^2) := by
  calc
    _ = ∑ x ∈ A, (((a : ℝ)^2 - a + 1/6) + (-2*(a : ℝ)+1)*x + (x:ℝ)^2) := by
      apply sum_congr rfl
      intro x hx
      rw [(bTwo_opposite (hu x hx) (hm x hx) ha).1]
      ring
    _ = _ := by simp [sum_add_distrib, ← mul_sum]; ring

private theorem pair_expansion (A : Finset ℚ) (hu : ∀ x ∈ A, 0 < x ∧ x ≤ 1) :
    ∑ x ∈ A, ∑ y ∈ A, bTwo (x-y) =
      2*(A.card:ℝ)*(∑ x ∈ A, (x:ℝ)^2) - 2*(∑ x ∈ A, (x:ℝ))^2 -
      4*(∑ x ∈ A, rr A x*(x:ℝ)) + 2*((A.card:ℝ)+1)*(∑ x ∈ A,(x:ℝ)) +
      (A.card:ℝ)^2/6 := by
  induction A using Finset.induction_on_max with
  | empty => simp
  | insert a A hm ih =>
    have hna : a ∉ A := fun h => lt_irrefl _ (hm _ h)
    have hu' : ∀ x ∈ A, 0 < x ∧ x ≤ 1 := fun x hx => hu x (mem_insert_of_mem hx)
    have ha := (hu a (mem_insert_self a A)).2
    obtain ⟨hn, ho⟩ := rank_insert hm
    have hsym : ∑ x ∈ A, bTwo (x-a) = ∑ x ∈ A, bTwo (a-x) := by
      apply sum_congr rfl
      intro x hx
      obtain ⟨hp, hn'⟩ := bTwo_opposite (hu' x hx).1 (hm x hx) ha
      exact hn'.trans hp.symm
    have hs := cross_sum hm (fun x hx => (hu' x hx).1) ha
    have hr : (∑ x ∈ A, rr (insert a A) x*(x:ℝ)) = ∑ x ∈ A, rr A x*(x:ℝ) :=
      sum_congr rfl (fun x hx => by rw [ho x hx])
    simp only [sum_insert hna, sub_self, sum_add_distrib, card_insert_of_notMem hna,
      Nat.cast_add, Nat.cast_one, hn, hr, hsym, hs, ih hu']
    norm_num [bTwo]
    ring

/-- The finite rank-energy formula with the right endpoint included and centered first moment. -/
theorem rank_energy_pair (A : Finset ℚ) (hne : A.Nonempty)
    (hu : ∀ x ∈ A, 0 < x ∧ x ≤ 1)
    (hmean : (∑ x ∈ A, (x:ℝ)) = ((A.card:ℝ)+1)/2) :
    (A.card : ℝ) * (∑ x ∈ A, ((x:ℝ) - ((A.filter (· ≤ x)).card:ℝ)/(A.card:ℝ))^2) + 1/12 =
      (∑ x ∈ A, ∑ y ∈ A, bTwo (x-y))/2 := by
  have hp : (A.card:ℝ) ≠ 0 := by exact_mod_cast (Finset.card_pos.mpr hne).ne'
  have hs := rank_squares A
  have hsq :
      ∑ x ∈ A, ((x:ℝ) - rr A x/(A.card:ℝ))^2 =
        (∑ x ∈ A, (x:ℝ)^2) - 2/(A.card:ℝ) * (∑ x ∈ A, rr A x*(x:ℝ)) +
        (1/(A.card:ℝ)^2) * (∑ x ∈ A, rr A x^2) := by
    rw [mul_sum, mul_sum, ← sum_sub_distrib, ← sum_add_distrib]
    apply sum_congr rfl
    intro x hx
    ring
  change (A.card : ℝ) * (∑ x ∈ A, ((x:ℝ) - rr A x/(A.card:ℝ))^2) + _ = _
  rw [hsq, pair_expansion A hu, hmean]
  field_simp [hp] at *
  nlinarith only [hs]

end Ratioque.Franel

