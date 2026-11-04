import FVLTFareyContactV1
import Mathlib.Combinatorics.SimpleGraph.Connectivity.Finite
import Mathlib.Combinatorics.SimpleGraph.Finite
import Mathlib.NumberTheory.Divisors
import Mathlib.Data.Rat.Lemmas
import Mathlib.Tactic

/-! FF-1 F2. Classical Farey arithmetic and exact finite component certificates.
Framework assembled by Robin Miller; classical components credited in the order.
No geometric or Rule 30 conclusion is asserted here. -/
namespace FVLT.FareyContactV1
#print SimpleGraph.Connected
#print SimpleGraph.Preconnected

theorem fareyAdj_symm (x y : ℚ) : fareyAdj x y ↔ fareyAdj y x := by
  unfold fareyAdj det
  rw [show y.num * (x.den : ℤ) - x.num * (y.den : ℤ) =
    -(x.num * (y.den : ℤ) - y.num * (x.den : ℤ)) by ring, abs_neg]

theorem fareyAdj_irrefl (x : ℚ) : ¬ fareyAdj x x := by
  simp [fareyAdj, det]

instance (x y : ℚ) : Decidable (fareyAdj x y) :=
  inferInstanceAs (Decidable (|det x y| = 1))

def fareyGraph (S : Finset ℚ) : SimpleGraph {x : ℚ // x ∈ S} where
  Adj x y := fareyAdj x.val y.val
  symm := ⟨fun _ _ h => (fareyAdj_symm _ _).mp h⟩
  loopless := ⟨fun x => fareyAdj_irrefl x.val⟩

instance (S : Finset ℚ) : DecidableRel (fareyGraph S).Adj :=
  fun x y => inferInstanceAs (Decidable (|det x.val y.val| = 1))

instance (S : Finset ℚ) (s : Finset {x : ℚ // x ∈ S}) :
    DecidableRel ((fareyGraph S).induce (s : Set {x : ℚ // x ∈ S})).Adj :=
  fun x y => inferInstanceAs (Decidable (fareyAdj x.val.val y.val.val))

theorem fareyGraph_adj (S : Finset ℚ) (x y : {x : ℚ // x ∈ S}) :
  (fareyGraph S).Adj x y ↔ fareyAdj x.val y.val := Iff.rfl

def admissible (α : List ℕ) : Finset ℕ :=
  α.toFinset.biUnion (fun a => (a + 1).divisors.filter (fun q => 2 ≤ q))
def phases (α : List ℕ) : Finset ℚ :=
  (admissible α).biUnion (fun q =>
    ((Finset.Icc 1 (q - 1)).filter (fun c => Nat.Coprime c q)).image
      (fun c : ℕ => (c : ℚ) / (q : ℚ)))
def phaseGraph (α : List ℕ) := fareyGraph (phases α)
def contactCount (S : Finset ℚ) : ℕ :=
  ((S.product S).filter (fun xy => xy.1 < xy.2 ∧ fareyAdj xy.1 xy.2)).card
def isolated (S : Finset ℚ) (x : ℚ) : Prop :=
  x ∈ S ∧ ∀ y ∈ S, ¬ fareyAdj x y
instance (S : Finset ℚ) (x : ℚ) : Decidable (isolated S x) := by
  unfold isolated
  infer_instance
def singletonPartition (S I : Finset ℚ) : Finset (Finset ℚ) :=
  I.image (fun x => {x}) ∪ {S \ I}

def ComponentCertificate {V : Type*} [DecidableEq V]
    (G : SimpleGraph V) (parts : Finset (Finset V)) : Prop :=
  (∀ s ∈ parts, s.Nonempty) ∧
  (∀ v : V, ∃ s ∈ parts, v ∈ s) ∧
  (∀ s ∈ parts, ∀ t ∈ parts, s ≠ t → Disjoint s t) ∧
  (∀ s ∈ parts, (G.induce (s : Set V)).Connected) ∧
  (∀ s ∈ parts, ∀ t ∈ parts, s ≠ t →
    ∀ u ∈ s, ∀ v ∈ t, ¬ G.Adj u v)

def rationalCertificate (S : Finset ℚ) (parts : Finset (Finset ℚ)) : Prop :=
  (∀ s ∈ parts, s ⊆ S) ∧
  ComponentCertificate (fareyGraph S)
    (parts.image (fun s => s.subtype (fun x => x ∈ S)))

theorem spanning_tree_connected (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (s : Finset V) (r : V)
  (parent : V → V) (depth : V → ℕ) (hr : r ∈ s)
  (hparent : ∀ v ∈ s, v ≠ r →
    parent v ∈ s ∧ G.Adj v (parent v) ∧ depth (parent v) < depth v) :
  (G.induce (s : Set V)).Connected := by
  let root : {v : V // v ∈ s} := ⟨r, hr⟩
  have go : ∀ n : ℕ, ∀ v : {v : V // v ∈ s}, depth v.val = n →
      (G.induce (s : Set V)).Reachable v root := by
    intro n
    induction n using Nat.strong_induction_on with
    | h n ih =>
      intro v hv
      by_cases he : v.val = r
      · have eq : v = root := Subtype.ext he
        subst v
        exact ⟨.nil⟩
      · obtain ⟨hp, ha, hd⟩ := hparent v.val v.property he
        obtain ⟨p⟩ := ih (depth (parent v.val)) (by omega)
          ⟨parent v.val, hp⟩ rfl
        have ha' : (G.induce (s : Set V)).Adj v ⟨parent v.val,hp⟩ := ha
        exact ⟨.cons ha' p⟩
  letI : Nonempty {v : V // v ∈ s} := ⟨root⟩
  exact SimpleGraph.Connected.mk (fun u v => (go _ u rfl).trans (go _ v rfl).symm)

private theorem part_reachable_closed (V : Type*) [DecidableEq V]
    (G : SimpleGraph V) (parts : Finset (Finset V))
    (h : ComponentCertificate G parts) (s : Finset V) (hs : s ∈ parts)
    (u v : V) (hu : u ∈ s) (hr : G.Reachable u v) : v ∈ s := by
  rcases h with ⟨_, hcover, _, _, hcross⟩
  have edge_closed : ∀ a ∈ s, ∀ b, G.Adj a b → b ∈ s := by
    intro a ha b hab
    obtain ⟨t, ht, hb⟩ := hcover b
    by_cases he : s = t
    · simpa [he] using hb
    · exact False.elim (hcross s hs t ht he a ha b hb hab)
  obtain ⟨p⟩ := hr
  induction p with
  | nil => exact hu
  | cons ha p ih => exact ih (edge_closed _ hu _ ha)

theorem certificate_component_bijection (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (parts : Finset (Finset V))
  (h : ComponentCertificate G parts) :
  ∃ e : {s : Finset V // s ∈ parts} ≃ G.ConnectedComponent,
    ∀ s : {s : Finset V // s ∈ parts}, ∀ v ∈ s.val,
      e s = G.connectedComponentMk v := by
  classical
  let pick (s : {s : Finset V // s ∈ parts}) : V := Classical.choose (h.1 s.val s.property)
  have hpick (s : {s : Finset V // s ∈ parts}) : pick s ∈ s.val :=
    Classical.choose_spec (h.1 s.val s.property)
  let f (s : {s : Finset V // s ∈ parts}) := G.connectedComponentMk (pick s)
  have hf (s : {s : Finset V // s ∈ parts}) (v : V) (hv : v ∈ s.val) :
      f s = G.connectedComponentMk v := by
    apply SimpleGraph.ConnectedComponent.sound
    exact ((h.2.2.2.1 s.val s.property) ⟨pick s, hpick s⟩ ⟨v, hv⟩).map
      (SimpleGraph.Embedding.induce (G := G) (s.val : Set V)).toHom
  have hinj : Function.Injective f := by
    intro s t he
    apply Subtype.ext
    by_contra hne
    have hr : G.Reachable (pick s) (pick t) := SimpleGraph.ConnectedComponent.exact he
    have hm := part_reachable_closed V G parts h s.val s.property
      (pick s) (pick t) (hpick s) hr
    exact Finset.disjoint_left.mp (h.2.2.1 s.val s.property t.val t.property hne) hm (hpick t)
  have hsurj : Function.Surjective f := by
    intro c
    refine SimpleGraph.ConnectedComponent.ind ?_ c
    intro v
    obtain ⟨s, hs, hv⟩ := h.2.1 v
    exact ⟨⟨s, hs⟩, hf ⟨s, hs⟩ v hv⟩
  exact ⟨Equiv.ofBijective f ⟨hinj, hsurj⟩, hf⟩

theorem certificate_component_count (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (parts : Finset (Finset V))
  (h : ComponentCertificate G parts) :
  Nat.card G.ConnectedComponent = parts.card := by
  classical
  obtain ⟨e, _⟩ := certificate_component_bijection V G parts h
  rw [← Nat.card_congr e]
  simp [Nat.card_eq_fintype_card]

theorem certificate_isolation (V : Type*) [DecidableEq V]
  (G : SimpleGraph V) (parts : Finset (Finset V))
  (h : ComponentCertificate G parts) (v : V) :
  (∀ w : V, ¬ G.Adj v w) ↔ {v} ∈ parts := by
  classical
  constructor
  · intro hi
    obtain ⟨s, hs, hv⟩ := h.2.1 v
    have heq : s = {v} := by
      apply Finset.ext
      intro w
      constructor
      · intro hw
        have hr := ((h.2.2.2.1 s hs) ⟨v,hv⟩ ⟨w,hw⟩).map
          (SimpleGraph.Embedding.induce (G := G) (s : Set V)).toHom
        obtain ⟨p⟩ := hr
        have : v = w := by
          cases p with
          | nil => rfl
          | cons ha _ => exact False.elim (hi _ ha)
        simpa [← this]
      · intro hw
        simpa using (Finset.mem_singleton.mp hw ▸ hv)
    simpa [heq] using hs
  · intro hs w hadj
    have hw := part_reachable_closed V G parts h {v} hs v w (by simp) hadj.reachable
    have he : w = v := Finset.mem_singleton.mp hw
    subst w
    exact G.loopless.irrefl v hadj

theorem contactCount_eq_edge_count (S : Finset ℚ) :
  contactCount S = Nat.card (fareyGraph S).edgeSet := by
  classical
  let P := (S.product S).filter (fun xy => xy.1 < xy.2 ∧ fareyAdj xy.1 xy.2)
  have hp (p : {p : ℚ × ℚ // p ∈ P}) :
      p.val.1 ∈ S ∧ p.val.2 ∈ S ∧ p.val.1 < p.val.2 ∧ fareyAdj p.val.1 p.val.2 := by
    have h := Finset.mem_filter.mp p.property
    have hh := Finset.mem_product.mp h.1
    exact ⟨hh.1, hh.2, h.2.1, h.2.2⟩
  let f (p : {p : ℚ × ℚ // p ∈ P}) : (fareyGraph S).edgeSet :=
    ⟨s(⟨p.val.1, (hp p).1⟩, ⟨p.val.2, (hp p).2.1⟩), (hp p).2.2.2⟩
  have hinj : Function.Injective f := by
    intro p q he
    have he' := Sym2.eq_iff.mp (congrArg Subtype.val he)
    rcases he' with he' | he'
    · apply Subtype.ext
      exact Prod.ext (congrArg Subtype.val he'.1) (congrArg Subtype.val he'.2)
    · have ha := congrArg Subtype.val he'.1
      have hb := congrArg Subtype.val he'.2
      have h1 := (hp p).2.2.1
      have h2 := (hp q).2.2.1
      simp only at ha hb
      linarith
  have hsurj : Function.Surjective f := by
    rintro ⟨e,he⟩
    revert he
    refine Sym2.inductionOn e ?_
    intro u v he
    have ha : fareyAdj u.val v.val := he
    have hne : u.val ≠ v.val := by
      intro hsame
      exact fareyAdj_irrefl v.val (hsame ▸ ha)
    rcases lt_or_gt_of_ne hne with hl | hl
    · let p : {p : ℚ × ℚ // p ∈ P} :=
        ⟨(u.val,v.val), by simp [P, u.property, v.property, hl, ha]⟩
      exact ⟨p, Subtype.ext (by rfl)⟩
    · have hav := (fareyAdj_symm _ _).mp ha
      let p : {p : ℚ × ℚ // p ∈ P} :=
        ⟨(v.val,u.val), by simp [P, u.property, v.property, hl, hav]⟩
      exact ⟨p, Subtype.ext (by exact Sym2.eq_swap)⟩
  have hc := Nat.card_congr (Equiv.ofBijective f ⟨hinj,hsurj⟩)
  calc
    contactCount S = P.card := rfl
    _ = Nat.card {p : ℚ × ℚ // p ∈ P} := by
      rw [Nat.card_eq_fintype_card]
      exact (Fintype.card_coe P).symm
    _ = Nat.card (fareyGraph S).edgeSet := hc

theorem rational_certificate_count (S : Finset ℚ) (parts : Finset (Finset ℚ))
  (h : rationalCertificate S parts) :
  Nat.card (fareyGraph S).ConnectedComponent = parts.card := by
  classical
  have hi : Set.InjOn (fun s : Finset ℚ => s.subtype (fun x => x ∈ S)) (parts : Set (Finset ℚ)) := by
    intro s hs t ht he
    apply Finset.ext
    intro x
    by_cases hx : x ∈ S
    · have hh := congrArg (fun u : Finset {x : ℚ // x ∈ S} => (⟨x,hx⟩ : {x : ℚ // x ∈ S}) ∈ u) he
      simpa using Iff.of_eq hh
    · exact iff_of_false (fun hh => hx (h.1 s hs hh)) (fun hh => hx (h.1 t ht hh))
  rw [certificate_component_count _ _ _ h.2]
  exact Finset.card_image_iff.mpr hi

theorem fixture421_vertices : phases [4,2,1] =
  {(1/5 : ℚ), 1/3, 2/5, 1/2, 3/5, 2/3, 4/5} := by decide +kernel

theorem fixture421_certificate : rationalCertificate (phases [4,2,1])
  {{(1/5 : ℚ)}, {1/3, 2/5, 1/2, 3/5, 2/3}, {4/5}} := by
  unfold rationalCertificate ComponentCertificate
  refine ⟨by decide +kernel, ?_, ?_, ?_, ?_, ?_⟩
  all_goals decide +kernel

theorem fixture421_counts : (phases [4,2,1]).card = 7 ∧
  contactCount (phases [4,2,1]) = 6 ∧
  Nat.card (phaseGraph [4,2,1]).ConnectedComponent = 3 := by
  refine ⟨by decide +kernel, by decide +kernel, ?_⟩
  have hc : ({{(1/5 : ℚ)}, {1/3, 2/5, 1/2, 3/5, 2/3}, {4/5}} : Finset (Finset ℚ)).card = 3 := by decide +kernel
  exact (rational_certificate_count _ _ fixture421_certificate).trans hc

theorem fixture421_isolated (x : ℚ) :
  isolated (phases [4,2,1]) x ↔ x ∈ ({(1/5 : ℚ), 4/5} : Finset ℚ) := by
  by_cases hx : x ∈ phases [4,2,1]
  · have hc : ∀ u : {u : ℚ // u ∈ phases [4,2,1]},
        isolated (phases [4,2,1]) u.val ↔ u.val ∈ ({(1/5 : ℚ),4/5} : Finset ℚ) := by decide +kernel
    exact hc ⟨x,hx⟩
  · have hs : ({(1/5 : ℚ),4/5} : Finset ℚ) ⊆ phases [4,2,1] := by decide +kernel
    exact iff_of_false (fun h => hx h.1) (fun h => hx (hs h))

theorem fixture92_certificate : rationalCertificate (phases [9,2])
  (singletonPartition (phases [9,2]) {(1/10 : ℚ), 1/5, 4/5, 9/10}) := by
  unfold rationalCertificate ComponentCertificate
  refine ⟨by decide +kernel, ?_, ?_, ?_, ?_, ?_⟩
  all_goals decide +kernel

theorem fixture92_counts : (phases [9,2]).card = 11 ∧
  contactCount (phases [9,2]) = 8 ∧
  Nat.card (phaseGraph [9,2]).ConnectedComponent = 5 := by
  refine ⟨by decide +kernel, by decide +kernel, ?_⟩
  have h := rational_certificate_count _ _ fixture92_certificate
  have hc : (singletonPartition (phases [9,2]) {(1/10 : ℚ), 1/5, 4/5, 9/10}).card = 5 := by decide +kernel
  exact h.trans hc

theorem fixture92_isolated (x : ℚ) :
  isolated (phases [9,2]) x ↔ x ∈ ({(1/10 : ℚ), 1/5, 4/5, 9/10} : Finset ℚ) := by
  by_cases hx : x ∈ phases [9,2]
  · have hc : ∀ u : {u : ℚ // u ∈ phases [9,2]},
        isolated (phases [9,2]) u.val ↔ u.val ∈ ({(1/10 : ℚ),1/5,4/5,9/10} : Finset ℚ) := by decide +kernel
    exact hc ⟨x,hx⟩
  · have hs : ({(1/10 : ℚ),1/5,4/5,9/10} : Finset ℚ) ⊆ phases [9,2] := by decide +kernel
    exact iff_of_false (fun h => hx h.1) (fun h => hx (hs h))

#print axioms FVLT.FareyContactV1.fareyAdj_symm
#print axioms FVLT.FareyContactV1.fareyAdj_irrefl
#print axioms FVLT.FareyContactV1.fareyGraph_adj
#print axioms FVLT.FareyContactV1.spanning_tree_connected
#print axioms FVLT.FareyContactV1.certificate_component_bijection
#print axioms FVLT.FareyContactV1.certificate_component_count
#print axioms FVLT.FareyContactV1.certificate_isolation
#print axioms FVLT.FareyContactV1.contactCount_eq_edge_count
#print axioms FVLT.FareyContactV1.rational_certificate_count
#print axioms FVLT.FareyContactV1.fixture421_vertices
#print axioms FVLT.FareyContactV1.fixture421_certificate
#print axioms FVLT.FareyContactV1.fixture421_counts
#print axioms FVLT.FareyContactV1.fixture421_isolated
#print axioms FVLT.FareyContactV1.fixture92_certificate
#print axioms FVLT.FareyContactV1.fixture92_counts
#print axioms FVLT.FareyContactV1.fixture92_isolated
end FVLT.FareyContactV1
