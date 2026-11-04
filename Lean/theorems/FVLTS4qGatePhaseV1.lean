import FVLTS4qSpinGateV1
import FVLTHelixGearboxV1

/-! A local0/pi encoding is proved, not an identification of arbitrary Rule30
dynamics with one fixed Vernier trajectory. -/
noncomputable section
namespace FVLT.S4qGatePhaseV1

def gateAngle (q r : Bool) : ℝ := if q || r then Real.pi else 0
theorem phase_pi : FVLT.HelixFrameV1.phase Real.pi= -1 := by
  simp [FVLT.HelixFrameV1.phase,Complex.exp_pi_mul_I]
theorem gate_as_phase (q r : Bool) :
    (S4qSpinGateV1.gate q r : ℂ)=FVLT.HelixFrameV1.phase (gateAngle q r) := by
  rw [S4qSpinGateV1.gate_eq_spin_or]
  cases h : q || r <;> simp [gateAngle,h,S4qSpinGateV1.spin_false,S4qSpinGateV1.spin_true,
    FVLT.HelixFrameV1.phase_zero,phase_pi]
theorem gate_complex_norm (q r : Bool) : ‖(S4qSpinGateV1.gate q r : ℂ)‖=1 := by
  rw [gate_as_phase,FVLT.HelixFrameV1.phase_norm]

theorem gate_fails_xor_character :
    S4qSpinGateV1.gate (xor true false) (xor false true)≠
      S4qSpinGateV1.gate true false*S4qSpinGateV1.gate false true := by
  norm_num [S4qSpinGateV1.gate,S4qSpinGateV1.spin_false,S4qSpinGateV1.spin_true]

theorem fixed_branch_increment (N t1 t2 : ℝ) (c : ℤ) (s u : ℝ) :
    FVLT.HelixGearboxV1.branch N t1 t2 c (s+u)=
      FVLT.HelixGearboxV1.branch N t1 t2 c s*FVLT.HelixGearboxV1.branch N t1 t2 c u :=
  FVLT.HelixGearboxV1.branch_increment N t1 t2 c s u

end FVLT.S4qGatePhaseV1
