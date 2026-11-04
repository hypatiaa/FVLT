import FVLTPeriodProjectorsV1
import Mathlib.NumberTheory.ArithmeticFunction.Moebius
import Mathlib.NumberTheory.Divisors

open scoped BigOperators
open ArithmeticFunction
open scoped ArithmeticFunction.Moebius

namespace Ruliology.CellularAutomata.FVLTConductorProjectorsV1

open Ruliology.CellularAutomata.FVLTPeriodProjectorsV1

/-!
# FVLT-H1 Milestone B: Full Exact-Conductor Projectors `P_q` and Energy Identities

For arbitrary `N > 0`, finite signals `x : Nat → K` over any characteristic-zero field `K : Type`
(supporting `ℚ`, `ℝ`, and `ℂ`), and any divisor `q ∣ N`, we define the exact-conductor projector
by divisor Möbius inversion:

  `(P N q x) t = ∑ m ∈ q.divisors, (μ (q / m) : K) * Q N m x t`

and prove:
1. Divisor reconstruction `Q_m = ∑_{q ∈ m.divisors} P_q` (`Q_eq_sum_P`).
2. Completeness `∑_{q ∈ N.divisors} P_q = id` (`sum_P_divisors_eq_mod`, `sum_P_divisors_eq_self_on_range`,
   `sum_P_divisors_eq_self_of_periodic`).
3. Linearity (`P_add`, `P_smul`, `P_sub`, `P_zero`) and complete-residue SUM self-adjointness
   (`P_selfAdjoint_sumInner`, `P_selfAdjoint_sesqInner`).
4. Cross-action `Q_m (P_r x) = if r ∣ m then P_r x else 0` (`Q_comp_P`), idempotence `P_q (P_q x) = P_q x`
   (`P_idem`), and pairwise annihilation `P_q (P_r x) = 0` for `q ≠ r` (`P_comp_P`, `P_orthogonal_of_ne`),
   plus inner-product orthogonality `sumInner N (P N q x) (P N r y) = 0` for `q ≠ r`.
5. Complete-residue sum-scale Parseval (`sum_E_full_eq_norm_sq`, `sum_E_full_sesq_eq_norm_sq`).
6. Exact fold identity `||Q_m x||_sum^2 = (N/m)⁻¹ ∑_{r < m} (∑_{j < N/m} x(r + j*m))^2`
   (`Q_norm_sq_eq_fold`, `Q_sesq_norm_sq_eq_fold`) and exact full-energy Möbius inversion
   `E_full N q x = ∑_{m ∈ q.divisors} μ(q/m) ||Q_m x||_sum^2` (`E_full_eq_moebius_fold`).
-/

/-- The exact-conductor projector `P_q = ∑_{m ∣ q} μ(q/m) Q_m` (Milestone B). -/
def P {K : Type} [Field K] (N q : Nat) (x : Nat → K) (t : Nat) : K :=
  ∑ m ∈ q.divisors, (μ (q / m) : K) * Q N m x t

/-- The folded residue sum `S_m(x, r) = ∑_{j=0}^{N/m - 1} x(r + j * m)`. -/
def foldSum {K : Type} [AddCommMonoid K] (N m : Nat) (x : Nat → K) (r : Nat) : K :=
  ∑ j ∈ Finset.range (N / m), x (r + j * m)

/-- The complete-residue sum-scale period-projected energy `||Q_m x||_sum^2`. -/
def F_fold {K : Type} [Field K] (N m : Nat) (x : Nat → K) : K :=
  sumInner N (Q N m x) (Q N m x)

/-- The sesquilinear complete-residue sum-scale period-projected energy. -/
def F_fold_sesq {K : Type} [Field K] (cnj : K →+* K) (N m : Nat) (x : Nat → K) : K :=
  sumSesqInner cnj N (Q N m x) (Q N m x)

/-- The full exact-conductor sum-scale energy `E_q^full(x) = ||P_q x||_sum^2`. -/
def E_full {K : Type} [Field K] (N q : Nat) (x : Nat → K) : K :=
  sumInner N (P N q x) (P N q x)

/-- The sesquilinear full exact-conductor sum-scale energy `E_q^full(x) = ⟨P_q x, P_q x⟩_sum`. -/
def E_full_sesq {K : Type} [Field K] (cnj : K →+* K) (N q : Nat) (x : Nat → K) : K :=
  sumSesqInner cnj N (P N q x) (P N q x)

/-! ### 1. General Divisor Möbius Inversion Helpers -/

/-- Forward divisor Möbius inversion: if `F(q) = ∑_{d ∈ q.divisors} μ(q/d) G(d)`, then
`∑_{q ∈ m.divisors} F(q) = G(m)` for every `m > 0`. -/
theorem moebius_sum_divisors_eq {R : Type} [CommRing R] (G : Nat → R) {m : Nat} (hm : 0 < m) :
    ∑ q ∈ m.divisors, (∑ d ∈ q.divisors, (μ (q / d) : R) * G d) = G m := by
  let F : Nat → R := fun q => ∑ x ∈ q.divisorsAntidiagonal, (μ x.fst : R) * G x.snd
  have hF_eq : ∀ q : Nat,
      (∑ d ∈ q.divisors, (μ (q / d) : R) * G d) = F q := by
    intro q
    simpa [F] using (Nat.sum_divisorsAntidiagonal' (f := fun x y => (μ x : R) * G y) (n := q)).symm
  simp_rw [hF_eq]
  have hinv := (ArithmeticFunction.sum_eq_iff_sum_mul_moebius_eq (R := R) (f := F) (g := G)).mpr
  exact hinv (fun n _ => rfl) m hm

/-- Downward-closed Möbius uniqueness on divisors of `N`: if `F1` and `F2` have the same
divisor sums for all `m ∣ N`, then `F1 q = F2 q` for all `q ∣ N`. -/
theorem moebius_unique_of_sum_divisors_eq_on_dvd {R : Type} [CommRing R] {N : Nat} (hN : 0 < N)
    {F1 F2 : Nat → R}
    (hsum : ∀ m : Nat, m ∣ N → ∑ d ∈ m.divisors, F1 d = ∑ d ∈ m.divisors, F2 d)
    {q : Nat} (hq : q ∣ N) :
    F1 q = F2 q := by
  have hq0 : 0 < q := pos_of_dvd_of_pos hN hq
  let s : Set Nat := {m : Nat | m ∣ N}
  have hs : ∀ m n : Nat, m ∣ n → n ∈ s → m ∈ s := fun m n hmn hn => dvd_trans hmn hn
  let G : Nat → R := fun m => ∑ d ∈ m.divisors, F2 d
  have h1 : ∀ n > 0, n ∈ s → (∑ d ∈ n.divisors, F1 d) = G n := by
    intro n _ hn
    exact hsum n hn
  have h2 : ∀ n > 0, n ∈ s → (∑ d ∈ n.divisors, F2 d) = G n := by
    intro n _ _
    rfl
  have hm1 := (ArithmeticFunction.sum_eq_iff_sum_mul_moebius_eq_on (R := R) s hs (f := F1) (g := G)).mp h1 q hq0 hq
  have hm2 := (ArithmeticFunction.sum_eq_iff_sum_mul_moebius_eq_on (R := R) s hs (f := F2) (g := G)).mp h2 q hq0 hq
  rw [← hm1, ← hm2]

/-! ### 2. Divisor Decomposition `Q_m = ∑_{q ∣ m} P_q` and Completeness -/

/-- Divisor decomposition (Milestone B): `∑_{q ∈ m.divisors} P_q x = Q_m x` for every `m > 0`. -/
theorem Q_eq_sum_P {K : Type} [Field K] (N : Nat) {m : Nat} (hm : 0 < m)
    (x : Nat → K) (t : Nat) :
    ∑ q ∈ m.divisors, P N q x t = Q N m x t := by
  unfold P
  exact moebius_sum_divisors_eq (fun d => Q N d x t) hm

/-- Functional form of `∑_{q ∈ m.divisors} P_q x = Q_m x` for `m ∣ N` (`0 < N`). -/
theorem Q_eq_sum_P_of_dvd {K : Type} [Field K] {N m : Nat} (hN : 0 < N) (hm : m ∣ N)
    (x : Nat → K) (t : Nat) :
    ∑ q ∈ m.divisors, P N q x t = Q N m x t :=
  Q_eq_sum_P N (pos_of_dvd_of_pos hN hm) x t

/-- Completeness of `{P_q}_{q ∣ N}`: `∑_{q ∈ N.divisors} P_q x t = x (t % N)`. -/
theorem sum_P_divisors_eq_mod {K : Type} [Field K] {N : Nat} (hN : 0 < N)
    (x : Nat → K) (t : Nat) :
    ∑ q ∈ N.divisors, P N q x t = x (t % N) := by
  rw [Q_eq_sum_P N hN x t, Q_self_eq_mod hN x t]

/-- Completeness on the canonical window `t < N`: `∑_{q ∈ N.divisors} P_q x t = x t`. -/
theorem sum_P_divisors_eq_self_on_range {K : Type} [Field K] {N : Nat} (hN : 0 < N)
    (x : Nat → K) {t : Nat} (ht : t < N) :
    ∑ q ∈ N.divisors, P N q x t = x t := by
  rw [sum_P_divisors_eq_mod hN x t, Nat.mod_eq_of_lt ht]

/-- Completeness on `N`-periodic signals: `∑_{q ∈ N.divisors} P_q x t = x t`. -/
theorem sum_P_divisors_eq_self_of_periodic {K : Type} [Field K] {N : Nat} (hN : 0 < N)
    {x : Nat → K} (hp : IsPeriodic N x) (t : Nat) :
    ∑ q ∈ N.divisors, P N q x t = x t := by
  rw [sum_P_divisors_eq_mod hN x t, ← periodic_eq_mod hp t]

/-- `P_1 = Q_1` is the constant complete-residue mean. -/
theorem P_one_eq_Q_one {K : Type} [Field K] (N : Nat) (x : Nat → K) (t : Nat) :
    P N 1 x t = Q N 1 x t := by
  unfold P
  simp

/-! ### 3. Linearity and Complete-Residue SUM Self-Adjointness of `P_q` -/

theorem P_add {K : Type} [Field K] (N q : Nat) (x y : Nat → K) (t : Nat) :
    P N q (fun s => x s + y s) t = P N q x t + P N q y t := by
  unfold P
  rw [← Finset.sum_add_distrib]
  refine Finset.sum_congr rfl (fun m _ => ?_)
  rw [Q_add, mul_add]

theorem P_smul {K : Type} [Field K] (N q : Nat) (c : K) (x : Nat → K) (t : Nat) :
    P N q (fun s => c * x s) t = c * P N q x t := by
  unfold P
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl (fun m _ => ?_)
  rw [Q_smul, mul_left_comm]

theorem P_sub {K : Type} [Field K] (N q : Nat) (x y : Nat → K) (t : Nat) :
    P N q (fun s => x s - y s) t = P N q x t - P N q y t := by
  unfold P
  rw [← Finset.sum_sub_distrib]
  refine Finset.sum_congr rfl (fun m _ => ?_)
  rw [Q_sub, mul_sub]

theorem P_zero {K : Type} [Field K] (N q : Nat) (t : Nat) :
    P N q (fun _ => (0 : K)) t = 0 := by
  unfold P
  simp [Q_zero]

lemma Q_sum {K : Type} [Field K] {ι : Type} (N m : Nat) (S : Finset ι)
    (f : ι → Nat → K) (t : Nat) :
    Q N m (fun s => ∑ i ∈ S, f i s) t = ∑ i ∈ S, Q N m (f i) t := by
  unfold Q
  rw [Finset.mul_sum]
  have hswap : ∑ j ∈ Finset.range (N / m), ∑ i ∈ S, f i ((t + j * m) % N) =
      ∑ i ∈ S, ∑ j ∈ Finset.range (N / m), f i ((t + j * m) % N) := Finset.sum_comm
  rw [← Finset.mul_sum, hswap, Finset.mul_sum]

/-- `P_q` is self-adjoint under the complete-residue SUM inner product. -/
theorem P_selfAdjoint_sumInner {K : Type} [Field K] {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x y : Nat → K) :
    sumInner N (P N q x) y = sumInner N x (P N q y) := by
  unfold sumInner P
  have h1 : ∀ t ∈ Finset.range N,
      (∑ m ∈ q.divisors, (μ (q / m) : K) * Q N m x t) * y t =
        ∑ m ∈ q.divisors, (μ (q / m) : K) * (Q N m x t * y t) := by
    intro t _
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl (fun m _ => by ring)
  have h2 : ∀ t ∈ Finset.range N,
      x t * (∑ m ∈ q.divisors, (μ (q / m) : K) * Q N m y t) =
        ∑ m ∈ q.divisors, (μ (q / m) : K) * (x t * Q N m y t) := by
    intro t _
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun m _ => by ring)
  rw [Finset.sum_congr rfl h1, Finset.sum_congr rfl h2, Finset.sum_comm]
  rw [Finset.sum_comm (s := Finset.range N) (t := q.divisors)]
  refine Finset.sum_congr rfl (fun m hm => ?_)
  rw [← Finset.mul_sum, ← Finset.mul_sum]
  have hm_dvd_q : m ∣ q := Nat.dvd_of_mem_divisors hm
  have hm_dvd_N : m ∣ N := dvd_trans hm_dvd_q hq
  have hsa := Q_selfAdjoint_sumInner hN hm_dvd_N x y
  unfold sumInner at hsa
  rw [hsa]

/-- `P_q` is self-adjoint under the sesquilinear SUM inner product for any `cnj : K →+* K`. -/
theorem P_selfAdjoint_sesqInner {K : Type} [Field K] (cnj : K →+* K) {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x y : Nat → K) :
    sumSesqInner cnj N (P N q x) y = sumSesqInner cnj N x (P N q y) := by
  unfold sumSesqInner P
  have h1 : ∀ t ∈ Finset.range N,
      cnj (∑ m ∈ q.divisors, (μ (q / m) : K) * Q N m x t) * y t =
        ∑ m ∈ q.divisors, (μ (q / m) : K) * (cnj (Q N m x t) * y t) := by
    intro t _
    rw [map_sum, Finset.sum_mul]
    refine Finset.sum_congr rfl (fun m _ => ?_)
    rw [map_mul, map_intCast, mul_assoc]
  have h2 : ∀ t ∈ Finset.range N,
      cnj (x t) * (∑ m ∈ q.divisors, (μ (q / m) : K) * Q N m y t) =
        ∑ m ∈ q.divisors, (μ (q / m) : K) * (cnj (x t) * Q N m y t) := by
    intro t _
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl (fun m _ => by ring)
  rw [Finset.sum_congr rfl h1, Finset.sum_congr rfl h2, Finset.sum_comm]
  rw [Finset.sum_comm (s := Finset.range N) (t := q.divisors)]
  refine Finset.sum_congr rfl (fun m hm => ?_)
  rw [← Finset.mul_sum, ← Finset.mul_sum]
  have hm_dvd_q : m ∣ q := Nat.dvd_of_mem_divisors hm
  have hm_dvd_N : m ∣ N := dvd_trans hm_dvd_q hq
  have hsa := Q_selfAdjoint_sesqInner cnj hN hm_dvd_N x y
  unfold sumSesqInner at hsa
  rw [hsa]

/-! ### 4. Idempotence and Pairwise Orthogonality of `{P_q}_{q ∣ N}` -/

lemma sum_divisors_ite_dvd {R : Type} [AddCommMonoid R] {m n : Nat} (hm : 0 < m) (hn : 0 < n)
    (f : Nat → R) :
    (∑ r ∈ n.divisors, if r ∣ m then f r else 0) =
      ∑ r ∈ (Nat.gcd m n).divisors, f r := by
  rw [← Finset.sum_filter]
  refine Finset.sum_congr ?_ (fun _ _ => rfl)
  ext r
  simp only [Finset.mem_filter, Nat.mem_divisors, ne_eq]
  have hgcd_ne : Nat.gcd m n ≠ 0 := by
    intro h0
    have := Nat.gcd_eq_zero_iff.mp h0
    omega
  constructor
  · rintro ⟨⟨hrn, _⟩, hrm⟩
    exact ⟨Nat.dvd_gcd hrm hrn, hgcd_ne⟩
  · rintro ⟨hrg, _⟩
    exact ⟨⟨dvd_trans hrg (Nat.gcd_dvd_right m n), Nat.ne_of_gt hn⟩,
      dvd_trans hrg (Nat.gcd_dvd_left m n)⟩

/-- Action of `Q_m` on `P_r`: `Q_m (P_r x) = P_r x` if `r ∣ m`, and `0` otherwise. -/
theorem Q_comp_P {K : Type} [Field K] [CharZero K] {N m r : Nat}
    (hN : 0 < N) (hm : m ∣ N) (hr : r ∣ N) (x : Nat → K) (t : Nat) :
    Q N m (P N r x) t = if r ∣ m then P N r x t else 0 := by
  let F1 : Nat → K := fun d => Q N m (P N d x) t
  let F2 : Nat → K := fun d => if d ∣ m then P N d x t else 0
  change F1 r = F2 r
  refine moebius_unique_of_sum_divisors_eq_on_dvd hN (fun n hn => ?_) hr
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have hn0 : 0 < n := pos_of_dvd_of_pos hN hn
  have hgm : Nat.gcd m n ∣ m := Nat.gcd_dvd_left m n
  have hgN : Nat.gcd m n ∣ N := dvd_trans hgm hm
  have hg0 : 0 < Nat.gcd m n := pos_of_dvd_of_pos hN hgN
  have lhs_eq : ∑ d ∈ n.divisors, F1 d = Q N (Nat.gcd m n) x t := by
    dsimp [F1]
    rw [← Q_sum N m n.divisors (fun d => P N d x) t]
    have hfun : (fun s => ∑ d ∈ n.divisors, P N d x s) = Q N n x := by
      funext s
      exact Q_eq_sum_P N hn0 x s
    rw [hfun]
    exact Q_comp_eq_gcd hN hm hn x t
  have rhs_eq : ∑ d ∈ n.divisors, F2 d = Q N (Nat.gcd m n) x t := by
    dsimp [F2]
    rw [sum_divisors_ite_dvd hm0 hn0 (fun d => P N d x t)]
    exact Q_eq_sum_P N hg0 x t
  rw [lhs_eq, rhs_eq]

/-- Projector algebra (Milestone B): for `q, r ∣ N`,
`P_q (P_r x) = P_r x` if `q = r`, and `0` if `q ≠ r`. -/
theorem P_comp_P {K : Type} [Field K] [CharZero K] {N q r : Nat}
    (hN : 0 < N) (hq : q ∣ N) (hr : r ∣ N) (x : Nat → K) (t : Nat) :
    P N q (P N r x) t = if q = r then P N q x t else 0 := by
  let H1 : Nat → K := fun d => P N d (P N r x) t
  let H2 : Nat → K := fun d => if d = r then P N d x t else 0
  change H1 q = H2 q
  refine moebius_unique_of_sum_divisors_eq_on_dvd hN (fun m hm => ?_) hq
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have lhs_eq : ∑ d ∈ m.divisors, H1 d = if r ∣ m then P N r x t else 0 := by
    dsimp [H1]
    rw [Q_eq_sum_P N hm0 (P N r x) t]
    exact Q_comp_P hN hm hr x t
  have rhs_eq : ∑ d ∈ m.divisors, H2 d = if r ∣ m then P N r x t else 0 := by
    dsimp [H2]
    rw [Finset.sum_ite_eq']
    have hmem : r ∈ m.divisors ↔ r ∣ m := by
      simp [Nat.mem_divisors, Nat.ne_of_gt hm0]
    by_cases hrm : r ∣ m
    · have hrm' : r ∈ m.divisors := hmem.mpr hrm
      rw [ite_eq_left hrm', ite_eq_left hrm]
    · have hrm' : r ∉ m.divisors := fun h => hrm (hmem.mp h)
      rw [ite_eq_right hrm', ite_eq_right hrm]
  rw [lhs_eq, rhs_eq]

/-- Idempotence of `P_q`: `P_q (P_q x) = P_q x`. -/
theorem P_idem {K : Type} [Field K] [CharZero K] {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x : Nat → K) (t : Nat) :
    P N q (P N q x) t = P N q x t := by
  rw [P_comp_P hN hq hq x t, ite_eq_left rfl]

/-- Functional form of idempotence `P_q ∘ P_q = P_q`. -/
theorem P_idem_fun {K : Type} [Field K] [CharZero K] {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x : Nat → K) :
    P N q (P N q x) = P N q x := by
  funext t
  exact P_idem hN hq x t

/-- Pairwise annihilation: for `q ≠ r`, `P_q (P_r x) t = 0`. -/
theorem P_orthogonal_of_ne {K : Type} [Field K] [CharZero K] {N q r : Nat}
    (hN : 0 < N) (hq : q ∣ N) (hr : r ∣ N) (hne : q ≠ r) (x : Nat → K) (t : Nat) :
    P N q (P N r x) t = 0 := by
  rw [P_comp_P hN hq hr x t, ite_eq_right hne]

/-- Functional form of pairwise annihilation `P_q (P_r x) = 0` for `q ≠ r`. -/
theorem P_orthogonal_of_ne_fun {K : Type} [Field K] [CharZero K] {N q r : Nat}
    (hN : 0 < N) (hq : q ∣ N) (hr : r ∣ N) (hne : q ≠ r) (x : Nat → K) :
    P N q (P N r x) = fun _ => 0 := by
  funext t
  exact P_orthogonal_of_ne hN hq hr hne x t

/-- Inner-product orthogonality: `sumInner N (P N q x) (P N r y) = 0` for `q ≠ r`. -/
theorem P_sumInner_orthogonal_of_ne {K : Type} [Field K] [CharZero K] {N q r : Nat}
    (hN : 0 < N) (hq : q ∣ N) (hr : r ∣ N) (hne : q ≠ r) (x y : Nat → K) :
    sumInner N (P N q x) (P N r y) = 0 := by
  rw [P_selfAdjoint_sumInner hN hq x (P N r y)]
  rw [P_orthogonal_of_ne_fun hN hq hr hne y]
  unfold sumInner
  simp

/-- Sesquilinear inner-product orthogonality: `sumSesqInner cnj N (P N q x) (P N r y) = 0` for `q ≠ r`. -/
theorem P_sesqInner_orthogonal_of_ne {K : Type} [Field K] [CharZero K] (cnj : K →+* K) {N q r : Nat}
    (hN : 0 < N) (hq : q ∣ N) (hr : r ∣ N) (hne : q ≠ r) (x y : Nat → K) :
    sumSesqInner cnj N (P N q x) (P N r y) = 0 := by
  rw [P_selfAdjoint_sesqInner cnj hN hq x (P N r y)]
  rw [P_orthogonal_of_ne_fun hN hq hr hne y]
  unfold sumSesqInner
  simp

/-! ### 5. Sum-Scale Parseval and Divisor Energy Decomposition -/

/-- `E_full N q x = sumInner N x (P N q x)` by self-adjointness and idempotence. -/
theorem E_full_eq_inner_P {K : Type} [Field K] [CharZero K] {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x : Nat → K) :
    E_full N q x = sumInner N x (P N q x) := by
  unfold E_full
  rw [P_selfAdjoint_sumInner hN hq x (P N q x), P_idem_fun hN hq x]

/-- `E_full_sesq cnj N q x = sumSesqInner cnj N x (P N q x)`. -/
theorem E_full_sesq_eq_inner_P {K : Type} [Field K] [CharZero K] (cnj : K →+* K) {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x : Nat → K) :
    E_full_sesq cnj N q x = sumSesqInner cnj N x (P N q x) := by
  unfold E_full_sesq
  rw [P_selfAdjoint_sesqInner cnj hN hq x (P N q x), P_idem_fun hN hq x]

/-- `F_fold N m x = sumInner N x (Q N m x)` by self-adjointness and idempotence of `Q_m`. -/
theorem F_fold_eq_inner_Q {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    F_fold N m x = sumInner N x (Q N m x) := by
  unfold F_fold
  rw [Q_selfAdjoint_sumInner hN hm x (Q N m x), Q_idem_fun hN hm x]

/-- `F_fold_sesq cnj N m x = sumSesqInner cnj N x (Q N m x)`. -/
theorem F_fold_sesq_eq_inner_Q {K : Type} [Field K] [CharZero K] (cnj : K →+* K) {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    F_fold_sesq cnj N m x = sumSesqInner cnj N x (Q N m x) := by
  unfold F_fold_sesq
  rw [Q_selfAdjoint_sesqInner cnj hN hm x (Q N m x), Q_idem_fun hN hm x]

/-- Sub-period Parseval / divisor energy sum: for `m ∣ N`,
`∑_{q ∈ m.divisors} E_full N q x = F_fold N m x = ||Q_m x||_sum^2`. -/
theorem sum_E_full_divisors_eq_F_fold {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    ∑ q ∈ m.divisors, E_full N q x = F_fold N m x := by
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have hcongr : ∑ q ∈ m.divisors, E_full N q x = ∑ q ∈ m.divisors, sumInner N x (P N q x) := by
    refine Finset.sum_congr rfl (fun q hq => ?_)
    exact E_full_eq_inner_P hN (dvd_trans (Nat.dvd_of_mem_divisors hq) hm) x
  rw [hcongr, F_fold_eq_inner_Q hN hm x]
  unfold sumInner
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun t _ => ?_)
  rw [← Finset.mul_sum, Q_eq_sum_P N hm0 x t]

/-- Sesquilinear sub-period Parseval: for `m ∣ N`,
`∑_{q ∈ m.divisors} E_full_sesq cnj N q x = F_fold_sesq cnj N m x`. -/
theorem sum_E_full_sesq_divisors_eq_F_fold {K : Type} [Field K] [CharZero K] (cnj : K →+* K)
    {N m : Nat} (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    ∑ q ∈ m.divisors, E_full_sesq cnj N q x = F_fold_sesq cnj N m x := by
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  have hcongr : ∑ q ∈ m.divisors, E_full_sesq cnj N q x =
      ∑ q ∈ m.divisors, sumSesqInner cnj N x (P N q x) := by
    refine Finset.sum_congr rfl (fun q hq => ?_)
    exact E_full_sesq_eq_inner_P cnj hN (dvd_trans (Nat.dvd_of_mem_divisors hq) hm) x
  rw [hcongr, F_fold_sesq_eq_inner_Q cnj hN hm x]
  unfold sumSesqInner
  rw [Finset.sum_comm]
  refine Finset.sum_congr rfl (fun t _ => ?_)
  rw [← Finset.mul_sum, Q_eq_sum_P N hm0 x t]

/-- Complete-residue sum-scale Parseval (Milestone B, FVLT Theorem 4.6):
`∑_{q ∈ N.divisors} E_full N q x = ∑_{t ∈ range N} x(t)^2`. -/
theorem sum_E_full_eq_norm_sq {K : Type} [Field K] [CharZero K] {N : Nat}
    (hN : 0 < N) (x : Nat → K) :
    ∑ q ∈ N.divisors, E_full N q x = ∑ t ∈ Finset.range N, x t * x t := by
  rw [sum_E_full_divisors_eq_F_fold hN (dvd_refl N) x, F_fold_eq_inner_Q hN (dvd_refl N) x]
  unfold sumInner
  refine Finset.sum_congr rfl (fun t ht => ?_)
  rw [Q_self_id_on_range hN x (Finset.mem_range.mp ht)]

/-- Sesquilinear complete-residue sum-scale Parseval (Milestone B, FVLT Theorem 4.6):
`∑_{q ∈ N.divisors} E_full_sesq cnj N q x = ∑_{t ∈ range N} cnj(x t) * x t`. -/
theorem sum_E_full_sesq_eq_norm_sq {K : Type} [Field K] [CharZero K] (cnj : K →+* K) {N : Nat}
    (hN : 0 < N) (x : Nat → K) :
    ∑ q ∈ N.divisors, E_full_sesq cnj N q x = ∑ t ∈ Finset.range N, cnj (x t) * x t := by
  rw [sum_E_full_sesq_divisors_eq_F_fold cnj hN (dvd_refl N) x,
      F_fold_sesq_eq_inner_Q cnj hN (dvd_refl N) x]
  unfold sumSesqInner
  refine Finset.sum_congr rfl (fun t ht => ?_)
  rw [Q_self_id_on_range hN x (Finset.mem_range.mp ht)]

/-! ### 6. Exact Fold Identity and Full-Energy Möbius Inversion -/

lemma sum_range_mul_eq_sum_mod_quot {K : Type} [AddCommMonoid K] (m k : Nat) (g : Nat → K) :
    ∑ t ∈ Finset.range (k * m), g t =
      ∑ r ∈ Finset.range m, ∑ q ∈ Finset.range k, g (r + q * m) := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Nat.succ_mul, Finset.sum_range_add, ih]
    have h1 : ∑ r ∈ Finset.range m, ∑ q ∈ Finset.range (k + 1), g (r + q * m) =
        ∑ r ∈ Finset.range m, ((∑ q ∈ Finset.range k, g (r + q * m)) + g (r + k * m)) := by
      refine Finset.sum_congr rfl (fun r _ => ?_)
      rw [Finset.sum_range_succ]
    rw [h1, Finset.sum_add_distrib]
    congr 1
    refine Finset.sum_congr rfl (fun r _ => ?_)
    rw [add_comm (k * m) r]

/-- Exact fold identity (Milestone B): for `0 < N` and `m ∣ N`,
`||Q_m x||_sum^2 = ((N/m : Nat) : K)⁻¹ * ∑_{r ∈ range m} (∑_{j ∈ range (N/m)} x(r + j*m))^2`. -/
theorem F_fold_eq_sum_foldSum_sq {K : Type} [Field K] [CharZero K] {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    F_fold N m x = ((N / m : Nat) : K)⁻¹ * ∑ r ∈ Finset.range m, foldSum N m x r * foldSum N m x r := by
  have hN_eq : (N / m) * m = N := Nat.div_mul_cancel hm
  rw [F_fold_eq_inner_Q hN hm x]
  unfold sumInner
  have hsplit : ∑ t ∈ Finset.range N, x t * Q N m x t =
      ∑ r ∈ Finset.range m, ∑ q ∈ Finset.range (N / m), x (r + q * m) * Q N m x (r + q * m) := by
    have := sum_range_mul_eq_sum_mod_quot m (N / m) (fun t => x t * Q N m x t)
    rwa [hN_eq] at this
  rw [hsplit, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun r hr => ?_)
  have hr_lt : r < m := Finset.mem_range.mp hr
  have hinner : ∀ q ∈ Finset.range (N / m),
      x (r + q * m) * Q N m x (r + q * m) =
        x (r + q * m) * (((N / m : Nat) : K)⁻¹ * foldSum N m x r) := by
    intro q _
    rw [Q_eq_quotSum hN hm x (r + q * m)]
    have hrmod : (r + q * m) % m = r := by
      rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hr_lt]
    rw [hrmod]
    rfl
  rw [Finset.sum_congr rfl hinner, ← Finset.sum_mul]
  unfold foldSum
  ring

/-- Sesquilinear exact fold identity (Milestone B): for `0 < N` and `m ∣ N`,
`F_fold_sesq cnj N m x = ((N/m : Nat) : K)⁻¹ * ∑_{r ∈ range m} cnj(foldSum N m x r) * foldSum N m x r`. -/
theorem F_fold_sesq_eq_sum_foldSum_sq {K : Type} [Field K] [CharZero K] (cnj : K →+* K) {N m : Nat}
    (hN : 0 < N) (hm : m ∣ N) (x : Nat → K) :
    F_fold_sesq cnj N m x =
      ((N / m : Nat) : K)⁻¹ * ∑ r ∈ Finset.range m, cnj (foldSum N m x r) * foldSum N m x r := by
  have hN_eq : (N / m) * m = N := Nat.div_mul_cancel hm
  rw [F_fold_sesq_eq_inner_Q cnj hN hm x]
  unfold sumSesqInner
  have hsplit : ∑ t ∈ Finset.range N, cnj (x t) * Q N m x t =
      ∑ r ∈ Finset.range m, ∑ q ∈ Finset.range (N / m), cnj (x (r + q * m)) * Q N m x (r + q * m) := by
    have := sum_range_mul_eq_sum_mod_quot m (N / m) (fun t => cnj (x t) * Q N m x t)
    rwa [hN_eq] at this
  rw [hsplit, Finset.mul_sum]
  refine Finset.sum_congr rfl (fun r hr => ?_)
  have hr_lt : r < m := Finset.mem_range.mp hr
  have hinner : ∀ q ∈ Finset.range (N / m),
      cnj (x (r + q * m)) * Q N m x (r + q * m) =
        cnj (x (r + q * m)) * (((N / m : Nat) : K)⁻¹ * foldSum N m x r) := by
    intro q _
    rw [Q_eq_quotSum hN hm x (r + q * m)]
    have hrmod : (r + q * m) % m = r := by
      rw [Nat.add_mul_mod_self_right, Nat.mod_eq_of_lt hr_lt]
    rw [hrmod]
    rfl
  rw [Finset.sum_congr rfl hinner, ← Finset.sum_mul, ← map_sum]
  unfold foldSum
  ring

/-- Full-energy divisor Möbius inversion (Milestone B): for `0 < N` and `q ∣ N`,
`E_full N q x = ∑_{m ∈ q.divisors} μ(q/m) * F_fold N m x`. -/
theorem E_full_eq_moebius_F_fold {K : Type} [Field K] [CharZero K] {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x : Nat → K) :
    E_full N q x = ∑ m ∈ q.divisors, (μ (q / m) : K) * F_fold N m x := by
  let F1 : Nat → K := fun d => E_full N d x
  let F2 : Nat → K := fun d => ∑ m ∈ d.divisors, (μ (d / m) : K) * F_fold N m x
  change F1 q = F2 q
  refine moebius_unique_of_sum_divisors_eq_on_dvd hN (fun m hm => ?_) hq
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  rw [sum_E_full_divisors_eq_F_fold hN hm x]
  exact (moebius_sum_divisors_eq (fun d => F_fold N d x) hm0).symm

/-- Sesquilinear full-energy divisor Möbius inversion (Milestone B): for `0 < N` and `q ∣ N`,
`E_full_sesq cnj N q x = ∑_{m ∈ q.divisors} μ(q/m) * F_fold_sesq cnj N m x`. -/
theorem E_full_sesq_eq_moebius_F_fold {K : Type} [Field K] [CharZero K] (cnj : K →+* K) {N q : Nat}
    (hN : 0 < N) (hq : q ∣ N) (x : Nat → K) :
    E_full_sesq cnj N q x = ∑ m ∈ q.divisors, (μ (q / m) : K) * F_fold_sesq cnj N m x := by
  let F1 : Nat → K := fun d => E_full_sesq cnj N d x
  let F2 : Nat → K := fun d => ∑ m ∈ d.divisors, (μ (d / m) : K) * F_fold_sesq cnj N m x
  change F1 q = F2 q
  refine moebius_unique_of_sum_divisors_eq_on_dvd hN (fun m hm => ?_) hq
  have hm0 : 0 < m := pos_of_dvd_of_pos hN hm
  rw [sum_E_full_sesq_divisors_eq_F_fold cnj hN hm x]
  exact (moebius_sum_divisors_eq (fun d => F_fold_sesq cnj N d x) hm0).symm

end Ruliology.CellularAutomata.FVLTConductorProjectorsV1
