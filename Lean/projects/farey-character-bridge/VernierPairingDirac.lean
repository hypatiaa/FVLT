/-
  VernierPairingDirac.lean — Formal Lean 4.35.0 structural theorems for the
  Vernier running-surplus pairing studies, finite-menu & character-transfer
  obstructions, and the Dirac-Fock bipartite rank reduction wired into
  `Ratioque.CrystalBridge` and `ThreeToothVernierBridge`.

  Credits: saphir (project lead), Astra (discipline), Opus (skeleton),
  Gemini 4 Argon (Vision seat).
-/

import CrystalBridge
import ThreeToothVernierBridge
import Mathlib.Analysis.Complex.Order
import Mathlib.LinearAlgebra.Matrix.Rank
import Mathlib.LinearAlgebra.Matrix.Hermitian
import Mathlib.Data.Nat.Prime.Infinite
import Mathlib.NumberTheory.DirichletCharacter.Bounds
import Mathlib.NumberTheory.DirichletCharacter.Orthogonality

noncomputable section

namespace Ratioque.VernierPairingDirac

open Complex Filter Asymptotics Finset Matrix
open scoped Matrix ComplexOrder

/-! ### 1. Causal LIFO Exact Surplus Invariant (`|U_LIFO| = |sum|`) -/

/-- One step of the chronological LIFO stack on integer signs in `{-1, 0, 1}`. -/
def lifoStep (stk : List ℤ) (s : ℤ) : List ℤ :=
  if s = 0 then stk
  else match stk with
  | [] => [s]
  | top :: rest => if top + s = 0 then rest else s :: top :: rest

/-- Running chronological LIFO stack over a list of step increments. -/
def lifoRun (xs : List ℤ) : List ℤ :=
  xs.foldl lifoStep []

private def IsUnitSignList (stk : List ℤ) : Prop :=
  (∀ x ∈ stk, x = 1) ∨ (∀ x ∈ stk, x = -1)

private lemma isUnitSignList_nil : IsUnitSignList [] :=
  Or.inl fun _ h => by simp at h

private lemma isUnitSignList_step {stk : List ℤ} (hstk : IsUnitSignList stk) {s : ℤ}
    (hs : s = -1 ∨ s = 0 ∨ s = 1) :
    IsUnitSignList (lifoStep stk s) ∧ (lifoStep stk s).sum = stk.sum + s := by
  by_cases hs0 : s = 0
  · subst hs0
    simp [lifoStep, hstk]
  · have hs1 : s = 1 ∨ s = -1 := by rcases hs with h | h | h <;> simp_all
    cases stk with
    | nil =>
      simp only [lifoStep, hs0, ↓reduceIte]
      refine ⟨?_, by simp⟩
      rcases hs1 with rfl | rfl
      · exact Or.inl fun x hx => by simp at hx; exact hx
      · exact Or.inr fun x hx => by simp at hx; exact hx
    | cons top rest =>
      simp only [lifoStep, hs0, ↓reduceIte]
      have htop : top = 1 ∨ top = -1 := by
        rcases hstk with h | h
        · exact Or.inl (h top (by simp))
        · exact Or.inr (h top (by simp))
      by_cases hcancel : top + s = 0
      · simp only [hcancel, ↓reduceIte]
        have hstk_rest : IsUnitSignList rest := by
          rcases hstk with h | h
          · exact Or.inl fun x hx => h x (by simp [hx])
          · exact Or.inr fun x hx => h x (by simp [hx])
        refine ⟨hstk_rest, ?_⟩
        simp only [List.sum_cons]
        omega
      · simp only [hcancel, ↓reduceIte]
        have heq : s = top := by rcases htop with rfl | rfl <;> rcases hs1 with rfl | rfl <;> omega
        have hstk_new : IsUnitSignList (s :: top :: rest) := by
          rcases hstk with h | h
          · refine Or.inl fun x hx => ?_
            simp only [List.mem_cons] at hx
            rcases hx with hxa | hxb | hxc
            · rw [hxa, heq]; exact h top (by simp)
            · rw [hxb]; exact h top (by simp)
            · exact h x (by simp [hxc])
          · refine Or.inr fun x hx => ?_
            simp only [List.mem_cons] at hx
            rcases hx with hxa | hxb | hxc
            · rw [hxa, heq]; exact h top (by simp)
            · rw [hxb]; exact h top (by simp)
            · exact h x (by simp [hxc])
        refine ⟨hstk_new, ?_⟩
        simp only [List.sum_cons]
        ring

private lemma uniform_list_sum_eq {c : ℤ} {stk : List ℤ} (h : ∀ x ∈ stk, x = c) :
    stk.sum = c * (stk.length : ℤ) := by
  induction stk with
  | nil => simp
  | cons a t ih =>
    have ha : a = c := h a (by simp)
    have ht : ∀ x ∈ t, x = c := fun x hx => h x (by simp [hx])
    rw [List.sum_cons, List.length_cons, ha, ih ht]
    push_cast
    ring

theorem causalLifo_unmatched_eq_abs_sum (xs : List ℤ) (hxs : ∀ s ∈ xs, s = -1 ∨ s = 0 ∨ s = 1) :
    (lifoRun xs).sum = xs.sum ∧ ((lifoRun xs).length : ℤ) = |xs.sum| := by
  have hinv : ∀ (l : List ℤ) (stk : List ℤ),
      IsUnitSignList stk → (∀ s ∈ l, s = -1 ∨ s = 0 ∨ s = 1) →
      IsUnitSignList (l.foldl lifoStep stk) ∧ (l.foldl lifoStep stk).sum = stk.sum + l.sum := by
    intro l
    induction l with
    | nil =>
      intro stk hstk _
      simp [hstk]
    | cons a t ih =>
      intro stk hstk hl
      have ha : a = -1 ∨ a = 0 ∨ a = 1 := hl a (by simp)
      have ht : ∀ s ∈ t, s = -1 ∨ s = 0 ∨ s = 1 := fun s hs => hl s (by simp [hs])
      obtain ⟨h1, hsum1⟩ := isUnitSignList_step hstk ha
      obtain ⟨h2, hsum2⟩ := ih (lifoStep stk a) h1 ht
      refine ⟨h2, ?_⟩
      simp only [List.foldl_cons, List.sum_cons]
      omega
  obtain ⟨hunit, hsum⟩ := hinv xs [] isUnitSignList_nil hxs
  change IsUnitSignList (lifoRun xs) at hunit
  change (lifoRun xs).sum = ([] : List ℤ).sum + xs.sum at hsum
  rw [List.sum_nil, zero_add] at hsum
  refine ⟨hsum, ?_⟩
  rcases hunit with hpos | hneg
  · have hls : (lifoRun xs).sum = ((lifoRun xs).length : ℤ) := by
      simpa using uniform_list_sum_eq hpos
    rw [← hsum, hls]
    exact (abs_of_nonneg (Int.natCast_nonneg _)).symm
  · have hls : (lifoRun xs).sum = -((lifoRun xs).length : ℤ) := by
      have := uniform_list_sum_eq hneg
      linarith
    rw [← hsum, hls, abs_neg]
    exact (abs_of_nonneg (Int.natCast_nonneg _)).symm

/-! ### 2. Joint `chi1 + chi4` Mod-4 Optimal Shared Pairing Identity -/

theorem mod4_abs_add_abs_eq_max (A B : ℤ) :
    |A| + |B| = max |A + B| |A - B| := by
  rcases abs_cases A with ⟨hA, _⟩ | ⟨hA, _⟩ <;>
  rcases abs_cases B with ⟨hB, _⟩ | ⟨hB, _⟩ <;>
  rcases abs_cases (A + B) with ⟨h1, _⟩ | ⟨h1, _⟩ <;>
  rcases abs_cases (A - B) with ⟨h2, _⟩ | ⟨h2, _⟩ <;>
  omega

/-- Mod-4 stratified causal LIFO on a stream of `(q, s)` pairs. -/
def mod4LifoRun (xs : List (ℕ × ℤ)) : List ℤ × List ℤ :=
  (lifoRun (xs.filterMap fun p => if p.1 % 4 = 1 then some p.2 else none),
   lifoRun (xs.filterMap fun p => if p.1 % 4 ≠ 1 then some p.2 else none))

theorem mod4Lifo_unmatched_eq_max (xs : List (ℕ × ℤ))
    (hxs : ∀ p ∈ xs, p.2 = -1 ∨ p.2 = 0 ∨ p.2 = 1) :
    let stks := mod4LifoRun xs
    let A := (xs.filterMap fun p => if p.1 % 4 = 1 then some p.2 else none).sum
    let B := (xs.filterMap fun p => if p.1 % 4 ≠ 1 then some p.2 else none).sum
    (stks.1.length : ℤ) + (stks.2.length : ℤ) = max |A + B| |A - B| := by
  dsimp only [mod4LifoRun]
  have h1 : ∀ s ∈ (xs.filterMap fun p => if p.1 % 4 = 1 then some p.2 else none),
      s = -1 ∨ s = 0 ∨ s = 1 := by
    intro s hs
    rw [List.mem_filterMap] at hs
    rcases hs with ⟨p, hp, hsome⟩
    split_ifs at hsome with hm
    injection hsome with hsp
    subst hsp
    exact hxs p hp
  have h3 : ∀ s ∈ (xs.filterMap fun p => if p.1 % 4 ≠ 1 then some p.2 else none),
      s = -1 ∨ s = 0 ∨ s = 1 := by
    intro s hs
    rw [List.mem_filterMap] at hs
    rcases hs with ⟨p, hp, hsome⟩
    split_ifs at hsome with hm
    injection hsome with hsp
    subst hsp
    exact hxs p hp
  rw [(causalLifo_unmatched_eq_abs_sum _ h1).2, (causalLifo_unmatched_eq_abs_sum _ h3).2]
  exact mod4_abs_add_abs_eq_max _ _

/-! ### 3. Disjoint Opposite-Sign Matching Reduction (Complex & Integer) to RH / `EveryCharacter` -/

/-- A vertex-disjoint matching `M` on `S` where each pair sums to `0` under `w : α → R`. -/
structure DisjointZeroMatching {α R : Type*} [AddCommMonoid R] [DecidableEq α]
    (S : Finset α) (w : α → R) (M : Finset (α × α)) : Prop where
  mem_left : ∀ p ∈ M, p.1 ∈ S
  mem_right : ∀ p ∈ M, p.2 ∈ S
  ne_self : ∀ p ∈ M, p.1 ≠ p.2
  disjoint_pairs : ∀ p ∈ M, ∀ q ∈ M, p ≠ q → p.1 ≠ q.1 ∧ p.1 ≠ q.2 ∧ p.2 ≠ q.1 ∧ p.2 ≠ q.2
  pair_sum_zero : ∀ p ∈ M, w p.1 + w p.2 = 0

private lemma matching_used_props {α R : Type*} [AddCommMonoid R] [DecidableEq α]
    {S : Finset α} {w : α → R} {M : Finset (α × α)} (hM : DisjointZeroMatching S w M) :
    let U := M.image Prod.fst ∪ M.image Prod.snd
    U ⊆ S ∧ U.card = 2 * M.card ∧ ∑ a ∈ U, w a = 0 := by
  intro U
  have h1S : M.image Prod.fst ⊆ S := fun a ha => by
    rcases Finset.mem_image.mp ha with ⟨p, hp, rfl⟩
    exact hM.mem_left p hp
  have h2S : M.image Prod.snd ⊆ S := fun a ha => by
    rcases Finset.mem_image.mp ha with ⟨p, hp, rfl⟩
    exact hM.mem_right p hp
  have hU_sub : U ⊆ S := Finset.union_subset h1S h2S
  have hinj1 : Set.InjOn Prod.fst (M : Set (α × α)) := by
    intro p hp q hq heq
    by_contra hne
    exact (hM.disjoint_pairs p hp q hq hne).1 heq
  have hinj2 : Set.InjOn Prod.snd (M : Set (α × α)) := by
    intro p hp q hq heq
    by_contra hne
    exact (hM.disjoint_pairs p hp q hq hne).2.2.2 heq
  have hdisj : Disjoint (M.image Prod.fst) (M.image Prod.snd) := by
    rw [Finset.disjoint_left]
    intro a ha1 ha2
    rcases Finset.mem_image.mp ha1 with ⟨p, hp, rfl⟩
    rcases Finset.mem_image.mp ha2 with ⟨q, hq, heq⟩
    by_cases hpq : p = q
    · subst hpq; exact hM.ne_self p hp heq.symm
    · exact (hM.disjoint_pairs p hp q hq hpq).2.1 heq.symm
  have hcard1 : (M.image Prod.fst).card = M.card := Finset.card_image_of_injOn hinj1
  have hcard2 : (M.image Prod.snd).card = M.card := Finset.card_image_of_injOn hinj2
  have hcardU : U.card = 2 * M.card := by
    rw [Finset.card_union_of_disjoint hdisj, hcard1, hcard2, two_mul]
  have hsumU : ∑ a ∈ U, w a = 0 := by
    rw [Finset.sum_union hdisj, Finset.sum_image (fun p hp q hq h => hinj1 hp hq h),
      Finset.sum_image (fun p hp q hq h => hinj2 hp hq h), ← Finset.sum_add_distrib]
    exact Finset.sum_eq_zero fun p hp => hM.pair_sum_zero p hp
  exact ⟨hU_sub, hcardU, hsumU⟩

theorem norm_sum_le_unmatched_of_matching {α : Type*} [DecidableEq α]
    {S : Finset α} {w : α → ℂ} {M : Finset (α × α)}
    (hw : ∀ a ∈ S, ‖w a‖ ≤ 1) (hM : DisjointZeroMatching S w M) :
    ‖∑ a ∈ S, w a‖ ≤ ((S.card - 2 * M.card : ℕ) : ℝ) := by
  obtain ⟨hU_sub, hcardU, hsumU⟩ := matching_used_props hM
  set U := M.image Prod.fst ∪ M.image Prod.snd
  have hsplit : ∑ a ∈ S, w a = ∑ a ∈ S \ U, w a := by
    have hadd := Finset.sum_sdiff hU_sub (f := w)
    rw [hsumU, add_zero] at hadd
    exact hadd.symm
  rw [hsplit]
  have hbound : ‖∑ a ∈ S \ U, w a‖ ≤ ∑ a ∈ S \ U, (1 : ℝ) := by
    refine le_trans (norm_sum_le _ _) (Finset.sum_le_sum fun a ha => ?_)
    exact hw a (Finset.mem_sdiff.mp ha).1
  simpa [Finset.card_sdiff, Finset.inter_eq_left.mpr hU_sub, hcardU] using hbound

theorem abs_int_sum_le_unmatched_of_matching {α : Type*} [DecidableEq α]
    {S : Finset α} {w : α → ℤ} {M : Finset (α × α)}
    (hw : ∀ a ∈ S, |w a| ≤ 1) (hM : DisjointZeroMatching S w M) :
    |∑ a ∈ S, w a| ≤ ((S.card - 2 * M.card : ℕ) : ℤ) := by
  obtain ⟨hU_sub, hcardU, hsumU⟩ := matching_used_props hM
  set U := M.image Prod.fst ∪ M.image Prod.snd
  have hsplit : ∑ a ∈ S, w a = ∑ a ∈ S \ U, w a := by
    have hadd := Finset.sum_sdiff hU_sub (f := w)
    rw [hsumU, add_zero] at hadd
    exact hadd.symm
  rw [hsplit]
  have hbound : |∑ a ∈ S \ U, w a| ≤ ∑ a ∈ S \ U, (1 : ℤ) := by
    refine le_trans (Finset.abs_sum_le_sum_abs _ _) (Finset.sum_le_sum fun a ha => ?_)
    exact hw a (Finset.mem_sdiff.mp ha).1
  simpa [Finset.card_sdiff, Finset.inter_eq_left.mpr hU_sub, hcardU] using hbound

/-- Class-preserving disjoint matching lower bound for `χ₁ + χ₄` simultaneously. -/
theorem mod4_shared_matching_lower_bound {α : Type*} [DecidableEq α]
    (S : Finset α) (w : α → ℤ) (cls : α → Bool) (M : Finset (α × α))
    (hw : ∀ a ∈ S, |w a| ≤ 1) (hM : DisjointZeroMatching S w M)
    (hcls : ∀ p ∈ M, cls p.1 = cls p.2) :
    let S1 := S.filter (fun a => cls a)
    let S3 := S.filter (fun a => !cls a)
    let A := ∑ a ∈ S1, w a
    let B := ∑ a ∈ S3, w a
    max |A + B| |A - B| ≤ ((S.card - 2 * M.card : ℕ) : ℤ) := by
  intro S1 S3 A B
  rw [← mod4_abs_add_abs_eq_max A B]
  set M1 := M.filter (fun p => cls p.1)
  set M3 := M.filter (fun p => !cls p.1)
  have hM1 : DisjointZeroMatching S1 w M1 := {
    mem_left := fun p hp => by
      have hp' := Finset.mem_filter.mp hp
      exact Finset.mem_filter.mpr ⟨hM.mem_left p hp'.1, hp'.2⟩
    mem_right := fun p hp => by
      have hp' := Finset.mem_filter.mp hp
      exact Finset.mem_filter.mpr ⟨hM.mem_right p hp'.1, hcls p hp'.1 ▸ hp'.2⟩
    ne_self := fun p hp => hM.ne_self p (Finset.mem_filter.mp hp).1
    disjoint_pairs := fun p hp q hq hpq =>
      hM.disjoint_pairs p (Finset.mem_filter.mp hp).1 q (Finset.mem_filter.mp hq).1 hpq
    pair_sum_zero := fun p hp => hM.pair_sum_zero p (Finset.mem_filter.mp hp).1
  }
  have hM3 : DisjointZeroMatching S3 w M3 := {
    mem_left := fun p hp => by
      have hp' := Finset.mem_filter.mp hp
      exact Finset.mem_filter.mpr ⟨hM.mem_left p hp'.1, hp'.2⟩
    mem_right := fun p hp => by
      have hp' := Finset.mem_filter.mp hp
      exact Finset.mem_filter.mpr ⟨hM.mem_right p hp'.1, (hcls p hp'.1) ▸ hp'.2⟩
    ne_self := fun p hp => hM.ne_self p (Finset.mem_filter.mp hp).1
    disjoint_pairs := fun p hp q hq hpq =>
      hM.disjoint_pairs p (Finset.mem_filter.mp hp).1 q (Finset.mem_filter.mp hq).1 hpq
    pair_sum_zero := fun p hp => hM.pair_sum_zero p (Finset.mem_filter.mp hp).1
  }
  have hle1 : |A| ≤ ((S1.card - 2 * M1.card : ℕ) : ℤ) :=
    abs_int_sum_le_unmatched_of_matching (fun a ha => hw a (Finset.mem_filter.mp ha).1) hM1
  have hle3 : |B| ≤ ((S3.card - 2 * M3.card : ℕ) : ℤ) :=
    abs_int_sum_le_unmatched_of_matching (fun a ha => hw a (Finset.mem_filter.mp ha).1) hM3
  have hS_part : S1.card + S3.card = S.card := by
    simpa [S1, S3, Bool.not_eq_true'] using
      Finset.card_filter_add_card_filter_not (fun a => cls a = true) (s := S)
  have hM_part : M1.card + M3.card = M.card := by
    simpa [M1, M3, Bool.not_eq_true'] using
      Finset.card_filter_add_card_filter_not (fun p => cls p.1 = true) (s := M)
  have h1len : 2 * M1.card ≤ S1.card := by
    obtain ⟨hU, hcU, _⟩ := matching_used_props hM1
    rw [← hcU]
    exact Finset.card_le_card hU
  have h3len : 2 * M3.card ≤ S3.card := by
    obtain ⟨hU, hcU, _⟩ := matching_used_props hM3
    rw [← hcU]
    exact Finset.card_le_card hU
  omega

/-- Active squarefree denominator vertices in `(x/2, x]` coprime to `6`. -/
def activeBand (x : ℝ) : Finset ℕ :=
  (Ratioque.VernierBridge.bandSet x).filter (fun q => Squarefree q)

private lemma twistedV_eq_sum_activeBand {N : ℕ} (χ : DirichletCharacter ℂ N) (x : ℝ) :
    Ratioque.CrystalBridge.twistedV χ x =
      ∑ q ∈ activeBand x, Ratioque.CrystalBridge.twistedCoeff χ q := by
  unfold Ratioque.CrystalBridge.twistedV activeBand Ratioque.VernierBridge.bandSet
  conv_rhs => rw [Finset.sum_filter]
  refine Finset.sum_congr rfl fun q _ => ?_
  by_cases hsq : Squarefree q
  · simp [hsq]
  · have hm : ArithmeticFunction.moebius q = 0 :=
      ArithmeticFunction.moebius_eq_zero_of_not_squarefree hsq
    simp [hsq, Ratioque.CrystalBridge.twistedCoeff, hm]

private theorem twistedVCancellation_of_matching_family {N : ℕ} (χ : DirichletCharacter ℂ N)
    (h : ∃ M : ℝ → Finset (ℕ × ℕ),
      (∀ x, DisjointZeroMatching (activeBand x) (Ratioque.CrystalBridge.twistedCoeff χ) (M x)) ∧
      (∀ ε : ℝ, 0 < ε → (fun x : ℝ => (((activeBand x).card - 2 * (M x).card : ℕ) : ℝ)) =O[atTop]
        (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε)))) :
    Ratioque.CrystalBridge.TwistedVCancellation χ := by
  rcases h with ⟨M, hM, hO⟩
  intro ε hε
  obtain ⟨c, hc⟩ := (hO ε hε).bound
  rw [Asymptotics.isBigO_iff]
  refine ⟨c, ?_⟩
  filter_upwards [hc] with x hx
  have hw : ∀ q ∈ activeBand x, ‖Ratioque.CrystalBridge.twistedCoeff χ q‖ ≤ 1 := by
    intro q _
    rw [Ratioque.CrystalBridge.twistedCoeff, norm_mul]
    have h1 : ‖χ q‖ ≤ 1 := DirichletCharacter.norm_le_one χ q
    have h2 : ‖(ArithmeticFunction.moebius q : ℂ)‖ ≤ 1 := by
      rw [Complex.norm_intCast]
      exact_mod_cast ArithmeticFunction.abs_moebius_le_one
    nlinarith [norm_nonneg (χ q), norm_nonneg (ArithmeticFunction.moebius q : ℂ)]
  have hle := norm_sum_le_unmatched_of_matching hw (hM x)
  rw [← twistedV_eq_sum_activeBand χ x] at hle
  have hnonneg : 0 ≤ (((activeBand x).card - 2 * (M x).card : ℕ) : ℝ) := Nat.cast_nonneg _
  have hnorm_eq : ‖(((activeBand x).card - 2 * (M x).card : ℕ) : ℝ)‖ =
      (((activeBand x).card - 2 * (M x).card : ℕ) : ℝ) := Real.norm_of_nonneg hnonneg
  rw [hnorm_eq] at hx
  exact le_trans hle hx

/-- Ordinary RH if an explicit disjoint zero-pair matching leaves `O_ε(X^(1/2+ε))` unmatched rows. -/
theorem riemannHypothesis_of_disjoint_matching_bound
    (h : ∃ M : ℝ → Finset (ℕ × ℕ),
      (∀ x, DisjointZeroMatching (activeBand x)
        (Ratioque.CrystalBridge.twistedCoeff (1 : DirichletCharacter ℂ 1)) (M x)) ∧
      (∀ ε : ℝ, 0 < ε → (fun x : ℝ => (((activeBand x).card - 2 * (M x).card : ℕ) : ℝ)) =O[atTop]
        (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε)))) :
    RiemannHypothesis :=
  Ratioque.CrystalBridge.riemannHypothesis_of_V_cancellation
    (twistedVCancellation_of_matching_family (1 : DirichletCharacter ℂ 1) h)

/-- `EveryCharacter` (`allChi`) if every `χ` admits a disjoint zero-pair matching leaving `O_ε(X^(1/2+ε))` rows. -/
theorem everyCharacter_of_allChi_disjoint_matching_bound
    (h : ∀ (N : ℕ) [NeZero N] (χ : DirichletCharacter ℂ N),
      ∃ M : ℝ → Finset (ℕ × ℕ),
        (∀ x, DisjointZeroMatching (activeBand x) (Ratioque.CrystalBridge.twistedCoeff χ) (M x)) ∧
        (∀ ε : ℝ, 0 < ε → (fun x : ℝ => (((activeBand x).card - 2 * (M x).card : ℕ) : ℝ)) =O[atTop]
          (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε)))) :
    Ratioque.CrystalBridge.EveryCharacter :=
  Ratioque.CrystalBridge.everyCharacter_of_allChi_V_cancellation fun N _ χ =>
    twistedVCancellation_of_matching_family χ (h N χ)

/-! ### 4. Obstruction 1: Fixed-Menu Prime Obstruction -/

/-- Any prime `p ∈ (x/2, x]` exceeding `Bmax` can NEVER be matched by any distinct pair `(A*k, B*k)`
    with both endpoints in `(x/2, x]` from a finite template set `T` (`1 ≤ A, B ≤ Bmax`, `A ≠ B`). -/
theorem fixed_menu_prime_obstruction
    (T : Finset (ℕ × ℕ)) (hT : ∀ t ∈ T, 1 ≤ t.1 ∧ 1 ≤ t.2 ∧ t.1 ≠ t.2)
    {x : ℝ} (hx : 2 ≤ x) {p : ℕ} (hp : Nat.Prime p)
    (_hpin : p ∈ Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊)
    (hpmax : T.sup (fun t => max t.1 t.2) < p) :
    ¬ ∃ (t : ℕ × ℕ) (k : ℕ), t ∈ T ∧
      t.1 * k ∈ Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊ ∧
      t.2 * k ∈ Finset.Ioc ⌊x / 2⌋₊ ⌊x⌋₊ ∧
      (p = t.1 * k ∨ p = t.2 * k) := by
  rintro ⟨⟨A, B⟩, k, ht, hAk, hBk, hp_eq⟩
  obtain ⟨hA1, hB1, hAB⟩ := hT (A, B) ht
  have hle_sup : max A B ≤ T.sup (fun t => max t.1 t.2) :=
    Finset.le_sup (f := fun t : ℕ × ℕ => max t.1 t.2) ht
  have hAlt : A < p := lt_of_le_of_lt (le_trans (le_max_left A B) hle_sup) hpmax
  have hBlt : B < p := lt_of_le_of_lt (le_trans (le_max_right A B) hle_sup) hpmax
  rw [Finset.mem_Ioc] at hAk hBk
  have htwo : ⌊x⌋₊ < 2 * (⌊x / 2⌋₊ + 1) := by
    have hfl : (⌊x / 2⌋₊ : ℝ) + 1 > x / 2 := Nat.lt_floor_add_one (x / 2)
    have hx_le : (⌊x⌋₊ : ℝ) ≤ x := Nat.floor_le (by linarith)
    have hreal : (⌊x⌋₊ : ℝ) < (2 * (⌊x / 2⌋₊ + 1) : ℕ) := by
      push_cast
      linarith
    exact_mod_cast hreal
  have hAne1 : A ≠ 1 := by
    intro hAeq
    subst hAeq
    have hB2 : 2 ≤ B := by omega
    have hlt : ⌊x⌋₊ < B * k := by
      calc ⌊x⌋₊ < 2 * (⌊x / 2⌋₊ + 1) := htwo
      _ ≤ 2 * (1 * k) := by omega
      _ = 2 * k := by ring
      _ ≤ B * k := Nat.mul_le_mul_right k hB2
    exact Nat.not_lt.mpr hBk.2 hlt
  have hBne1 : B ≠ 1 := by
    intro hBeq
    subst hBeq
    have hA2 : 2 ≤ A := by omega
    have hlt : ⌊x⌋₊ < A * k := by
      calc ⌊x⌋₊ < 2 * (⌊x / 2⌋₊ + 1) := htwo
      _ ≤ 2 * (1 * k) := by omega
      _ = 2 * k := by ring
      _ ≤ A * k := Nat.mul_le_mul_right k hA2
    exact Nat.not_lt.mpr hAk.2 hlt
  rcases hp_eq with h1 | h2
  · have hdvd : A ∣ p := ⟨k, h1⟩
    rcases (Nat.dvd_prime hp).mp hdvd with h | h
    · exact hAne1 h
    · omega
  · have hdvd : B ∣ p := ⟨k, h2⟩
    rcases (Nat.dvd_prime hp).mp hdvd with h | h
    · exact hBne1 h
    · omega

/-! ### 5. Obstruction 2: No Universal Character-Blind Inter-Denominator Pairing -/

theorem no_universal_inter_denominator_pair {q r : ℕ} (hq : 1 ≤ q) (hr : 1 ≤ r) (hne : q ≠ r) :
    ∃ (p : ℕ) (_ : NeZero p) (χ : DirichletCharacter ℂ p), χ q ≠ χ r := by
  obtain ⟨p, hp_ge, hp_prime⟩ := Nat.exists_infinite_primes (max q r + 1)
  have : Fact p.Prime := ⟨hp_prime⟩
  have : NeZero p := ⟨hp_prime.ne_zero⟩
  have hq_lt : q < p := by omega
  have hr_lt : r < p := by omega
  have hq_nz : (q : ZMod p) ≠ 0 := by
    intro h
    have hdvd : p ∣ q := (ZMod.natCast_eq_zero_iff q p).mp h
    have : p ≤ q := Nat.le_of_dvd hq hdvd
    omega
  have hr_nz : (r : ZMod p) ≠ 0 := by
    intro h
    have hdvd : p ∣ r := (ZMod.natCast_eq_zero_iff r p).mp h
    have : p ≤ r := Nat.le_of_dvd hr hdvd
    omega
  have hne_zmod : (q : ZMod p) ≠ (r : ZMod p) := by
    intro heq
    have hq_val := congrArg ZMod.val heq
    rw [ZMod.val_natCast_of_lt hq_lt, ZMod.val_natCast_of_lt hr_lt] at hq_val
    exact hne hq_val
  have hunit_q : IsUnit (q : ZMod p) := Ne.isUnit hq_nz
  have hratio_ne : (q : ZMod p)⁻¹ * (r : ZMod p) ≠ 1 := by
    intro h1
    have hmul := congrArg (fun z => (q : ZMod p) * z) h1
    simp only [← mul_assoc, ZMod.mul_inv_of_unit _ hunit_q, one_mul, mul_one] at hmul
    exact hne_zmod hmul.symm
  obtain ⟨χ, hχ⟩ := DirichletCharacter.exists_apply_ne_one_of_hasEnoughRootsOfUnity ℂ hratio_ne
  refine ⟨p, inferInstance, χ, ?_⟩
  intro heq
  apply hχ
  have h1 : χ (q : ZMod p) * χ ((q : ZMod p)⁻¹ * (r : ZMod p)) = χ (q : ZMod p) * 1 := by
    rw [← map_mul, ← mul_assoc, ZMod.mul_inv_of_unit _ hunit_q, one_mul, mul_one]
    exact heq.symm
  have hχq_nz : χ (q : ZMod p) ≠ 0 :=
    norm_ne_zero_iff.mp (by
      rw [← hunit_q.unit_spec, DirichletCharacter.unit_norm_eq_one χ hunit_q.unit]
      exact one_ne_zero)
  exact mul_left_cancel₀ hχq_nz h1

/-! ### 6. Dirac-Fock Bipartite Operator, Rank-Nullity Reduction & Uniform-Coupling Defect -/

/-- Self-adjoint off-diagonal bipartite Dirac operator `[[0, B], [Bᴴ, 0]]`. -/
def diracMatrix {P N : Type*} (B : Matrix P N ℂ) : Matrix (P ⊕ N) (P ⊕ N) ℂ :=
  Matrix.fromBlocks (0 : Matrix P P ℂ) B Bᴴ (0 : Matrix N N ℂ)

theorem diracMatrix_isHermitian {P N : Type*} [Fintype P] [Fintype N] (B : Matrix P N ℂ) :
    (diracMatrix B).IsHermitian := by
  apply Matrix.IsHermitian.ext
  intro i j
  cases i with
  | inl i =>
    cases j with
    | inl j => simp [diracMatrix]
    | inr j => simp [diracMatrix]
  | inr i =>
    cases j with
    | inl j => simp [diracMatrix]
    | inr j => simp [diracMatrix]

private lemma dirac_mulVec_eq_zero_iff {P N : Type*} [Fintype P] [Fintype N]
    (B : Matrix P N ℂ) (v : P ⊕ N → ℂ) :
    (diracMatrix B).mulVec v = 0 ↔
      Bᴴ.mulVec (v ∘ Sum.inl) = 0 ∧ B.mulVec (v ∘ Sum.inr) = 0 := by
  unfold diracMatrix
  constructor
  · intro h
    refine ⟨?_, ?_⟩
    · ext j
      have hj := congrFun h (Sum.inr j)
      simpa [Matrix.mulVec, dotProduct, Fintype.sum_sum_type] using hj
    · ext i
      have hi := congrFun h (Sum.inl i)
      simpa [Matrix.mulVec, dotProduct, Fintype.sum_sum_type] using hi
  · rintro ⟨h1, h2⟩
    ext x
    cases x with
    | inl i =>
      have hi := congrFun h2 i
      simpa [Matrix.mulVec, dotProduct, Fintype.sum_sum_type] using hi
    | inr j =>
      have hj := congrFun h1 j
      simpa [Matrix.mulVec, dotProduct, Fintype.sum_sum_type] using hj

/-- `ker(diracMatrix B) ≃ ker(Bᴴ) × ker(B)` as `ℂ`-linear spaces. -/
def diracKerEquiv {P N : Type*} [Fintype P] [Fintype N] (B : Matrix P N ℂ) :
    LinearMap.ker (diracMatrix B).mulVecLin ≃ₗ[ℂ]
      LinearMap.ker Bᴴ.mulVecLin × LinearMap.ker B.mulVecLin where
  toFun v :=
    (⟨v.1 ∘ Sum.inl, ((dirac_mulVec_eq_zero_iff B v.1).mp v.2).1⟩,
     ⟨v.1 ∘ Sum.inr, ((dirac_mulVec_eq_zero_iff B v.1).mp v.2).2⟩)
  invFun p :=
    ⟨Sum.elim p.1.1 p.2.1, (dirac_mulVec_eq_zero_iff B (Sum.elim p.1.1 p.2.1)).mpr
      ⟨p.1.2, p.2.2⟩⟩
  left_inv v := by
    ext x
    cases x <;> rfl
  right_inv p := by
    ext x <;> rfl
  map_add' v w := by
    ext x <;> rfl
  map_smul' c v := by
    ext x <;> rfl

theorem diracMatrix_finrank_ker {P N : Type*} [Fintype P] [Fintype N] (B : Matrix P N ℂ) :
    Module.finrank ℂ (LinearMap.ker (diracMatrix B).mulVecLin) =
      Fintype.card P + Fintype.card N - 2 * B.rank := by
  have heq : Module.finrank ℂ (LinearMap.ker (diracMatrix B).mulVecLin) =
      Module.finrank ℂ (LinearMap.ker Bᴴ.mulVecLin) +
        Module.finrank ℂ (LinearMap.ker B.mulVecLin) := by
    rw [(diracKerEquiv B).finrank_eq, Module.finrank_prod]
  have hB : B.rank + Module.finrank ℂ (LinearMap.ker B.mulVecLin) = Fintype.card N := by
    unfold Matrix.rank
    rw [LinearMap.finrank_range_add_finrank_ker, Module.finrank_fintype_fun_eq_card]
  have hBH : B.rank + Module.finrank ℂ (LinearMap.ker Bᴴ.mulVecLin) = Fintype.card P := by
    have hr : Bᴴ.rank = B.rank := Matrix.rank_conjTranspose B
    rw [← hr]
    unfold Matrix.rank
    rw [LinearMap.finrank_range_add_finrank_ker, Module.finrank_fintype_fun_eq_card]
  omega

theorem abs_grade_diff_le_dirac_ker {P N : Type*} [Fintype P] [Fintype N] (B : Matrix P N ℂ) :
    |((Fintype.card P : ℤ) - (Fintype.card N : ℤ))| ≤
      (Module.finrank ℂ (LinearMap.ker (diracMatrix B).mulVecLin) : ℤ) := by
  have hB : B.rank ≤ Fintype.card N := by
    unfold Matrix.rank
    have := LinearMap.finrank_range_add_finrank_ker B.mulVecLin
    rw [Module.finrank_fintype_fun_eq_card] at this
    omega
  have hBH : B.rank ≤ Fintype.card P := by
    have hr : Bᴴ.rank = B.rank := Matrix.rank_conjTranspose B
    rw [← hr]
    unfold Matrix.rank
    have := LinearMap.finrank_range_add_finrank_ker Bᴴ.mulVecLin
    rw [Module.finrank_fintype_fun_eq_card] at this
    omega
  rw [diracMatrix_finrank_ker B]
  rcases abs_cases ((Fintype.card P : ℤ) - (Fintype.card N : ℤ)) with ⟨_, _⟩ | ⟨_, _⟩ <;> omega

/-- Uniform-coupling defect: if `S` columns of `B` are identical, `|S| - 1 ≤ dim ker B`. -/
theorem uniform_coupling_nullity {P N : Type*} [Fintype P] [Fintype N] [DecidableEq N]
    (B : Matrix P N ℂ) (S : Finset N)
    (hunif : ∀ i ∈ S, ∀ j ∈ S, ∀ r : P, B r i = B r j) :
    S.card - 1 ≤ Module.finrank ℂ (LinearMap.ker B.mulVecLin) := by
  by_cases hne : S.Nonempty
  · obtain ⟨i₀, hi₀⟩ := hne
    let S' : Finset N := S.erase i₀
    have hcard : S'.card = S.card - 1 := Finset.card_erase_of_mem hi₀
    rw [← hcard]
    let f : S' → LinearMap.ker B.mulVecLin := fun j =>
      ⟨Pi.single j.1 1 - Pi.single i₀ 1, by
        rw [LinearMap.mem_ker]
        ext r
        have hj_mem : j.1 ∈ S := Finset.mem_of_mem_erase j.2
        simp only [Matrix.mulVecLin_apply, Pi.zero_apply, Matrix.mulVec_sub, Pi.sub_apply]
        have h1 : B.mulVec (Pi.single j.1 1) r = B r j.1 := by
          simp [Matrix.mulVec, dotProduct, Pi.single_apply]
        have h2 : B.mulVec (Pi.single i₀ 1) r = B r i₀ := by
          simp [Matrix.mulVec, dotProduct, Pi.single_apply]
        rw [h1, h2, hunif j.1 hj_mem i₀ hi₀ r, sub_self]⟩
    have hli : LinearIndependent ℂ f := by
      rw [Fintype.linearIndependent_iff]
      intro c hc j
      have hj_ne : j.1 ≠ i₀ := Finset.ne_of_mem_erase j.2
      have hcoord := congrArg (fun v : LinearMap.ker B.mulVecLin => v.1 j.1) hc
      simp only [Finset.sum_apply, Submodule.coe_sum, ZeroMemClass.coe_zero, Pi.zero_apply,
        SetLike.val_smul, Pi.smul_apply, smul_eq_mul, f, Pi.sub_apply,
        Pi.single_apply, hj_ne, ↓reduceIte, sub_zero] at hcoord
      rw [Finset.sum_eq_single j] at hcoord
      · simpa using hcoord
      · intro k _ hkne
        have : j.1 ≠ k.1 := fun h => hkne (Subtype.ext h.symm)
        simp [this]
      · intro hnot; exact absurd (Finset.mem_univ j) hnot
    simpa [Fintype.card_coe] using hli.fintype_card_le_finrank
  · rw [Finset.not_nonempty_iff_eq_empty.mp hne]
    simp

/-- Positive and negative grades of `activeBand x` for ordinary `μ(q)` (`χ = 1`). -/
def posBand (x : ℝ) : Finset ℕ :=
  (activeBand x).filter (fun q => ArithmeticFunction.moebius q = 1)

def negBand (x : ℝ) : Finset ℕ :=
  (activeBand x).filter (fun q => ArithmeticFunction.moebius q = -1)

theorem norm_V_eq_abs_grade_diff (x : ℝ) :
    ‖Ratioque.CrystalBridge.V x‖ = |((posBand x).card : ℤ) - ((negBand x).card : ℤ)| := by
  rw [Ratioque.CrystalBridge.V, twistedV_eq_sum_activeBand]
  have hdisj : Disjoint (posBand x) (negBand x) := by
    rw [Finset.disjoint_left]
    intro q hp hn
    rw [posBand, Finset.mem_filter] at hp
    rw [negBand, Finset.mem_filter] at hn
    omega
  have hunion : posBand x ∪ negBand x = activeBand x := by
    ext q
    simp only [Finset.mem_union, posBand, negBand, Finset.mem_filter, activeBand]
    constructor
    · rintro (h | h) <;> exact h.1
    · intro h
      have hsq : Squarefree q := h.2
      have hmu := ArithmeticFunction.moebius_ne_zero_iff_squarefree.mpr hsq
      rcases ArithmeticFunction.moebius_ne_zero_iff_eq_or.mp hmu with hm | hm
      · exact Or.inl ⟨h, hm⟩
      · exact Or.inr ⟨h, hm⟩
  have hsum : ∑ q ∈ activeBand x,
      Ratioque.CrystalBridge.twistedCoeff (1 : DirichletCharacter ℂ 1) q =
      (((posBand x).card : ℤ) - ((negBand x).card : ℤ) : ℂ) := by
    rw [← hunion, Finset.sum_union hdisj]
    have hp_sum : ∑ q ∈ posBand x,
        Ratioque.CrystalBridge.twistedCoeff (1 : DirichletCharacter ℂ 1) q =
        ((posBand x).card : ℂ) := by
      have : ∀ q ∈ posBand x, Ratioque.CrystalBridge.twistedCoeff (1 : DirichletCharacter ℂ 1) q = 1 := by
        intro q hq
        rw [posBand, Finset.mem_filter] at hq
        simp [Ratioque.CrystalBridge.twistedCoeff, hq.2, MulChar.one_apply (isUnit_of_subsingleton _)]
      rw [Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul, mul_one]
    have hn_sum : ∑ q ∈ negBand x,
        Ratioque.CrystalBridge.twistedCoeff (1 : DirichletCharacter ℂ 1) q =
        -((negBand x).card : ℂ) := by
      have : ∀ q ∈ negBand x, Ratioque.CrystalBridge.twistedCoeff (1 : DirichletCharacter ℂ 1) q = -1 := by
        intro q hq
        rw [negBand, Finset.mem_filter] at hq
        simp [Ratioque.CrystalBridge.twistedCoeff, hq.2, MulChar.one_apply (isUnit_of_subsingleton _)]
      rw [Finset.sum_congr rfl this, Finset.sum_const, nsmul_eq_mul, mul_neg_one]
    rw [hp_sum, hn_sum]
    push_cast
    ring
  rw [hsum, ← Int.cast_sub, Complex.norm_intCast, ← Int.cast_abs]

theorem norm_V_le_dirac_ker (x : ℝ) (B : Matrix (posBand x) (negBand x) ℂ) :
    ‖Ratioque.CrystalBridge.V x‖ ≤
      (Module.finrank ℂ (LinearMap.ker (diracMatrix B).mulVecLin) : ℝ) := by
  rw [norm_V_eq_abs_grade_diff x]
  have h := abs_grade_diff_le_dirac_ker B
  simp only [Fintype.card_coe] at h
  exact_mod_cast h

/-- Dirac-Fock RH reduction: a family of bipartite operators `B x : Matrix (posBand x) (negBand x) ℂ`
    with `rank(B x) ≥ (Q(x) - O_ε(x^(1/2+ε))) / 2` implies `RiemannHypothesis`. -/
theorem riemannHypothesis_of_dirac_rank_bound
    (B : ∀ x : ℝ, Matrix (posBand x) (negBand x) ℂ)
    (hrank : ∀ ε : ℝ, 0 < ε →
      (fun x : ℝ => (((activeBand x).card - 2 * (B x).rank : ℕ) : ℝ)) =O[atTop]
        (fun x : ℝ => x ^ ((1 / 2 : ℝ) + ε))) :
    RiemannHypothesis := by
  refine Ratioque.CrystalBridge.riemannHypothesis_of_V_cancellation fun ε hε => ?_
  obtain ⟨c, hc⟩ := (hrank ε hε).bound
  rw [Asymptotics.isBigO_iff]
  refine ⟨c, ?_⟩
  filter_upwards [hc] with x hx
  have hdisj : Disjoint (posBand x) (negBand x) := by
    rw [Finset.disjoint_left]
    intro q hp hn
    rw [posBand, Finset.mem_filter] at hp
    rw [negBand, Finset.mem_filter] at hn
    omega
  have hunion : posBand x ∪ negBand x = activeBand x := by
    ext q
    simp only [Finset.mem_union, posBand, negBand, Finset.mem_filter, activeBand]
    constructor
    · rintro (h | h) <;> exact h.1
    · intro h
      have hmu := ArithmeticFunction.moebius_ne_zero_iff_squarefree.mpr h.2
      rcases ArithmeticFunction.moebius_ne_zero_iff_eq_or.mp hmu with hm | hm
      · exact Or.inl ⟨h, hm⟩
      · exact Or.inr ⟨h, hm⟩
  have hcard : (posBand x).card + (negBand x).card = (activeBand x).card := by
    rw [← hunion, Finset.card_union_of_disjoint hdisj]
  have hker := norm_V_le_dirac_ker x (B x)
  rw [diracMatrix_finrank_ker (B x), Fintype.card_coe, Fintype.card_coe, hcard] at hker
  have hnorm_eq : ‖(((activeBand x).card - 2 * (B x).rank : ℕ) : ℝ)‖ =
      (((activeBand x).card - 2 * (B x).rank : ℕ) : ℝ) := Real.norm_of_nonneg (Nat.cast_nonneg _)
  rw [hnorm_eq] at hx
  exact le_trans hker hx

end Ratioque.VernierPairingDirac

#print axioms Ratioque.VernierPairingDirac.causalLifo_unmatched_eq_abs_sum
#print axioms Ratioque.VernierPairingDirac.mod4_abs_add_abs_eq_max
#print axioms Ratioque.VernierPairingDirac.mod4Lifo_unmatched_eq_max
#print axioms Ratioque.VernierPairingDirac.norm_sum_le_unmatched_of_matching
#print axioms Ratioque.VernierPairingDirac.mod4_shared_matching_lower_bound
#print axioms Ratioque.VernierPairingDirac.riemannHypothesis_of_disjoint_matching_bound
#print axioms Ratioque.VernierPairingDirac.everyCharacter_of_allChi_disjoint_matching_bound
#print axioms Ratioque.VernierPairingDirac.fixed_menu_prime_obstruction
#print axioms Ratioque.VernierPairingDirac.no_universal_inter_denominator_pair
#print axioms Ratioque.VernierPairingDirac.diracMatrix_isHermitian
#print axioms Ratioque.VernierPairingDirac.diracMatrix_finrank_ker
#print axioms Ratioque.VernierPairingDirac.uniform_coupling_nullity
#print axioms Ratioque.VernierPairingDirac.norm_V_le_dirac_ker
#print axioms Ratioque.VernierPairingDirac.riemannHypothesis_of_dirac_rank_bound
