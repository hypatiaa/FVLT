import FVLTAtomSkinDataV1
import Mathlib.Data.Fintype.Powerset
import Lean.Elab.Tactic.Omega

namespace FVLT.AtomSkinV1

theorem vertex_count (ω : ℕ) (hω : 3 ≤ ω) :
    Fintype.card (Vertex ω) = 2 ^ ω := by
  simpa only [Fintype.card_fin] using (Fintype.card_finset (α := Fin ω))

theorem cube_genus_zero (h3 : 3 ≤ (3 : ℕ)) : genus 3 h3 = 0 := by
  decide +revert

theorem cube_edge_iff (ω : ℕ) (hω : 3 ≤ ω) (x y : Vertex ω) :
    cubeAdjacent ω x y ↔ ∃ e : Edge ω,
      (x = lower ω e ∧ y = upper ω e) ∨
      (y = lower ω e ∧ x = upper ω e) := by
  constructor
  · rintro ⟨d, rfl⟩
    refine ⟨mkEdge ω x d, ?_⟩
    by_cases hd : d ∈ x
    · right
      simp [toggle, mkEdge, lower, upper, hd]
    · left
      simp [toggle, mkEdge, lower, upper, hd]
  · rintro ⟨e, ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩⟩
    · refine ⟨e.val.2, ?_⟩
      simp [toggle, lower, upper, e.property]
    · refine ⟨e.val.2, ?_⟩
      simp [toggle, lower, upper, e.property]

private theorem adjacent_symmetric
    (ω : ℕ) (hω : 3 ≤ ω) (x y : Vertex ω) (h : cubeAdjacent ω x y) :
    cubeAdjacent ω y x := by
  rcases (cube_edge_iff ω hω x y).mp h with ⟨e, he | he⟩
  · exact (cube_edge_iff ω hω y x).mpr ⟨e, Or.inr he⟩
  · exact (cube_edge_iff ω hω y x).mpr ⟨e, Or.inl he⟩

private theorem path_from_empty (ω : ℕ) (v : Vertex ω) :
    ∃ n : ℕ, ∃ f : ℕ → Vertex ω,
      f 0 = ∅ ∧ f n = v ∧
      ∀ k : ℕ, k < n → cubeAdjacent ω (f k) (f (k + 1)) := by
  classical
  induction v using Finset.induction_on with
  | empty =>
      refine ⟨0, (fun _ => ∅), rfl, rfl, ?_⟩
      intro k hk
      omega
  | @insert a v ha ih =>
      rcases ih with ⟨n, f, hf0, hfn, hstep⟩
      refine ⟨n + 1, (fun k => if k ≤ n then f k else insert a v), ?_, ?_, ?_⟩
      · simp [hf0]
      · simp
      · intro k hk
        by_cases hkn : k < n
        · have hk0 : k ≤ n := by omega
          have hk1 : k + 1 ≤ n := by omega
          simp only [if_pos hk0, if_pos hk1]
          exact hstep k hkn
        · have hke : k = n := by omega
          subst k
          simp only [if_pos (Nat.le_refl n), if_neg (by omega : ¬n + 1 ≤ n)]
          rw [hfn]
          refine ⟨a, ?_⟩
          simp [toggle, ha]

theorem cube_connected (ω : ℕ) (hω : 3 ≤ ω) (x y : Vertex ω) :
    ∃ n : ℕ, ∃ v : ℕ → Vertex ω,
      v 0 = x ∧ v n = y ∧
      ∀ k : ℕ, k < n → cubeAdjacent ω (v k) (v (k + 1)) := by
  rcases path_from_empty ω x with ⟨n, f, hf0, hfn, hf⟩
  rcases path_from_empty ω y with ⟨m, g, hg0, hgm, hg⟩
  refine ⟨n + m, (fun k => if k ≤ n then f (n - k) else g (k - n)), ?_, ?_, ?_⟩
  · simp [hfn]
  · by_cases hm : m = 0
    · have hy : y = ∅ := by simpa [hm, hg0] using hgm.symm
      simp [hm, hf0, hy]
    · have hgt : ¬n + m ≤ n := by omega
      simp [hgt, hgm]
  · intro k hk
    by_cases hkn : k < n
    · have hk0 : k ≤ n := by omega
      have hk1 : k + 1 ≤ n := by omega
      simp only [if_pos hk0, if_pos hk1]
      have hidx : n - (k + 1) < n := by omega
      have hstep := hf (n - (k + 1)) hidx
      have heq : n - (k + 1) + 1 = n - k := by omega
      rw [heq] at hstep
      exact adjacent_symmetric ω hω _ _ hstep
    · by_cases hke : k = n
      · subst k
        have hmpos : 0 < m := by omega
        simpa [hf0, hg0] using hg 0 hmpos
      · have hk0 : ¬k ≤ n := by omega
        have hk1 : ¬k + 1 ≤ n := by omega
        simp only [if_neg hk0, if_neg hk1]
        have hkm : k - n < m := by omega
        have heq : k + 1 - n = (k - n) + 1 := by omega
        rw [heq]
        exact hg (k - n) hkm

theorem incident_direction_equiv (ω : ℕ) (hω : 3 ≤ ω) (x : Vertex ω) :
    ∃ φ : {e : Edge ω // edgeIncident ω e x} ≃ Fin ω,
      ∀ e, φ e = e.val.val.2 := by
  let φ : {e : Edge ω // edgeIncident ω e x} ≃ Fin ω :=
    { toFun := fun e => e.val.val.2
      invFun := fun d => ⟨mkEdge ω x d, by
        change x = x.erase d ∨ x = insert d (x.erase d)
        by_cases hd : d ∈ x
        · exact Or.inr (Finset.insert_erase hd).symm
        · exact Or.inl (Finset.erase_eq_of_not_mem hd).symm⟩
      left_inv := by
        intro e
        apply Subtype.ext
        apply Subtype.ext
        apply Prod.ext
        · change x.erase e.val.val.2 = e.val.val.1
          rcases e.property with hx | hx
          · rw [hx]
            simpa [lower] using Finset.erase_eq_of_not_mem e.val.property
          · rw [hx]
            simp [upper, e.val.property]
        · rfl
      right_inv := by
        intro d
        rfl }
  exact ⟨φ, fun _ => rfl⟩

end FVLT.AtomSkinV1


