import FVLTCliffordGeometryV1
import FVLTTwoClockV1
import FVLTBeatPeriodV1

/-! Explicit bridge between finite clock addresses and their Clifford readout.
The quotient chart is faithful on the coprime sampled orbit, not on all S3.
Tail colouring remains equivalent to periodicity, not a forced dynamics result. -/
noncomputable section
namespace FVLT.HopfClockBridgeV1
open CliffordGeometryV1
variable {P Q : ℕ} [NeZero P] [NeZero Q]

def realise (z : ZMod P × ZMod Q) : Space :=
  !₂[(cliffordScale : ℂ)*ZMod.stdAddChar z.1,
    (cliffordScale : ℂ)*ZMod.stdAddChar z.2]

theorem realise_injective : Function.Injective (realise (P:=P) (Q:=Q)) := by
  intro z w he
  have h0 := congrArg (fun v : Space => v 0) he
  have h1 := congrArg (fun v : Space => v 1) he
  apply Prod.ext
  · apply ZMod.injective_stdAddChar
    apply mul_left_cancel₀ cliffordScale_complex_ne_zero
    simpa [realise] using h0
  · apply ZMod.injective_stdAddChar
    apply mul_left_cancel₀ cliffordScale_complex_ne_zero
    simpa [realise] using h1

theorem realise_address (t : ℕ) :
    realise (TwoClockV1.address P Q t)=gamma P Q (t : ℤ) := by
  ext i
  fin_cases i <;> simp [realise,TwoClockV1.address,gamma,CliffordGeometryV1.clock]

theorem gamma_eq_iff_address (t u : ℕ) :
    gamma P Q (t : ℤ)=gamma P Q (u : ℤ) ↔
      TwoClockV1.address P Q t=TwoClockV1.address P Q u := by
  rw [← realise_address, ← realise_address]
  exact realise_injective.eq_iff

theorem gamma_least_positive_return :
    0<TwoClockV1.clock P Q ∧
      gamma P Q (TwoClockV1.clock P Q : ℤ)=gamma P Q 0 ∧
      ∀n : ℕ,0<n → gamma P Q (n : ℤ)=gamma P Q 0 → TwoClockV1.clock P Q≤n := by
  have h := TwoClockV1.least_positive_return (P:=P) (Q:=Q)
  refine ⟨h.1,?_,?_⟩
  · exact (gamma_eq_iff_address _ 0).mpr h.2.1
  · intro n hn he
    exact h.2.2 n hn ((gamma_eq_iff_address n 0).mp he)

def GammaVisited (P Q : ℕ) [NeZero P] [NeZero Q] :=
  {z : Space // ∃t : ℕ,gamma P Q (t : ℤ)=z}

def gammaVisit (t : ℕ) : GammaVisited P Q := ⟨gamma P Q (t : ℤ),t,rfl⟩

def toGamma (z : TwoClockV1.VisitedAddress P Q) : GammaVisited P Q :=
  ⟨realise z.val,by
    obtain ⟨t,ht⟩ := z.property
    exact ⟨t,by rw [← realise_address,ht]⟩⟩

theorem toGamma_bijective : Function.Bijective (toGamma (P:=P) (Q:=Q)) := by
  constructor
  · intro z w he
    apply Subtype.ext
    apply realise_injective
    exact congrArg Subtype.val he
  · intro z
    obtain ⟨t,ht⟩ := z.property
    refine ⟨TwoClockV1.visit P Q t,?_⟩
    apply Subtype.ext
    change realise (TwoClockV1.address P Q t)=z.val
    rw [realise_address]
    exact ht

def visitedEquiv : TwoClockV1.VisitedAddress P Q ≃ GammaVisited P Q :=
  Equiv.ofBijective toGamma toGamma_bijective

theorem visitedEquiv_visit (t : ℕ) :
    visitedEquiv (TwoClockV1.visit P Q t)=gammaVisit (P:=P) (Q:=Q) t := by
  apply Subtype.ext
  change realise (TwoClockV1.address P Q t)=gamma P Q (t : ℤ)
  exact realise_address t

def TailFactorsGamma {A : Type*} (c : ℕ → A) : Prop :=
  ∃T : ℕ,∃color : GammaVisited P Q → A,∀t : ℕ,T≤t → c t=color (gammaVisit t)

theorem periodic_iff_gamma_colouring {A : Type*} (c : ℕ → A) :
    NaturalFanV1.EventuallyPPeriodic (TwoClockV1.clock P Q) c ↔
      TailFactorsGamma (P:=P) (Q:=Q) c := by
  rw [TwoClockV1.eventual_period_iff_tail_factors]
  constructor
  · rintro ⟨T,color,h⟩
    refine ⟨T,(fun z=>color (visitedEquiv.symm z)),?_⟩
    intro t ht
    change c t=color (visitedEquiv.symm (gammaVisit t))
    rw [← visitedEquiv_visit,Equiv.symm_apply_apply]
    exact h t ht
  · rintro ⟨T,color,h⟩
    refine ⟨T,(fun z=>color (visitedEquiv z)),?_⟩
    intro t ht
    change c t=color (visitedEquiv (TwoClockV1.visit P Q t))
    rw [visitedEquiv_visit]
    exact h t ht

theorem clock_eq_exp (n : ℕ) [NeZero n] (t : ℤ) :
    CliffordGeometryV1.clock n t=
      Complex.exp (2*Real.pi*Complex.I*(t : ℂ)/(n : ℂ)) := by
  simpa [CliffordGeometryV1.clock] using ZMod.stdAddChar_coe (N:=n) t

theorem chart_gamma_eq_beat (t : ℤ) : chart (gamma P Q t)=BeatPeriodV1.beat P Q t := by
  rw [chart_gamma,clock_eq_exp,clock_eq_exp,BeatPeriodV1.beat_eq_exp,← Complex.exp_sub]
  congr 1
  ring

theorem chart_gamma_norm (t : ℤ) : ‖chart (gamma P Q t)‖=1 := by
  rw [chart_gamma,norm_div,clock_norm,clock_norm]
  norm_num

theorem coprime_chart_eq_iff (h : P.Coprime Q) (t u : ℤ) :
    chart (gamma P Q t)=chart (gamma P Q u) ↔
      (t : ZMod (P*Q))=(u : ZMod (P*Q)) := by
  rw [chart_gamma_eq_beat,chart_gamma_eq_beat]
  exact (BeatPeriodV1.coprime_beatCyclic_injective P Q h).eq_iff

theorem chart_integer_period_iff (n : ℕ) :
    Function.Periodic (fun t : ℤ=>chart (gamma P Q t)) (n : ℤ) ↔
      BeatPeriodV1.leastPeriod P Q ∣ n := by
  simpa only [chart_gamma_eq_beat] using BeatPeriodV1.beat_period_iff P Q n

theorem chart_least_positive_integer_period :
    IsLeast {n : ℕ | 0<n ∧ Function.Periodic
      (fun t : ℤ=>chart (gamma P Q t)) (n : ℤ)} (BeatPeriodV1.leastPeriod P Q) := by
  simpa only [chart_gamma_eq_beat] using BeatPeriodV1.leastPeriod_isLeast P Q

theorem equal_clock_chart (P : ℕ) [NeZero P] (t : ℤ) :
    chart (gamma P P t)=1 := by
  rw [chart_gamma]
  exact div_self (clock_ne_zero P t)

end FVLT.HopfClockBridgeV1
