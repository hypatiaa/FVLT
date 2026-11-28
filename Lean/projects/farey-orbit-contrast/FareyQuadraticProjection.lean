import FareyRankInversion

/-! The quadratic projection of the literal order-N Farey rank errors at a/7.
    The average is over all six units, with the usual real quadratic character. -/
namespace FareyOrbitSeven

local instance : Fact (Nat.Prime 7) := ⟨by decide⟩

theorem chi7_eq_legendre (k : ℕ) : chi7 k = legendreSym 7 (k : ℤ) := by
  have hp : chi7 k = chi7 (k % 7) := by simp [chi7]
  rw [hp, legendreSym.mod 7 (k : ℤ)]
  change chi7 (k % 7) = legendreSym 7 ((k : ℤ) % (7 : ℤ))
  have hm : (k : ℤ) % (7 : ℤ) = ((k % 7 : ℕ) : ℤ) := by omega
  rw [hm]
  have hr : k % 7 < 7 := Nat.mod_lt _ (by decide)
  generalize k % 7 = r at *
  interval_cases r <;> first
    | (change (0 : ℤ) = _; norm_num)
    | (change (1 : ℤ) = _; norm_num)
    | (change (-1 : ℤ) = _; norm_num)

private theorem weightedRows (t : ℕ) (w : ℕ → ℤ) :
    contrast (fun a => sumTo t fun k => w k * floorRow a k) +
      sumTo t (fun k => w k * (k : ℤ)) = sumTo t (fun k => w k * chi7 k) := by
  induction t with
  | zero => simp [contrast, sumTo]
  | succ n ih =>
    have hk := floor_contrast (n+1)
    simp only [contrast] at hk ih ⊢
    simp only [sumTo]
    linear_combination ih + w (n+1) * hk

/-- The equality is in integers. Both sides are scaled by seven. -/
theorem scaled_contrast_eq_mertens (N : ℕ) :
    contrast (displacement7 N) = 7 * sumTo N (fun k => ordinaryMertens (N/k) * chi7 k) := by
  let w := fun k => ordinaryMertens (N/k)
  have hw := weightedRows N w
  have length : lengthFarey N = sumTo N (fun k => w k * (k : ℤ)) := by
    rw [lengthFarey, countRank_eq_mertens_floors N 7 (by decide)]
    simp [floorRow, w]
  simp only [contrast] at hw ⊢
  simp only [displacement7, length]
  rw [countRank_eq_mertens_floors N 1 (by decide), countRank_eq_mertens_floors N 2 (by decide),
      countRank_eq_mertens_floors N 4 (by decide), countRank_eq_mertens_floors N 3 (by decide),
      countRank_eq_mertens_floors N 5 (by decide), countRank_eq_mertens_floors N 6 (by decide)]
  dsimp only [w] at hw ⊢
  linear_combination 7 * hw

/-- Seven undoes the integer scaling of each rank and six normalizes the character. -/
def quadraticCoefficient (N : ℕ) : ℚ := (contrast (displacement7 N) : ℚ) / 42

/-- Equal-spacing prediction subtracted from the inclusive rank at a/7. -/
def rankError (N a : ℕ) : ℚ :=
  (countRank N a : ℚ) - (a : ℚ) / 7 * (lengthFarey N : ℚ)

theorem coefficient_from_ranks (N : ℕ) :
    (rankError N 1 + rankError N 2 + rankError N 4 -
      (rankError N 3 + rankError N 5 + rankError N 6)) / 6 = quadraticCoefficient N := by
  simp only [rankError, quadraticCoefficient, contrast, displacement7]
  push_cast
  ring

theorem quadraticCoefficient_eq (N : ℕ) :
    quadraticCoefficient N =
      ((∑ k ∈ Finset.Icc 1 N, ordinaryMertens (N/k) * legendreSym 7 (k : ℤ) : ℤ) : ℚ) / 6 := by
  rw [quadraticCoefficient, scaled_contrast_eq_mertens, sumTo_eq_Icc]
  simp only [chi7_eq_legendre, Int.cast_mul, Int.cast_ofNat]
  ring

theorem quadraticCoefficient_40 : quadraticCoefficient 40 = 1/3 := by
  rw [quadraticCoefficient, order40.2.2]
  norm_num

/-- Mean squared rank error over the six primitive seventh fractions. -/
def anchorEnergy (N : ℕ) : ℚ :=
  (rankError N 1 ^ 2 + rankError N 2 ^ 2 + rankError N 3 ^ 2 +
   rankError N 4 ^ 2 + rankError N 5 ^ 2 + rankError N 6 ^ 2) / 6

theorem quadratic_component_le_energy (N : ℕ) :
    quadraticCoefficient N ^ 2 ≤ anchorEnergy N := by
  let c := quadraticCoefficient N
  have hc : (rankError N 1 + rankError N 2 + rankError N 4 -
      (rankError N 3 + rankError N 5 + rankError N 6)) / 6 = c := coefficient_from_ranks N
  have h := congrArg (fun x : ℚ => x * c) hc
  change c ^ 2 ≤ _
  unfold anchorEnergy
  nlinarith only [h, sq_nonneg (rankError N 1 - c), sq_nonneg (rankError N 2 - c),
    sq_nonneg (rankError N 4 - c), sq_nonneg (rankError N 3 + c),
    sq_nonneg (rankError N 5 + c), sq_nonneg (rankError N 6 + c)]

end FareyOrbitSeven
