module

public import Mathlib.Algebra.BigOperators.Ring.Finset
public import Mathlib.Analysis.SpecialFunctions.BinaryEntropy
public import Mathlib.Analysis.SpecialFunctions.Pow.Real
public import Mathlib.Data.Nat.Factorization.Defs
public import Mathlib.Data.Nat.Squarefree
public import Mathlib.NumberTheory.Divisors
public import Mathlib.Tactic

@[expose] public section

open scoped BigOperators
namespace FVLT.DivisorBoltzmannV1

abbrev PrimeIndex (N : ℕ) := ↥N.factorization.support
abbrev ExponentBox (N : ℕ) := (p : PrimeIndex N) → Fin (N.factorization p.val + 1)

def pack (N : ℕ) (e : ExponentBox N) : ℕ :=
  ∏ p : PrimeIndex N, p.val ^ (e p).val

noncomputable def softmax {α : Type*} (s : Finset α) (logit : α → ℝ)
    (x : α) : ℝ :=
  Real.exp (logit x) / ∑ y ∈ s, Real.exp (logit y)

noncomputable def weight (β : ℝ) (d : ℕ) : ℝ :=
  Real.rpow (d : ℝ) (-β)

noncomputable def partition (N : ℕ) (β : ℝ) : ℝ :=
  ∑ d ∈ N.divisors, weight β d

noncomputable def divisorMass (N : ℕ) (β : ℝ) (d : ℕ) : ℝ :=
  weight β d / partition N β

noncomputable def primeWeight {N : ℕ} (β : ℝ) (p : PrimeIndex N)
    (k : Fin (N.factorization p.val + 1)) : ℝ :=
  Real.rpow (p.val : ℝ) (-β * (k.val : ℝ))

noncomputable def primeMass {N : ℕ} (β : ℝ) (p : PrimeIndex N)
    (k : Fin (N.factorization p.val + 1)) : ℝ :=
  primeWeight β p k / ∑ j : Fin (N.factorization p.val + 1), primeWeight β p j

noncomputable def divisorEntropy (N : ℕ) (β : ℝ) : ℝ :=
  ∑ d ∈ N.divisors, Real.negMulLog (divisorMass N β d)

noncomputable def primeEntropy {N : ℕ} (β : ℝ) (p : PrimeIndex N) : ℝ :=
  ∑ k : Fin (N.factorization p.val + 1), Real.negMulLog (primeMass β p k)


private theorem prime_index_prime {N : ℕ} (p : PrimeIndex N) : p.val.Prime :=
  Nat.prime_of_mem_primeFactors p.property

private theorem pack_pos (N : ℕ) (e : ExponentBox N) : 0 < pack N e := by
  apply Finset.prod_pos
  intro p _
  exact pow_pos (prime_index_prime p).pos _

private theorem pack_factorization (N : ℕ) (e : ExponentBox N) (p : ℕ) :
    (pack N e).factorization p = if h : p ∈ N.factorization.support then (e ⟨p, h⟩).val else 0 := by
  classical
  unfold pack
  rw [Nat.factorization_prod (fun q _ => pow_ne_zero _ (prime_index_prime q).ne_zero)]
  simp only [(prime_index_prime _).factorization_pow, Finsupp.finsetSum_apply, Finsupp.single_apply]
  split_ifs with hp
  · rw [Finset.sum_eq_single (⟨p, hp⟩ : PrimeIndex N)]
    · simp
    · intro q _ hq
      simp [show q.val ≠ p from fun h => hq (Subtype.ext h)]
    · exact fun h => (h (Finset.mem_univ _)).elim
  · apply Finset.sum_eq_zero
    intro q _
    simp [show q.val ≠ p from fun h => hp (h ▸ q.property)]

private theorem sum_product {ι : Type*} [Fintype ι] [DecidableEq ι] {A : ι → Type*}
    [∀ i, Fintype (A i)] (f : ∀ i, A i → ℝ) :
    (∑ x : ∀ i, A i, ∏ i, f i (x i)) = ∏ i, ∑ j, f i j := by
  classical
  simpa only [Fintype.piFinset_univ] using
    (Finset.prod_univ_sum (fun i => (Finset.univ : Finset (A i))) f).symm

theorem softmax_zero {α : Type*} (s : Finset α) (x : α) :
    softmax s (fun _ => 0) x = 1 / (s.card : ℝ) := by
  simp [softmax, Finset.sum_const]

theorem exists_exponent_equiv (N : ℕ) (hN : 0 < N) :
    ∃ f : ExponentBox N ≃ ↥N.divisors, ∀ e, (f e).val = pack N e := by
  classical
  have hle (e : ExponentBox N) : (pack N e).factorization ≤ N.factorization := by
    intro p
    rw [pack_factorization]
    split_ifs with hp
    · exact Nat.le_of_lt_succ (e ⟨p, hp⟩).isLt
    · exact Nat.zero_le _
  let f (e : ExponentBox N) : ↥N.divisors :=
    ⟨pack N e, Nat.mem_divisors.mpr
      ⟨(Nat.factorization_le_iff_dvd (pack_pos N e).ne' hN.ne').mp (hle e), hN.ne'⟩⟩
  refine ⟨Equiv.ofBijective f ⟨?_, ?_⟩, fun _ => rfl⟩
  · intro e g h
    funext p
    apply Fin.ext
    have hp := congrArg (fun d : ↥N.divisors => d.val.factorization p.val) h
    change (pack N e).factorization p.val = (pack N g).factorization p.val at hp
    simpa only [pack_factorization, dite_eq_left p.property] using hp
  · intro d
    have hd := Nat.dvd_of_mem_divisors d.property
    have hd0 : d.val ≠ 0 := (Nat.pos_of_dvd_of_pos hd hN).ne'
    have hdle := (Nat.factorization_le_iff_dvd hd0 hN.ne').mpr hd
    let e (p : PrimeIndex N) : Fin (N.factorization p.val + 1) :=
      ⟨d.val.factorization p.val, Nat.lt_succ_of_le (hdle p.val)⟩
    refine ⟨e, Subtype.ext ?_⟩
    change pack N e = d.val
    have he : (pack N e).factorization = d.val.factorization := by
      ext p
      rw [pack_factorization]
      split_ifs with hp
      · rfl
      · have hz : N.factorization p = 0 := Finsupp.notMem_support_iff.mp hp
        exact (Nat.eq_zero_of_le_zero (hz ▸ hdle p)).symm
    simpa only [Nat.prod_factorization_pow_eq_self (pack_pos N e).ne',
      Nat.prod_factorization_pow_eq_self hd0] using congrArg (fun a : ℕ →₀ ℕ => a.prod (· ^ ·)) he

theorem divisor_mass_eq_softmax (N : ℕ) (β : ℝ) {d : ℕ} (hd : d ∈ N.divisors) :
    divisorMass N β d =
      softmax N.divisors (fun j => -β * Real.log (j : ℝ)) d := by
  have he (j : ℕ) (hj : j ∈ N.divisors) :
      weight β j = Real.exp (-β * Real.log (j : ℝ)) := by
    have hpos : (0 : ℝ) < j := by
      exact_mod_cast Nat.pos_of_dvd_of_pos (Nat.dvd_of_mem_divisors hj)
        (Nat.pos_of_ne_zero (Nat.ne_zero_of_mem_divisors hj))
    change (j : ℝ) ^ (-β) = _
    rw [Real.rpow_def_of_pos hpos, mul_comm]
  rw [divisorMass, partition, softmax, he d hd, Finset.sum_congr rfl he]

private theorem pack_weight (N : ℕ) (β : ℝ) (e : ExponentBox N) :
    weight β (pack N e) = ∏ p : PrimeIndex N, primeWeight β p (e p) := by
  classical
  unfold weight pack primeWeight
  push_cast
  change (∏ p : PrimeIndex N, (p.val : ℝ) ^ (e p).val) ^ (-β) =
    ∏ p : PrimeIndex N, (p.val : ℝ) ^ (-β * ((e p).val : ℝ))
  rw [← Real.finsetProd_rpow]
  · apply Finset.prod_congr rfl
    intro p _
    rw [mul_comm (-β) ((e p).val : ℝ), Real.rpow_natCast_mul (Nat.cast_nonneg p.val)]
  · intros
    positivity

theorem partition_factorization (N : ℕ) (hN : 0 < N) (β : ℝ) :
    partition N β =
      ∏ p : PrimeIndex N, ∑ k : Fin (N.factorization p.val + 1), primeWeight β p k := by
  obtain ⟨f, hf⟩ := exists_exponent_equiv N hN
  rw [partition, ← sum_product]
  rw [← Finset.sum_attach]
  exact (Fintype.sum_equiv f _ _ (fun e => by rw [hf, pack_weight])).symm

theorem partition_complement (N : ℕ) (hN : 0 < N) (β : ℝ) :
    partition N β =
      weight β N * ∑ d ∈ N.divisors, weight (-β) d := by
  classical
  unfold partition
  rw [Finset.mul_sum]
  refine Finset.sum_bij (fun d _ => N / d) ?_ ?_ ?_ ?_
  · intro d hd
    exact Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd (Nat.dvd_of_mem_divisors hd), hN.ne'⟩
  · intro a ha b hb hab
    have hinv (d : ℕ) (hd : d ∈ N.divisors) : N / (N / d) = d := by
      have hm := Nat.div_mul_cancel (Nat.dvd_of_mem_divisors hd)
      have hp : 0 < N / d := Nat.pos_of_ne_zero (by intro hz; exact hN.ne' (by simpa [hz] using hm.symm))
      exact (Nat.div_eq_of_eq_mul_left hp (by simpa [Nat.mul_comm] using hm.symm))
    simpa only [hinv a ha, hinv b hb] using congrArg (N / ·) hab
  · intro d hd
    have hm := Nat.div_mul_cancel (Nat.dvd_of_mem_divisors hd)
    have hp : 0 < N / d := Nat.pos_of_ne_zero (by intro hz; exact hN.ne' (by simpa [hz] using hm.symm))
    exact ⟨N / d, Nat.mem_divisors.mpr ⟨Nat.div_dvd_of_dvd (Nat.dvd_of_mem_divisors hd), hN.ne'⟩,
      Nat.div_eq_of_eq_mul_left hp (by simpa [Nat.mul_comm] using hm.symm)⟩
  · intro d hd
    have hm := Nat.div_mul_cancel (Nat.dvd_of_mem_divisors hd)
    have hq : (0 : ℝ) ≤ (N / d : ℕ) := by positivity
    have hp : (0 : ℝ) ≤ d := by positivity
    change (d : ℝ) ^ (-β) = (N : ℝ) ^ (-β) * ((N / d : ℕ) : ℝ) ^ (- -β)
    have hcast : (N : ℝ) = ((N / d : ℕ) : ℝ) * (d : ℝ) := by exact_mod_cast hm.symm
    rw [neg_neg, hcast, Real.mul_rpow hq hp, Real.rpow_neg hq]
    have hn : (0 : ℝ) < (N / d : ℕ) := by
      exact_mod_cast Nat.pos_of_ne_zero (by intro hz; exact hN.ne' (by simpa [hz] using hm.symm))
    field_simp [ne_of_gt (Real.rpow_pos_of_pos hn β)]

private theorem prime_weight_pos {N : ℕ} (β : ℝ) (p : PrimeIndex N)
    (k : Fin (N.factorization p.val + 1)) : 0 < primeWeight β p k :=
  Real.rpow_pos_of_pos (by exact_mod_cast (prime_index_prime p).pos) _

private theorem prime_partition_pos {N : ℕ} (β : ℝ) (p : PrimeIndex N) :
    0 < ∑ k : Fin (N.factorization p.val + 1), primeWeight β p k :=
  Finset.sum_pos (fun k _ => prime_weight_pos β p k) Finset.univ_nonempty

private theorem prime_mass_pos {N : ℕ} (β : ℝ) (p : PrimeIndex N)
    (k : Fin (N.factorization p.val + 1)) : 0 < primeMass β p k :=
  div_pos (prime_weight_pos β p k) (prime_partition_pos β p)

theorem prime_mass_sum {N : ℕ} (β : ℝ) (p : PrimeIndex N) :
    (∑ k : Fin (N.factorization p.val + 1), primeMass β p k) = 1 := by
  unfold primeMass
  rw [← Finset.sum_div, div_self (ne_of_gt (prime_partition_pos β p))]

theorem divisor_mass_factorization (N : ℕ) (hN : 0 < N) (β : ℝ)
    (e : ExponentBox N) :
    divisorMass N β (pack N e) = ∏ p : PrimeIndex N, primeMass β p (e p) := by
  rw [divisorMass, partition_factorization N hN, pack_weight]
  unfold primeMass
  rw [Finset.prod_div_distrib]

private theorem product_entropy {ι : Type*} [Fintype ι] [DecidableEq ι] {A : ι → Type*}
    [∀ i, Fintype (A i)] (m : ∀ i, A i → ℝ)
    (hp : ∀ i k, 0 < m i k) (hs : ∀ i, (∑ k, m i k) = 1) :
    (∑ e : ∀ i, A i, Real.negMulLog (∏ i, m i (e i))) =
      ∑ i, ∑ k, Real.negMulLog (m i k) := by
  classical
  have hterm (e : ∀ i, A i) :
      Real.negMulLog (∏ i, m i (e i)) =
        ∑ i, ∏ j, (if j = i then Real.negMulLog (m j (e j)) else m j (e j)) := by
    simp only [Real.negMulLog_def]
    rw [Real.log_prod (fun j _ => (hp j (e j)).ne'), Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    rw [← Finset.mul_prod_erase Finset.univ _ hi, ← Finset.mul_prod_erase Finset.univ _ hi]
    simp only [ite_true]
    have he : (∏ j ∈ Finset.univ.erase i,
        if j = i then Real.negMulLog (m j (e j)) else m j (e j)) =
        ∏ j ∈ Finset.univ.erase i, m j (e j) := by
      apply Finset.prod_congr rfl
      intro j hj
      rw [ite_eq_right (Finset.ne_of_mem_erase hj)]
    simp only [Real.negMulLog_def] at he
    rw [he]
    ring
  simp_rw [hterm]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  rw [sum_product (fun j k => if j = i then Real.negMulLog (m j k) else m j k),
    ← Finset.mul_prod_erase Finset.univ _ hi]
  simp only [ite_true]
  have he : (∏ j ∈ Finset.univ.erase i,
      ∑ k, if j = i then Real.negMulLog (m j k) else m j k) = 1 := by
    apply Finset.prod_eq_one
    intro j hj
    simpa only [ite_eq_right (Finset.ne_of_mem_erase hj)] using hs j
  rw [he, mul_one]

theorem divisor_entropy_decomposition (N : ℕ) (hN : 0 < N) (β : ℝ) :
    divisorEntropy N β = ∑ p : PrimeIndex N, primeEntropy β p := by
  obtain ⟨f, hf⟩ := exists_exponent_equiv N hN
  unfold divisorEntropy primeEntropy
  rw [← Finset.sum_attach]
  calc
    _ = ∑ e : ExponentBox N, Real.negMulLog (∏ p : PrimeIndex N, primeMass β p (e p)) := by
      exact (Fintype.sum_equiv f _ _ (fun e => by rw [hf, divisor_mass_factorization N hN])).symm
    _ = _ := product_entropy (primeMass β) (fun p k => prime_mass_pos β p k) (prime_mass_sum β)

theorem divisor_entropy_zero_beta (N : ℕ) (hN : 0 < N) :
    divisorEntropy N 0 =
      ∑ p : PrimeIndex N, Real.log ((N.factorization p.val : ℝ) + 1) := by
  rw [divisor_entropy_decomposition N hN]
  apply Finset.sum_congr rfl
  intro p _
  simp [primeEntropy, primeMass, primeWeight, Finset.sum_const, Real.negMulLog_def,
    Real.log_inv, one_div, nsmul_eq_mul, show (N.factorization p.val : ℝ) + 1 ≠ 0 by positivity,
    ]

private theorem prime_index_squarefree {N : ℕ} (hs : Squarefree N)
    (p : PrimeIndex N) : N.factorization p.val = 1 :=
  Nat.factorization_eq_one_of_squarefree hs (prime_index_prime p)
    (Nat.dvd_of_mem_primeFactors p.property)

private theorem squarefree_sum {N : ℕ} (hs : Squarefree N) (p : PrimeIndex N)
    (f : Fin (N.factorization p.val + 1) → ℝ) :
    (∑ k, f k) = f 0 + f 1 := by
  have h := prime_index_squarefree hs p
  generalize N.factorization p.val = n at h f ⊢
  subst n
  exact Fin.sum_univ_two f

theorem squarefree_prime_mass_one (N : ℕ) (hN : Squarefree N)
    (β : ℝ) (p : PrimeIndex N) (k : Fin (N.factorization p.val + 1))
    (hk : k.val = 1) :
    primeMass β p k = weight β p.val / (1 + weight β p.val) := by
  have hs := prime_index_squarefree hN p
  have hsum := squarefree_sum hN p (primeWeight β p)
  have hw : primeWeight β p k = weight β p.val := by simp [primeWeight, weight, hk]
  rw [primeMass, hsum, hw]
  simp [primeWeight, weight, hs]

theorem squarefree_prime_entropy (N : ℕ) (hN : Squarefree N)
    (β : ℝ) (p : PrimeIndex N) :
    primeEntropy β p = Real.binEntropy (weight β p.val / (1 + weight β p.val)) := by
  classical
  let k₁ : Fin (N.factorization p.val + 1) :=
    ⟨1, by rw [prime_index_squarefree hN p]; decide⟩
  have hk : k₁ = 1 := Fin.ext (by simp [k₁, prime_index_squarefree hN p])
  have hs := prime_mass_sum β p
  rw [squarefree_sum hN p] at hs
  rw [primeEntropy, squarefree_sum hN p, Real.binEntropy_eq_negMulLog_add_negMulLog_one_sub]
  have h := squarefree_prime_mass_one N hN β p k₁ rfl
  rw [hk] at h
  rw [← h, show primeMass β p 0 = 1 - primeMass β p 1 by linarith, add_comm]

theorem squarefree_entropy_zero_beta (N : ℕ) (hN : 0 < N) (hs : Squarefree N) :
    divisorEntropy N 0 = (N.factorization.support.card : ℝ) * Real.log 2 := by
  rw [divisor_entropy_zero_beta N hN]
  have ht (p : PrimeIndex N) : Real.log ((N.factorization p.val : ℝ) + 1) = Real.log 2 := by
    rw [prime_index_squarefree hs p]
    norm_num
  simp only [ht, Finset.sum_const, nsmul_eq_mul]
  rw [← Fintype.card, Fintype.card_coe]

end FVLT.DivisorBoltzmannV1
