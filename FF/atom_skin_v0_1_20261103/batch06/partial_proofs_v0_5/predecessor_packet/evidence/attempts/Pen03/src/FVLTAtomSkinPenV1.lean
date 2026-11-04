import FVLTAtomSkinDataV1
import Mathlib.Logic.Function.Iterate
import Mathlib.Tactic.Ring
import Lean.Elab.Tactic.Omega

namespace FVLT.AtomSkinV1

private theorem mem_toggle (ω : ℕ) (w : Vertex ω) (d a : Fin ω) :
    a ∈ toggle ω w d ↔ (a = d ∧ a ∉ w) ∨ (a ≠ d ∧ a ∈ w) := by
  by_cases ha : a = d <;> by_cases hd : d ∈ w <;> simp_all [toggle]

private theorem toggle_twice (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    toggle ω (toggle ω w d) d = w := by
  apply Finset.ext
  intro a
  by_cases ha : a = d <;> by_cases hw : a ∈ w <;> simp_all [mem_toggle]

private theorem toggle_commute (ω : ℕ) (w : Vertex ω) (d b : Fin ω) :
    toggle ω (toggle ω w d) b = toggle ω (toggle ω w b) d := by
  apply Finset.ext
  intro a
  by_cases hd : a = d <;> by_cases hb : a = b <;>
    by_cases hw : a ∈ w <;> simp_all [mem_toggle]

private theorem toggle_pair_ne (ω : ℕ) (w : Vertex ω) (d b : Fin ω)
    (hdb : d ≠ b) : toggle ω (toggle ω w d) b ≠ w := by
  intro h
  have hm := Finset.ext_iff.mp h b
  clear h
  have hbd : b ≠ d := Ne.symm hdb
  by_cases hb : b ∈ w <;> simp [mem_toggle, hbd, hb] at hm

private theorem epsilon_values (ω : ℕ) (w : Vertex ω) :
    epsilon ω w = 1 ∨ epsilon ω w = -1 := by
  have h : ∀ n : ℕ, (-1 : ℤ) ^ n = 1 ∨ (-1 : ℤ) ^ n = -1 := by
    intro n
    induction n with
    | zero => simp
    | succ n ih => rcases ih with h | h <;> simp [pow_succ, h]
  exact h w.card

private theorem epsilon_insert (ω : ℕ) (w : Vertex ω) (d : Fin ω) (hd : d ∉ w) :
    epsilon ω (insert d w) = -epsilon ω w := by
  simp [epsilon, hd, pow_succ]

private theorem epsilon_toggle (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    epsilon ω (toggle ω w d) = -epsilon ω w := by
  by_cases hd : d ∈ w
  · have h := epsilon_insert ω (w.erase d) d (by simp)
    simp only [Finset.insert_erase hd] at h
    simp only [toggle, ite_eq_left hd]
    omega
  · simpa only [toggle, ite_eq_right hd] using epsilon_insert ω w d hd

private theorem cyclic_value (ω : ℕ) (hω : 3 ≤ ω) (z : ℤ) :
    ((cyclicDir ω hω z).val : ℤ) = z % (ω : ℤ) := by
  have hr0 := Int.emod_nonneg z (by omega : (ω : ℤ) ≠ 0)
  have hrlt := Int.emod_lt_of_pos z (by omega : 0 < (ω : ℤ))
  have hnat : (z % (ω : ℤ)).toNat < ω := by omega
  change (((z % (ω : ℤ)).toNat % ω : ℕ) : ℤ) = z % (ω : ℤ)
  rw [Nat.mod_eq_of_lt hnat]
  omega

private theorem cyclic_shift_cancel (ω : ℕ) (hω : 3 ≤ ω) (b : Fin ω) (δ : ℤ) :
    cyclicDir ω hω (((cyclicDir ω hω ((b.val : ℤ) + δ)).val : ℤ) - δ) = b := by
  have hi := b.isLt
  have hm : ((((cyclicDir ω hω ((b.val : ℤ) + δ)).val : ℤ) - δ) % (ω : ℤ)) =
      (b.val : ℤ) := by
    rw [cyclic_value ω hω ((b.val : ℤ) + δ), Int.emod_sub_emod, add_sub_cancel_right]
    exact Int.emod_eq_of_lt (by omega) (by omega)
  have hv := (cyclic_value ω hω
    (((cyclicDir ω hω ((b.val : ℤ) + δ)).val : ℤ) - δ)).trans hm
  apply Fin.ext
  omega

private theorem next_ne (ω : ℕ) (hω : 3 ≤ ω) (b : Fin ω) : next ω hω b ≠ b := by
  intro h
  have hi := b.isLt
  have hv : ((next ω hω b).val : ℤ) = ((b.val : ℤ) + 1) % (ω : ℤ) :=
    cyclic_value ω hω ((b.val : ℤ) + 1)
  rw [h] at hv
  by_cases hs : (b.val : ℤ) + 1 < (ω : ℤ)
  · rw [Int.emod_eq_of_lt (by omega) hs] at hv
    omega
  · have he : (b.val : ℤ) + 1 = (ω : ℤ) := by omega
    rw [he] at hv
    simp only [Int.emod_self] at hv
    omega

private theorem prev_ne (ω : ℕ) (hω : 3 ≤ ω) (b : Fin ω) : prev ω hω b ≠ b := by
  have hinv : next ω hω (prev ω hω b) = b := by
    simpa [next, prev, sub_eq_add_neg] using cyclic_shift_cancel ω hω b (-1)
  intro h
  rw [h] at hinv
  exact next_ne ω hω b hinv

theorem pen_adjacent_seat
    (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    ((step ω hω s st).2 = next ω hω st.2 ∨
      (step ω hω s st).2 = prev ω hω st.2) ∧
      (step ω hω s st).2 ≠ st.2 := by
  have hd : (step ω hω s st).2 = next ω hω st.2 ∨
      (step ω hω s st).2 = prev ω hω st.2 := by
    cases s <;> rcases epsilon_values ω st.1 with he | he <;>
      simp [step, signValue, he, next, prev]
  refine ⟨hd, ?_⟩
  rcases hd with hn | hp
  · rw [hn]
    exact next_ne ω hω st.2
  · rw [hp]
    exact prev_ne ω hω st.2

private theorem epsilon_step (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    epsilon ω (step ω hω s st).1 = -epsilon ω st.1 := by
  change epsilon ω (toggle ω st.1 (step ω hω s st).2) = -epsilon ω st.1
  exact epsilon_toggle ω st.1 (step ω hω s st).2

private theorem step_twice (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    step ω hω s (step ω hω s st) = (toggle ω (step ω hω s st).1 st.2, st.2) := by
  let δ : ℤ := -(signValue s * epsilon ω st.1)
  have hd : (step ω hω s st).2 = cyclicDir ω hω ((st.2.val : ℤ) + δ) := by
    change cyclicDir ω hω ((st.2.val : ℤ) - signValue s * epsilon ω st.1) = _
    congr 1
  have hdir : (step ω hω s (step ω hω s st)).2 = st.2 := by
    change cyclicDir ω hω (((step ω hω s st).2.val : ℤ) -
      signValue s * epsilon ω (step ω hω s st).1) = st.2
    rw [epsilon_step ω hω s st]
    have hin : ((step ω hω s st).2.val : ℤ) - signValue s * (-epsilon ω st.1) =
        ((cyclicDir ω hω ((st.2.val : ℤ) + δ)).val : ℤ) - δ := by
      rw [hd]
      dsimp [δ]
      ring
    rw [hin]
    exact cyclic_shift_cancel ω hω st.2 δ
  apply Prod.ext
  · change toggle ω (step ω hω s st).1 (step ω hω s (step ω hω s st)).2 = _
    rw [hdir]
  · exact hdir

private theorem raw_return_four (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    step ω hω s (step ω hω s (step ω hω s (step ω hω s st))) = st := by
  rcases st with ⟨w, b⟩
  let d : Fin ω := (step ω hω s (w, b)).2
  let w2 : Vertex ω := toggle ω (toggle ω w d) b
  have h1 : step ω hω s (w, b) = (toggle ω w d, d) := rfl
  have h2 : step ω hω s (step ω hω s (w, b)) = (w2, b) := by
    simpa only [h1, Prod.fst, Prod.snd] using step_twice ω hω s (w, b)
  have he2 : epsilon ω w2 = epsilon ω w := by
    dsimp only [w2]
    rw [epsilon_toggle, epsilon_toggle, neg_neg]
  have h3 : step ω hω s (w2, b) = (toggle ω w2 d, d) := by
    change (toggle ω w2 (cyclicDir ω hω ((b.val : ℤ) - signValue s * epsilon ω w2)),
      cyclicDir ω hω ((b.val : ℤ) - signValue s * epsilon ω w2)) = _
    simp only [he2]
    rfl
  have h4 : step ω hω s (step ω hω s (w2, b)) =
      (toggle ω (toggle ω w2 d) b, b) := by
    simpa only [h3, Prod.fst, Prod.snd] using step_twice ω hω s (w2, b)
  have hc : toggle ω (toggle ω w2 d) b = w := by
    dsimp only [w2]
    rw [toggle_commute ω (toggle ω w d) b d, toggle_twice, toggle_twice]
  rw [hc] at h4
  rw [h2]
  exact h4

theorem pen_return_four
    (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    (step ω hω s)^[4] st = st := by
  simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply] using
    raw_return_four ω hω s st

private theorem step_ne (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    step ω hω s st ≠ st := by
  intro h
  exact (pen_adjacent_seat ω hω s st).2 (congrArg Prod.snd h)

theorem pen_no_earlier_return
    (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω)
    (k : ℕ) (hk0 : 0 < k) (hk4 : k < 4) :
    (step ω hω s)^[k] st ≠ st := by
  have hk : k = 1 ∨ k = 2 ∨ k = 3 := by omega
  rcases hk with rfl | rfl | rfl
  · simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply] using
      step_ne ω hω s st
  · intro h
    have hr : step ω hω s (step ω hω s st) = st := by
      simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply] using h
    have hv := congrArg Prod.fst ((step_twice ω hω s st).symm.trans hr)
    exact (toggle_pair_ne ω st.1 (step ω hω s st).2 st.2
      (pen_adjacent_seat ω hω s st).2) hv
  · intro h
    have hr : step ω hω s (step ω hω s (step ω hω s st)) = st := by
      simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply] using h
    have hnext := congrArg (step ω hω s) hr
    exact step_ne ω hω s st ((raw_return_four ω hω s st).symm.trans hnext).symm

end FVLT.AtomSkinV1
