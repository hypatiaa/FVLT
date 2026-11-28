import FareyMerge
namespace AtlasMerge
open Finset

theorem mem_frac {a b K : ℕ} (ha : a ≤ b) (hb : 0 < b) (hK : b ≤ K) :
    (a : ℚ)/b ∈ farey K := by
  exact mem_image.mpr ⟨(a,b), mem_filter.mpr ⟨mem_product.mpr
    ⟨mem_Icc.mpr ⟨by omega,ha.trans hK⟩,mem_Icc.mpr ⟨hb,hK⟩⟩,ha⟩,rfl⟩

theorem frac_den {a b : ℕ} (hb : 0 < b) : ((a : ℚ)/b).den ≤ b := by
  apply Nat.le_of_dvd hb
  exact_mod_cast (show (((a:ℚ)/b).den:ℤ) ∣ (b:ℤ) from by
    simpa [Rat.divInt_eq_div] using Rat.den_dvd (a:ℤ) (b:ℤ))

theorem farey_iff (K : ℕ) (r : ℚ) : r ∈ farey K ↔ 0 ≤ r ∧ r ≤ 1 ∧ r.den ≤ K := by
  constructor
  · rintro h
    obtain ⟨⟨a,b⟩,hm,rfl⟩ := mem_image.mp h
    obtain ⟨h,ha⟩ := mem_filter.mp hm
    obtain ⟨_,hb⟩ := mem_product.mp h
    obtain ⟨hb,hK⟩ := mem_Icc.mp hb
    change a ≤ b at ha
    change 1 ≤ b at hb
    change b ≤ K at hK
    change 0 ≤ (a:ℚ)/b ∧ _ ∧ _
    exact ⟨by positivity, (div_le_one (by positivity)).2 (by exact_mod_cast ha), (frac_den hb).trans hK⟩
  · rintro ⟨h0,h1,hK⟩
    have hn : 0 ≤ r.num := Rat.num_nonneg.mpr h0
    have he : (r.num.toNat : ℚ)/r.den = r := by
      rw [← Int.cast_natCast, Int.toNat_of_nonneg hn, Rat.num_div_den]
    apply he ▸ mem_frac _ r.den_pos hK
    have ht := (div_le_one (show (0:ℚ) < r.den by exact_mod_cast r.den_pos)).1 (he.le.trans h1)
    exact_mod_cast ht

private theorem search {K : ℕ} {r : ℚ} (hout : r ∉ farey K)
    (a b c d : ℕ) (hb : 0 < b) (hd : 0 < d) (hab : a ≤ b) (hcd : c ≤ d)
    (hbK : b ≤ K) (hdK : d ≤ K) (det : c*b = a*d+1)
    (left : (a:ℚ)/b < r) (right : r < (c:ℚ)/d) :
    ∃ A B C D : ℕ, 0 < B ∧ 0 < D ∧ A ≤ B ∧ C ≤ D ∧ B ≤ K ∧ D ≤ K ∧
      K < B+D ∧ C*B = A*D+1 ∧ (A:ℚ)/B < r ∧ r < (C:ℚ)/D := by
  by_cases cut : K < b+d
  · exact ⟨a,b,c,d,hb,hd,hab,hcd,hbK,hdK,cut,det,left,right⟩
  have hm : (↑(a+c):ℚ)/(b+d:ℕ) ∈ farey K := mem_frac (by omega) (by omega) (by omega)
  rcases lt_or_gt_of_ne (show (↑(a+c):ℚ)/(b+d:ℕ) ≠ r from fun e => hout (e ▸ hm)) with h | h
  · exact search hout (a+c) (b+d) c d (by omega) hd (by omega) hcd (by omega) hdK
      (by nlinarith only [det]) h right
  · exact search hout a b (a+c) (b+d) hb (by omega) hab (by omega) hbK (by omega)
      (by nlinarith only [det]) left h
termination_by 2*K-(b+d)
decreasing_by all_goals omega

private theorem empty_gap {a b c d u v : ℕ} (hb : 0 < b) (hd : 0 < d) (hv : 0 < v)
    (det : c*b=a*d+1) (l : (a:ℚ)/b < (u:ℚ)/v) (h : (u:ℚ)/v < (c:ℚ)/d) : b+d ≤ v := by
  have H : a*v < u*b := by exact_mod_cast (div_lt_div_iff₀ (by positivity) (by positivity)).1 l
  have J : u*d < c*v := by exact_mod_cast (div_lt_div_iff₀ (by positivity) (by positivity)).1 h
  nlinarith only [Nat.mul_le_mul_left d (show a*v+1 ≤ u*b by omega),
    Nat.mul_le_mul_left b (show u*d+1 ≤ c*v by omega), congrArg (·*v) det]

/-- A coarse step decreases denominators and moves at most 2/(q(K+1)). -/
theorem parent_step {K : ℕ} (hK : 1 ≤ K) {r : ℚ} (h0 : 0 ≤ r) (h1 : r ≤ 1) :
    parent K r ∈ farey K ∧ (parent K r).den ≤ r.den ∧
      |r-parent K r| * (parent K r).den * (K+1:ℕ) ≤ 2 := by
  let L := insert (0:ℚ) ((farey K).filter (· ≤ r))
  let U := insert (1:ℚ) ((farey K).filter (r ≤ ·))
  have Lne : L.Nonempty := insert_nonempty ..
  have Une : U.Nonempty := insert_nonempty ..
  have zl : (0:ℚ) ∈ farey K := (farey_iff ..).2 ⟨by norm_num,by norm_num,by simpa using hK⟩
  have ou : (1:ℚ) ∈ farey K := (farey_iff ..).2 ⟨by norm_num,by norm_num,by simpa using hK⟩
  have lp (z) (hz : z ∈ L) : z ∈ farey K ∧ z ≤ r := by
    rcases mem_insert.mp hz with h|h
    · exact h ▸ ⟨zl,h0⟩
    · exact mem_filter.mp h
  have up (z) (hz : z ∈ U) : z ∈ farey K ∧ r ≤ z := by
    rcases mem_insert.mp hz with h|h
    · exact h ▸ ⟨ou,h1⟩
    · exact mem_filter.mp h
  have lp' := lp _ (L.max'_mem Lne)
  have up' := up _ (U.min'_mem Une)
  by_cases hr : r ∈ farey K
  · have l : L.max' Lne = r := le_antisymm lp'.2 (L.le_max' r (mem_insert_of_mem (mem_filter.mpr ⟨hr,le_rfl⟩)))
    have u : U.min' Une = r := le_antisymm (U.min'_le r (mem_insert_of_mem (mem_filter.mpr ⟨hr,le_rfl⟩))) up'.2
    have e : parent K r = r := by change (if _ then L.max' Lne else U.min' Une) = r; split <;> assumption
    simp [e,hr]
  have hl : 0 < r := lt_of_le_of_ne h0 (fun e => hr (e ▸ zl))
  have hu : r < 1 := lt_of_le_of_ne h1 (fun e => hr (e.symm ▸ ou))
  obtain ⟨a,b,c,d,hb,hd,hab,hcd,bK,dK,cut,det,lt,gt⟩ :=
    search hr 0 1 1 1 (by decide) (by decide) (by decide) (by decide) hK hK
      (by decide) (by simpa using hl) (by simpa using hu)
  have noMiddle (z : ℚ) (hz : z ∈ farey K) (l : (a:ℚ)/b < z) (u : z < (c:ℚ)/d) : False := by
    obtain ⟨⟨i,j⟩,hm,rfl⟩ := mem_image.mp hz
    obtain ⟨_,hj⟩ := mem_product.mp (mem_filter.mp hm).1
    obtain ⟨jpos,jK⟩ := mem_Icc.mp hj
    exact (not_lt_of_ge ((empty_gap hb hd jpos det l u).trans jK)) cut
  have lo : L.max' Lne = (a:ℚ)/b := by
    apply le_antisymm _ (L.le_max' _ (mem_insert_of_mem (mem_filter.mpr ⟨mem_frac hab hb bK,lt.le⟩)))
    exact le_of_not_gt fun h => noMiddle _ lp'.1 h (lp'.2.trans_lt gt)
  have hi : U.min' Une = (c:ℚ)/d := by
    apply le_antisymm (U.min'_le _ (mem_insert_of_mem (mem_filter.mpr ⟨mem_frac hcd hd dK,gt.le⟩))) _
    exact le_of_not_gt fun h => noMiddle _ up'.1 (lt.trans_le up'.2) h
  let p := parent K r
  have info : p ∈ farey K ∧ (p = (a:ℚ)/b ∨ p = (c:ℚ)/d) ∧ p.den ≤ b ∧ p.den ≤ d := by
    change (fun z : ℚ => z ∈ farey K ∧ (z = (a:ℚ)/b ∨ z = (c:ℚ)/d) ∧ z.den ≤ b ∧ z.den ≤ d)
      (if (L.max' Lne).den ≤ (U.min' Une).den then L.max' Lne else U.min' Une)
    rw [lo,hi]
    split_ifs with h
    · exact ⟨mem_frac hab hb bK,Or.inl rfl,frac_den hb,h.trans (frac_den hd)⟩
    · exact ⟨mem_frac hcd hd dK,Or.inr rfl,(le_of_not_ge h).trans (frac_den hb),frac_den hd⟩
  refine ⟨info.1, ((farey_iff ..).1 info.1).2.2.trans (by by_contra! bad; exact hr ((farey_iff ..).2 ⟨h0,h1,by omega⟩)), ?_⟩
  have dist : |r-p| ≤ (c:ℚ)/d-(a:ℚ)/b := by rcases info.2.1 with h|h <;> rw [h,abs_le] <;> constructor <;> linarith
  have width : (c:ℚ)/d-(a:ℚ)/b = 1/(b*d) := by
    have h : (c:ℚ)*b=a*d+1 := by exact_mod_cast det
    field_simp; nlinarith
  have prod : p.den*(K+1) ≤ 2*(b*d) := by
    calc _ ≤ p.den*(b+d) := Nat.mul_le_mul_left _ cut
         _ ≤ d*b+b*d := by rw [Nat.mul_add]; gcongr <;> tauto
         _ = _ := by ring
  change |r-p| * p.den * (K+1:ℕ) ≤ 2
  rw [width] at dist
  calc _ ≤ (1/(b*d:ℚ))*p.den*(K+1:ℕ) := by gcongr
       _ ≤ _ := by
         have hp : (p.den:ℚ)*(↑(K+1:ℕ)) ≤ 2*((b:ℚ)*d) := by exact_mod_cast prod
         field_simp; linarith

theorem actual_radius {N : ℕ} (hN : 4 ≤ N) {r : ℚ} (hr : r ∈ farey N) :
    let b := twoLevelAnchor N r
    b ∈ farey (N/4) ∧ |r-b| ≤ 12/((b.den:ℚ)*N) := by
  obtain ⟨hr0,hr1,_⟩ := (farey_iff ..).1 hr
  let a := parent (N/2) r
  let b := twoLevelAnchor N r
  obtain ⟨ha,_,h₁⟩ := parent_step (K:=N/2) (by omega) hr0 hr1
  obtain ⟨ha0,ha1,_⟩ := (farey_iff ..).1 ha
  obtain ⟨hb,hba,h₂⟩ := parent_step (K:=N/4) (by omega) ha0 ha1
  change b.den ≤ a.den at hba
  change |r-a| *a.den*↑(N/2+1) ≤ 2 at h₁
  change |a-b| *b.den*↑(N/4+1) ≤ 2 at h₂
  refine ⟨hb, (le_div_iff₀ (show 0 < (b.den:ℚ)*N by
    have := b.den_pos; positivity)).2 ?_⟩
  have d₁ : (N:ℚ) ≤ 2*↑(N/2+1) := by exact_mod_cast (show N ≤ 2*(N/2+1) by omega)
  have d₂ : (N:ℚ) ≤ 4*↑(N/4+1) := by exact_mod_cast (show N ≤ 4*(N/4+1) by omega)
  have s₁ : |r-a| *b.den*N ≤ 4 := by
    calc _ ≤ |r-a| *a.den*(2*↑(N/2+1)) := by gcongr
         _ = 2*(|r-a| *a.den*↑(N/2+1)) := by ring
         _ ≤ 4 := by linarith
  have s₂ : |a-b| *b.den*N ≤ 8 := by
    calc _ ≤ |a-b| *b.den*(4*↑(N/4+1)) := by gcongr
         _ = 4*(|a-b| *b.den*↑(N/4+1)) := by ring
         _ ≤ 8 := by linarith
  calc |r-b| *((b.den:ℚ)*N) ≤ (|r-a| + |a-b|)*(b.den*N) := by
         gcongr; exact abs_sub_le .. 
       _ ≤ 12 := by linarith
end AtlasMerge

