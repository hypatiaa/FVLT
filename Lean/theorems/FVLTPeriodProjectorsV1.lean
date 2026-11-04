import Ruliology.CellularAutomata.Rule30Prize
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Sigma
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Data.Finset.Card
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic.Common
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Linarith

open scoped BigOperators

namespace Ruliology.CellularAutomata.FVLTPeriodProjectorsV1

/-!
# FVLT-H1 Milestone A: General Period-Projection Operators `Q_m`

For arbitrary `N > 0`, finite signals `x : Nat → K` (over any field `K : Type` of characteristic zero,
supporting `ℚ`, `ℝ`, and `ℂ`), and any divisor `m ∣ N`, we define the residue-average operator:

  `(Q N m x) t = ((N / m : Nat) : K)⁻¹ * ∑ j ∈ Finset.range (N / m), x ((t + j * m) % N)`

and prove:
1. Equivalence to the canonical quotient-remainder sum and the residue-class filter sum over `Finset.range N`.
2. Linearity (`Q_add`, `Q_smul`, `Q_sub`, `Q_zero`, `Q_linear_comb`).
3. Self-adjointness under the complete-residue SUM inner product (`Q_selfAdjoint_sumInner`) and
   any ring-involution sesquilinear SUM inner product (`Q_selfAdjoint_sesqInner`).
4. Projection onto `m`-periodic signals in both directions (`Q_periodic`, `Q_eq_self_of_periodic`,
   `Q_fixpoint_iff_periodic`, and window-periodic counterparts).
5. Idempotence `Q_m (Q_m x) = Q_m x`, `Q_N = id` (modulo `N` / on `0..N-1`), and `Q_1 = mean`.
6. Semigroup law `Q_m (Q_n x) = Q_{gcd(m, n)} x` for all `m ∣ N` and `n ∣ N`.
-/

/-- The residue class `{s ∈ {0, ..., N-1} | s % m = t % m}`. -/
def resSet (N m t : Nat) : Finset Nat :=
  (Finset.range N).filter (fun s => s % m = t % m)

lemma pos_of_dvd_of_pos {N m : Nat} (hN : 0 < N) (hm : m ∣ N) : 0 < m := by
  rcases Nat.eq_zero_or_pos m with rfl | h
  · simp at hm; omega
  · exact h

lemma div_pos_of_dvd_of_pos {N m : Nat} (hN : 0 < N) (hm : m ∣ N) : 0 < N / m :=
  Nat.div_pos (Nat.le_of_dvd hN hm) (pos_of_dvd_of_pos hN hm)

lemma add_mul_mod_eq_quot_form {N m : Nat} (hN : 0 < N) (hm : m ∣ N) (t j : Nat) :
    (t + j * m) % N = t % m + ((t / m + j) % (N / m)) * m := by
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have hk0 : 0 < N / m := div_pos_of_dvd_of_pos hN hm
  have hN_eq : (N / m) * m = N := Nat.div_mul_cancel hm
  set k := N / m
  set q := t / m + j
  have h_decomp : t + j * m = (t % m + (q % k) * m) + (q / k) * N := by
    have ht : t % m + m * (t / m) = t := Nat.mod_add_div t m
    have hq : q % k + k * (q / k) = q := Nat.mod_add_div q k
    calc t + j * m
      _ = (t % m + m * (t / m)) + j * m := by rw [ht]
      _ = t % m + (t / m + j) * m := by ring
      _ = t % m + (q % k + k * (q / k)) * m := by rw [hq]
      _ = (t % m + (q % k) * m) + (q / k) * ((N / m) * m) := by ring
      _ = (t % m + (q % k) * m) + (q / k) * N := by rw [hN_eq]
  have h_lt : t % m + (q % k) * m < N := by
    have h1 : t % m < m := Nat.mod_lt t hm0
    have h2 : q % k < k := Nat.mod_lt q hk0
    have h3 : (q % k + 1) * m ≤ k * m := Nat.mul_le_mul_right m h2
    linarith
  rw [h_decomp, Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt h_lt]

lemma mod_add_lt_of_ge {k r j : Nat} (hr : r < k) (hj : j < k) (hge : ¬ r + j < k) :
    (r + j) % k = r + j - k := by
  have hlt : r + j - k < k := by omega
  have heq : r + j = (r + j - k) + k := by omega
  calc (r + j) % k
    _ = ((r + j - k) + k) % k := by rw [← heq]
    _ = (r + j - k) % k := Nat.add_mod_right (r + j - k) k
    _ = r + j - k := Nat.mod_eq_of_lt hlt

lemma injOn_add_mod {k : Nat} (hk : 0 < k) (a : Nat) :
    ∀ j1 ∈ Finset.range k, ∀ j2 ∈ Finset.range k,
      (a + j1) % k = (a + j2) % k → j1 = j2 := by
  intro j1 hj1 j2 hj2 hmod
  rw [Finset.mem_range] at hj1 hj2
  have h1 : (a + j1) % k = (a % k + j1) % k := by rw [Nat.add_mod, Nat.mod_eq_of_lt hj1]
  have h2 : (a + j2) % k = (a % k + j2) % k := by rw [Nat.add_mod, Nat.mod_eq_of_lt hj2]
  rw [h1, h2] at hmod
  have ha : a % k < k := Nat.mod_lt a hk
  by_cases c1 : a % k + j1 < k <;> by_cases c2 : a % k + j2 < k
  · rw [Nat.mod_eq_of_lt c1, Nat.mod_eq_of_lt c2] at hmod; omega
  · rw [Nat.mod_eq_of_lt c1, mod_add_lt_of_ge ha hj2 c2] at hmod; omega
  · rw [mod_add_lt_of_ge ha hj1 c1, Nat.mod_eq_of_lt c2] at hmod; omega
  · rw [mod_add_lt_of_ge ha hj1 c1, mod_add_lt_of_ge ha hj2 c2] at hmod; omega

lemma image_add_mod_eq_range {k : Nat} (hk : 0 < k) (a : Nat) :
    (Finset.range k).image (fun j => (a + j) % k) = Finset.range k := by
  apply Finset.eq_of_subset_of_card_le
  · intro q hq
    rcases Finset.mem_image.mp hq with ⟨j, _, rfl⟩
    exact Finset.mem_range.mpr (Nat.mod_lt _ hk)
  · rw [Finset.card_image_of_injOn]
    intro j1 hj1 j2 hj2 hmod
    exact injOn_add_mod hk a j1 hj1 j2 hj2 hmod

lemma sum_range_add_mod {K : Type} [AddCommMonoid K] {k : Nat} (hk : 0 < k) (a : Nat) (f : Nat → K) :
    ∑ j ∈ Finset.range k, f ((a + j) % k) = ∑ q ∈ Finset.range k, f q := by
  have himg := image_add_mod_eq_range hk a
  calc ∑ j ∈ Finset.range k, f ((a + j) % k)
    _ = ∑ q ∈ (Finset.range k).image (fun j => (a + j) % k), f q := by
        rw [Finset.sum_image]
        intro j1 hj1 j2 hj2 hmod
        exact injOn_add_mod hk a j1 hj1 j2 hj2 hmod
    _ = ∑ q ∈ Finset.range k, f q := by rw [himg]

lemma injOn_quot {N m : Nat} (hm : 0 < m) (t : Nat) :
    ∀ q1 ∈ Finset.range (N / m), ∀ q2 ∈ Finset.range (N / m),
      t % m + q1 * m = t % m + q2 * m → q1 = q2 := by
  intro q1 _ q2 _ heq
  have hmul : q1 * m = q2 * m := Nat.add_left_cancel heq
  exact Nat.eq_of_mul_eq_mul_right hm hmul

lemma resSet_eq_image_quot {N m : Nat} (hN : 0 < N) (hm : m ∣ N) (t : Nat) :
    resSet N m t = (Finset.range (N / m)).image (fun q => t % m + q * m) := by
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have hN_eq : (N / m) * m = N := Nat.div_mul_cancel hm
  ext s
  simp only [resSet, Finset.mem_filter, Finset.mem_range, Finset.mem_image]
  constructor
  · rintro ⟨hsN, hsmod⟩
    refine ⟨s / m, ?_, ?_⟩
    · rw [← hN_eq] at hsN
      exact Nat.div_lt_of_lt_mul (by linarith)
    · have hdiv : s % m + m * (s / m) = s := Nat.mod_add_div s m
      rw [← hsmod]
      linarith
  · rintro ⟨q, hq, rfl⟩
    have htm : t % m < m := Nat.mod_lt t hm0
    have hqm : (q + 1) * m ≤ (N / m) * m := Nat.mul_le_mul_right m hq
    refine ⟨by linarith, ?_⟩
    rw [Nat.add_mul_mod_self_right, Nat.mod_mod]

lemma card_resSet {N m : Nat} (hN : 0 < N) (hm : m ∣ N) (t : Nat) :
    (resSet N m t).card = N / m := by
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  rw [resSet_eq_image_quot hN hm t, Finset.card_image_of_injOn]
  · exact Finset.card_range (N / m)
  · intro q1 hq1 q2 hq2 heq
    exact injOn_quot hm0 t q1 hq1 q2 hq2 heq

lemma sum_resSet_eq_sum_quot {K : Type} [AddCommMonoid K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    ∑ s ∈ resSet N m t, x s = ∑ q ∈ Finset.range (N / m), x (t % m + q * m) := by
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  rw [resSet_eq_image_quot hN hm t, Finset.sum_image]
  intro q1 hq1 q2 hq2 heq
  exact injOn_quot hm0 t q1 hq1 q2 hq2 heq

lemma sum_stride_eq_sum_quot {K : Type} [AddCommMonoid K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    ∑ j ∈ Finset.range (N / m), x ((t + j * m) % N) =
      ∑ q ∈ Finset.range (N / m), x (t % m + q * m) := by
  have hk0 : 0 < N / m := div_pos_of_dvd_of_pos hN hm
  have hcongr : ∑ j ∈ Finset.range (N / m), x ((t + j * m) % N) =
      ∑ j ∈ Finset.range (N / m), x (t % m + ((t / m + j) % (N / m)) * m) := by
    refine Finset.sum_congr rfl (fun j _ => ?_)
    rw [add_mul_mod_eq_quot_form hN hm t j]
  rw [hcongr]
  exact sum_range_add_mod hk0 (t / m) (fun q => x (t % m + q * m))

lemma sum_stride_eq_sum_resSet {K : Type} [AddCommMonoid K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    ∑ j ∈ Finset.range (N / m), x ((t + j * m) % N) = ∑ s ∈ resSet N m t, x s := by
  rw [sum_stride_eq_sum_quot hN hm x t, ← sum_resSet_eq_sum_quot hN hm x t]

/-- The residue-average period-projection operator `Q_m` on `Z/NZ` (Milestone A). -/
def Q {K : Type} [Field K] (N m : Nat) (x : Nat → K) (t : Nat) : K :=
  ((N / m : Nat) : K)⁻¹ * ∑ j ∈ Finset.range (N / m), x ((t + j * m) % N)

/-- Equivalence of `Q N m` with the residue-filter average over `Finset.range N`. -/
theorem Q_eq_resSum {K : Type} [Field K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N m x t = ((N / m : Nat) : K)⁻¹ * ∑ s ∈ resSet N m t, x s := by
  unfold Q
  rw [sum_stride_eq_sum_resSet hN hm x t]

/-- Equivalence of `Q N m` with the canonical quotient-remainder fold average. -/
theorem Q_eq_quotSum {K : Type} [Field K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N m x t = ((N / m : Nat) : K)⁻¹ * ∑ q ∈ Finset.range (N / m), x (t % m + q * m) := by
  unfold Q
  rw [sum_stride_eq_sum_quot hN hm x t]

/-! ### 1. Linearity of `Q_m` -/

theorem Q_add {K : Type} [Field K] (N m : Nat) (x y : Nat → K) (t : Nat) :
    Q N m (fun s => x s + y s) t = Q N m x t + Q N m y t := by
  unfold Q
  rw [Finset.sum_add_distrib, mul_add]

theorem Q_smul {K : Type} [Field K] (N m : Nat) (c : K) (x : Nat → K) (t : Nat) :
    Q N m (fun s => c * x s) t = c * Q N m x t := by
  unfold Q
  rw [← Finset.mul_sum, mul_left_comm]

theorem Q_sub {K : Type} [Field K] (N m : Nat) (x y : Nat → K) (t : Nat) :
    Q N m (fun s => x s - y s) t = Q N m x t - Q N m y t := by
  unfold Q
  rw [Finset.sum_sub_distrib, mul_sub]

theorem Q_zero {K : Type} [Field K] (N m : Nat) (t : Nat) :
    Q N m (fun _ => (0 : K)) t = 0 := by
  unfold Q
  simp

theorem Q_linear_comb {K : Type} [Field K] (N m : Nat) (a b : K) (x y : Nat → K) (t : Nat) :
    Q N m (fun s => a * x s + b * y s) t = a * Q N m x t + b * Q N m y t := by
  rw [Q_add, Q_smul, Q_smul]

/-! ### 2. Self-Adjointness for the Complete-Residue SUM Inner Product -/

/-- The complete-residue sum bilinear inner product `∑_{t=0}^{N-1} x(t) y(t)`. -/
def sumInner {K : Type} [CommRing K] (N : Nat) (x y : Nat → K) : K :=
  ∑ t ∈ Finset.range N, x t * y t

/-- The complete-residue sesquilinear sum inner product `∑_{t=0}^{N-1} cnj(x(t)) y(t)`
for any ring endomorphism/involution `cnj : K →+* K` (e.g. complex conjugation on `ℂ`). -/
def sumSesqInner {K : Type} [CommRing K] (cnj : K →+* K) (N : Nat) (x y : Nat → K) : K :=
  ∑ t ∈ Finset.range N, cnj (x t) * y t

lemma sum_resSet_swap {K : Type} [CommSemiring K] (N m : Nat) (f g : Nat → K) :
    ∑ t ∈ Finset.range N, f t * (∑ s ∈ resSet N m t, g s) =
      ∑ s ∈ Finset.range N, (∑ t ∈ resSet N m s, f t) * g s := by
  have h1 : ∀ t, f t * (∑ s ∈ resSet N m t, g s) =
      ∑ s ∈ Finset.range N, if s % m = t % m then f t * g s else 0 := by
    intro t
    rw [Finset.mul_sum, resSet, Finset.sum_filter]
  have h2 : ∀ s, (∑ t ∈ resSet N m s, f t) * g s =
      ∑ t ∈ Finset.range N, if s % m = t % m then f t * g s else 0 := by
    intro s
    rw [Finset.sum_mul, resSet, Finset.sum_filter]
    refine Finset.sum_congr rfl (fun t _ => ?_)
    have hiff : (t % m = s % m) ↔ (s % m = t % m) := eq_comm
    simp only [hiff]
  simp_rw [h1, h2]
  exact Finset.sum_comm

/-- `Q_m` is self-adjoint under the complete-residue SUM inner product. -/
theorem Q_selfAdjoint_sumInner {K : Type} [Field K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x y : Nat → K) :
    sumInner N (Q N m x) y = sumInner N x (Q N m y) := by
  unfold sumInner
  have hx : ∀ t ∈ Finset.range N,
      Q N m x t * y t = ((N / m : Nat) : K)⁻¹ * ((∑ s ∈ resSet N m t, x s) * y t) := by
    intro t _
    rw [Q_eq_resSum hN hm x t, mul_assoc]
  have hy : ∀ t ∈ Finset.range N,
      x t * Q N m y t = ((N / m : Nat) : K)⁻¹ * (x t * ∑ s ∈ resSet N m t, y s) := by
    intro t _
    rw [Q_eq_resSum hN hm y t, mul_left_comm]
  rw [Finset.sum_congr rfl hx, Finset.sum_congr rfl hy, ← Finset.mul_sum, ← Finset.mul_sum]
  rw [sum_resSet_swap N m x y]

/-- `Q_m` is self-adjoint under the sesquilinear SUM inner product for any `cnj : K →+* K`. -/
theorem Q_selfAdjoint_sesqInner {K : Type} [Field K] (cnj : K →+* K) {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x y : Nat → K) :
    sumSesqInner cnj N (Q N m x) y = sumSesqInner cnj N x (Q N m y) := by
  unfold sumSesqInner
  have hx : ∀ t ∈ Finset.range N,
      cnj (Q N m x t) * y t = ((N / m : Nat) : K)⁻¹ * ((∑ s ∈ resSet N m t, cnj (x s)) * y t) := by
    intro t _
    rw [Q_eq_resSum hN hm x t, map_mul, map_inv₀, map_natCast, map_sum, mul_assoc]
  have hy : ∀ t ∈ Finset.range N,
      cnj (x t) * Q N m y t = ((N / m : Nat) : K)⁻¹ * (cnj (x t) * ∑ s ∈ resSet N m t, y s) := by
    intro t _
    rw [Q_eq_resSum hN hm y t, mul_left_comm]
  rw [Finset.sum_congr rfl hx, Finset.sum_congr rfl hy, ← Finset.mul_sum, ← Finset.mul_sum]
  rw [sum_resSet_swap N m (fun s => cnj (x s)) y]

/-! ### 3. Periodicity, Idempotence, `Q_N = id`, and `Q_1 = mean` -/

/-- A signal `x : Nat → α` is `m`-periodic if `x (t + m) = x t` for all `t : Nat`. -/
def IsPeriodic {α : Type} (m : Nat) (x : Nat → α) : Prop :=
  ∀ t : Nat, x (t + m) = x t

lemma resSet_mod_eq (N m t : Nat) : resSet N m (t % m) = resSet N m t := by
  unfold resSet
  ext s
  simp

lemma resSet_add_mul_right (N m t k : Nat) : resSet N m (t + k * m) = resSet N m t := by
  unfold resSet
  ext s
  simp [Nat.add_mul_mod_self_right]

lemma resSet_mod_N_eq {N m : Nat} (hm : m ∣ N) (t : Nat) :
    resSet N m (t % N) = resSet N m t := by
  unfold resSet
  ext s
  simp [Nat.mod_mod_of_dvd t hm]

theorem Q_mod_m {K : Type} [Field K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N m x (t % m) = Q N m x t := by
  rw [Q_eq_resSum hN hm x (t % m), Q_eq_resSum hN hm x t, resSet_mod_eq]

theorem Q_mod_N {K : Type} [Field K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N m x (t % N) = Q N m x t := by
  rw [Q_eq_resSum hN hm x (t % N), Q_eq_resSum hN hm x t, resSet_mod_N_eq hm]

/-- Forward direction of periodic projection: for every `x`, `Q N m x` is `m`-periodic. -/
theorem Q_periodic {K : Type} [Field K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    IsPeriodic m (Q N m x) := by
  intro t
  rw [Q_eq_resSum hN hm x (t + m), Q_eq_resSum hN hm x t]
  have h1 : t + m = t + 1 * m := by ring
  rw [h1, resSet_add_mul_right]

lemma periodic_add_mul {α : Type} {m : Nat} {x : Nat → α} (hp : IsPeriodic m x) (t q : Nat) :
    x (t + q * m) = x t := by
  induction q with
  | zero => simp
  | succ q ih =>
    have hstep : t + (q + 1) * m = (t + q * m) + m := by ring
    rw [hstep, hp (t + q * m), ih]

lemma periodic_eq_mod {α : Type} {m : Nat} {x : Nat → α} (hp : IsPeriodic m x) (t : Nat) :
    x t = x (t % m) := by
  have hdiv : t % m + (t / m) * m = t := by
    have h := Nat.mod_add_div t m
    linarith
  calc x t
    _ = x (t % m + (t / m) * m) := by rw [hdiv]
    _ = x (t % m) := periodic_add_mul hp (t % m) (t / m)

lemma periodic_of_dvd {α : Type} {d m : Nat} (hd : d ∣ m) {x : Nat → α} (hp : IsPeriodic d x) :
    IsPeriodic m x := by
  rcases hd with ⟨k, rfl⟩
  intro t
  have hmul : t + d * k = t + k * d := by ring
  rw [hmul]
  exact periodic_add_mul hp t k

/-- Reverse direction of periodic projection: if `x` is `m`-periodic on `0..N-1`
(i.e. `x s = x (s % m)` for all `s < N`), then `Q N m x t = x (t % m)` for all `t`. -/
theorem Q_eq_mod_of_window_periodic {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) {x : Nat → K}
    (hwin : ∀ s < N, x s = x (s % m)) (t : Nat) :
    Q N m x t = x (t % m) := by
  have hk0 : 0 < N / m := div_pos_of_dvd_of_pos hN hm
  have hk_ne : ((N / m : Nat) : K) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hk0)
  rw [Q_eq_resSum hN hm x t]
  have hsum : ∑ s ∈ resSet N m t, x s = ∑ _s ∈ resSet N m t, x (t % m) := by
    refine Finset.sum_congr rfl (fun s hs => ?_)
    simp only [resSet, Finset.mem_filter, Finset.mem_range] at hs
    rw [hwin s hs.1, hs.2]
  rw [hsum, Finset.sum_const, card_resSet hN hm t, nsmul_eq_mul, inv_mul_cancel_left₀ hk_ne]

/-- If `x` is `m`-periodic, then `Q N m x = x` everywhere. -/
theorem Q_eq_self_of_periodic {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) {x : Nat → K} (hp : IsPeriodic m x) (t : Nat) :
    Q N m x t = x t := by
  have hwin : ∀ s < N, x s = x (s % m) := fun s _ => periodic_eq_mod hp s
  rw [Q_eq_mod_of_window_periodic hN hm hwin t, ← periodic_eq_mod hp t]

/-- Bidirectional characterization: `Q N m x = x` iff `x` is `m`-periodic. -/
theorem Q_fixpoint_iff_periodic {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    (∀ t, Q N m x t = x t) ↔ IsPeriodic m x := by
  constructor
  · intro hfix t
    rw [← hfix (t + m), ← hfix t]
    exact Q_periodic hN hm x t
  · intro hp t
    exact Q_eq_self_of_periodic hN hm hp t

/-- Idempotence: `Q_m^2 = Q_m`. -/
theorem Q_idem {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N m (Q N m x) t = Q N m x t :=
  Q_eq_self_of_periodic hN hm (Q_periodic hN hm x) t

/-- Functional form of idempotence `Q_m ∘ Q_m = Q_m`. -/
theorem Q_idem_fun {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    Q N m (Q N m x) = Q N m x := by
  funext t
  exact Q_idem hN hm x t

/-- `Q_N x t = x (t % N)` for all `t`. -/
theorem Q_self_eq_mod {K : Type} [Field K] {N : Nat}
    (hN : 0 < N) (x : Nat → K) (t : Nat) :
    Q N N x t = x (t % N) := by
  unfold Q
  rw [Nat.div_self hN]
  simp

/-- `Q_N x t = x t` on the canonical window `t < N`. -/
theorem Q_self_id_on_range {K : Type} [Field K] {N : Nat}
    (hN : 0 < N) (x : Nat → K) {t : Nat} (ht : t < N) :
    Q N N x t = x t := by
  rw [Q_self_eq_mod hN x t, Nat.mod_eq_of_lt ht]

/-- `Q_N x = x` for every `N`-periodic signal `x`. -/
theorem Q_self_id_of_periodic {K : Type} [Field K] {N : Nat}
    (hN : 0 < N) {x : Nat → K} (hp : IsPeriodic N x) :
    Q N N x = x := by
  funext t
  rw [Q_self_eq_mod hN x t, ← periodic_eq_mod hp t]

/-- `Q_1` is the constant complete-residue mean `(1/N) ∑_{s=0}^{N-1} x(s)`. -/
theorem Q_one_eq_mean {K : Type} [Field K] {N : Nat}
    (hN : 0 < N) (x : Nat → K) (t : Nat) :
    Q N 1 x t = (N : K)⁻¹ * ∑ s ∈ Finset.range N, x s := by
  have h1 : 1 ∣ N := one_dvd N
  rw [Q_eq_resSum hN h1 x t, Nat.div_one]
  have hres : resSet N 1 t = Finset.range N := by
    unfold resSet
    ext s
    simp [Nat.mod_one]
  rw [hres]

/-! ### 4. Semigroup Composition Law `Q_m Q_n = Q_{gcd(m, n)}` -/

/-- `Q_m` and `Q_n` commute. -/
theorem Q_comm {K : Type} [Field K] (N m n : Nat) (x : Nat → K) (t : Nat) :
    Q N m (Q N n x) t = Q N n (Q N m x) t := by
  unfold Q
  have h_inner_m : ∀ j ∈ Finset.range (N / m),
      ((N / n : Nat) : K)⁻¹ * ∑ i ∈ Finset.range (N / n), x (((t + j * m) % N + i * n) % N) =
        ((N / n : Nat) : K)⁻¹ * ∑ i ∈ Finset.range (N / n), x ((t + j * m + i * n) % N) := by
    intro j _
    congr 1
    refine Finset.sum_congr rfl (fun i _ => ?_)
    rw [Nat.mod_add_mod]
  have h_inner_n : ∀ i ∈ Finset.range (N / n),
      ((N / m : Nat) : K)⁻¹ * ∑ j ∈ Finset.range (N / m), x (((t + i * n) % N + j * m) % N) =
        ((N / m : Nat) : K)⁻¹ * ∑ j ∈ Finset.range (N / m), x ((t + j * m + i * n) % N) := by
    intro i _
    congr 1
    refine Finset.sum_congr rfl (fun j _ => ?_)
    rw [Nat.mod_add_mod]
    have h_add : t + i * n + j * m = t + j * m + i * n := by ring
    rw [h_add]
  rw [Finset.sum_congr rfl h_inner_m, Finset.sum_congr rfl h_inner_n]
  rw [← Finset.mul_sum, ← Finset.mul_sum, Finset.sum_comm, mul_left_comm]

/-- Euclidean periodicity lemma: a signal that is both `m`-periodic and `n`-periodic
(for `m, n > 0`) is `gcd(m, n)`-periodic. -/
lemma periodic_gcd_of_periodic {α : Type} {m n : Nat} (hm : 0 < m) (hn : 0 < n)
    {z : Nat → α} (hpm : IsPeriodic m z) (hpn : IsPeriodic n z) :
    IsPeriodic (Nat.gcd m n) z := by
  have hmain : ∀ s m n : Nat, m + n = s → 0 < m → 0 < n →
      IsPeriodic m z → IsPeriodic n z → IsPeriodic (Nat.gcd m n) z := by
    intro s
    induction s using Nat.strongRecOn with
    | ind s ih =>
      intro m n hsum hm0 hn0 hpm0 hpn0
      rcases lt_trichotomy m n with hlt | rfl | hgt
      · have hn' : 0 < n - m := by omega
        have hsum' : m + (n - m) < s := by omega
        have hpn' : IsPeriodic (n - m) z := by
          intro t
          have heq : t + (n - m) + m = t + n := by omega
          rw [← hpm0 (t + (n - m)), heq, hpn0 t]
        have hgcd : Nat.gcd m n = Nat.gcd m (n - m) := by
          have h := Nat.gcd_sub_self_right (le_of_lt hlt)
          exact h.symm
        rw [hgcd]
        exact ih (m + (n - m)) hsum' m (n - m) rfl hm0 hn' hpm0 hpn'
      · rw [Nat.gcd_self]
        exact hpm0
      · have hm' : 0 < m - n := by omega
        have hsum' : (m - n) + n < s := by omega
        have hpm' : IsPeriodic (m - n) z := by
          intro t
          have heq : t + (m - n) + n = t + m := by omega
          rw [← hpn0 (t + (m - n)), heq, hpm0 t]
        have hgcd : Nat.gcd m n = Nat.gcd (m - n) n := by
          have h := Nat.gcd_sub_self_left (le_of_lt hgt)
          exact h.symm
        rw [hgcd]
        exact ih ((m - n) + n) hsum' (m - n) n rfl hm' hn0 hpm' hpn0
  exact hmain (m + n) m n rfl hm hn hpm hpn

/-- If `d ∣ m` and `m ∣ N`, then `Q_m` absorbs `Q_d` on the right: `Q_m (Q_d x) = Q_d x`. -/
theorem Q_dvd_absorb_right {K : Type} [Field K] [CharZero K] {N d m : Nat}
    (hN : 0 < N) (hdm : d ∣ m) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N m (Q N d x) t = Q N d x t := by
  have hdN : d ∣ N := dvd_trans hdm hm
  have hpd : IsPeriodic d (Q N d x) := Q_periodic hN hdN x
  have hpm : IsPeriodic m (Q N d x) := periodic_of_dvd hdm hpd
  exact Q_eq_self_of_periodic hN hm hpm t

/-- If `d ∣ m` and `m ∣ N`, then `Q_d` absorbs `Q_m` on the right: `Q_d (Q_m x) = Q_d x`. -/
theorem Q_dvd_absorb_left {K : Type} [Field K] [CharZero K] {N d m : Nat}
    (hN : 0 < N) (hdm : d ∣ m) (hm : m ∣ N) (x : Nat → K) (t : Nat) :
    Q N d (Q N m x) t = Q N d x t := by
  rw [Q_comm N d m x t]
  exact Q_dvd_absorb_right hN hdm hm x t

/-- Semigroup composition law (Milestone A): for `m ∣ N` and `n ∣ N`,
`Q_m (Q_n x) = Q_{gcd(m, n)} x`. -/
theorem Q_comp_eq_gcd {K : Type} [Field K] [CharZero K] {N m n : Nat}
    (hN : 0 < N) (hm : m ∣ N) (hn : n ∣ N) (x : Nat → K) (t : Nat) :
    Q N m (Q N n x) t = Q N (Nat.gcd m n) x t := by
  set g := Nat.gcd m n
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have hn0 : 0 < n := pos_of_dvd_of_pos hN hn
  have hgm : g ∣ m := Nat.gcd_dvd_left m n
  have hgn : g ∣ n := Nat.gcd_dvd_right m n
  have hgN : g ∣ N := dvd_trans hgm hm
  have hpm : IsPeriodic m (Q N m (Q N n x)) := Q_periodic hN hm (Q N n x)
  have hpn : IsPeriodic n (Q N m (Q N n x)) := by
    intro u
    rw [Q_comm N m n x (u + n), Q_comm N m n x u]
    exact Q_periodic hN hn (Q N m x) u
  have hpg : IsPeriodic g (Q N m (Q N n x)) := periodic_gcd_of_periodic hm0 hn0 hpm hpn
  calc Q N m (Q N n x) t
    _ = Q N g (Q N m (Q N n x)) t := (Q_eq_self_of_periodic hN hgN hpg t).symm
    _ = Q N g (Q N n x) t := Q_dvd_absorb_left hN hgm hm (Q N n x) t
    _ = Q N g x t := Q_dvd_absorb_left hN hgn hn x t

/-- Functional form of `Q_m ∘ Q_n = Q_{gcd(m, n)}`. -/
theorem Q_comp_eq_gcd_fun {K : Type} [Field K] [CharZero K] {N m n : Nat}
    (hN : 0 < N) (hm : m ∣ N) (hn : n ∣ N) (x : Nat → K) :
    Q N m (Q N n x) = Q N (Nat.gcd m n) x := by
  funext t
  exact Q_comp_eq_gcd hN hm hn x t

end Ruliology.CellularAutomata.FVLTPeriodProjectorsV1
