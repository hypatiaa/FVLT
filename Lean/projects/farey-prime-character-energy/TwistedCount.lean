import Mathlib

/-!
# Counting the twisted positive Farey staircase

Our arithmetic Fourier convention includes 1/1 and excludes 0/1. The endpoint
correction for Huxley's weighted Franel identity (2012, Theorem 3, (1.16))
is therefore -1/2 in the sawtooth expansion.
-/
open Finset
open scoped BigOperators

namespace TwistedFarey

variable {q : ℕ}

noncomputable def mertens (χ : DirichletCharacter ℂ q) (N : ℕ) : ℂ :=
  ∑ k ∈ Icc 1 N, (ArithmeticFunction.moebius k : ℂ) * χ k

noncomputable def coeff (χ : DirichletCharacter ℂ q) (N m : ℕ) : ℂ :=
  χ m * mertens χ (N / m)

noncomputable def saw (x : ℝ) : ℝ := Int.fract x - 1 / 2

/-- Number of positive reduced numerators with a/d ≤ x for x ∈ [0,1]. -/
noncomputable def ringCount (d : ℕ) (x : ℝ) : ℕ :=
  ((Icc 1 ⌊d * x⌋₊).filter (d.Coprime ·)).card

noncomputable def discrepancy (χ : DirichletCharacter ℂ q) (N : ℕ) (x : ℝ) : ℂ :=
  (∑ d ∈ Icc 1 N, χ d * (ringCount d x : ℂ)) -
    (∑ d ∈ Icc 1 N, χ d * (d.totient : ℂ)) * (x : ℂ)

private theorem mu_sum (d : ℕ) :
    ∑ k ∈ d.divisors, (ArithmeticFunction.moebius k : ℂ) = if d = 1 then 1 else 0 := by
  have h := DFunLike.congr_fun (ArithmeticFunction.moebius_mul_coe_zeta) d
  rw [ArithmeticFunction.coe_mul_zeta_apply, ArithmeticFunction.one_apply] at h
  exact_mod_cast h

private theorem multiples_sum (n k : ℕ) (hk : 0 < k) (f : ℕ → ℂ) :
    (∑ a ∈ Icc 1 n, if k ∣ a then f a else 0) =
      ∑ j ∈ Icc 1 (n / k), f (k*j) := by
  classical
  rw [← Finset.sum_filter]
  symm
  apply Finset.sum_bij (fun j _ => k * j)
  · intro j hj
    obtain ⟨hj1,hjn⟩ := mem_Icc.mp hj
    exact mem_filter.mpr ⟨mem_Icc.mpr ⟨Nat.mul_pos hk hj1,
      by simpa [Nat.mul_comm] using (Nat.le_div_iff_mul_le hk).mp hjn⟩, dvd_mul_right ..⟩
  · intro a _ b _ hab
    exact Nat.eq_of_mul_eq_mul_left hk hab
  · intro a ha
    obtain ⟨ha, ⟨j,rfl⟩⟩ := mem_filter.mp ha
    obtain ⟨hpos,hle⟩ := mem_Icc.mp ha
    refine ⟨j, mem_Icc.mpr ⟨?_,?_⟩, rfl⟩
    · by_contra! hj
      simp_all
    · exact (Nat.le_div_iff_mul_le hk).mpr (by simpa [Nat.mul_comm] using hle)
  · simp

private theorem indicator_coprime (d a : ℕ) (hd : 0 < d) :
    (if d.Coprime a then (1 : ℂ) else 0) =
    ∑ k ∈ d.divisors, if k ∣ a then (ArithmeticFunction.moebius k : ℂ) else 0 := by
  classical
  rw [← sum_filter]
  have e : d.divisors.filter (· ∣ a) = (d.gcd a).divisors := by
    ext k
    simp [Nat.mem_divisors, Nat.dvd_gcd_iff, hd.ne', (Nat.gcd_pos_of_pos_left a hd).ne']
  rw [e, mu_sum]

private theorem ringCount_divisors (d : ℕ) (hd : 0 < d) (x : ℝ) :
    (ringCount d x : ℂ) =
    ∑ k ∈ d.divisors, (ArithmeticFunction.moebius k : ℂ) * (⌊(d / k : ℕ) * x⌋₊ : ℂ) := by
  classical
  let b := ⌊d*x⌋₊
  calc
    _ = ∑ a ∈ Icc 1 b, (if d.Coprime a then (1 : ℂ) else 0) := by
      simp [ringCount, b]
    _ = ∑ k ∈ d.divisors, ∑ a ∈ Icc 1 b,
        if k ∣ a then (ArithmeticFunction.moebius k : ℂ) else 0 := by
      simp_rw [indicator_coprime d _ hd]
      rw [sum_comm]
    _ = _ := by
      refine sum_congr rfl fun k hk => ?_
      rw [multiples_sum _ _ (Nat.pos_of_mem_divisors hk)
        (fun _ => (ArithmeticFunction.moebius k : ℂ))]
      have he : b / k = ⌊(d / k : ℕ) * x⌋₊ := by
        obtain ⟨j,rfl⟩ := (Nat.mem_divisors.mp hk).1
        have hkpos : 0 < k := Nat.pos_of_mem_divisors hk
        have hk' : (k : ℝ) ≠ 0 := by exact_mod_cast hkpos.ne'
        dsimp [b]
        rw [← Nat.floor_div_natCast, Nat.mul_div_cancel_left _ hkpos, Nat.cast_mul]
        congr 1
        field_simp
      simp [he, mul_comm]

private theorem fold_divisors (χ : DirichletCharacter ℂ q) (N : ℕ) (F : ℕ → ℂ) :
    (∑ d ∈ Icc 1 N, χ d *
      ∑ k ∈ d.divisors, (ArithmeticFunction.moebius k : ℂ) * F (d / k)) =
    ∑ m ∈ Icc 1 N, coeff χ N m * F m := by
  classical
  have per (d : ℕ) (hd : d ∈ Icc 1 N) :
      χ d * (∑ k ∈ d.divisors, (ArithmeticFunction.moebius k : ℂ) * F (d / k)) =
      ∑ m ∈ Icc 1 N, if m ∣ d then χ d * (ArithmeticFunction.moebius (d / m) : ℂ) * F m else 0 := by
    obtain ⟨hd1, hdN⟩ := mem_Icc.mp hd
    rw [← sum_filter]
    have hset : (Icc 1 N).filter (· ∣ d) = d.divisors := by
      ext k
      simp only [mem_filter, mem_Icc, Nat.mem_divisors]
      exact ⟨fun h => ⟨h.2, Nat.ne_of_gt hd1⟩, fun h =>
        ⟨⟨Nat.pos_of_dvd_of_pos h.1 hd1,(Nat.le_of_dvd hd1 h.1).trans hdN⟩,h.1⟩⟩
    rw [hset, mul_sum]
    conv_rhs => rw [← Nat.sum_div_divisors d]
    refine sum_congr rfl fun k hk => ?_
    obtain ⟨j,hj⟩ := (Nat.mem_divisors.mp hk).1
    have h1 := Nat.pos_of_mem_divisors hk
    have h2 : 0 < j := by by_contra! hh; simp_all
    rw [hj, Nat.mul_div_cancel_left _ h1, Nat.mul_div_cancel _ h2]
    ring
  rw [sum_congr rfl per, sum_comm]
  refine sum_congr rfl fun m hm => ?_
  have hm1 := (mem_Icc.mp hm).1
  rw [multiples_sum _ _ hm1 (fun d => χ d * (ArithmeticFunction.moebius (d / m) : ℂ) * F m)]
  simp [coeff, mertens, mul_sum, sum_mul, Nat.mul_div_cancel_left _ hm1]
  apply sum_congr rfl
  intro k hk
  ring

theorem coeff_sum (χ : DirichletCharacter ℂ q) (N : ℕ) (hN : 0 < N) :
    ∑ m ∈ Icc 1 N, coeff χ N m = 1 := by
  have h := fold_divisors χ N (fun _ => 1)
  have hN' : 1 ≤ N := hN
  simpa [mu_sum, Finset.mem_Icc, hN'] using h.symm

theorem count_eq_floors (χ : DirichletCharacter ℂ q) (N : ℕ) (x : ℝ) :
    (∑ d ∈ Icc 1 N, χ d * (ringCount d x : ℂ)) =
      ∑ m ∈ Icc 1 N, coeff χ N m * (⌊m*x⌋₊ : ℂ) := by
  rw [← fold_divisors]
  exact sum_congr rfl fun d hd => congrArg _ (ringCount_divisors d (mem_Icc.mp hd).1 x)

theorem ringCount_one (d : ℕ) : ringCount d 1 = d.totient := by
  have h := Nat.filter_coprime_Ico_eq_totient d 1
  have hset : Ico 1 (1 + d) = Icc 1 d := by ext; simp; omega
  simpa [ringCount, hset] using h

theorem slope_eq (χ : DirichletCharacter ℂ q) (N : ℕ) :
    (∑ d ∈ Icc 1 N, χ d * (d.totient : ℂ)) =
    ∑ m ∈ Icc 1 N, coeff χ N m * m := by
  simpa [ringCount_one] using count_eq_floors χ N 1

theorem discrepancy_eq_saw (χ : DirichletCharacter ℂ q) (N : ℕ) (hN : 0 < N)
    {x : ℝ} (hx : x ∈ Set.Icc 0 1) :
    discrepancy χ N x =
      -(∑ m ∈ Icc 1 N, coeff χ N m * (saw (m * x) : ℂ)) - 1/2 := by
  unfold discrepancy
  rw [count_eq_floors, slope_eq, sum_mul, ← sum_sub_distrib]
  have hs (m : ℕ) :
      coeff χ N m * (⌊m*x⌋₊ : ℂ) - coeff χ N m * m * (x : ℂ) =
      -(coeff χ N m * (saw (m*x) : ℂ)) - coeff χ N m / 2 := by
    have hmx : 0 ≤ (m:ℝ)*x := mul_nonneg (Nat.cast_nonneg _) hx.1
    have he : ((⌊m*x⌋₊ : ℕ) : ℝ) = (⌊m*x⌋ : ℤ) := by
      exact_mod_cast (Int.natCast_floor_eq_floor hmx)
    unfold saw Int.fract
    push_cast
    have he' := congrArg Complex.ofReal he
    push_cast at he'
    rw [he']
    ring
  simp_rw [hs]
  rw [sum_sub_distrib, sum_neg_distrib, ← sum_div, coeff_sum χ N hN]

/-- Literal positive Farey ticks in one denominator ring, including 1/1. -/
theorem ringCount_eq_farey_ticks (d : ℕ) (hd : 0 < d) {x : ℝ} (hx : x ∈ Set.Icc 0 1) :
    ringCount d x = ((Icc 1 d).filter
      (fun a : ℕ => d.Coprime a ∧ (a : ℝ) / d ≤ x)).card := by
  unfold ringCount
  congr 1
  ext a
  have hd' : 0 < (d : ℝ) := by exact_mod_cast hd
  have hdx : 0 ≤ (d : ℝ) * x := mul_nonneg hd'.le hx.1
  have hflo : ⌊(d : ℝ) * x⌋₊ ≤ d := by
    calc
      _ ≤ ⌊(d : ℝ) * 1⌋₊ := Nat.floor_mono (mul_le_mul_of_nonneg_left hx.2 hd'.le)
      _ = _ := by simp
  simp only [mem_filter, mem_Icc]
  constructor
  · rintro ⟨⟨ha, hle⟩, hcop⟩
    exact ⟨⟨ha, hle.trans hflo⟩, hcop, (div_le_iff₀ hd').mpr
      (by simpa [mul_comm] using (Nat.le_floor_iff hdx).mp hle)⟩
  · rintro ⟨⟨ha, _⟩, hcop, hle⟩
    exact ⟨⟨ha, (Nat.le_floor_iff hdx).mpr
      (by simpa [mul_comm] using (div_le_iff₀ hd').mp hle)⟩, hcop⟩

@[simp] theorem coeff_one (χ : DirichletCharacter ℂ q) (N : ℕ) :
    coeff χ N 1 = mertens χ N := by simp [coeff]

end TwistedFarey

