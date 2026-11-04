import Mathlib.Data.Fintype.Pigeonhole
import Mathlib.Tactic

/-!
Generic finite-state obstruction to reproducing two non-jointly-eventually-periodic
observations. No cellular-automaton recurrence or Rule30 theorem is assumed here
except through the explicit final hypothesis on the two target observations.
-/

namespace FVLT.FiniteStateObstructionV1

def EventuallyPeriodic {A : Type*} (f : ℕ → A) : Prop :=
  ∃ T P : ℕ, 0 < P ∧ ∀ t, T ≤ t → f (t+P)=f t

theorem equal_future_of_equal {S : Type*} (F : S → S) (u : ℕ → S)
    (hu : ∀ t, u (t+1)=F (u t)) {m n : ℕ} (he : u m=u n) :
    ∀ r, u (m+r)=u (n+r) := by
  intro r
  induction r with
  | zero => simpa using he
  | succ r ih =>
    calc
      u (m+(r+1)) = u ((m+r)+1) := by congr 1
      _ = F (u (m+r)) := hu _
      _ = F (u (n+r)) := congrArg F ih
      _ = u ((n+r)+1) := (hu _).symm
      _ = u (n+(r+1)) := by congr 1

/-- No injectivity of the update is needed: the orbit can have a transient. -/
theorem finite_trajectory_eventually_periodic {S : Type*} [Finite S]
    (F : S → S) (u : ℕ → S) (hu : ∀ t, u (t+1)=F (u t)) :
    EventuallyPeriodic u := by
  obtain ⟨m,n,hmn,he⟩ := Finite.exists_ne_map_eq_of_infinite u
  have ordered : ∃ m n : ℕ, m<n ∧ u m=u n := by
    rcases lt_or_gt_of_ne hmn with h | h
    · exact ⟨m,n,h,he⟩
    · exact ⟨n,m,h,he.symm⟩
  obtain ⟨m,n,hmn,he⟩ := ordered
  refine ⟨m,n-m,by omega,?_⟩
  intro t ht
  have hf := equal_future_of_equal F u hu he (t-m)
  have hm : m+(t-m)=t := by omega
  have hn : n+(t-m)=t+(n-m) := by omega
  simpa only [hm,hn] using hf.symm

theorem observable_eventually_periodic {S A : Type*} [Finite S]
    (F : S → S) (u : ℕ → S) (hu : ∀ t, u (t+1)=F (u t))
    (read : S → A) : EventuallyPeriodic (fun t => read (u t)) := by
  obtain ⟨T,P,hP,h⟩ := finite_trajectory_eventually_periodic F u hu
  exact ⟨T,P,hP,fun t ht => congrArg read (h t ht)⟩

theorem eventual_equality_preserves_periodicity {A : Type*}
    (f g : ℕ → A) (hf : EventuallyPeriodic f)
    (he : ∃ U, ∀ t, U≤t → f t=g t) : EventuallyPeriodic g := by
  obtain ⟨T,P,hP,hf⟩ := hf
  obtain ⟨U,he⟩ := he
  refine ⟨max T U,P,hP,?_⟩
  intro t ht
  calc
    g (t+P) = f (t+P) := (he _ (by omega)).symm
    _ = f t := hf _ (by omega)
    _ = g t := he _ (by omega)

/-- A finite autonomous trajectory cannot eventually reproduce a forbidden pair
of target observations. The two readout maps are allowed to coincide. -/
theorem no_finite_realization_of_two_observations {S A : Type*} [Finite S]
    (F : S → S) (u : ℕ → S) (hu : ∀ t, u (t+1)=F (u t))
    (read0 read1 : S → A) (f0 f1 : ℕ → A)
    (hno : ¬ (EventuallyPeriodic f0 ∧ EventuallyPeriodic f1))
    (he0 : ∃ U, ∀ t, U≤t → read0 (u t)=f0 t)
    (he1 : ∃ U, ∀ t, U≤t → read1 (u t)=f1 t) : False := by
  apply hno
  constructor
  · exact eventual_equality_preserves_periodicity _ _
      (observable_eventually_periodic F u hu read0) he0
  · exact eventual_equality_preserves_periodicity _ _
      (observable_eventually_periodic F u hu read1) he1

/-- Late agreement on the growing integer cone would reproduce columns 0 and 1.
The target may be any sequence of full integer rows satisfying the explicit
no-two-periodic-columns premise; no dynamics is hidden in this statement. -/
theorem arbitrarily_late_cone_mismatch {S A : Type*} [Finite S]
    (F : S → S) (u : ℕ → S) (hu : ∀ t, u (t+1)=F (u t))
    (read : S → ℤ → A) (target : ℕ → ℤ → A)
    (hno : ¬ (EventuallyPeriodic (fun t => target t 0) ∧
      EventuallyPeriodic (fun t => target t 1))) (T : ℕ) :
    ∃ t, T≤t ∧ ∃ i : ℤ, |i|≤(t : ℤ) ∧ read (u t) i ≠ target t i := by
  classical
  by_contra! h
  apply no_finite_realization_of_two_observations F u hu
    (fun s => read s 0) (fun s => read s 1)
    (fun t => target t 0) (fun t => target t 1) hno
  · refine ⟨T,?_⟩
    intro t ht
    exact h t ht 0 (by simp)
  · refine ⟨max T 1,?_⟩
    intro t ht
    apply h t (by omega) 1
    norm_num
    exact_mod_cast (show 1≤t by omega)

end FVLT.FiniteStateObstructionV1
