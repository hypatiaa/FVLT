import BlockMatching
namespace AtlasLog
open Finset
noncomputable section

def blockCost (t h : ℕ) : ℝ := max |(blockSum false t h:ℝ)| |(blockSum true t h:ℝ)|
private theorem cost_nn (t h : ℕ) : 0 ≤ blockCost t h := (abs_nonneg _).trans (le_max_left ..)

private theorem adj {a b c h : ℕ} {u v : ℝ} (ab : a≤b) (bc : b≤c)
    (p : Fits (Ioc a b) h u) (q : Fits (Ioc b c) h v) : Fits (Ioc a c) h (u+v) := by
  have d : Disjoint (Ioc a b) (Ioc b c) := disjoint_left.mpr fun _ h1 h2 =>
    (not_lt_of_ge (mem_Ioc.mp h1).2) (mem_Ioc.mp h2).1
  have eq : Ioc a b ∪ Ioc b c = Ioc a c := by ext; simp only [mem_union,mem_Ioc]; omega
  rw [←eq]; exact fits_union d p q

private theorem run_blocks (start h k : ℕ) :
    Fits (Ioc start (start+k*h)) h (∑ i ∈ range k, blockCost (start+i*h) h) := by
  induction k with
  | zero => simpa using fits_empty_edges (∅ : Finset ℕ) h
  | succ k ih =>
    rw [sum_range_succ,Nat.succ_mul,←Nat.add_assoc]
    exact adj (Nat.le_add_right ..) (Nat.le_add_right ..) ih (full_block_matching ..)

def starts (X h : ℕ) := Icc (X/2) (X-h)

private theorem offset_match (X h : ℕ) (hh : 0<h) (room : X/2+h ≤ X) (j : Fin h) :
    Fits (Ioc (X/2) X) h (2*h + ∑ t ∈ starts X h, if (t-X/2)%h=j.val then blockCost t h else 0) := by
  let L := X/2
  let s := L+j.val
  let k := (X-s)/h
  let e := s+k*h
  have jj := j.isLt
  have ls : L ≤ s := Nat.le_add_right ..
  have sx : s≤X := by dsimp [s,L]; omega
  have ke := Nat.div_add_mod (X-s) h
  have rem := Nat.mod_lt (X-s) hh
  have ex : e≤X := by dsimp [e,k]; rw [Nat.mul_comm _ h]; omega
  have tail : X-e < h := by dsimp [e,k]; rw [Nat.mul_comm _ h]; omega
  let f (i : ℕ) := s+i*h
  have inj : Function.Injective f := fun i j e => Nat.eq_of_mul_eq_mul_right hh (Nat.add_left_cancel e)
  have sub : (range k).image f ⊆ (starts X h).filter (fun t => (t-X/2)%h=j.val) := by
    intro t ht
    obtain ⟨i,hi,rfl⟩ := mem_image.mp ht
    have small := mem_range.mp hi
    have endpt : s+i*h+h ≤ e := by
      have := Nat.mul_le_mul_right h (show i+1≤k by omega)
      dsimp [e]; rw [Nat.succ_mul] at this; omega
    apply mem_filter.mpr
    refine ⟨mem_Icc.mpr ⟨ls.trans (Nat.le_add_right ..),?_⟩,?_⟩
    · change s+i*h ≤ X-h; omega
    · change (L+j.val+i*h-L)%h=j.val
      rw [show L+j.val+i*h-L=j.val+i*h by omega,Nat.add_mul_mod_self_right,Nat.mod_eq_of_lt jj]
  have dom : (∑ i ∈ range k, blockCost (s+i*h) h) ≤
      ∑ t ∈ starts X h, if (t-X/2)%h=j.val then blockCost t h else 0 := by
    rw [←sum_filter]
    calc _ = ∑ t ∈ (range k).image f, blockCost t h := (sum_image (fun _ _ _ _ eq => inj eq)).symm
         _ ≤ _ := sum_le_sum_of_subset_of_nonneg sub (fun t _ _ => cost_nn t h)
  have one := fits_empty_edges (Ioc L s) h
  have two := run_blocks s h k
  have three := fits_empty_edges (Ioc e X) h
  have together := adj (ls.trans (Nat.le_add_right s (k*h))) ex
    (adj ls (Nat.le_add_right s (k*h)) one two) three
  apply fits_mono together
  simp only [Nat.card_Ioc]
  have head : s-L<h := by dsimp [s]; omega
  have hs : ((s-L:ℕ):ℝ) ≤ h := by exact_mod_cast head.le
  have ht : ((X-e:ℕ):ℝ) ≤ h := by exact_mod_cast tail.le
  linarith

/-- One common matching, with the best full-block offset chosen on the actual band. -/
theorem averaged_block_matching (X h : ℕ) (hh : 0<h) (room : X/2+h ≤ X) :
    Fits (Ioc (X/2) X) h (2*h + (∑ t ∈ starts X h, blockCost t h)/h) := by
  let row (j : Fin h) : ℝ := ∑ t ∈ starts X h, if (t-X/2)%h=j.val then blockCost t h else 0
  let off (t : ℕ) : Fin h := ⟨(t-X/2)%h,Nat.mod_lt _ hh⟩
  have sumRows : ∑ j, row j = ∑ t ∈ starts X h, blockCost t h := by
    unfold row; rw [sum_comm]; apply sum_congr rfl; intro t _
    change (∑ j : Fin h, if (off t).val=j.val then _ else _) = _
    simp only [Fin.val_inj]; simp
  have pos : (0:ℝ)<h := by exact_mod_cast hh
  have best : ∃ j : Fin h, row j ≤ (∑ t ∈ starts X h, blockCost t h)/h := by
    by_contra! bad
    have ne : (univ : Finset (Fin h)).Nonempty := ⟨⟨0,hh⟩,mem_univ _⟩
    have hs := sum_lt_sum_of_nonempty ne (fun j _ => bad j)
    rw [sumRows] at hs; simp at hs; field_simp at hs; linarith
  obtain ⟨j,hj⟩ := best
  exact fits_mono (offset_match X h hh room j) (add_le_add_right hj _)
end
end AtlasLog
