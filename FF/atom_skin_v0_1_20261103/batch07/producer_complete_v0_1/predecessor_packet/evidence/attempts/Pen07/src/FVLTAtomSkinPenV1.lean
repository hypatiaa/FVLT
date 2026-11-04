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

private def boxOrbit (ω : ℕ) (w : Vertex ω) (i j : Fin ω) : Finset (Vertex ω) :=
  {w, toggle ω w i, toggle ω w j, toggle ω (toggle ω w i) j}

private theorem boxOrbit_swap (ω : ℕ) (w : Vertex ω) (i j : Fin ω) :
    boxOrbit ω w i j = boxOrbit ω w j i := by
  ext u
  simp [boxOrbit, toggle_commute ω w i j, or_comm, or_left_comm, or_assoc]

private theorem boxOrbit_flip_i (ω : ℕ) (w : Vertex ω) (i j : Fin ω) :
    boxOrbit ω (toggle ω w i) i j = boxOrbit ω w i j := by
  ext u
  simp [boxOrbit, toggle_twice, or_comm, or_left_comm, or_assoc]

private theorem boxOrbit_flip_j (ω : ℕ) (w : Vertex ω) (i j : Fin ω) :
    boxOrbit ω (toggle ω w j) i j = boxOrbit ω w i j := by
  rw [boxOrbit_swap ω (toggle ω w j) i j, boxOrbit_flip_i,
    boxOrbit_swap ω w j i]

private theorem boxOrbit_erase_i (ω : ℕ) (w : Vertex ω) (i j : Fin ω) :
    boxOrbit ω (w.erase i) i j = boxOrbit ω w i j := by
  by_cases hi : i ∈ w
  · simpa only [toggle, if_pos hi] using boxOrbit_flip_i ω w i j
  · simp only [Finset.erase_eq_of_notMem hi]

private theorem boxOrbit_erase_j (ω : ℕ) (w : Vertex ω) (i j : Fin ω) :
    boxOrbit ω (w.erase j) i j = boxOrbit ω w i j := by
  rw [boxOrbit_swap ω (w.erase j) i j, boxOrbit_erase_i,
    boxOrbit_swap ω w j i]

private theorem corners_squareAt (ω : ℕ) (hω : 3 ≤ ω) (w : Vertex ω) (i : Fin ω) :
    corners ω hω (squareAt ω hω w i) = boxOrbit ω w i (next ω hω i) := by
  let j := next ω hω i
  let v := (w.erase i).erase j
  have hi : i ∉ v := by simp [v]
  have hj : j ∉ v := by simp [v]
  have hji : j ≠ i := next_ne ω hω i
  have hbase : corners ω hω (squareAt ω hω w i) = boxOrbit ω v i j := by
    simp only [corners, squareAt]
    change {v, insert i v, insert j v, insert i (insert j v)} = boxOrbit ω v i j
    simp [boxOrbit, toggle, hi, hj, hji, Finset.insert_comm]
  rw [hbase]
  exact (boxOrbit_erase_j ω (w.erase i) i j).trans (boxOrbit_erase_i ω w i j)

private theorem four_vertex_orbit (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    (Finset.range 4).image (fun k => ((step ω hω s)^[k] st).1) =
      boxOrbit ω st.1 (step ω hω s st).2 st.2 := by
  have h2 := step_twice ω hω s st
  have h3 : (step ω hω s (step ω hω s (step ω hω s st))).1 =
      toggle ω st.1 st.2 := by
    have he := congrArg Prod.fst
      ((step_twice ω hω s (step ω hω s (step ω hω s st))).symm.trans
        (raw_return_four ω hω s st))
    have hb : (step ω hω s (step ω hω s st)).2 = st.2 := by
      simpa only [Prod.snd] using congrArg Prod.snd h2
    simp only [Prod.fst, hb] at he
    have ht := congrArg (fun w => toggle ω w st.2) he
    simpa only [toggle_twice] using ht
  have h1 : (step ω hω s st).1 = toggle ω st.1 (step ω hω s st).2 := rfl
  have hv1 : ((step ω hω s)^[1] st).1 = toggle ω st.1 (step ω hω s st).2 := by
    simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply] using h1
  have hv2 : ((step ω hω s)^[2] st).1 = toggle ω (toggle ω st.1 (step ω hω s st).2) st.2 := by
    simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply, Prod.fst, h1] using congrArg Prod.fst h2
  have hv3 : ((step ω hω s)^[3] st).1 = toggle ω st.1 st.2 := by
    simpa only [Function.iterate_succ_apply, Function.iterate_zero_apply] using h3
  ext u
  simp only [Finset.range_add_one, Finset.range_zero, Finset.image_insert,
    Finset.image_empty, hv3, hv2, hv1, Function.iterate_zero_apply,
    Finset.mem_insert, Finset.notMem_empty, or_false]
  simp [boxOrbit, toggle_commute, or_comm, or_left_comm, or_assoc]

theorem pen_four_corners
    (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    ∃ f : Square ω hω,
      (Finset.range 4).image (fun k => ((step ω hω s)^[k] st).1) =
        corners ω hω f := by
  rw [four_vertex_orbit]
  rcases (pen_adjacent_seat ω hω s st).1 with hn | hp
  · refine ⟨squareAt ω hω st.1 st.2, ?_⟩
    rw [corners_squareAt, hn, boxOrbit_swap]
  · refine ⟨squareAt ω hω st.1 (prev ω hω st.2), ?_⟩
    have hinv : next ω hω (prev ω hω st.2) = st.2 := by
      simpa [next, prev, sub_eq_add_neg] using cyclic_shift_cancel ω hω st.2 (-1)
    rw [corners_squareAt, hp, hinv]

private theorem next_prev (ω : ℕ) (hω : 3 ≤ ω) (i : Fin ω) :
    next ω hω (prev ω hω i) = i := by
  simpa [next, prev, sub_eq_add_neg] using cyclic_shift_cancel ω hω i (-1)

private theorem prev_next (ω : ℕ) (hω : 3 ≤ ω) (i : Fin ω) :
    prev ω hω (next ω hω i) = i := by
  simpa [next, prev] using cyclic_shift_cancel ω hω i 1


private theorem erase_eq_cases (ω : ℕ) (w v : Vertex ω) (i : Fin ω) (hi : i ∉ v) :
    w.erase i = v ↔ w = v ∨ w = insert i v := by
  constructor
  · intro h
    by_cases hw : i ∈ w
    · right
      rw [← h, Finset.insert_erase hw]
    · left
      simpa only [Finset.erase_eq_of_notMem hw] using h
  · rintro (rfl | rfl) <;> simp [hi]

private theorem primary_square_eq (ω : ℕ) (hω : 3 ≤ ω) (e : Edge ω)
    (f : Square ω hω) :
    f = squareAt ω hω (lower ω e) e.val.2 ↔
      e.val.2 = f.val.2 ∧
        (lower ω e = f.val.1 ∨ lower ω e = insert (next ω hω f.val.2) f.val.1) := by
  rcases e with ⟨⟨w, d⟩, hd⟩
  rcases f with ⟨⟨v, i⟩, hi, hj⟩
  change _ ↔ d = i ∧ (w = v ∨ w = insert (next ω hω i) v)
  constructor
  · intro h
    have hid : i = d := congrArg (fun f => f.val.2) h
    subst d
    have hv : v = (w.erase i).erase (next ω hω i) :=
      congrArg (fun f => f.val.1) h
    rw [Finset.erase_eq_of_notMem hd] at hv
    exact ⟨rfl, (erase_eq_cases ω w v _ hj).mp hv.symm⟩
  · rintro ⟨hid, hw⟩
    subst d
    apply Subtype.ext
    change (v, i) = ((w.erase i).erase (next ω hω i), i)
    rw [Finset.erase_eq_of_notMem hd, (erase_eq_cases ω w v _ hj).mpr hw]

private theorem secondary_square_eq (ω : ℕ) (hω : 3 ≤ ω) (e : Edge ω)
    (f : Square ω hω) :
    f = squareAt ω hω (lower ω e) (prev ω hω e.val.2) ↔
      e.val.2 = next ω hω f.val.2 ∧
        (lower ω e = f.val.1 ∨ lower ω e = insert f.val.2 f.val.1) := by
  rcases e with ⟨⟨w, d⟩, hd⟩
  rcases f with ⟨⟨v, i⟩, hi, hj⟩
  change _ ↔ d = next ω hω i ∧ (w = v ∨ w = insert i v)
  constructor
  · intro h
    have hid : i = prev ω hω d := congrArg (fun f => f.val.2) h
    have hdj : d = next ω hω i := by rw [hid, next_prev]
    have hv : v = (w.erase (prev ω hω d)).erase (next ω hω (prev ω hω d)) :=
      congrArg (fun f => f.val.1) h
    rw [next_prev, Finset.erase_right_comm, Finset.erase_eq_of_notMem hd, ← hid] at hv
    exact ⟨hdj, (erase_eq_cases ω w v i hi).mp hv.symm⟩
  · rintro ⟨rfl, hw⟩
    apply Subtype.ext
    change (v, i) = ((w.erase (prev ω hω (next ω hω i))).erase
      (next ω hω (prev ω hω (next ω hω i))), prev ω hω (next ω hω i))
    rw [prev_next, Finset.erase_right_comm, Finset.erase_eq_of_notMem hd,
      (erase_eq_cases ω w v i hi).mpr hw]

private theorem coefficient_channels (ω : ℕ) (hω : 3 ≤ ω) (f : Square ω hω)
    (e : Edge ω) :
    coefficient ω hω f e =
      if f = squareAt ω hω (lower ω e) e.val.2 then epsilon ω (lower ω e)
      else if f = squareAt ω hω (lower ω e) (prev ω hω e.val.2)
        then -epsilon ω (lower ω e) else 0 := by
  classical
  simp only [primary_square_eq, secondary_square_eq]
  rcases e with ⟨⟨w, d⟩, hd⟩
  rcases f with ⟨⟨v, i⟩, hi, hj⟩
  have hji := next_ne ω hω i
  have hij : i ≠ next ω hω i := Ne.symm hji
  have hins : insert i v ≠ insert (next ω hω i) v := by
    intro h
    have hm := Finset.ext_iff.mp h i
    simp [hi, hij] at hm
  by_cases hdi : d = i <;> by_cases hdj : d = next ω hω i <;>
    by_cases hw : w = v <;> by_cases hwi : w = insert i v <;>
    by_cases hwj : w = insert (next ω hω i) v <;>
    simp_all [coefficient, boundary, mkEdge, lower, Finsupp.single_apply,
      Subtype.mk.injEq, Prod.mk.injEq, epsilon_insert]


private theorem epsilon_ne_zero (ω : ℕ) (v : Vertex ω) : epsilon ω v ≠ 0 := by
  exact pow_ne_zero _ (by decide : (-1 : ℤ) ≠ 0)

private theorem epsilon_erase (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    epsilon ω (w.erase d) = if d ∈ w then -epsilon ω w else epsilon ω w := by
  by_cases hd : d ∈ w
  · simpa only [toggle, if_pos hd] using epsilon_toggle ω w d
  · simp [Finset.erase_eq_of_notMem hd, hd]

private theorem directed_out (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    directedCoefficient ω w (toggle ω w d) (mkEdge ω w d) =
      if d ∈ w then -1 else 1 := by
  by_cases hd : d ∈ w
  · have hne : w ≠ w.erase d := by
      intro h
      have hn : d ∉ w := by rw [h]; simp
      exact hn hd
    simp [directedCoefficient, toggle, mkEdge, lower, upper, hd, hne]
  · have hne : w ≠ insert d w := by
      intro h
      have hm : d ∈ w := by rw [h]; simp
      exact hd hm
    simp [directedCoefficient, toggle, mkEdge, lower, upper, hd, hne]

private theorem directed_in (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    directedCoefficient ω (toggle ω w d) w (mkEdge ω w d) =
      -(if d ∈ w then -1 else 1) := by
  by_cases hd : d ∈ w
  · have hne : w ≠ w.erase d := by
      intro h
      have hn : d ∉ w := by rw [h]; simp
      exact hn hd
    simp [directedCoefficient, toggle, mkEdge, lower, upper, hd, hne]
  · have hne : w ≠ insert d w := by
      intro h
      have hm : d ∈ w := by rw [h]; simp
      exact hd hm
    simp [directedCoefficient, toggle, mkEdge, lower, upper, hd, hne]

private theorem directed_out_phase (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    directedCoefficient ω w (toggle ω w d) (mkEdge ω w d) =
      epsilon ω w * epsilon ω (w.erase d) := by
  rw [directed_out, epsilon_erase]
  rcases epsilon_values ω w with h | h <;> by_cases hd : d ∈ w <;> simp [h, hd]

private theorem directed_in_phase (ω : ℕ) (w : Vertex ω) (d : Fin ω) :
    directedCoefficient ω (toggle ω w d) w (mkEdge ω w d) =
      -epsilon ω w * epsilon ω (w.erase d) := by
  rw [directed_in, ← directed_out, directed_out_phase]
  ring

private theorem coefficient_primary (ω : ℕ) (hω : 3 ≤ ω) (w : Vertex ω) (i : Fin ω) :
    coefficient ω hω (squareAt ω hω w i) (mkEdge ω w i) = epsilon ω (w.erase i) := by
  have hp : squareAt ω hω w i = squareAt ω hω (lower ω (mkEdge ω w i)) i := by
    apply (primary_square_eq ω hω (mkEdge ω w i) (squareAt ω hω w i)).mpr
    refine ⟨rfl, ?_⟩
    change w.erase i = (w.erase i).erase (next ω hω i) ∨
      w.erase i = insert (next ω hω i) ((w.erase i).erase (next ω hω i))
    exact (erase_eq_cases ω (w.erase i) ((w.erase i).erase (next ω hω i))
      (next ω hω i) (by simp)).mp rfl
  rw [coefficient_channels, if_pos hp]
  rfl

private theorem coefficient_secondary (ω : ℕ) (hω : 3 ≤ ω) (w : Vertex ω) (i : Fin ω) :
    coefficient ω hω (squareAt ω hω w i) (mkEdge ω w (next ω hω i)) =
      -epsilon ω (w.erase (next ω hω i)) := by
  have hp : squareAt ω hω w i ≠
      squareAt ω hω (lower ω (mkEdge ω w (next ω hω i))) (next ω hω i) := by
    intro h
    exact next_ne ω hω i (congrArg (fun f => f.val.2) h).symm
  have hs : squareAt ω hω w i = squareAt ω hω
      (lower ω (mkEdge ω w (next ω hω i))) (prev ω hω (next ω hω i)) := by
    apply (secondary_square_eq ω hω (mkEdge ω w (next ω hω i))
      (squareAt ω hω w i)).mpr
    refine ⟨rfl, ?_⟩
    change w.erase (next ω hω i) = (w.erase i).erase (next ω hω i) ∨
      w.erase (next ω hω i) = insert i ((w.erase i).erase (next ω hω i))
    apply (erase_eq_cases ω (w.erase (next ω hω i))
      ((w.erase i).erase (next ω hω i)) i (by simp)).mp
    exact Finset.erase_right_comm
  rw [coefficient_channels, if_neg hp, if_pos hs]
  rfl

private theorem oriented_next (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω)
    (hd : (step ω hω s st).2 = next ω hω st.2)
    (hs : signValue s = -epsilon ω st.1) :
    ∃ f : Square ω hω,
      coefficient ω hω f (mkEdge ω st.1 st.2) ≠ 0 ∧
      coefficient ω hω f (mkEdge ω st.1 (step ω hω s st).2) ≠ 0 ∧
      directedCoefficient ω (toggle ω st.1 st.2) st.1 (mkEdge ω st.1 st.2) =
        signValue s * coefficient ω hω f (mkEdge ω st.1 st.2) ∧
      directedCoefficient ω st.1 (step ω hω s st).1
          (mkEdge ω st.1 (step ω hω s st).2) =
        signValue s * coefficient ω hω f (mkEdge ω st.1 (step ω hω s st).2) := by
  refine ⟨squareAt ω hω st.1 st.2, ?_, ?_, ?_, ?_⟩
  · rw [coefficient_primary]
    exact epsilon_ne_zero ω _
  · rw [hd, coefficient_secondary]
    exact neg_ne_zero.mpr (epsilon_ne_zero ω _)
  · rw [directed_in_phase, coefficient_primary, hs]
  · change directedCoefficient ω st.1 (toggle ω st.1 (step ω hω s st).2) _ = _
    rw [hd, directed_out_phase, coefficient_secondary, hs]
    ring

private theorem oriented_prev (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω)
    (hd : (step ω hω s st).2 = prev ω hω st.2)
    (hs : signValue s = epsilon ω st.1) :
    ∃ f : Square ω hω,
      coefficient ω hω f (mkEdge ω st.1 st.2) ≠ 0 ∧
      coefficient ω hω f (mkEdge ω st.1 (step ω hω s st).2) ≠ 0 ∧
      directedCoefficient ω (toggle ω st.1 st.2) st.1 (mkEdge ω st.1 st.2) =
        signValue s * coefficient ω hω f (mkEdge ω st.1 st.2) ∧
      directedCoefficient ω st.1 (step ω hω s st).1
          (mkEdge ω st.1 (step ω hω s st).2) =
        signValue s * coefficient ω hω f (mkEdge ω st.1 (step ω hω s st).2) := by
  let d := (step ω hω s st).2
  have hb : next ω hω d = st.2 := by rw [show d = prev ω hω st.2 from hd, next_prev]
  have cb : coefficient ω hω (squareAt ω hω st.1 d) (mkEdge ω st.1 st.2) =
      -epsilon ω (st.1.erase st.2) := by rw [← hb, coefficient_secondary]
  have cd := coefficient_primary ω hω st.1 d
  refine ⟨squareAt ω hω st.1 d, ?_, ?_, ?_, ?_⟩
  · rw [cb]
    exact neg_ne_zero.mpr (epsilon_ne_zero ω _)
  · change coefficient ω hω (squareAt ω hω st.1 d) (mkEdge ω st.1 d) ≠ 0
    rw [cd]
    exact epsilon_ne_zero ω _
  · rw [directed_in_phase, cb, hs]
    ring
  · change directedCoefficient ω st.1 (toggle ω st.1 d) (mkEdge ω st.1 d) = _
    rw [directed_out_phase, cd, hs]

theorem pen_oriented_square
    (ω : ℕ) (hω : 3 ≤ ω) (s : Sign) (st : State ω) :
    ∃ f : Square ω hω,
      coefficient ω hω f (mkEdge ω st.1 st.2) ≠ 0 ∧
      coefficient ω hω f (mkEdge ω st.1 (step ω hω s st).2) ≠ 0 ∧
      directedCoefficient ω (toggle ω st.1 st.2) st.1 (mkEdge ω st.1 st.2) =
        signValue s * coefficient ω hω f (mkEdge ω st.1 st.2) ∧
      directedCoefficient ω st.1 (step ω hω s st).1
          (mkEdge ω st.1 (step ω hω s st).2) =
        signValue s * coefficient ω hω f (mkEdge ω st.1 (step ω hω s st).2) := by
  cases s <;> rcases epsilon_values ω st.1 with he | he
  · apply oriented_prev ω hω .positive st <;> simp [step, signValue, he, prev]
  · apply oriented_next ω hω .positive st <;> simp [step, signValue, he, next]
  · apply oriented_next ω hω .negative st <;> simp [step, signValue, he, next]
  · apply oriented_prev ω hω .negative st <;> simp [step, signValue, he, prev]

end FVLT.AtomSkinV1
