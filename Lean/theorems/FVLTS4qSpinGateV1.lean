import S4n_G_PeriodTwoTargetIV1
import FVLTWovenEvolutionV1

/-! S4q under Addendum1: exact sign gate, Rule150 comparison and a separately
named affine truncation. The standard local identities carry no novelty claim. -/
noncomputable section
namespace FVLT.S4qSpinGateV1
open scoped BigOperators

def spin (b : Bool) : ℝ := (S4nPeriodTwoTargetIV1.spin b : ℝ)
def rule30 (p q r : Bool) : Bool := WovenEvolutionV1.rule p q r
def rule150 (p q r : Bool) : Bool := xor p (xor q r)
def gate (q r : Bool) : ℝ := (-1+spin q+spin r+spin q*spin r)/2
def affineGate (x y : ℝ) : ℝ := (-1+x+y)/2
def interaction (x y : ℝ) : ℝ := x*y/2
def saturation (q r : Bool) : ℝ := if q && r then 1 else 0
def truncatedOutput (p q r : Bool) : ℝ := spin p*affineGate (spin q) (spin r)

theorem spin_false : spin false=1 := by norm_num [spin,S4nPeriodTwoTargetIV1.spin]
theorem spin_true : spin true= -1 := by norm_num [spin,S4nPeriodTwoTargetIV1.spin]
theorem spin_square (b : Bool) : spin b*spin b=1 := by cases b <;> norm_num [spin_false,spin_true]
theorem spin_abs (b : Bool) : |spin b|=1 := by cases b <;> norm_num [spin_false,spin_true]
theorem spin_xor (a b : Bool) : spin (xor a b)=spin a*spin b := by
  unfold spin
  exact_mod_cast S4nPeriodTwoTargetIV1.spin_xor a b

/-- Reuses Gemini's released S4n-G integer identity, not a fresh discovery. -/
theorem gate_eq_spin_or (q r : Bool) : gate q r=spin (q || r) := by
  have hi := S4nPeriodTwoTargetIV1.two_mul_spin_or q r
  have hr : (2 : ℝ)*spin (q || r)= -1+spin q+spin r+spin q*spin r := by
    unfold spin
    exact_mod_cast hi
  unfold gate
  linarith

theorem local_factor (p q r : Bool) : spin (rule30 p q r)=spin p*gate q r := by
  change spin (xor p (q || r))=spin p*gate q r
  rw [spin_xor,gate_eq_spin_or]
theorem gate_is_sign (q r : Bool) : gate q r=1 ∨ gate q r= -1 := by
  rw [gate_eq_spin_or]
  cases h : q || r <;> simp [h,spin_false,spin_true]
theorem gate_square (q r : Bool) : gate q r*gate q r=1 := by
  rw [gate_eq_spin_or,spin_square]
theorem gate_abs (q r : Bool) : |gate q r|=1 := by rw [gate_eq_spin_or,spin_abs]
theorem gate_split (q r : Bool) : gate q r=affineGate (spin q) (spin r)+interaction (spin q) (spin r) := by
  unfold gate affineGate interaction
  ring

def rowStep (x : ℤ → Bool) (i : ℤ) : Bool := rule30 (x (i-1)) (x i) (x (i+1))
def row150 (x : ℤ → Bool) (i : ℤ) : Bool := rule150 (x (i-1)) (x i) (x (i+1))
def twistField (x : ℤ → Bool) (i : ℤ) : ℝ := spin (x (i-1))
def gateField (x : ℤ → Bool) (i : ℤ) : ℝ := gate (x i) (x (i+1))
theorem row_factor (x : ℤ → Bool) (i : ℤ) : spin (rowStep x i)=twistField x i*gateField x i :=
  local_factor _ _ _
theorem row_factor_function (x : ℤ → Bool) :
    (fun i => spin (rowStep x i))=(fun i => twistField x i*gateField x i) := funext (row_factor x)
theorem infinite_step_factor (t : ℕ) (i : ℤ) :
    spin (WovenEvolutionV1.infinite (t+1) i)=
      twistField (WovenEvolutionV1.infinite t) i*gateField (WovenEvolutionV1.infinite t) i := by
  exact local_factor _ _ _

/-- Truth-table indexing uses p=bit2,q=bit1,r=bit0 and sum 2^n. -/
def elementaryCode (f : Bool → Bool → Bool → Bool) : ℕ :=
  ∑ n ∈ Finset.range 8,
    if f (decide (n/4%2=1)) (decide (n/2%2=1)) (decide (n%2=1)) then 2^n else 0
theorem rule30_code : elementaryCode rule30=30 := by decide
theorem rule150_code : elementaryCode rule150=150 := by decide
theorem rule150_spin (p q r : Bool) : spin (rule150 p q r)=spin p*spin q*spin r := by
  unfold rule150
  rw [spin_xor,spin_xor]
  ring
theorem rule150_xor_additive : ∀ p q r p' q' r' : Bool,
    rule150 (xor p p') (xor q q') (xor r r')=xor (rule150 p q r) (rule150 p' q' r') := by decide
theorem rule30_not_xor_additive : ¬∀ p q r p' q' r' : Bool,
    rule30 (xor p p') (xor q q') (xor r r')=xor (rule30 p q r) (rule30 p' q' r') := by decide
theorem local_difference_iff (p q r : Bool) : rule30 p q r≠rule150 p q r ↔ q=true ∧ r=true := by
  cases p <;> cases q <;> cases r <;> decide
theorem or_xor_difference_iff (q r : Bool) : (q || r)≠xor q r ↔ q=true ∧ r=true := by
  cases q <;> cases r <;> decide
theorem saturation_spin (q r : Bool) : saturation q r=(1-spin q)*(1-spin r)/4 := by
  cases q <;> cases r <;> norm_num [saturation,spin_false,spin_true]
theorem gate_xor_correction (q r : Bool) :
    gate q r=spin q*spin r-(1/2 : ℝ)*(1-spin q)*(1-spin r) := by
  unfold gate
  ring
theorem local_correction (p q r : Bool) :
    spin (rule30 p q r)=spin (rule150 p q r)-(1/2 : ℝ)*spin p*(1-spin q)*(1-spin r) := by
  rw [local_factor,rule150_spin,gate_xor_correction]
  ring
theorem local_correction_indicator (p q r : Bool) :
    spin (rule30 p q r)-spin (rule150 p q r)= -2*spin p*saturation q r := by
  rw [local_correction,saturation_spin]
  ring
theorem correction_on_saturation (p : Bool) :
    spin (rule30 p true true)-spin (rule150 p true true)= -2*spin p := by
  rw [local_correction_indicator]
  simp [saturation]
theorem correction_off_saturation (p q r : Bool) (h : (q && r)=false) :
    spin (rule30 p q r)-spin (rule150 p q r)=0 := by
  rw [local_correction_indicator]
  simp [saturation,h]
theorem row_correction (x : ℤ → Bool) (i : ℤ) :
    spin (rowStep x i)-spin (row150 x i)= -2*twistField x i*saturation (x i) (x (i+1)) :=
  local_correction_indicator _ _ _

/-- Literal Walsh deletion: a separate non-Boolean surrogate. -/
theorem omission_error (q r : Bool) :
    gate q r-affineGate (spin q) (spin r)=spin q*spin r/2 := by
  unfold gate affineGate
  ring
theorem omission_error_abs (q r : Bool) :
    |gate q r-affineGate (spin q) (spin r)|=(1/2 : ℝ) := by
  rw [omission_error]
  cases q <;> cases r <;> norm_num [spin_false,spin_true]
theorem truncated_output_error_abs (p q r : Bool) :
    |spin (rule30 p q r)-truncatedOutput p q r|=(1/2 : ℝ) := by
  rw [local_factor]
  unfold truncatedOutput
  rw [←mul_sub,abs_mul,spin_abs,omission_error_abs]
  norm_num
theorem truncation_not_unit (q r : Bool) : |affineGate (spin q) (spin r)|≠1 := by
  cases q <;> cases r <;> norm_num [affineGate,spin_false,spin_true]
theorem affine_gate_zero : affineGate 0 0= -(1/2 : ℝ) := by norm_num [affineGate]
theorem affine_gate_not_additive :
    affineGate (0+0) (0+0)≠affineGate 0 0+affineGate 0 0 := by norm_num [affineGate]
theorem affine_gate_translation (x y u v : ℝ) :
    affineGate (x+u) (y+v)=affineGate x y+(u+v)/2 := by unfold affineGate; ring

end FVLT.S4qSpinGateV1
