import Mathlib

noncomputable section

namespace AtlasLocal

/-- Wait at i until every remaining step must increase to reach j+H. -/
def lane (H i j t : ℤ) : ℤ := max i (j-H+t)

theorem lane_path (H i j : ℤ) (h : |j-i| ≤ H) :
    lane H i j 0 = i ∧ lane H i j (2*H) = j+H ∧
    ∀ t, lane H i j (t+1) = lane H i j t ∨
      lane H i j (t+1) = lane H i j t + 1 := by
  rw [abs_le] at h
  unfold lane
  refine ⟨by omega, by omega, ?_⟩
  intro t
  omega

/-- All aligned pairs have disjoint vertices at every time, including H=0. -/
theorem lanes_disjoint (H i j i' j' t : ℤ) (hi : i < i') (hj : j < j') :
    lane H i j t < lane H i' j' t := by unfold lane; omega

theorem uncross (H i i' j j' : ℤ) (hi : i ≤ i') (hj : j ≤ j')
    (hx : |j'-i| ≤ H) (hy : |j-i'| ≤ H) :
    |j-i| ≤ H ∧ |j'-i'| ≤ H := by
  rw [abs_le] at hx hy
  constructor <;> rw [abs_le] <;> omega

/-- Every nonvanishing minor exhibits a permutation of supported entries. -/
theorem support_of_det_ne_zero {ι : Type*} [Fintype ι] [DecidableEq ι]
    (A : Matrix ι ι ℝ) (h : A.det ≠ 0) :
    ∃ σ : Equiv.Perm ι, ∀ i, A (σ i) i ≠ 0 := by
  classical
  by_contra! hf
  apply h
  rw [Matrix.det_apply]
  apply Finset.sum_eq_zero
  intro σ _
  obtain ⟨i, hi⟩ := hf σ
  have hz : (∏ j, A (σ j) j) = 0 := Finset.prod_eq_zero (Finset.mem_univ i) hi
  rw [hz, smul_zero]
/-- The shift from j to j+H in the viewer is made at the call site. -/
def walk (n : ℕ) (x y : ℤ) : ℝ :=
  if x ≤ y then (n.choose (y-x).toNat : ℝ) else 0

private theorem walk_succ (n : ℕ) (x y : ℤ) :
    walk (n+1) x y = walk n x y + walk n (x+1) y := by
  rcases lt_trichotomy x y with h|h|h
  · have e : (y-x).toNat = (y-(x+1)).toNat+1 := by omega
    simp [walk, h.le, show x+1 ≤ y by omega, e, Nat.choose_succ_succ, add_comm]
  · subst y; simp [walk]
  · simp [walk, show ¬x ≤ y by omega, show ¬x+1 ≤ y by omega]

def minor {k : ℕ} (n : ℕ) (x y : Fin k → ℤ) : ℝ :=
  (Matrix.of fun i j => walk n (x i) (y j)).det

private def next {k : ℕ} (s : Finset (Fin k)) (x : Fin k → ℤ) (i : Fin k) :=
  if i ∈ s then x i else x i+1

private theorem expand {k : ℕ} (n : ℕ) (x y : Fin k → ℤ) :
    minor (n+1) x y = ∑ s : Finset (Fin k), minor n (next s x) y := by
  classical
  let a := fun i j => walk n (x i) (y j)
  let b := fun i j => walk n (x i+1) (y j)
  let f := (Matrix.detRowAlternating (R := ℝ) (n := Fin k)).toMultilinearMap
  have he : minor (n+1) x y = f (a+b) := by
    unfold minor
    congr 1
    exact show Matrix.of (fun i j => walk (n+1) (x i) (y j)) = a+b from
      funext fun i => funext fun j => walk_succ n (x i) (y j)
  rw [he, f.map_add_univ]
  apply Finset.sum_congr rfl
  intro s _
  change (Matrix.of (s.piecewise a b)).det = _
  unfold minor
  congr 1
  ext i j
  by_cases h : i ∈ s <;> simp [Finset.piecewise, next, h, a, b]

/-- Every ordered minor is nonnegative, and an aligned reachable family
gives strict positivity. Expansion uses multilinearity one time slice at a time. -/
theorem ordered_minors {k : ℕ} (n : ℕ) (x y : Fin k → ℤ)
    (hx : StrictMono x) (hy : StrictMono y) :
    0 ≤ minor n x y ∧ ((∀ i, x i ≤ y i ∧ y i ≤ x i+n) → 0 < minor n x y) := by
  classical
  induction n generalizing x with
  | zero =>
    have hw (u v : ℤ) : walk 0 u v = if u=v then 1 else 0 := by
      rcases lt_trichotomy u v with h|h|h
      · simp [walk, h.le, h.ne, Nat.choose_eq_zero_of_lt (show 0 < (v-u).toNat by omega)]
      · subst v; simp [walk]
      · simp [walk, not_le.mpr h, h.ne']
    have he : minor 0 x y = ((1 : Matrix ℤ ℤ ℝ).submatrix x y).det := by
      unfold minor
      congr 1
      ext i j
      simp [hw, Matrix.one_apply]
    rw [he]
    refine ⟨Matrix.IsTotallyNonneg.one hx hy, ?_⟩
    intro reach
    have e : x=y := funext fun i => by have := reach i; omega
    subst y
    simp [Matrix.submatrix_one _ hx.injective]
  | succ n ih =>
    rw [expand]
    have term (s : Finset (Fin k)) : 0 ≤ minor n (next s x) y := by
      by_cases mono : StrictMono (next s x)
      · exact (ih _ mono).1
      · simp only [StrictMono, not_forall] at mono
        obtain ⟨i,j,hij,hbad⟩ := mono
        have hi := hx hij
        have eq : next s x i = next s x j := by
          unfold next at *; split_ifs at * <;> omega
        have same : (Matrix.of fun u v => walk n (next s x u) (y v)) i =
            (Matrix.of fun u v => walk n (next s x u) (y v)) j := by
          funext l
          change walk n (next s x i) (y l) = walk n (next s x j) (y l)
          rw [eq]
        rw [minor, Matrix.det_zero_of_row_eq hij.ne same]
    refine ⟨Finset.sum_nonneg (fun s _ => term s), ?_⟩
    intro reach
    let s := Finset.univ.filter (fun i => y i ≤ x i+n)
    have en (i : Fin k) : next s x i = max (x i) (y i-n) := by
      have := reach i
      simp only [s, next, Finset.mem_filter, Finset.mem_univ, true_and]
      split_ifs <;> omega
    have mono : StrictMono (next s x) := by
      intro i j hij
      rw [en,en]
      have := hx hij
      have := hy hij
      omega
    have hit := (ih _ mono).2 (show ∀ i, next s x i ≤ y i ∧ y i ≤ next s x i+n by
      intro i; rw [en]; have := reach i; omega)
    exact hit.trans_le (Finset.single_le_sum (fun t _ => term t) (Finset.mem_univ s))
private theorem select_rows {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) (k : ℕ)
    (hk : A.rank = k) : ∃ r : Fin k → Fin m, LinearIndependent ℝ (A.row ∘ r) := by
  have hs := Submodule.exists_fun_fin_finrank_span_eq ℝ (Set.range A.row)
  rw [← A.rank_eq_finrank_span_row, hk] at hs
  obtain ⟨f,hf,_,hind⟩ := hs
  choose r hr using hf
  exact ⟨r, (show A.row ∘ r = f from funext hr) ▸ hind⟩

/-- Finite real matrix rank is attained by a minor, including rank zero. -/
theorem rank_minor {m n : ℕ} (A : Matrix (Fin m) (Fin n) ℝ) :
    ∃ r : Fin A.rank → Fin m, ∃ c : Fin A.rank → Fin n,
      Function.Injective r ∧ Function.Injective c ∧ (A.submatrix r c).det ≠ 0 := by
  obtain ⟨r,hr⟩ := select_rows A A.rank rfl
  let B := A.submatrix r id
  have hb : B.rank = A.rank := by simpa using (show LinearIndependent ℝ B.row from hr).rank_matrix
  obtain ⟨c,hc⟩ := select_rows B.transpose A.rank (B.rank_transpose.trans hb)
  have hh : LinearIndependent ℝ (A.submatrix r c).col := hc
  exact ⟨r,c,hr.injective.of_comp,hc.injective.of_comp,
    ((Matrix.isUnit_iff_isUnit_det _).mp (Matrix.linearIndependent_col_iff_isUnit.mp hh)).ne_zero⟩

private theorem sorted_bounds {k : ℕ} (a b : Fin k → ℤ) (p q : Equiv.Perm (Fin k))
    (ha : Monotone (a ∘ p)) (hb : Monotone (b ∘ q)) (hle : ∀ i, a i ≤ b i)
    (i : Fin k) : a (p i) ≤ b (q i) := by
  classical
  let T := b (q i)
  have hcard (f : Fin k → ℤ) (σ : Equiv.Perm (Fin k)) :
      (Finset.univ.filter (fun j => f (σ j) ≤ T)).card =
      (Finset.univ.filter (fun j => f j ≤ T)).card := by
    apply Finset.card_bij' (fun j _ => σ j) (fun j _ => σ.symm j) <;> simp
  apply (Tuple.lt_card_le_iff_apply_le_of_monotone ha).mp
  have h := (Tuple.lt_card_le_iff_apply_le_of_monotone hb (a := T) (j := i)).mpr le_rfl
  change i.val < (Finset.univ.filter (fun j => a (p j) ≤ T)).card
  change i.val < (Finset.univ.filter (fun j => b (q j) ≤ T)).card at h
  rw [hcard] at h ⊢
  apply h.trans_le (Finset.card_le_card ?_)
  intro j hj
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _, (hle j).trans (Finset.mem_filter.mp hj).2⟩

/-- Matching chooses distinct row and column indices, with no order hypothesis. -/
def Matches {m n : ℕ} (x : Fin m → ℤ) (y : Fin n → ℤ) (H k : ℕ) : Prop :=
  ∃ r : Fin k → Fin m, ∃ c : Fin k → Fin n,
    Function.Injective r ∧ Function.Injective c ∧ ∀ i, |y (c i)-x (r i)| ≤ H

/-- The radius-H binomial matrix has rank equal to the maximum matching size. -/
theorem local_rank_matching {m n : ℕ} (x : Fin m → ℤ) (y : Fin n → ℤ)
    (hx : Function.Injective x) (hy : Function.Injective y) (H : ℕ) :
    let A := Matrix.of fun i j => walk (2*H) (x i) (y j+H)
    IsGreatest {k | Matches x y H k} A.rank := by
  intro A
  constructor
  · obtain ⟨r,c,hr,hc,hd⟩ := rank_minor A
    obtain ⟨p,hp⟩ := support_of_det_ne_zero _ hd
    refine ⟨r ∘ p,c,hr.comp p.injective,hc,?_⟩
    intro i
    have h := hp i
    change walk (2*H) (x (r (p i))) (y (c i)+H) ≠ 0 at h
    unfold walk at h
    split_ifs at h with hs
    · have ht : (y (c i)+H-x (r (p i)) |>.toNat) ≤ 2*H := by
        by_contra! hn; exact h (by simp [Nat.choose_eq_zero_of_lt hn])
      change |y (c i)-x (r (p i))| ≤ H
      rw [abs_le]; omega
    · exact (h rfl).elim
  · rintro k ⟨r,c,hr,hc,hreach⟩
    let a := x ∘ r
    let b := y ∘ c
    let p := Tuple.sort a
    let q := Tuple.sort b
    have ha : StrictMono (a ∘ p) := (Tuple.monotone_sort a).strictMono_of_injective ((hx.comp hr).comp p.injective)
    have hb : StrictMono (b ∘ q) := (Tuple.monotone_sort b).strictMono_of_injective ((hy.comp hc).comp q.injective)
    have hab (i) := abs_le.mp (hreach i)
    have hordered := (ordered_minors (2*H) (a ∘ p) ((fun j => b j+H) ∘ q) ha
      (fun i j hij => add_lt_add_left (hb hij) _)).2
    have hs := hordered (fun i => by
      have hl := sorted_bounds a (fun j => b j+H) p q ha.monotone
        (fun i j hij => add_le_add_left (hb.monotone hij) _) (fun j => by
          have := hab j; dsimp [a,b]; omega) i
      have hu := sorted_bounds b (fun j => a j+H) q p hb.monotone
        (fun i j hij => add_le_add_left (ha.monotone hij) _) (fun j => by
          have := hab j; dsimp [a,b]; omega) i
      dsimp only [Function.comp_apply]; push_cast; constructor <;> omega)
    have hdet : (A.submatrix (r ∘ p) (c ∘ q)).det ≠ 0 := ne_of_gt hs
    have hk := A.rank_submatrix_le (r ∘ p) (c ∘ q)
    rwa [Matrix.rank_of_det_ne_zero hdet, Fintype.card_fin] at hk
end AtlasLocal
