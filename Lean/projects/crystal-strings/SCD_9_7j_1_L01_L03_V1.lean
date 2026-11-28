/-
  Rmk 9.7j.1 (symmetric chains of Div(N)) -- Lean check L-01..L-03, v0.1 (2026-11-03).
  Spec: SCD_9_7j_1_CHECK_SPEC_v0_1.md (sha256 77b92839...), section 0 conventions.
  Core Lean 4 only (no imports). Builder: Claude Opus 5.5.

  Conventions (spec section 0):
  * A divisor of N = p_1^a_1 ... p_m^a_m (p_1 < ... < p_m) is its exponent vector
    e = [e_1, ..., e_m] : List Nat with 0 <= e_i <= a_i; the profile is ex = [a_1, ..., a_m].
  * The word of e is the concatenation, over i ascending, of 1^e_i 0^(a_i - e_i).
    A letter is (block index i, bit) with bit true = 1 = ")" and false = 0 = "(".
  * Each 1 pairs with the nearest unpaired 0 to its left (left-to-right stack scan).
  * raise (E~) flips the leftmost unpaired 0 (e_i += 1 for its block i); none if no unpaired 0.
  * lower (F~) flips the rightmost unpaired 1 (e_i -= 1 for its block i); none if no unpaired 1.
  * A string starts at e with lower = none and applies raise until raise = none.
-/
namespace SCD97j1

/-- Sum of a list of naturals (Omega of an exponent vector; Omega_max of a profile). -/
def sumL : List Nat → Nat
  | [] => 0
  | x :: xs => x + sumL xs

/-- Word blocks from block index `i` on: 1^e_i 0^(a_i - e_i), ascending. -/
def wordAux : Nat → List Nat → List Nat → List (Nat × Bool)
  | i, a :: as, e :: es =>
      List.replicate e (i, true) ++ List.replicate (a - e) (i, false) ++ wordAux (i + 1) as es
  | _, _, _ => []

def word (ex e : List Nat) : List (Nat × Bool) := wordAux 0 ex e

/-- Left-to-right bracket scan. `st` holds the unpaired 0s seen so far, most recent first
    (as (position, block)); `u1` holds the unpaired 1s, most recent first. A 1 pairs with the
    top of `st`, which is the nearest unpaired 0 to its left; with `st` empty it stays unpaired.
    Result: (unpaired 1s, unpaired 0s), each in ascending position order. -/
def scan : List (Nat × Bool) → Nat → List (Nat × Nat) → List (Nat × Nat) →
    List (Nat × Nat) × List (Nat × Nat)
  | [], _, st, u1 => (u1.reverse, st.reverse)
  | (b, false) :: w, k, st, u1 => scan w (k + 1) ((k, b) :: st) u1
  | (b, true) :: w, k, st, u1 =>
      match st with
      | _ :: st' => scan w (k + 1) st' u1
      | [] => scan w (k + 1) [] ((k, b) :: u1)

/-- (positions-with-blocks of unpaired 1s, of unpaired 0s), both ascending. -/
def unpaired (w : List (Nat × Bool)) : List (Nat × Nat) × List (Nat × Nat) := scan w 0 [] []

def incAt : Nat → List Nat → List Nat
  | _, [] => []
  | 0, x :: xs => (x + 1) :: xs
  | i + 1, x :: xs => x :: incAt i xs

def decAt : Nat → List Nat → List Nat
  | _, [] => []
  | 0, x :: xs => (x - 1) :: xs
  | i + 1, x :: xs => x :: decAt i xs

/-- E~ : flip the leftmost unpaired 0 (multiply by that block's prime). -/
def raise (ex e : List Nat) : Option (List Nat) :=
  match (unpaired (word ex e)).2 with
  | [] => none
  | (_, b) :: _ => some (incAt b e)

/-- F~ : flip the rightmost unpaired 1 (divide by that block's prime). -/
def lower (ex e : List Nat) : Option (List Nat) :=
  match (unpaired (word ex e)).1.reverse with
  | [] => none
  | (_, b) :: _ => some (decAt b e)

/-- All exponent vectors 0 <= e_i <= a_i (the divisors of N), lexicographic order. -/
def divs : List Nat → List (List Nat)
  | [] => [[]]
  | a :: as =>
      let r := divs as
      (List.range (a + 1)).flatMap (fun x => r.map (fun t => x :: t))

/-- Apply raise repeatedly from `e`, with fuel. -/
def climb (ex : List Nat) : Nat → List Nat → List (List Nat)
  | 0, e => [e]
  | n + 1, e =>
      e :: (match raise ex e with
            | none => []
            | some e' => climb ex n e')

/-- The strings: start at every divisor with lower = none, raise until undefined.
    Fuel Omega_max is enough when the C2 check holds; the check `tops_closed` below
    verifies that every string ends where raise is undefined, so fuel never truncates. -/
def strings (ex : List Nat) : List (List (List Nat)) :=
  ((divs ex).filter (fun e => (lower ex e).isNone)).map (climb ex (sumL ex))

/-- `stepUp a b`: b is a with exactly one coordinate raised by 1 (all others equal). -/
def stepUp : List Nat → List Nat → Bool
  | x :: xs, y :: ys => (y == x + 1 && xs == ys) || (y == x && stepUp xs ys)
  | _, _ => false

/-- W_r = number of divisors of rank r. -/
def W (ex : List Nat) (r : Nat) : Nat := (divs ex).countP (fun d => decide (sumL d = r))

/-- Number of strings whose bottom has rank r. -/
def starts (ex : List Nat) (r : Nat) : Nat :=
  (strings ex).countP (fun s => decide (sumL (s.headD []) = r))

/-- Divisor value of an exponent vector over the given primes. -/
def val : List Nat → List Nat → Nat
  | p :: ps, e :: es => p ^ e * val ps es
  | _, _ => 1

/-! ### Check predicates (Prop, decidable) -/

/-- C1, half 1: whenever raise e = some e', lower e' = some e. -/
abbrev C1a (ex : List Nat) : Prop :=
  ∀ e ∈ divs ex, ∀ e' ∈ (raise ex e).toList, lower ex e' = some e
/-- C1, half 2: whenever lower e' = some e, raise e = some e'. -/
abbrev C1b (ex : List Nat) : Prop :=
  ∀ e' ∈ divs ex, ∀ e ∈ (lower ex e').toList, raise ex e = some e'
/-- C1 as stated: E~ and F~ are inverse partial maps on Div(N). -/
abbrev C1 (ex : List Nat) : Prop :=
  ∀ e ∈ divs ex, ∀ e' ∈ divs ex, (raise ex e = some e' ↔ lower ex e' = some e)

/-- Strings are well formed: nonempty, start where lower is undefined, end where raise is
    undefined (so the fuel did not truncate), and consecutive entries are raise steps. -/
abbrev WellFormed (ex : List Nat) : Prop :=
  ∀ s ∈ strings ex, s ≠ [] ∧ lower ex (s.headD []) = none ∧ raise ex (s.getLastD []) = none ∧
    ∀ p ∈ s.zip s.tail, raise ex p.1 = some p.2

/-- C2: each step raises exactly one exponent by 1. -/
abbrev C2 (ex : List Nat) : Prop :=
  ∀ s ∈ strings ex, ∀ p ∈ s.zip s.tail, stepUp p.1 p.2 = true

/-- C3: Omega(bottom) + Omega(top) = Omega_max. -/
abbrev C3 (ex : List Nat) : Prop :=
  ∀ s ∈ strings ex, sumL (s.headD []) + sumL (s.getLastD []) = sumL ex

/-- C4: every divisor lies in exactly one string, and strings contain only divisors. -/
abbrev C4 (ex : List Nat) : Prop :=
  (∀ d ∈ divs ex, (strings ex).countP (fun s => decide (d ∈ s)) = 1) ∧
  (∀ s ∈ strings ex, ∀ d ∈ s, d ∈ divs ex)

/-- C5: #strings starting at rank r = W_r - W_{r-1} (W_{-1} = 0) if 2r <= Omega_max, else 0.
    Stated without truncated subtraction: starts r + W_{r-1} = W_r. -/
abbrev C5 (ex : List Nat) : Prop :=
  ∀ r ∈ List.range (sumL ex + 1),
    if 2 * r ≤ sumL ex then starts ex r + (if r = 0 then 0 else W ex (r - 1)) = W ex r
    else starts ex r = 0

/-- C6: #strings = W_{floor(Omega_max / 2)}. -/
abbrev C6 (ex : List Nat) : Prop :=
  (strings ex).length = W ex (sumL ex / 2)

/-- From the two decidable halves to the stated C1 (general, proved by hand). -/
theorem C1_of_halves (ex : List Nat) (ha : C1a ex) (hb : C1b ex) : C1 ex := by
  intro e he e' he'
  constructor
  · intro h
    exact ha e he e' (by simp [h])
  · intro h
    exact hb e' he' e (by simp [h])

/-- stepUp raises the rank by exactly 1 (general). -/
theorem stepUp_sum : ∀ a b : List Nat, stepUp a b = true → sumL b = sumL a + 1
  | [], _, h => by simp [stepUp] at h
  | _ :: _, [], h => by simp [stepUp] at h
  | x :: xs, y :: ys, h => by
      simp only [stepUp, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at h
      rcases h with ⟨h1, h2⟩ | ⟨h1, h2⟩
      · subst h1; subst h2; simp [sumL]; omega
      · subst h1; have := stepUp_sum xs ys h2; simp [sumL, this]; omega

end SCD97j1

namespace SCD97j1
/-! ### L-02 (partial): general rank statements for raise and lower, every profile -/

theorem wordAux_mem : ∀ (ex e : List Nat) (i b : Nat) (x : Bool),
    (b, x) ∈ wordAux i ex e → i ≤ b ∧ b < i + e.length
  | a :: as, y :: ys, i, b, x, h => by
      simp only [wordAux, List.mem_append, List.mem_replicate, Prod.mk.injEq] at h
      rcases h with (⟨_, rfl, _⟩ | ⟨_, rfl, _⟩) | h
      · simp
      · simp
      · have := wordAux_mem as ys (i + 1) b x h
        simp only [List.length_cons]; omega
  | [], _, i, b, x, h => by simp [wordAux] at h
  | _ :: _, [], i, b, x, h => by simp [wordAux] at h

/-- A letter 1 of block b sits in a block with e_b >= 1. -/
theorem wordAux_mem_true : ∀ (ex e : List Nat) (i b : Nat),
    (b, true) ∈ wordAux i ex e → i ≤ b ∧ 1 ≤ e.getD (b - i) 0
  | a :: as, y :: ys, i, b, h => by
      simp only [wordAux, List.mem_append, List.mem_replicate, Prod.mk.injEq] at h
      rcases h with (⟨hy, rfl, _⟩ | ⟨_, _, h⟩) | h
      · simp; omega
      · cases h
      · have ih := wordAux_mem_true as ys (i + 1) b h
        have hb : b - i = (b - (i + 1)) + 1 := by omega
        refine ⟨by omega, ?_⟩
        rw [hb]; simpa using ih.2
  | [], _, i, b, h => by simp [wordAux] at h
  | _ :: _, [], i, b, h => by simp [wordAux] at h

/-- Every entry of the scan output comes from the initial stacks or from a letter of the word;
    unpaired 1s come from letters 1. -/
theorem scan_mem : ∀ (w : List (Nat × Bool)) (k : Nat) (st u1 : List (Nat × Nat)) (p : Nat × Nat),
    (p ∈ (scan w k st u1).1 → p ∈ u1 ∨ (p.2, true) ∈ w) ∧
    (p ∈ (scan w k st u1).2 → p ∈ st ∨ ∃ x, (p.2, x) ∈ w)
  | [], k, st, u1, p => by simp [scan]
  | (b, false) :: w, k, st, u1, p => by
      have ih := scan_mem w (k + 1) ((k, b) :: st) u1 p
      simp only [scan]
      constructor
      · intro h
        rcases ih.1 h with h1 | h1
        · exact Or.inl h1
        · exact Or.inr (by simp [h1])
      · intro h
        rcases ih.2 h with h1 | ⟨x, hx⟩
        · simp only [List.mem_cons] at h1
          rcases h1 with rfl | h1
          · exact Or.inr ⟨false, by simp⟩
          · exact Or.inl h1
        · exact Or.inr ⟨x, by simp [hx]⟩
  | (b, true) :: w, k, st, u1, p => by
      cases st with
      | cons q st' =>
          have ih := scan_mem w (k + 1) st' u1 p
          simp only [scan]
          constructor
          · intro h
            rcases ih.1 h with h1 | h1
            · exact Or.inl h1
            · exact Or.inr (by simp [h1])
          · intro h
            rcases ih.2 h with h1 | ⟨x, hx⟩
            · exact Or.inl (by simp [h1])
            · exact Or.inr ⟨x, by simp [hx]⟩
      | nil =>
          have ih := scan_mem w (k + 1) [] ((k, b) :: u1) p
          simp only [scan]
          constructor
          · intro h
            rcases ih.1 h with h1 | h1
            · simp only [List.mem_cons] at h1
              rcases h1 with rfl | h1
              · exact Or.inr (by simp)
              · exact Or.inl h1
            · exact Or.inr (by simp [h1])
          · intro h
            rcases ih.2 h with h1 | ⟨x, hx⟩
            · simp at h1
            · exact Or.inr ⟨x, by simp [hx]⟩

theorem incAt_stepUp : ∀ (b : Nat) (e : List Nat), b < e.length → stepUp e (incAt b e) = true
  | _, [], h => by simp at h
  | 0, x :: xs, _ => by simp [incAt, stepUp]
  | b + 1, x :: xs, h => by
      have ih := incAt_stepUp b xs (by simp at h; omega)
      simp [incAt, stepUp, ih]

theorem decAt_stepUp : ∀ (b : Nat) (e : List Nat), 1 ≤ e.getD b 0 → b < e.length →
    stepUp (decAt b e) e = true
  | _, [], _, h => by simp at h
  | 0, x :: xs, h1, _ => by
      simp at h1
      simp [decAt, stepUp]; omega
  | b + 1, x :: xs, h1, h => by
      have ih := decAt_stepUp b xs (by simpa using h1) (by simp at h; omega)
      simp [decAt, stepUp, ih]

/-- L-02 (raise_succ_rank): raise adds 1 to exactly one coordinate, so the rank rises by 1.
    Holds for every profile and every vector. -/
theorem raise_succ_rank (ex e e' : List Nat) (h : raise ex e = some e') :
    stepUp e e' = true ∧ sumL e' = sumL e + 1 := by
  unfold raise at h
  split at h
  · cases h
  · rename_i k b rest heq
    cases h
    have hm : (k, b) ∈ (unpaired (word ex e)).2 := by rw [heq]; simp
    rcases (scan_mem (word ex e) 0 [] [] (k, b)).2 hm with h0 | ⟨x, hx⟩
    · simp at h0
    · have hb := wordAux_mem ex e 0 b x hx
      have hs := incAt_stepUp b e (by omega)
      exact ⟨hs, stepUp_sum _ _ hs⟩

/-- L-02 (lower counterpart): lower subtracts 1 from exactly one coordinate. -/
theorem lower_pred_rank (ex e e' : List Nat) (h : lower ex e = some e') :
    stepUp e' e = true ∧ sumL e = sumL e' + 1 := by
  unfold lower at h
  split at h
  · cases h
  · rename_i k b rest heq
    cases h
    have hm : (k, b) ∈ (unpaired (word ex e)).1 := by
      rw [← List.mem_reverse, heq]; simp
    rcases (scan_mem (word ex e) 0 [] [] (k, b)).1 hm with h0 | hx
    · simp at h0
    · have hb := wordAux_mem ex e 0 b true hx
      have h1 := wordAux_mem_true ex e 0 b hx
      simp only [Nat.sub_zero] at h1
      have hs := decAt_stepUp b e h1.2 (by omega)
      exact ⟨hs, stepUp_sum _ _ hs⟩

#print axioms wordAux_mem
#print axioms wordAux_mem_true
#print axioms scan_mem
#print axioms incAt_stepUp
#print axioms decAt_stepUp
#print axioms raise_succ_rank
#print axioms lower_pred_rank
#print axioms stepUp_sum
#print axioms C1_of_halves
end SCD97j1

namespace SCD97j1
/-! ### N = 720 = 2^4 * 3^2 * 5^1, profile [4,2,1] (ascending primes) -/
theorem N720_factorisation : 720 = 2^4 * 3^2 * 5^1 := by decide
theorem N720_C1a : C1a [4,2,1] := by decide
theorem N720_C1b : C1b [4,2,1] := by decide
theorem N720_C1 : C1 [4,2,1] := C1_of_halves _ N720_C1a N720_C1b
theorem N720_wellFormed : WellFormed [4,2,1] := by decide
theorem N720_C2 : C2 [4,2,1] := by decide
theorem N720_C3 : C3 [4,2,1] := by decide
theorem N720_C4 : C4 [4,2,1] := by decide
theorem N720_C5 : C5 [4,2,1] := by decide
theorem N720_C6 : C6 [4,2,1] := by decide
theorem N720_W : (List.range (sumL [4,2,1] + 1)).map (W [4,2,1]) = [1,3,5,6,6,5,3,1] := by decide
theorem N720_count : (strings [4,2,1]).length = 6 := by decide
#print axioms N720_factorisation
#print axioms N720_C1a
#print axioms N720_C1b
#print axioms N720_C1
#print axioms N720_wellFormed
#print axioms N720_C2
#print axioms N720_C3
#print axioms N720_C4
#print axioms N720_C5
#print axioms N720_C6
#print axioms N720_W
#print axioms N720_count
end SCD97j1

namespace SCD97j1
/-! ### N = 720: the strings of spec section 2, as explicit lists -/

/-- (a) As exponent vectors over (2, 3, 5), in the enumeration order of `strings`
    (bottoms in lexicographic order of exponent vectors). -/
theorem N720_strings_exponents : strings [4,2,1] =
  [ [[0,0,0],[1,0,0],[2,0,0],[3,0,0],[4,0,0],[4,1,0],[4,2,0],[4,2,1]],
    [[0,0,1],[1,0,1],[2,0,1],[3,0,1],[4,0,1],[4,1,1]],
    [[0,1,0],[1,1,0],[2,1,0],[3,1,0],[3,2,0],[3,2,1]],
    [[0,1,1],[1,1,1],[2,1,1],[3,1,1]],
    [[0,2,0],[1,2,0],[2,2,0],[2,2,1]],
    [[0,2,1],[1,2,1]] ] := by decide

/-- Spec section 2 order: longer strings first, then by bottom value
    (bottoms are distinct, so this is the reference script's key (-len, values)). -/
def before (s t : List Nat) : Bool :=
  t.length < s.length || (s.length == t.length && s.headD 0 < t.headD 0)

def insertS (s : List Nat) : List (List Nat) → List (List Nat)
  | [] => [s]
  | t :: ts => if before s t then s :: t :: ts else t :: insertS s ts

def sortS : List (List Nat) → List (List Nat)
  | [] => []
  | s :: ss => insertS s (sortS ss)

/-- (b) As divisor values, in the order printed in spec section 2:
    8 1<2<4<8<16<48<144<720 / 6 3<6<12<24<72<360 / 6 5<10<20<40<80<240 /
    4 9<18<36<180 / 4 15<30<60<120 / 2 45<90. -/
theorem N720_strings_values :
    sortS ((strings [4,2,1]).map (fun s => s.map (val [2,3,5]))) =
  [ [1,2,4,8,16,48,144,720],
    [3,6,12,24,72,360],
    [5,10,20,40,80,240],
    [9,18,36,180],
    [15,30,60,120],
    [45,90] ] := by decide

#print axioms N720_strings_exponents
#print axioms N720_strings_values
end SCD97j1

namespace SCD97j1
/-! ### N = 30030 = 2^1 * 3^1 * 5^1 * 7^1 * 11^1 * 13^1, profile [1,1,1,1,1,1] (ascending primes) -/
theorem N30030_factorisation : 30030 = 2^1 * 3^1 * 5^1 * 7^1 * 11^1 * 13^1 := by decide
theorem N30030_C1a : C1a [1,1,1,1,1,1] := by decide
theorem N30030_C1b : C1b [1,1,1,1,1,1] := by decide
theorem N30030_C1 : C1 [1,1,1,1,1,1] := C1_of_halves _ N30030_C1a N30030_C1b
theorem N30030_wellFormed : WellFormed [1,1,1,1,1,1] := by decide
theorem N30030_C2 : C2 [1,1,1,1,1,1] := by decide
theorem N30030_C3 : C3 [1,1,1,1,1,1] := by decide
theorem N30030_C4 : C4 [1,1,1,1,1,1] := by decide
theorem N30030_C5 : C5 [1,1,1,1,1,1] := by decide
theorem N30030_C6 : C6 [1,1,1,1,1,1] := by decide
theorem N30030_W : (List.range (sumL [1,1,1,1,1,1] + 1)).map (W [1,1,1,1,1,1]) = [1,6,15,20,15,6,1] := by decide
theorem N30030_count : (strings [1,1,1,1,1,1]).length = 20 := by decide
#print axioms N30030_factorisation
#print axioms N30030_C1a
#print axioms N30030_C1b
#print axioms N30030_C1
#print axioms N30030_wellFormed
#print axioms N30030_C2
#print axioms N30030_C3
#print axioms N30030_C4
#print axioms N30030_C5
#print axioms N30030_C6
#print axioms N30030_W
#print axioms N30030_count
end SCD97j1

/- N = 720720: plain `decide` exceeds the elaborator default maxRecDepth 512 (job SCD-LEAN-04);
   raising this elaborator recursion limit is the only change. Proofs are still plain `decide`. -/
set_option maxRecDepth 20000

namespace SCD97j1
/-! ### N = 720720 = 2^4 * 3^2 * 5^1 * 7^1 * 11^1 * 13^1, profile [4,2,1,1,1,1] (ascending primes) -/
theorem N720720_factorisation : 720720 = 2^4 * 3^2 * 5^1 * 7^1 * 11^1 * 13^1 := by decide
theorem N720720_C1a : C1a [4,2,1,1,1,1] := by decide
theorem N720720_C1b : C1b [4,2,1,1,1,1] := by decide
theorem N720720_C1 : C1 [4,2,1,1,1,1] := C1_of_halves _ N720720_C1a N720720_C1b
theorem N720720_wellFormed : WellFormed [4,2,1,1,1,1] := by decide
theorem N720720_C2 : C2 [4,2,1,1,1,1] := by decide
theorem N720720_C3 : C3 [4,2,1,1,1,1] := by decide
theorem N720720_C4 : C4 [4,2,1,1,1,1] := by decide
theorem N720720_C5 : C5 [4,2,1,1,1,1] := by decide
theorem N720720_C6 : C6 [4,2,1,1,1,1] := by decide
theorem N720720_W : (List.range (sumL [4,2,1,1,1,1] + 1)).map (W [4,2,1,1,1,1]) = [1,6,17,31,42,46,42,31,17,6,1] := by decide
theorem N720720_count : (strings [4,2,1,1,1,1]).length = 46 := by decide
#print axioms N720720_factorisation
#print axioms N720720_C1a
#print axioms N720720_C1b
#print axioms N720720_C1
#print axioms N720720_wellFormed
#print axioms N720720_C2
#print axioms N720720_C3
#print axioms N720720_C4
#print axioms N720720_C5
#print axioms N720720_C6
#print axioms N720720_W
#print axioms N720720_count
end SCD97j1
