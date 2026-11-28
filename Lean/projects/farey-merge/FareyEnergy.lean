import FareyPacking
namespace AtlasMerge
open Finset
noncomputable section

private theorem denom_count (K q : ℕ) : ((obs K).filter (·.den = q)).card ≤ q := by
  have bounds (x : ℚ) (hx : x ∈ (obs K).filter (·.den = q)) :
      0 < x.num ∧ x.num ≤ (q:ℤ) ∧ x.den = q := by
    obtain ⟨hx,hq⟩ := mem_filter.mp hx
    obtain ⟨hn,hx⟩ := mem_erase.mp hx
    obtain ⟨h0,h1,_⟩ := (farey_iff ..).1 hx
    have hd : (0:ℚ) < x.den := by exact_mod_cast x.den_pos
    have he := Rat.num_div_den x
    have hnum : (x.num:ℚ) ≤ x.den :=
      (div_le_one hd).1 (he.le.trans h1)
    exact ⟨Rat.num_pos.mpr (lt_of_le_of_ne h0 hn.symm),by rw [← hq]; exact_mod_cast hnum,hq⟩
  have hc : ((obs K).filter (·.den = q)).card ≤ (Icc 1 q).card := by
    apply card_le_card_of_injOn (fun x : ℚ => x.num.toNat)
    · intro x hx
      obtain ⟨h,h',_⟩ := bounds x hx
      apply mem_Icc.mpr
      change 1 ≤ x.num.toNat ∧ x.num.toNat ≤ q
      omega
    · intro x hx y hy he
      obtain ⟨hx0,_,hxq⟩ := bounds x hx
      obtain ⟨hy0,_,hyq⟩ := bounds y hy
      change x.num.toNat = y.num.toNat at he
      have hn : x.num = y.num := by omega
      calc x = (x.num:ℚ)/x.den := (Rat.num_div_den _).symm
           _ = (y.num:ℚ)/y.den := by rw [hn,hxq,hyq]
           _ = y := Rat.num_div_den _
  simpa using hc

private theorem recip (k : ℕ) : ∑ q ∈ Icc 1 (k+1), (1:ℝ)/(q:ℝ)^2 ≤ 2-1/(k+1:ℕ) := by
  induction k with
  | zero => norm_num
  | succ k ih =>
    rw [sum_Icc_succ_top (by omega : 1 ≤ k+1+1)]
    push_cast at ih ⊢
    have hh : 1/((k:ℝ)+1+1)^2 ≤ 1/((k:ℝ)+1)-1/((k:ℝ)+1+1) := by field_simp; nlinarith
    linarith

theorem denominator_mass {K : ℕ} (hK : 1 ≤ K) :
    ∑ b ∈ farey K, (1:ℝ)/(b.den:ℝ)^3 ≤ 3 := by
  have hz : (0:ℚ) ∈ farey K := (farey_iff ..).2 ⟨by norm_num,by norm_num,by simpa using hK⟩
  have part := sum_fiberwise_of_maps_to' (s:=obs K) (t:=Icc 1 K) (g:=Rat.den)
    (fun b hb => mem_Icc.mpr ⟨b.den_pos,((farey_iff ..).1 (mem_erase.mp hb).2).2.2⟩)
    (fun q : ℕ => (1:ℝ)/(q:ℝ)^3)
  have h : (∑ b ∈ obs K, (1:ℝ)/(b.den:ℝ)^3) ≤ 2 := by
    rw [← part]
    calc _ ≤ ∑ q ∈ Icc 1 K, (1:ℝ)/(q:ℝ)^2 := by
          apply sum_le_sum
          intro q hq
          have hp : (0:ℝ) < q := by exact_mod_cast (mem_Icc.mp hq).1
          simp only [sum_const, nsmul_eq_mul]
          calc _ ≤ (q:ℝ)*(1/(q:ℝ)^3) := by gcongr; exact_mod_cast denom_count K q
               _ = _ := by field_simp
         _ ≤ _ := by
           obtain ⟨k,rfl⟩ := Nat.exists_eq_add_of_le hK
           rw [Nat.add_comm 1 k]; exact (recip k).trans (sub_le_self _ (by positivity))
  have split := sum_erase_add (farey K) (fun b : ℚ => (1:ℝ)/(b.den:ℝ)^3) hz
  change (∑ b ∈ (farey K).erase 0, (1:ℝ)/(b.den:ℝ)^3) ≤ 2 at h
  simp only [Rat.den_zero, Nat.cast_one, one_pow, div_one] at split
  linarith

def childRows (N : ℕ) (a : ℚ) := (obs N).filter (parent (N/2) · = a)
def children (N : ℕ) (b : ℚ) := (farey (N/2)).filter (parent (N/4) · = b)
def weight (N : ℕ) (a : ℚ) : ℝ := (childRows N a).card
def childMean (N : ℕ) (a : ℚ) : ℝ :=
  (∑ r ∈ childRows N a, ((displacement N r:ℚ):ℝ)) / weight N a
def parentMean (N : ℕ) (b : ℚ) : ℝ :=
  (∑ a ∈ children N b, weight N a*childMean N a) / (∑ a ∈ children N b, weight N a)

/-- The weighted change in child means upon the second merge, using original ranks. -/
def mergeLoss (N : ℕ) : ℝ :=
  ∑ b ∈ farey (N/4), (obs N).card *
    ∑ a ∈ children N b, weight N a*(childMean N a-parentMean N b)^2

private theorem partition_sum {N : ℕ} (hN : 4 ≤ N) (b : ℚ) (f : ℚ → ℝ) :
    ∑ a ∈ children N b, ∑ r ∈ childRows N a, f r = ∑ r ∈ fibre N b, f r := by
  have cover (r) (hr : r ∈ fibre N b) : parent (N/2) r ∈ children N b := by
    obtain ⟨ho,e⟩ := mem_filter.mp hr
    obtain ⟨h0,h1,_⟩ := (farey_iff ..).1 (mem_erase.mp ho).2
    exact mem_filter.mpr ⟨(parent_step (K:=N/2) (by omega) h0 h1).1,e⟩
  have eq (a) (ha : a ∈ children N b) :
      (fibre N b).filter (parent (N/2) · = a) = childRows N a := by
    ext r
    obtain ⟨_,h⟩ := mem_filter.mp ha
    constructor
    · intro hz
      obtain ⟨hf,e⟩ := mem_filter.mp hz
      exact mem_filter.mpr ⟨(mem_filter.mp hf).1,e⟩
    · intro hz
      obtain ⟨ho,e⟩ := mem_filter.mp hz
      exact mem_filter.mpr ⟨mem_filter.mpr ⟨ho,(congrArg (parent (N/4)) e).trans h⟩,e⟩
  rw [← sum_fiberwise_of_maps_to cover f]
  exact sum_congr rfl fun a ha => by rw [eq a ha]

private theorem partition {N : ℕ} (hN : 4 ≤ N) (b : ℚ) :
    ∑ a ∈ children N b, weight N a = ((fibre N b).card:ℝ) := by
  simpa [weight] using partition_sum hN b (fun _ => (1:ℝ))

/-- The second-level mean averages the original observations with their original ranks. -/
theorem parentMean_original {N : ℕ} (hN : 4 ≤ N) (b : ℚ) :
    parentMean N b = (∑ r ∈ fibre N b, ((displacement N r:ℚ):ℝ)) / (fibre N b).card := by
  unfold parentMean
  rw [partition hN, ← partition_sum hN b]
  congr 1
  apply sum_congr rfl
  intro a _
  by_cases he : (childRows N a).Nonempty
  · have hp : (0:ℝ) < (childRows N a).card := by exact_mod_cast card_pos.mpr he
    unfold childMean weight; field_simp
  · simp [weight,childMean,not_nonempty_iff_eq_empty.mp he]

private theorem center_eq (N : ℕ) (b : ℚ) :
    ∑ a ∈ children N b, weight N a*(childMean N a-parentMean N b) = 0 := by
  simp_rw [mul_sub, sum_sub_distrib, ← sum_mul]
  unfold parentMean
  by_cases hz : ∑ a ∈ children N b, weight N a = 0
  · have hw := (sum_eq_zero_iff_of_nonneg (fun a (_ : a ∈ children N b) =>
      (show 0 ≤ weight N a from Nat.cast_nonneg _))).mp hz
    simp [hz]
    exact sum_eq_zero fun a ha => by rw [hw a ha,zero_mul]
  · field_simp; ring

private theorem mean_near {N : ℕ} (hN : 4 ≤ N) {b a : ℚ} (ha : a ∈ children N b)
    (hne : (childRows N a).Nonempty) :
    |childMean N a-((displacement N b:ℚ):ℝ)| ≤ 12*N/(((obs N).card:ℝ)*b.den) := by
  let s := childRows N a
  let R : ℝ := 12*N/(((obs N).card:ℝ)*b.den)
  let z : ℝ := displacement N b
  have hp : (0:ℝ) < s.card := by exact_mod_cast card_pos.mpr hne
  have e (r) (hr : r ∈ s) : |((displacement N r:ℚ):ℝ)-z| ≤ R := by
    obtain ⟨ho,eq⟩ := mem_filter.mp hr
    have hb : twoLevelAnchor N r = b := (congrArg (parent (N/4)) eq).trans (mem_filter.mp ha).2
    have hh := displacement_at_anchor hN ho
    simpa only [hb] using hh
  have iden : childMean N a-z = (∑ r ∈ s, (((displacement N r:ℚ):ℝ)-z))/s.card := by
    simp only [sum_sub_distrib,sum_const,nsmul_eq_mul,childMean,weight]; change _/ (s.card:ℝ)-z = _
    field_simp; rfl
  change |childMean N a-z| ≤ R
  rw [iden,abs_div,abs_of_pos hp]
  apply (div_le_iff₀ hp).2
  calc _ ≤ ∑ r ∈ s, |((displacement N r:ℚ):ℝ)-z| := Finset.abs_sum_le_sum_abs ..
       _ ≤ ∑ _r ∈ s, R := sum_le_sum e
       _ = _ := by simp [mul_comm]

/-- The quantity bounded in this module is exactly the drop between the two
retained energies, measured using the same original population at both levels. -/
theorem merge_balance {N : ℕ} (hN : 4 ≤ N) :
    (∑ a ∈ farey (N/2), (obs N).card*(weight N a*(childMean N a)^2)) =
    mergeLoss N + ∑ b ∈ farey (N/4), (obs N).card*((fibre N b).card*(parentMean N b)^2) := by
  have cover (a) (ha : a ∈ farey (N/2)) : parent (N/4) a ∈ farey (N/4) :=
    (parent_step (K:=N/4) (by omega) ((farey_iff ..).1 ha).1 ((farey_iff ..).1 ha).2.1).1
  rw [← sum_fiberwise_of_maps_to cover, mergeLoss, ← sum_add_distrib]
  apply sum_congr rfl
  intro b _
  change (∑ a ∈ children N b, _) = _
  rw [← mul_sum, ← mul_add]
  congr 1
  have he := change_center (children N b) (weight N) (childMean N) (parentMean N b) 0 (center_eq N b)
  simpa only [sub_zero, partition hN] using he

/-- No geometric or counting assumptions. The only hypothesis is N ≥ 4. -/
theorem actual_merge_bound {N : ℕ} (hN : 4 ≤ N) : 0 ≤ mergeLoss N ∧ mergeLoss N ≤ 86400*N := by
  let m : ℝ := (obs N).card
  have hn : (0:ℝ) < N := by exact_mod_cast (show 0<N by omega)
  have hm := population_lower (show 2 ≤ N by omega)
  have hm0 : 0 < m := by dsimp [m]; nlinarith [sq_pos_of_pos hn]
  have wn (a : ℚ) : 0 ≤ weight N a := Nat.cast_nonneg _
  refine ⟨sum_nonneg (fun b _ => mul_nonneg hm0.le (sum_nonneg (fun a _ => mul_nonneg (wn a) (sq_nonneg _)))),?_⟩
  apply sum_parent_cost (farey (N/4)) (fun b => b.den) _ N hn.le _ (denominator_mass (by omega))
  intro b hb
  let z : ℝ := displacement N b
  let R : ℝ := 12*N/(m*b.den)
  have rp : 0 ≤ R := by dsimp [R]; positivity
  have hvar : ∑ a ∈ children N b, weight N a*(childMean N a-parentMean N b)^2 ≤
      ((fibre N b).card:ℝ)*R^2 := by
    rw [← partition hN b]
    have H := change_center (children N b) (weight N) (childMean N) (parentMean N b) z (center_eq N b)
    calc _ ≤ ∑ a ∈ children N b, weight N a*(childMean N a-z)^2 := by
          rw [H]; exact le_add_of_nonneg_right (mul_nonneg (sum_nonneg fun a _ => wn a) (sq_nonneg _))
         _ ≤ ∑ a ∈ children N b, weight N a*R^2 := by
          apply sum_le_sum
          intro a ha
          by_cases ne : (childRows N a).Nonempty
          · apply mul_le_mul_of_nonneg_left _ (wn a)
            have near : |childMean N a-z| ≤ R := mean_near hN ha ne
            nlinarith [sq_abs (childMean N a-z),mul_nonneg (sub_nonneg.mpr near)
              (add_nonneg rp (abs_nonneg (childMean N a-z)))]
          · simp [weight,not_nonempty_iff_eq_empty.mp ne]
         _ = _ := (sum_mul ..).symm
  change m*(∑ a ∈ children N b, _) ≤ _
  calc _ ≤ m*(((fibre N b).card:ℝ)*R^2) := mul_le_mul_of_nonneg_left hvar hm0.le
       _ = m*((fibre N b).card:ℝ)*R^2 := by ring
       _ ≤ 28800*N/(b.den:ℝ)^3 := parent_cost N m b.den _ R hn (by exact_mod_cast b.den_pos)
          hm (fibre_population hN b hb) rp le_rfl
       _ = _ := by ring
end
end AtlasMerge

