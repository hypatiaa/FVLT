/-
  ThreeToothVernierBridge.lean — Formal Lean 4.35.0 bridge from the centered
  three-tooth square-root Vernier on the Farey denominator band (X/2 < q ≤ X, (q,6)=1)
  to `Ratioque.CrystalBridge.twistedV`, Mathlib's `RiemannHypothesis`, and `EveryCharacter`.

  Credits: saphir (project lead), Gemini 4 Argon (Vision seat).
  Conditional reductions only: all zero-free/RH theorems take explicit O_ε(x^(1/2+ε)) bounds.
-/

import CrystalBridge

noncomputable section

namespace Ratioque.VernierBridge

open ArithmeticFunction Complex Filter Asymptotics Finset
open scoped ArithmeticFunction.Moebius Topology

/-! ### 1. Centered Three-Tooth Row Definitions -/

/-- Left outer Vernier tooth `exp(i * pi * a * (q - 1) / q)`. -/
def leftTooth (q a : ℕ) : ℂ :=
  Complex.exp (Complex.I * Real.pi * (a : ℂ) * ((q - 1 : ℕ) : ℂ) / (q : ℂ))

/-- Center Vernier tooth `exp(i * pi * a) = (-1)^a`. -/
def centerTooth (a : ℕ) : ℂ :=
  (-1 : ℂ) ^ a

/-- Right outer Vernier tooth `exp(i * pi * a * (q + 1) / q)`. -/
def rightTooth (q a : ℕ) : ℂ :=
  Complex.exp (Complex.I * Real.pi * (a : ℂ) * ((q + 1 : ℕ) : ℂ) / (q : ℂ))

/-- Reduced Farey numerators `1 ≤ a < q` with `gcd a q = 1`. -/
def reducedNumerators (q : ℕ) : Finset ℕ :=
  (Finset.Ico 1 q).filter (fun a => Nat.Coprime a q)

def leftToothRowSum (q : ℕ) : ℂ :=
  ∑ a ∈ reducedNumerators q, leftTooth q a

def centerToothRowSum (q : ℕ) : ℂ :=
  ∑ a ∈ reducedNumerators q, centerTooth a

def rightToothRowSum (q : ℕ) : ℂ :=
  ∑ a ∈ reducedNumerators q, rightTooth q a

/-- Active prime-to-six dyadic denominator band `(x/2, x]`. -/
def bandSet (x : ℝ) : Finset ℕ :=
  (Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊).filter (fun q => Nat.Coprime q 6)

def leftFlankBand {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  ∑ q ∈ bandSet x, χ q * leftToothRowSum q

def centerBand {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  ∑ q ∈ bandSet x, χ q * centerToothRowSum q

def rightFlankBand {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  ∑ q ∈ bandSet x, χ q * rightToothRowSum q

def threeToothEndpoint {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  leftFlankBand χ x + centerBand χ x + rightFlankBand χ x

/-! ### 2. Exact Center Tooth Cancellation (`F_0(q) = 0`) -/

private lemma coprime_sub_left_of_lt {a q : ℕ} (ha : Nat.Coprime a q) (hlt : a ≤ q) :
    Nat.Coprime (q - a) q := by
  refine Nat.coprime_of_dvd' fun p _ hpqa hpq => ?_
  have hpa : p ∣ a := by
    have := Nat.dvd_sub hpq hpqa
    rwa [Nat.sub_sub_self hlt] at this
  exact ha.gcd_eq_one ▸ Nat.dvd_gcd hpa hpq

private lemma neg_one_pow_sub_of_odd {a q : ℕ} (hodd : Odd q) (hle : a ≤ q) :
    (-1 : ℂ) ^ (q - a) = - ((-1 : ℂ) ^ a) := by
  have hprod : (-1 : ℂ) ^ a * (-1 : ℂ) ^ (q - a) = -1 := by
    rw [← pow_add, Nat.add_sub_of_le hle, hodd.neg_one_pow]
  have hsq : (-1 : ℂ) ^ a * (-1 : ℂ) ^ a = 1 := by
    rw [← pow_add, ← two_mul, pow_mul]
    simp
  calc
    (-1 : ℂ) ^ (q - a) = ((-1 : ℂ) ^ a * (-1 : ℂ) ^ a) * (-1 : ℂ) ^ (q - a) := by rw [hsq, one_mul]
    _ = (-1 : ℂ) ^ a * ((-1 : ℂ) ^ a * (-1 : ℂ) ^ (q - a)) := by ring
    _ = (-1 : ℂ) ^ a * (-1) := by rw [hprod]
    _ = -((-1 : ℂ) ^ a) := by ring

theorem centerToothRowSum_eq_zero {q : ℕ} (_hq1 : 1 < q) (hodd : Odd q) :
    centerToothRowSum q = 0 := by
  have hmem : ∀ a ∈ reducedNumerators q, q - a ∈ reducedNumerators q := by
    intro a ha
    rw [reducedNumerators, Finset.mem_filter, Finset.mem_Ico] at ha ⊢
    rcases ha with ⟨⟨ha1, haq⟩, hcop⟩
    have hqsub_pos : 1 ≤ q - a := Nat.le_sub_of_add_le' (by omega)
    have hqsub_lt : q - a < q := by omega
    exact ⟨⟨hqsub_pos, hqsub_lt⟩, coprime_sub_left_of_lt hcop (le_of_lt haq)⟩
  have hswap : centerToothRowSum q = - centerToothRowSum q := by
    calc
      centerToothRowSum q
          = ∑ a ∈ reducedNumerators q, centerTooth (q - a) := by
            refine Finset.sum_bij (fun a _ => q - a) (fun a ha => hmem a ha) ?_ ?_
              (fun a ha => by
                simp only [centerTooth]
                rw [Nat.sub_sub_self (le_of_lt (Finset.mem_Ico.mp (Finset.mem_filter.mp ha).1).2)])
            · intro a₁ ha₁ a₂ ha₂ heq
              rw [reducedNumerators, Finset.mem_filter, Finset.mem_Ico] at ha₁ ha₂
              omega
            · intro b hb
              refine ⟨q - b, hmem b hb, ?_⟩
              rw [reducedNumerators, Finset.mem_filter, Finset.mem_Ico] at hb
              omega
      _ = ∑ a ∈ reducedNumerators q, - centerTooth a := by
            refine Finset.sum_congr rfl fun a ha => ?_
            rw [reducedNumerators, Finset.mem_filter, Finset.mem_Ico] at ha
            exact neg_one_pow_sub_of_odd hodd (le_of_lt ha.1.2)
      _ = - centerToothRowSum q := by simp [centerToothRowSum, Finset.sum_neg_distrib]
  have h2 : (2 : ℂ) * centerToothRowSum q = 0 := by linear_combination hswap
  exact (mul_eq_zero.mp h2).resolve_left (by norm_num)

/-! ### 3. Primitive Root Sum Equals `μ(q)` and Flank Permutation Identity -/

/-- Primitive `q`-th root sum over `a < q, gcd a q = 1`. -/
def primitiveRootSum (q : ℕ) : ℂ :=
  ∑ a ∈ (Finset.range q).filter (fun a => Nat.Coprime a q),
    Complex.exp (2 * Real.pi * Complex.I * (a : ℂ) / (q : ℂ))

private lemma exp_two_pi_div_ne_one {q : ℕ} (hq1 : 1 < q) :
    Complex.exp (2 * Real.pi * Complex.I / (q : ℂ)) ≠ 1 := by
  intro h
  rw [Complex.exp_eq_one_iff] at h
  rcases h with ⟨k, hk⟩
  have hq0 : (q : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  have h2pi : (2 * Real.pi * Complex.I : ℂ) ≠ 0 := by
    simp [Real.pi_ne_zero, Complex.I_ne_zero]
  have hmul : (1 : ℂ) = (k : ℂ) * (q : ℂ) := by
    have h1 : (2 * Real.pi * Complex.I : ℂ) / (q : ℂ) = (k : ℂ) * (2 * Real.pi * Complex.I) := hk
    have h2 : (1 / (q : ℂ)) * (2 * Real.pi * Complex.I) = ((k : ℂ)) * (2 * Real.pi * Complex.I) := by
      calc (1 / (q : ℂ)) * (2 * Real.pi * Complex.I) = (2 * Real.pi * Complex.I) / (q : ℂ) := by ring
      _ = (k : ℂ) * (2 * Real.pi * Complex.I) := h1
    have h3 : (1 / (q : ℂ)) = (k : ℂ) := mul_right_cancel₀ h2pi h2
    calc (1 : ℂ) = (1 / (q : ℂ)) * (q : ℂ) := by field_simp [hq0]
    _ = (k : ℂ) * (q : ℂ) := by rw [h3]
  have hre : (1 : ℝ) = (k : ℝ) * (q : ℝ) := by
    have := congrArg Complex.re hmul
    simpa using this
  have hq_ge : (2 : ℝ) ≤ (q : ℝ) := by exact_mod_cast hq1
  have hk_int : (1 : ℤ) = k * (q : ℤ) := by
    exact_mod_cast hre
  have hq_dvd : (q : ℤ) ∣ 1 := ⟨k, by linarith⟩
  have hq_le : (q : ℤ) ≤ 1 := Int.le_of_dvd (by decide) hq_dvd
  omega

private lemma sum_all_roots_eq {q : ℕ} (hq : 1 ≤ q) :
    ∑ k ∈ Finset.range q, Complex.exp (2 * Real.pi * Complex.I * (k : ℂ) / (q : ℂ)) =
      if q = 1 then 1 else 0 := by
  by_cases hq1 : q = 1
  · subst hq1
    simp
  · have hgt : 1 < q := by omega
    simp only [hq1, ↓reduceIte]
    set ω : ℂ := Complex.exp (2 * Real.pi * Complex.I / (q : ℂ))
    have hterm : ∀ k ∈ Finset.range q,
        Complex.exp (2 * Real.pi * Complex.I * (k : ℂ) / (q : ℂ)) = ω ^ k := by
      intro k _
      rw [← Complex.exp_nat_mul]
      congr 1
      ring
    rw [Finset.sum_congr rfl hterm, geom_sum_eq (exp_two_pi_div_ne_one hgt) q]
    have hpow : ω ^ q = 1 := by
      rw [← Complex.exp_nat_mul]
      have hq0 : (q : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
      have harg : (q : ℂ) * (2 * Real.pi * Complex.I / (q : ℂ)) = 2 * Real.pi * Complex.I := by
        field_simp [hq0]
      rw [harg]
      exact Complex.exp_two_pi_mul_I
    rw [hpow]
    simp

private lemma primitiveRootSum_eq_moebius_of_div {q : ℕ} (hq : 1 ≤ q) :
    primitiveRootSum q = (ArithmeticFunction.moebius q : ℂ) := by
  have hdiv_sum : ∀ n > 0, ∑ d ∈ n.divisors, primitiveRootSum d = if n = 1 then (1 : ℂ) else 0 := by
    intro n hn
    rw [← sum_all_roots_eq hn]
    -- Partition `k ∈ range n` by exact order `d = n / Nat.gcd k n ∈ n.divisors`
    have hmaps : ∀ k ∈ Finset.range n, n / Nat.gcd k n ∈ n.divisors := by
      intro k _
      exact Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd (Nat.gcd_dvd_right k n), by omega⟩
    rw [← Finset.sum_fiberwise_of_maps_to hmaps]
    refine Finset.sum_congr rfl fun d hd => ?_
    have hd_dvd : d ∣ n := (Nat.mem_divisors.mp hd).1
    have hd_pos : 0 < d := Nat.pos_of_mem_divisors hd
    let m : ℕ := n / d
    have hm_pos : 0 < m := Nat.div_pos (Nat.le_of_dvd hn hd_dvd) hd_pos
    have hnm : m * d = n := Nat.div_mul_cancel hd_dvd
    have hm_ne : m ≠ 0 := by omega
    -- Bijection `a ↦ a * m` between `(range d).filter (Coprime · d)` and `{k ∈ range n | n / gcd k n = d}`
    refine Finset.sum_bij'
      (fun a _ => a * m)
      (fun k _ => k / m)
      ?_ ?_ ?_ ?_ ?_
    · intro a ha
      rw [Finset.mem_filter, Finset.mem_range] at ha
      rw [Finset.mem_filter, Finset.mem_range]
      have hlt : a * m < n := by
        calc a * m < d * m := Nat.mul_lt_mul_of_pos_right ha.1 hm_pos
        _ = n := by rw [mul_comm, hnm]
      refine ⟨hlt, ?_⟩
      have hgcd : Nat.gcd (a * m) n = m := by
        calc Nat.gcd (a * m) n = Nat.gcd (a * m) (d * m) := by rw [← hnm, mul_comm m d]
        _ = Nat.gcd a d * m := Nat.gcd_mul_right _ _ _
        _ = 1 * m := by rw [ha.2.gcd_eq_one]
        _ = m := one_mul m
      rw [hgcd, ← hnm]
      exact Nat.mul_div_right d hm_pos
    · intro k hk
      simp only [Finset.mem_filter, Finset.mem_range] at hk
      rcases hk with ⟨hk_lt, hk_eq⟩
      have hgcd_dvd : Nat.gcd k n ∣ n := Nat.gcd_dvd_right k n
      have hgcd_eq : Nat.gcd k n = m := by
        have h1 : n / Nat.gcd k n * Nat.gcd k n = n := Nat.div_mul_cancel hgcd_dvd
        have h2 : d * Nat.gcd k n = d * m := by
          calc d * Nat.gcd k n = n / Nat.gcd k n * Nat.gcd k n := by rw [hk_eq]
          _ = n := h1
          _ = d * m := by rw [← hnm, mul_comm]
        exact mul_left_cancel₀ (by omega) h2
      have hm_dvd_k : m ∣ k := hgcd_eq ▸ Nat.gcd_dvd_left k n
      have hk_div_lt : k / m < d := by
        rw [Nat.div_lt_iff_lt_mul hm_pos, mul_comm, hnm]
        exact hk_lt
      have hcop : Nat.Coprime (k / m) d := by
        have hg : Nat.gcd ((k / m) * m) (d * m) = Nat.gcd (k / m) d * m :=
          Nat.gcd_mul_right _ _ _
        rw [Nat.div_mul_cancel hm_dvd_k, mul_comm d m, hnm, hgcd_eq] at hg
        have : Nat.gcd (k / m) d * m = 1 * m := by rw [← hg, one_mul]
        exact Nat.coprime_iff_gcd_eq_one.mpr (mul_right_cancel₀ hm_ne this)
      exact Finset.mem_filter.mpr ⟨Finset.mem_range.mpr hk_div_lt, hcop⟩
    · intro a _
      exact Nat.mul_div_cancel a hm_pos
    · intro k hk
      simp only [Finset.mem_filter, Finset.mem_range] at hk
      rcases hk with ⟨_, hk_eq⟩
      have hgcd_dvd : Nat.gcd k n ∣ n := Nat.gcd_dvd_right k n
      have hgcd_eq : Nat.gcd k n = m := by
        have h1 : n / Nat.gcd k n * Nat.gcd k n = n := Nat.div_mul_cancel hgcd_dvd
        have h2 : d * Nat.gcd k n = d * m := by
          calc d * Nat.gcd k n = n / Nat.gcd k n * Nat.gcd k n := by rw [hk_eq]
          _ = n := h1
          _ = d * m := by rw [← hnm, mul_comm]
        exact mul_left_cancel₀ (by omega) h2
      exact Nat.div_mul_cancel (hgcd_eq ▸ Nat.gcd_dvd_left k n)
    · intro a _
      congr 1
      have hd0 : (d : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
      have hm0 : (m : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
      have hnm_c : (m : ℂ) * (d : ℂ) = (n : ℂ) := by exact_mod_cast hnm
      rw [Nat.cast_mul, ← hnm_c]
      field_simp [hm0, hd0]
  have hinv := (ArithmeticFunction.sum_eq_iff_sum_mul_moebius_eq (R := ℂ)).mp hdiv_sum q hq
  calc
    primitiveRootSum q
        = ∑ x ∈ q.divisorsAntidiagonal, (ArithmeticFunction.moebius x.1 : ℂ) *
            (if x.2 = 1 then (1 : ℂ) else 0) := hinv.symm
    _ = (ArithmeticFunction.moebius q : ℂ) * (if (1 : ℕ) = 1 then (1 : ℂ) else 0) := by
          refine Finset.sum_eq_single (q, 1) ?_ ?_
          · intro x hx hne
            rcases x with ⟨u, v⟩
            rw [Nat.mem_divisorsAntidiagonal] at hx
            by_cases hv : v = 1
            · subst hv
              simp only [mul_one] at hx
              have huq : u = q := hx.1
              subst huq
              exact absurd rfl hne
            · simp [hv]
          · intro hnot
            exact absurd (Nat.mem_divisorsAntidiagonal.mpr ⟨mul_one q, by omega⟩) hnot
    _ = (ArithmeticFunction.moebius q : ℂ) := by simp

private lemma exp_two_pi_mul_mod_eq {a u q : ℕ} (hq : 1 ≤ q) :
    Complex.exp (2 * Real.pi * Complex.I * ((a * u : ℕ) : ℂ) / (q : ℂ)) =
      Complex.exp (2 * Real.pi * Complex.I * (((a * u) % q : ℕ) : ℂ) / (q : ℂ)) := by
  have hdiv : a * u = q * ((a * u) / q) + (a * u) % q := (Nat.div_add_mod (a * u) q).symm
  have hq0 : (q : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (by omega)
  have hsplit : 2 * Real.pi * Complex.I * ((a * u : ℕ) : ℂ) / (q : ℂ) =
      (((a * u) / q : ℕ) : ℂ) * (2 * Real.pi * Complex.I) +
        2 * Real.pi * Complex.I * (((a * u) % q : ℕ) : ℂ) / (q : ℂ) := by
    have hc : ((a * u : ℕ) : ℂ) = (q : ℂ) * (((a * u) / q : ℕ) : ℂ) + (((a * u) % q : ℕ) : ℂ) := by
      exact_mod_cast hdiv
    rw [hc]
    field_simp [hq0]
  rw [hsplit, Complex.exp_add, Complex.exp_nat_mul_two_pi_mul_I, one_mul]

private lemma sum_exp_mul_coprime_eq_primitive {q u : ℕ} (hq1 : 1 < q) (hcop : Nat.Coprime u q) :
    ∑ a ∈ reducedNumerators q, Complex.exp (2 * Real.pi * Complex.I * ((a * u : ℕ) : ℂ) / (q : ℂ)) =
      primitiveRootSum q := by
  have hred : reducedNumerators q = (Finset.range q).filter (fun a => Nat.Coprime a q) := by
    ext a
    simp only [reducedNumerators, Finset.mem_filter, Finset.mem_Ico, Finset.mem_range]
    constructor
    · rintro ⟨⟨_, haq⟩, h⟩; exact ⟨haq, h⟩
    · rintro ⟨haq, h⟩
      have ha0 : a ≠ 0 := by
        intro hz
        subst hz
        rw [Nat.coprime_zero_left] at h
        omega
      exact ⟨⟨Nat.pos_of_ne_zero ha0, haq⟩, h⟩
  rw [hred]
  have : NeZero q := ⟨by omega⟩
  have : Fact (1 < q) := ⟨hq1⟩
  let v : ℕ := ((u : ZMod q)⁻¹).val
  have hu_unit : IsUnit (u : ZMod q) := (ZMod.isUnit_iff_coprime u q).mpr hcop
  have huv_z : ((u * v : ℕ) : ZMod q) = 1 := by
    push_cast [v]
    rw [ZMod.natCast_zmod_val, ZMod.mul_inv_of_unit _ hu_unit]
  have hv : (u * v) % q = 1 := by
    have hval := congrArg ZMod.val huv_z
    rw [ZMod.val_natCast, ZMod.val_one] at hval
    exact hval
  have hcop_v : Nat.Coprime v q :=
    Nat.coprime_of_mul_modEq_one u (show v * u ≡ 1 [MOD q] by
      rw [Nat.ModEq, mul_comm, hv, Nat.mod_eq_of_lt hq1])
  have hmem_mul : ∀ {x y : ℕ}, Nat.Coprime y q → x ∈ (Finset.range q).filter (fun a => Nat.Coprime a q) →
      (x * y) % q ∈ (Finset.range q).filter (fun a => Nat.Coprime a q) := by
    intro x y hy hx
    rw [Finset.mem_filter, Finset.mem_range] at hx ⊢
    refine ⟨Nat.mod_lt _ (by omega), ?_⟩
    refine Nat.coprime_of_dvd' fun p _ hpm hpq => ?_
    have hxy : p ∣ x * y := by
      rw [← Nat.div_add_mod (x * y) q]
      exact dvd_add (dvd_mul_of_dvd_left hpq _) hpm
    exact (hx.2.mul_left hy).gcd_eq_one ▸ Nat.dvd_gcd hxy hpq
  calc
    ∑ a ∈ (Finset.range q).filter (fun a => Nat.Coprime a q),
        Complex.exp (2 * Real.pi * Complex.I * ((a * u : ℕ) : ℂ) / (q : ℂ))
      = ∑ a ∈ (Finset.range q).filter (fun a => Nat.Coprime a q),
          Complex.exp (2 * Real.pi * Complex.I * (((a * u) % q : ℕ) : ℂ) / (q : ℂ)) := by
            refine Finset.sum_congr rfl fun a _ => exp_two_pi_mul_mod_eq (by omega)
    _ = primitiveRootSum q := by
          refine Finset.sum_bij' (fun a _ => (a * u) % q) (fun b _ => (b * v) % q)
            (fun a ha => hmem_mul hcop ha) (fun b hb => hmem_mul hcop_v hb) ?_ ?_ (fun _ _ => rfl)
          · intro a ha
            rw [Finset.mem_filter, Finset.mem_range] at ha
            calc ((a * u) % q * v) % q = (a * u * v) % q := by simp [Nat.mod_mul_mod]
            _ = (a * (u * v)) % q := by ring_nf
            _ = (a % q * ((u * v) % q)) % q := Nat.mul_mod a (u * v) q
            _ = (a % q * 1) % q := by rw [hv]
            _ = a % q := by simp
            _ = a := Nat.mod_eq_of_lt ha.1
          · intro b hb
            rw [Finset.mem_filter, Finset.mem_range] at hb
            calc ((b * v) % q * u) % q = (b * v * u) % q := by simp [Nat.mod_mul_mod]
            _ = (b * (u * v)) % q := by ring_nf
            _ = (b % q * ((u * v) % q)) % q := Nat.mul_mod b (u * v) q
            _ = (b % q * 1) % q := by rw [hv]
            _ = b % q := by simp
            _ = b := Nat.mod_eq_of_lt hb.1

theorem leftToothRowSum_eq_moebius {q : ℕ} (hq1 : 1 < q) (hodd : Odd q) :
    leftToothRowSum q = (ArithmeticFunction.moebius q : ℂ) := by
  rcases hodd with ⟨m, rfl⟩
  have hcop : Nat.Coprime m (2 * m + 1) := by
    refine Nat.coprime_of_dvd' fun p _ hpm hpq => ?_
    have : p ∣ (2 * m + 1) - 2 * m := Nat.dvd_sub hpq (dvd_mul_of_dvd_right hpm 2)
    simpa using this
  have hterm : ∀ a ∈ reducedNumerators (2 * m + 1),
      leftTooth (2 * m + 1) a =
        Complex.exp (2 * Real.pi * Complex.I * ((a * m : ℕ) : ℂ) / ((2 * m + 1 : ℕ) : ℂ)) := by
    intro a _
    unfold leftTooth
    congr 1
    have hsub : (2 * m + 1 - 1 : ℕ) = 2 * m := by omega
    rw [hsub]
    push_cast
    ring
  rw [leftToothRowSum, Finset.sum_congr rfl hterm, sum_exp_mul_coprime_eq_primitive hq1 hcop]
  exact primitiveRootSum_eq_moebius_of_div (by omega)

theorem rightToothRowSum_eq_moebius {q : ℕ} (hq1 : 1 < q) (hodd : Odd q) :
    rightToothRowSum q = (ArithmeticFunction.moebius q : ℂ) := by
  rcases hodd with ⟨m, rfl⟩
  have hcop : Nat.Coprime (m + 1) (2 * m + 1) := by
    refine Nat.coprime_of_dvd' fun p _ hpm hpq => ?_
    have : p ∣ 2 * (m + 1) - (2 * m + 1) := Nat.dvd_sub (dvd_mul_of_dvd_right hpm 2) hpq
    have heq : 2 * (m + 1) - (2 * m + 1) = 1 := by omega
    rwa [heq] at this
  have hterm : ∀ a ∈ reducedNumerators (2 * m + 1),
      rightTooth (2 * m + 1) a =
        Complex.exp (2 * Real.pi * Complex.I * ((a * (m + 1) : ℕ) : ℂ) / ((2 * m + 1 : ℕ) : ℂ)) := by
    intro a _
    unfold rightTooth
    congr 1
    have hadd : (2 * m + 1 + 1 : ℕ) = 2 * (m + 1) := by omega
    rw [hadd]
    push_cast
    ring
  rw [rightToothRowSum, Finset.sum_congr rfl hterm, sum_exp_mul_coprime_eq_primitive hq1 hcop]
  exact primitiveRootSum_eq_moebius_of_div (by omega)

/-! ### 4. Band Separation & Bridges to RH / `EveryCharacter` -/

private lemma band_mem_gt_one_and_odd {x : ℝ} (hx : 2 ≤ x) {q : ℕ} (hq : q ∈ bandSet x) :
    1 < q ∧ Odd q := by
  rw [bandSet, Finset.mem_filter, Finset.mem_Ioc] at hq
  have hhalf : 1 ≤ ⌊x / 2⌋₊ := Nat.le_floor (by norm_num; linarith)
  have hgt : 1 < q := lt_of_le_of_lt hhalf hq.1.1
  have hcop2 : Nat.Coprime q 2 :=
    Nat.Coprime.coprime_dvd_right (by decide : 2 ∣ 6) hq.2
  have hodd : Odd q := by
    rw [Nat.odd_iff]
    by_contra hne
    have hmod : q % 2 = 0 := by omega
    have h2dvd : 2 ∣ q := Nat.dvd_of_mod_eq_zero hmod
    have hd : 2 ∣ Nat.gcd q 2 := Nat.dvd_gcd h2dvd (dvd_refl 2)
    rw [hcop2.gcd_eq_one] at hd
    omega
  exact ⟨hgt, hodd⟩

theorem leftFlankBand_eq_twistedV {N : ℕ} (χ : DirichletCharacter ℂ N) {x : ℝ} (hx : 2 ≤ x) :
    leftFlankBand χ x = Ratioque.CrystalBridge.twistedV χ x := by
  unfold leftFlankBand Ratioque.CrystalBridge.twistedV bandSet
  refine Finset.sum_congr rfl fun q hq => ?_
  obtain ⟨hq1, hodd⟩ := band_mem_gt_one_and_odd hx hq
  rw [leftToothRowSum_eq_moebius hq1 hodd, Ratioque.CrystalBridge.twistedCoeff]

theorem centerBand_eq_zero {N : ℕ} (χ : DirichletCharacter ℂ N) {x : ℝ} (hx : 2 ≤ x) :
    centerBand χ x = 0 := by
  unfold centerBand
  refine Finset.sum_eq_zero fun q hq => ?_
  obtain ⟨hq1, hodd⟩ := band_mem_gt_one_and_odd hx hq
  rw [centerToothRowSum_eq_zero hq1 hodd, mul_zero]

theorem rightFlankBand_eq_twistedV {N : ℕ} (χ : DirichletCharacter ℂ N) {x : ℝ} (hx : 2 ≤ x) :
    rightFlankBand χ x = Ratioque.CrystalBridge.twistedV χ x := by
  unfold rightFlankBand Ratioque.CrystalBridge.twistedV bandSet
  refine Finset.sum_congr rfl fun q hq => ?_
  obtain ⟨hq1, hodd⟩ := band_mem_gt_one_and_odd hx hq
  rw [rightToothRowSum_eq_moebius hq1 hodd, Ratioque.CrystalBridge.twistedCoeff]

theorem threeToothEndpoint_eq_two_mul_twistedV {N : ℕ} (χ : DirichletCharacter ℂ N) {x : ℝ} (hx : 2 ≤ x) :
    threeToothEndpoint χ x = 2 * Ratioque.CrystalBridge.twistedV χ x := by
  rw [threeToothEndpoint, leftFlankBand_eq_twistedV χ hx, centerBand_eq_zero χ hx,
    rightFlankBand_eq_twistedV χ hx]
  ring

private theorem twistedVCancellation_of_threeTooth {N : ℕ} (χ : DirichletCharacter ℂ N)
    (h : ∀ ε : ℝ, 0 < ε → threeToothEndpoint χ =O[atTop] (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε))) :
    Ratioque.CrystalBridge.TwistedVCancellation χ := by
  intro ε hε
  obtain ⟨c, hc⟩ := (h ε hε).bound
  rw [Asymptotics.isBigO_iff]
  refine ⟨c / 2, ?_⟩
  filter_upwards [hc, eventually_ge_atTop (2 : ℝ)] with x hx hx2
  have heq := threeToothEndpoint_eq_two_mul_twistedV χ hx2
  have h2 : ‖threeToothEndpoint χ x‖ = 2 * ‖Ratioque.CrystalBridge.twistedV χ x‖ := by
    rw [heq, norm_mul]
    simp
  linarith

/-- Ordinary RH from the centered three-tooth Vernier endpoint (`χ = 1`). -/
theorem riemannHypothesis_of_threeTooth_cancellation
    (h : ∀ ε : ℝ, 0 < ε →
      threeToothEndpoint (1 : DirichletCharacter ℂ 1) =O[atTop] (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε))) :
    RiemannHypothesis :=
  Ratioque.CrystalBridge.riemannHypothesis_of_V_cancellation
    (twistedVCancellation_of_threeTooth (1 : DirichletCharacter ℂ 1) h)

/-- Full `EveryCharacter` (`allChi`) from character-twisted three-tooth Vernier cancellation. -/
theorem everyCharacter_of_allChi_threeTooth_cancellation
    (h : ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (ε : ℝ),
      0 < ε → threeToothEndpoint χ =O[atTop] (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε))) :
    Ratioque.CrystalBridge.EveryCharacter :=
  Ratioque.CrystalBridge.everyCharacter_of_allChi_V_cancellation fun N _ χ =>
    twistedVCancellation_of_threeTooth χ (h N χ)

end Ratioque.VernierBridge

#print axioms Ratioque.VernierBridge.centerToothRowSum_eq_zero
#print axioms Ratioque.VernierBridge.leftToothRowSum_eq_moebius
#print axioms Ratioque.VernierBridge.rightToothRowSum_eq_moebius
#print axioms Ratioque.VernierBridge.threeToothEndpoint_eq_two_mul_twistedV
#print axioms Ratioque.VernierBridge.riemannHypothesis_of_threeTooth_cancellation
#print axioms Ratioque.VernierBridge.everyCharacter_of_allChi_threeTooth_cancellation
