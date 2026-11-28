import ShortLong
import Mathlib.Analysis.SpecialFunctions.Pow.Asymptotics

namespace AtlasLog
open Finset Filter ArithmeticFunction
open scoped ArithmeticFunction.Moebius
noncomputable section

def residuePrefix (r : ℕ) (y : ℝ) : ℝ :=
  ∑ n ∈ Ioc 0 ⌊y⌋₊, if n%12=r then (μ n : ℝ) else 0

def referenceLength (x : ℝ) := x / (Real.log x)^20

/-- The fixed-modulus, one-exponent part of the Möbius Siegel–Walfisz input. -/
def Prefix21 : Prop := ∃ B : ℝ, 0<B ∧ ∃ Y : ℝ, ∀ y ≥ Y, ∀ r ∈ residues,
  |residuePrefix r y| ≤ B*y/(Real.log y)^21

theorem window_prefix_difference (r : ℕ) (x H : ℝ) (hH : 0≤H) :
    windowSum 12 r x H = residuePrefix r (x+H) - residuePrefix r x := by
  have ord := Nat.floor_le_floor (show x ≤ x+H by linarith)
  have split : Ioc 0 ⌊x+H⌋₊ = Ioc 0 ⌊x⌋₊ ∪ Ioc ⌊x⌋₊ ⌊x+H⌋₊ := by
    ext n; simp only [mem_union,mem_Ioc]; omega
  have dis : Disjoint (Ioc 0 ⌊x⌋₊) (Ioc ⌊x⌋₊ ⌊x+H⌋₊) := by
    apply disjoint_left.mpr; intro n hn hh
    exact (not_lt_of_ge (mem_Ioc.mp hn).2) (mem_Ioc.mp hh).1
  unfold windowSum residuePrefix
  rw [split,sum_union dis]; ring

theorem reference_from_prefix (B x : ℝ) (hb : 0<B) (hx : 0<x) (hl : 1≤Real.log x)
    (r : ℕ) (a : |residuePrefix r x| ≤ B*x/(Real.log x)^21)
    (b : |residuePrefix r (x+referenceLength x)| ≤
      B*(x+referenceLength x)/(Real.log (x+referenceLength x))^21) :
    |windowMean r x (referenceLength x)| ≤ 3*B/Real.log x := by
  have lp : 0<Real.log x := by linarith
  have hp : 0<referenceLength x := div_pos hx (pow_pos lp _)
  have hs : referenceLength x ≤ x := by
    unfold referenceLength; exact div_le_self hx.le (one_le_pow₀ hl)
  have inc := Real.log_le_log hx (show x≤x+referenceLength x by linarith)
  have right : |residuePrefix r (x+referenceLength x)| ≤ B*(2*x)/(Real.log x)^21 := by
    apply b.trans
    apply (div_le_div_of_nonneg_left (by positivity) (by positivity) (pow_le_pow_left₀ lp.le inc 21)).trans
    apply div_le_div_of_nonneg_right _ (by positivity)
    exact mul_le_mul_of_nonneg_left (by linarith) hb.le
  unfold windowMean
  rw [window_prefix_difference _ _ _ hp.le,abs_div,abs_of_pos hp,div_le_iff₀ hp]
  apply (abs_sub _ _).trans ((add_le_add right a).trans_eq ?_)
  unfold referenceLength
  field_simp; ring

/-- The long/short comparison from Part I Proposition 3.4(i), restricted
to H₂=x/log²⁰x and the four units modulo 12; A=1 and ε=1/200. -/
def PartIComparison12 : Prop := ∃ C : ℝ, 0<C ∧ ∃ Y : ℝ, ∀ x ≥ Y, ∀ H : ℝ,
  x^(7/12+1/200:ℝ) ≤ H → H ≤ referenceLength x → ∀ r ∈ residues,
    |windowMean r x H-windowMean r x (referenceLength x)| ≤ C/Real.log x

theorem long_range_lower (M : ℕ) (hm : 4≤M) (x : ℝ) (xb : x ∈ Set.Icc (M:ℝ) (2*M)) :
    x^(7/12+1/200:ℝ) ≤ longLength M := by
  have mr : (1:ℝ) ≤ M := by exact_mod_cast (show 1≤M by omega)
  have root : 2 ≤ Real.sqrt M := (Real.le_sqrt (by norm_num) (by positivity)).mpr
    (by exact_mod_cast hm)
  have up : x ≤ (M:ℝ)^(1+(1/2:ℝ)) := by
    rw [Real.rpow_add (by positivity : 0<(M:ℝ)),Real.rpow_one,←Real.sqrt_eq_rpow]
    nlinarith [xb.2,mul_le_mul_of_nonneg_left root (show 0≤(M:ℝ) by positivity)]
  calc _ ≤ ((M:ℝ)^(1+(1/2:ℝ)))^(7/12+1/200:ℝ) :=
          Real.rpow_le_rpow (by linarith [xb.1]) up (by norm_num)
       _ ≤ _ := by rw [←Real.rpow_mul (by positivity)]; apply Real.rpow_le_rpow_of_exponent_le mr; norm_num [longLength]

theorem long_range_upper : ∃ Y : ℝ, ∀ x ≥ Y, ∀ M : ℕ, (M:ℝ) ≤ x →
    longLength M ≤ referenceLength x := by
  have asym := (isLittleO_log_rpow_rpow_atTop (20:ℝ) (by norm_num : (0:ℝ)<1/100)).bound
    (by norm_num : (0:ℝ)<1)
  obtain ⟨Y,hy⟩ := eventually_atTop.1 asym
  refine ⟨max Y 4,?_⟩
  intro x hx M hM
  have pos : 0<x := by linarith [le_max_right Y (4:ℝ)]
  have lp : 0<Real.log x := Real.log_pos (by linarith [le_max_right Y (4:ℝ)])
  have logb := hy x ((le_max_left Y 4).trans hx)
  simp only [Real.norm_eq_abs,one_mul,abs_of_nonneg (Real.rpow_nonneg pos.le _)] at logb
  have bound : (Real.log x)^20 ≤ x^(1/100:ℝ) := by
    simpa [abs_of_pos lp] using logb
  unfold referenceLength longLength
  rw [le_div_iff₀ (pow_pos lp _)]
  calc _ ≤ x^(99/100:ℝ)*x^(1/100:ℝ) :=
          mul_le_mul (Real.rpow_le_rpow (by positivity) hM (by norm_num)) bound (by positivity) (by positivity)
       _ = x := by rw [←Real.rpow_add pos]; norm_num

theorem longWindow12_of_partI (sw : Prefix21) (comparison : PartIComparison12) : LongWindow12 := by
  obtain ⟨B,hB,Y,sw⟩ := sw
  obtain ⟨C,hC,Z,comp⟩ := comparison
  obtain ⟨W,upper⟩ := long_range_upper
  let T := max 4 (max Y (max Z W))
  refine ⟨C+3*B,by positivity,⌈T⌉₊,?_⟩
  intro M m0 x xb r hr
  have tm : T ≤ (M:ℝ) := (Nat.le_ceil T).trans (by exact_mod_cast m0)
  have mx := xb.1
  dsimp [T] at tm
  have m4 : (4:ℝ)≤M := (le_max_left ..).trans tm
  have hY : Y≤x := le_trans (le_max_left ..) ((le_max_right ..).trans (tm.trans mx))
  have hZW : max Z W ≤ x := (le_max_right ..).trans ((le_max_right ..).trans (tm.trans mx))
  have xp : 0<x := by linarith
  have logm : 0<Real.log M := Real.log_pos (by linarith)
  have logone : 1 ≤ Real.log x := (Real.le_log_iff_exp_le xp).mpr
    (by linarith [Real.exp_one_lt_d9])
  have inc : x≤x+referenceLength x := by
    apply le_add_of_nonneg_right
    unfold referenceLength; have := Real.log_pos (show 1<x by linarith); positivity
  have ref := reference_from_prefix B x hB xp logone r (sw x hY r hr) (sw _ (hY.trans inc) r hr)
  have dif := comp x ((le_max_left ..).trans hZW) _ (long_range_lower M (by exact_mod_cast m4) x xb)
    (upper x ((le_max_right ..).trans hZW) M mx) r hr
  have tri := abs_add_le (windowMean r x (longLength M)-windowMean r x (referenceLength x))
    (windowMean r x (referenceLength x))
  rw [sub_add_cancel] at tri
  apply (tri.trans (add_le_add dif ref)).trans
  rw [←add_div]
  exact div_le_div_of_nonneg_left (by positivity) logm (Real.log_le_log (by linarith) mx)

end
end AtlasLog
