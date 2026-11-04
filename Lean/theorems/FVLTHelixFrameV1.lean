import FVLTCliffordGeometryV1

/-! Explicit Euclidean sum-dot geometry on C x R. The product max norm is not
used. The reference frame is algebraically normal to the declared direction;
no Frenet/Bishop or derivative characterization is asserted. -/
noncomputable section
namespace FVLT.HelixFrameV1

def phase (a : ℝ) : ℂ := Complex.exp ((a : ℂ)*Complex.I)
theorem phase_zero : phase 0=1 := by simp [phase]
theorem phase_add (a b : ℝ) : phase (a+b)=phase a*phase b := by
  simp only [phase,Complex.ofReal_add,add_mul,Complex.exp_add]
theorem phase_ne_zero (a : ℝ) : phase a≠0 := Complex.exp_ne_zero _
theorem phase_norm (a : ℝ) : ‖phase a‖=1 := by simp [phase,Complex.norm_exp]
theorem phase_normSq (a : ℝ) : Complex.normSq (phase a)=1 := by
  rw [Complex.normSq_eq_norm_sq,phase_norm]
  norm_num
theorem phase_sub (a b : ℝ) : phase (a-b)=phase a/phase b := by
  simp only [phase,Complex.ofReal_sub,sub_mul,Complex.exp_sub]

abbrev Vec := ℂ × ℝ
def dot (v w : Vec) : ℝ := v.1.re*w.1.re+v.1.im*w.1.im+v.2*w.2
def add (v w : Vec) : Vec := (v.1+w.1,v.2+w.2)
def scale (a : ℝ) (v : Vec) : Vec := ((a : ℂ)*v.1,a*v.2)
def rotate (a : ℝ) (v : Vec) : Vec := (phase a*v.1,v.2)
def screw (a h : ℝ) (p : Vec) : Vec := (phase a*p.1,p.2+h)

theorem dot_comm (v w : Vec) : dot v w=dot w v := by unfold dot; ring
theorem dot_add_left (u v w : Vec) : dot (add u v) w=dot u w+dot v w := by
  simp [dot,add,Complex.add_re,Complex.add_im] <;> ring
theorem dot_add_right (u v w : Vec) : dot u (add v w)=dot u v+dot u w := by
  simp [dot,add,Complex.add_re,Complex.add_im] <;> ring
theorem dot_scale_left (a : ℝ) (v w : Vec) : dot (scale a v) w=a*dot v w := by
  simp [dot,scale,Complex.mul_re,Complex.mul_im] <;> ring
theorem dot_scale_right (a : ℝ) (v w : Vec) : dot v (scale a w)=a*dot v w := by
  rw [dot_comm,dot_scale_left,dot_comm w v]

theorem rotate_dot (a : ℝ) (v w : Vec) : dot (rotate a v) (rotate a w)=dot v w := by
  have hu : (phase a).re^2+(phase a).im^2=1 := by
    simpa [Complex.normSq_apply,pow_two] using phase_normSq a
  calc
    dot (rotate a v) (rotate a w) =
      ((phase a).re^2+(phase a).im^2)*(v.1.re*w.1.re+v.1.im*w.1.im)+v.2*w.2 := by
        simp only [dot,rotate,Complex.mul_re,Complex.mul_im]
        ring
    _ = dot v w := by rw [hu]; simp [dot]

theorem rotate_add (a b : ℝ) (v : Vec) : rotate (a+b) v=rotate a (rotate b v) := by
  apply Prod.ext <;> simp [rotate,phase_add,mul_assoc]
theorem rotate_zero (v : Vec) : rotate 0 v=v := by simp [rotate,phase_zero]
theorem screw_add (a b h k : ℝ) (v : Vec) :
    screw (a+b) (h+k) v=screw a h (screw b k v) := by
  apply Prod.ext <;> simp [screw,phase_add,mul_assoc] <;> ring
theorem screw_zero (v : Vec) : screw 0 0 v=v := by simp [screw,phase_zero]

def speed (k h : ℝ) : ℝ := Real.sqrt (k^2+h^2)
theorem speed_pos (k h : ℝ) (hh : 0<h) : 0<speed k h := by
  apply Real.sqrt_pos.mpr
  nlinarith [sq_nonneg k]
theorem speed_sq (k h : ℝ) : speed k h^2=k^2+h^2 := by
  exact Real.sq_sqrt (by positivity)
def baseA : Vec := (1,0)
def baseB (k h : ℝ) : Vec := (((-h/speed k h : ℝ) : ℂ)*Complex.I,k/speed k h)
def direction (k h : ℝ) : Vec := (((k : ℝ) : ℂ)*Complex.I,h)
def normalA (a : ℝ) : Vec := rotate a baseA
def normalB (a k h : ℝ) : Vec := rotate a (baseB k h)

theorem baseA_unit : dot baseA baseA=1 := by norm_num [dot,baseA]
theorem baseB_unit (k h : ℝ) (hh : 0<h) : dot (baseB k h) (baseB k h)=1 := by
  have hn := ne_of_gt (speed_pos k h hh)
  have hs := speed_sq k h
  simp [dot,baseB,Complex.mul_re,Complex.mul_im]
  field_simp <;> nlinarith
theorem base_orthogonal (k h : ℝ) : dot baseA (baseB k h)=0 := by
  simp [dot,baseA,baseB,Complex.mul_re,Complex.mul_im]
theorem direction_normalA (k h : ℝ) : dot (direction k h) baseA=0 := by
  simp [dot,direction,baseA,Complex.mul_re,Complex.mul_im]
theorem direction_normalB (k h : ℝ) : dot (direction k h) (baseB k h)=0 := by
  simp [dot,direction,baseB,Complex.mul_re,Complex.mul_im] <;> ring
theorem normalA_unit (a : ℝ) : dot (normalA a) (normalA a)=1 := by
  rw [normalA,rotate_dot,baseA_unit]
theorem normalB_unit (a k h : ℝ) (hh : 0<h) : dot (normalB a k h) (normalB a k h)=1 := by
  rw [normalB,rotate_dot,baseB_unit k h hh]
theorem normals_orthogonal (a k h : ℝ) : dot (normalA a) (normalB a k h)=0 := by
  rw [normalA,normalB,rotate_dot,base_orthogonal]
theorem normals_orthogonal_reverse (a k h : ℝ) : dot (normalB a k h) (normalA a)=0 := by
  rw [dot_comm,normals_orthogonal]
theorem rotated_direction_normals (a k h : ℝ) :
    dot (rotate a (direction k h)) (normalA a)=0 ∧
    dot (rotate a (direction k h)) (normalB a k h)=0 := by
  simp only [normalA,normalB,rotate_dot,direction_normalA,direction_normalB,and_self]

def marked (a k h tau : ℝ) : Vec :=
  add (scale (Real.cos tau) (normalA a)) (scale (Real.sin tau) (normalB a k h))

theorem marked_unit (a k h tau : ℝ) (hh : 0<h) :
    dot (marked a k h tau) (marked a k h tau)=1 := by
  simp only [marked,dot_add_left,dot_add_right,dot_scale_left,dot_scale_right,
    normalA_unit,normalB_unit a k h hh,normals_orthogonal,normals_orthogonal_reverse,
    mul_zero,zero_mul,mul_one,add_zero,zero_add]
  nlinarith [Real.sin_sq_add_cos_sq tau]

theorem normalA_transport (a b : ℝ) : rotate b (normalA a)=normalA (b+a) := by
  exact (rotate_add b a baseA).symm
theorem normalB_transport (a b k h : ℝ) : rotate b (normalB a k h)=normalB (b+a) k h := by
  exact (rotate_add b a (baseB k h)).symm
theorem marked_transport (a b k h tau : ℝ) :
    rotate b (marked a k h tau)=marked (b+a) k h tau := by
  apply Prod.ext
  · simp [rotate,marked,add,scale,normalA,normalB,phase_add]
    ring
  · simp [rotate,marked,add,scale,normalA,normalB]

def quarterMarked (a k h tau : ℝ) : Vec :=
  add (scale (-Real.sin tau) (normalA a)) (scale (Real.cos tau) (normalB a k h))

theorem marked_twist (a k h tau delta : ℝ) :
    marked a k h (tau+delta)=
      add (scale (Real.cos delta) (marked a k h tau))
        (scale (Real.sin delta) (quarterMarked a k h tau)) := by
  apply Prod.ext
  · simp [marked,quarterMarked,add,scale,Real.cos_add,Real.sin_add]
    ring
  · simp [marked,quarterMarked,add,scale,Real.cos_add,Real.sin_add]
    ring

theorem marked_frame_coordinates (a k h tau : ℝ) (hh : 0<h) :
    dot (marked a k h tau) (normalA a)=Real.cos tau ∧
    dot (marked a k h tau) (normalB a k h)=Real.sin tau := by
  simp [marked,dot_add_left,dot_scale_left,normalA_unit,normalB_unit a k h hh,
    normals_orthogonal,normals_orthogonal_reverse]

end FVLT.HelixFrameV1
