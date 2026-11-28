import FVLTRule30GateReturnFrequencyV1
import Mathlib.Analysis.SpecificLimits.Basic
import Mathlib.Tactic

namespace FVLT.Rule30GateReturnFrequencyV1

open Filter
open scoped Topology
open Ruliology.CellularAutomata
open Rule30PeriodTwoSideways

private theorem returns_strictMono
    (s : Nat → Nat)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5) :
    StrictMono s := by
  apply strictMono_nat_of_lt_succ
  intro n
  rcases hgap n with h | h <;> omega

private theorem gate_count_prefix_split
    (R : Nat → Bool) (start T : Nat) (hT : start ≤ T) :
    ((Finset.range T).filter (fun i => u R i = true)).card =
      ((Finset.range start).filter (fun i => u R i = true)).card +
      ((Finset.Ico start T).filter (fun i => u R i = true)).card := by
  classical
  have heq : (Finset.range T).filter (fun i => u R i = true) =
      (Finset.range start).filter (fun i => u R i = true) ∪
        (Finset.Ico start T).filter (fun i => u R i = true) := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_union, Finset.mem_Ico]
    constructor
    · rintro ⟨hi, hb⟩
      by_cases his : i < start
      · exact Or.inl ⟨his, hb⟩
      · exact Or.inr ⟨⟨by omega, hi⟩, hb⟩
    · rintro (⟨hi, hb⟩ | ⟨⟨hi, hj⟩, hb⟩)
      · exact ⟨by omega, hb⟩
      · exact ⟨hj, hb⟩
  have hdis : Disjoint ((Finset.range start).filter (fun i => u R i = true))
      ((Finset.Ico start T).filter (fun i => u R i = true)) := by
    apply Finset.disjoint_left.mpr
    intro i ha hb
    simp only [Finset.mem_filter, Finset.mem_range, Finset.mem_Ico] at ha hb
    omega
  rw [heq, Finset.card_union_of_disjoint hdis]

private theorem return_count_bracket
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false)
    (T : Nat) (hT : s 0 ≤ T) :
    T ≤ s (((Finset.Ico (s 0) T).filter (fun i => u R i = true)).card) ∧
      s (((Finset.Ico (s 0) T).filter (fun i => u R i = true)).card) ≤ T + 4 := by
  classical
  let v := ((Finset.Ico (s 0) T).filter (fun i => u R i = true)).card
  have hm := (returns_strictMono s hgap).monotone
  have hlo : T ≤ s v := by
    by_contra h
    have hs : s v < T := by omega
    have hnot : s v ∉ (Finset.Ico (s 0) (s v)).filter (fun i => u R i = true) := by simp
    have hsub : insert (s v) ((Finset.Ico (s 0) (s v)).filter (fun i => u R i = true)) ⊆
        (Finset.Ico (s 0) T).filter (fun i => u R i = true) := by
      intro i hi
      simp only [Finset.mem_insert, Finset.mem_filter, Finset.mem_Ico] at hi ⊢
      rcases hi with rfl | ⟨⟨ha, hb⟩, hc⟩
      · exact ⟨⟨hm (Nat.zero_le v), hs⟩, hblack v⟩
      · exact ⟨⟨ha, by omega⟩, hc⟩
    have hc := Finset.card_le_card hsub
    rw [Finset.card_insert_of_notMem hnot, return_interval_black_count R s hblack hgap hwhite v] at hc
    change v + 1 ≤ v at hc
    omega
  refine ⟨hlo, ?_⟩
  change s v ≤ T + 4
  cases hv : v with
  | zero => have : s 0 ≤ T := hT; simpa [hv] using (show s 0 ≤ T + 4 by omega)
  | succ n =>
    have hprev : s n < T := by
      by_contra h
      have hsub : (Finset.Ico (s 0) T).filter (fun i => u R i = true) ⊆
          (Finset.Ico (s 0) (s n)).filter (fun i => u R i = true) := by
        intro i hi
        simp only [Finset.mem_filter, Finset.mem_Ico] at hi ⊢
        exact ⟨⟨hi.1.1, by omega⟩, hi.2⟩
      have hc := Finset.card_le_card hsub
      rw [return_interval_black_count R s hblack hgap hwhite n] at hc
      change v ≤ n at hc
      omega
    rcases hgap n with hg | hg <;> omega

private theorem return_count_tendsto_atTop
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false) :
    Tendsto
      (fun T : Nat => ((Finset.Ico (s 0) T).filter (fun i => u R i = true)).card)
      atTop atTop := by
  classical
  apply tendsto_atTop.2
  intro N
  apply eventually_atTop.2
  refine ⟨s N, ?_⟩
  intro T hT
  rw [← return_interval_black_count R s hblack hgap hwhite N]
  apply Finset.card_le_card
  intro i hi
  simp only [Finset.mem_filter, Finset.mem_Ico] at hi ⊢
  exact ⟨⟨hi.1.1, by omega⟩, hi.2⟩

private theorem clock_tendsto_of_frequency
    (s : Nat → Nat)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (phi : ℝ)
    (hfreq : Tendsto
      (fun N : Nat =>
        (((Finset.range N).filter (fun j => s (j + 1) = s j + 5)).card : ℝ) /
          (N : ℝ)) atTop (𝓝 phi)) :
    Tendsto (fun N : Nat => (s N : ℝ) / (N : ℝ)) atTop (𝓝 (3 + 2 * phi)) := by
  classical
  have hlim : Tendsto
      (fun N : Nat => (s 0 : ℝ) / N + 3 +
        2 * ((((Finset.range N).filter (fun j => s (j + 1) = s j + 5)).card : ℝ) / N))
      atTop (𝓝 (3 + 2 * phi)) := by
    simpa using ((tendsto_const_div_atTop_nhds_zero_nat (s 0 : ℝ)).add
      (tendsto_const_nhds (x := (3 : ℝ)))).add
        ((tendsto_const_nhds (x := (2 : ℝ))).mul hfreq)
  apply hlim.congr'
  filter_upwards [eventually_atTop.2 ⟨1, fun N hN => hN⟩] with N hN
  have hn : (N : ℝ) ≠ 0 := by exact_mod_cast (show N ≠ 0 by omega)
  have hs := congrArg (fun n : Nat => (n : ℝ)) (return_span_eq_three_mul_add_two_five_count s hgap N)
  push_cast at hs
  rw [hs]
  field_simp [hn]
  <;> ring

private theorem clock_tendsto_of_density
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false)
    (density : ℝ) (hdensity : 0 < density)
    (hlim : Tendsto
      (fun T : Nat =>
        (((Finset.range T).filter (fun i => u R i = true)).card : ℝ) /
          (T : ℝ)) atTop (𝓝 density)) :
    Tendsto (fun N : Nat => (s N : ℝ) / (N : ℝ)) atTop (𝓝 (1 / density)) := by
  classical
  have hm := returns_strictMono s hgap
  have hs := hm.tendsto_atTop
  have hf := (tendsto_const_div_atTop_nhds_zero_nat
    (((Finset.range (s 0)).filter (fun i => u R i = true)).card : ℝ)).comp hs
  have hinv : Tendsto (fun N : Nat => (N : ℝ) / (s N : ℝ)) atTop (𝓝 density) := by
    have hsub := (hlim.comp hs).sub hf
    have hsub' : Tendsto
        (fun N : Nat =>
          (((Finset.range (s N)).filter (fun i => u R i = true)).card : ℝ) / (s N : ℝ) -
          (((Finset.range (s 0)).filter (fun i => u R i = true)).card : ℝ) / (s N : ℝ))
        atTop (𝓝 density) := by simpa using hsub
    apply hsub'.congr'
    apply Filter.Eventually.of_forall
    intro N
    have hc := gate_count_prefix_split R (s 0) (s N) (hm.monotone (Nat.zero_le N))
    rw [return_interval_black_count R s hblack hgap hwhite N] at hc
    have hcr := congrArg (fun n : Nat => (n : ℝ)) hc
    push_cast at hcr
    change (((Finset.range (s N)).filter (fun i => u R i = true)).card : ℝ) / (s N : ℝ) -
      (((Finset.range (s 0)).filter (fun i => u R i = true)).card : ℝ) / (s N : ℝ) =
      (N : ℝ) / (s N : ℝ)
    rw [hcr]
    ring
  have hrecip : Tendsto (fun N : Nat => (1 : ℝ) / ((N : ℝ) / (s N : ℝ)))
      atTop (𝓝 (1 / density)) :=
    (tendsto_const_nhds (x := (1 : ℝ))).div hinv (ne_of_gt hdensity)
  simpa only [one_div_div] using hrecip

private theorem gate_density_tendsto_of_clock
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false)
    (a : ℝ) (ha : 0 < a)
    (hclock : Tendsto (fun N : Nat => (s N : ℝ) / (N : ℝ)) atTop (𝓝 a)) :
    Tendsto
      (fun T : Nat =>
        (((Finset.range T).filter (fun i => u R i = true)).card : ℝ) /
          (T : ℝ)) atTop (𝓝 (1 / a)) := by
  classical
  let v : Nat → Nat := fun T => ((Finset.Ico (s 0) T).filter (fun i => u R i = true)).card
  have hv : Tendsto v atTop atTop := return_count_tendsto_atTop R s hblack hgap hwhite
  have ht : ∀ᶠ T : Nat in atTop, s 0 ≤ T ∧ 1 ≤ T :=
    eventually_atTop.2 ⟨max (s 0) 1, fun T hT => ⟨by omega, by omega⟩⟩
  have hlow : ∀ᶠ T : Nat in atTop, (1 : ℝ) ≤ (s (v T) : ℝ) / (T : ℝ) := by
    filter_upwards [ht] with T hT
    have hb := (return_count_bracket R s hblack hgap hwhite T hT.1).1
    have hpos : (0 : ℝ) < T := by exact_mod_cast (show 0 < T by omega)
    apply (le_div_iff₀ hpos).2
    simpa using (show (T : ℝ) ≤ (s (v T) : ℝ) by exact_mod_cast hb)
  have hhigh : ∀ᶠ T : Nat in atTop,
      (s (v T) : ℝ) / (T : ℝ) ≤ 1 + (4 : ℝ) / T := by
    filter_upwards [ht] with T hT
    have hb := (return_count_bracket R s hblack hgap hwhite T hT.1).2
    have hpos : (0 : ℝ) < T := by exact_mod_cast (show 0 < T by omega)
    have hbr : (s (v T) : ℝ) ≤ (T : ℝ) + 4 := by exact_mod_cast hb
    calc
      (s (v T) : ℝ) / (T : ℝ) ≤ ((T : ℝ) + 4) / T := by gcongr
      _ = 1 + (4 : ℝ) / T := by field_simp [ne_of_gt hpos]
  have hup : Tendsto (fun T : Nat => (1 : ℝ) + 4 / T) atTop (𝓝 (1 : ℝ)) := by
    simpa using (tendsto_const_nhds (x := (1 : ℝ))).add
      (tendsto_const_div_atTop_nhds_zero_nat (4 : ℝ))
  have hratio : Tendsto (fun T : Nat => (s (v T) : ℝ) / (T : ℝ)) atTop (𝓝 (1 : ℝ)) :=
    tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hup hlow hhigh
  have hquot := hratio.div (hclock.comp hv) (ne_of_gt ha)
  have hvpos : ∀ᶠ T : Nat in atTop, 1 ≤ v T := (tendsto_atTop.1 hv) 1
  have hcount : Tendsto (fun T : Nat => (v T : ℝ) / (T : ℝ)) atTop (𝓝 (1 / a)) := by
    apply hquot.congr'
    filter_upwards [ht, hvpos] with T hT hvT
    have hv0 : (0 : ℝ) < v T := by exact_mod_cast (show 0 < v T by omega)
    have hs0 : (0 : ℝ) < s (v T) := by
      have hlt := returns_strictMono s hgap (show 0 < v T by omega)
      exact_mod_cast (show 0 < s (v T) by omega)
    have ht0 : (0 : ℝ) < T := by exact_mod_cast (show 0 < T by omega)
    change ((s (v T) : ℝ) / (T : ℝ)) / ((s (v T) : ℝ) / (v T : ℝ)) =
      (v T : ℝ) / (T : ℝ)
    field_simp [ne_of_gt hv0, ne_of_gt hs0, ne_of_gt ht0]
    <;> ring
  have hfull : Tendsto
      (fun T : Nat =>
        (((Finset.range (s 0)).filter (fun i => u R i = true)).card : ℝ) / T +
          (v T : ℝ) / T) atTop (𝓝 (1 / a)) := by
    simpa using (tendsto_const_div_atTop_nhds_zero_nat
      (((Finset.range (s 0)).filter (fun i => u R i = true)).card : ℝ)).add hcount
  apply hfull.congr'
  filter_upwards [ht] with T hT
  have hc := congrArg (fun n : Nat => (n : ℝ)) (gate_count_prefix_split R (s 0) T hT.1)
  push_cast at hc
  change _ = (((Finset.range T).filter (fun i => u R i = true)).card : ℝ) / T
  rw [hc]
  dsimp only [v]
  ring

theorem five_frequency_tendsto_iff_gate_density_tendsto
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false)
    (phi : ℝ) (hphi0 : 0 ≤ phi) (hphi1 : phi ≤ 1) :
    Tendsto
      (fun N : Nat =>
        (((Finset.range N).filter (fun j => s (j + 1) = s j + 5)).card : ℝ) /
          (N : ℝ))
      atTop (𝓝 phi) ↔
    Tendsto
      (fun T : Nat =>
        (((Finset.range T).filter (fun i => u R i = true)).card : ℝ) /
          (T : ℝ))
      atTop (𝓝 (1 / (3 + 2 * phi))) := by
  classical
  have ha : 0 < 3 + 2 * phi := by linarith
  constructor
  · intro hfreq
    exact gate_density_tendsto_of_clock R s hblack hgap hwhite (3 + 2 * phi) ha
      (clock_tendsto_of_frequency s hgap phi hfreq)
  · intro hden
    have hd : 0 < 1 / (3 + 2 * phi) := by positivity
    have hc := clock_tendsto_of_density R s hblack hgap hwhite (1 / (3 + 2 * phi)) hd hden
    have hf := (((hc.sub (tendsto_const_div_atTop_nhds_zero_nat (s 0 : ℝ))).sub
      (tendsto_const_nhds (x := (3 : ℝ)))).div_const (2 : ℝ))
    have heq : ((1 / (1 / (3 + 2 * phi)) - 0) - 3) / 2 = phi := by field_simp [ne_of_gt ha]; ring
    rw [heq] at hf
    apply hf.congr'
    filter_upwards [eventually_atTop.2 ⟨1, fun N hN => hN⟩] with N hN
    have hn : (N : ℝ) ≠ 0 := by exact_mod_cast (show N ≠ 0 by omega)
    have hs := congrArg (fun n : Nat => (n : ℝ)) (return_span_eq_three_mul_add_two_five_count s hgap N)
    push_cast at hs
    field_simp [hn]
    <;> nlinarith

theorem five_frequency_limit_exists_iff_gate_density_limit_exists
    (R : Nat → Bool) (s : Nat → Nat)
    (hblack : ∀ n, u R (s n) = true)
    (hgap : ∀ n, s (n + 1) = s n + 3 ∨ s (n + 1) = s n + 5)
    (hwhite : ∀ n i, s n < i → i < s (n + 1) → u R i = false) :
    (∃ phi : ℝ, 0 ≤ phi ∧ phi ≤ 1 ∧
      Tendsto
        (fun N : Nat =>
          (((Finset.range N).filter (fun j => s (j + 1) = s j + 5)).card : ℝ) /
            (N : ℝ))
        atTop (𝓝 phi)) ↔
    (∃ density : ℝ, (1 : ℝ) / 5 ≤ density ∧ density ≤ (1 : ℝ) / 3 ∧
      Tendsto
        (fun T : Nat =>
          (((Finset.range T).filter (fun i => u R i = true)).card : ℝ) /
            (T : ℝ))
        atTop (𝓝 density)) := by
  constructor
  · rintro ⟨phi, h0, h1, hf⟩
    have ha : 0 < 3 + 2 * phi := by linarith
    refine ⟨1 / (3 + 2 * phi), ?_, ?_,
      (five_frequency_tendsto_iff_gate_density_tendsto R s hblack hgap hwhite phi h0 h1).1 hf⟩
    · apply (le_div_iff₀ ha).2
      nlinarith
    · apply (div_le_iff₀ ha).2
      nlinarith
  · rintro ⟨density, h0, h1, hd⟩
    have hd0 : 0 < density := by linarith
    let phi : ℝ := (1 / density - 3) / 2
    have hlo : 3 ≤ 1 / density := by
      apply (le_div_iff₀ hd0).2
      nlinarith
    have hhi : 1 / density ≤ 5 := by
      apply (div_le_iff₀ hd0).2
      nlinarith
    have hp0 : 0 ≤ phi := by dsimp only [phi]; linarith
    have hp1 : phi ≤ 1 := by dsimp only [phi]; linarith
    refine ⟨phi, hp0, hp1, ?_⟩
    apply (five_frequency_tendsto_iff_gate_density_tendsto R s hblack hgap hwhite phi hp0 hp1).2
    have heq : 1 / (3 + 2 * phi) = density := by
      have hinner : 3 + 2 * phi = 1 / density := by dsimp only [phi]; ring
      rw [hinner]
      simp
    rw [heq]
    exact hd

end FVLT.Rule30GateReturnFrequencyV1
