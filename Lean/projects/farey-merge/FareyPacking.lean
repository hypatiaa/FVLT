import FareyCount
namespace AtlasMerge
open Finset
private theorem scaled_spacing {N : ℕ} {x y : ℚ} (hx : x ∈ farey N) (hy : y ∈ farey N)
    (hlt : x < y) : 1 ≤ ((y:ℝ)-x)*(N:ℝ)^2 := by
  have hd := Nat.le_of_dvd (Nat.mul_pos y.den_pos x.den_pos) (Rat.sub_den_dvd y x)
  have hu : (y-x).den ≤ N*N := hd.trans (Nat.mul_le_mul ((farey_iff ..).1 hy).2.2 ((farey_iff ..).1 hx).2.2)
  have hp : (0:ℚ) < y-x := sub_pos.mpr hlt
  have hnum : 0 < (y-x).num := Rat.num_pos.mpr hp
  have he : (y-x)*((y-x).den:ℚ) = (y-x).num := by
    exact (eq_div_iff (by exact_mod_cast (y-x).den_pos.ne')).mp (Rat.num_div_den _).symm
  have hg : (1:ℚ) ≤ (y-x)*((N:ℚ)^2) := calc
    _ ≤ ((y-x).num:ℚ) := by exact_mod_cast (show (1:ℤ) ≤ (y-x).num by omega)
    _ = _ := he.symm
    _ ≤ _ := mul_le_mul_of_nonneg_left (by rw [sq]; exact_mod_cast hu) hp.le
  exact_mod_cast hg

/-- The floor bins have width one in units of 1/N². -/
theorem packing {N : ℕ} (s : Finset ℚ) (hs : s ⊆ farey N) (l u : ℝ)
    (hlu : l ≤ u) (h : ∀ z ∈ s, l ≤ (z:ℝ) ∧ (z:ℝ) ≤ u) :
    (s.card:ℝ) ≤ 1+(u-l)*N^2 := by
  let f := fun z : ℚ => ⌊((z:ℝ)-l)*N^2⌋₊
  have mono {x y} (hx : x ∈ s) (hy : y ∈ s) (hlt : x < y) : f x < f y := by
    have hh := scaled_spacing (hs hx) (hs hy) hlt
    have hx' : (f x:ℝ) ≤ ((x:ℝ)-l)*N^2 := Nat.floor_le (mul_nonneg (sub_nonneg.mpr (h x hx).1) (sq_nonneg _))
    have hh' : ((f x+1:ℕ):ℝ) ≤ ((y:ℝ)-l)*N^2 := by push_cast; linarith
    exact Nat.le_floor hh'
  have hc : s.card ≤ (Icc 0 ⌊(u-l)*N^2⌋₊).card := by
    apply card_le_card_of_injOn f
    · intro z hz
      apply mem_Icc.mpr
      exact ⟨Nat.zero_le _, Nat.floor_mono (by gcongr; exact (h z hz).2)⟩
    · intro x hx y hy he
      rcases lt_trichotomy x y with h|h|h
      · exact False.elim ((mono hx hy h).ne he)
      · exact h
      · exact False.elim ((mono hy hx h).ne he.symm)
  simp at hc
  have bound := Nat.floor_le (mul_nonneg (sub_nonneg.mpr hlu) (sq_nonneg (N:ℝ)))
  exact (show (s.card:ℝ) ≤ ↑⌊(u-l)*N^2⌋₊ + 1 by exact_mod_cast hc).trans (by linarith)

def rankAt (N : ℕ) (x : ℚ) := ((obs N).filter (· ≤ x)).card

private theorem rank_diff {N : ℕ} {x y : ℚ} (hx : x ∈ farey N) (_hy : y ∈ farey N) (hxy : x ≤ y) :
    rankAt N x ≤ rankAt N y ∧ (rankAt N y:ℝ)-rankAt N x ≤ ((y:ℝ)-x)*N^2 := by
  let s := (farey N).filter (fun z => x ≤ z ∧ z ≤ y)
  let a := (obs N).filter (· ≤ x)
  let b := (obs N).filter (· ≤ y)
  have ab : a ⊆ b := fun z hz => mem_filter.mpr ⟨(mem_filter.mp hz).1, (mem_filter.mp hz).2.trans hxy⟩
  have hx' : x ∈ s := mem_filter.mpr ⟨hx,le_rfl,hxy⟩
  have sub : b \ a ⊆ s.erase x := by
    intro z hz
    obtain ⟨hz,hn⟩ := mem_sdiff.mp hz
    obtain ⟨ho,hy'⟩ := mem_filter.mp hz
    have hlt : x < z := lt_of_not_ge fun h => hn (mem_filter.mpr ⟨ho,h⟩)
    exact mem_erase.mpr ⟨hlt.ne',mem_filter.mpr ⟨(mem_erase.mp ho).2,hlt.le,hy'⟩⟩
  have hc := card_le_card sub
  rw [card_sdiff_of_subset ab,card_erase_of_mem hx'] at hc
  have c := packing s (filter_subset ..) (x:ℝ) y (by exact_mod_cast hxy) (fun z hz =>
    ⟨by exact_mod_cast (mem_filter.mp hz).2.1,by exact_mod_cast (mem_filter.mp hz).2.2⟩)
  have hab := card_le_card ab
  have hpos := card_pos.mpr ⟨x,hx'⟩
  have step : b.card+1 ≤ s.card+a.card := by omega
  refine ⟨hab,?_⟩
  change (b.card:ℝ)-a.card ≤ _
  have step' : (b.card:ℝ)+1 ≤ s.card+a.card := by exact_mod_cast step
  linarith

theorem population_upper {N : ℕ} (hN : 1 ≤ N) : ((obs N).card:ℝ) ≤ (N:ℝ)^2 := by
  have hx : (0:ℚ) ∈ farey N := (farey_iff ..).2 ⟨by norm_num,by norm_num,by simpa using hN⟩
  have hy : (1:ℚ) ∈ farey N := (farey_iff ..).2 ⟨by norm_num,by norm_num,by simpa using hN⟩
  have h := (rank_diff hx hy (by norm_num)).2
  have r0 : rankAt N 0 = 0 := by
    apply card_eq_zero.mpr
    apply eq_empty_iff_forall_notMem.mpr
    intro z hz
    obtain ⟨hz,hle⟩ := mem_filter.mp hz
    obtain ⟨hne,hm⟩ := mem_erase.mp hz
    exact hne (le_antisymm hle ((farey_iff ..).1 hm).1)
  have r1 : rankAt N 1 = (obs N).card := congrArg card (filter_true_of_mem fun z hz =>
    ((farey_iff ..).1 (mem_erase.mp hz).2).2.1)
  simpa [r0,r1] using h

def fibre (N : ℕ) (b : ℚ) := (obs N).filter (twoLevelAnchor N · = b)

theorem fibre_population {N : ℕ} (hN : 4 ≤ N) (b : ℚ) (hb : b ∈ farey (N/4)) :
    ((fibre N b).card:ℝ) ≤ 25*N/b.den := by
  let R : ℝ := 12/((b.den:ℝ)*N)
  have bpos : (0:ℝ) < b.den := by exact_mod_cast b.den_pos
  have Npos : (0:ℝ) < N := by exact_mod_cast (show 0<N by omega)
  have bN : (b.den:ℝ) ≤ N := by exact_mod_cast (((farey_iff ..).1 hb).2.2.trans (Nat.div_le_self ..))
  have rp : 0 ≤ R := by dsimp [R]; positivity
  have h := packing (fibre N b) (fun _ hz => (mem_erase.mp (mem_filter.mp hz).1).2)
    ((b:ℝ)-R) (b+R) (by linarith) (by
      intro z hz
      obtain ⟨ho,e⟩ := mem_filter.mp hz
      have hr := (actual_radius hN (mem_erase.mp ho).2).2
      change twoLevelAnchor N z = b at e; rw [e] at hr
      have h' : |(z:ℝ)-(b:ℝ)| ≤ R := by
        dsimp [R]; simpa only [Rat.cast_abs,Rat.cast_sub,Rat.cast_div,Rat.cast_mul,Rat.cast_natCast,Rat.cast_ofNat] using (Rat.cast_le (K:=ℝ)).mpr hr
      rw [abs_le] at h'; constructor <;> linarith)
  apply h.trans
  dsimp [R]; field_simp; nlinarith [mul_le_mul_of_nonneg_right bN Npos.le]

theorem displacement_at_anchor {N : ℕ} (hN : 4 ≤ N) {r : ℚ} (hr : r ∈ obs N) :
    let b := twoLevelAnchor N r
    |((displacement N r:ℚ):ℝ)-((displacement N b:ℚ):ℝ)| ≤
      12*N/(((obs N).card:ℝ)*b.den) := by
  intro b
  have hn : (0:ℝ) < N := by exact_mod_cast (show 0<N by omega)
  have hm := population_lower (show 2 ≤ N by omega)
  have mp : 0 < ((obs N).card:ℝ) := by nlinarith [sq_pos_of_pos hn]
  have hrf := (mem_erase.mp hr).2
  obtain ⟨hb,hrad⟩ := actual_radius hN hrf
  have hbf := (farey_iff N b).2 ⟨((farey_iff ..).1 hb).1, ((farey_iff ..).1 hb).2.1,
    ((farey_iff ..).1 hb).2.2.trans (Nat.div_le_self ..)⟩
  push_cast [displacement]
  change |((r:ℝ)-(rankAt N r:ℝ)/(obs N).card)-((b:ℝ)-(rankAt N b:ℝ)/(obs N).card)| ≤ _
  apply displacement_change _ _ _ _ _ _ _ hn (by exact_mod_cast b.den_pos) mp
    (population_upper (by omega)) (by simpa only [Rat.cast_abs,Rat.cast_sub,Rat.cast_div,Rat.cast_mul,Rat.cast_natCast,Rat.cast_ofNat] using (Rat.cast_le (K:=ℝ)).mpr hrad)
  · rcases le_total r b with h|h
    · obtain ⟨hle,hh⟩ := rank_diff hrf hbf h
      rw [abs_of_nonpos (by apply sub_nonpos.mpr; exact_mod_cast hle : (rankAt N r:ℝ)-rankAt N b ≤ 0),
        abs_of_nonpos (by exact_mod_cast sub_nonpos.mpr h : (r:ℝ)-b ≤ 0)]
      linarith
    · obtain ⟨hle,hh⟩ := rank_diff hbf hrf h
      rw [abs_of_nonneg (by apply sub_nonneg.mpr; exact_mod_cast hle : 0 ≤ (rankAt N r:ℝ)-rankAt N b),
        abs_of_nonneg (by exact_mod_cast sub_nonneg.mpr h : 0 ≤ (r:ℝ)-b)]
      linarith
  · rcases le_total r b with h|h
    · exact Or.inl ⟨by exact_mod_cast h,by exact_mod_cast (rank_diff hrf hbf h).1⟩
    · exact Or.inr ⟨by exact_mod_cast h,by exact_mod_cast (rank_diff hbf hrf h).1⟩
end AtlasMerge

