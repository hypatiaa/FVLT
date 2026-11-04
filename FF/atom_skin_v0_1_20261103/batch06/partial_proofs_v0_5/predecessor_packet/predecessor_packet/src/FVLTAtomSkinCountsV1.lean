import FVLTAtomSkinDataV1
import Mathlib.Data.Fintype.Powerset
import Lean.Elab.Tactic.Omega
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Tactic.Ring

open scoped BigOperators

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
          simp only [ite_eq_left hk0, ite_eq_left hk1]
          exact hstep k hkn
        · have hke : k = n := by omega
          subst k
          simp only [ite_eq_left (Nat.le_refl n), ite_eq_right (by omega : ¬n + 1 ≤ n)]
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
      simp only [ite_eq_left hk0, ite_eq_left hk1]
      have hidx : n - (k + 1) < n := by omega
      have hstep := hf (n - (k + 1)) hidx
      have heq : n - (k + 1) + 1 = n - k := by omega
      rw [heq] at hstep
      exact adjacent_symmetric ω hω _ _ hstep
    · by_cases hke : k = n
      · subst k
        have hmpos : 0 < m := by omega
        have hnext : ¬n + 1 ≤ n := by omega
        simpa [hf0, hg0, hnext] using hg 0 hmpos
      · have hk0 : ¬k ≤ n := by omega
        have hk1 : ¬k + 1 ≤ n := by omega
        simp only [ite_eq_right hk0, ite_eq_right hk1]
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
        · exact Or.inl (by simp [hd])⟩
      left_inv := by
        intro e
        apply Subtype.ext
        apply Subtype.ext
        apply Prod.ext
        · change x.erase e.val.val.2 = e.val.val.1
          rcases e.property with hx | hx
          · calc
              x.erase e.val.val.2 = (lower ω e.val).erase e.val.val.2 :=
                congrArg (fun v : Vertex ω => v.erase e.val.val.2) hx
              _ = e.val.val.1 := by simp [lower, e.val.property]
          · calc
              x.erase e.val.val.2 = (upper ω e.val).erase e.val.val.2 :=
                congrArg (fun v : Vertex ω => v.erase e.val.val.2) hx
              _ = e.val.val.1 := by simp [upper, e.val.property]
        · rfl
      right_inv := by
        intro d
        rfl }
  exact ⟨φ, fun _ => rfl⟩

private theorem card_subsets (ω : ℕ) (s : Vertex ω) :
    Fintype.card {v : Vertex ω // v ⊆ s} = 2 ^ s.card := by
  classical
  calc
    Fintype.card {v : Vertex ω // v ⊆ s} = s.powerset.card := by
      apply Fintype.card_of_subtype s.powerset
      intro v
      exact Finset.mem_powerset
    _ = 2 ^ s.card := Finset.card_powerset s

private theorem card_avoid_one (ω : ℕ) (d : Fin ω) :
    Fintype.card {v : Vertex ω // d ∉ v} = 2 ^ (ω - 1) := by
  classical
  let s : Vertex ω := Finset.univ.erase d
  let e : {v : Vertex ω // d ∉ v} ≃ {v : Vertex ω // v ⊆ s} :=
    { toFun := fun v => ⟨v.val, by simpa [s, Finset.subset_erase] using v.property⟩
      invFun := fun v => ⟨v.val, by simpa [s, Finset.subset_erase] using v.property⟩
      left_inv := by intro v; rfl
      right_inv := by intro v; rfl }
  calc
    Fintype.card {v : Vertex ω // d ∉ v} =
        Fintype.card {v : Vertex ω // v ⊆ s} := Fintype.card_congr e
    _ = 2 ^ s.card := card_subsets ω s
    _ = 2 ^ (ω - 1) := by simp [s]

theorem edge_count (ω : ℕ) (hω : 3 ≤ ω) :
    Fintype.card (Edge ω) = ω * 2 ^ (ω - 1) := by
  classical
  let e : Edge ω ≃ Σ d : Fin ω, {v : Vertex ω // d ∉ v} :=
    { toFun := fun t => ⟨t.val.2, ⟨t.val.1, t.property⟩⟩
      invFun := fun t => ⟨(t.2.val, t.1), t.2.property⟩
      left_inv := by rintro ⟨⟨v, d⟩, hv⟩; rfl
      right_inv := by rintro ⟨d, v, hv⟩; rfl }
  calc
    Fintype.card (Edge ω) =
        Fintype.card (Σ d : Fin ω, {v : Vertex ω // d ∉ v}) := Fintype.card_congr e
    _ = ∑ d : Fin ω, Fintype.card {v : Vertex ω // d ∉ v} := Fintype.card_sigma
    _ = ∑ _d : Fin ω, 2 ^ (ω - 1) := by
      apply Finset.sum_congr rfl
      intro d hd
      exact card_avoid_one ω d
    _ = ω * 2 ^ (ω - 1) := by simp

private theorem next_value (ω : ℕ) (hω : 3 ≤ ω) (i : Fin ω) :
    (next ω hω i).val = (i.val + 1) % ω := by
  change (((i.val : ℤ) + 1) % (ω : ℤ)).toNat % ω = (i.val + 1) % ω
  rw [Int.toNat_emod (by omega : 0 ≤ (i.val : ℤ) + 1) (by omega : 0 ≤ (ω : ℤ))]
  have hx : ((i.val : ℤ) + 1).toNat = i.val + 1 := by omega
  rw [hx]
  simp only [Int.toNat_natCast, Nat.mod_mod]

private theorem next_ne_self (ω : ℕ) (hω : 3 ≤ ω) (i : Fin ω) :
    next ω hω i ≠ i := by
  intro h
  have hv := congrArg Fin.val h
  rw [next_value ω hω i] at hv
  have hi := i.isLt
  by_cases hs : i.val + 1 < ω
  · rw [Nat.mod_eq_of_lt hs] at hv
    omega
  · have he : i.val + 1 = ω := by omega
    rw [he, Nat.mod_self] at hv
    omega

private theorem card_avoid_two (ω : ℕ) (i j : Fin ω) (hji : j ≠ i) :
    Fintype.card {v : Vertex ω // i ∉ v ∧ j ∉ v} = 2 ^ (ω - 2) := by
  classical
  let s : Vertex ω := (Finset.univ.erase i).erase j
  let e : {v : Vertex ω // i ∉ v ∧ j ∉ v} ≃ {v : Vertex ω // v ⊆ s} :=
    { toFun := fun v => ⟨v.val, by simpa [s, Finset.subset_erase] using v.property⟩
      invFun := fun v => ⟨v.val, by simpa [s, Finset.subset_erase] using v.property⟩
      left_inv := by intro v; rfl
      right_inv := by intro v; rfl }
  calc
    Fintype.card {v : Vertex ω // i ∉ v ∧ j ∉ v} =
        Fintype.card {v : Vertex ω // v ⊆ s} := Fintype.card_congr e
    _ = 2 ^ s.card := card_subsets ω s
    _ = 2 ^ (ω - 2) := by
      have hj : j ∈ (Finset.univ : Vertex ω).erase i := by simp [hji]
      dsimp [s]
      rw [Finset.card_erase_of_mem hj, Finset.card_erase_of_mem (Finset.mem_univ i)]
      simp [Nat.sub_sub]

theorem square_count (ω : ℕ) (hω : 3 ≤ ω) :
    Fintype.card (Square ω hω) = ω * 2 ^ (ω - 2) := by
  classical
  let e : Square ω hω ≃
      Σ i : Fin ω, {v : Vertex ω // i ∉ v ∧ next ω hω i ∉ v} :=
    { toFun := fun t => ⟨t.val.2, ⟨t.val.1, t.property⟩⟩
      invFun := fun t => ⟨(t.2.val, t.1), t.2.property⟩
      left_inv := by rintro ⟨⟨v, i⟩, hv⟩; rfl
      right_inv := by rintro ⟨i, v, hv⟩; rfl }
  calc
    Fintype.card (Square ω hω) =
        Fintype.card (Σ i : Fin ω, {v : Vertex ω // i ∉ v ∧ next ω hω i ∉ v}) :=
      Fintype.card_congr e
    _ = ∑ i : Fin ω, Fintype.card {v : Vertex ω // i ∉ v ∧ next ω hω i ∉ v} :=
      Fintype.card_sigma
    _ = ∑ _i : Fin ω, 2 ^ (ω - 2) := by
      apply Finset.sum_congr rfl
      intro i hi
      exact card_avoid_two ω i (next ω hω i) (next_ne_self ω hω i)
    _ = ω * 2 ^ (ω - 2) := by simp

theorem chi_formula (ω : ℕ) (hω : 3 ≤ ω) :
    chi ω hω = (2 : ℤ) ^ (ω - 2) * (4 - (ω : ℤ)) := by
  unfold chi
  rw [vertex_count ω hω, edge_count ω hω, square_count ω hω]
  simp only [Nat.cast_mul, Nat.cast_pow, Nat.cast_ofNat]
  have hp0 : (2 : ℤ) ^ ω = 4 * (2 : ℤ) ^ (ω - 2) := by
    conv_lhs => rw [show ω = (ω - 2) + 2 by omega]
    rw [pow_add]
    ring
  have hp1 : (2 : ℤ) ^ (ω - 1) = 2 * (2 : ℤ) ^ (ω - 2) := by
    rw [show ω - 1 = (ω - 2) + 1 by omega, pow_succ]
    ring
  rw [hp0, hp1]
  ring

theorem chi_even (ω : ℕ) (hω : 3 ≤ ω) : Even (chi ω hω) := by
  refine ⟨(2 : ℤ) ^ (ω - 3) * (4 - (ω : ℤ)), ?_⟩
  rw [chi_formula ω hω, show ω - 2 = (ω - 3) + 1 by omega, pow_succ]
  ring

theorem genus_formula (ω : ℕ) (hω : 3 ≤ ω) :
    genus ω hω = 1 + ((ω : ℤ) - 4) * (2 : ℤ) ^ (ω - 3) := by
  unfold genus
  rw [chi_formula ω hω]
  have hp : (2 : ℤ) ^ (ω - 2) = 2 * (2 : ℤ) ^ (ω - 3) := by
    rw [show ω - 2 = (ω - 3) + 1 by omega, pow_succ]
    ring
  rw [hp]
  have hdiv : ((2 : ℤ) * (2 : ℤ) ^ (ω - 3) * (4 - (ω : ℤ))) / 2 =
      (2 : ℤ) ^ (ω - 3) * (4 - (ω : ℤ)) := by
    rw [mul_assoc]
    exact Int.mul_ediv_cancel_left _ (by decide : (2 : ℤ) ≠ 0)
  rw [hdiv]
  ring

end FVLT.AtomSkinV1




