import FVLTRule30SpinV1
import FVLTNonlinearSpectralV1

/-! Actual ring-generated Rule30 spins satisfy the spectral polynomial.
Padding separately identifies the finite core with actual kit cells. No
off-support regeneration, energy lower bound or prize conclusion follows. -/
noncomputable section
namespace FVLT.ActualSpinSpectrumV1
open Rule30SpinV1 WovenEvolutionV1 RingSemanticsV1
open TurnFourierV1 ProductConvolutionV1 NonlinearSpectralV1
open Ruliology.CellularAutomata

def cyclicSpin (N t : ℕ) (z : ZMod N) : ℂ := spinC (ring (fun _=>N) t z)

theorem actual_cyclic_spin_update (N : ℕ) [NeZero N] (t : ℕ) :
    cyclicSpin N (t+1)=polyUpdate (cyclicSpin N t) := by
  funext z
  have hs := congrFun (WovenCylinderV1.fixed_ring_step N t) z
  change spinC (ring (fun _=>N) (t+1) z)=_
  rw [hs]
  exact forward_spin _ _ _

theorem actual_cyclic_doubled_transform (N : ℕ) [NeZero N] (t : ℕ) (k : ZMod N) :
    2*plusDFT (cyclicSpin N (t+1)) k=
      -plusDFT (left (cyclicSpin N t)) k
      -(1/(N : ℂ))*convolution (plusDFT (left (cyclicSpin N t))) (plusDFT (cyclicSpin N t)) k
      -(1/(N : ℂ))*convolution (plusDFT (left (cyclicSpin N t))) (plusDFT (right (cyclicSpin N t))) k
      +(1/(N : ℂ))*convolution
        (plusDFT (fun b => left (cyclicSpin N t) b*cyclicSpin N t b))
        (plusDFT (right (cyclicSpin N t))) k := by
  rw [actual_cyclic_spin_update]
  exact doubled_product_convolution (cyclicSpin N t) k

theorem padded_spin_eq_actual_kit (N T : ℕ) (hpad : 2*T+3≤N)
    (t : ℕ) (ht : t≤T) (i : ℤ) (hi : |i|≤(t : ℤ)) :
    cyclicSpin N t (i : ZMod N)=spinC (Rule30Jen.cell t i) := by
  unfold cyclicSpin
  rw [ring_read (fun _=>N) (fun _=>NoWrapPaddingV1.padding_pos N T hpad),
    NoWrapPaddingV1.fixed_weave_eq_infinite_core N T hpad t ht i hi,
    WovenKitBridgeV1.infinite_eq_kit]

end FVLT.ActualSpinSpectrumV1
