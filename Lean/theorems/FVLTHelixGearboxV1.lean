import FVLTHelixFrameV1
import FVLTGearboxV1
import FVLTHopfClockBridgeV1

/-! A declared framed helix, independent screw and local-frame twist actions,
and exact branch gearbox quotient. No existing viewer is identified by fiat. -/
noncomputable section
namespace FVLT.HelixGearboxV1
open HelixFrameV1

structure Pose where
  address : ℝ
  height : ℝ
  orientation : ℝ

def advance (delta rise : ℝ) (p : Pose) : Pose :=
  ⟨p.address+delta,p.height+rise,p.orientation⟩
def twist (tau : ℝ) (p : Pose) : Pose :=
  ⟨p.address,p.height,p.orientation+tau⟩
def position (R : ℝ) (p : Pose) : Vec := ((R : ℂ)*phase p.address,p.height)
def mark (k h : ℝ) (p : Pose) : Vec := marked p.address k h p.orientation

theorem advance_zero (p : Pose) : advance 0 0 p=p := by cases p; simp [advance]
theorem twist_zero (p : Pose) : twist 0 p=p := by cases p; simp [twist]
theorem advances_compose (a b h k : ℝ) (p : Pose) :
    advance a h (advance b k p)=advance (a+b) (h+k) p := by
  cases p
  simp [advance,add_assoc,add_comm,add_left_comm]
theorem twists_compose (a b : ℝ) (p : Pose) : twist a (twist b p)=twist (a+b) p := by
  cases p
  simp [twist,add_assoc,add_comm,add_left_comm]
theorem advance_twist_commute (a h tau : ℝ) (p : Pose) :
    advance a h (twist tau p)=twist tau (advance a h p) := rfl
theorem position_advance (R a h : ℝ) (p : Pose) :
    position R (advance a h p)=screw a h (position R p) := by
  apply Prod.ext
  · simp [position,advance,screw,phase_add]
    ring
  · rfl
theorem position_twist (R tau : ℝ) (p : Pose) : position R (twist tau p)=position R p := rfl
theorem mark_advance (a rise k h : ℝ) (p : Pose) :
    mark k h (advance a rise p)=rotate a (mark k h p) := by
  dsimp [mark,advance]
  rw [marked_transport,add_comm p.address a]
theorem mark_twist (tau k h : ℝ) (p : Pose) :
    mark k h (twist tau p)=add (scale (Real.cos tau) (mark k h p))
      (scale (Real.sin tau) (quarterMarked p.address k h p.orientation)) := by
  exact marked_twist p.address k h p.orientation tau
theorem mark_unit (k h : ℝ) (hh : 0<h) (p : Pose) : dot (mark k h p) (mark k h p)=1 :=
  marked_unit _ _ _ _ hh

def alpha (t1 : ℝ) : ℝ := Real.pi*t1
def beta (N t2 : ℝ) (c : ℤ) : ℝ := -Real.pi*(c : ℝ)*t2/N
def walk (N t1 t2 h : ℝ) (c : ℤ) (s : ℝ) : Pose :=
  ⟨beta N t2 c*s,h*s,alpha t1*s⟩

theorem walk_zero (N t1 t2 h : ℝ) (c : ℤ) : walk N t1 t2 h c 0=⟨0,0,0⟩ := by
  simp [walk]
theorem walker_increment (N t1 t2 h : ℝ) (c : ℤ) (s u : ℝ) :
    walk N t1 t2 h c (s+u)=
      twist (alpha t1*u) (advance (beta N t2 c*u) (h*u) (walk N t1 t2 h c s)) := by
  unfold walk twist advance
  congr 1 <;> ring
theorem walker_position_increment (N t1 t2 h R : ℝ) (c : ℤ) (s u : ℝ) :
    position R (walk N t1 t2 h c (s+u))=
      screw (beta N t2 c*u) (h*u) (position R (walk N t1 t2 h c s)) := by
  rw [walker_increment,position_twist,position_advance]
theorem walk_position_norm (N t1 t2 h R : ℝ) (c : ℤ) (s : ℝ) :
    ‖(position R (walk N t1 t2 h c s)).1‖=|R| := by
  simp [position,norm_mul,phase_norm]

def lift (a b : ℝ) (p : Pose) : CliffordGeometryV1.Space :=
  !₂[(a : ℂ)*phase p.orientation,(b : ℂ)*phase p.address]

theorem lift_norm_sq (a b : ℝ) (p : Pose) : ‖lift a b p‖^2=a^2+b^2 := by
  rw [CliffordGeometryV1.euclidean_norm_sq]
  simp [lift,Complex.normSq_mul,phase_normSq,Complex.normSq_ofReal,pow_two]
theorem lift_norm_one (a b : ℝ) (hab : a^2+b^2=1) (p : Pose) : ‖lift a b p‖=1 := by
  have h := lift_norm_sq a b p
  rw [hab] at h
  nlinarith [norm_nonneg (lift a b p)]
theorem lift_chart (a b : ℝ) (hb : b≠0) (p : Pose) :
    CliffordGeometryV1.chart (lift a b p)=((a/b : ℝ) : ℂ)*phase (p.orientation-p.address) := by
  change ((a : ℂ)*phase p.orientation)/((b : ℂ)*phase p.address)=_
  rw [phase_sub]
  push_cast
  have hbC : (b : ℂ)≠0 := by exact_mod_cast hb
  field_simp [phase_ne_zero p.address] <;> ring

def branch (N t1 t2 : ℝ) (c : ℤ) (s : ℝ) : ℂ :=
  phase (Real.pi*s*(t1+(c : ℝ)*t2/N))

theorem walk_relative_phase (N t1 t2 h : ℝ) (c : ℤ) (s : ℝ) :
    phase ((walk N t1 t2 h c s).orientation-(walk N t1 t2 h c s).address)=
      branch N t1 t2 c s := by
  unfold walk alpha beta branch
  congr 1
  ring
theorem chart_walk (N t1 t2 h a b : ℝ) (hb : b≠0) (c : ℤ) (s : ℝ) :
    CliffordGeometryV1.chart (lift a b (walk N t1 t2 h c s))=
      ((a/b : ℝ) : ℂ)*branch N t1 t2 c s := by
  rw [lift_chart a b hb,walk_relative_phase]
theorem branch_gearbox (N t1 t2 : ℝ) (hN : N≠0) (c : ℤ) (s : ℝ) :
    branch N t1 t2 c s=phase ((N*t1+(c : ℝ)*t2)*s*Real.pi/N) := by
  unfold branch
  congr 1
  field_simp <;> ring
theorem branch_increment (N t1 t2 : ℝ) (c : ℤ) (s u : ℝ) :
    branch N t1 t2 c (s+u)=branch N t1 t2 c s*branch N t1 t2 c u := by
  unfold branch
  rw [show Real.pi*(s+u)*(t1+(c : ℝ)*t2/N)=
    Real.pi*s*(t1+(c : ℝ)*t2/N)+Real.pi*u*(t1+(c : ℝ)*t2/N) by ring,phase_add]
theorem branch_factor (N t1 t2 : ℝ) (c : ℤ) (s : ℝ) :
    branch N t1 t2 c s=phase (alpha t1*s)*phase (Real.pi*s*(c : ℝ)*t2/N) := by
  rw [←phase_add]
  unfold branch alpha
  congr 1
  ring

def normalizer (R : ℝ) : ℝ := Real.sqrt (1+R^2)
def amplitudeA (R : ℝ) : ℝ := R/normalizer R
def amplitudeB (R : ℝ) : ℝ := 1/normalizer R
theorem normalizer_pos (R : ℝ) : 0<normalizer R := by
  apply Real.sqrt_pos.mpr
  positivity
theorem normalizer_sq (R : ℝ) : normalizer R^2=1+R^2 :=
  Real.sq_sqrt (by positivity)
theorem amplitudeB_pos (R : ℝ) : 0<amplitudeB R :=
  div_pos (by norm_num) (normalizer_pos R)
theorem amplitudes_ratio (R : ℝ) : amplitudeA R/amplitudeB R=R := by
  have hn := ne_of_gt (normalizer_pos R)
  unfold amplitudeA amplitudeB
  field_simp
theorem amplitudes_normalized (R : ℝ) : amplitudeA R^2+amplitudeB R^2=1 := by
  have hn := ne_of_gt (normalizer_pos R)
  have hs := normalizer_sq R
  unfold amplitudeA amplitudeB
  field_simp <;> nlinarith
theorem normalized_lift_unit (R : ℝ) (p : Pose) :
    ‖lift (amplitudeA R) (amplitudeB R) p‖=1 :=
  lift_norm_one _ _ (amplitudes_normalized R) p
theorem normalized_chart_walk (N t1 t2 h R : ℝ) (c : ℤ) (s : ℝ) :
    CliffordGeometryV1.chart (lift (amplitudeA R) (amplitudeB R) (walk N t1 t2 h c s))=
      (R : ℂ)*branch N t1 t2 c s := by
  rw [chart_walk N t1 t2 h (amplitudeA R) (amplitudeB R)
    (ne_of_gt (amplitudeB_pos R)),amplitudes_ratio]
theorem chart_common_rotation (a b delta : ℝ) (hb : b≠0) (p : Pose) :
    CliffordGeometryV1.chart (lift a b (twist delta (advance delta 0 p)))=
      CliffordGeometryV1.chart (lift a b p) := by
  rw [lift_chart a b hb,lift_chart a b hb]
  unfold twist advance
  congr 2
  ring

/-- Half-turn denominator N means a full-turn cyclic clock of size 2N. -/
theorem integer_branch_clock (N : ℕ) [NeZero N] (t1 t2 c s : ℤ) :
    branch (N : ℝ) (t1 : ℝ) (t2 : ℝ) c (s : ℝ)=
      CliffordGeometryV1.clock (2*N) (((N : ℤ)*t1+c*t2)*s) := by
  rw [HopfClockBridgeV1.clock_eq_exp]
  unfold branch phase
  push_cast
  have hn : (N : ℂ)≠0 := by exact_mod_cast NeZero.ne N
  congr 1
  field_simp <;> ring
theorem integer_minus_branch_k1 (N : ℕ) [NeZero N] (t1 t2 s : ℤ) :
    branch (N : ℝ) (t1 : ℝ) (t2 : ℝ) (-1) (s : ℝ)=
      CliffordGeometryV1.clock (2*N) (GearboxV1.k1 (N : ℤ) t1 t2*s) := by
  rw [integer_branch_clock]
  congr 1
  unfold GearboxV1.k1
  ring
theorem integer_plus_branch_k2 (N : ℕ) [NeZero N] (t1 t2 s : ℤ) :
    branch (N : ℝ) (t1 : ℝ) (t2 : ℝ) 1 (s : ℝ)=
      CliffordGeometryV1.clock (2*N) (GearboxV1.k2 (N : ℤ) t1 t2*s) := by
  rw [integer_branch_clock]
  congr 1
  unfold GearboxV1.k2
  ring

end FVLT.HelixGearboxV1
