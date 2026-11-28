import Ruliology.CellularAutomata.Rule30GateTrap
import Mathlib.Order.Interval.Finset.Nat
import Mathlib.Tactic

namespace FVLT.Rule30GateReturnFrequencyV1

open Ruliology.CellularAutomata
open Rule30PeriodTwoSideways

theorem successive_returns_exists_unique
    (R : Nat → Bool) (t0 start : Nat)
    (ht0 : t0 % 2 = 1)
    (hentry : Rule30GateTrap.win R t0 ∈ Rule30GateTrap.trap)
    (hstart : u R start = true) (hafter : t0 ≤ 2 * start + 1) :
    ∃! s : Nat → Nat,
      s 0 = start ∧
      (∀ n, u R (s n) = true) ∧
      (∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5) ∧
      (∀ n i, s n < i → i < s (n + 1) → u R i = false) := by
  classical
  let next : Nat → Nat := fun a => if u R (a + 3) = true then a + 3 else a + 5
  have hnext (a : Nat) (ha : u R a = true) (hat : t0 ≤ 2 * a + 1) :
      u R (next a) = true ∧
      (next a = a + 3 ∨ next a = a + 5) ∧
      (∀ i, a < i → i < next a → u R i = false) := by
    rcases Rule30GateTrap.gaps_of_entry R ht0 hentry a hat ha with
      ⟨h1, h2, h3⟩ | ⟨h1, h2, h3, h4, h5⟩
    · have hn : next a = a + 3 := by simp [next, h3]
      rw [hn]
      refine ⟨h3, Or.inl rfl, ?_⟩
      intro i hi hj
      have he : i = a + 1 ∨ i = a + 2 := by omega
      rcases he with rfl | rfl
      · exact h1
      · exact h2
    · have hn : next a = a + 5 := by simp [next, h3]
      rw [hn]
      refine ⟨h5, Or.inr rfl, ?_⟩
      intro i hi hj
      have he : i = a + 1 ∨ i = a + 2 ∨ i = a + 3 ∨ i = a + 4 := by omega
      rcases he with rfl | rfl | rfl | rfl
      · exact h1
      · exact h2
      · exact h3
      · exact h4
  let s : Nat → Nat := Nat.rec start (fun _ a => next a)
  have hs : ∀ n, s (n + 1) = next (s n) := fun _ => rfl
  have hb : ∀ n, u R (s n) = true ∧ t0 ≤ 2 * s n + 1 := by
    intro n
    induction n with
    | zero => exact ⟨hstart, hafter⟩
    | succ n ih =>
      rw [hs]
      obtain ⟨hblack, hgap, hwhite⟩ := hnext (s n) ih.1 ih.2
      refine ⟨hblack, ?_⟩
      rcases hgap with hg | hg <;> omega
  have hg : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5 := by
    intro n
    rw [hs]
    exact (hnext (s n) (hb n).1 (hb n).2).2.1
  have hw : ∀ n i, s n < i → i < s (n + 1) → u R i = false := by
    intro n
    rw [hs]
    exact (hnext (s n) (hb n).1 (hb n).2).2.2
  refine ⟨s, ⟨rfl, fun n => (hb n).1, hg, hw⟩, ?_⟩
  intro z hz
  rcases hz with ⟨hz0, hzb, hzg, hzw⟩
  funext n
  induction n with
  | zero => exact hz0
  | succ n ih =>
    have ha := hg n
    have hb' := hzg n
    rw [ih] at hb'
    by_contra hne
    rcases ha with ha | ha <;> rcases hb' with hb' | hb'
    · omega
    · have hwhite := hzw n (s (n + 1)) (by omega) (by omega)
      have hblack := (hb (n + 1)).1
      rw [hblack] at hwhite
      contradiction
    · have hwhite := hw n (z (n + 1)) (by omega) (by omega)
      have hblack := hzb (n + 1)
      rw [hblack] at hwhite
      contradiction
    · omega

theorem return_span_eq_three_mul_add_two_five_count
    (s : Nat → Nat)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (N : Nat) :
    s N = s 0 + 3 * N +
      2 * ((Finset.range N).filter (fun j => s (j + 1) = s j + 5)).card := by
  classical
  induction N with
  | zero => simp
  | succ N ih =>
    have hc :
        ((Finset.range (N + 1)).filter (fun j => s (j + 1) = s j + 5)).card =
        ((Finset.range N).filter (fun j => s (j + 1) = s j + 5)).card +
          (if s (N + 1) = s N + 5 then 1 else 0) := by
      by_cases h : s (N + 1) = s N + 5 <;> simp [Finset.range_add_one, Finset.filter_insert, h]
    rw [hc]
    rcases hgap N with h | h
    · have hn : s (N + 1) ≠ s N + 5 := by omega
      rw [if_neg hn]
      omega
    · rw [if_pos h]
      omega

theorem return_interval_black_count
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false)
    (N : Nat) :
    ((Finset.Ico (s 0) (s N)).filter (fun i => u R i = true)).card = N := by
  classical
  have hle : ∀ n, s 0 ≤ s n := by
    intro n
    induction n with
    | zero => exact Nat.le_refl _
    | succ n ih => rcases hgap n with h | h <;> omega
  induction N with
  | zero => simp
  | succ N ih =>
    have hlt : s N < s (N + 1) := by rcases hgap N with h | h <;> omega
    have heq :
        (Finset.Ico (s 0) (s (N + 1))).filter (fun i => u R i = true) =
        insert (s N) ((Finset.Ico (s 0) (s N)).filter (fun i => u R i = true)) := by
      ext i
      simp only [Finset.mem_filter, Finset.mem_Ico, Finset.mem_insert]
      constructor
      · rintro ⟨⟨ha, hb⟩, hc⟩
        by_cases hi : i < s N
        · exact Or.inr ⟨⟨ha, hi⟩, hc⟩
        · left
          by_contra hne
          have hh := hwhite N i (by omega) hb
          rw [hc] at hh
          contradiction
      · rintro (rfl | ⟨⟨ha, hb⟩, hc⟩)
        · exact ⟨⟨hle N, hlt⟩, hblack N⟩
        · exact ⟨⟨ha, by omega⟩, hc⟩
    have hnot : s N ∉ (Finset.Ico (s 0) (s N)).filter (fun i => u R i = true) := by simp
    rw [heq, Finset.card_insert_of_notMem hnot, ih]

end FVLT.Rule30GateReturnFrequencyV1
