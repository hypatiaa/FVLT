import Ruliology.CellularAutomata.Rule30LeftConductorTransferV1
import FVLTWovenKitBridgeV1
import FVLTNoWrapPaddingV1

/-! T7's true=+1, false=-1 convention, reused rather than sign-switched.
The forward polynomial remains nonlinear. This module does not claim that
nonlinearity forces any conductor energy or arbitrarily late center change. -/
namespace FVLT.Rule30SpinV1
open Ruliology.CellularAutomata
open WovenEvolutionV1

def spinZ (b : Bool) : ℤ := Rule30LeftConductorTransferV1.spin b
def spinC (b : Bool) : ℂ := (spinZ b : ℂ)

theorem spin_convention (b : Bool) : spinC b=NoWrapPaddingV1.spinLift b := by
  cases b <;> norm_num [spinC,spinZ,Rule30LeftConductorTransferV1.spin,NoWrapPaddingV1.spinLift]

theorem forward_spin_twice (a b c : Bool) :
    2*spinZ (rule a b c)= -spinZ a*(1+spinZ b+spinZ c-spinZ b*spinZ c) := by
  simpa only [spinZ,rule,Rule30LeftConductorTransferV1.leftSidewaysBit] using Rule30LeftConductorTransferV1.leftSidewaysBit_spin_eq a b c

theorem forward_spin (a b c : Bool) :
    spinC (rule a b c)= -spinC a*(1+spinC b+spinC c-spinC b*spinC c)/2 := by
  have hz := forward_spin_twice a b c
  have hc : 2*spinC (rule a b c)= -spinC a*(1+spinC b+spinC c-spinC b*spinC c) := by
    dsimp only [spinC]
    exact_mod_cast hz
  apply (eq_div_iff (by norm_num : (2 : ℂ)≠0)).mpr
  rw [mul_comm]
  exact hc

theorem infinite_row_spin_update (t : ℕ) (i : ℤ) :
    spinC (infinite (t+1) i)=
      -spinC (infinite t (i-1))*(1+spinC (infinite t i)+spinC (infinite t (i+1))-
        spinC (infinite t i)*spinC (infinite t (i+1)))/2 :=
  forward_spin _ _ _

theorem kit_row_spin_update (t : ℕ) (i : ℤ) :
    spinC (Rule30Jen.cell (t+1) i)=
      -spinC (Rule30Jen.cell t (i-1))*(1+spinC (Rule30Jen.cell t i)+spinC (Rule30Jen.cell t (i+1))-
        spinC (Rule30Jen.cell t i)*spinC (Rule30Jen.cell t (i+1)))/2 := by
  simpa only [WovenKitBridgeV1.infinite_eq_kit] using infinite_row_spin_update t i

theorem spinC_injective : Function.Injective spinC := by
  intro a b he
  cases a <;> cases b <;> simp_all [spinC,spinZ,Rule30LeftConductorTransferV1.spin] <;> norm_num at he

/-- Existing kit period-one obstruction transported through the injective spin encoding. -/
theorem spin_center_not_eventually_constant :
    ¬ ∃T z, ∀t, T≤t → spinC (Rule30Jen.cell t 0)=z := by
  rintro ⟨T,z,h⟩
  apply Rule30Prize.center_not_eventually_constant
  refine ⟨T,Rule30Jen.cell T 0,?_⟩
  intro t ht
  apply spinC_injective
  exact (h t ht).trans (h T le_rfl).symm

end FVLT.Rule30SpinV1
