import FareyParent
namespace AtlasMerge
open Finset

def obs (N : ℕ) := (farey N).erase 0
private def grid (n : ℕ) := Icc 1 n ×ˢ Icc 1 n
private def shape (x : ℚ) : ℕ × ℕ := (x.num.toNat,x.den)

private theorem encode {a b N : ℕ} (ha : 1 ≤ a) (hab : a ≤ b) (hb : b ≤ N)
    (cop : a.Coprime b) :
    ∃ x ∈ obs N, shape x = (a,b) := by
  have hp : 0 < b := by omega
  let x := (a:ℚ)/b
  have hm : x ∈ obs N := mem_erase.mpr ⟨ne_of_gt (by dsimp [x]; positivity), mem_frac hab hp hb⟩
  have hn := Rat.num_div_eq_of_coprime (a:=(a:ℤ)) (b:=(b:ℤ)) (by exact_mod_cast hp) (by simpa using cop)
  have hd := Rat.den_div_eq_of_coprime (a:=(a:ℤ)) (b:=(b:ℤ)) (by exact_mod_cast hp) (by simpa using cop)
  simp only [Int.cast_natCast] at hn hd
  refine ⟨x,hm,Prod.ext ?_ ?_⟩
  · change ((a:ℚ)/b).num.toNat = a
    rw [hn]; simp
  · exact_mod_cast hd

private theorem square_cover (N : ℕ) :
    N*N ≤ 2*(obs N).card + ∑ d ∈ Icc 2 N, (N/d)*(N/d) := by
  let S := (obs N).image shape
  let T := S.image Prod.swap
  let blocks := fun d : ℕ => (grid (N/d)).image (fun p => (d*p.1,d*p.2))
  have cover : grid N ⊆ (S ∪ T) ∪ (Icc 2 N).biUnion blocks := by
    rintro ⟨a,b⟩ hab
    obtain ⟨ha,hb⟩ := mem_product.mp hab
    obtain ⟨a0,aN⟩ := mem_Icc.mp ha
    obtain ⟨b0,bN⟩ := mem_Icc.mp hb
    by_cases cop : a.Coprime b
    · apply mem_union_left
      rcases le_total a b with h|h
      · obtain ⟨x,hx,eq⟩ := encode a0 h bN cop
        exact mem_union_left _ (mem_image.mpr ⟨x,hx,eq⟩)
      · obtain ⟨x,hx,eq⟩ := encode b0 h aN cop.symm
        exact mem_union_right _ (mem_image.mpr ⟨(b,a),mem_image.mpr ⟨x,hx,eq⟩,rfl⟩)
    · let d := a.gcd b
      have da : d ∣ a := Nat.gcd_dvd_left .. 
      have db : d ∣ b := Nat.gcd_dvd_right ..
      have dp : 0 < d := Nat.gcd_pos_of_pos_left b a0
      have d1 : d ≠ 1 := cop
      have dla := Nat.le_of_dvd a0 da
      have dlb := Nat.le_of_dvd b0 db
      apply mem_union_right
      apply mem_biUnion.mpr
      refine ⟨d,mem_Icc.mpr ⟨by omega,by omega⟩,mem_image.mpr ⟨(a/d,b/d),?_,?_⟩⟩
      · exact mem_product.mpr ⟨mem_Icc.mpr ⟨(Nat.div_pos dla dp),Nat.div_le_div_right aN⟩,
          mem_Icc.mpr ⟨Nat.div_pos dlb dp,Nat.div_le_div_right bN⟩⟩
      · exact Prod.ext (Nat.mul_div_cancel' da) (Nat.mul_div_cancel' db)
  have ss : S.card ≤ (obs N).card := card_image_le
  have tt : T.card ≤ S.card := card_image_le
  have cc := card_le_card cover
  have hh := card_union_le (S ∪ T) ((Icc 2 N).biUnion blocks)
  have jj := card_union_le S T
  have kk := card_biUnion_le (s:=Icc 2 N) (t:=blocks)
  have ww : ∑ d ∈ Icc 2 N, (blocks d).card ≤ ∑ d ∈ Icc 2 N, (N/d)*(N/d) := by
    apply sum_le_sum
    intro d _
    simpa [blocks,grid] using (card_image_le (s:=grid (N/d)) (f:=fun p => (d*p.1,d*p.2)))
  simpa [grid] using (show (grid N).card ≤ _ from by omega)

/-- Majorize the finite reciprocal-square tail by telescoping 1/(d-1) - 1/d. -/
private theorem recip_tail (n : ℕ) : ∑ d ∈ Icc 2 (n+2), (1:ℝ)/(d:ℝ)^2 ≤
    3/4 - 1/(n+2:ℕ) := by
  induction n with
  | zero => norm_num [Finset.Icc_self]
  | succ n ih =>
    rw [show n+1+2=(n+2)+1 by omega, sum_Icc_succ_top (by omega : 2 ≤ n+2+1)]
    push_cast at ih ⊢
    have hh : 1/((n:ℝ)+2+1)^2 ≤ 1/((n:ℝ)+2)-1/((n:ℝ)+2+1) := by
      field_simp; nlinarith
    linarith

theorem population_lower {N : ℕ} (hN : 2 ≤ N) : (N:ℝ)^2 ≤ 8*(obs N).card := by
  have h := square_cover N
  have hr : (N:ℝ)*N ≤ 2*((obs N).card:ℝ)+∑ d ∈ Icc 2 N, (↑(N/d):ℝ)*↑(N/d) := by exact_mod_cast h
  have err : (∑ d ∈ Icc 2 N, (↑(N/d):ℝ)*↑(N/d)) ≤ (N:ℝ)^2*(3/4) := by
    calc _ ≤ ∑ d ∈ Icc 2 N, (N:ℝ)^2*(1/(d:ℝ)^2) := by
          apply sum_le_sum
          intro d hd
          have dp : (0:ℝ) < d := by exact_mod_cast (show 0<d by have := (mem_Icc.mp hd).1; omega)
          have dv : (↑(N/d):ℝ) ≤ N/d := (le_div_iff₀ dp).2 (by exact_mod_cast Nat.div_mul_le_self N d)
          calc _ ≤ ((N:ℝ)/d)*((N:ℝ)/d) := by gcongr
               _ = _ := by ring
         _ = _ := (mul_sum ..).symm
         _ ≤ _ := by
           apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
           obtain ⟨k,rfl⟩ := Nat.exists_eq_add_of_le hN
           have ht := recip_tail k
           rw [Nat.add_comm 2 k]
           exact ht.trans (sub_le_self _ (by positivity))
  linarith [sq_nonneg (N:ℝ)]
end AtlasMerge

