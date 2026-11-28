import FareyOrbitSeven
import TwistedCount

/-! The literal inclusive Farey headcount at a/7 in terms of the ordinary
Mertens function. The modulus-one specialization counts all denominators. -/

namespace FareyOrbitSeven

open Finset

/-- The ordinary summatory Möbius function, with positive integer index. -/
def ordinaryMertens (N : ℕ) : ℤ :=
  ∑ j ∈ Icc 1 N, ArithmeticFunction.moebius j

theorem sumTo_eq_Icc (N : ℕ) (f : ℕ → ℤ) :
    sumTo N f = ∑ j ∈ Icc 1 N, f j := by
  induction N with
  | zero => simp [sumTo]
  | succ n ih =>
    have hset : Icc 1 (n+1) = insert (n+1) (Icc 1 n) := by
      ext j
      simp only [mem_Icc, mem_insert]
      omega
    rw [sumTo, ih, hset, sum_insert (by simp)]
    abel

private theorem floorAt (a k : ℕ) :
    ⌊(k : ℝ) * ((a : ℝ)/7)⌋₊ = a*k/7 := by
  have h : (k : ℝ) * ((a : ℝ)/7) = ((a*k : ℕ) : ℝ) / (7 : ℕ) := by
    push_cast
    ring
  rw [h, Nat.floor_div_eq_div]

private theorem countRow (a q : ℕ) (ha : a ≤ 7) :
    (sumTo q fun u => if u.gcd q = 1 ∧ 7*u ≤ a*q then 1 else 0) =
      (TwistedFarey.ringCount q ((a:ℝ)/7) : ℤ) := by
  rw [sumTo_eq_Icc, Finset.sum_boole, TwistedFarey.ringCount, floorAt]
  congr 2
  ext u
  simp only [mem_filter, mem_Icc, Nat.Coprime, Nat.gcd_comm q u]
  have hprod := Nat.mul_le_mul_right q ha
  constructor
  · rintro ⟨⟨hu, _⟩, hg, hmul⟩
    exact ⟨⟨hu, (Nat.le_div_iff_mul_le (by decide)).mpr (by omega)⟩, hg⟩
  · rintro ⟨⟨hu, hdiv⟩, hg⟩
    have hmul := (Nat.le_div_iff_mul_le (by decide : 0 < 7)).mp hdiv
    exact ⟨⟨hu, by omega⟩, hg, by omega⟩

private theorem trivial_eval (k : ℕ) : (1 : DirichletCharacter ℂ 1) k = 1 := by
  rw [Subsingleton.elim (k : ZMod 1) 1, map_one]

/-- General-order inversion of the actual positive primitive-pair rank, including
the rational endpoint and the order zero empty sum. -/
theorem countRank_eq_mertens_floors (N a : ℕ) (ha : a ≤ 7) :
    countRank N a = sumTo N (fun k => ordinaryMertens (N/k) * floorRow a k) := by
  unfold countRank
  simp_rw [countRow a _ ha]
  rw [sumTo_eq_Icc, sumTo_eq_Icc]
  have h := TwistedFarey.count_eq_floors (1 : DirichletCharacter ℂ 1) N ((a:ℝ)/7)
  simp only [TwistedFarey.coeff, TwistedFarey.mertens, trivial_eval, mul_one, one_mul, floorAt] at h
  unfold ordinaryMertens floorRow
  apply Int.cast_injective (α := ℂ)
  push_cast
  exact h

end FareyOrbitSeven
