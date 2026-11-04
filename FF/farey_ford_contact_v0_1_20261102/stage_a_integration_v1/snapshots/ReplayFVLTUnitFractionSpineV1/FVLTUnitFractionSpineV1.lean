import FVLTFordGeometryCompletionV1
import Mathlib.Tactic

/-! FF-1 R3: the classical unit-fraction spine and its finite induced path graph.
Framework assembled by Robin Miller; classical Farey/Ford components, Ford (1938),
Apostol ch. 5; structural reference Paulson, Isabelle AFP (2025).
-/
namespace FVLT.FareyContactV1
noncomputable section

def vertexSet (V : Finset ℕ) : Finset ℚ := V.image unitFrac
def integerPath : SimpleGraph ℕ where
  Adj a b := |(a : ℤ) - (b : ℤ)| = 1
  symm := ⟨fun a b h => by rwa [abs_sub_comm]⟩
  loopless := ⟨fun a h => by simp at h⟩

private theorem unitFrac_coordinates (a : ℕ) (ha : 0 < a) :
    (unitFrac a).num = 1 ∧ (unitFrac a).den = a := by
  simpa [unitFrac,rawValue] using rawValue_canonical 1 a ha (by simp)

theorem unitFrac_injective_positive (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
  unitFrac a = unitFrac b ↔ a = b := by
  constructor
  · intro h
    have hd := congrArg Rat.den h
    simpa only [(unitFrac_coordinates a ha).2,(unitFrac_coordinates b hb).2] using hd
  · rintro rfl
    rfl

theorem integerPath_adj (a b : ℕ) :
  integerPath.Adj a b ↔ |(a : ℤ) - (b : ℤ)| = 1 := Iff.rfl

theorem unitFrac_adj (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
  fareyAdj (unitFrac a) (unitFrac b) ↔ |(a : ℤ) - (b : ℤ)| = 1 := by
  simp [fareyAdj,det,(unitFrac_coordinates a ha).1,(unitFrac_coordinates a ha).2,
    (unitFrac_coordinates b hb).1,(unitFrac_coordinates b hb).2,abs_sub_comm]

theorem unitFrac_graph_iso (V : Finset ℕ) (hV : ∀ a ∈ V, 0 < a) :
  Nonempty ((integerPath.induce (V : Set ℕ)) ≃g fareyGraph (vertexSet V)) := by
  classical
  let f : {a : ℕ // a ∈ V} → {x : ℚ // x ∈ vertexSet V} := fun a =>
    ⟨unitFrac a.val,Finset.mem_image.mpr ⟨a.val,a.property,rfl⟩⟩
  have hinj : Function.Injective f := by
    intro a b hab
    apply Subtype.ext
    exact (unitFrac_injective_positive a.val b.val (hV _ a.property) (hV _ b.property)).mp
      (congrArg Subtype.val hab)
  have hsurj : Function.Surjective f := by
    intro x
    obtain ⟨a,ha,he⟩ := Finset.mem_image.mp x.property
    exact ⟨⟨a,ha⟩,Subtype.ext he⟩
  let e := Equiv.ofBijective f ⟨hinj,hsurj⟩
  refine ⟨{toEquiv := e, map_rel_iff' := ?_}⟩
  intro a b
  change fareyAdj (unitFrac a.val) (unitFrac b.val) ↔ |(a.val:ℤ)-(b.val:ℤ)| = 1
  exact unitFrac_adj a.val b.val (hV _ a.property) (hV _ b.property)

private theorem path_cut (V : Finset ℕ) (k : ℕ) (hk : k ∉ V)
    (u v : {a : ℕ // a ∈ V})
    (p : (integerPath.induce (V : Set ℕ)).Walk u v) :
    u.val < k → v.val < k := by
  induction p with
  | nil => exact fun h => h
  | @cons a b c hab p ih =>
    intro ha
    apply ih
    have hb : b.val ≠ k := by
      intro he
      apply hk
      simpa only [he] using b.property
    change |(a.val:ℤ)-(b.val:ℤ)| = 1 at hab
    have hd := (abs_le.mp hab.le).1
    omega

private theorem induced_path_connected (V : Finset ℕ) (hne : V.Nonempty)
    (hV : ∀ a ∈ V, 0 < a) :
    (integerPath.induce (V : Set ℕ)).Connected ↔
      ∃ m M : ℕ, 1 ≤ m ∧ m ≤ M ∧ V = Finset.Icc m M := by
  classical
  constructor
  · intro hc
    let m := V.min' hne
    let M := V.max' hne
    have hm : m ∈ V := Finset.min'_mem V hne
    have hM : M ∈ V := Finset.max'_mem V hne
    have hmM : m ≤ M := Finset.min'_le V M hM
    refine ⟨m,M,hV _ hm,hmM,?_⟩
    ext k
    constructor
    · intro hk
      exact Finset.mem_Icc.mpr ⟨Finset.min'_le V k hk,Finset.le_max' V k hk⟩
    · intro hk
      obtain ⟨hmk,hkM⟩ := Finset.mem_Icc.mp hk
      by_contra hnot
      have hmk' : m < k := by
        have hne' : m ≠ k := by intro he; apply hnot; simpa only [← he] using hm
        omega
      obtain ⟨p⟩ := hc ⟨m,hm⟩ ⟨M,hM⟩
      have hbad := path_cut V k hnot ⟨m,hm⟩ ⟨M,hM⟩ p hmk'
      change M < k at hbad
      omega
  · rintro ⟨m,M,hm,hmM,rfl⟩
    let S := Finset.Icc m M
    have hmin : m ∈ S := Finset.mem_Icc.mpr ⟨le_rfl,hmM⟩
    have walk : ∀ (k : ℕ) (hk : m+k ≤ M),
        (integerPath.induce (S : Set ℕ)).Reachable
          ⟨m,hmin⟩ ⟨m+k,Finset.mem_Icc.mpr ⟨by omega,hk⟩⟩ := by
      intro k
      induction k with
      | zero =>
        intro hk
        exact SimpleGraph.Reachable.refl _
      | succ k ih =>
        intro hk
        have hk' : m+k ≤ M := by omega
        have hr := ih hk'
        apply hr.trans
        apply SimpleGraph.Adj.reachable
        change |((m+k:ℕ):ℤ)-((m+(k+1):ℕ):ℤ)| = 1
        simp
    apply (SimpleGraph.connected_iff_exists_forall_reachable _).mpr
    refine ⟨⟨m,hmin⟩,?_⟩
    intro v
    have hv := Finset.mem_Icc.mp v.property
    have hreach := walk (v.val-m) (by omega)
    have he : m+(v.val-m) = v.val := by omega
    simpa only [he] using hreach

theorem unitFrac_graph_connected (V : Finset ℕ) (hne : V.Nonempty)
  (hV : ∀ a ∈ V, 0 < a) :
  (fareyGraph (vertexSet V)).Connected ↔
    ∃ m M : ℕ, 1 ≤ m ∧ m ≤ M ∧ V = Finset.Icc m M := by
  obtain ⟨e⟩ := unitFrac_graph_iso V hV
  exact e.connected_iff.symm.trans (induced_path_connected V hne hV)

theorem empty_graph_convention :
  (fareyGraph ∅).Preconnected ∧ ¬ (fareyGraph ∅).Connected := by
  constructor
  · intro a
    exact False.elim (Finset.notMem_empty a.val a.property)
  · intro h
    obtain ⟨a⟩ := h.nonempty
    exact Finset.notMem_empty a.val a.property

theorem gap_det (a k : ℕ) (ha : 0 < a) (hk : 0 < k) :
  |det (unitFrac a) (unitFrac (a + k))| = (k : ℤ) := by
  have hb := unitFrac_coordinates (a+k) (by omega)
  have ha' := unitFrac_coordinates a ha
  simp [det,ha'.1,ha'.2,hb.1,hb.2]

private theorem gap_mediant_value (a k : ℕ) (ha : 0 < a) (hk : 0 < k) :
    mediant (unitFrac a) (unitFrac (a+k)) = (2:ℚ)/(2*(a:ℚ)+(k:ℚ)) := by
  have hb := unitFrac_coordinates (a+k) (by omega)
  have ha' := unitFrac_coordinates a ha
  unfold mediant
  rw [ha'.1,ha'.2,hb.1,hb.2]
  unfold rawValue
  push_cast
  congr 1
  ring

theorem minimal_gap_mediant (a : ℕ) (ha : 0 < a) :
  mediant (unitFrac a) (unitFrac (a + 2)) = unitFrac (a + 1) := by
  rw [gap_mediant_value a 2 ha (by omega)]
  unfold unitFrac
  have hp : (0:ℚ) < a := by exact_mod_cast ha
  push_cast
  field_simp [show (a:ℚ)+1 ≠ 0 by positivity]

theorem gap_mediant_unit_iff (a k : ℕ) (ha : 0 < a) (hk : 2 < k) :
  (∃ b : ℕ, 0 < b ∧
    mediant (unitFrac a) (unitFrac (a + k)) = unitFrac b) ↔ Even k := by
  have hp : (0:ℚ) < a := by exact_mod_cast ha
  have hkQ : (0:ℚ) < k := by exact_mod_cast (show 0 < k by omega)
  have hden : 2*(a:ℚ)+(k:ℚ) ≠ 0 := by positivity
  constructor
  · rintro ⟨b,hb,h⟩
    rw [gap_mediant_value a k ha (by omega),unitFrac] at h
    have hbQ : (b:ℚ) ≠ 0 := by exact_mod_cast (ne_of_gt hb)
    have he := (div_eq_div_iff hden hbQ).mp h
    have hi : 2*b = 2*a+k := by exact_mod_cast (by simpa using he : (2:ℚ)*b = 2*a+k)
    exact ⟨b-a,by omega⟩
  · rintro ⟨t,ht⟩
    refine ⟨a+t,by omega,?_⟩
    rw [gap_mediant_value a k ha (by omega),unitFrac]
    have htQ : (k:ℚ) = (t:ℚ)+(t:ℚ) := by exact_mod_cast ht
    push_cast
    rw [htQ]
    field_simp [show (a:ℚ)+(t:ℚ) ≠ 0 by positivity]
    ring

#print axioms FVLT.FareyContactV1.unitFrac_injective_positive
#print axioms FVLT.FareyContactV1.integerPath_adj
#print axioms FVLT.FareyContactV1.unitFrac_adj
#print axioms FVLT.FareyContactV1.unitFrac_graph_iso
#print axioms FVLT.FareyContactV1.unitFrac_graph_connected
#print axioms FVLT.FareyContactV1.empty_graph_convention
#print axioms FVLT.FareyContactV1.gap_det
#print axioms FVLT.FareyContactV1.minimal_gap_mediant
#print axioms FVLT.FareyContactV1.gap_mediant_unit_iff
#print axioms unitFrac_coordinates
#print axioms path_cut
#print axioms induced_path_connected
#print axioms gap_mediant_value
end
end FVLT.FareyContactV1

namespace FVLT.FordGeometryV1
open FVLT.FareyContactV1
theorem unitFrac_tangent (a b : ℕ) (ha : 0 < a) (hb : 0 < b) :
  tangent (unitFrac a) (unitFrac b) ↔ |(a : ℤ) - (b : ℤ)| = 1 := by
  by_cases hab : a = b
  · subst b
    simp [tangent]
  · have hne : unitFrac a ≠ unitFrac b := by
      exact fun he => hab ((unitFrac_injective_positive a b ha hb).mp he)
    exact (ford_tangent_iff _ _ hne).trans (unitFrac_adj a b ha hb)
#print axioms FVLT.FordGeometryV1.unitFrac_tangent
end FVLT.FordGeometryV1
