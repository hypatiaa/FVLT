/-
  CrystalBridge.lean — Formal Lean 4.35.0 reductions from the Ratioque CAT(0) /
  Kashiwara crystal slice sum V(x) (and its Dirichlet character twists V_chi(x))
  as well as the Farey first-harmonic bound to Mathlib's `RiemannHypothesis`
  and Alpoge's `EveryCharacter` (`allChi`).

  Credits: saphir (project lead), Astra (discipline), Opus (skeleton), Gemini (vision).
  Conditional reductions only: `VCancellation`, `TwistedVCancellation`, and
  `AllChiVCancellation` are explicit open mathematical hypotheses.
-/

import Mathlib.Algebra.Order.Floor.Semifield
import Mathlib.Analysis.Complex.ExponentialBounds
import Mathlib.Analysis.MellinTransform
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Bounds
import Mathlib.Data.Nat.Log
import Mathlib.NumberTheory.ArithmeticFunction.Moebius
import Mathlib.NumberTheory.LSeries.Dirichlet
import Mathlib.NumberTheory.LSeries.DirichletContinuation
import Mathlib.NumberTheory.LSeries.Nonvanishing
import Mathlib.NumberTheory.LSeries.RiemannZeta
import Mathlib.NumberTheory.LSeries.SumCoeff
import Mathlib.Tactic

noncomputable section

namespace Ratioque.CrystalBridge

open ArithmeticFunction Complex Filter Asymptotics MeasureTheory
open scoped ArithmeticFunction.Moebius Topology LSeries.notation

/-! ### 1. Core Definitions: Crystal Slices, Twisted Mobius, and Open Hypotheses -/

/-- Exact analogue of `UpperTheory.EveryCharacter` (`EveryCharacter.lean:13`). -/
def EveryCharacter : Prop :=
  ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N) (s : ℂ),
    (1 / 2 : ℝ) < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0

/-- Arithmetic weight `χ(n) * μ(n)` matching Mathlib's `↗χ * ↗μ`. -/
def twistedCoeff {N : ℕ} (χ : DirichletCharacter ℂ N) (n : ℕ) : ℂ :=
  χ n * (ArithmeticFunction.moebius n : ℂ)

lemma twistedCoeff_eq_LSeries_mul {N : ℕ} (χ : DirichletCharacter ℂ N) :
    twistedCoeff χ = (↗χ * ↗μ) := by
  ext n
  simp [twistedCoeff]

/-- Partial sum of `χ(k) μ(k)` over `1 ≤ k ≤ ⌊x⌋₊` (coprime to `B`). -/
def twistedCoprimeSum {N : ℕ} (χ : DirichletCharacter ℂ N) (B : ℕ) (x : ℝ) : ℂ :=
  ∑ k ∈ (Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k B), twistedCoeff χ k

/-- Full twisted Mertens sum `M_χ(x) = ∑_{1 ≤ k ≤ x} χ(k) μ(k)`. -/
def twistedMertens {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  ∑ k ∈ Finset.Icc 1 ⌊x⌋₊, twistedCoeff χ k

/-- Prime-to-six twisted cumulative Mobius sum `S_{6,χ}(x)`. -/
def twistedS6 {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  twistedCoprimeSum χ 6 x

/-- Dyadic crystal-slab / Farey-band sum `V_χ(x) = ∑_{x/2 < k ≤ x, (k,6)=1} χ(k) μ(k)`. -/
def twistedV {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) : ℂ :=
  ∑ k ∈ (Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊).filter (fun k => Nat.Coprime k 6), twistedCoeff χ k

/-- Untwisted Mertens sum `M(x) = ∑_{1 ≤ k ≤ x} μ(k)`. -/
def mertens (x : ℝ) : ℂ :=
  twistedMertens (1 : DirichletCharacter ℂ 1) x

/-- Untwisted prime-to-six dyadic crystal-slab sum `V(x)`. -/
def V (x : ℝ) : ℂ :=
  twistedV (1 : DirichletCharacter ℂ 1) x

/-- Open square-root-scale hypothesis for the twisted Mertens sum `M_χ`. -/
def TwistedMertensCancellation {N : ℕ} (χ : DirichletCharacter ℂ N) : Prop :=
  ∀ ε : ℝ, 0 < ε → twistedMertens χ =O[atTop] (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε))

/-- Open square-root-scale hypothesis for the twisted dyadic crystal slab `V_χ`. -/
def TwistedVCancellation {N : ℕ} (χ : DirichletCharacter ℂ N) : Prop :=
  ∀ ε : ℝ, 0 < ε → twistedV χ =O[atTop] (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε))

/-- Open `allChi` crystal-slab hypothesis across every modulus `N ≥ 1` and character `χ`. -/
def AllChiVCancellation : Prop :=
  ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N), TwistedVCancellation χ

/-- Open ordinary-RH Mertens cancellation hypothesis. -/
def MertensCancellation : Prop :=
  TwistedMertensCancellation (1 : DirichletCharacter ℂ 1)

/-- Open ordinary-RH crystal-slab hypothesis (`χ = 1`). -/
def VCancellation : Prop :=
  TwistedVCancellation (1 : DirichletCharacter ℂ 1)

/-! ### 2. Unconditional Finite Identities on the Crystal Slab -/

lemma twistedCoprimeSum_one {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) :
    twistedCoprimeSum χ 1 x = twistedMertens χ x := by
  simp [twistedCoprimeSum, twistedMertens]

lemma twistedCoeff_prime_mul {N : ℕ} (χ : DirichletCharacter ℂ N) {p j : ℕ} (hp : p.Prime) :
    twistedCoeff χ (p * j) = if p ∣ j then 0 else -χ p * twistedCoeff χ j := by
  split_ifs with hdiv
  · obtain ⟨k, rfl⟩ := hdiv
    have hns : ¬ Squarefree (p * (p * k)) := by
      intro hs
      have hdvd : p * p ∣ p * (p * k) := ⟨k, by ring⟩
      exact hp.ne_one (Nat.isUnit_iff.mp (hs p hdvd))
    simp [twistedCoeff, ArithmeticFunction.moebius_eq_zero_of_not_squarefree hns]
  · have hcop : Nat.Coprime p j := hp.coprime_iff_not_dvd.mpr hdiv
    have hmu : ArithmeticFunction.moebius (p * j) = -ArithmeticFunction.moebius j := by
      rw [ArithmeticFunction.isMultiplicative_moebius.map_mul_of_coprime hcop,
        ArithmeticFunction.moebius_apply_prime hp, neg_one_mul]
    rw [twistedCoeff, twistedCoeff, hmu]
    simp only [Nat.cast_mul, map_mul, Int.cast_neg, mul_neg, neg_mul]
    ring

/-- Exact single-prime sieve factor: removing prime `p` coprime to `B` from `Coprime · B`. -/
theorem twistedCoprimeSum_sieve_prime {N : ℕ} (χ : DirichletCharacter ℂ N)
    {p B : ℕ} (hp : p.Prime) (hpB : Nat.Coprime p B) (x : ℝ) :
    twistedCoprimeSum χ B x =
      twistedCoprimeSum χ (p * B) x - χ p * twistedCoprimeSum χ (p * B) (x / p) := by
  unfold twistedCoprimeSum
  have hsplit := Finset.sum_filter_add_sum_filter_not
    ((Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k B)) (fun k => p ∣ k) (twistedCoeff χ)
  have hnot :
      ∑ k ∈ ((Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k B)).filter (fun k => ¬ p ∣ k),
          twistedCoeff χ k =
        ∑ k ∈ (Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k (p * B)), twistedCoeff χ k := by
    refine Finset.sum_congr ?_ (fun _ _ => rfl)
    ext k
    simp only [Finset.mem_filter, Nat.coprime_mul_iff_right]
    constructor
    · intro hk
      exact ⟨hk.1.1, (hp.coprime_iff_not_dvd.mpr hk.2).symm, hk.1.2⟩
    · intro hk
      exact ⟨⟨hk.1, hk.2.2⟩, hp.coprime_iff_not_dvd.mp hk.2.1.symm⟩
  have hdvdSum :
      ∑ k ∈ ((Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k B)).filter (fun k => p ∣ k),
          twistedCoeff χ k =
        -χ p * ∑ j ∈ (Finset.Icc 1 ⌊x / p⌋₊).filter (fun j => Nat.Coprime j (p * B)),
          twistedCoeff χ j := by
    rw [Nat.floor_div_natCast x p]
    have hbij :
        ∑ k ∈ ((Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k B)).filter (fun k => p ∣ k),
            twistedCoeff χ k =
          ∑ j ∈ (Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j B),
            twistedCoeff χ (p * j) := by
      refine Finset.sum_bij'
        (fun k _ => k / p)
        (fun j _ => p * j)
        ?_ ?_ ?_ ?_ ?_
      · intro k hk
        simp only [Finset.mem_filter, Finset.mem_Icc] at hk ⊢
        rcases hk with ⟨⟨⟨hk1, hk2⟩, hkB⟩, ⟨m, rfl⟩⟩
        have hmpos : 1 ≤ m := by
          by_contra hm0
          have hmzero : m = 0 := by omega
          simp [hmzero] at hk1
        rw [Nat.mul_div_cancel_left _ hp.pos]
        refine ⟨⟨hmpos, (Nat.le_div_iff_mul_le hp.pos).mpr (by simpa [mul_comm] using hk2)⟩,
          (Nat.coprime_mul_iff_left.mp hkB).2⟩
      · intro j hj
        simp only [Finset.mem_filter, Finset.mem_Icc] at hj ⊢
        rcases hj with ⟨⟨hj1, hj2⟩, hjB⟩
        have hle : p * j ≤ ⌊x⌋₊ := by
          have := (Nat.le_div_iff_mul_le hp.pos).mp hj2
          linarith
        refine ⟨⟨⟨Nat.mul_pos hp.pos hj1, hle⟩, Nat.coprime_mul_iff_left.mpr ⟨hpB, hjB⟩⟩, ⟨j, rfl⟩⟩
      · intro k hk
        simp only [Finset.mem_filter] at hk
        exact Nat.mul_div_cancel' hk.2
      · intro j _
        exact Nat.mul_div_cancel_left _ hp.pos
      · intro k hk
        simp only [Finset.mem_filter] at hk
        rw [Nat.mul_div_cancel' hk.2]
    rw [hbij]
    have hrewrite :
        ∑ j ∈ (Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j B),
            twistedCoeff χ (p * j) =
          ∑ j ∈ ((Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j B)).filter
            (fun j => ¬ p ∣ j), (-χ p * twistedCoeff χ j) := by
      have hs := Finset.sum_filter_add_sum_filter_not
        ((Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j B))
        (fun j => p ∣ j) (fun j => twistedCoeff χ (p * j))
      have hzero :
          ∑ j ∈ ((Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j B)).filter
              (fun j => p ∣ j), twistedCoeff χ (p * j) = 0 := by
        apply Finset.sum_eq_zero
        intro j hj
        simp only [Finset.mem_filter] at hj
        rw [twistedCoeff_prime_mul χ hp]
        exact ite_eq_left_iff.mpr fun h => (h hj.2).elim
      rw [hzero, zero_add] at hs
      rw [← hs]
      refine Finset.sum_congr rfl fun j hj => ?_
      simp only [Finset.mem_filter] at hj
      rw [twistedCoeff_prime_mul χ hp]
      exact ite_eq_right_iff.mpr fun h => (hj.2 h).elim
    rw [hrewrite, ← Finset.mul_sum]
    have hfilt :
        ((Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j B)).filter (fun j => ¬ p ∣ j) =
          (Finset.Icc 1 (⌊x⌋₊ / p)).filter (fun j => Nat.Coprime j (p * B)) := by
      ext j
      simp only [Finset.mem_filter, Nat.coprime_mul_iff_right]
      constructor
      · intro hj
        exact ⟨hj.1.1, (hp.coprime_iff_not_dvd.mpr hj.2).symm, hj.1.2⟩
      · intro hj
        exact ⟨⟨hj.1, hj.2.2⟩, hp.coprime_iff_not_dvd.mp hj.2.1.symm⟩
    rw [hfilt]
  rw [← hsplit, hnot, hdvdSum]
  ring

/-- Exact inclusion-exclusion restoring primes `2` and `3` for any character `χ`. -/
theorem twistedMertens_eq_restore_2_3 {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) :
    twistedMertens χ x =
      twistedS6 χ x - χ 2 * twistedS6 χ (x / 2)
        - χ 3 * twistedS6 χ (x / 3) + χ 2 * χ 3 * twistedS6 χ (x / 6) := by
  have h1 : twistedMertens χ x =
      twistedCoprimeSum χ 2 x - χ 2 * twistedCoprimeSum χ 2 (x / 2) := by
    rw [← twistedCoprimeSum_one χ x]
    simpa using twistedCoprimeSum_sieve_prime χ Nat.prime_two (Nat.coprime_one_right 2) x
  have h2 (y : ℝ) : twistedCoprimeSum χ 2 y =
      twistedS6 χ y - χ 3 * twistedS6 χ (y / 3) := by
    have hs := twistedCoprimeSum_sieve_prime χ Nat.prime_three (by decide : Nat.Coprime 3 2) y
    simpa [twistedS6] using hs
  rw [h1, h2 x, h2 (x / 2)]
  have hdiv6 : (x / 2) / 3 = x / 6 := by ring
  rw [hdiv6]
  ring

/-- Dyadic slab relation `V_χ(x) = S_{6,χ}(x) - S_{6,χ}(x / 2)` for `0 ≤ x`. -/
theorem twistedV_eq_sub_twistedS6 {N : ℕ} (χ : DirichletCharacter ℂ N) {x : ℝ} (hx : 0 ≤ x) :
    twistedV χ x = twistedS6 χ x - twistedS6 χ (x / 2) := by
  have hle : ⌊x / 2⌋₊ ≤ ⌊x⌋₊ := Nat.floor_mono (by linarith)
  have hdisj :
      (Finset.Icc 1 ⌊x / 2⌋₊).filter (fun k => Nat.Coprime k 6) ∪
        (Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊).filter (fun k => Nat.Coprime k 6) =
          (Finset.Icc 1 ⌊x⌋₊).filter (fun k => Nat.Coprime k 6) := by
    ext k
    simp only [Finset.mem_union, Finset.mem_filter, Finset.mem_Icc, Finset.mem_Ioc]
    omega
  have hinter :
      Disjoint ((Finset.Icc 1 ⌊x / 2⌋₊).filter (fun k => Nat.Coprime k 6))
        ((Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊).filter (fun k => Nat.Coprime k 6)) := by
    rw [Finset.disjoint_left]
    intro k hk1 hk2
    simp only [Finset.mem_filter, Finset.mem_Icc, Finset.mem_Ioc] at hk1 hk2
    omega
  have hsum := Finset.sum_union hinter (f := twistedCoeff χ)
  rw [hdisj] at hsum
  unfold twistedV twistedS6 twistedCoprimeSum
  exact eq_sub_of_add_eq' hsum.symm

/-- Exact dyadic crystal-slab decomposition of `S_{6,χ}(x)`. -/
theorem twistedS6_eq_sum_dyadic_V {N : ℕ} (χ : DirichletCharacter ℂ N) :
    ∀ K : ℕ, ∀ x : ℝ, 0 ≤ x → ⌊x⌋₊ < 2 ^ K →
      twistedS6 χ x = ∑ k ∈ Finset.range K, twistedV χ (x / (2 : ℝ) ^ k) := by
  intro K
  induction K with
  | zero =>
    intro x _ hxK
    have h0 : ⌊x⌋₊ = 0 := by omega
    simp [twistedS6, twistedCoprimeSum, h0]
  | succ K ih =>
    intro x hx hxK
    have hx2_nonneg : 0 ≤ x / 2 := by linarith
    have hx2_lt : ⌊x / 2⌋₊ < 2 ^ K := by
      have hf : ⌊x / ((2 : ℕ) : ℝ)⌋₊ = ⌊x⌋₊ / 2 := Nat.floor_div_natCast x 2
      norm_num at hf
      rw [hf]
      exact Nat.div_lt_of_lt_mul (by simpa [pow_succ', mul_comm] using hxK)
    rw [Finset.sum_range_succ']
    have hshift :
        ∑ k ∈ Finset.range K, twistedV χ (x / (2 : ℝ) ^ (k + 1)) =
          ∑ k ∈ Finset.range K, twistedV χ ((x / 2) / (2 : ℝ) ^ k) := by
      apply Finset.sum_congr rfl
      intro k _
      rw [show x / (2 : ℝ) ^ (k + 1) = (x / 2) / (2 : ℝ) ^ k by rw [pow_succ']; ring]
    rw [hshift, ← ih (x / 2) hx2_nonneg hx2_lt, pow_zero, div_one, twistedV_eq_sub_twistedS6 χ hx]
    ring

/-- Untwisted specialization: `M(x) = V(x) - V(x / 3)` for `0 ≤ x` (`ANALYTIC.md:11`). -/
theorem mertens_eq_V_sub_V_div_three {x : ℝ} (hx : 0 ≤ x) :
    mertens x = V x - V (x / 3) := by
  unfold mertens V
  have h1 := twistedMertens_eq_restore_2_3 (1 : DirichletCharacter ℂ 1) x
  have hchr (m : ZMod 1) : (1 : DirichletCharacter ℂ 1) m = 1 :=
    MulChar.one_apply (isUnit_of_subsingleton m)
  rw [hchr, hchr] at h1
  rw [h1, twistedV_eq_sub_twistedS6 _ hx, twistedV_eq_sub_twistedS6 _ (by linarith)]
  rw [show (x / 3) / 2 = x / 6 by ring]
  ring

/-! ### 3. Dyadic-Slab Growth Transfer (`V_χ` / `V` -> `M_χ` / `M`) -/

private lemma twistedS6_eq_zero_of_lt_one {N : ℕ} (χ : DirichletCharacter ℂ N)
    {x : ℝ} (hx : x < 1) : twistedS6 χ x = 0 := by
  have h0 : ⌊x⌋₊ = 0 := Nat.floor_eq_zero.mpr hx
  simp [twistedS6, twistedCoprimeSum, h0]

private lemma twistedV_eq_zero_of_lt_one {N : ℕ} (χ : DirichletCharacter ℂ N)
    {x : ℝ} (hx : x < 1) : twistedV χ x = 0 := by
  have h0 : ⌊x⌋₊ = 0 := Nat.floor_eq_zero.mpr hx
  have h02 : ⌊x / 2⌋₊ = 0 := Nat.floor_eq_zero.mpr (by linarith)
  simp [twistedV, h0, h02]

/-- Summing dyadic slabs transfers `V_χ(x) = O_ε(x^(1/2+ε))` to `M_χ(x) = O_ε(x^(1/2+ε))`. -/
theorem twistedMertensCancellation_of_twistedVCancellation
    {N : ℕ} {χ : DirichletCharacter ℂ N} (hV : TwistedVCancellation χ) :
    TwistedMertensCancellation χ := by
  intro ε hε
  let θ : ℝ := 1 / 2 + ε
  have hθ_pos : 0 < θ := by dsimp [θ]; linarith
  have hVθ := hV ε hε
  obtain ⟨C₀, hC₀_pos, hC₀⟩ := hVθ.exists_pos
  obtain ⟨X₀, hX₀⟩ := eventually_atTop.mp hC₀.bound
  let B₀ : ℝ := ∑ k ∈ Finset.Icc 1 (⌊max X₀ 1⌋₊), (1 : ℝ)
  let C : ℝ := max C₀ B₀ + 1
  have hC_pos : 0 < C := by positivity
  have hV_global : ∀ t : ℝ, 1 ≤ t → ‖twistedV χ t‖ ≤ C * t ^ θ := by
    intro t ht
    by_cases hbig : X₀ ≤ t
    · have ht0 := hX₀ t hbig
      have hnorm : ‖t ^ θ‖ = t ^ θ := by
        rw [Real.norm_of_nonneg (Real.rpow_nonneg (by linarith) _)]
      rw [hnorm] at ht0
      exact ht0.trans (mul_le_mul_of_nonneg_right
        (le_trans (le_max_left _ _) (le_add_of_nonneg_right zero_le_one))
        (Real.rpow_nonneg (by linarith) _))
    · have hlt : t < max X₀ 1 := lt_max_of_lt_left (lt_of_not_ge hbig)
      have hfloor_le : ⌊t⌋₊ ≤ ⌊max X₀ 1⌋₊ := Nat.floor_mono hlt.le
      have hnorm_sum :
          ‖twistedV χ t‖ ≤
            ∑ k ∈ (Finset.Ioc ⌊t / 2⌋₊ ⌊t⌋₊).filter (fun k => Nat.Coprime k 6),
              ‖twistedCoeff χ k‖ := norm_sum_le _ _
      have hterm : ∀ k : ℕ, ‖twistedCoeff χ k‖ ≤ 1 := by
        intro k
        rw [twistedCoeff, norm_mul]
        have h1 : ‖χ k‖ ≤ 1 := χ.norm_le_one k
        have h2 : ‖(ArithmeticFunction.moebius k : ℂ)‖ ≤ 1 := by
          rw [Complex.norm_intCast]
          exact_mod_cast (ArithmeticFunction.abs_moebius_le_one (n := k))
        simpa using mul_le_mul h1 h2 (norm_nonneg _) zero_le_one
      have hsub :
          (Finset.Ioc ⌊t / 2⌋₊ ⌊t⌋₊).filter (fun k => Nat.Coprime k 6) ⊆
            Finset.Icc 1 (⌊max X₀ 1⌋₊) := by
        intro k hk
        simp only [Finset.mem_filter, Finset.mem_Ioc, Finset.mem_Icc] at hk ⊢
        omega
      have hle_B : ‖twistedV χ t‖ ≤ B₀ := by
        calc ‖twistedV χ t‖
            ≤ ∑ k ∈ (Finset.Ioc ⌊t / 2⌋₊ ⌊t⌋₊).filter (fun k => Nat.Coprime k 6),
                ‖twistedCoeff χ k‖ := hnorm_sum
          _ ≤ ∑ _k ∈ (Finset.Ioc ⌊t / 2⌋₊ ⌊t⌋₊).filter (fun k => Nat.Coprime k 6), (1 : ℝ) :=
              Finset.sum_le_sum (fun k _ => hterm k)
          _ ≤ B₀ := Finset.sum_le_sum_of_subset_of_nonneg hsub (fun _ _ _ => zero_le_one)
      have h1_le_pow : 1 ≤ t ^ θ := Real.one_le_rpow ht hθ_pos.le
      calc ‖twistedV χ t‖ ≤ B₀ := hle_B
        _ ≤ C := by dsimp [C]; exact le_trans (le_max_right _ _) (le_add_of_nonneg_right zero_le_one)
        _ ≤ C * t ^ θ := le_mul_of_one_le_right hC_pos.le h1_le_pow
  let r : ℝ := (2 : ℝ) ^ (-θ)
  have hr_pos : 0 < r := Real.rpow_pos_of_pos zero_lt_two _
  have hr_lt : r < 1 := Real.rpow_lt_one_of_one_lt_of_neg one_lt_two (neg_lt_zero.mpr hθ_pos)
  let C_S6 : ℝ := C / (1 - r)
  have hS6_bound : ∀ x : ℝ, 0 ≤ x → ‖twistedS6 χ x‖ ≤ C_S6 * (max x 1) ^ θ := by
    intro x hx
    by_cases hx1 : x < 1
    · rw [twistedS6_eq_zero_of_lt_one χ hx1, norm_zero]
      have hpos1 : 0 ≤ C_S6 := div_nonneg hC_pos.le (sub_nonneg.mpr hr_lt.le)
      exact mul_nonneg hpos1 (Real.rpow_nonneg (by positivity) _)
    · have hx_ge : 1 ≤ x := le_of_not_gt hx1
      rw [max_eq_left hx_ge]
      let K := Nat.log 2 ⌊x⌋₊ + 1
      have hltK : ⌊x⌋₊ < 2 ^ K := Nat.lt_pow_succ_log_self one_lt_two ⌊x⌋₊
      rw [twistedS6_eq_sum_dyadic_V χ K x hx hltK]
      have hsum_le :
          ‖∑ k ∈ Finset.range K, twistedV χ (x / (2 : ℝ) ^ k)‖ ≤
            ∑ k ∈ Finset.range K, C * (x ^ θ * r ^ k) := by
        refine (norm_sum_le _ _).trans (Finset.sum_le_sum fun k _ => ?_)
        by_cases hk1 : x / (2 : ℝ) ^ k < 1
        · rw [twistedV_eq_zero_of_lt_one χ hk1, norm_zero]
          exact mul_nonneg hC_pos.le (mul_nonneg (Real.rpow_nonneg hx _) (pow_nonneg hr_pos.le _))
        · have hk_ge : 1 ≤ x / (2 : ℝ) ^ k := le_of_not_gt hk1
          have hpow_eq : (x / (2 : ℝ) ^ k) ^ θ = x ^ θ * r ^ k := by
            rw [Real.div_rpow hx (by positivity), div_eq_mul_inv]
            congr 1
            rw [← Real.rpow_natCast, ← Real.rpow_mul zero_le_two, ← Real.rpow_neg zero_le_two,
              ← Real.rpow_natCast r k]
            dsimp [r]
            rw [← Real.rpow_mul zero_le_two]
            congr 1
            ring
          calc ‖twistedV χ (x / (2 : ℝ) ^ k)‖
              ≤ C * (x / (2 : ℝ) ^ k) ^ θ := hV_global _ hk_ge
            _ = C * (x ^ θ * r ^ k) := by rw [hpow_eq]
      have hgeom : ∑ k ∈ Finset.range K, r ^ k ≤ 1 / (1 - r) := by
        rw [geom_sum_eq hr_lt.ne]
        have hnum : 1 - r ^ K ≤ 1 := sub_le_self 1 (pow_nonneg hr_pos.le _)
        have hden : 0 < 1 - r := sub_pos.mpr hr_lt
        rw [← neg_sub (1 : ℝ) (r ^ K), ← neg_sub (1 : ℝ) r, neg_div_neg_eq]
        exact div_le_div_of_nonneg_right hnum hden.le
      calc ‖∑ k ∈ Finset.range K, twistedV χ (x / (2 : ℝ) ^ k)‖
          ≤ ∑ k ∈ Finset.range K, C * (x ^ θ * r ^ k) := hsum_le
        _ = C * x ^ θ * ∑ k ∈ Finset.range K, r ^ k := by
            simp_rw [← Finset.mul_sum, mul_assoc]
        _ ≤ C * x ^ θ * (1 / (1 - r)) :=
            mul_le_mul_of_nonneg_left hgeom (mul_nonneg hC_pos.le (Real.rpow_nonneg hx _))
        _ = C_S6 * x ^ θ := by dsimp [C_S6]; ring
  refine isBigO_iff.mpr ⟨4 * C_S6, ?_⟩
  filter_upwards [eventually_ge_atTop (6 : ℝ)] with x hx6
  have hx0 : 0 ≤ x := by linarith
  have hx1 : 1 ≤ x := by linarith
  rw [twistedMertens_eq_restore_2_3 χ x]
  have hn (d : ℝ) (hd : 1 ≤ d) : ‖twistedS6 χ (x / d)‖ ≤ C_S6 * x ^ θ := by
    have h0 : 0 ≤ x / d := div_nonneg hx0 (by linarith)
    have hle : max (x / d) 1 ≤ x := max_le (div_le_self hx0 hd) hx1
    calc ‖twistedS6 χ (x / d)‖
        ≤ C_S6 * (max (x / d) 1) ^ θ := hS6_bound (x / d) h0
      _ ≤ C_S6 * x ^ θ := by
          have hCS : 0 ≤ C_S6 := div_nonneg hC_pos.le (sub_nonneg.mpr hr_lt.le)
          exact mul_le_mul_of_nonneg_left (Real.rpow_le_rpow (by positivity) hle hθ_pos.le) hCS
  have hc2 : ‖χ 2‖ ≤ 1 := χ.norm_le_one 2
  have hc3 : ‖χ 3‖ ≤ 1 := χ.norm_le_one 3
  have hnorm_rhs : ‖x ^ θ‖ = x ^ θ := Real.norm_of_nonneg (Real.rpow_nonneg hx0 _)
  rw [hnorm_rhs]
  calc ‖twistedS6 χ x - χ 2 * twistedS6 χ (x / 2) - χ 3 * twistedS6 χ (x / 3)
          + χ 2 * χ 3 * twistedS6 χ (x / 6)‖
      ≤ ‖twistedS6 χ x‖ + ‖χ 2 * twistedS6 χ (x / 2)‖ + ‖χ 3 * twistedS6 χ (x / 3)‖
          + ‖χ 2 * χ 3 * twistedS6 χ (x / 6)‖ := by
          have t1 := norm_add_le (twistedS6 χ x - χ 2 * twistedS6 χ (x / 2) - χ 3 * twistedS6 χ (x / 3))
            (χ 2 * χ 3 * twistedS6 χ (x / 6))
          have t2 := norm_sub_le (twistedS6 χ x - χ 2 * twistedS6 χ (x / 2)) (χ 3 * twistedS6 χ (x / 3))
          have t3 := norm_sub_le (twistedS6 χ x) (χ 2 * twistedS6 χ (x / 2))
          linarith
    _ ≤ C_S6 * x ^ θ + 1 * (C_S6 * x ^ θ) + 1 * (C_S6 * x ^ θ) + (1 * 1) * (C_S6 * x ^ θ) := by
          have h1 : ‖twistedS6 χ x‖ ≤ C_S6 * x ^ θ := by simpa using hn 1 le_rfl
          have h2 : ‖χ 2 * twistedS6 χ (x / 2)‖ ≤ 1 * (C_S6 * x ^ θ) := by
            rw [norm_mul]; exact mul_le_mul hc2 (hn 2 (by norm_num)) (norm_nonneg _) zero_le_one
          have h3 : ‖χ 3 * twistedS6 χ (x / 3)‖ ≤ 1 * (C_S6 * x ^ θ) := by
            rw [norm_mul]; exact mul_le_mul hc3 (hn 3 (by norm_num)) (norm_nonneg _) zero_le_one
          have h4 : ‖χ 2 * χ 3 * twistedS6 χ (x / 6)‖ ≤ (1 * 1) * (C_S6 * x ^ θ) := by
            rw [norm_mul, norm_mul]
            exact mul_le_mul (mul_le_mul hc2 hc3 (norm_nonneg _) zero_le_one)
              (hn 6 (by norm_num)) (norm_nonneg _) (by norm_num)
          linarith
    _ = 4 * C_S6 * x ^ θ := by ring

theorem mertensCancellation_of_VCancellation (hV : VCancellation) : MertensCancellation :=
  twistedMertensCancellation_of_twistedVCancellation hV

/-! ### 4. Farey First-Harmonic Taylor Lemma & Conditional Bridge -/

private lemma one_sub_cos_eq_two_mul_sin_sq (t : ℝ) :
    1 - Real.cos t = 2 * Real.sin (t / 2) ^ 2 := by
  have hcos : Real.cos t = Real.cos (t / 2 + t / 2) := by ring_nf
  rw [hcos, Real.cos_add]
  have hpy : Real.cos (t / 2) ^ 2 + Real.sin (t / 2) ^ 2 = 1 := Real.cos_sq_add_sin_sq (t / 2)
  linarith

/-- Exact Taylor bound used in Astra's Farey first-harmonic reduction:
    `|exp(i θ) - 1 - i θ| ≤ θ^2 / 2` for every real `θ`. -/
theorem norm_cexp_I_mul_sub_one_sub_I_mul_le (θ : ℝ) :
    ‖Complex.exp (Complex.I * θ) - 1 - Complex.I * θ‖ ≤ θ ^ 2 / 2 := by
  let g : ℝ → ℝ := fun t => t ^ 4 / 4 - ((Real.cos t - 1) ^ 2 + (Real.sin t - t) ^ 2)
  have hsq (t : ℝ) :
      ‖Complex.exp (Complex.I * t) - 1 - Complex.I * t‖ ^ 2 =
        (Real.cos t - 1) ^ 2 + (Real.sin t - t) ^ 2 := by
    have hre : (Complex.exp (Complex.I * t) - 1 - Complex.I * t).re = Real.cos t - 1 := by
      rw [mul_comm Complex.I (t : ℂ), Complex.exp_mul_I]
      simp [Complex.cos_ofReal_re, Complex.sin_ofReal_re]
    have him : (Complex.exp (Complex.I * t) - 1 - Complex.I * t).im = Real.sin t - t := by
      rw [mul_comm Complex.I (t : ℂ), Complex.exp_mul_I]
      simp [Complex.sin_ofReal_re]
    rw [← hre, ← him, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply]
    ring
  have hderiv (t : ℝ) :
      HasDerivAt g (t * (t ^ 2 - 4 * Real.sin (t / 2) ^ 2)) t := by
    have h1 : HasDerivAt (fun u : ℝ => u ^ 4 / 4) (t ^ 3) t := by
      have hp := (hasDerivAt_id t).pow 4
      have hdiv : HasDerivAt (fun u : ℝ => u ^ 4 / 4) ((4 : ℝ) * t ^ 3 / 4) t := by
        simpa using hp.div_const 4
      convert hdiv using 1
      ring
    have h2 : HasDerivAt (fun u : ℝ => Real.cos u - 1) (-Real.sin t) t :=
      (Real.hasDerivAt_cos t).sub_const 1
    have h3 : HasDerivAt (fun u : ℝ => Real.sin u - u) (Real.cos t - 1) t :=
      (Real.hasDerivAt_sin t).sub (hasDerivAt_id t)
    have h2sq : HasDerivAt (fun u : ℝ => (Real.cos u - 1) ^ 2)
        (2 * (Real.cos t - 1) * (-Real.sin t)) t := by
      have hm := h2.mul h2
      have heq : (fun u : ℝ => (Real.cos u - 1) ^ 2) = fun u => (Real.cos u - 1) * (Real.cos u - 1) := by
        ext u; ring
      rw [heq]
      convert hm using 1
      all_goals first | ring1 | rfl
    have h3sq : HasDerivAt (fun u : ℝ => (Real.sin u - u) ^ 2)
        (2 * (Real.sin t - t) * (Real.cos t - 1)) t := by
      have hm := h3.mul h3
      have heq : (fun u : ℝ => (Real.sin u - u) ^ 2) = fun u => (Real.sin u - u) * (Real.sin u - u) := by
        ext u; ring
      rw [heq]
      convert hm using 1
      all_goals first | ring1 | rfl
    convert h1.sub (h2sq.add h3sq) using 1
    all_goals first | linear_combination 2 * t * one_sub_cos_eq_two_mul_sin_sq t | rfl
  have hg_nonneg_nonneg : ∀ t : ℝ, 0 ≤ t → 0 ≤ g t := by
    intro t ht
    have hmono : MonotoneOn g (Set.Ici 0) := by
      refine monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ici 0)
        (fun x _ => (hderiv x).continuousAt.continuousWithinAt)
        (fun x _ => (hderiv x).hasDerivWithinAt) ?_
      intro x hx
      have hx0 : 0 ≤ x := interior_subset hx
      have hsq_sin : Real.sin (x / 2) ^ 2 ≤ (x / 2) ^ 2 := Real.sin_sq_le_sq
      have h4 : 0 ≤ x ^ 2 - 4 * Real.sin (x / 2) ^ 2 := by linarith
      exact mul_nonneg hx0 h4
    have hg0 : g 0 = 0 := by simp [g]
    rw [← hg0]
    exact hmono (Set.mem_Ici.mpr le_rfl) (Set.mem_Ici.mpr ht) ht
  have hg_nonneg : 0 ≤ g θ := by
    rcases le_total 0 θ with hpos | hneg
    · exact hg_nonneg_nonneg θ hpos
    · have hneg' := hg_nonneg_nonneg (-θ) (neg_nonneg.mpr hneg)
      have heven : g (-θ) = g θ := by
        simp [g, Real.cos_neg, Real.sin_neg]
        ring
      rwa [heven] at hneg'
  have hsq_le : ‖Complex.exp (Complex.I * θ) - 1 - Complex.I * θ‖ ^ 2 ≤ (θ ^ 2 / 2) ^ 2 := by
    rw [hsq θ]
    have : θ ^ 4 / 4 = (θ ^ 2 / 2) ^ 2 := by ring
    dsimp [g] at hg_nonneg
    linarith
  have habs := abs_le_of_sq_le_sq' hsq_le (by positivity)
  simpa [abs_of_nonneg (norm_nonneg _)] using habs.2

/-- If `H : ℕ → ℂ` stays within a constant `B` of `M(N)` and satisfies `H(N) = O_ε(N^(1/2+ε))`,
    then `MertensCancellation` holds. -/
theorem mertensCancellation_of_bounded_approx (H : ℕ → ℂ)
    (hdiff : ∃ B : ℝ, ∀ n : ℕ, 2 ≤ n → ‖mertens n - H n‖ ≤ B)
    (hH : ∀ ε : ℝ, 0 < ε → H =O[atTop] (fun n : ℕ => (n : ℝ) ^ ((1 / 2 : ℝ) + ε))) :
    MertensCancellation := by
  intro ε hε
  obtain ⟨B, hB⟩ := hdiff
  obtain ⟨C, hC_pos, hC⟩ := (hH ε hε).exists_pos
  obtain ⟨N₀, hN₀⟩ := eventually_atTop.mp hC.bound
  let N₁ := max N₀ 2
  refine isBigO_iff.mpr ⟨C + max B 0 + 1, ?_⟩
  filter_upwards [eventually_ge_atTop (N₁ : ℝ)] with x hx
  have hx0 : 0 ≤ x := by linarith [(show (0 : ℝ) ≤ N₁ by positivity)]
  have hfloor_ge : N₁ ≤ ⌊x⌋₊ := Nat.le_floor hx
  have hfloor_ge_2 : 2 ≤ ⌊x⌋₊ := le_trans (le_max_right _ _) hfloor_ge
  have hfloor_ge_N0 : N₀ ≤ ⌊x⌋₊ := le_trans (le_max_left _ _) hfloor_ge
  have hM_eq : mertens x = mertens (⌊x⌋₊ : ℕ) := by
    simp [mertens, twistedMertens, Nat.floor_natCast]
  have hH_n := hN₀ ⌊x⌋₊ hfloor_ge_N0
  have hpow_floor : (⌊x⌋₊ : ℝ) ^ ((1 / 2 : ℝ) + ε) ≤ x ^ ((1 / 2 : ℝ) + ε) :=
    Real.rpow_le_rpow (Nat.cast_nonneg _) (Nat.floor_le hx0) (by linarith)
  have hnorm_H : ‖H ⌊x⌋₊‖ ≤ C * x ^ ((1 / 2 : ℝ) + ε) := by
    have hrn : ‖((⌊x⌋₊ : ℝ) ^ ((1 / 2 : ℝ) + ε))‖ = (⌊x⌋₊ : ℝ) ^ ((1 / 2 : ℝ) + ε) :=
      Real.norm_of_nonneg (Real.rpow_nonneg (Nat.cast_nonneg _) _)
    rw [hrn] at hH_n
    exact hH_n.trans (mul_le_mul_of_nonneg_left hpow_floor hC_pos.le)
  have h1x : 1 ≤ x ^ ((1 / 2 : ℝ) + ε) :=
    Real.one_le_rpow
      (by
        have h2N : (2 : ℝ) ≤ N₁ := by exact_mod_cast le_max_right N₀ 2
        linarith)
      (by linarith)
  have hB0 : 0 ≤ max B 0 := le_max_right B 0
  have hB_le : max B 0 ≤ max B 0 * x ^ ((1 / 2 : ℝ) + ε) :=
    le_mul_of_one_le_right hB0 h1x
  have hdiff_n := hB ⌊x⌋₊ hfloor_ge_2
  rw [Real.norm_of_nonneg (Real.rpow_nonneg hx0 _)]
  calc ‖mertens x‖ = ‖(mertens (⌊x⌋₊ : ℕ) - H ⌊x⌋₊) + H ⌊x⌋₊‖ := by rw [hM_eq]; ring_nf
    _ ≤ ‖mertens (⌊x⌋₊ : ℕ) - H ⌊x⌋₊‖ + ‖H ⌊x⌋₊‖ := norm_add_le _ _
    _ ≤ max B 0 + C * x ^ ((1 / 2 : ℝ) + ε) :=
        add_le_add (hdiff_n.trans (le_max_left _ _)) hnorm_H
    _ ≤ max B 0 * x ^ ((1 / 2 : ℝ) + ε) + C * x ^ ((1 / 2 : ℝ) + ε) :=
        add_le_add hB_le le_rfl
    _ ≤ (C + max B 0 + 1) * x ^ ((1 / 2 : ℝ) + ε) := by nlinarith [h1x]

/-! ### 5. Mellin Continuation -> Zero-Free Half-Plane -> `EveryCharacter` & `RiemannHypothesis` -/

private def cutTwistedMertens {N : ℕ} (χ : DirichletCharacter ℂ N) : ℝ → ℂ :=
  (Set.Ioi (1 : ℝ)).indicator (twistedMertens χ)

/-- Mellin representation `s * ∫_1^∞ M_χ(x) x^{-(s+1)} dx` of `1 / L(s, χ)`. -/
def twistedReciprocal {N : ℕ} (χ : DirichletCharacter ℂ N) (s : ℂ) : ℂ :=
  s * mellin (cutTwistedMertens χ) (-s)

private lemma cutTwisted_local {N : ℕ} (χ : DirichletCharacter ℂ N) :
    LocallyIntegrableOn (cutTwistedMertens χ) (Set.Ioi 0) := by
  have h : LocallyIntegrableOn (twistedMertens χ) (Set.Ici 0) := by
    unfold twistedMertens
    simpa only [one_mul] using (locallyIntegrableOn_mul_sum_Icc (m := 1) (twistedCoeff χ)
      (a := (0 : ℝ)) le_rfl (locallyIntegrableOn_const (1 : ℂ)))
  intro x hx
  obtain ⟨U, hU, hI⟩ := h.mono_set Set.Ioi_subset_Ici_self x hx
  exact ⟨U, hU, hI.indicator measurableSet_Ioi⟩

private lemma cutTwisted_growth {N : ℕ} {χ : DirichletCharacter ℂ N}
    (hM : TwistedMertensCancellation χ) {ε : ℝ} (hε : 0 < ε) :
    cutTwistedMertens χ =O[atTop] (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε)) := by
  obtain ⟨C, hC⟩ := isBigO_iff.mp (hM ε hε)
  refine isBigO_iff.mpr ⟨C, ?_⟩
  filter_upwards [eventually_gt_atTop (1 : ℝ), hC] with x hx hc
  simpa only [cutTwistedMertens, Set.indicator_of_mem (Set.mem_Ioi.mpr hx)] using hc

theorem twistedReciprocal_analytic {N : ℕ} {χ : DirichletCharacter ℂ N}
    (hM : TwistedMertensCancellation χ) :
    AnalyticOnNhd ℂ (twistedReciprocal χ) {s : ℂ | (1 / 2 : ℝ) < s.re} := by
  apply DifferentiableOn.analyticOnNhd _ (isOpen_lt continuous_const Complex.continuous_re)
  intro s hs
  change (1 / 2 : ℝ) < s.re at hs
  let ε : ℝ := (s.re - 1 / 2) / 2
  have hε : 0 < ε := by dsimp [ε]; linarith
  let b := -s.re - 1
  have htop : cutTwistedMertens χ =O[atTop] (fun x : ℝ => x ^ (-(-(1 / 2 + ε)))) := by
    simpa only [neg_neg] using cutTwisted_growth hM hε
  have hbot : cutTwistedMertens χ =O[𝓝[>] (0 : ℝ)] (fun x : ℝ => x ^ (-b)) := by
    refine isBigO_iff.mpr ⟨0, ?_⟩
    have hh : ∀ᶠ x in 𝓝[>] (0 : ℝ), x < 1 :=
      (eventually_lt_nhds (by norm_num : (0 : ℝ) < 1)).filter_mono nhdsWithin_le_nhds
    filter_upwards [hh] with x hx
    simp [cutTwistedMertens, not_lt.mpr hx.le]
  have hd := mellin_differentiableAt_of_isBigO_rpow (s := -s) (cutTwisted_local χ) htop
    (by change -s.re < -(1 / 2 + ε); dsimp [ε]; linarith) hbot
    (by change -s.re - 1 < -s.re; linarith)
  exact (differentiableAt_id.mul (hd.comp s differentiableAt_id.neg)).differentiableWithinAt

private lemma mellin_cutTwisted_eq {N : ℕ} (χ : DirichletCharacter ℂ N) (s : ℂ) :
    mellin (cutTwistedMertens χ) (-s) =
      ∫ x in Set.Ioi (1 : ℝ), twistedMertens χ x * (x : ℂ) ^ (-(s + 1)) := by
  unfold mellin
  have he (x : ℝ) : (x : ℂ) ^ (-s - 1) • cutTwistedMertens χ x =
      (Set.Ioi (1 : ℝ)).indicator (fun x : ℝ => twistedMertens χ x * (x : ℂ) ^ (-(s + 1))) x := by
    by_cases hx : x ∈ Set.Ioi (1 : ℝ)
    · simp only [cutTwistedMertens, Set.indicator_of_mem hx, smul_eq_mul,
        show -s - 1 = -(s + 1) by ring, mul_comm]
    · simp [cutTwistedMertens, Set.indicator_of_notMem hx]
  simp_rw [he]
  rw [setIntegral_indicator measurableSet_Ioi,
    Set.inter_eq_right.mpr (Set.Ioi_subset_Ioi (by norm_num))]

theorem twistedReciprocal_euler {N : ℕ} [NeZero N] {χ : DirichletCharacter ℂ N}
    (hM : TwistedMertensCancellation χ) {s : ℂ} (hs : 1 < s.re) :
    DirichletCharacter.LFunction χ s * twistedReciprocal χ s = 1 := by
  have ho := (hM (1 / 2) (by norm_num)).comp_tendsto
    (tendsto_natCast_atTop_atTop : Tendsto (fun n : ℕ => (n : ℝ)) atTop atTop)
  have hn : (fun n : ℕ => ∑ k ∈ Finset.Icc 1 n, twistedCoeff χ k) =O[atTop]
      (fun n : ℕ => (n : ℝ) ^ (1 : ℝ)) := by
    change (fun n : ℕ => twistedMertens χ (n : ℝ)) =O[atTop]
      (fun n : ℕ => (n : ℝ) ^ ((1 / 2 : ℝ) + 1 / 2)) at ho
    rw [show (1 / 2 : ℝ) + 1 / 2 = 1 by norm_num] at ho
    simpa only [twistedMertens, Nat.floor_natCast] using ho
  have hconv : LSeriesSummable (twistedCoeff χ) s := by
    have hmu : LSeriesSummable (↗χ * ↗μ) s :=
      DirichletCharacter.LSeriesSummable_mul χ
        (ArithmeticFunction.LSeriesSummable_moebius_iff.mpr hs)
    simpa only [← twistedCoeff_eq_LSeries_mul] using hmu
  have hi := LSeries_eq_mul_integral (twistedCoeff χ) (by norm_num : (0 : ℝ) ≤ 1) hs hconv hn
  have hEq : LSeries (twistedCoeff χ) s = twistedReciprocal χ s := by
    rw [twistedReciprocal, mellin_cutTwisted_eq]
    exact hi
  rw [← hEq, twistedCoeff_eq_LSeries_mul χ, DirichletCharacter.LFunction_eq_LSeries χ hs]
  exact DirichletCharacter.LSeries.mul_mu_eq_one χ hs

private def regularizedLTriv (N : ℕ) [NeZero N] : ℂ → ℂ :=
  Function.update (fun t : ℂ => (t - 1) * DirichletCharacter.LFunctionTrivChar N t) 1
    (∏ p ∈ N.primeFactors, (1 - (p : ℂ)⁻¹))

private lemma regularizedLTriv_germ (N : ℕ) [NeZero N] {s : ℂ} (hs : s ≠ 1) :
    regularizedLTriv N =ᶠ[nhds s] fun t => (t - 1) * DirichletCharacter.LFunctionTrivChar N t := by
  filter_upwards [eventually_ne_nhds hs] with t ht
  exact Function.update_of_ne ht ..

private lemma regularizedLTriv_analytic (N : ℕ) [NeZero N] (s : ℂ) :
    AnalyticAt ℂ (regularizedLTriv N) s := by
  have away : ∀ t : ℂ, t ≠ 1 → AnalyticAt ℂ (regularizedLTriv N) t := by
    intro t ht
    have hdiff : DifferentiableOn ℂ (DirichletCharacter.LFunctionTrivChar N) {z : ℂ | z ≠ 1} :=
      fun z hz => (DirichletCharacter.differentiableAt_LFunction 1 z (Or.inl hz)).differentiableWithinAt
    have han : AnalyticAt ℂ (DirichletCharacter.LFunctionTrivChar N) t :=
      (hdiff.analyticOnNhd isOpen_ne) t ht
    exact (((analyticAt_id.sub analyticAt_const).mul han).congr (regularizedLTriv_germ N ht).symm)
  rcases eq_or_ne s 1 with rfl | hs
  · apply Complex.analyticAt_of_differentiable_on_punctured_nhds_of_continuousAt
    · filter_upwards [self_mem_nhdsWithin] with t ht using (away t ht).differentiableAt
    · simpa only [regularizedLTriv, continuousAt_update_same] using
        DirichletCharacter.LFunctionTrivChar_residue_one (N := N)
  · exact away s hs

/-- Analytic continuation of `1 / L(s, χ)` rules out zeros in `Re s > 1/2`. -/
theorem LFunction_ne_zero_of_twistedMertensCancellation {N : ℕ} [NeZero N]
    {χ : DirichletCharacter ℂ N} (hM : TwistedMertensCancellation χ) :
    ∀ s : ℂ, (1 / 2 : ℝ) < s.re → (χ ≠ 1 ∨ s ≠ 1) → DirichletCharacter.LFunction χ s ≠ 0 := by
  let H : Set ℂ := {s | (1 / 2 : ℝ) < s.re}
  have hconn : IsPreconnected H := (convex_halfSpace_re_gt (1 / 2)).isPreconnected
  have h2 : (2 : ℂ) ∈ H := by norm_num [H]
  have hb : {s : ℂ | 1 < s.re} ∈ 𝓝 (2 : ℂ) :=
    (isOpen_lt continuous_const Complex.continuous_re).mem_nhds (by norm_num)
  by_cases hχ : χ = 1
  · subst hχ
    intro s hs hne
    have hs1 : s ≠ 1 := hne.resolve_left (fun h => h rfl)
    have hA : AnalyticOnNhd ℂ (regularizedLTriv N * twistedReciprocal 1) H :=
      fun z hz => (regularizedLTriv_analytic N z).mul (twistedReciprocal_analytic hM z hz)
    have hB : AnalyticOnNhd ℂ (fun s : ℂ => s - 1) H :=
      fun _ _ => analyticAt_id.sub analyticAt_const
    have he : regularizedLTriv N * twistedReciprocal (1 : DirichletCharacter ℂ N) =ᶠ[𝓝 (2 : ℂ)]
        (fun s : ℂ => s - 1) := by
      filter_upwards [hb] with z hz
      have hz1 : z ≠ 1 := by intro h; simp [h] at hz
      change regularizedLTriv N z * twistedReciprocal 1 z = z - 1
      rw [(regularizedLTriv_germ N hz1).eq_of_nhds, mul_assoc]
      change (z - 1) * (DirichletCharacter.LFunctionTrivChar N z * twistedReciprocal 1 z) = z - 1
      rw [DirichletCharacter.LFunctionTrivChar, twistedReciprocal_euler hM hz, mul_one]
    have hall := hA.eqOn_of_preconnected_of_eventuallyEq hB hconn h2 he
    intro hz
    have h := hall (show s ∈ H from hs)
    change regularizedLTriv N s * twistedReciprocal 1 s = s - 1 at h
    rw [(regularizedLTriv_germ N hs1).eq_of_nhds] at h
    change (s - 1) * DirichletCharacter.LFunctionTrivChar N s * twistedReciprocal 1 s = s - 1 at h
    have hz' : DirichletCharacter.LFunctionTrivChar N s = 0 := hz
    rw [hz', mul_zero, zero_mul] at h
    exact (sub_ne_zero.mpr hs1) h.symm
  · intro s hs _
    have hopen : IsOpen H := isOpen_lt continuous_const Complex.continuous_re
    have hanL : AnalyticOnNhd ℂ (DirichletCharacter.LFunction χ) H :=
      (DirichletCharacter.differentiable_LFunction hχ).differentiableOn.analyticOnNhd hopen
    have hA : AnalyticOnNhd ℂ (DirichletCharacter.LFunction χ * twistedReciprocal χ) H :=
      fun z hz => (hanL z hz).mul (twistedReciprocal_analytic hM z hz)
    have hB : AnalyticOnNhd ℂ (fun _ : ℂ => (1 : ℂ)) H := fun _ _ => analyticAt_const
    have he : DirichletCharacter.LFunction χ * twistedReciprocal χ =ᶠ[𝓝 (2 : ℂ)] (fun _ => (1 : ℂ)) := by
      filter_upwards [hb] with z hz
      exact twistedReciprocal_euler hM hz
    have hall := hA.eqOn_of_preconnected_of_eventuallyEq hB hconn h2 he
    intro hz
    have h := hall (show s ∈ H from hs)
    change DirichletCharacter.LFunction χ s * twistedReciprocal χ s = 1 at h
    rw [hz, zero_mul] at h
    exact one_ne_zero h.symm

/-- Replacing `allChi` (`EveryCharacter`): uniform sub-exponent twisted crystal-slab bounds
    across all moduli and Dirichlet characters imply `EveryCharacter`. -/
theorem everyCharacter_of_allChi_V_cancellation (hAll : AllChiVCancellation) : EveryCharacter := by
  intro N hN χ s hs hne
  exact LFunction_ne_zero_of_twistedMertensCancellation
    (twistedMertensCancellation_of_twistedVCancellation (hAll N χ)) s hs hne

/-- Functional-equation closure (`RhOfRight.lean` + `CritLine.lean`): right-half-plane
    nonvanishing of `ζ` implies `RiemannHypothesis`. -/
theorem riemannHypothesis_of_right_zero_free
    (hz : ∀ s : ℂ, (1 / 2 : ℝ) < s.re → s ≠ 1 → riemannZeta s ≠ 0) : RiemannHypothesis := by
  unfold RiemannHypothesis
  intro s hs htriv hs1
  rcases lt_trichotomy s.re (1 / 2) with hlt | heq | hgt
  · exfalso
    have hpi : (Real.pi : ℂ) ≠ 0 := by exact_mod_cast Real.pi_ne_zero
    have hs0 : s ≠ 0 := by
      rintro rfl
      rw [riemannZeta_zero] at hs
      norm_num at hs
    have ht : 1 / 2 < (1 - s).re := by
      rw [Complex.sub_re, Complex.one_re]
      linarith
    have h1 : (1 - s) ≠ 1 := by
      intro h
      apply hs0
      linear_combination -h
    have hnat : ∀ n : ℕ, (1 - s) ≠ -(n : ℂ) := by
      intro n h
      have hr := congrArg Complex.re h
      rw [Complex.sub_re, Complex.one_re, Complex.neg_re, Complex.natCast_re] at hr
      have : (0 : ℝ) ≤ n := n.cast_nonneg
      linarith
    have key := riemannZeta_one_sub hnat h1
    rw [sub_sub_cancel, hs] at key
    have hz' := hz (1 - s) ht h1
    have h2pi : (2 : ℂ) * (2 * (Real.pi : ℂ)) ^ (-(1 - s)) ≠ 0 :=
      mul_ne_zero two_ne_zero (Complex.cpow_ne_zero_iff.2 (Or.inl (mul_ne_zero two_ne_zero hpi)))
    have hG : Complex.Gamma (1 - s) ≠ 0 := Complex.Gamma_ne_zero_of_re_pos (by linarith)
    have hcos : Complex.cos ((Real.pi : ℂ) * (1 - s) / 2) ≠ 0 := by
      rw [Ne, Complex.cos_eq_zero_iff]
      rintro ⟨k, hk⟩
      have h3 : ((1 - s) - (2 * (k : ℂ) + 1)) * (Real.pi : ℂ) = 0 := by
        linear_combination 2 * hk
      rcases mul_eq_zero.1 h3 with h | h
      · have hsk : s = -2 * (k : ℂ) := by linear_combination -h
        have hre : s.re = -2 * (k : ℝ) := by
          rw [hsk, Complex.mul_re]
          simp
        rcases lt_trichotomy k 0 with hk0 | hk0 | hk0
        · have : (k : ℝ) ≤ -1 := by exact_mod_cast (show k ≤ -1 by omega)
          linarith
        · apply hs0
          rw [hsk, hk0]
          simp
        · apply htriv
          refine ⟨(k - 1).toNat, ?_⟩
          have hnk : ((k - 1).toNat : ℤ) = k - 1 := Int.toNat_of_nonneg (by omega)
          have h' : (((k - 1).toNat : ℕ) : ℂ) = (k : ℂ) - 1 := by
            have := congrArg (fun m : ℤ => (m : ℂ)) hnk
            push_cast at this
            exact this
          rw [hsk, h']
          ring
      · exact hpi h
    exact (mul_ne_zero (mul_ne_zero (mul_ne_zero h2pi hG) hcos) hz') key.symm
  · exact heq
  · exact absurd hs (hz s hgt hs1)

/-- Exact analogue of `Formalism.VW.rh_of_every` (`CritLine.lean:29–32`), specializing
    `EveryCharacter` to modulus `1`, character `1`. -/
theorem riemannHypothesis_of_everyCharacter (h : EveryCharacter) : RiemannHypothesis :=
  riemannHypothesis_of_right_zero_free fun s hs hs1 => by
    have := h 1 (1 : DirichletCharacter ℂ 1) s hs (Or.inr hs1)
    rwa [DirichletCharacter.LFunction_modOne_eq] at this

/-- Main ordinary-RH bridge: untwisted (`χ = 1`) crystal-slab cancellation `V(x) = O_ε(x^(1/2+ε))`
    implies `RiemannHypothesis` directly (without requiring general `χ`). -/
theorem riemannHypothesis_of_V_cancellation (hV : VCancellation) : RiemannHypothesis := by
  refine riemannHypothesis_of_right_zero_free fun s hs hs1 => ?_
  have hL := LFunction_ne_zero_of_twistedMertensCancellation
    (mertensCancellation_of_VCancellation hV) s hs (Or.inr hs1)
  rwa [DirichletCharacter.LFunction_modOne_eq] at hL

/-- Farey first-harmonic RH bridge: any `H : ℕ → ℂ` within `O(1)` of `M(N)` (such as
    `H_1(N)` under `|M(N) - H_1(N)| ≤ 2π² ∑ δ_j² = O(1)`) implies `RiemannHypothesis`
    once `H(N) = O_ε(N^(1/2+ε))`. -/
theorem riemannHypothesis_of_farey_approx (H : ℕ → ℂ)
    (hdiff : ∃ B : ℝ, ∀ n : ℕ, 2 ≤ n → ‖mertens n - H n‖ ≤ B)
    (hH : ∀ ε : ℝ, 0 < ε → H =O[atTop] (fun n : ℕ => (n : ℝ) ^ ((1 / 2 : ℝ) + ε))) :
    RiemannHypothesis := by
  refine riemannHypothesis_of_right_zero_free fun s hs hs1 => ?_
  have hL := LFunction_ne_zero_of_twistedMertensCancellation
    (mertensCancellation_of_bounded_approx H hdiff hH) s hs (Or.inr hs1)
  rwa [DirichletCharacter.LFunction_modOne_eq] at hL

end Ratioque.CrystalBridge

#print axioms Ratioque.CrystalBridge.twistedMertens_eq_restore_2_3
#print axioms Ratioque.CrystalBridge.mertens_eq_V_sub_V_div_three
#print axioms Ratioque.CrystalBridge.norm_cexp_I_mul_sub_one_sub_I_mul_le
#print axioms Ratioque.CrystalBridge.riemannHypothesis_of_V_cancellation
#print axioms Ratioque.CrystalBridge.riemannHypothesis_of_farey_approx
#print axioms Ratioque.CrystalBridge.everyCharacter_of_allChi_V_cancellation
#print axioms Ratioque.CrystalBridge.riemannHypothesis_of_everyCharacter
