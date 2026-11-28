import CrystalBridge

/-!
# Prime-to-six Möbius sums from twisted Mertens sums

The two public declarations implement C1a and C1 of Opus's converse specification.
The first inverts the finite sieve for 2 and 3. The second sums the factors
2^(-θa) and 3^(-θb) geometrically, preserving the Mertens exponent θ.
-/

noncomputable section

namespace Ratioque.CrystalBridge

open Filter Asymptotics
open scoped Topology

private lemma c1a_unroll_sieve (p : ℕ) (c : ℂ) (F G : ℝ → ℂ)
    (hstep : ∀ t, F t = G t - c * G (t / p))
    (hzero : ∀ t, ⌊t⌋₊ = 0 → G t = 0) :
    ∀ K : ℕ, ∀ t : ℝ, ⌊t⌋₊ < p ^ K →
      G t = ∑ a ∈ Finset.range K, c ^ a * F (t / (p : ℝ) ^ a) := by
  intro K
  induction K with
  | zero =>
    intro t ht
    have hf : ⌊t⌋₊ = 0 := by simpa using ht
    simp [hzero t hf]
  | succ K ih =>
    intro t ht
    have hcut : ⌊t / (p : ℝ)⌋₊ < p ^ K := by
      rw [Nat.floor_div_natCast]
      exact Nat.div_lt_of_lt_mul (by simpa [pow_succ, mul_comm] using ht)
    rw [Finset.sum_range_succ']
    simp only [pow_zero, div_one, one_mul]
    have hshift :
        (∑ a ∈ Finset.range K, c ^ (a + 1) * F (t / (p : ℝ) ^ (a + 1))) =
          c * ∑ a ∈ Finset.range K, c ^ a * F ((t / p) / (p : ℝ) ^ a) := by
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro a _
      rw [show t / (p : ℝ) ^ (a + 1) = (t / p) / (p : ℝ) ^ a by
        rw [pow_succ', div_div]]
      rw [pow_succ]
      ring
    rw [hshift, ← ih (t / p) hcut, hstep t]
    ring

/-- C1a: the prime-to-six sum is a finite `{2,3}`-geometric combination of twisted Mertens values. -/
theorem twistedS6_eq_sum_twistedMertens {N : ℕ} (χ : DirichletCharacter ℂ N) {x : ℝ} (hx : 0 ≤ x) :
    twistedS6 χ x =
      ∑ a ∈ Finset.range (Nat.log 2 ⌊x⌋₊ + 1), ∑ b ∈ Finset.range (Nat.log 3 ⌊x⌋₊ + 1),
        (χ 2) ^ a * (χ 3) ^ b * twistedMertens χ (x / ((2 : ℝ) ^ a * (3 : ℝ) ^ b)) := by
  have hz (B : ℕ) (t : ℝ) (ht : ⌊t⌋₊ = 0) : twistedCoprimeSum χ B t = 0 := by
    simp [twistedCoprimeSum, ht]
  have h2 (t : ℝ) : twistedCoprimeSum χ 3 t =
      twistedCoprimeSum χ 6 t - χ 2 * twistedCoprimeSum χ 6 (t / 2) := by
    simpa using twistedCoprimeSum_sieve_prime χ Nat.prime_two (by decide : Nat.Coprime 2 3) t
  have h3 (t : ℝ) : twistedMertens χ t =
      twistedCoprimeSum χ 3 t - χ 3 * twistedCoprimeSum χ 3 (t / 3) := by
    rw [← twistedCoprimeSum_one χ t]
    simpa using twistedCoprimeSum_sieve_prime χ Nat.prime_three (Nat.coprime_one_right 3) t
  unfold twistedS6
  rw [c1a_unroll_sieve 2 (χ 2) _ _ h2 (hz 6) _ x (Nat.lt_pow_succ_log_self one_lt_two ⌊x⌋₊)]
  apply Finset.sum_congr rfl
  intro a _
  have hp : 1 ≤ (2 : ℝ) ^ a := one_le_pow₀ (by norm_num)
  have hfloor : ⌊x / (2 : ℝ) ^ a⌋₊ ≤ ⌊x⌋₊ := Nat.floor_mono (div_le_self hx hp)
  have hcut : ⌊x / (2 : ℝ) ^ a⌋₊ < 3 ^ (Nat.log 3 ⌊x⌋₊ + 1) :=
    lt_of_le_of_lt hfloor (Nat.lt_pow_succ_log_self (by decide : 1 < 3) ⌊x⌋₊)
  simp only [Nat.cast_ofNat]
  rw [c1a_unroll_sieve 3 (χ 3) _ _ h3 (hz 3) _ _ hcut, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro b _
  simp only [Nat.cast_ofNat, div_div, mul_assoc]

private lemma c1_mertens_global {N : ℕ} (χ : DirichletCharacter ℂ N)
    {θ : ℝ} (hθ : 0 ≤ θ)
    (hM : twistedMertens χ =O[atTop] (fun x : ℝ => x ^ θ)) :
    ∃ C : ℝ, 0 ≤ C ∧ ∀ x : ℝ, 0 ≤ x → ‖twistedMertens χ x‖ ≤ C * x ^ θ := by
  obtain ⟨c, hc, hb⟩ := hM.exists_pos
  obtain ⟨T, hT⟩ := eventually_atTop.mp hb.bound
  let B : ℝ := ∑ k ∈ Finset.Icc 1 ⌊T⌋₊, ‖twistedCoeff χ k‖
  refine ⟨max c B, hc.le.trans (le_max_left _ _), ?_⟩
  intro x hx
  have hxp := Real.rpow_nonneg hx θ
  by_cases hx1 : x < 1
  · have hzero : ⌊x⌋₊ = 0 := Nat.floor_eq_zero.mpr hx1
    have hz : twistedMertens χ x = 0 := by simp [twistedMertens, hzero]
    rw [hz, norm_zero]
    exact mul_nonneg (hc.le.trans (le_max_left _ _)) hxp
  by_cases hlarge : T ≤ x
  · have bound := hT x hlarge
    rw [Real.norm_of_nonneg hxp] at bound
    exact bound.trans (mul_le_mul_of_nonneg_right (le_max_left _ _) hxp)
  have hsub : Finset.Icc 1 ⌊x⌋₊ ⊆ Finset.Icc 1 ⌊T⌋₊ := by
    intro k hk
    rcases Finset.mem_Icc.mp hk with ⟨hk1, hkx⟩
    exact Finset.mem_Icc.mpr ⟨hk1, hkx.trans (Nat.floor_mono (le_of_not_ge hlarge))⟩
  calc ‖twistedMertens χ x‖
      ≤ ∑ k ∈ Finset.Icc 1 ⌊x⌋₊, ‖twistedCoeff χ k‖ := norm_sum_le _ _
    _ ≤ B := Finset.sum_le_sum_of_subset_of_nonneg hsub (fun _ _ _ => norm_nonneg _)
    _ ≤ max c B := le_max_right _ _
    _ ≤ max c B * x ^ θ := le_mul_of_one_le_right
      (hc.le.trans (le_max_left _ _)) (Real.one_le_rpow (le_of_not_gt hx1) hθ)

private lemma c1_rpow_div_natpow {x p : ℝ} (hx : 0 ≤ x) (hp : 0 < p) (k : ℕ) (θ : ℝ) :
    (x / p ^ k) ^ θ = x ^ θ * (p ^ (-θ)) ^ k := by
  rw [Real.div_rpow hx (pow_nonneg hp.le _), div_eq_mul_inv]
  congr 1
  rw [← Real.rpow_natCast, ← Real.rpow_mul hp.le, ← Real.rpow_neg hp.le,
    ← Real.rpow_natCast (p ^ (-θ)) k, ← Real.rpow_mul hp.le]
  congr 1
  ring

private lemma c1_geometric_bound {r : ℝ} (hr : 0 ≤ r) (hr1 : r < 1) (k : ℕ) :
    ∑ j ∈ Finset.range k, r ^ j ≤ 1 / (1 - r) := by
  rw [geom_sum_eq hr1.ne, ← neg_sub (1 : ℝ) (r ^ k), ← neg_sub (1 : ℝ) r, neg_div_neg_eq]
  exact div_le_div_of_nonneg_right (sub_le_self _ (pow_nonneg hr _)) (sub_nonneg.mpr hr1.le)

/-- C1: Mertens-scale cancellation transfers to the dyadic slab. -/
theorem twistedVCancellation_of_twistedMertensCancellation {N : ℕ} (χ : DirichletCharacter ℂ N)
    (h : TwistedMertensCancellation χ) : TwistedVCancellation χ := by
  intro ε hε
  let θ : ℝ := 1 / 2 + ε
  have hθ : 0 < θ := by dsimp [θ]; linarith
  obtain ⟨C, hC, hM⟩ := c1_mertens_global χ hθ.le (h ε hε)
  let r : ℝ := (2 : ℝ) ^ (-θ)
  let s : ℝ := (3 : ℝ) ^ (-θ)
  have hr : 0 < r := Real.rpow_pos_of_pos (by norm_num) _
  have hs : 0 < s := Real.rpow_pos_of_pos (by norm_num) _
  have hr1 : r < 1 := Real.rpow_lt_one_of_one_lt_of_neg (by norm_num) (neg_lt_zero.mpr hθ)
  have hs1 : s < 1 := Real.rpow_lt_one_of_one_lt_of_neg (by norm_num) (neg_lt_zero.mpr hθ)
  have hgr : 0 ≤ 1 / (1 - r) := div_nonneg zero_le_one (sub_nonneg.mpr hr1.le)
  have hgs : 0 ≤ 1 / (1 - s) := div_nonneg zero_le_one (sub_nonneg.mpr hs1.le)
  let K : ℝ := C * (1 / (1 - r)) * (1 / (1 - s))
  have hK : 0 ≤ K := mul_nonneg (mul_nonneg hC hgr) hgs
  have hS : ∀ x : ℝ, 0 ≤ x → ‖twistedS6 χ x‖ ≤ K * x ^ θ := by
    intro x hx
    let A := Nat.log 2 ⌊x⌋₊ + 1
    let B := Nat.log 3 ⌊x⌋₊ + 1
    have hxp := Real.rpow_nonneg hx θ
    have hterm (a b : ℕ) :
        ‖(χ 2) ^ a * (χ 3) ^ b * twistedMertens χ (x / ((2 : ℝ) ^ a * (3 : ℝ) ^ b))‖
          ≤ C * x ^ θ * r ^ a * s ^ b := by
      let y := x / ((2 : ℝ) ^ a * (3 : ℝ) ^ b)
      have hy : 0 ≤ y := by dsimp [y]; positivity
      have h2 : ‖χ 2‖ ^ a ≤ 1 := pow_le_one₀ (norm_nonneg _) (χ.norm_le_one 2)
      have h3 : ‖χ 3‖ ^ b ≤ 1 := pow_le_one₀ (norm_nonneg _) (χ.norm_le_one 3)
      have hw : ‖χ 2‖ ^ a * ‖χ 3‖ ^ b ≤ 1 := by
        simpa using mul_le_mul h2 h3 (pow_nonneg (norm_nonneg _) _) zero_le_one
      calc ‖(χ 2) ^ a * (χ 3) ^ b * twistedMertens χ y‖
          = (‖χ 2‖ ^ a * ‖χ 3‖ ^ b) * ‖twistedMertens χ y‖ := by simp only [norm_mul, norm_pow]
        _ ≤ 1 * ‖twistedMertens χ y‖ := mul_le_mul_of_nonneg_right hw (norm_nonneg _)
        _ ≤ C * y ^ θ := by simpa using hM y hy
        _ = C * x ^ θ * r ^ a * s ^ b := by
          dsimp [y]
          rw [← div_div, c1_rpow_div_natpow (x := x / (2 : ℝ) ^ a) (by positivity)
            (by norm_num : (0 : ℝ) < 3), c1_rpow_div_natpow hx (by norm_num : (0 : ℝ) < 2)]
          dsimp [r, s]
          ring
    have hdouble :
        ‖twistedS6 χ x‖ ≤ ∑ a ∈ Finset.range A, ∑ b ∈ Finset.range B, C * x ^ θ * r ^ a * s ^ b := by
      rw [twistedS6_eq_sum_twistedMertens χ hx]
      refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun a _ => ?_)
      exact (norm_sum_le _ _).trans (Finset.sum_le_sum fun b _ => hterm a b)
    calc ‖twistedS6 χ x‖
        ≤ ∑ a ∈ Finset.range A, ∑ b ∈ Finset.range B, C * x ^ θ * r ^ a * s ^ b := hdouble
      _ = (C * x ^ θ * ∑ a ∈ Finset.range A, r ^ a) * ∑ b ∈ Finset.range B, s ^ b := by
        simp_rw [← Finset.mul_sum]
        rw [← Finset.sum_mul, ← Finset.mul_sum]
      _ ≤ (C * x ^ θ * (1 / (1 - r))) * (1 / (1 - s)) :=
        mul_le_mul (mul_le_mul_of_nonneg_left (c1_geometric_bound hr.le hr1 A) (mul_nonneg hC hxp))
          (c1_geometric_bound hs.le hs1 B) (Finset.sum_nonneg fun _ _ => pow_nonneg hs.le _)
          (mul_nonneg (mul_nonneg hC hxp) hgr)
      _ = K * x ^ θ := by dsimp [K]; ring
  refine isBigO_iff.mpr ⟨2 * K, ?_⟩
  filter_upwards [eventually_ge_atTop (1 : ℝ)] with x hx
  have hx0 : 0 ≤ x := by linarith
  have hx2 : 0 ≤ x / 2 := by linarith
  have hxp := Real.rpow_nonneg hx0 θ
  change ‖twistedV χ x‖ ≤ 2 * K * ‖x ^ θ‖
  rw [twistedV_eq_sub_twistedS6 χ hx0, Real.norm_of_nonneg hxp]
  calc ‖twistedS6 χ x - twistedS6 χ (x / 2)‖
      ≤ ‖twistedS6 χ x‖ + ‖twistedS6 χ (x / 2)‖ := norm_sub_le _ _
    _ ≤ K * x ^ θ + K * (x / 2) ^ θ := add_le_add (hS x hx0) (hS _ hx2)
    _ ≤ K * x ^ θ + K * x ^ θ := add_le_add le_rfl
      (mul_le_mul_of_nonneg_left (Real.rpow_le_rpow hx2 (half_le_self hx0) hθ.le) hK)
    _ = 2 * K * x ^ θ := by ring

end Ratioque.CrystalBridge

#print axioms Ratioque.CrystalBridge.twistedS6_eq_sum_twistedMertens
#print axioms Ratioque.CrystalBridge.twistedVCancellation_of_twistedMertensCancellation
