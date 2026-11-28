import Mathlib

namespace AtlasLog
open Finset

/-- In each block the simultaneous two-grading matching pairs rows within
each of the two unit classes modulo four. -/
theorem simultaneous_residual (a b : ℝ) :
    |a|+|b| = max |a+b| |a-b| := by
  rcases le_total 0 a with ha|ha <;> rcases le_total 0 b with hb|hb <;>
    simp only [abs, max_def] <;> split_ifs <;> linarith

/-- All offsets together charge each full block start exactly once. -/
theorem offset_average {ι : Type*} (s : Finset ι) (off : ι → Fin h)
    (w : ι → ℝ) (hh : 0 < h) (U : ℝ)
    (hmatch : ∀ j, U ≤ 2*h + ∑ i ∈ s, if off i = j then w i else 0) :
    U ≤ 2*h + (∑ i ∈ s, w i) / h := by
  have H := Finset.sum_le_sum (s := (Finset.univ : Finset (Fin h))) (fun j _ => hmatch j)
  rw [Finset.sum_add_distrib, Finset.sum_comm (s := Finset.univ) (t := s)] at H
  simp at H
  have hp : 0 < (h : ℝ) := by exact_mod_cast hh
  calc U ≤ (2*(h:ℝ)*h + ∑ i ∈ s, w i)/h := by apply (le_div_iff₀ hp).mpr; linarith
       _ = _ := by field_simp

/-- Separate exceptional and ordinary starts before summing absolute
block imbalances, with an explicit budget for both boundary blocks. -/
theorem exceptional_budget {ι : Type*} (s : Finset ι) (bad : ι → Bool)
    (w : ι → ℝ) (X δ : ℝ) (hX : (s.card : ℝ) ≤ X) (hδ : 0 ≤ δ)
    (hsmall : ∀ t ∈ s, bad t = false → w t ≤ δ)
    (hbad : ∀ t ∈ s, bad t = true → w t ≤ 1)
    (hcount : ((s.filter (fun t => bad t = true)).card : ℝ) ≤ X*δ) :
    ∑ t ∈ s, w t ≤ 2*X*δ := by
  classical
  calc
    _ ≤ ∑ t ∈ s, (δ + if bad t = true then (1:ℝ) else 0) := by
      apply sum_le_sum
      intro t ht
      cases h : bad t with
      | false => simpa [h] using hsmall t ht h
      | true => simp; linarith [hbad t ht h]
    _ = (s.card : ℝ)*δ + ((s.filter (fun t => bad t = true)).card : ℝ) := by
      rw [sum_add_distrib]; simp
    _ ≤ _ := by nlinarith [mul_le_mul_of_nonneg_right hX hδ]
open ArithmeticFunction
open scoped ArithmeticFunction.Moebius

/-- The two signed denominator bands, extended by zero off the active residues. -/
def bandWeight (twisted : Bool) (n : ℕ) : ℤ :=
  if n.Coprime 6 then (if twisted && n % 4 == 3 then -μ n else μ n) else 0

def blockSum (twisted : Bool) (t h : ℕ) : ℤ :=
  ∑ n ∈ Ioc t (t+h), bandWeight twisted n

/-- Instantiate offset averaging on the actual dyadic band. The analytic input
is a count of exceptional starts for the selected Möbius grading. -/
theorem band_budget (twisted : Bool) (X h : ℕ) (hh : 0 < h)
    (s : Finset ℕ) (hs : s = Icc (X/2) (X-h)) (off : ℕ → Fin h)
    (bad : ℕ → Bool) (U δ : ℝ) (hδ : 0 ≤ δ) (hc : (s.card : ℝ) ≤ X)
    (hm : ∀ j, U ≤ 2*h + ∑ t ∈ s,
      if off t = j then |(blockSum twisted t h : ℝ)| else 0)
    (hn : ∀ t ∈ Icc (X/2) (X-h), bad t = false → |(blockSum twisted t h : ℝ)| / h ≤ δ)
    (he : ((s.filter (fun t => bad t = true)).card : ℝ) ≤ X*δ) :
    U ≤ 2*h + 2*X*δ := by
  have hp : (0:ℝ) < h := by exact_mod_cast hh
  have unit (n : ℕ) : |(bandWeight twisted n : ℝ)| ≤ 1 := by
    unfold bandWeight
    split_ifs <;> rcases moebius_eq_or n with h|h|h <;> norm_num [h]
  have hb (t : ℕ) : |(blockSum twisted t h : ℝ)| / h ≤ 1 := by
    apply (div_le_iff₀ hp).2
    simp only [blockSum, Int.cast_sum]
    calc _ ≤ ∑ n ∈ Ioc t (t+h), |(bandWeight twisted n : ℝ)| := Finset.abs_sum_le_sum_abs ..
         _ ≤ ∑ _n ∈ Ioc t (t+h), (1:ℝ) := sum_le_sum (fun n _ => unit n)
         _ = _ := by simp
  have budget := exceptional_budget s bad (fun t => |(blockSum twisted t h : ℝ)| / h)
    X δ hc hδ (hs ▸ hn) (fun t _ _ => hb t) he
  rw [← Finset.sum_div] at budget
  exact (offset_average s off _ hh U hm).trans (by linarith)
end AtlasLog
