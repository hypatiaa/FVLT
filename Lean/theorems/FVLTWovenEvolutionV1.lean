import FVLTWovenCanonicalV1

/-! An actual changing-ring recurrence. Each step canonicalizes its CURRENT
label, then reads all three parents on the previous ring. The infinite source
is defined independently. Their agreement is proved under a sufficient margin,
not assumed by copying source rows into rings. -/
namespace FVLT.WovenEvolutionV1
open WovenCanonicalV1

def rule (a b c : Bool) : Bool := xor a (b || c)

def infinite (t : ℕ) : ℤ → Bool :=
  Nat.rec (fun i => decide (i=0))
    (fun _ prev i => rule (prev (i-1)) (prev i) (prev (i+1))) t

def weave (L : ℕ → ℕ) (t : ℕ) : ℤ → Bool :=
  Nat.rec (fun i => decide (rep (L 0) i=0))
    (fun t prev i => let j := rep (L (t+1)) i
      rule (prev (j-1)) (prev j) (prev (j+1))) t

theorem infinite_left_false : ∀ (t : ℕ) (i : ℤ),
    i < -(t : ℤ) → infinite t i=false
  | 0,i,hi => by simp [infinite]; omega
  | t+1,i,hi => by
      change rule (infinite t (i-1)) (infinite t i) (infinite t (i+1))=false
      rw [infinite_left_false t (i-1) (by omega),
        infinite_left_false t i (by omega), infinite_left_false t (i+1) (by omega)]
      rfl

theorem infinite_right_false : ∀ (t : ℕ) (i : ℤ),
    (t : ℤ) < i → infinite t i=false
  | 0,i,hi => by simp [infinite]; omega
  | t+1,i,hi => by
      change rule (infinite t (i-1)) (infinite t i) (infinite t (i+1))=false
      rw [infinite_right_false t (i-1) (by omega),
        infinite_right_false t i (by omega), infinite_right_false t (i+1) (by omega)]
      rfl

theorem infinite_support (t : ℕ) (i : ℤ) (hi : (t : ℤ) < |i|) :
    infinite t i=false := by
  by_cases hl : i < -(t : ℤ)
  · exact infinite_left_false t i hl
  · apply infinite_right_false t i
    by_contra hn
    have ha : |i| ≤ (t : ℤ) := abs_le.mpr ⟨by omega, by omega⟩
    omega

theorem weave_respects_mod (L : ℕ → ℕ) (t : ℕ) (hL : 0<L t)
    (i j : ℤ) (he : i % (L t : ℤ)=j % (L t : ℤ)) :
    weave L t i=weave L t j := by
  have hr := (rep_eq_iff_mod (L t) hL i j).mpr he
  cases t with
  | zero => simp [weave, hr]
  | succ t => simp [weave, hr]

theorem parent_read_eq (L Lnext t : ℕ) (hL : 0<L) (hn : 0<Lnext)
    (hcap : 2*t+1≤L) (hgap : Lnext/2+t+1<L)
    (j δ : ℤ) (hj : InWindow Lnext j) (hd : |δ|≤1) :
    infinite t (rep L (j+δ))=infinite t (j+δ) := by
  by_cases hi : |j+δ|≤(t : ℤ)
  · rw [rep_core L t hcap _ hi]
  · have ho : (t : ℤ) < |j+δ| := by omega
    rw [infinite_support t _ (parent_outside_core L Lnext t hL hn hgap j δ hj hd ho),
      infinite_support t _ ho]

/-- Sufficient conditions only. The theorem does not assert their necessity. -/
theorem weave_eq_infinite_rep (L : ℕ → ℕ) (hpos : ∀t,0<L t)
    (hcap : ∀t,2*t+1≤L t) (hgap : ∀t,L (t+1)/2+t+1<L t) :
    ∀ (t : ℕ) (i : ℤ), weave L t i=infinite t (rep (L t) i)
  | 0,i => rfl
  | t+1,i => by
      let j := rep (L (t+1)) i
      have hj : InWindow (L (t+1)) j := rep_bounds _ (hpos _) _
      change rule (weave L t (j-1)) (weave L t j) (weave L t (j+1))=
        rule (infinite t (j-1)) (infinite t j) (infinite t (j+1))
      have hm := parent_read_eq (L t) (L (t+1)) t (hpos _) (hpos _) (hcap _) (hgap _) j (-1) hj (by norm_num)
      have hz := parent_read_eq (L t) (L (t+1)) t (hpos _) (hpos _) (hcap _) (hgap _) j 0 hj (by norm_num)
      have hp := parent_read_eq (L t) (L (t+1)) t (hpos _) (hpos _) (hcap _) (hgap _) j 1 hj (by norm_num)
      simp only [add_zero] at hz
      have hm' : infinite t (rep (L t) (j-1))=infinite t (j-1) := by
        simpa only [sub_eq_add_neg] using hm
      rw [weave_eq_infinite_rep L hpos hcap hgap t (j-1),
        weave_eq_infinite_rep L hpos hcap hgap t j,
        weave_eq_infinite_rep L hpos hcap hgap t (j+1), hm', hz, hp]

theorem weave_eq_infinite_window (L : ℕ → ℕ) (hpos : ∀t,0<L t)
    (hcap : ∀t,2*t+1≤L t) (hgap : ∀t,L (t+1)/2+t+1<L t)
    (t : ℕ) (i : ℤ) (hi : InWindow (L t) i) : weave L t i=infinite t i := by
  rw [weave_eq_infinite_rep L hpos hcap hgap, rep_eq_self _ (hpos _) _ hi]

theorem weave_eq_infinite_core (L : ℕ → ℕ) (hpos : ∀t,0<L t)
    (hcap : ∀t,2*t+1≤L t) (hgap : ∀t,L (t+1)/2+t+1<L t)
    (t : ℕ) (i : ℤ) (hi : |i|≤(t : ℤ)) : weave L t i=infinite t i := by
  exact weave_eq_infinite_window L hpos hcap hgap t i (core_in_window _ _ (hcap t) i hi)

theorem weave_outside_core (L : ℕ → ℕ) (hpos : ∀t,0<L t)
    (hcap : ∀t,2*t+1≤L t) (hgap : ∀t,L (t+1)/2+t+1<L t)
    (t : ℕ) (i : ℤ) (hi : InWindow (L t) i) (hout : (t : ℤ) < |i|) :
    weave L t i=false := by
  rw [weave_eq_infinite_window L hpos hcap hgap t i hi]
  exact infinite_support t i hout

theorem linear_two_plus_five (t : ℕ) (i : ℤ) (hi : |i|≤(t : ℤ)) :
    weave (fun s=>2*s+5) t i=infinite t i := by
  apply weave_eq_infinite_core (fun s=>2*s+5) (by intro s; omega)
    (by intro s; omega) (by intro s; omega) t i hi

theorem minimal_length_row_two_mismatch :
    weave (fun t=>2*t+3) 2 2 ≠ infinite 2 2 := by decide

theorem minimal_length_initial_core :
    ∀t : Fin 2, ∀k : Fin (2*t.val+1),
      weave (fun s=>2*s+3) t.val ((k.val : ℤ)-(t.val : ℤ))=
        infinite t.val ((k.val : ℤ)-(t.val : ℤ)) := by decide

theorem minimal_length_before_two (t : ℕ) (ht : t<2)
    (i : ℤ) (hi : |i|≤(t : ℤ)) :
    weave (fun s=>2*s+3) t i=infinite t i := by
  have hb := abs_le.mp hi
  let k : Fin (2*t+1) := ⟨(i+(t : ℤ)).toNat, by omega⟩
  have hk : (k.val : ℤ)-(t : ℤ)=i := by dsimp [k]; omega
  simpa only [hk] using minimal_length_initial_core ⟨t,ht⟩ k

end FVLT.WovenEvolutionV1
