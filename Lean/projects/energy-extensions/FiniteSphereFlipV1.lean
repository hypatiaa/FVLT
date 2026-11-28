import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.Ring.GeomSum
import Mathlib.Analysis.SpecialFunctions.Pow.Complex
import Mathlib.Analysis.SpecialFunctions.Pow.Real
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Complex
import Mathlib.Data.Nat.Factorization.Basic
import Mathlib.Data.Nat.Factors
import Mathlib.Data.Nat.Squarefree
import Mathlib.NumberTheory.ArithmeticFunction.Defs
import Mathlib.NumberTheory.ArithmeticFunction.Misc
import Mathlib.NumberTheory.Divisors

/-!
# Finite Sphere Flip: Squeezed-sphere divisor zeta as a finite model of the zeta flip

Lean 4 formalization of `FINITE_SPHERE_FLIP_NOTE_v0_1_20261123/NOTE.md` (Skeleton seat / Claude Opus 5.5,
companion to R6 from Stack Bus `#2202/#2203`, following `saphir`'s connection of the squeezed-sphere
pen and its polyhedra to the zeta flip; requested in `#2205`).

Defines `finiteZeta N s := ∑ d ∈ N.divisors, (d : ℂ) ^ (-s)` and formalizes the six finite-model
statements from `NOTE.md`:

1. **Finite functional equation:** `ζ_N(s) = N ^ (-s) * ζ_N(-s)`, and mirror-and-turn form
   `ζ_N(it) = N ^ (-it) * conj (ζ_N(it))`.
2. **Circle flip without stretch & off-equator stretch:** On the equator `σ = 0`,
   `(N / d) ^ (-it) = N ^ (-it) * conj (d ^ (-it))`; for `N ≥ 2`, `‖N ^ (-s)‖ = 1 ↔ s.re = 0`.
3. **Product over prime dice:** `ζ_N(s) = ∏_{p ∈ N.primeFactors} ∑_{k ≤ v_p(N)} (p ^ (-s)) ^ k`,
   specializing to `∏_{p ∈ N.primeFactors} (1 + p ^ (-s))` when `Squarefree N`.
4. **Trivial finite RH:** Every zero of `ζ_N` has `s.re = 0`, because vanishing of the finite
   prime-power product forces one prime-power cyclotomic factor to vanish (`x_p ^ (a + 1) = 1`,
   `x_p ≠ 1`, so `‖x_p‖ = 1`); for `Squarefree N`, `ζ_N(s) = 0 ↔ ∃ p ∣ N, p ^ (-s) = -1`.
5. **Finite Hardy Z realness:** `N ^ (it / 2) * ζ_N(it)` has zero imaginary part for every `N ≥ 1`,
   and for `Squarefree N` equals `∏_{p ∈ N.primeFactors} (2 * cos (t * log p / 2))`.
6. **Antipode = Ω-layer complement:** `d ↦ N / d` is an involution on `N.divisors` swapping layers
   `bigOmega d = k` and `bigOmega d = bigOmega N - k`, with exact checks for `N = 30` (layers `1, 2`,
   3 + 3 = 6 divisors) and `N = 2310` (layers `2, 3`, 10 + 10 = 20 divisors; `Rmk 9.7j.2`
   dodecahedron context is cited here as an external Idea Catalog candidate without depending on it).

**Scope note:** `ζ_N` is a finite product over `N.primeFactors`, so a factor-by-factor argument places
all its zeros on `Re s = 0`. The Riemann zeta function `ζ` has a convergent Euler product only on
`Re s > 1` (zero-free), not inside the critical strip. Hence `ζ_N` is an exactly solvable structural
model of the flip, **not** a route to RH.
-/

noncomputable section
open scoped BigOperators ComplexConjugate

namespace RHConnections.FiniteSphereFlip

/-- Finite divisor zeta `ζ_N(s) = ∑_{d ∣ N} d ^ (-s)`. Zero when `N = 0`. -/
def finiteZeta (N : ℕ) (s : ℂ) : ℂ :=
  ∑ d ∈ N.divisors, (d : ℂ) ^ (-s)

/-- Finite Hardy rotation `Z_N(t) = N ^ (it / 2) * ζ_N(it)` along the equator `Re s = 0`. -/
def finiteHardyZ (N : ℕ) (t : ℝ) : ℂ :=
  (N : ℂ) ^ ((⟨0, t⟩ : ℂ) / 2) * finiteZeta N (⟨0, t⟩ : ℂ)

/-- Prime divisor count with multiplicity `Ω(n)`. -/
def bigOmega (n : ℕ) : ℕ :=
  n.primeFactorsList.length

/-- The `k`-th `Ω`-layer of `Div(N)`. -/
def omegaLayer (N k : ℕ) : Finset ℕ :=
  N.divisors.filter (fun d => bigOmega d = k)

/-! ## Statement 1: Finite functional equation and mirror-and-turn -/

private lemma natCast_cpow_mul_neg_eq {N d : ℕ} (hN : N ≠ 0) (hd : d ∣ N) (s : ℂ) :
    ((N / d : ℕ) : ℂ) ^ (-s) = (N : ℂ) ^ (-s) * (d : ℂ) ^ s := by
  have hd0 : (d : ℂ) ≠ 0 := by
    intro h
    have hd_nat : d = 0 := Nat.cast_eq_zero.mp h
    rw [hd_nat, zero_dvd_iff] at hd
    exact hN hd
  have hmulR : ((N / d : ℕ) : ℝ) * (d : ℝ) = (N : ℝ) := by
    exact_mod_cast Nat.div_mul_cancel hd
  have hpow_mul : ((N / d : ℕ) : ℂ) ^ (-s) * (d : ℂ) ^ (-s) = (N : ℂ) ^ (-s) := by
    calc ((N / d : ℕ) : ℂ) ^ (-s) * (d : ℂ) ^ (-s)
        = (((N / d : ℕ) : ℝ) : ℂ) ^ (-s) * ((d : ℝ) : ℂ) ^ (-s) := by
            rw [Complex.ofReal_natCast, Complex.ofReal_natCast]
      _ = ((((N / d : ℕ) : ℝ) : ℂ) * ((d : ℝ) : ℂ)) ^ (-s) := by
            rw [Complex.mul_cpow_ofReal_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _) (-s)]
      _ = (N : ℂ) ^ (-s) := by
            rw [← Complex.ofReal_mul, hmulR, Complex.ofReal_natCast]
  calc ((N / d : ℕ) : ℂ) ^ (-s)
      = ((N / d : ℕ) : ℂ) ^ (-s) * ((d : ℂ) ^ (-s) * (d : ℂ) ^ s) := by
          rw [← Complex.cpow_add _ _ hd0, neg_add_cancel, Complex.cpow_zero, mul_one]
    _ = (((N / d : ℕ) : ℂ) ^ (-s) * (d : ℂ) ^ (-s)) * (d : ℂ) ^ s := by ring
    _ = (N : ℂ) ^ (-s) * (d : ℂ) ^ s := by rw [hpow_mul]

/-- Statement 1 (`NOTE.md`): `ζ_N(s) = N ^ (-s) * ζ_N(-s)` by pairing `d ↔ N / d`. -/
theorem finiteZeta_functional_eq {N : ℕ} (hN : N ≠ 0) (s : ℂ) :
    finiteZeta N s = (N : ℂ) ^ (-s) * finiteZeta N (-s) := by
  unfold finiteZeta
  rw [Finset.mul_sum]
  refine Finset.sum_bij (fun d _ => N / d) ?_ ?_ ?_ ?_
  · intro d hd
    have hmem := Nat.mem_divisors.mp hd
    exact Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd hmem.1, hN⟩
  · intro a ha b hb hab
    have hha : N / (N / a) = a := Nat.div_div_self (Nat.dvd_of_mem_divisors ha) hN
    have hhb : N / (N / b) = b := Nat.div_div_self (Nat.dvd_of_mem_divisors hb) hN
    rw [← hha, ← hhb, hab]
  · intro d hd
    refine ⟨N / d, Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd (Nat.dvd_of_mem_divisors hd), hN⟩, ?_⟩
    exact Nat.div_div_self (Nat.dvd_of_mem_divisors hd) hN
  · intro d hd
    have hmem := Nat.mem_divisors.mp hd
    have hdiv_dvd : N / d ∣ N := Nat.div_dvd_of_dvd hmem.1
    have hself : N / (N / d) = d := Nat.div_div_self hmem.1 hN
    have hterm := natCast_cpow_mul_neg_eq hN hdiv_dvd s
    rw [hself] at hterm
    simpa only [neg_neg] using hterm

/-- Conjugation symmetry of the finite divisor zeta: `conj (ζ_N(s)) = ζ_N(conj s)`. -/
theorem finiteZeta_conj (N : ℕ) (s : ℂ) :
    conj (finiteZeta N s) = finiteZeta N (conj s) := by
  unfold finiteZeta
  rw [map_sum]
  refine Finset.sum_congr rfl fun d _ => ?_
  have harg : (d : ℂ).arg ≠ Real.pi := by
    rw [Complex.natCast_arg]
    exact Real.pi_ne_zero.symm
  have hc := Complex.cpow_conj (d : ℂ) (-s) harg
  rw [Complex.conj_natCast, map_neg] at hc
  exact hc.symm

/-- Twin mirror form: `ζ_N(σ + it) = N ^ (-(σ + it)) * conj (ζ_N(-σ + it))`. -/
theorem finiteZeta_eq_mul_conj_twin {N : ℕ} (hN : N ≠ 0) (σ t : ℝ) :
    finiteZeta N (⟨σ, t⟩ : ℂ) =
      (N : ℂ) ^ (-(⟨σ, t⟩ : ℂ)) * conj (finiteZeta N (⟨-σ, t⟩ : ℂ)) := by
  have hc : -(⟨σ, t⟩ : ℂ) = conj (⟨-σ, t⟩ : ℂ) := by
    apply Complex.ext <;> simp
  rw [finiteZeta_functional_eq hN, hc, ← finiteZeta_conj]

/-- Mirror-and-turn on the equator `σ = 0`: `ζ_N(it) = N ^ (-it) * conj (ζ_N(it))`. -/
theorem finiteZeta_equator_eq_flip_mul_conj {N : ℕ} (hN : N ≠ 0) (t : ℝ) :
    finiteZeta N (⟨0, t⟩ : ℂ) =
      (N : ℂ) ^ (-(⟨0, t⟩ : ℂ)) * conj (finiteZeta N (⟨0, t⟩ : ℂ)) := by
  simpa using finiteZeta_eq_mul_conj_twin hN 0 t

/-! ## Statement 2: Circle flip without stretch and off-equator stretch -/

/-- Statement 2a (`NOTE.md`): termwise circle flip `(N / d) ^ (-it) = N ^ (-it) * conj (d ^ (-it))`. -/
theorem circle_antipode_flip {N d : ℕ} (hN : N ≠ 0) (hd : d ∣ N) (t : ℝ) :
    ((N / d : ℕ) : ℂ) ^ (-(⟨0, t⟩ : ℂ)) =
      (N : ℂ) ^ (-(⟨0, t⟩ : ℂ)) * conj ((d : ℂ) ^ (-(⟨0, t⟩ : ℂ))) := by
  have harg : (d : ℂ).arg ≠ Real.pi := by
    rw [Complex.natCast_arg]
    exact Real.pi_ne_zero.symm
  have hc := Complex.cpow_conj (d : ℂ) (-(⟨0, t⟩ : ℂ)) harg
  have hconj : conj ((d : ℂ) ^ (-(⟨0, t⟩ : ℂ))) = (d : ℂ) ^ (⟨0, t⟩ : ℂ) := by
    rw [Complex.conj_natCast, map_neg, show conj (⟨0, t⟩ : ℂ) = -(⟨0, t⟩ : ℂ) by
      apply Complex.ext <;> simp, neg_neg] at hc
    exact hc.symm
  rw [hconj]
  exact natCast_cpow_mul_neg_eq hN hd (⟨0, t⟩ : ℂ)

/-- Norm of the finite flip factor: `‖N ^ (-s)‖ = N ^ (-s.re)` for `N ≥ 1`. -/
theorem norm_finiteFlipFactor {N : ℕ} (hN : N ≠ 0) (s : ℂ) :
    ‖(N : ℂ) ^ (-s)‖ = (N : ℝ) ^ (-s.re) := by
  have hpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hN
  simpa only [Complex.ofReal_natCast, Complex.neg_re] using
    Complex.norm_cpow_eq_rpow_re_of_pos hpos (-s)

/-- Statement 2b (`NOTE.md`): no stretch iff on the equator (`‖N ^ (-s)‖ = 1 ↔ s.re = 0` for `N ≥ 2`). -/
theorem norm_finiteFlipFactor_eq_one_iff {N : ℕ} (hN : 2 ≤ N) (s : ℂ) :
    ‖(N : ℂ) ^ (-s)‖ = 1 ↔ s.re = 0 := by
  have hN0 : N ≠ 0 := by omega
  have hpos : (0 : ℝ) < (N : ℝ) := by exact_mod_cast Nat.pos_of_ne_zero hN0
  have hne1 : (N : ℝ) ≠ 1 := by
    exact_mod_cast (show N ≠ 1 by omega)
  rw [norm_finiteFlipFactor hN0 s, ← Real.rpow_zero (N : ℝ)]
  rw [Real.rpow_right_inj hpos hne1, neg_eq_zero]

/-- Strictly inside the right half-plane `s.re > 0`, the flip factor shrinks (`‖N ^ (-s)‖ < 1`). -/
theorem norm_finiteFlipFactor_lt_one_of_re_pos {N : ℕ} (hN : 2 ≤ N) {s : ℂ} (hs : 0 < s.re) :
    ‖(N : ℂ) ^ (-s)‖ < 1 := by
  have hN0 : N ≠ 0 := by omega
  have hgt1 : (1 : ℝ) < (N : ℝ) := by exact_mod_cast (show 1 < N by omega)
  rw [norm_finiteFlipFactor hN0 s]
  exact Real.rpow_lt_one_of_one_lt_of_neg hgt1 (neg_lt_zero.mpr hs)

/-- Strictly in the left half-plane `s.re < 0`, the flip factor expands (`1 < ‖N ^ (-s)‖`). -/
theorem norm_finiteFlipFactor_gt_one_of_re_neg {N : ℕ} (hN : 2 ≤ N) {s : ℂ} (hs : s.re < 0) :
    1 < ‖(N : ℂ) ^ (-s)‖ := by
  have hN0 : N ≠ 0 := by omega
  have hgt1 : (1 : ℝ) < (N : ℝ) := by exact_mod_cast (show 1 < N by omega)
  rw [norm_finiteFlipFactor hN0 s]
  exact Real.one_lt_rpow hgt1 (neg_pos.mpr hs)

/-! ## Statement 3: Product over prime dice -/

private def zetaArithC : ArithmeticFunction ℂ where
  toFun n := if n = 0 then 0 else 1
  map_zero' := rfl

private lemma isMultiplicative_zetaArithC : zetaArithC.IsMultiplicative := by
  rw [ArithmeticFunction.IsMultiplicative.iff_ne_zero]
  refine ⟨by simp [zetaArithC], fun {m n} hm hn _ => ?_⟩
  simp [zetaArithC, hm, hn]

private def powNegSArith (s : ℂ) : ArithmeticFunction ℂ where
  toFun n := if n = 0 then 0 else (n : ℂ) ^ (-s)
  map_zero' := rfl

private lemma isMultiplicative_powNegSArith (s : ℂ) : (powNegSArith s).IsMultiplicative := by
  rw [ArithmeticFunction.IsMultiplicative.iff_ne_zero]
  refine ⟨by simp [powNegSArith], fun {m n} hm hn _ => ?_⟩
  have hmn : m * n ≠ 0 := mul_ne_zero hm hn
  change (if m * n = 0 then 0 else ((m * n : ℕ) : ℂ) ^ (-s)) =
    (if m = 0 then 0 else (m : ℂ) ^ (-s)) * (if n = 0 then 0 else (n : ℂ) ^ (-s))
  simp only [hmn, hm, hn, ↓reduceIte]
  calc (((m * n : ℕ) : ℝ) : ℂ) ^ (-s)
      = ((((m : ℝ) : ℂ) * ((n : ℝ) : ℂ)) ^ (-s)) := by
          rw [Nat.cast_mul, Complex.ofReal_mul]
    _ = ((m : ℝ) : ℂ) ^ (-s) * ((n : ℝ) : ℂ) ^ (-s) :=
          Complex.mul_cpow_ofReal_nonneg (Nat.cast_nonneg m) (Nat.cast_nonneg n) (-s)

private def finiteZetaArith (s : ℂ) : ArithmeticFunction ℂ where
  toFun n := if n = 0 then 0 else finiteZeta n s
  map_zero' := rfl

private lemma zeta_mul_powNegS_eq_finiteZetaArith (s : ℂ) :
    zetaArithC * powNegSArith s = finiteZetaArith s := by
  ext n
  by_cases hn : n = 0
  · subst hn; simp
  · rw [ArithmeticFunction.mul_apply, Nat.sum_divisorsAntidiagonal' (n := n)
        (fun i j => zetaArithC i * powNegSArith s j)]
    change (∑ d ∈ n.divisors, zetaArithC (n / d) * powNegSArith s d) =
      if n = 0 then 0 else finiteZeta n s
    rw [ite_eq_right_iff.mpr (fun h => absurd h hn), finiteZeta]
    refine Finset.sum_congr rfl fun d hd => ?_
    have hd0 : d ≠ 0 := (Nat.pos_of_mem_divisors hd).ne'
    have hq0 : n / d ≠ 0 := by
      have hdvd := Nat.dvd_of_mem_divisors hd
      intro hq
      have := Nat.div_mul_cancel hdvd
      rw [hq, zero_mul] at this
      exact hn this.symm
    change (if n / d = 0 then (0 : ℂ) else 1) * (if d = 0 then 0 else (d : ℂ) ^ (-s)) = (d : ℂ) ^ (-s)
    simp [hd0, hq0]

private lemma isMultiplicative_finiteZetaArith (s : ℂ) :
    (finiteZetaArith s).IsMultiplicative := by
  rw [← zeta_mul_powNegS_eq_finiteZetaArith s]
  exact isMultiplicative_zetaArithC.mul (isMultiplicative_powNegSArith s)

private lemma natCast_pow_cpow (p k : ℕ) (w : ℂ) :
    ((p ^ k : ℕ) : ℂ) ^ w = ((p : ℂ) ^ w) ^ k := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [pow_succ, pow_succ]
    calc (((p ^ k * p : ℕ) : ℝ) : ℂ) ^ w
        = ((((p ^ k : ℕ) : ℝ) : ℂ) * ((p : ℝ) : ℂ)) ^ w := by
            rw [Nat.cast_mul, Complex.ofReal_mul]
      _ = (((p ^ k : ℕ) : ℝ) : ℂ) ^ w * ((p : ℝ) : ℂ) ^ w :=
            Complex.mul_cpow_ofReal_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _) w
      _ = ((p : ℂ) ^ w) ^ k * (p : ℂ) ^ w := by
            rw [Complex.ofReal_natCast, Complex.ofReal_natCast, ih]

private lemma finiteZeta_prime_pow {p : ℕ} (hp : p.Prime) (a : ℕ) (s : ℂ) :
    finiteZeta (p ^ a) s = ∑ k ∈ Finset.range (a + 1), ((p : ℂ) ^ (-s)) ^ k := by
  unfold finiteZeta
  rw [Nat.divisors_prime_pow hp, Finset.sum_map]
  refine Finset.sum_congr rfl fun k _ => ?_
  exact natCast_pow_cpow p k (-s)

/-- Statement 3a (`NOTE.md`): general prime-power product formula for `ζ_N(s)`. -/
theorem finiteZeta_eq_prod_primeFactors {N : ℕ} (hN : N ≠ 0) (s : ℂ) :
    finiteZeta N s =
      ∏ p ∈ N.primeFactors, ∑ k ∈ Finset.range (N.factorization p + 1), ((p : ℂ) ^ (-s)) ^ k := by
  have h1 : (finiteZetaArith s) N = finiteZeta N s := ite_eq_right_iff.mpr (fun h => absurd h hN)
  rw [← h1, (isMultiplicative_finiteZetaArith s).multiplicative_factorization _ hN]
  rw [Finsupp.prod, N.support_factorization]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hp_prime : p.Prime := Nat.prime_of_mem_primeFactors hp
  have hpow0 : p ^ N.factorization p ≠ 0 := pow_ne_zero _ hp_prime.ne_zero
  change (if p ^ N.factorization p = 0 then 0 else finiteZeta (p ^ N.factorization p) s) = _
  rw [ite_eq_right_iff.mpr (fun h => absurd h hpow0)]
  exact finiteZeta_prime_pow hp_prime (N.factorization p) s

/-- Statement 3b (`NOTE.md`): squarefree product over prime dice `ζ_N(s) = ∏_{p ∣ N} (1 + p ^ (-s))`. -/
theorem finiteZeta_eq_prod_squarefree {N : ℕ} (hN : Squarefree N) (s : ℂ) :
    finiteZeta N s = ∏ p ∈ N.primeFactors, (1 + (p : ℂ) ^ (-s)) := by
  rw [finiteZeta_eq_prod_primeFactors hN.ne_zero s]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hp_pos : 0 < N.factorization p :=
    (Nat.Prime.dvd_iff_one_le_factorization (Nat.prime_of_mem_primeFactors hp) hN.ne_zero).mp
      (Nat.dvd_of_mem_primeFactors hp)
  have hp_le : N.factorization p ≤ 1 := (Nat.squarefree_iff_factorization_le_one hN.ne_zero).mp hN p
  have hp_eq : N.factorization p = 1 := by omega
  rw [hp_eq]
  simp [Finset.sum_range_succ]

/-! ## Statement 4: Trivial finite RH -/

/-- Exact vanishing characterization of the prime-power geometric sum `∑_{k ≤ a} x ^ k`. -/
theorem geom_sum_succ_eq_zero_iff (a : ℕ) (x : ℂ) :
    (∑ k ∈ Finset.range (a + 1), x ^ k) = 0 ↔ x ^ (a + 1) = 1 ∧ x ≠ 1 := by
  have hmul : (∑ k ∈ Finset.range (a + 1), x ^ k) * (x - 1) = x ^ (a + 1) - 1 := by
    rw [← geom_sum₂_with_one x (a + 1)]
    simpa only [one_pow] using (Commute.all x (1 : ℂ)).geom_sum₂_mul (a + 1)
  constructor
  · intro hz
    have hpow : x ^ (a + 1) = 1 := by
      rw [hz, zero_mul] at hmul
      exact sub_eq_zero.mp hmul.symm
    have hne : x ≠ 1 := by
      intro hx1
      rw [hx1] at hz
      simp only [one_pow, Finset.sum_const, Finset.card_range, nsmul_eq_mul, mul_one,
        Nat.cast_eq_zero] at hz
      omega
    exact ⟨hpow, hne⟩
  · rintro ⟨hpow, hne⟩
    have hsub : x - 1 ≠ 0 := sub_ne_zero.mpr hne
    rw [hpow, sub_self] at hmul
    exact (mul_eq_zero.mp hmul).resolve_right hsub

/-- Statement 4a (`NOTE.md`): exact characterization of zeros of `ζ_N`. -/
theorem finiteZeta_zero_iff {N : ℕ} (hN : N ≠ 0) (s : ℂ) :
    finiteZeta N s = 0 ↔
      ∃ p ∈ N.primeFactors,
        ((p : ℂ) ^ (-s)) ^ (N.factorization p + 1) = 1 ∧ (p : ℂ) ^ (-s) ≠ 1 := by
  rw [finiteZeta_eq_prod_primeFactors hN s, Finset.prod_eq_zero_iff]
  refine exists_congr fun p => and_congr_right fun _ => ?_
  exact geom_sum_succ_eq_zero_iff (N.factorization p) ((p : ℂ) ^ (-s))

/-- Statement 4b (`NOTE.md`, trivial finite RH): every zero of `ζ_N(s)` lies on the equator `s.re = 0`. -/
theorem finiteZeta_zero_re_eq_zero {N : ℕ} (hN : N ≠ 0) {s : ℂ} (hz : finiteZeta N s = 0) :
    s.re = 0 := by
  obtain ⟨p, hp, hpow, _⟩ := (finiteZeta_zero_iff hN s).mp hz
  have hp_prime : p.Prime := Nat.prime_of_mem_primeFactors hp
  have hn_pow : ‖(p : ℂ) ^ (-s)‖ ^ (N.factorization p + 1) = 1 := by
    rw [← norm_pow, hpow, norm_one]
  have hnorm1 : ‖(p : ℂ) ^ (-s)‖ = 1 := by
    have h0 : 0 ≤ ‖(p : ℂ) ^ (-s)‖ := norm_nonneg _
    by_contra hne
    rcases lt_or_gt_of_ne hne with hlt | hgt
    · have : ‖(p : ℂ) ^ (-s)‖ ^ (N.factorization p + 1) < 1 :=
        pow_lt_one₀ h0 hlt (Nat.succ_ne_zero _)
      linarith
    · have : 1 < ‖(p : ℂ) ^ (-s)‖ ^ (N.factorization p + 1) :=
        one_lt_pow₀ hgt (Nat.succ_ne_zero _)
      linarith
  exact (norm_finiteFlipFactor_eq_one_iff hp_prime.two_le s).mp hnorm1

/-- Statement 4c (`NOTE.md`): for squarefree `N`, `ζ_N(s) = 0` iff some prime coin lands at `-1`. -/
theorem finiteZeta_squarefree_zero_iff {N : ℕ} (hN : Squarefree N) (s : ℂ) :
    finiteZeta N s = 0 ↔ ∃ p ∈ N.primeFactors, (p : ℂ) ^ (-s) = -1 := by
  rw [finiteZeta_eq_prod_squarefree hN s, Finset.prod_eq_zero_iff]
  refine exists_congr fun p => and_congr_right fun _ => ?_
  constructor
  · intro h; exact eq_neg_of_add_eq_zero_right h
  · intro h; rw [h]; ring

/-- Explicit equator zero witness for squarefree `N`: `s = i * (2k + 1)π / log p` gives `p ^ (-s) = -1`. -/
theorem finiteZeta_squarefree_zero_of_odd_pi {N p : ℕ} (hN : Squarefree N)
    (hp : p ∈ N.primeFactors) (k : ℤ) :
    finiteZeta N (⟨0, (2 * (k : ℝ) + 1) * Real.pi / Real.log p⟩ : ℂ) = 0 := by
  rw [finiteZeta_squarefree_zero_iff hN]
  refine ⟨p, hp, ?_⟩
  have hp_prime : p.Prime := Nat.prime_of_mem_primeFactors hp
  have hp0 : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hp_prime.ne_zero
  have hp1 : (1 : ℝ) < (p : ℝ) := by exact_mod_cast hp_prime.one_lt
  have hlog : Real.log p ≠ 0 := (Real.log_pos hp1).ne'
  have hlogC : Complex.log (p : ℂ) = (Real.log p : ℂ) := by
    rw [← Complex.ofReal_natCast, Complex.ofReal_log (Nat.cast_nonneg p)]
  let t : ℝ := (2 * (k : ℝ) + 1) * Real.pi / Real.log p
  have hs_eq : -(⟨0, t⟩ : ℂ) = -((t : ℂ) * Complex.I) := by
    apply Complex.ext <;> simp
  rw [Complex.cpow_def_of_ne_zero hp0, hlogC, hs_eq]
  have harg : (Real.log p : ℂ) * -((t : ℂ) * Complex.I) =
      -((Real.pi + (k : ℂ) * (2 * Real.pi)) * Complex.I) := by
    have hlogC_ne : (Real.log p : ℂ) ≠ 0 := Complex.ofReal_ne_zero.mpr hlog
    dsimp [t]
    push_cast
    rw [← hlogC] at hlogC_ne
    field_simp [hlogC_ne]
    ring
  rw [harg, Complex.exp_neg, Complex.exp_mul_I, Complex.cos_add_int_mul_two_pi,
    Complex.sin_add_int_mul_two_pi]
  simp

/-! ## Statement 5: Finite Hardy Z realness and squarefree cosine product -/

/-- Statement 5a (`NOTE.md`): `finiteHardyZ N t = N ^ (it / 2) * ζ_N(it)` is real for every `N ≥ 1`. -/
theorem finiteHardyZ_im_eq_zero {N : ℕ} (hN : N ≠ 0) (t : ℝ) :
    (finiteHardyZ N t).im = 0 := by
  have hN0 : (N : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr hN
  have harg : (N : ℂ).arg ≠ Real.pi := by
    rw [Complex.natCast_arg]
    exact Real.pi_ne_zero.symm
  let z : ℂ := (⟨0, t⟩ : ℂ)
  have hz_conj : conj (z / 2) = -(z / 2) := by
    rw [map_div₀, map_ofNat]
    apply Complex.ext
    · simp [z]
    · simp [z]; ring
  have hpow_conj : conj ((N : ℂ) ^ (z / 2)) = (N : ℂ) ^ (-(z / 2)) := by
    have hc := Complex.cpow_conj (N : ℂ) (z / 2) harg
    rw [Complex.conj_natCast, hz_conj] at hc
    exact hc.symm
  have hpow_mul : (N : ℂ) ^ (z / 2) * (N : ℂ) ^ (-z) = (N : ℂ) ^ (-(z / 2)) := by
    rw [← Complex.cpow_add _ _ hN0]
    congr 1
    ring
  have hconj_eq : conj (finiteHardyZ N t) = finiteHardyZ N t := by
    calc conj (finiteHardyZ N t)
        = conj ((N : ℂ) ^ (z / 2)) * conj (finiteZeta N z) := map_mul _ _ _
      _ = (N : ℂ) ^ (-(z / 2)) * conj (finiteZeta N z) := by rw [hpow_conj]
      _ = ((N : ℂ) ^ (z / 2) * (N : ℂ) ^ (-z)) * conj (finiteZeta N z) := by rw [hpow_mul]
      _ = (N : ℂ) ^ (z / 2) * ((N : ℂ) ^ (-z) * conj (finiteZeta N z)) := by ring
      _ = (N : ℂ) ^ (z / 2) * finiteZeta N z := by
          rw [← finiteZeta_equator_eq_flip_mul_conj hN t]
      _ = finiteHardyZ N t := rfl
  exact Complex.conj_eq_iff_im.mp hconj_eq

private lemma prod_natCast_cpow (S : Finset ℕ) (w : ℂ) :
    ∏ p ∈ S, (p : ℂ) ^ w = ((∏ p ∈ S, p : ℕ) : ℂ) ^ w := by
  classical
  induction S using Finset.induction_on with
  | empty => simp
  | @insert a s has ih =>
    rw [Finset.prod_insert has, Finset.prod_insert has, Nat.cast_mul, ih]
    rw [← Complex.ofReal_natCast a, ← Complex.ofReal_natCast (∏ p ∈ s, p)]
    rw [← Complex.mul_cpow_ofReal_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _) w]

/-- Statement 5b (`NOTE.md`): centred squarefree product `N ^ (s / 2) * ζ_N(s) = ∏_{p ∣ N} (p^(s/2) + p^(-s/2))`. -/
theorem finiteZeta_centred_squarefree {N : ℕ} (hN : Squarefree N) (s : ℂ) :
    (N : ℂ) ^ (s / 2) * finiteZeta N s =
      ∏ p ∈ N.primeFactors, ((p : ℂ) ^ (s / 2) + (p : ℂ) ^ (-s / 2)) := by
  have hN_pow : (N : ℂ) ^ (s / 2) = ∏ p ∈ N.primeFactors, (p : ℂ) ^ (s / 2) := by
    rw [prod_natCast_cpow, Nat.prod_primeFactors_of_squarefree hN]
  rw [hN_pow, finiteZeta_eq_prod_squarefree hN s, ← Finset.prod_mul_distrib]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hp0 : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.prime_of_mem_primeFactors hp).ne_zero
  rw [mul_add, mul_one, ← Complex.cpow_add _ _ hp0]
  congr 1
  ring_nf

/-- Statement 5c (`NOTE.md`): on the equator, `Z_N(t) = ∏_{p ∣ N} (2 * cos (t * log p / 2))` for squarefree `N`. -/
theorem finiteHardyZ_squarefree_eq_cos_prod {N : ℕ} (hN : Squarefree N) (t : ℝ) :
    finiteHardyZ N t =
      ∏ p ∈ N.primeFactors, ((2 * Real.cos (t * Real.log p / 2) : ℝ) : ℂ) := by
  have hc := finiteZeta_centred_squarefree hN (⟨0, t⟩ : ℂ)
  change finiteHardyZ N t = _ at hc
  rw [hc]
  refine Finset.prod_congr rfl fun p hp => ?_
  have hp0 : (p : ℂ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.prime_of_mem_primeFactors hp).ne_zero
  have hlogC : Complex.log (p : ℂ) = (Real.log p : ℂ) := by
    rw [← Complex.ofReal_natCast, Complex.ofReal_log (Nat.cast_nonneg p)]
  have hdiv : (⟨0, t⟩ : ℂ) / 2 = ((t / 2 : ℝ) : ℂ) * Complex.I := by
    apply Complex.ext <;> simp
  have hneg_div : -((⟨0, t⟩ : ℂ)) / 2 = -(((t / 2 : ℝ) : ℂ) * Complex.I) := by
    apply Complex.ext
    · simp
    · simp; ring
  have hθ : Complex.log (p : ℂ) * (((t / 2 : ℝ) : ℂ) * Complex.I) =
      ((t * Real.log p / 2 : ℝ) : ℂ) * Complex.I := by
    rw [hlogC]; push_cast; ring
  have hθ_neg : Complex.log (p : ℂ) * -(((t / 2 : ℝ) : ℂ) * Complex.I) =
      -((t * Real.log p / 2 : ℝ) : ℂ) * Complex.I := by
    rw [hlogC]; push_cast; ring
  rw [Complex.cpow_def_of_ne_zero hp0, Complex.cpow_def_of_ne_zero hp0, hdiv, hneg_div, hθ, hθ_neg]
  have hcos : Complex.exp (((t * Real.log p / 2 : ℝ) : ℂ) * Complex.I) +
      Complex.exp (-((t * Real.log p / 2 : ℝ) : ℂ) * Complex.I) =
        2 * Complex.cos ((t * Real.log p / 2 : ℝ) : ℂ) := by
    rw [Complex.cos]
    ring
  rw [hcos, ← Complex.ofReal_cos, ← Complex.ofReal_ofNat, ← Complex.ofReal_mul]

/-! ## Statement 6: Complement Ω-layer swap and concrete polyhedron examples (30, 2310) -/

/-- Additivity of `bigOmega` on nonzero products. -/
theorem bigOmega_mul {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) :
    bigOmega (a * b) = bigOmega a + bigOmega b := by
  unfold bigOmega
  rw [(Nat.perm_primeFactorsList_mul ha hb).length_eq, List.length_append]

/-- Complement `Ω`-weight identity: `Ω(N / d) = Ω(N) - Ω(d)` for every divisor `d ∣ N`. -/
theorem bigOmega_complement {N d : ℕ} (hN : N ≠ 0) (hd : d ∈ N.divisors) :
    bigOmega (N / d) = bigOmega N - bigOmega d := by
  have hdvd := Nat.dvd_of_mem_divisors hd
  have hd0 : d ≠ 0 := (Nat.pos_of_mem_divisors hd).ne'
  have hq0 : N / d ≠ 0 := by
    intro hq
    have hmul := Nat.div_mul_cancel hdvd
    rw [hq, zero_mul] at hmul
    exact hN hmul.symm
  have hsum : bigOmega (N / d) + bigOmega d = bigOmega N := by
    rw [← bigOmega_mul hq0 hd0, Nat.div_mul_cancel hdvd]
  omega

/-- Complement `d ↦ N / d` maps `omegaLayer N k` into `omegaLayer N (bigOmega N - k)`. -/
theorem complement_mem_omegaLayer {N k d : ℕ} (hN : N ≠ 0) (hd : d ∈ omegaLayer N k) :
    N / d ∈ omegaLayer N (bigOmega N - k) := by
  simp only [omegaLayer, Finset.mem_filter] at hd ⊢
  refine ⟨Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd (Nat.dvd_of_mem_divisors hd.1), hN⟩, ?_⟩
  rw [bigOmega_complement hN hd.1, hd.2]

/-- Statement 6a (`NOTE.md`): `d ↦ N / d` is a cardinality-preserving bijection swapping `k ↔ Ω(N) - k`. -/
theorem card_omegaLayer_complement {N : ℕ} (hN : N ≠ 0) {k : ℕ} (hk : k ≤ bigOmega N) :
    (omegaLayer N (bigOmega N - k)).card = (omegaLayer N k).card := by
  symm
  refine Finset.card_bij (fun d _ => N / d) ?_ ?_ ?_
  · intro d hd
    exact complement_mem_omegaLayer hN hd
  · intro a ha b hb hab
    have ha_div : a ∣ N := Nat.dvd_of_mem_divisors (Finset.mem_filter.mp ha).1
    have hb_div : b ∣ N := Nat.dvd_of_mem_divisors (Finset.mem_filter.mp hb).1
    have hha : N / (N / a) = a := Nat.div_div_self ha_div hN
    have hhb : N / (N / b) = b := Nat.div_div_self hb_div hN
    rw [← hha, ← hhb, hab]
  · intro d hd
    have hcomp := complement_mem_omegaLayer hN hd
    have hsub : bigOmega N - (bigOmega N - k) = k := Nat.sub_sub_self hk
    rw [hsub] at hcomp
    refine ⟨N / d, hcomp, ?_⟩
    exact Nat.div_div_self (Nat.dvd_of_mem_divisors (Finset.mem_filter.mp hd).1) hN

private lemma squarefree_prod_primes {s : Finset ℕ} (hs : ∀ p ∈ s, p.Prime) :
    Squarefree (∏ p ∈ s, p) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s has ih =>
    have hs' : ∀ p ∈ s, p.Prime := fun p hp => hs p (Finset.mem_insert_of_mem hp)
    have ha_prime : a.Prime := hs a (Finset.mem_insert_self a s)
    have hcop : Nat.Coprime a (∏ p ∈ s, p) := by
      rw [ha_prime.coprime_iff_not_dvd]
      intro hdvd
      obtain ⟨p, hps, hap⟩ := (ha_prime.prime.dvd_finsetProd_iff _).mp hdvd
      have hap_eq := ((hs' p hps).dvd_iff_eq ha_prime.ne_one).mp hap
      rw [← hap_eq] at has
      exact has hps
    rw [Finset.prod_insert has, Nat.squarefree_mul hcop]
    exact ⟨ha_prime.squarefree, ih hs'⟩

private lemma bigOmega_eq_primeFactors_card_of_squarefree {d : ℕ} (hd : Squarefree d) :
    bigOmega d = d.primeFactors.card := by
  unfold bigOmega
  rw [← Nat.toFinset_factors, List.toFinset_card_of_nodup hd.nodup_primeFactorsList]

/-- Statement 6b (`NOTE.md`): for squarefree `N`, the `k`-th `Ω`-layer has size `(ω(N) choose k)`. -/
theorem card_omegaLayer_squarefree {N : ℕ} (hN : Squarefree N) (k : ℕ) :
    (omegaLayer N k).card = Nat.choose N.primeFactors.card k := by
  rw [← Finset.card_powersetCard]
  symm
  refine Finset.card_bij (fun t _ => ∏ p ∈ t, p) ?_ ?_ ?_
  · intro t ht
    obtain ⟨hts, htc⟩ := Finset.mem_powersetCard.mp ht
    have hprimes : ∀ p ∈ t, p.Prime := fun p hp => Nat.prime_of_mem_primeFactors (hts hp)
    have hsq : Squarefree (∏ p ∈ t, p) := squarefree_prod_primes hprimes
    have hdvd : ∏ p ∈ t, p ∣ N := by
      rw [← Nat.prod_primeFactors_of_squarefree hN]
      exact Finset.prod_dvd_prod_of_subset t N.primeFactors (fun p => p) hts
    have hmem : ∏ p ∈ t, p ∈ N.divisors := Nat.mem_divisors.mpr ⟨hdvd, hN.ne_zero⟩
    have hom : bigOmega (∏ p ∈ t, p) = k := by
      rw [bigOmega_eq_primeFactors_card_of_squarefree hsq, Nat.primeFactors_prod hprimes, htc]
    exact Finset.mem_filter.mpr ⟨hmem, hom⟩
  · intro t1 ht1 t2 ht2 heq
    have hp1 : ∀ p ∈ t1, p.Prime := fun p hp =>
      Nat.prime_of_mem_primeFactors ((Finset.mem_powersetCard.mp ht1).1 hp)
    have hp2 : ∀ p ∈ t2, p.Prime := fun p hp =>
      Nat.prime_of_mem_primeFactors ((Finset.mem_powersetCard.mp ht2).1 hp)
    rw [← Nat.primeFactors_prod hp1, ← Nat.primeFactors_prod hp2, heq]
  · intro d hd
    simp only [omegaLayer, Finset.mem_filter] at hd
    have hsq_d : Squarefree d := hN.squarefree_of_dvd (Nat.dvd_of_mem_divisors hd.1)
    have hsub : d.primeFactors ⊆ N.primeFactors :=
      Nat.primeFactors_mono (Nat.dvd_of_mem_divisors hd.1) hN.ne_zero
    have hcard : d.primeFactors.card = k := by
      rw [← bigOmega_eq_primeFactors_card_of_squarefree hsq_d, hd.2]
    refine ⟨d.primeFactors, Finset.mem_powersetCard.mpr ⟨hsub, hcard⟩, ?_⟩
    exact Nat.prod_primeFactors_of_squarefree hsq_d

/-! ### Concrete checks: `N = 30` (cube/hexagon equator) and `N = 2310` (dodecahedron straddle)

Note: The `Rmk 9.7j.2` dodecahedron crystal correspondence mentioned in `NOTE.md` remains at the
Idea Catalog candidate stage; these finite layer theorems cite it only in commentary and do not
import or depend on any external Idea Catalog formalization. -/

private lemma squarefree_30 : Squarefree 30 ∧ (30 : ℕ).primeFactors = {2, 3, 5} := by
  have hs : ∀ p ∈ ({2, 3, 5} : Finset ℕ), p.Prime := by decide
  have hprod : ∏ p ∈ ({2, 3, 5} : Finset ℕ), p = 30 := by decide
  refine ⟨?_, ?_⟩
  · simpa [hprod] using squarefree_prod_primes hs
  · simpa [hprod] using Nat.primeFactors_prod hs

private lemma squarefree_2310 :
    Squarefree 2310 ∧ (2310 : ℕ).primeFactors = {2, 3, 5, 7, 11} := by
  have hs : ∀ p ∈ ({2, 3, 5, 7, 11} : Finset ℕ), p.Prime := by decide
  have hprod : ∏ p ∈ ({2, 3, 5, 7, 11} : Finset ℕ), p = 2310 := by decide
  refine ⟨?_, ?_⟩
  · simpa [hprod] using squarefree_prod_primes hs
  · simpa [hprod] using Nat.primeFactors_prod hs

/-- Concrete check (`NOTE.md` §6): `N = 30` has `Ω(30) = 3` and complement-swapped middle layers `Ω = 1, 2` of size `3` each (sum `6`). -/
theorem finite_example_30 :
    bigOmega 30 = 3 ∧
      (omegaLayer 30 1).card = 3 ∧
      (omegaLayer 30 2).card = 3 ∧
      (omegaLayer 30 1).card + (omegaLayer 30 2).card = 6 := by
  rcases squarefree_30 with ⟨hsq, hpf⟩
  have hcard : (30 : ℕ).primeFactors.card = 3 := by rw [hpf]; decide
  have hOm : bigOmega 30 = 3 := by
    rw [bigOmega_eq_primeFactors_card_of_squarefree hsq, hcard]
  have h1 : (omegaLayer 30 1).card = 3 := by
    rw [card_omegaLayer_squarefree hsq 1, hcard]; decide
  have h2 : (omegaLayer 30 2).card = 3 := by
    rw [card_omegaLayer_squarefree hsq 2, hcard]; decide
  refine ⟨hOm, h1, h2, by omega⟩

/-- Concrete check (`NOTE.md` §6): `N = 2310` has `Ω(2310) = 5` and complement-swapped middle layers `Ω = 2, 3` of size `10` each (20 total vertices). -/
theorem finite_example_2310 :
    bigOmega 2310 = 5 ∧
      (omegaLayer 2310 2).card = 10 ∧
      (omegaLayer 2310 3).card = 10 ∧
      (omegaLayer 2310 2).card + (omegaLayer 2310 3).card = 20 := by
  rcases squarefree_2310 with ⟨hsq, hpf⟩
  have hcard : (2310 : ℕ).primeFactors.card = 5 := by rw [hpf]; decide
  have hOm : bigOmega 2310 = 5 := by
    rw [bigOmega_eq_primeFactors_card_of_squarefree hsq, hcard]
  have h2 : (omegaLayer 2310 2).card = 10 := by
    rw [card_omegaLayer_squarefree hsq 2, hcard]; decide
  have h3 : (omegaLayer 2310 3).card = 10 := by
    rw [card_omegaLayer_squarefree hsq 3, hcard]; decide
  refine ⟨hOm, h2, h3, by omega⟩

end RHConnections.FiniteSphereFlip
