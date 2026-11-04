import FVLTPhaseAddressV1

/-!
# The signed n6 mirror control

Flipping the sign of n6 reflects the complex point through the origin.
This is a half-turn, distinct from complex conjugation across the real axis.
The radial magnitude is unchanged, and every ordered walk prefix is mirrored.
-/
namespace FVLT.N6MirrorV1

noncomputable section

def mirror (z : ℂ) : ℂ := -z

@[simp] theorem mirror_twice (z : ℂ) : mirror (mirror z) = z := by simp [mirror]

theorem mirror_norm (z : ℂ) : ‖mirror z‖ = ‖z‖ := norm_neg z

theorem radius_neg_scale (m : CoupledPointV1.Modulus) (alpha n6 : ℝ) :
    AlphaAmplitudeV1.radius m alpha (-n6) = -AlphaAmplitudeV1.radius m alpha n6 := by
  simp [AlphaAmplitudeV1.radius]

theorem point_neg_scale (m : CoupledPointV1.Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    AlphaAmplitudeV1.point m alpha (-n6) k s =
      mirror (AlphaAmplitudeV1.point m alpha n6 k s) := by
  simp [AlphaAmplitudeV1.point, radius_neg_scale, mirror]

theorem point_neg_scale_norm (m : CoupledPointV1.Modulus) (alpha n6 : ℝ) (k s : ℤ) :
    ‖AlphaAmplitudeV1.point m alpha (-n6) k s‖ =
      ‖AlphaAmplitudeV1.point m alpha n6 k s‖ := by
  rw [point_neg_scale, mirror_norm]

theorem point_neg_scale_real_contact (m : CoupledPointV1.Modulus) (alpha n6 : ℝ)
    (k s : ℤ) :
    (AlphaAmplitudeV1.point m alpha (-n6) k s).im = 0 ↔
      (AlphaAmplitudeV1.point m alpha n6 k s).im = 0 := by
  rw [point_neg_scale]
  simp [mirror]

theorem mirror_phasor_halfturn (x : ℝ) :
    mirror (PhaseAddressV1.phasor x) = PhaseAddressV1.phasor (x+1) := by
  rw [PhaseAddressV1.phasor_add, PhaseAddressV1.phasor_one]
  simp [mirror]

/-- The exact sign flip can instead be represented by a unit phase-address shift. -/
theorem point_neg_scale_halfturn (m : CoupledPointV1.Modulus) (alpha n6 : ℝ)
    (k s : ℤ) :
    AlphaAmplitudeV1.point m alpha (-n6) k s =
      (AlphaAmplitudeV1.radius m alpha n6 : ℂ) *
        PhaseAddressV1.phasor ((PhaseAddressV1.address m k s : ℝ)+1) := by
  rw [point_neg_scale, PhaseAddressV1.alpha_point_eq, PhaseAddressV1.phasor_add,
    PhaseAddressV1.phasor_one]
  simp [mirror]

theorem trailPoint_neg_scale (n1 : ℕ) (i : RosetteTrailV1.Trail n1) (arm : Bool)
    (alpha n6 : ℝ) (t1 t2 s : ℤ) :
    AlphaAmplitudeV1.trailPoint n1 i arm alpha (-n6) t1 t2 s =
      mirror (AlphaAmplitudeV1.trailPoint n1 i arm alpha n6 t1 t2 s) := by
  cases arm <;> simp [AlphaAmplitudeV1.trailPoint, AlphaAmplitudeV1.z1,
    AlphaAmplitudeV1.z2, point_neg_scale]

theorem walk_mirror (tilt : ℝ) (z : ℕ → ℂ) (t : ℕ) :
    WalkTiltV1.walk tilt (fun j => mirror (z j)) t =
      mirror (WalkTiltV1.walk tilt z t) := by
  simpa [mirror] using WalkTiltV1.walk_mul tilt z (-1) t

theorem pointWalk_neg_scale (m : CoupledPointV1.Modulus) (alpha n6 tilt : ℝ)
    (k : ℕ → ℤ) (s : ℤ) (t : ℕ) :
    WalkTiltV1.pointWalk m alpha (-n6) tilt k s t =
      mirror (WalkTiltV1.pointWalk m alpha n6 tilt k s t) := by
  unfold WalkTiltV1.pointWalk
  simp_rw [point_neg_scale]
  exact walk_mirror tilt _ t

/-- Conjugation exchanges the arms; n6 inversion negates either arm. -/
theorem mirror_commutes_conjugation (z : ℂ) :
    mirror (star z) = star (mirror z) := by simp [mirror]

end
end FVLT.N6MirrorV1
