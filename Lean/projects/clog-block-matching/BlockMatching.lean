import LogSurplus

namespace AtlasLog
open Finset
noncomputable section

abbrev Edge := ℕ × ℕ
def active (s : Finset ℕ) := s.filter fun n => bandWeight false n ≠ 0
def imbalance (s : Finset ℕ) : ℤ := ∑ n ∈ s, bandWeight false n

/-- An edge joins two actual rows and reverses both signs. Each endpoint projection
is injective on the chosen edges. Positive and negative sides are disjoint. -/
def Legal (s : Finset ℕ) (h : ℕ) (E : Finset Edge) : Prop :=
  (∀ e ∈ E, e.1 ∈ s ∧ e.2 ∈ s ∧ bandWeight false e.1 = 1 ∧ bandWeight false e.2 = -1 ∧
    bandWeight true e.1 = -bandWeight true e.2 ∧ Nat.dist e.1 e.2 ≤ 2*h) ∧
  Set.InjOn Prod.fst (↑E : Set Edge) ∧ Set.InjOn Prod.snd (↑E : Set Edge)

def Fits (s : Finset ℕ) (h : ℕ) (u : ℝ) : Prop :=
  ∃ E, Legal s h E ∧ ((active s).card:ℝ) - 2*(E.card:ℝ) ≤ u

/-- The real-valued loss is the cardinality of the active denominators left
unmatched, including all band endpoints. -/
theorem residual_card {s h E} (H : Legal s h E) :
    (((active s \ (E.image Prod.fst ∪ E.image Prod.snd)).card:ℕ):ℝ) =
      ((active s).card:ℝ)-2*(E.card:ℝ) := by
  obtain ⟨ok,hl,hr⟩ := H
  have dis : Disjoint (E.image Prod.fst) (E.image Prod.snd) := by
    apply disjoint_left.mpr; rintro n hp hm
    obtain ⟨a,ha,ea⟩ := mem_image.mp hp; obtain ⟨b,hb,eb⟩ := mem_image.mp hm
    have p := (ok a ha).2.2.1; have m := (ok b hb).2.2.2.1
    rw [ea] at p; rw [eb] at m; omega
  have sub : E.image Prod.fst ∪ E.image Prod.snd ⊆ active s := by
    intro n hn; rcases mem_union.mp hn with hp|hm
    · obtain ⟨a,ha,rfl⟩ := mem_image.mp hp
      exact mem_filter.mpr ⟨(ok a ha).1,by rw [(ok a ha).2.2.1]; decide⟩
    · obtain ⟨a,ha,rfl⟩ := mem_image.mp hm
      exact mem_filter.mpr ⟨(ok a ha).2.1,by rw [(ok a ha).2.2.2.1]; decide⟩
  have eq := card_sdiff_add_card_eq_card sub
  rw [card_union_of_disjoint dis,card_image_of_injOn hl,card_image_of_injOn hr] at eq
  exact_mod_cast (show (((active s \ (E.image Prod.fst ∪ E.image Prod.snd)).card:ℕ):ℤ) =
    ((active s).card:ℤ)-2*(E.card:ℤ) by omega)

theorem fits_mono {s h u v} (h1 : Fits s h u) (h2 : u ≤ v) : Fits s h v := by
  obtain ⟨E,he,hu⟩ := h1; exact ⟨E,he,hu.trans h2⟩

theorem fits_empty_edges (s : Finset ℕ) (h : ℕ) : Fits s h (s.card:ℝ) := by
  refine ⟨∅,by simp [Legal],?_⟩
  simpa using (show ((active s).card:ℝ) ≤ s.card by exact_mod_cast card_filter_le ..)

theorem fits_union {s t : Finset ℕ} {h u v} (d : Disjoint s t)
    (hs : Fits s h u) (ht : Fits t h v) : Fits (s∪t) h (u+v) := by
  obtain ⟨E,⟨e,el,er⟩,eu⟩ := hs
  obtain ⟨F,⟨f,fl,fr⟩,fv⟩ := ht
  have D := disjoint_left.mp d
  have ed : Disjoint E F := disjoint_left.mpr fun a ha hb => D (e a ha).1 (f a hb).1
  have inj {g : Edge → ℕ} (es : ∀ a ∈ E, g a ∈ s) (fs : ∀ a ∈ F, g a ∈ t)
      (le : Set.InjOn g (↑E : Set Edge)) (lf : Set.InjOn g (↑F : Set Edge)) : Set.InjOn g (↑(E∪F) : Set Edge) := by
    intro a ha b hb eq
    rcases mem_union.mp ha with ha|ha <;> rcases mem_union.mp hb with hb|hb
    · exact le ha hb eq
    · exact False.elim (D (es a ha) (eq ▸ fs b hb))
    · exact False.elim (D (es b hb) (eq ▸ fs a ha))
    · exact lf ha hb eq
  refine ⟨E∪F,⟨?_,inj (fun a ha => (e a ha).1) (fun a ha => (f a ha).1) el fl,
    inj (fun a ha => (e a ha).2.1) (fun a ha => (f a ha).2.1) er fr⟩,?_⟩
  · intro a ha; rcases mem_union.mp ha with h1|h2
    · obtain ⟨l,r,z⟩ := e a h1; exact ⟨mem_union_left _ l,mem_union_left _ r,z⟩
    · obtain ⟨l,r,z⟩ := f a h2; exact ⟨mem_union_right _ l,mem_union_right _ r,z⟩
  · have eq : active (s∪t) = active s ∪ active t := filter_union ..
    have ad : Disjoint (active s) (active t) := d.mono (filter_subset ..) (filter_subset ..)
    rw [eq,card_union_of_disjoint ad,card_union_of_disjoint ed]; push_cast; linarith

private theorem unit_weight (n : ℕ) : bandWeight false n = -1 ∨ bandWeight false n = 0 ∨ bandWeight false n = 1 := by
  have h := ArithmeticFunction.moebius_eq_or n
  change (if n.Coprime 6 then _ else _) = _ ∨ _ 
  unfold bandWeight at *
  split_ifs <;> grind

private theorem twisted (n : ℕ) : bandWeight true n =
    if n%4=3 then -bandWeight false n else bandWeight false n := by
  unfold bandWeight; split_ifs <;> grind

private def positives (s : Finset ℕ) := s.filter fun n => bandWeight false n = 1
private def negatives (s : Finset ℕ) := s.filter fun n => bandWeight false n = -1

private theorem counts (s : Finset ℕ) :
    (active s).card = (positives s).card + (negatives s).card ∧
    imbalance s = ((positives s).card:ℤ) - (negatives s).card := by
  have dis : Disjoint (positives s) (negatives s) := disjoint_left.mpr (by
    intro x h k; have := (mem_filter.mp h).2; have := (mem_filter.mp k).2; omega)
  have eq : active s = positives s ∪ negatives s := by
    ext x; simp only [active,positives,negatives,mem_union,mem_filter]; rcases unit_weight x with z|z|z <;> simp [z]
  refine ⟨eq ▸ card_union_of_disjoint dis,?_⟩
  have ind (n : ℕ) : bandWeight false n = (if bandWeight false n=1 then (1:ℤ) else 0) -
      (if bandWeight false n= -1 then 1 else 0) := by rcases unit_weight n with z|z|z <;> norm_num [z]
  unfold imbalance positives negatives
  conv_lhs => arg 2; ext n; rw [ind n]
  rw [sum_sub_distrib,← sum_filter,← sum_filter]; simp

/-- Enumerate both sign classes in order and pair their first min(card+,card−) rows. -/
private theorem matching_min (P M : Finset ℕ) :
    ∃ E : Finset Edge, (∀ e ∈ E, e.1 ∈ P ∧ e.2 ∈ M) ∧ Set.InjOn Prod.fst (↑E : Set Edge) ∧
      Set.InjOn Prod.snd (↑E : Set Edge) ∧ E.card = min P.card M.card := by
  let k := min P.card M.card
  let a (i : Fin k) := P.orderEmbOfFin rfl (i.castLE (min_le_left ..))
  let b (i : Fin k) := M.orderEmbOfFin rfl (i.castLE (min_le_right ..))
  have ai : Function.Injective a := fun i j eq => Fin.ext (Fin.mk.inj ((P.orderEmbOfFin rfl).injective eq))
  have bi : Function.Injective b := fun i j eq => Fin.ext (Fin.mk.inj ((M.orderEmbOfFin rfl).injective eq))
  let g (i : Fin k) : Edge := (a i,b i)
  have gi : Function.Injective g := fun i j eq => ai (congrArg Prod.fst eq)
  refine ⟨univ.image g,?_,?_,?_,?_⟩
  · rintro _ he; obtain ⟨i,_,rfl⟩ := mem_image.mp he; exact ⟨P.orderEmbOfFin_mem ..,M.orderEmbOfFin_mem ..⟩
  · intro x hx y hy eq; obtain ⟨i,_,rfl⟩ := mem_image.mp hx; obtain ⟨j,_,rfl⟩ := mem_image.mp hy
    exact congrArg g (ai eq)
  · intro x hx y hy eq; obtain ⟨i,_,rfl⟩ := mem_image.mp hx; obtain ⟨j,_,rfl⟩ := mem_image.mp hy
    exact congrArg g (bi eq)
  · simp [card_image_of_injective _ gi,k]

private theorem class_match (s : Finset ℕ) (h : ℕ)
    (near : ∀ i ∈ s, ∀ j ∈ s, Nat.dist i j ≤ 2*h)
    (same : ∀ i ∈ s, ∀ j ∈ s, (i%4=3 ↔ j%4=3)) :
    Fits s h |(imbalance s:ℝ)| := by
  obtain ⟨E,e,el,er,ek⟩ := matching_min (positives s) (negatives s)
  refine ⟨E,⟨?_,el,er⟩,?_⟩
  · intro x hx; obtain ⟨l,r⟩ := e x hx
    obtain ⟨ls,lp⟩ := mem_filter.mp l; obtain ⟨rs,rp⟩ := mem_filter.mp r
    refine ⟨ls,rs,lp,rp,?_,near _ ls _ rs⟩
    rw [twisted,twisted,lp,rp]; have hs := same _ ls _ rs; split_ifs <;> grind
  · have c := counts s
    rw [c.1,c.2,ek]; push_cast; rw [abs_sub_comm]; rcases le_total (positives s).card (negatives s).card with le|le
    · rw [min_eq_left (by exact_mod_cast le),abs_of_nonneg (by exact_mod_cast (Int.sub_nonneg.mpr (by exact_mod_cast le) : (0:ℤ)≤(negatives s).card-(positives s).card))]; linarith
    · rw [min_eq_right (by exact_mod_cast le),abs_of_nonpos (by exact_mod_cast (sub_nonpos.mpr (by exact_mod_cast le) : ((negatives s).card:ℤ)-(positives s).card≤0))]; linarith

theorem full_block_matching (t h : ℕ) :
    Fits (Ioc t (t+h)) h (max |(blockSum false t h:ℝ)| |(blockSum true t h:ℝ)|) := by
  let s := Ioc t (t+h)
  let A := s.filter fun n => ¬ n%4=3
  let B := s.filter fun n => n%4=3
  have near (i) (hi : i ∈ s) (j) (hj : j ∈ s) : Nat.dist i j ≤ 2*h := by
    obtain ⟨_,_⟩ := mem_Ioc.mp hi; obtain ⟨_,_⟩ := mem_Ioc.mp hj; simp only [Nat.dist]; omega
  have ma := class_match A h (fun _ hi _ hj => near _ (mem_filter.mp hi).1 _ (mem_filter.mp hj).1)
    (fun _ hi _ hj => iff_of_false (mem_filter.mp hi).2 (mem_filter.mp hj).2)
  have mb := class_match B h (fun _ hi _ hj => near _ (mem_filter.mp hi).1 _ (mem_filter.mp hj).1)
    (fun _ hi _ hj => iff_of_true (mem_filter.mp hi).2 (mem_filter.mp hj).2)
  have dis : Disjoint A B := disjoint_left.mpr fun _ ha hb => (mem_filter.mp ha).2 (mem_filter.mp hb).2
  have join : A∪B=s := by ext; simp [A,B]; tauto
  have m := fits_union dis ma mb
  rw [join] at m
  have eq1 : blockSum false t h = imbalance A + imbalance B := by
    unfold blockSum imbalance; rw [←sum_union dis,join]
  have eq4 : blockSum true t h = imbalance A - imbalance B := by
    change (∑ n ∈ s, _) = _
    rw [←join,sum_union dis]; unfold imbalance
    rw [sub_eq_add_neg,←sum_neg_distrib]; congr 1
    · apply sum_congr rfl; intro n hn; simp [twisted n,(mem_filter.mp hn : _ ∧ _).2]
    · apply sum_congr rfl; intro n hn; simp [twisted n,(mem_filter.mp hn : _ ∧ _).2]
  rw [eq1,eq4]; push_cast; rw [← simultaneous_residual]; exact m
end
end AtlasLog
