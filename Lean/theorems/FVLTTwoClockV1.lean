import FVLTNaturalFanV1
import Mathlib.Data.ZMod.Basic
import Mathlib.Data.Nat.ModEq
import Mathlib.Tactic

/-!
Two positive arithmetic clocks and their visited address grid. The return clock
is lcm(P,Q), not P*Q unless coprimality is declared. Tail factorization uses one
coloring of visited addresses and one shared natural-time threshold.
No complex readout or Rule30 forcing assertion is introduced here.
-/
namespace FVLT.TwoClockV1
open NaturalFanV1
noncomputable section
variable {P Q : ℕ} [NeZero P] [NeZero Q]

def clock (P Q : ℕ) : ℕ := Nat.lcm P Q

def address (P Q t : ℕ) : ZMod P × ZMod Q := (t,t)

theorem clock_pos : 0 < clock P Q :=
  Nat.lcm_pos (Nat.pos_of_ne_zero (NeZero.ne P))
    (Nat.pos_of_ne_zero (NeZero.ne Q))

theorem address_eq_iff_mod (t u : ℕ) :
    address P Q t = address P Q u ↔ t % clock P Q = u % clock P Q := by
  change ((t : ZMod P),(t : ZMod Q)) = ((u : ZMod P),(u : ZMod Q)) ↔ _
  rw [Prod.mk.injEq, ZMod.natCast_eq_natCast_iff, ZMod.natCast_eq_natCast_iff]
  change (t ≡ u [MOD P] ∧ t ≡ u [MOD Q]) ↔ t ≡ u [MOD Nat.lcm P Q]
  exact ⟨fun h => Nat.mod_lcm h.1 h.2,
    fun h => ⟨h.of_dvd (Nat.dvd_lcm_left P Q), h.of_dvd (Nat.dvd_lcm_right P Q)⟩⟩

/-- Integer difference avoids an unsigned-natural subtraction convention. -/
theorem address_eq_iff_dvd_difference (t u : ℕ) :
    address P Q t = address P Q u ↔
      (clock P Q : ℤ) ∣ (u : ℤ)-(t : ℤ) := by
  rw [address_eq_iff_mod]
  exact Nat.modEq_iff_dvd

theorem return_iff_dvd (n : ℕ) :
    address P Q n = address P Q 0 ↔ clock P Q ∣ n := by
  rw [address_eq_iff_mod]
  simp [Nat.dvd_iff_mod_eq_zero]

theorem address_add_clock (t : ℕ) :
    address P Q (t+clock P Q) = address P Q t := by
  rw [address_eq_iff_mod]
  simp [Nat.add_mod]

theorem address_add_multiple (t k : ℕ) :
    address P Q (t+clock P Q*k) = address P Q t := by
  rw [address_eq_iff_mod]
  simp [Nat.add_mod, Nat.mul_mod]

theorem least_positive_return :
    0 < clock P Q ∧ address P Q (clock P Q) = address P Q 0 ∧
      ∀ n : ℕ, 0<n → address P Q n = address P Q 0 → clock P Q ≤ n := by
  refine ⟨clock_pos, (return_iff_dvd _).mpr (dvd_refl _), ?_⟩
  intro n hn he
  exact Nat.le_of_dvd hn ((return_iff_dvd n).mp he)

def Compatible (z : ZMod P × ZMod Q) : Prop :=
  z.1.val % Nat.gcd P Q = z.2.val % Nat.gcd P Q

theorem address_compatible (t : ℕ) : Compatible (address P Q t) := by
  simp only [Compatible, address, ZMod.val_natCast]
  rw [Nat.mod_mod_of_dvd t (Nat.gcd_dvd_left P Q),
    Nat.mod_mod_of_dvd t (Nat.gcd_dvd_right P Q)]

/-- Generalized CRT: exactly the gcd-compatible pairs are visited. -/
theorem exists_address_iff_compatible (z : ZMod P × ZMod Q) :
    (∃ t : ℕ, address P Q t=z) ↔ Compatible z := by
  constructor
  · rintro ⟨t,rfl⟩
    exact address_compatible t
  · intro h
    let w := Nat.chineseRemainder' (show z.1.val ≡ z.2.val [MOD Nat.gcd P Q] from h)
    refine ⟨w.val, Prod.ext ?_ ?_⟩
    · change (w.val : ZMod P)=z.1
      calc
        (w.val : ZMod P) = (z.1.val : ZMod P) :=
          (ZMod.natCast_eq_natCast_iff _ _ _).mpr w.property.1
        _ = z.1 := ZMod.natCast_zmod_val _
    · change (w.val : ZMod Q)=z.2
      calc
        (w.val : ZMod Q) = (z.2.val : ZMod Q) :=
          (ZMod.natCast_eq_natCast_iff _ _ _).mpr w.property.2
        _ = z.2 := ZMod.natCast_zmod_val _

def coprimeCRT (h : P.Coprime Q) : ZMod (P*Q) ≃+* ZMod P × ZMod Q :=
  ZMod.chineseRemainder h

theorem coprimeCRT_nat (h : P.Coprime Q) (t : ℕ) :
    coprimeCRT h (t : ZMod (P*Q)) = address P Q t := by
  change coprimeCRT h (t : ZMod (P*Q)) = (t : ZMod P × ZMod Q)
  exact map_natCast _ t

theorem address_surjective_iff_coprime :
    Function.Surjective (address P Q) ↔ P.Coprime Q := by
  constructor
  · intro hs
    obtain ⟨t,ht⟩ := hs ((0 : ZMod P),(1 : ZMod Q))
    have hp : t ≡ 0 [MOD P] :=
      (ZMod.natCast_eq_natCast_iff t 0 P).mp (by simpa [address] using congrArg Prod.fst ht)
    have hq : t ≡ 1 [MOD Q] :=
      (ZMod.natCast_eq_natCast_iff t 1 Q).mp (by simpa [address] using congrArg Prod.snd ht)
    have hg : 0 ≡ 1 [MOD Nat.gcd P Q] :=
      (hp.of_dvd (Nat.gcd_dvd_left P Q)).symm.trans
        (hq.of_dvd (Nat.gcd_dvd_right P Q))
    exact Nat.coprime_iff_gcd_eq_one.mpr
      (Nat.dvd_one.mp (Nat.modEq_zero_iff_dvd.mp hg.symm))
  · intro h z
    apply (exists_address_iff_compatible z).mpr
    simp [Compatible, h.gcd_eq_one]
    omega

def VisitedAddress (P Q : ℕ) :=
  {z : ZMod P × ZMod Q // ∃ t : ℕ, address P Q t=z}

def visit (P Q t : ℕ) : VisitedAddress P Q := ⟨address P Q t,⟨t,rfl⟩⟩

def representative (z : VisitedAddress P Q) : ℕ := Classical.choose z.property

theorem representative_spec (z : VisitedAddress P Q) :
    address P Q (representative z)=z.val := Classical.choose_spec z.property

theorem visit_add_clock (t : ℕ) : visit P Q (t+clock P Q)=visit P Q t := by
  apply Subtype.ext
  exact address_add_clock t

def TailFactors {A : Type*} (P Q : ℕ) (c : ℕ → A) : Prop :=
  ∃ T : ℕ, ∃ color : VisitedAddress P Q → A,
    ∀ t : ℕ, T≤t → c t=color (visit P Q t)

/-- Iteration on a tail is valid from each starting time, with no finite alphabet. -/
theorem tail_periodic_multiple {A : Type*} (c : ℕ → A) (L T : ℕ)
    (hc : ∀ t, T≤t → c (t+L)=c t) (k t : ℕ) (ht : T≤t) :
    c (t+k*L)=c t := by
  induction k with
  | zero => simp
  | succ k ih =>
    calc
      c (t+(k+1)*L) = c ((t+k*L)+L) := by congr 1; ring
      _ = c (t+k*L) := hc _ (by omega)
      _ = c t := ih

theorem tail_congruence_same_color {A : Type*} (c : ℕ → A) (L T : ℕ)
    (hc : ∀ t, T≤t → c (t+L)=c t) (t u : ℕ)
    (ht : T≤t) (hu : T≤u) (he : t%L=u%L) : c t=c u := by
  have htper := tail_periodic_multiple c L T hc (u/L) t ht
  have huper := tail_periodic_multiple c L T hc (t/L) u hu
  have htime : t+(u/L)*L=u+(t/L)*L := by
    have htaddr := Nat.mod_add_div t L
    have huaddr := Nat.mod_add_div u L
    nlinarith
  exact htper.symm.trans ((congrArg c htime).trans huper)

theorem eventual_period_iff_tail_factors {A : Type*} (c : ℕ → A) :
    EventuallyPPeriodic (clock P Q) c ↔ TailFactors P Q c := by
  constructor
  · rintro ⟨T,hT⟩
    let color : VisitedAddress P Q → A :=
      fun z => c (clock P Q*T+representative z)
    refine ⟨T,color,?_⟩
    intro t ht
    have hLT : T≤clock P Q*T := by
      have h1 : 1≤clock P Q := clock_pos
      simpa using Nat.mul_le_mul_right T h1
    have haddr : address P Q (clock P Q*T+representative (visit P Q t)) =
        address P Q t := by
      calc
        _ = address P Q (representative (visit P Q t)) := by
          rw [address_eq_iff_mod]
          simp [Nat.add_mod, Nat.mul_mod]
        _ = address P Q t := representative_spec (visit P Q t)
    apply tail_congruence_same_color c (clock P Q) T hT t
      (clock P Q*T+representative (visit P Q t)) ht (by omega)
    exact ((address_eq_iff_mod _ _).mp haddr).symm
  · rintro ⟨T,color,hc⟩
    refine ⟨T,?_⟩
    intro t ht
    rw [hc (t+clock P Q) (by omega), hc t ht, visit_add_clock]

end
end FVLT.TwoClockV1
