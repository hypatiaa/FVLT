import Mathlib.Data.ZMod.Basic
import Mathlib.GroupTheory.Perm.Sign
import Mathlib.Data.Set.Card
import Mathlib.Data.Fintype.Pi
import Mathlib.Data.List.Rotate
import Mathlib.Data.Fin.VecNotation
import Mathlib.Tactic.Ring
import Mathlib.Tactic.Abel
import Mathlib.Tactic.FinCases
import Mathlib.Tactic.NormNum

/-!
# GOLAY-DOOR-2 walk holonomy and hexacode chirality (library module, v0.1.2 documentation)
All 29 statements below are proved, with no `sorry`. Audit VERIFIED: FVLT_GOLAY_WALK_HOLONOMY_LEAN_AUDIT_v0_1_1_20261113
(059ffe3b…); in library v36+4 (SUMS f2febd64…). v0.1.2 changes documentation comments only; the statements and
proofs are those of v0.1.1 (c47696d9…). The statements were frozen as STATEMENT DRAFT v0.1.1 (2026-11-13).

v0.1.1 successor of v0.1 (d4ecca3d…, kept). Only change: `symQ` and `diagSum` are written without recursion
of their own (`steps` = zip with tail, `areaStep` folded by `foldl`, `sum`); `symQAux` is removed. Reason: the
v0.1 audit (FVLT_GOLAY_WALK_HOLONOMY_LEAN_AUDIT_v0_1_20261111) found that Lean 4.35 emits a compiler-only
`_unsafe_rec` constant for every recursive definition, and replay checker 436 fails any partial constant.
Same values as v0.1 (checked on 3000 walks); all 29 theorem statements are unchanged.

Source: GOLAY-DOOR-2 spec v0.2.2 (`golay_door_2_20261109/experiment_spec_2026-11-10_golay-door-2_v0_2_2.md`,
1020a235…) §C.2 and the pinned reference block; scripts `check_fvlt_native_walk_symmetric_Q_v0_2.js` (76a07603…)
and `check_chiral_class_alignment_v0_1.py` (3590a140…). Walk frame: Codex bus #2043; sign fixture: Codex #2067;
chiral-class point: Gemini #2071. Native walk s ↦ gcd(s, N): saphir.

Item 1 (walk): the symmetric (Weyl) area of the closed native walk is 0 for EVERY N and EVERY coordinate map
of the visited divisors (not only 30030 and the rank-2 split maps); the committed A-first and B-first areas are opposite.
Item 2 (orientation): a linear change of the F3² frame multiplies the symmetric area by its determinant; a
diagonal (orientation) change multiplies the committed area by its determinant; translation changes nothing.
Item 3 (hexacode): finite F4 facts. 3a (T13–T15) are witness/decision checks. 3b (T16–T18) are the core results, proved by kernel check.

Conventions:
* points are `ZMod 3 × ZMod 3` (positions in the two declared cyclic orders); 1/2 = 2 in F3;
* a step d from running displacement S adds 2·(S ∧ d); a two-triple step takes the zero-area (midpoint) lift;
  A-first (ε = 1) adds 2·d₁d₂, B-first (ε = −1) subtracts it;
* F4 = Fin 4 with 2 = ω, 3 = ω²; codes are spans of three generator rows; `remap σ` reads input σ j into output j
  (the #2067 convention, output j reads input map[j]); the monomial class applies the scaling first, then the
  permutation.
-/

namespace FVLT.GolayWalkHolonomyV1

/-! ## Item 1: area on the native walk -/

abbrev Pt := ZMod 3 × ZMod 3

/-- S ∧ d. -/
def wedge (u v : Pt) : ZMod 3 := u.1 * v.2 - u.2 * v.1

/-- The step list of a walk: d_t = x_{t+1} − x_t. -/
def steps (xs : List Pt) : List Pt := (xs.zip xs.tail).map fun q => q.2 - q.1

/-- One area step: running displacement S and area Q; the step d adds 2·(S ∧ d), then S becomes S + d. -/
def areaStep (st : Pt × ZMod 3) (d : Pt) : Pt × ZMod 3 := (st.1 + d, st.2 + 2 * wedge st.1 d)

/-- Symmetric (zero-area-lift) area Q of a walk, started at its first point (S = 0, Q = 0). -/
def symQ (xs : List Pt) : ZMod 3 := ((steps xs).foldl areaStep (0, 0)).2

/-- Σ over steps of d₁·d₂ (the diagonal correction). -/
def diagSum (xs : List Pt) : ZMod 3 := ((steps xs).map fun d => d.1 * d.2).sum

/-- Committed area: ε = 1 is A-first, ε = −1 is B-first. -/
def commQ (ε : ZMod 3) (xs : List Pt) : ZMod 3 := symQ xs + ε * 2 * diagSum xs

/-- Close a walk by returning to its first point. -/
def closeLoop : List Pt → List Pt
  | [] => []
  | x :: xs => x :: xs ++ [x]

/-- The native walk s ↦ gcd(s, N), s = 1, …, N, read through a coordinate map `f`
(`none` = the divisor is not in the coordinate set). -/
def gcdVisits (N : ℕ) (f : ℕ → Option Pt) : List Pt :=
  (List.range' 1 N).filterMap (fun s => f (Nat.gcd s N))

/-! ### Proof helpers for item 1 (builder; not part of the frozen statements) -/

/-- Open chain sum of wedges over consecutive points (no recursion of its own). -/
private def chain (l : List Pt) : ZMod 3 := ((l.zip l.tail).map fun q => wedge q.1 q.2).sum

private theorem chain_nil : chain [] = 0 := by simp [chain]

private theorem chain_single (x : Pt) : chain [x] = 0 := by simp [chain]

private theorem chain_cons2 (x y : Pt) (ys : List Pt) :
    chain (x :: y :: ys) = wedge x y + chain (y :: ys) := by
  simp [chain]

private theorem steps_nil : steps [] = [] := by simp [steps]

private theorem steps_single (x : Pt) : steps [x] = [] := by simp [steps]

private theorem steps_cons2 (x y : Pt) (ys : List Pt) : steps (x :: y :: ys) = (y - x) :: steps (y :: ys) := by
  simp [steps]

private theorem symQ_nil : symQ [] = 0 := by simp [symQ, steps_nil]

private theorem diagSum_nil : diagSum [] = 0 := by simp [diagSum, steps_nil]

private theorem diagSum_single (x : Pt) : diagSum [x] = 0 := by simp [diagSum, steps_single]

private theorem diagSum_cons2 (x y : Pt) (ys : List Pt) :
    diagSum (x :: y :: ys) = (y.1 - x.1) * (y.2 - x.2) + diagSum (y :: ys) := by
  simp [diagSum, steps_cons2]

/-- The running area from displacement `S` and previous point `p` (non-recursive; replaces v0.1's `symQAux`). -/
private def F (S p : Pt) (ys : List Pt) : ZMod 3 := ((steps (p :: ys)).foldl areaStep (S, 0)).2

private theorem foldl_shift (ds : List Pt) : ∀ (S : Pt) (Q : ZMod 3),
    (ds.foldl areaStep (S, Q)).2 = Q + (ds.foldl areaStep (S, 0)).2 := by
  induction ds with
  | nil => intro S Q; simp
  | cons d ds ih =>
    intro S Q
    simp only [List.foldl_cons, areaStep]
    rw [ih (S + d) (Q + 2 * wedge S d), ih (S + d) (0 + 2 * wedge S d)]
    ring

private theorem F_nil (S p : Pt) : F S p [] = 0 := by simp [F, steps_single]

private theorem F_cons (S p y : Pt) (ys : List Pt) :
    F S p (y :: ys) = 2 * wedge S (y - p) + F (S + (y - p)) y ys := by
  unfold F
  rw [steps_cons2, List.foldl_cons]
  simp only [areaStep]
  rw [foldl_shift]
  ring

private theorem symQ_eq_F (x : Pt) (xs : List Pt) : symQ (x :: xs) = F 0 x xs := rfl

private def wo : Option Pt → Option Pt → ZMod 3
  | some a, some b => wedge a b
  | _, _ => 0

private theorem wedge_anti (a b : Pt) : wedge a b = - wedge b a := by
  simp only [wedge]; ring

private theorem wedge_self (a : Pt) : wedge a a = 0 := by
  simp only [wedge]; ring

private theorem wo_swap (o₁ o₂ : Option Pt) : wo o₁ o₂ = - wo o₂ o₁ := by
  cases o₁ <;> cases o₂ <;> simp only [wo, neg_zero]
  exact wedge_anti _ _

private theorem chain_cons (a : Pt) (l : List Pt) : chain (a :: l) = wo (some a) l.head? + chain l := by
  cases l <;> simp [chain_nil, chain_single, chain_cons2, wo]

private theorem chain_concat (l : List Pt) (a : Pt) :
    chain (l ++ [a]) = chain l + wo l.getLast? (some a) := by
  induction l with
  | nil => simp [chain_nil, chain_single, wo]
  | cons b l ih =>
    rw [List.cons_append, chain_cons, ih, chain_cons]
    cases l with
    | nil => simp [chain_nil, wo]
    | cons c l => simp [add_assoc]

private theorem chain_reverse (l : List Pt) : chain l.reverse = - chain l := by
  induction l with
  | nil => simp [chain_nil]
  | cons a l ih =>
    rw [List.reverse_cons, chain_concat, ih, List.getLast?_reverse, chain_cons, wo_swap]
    ring

private theorem F_eq (S p : Pt) (ys : List Pt) :
    F S p ys = 2 * (chain (p :: ys) + wo (p :: ys).getLast? (some (p - S)) - wedge p (p - S)) := by
  induction ys generalizing S p with
  | nil => simp [F_nil, chain_single, wo]
  | cons y ys ih =>
    rw [F_cons, ih, List.getLast?_cons_cons, chain_cons2]
    have h1 : y - (S + (y - p)) = p - S := by abel
    rw [h1]
    generalize chain (y :: ys) = C
    generalize wo (y :: ys).getLast? (some (p - S)) = W
    obtain ⟨s1, s2⟩ := S
    obtain ⟨p1, p2⟩ := p
    obtain ⟨y1, y2⟩ := y
    simp only [wedge, Prod.mk_sub_mk]
    ring

private theorem symQ_cons (x : Pt) (xs : List Pt) :
    symQ (x :: xs) = 2 * (chain (x :: xs) + wo (x :: xs).getLast? (some x)) := by
  rw [symQ_eq_F, F_eq, sub_zero, wedge_self, sub_zero]

private theorem symQ_closeLoop_cons (x : Pt) (xs : List Pt) :
    symQ (closeLoop (x :: xs)) = 2 * chain (x :: xs ++ [x]) := by
  rw [closeLoop, List.cons_append, symQ_cons, ← List.cons_append]
  have : (x :: xs ++ [x]).getLast? = some x := by
    rw [List.getLast?_concat]
  rw [this]
  simp [wo, wedge_self]

private theorem Q_rotate_one (v : List Pt) :
    symQ (closeLoop (v.rotate 1)) = symQ (closeLoop v) := by
  rcases v with _ | ⟨x, _ | ⟨y, ys⟩⟩
  · simp
  · rw [List.rotate_singleton]
  · have hr : (x :: y :: ys).rotate 1 = y :: (ys ++ [x]) := by simp [List.rotate_cons_succ]
    rw [hr, symQ_closeLoop_cons, symQ_closeLoop_cons]
    have h1 : chain (y :: (ys ++ [x]) ++ [y]) = chain (y :: (ys ++ [x])) + wedge x y := by
      rw [chain_concat, ← List.cons_append, List.getLast?_concat]; rfl
    have h2 : chain (x :: y :: ys ++ [x]) = wedge x y + chain (y :: (ys ++ [x])) := by
      rw [List.cons_append, chain_cons]; simp [wo]
    rw [h1, h2]; ring

/-- T1. Reversing a closed walk negates its area. -/
theorem symQ_reverse_closeLoop (v : List Pt) :
    symQ (closeLoop v).reverse = - symQ (closeLoop v) := by
  cases v with
  | nil => simp [closeLoop, symQ_nil]
  | cons x xs =>
    have e : (closeLoop (x :: xs)).reverse = closeLoop (x :: xs.reverse) := by
      simp [closeLoop]
    rw [e, symQ_closeLoop_cons, symQ_closeLoop_cons]
    have : x :: xs.reverse ++ [x] = (x :: xs ++ [x]).reverse := by simp
    rw [this, chain_reverse]; ring

/-- T2. The area of a closed walk does not depend on the start point. -/
theorem symQ_closeLoop_rotate (v : List Pt) (k : ℕ) :
    symQ (closeLoop (v.rotate k)) = symQ (closeLoop v) := by
  induction k with
  | zero => simp
  | succ k ih => rw [← List.rotate_rotate, Q_rotate_one, ih]

private theorem Q_reverse (u : List Pt) : symQ (closeLoop u.reverse) = - symQ (closeLoop u) := by
  cases u with
  | nil => simp [closeLoop, symQ_nil]
  | cons x xs =>
    rw [← symQ_closeLoop_rotate _ xs.length]
    have h : (x :: xs).reverse.rotate xs.length = x :: xs.reverse := by
      rw [List.reverse_cons]
      have := List.rotate_append_length_eq xs.reverse [x]
      rw [List.length_reverse] at this
      rw [this]; rfl
    rw [h, ← symQ_reverse_closeLoop]
    congr 1
    simp [closeLoop]

private theorem zmod3_eq_zero : ∀ q : ZMod 3, q = -q → q = 0 := by decide

/-- T3a. A palindromic closed walk has area 0 (uses 2 ≠ 0 in F3). -/
theorem symQ_palindrome (v : List Pt) (h : v.reverse = v) : symQ (closeLoop v) = 0 := by
  apply zmod3_eq_zero
  conv_lhs => rw [← h]
  exact Q_reverse v

/-- T3b. A palindrome followed by one extra point (a cyclic palindrome) also has area 0. -/
theorem symQ_cyclic_palindrome (v : List Pt) (w : Pt) (h : v.reverse = v) :
    symQ (closeLoop (v ++ [w])) = 0 := by
  apply zmod3_eq_zero
  have h1 : symQ (closeLoop (v ++ [w])) = symQ (closeLoop (w :: v)) := by
    rw [← symQ_closeLoop_rotate (v ++ [w]) v.length, List.rotate_append_length_eq]; rfl
  have h2 : (v ++ [w]).reverse = w :: v := by simp [h]
  calc symQ (closeLoop (v ++ [w])) = symQ (closeLoop (v ++ [w]).reverse) := by rw [h2, h1]
    _ = _ := Q_reverse _

/-- T4. The visits for s = 1, …, N−1 form a palindrome (gcd(N − s, N) = gcd(s, N)); s = N is appended. -/
theorem gcdVisits_split (N : ℕ) (hN : 1 ≤ N) (f : ℕ → Option Pt) :
    ∃ v : List Pt, v.reverse = v ∧ gcdVisits N f = v ++ (f N).toList := by
  obtain ⟨M, rfl⟩ : ∃ M, N = M + 1 := ⟨N - 1, by omega⟩
  refine ⟨(List.range' 1 M).filterMap (fun s => f (Nat.gcd s (M + 1))), ?_, ?_⟩
  · rw [← List.filterMap_reverse, List.reverse_range', List.range'_eq_map_range, List.filterMap_map,
      List.filterMap_map]
    apply List.filterMap_congr
    intro x hx
    rw [List.mem_range] at hx
    simp only [Function.comp]
    have : 1 + M - 1 - x = (M + 1) - (1 + x) := by omega
    rw [this, Nat.gcd_self_sub_left (by omega)]
  · unfold gcdVisits
    rw [List.range'_concat, List.filterMap_append]
    congr 1
    have : 1 + 1 * M = M + 1 := by ring
    rw [this]
    simp only [List.filterMap_cons, List.filterMap_nil, Nat.gcd_self]
    cases f (M + 1) <;> rfl

/-- T5. Main item 1: the symmetric holonomy of the native walk is 0, for every N and every coordinate map. -/
theorem gcd_walk_symQ_zero (N : ℕ) (f : ℕ → Option Pt) :
    symQ (closeLoop (gcdVisits N f)) = 0 := by
  rcases Nat.eq_zero_or_pos N with rfl | hN
  · simp [gcdVisits, closeLoop, symQ_nil]
  · obtain ⟨v, hv, he⟩ := gcdVisits_split N hN f
    rw [he]
    cases f N with
    | none => simpa using symQ_palindrome v hv
    | some w => simpa using symQ_cyclic_palindrome v w hv

/-- T6. The two committed areas average to the symmetric one. -/
theorem commQ_add (ε : ZMod 3) (xs : List Pt) :
    commQ ε xs + commQ (-ε) xs = 2 * symQ xs := by
  simp only [commQ]; ring

/-- T7. On the native walk the A-first and B-first holonomies are opposite. -/
theorem gcd_walk_commQ_opposite (N : ℕ) (f : ℕ → Option Pt) :
    commQ 1 (closeLoop (gcdVisits N f)) = - commQ (-1) (closeLoop (gcdVisits N f)) := by
  have h := gcd_walk_symQ_zero N f
  simp only [commQ, h]; ring

/-- T8. There is no 1/2 in F2, so the zero-area (midpoint) lift cannot be formed over F2.
(Algebraic fact only; what it means for the Rule 30 shell is not stated here.) -/
theorem no_half_ZMod2 : ¬ ∃ h : ZMod 2, 2 * h = 1 := by
  decide

/-! ## Item 2: orientation -/

/-- T9a. A linear frame change multiplies the wedge by its determinant. -/
theorem wedge_linear (a b c d : ZMod 3) (u v : Pt) :
    wedge (a * u.1 + b * u.2, c * u.1 + d * u.2) (a * v.1 + b * v.2, c * v.1 + d * v.2)
      = (a * d - b * c) * wedge u v := by
  obtain ⟨u1, u2⟩ := u
  obtain ⟨v1, v2⟩ := v
  simp only [wedge]; ring

private def lin (a b c d : ZMod 3) (p : Pt) : Pt := (a * p.1 + b * p.2, c * p.1 + d * p.2)

private theorem F_lin (a b c d : ZMod 3) (S p : Pt) (ys : List Pt) :
    F (lin a b c d S) (lin a b c d p) (ys.map (lin a b c d)) = (a * d - b * c) * F S p ys := by
  induction ys generalizing S p with
  | nil => simp [F_nil]
  | cons y ys ih =>
    simp only [List.map_cons, F_cons]
    have e1 : lin a b c d S + (lin a b c d y - lin a b c d p) = lin a b c d (S + (y - p)) := by
      obtain ⟨s1, s2⟩ := S; obtain ⟨p1, p2⟩ := p; obtain ⟨y1, y2⟩ := y
      simp only [lin, Prod.mk_add_mk, Prod.mk_sub_mk, Prod.mk.injEq]
      constructor <;> ring
    have e2 : wedge (lin a b c d S) (lin a b c d y - lin a b c d p) = (a * d - b * c) * wedge S (y - p) := by
      obtain ⟨s1, s2⟩ := S; obtain ⟨p1, p2⟩ := p; obtain ⟨y1, y2⟩ := y
      simp only [lin, wedge, Prod.mk_sub_mk]
      ring
    rw [e1, ih, e2]; ring

/-- T9b. A linear frame change multiplies the symmetric area by its determinant. -/
theorem symQ_linear (a b c d : ZMod 3) (xs : List Pt) :
    symQ (xs.map fun p => (a * p.1 + b * p.2, c * p.1 + d * p.2)) = (a * d - b * c) * symQ xs := by
  show symQ (xs.map (lin a b c d)) = _
  cases xs with
  | nil => simp [symQ_nil]
  | cons x xs =>
    have := F_lin a b c d 0 x xs
    rw [show lin a b c d 0 = 0 by simp [lin]] at this
    rw [List.map_cons, symQ_eq_F, symQ_eq_F]
    exact this

private theorem diagSum_diag_cons (δ₁ δ₂ : ZMod 3) (xs : List Pt) : ∀ x : Pt,
    diagSum ((x :: xs).map fun p => (δ₁ * p.1, δ₂ * p.2)) = δ₁ * δ₂ * diagSum (x :: xs) := by
  induction xs with
  | nil => intro x; simp [diagSum_single]
  | cons y ys ih =>
    intro x
    have := ih y
    simp only [List.map_cons] at this
    simp only [List.map_cons, diagSum_cons2]
    rw [this]; ring

private theorem diagSum_diag (δ₁ δ₂ : ZMod 3) (xs : List Pt) :
    diagSum (xs.map fun p => (δ₁ * p.1, δ₂ * p.2)) = δ₁ * δ₂ * diagSum xs := by
  cases xs with
  | nil => simp [diagSum_nil]
  | cons x xs => exact diagSum_diag_cons δ₁ δ₂ xs x

/-- T10. A diagonal frame change multiplies the committed area by its determinant. -/
theorem commQ_diag (δ₁ δ₂ ε : ZMod 3) (xs : List Pt) :
    commQ ε (xs.map fun p => (δ₁ * p.1, δ₂ * p.2)) = δ₁ * δ₂ * commQ ε xs := by
  unfold commQ
  rw [diagSum_diag]
  have := symQ_linear δ₁ 0 0 δ₂ xs
  simp only [zero_mul, add_zero, zero_add, mul_zero, sub_zero] at this
  rw [this]; ring

/-- T10a. One orientation flip (reverse one triple's cyclic order) negates the committed area. -/
theorem commQ_one_flip (ε : ZMod 3) (xs : List Pt) :
    commQ ε (xs.map fun p => (-p.1, p.2)) = - commQ ε xs := by
  have := commQ_diag (-1) 1 ε xs
  simpa using this

/-- T10b. Two flips leave it fixed. -/
theorem commQ_two_flips (ε : ZMod 3) (xs : List Pt) :
    commQ ε (xs.map fun p => (-p.1, -p.2)) = commQ ε xs := by
  have := commQ_diag (-1) (-1) ε xs
  simpa using this

private theorem F_translate (c S p : Pt) (ys : List Pt) :
    F S (p + c) (ys.map (· + c)) = F S p ys := by
  induction ys generalizing S p with
  | nil => simp [F_nil]
  | cons y ys ih => simp only [List.map_cons, F_cons, add_sub_add_right_eq_sub, ih]

/-- T11. Changing the start of a cyclic order (a translation) changes nothing. -/
theorem symQ_translate (c : Pt) (xs : List Pt) : symQ (xs.map (· + c)) = symQ xs := by
  cases xs with
  | nil => simp [symQ_nil]
  | cons x xs =>
    rw [List.map_cons, symQ_eq_F, symQ_eq_F]
    exact F_translate c 0 x xs

/-- T12a. Codex #2067 fixture: 14 → 21 → 33 with A = (2,3,5), B = (7,11,13) has Q = 2. -/
theorem fixture_Q : symQ [(0, 0), (1, 0), (1, 1)] = 2 := by
  decide

/-- T12b. A's cyclic order reversed: Q = 1. -/
theorem fixture_Q_A_reversed : symQ [(0, 0), (2, 0), (2, 1)] = 1 := by
  decide

/-- T12c. Both reversed: Q = 2. -/
theorem fixture_Q_both_reversed : symQ [(0, 0), (2, 0), (2, 2)] = 2 := by
  decide

/-! ## Item 3: hexacode chirality -/

abbrev F4 := Fin 4

/-- F4 addition (XOR on the labels 0, 1, ω = 2, ω² = 3). -/
def addT : F4 → F4 → F4 := ![![0, 1, 2, 3], ![1, 0, 3, 2], ![2, 3, 0, 1], ![3, 2, 1, 0]]

/-- F4 multiplication. -/
def mulT : F4 → F4 → F4 := ![![0, 0, 0, 0], ![0, 1, 2, 3], ![0, 2, 3, 1], ![0, 3, 1, 2]]

/-- Frobenius x ↦ x² (swaps ω and ω²). -/
def frob : F4 → F4 := ![0, 1, 3, 2]

abbrev Word := Fin 6 → F4

def comb3 (G : Fin 3 → Word) (c : Fin 3 → F4) : Word :=
  fun i => addT (addT (mulT (c 0) (G 0 i)) (mulT (c 1) (G 1 i))) (mulT (c 2) (G 2 i))

/-- The code spanned by three rows. -/
def code (G : Fin 3 → Word) : Finset Word := Finset.univ.image (comb3 G)

/-- Output j reads input σ j. -/
def remap (σ : Fin 6 → Fin 6) (C : Finset Word) : Finset Word := C.image (fun w j => w (σ j))

def scale (d : Fin 6 → F4) (C : Finset Word) : Finset Word := C.image (fun w j => mulT (d j) (w j))

def conj (C : Finset Word) : Finset Word := C.image (fun w j => frob (w j))

/-- H_Curtis, the Door-1 v0.1.3 generator. -/
def GCurtis : Fin 3 → Word := ![![1, 0, 0, 1, 3, 2], ![0, 1, 0, 1, 2, 3], ![0, 0, 1, 1, 1, 1]]

/-- #2056's recovered code REC = [I | A], A = [[1,1,1],[1,ω,ω²],[1,ω²,ω]], in the induced frame. -/
def GRec : Fin 3 → Word := ![![1, 0, 0, 1, 1, 1], ![0, 1, 0, 1, 2, 3], ![0, 0, 1, 1, 3, 2]]

/-- curtis_to_bridge [0,2,4,1,3,5]. -/
def c2b : Equiv.Perm (Fin 6) := ⟨![0, 2, 4, 1, 3, 5], ![0, 3, 1, 4, 2, 5], by decide, by decide⟩
/-- induced → Curtis [2,1,0,3,4,5] (#2067). -/
def i2c : Equiv.Perm (Fin 6) := ⟨![2, 1, 0, 3, 4, 5], ![2, 1, 0, 3, 4, 5], by decide, by decide⟩
/-- induced → bridge [2,0,4,1,3,5] (#2067). -/
def i2b : Equiv.Perm (Fin 6) := ⟨![2, 0, 4, 1, 3, 5], ![1, 3, 0, 4, 2, 5], by decide, by decide⟩

def HCurtis : Finset Word := code GCurtis
def HBridge : Finset Word := remap c2b HCurtis
def REC : Finset Word := code GRec

/-- The chiral class of C: its orbit under even monomial maps (μ3^6 ⋊ A6), scaling first, then permutation. -/
def evenClass (C : Finset Word) : Set (Finset Word) :=
  {D | ∃ σ : Equiv.Perm (Fin 6), Equiv.Perm.sign σ = 1 ∧
        ∃ d : Fin 6 → F4, (∀ j, d j ≠ 0) ∧ D = remap σ (scale d C)}

/-! ### Proof helpers for item 3 (builder; not part of the frozen statements) -/

-- The 30 kernel-check chunks below each need about 2.5 GB; check them one at a time.
set_option Elab.async false

private theorem remap_comp (σ τ : Fin 6 → Fin 6) (C : Finset Word) :
    remap τ (remap σ C) = remap (σ ∘ τ) C := by
  unfold remap; rw [Finset.image_image]; rfl

private theorem remap_id (C : Finset Word) : remap id C = C := by
  unfold remap; exact Finset.image_id'

private theorem scale_remap (d : Fin 6 → F4) (τ : Equiv.Perm (Fin 6)) (C : Finset Word) :
    scale d (remap τ C) = remap τ (scale (fun k => d (τ⁻¹ k)) C) := by
  unfold scale remap
  rw [Finset.image_image, Finset.image_image]
  congr 1
  funext w j
  simp

private theorem comb3_GCurtis_head (c : Fin 3 → F4) :
    comb3 GCurtis c 0 = c 0 ∧ comb3 GCurtis c 1 = c 1 ∧ comb3 GCurtis c 2 = c 2 := by
  have key : ∀ a b e : F4, comb3 GCurtis ![a, b, e] 0 = a ∧ comb3 GCurtis ![a, b, e] 1 = b ∧
      comb3 GCurtis ![a, b, e] 2 = e := by decide +kernel
  have hc : ![c 0, c 1, c 2] = c := by funext i; fin_cases i <;> rfl
  have := key (c 0) (c 1) (c 2)
  rwa [hc] at this

/-- Systematic membership test for H_Curtis (generator [I | A]). -/
private theorem mem_HCurtis (w : Word) : w ∈ HCurtis ↔ w = comb3 GCurtis ![w 0, w 1, w 2] := by
  constructor
  · intro hw
    simp only [HCurtis, code, Finset.mem_image, Finset.mem_univ, true_and] at hw
    obtain ⟨c, rfl⟩ := hw
    obtain ⟨h0, h1, h2⟩ := comb3_GCurtis_head c
    rw [h0, h1, h2]
    congr 1
    funext i; fin_cases i <;> rfl
  · intro hw
    rw [HCurtis, code, Finset.mem_image]
    exact ⟨_, Finset.mem_univ _, hw.symm⟩

private def invT : F4 → F4 := ![0, 1, 3, 2]

/-- A weight-6 word of H_Curtis (coefficients (1, 1, ω)). -/
private def u6 : Word := ![1, 1, 2, 2, 3, 3]

private abbrev inHP (w : Word) : Prop := ∀ j : Fin 6, w j = comb3 GCurtis ![w 0, w 1, w 2] j

private def rowImg (f : Fin 6 → Fin 6) (e : Fin 6 → F4) (i : Fin 3) : Word :=
  fun j => mulT (e j) (GCurtis i (f j))

/-- `Equiv.Perm.signAux` read off the values of a function. -/
private def sgnF (f : Fin 6 → Fin 6) : ℤˣ :=
  ∏ x ∈ Equiv.Perm.finPairsLT 6, if f x.1 ≤ f x.2 then -1 else 1

/-- For a value table `f`: every weight-6 word `w` of H_Curtis taken as the image of `u6` fixes the
scaling `e j = w j / u6 (f j)`; if the three generator rows then map into H_Curtis, `f` is even. -/
private abbrev autOK (f : Fin 6 → Fin 6) : Prop :=
  ∀ x y z : F4, (∀ j, comb3 GCurtis ![x, y, z] j ≠ 0) →
    (∀ i : Fin 3, inHP (rowImg f (fun j => mulT (comb3 GCurtis ![x, y, z] j) (invT (u6 (f j)))) i)) →
    sgnF f = 1

/-- Converse direction (used for T18): an even value table admits a weight-6 image word whose
scaling maps all three generator rows into H_Curtis. -/
private abbrev autEx (f : Fin 6 → Fin 6) : Prop :=
  sgnF f = 1 → ∃ x y z : F4, (∀ j, comb3 GCurtis ![x, y, z] j ≠ 0) ∧
    ∀ i : Fin 3, inHP (rowImg f (fun j => mulT (comb3 GCurtis ![x, y, z] j) (invT (u6 (f j)))) i)

private instance autEx_dec (f : Fin 6 → Fin 6) : Decidable (autEx f) :=
  inferInstanceAs (Decidable (sgnF f = 1 → ∃ x y z : F4, (∀ j, comb3 GCurtis ![x, y, z] j ≠ 0) ∧
    ∀ i : Fin 3, inHP (rowImg f (fun j => mulT (comb3 GCurtis ![x, y, z] j) (invT (u6 (f j)))) i)))

private abbrev autBoth (f : Fin 6 → Fin 6) : Prop := autOK f ∧ autEx f

private theorem core_0_1 : ∀ a2 : Fin 6, a2 ≠ 0 → a2 ≠ 1 →
    ∀ a3 : Fin 6, a3 ≠ 0 → a3 ≠ 1 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 0 → a4 ≠ 1 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 0 → a5 ≠ 1 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![0, 1, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_0_2 : ∀ a2 : Fin 6, a2 ≠ 0 → a2 ≠ 2 →
    ∀ a3 : Fin 6, a3 ≠ 0 → a3 ≠ 2 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 0 → a4 ≠ 2 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 0 → a5 ≠ 2 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![0, 2, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_0_3 : ∀ a2 : Fin 6, a2 ≠ 0 → a2 ≠ 3 →
    ∀ a3 : Fin 6, a3 ≠ 0 → a3 ≠ 3 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 0 → a4 ≠ 3 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 0 → a5 ≠ 3 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![0, 3, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_0_4 : ∀ a2 : Fin 6, a2 ≠ 0 → a2 ≠ 4 →
    ∀ a3 : Fin 6, a3 ≠ 0 → a3 ≠ 4 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 0 → a4 ≠ 4 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 0 → a5 ≠ 4 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![0, 4, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_0_5 : ∀ a2 : Fin 6, a2 ≠ 0 → a2 ≠ 5 →
    ∀ a3 : Fin 6, a3 ≠ 0 → a3 ≠ 5 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 0 → a4 ≠ 5 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 0 → a5 ≠ 5 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![0, 5, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_1_0 : ∀ a2 : Fin 6, a2 ≠ 1 → a2 ≠ 0 →
    ∀ a3 : Fin 6, a3 ≠ 1 → a3 ≠ 0 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 1 → a4 ≠ 0 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 1 → a5 ≠ 0 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![1, 0, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_1_2 : ∀ a2 : Fin 6, a2 ≠ 1 → a2 ≠ 2 →
    ∀ a3 : Fin 6, a3 ≠ 1 → a3 ≠ 2 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 1 → a4 ≠ 2 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 1 → a5 ≠ 2 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![1, 2, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_1_3 : ∀ a2 : Fin 6, a2 ≠ 1 → a2 ≠ 3 →
    ∀ a3 : Fin 6, a3 ≠ 1 → a3 ≠ 3 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 1 → a4 ≠ 3 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 1 → a5 ≠ 3 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![1, 3, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_1_4 : ∀ a2 : Fin 6, a2 ≠ 1 → a2 ≠ 4 →
    ∀ a3 : Fin 6, a3 ≠ 1 → a3 ≠ 4 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 1 → a4 ≠ 4 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 1 → a5 ≠ 4 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![1, 4, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_1_5 : ∀ a2 : Fin 6, a2 ≠ 1 → a2 ≠ 5 →
    ∀ a3 : Fin 6, a3 ≠ 1 → a3 ≠ 5 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 1 → a4 ≠ 5 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 1 → a5 ≠ 5 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![1, 5, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_2_0 : ∀ a2 : Fin 6, a2 ≠ 2 → a2 ≠ 0 →
    ∀ a3 : Fin 6, a3 ≠ 2 → a3 ≠ 0 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 2 → a4 ≠ 0 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 2 → a5 ≠ 0 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![2, 0, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_2_1 : ∀ a2 : Fin 6, a2 ≠ 2 → a2 ≠ 1 →
    ∀ a3 : Fin 6, a3 ≠ 2 → a3 ≠ 1 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 2 → a4 ≠ 1 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 2 → a5 ≠ 1 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![2, 1, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_2_3 : ∀ a2 : Fin 6, a2 ≠ 2 → a2 ≠ 3 →
    ∀ a3 : Fin 6, a3 ≠ 2 → a3 ≠ 3 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 2 → a4 ≠ 3 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 2 → a5 ≠ 3 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![2, 3, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_2_4 : ∀ a2 : Fin 6, a2 ≠ 2 → a2 ≠ 4 →
    ∀ a3 : Fin 6, a3 ≠ 2 → a3 ≠ 4 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 2 → a4 ≠ 4 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 2 → a5 ≠ 4 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![2, 4, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_2_5 : ∀ a2 : Fin 6, a2 ≠ 2 → a2 ≠ 5 →
    ∀ a3 : Fin 6, a3 ≠ 2 → a3 ≠ 5 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 2 → a4 ≠ 5 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 2 → a5 ≠ 5 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![2, 5, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_3_0 : ∀ a2 : Fin 6, a2 ≠ 3 → a2 ≠ 0 →
    ∀ a3 : Fin 6, a3 ≠ 3 → a3 ≠ 0 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 3 → a4 ≠ 0 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 3 → a5 ≠ 0 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![3, 0, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_3_1 : ∀ a2 : Fin 6, a2 ≠ 3 → a2 ≠ 1 →
    ∀ a3 : Fin 6, a3 ≠ 3 → a3 ≠ 1 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 3 → a4 ≠ 1 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 3 → a5 ≠ 1 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![3, 1, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_3_2 : ∀ a2 : Fin 6, a2 ≠ 3 → a2 ≠ 2 →
    ∀ a3 : Fin 6, a3 ≠ 3 → a3 ≠ 2 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 3 → a4 ≠ 2 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 3 → a5 ≠ 2 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![3, 2, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_3_4 : ∀ a2 : Fin 6, a2 ≠ 3 → a2 ≠ 4 →
    ∀ a3 : Fin 6, a3 ≠ 3 → a3 ≠ 4 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 3 → a4 ≠ 4 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 3 → a5 ≠ 4 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![3, 4, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_3_5 : ∀ a2 : Fin 6, a2 ≠ 3 → a2 ≠ 5 →
    ∀ a3 : Fin 6, a3 ≠ 3 → a3 ≠ 5 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 3 → a4 ≠ 5 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 3 → a5 ≠ 5 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![3, 5, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_4_0 : ∀ a2 : Fin 6, a2 ≠ 4 → a2 ≠ 0 →
    ∀ a3 : Fin 6, a3 ≠ 4 → a3 ≠ 0 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 4 → a4 ≠ 0 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 4 → a5 ≠ 0 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![4, 0, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_4_1 : ∀ a2 : Fin 6, a2 ≠ 4 → a2 ≠ 1 →
    ∀ a3 : Fin 6, a3 ≠ 4 → a3 ≠ 1 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 4 → a4 ≠ 1 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 4 → a5 ≠ 1 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![4, 1, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_4_2 : ∀ a2 : Fin 6, a2 ≠ 4 → a2 ≠ 2 →
    ∀ a3 : Fin 6, a3 ≠ 4 → a3 ≠ 2 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 4 → a4 ≠ 2 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 4 → a5 ≠ 2 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![4, 2, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_4_3 : ∀ a2 : Fin 6, a2 ≠ 4 → a2 ≠ 3 →
    ∀ a3 : Fin 6, a3 ≠ 4 → a3 ≠ 3 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 4 → a4 ≠ 3 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 4 → a5 ≠ 3 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![4, 3, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_4_5 : ∀ a2 : Fin 6, a2 ≠ 4 → a2 ≠ 5 →
    ∀ a3 : Fin 6, a3 ≠ 4 → a3 ≠ 5 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 4 → a4 ≠ 5 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 4 → a5 ≠ 5 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![4, 5, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_5_0 : ∀ a2 : Fin 6, a2 ≠ 5 → a2 ≠ 0 →
    ∀ a3 : Fin 6, a3 ≠ 5 → a3 ≠ 0 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 5 → a4 ≠ 0 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 5 → a5 ≠ 0 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![5, 0, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_5_1 : ∀ a2 : Fin 6, a2 ≠ 5 → a2 ≠ 1 →
    ∀ a3 : Fin 6, a3 ≠ 5 → a3 ≠ 1 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 5 → a4 ≠ 1 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 5 → a5 ≠ 1 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![5, 1, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_5_2 : ∀ a2 : Fin 6, a2 ≠ 5 → a2 ≠ 2 →
    ∀ a3 : Fin 6, a3 ≠ 5 → a3 ≠ 2 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 5 → a4 ≠ 2 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 5 → a5 ≠ 2 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![5, 2, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_5_3 : ∀ a2 : Fin 6, a2 ≠ 5 → a2 ≠ 3 →
    ∀ a3 : Fin 6, a3 ≠ 5 → a3 ≠ 3 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 5 → a4 ≠ 3 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 5 → a5 ≠ 3 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![5, 3, a2, a3, a4, a5] := by
  decide +kernel

private theorem core_5_4 : ∀ a2 : Fin 6, a2 ≠ 5 → a2 ≠ 4 →
    ∀ a3 : Fin 6, a3 ≠ 5 → a3 ≠ 4 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ 5 → a4 ≠ 4 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ 5 → a5 ≠ 4 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![5, 4, a2, a3, a4, a5] := by
  decide +kernel

/-- The kernel check over all 720 value tables of permutations of Fin 6, assembled from the chunks. -/
private theorem core (a0 a1 : Fin 6) (h10 : a1 ≠ a0) : ∀ a2 : Fin 6, a2 ≠ a0 → a2 ≠ a1 →
    ∀ a3 : Fin 6, a3 ≠ a0 → a3 ≠ a1 → a3 ≠ a2 →
    ∀ a4 : Fin 6, a4 ≠ a0 → a4 ≠ a1 → a4 ≠ a2 → a4 ≠ a3 →
    ∀ a5 : Fin 6, a5 ≠ a0 → a5 ≠ a1 → a5 ≠ a2 → a5 ≠ a3 → a5 ≠ a4 →
    autBoth ![a0, a1, a2, a3, a4, a5] := by
  fin_cases a0 <;> fin_cases a1 <;> first
    | exact absurd rfl h10
    | exact core_0_1
    | exact core_0_2
    | exact core_0_3
    | exact core_0_4
    | exact core_0_5
    | exact core_1_0
    | exact core_1_2
    | exact core_1_3
    | exact core_1_4
    | exact core_1_5
    | exact core_2_0
    | exact core_2_1
    | exact core_2_3
    | exact core_2_4
    | exact core_2_5
    | exact core_3_0
    | exact core_3_1
    | exact core_3_2
    | exact core_3_4
    | exact core_3_5
    | exact core_4_0
    | exact core_4_1
    | exact core_4_2
    | exact core_4_3
    | exact core_4_5
    | exact core_5_0
    | exact core_5_1
    | exact core_5_2
    | exact core_5_3
    | exact core_5_4

private theorem core_perm (σ : Equiv.Perm (Fin 6)) : autBoth ![σ 0, σ 1, σ 2, σ 3, σ 4, σ 5] :=
  core (σ 0) (σ 1) (σ.injective.ne (by decide))
    (σ 2) (σ.injective.ne (by decide)) (σ.injective.ne (by decide))
    (σ 3) (σ.injective.ne (by decide)) (σ.injective.ne (by decide)) (σ.injective.ne (by decide))
    (σ 4) (σ.injective.ne (by decide)) (σ.injective.ne (by decide)) (σ.injective.ne (by decide))
      (σ.injective.ne (by decide))
    (σ 5) (σ.injective.ne (by decide)) (σ.injective.ne (by decide)) (σ.injective.ne (by decide))
      (σ.injective.ne (by decide)) (σ.injective.ne (by decide))

private theorem sign_eq_sgnF (σ : Equiv.Perm (Fin 6)) : Equiv.Perm.sign σ = sgnF σ := by
  show Equiv.Perm.sign σ = Equiv.Perm.signAux σ
  refine Equiv.Perm.swap_induction_on σ (by simp) ?_
  intro f x y hxy ih
  rw [Equiv.Perm.sign_mul, Equiv.Perm.signAux_mul, ih, Equiv.Perm.sign_swap hxy,
    Equiv.Perm.signAux_swap hxy]

private theorem mulT_ne_zero : ∀ a b : F4, a ≠ 0 → b ≠ 0 → mulT a b ≠ 0 := by decide
private theorem mulT_invT : ∀ a b : F4, b ≠ 0 → mulT (mulT a b) (invT b) = a := by decide
private theorem u6_ne_zero : ∀ j, u6 j ≠ 0 := by decide
private theorem u6_mem : u6 ∈ HCurtis := by decide +kernel
private theorem GCurtis_mem : ∀ i, GCurtis i ∈ HCurtis := by decide +kernel

private theorem mem_of_aut {σ : Equiv.Perm (Fin 6)} {d : Fin 6 → F4}
    (h : remap σ (scale d HCurtis) = HCurtis) {v : Word} (hv : v ∈ HCurtis) :
    (fun j => mulT (d (σ j)) (v (σ j))) ∈ HCurtis := by
  rw [← h]
  exact Finset.mem_image.2 ⟨_, Finset.mem_image.2 ⟨v, hv, rfl⟩, rfl⟩

private theorem inHP_of_mem {w : Word} (hw : w ∈ HCurtis) : inHP w :=
  fun j => congrFun ((mem_HCurtis w).1 hw) j

/-- T13. Parities: c2b odd, i2c odd, i2b even. -/
theorem sign_c2b : Equiv.Perm.sign c2b = -1 := by
  decide
theorem sign_i2c : Equiv.Perm.sign i2c = -1 := by
  decide
theorem sign_i2b : Equiv.Perm.sign i2b = 1 := by
  decide

/-- T14a. map_Curtis(REC) = H_Curtis. -/
theorem remap_i2c_REC : remap i2c REC = HCurtis := by
  decide +kernel
/-- T14b. map_bridge(REC) = H_bridge. -/
theorem remap_i2b_REC : remap i2b REC = HBridge := by
  decide +kernel

/-- T15a. H_bridge is in REC's chiral class (σ = i2b, d = 1). -/
theorem HBridge_mem_evenClass_REC : HBridge ∈ evenClass REC := by
  refine ⟨i2b, sign_i2b, fun _ => 1, fun _ => (by decide : (1 : F4) ≠ 0), ?_⟩
  decide +kernel
/-- T15b. H_Curtis is in conj(REC)'s chiral class. Witness found by script: σ = identity, d = (1,1,1,1,ω²,ω). -/
theorem HCurtis_mem_evenClass_conj_REC : HCurtis ∈ evenClass (conj REC) := by
  refine ⟨1, Equiv.Perm.sign_one, ![1, 1, 1, 1, 3, 2], by decide, ?_⟩
  decide +kernel

/-! ### 3b: core results (T16–T18), proved by kernel check -/

/-- T16 (core). Every monomial automorphism of H_Curtis has an even permutation part. -/
theorem aut_HCurtis_even (σ : Equiv.Perm (Fin 6)) (d : Fin 6 → F4) (hd : ∀ j, d j ≠ 0)
    (h : remap σ (scale d HCurtis) = HCurtis) : Equiv.Perm.sign σ = 1 := by
  obtain ⟨u', hu'⟩ : ∃ u' : Word, u' = fun j => mulT (d (σ j)) (u6 (σ j)) := ⟨_, rfl⟩
  have hmem : u' ∈ HCurtis := hu' ▸ mem_of_aut h u6_mem
  have hw : comb3 GCurtis ![u' 0, u' 1, u' 2] = u' := ((mem_HCurtis u').1 hmem).symm
  have hcore := (core_perm σ).1 (u' 0) (u' 1) (u' 2)
  have hf : ![σ 0, σ 1, σ 2, σ 3, σ 4, σ 5] = ⇑σ := by funext j; fin_cases j <;> rfl
  rw [hf, hw] at hcore
  have he : (fun j => mulT (u' j) (invT (u6 (σ j)))) = fun j => d (σ j) := by
    funext j; rw [hu']; exact mulT_invT _ _ (u6_ne_zero _)
  have hrow : ∀ i, inHP (rowImg σ (fun j => mulT (u' j) (invT (u6 (σ j)))) i) := by
    intro i
    rw [he]
    exact inHP_of_mem (mem_of_aut h (GCurtis_mem i))
  rw [sign_eq_sgnF]
  refine hcore (fun j => ?_) hrow
  rw [hu']
  exact mulT_ne_zero _ _ (hd _) (u6_ne_zero _)

/-- T17a. The two chiral classes are different: H_bridge is not in H_Curtis's class. -/
theorem HBridge_not_mem_evenClass_HCurtis : HBridge ∉ evenClass HCurtis := by
  rintro ⟨σ, hσ, d, hd, h⟩
  have key : remap ⇑(σ * c2b⁻¹) (scale d HCurtis) = HCurtis := by
    rw [Equiv.Perm.coe_mul, ← remap_comp, ← h, HBridge, remap_comp, ← Equiv.Perm.coe_mul,
      mul_inv_cancel, Equiv.Perm.coe_one, remap_id]
  have := aut_HCurtis_even _ d hd key
  rw [Equiv.Perm.sign_mul, Equiv.Perm.sign_inv, hσ, sign_c2b] at this
  have h2 := congrArg Units.val this
  norm_num at h2
/-- T17b. Hence H_Curtis is not in REC's chiral class (REC is in the bridge class, not the Curtis class). -/
theorem HCurtis_not_mem_evenClass_REC : HCurtis ∉ evenClass REC := by
  rintro ⟨σ, hσ, d, hd, h⟩
  have hR : REC = remap ⇑(i2c⁻¹) HCurtis := by
    rw [← remap_i2c_REC, remap_comp, ← Equiv.Perm.coe_mul, mul_inv_cancel, Equiv.Perm.coe_one,
      remap_id]
  rw [hR, scale_remap, remap_comp, ← Equiv.Perm.coe_mul] at h
  have := aut_HCurtis_even _ _ (fun j => hd _) h.symm
  rw [Equiv.Perm.sign_mul, Equiv.Perm.sign_inv, hσ, sign_i2c] at this
  have h2 := congrArg Units.val this
  norm_num at h2

/-! ### Proof helpers for T18 (builder; not part of the frozen statements) -/

private theorem mem_HCurtis' (w : Word) : w ∈ HCurtis ↔ ∃ a b c : F4, w = comb3 GCurtis ![a, b, c] := by
  constructor
  · intro hw; exact ⟨_, _, _, (mem_HCurtis w).1 hw⟩
  · rintro ⟨a, b, c, rfl⟩
    exact Finset.mem_image.2 ⟨_, Finset.mem_univ _, rfl⟩

private theorem addT_comb3 : ∀ a b c a' b' c' : F4, ∀ j : Fin 6,
    addT (comb3 GCurtis ![a, b, c] j) (comb3 GCurtis ![a', b', c'] j) =
      comb3 GCurtis ![addT a a', addT b b', addT c c'] j := by
  decide +kernel

private theorem mulT_comb3 : ∀ l a b c : F4, ∀ j : Fin 6,
    mulT l (comb3 GCurtis ![a, b, c] j) = comb3 GCurtis ![mulT l a, mulT l b, mulT l c] j := by
  decide +kernel

private theorem add_mem {u v : Word} (hu : u ∈ HCurtis) (hv : v ∈ HCurtis) :
    (fun j => addT (u j) (v j)) ∈ HCurtis := by
  obtain ⟨a, b, c, rfl⟩ := (mem_HCurtis' u).1 hu
  obtain ⟨a', b', c', rfl⟩ := (mem_HCurtis' v).1 hv
  exact (mem_HCurtis' _).2 ⟨_, _, _, funext fun j => addT_comb3 a b c a' b' c' j⟩

private theorem smul_mem (l : F4) {u : Word} (hu : u ∈ HCurtis) :
    (fun j => mulT l (u j)) ∈ HCurtis := by
  obtain ⟨a, b, c, rfl⟩ := (mem_HCurtis' u).1 hu
  exact (mem_HCurtis' _).2 ⟨_, _, _, funext fun j => mulT_comb3 l a b c j⟩

private theorem comb3_mem (R : Fin 3 → Word) (hR : ∀ i, R i ∈ HCurtis) (c : Fin 3 → F4) :
    comb3 R c ∈ HCurtis :=
  add_mem (add_mem (smul_mem (c 0) (hR 0)) (smul_mem (c 1) (hR 1))) (smul_mem (c 2) (hR 2))

private theorem distr7 : ∀ e a b c g0 g1 g2 : F4,
    mulT e (addT (addT (mulT a g0) (mulT b g1)) (mulT c g2)) =
      addT (addT (mulT a (mulT e g0)) (mulT b (mulT e g1))) (mulT c (mulT e g2)) := by
  decide +kernel

private theorem image_sub_of_rows (f : Fin 6 → Fin 6) (e : Fin 6 → F4)
    (hrows : ∀ i, rowImg f e i ∈ HCurtis) {w : Word} (hw : w ∈ HCurtis) :
    (fun j => mulT (e j) (w (f j))) ∈ HCurtis := by
  obtain ⟨a, b, c, rfl⟩ := (mem_HCurtis' w).1 hw
  have : (fun j => mulT (e j) (comb3 GCurtis ![a, b, c] (f j))) = comb3 (rowImg f e) ![a, b, c] :=
    funext fun j => distr7 (e j) a b c (GCurtis 0 (f j)) (GCurtis 1 (f j)) (GCurtis 2 (f j))
  rw [this]
  exact comb3_mem _ hrows _

private theorem mulT_cancel : ∀ a x y : F4, a ≠ 0 → mulT a x = mulT a y → x = y := by decide
private theorem mulT_assoc' : ∀ a b c : F4, mulT a (mulT b c) = mulT (mulT a b) c := by decide
private theorem one_mulT : ∀ a : F4, mulT 1 a = a := by decide
private theorem invT_ne_zero : ∀ b : F4, b ≠ 0 → invT b ≠ 0 := by decide
private theorem invT_mulT : ∀ b : F4, b ≠ 0 → mulT (invT b) b = 1 := by decide
private theorem mulT_invT_self : ∀ b : F4, b ≠ 0 → mulT b (invT b) = 1 := by decide
private theorem invT_eq : ∀ a b : F4, b ≠ 0 → mulT (invT b) a = 1 → a = b := by decide

/-- Rows criterion: if the three generator rows map into H_Curtis, the monomial map is an automorphism. -/
private theorem aut_of_rows (σ : Equiv.Perm (Fin 6)) (e : Fin 6 → F4) (he : ∀ j, e j ≠ 0)
    (hrows : ∀ i, rowImg σ e i ∈ HCurtis) : scale e (remap σ HCurtis) = HCurtis := by
  have himg : scale e (remap σ HCurtis) = HCurtis.image (fun w j => mulT (e j) (w (σ j))) := by
    unfold scale remap; rw [Finset.image_image]; rfl
  rw [himg]
  apply Finset.eq_of_subset_of_card_le
  · intro v hv
    obtain ⟨w, hw, rfl⟩ := Finset.mem_image.1 hv
    exact image_sub_of_rows σ e hrows hw
  · have hinj : Function.Injective (fun (w : Word) j => mulT (e j) (w (σ j))) := by
      intro w w' hww
      funext k
      have := congrFun hww (σ⁻¹ k)
      have hk : σ (σ⁻¹ k) = k := σ.apply_symm_apply k
      simp only [hk] at this
      exact mulT_cancel _ _ _ (he _) this
    rw [Finset.card_image_of_injective _ hinj]

private theorem scale_scale (d d' : Fin 6 → F4) (C : Finset Word) :
    scale d (scale d' C) = scale (fun j => mulT (d j) (d' j)) C := by
  unfold scale; rw [Finset.image_image]
  congr 1; funext w j; exact mulT_assoc' _ _ _

private theorem scale_one' (C : Finset Word) : scale (fun _ => 1) C = C := by
  unfold scale
  have : (fun (w : Word) (j : Fin 6) => mulT ((fun _ => (1 : F4)) j) (w j)) = id := by
    funext w j; exact one_mulT _
  rw [this, Finset.image_id]

private theorem remap_scale (σ : Fin 6 → Fin 6) (d : Fin 6 → F4) (C : Finset Word) :
    remap σ (scale d C) = scale (fun j => d (σ j)) (remap σ C) := by
  unfold remap scale; rw [Finset.image_image, Finset.image_image]; rfl

private theorem scale_const : ∀ l : F4, l ≠ 0 → scale (fun _ => l) HCurtis = HCurtis := by
  decide +kernel

/-- Every even permutation of the coordinates is realized on H_Curtis by a rescaling. -/
private theorem even_realized (σ : Equiv.Perm (Fin 6)) (hσ : Equiv.Perm.sign σ = 1) :
    ∃ g : Fin 6 → F4, (∀ j, g j ≠ 0) ∧ remap σ HCurtis = scale g HCurtis := by
  have hc := (core_perm σ).2
  have hf : ![σ 0, σ 1, σ 2, σ 3, σ 4, σ 5] = ⇑σ := by funext j; fin_cases j <;> rfl
  rw [hf] at hc
  have hs : sgnF σ = 1 := by rw [← sign_eq_sgnF]; exact hσ
  obtain ⟨x, y, z, hnz, hrows⟩ := hc hs
  obtain ⟨e, he_def⟩ : ∃ e : Fin 6 → F4,
      e = fun j => mulT (comb3 GCurtis ![x, y, z] j) (invT (u6 (σ j))) := ⟨_, rfl⟩
  rw [← he_def] at hrows
  have he : ∀ j, e j ≠ 0 := by
    intro j; rw [he_def]; exact mulT_ne_zero _ _ (hnz j) (invT_ne_zero _ (u6_ne_zero _))
  have haut := aut_of_rows σ e he (fun i => (mem_HCurtis _).2 (funext (hrows i)))
  refine ⟨fun j => invT (e j), fun j => invT_ne_zero _ (he j), ?_⟩
  conv_rhs => rw [← haut]
  rw [scale_scale]
  have : (fun j => mulT (invT (e j)) (e j)) = fun _ => (1 : F4) :=
    funext fun j => invT_mulT _ (he j)
  rw [this, scale_one']

/-- Normalized scalings: first entry 1, all entries nonzero. -/
private def Enorm : Finset (Fin 6 → F4) := Finset.univ.filter fun e => e 0 = 1 ∧ ∀ j, e j ≠ 0

private theorem Enorm_card : Enorm.card = 243 := by decide +kernel

private theorem scale_normalize (e : Fin 6 → F4) (he : ∀ j, e j ≠ 0) :
    scale e HCurtis = scale (fun j => mulT (e j) (invT (e 0))) HCurtis := by
  conv_lhs => rw [← scale_const (invT (e 0)) (invT_ne_zero _ (he 0))]
  rw [scale_scale]

/-- Kernel check: a diagonal automorphism with first entry 1 is the identity. -/
private theorem diag_aut : ∀ q1 q2 q3 q4 q5 : F4, q1 ≠ 0 → q2 ≠ 0 → q3 ≠ 0 → q4 ≠ 0 → q5 ≠ 0 →
    (∀ i : Fin 3, inHP (rowImg id ![1, q1, q2, q3, q4, q5] i)) →
    q1 = 1 ∧ q2 = 1 ∧ q3 = 1 ∧ q4 = 1 ∧ q5 = 1 := by
  decide +kernel

private theorem scale_inj (e e' : Fin 6 → F4) (he : e ∈ Enorm) (he' : e' ∈ Enorm)
    (h : scale e HCurtis = scale e' HCurtis) : e = e' := by
  simp only [Enorm, Finset.mem_filter, Finset.mem_univ, true_and] at he he'
  obtain ⟨h0, hnz⟩ := he
  obtain ⟨h0', hnz'⟩ := he'
  obtain ⟨q, hq_def⟩ : ∃ q : Fin 6 → F4, q = fun j => mulT (invT (e' j)) (e j) := ⟨_, rfl⟩
  have hq : scale q HCurtis = HCurtis := by
    have := congrArg (scale fun j => invT (e' j)) h
    simp only [scale_scale] at this
    have h1 : (fun j => mulT (invT (e' j)) (e' j)) = fun _ => (1 : F4) :=
      funext fun j => invT_mulT _ (hnz' j)
    rw [h1, scale_one', ← hq_def] at this
    exact this
  have hrows : ∀ i, inHP (rowImg id q i) := fun i => inHP_of_mem (by
    rw [← hq]; exact Finset.mem_image.2 ⟨GCurtis i, GCurtis_mem i, rfl⟩)
  have hqnz : ∀ j, q j ≠ 0 := by
    intro j; rw [hq_def]; exact mulT_ne_zero _ _ (invT_ne_zero _ (hnz' j)) (hnz j)
  have hq0 : q 0 = 1 := by rw [hq_def]; simp only [h0, h0']; decide
  have hqf : q = ![1, q 1, q 2, q 3, q 4, q 5] := by
    funext j; fin_cases j
    exacts [hq0, rfl, rfl, rfl, rfl, rfl]
  rw [hqf] at hrows
  obtain ⟨h1, h2, h3, h4, h5⟩ :=
    diag_aut (q 1) (q 2) (q 3) (q 4) (q 5) (hqnz 1) (hqnz 2) (hqnz 3) (hqnz 4) (hqnz 5) hrows
  have hall : ∀ j, q j = 1 := by
    intro j; fin_cases j
    exacts [hq0, h1, h2, h3, h4, h5]
  funext j
  have := hall j
  simp only [hq_def] at this
  exact invT_eq _ _ (hnz' j) this

/-- T18 (optional). Each chiral class has 243 codes. -/
theorem evenClass_HCurtis_ncard : (evenClass HCurtis).ncard = 243 := by
  have hset : evenClass HCurtis = ↑(Enorm.image fun e => scale e HCurtis) := by
    ext D
    simp only [evenClass, Set.mem_ofPred_eq, Finset.coe_image, Set.mem_image, Finset.mem_coe]
    constructor
    · rintro ⟨σ, hσ, d, hd, rfl⟩
      obtain ⟨g, hg, hgσ⟩ := even_realized σ hσ
      rw [remap_scale, hgσ, scale_scale]
      have hnz : ∀ j, mulT (d (σ j)) (g j) ≠ 0 := fun j => mulT_ne_zero _ _ (hd _) (hg j)
      refine ⟨fun j => mulT (mulT (d (σ j)) (g j)) (invT (mulT (d (σ 0)) (g 0))), ?_,
        (scale_normalize _ hnz).symm⟩
      simp only [Enorm, Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨mulT_invT_self _ (hnz 0),
        fun j => mulT_ne_zero _ _ (hnz j) (invT_ne_zero _ (hnz 0))⟩
    · rintro ⟨e, he, rfl⟩
      simp only [Enorm, Finset.mem_filter, Finset.mem_univ, true_and] at he
      refine ⟨1, Equiv.Perm.sign_one, e, he.2, ?_⟩
      rw [Equiv.Perm.coe_one, remap_id]
  rw [hset, Set.ncard_coe_finset, Finset.card_image_of_injOn, Enorm_card]
  intro e he e' he' h
  exact scale_inj e e' he he' h

end FVLT.GolayWalkHolonomyV1
