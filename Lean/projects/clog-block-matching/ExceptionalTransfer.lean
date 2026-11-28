import ShortIntervals

namespace AtlasLog
open Finset MeasureTheory
noncomputable section

/-- Real starting point; integer lengths give the same denominators as at floor x. -/
def realBad (X : ℕ) (k : ℝ) : Set ℝ :=
  {x | (↑(X/2:ℕ):ℝ) ≤ x ∧ x ≤ 2*(↑(X/2:ℕ):ℝ) ∧ ∃ r ∈ residues,
    k < |apSum r ⌊x⌋₊ X.sqrt|}

/-- Needed analytic lemma, a constant-observable, four-progression specialization
of Matomäki–Radziwiłł–Shao–Tao–Teräväinen, Theorem 1.1(i). -/
def AP12Measure : Prop := ∃ K : ℝ, 0<K ∧ ∃ X₀ : ℕ, ∀ X ≥ X₀,
  volume (realBad X (K*X.sqrt/Real.log X)) ≤ ENNReal.ofReal (K*X/Real.log X)

/-- For an integer length the arithmetic progressions in the real interval
(x,x+h] have exactly the endpoints used by the discrete sums. -/
theorem real_interval_membership (n h : ℕ) {x : ℝ} (hx : 0≤x) :
    n ∈ Ioc ⌊x⌋₊ (⌊x⌋₊+h) ↔ x < n ∧ (n:ℝ) ≤ x+h := by
  rw [mem_Ioc,Nat.floor_lt hx,← Nat.floor_add_natCast hx,Nat.le_floor_iff (by positivity)]

private def cell (n : ℕ) := Set.Ico (n:ℝ) ((n:ℝ)+1)

theorem bad_count_le_volume (X : ℕ) (hX : 16≤X) (k : ℝ) :
    ((badStarts X X.sqrt k).card:ENNReal) ≤ volume (realBad X k) := by
  let s := badStarts X X.sqrt k
  have hh : 2 ≤ X.sqrt := Nat.le_sqrt.mpr (by omega)
  have hsmall := Nat.sqrt_le_self X
  have sub : (⋃ n ∈ s, cell n) ⊆ realBad X k := by
    intro x hx
    obtain ⟨n,hn,hx⟩ := Set.mem_iUnion₂.mp hx
    obtain ⟨low,hi⟩ := hx
    obtain ⟨hs,hr⟩ := mem_filter.mp hn
    obtain ⟨left,right⟩ := mem_Icc.mp hs
    have high : n+1 ≤ 2*(X/2) := by omega
    have low' : (↑(X/2:ℕ):ℝ) ≤ n := by exact_mod_cast left
    refine ⟨low'.trans low,hi.le.trans (by exact_mod_cast high),?_⟩
    rwa [Nat.floor_eq_on_Ico n x ⟨low,hi⟩]
  have dis : Set.PairwiseDisjoint (↑s : Set ℕ) cell := by
    intro a _ b _ ne; apply Set.disjoint_left.mpr; intro x ha hb
    have ha' := Nat.floor_eq_on_Ico a x ha
    have hb' := Nat.floor_eq_on_Ico b x hb
    exact ne (ha'.symm.trans hb')
  have v := measure_mono (μ:=volume) sub
  rw [measure_biUnion_finset dis (fun _ _ => measurableSet_Ico)] at v
  simpa [s,cell,Real.volume_Ico] using v

theorem discrete_from_measure (H : AP12Measure) : AP12Exceptional := by
  obtain ⟨K,hK,X₀,h⟩ := H
  refine ⟨K,hK,max X₀ 16,?_⟩
  intro X hX
  have hx := (le_max_right X₀ 16).trans hX
  have hpos : (1:ℝ)<X := by exact_mod_cast (show 1<X by omega)
  have nonneg : 0 ≤ K*X/Real.log X := by have := Real.log_pos hpos; positivity
  have le := (bad_count_le_volume X hx _).trans (h X ((le_max_left X₀ 16).trans hX))
  have out := ENNReal.toReal_mono ENNReal.ofReal_ne_top le
  simpa [ENNReal.toReal_ofReal nonneg] using out

private theorem logs {X : ℕ} (hx : 16≤X) :
    1 ≤ Real.log X ∧ 0 < Real.log X.sqrt ∧ Real.log X.sqrt ≤ Real.log X := by
  have hr : 2 ≤ X.sqrt := Nat.le_sqrt.mpr (by omega)
  have h16 : (16:ℝ)≤X := by exact_mod_cast hx
  have hl : Real.exp 1 ≤ X := Real.exp_one_lt_d9.le.trans ((by norm_num : (2.7182818286:ℝ) ≤ 16).trans h16)
  have xp : (0:ℝ)<X := by exact_mod_cast (show 0<X by omega)
  have sp : (1:ℝ)<X.sqrt := by exact_mod_cast hr
  exact ⟨(Real.le_log_iff_exp_le xp).mpr hl,Real.log_pos sp,
    Real.log_le_log (by linarith) (by exact_mod_cast Nat.sqrt_le_self X)⟩

private theorem power_compare {u v α : ℝ} (hu : 0≤u) (uv : u≤v) (hv : 1≤v)
    (a0 : 0≤α) (a1 : α≤1) : u^α ≤ v := by
  calc _ ≤ v^α := Real.rpow_le_rpow hu uv a0
       _ ≤ v^ (1:ℝ) := Real.rpow_le_rpow_of_exponent_le hv a1
       _ = _ := Real.rpow_one _

/-- Both signed short sums have the stated threshold and exceptional count.
The same analytic input works for both signs at once. -/
theorem signed_short_estimate (H : AP12Measure) :
    ∃ C : ℝ, 0<C ∧ ∃ X₀ : ℕ, ∀ X ≥ X₀, ∀ tw : Bool,
      let h := X.sqrt
      (((starts X h).filter (fun t => C*h/(Real.log h)^(1/200:ℝ) <
          |(blockSum tw t h:ℝ)|)).card:ℝ) ≤ C*X/(Real.log h)^(1/100:ℝ) := by
  obtain ⟨K,hK,X₀,bound⟩ := discrete_from_measure H
  refine ⟨4*K,by positivity,max X₀ 16,?_⟩
  intro X hX tw
  have hx := (le_max_right X₀ 16).trans hX
  obtain ⟨lx,lh,le⟩ := logs hx
  have lp : 0 < Real.log X := by linarith
  have p1 := power_compare lh.le le lx (by norm_num : (0:ℝ) ≤ 1/200) (by norm_num)
  have p2 := power_compare lh.le le lx (by norm_num : (0:ℝ) ≤ 1/100) (by norm_num)
  have H1 : 4*(K*X.sqrt/Real.log X) ≤ 4*K*X.sqrt/(Real.log X.sqrt)^(1/200:ℝ) := by
    rw [←mul_div_assoc,←mul_assoc]; exact div_le_div_of_nonneg_left (by positivity) (by positivity) p1
  have H2 : K*X/Real.log X ≤ 4*K*X/(Real.log X.sqrt)^(1/100:ℝ) := by
    apply (div_le_div_of_nonneg_left (by positivity) (by positivity) p2).trans
    gcongr; linarith
  have sub := signed_bad_subset tw X X.sqrt (K*X.sqrt/Real.log X)
  apply le_trans _ ((bound X ((le_max_left X₀ 16).trans hX)).trans H2)
  exact_mod_cast card_le_card (fun t ht => sub (mem_filter.mpr ⟨(mem_filter.mp ht).1,
    H1.trans_lt (mem_filter.mp ht).2⟩))

/-- The atlas rate for the actual shared matching. -/
theorem actual_clog (H : AP12Measure) :
    ∃ C : ℝ, 0<C ∧ ∃ X₀ : ℕ, ∀ X ≥ X₀,
      Fits (Ioc (X/2) X) X.sqrt (C*X/(Real.log X)^(1/200:ℝ)) := by
  obtain ⟨K,hK,X₀,bound⟩ := actual_matching_log (discrete_from_measure H)
  refine ⟨K,hK,max X₀ 16,?_⟩
  intro X hX
  have hl := (logs ((le_max_right X₀ 16).trans hX)).1
  have hp : 0<Real.log X := by linarith
  apply fits_mono (bound X ((le_max_left X₀ 16).trans hX))
  exact div_le_div_of_nonneg_left (by positivity) (by positivity)
    (power_compare hp.le le_rfl hl (by norm_num) (by norm_num))

end
end AtlasLog
