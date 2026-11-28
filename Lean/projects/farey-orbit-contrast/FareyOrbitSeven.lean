import Std.Tactic

/-! Integer normalizations for the quadratic-character contrast modulo seven.
    Each rank is a count of actual positive reduced fractions at the original order. -/
namespace FareyOrbitSeven

def contrast (f : Nat → Int) : Int :=
  f 1 + f 2 + f 4 - (f 3 + f 5 + f 6)

private def chiResidue (r : Nat) : Int :=
  if r = 0 then 0 else if r = 1 ∨ r = 2 ∨ r = 4 then 1 else -1

def chi7 (k : Nat) : Int := chiResidue (k % 7)

/-- Fourteen times the centered sawtooth at t/7, with value zero on integers. -/
def saw14 (t : Nat) : Int :=
  if t % 7 = 0 then 0 else 2 * ((t % 7 : Nat) : Int) - 7

private theorem seven_cases (P : Nat → Prop) (k : Nat)
    (h0 : P 0) (h1 : P 1) (h2 : P 2) (h3 : P 3)
    (h4 : P 4) (h5 : P 5) (h6 : P 6) : P (k % 7) := by
  have h := Nat.mod_lt k (by decide : 0 < 7)
  have h' : k % 7 = 0 ∨ k % 7 = 1 ∨ k % 7 = 2 ∨ k % 7 = 3 ∨
      k % 7 = 4 ∨ k % 7 = 5 ∨ k % 7 = 6 := by omega
  rcases h' with h | h | h | h | h | h | h <;> simp_all

/-- The raw fractional-part contrast, multiplied by seven. -/
theorem raw_contrast (k : Nat) :
    contrast (fun a => ((a*k % 7 : Nat) : Int)) = -7 * chi7 k := by
  unfold chi7
  rw [show (fun a : Nat => ((a*k % 7 : Nat) : Int)) =
      (fun a : Nat => ((a*(k%7) % 7 : Nat) : Int)) by
        funext a; rw [Nat.mul_mod_mod]]
  exact seven_cases (fun r => contrast (fun a => ((a*r % 7 : Nat) : Int)) =
      -7 * chiResidue r) k (by decide) (by decide) (by decide) (by decide)
      (by decide) (by decide) (by decide)

/-- The quadratic coefficient of the centered sawtooth, before division by six. -/
theorem saw_contrast (k : Nat) :
    contrast (fun a => saw14 (a*k)) = -14 * chi7 k := by
  unfold chi7
  rw [show (fun a : Nat => saw14 (a*k)) = (fun a : Nat => saw14 (a*(k%7))) by
    funext a; simp only [saw14, Nat.mul_mod_mod]]
  exact seven_cases (fun r => contrast (fun a => saw14 (a*r)) = -14 * chiResidue r)
    k (by decide) (by decide) (by decide) (by decide) (by decide) (by decide) (by decide)

def floorRow (a k : Nat) : Int := ((a*k/7 : Nat) : Int)

/-- Removing the uniform slope leaves one quadratic-character value per floor row. -/
theorem floor_contrast (k : Nat) : contrast (fun a => floorRow a k) + k = chi7 k := by
  have raw := raw_contrast k
  have split (a : Nat) := Nat.mod_add_div (a*k) 7
  have h1 := split 1
  have h2 := split 2
  have h3 := split 3
  have h4 := split 4
  have h5 := split 5
  have h6 := split 6
  simp only [contrast, floorRow] at *
  omega

def sumTo : Nat → (Nat → Int) → Int
  | 0, _ => 0
  | n+1, f => sumTo n f + f (n+1)

/-- The true positive Farey rank at a/7, counting the endpoint when it occurs. -/
def countRank (N a : Nat) : Int :=
  sumTo N fun q => sumTo q fun u => if u.gcd q = 1 ∧ 7*u ≤ a*q then 1 else 0

def lengthFarey (N : Nat) : Int := countRank N 7

/-- Seven times A_N(a/7) − (a/7)A_N(1). -/
def displacement7 (N a : Nat) : Int := 7 * countRank N a - (a : Int) * lengthFarey N

set_option maxRecDepth 100000 in
set_option maxHeartbeats 5000000 in
theorem order40 :
    lengthFarey 40 = 490 ∧
    (List.map (displacement7 40) [1,2,3,4,5,6]) = [0,7,0,0,-7,0] ∧
    contrast (displacement7 40) = 14 := by decide

end FareyOrbitSeven
