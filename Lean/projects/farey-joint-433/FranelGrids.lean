import Verified

noncomputable section

namespace Ratioque.Franel

open RHConnections

/-- The Farey fractions of order `N` in `(0, 1]`: `j/q` with `1 ≤ j ≤ q ≤ N`, `gcd(j, q) = 1`. -/
def fareySet (N : ℕ) : Finset ℚ :=
  (((Finset.Icc 1 N) ×ˢ (Finset.Icc 1 N)).filter (fun p => p.1 ≤ p.2 ∧ Nat.Coprime p.1 p.2)).image
    (fun p => (p.1 : ℚ) / p.2)

/-- `Φ(N) = |F_N ∩ (0, 1]|`. -/
def Phi (N : ℕ) : ℕ := (fareySet N).card

/-- Rank of `r` in the Farey sequence: the number of Farey fractions `≤ r` (equals its sorted index for `r ∈ F_N`). -/
def rank (N : ℕ) (r : ℚ) : ℕ := ((fareySet N).filter (fun r' => r' ≤ r)).card

/-- Franel's normalized energy `I_N = Φ · Σ_k (r_k - k/Φ)² + 1/12`. -/
def franelEnergy (N : ℕ) : ℝ :=
  (Phi N : ℝ) * ∑ r ∈ fareySet N, ((r : ℝ) - (rank N r : ℝ) / (Phi N : ℝ)) ^ 2 + 1 / 12

open RHConnections.ArithmeticFourierInversion

private theorem repr_positive {r : ℚ} (h : 0 < r) :
    (r.num.natAbs : ℚ) / r.den = r := by
  rw [Nat.cast_natAbs, abs_of_nonneg (Rat.num_pos.mpr h).le]
  exact Rat.num_div_den r

private theorem repr_in_band {r : ℚ} (h : 0 < r) (h' : r ≤ 1) :
    1 ≤ r.num.natAbs ∧ r.num.natAbs ≤ r.den := by
  have hd : 0 < (r.den : ℚ) := by exact_mod_cast r.pos
  have hh := repr_positive h
  constructor
  · have hn : 0 < r.num.natAbs := Int.natAbs_pos.mpr (Rat.num_pos.mpr h).ne'
    omega
  · have : (r.num.natAbs : ℚ) ≤ r.den := by
      have hh' := (div_le_iff₀ hd).mp (hh.trans_le h')
      simpa using hh'
    exact_mod_cast this

private theorem grid_den_dvd (a k : ℕ) : ((a : ℚ) / k).den ∣ k := by
  have hd := Rat.den_dvd (a : ℤ) (k : ℤ)
  simpa only [Rat.divInt_eq_div, Int.cast_natCast, Int.natCast_dvd_natCast] using hd

theorem farey_mem_iff {r : ℚ} {N : ℕ} :
    r ∈ fareySet N ↔ 0 < r ∧ r ≤ 1 ∧ r.den ≤ N := by
  constructor
  · intro h
    obtain ⟨⟨a,k⟩, hp, rfl⟩ := Finset.mem_image.mp h
    obtain ⟨ha', hk'⟩ := Finset.mem_filter.mp hp
    obtain ⟨ha,hk⟩ := Finset.mem_product.mp ha'
    obtain ⟨ha1,_⟩ := Finset.mem_Icc.mp ha
    obtain ⟨hk1,hkN⟩ := Finset.mem_Icc.mp hk
    change a ≤ k ∧ _ at hk'
    have hk0 : 0 < (k:ℚ) := by exact_mod_cast (show 0 < k by omega)
    refine ⟨div_pos (by exact_mod_cast (show 0 < a by omega)) hk0, ?_, ?_⟩
    · apply (div_le_iff₀ hk0).mpr
      simpa using (show (a:ℚ) ≤ k by exact_mod_cast hk'.1)
    · exact (Nat.le_of_dvd (by omega) (grid_den_dvd a k)).trans hkN
  · rintro ⟨hr,hr1,hd⟩
    obtain ⟨ha1,hak⟩ := repr_in_band hr hr1
    refine Finset.mem_image.mpr ⟨(r.num.natAbs,r.den), Finset.mem_filter.mpr ⟨?_,hak,r.reduced⟩,
      repr_positive hr⟩
    exact Finset.mem_product.mpr ⟨Finset.mem_Icc.mpr ⟨ha1,hak.trans hd⟩,
      Finset.mem_Icc.mpr ⟨r.pos,hd⟩⟩

theorem farey_nonempty {N : ℕ} (hN : 1 ≤ N) : (fareySet N).Nonempty :=
  ⟨1, farey_mem_iff.mpr (by simpa using hN)⟩

private theorem grid_eq_filter {N k : ℕ} (hk : 1 ≤ k) (hkN : k ≤ N) (f : ℚ → ℝ) :
    (∑ a ∈ Finset.Icc 1 k, f ((a:ℚ)/k)) =
    ∑ r ∈ (fareySet N).filter (fun r => r.den ∣ k), f r := by
  have hkq : 0 < (k:ℚ) := by exact_mod_cast (show 0 < k by omega)
  apply Finset.sum_bij (fun (a : ℕ) _ => (a:ℚ)/k)
  · intro a ha
    obtain ⟨ha1,hak⟩ := Finset.mem_Icc.mp ha
    have hdiv := grid_den_dvd a k
    refine Finset.mem_filter.mpr ⟨farey_mem_iff.mpr ⟨div_pos ?_ hkq, ?_,
      (Nat.le_of_dvd (by omega) hdiv).trans hkN⟩, hdiv⟩
    · exact_mod_cast (show 0 < a by omega)
    · apply (div_le_iff₀ hkq).mpr
      simpa using (show (a:ℚ) ≤ k by exact_mod_cast hak)
  · intro a _ b _ h
    exact_mod_cast (div_left_inj' hkq.ne').mp h
  · intro r hr
    obtain ⟨hr, hd⟩ := Finset.mem_filter.mp hr
    obtain ⟨hr0,hr1,_⟩ := farey_mem_iff.mp hr
    obtain ⟨b, hb⟩ := hd
    have hb0 : 0 < b := by by_contra! hz; simp [Nat.le_zero.mp hz] at hb; omega
    obtain ⟨ha1,ha2⟩ := repr_in_band hr0 hr1
    refine ⟨r.num.natAbs*b, Finset.mem_Icc.mpr ⟨Nat.mul_pos ha1 hb0, hb ▸ Nat.mul_le_mul_right b ha2⟩,?_⟩
    rw [hb, Nat.cast_mul, Nat.cast_mul, mul_div_mul_right _ _ (by exact_mod_cast hb0.ne')]
    exact repr_positive hr0
  · intros; rfl

theorem mertens_grid_weight {t : ℕ} (ht : 1 ≤ t) :
    (∑ k ∈ Finset.Icc 1 t, M (t/k)) = 1 := by
  let z : ArithmeticFunction ℝ := ↑ArithmeticFunction.zeta
  have idz : z * muR = 1 := ArithmeticFunction.coe_zeta_mul_coe_moebius
  have h := ArithmeticFunction.sum_Ioc_mul_eq_sum_sum z muR t
  rw [idz] at h
  have heq : Finset.Icc 1 t = Finset.Ioc 0 t := by ext; simp; omega
  rw [heq]
  calc
    _ = ∑ k ∈ Finset.Ioc 0 t, z k * M (t/k) := by
      apply Finset.sum_congr rfl
      intro k hk
      have hk0 := (Finset.mem_Ioc.mp hk).1.ne'
      simp [z, hk0]
    _ = _ := h.symm.trans (by simp [ArithmeticFunction.one_apply, show t ≠ 0 by omega])

private theorem divisor_grid_weight {N d : ℕ} (hd : 0 < d) (hN : d ≤ N) :
    (∑ k ∈ (Finset.Icc 1 N).filter (fun k => d ∣ k), M (N/k)) = 1 := by
  rw [← mertens_grid_weight (Nat.div_pos hN hd)]
  symm
  apply Finset.sum_bij (fun l _ => d*l)
  · intro l hl
    obtain ⟨hl1,hlL⟩ := Finset.mem_Icc.mp hl
    exact Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨Nat.mul_pos hd hl1,
      by simpa [mul_comm] using (Nat.le_div_iff_mul_le hd).mp hlL⟩, dvd_mul_right _ _⟩
  · intro a _ b _ hab
    exact Nat.eq_of_mul_eq_mul_left hd hab
  · intro k hk
    obtain ⟨hk, ⟨l, rfl⟩⟩ := Finset.mem_filter.mp hk
    obtain ⟨hk1,hkN⟩ := Finset.mem_Icc.mp hk
    exact ⟨l, Finset.mem_Icc.mpr ⟨Nat.pos_of_mul_pos_left hk1,
      (Nat.le_div_iff_mul_le hd).mpr (mul_comm l d ▸ hkN)⟩, rfl⟩
  · intro l _
    rw [Nat.div_div_eq_div_mul]

theorem farey_grid_disintegration {N : ℕ} (_hN : 1 ≤ N) (f : ℚ → ℝ) :
    (∑ r ∈ fareySet N, f r) =
    ∑ k ∈ Finset.Icc 1 N, M (N/k) * ∑ a ∈ Finset.Icc 1 k, f ((a:ℚ)/k) := by
  symm
  calc
    _ = ∑ k ∈ Finset.Icc 1 N, ∑ r ∈ fareySet N, (if r.den ∣ k then M (N/k) else 0) * f r := by
      refine Finset.sum_congr rfl fun k hk => ?_
      obtain ⟨hk1,hkN⟩ := Finset.mem_Icc.mp hk
      rw [grid_eq_filter hk1 hkN f, Finset.mul_sum, Finset.sum_filter]
      apply Finset.sum_congr rfl
      intro r _
      split_ifs <;> simp_all
    _ = _ := by
      rw [Finset.sum_comm]
      refine Finset.sum_congr rfl fun r hr => ?_
      rw [← Finset.sum_mul, ← Finset.sum_filter,
        divisor_grid_weight r.pos (farey_mem_iff.mp hr).2.2, one_mul]


private theorem grid_first_moment (k : ℕ) (hk : 1 ≤ k) :
    (∑ a ∈ Finset.Icc 1 k, (((a:ℚ)/k : ℚ) : ℝ)) = ((k:ℝ) + 1) / 2 := by
  have hs (n : ℕ) : (∑ a ∈ Finset.Icc 1 n, (a:ℝ)) = n*((n:ℝ)+1)/2 := by
    induction n with
    | zero => simp
    | succ n ih =>
      rw [Finset.sum_Icc_succ_top (by omega : 1 ≤ n+1), ih, Nat.cast_succ]
      ring
  simp only [Rat.cast_div, Rat.cast_natCast, ← Finset.sum_div, hs]
  have h0 : (k:ℝ) ≠ 0 := by exact_mod_cast (show k ≠ 0 by omega)
  field_simp

theorem farey_first_moment {N : ℕ} (hN : 1 ≤ N) :
    (∑ r ∈ fareySet N, (r:ℝ)) = ((Phi N : ℝ) + 1)/2 := by
  have hconst := farey_grid_disintegration hN (fun _ => (1:ℝ))
  have hcard : (Phi N : ℝ) = ∑ k ∈ Finset.Icc 1 N, M (N/k) * (k:ℝ) := by
    simpa [Phi, Nat.card_Icc] using hconst
  rw [farey_grid_disintegration hN, hcard]
  calc
    _ = ∑ k ∈ Finset.Icc 1 N, (M (N/k) * k + M (N/k))/2 := by
      refine Finset.sum_congr rfl fun k hk => ?_
      rw [grid_first_moment k (Finset.mem_Icc.mp hk).1]
      ring
    _ = _ := by rw [← Finset.sum_div, Finset.sum_add_distrib, mertens_grid_weight hN]

end Ratioque.Franel

