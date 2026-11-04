import FVLTWovenCertificateV1

/-!
Bounded sufficient-margin induction, allowing a fixed cylinder to be compared
through a finite safe horizon. The exact first-failure claim below uses both
this theorem and the separately checked row51 certificate.
-/
namespace FVLT.WovenFiniteHorizonV1
open WovenCanonicalV1 WovenEvolutionV1 WovenCertificateV1

theorem weave_eq_infinite_rep_up_to (L : ℕ → ℕ) (N : ℕ)
    (hpos : ∀ s, 0 < L s)
    (hcap : ∀ s, s ≤ N → 2 * s + 1 ≤ L s)
    (hgap : ∀ s, s < N → L (s + 1) / 2 + s + 1 < L s) :
    ∀ t, t ≤ N → ∀ i : ℤ, weave L t i = infinite t (rep (L t) i) := by
  intro t
  induction t with
  | zero => intro _ i; rfl
  | succ t ih =>
    intro ht i
    have htN : t < N := by omega
    let j := rep (L (t + 1)) i
    have hj : InWindow (L (t + 1)) j := rep_bounds _ (hpos _) _
    change rule (weave L t (j - 1)) (weave L t j) (weave L t (j + 1)) =
      rule (infinite t (j - 1)) (infinite t j) (infinite t (j + 1))
    have hm := parent_read_eq (L t) (L (t + 1)) t (hpos _) (hpos _)
      (hcap t (by omega)) (hgap t htN) j (-1) hj (by norm_num)
    have hz := parent_read_eq (L t) (L (t + 1)) t (hpos _) (hpos _)
      (hcap t (by omega)) (hgap t htN) j 0 hj (by norm_num)
    have hp := parent_read_eq (L t) (L (t + 1)) t (hpos _) (hpos _)
      (hcap t (by omega)) (hgap t htN) j 1 hj (by norm_num)
    simp only [add_zero] at hz
    have hm' : infinite t (rep (L t) (j - 1)) = infinite t (j - 1) := by
      simpa only [sub_eq_add_neg] using hm
    rw [ih (by omega) (j - 1), ih (by omega) j, ih (by omega) (j + 1),
      hm', hz, hp]

theorem weave_eq_infinite_window_up_to (L : ℕ → ℕ) (N : ℕ)
    (hpos : ∀ s, 0 < L s)
    (hcap : ∀ s, s ≤ N → 2 * s + 1 ≤ L s)
    (hgap : ∀ s, s < N → L (s + 1) / 2 + s + 1 < L s)
    (t : ℕ) (ht : t ≤ N) (i : ℤ) (hi : InWindow (L t) i) :
    weave L t i = infinite t i := by
  rw [weave_eq_infinite_rep_up_to L N hpos hcap hgap t ht i,
    rep_eq_self _ (hpos _) _ hi]

theorem weave_eq_infinite_core_up_to (L : ℕ → ℕ) (N : ℕ)
    (hpos : ∀ s, 0 < L s)
    (hcap : ∀ s, s ≤ N → 2 * s + 1 ≤ L s)
    (hgap : ∀ s, s < N → L (s + 1) / 2 + s + 1 < L s)
    (t : ℕ) (ht : t ≤ N) (i : ℤ) (hi : |i| ≤ (t : ℤ)) :
    weave L t i = infinite t i :=
  weave_eq_infinite_window_up_to L N hpos hcap hgap t ht i
    (core_in_window _ _ (hcap t ht) i hi)

/-- Every core label agrees through row50, not just a finite set of sample columns. -/
theorem fixed101_agrees_through50 (t : ℕ) (ht : t ≤ 50)
    (i : ℤ) (hi : |i| ≤ (t : ℤ)) :
    weave (fun _ => 101) t i = infinite t i := by
  exact weave_eq_infinite_core_up_to (fun _ => 101) 50
    (by intro s; norm_num)
    (by intro s hs; omega)
    (by intro s hs; omega) t ht i hi

def Fixed101CoreMismatch (t : ℕ) : Prop :=
  ∃ i : ℤ, |i| ≤ (t : ℤ) ∧ weave (fun _ => 101) t i ≠ infinite t i

theorem fixed101_mismatch_at51 : Fixed101CoreMismatch 51 :=
  ⟨51, by norm_num, fixed101_row51_mismatch⟩

/-- This is a first-core-mismatch theorem, rather than only the mismatch-at51 witness. -/
theorem fixed101_first_core_mismatch : IsLeast {t : ℕ | Fixed101CoreMismatch t} 51 := by
  refine ⟨fixed101_mismatch_at51, ?_⟩
  intro t ht
  by_contra hn
  have ht50 : t ≤ 50 := by omega
  obtain ⟨i, hi, hne⟩ := ht
  exact hne (fixed101_agrees_through50 t ht50 i hi)

end FVLT.WovenFiniteHorizonV1
