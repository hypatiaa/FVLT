import FVLTUnitFractionSpineV1
import Mathlib.Data.Int.ModEq
import Mathlib.Tactic

/-! FF-1 R4: exact interior phase partners, isolation and complement.
Framework assembled by Robin Miller; classical rational/Farey components.
Ford (1938), Apostol ch. 5; structural reference Paulson, Isabelle AFP (2025).
-/
namespace FVLT.FareyContactV1
noncomputable section

def unreducedPhases (α : List ℕ) : Finset ℚ :=
  α.toFinset.biUnion (fun a => (Finset.Icc 1 a).image
    (fun e : ℕ => (e : ℚ) / ((a + 1 : ℕ) : ℚ)))

private theorem admissible_two (α : List ℕ) (q : ℕ) (hq : q ∈ admissible α) : 2 ≤ q := by
  obtain ⟨a,ha,hqa⟩ := Finset.mem_biUnion.mp hq
  exact (Finset.mem_filter.mp hqa).2

private theorem interior_numerator (x : ℚ) (hx : 0 < x ∧ x < 1) :
    1 ≤ x.num ∧ x.num ≤ (x.den:ℤ)-1 ∧ 2 ≤ x.den := by
  have hn : 0 < x.num := Rat.num_pos.mpr hx.1
  have hd : (0:ℚ) < x.den := by exact_mod_cast x.den_pos
  have hq : (x.num:ℚ)/(x.den:ℚ) < 1 := by simpa only [Rat.num_div_den] using hx.2
  have hi : x.num < (x.den:ℤ) := by exact_mod_cast (div_lt_one hd).mp hq
  omega

private theorem phase_description (α : List ℕ) (x : ℚ) :
    x ∈ phases α ↔ 0 < x ∧ x < 1 ∧ x.den ∈ admissible α := by
  classical
  constructor
  · intro hx
    obtain ⟨q,hq,hcq⟩ := Finset.mem_biUnion.mp hx
    obtain ⟨c,hc,rfl⟩ := Finset.mem_image.mp hcq
    obtain ⟨hcI,hcop⟩ := Finset.mem_filter.mp hc
    obtain ⟨hc1,hc2⟩ := Finset.mem_Icc.mp hcI
    have hq2 := admissible_two α q hq
    have hqQ : (0:ℚ) < q := by exact_mod_cast (show 0 < q by omega)
    have hcQ : (0:ℚ) < c := by exact_mod_cast (show 0 < c by omega)
    have hltQ : (c:ℚ) < q := by exact_mod_cast (show c < q by omega)
    have hcanon := rawValue_canonical (c:ℤ) q (by omega) (by simpa using hcop)
    have hden : ((c:ℚ)/(q:ℚ)).den = q := by simpa [rawValue] using hcanon.2
    exact ⟨div_pos hcQ hqQ,(div_lt_one hqQ).mpr hltQ,by simpa only [hden] using hq⟩
  · rintro ⟨hx0,hx1,hden⟩
    have hi := interior_numerator x ⟨hx0,hx1⟩
    let c := x.num.toNat
    have hcZ : (c:ℤ) = x.num := Int.toNat_of_nonneg (by omega)
    have hc1 : 1 ≤ c := by omega
    have hc2 : c ≤ x.den-1 := by omega
    have hcop : Nat.Coprime c x.den := by
      simpa only [← hcZ,Int.natAbs_natCast] using x.reduced
    apply Finset.mem_biUnion.mpr
    refine ⟨x.den,hden,Finset.mem_image.mpr ⟨c,?_,?_⟩⟩
    · exact Finset.mem_filter.mpr ⟨Finset.mem_Icc.mpr ⟨hc1,hc2⟩,hcop⟩
    · have hcQ : (c:ℚ) = (x.num:ℚ) := by exact_mod_cast hcZ
      rw [hcQ]
      exact Rat.num_div_den x

theorem phases_eq_unreduced (α : List ℕ) (hα : ∀ a ∈ α, 0 < a) :
  phases α = unreducedPhases α := by
  classical
  ext x
  constructor
  · intro hx
    obtain ⟨hx0,hx1,hden⟩ := (phase_description α x).mp hx
    have hi := interior_numerator x ⟨hx0,hx1⟩
    obtain ⟨a,ha,hqa⟩ := Finset.mem_biUnion.mp hden
    have hdiv := Nat.dvd_of_mem_divisors (Finset.mem_filter.mp hqa).1
    obtain ⟨t,ht⟩ := hdiv
    have htpos : 0 < t := by
      by_contra hh
      have he : t = 0 := by omega
      simp [he] at ht
    let c := x.num.toNat
    have hcZ : (c:ℤ) = x.num := Int.toNat_of_nonneg (by omega)
    have hcpos : 0 < c := by omega
    have hclt : c < x.den := by omega
    have hepos : 1 ≤ c*t := by have := Nat.mul_pos hcpos htpos; omega
    have helt : c*t < a+1 := by rw [ht]; exact Nat.mul_lt_mul_of_pos_right hclt htpos
    have htQ : ((a+1:ℕ):ℚ) = (x.den:ℚ)*(t:ℚ) := by exact_mod_cast ht
    have htne : (t:ℚ) ≠ 0 := by exact_mod_cast (ne_of_gt htpos)
    have hqne : (x.den:ℚ) ≠ 0 := by exact_mod_cast x.den_ne_zero
    refine Finset.mem_biUnion.mpr ⟨a,ha,Finset.mem_image.mpr ⟨c*t,?_,?_⟩⟩
    · exact Finset.mem_Icc.mpr ⟨hepos,by omega⟩
    · calc
        _ = (c:ℚ)/(x.den:ℚ) := by rw [htQ]; push_cast; field_simp
        _ = x := by
          rw [show (c:ℚ) = (x.num:ℚ) by exact_mod_cast hcZ]
          exact Rat.num_div_den x
  · intro hx
    obtain ⟨a,ha,hax⟩ := Finset.mem_biUnion.mp hx
    obtain ⟨e,he,rfl⟩ := Finset.mem_image.mp hax
    obtain ⟨he1,hea⟩ := Finset.mem_Icc.mp he
    have hdenpos : (0:ℚ) < ((a+1:ℕ):ℚ) := by positivity
    have hepos : (0:ℚ) < e := by exact_mod_cast (show 0 < e by omega)
    have helt : (e:ℚ) < ((a+1:ℕ):ℚ) := by exact_mod_cast (show e < a+1 by omega)
    have bounds : 0 < (e:ℚ)/((a+1:ℕ):ℚ) ∧ (e:ℚ)/((a+1:ℕ):ℚ) < 1 :=
      ⟨div_pos hepos hdenpos,(div_lt_one hdenpos).mpr helt⟩
    have hd : ((e:ℚ)/((a+1:ℕ):ℚ)).den ∣ a+1 := by
      apply Int.natCast_dvd_natCast.mp
      simpa only [Rat.divInt_eq_div,Int.cast_natCast] using Rat.den_dvd (e:ℤ) ((a+1:ℕ):ℤ)
    apply (phase_description α _).mpr
    refine ⟨bounds.1,bounds.2,Finset.mem_biUnion.mpr ⟨a,ha,?_⟩⟩
    exact Finset.mem_filter.mpr ⟨Nat.mem_divisors.mpr ⟨hd,by omega⟩,
      (interior_numerator _ bounds).2.2⟩

theorem phase_domain (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) :
  0 < x ∧ x < 1 ∧ 2 ≤ x.den ∧ x.den ∈ admissible α := by
  obtain ⟨h0,h1,hd⟩ := (phase_description α x).mp hx
  exact ⟨h0,h1,admissible_two α x.den hd,hd⟩

private theorem sign_witness (d : ℤ) (hd : |d| = 1) :
    ∃ ε : ℤ, (ε = -1 ∨ ε = 1) ∧ d = ε := by
  have he : d = (1:ℤ) ∨ d = -(1:ℤ) := abs_eq_abs.mp (by simpa using hd)
  rcases he with he|he
  · exact ⟨1,Or.inr rfl,he⟩
  · exact ⟨-1,Or.inl rfl,he⟩

theorem denominator_partner (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) (s : ℕ) (hs : s ∈ admissible α)
  (c : ℤ) :
  (rawValue c s ∈ phases α ∧ (rawValue c s).den = s ∧
    (rawValue c s).num = c ∧ fareyAdj x (rawValue c s)) ↔
  (1 ≤ c ∧ c ≤ (s : ℤ) - 1 ∧
    ∃ ε : ℤ, (ε = -1 ∨ ε = 1) ∧ x.num*(s : ℤ) - c*(x.den : ℤ) = ε) := by
  constructor
  · rintro ⟨hmem,hd,hn,hadj⟩
    have hp := phase_domain α hα _ hmem
    have hi := interior_numerator _ ⟨hp.1,hp.2.1⟩
    rw [hd,hn] at hi
    have hh : |x.num*(s:ℤ)-c*(x.den:ℤ)| = 1 := by simpa only [fareyAdj,det,hd,hn] using hadj
    exact ⟨hi.1,hi.2.1,sign_witness _ hh⟩
  · rintro ⟨hc1,hc2,ε,hε,he⟩
    have habs : |x.num*(s:ℤ)-c*(x.den:ℤ)| = 1 := by
      rw [he]; rcases hε with rfl|rfl <;> norm_num
    have hs2 := admissible_two α s hs
    have hcop := (raw_det_one_coprime x.num c x.den s x.den_pos (by omega) habs).2.1
    have hcan := rawValue_canonical c s (by omega) hcop
    have hsQ : (0:ℚ) < s := by exact_mod_cast (show 0 < s by omega)
    have hcQ : (0:ℚ) < c := by exact_mod_cast (show 0 < c by omega)
    have hltQ : (c:ℚ) < s := by exact_mod_cast (show c < (s:ℤ) by omega)
    have hmem : rawValue c s ∈ phases α := by
      apply (phase_description α _).mpr
      exact ⟨div_pos hcQ hsQ,(div_lt_one hsQ).mpr hltQ,by simpa only [hcan.2] using hs⟩
    refine ⟨hmem,hcan.2,hcan.1,?_⟩
    simpa only [fareyAdj,det,hcan.1,hcan.2] using habs

theorem partner_congruence (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) (s : ℕ) (hs : s ∈ admissible α) :
  (∃ y ∈ phases α, y.den = s ∧ fareyAdj x y) ↔
  ∃ ε : ℤ, (ε = -1 ∨ ε = 1) ∧
    Int.ModEq (x.den : ℤ) (x.num*(s : ℤ)) ε ∧
    1 ≤ (x.num*(s : ℤ) - ε) / (x.den : ℤ) ∧
    (x.num*(s : ℤ) - ε) / (x.den : ℤ) ≤ (s : ℤ) - 1 := by
  constructor
  · rintro ⟨y,hy,hden,hxy⟩
    have heq : rawValue y.num s = y := by rw [← hden]; exact rawValue_num_den y
    have hp := (denominator_partner α hα x hx s hs y.num).mp
      ⟨by simpa only [heq] using hy,by simpa only [heq] using hden,by rw [heq],by simpa only [heq] using hxy⟩
    obtain ⟨hc1,hc2,ε,hε,he⟩ := hp
    have hm : Int.ModEq (x.den:ℤ) (x.num*(s:ℤ)) ε := by
      apply Int.modEq_iff_dvd.mpr
      refine ⟨-y.num,?_⟩
      linarith
    have hquot : (x.num*(s:ℤ)-ε)/(x.den:ℤ) = y.num := by
      rw [show x.num*(s:ℤ)-ε = y.num*(x.den:ℤ) by linarith]
      exact Int.mul_ediv_cancel _ (by exact_mod_cast x.den_ne_zero)
    exact ⟨ε,hε,hm,by simpa only [hquot] using hc1,by simpa only [hquot] using hc2⟩
  · rintro ⟨ε,hε,hm,hc1,hc2⟩
    let c := (x.num*(s:ℤ)-ε)/(x.den:ℤ)
    have hdiv : (x.den:ℤ) ∣ (x.num*(s:ℤ)-ε) := by
      have hh := (Int.modEq_iff_dvd.mp hm).neg_right
      convert hh using 1; ring
    have hmul := Int.ediv_mul_cancel hdiv
    have he : x.num*(s:ℤ)-c*(x.den:ℤ) = ε := by dsimp [c]; linarith
    have hp := (denominator_partner α hα x hx s hs c).mpr ⟨hc1,hc2,ε,hε,he⟩
    exact ⟨rawValue c s,hp.1,hp.2.1,hp.2.2.2⟩

theorem cross_denominator (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x y : ℚ) (hx : x ∈ phases α) (hy : y ∈ phases α)
  (h : fareyAdj x y) : x.den ≠ y.den := by
  intro he
  have hc := (raw_det_one_coprime x.num y.num x.den y.den x.den_pos y.den_pos h).2.2
  rw [← he] at hc
  have hh := hc.gcd_eq_one
  rw [Nat.gcd_self] at hh
  have hp := phase_domain α hα x hx
  omega

theorem isolation_criterion (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) :
  isolated (phases α) x ↔
    ¬ ∃ s ∈ admissible α, ∃ c ε : ℤ,
      (ε = -1 ∨ ε = 1) ∧ 1 ≤ c ∧ c ≤ (s : ℤ) - 1 ∧
      x.num*(s : ℤ) - c*(x.den : ℤ) = ε := by
  constructor
  · intro hi
    rintro ⟨s,hs,c,ε,hε,hc1,hc2,he⟩
    have hp := (denominator_partner α hα x hx s hs c).mpr ⟨hc1,hc2,ε,hε,he⟩
    exact hi.2 _ hp.1 hp.2.2.2
  · intro hn
    refine ⟨hx,?_⟩
    intro y hy hadj
    have hp := phase_domain α hα y hy
    have hr := interior_numerator y ⟨hp.1,hp.2.1⟩
    obtain ⟨ε,hε,he⟩ := sign_witness (det x y) hadj
    exact hn ⟨y.den,hp.2.2.2,y.num,ε,hε,hr.1,hr.2.1,he⟩

private theorem unit_phase (α : List ℕ) (n : ℕ) (hn : n ∈ admissible α) :
    unitFrac n ∈ phases α ∧ (unitFrac n).num = 1 ∧ (unitFrac n).den = n := by
  have hn2 := admissible_two α n hn
  have hc := rawValue_canonical 1 n (by omega) (by simp)
  have hd : (unitFrac n).num = 1 ∧ (unitFrac n).den = n := by simpa [unitFrac,rawValue] using hc
  have hnQ : (1:ℚ) < n := by exact_mod_cast (show 1 < n by omega)
  refine ⟨(phase_description α _).mpr ⟨?_,?_,?_⟩,hd.1,hd.2⟩
  · unfold unitFrac; positivity
  · unfold unitFrac; exact (div_lt_one (by linarith)).mpr hnQ
  · simpa only [hd.2] using hn

theorem endpoint_isolation (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (n : ℕ) (hn : n ∈ admissible α) :
  isolated (phases α) (unitFrac n) ↔
    ¬ ∃ s ∈ admissible α, ∃ ε : ℤ,
      (ε = -1 ∨ ε = 1) ∧ Int.ModEq (n : ℤ) (s : ℤ) ε ∧
      1 ≤ ((s : ℤ) - ε)/(n : ℤ) ∧
      ((s : ℤ) - ε)/(n : ℤ) ≤ (s : ℤ) - 1 := by
  have hu := unit_phase α n hn
  constructor
  · intro hi
    rintro ⟨s,hs,ε,hε,hm,hc1,hc2⟩
    have hp := (partner_congruence α hα (unitFrac n) hu.1 s hs).mpr
      ⟨ε,hε,by simpa only [hu.2.1,hu.2.2,one_mul] using hm,
        by simpa only [hu.2.1,hu.2.2,one_mul] using hc1,
        by simpa only [hu.2.1,hu.2.2,one_mul] using hc2⟩
    obtain ⟨y,hy,hd,hxy⟩ := hp
    exact hi.2 y hy hxy
  · intro hn'
    refine ⟨hu.1,?_⟩
    intro y hy hadj
    have hd := (phase_domain α hα y hy).2.2.2
    have hp := (partner_congruence α hα (unitFrac n) hu.1 y.den hd).mp ⟨y,hy,rfl,hadj⟩
    apply hn'
    refine ⟨y.den,hd,?_⟩
    simpa only [hu.2.1,hu.2.2,one_mul] using hp

private theorem complement_coordinates (x : ℚ) :
    (1-x).den = x.den ∧ (1-x).num = (x.den:ℤ)-x.num := by
  have hd : (1-x).den = x.den := by simp
  have hh := Rat.sub_num_den' 1 x
  have he : (1-x).num*(x.den:ℤ) = ((x.den:ℤ)-x.num)*(x.den:ℤ) := by
    simpa [hd] using hh
  exact ⟨hd,mul_right_cancel₀ (by exact_mod_cast x.den_ne_zero) he⟩

theorem complement_mem (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) : x ∈ phases α ↔ 1 - x ∈ phases α := by
  rw [phase_description,phase_description,(complement_coordinates x).1]
  constructor
  · rintro ⟨h0,h1,hd⟩
    exact ⟨by linarith,by linarith,hd⟩
  · rintro ⟨h0,h1,hd⟩
    exact ⟨by linarith,by linarith,hd⟩

theorem complement_adj (x y : ℚ) (hx : 0 < x ∧ x < 1)
  (hy : 0 < y ∧ y < 1) : fareyAdj (1-x) (1-y) ↔ fareyAdj x y := by
  unfold fareyAdj det
  rw [(complement_coordinates x).1,(complement_coordinates x).2,
    (complement_coordinates y).1,(complement_coordinates y).2]
  rw [show ((x.den:ℤ)-x.num)*(y.den:ℤ)-((y.den:ℤ)-y.num)*(x.den:ℤ) =
    -(x.num*(y.den:ℤ)-y.num*(x.den:ℤ)) by ring,abs_neg]

theorem complement_graph_auto (α : List ℕ) (hα : ∀ a ∈ α, 0 < a) :
  ∃ e : phaseGraph α ≃g phaseGraph α,
    ∀ x : {x : ℚ // x ∈ phases α}, (e x).val = 1 - x.val := by
  classical
  let f : {x : ℚ // x ∈ phases α} → {x : ℚ // x ∈ phases α} :=
    fun x => ⟨1-x.val,(complement_mem α hα x.val).mp x.property⟩
  have hinv : Function.Involutive f := by intro x; apply Subtype.ext; dsimp [f]; ring
  let e : phaseGraph α ≃g phaseGraph α :=
    {toEquiv := {toFun := f, invFun := f, left_inv := hinv, right_inv := hinv}
     map_rel_iff' := by
       intro x y
       change fareyAdj (1-x.val) (1-y.val) ↔ fareyAdj x.val y.val
       have hx := phase_domain α hα x.val x.property
       have hy := phase_domain α hα y.val y.property
       exact complement_adj x.val y.val ⟨hx.1,hx.2.1⟩ ⟨hy.1,hy.2.1⟩}
  exact ⟨e,fun x => rfl⟩

theorem isolated_complement_pairs (α : List ℕ) (hα : ∀ a ∈ α, 0 < a)
  (x : ℚ) (hx : x ∈ phases α) :
  (isolated (phases α) x ↔ isolated (phases α) (1-x)) ∧
    (1-x = x ↔ x = (1/2 : ℚ)) := by
  have forward : ∀ u : ℚ, u ∈ phases α → isolated (phases α) u → isolated (phases α) (1-u) := by
    intro u hu hi
    refine ⟨(complement_mem α hα u).mp hu,?_⟩
    intro y hy hadj
    have hyc := (complement_mem α hα y).mp hy
    have hub := phase_domain α hα u hu
    have hyb := phase_domain α hα (1-y) hyc
    have hc : fareyAdj (1-u) (1-(1-y)) := by
      simpa only [show 1-(1-y) = y by ring] using hadj
    have hh := (complement_adj u (1-y) ⟨hub.1,hub.2.1⟩ ⟨hyb.1,hyb.2.1⟩).mp hc
    exact hi.2 (1-y) hyc hh
  constructor
  · constructor
    · exact forward x hx
    · intro hi
      have hh := forward (1-x) ((complement_mem α hα x).mp hx) hi
      simpa only [show 1-(1-x) = x by ring] using hh
  · constructor <;> intro h <;> linarith

#print axioms FVLT.FareyContactV1.phases_eq_unreduced
#print axioms FVLT.FareyContactV1.phase_domain
#print axioms FVLT.FareyContactV1.denominator_partner
#print axioms FVLT.FareyContactV1.partner_congruence
#print axioms FVLT.FareyContactV1.cross_denominator
#print axioms FVLT.FareyContactV1.isolation_criterion
#print axioms FVLT.FareyContactV1.endpoint_isolation
#print axioms FVLT.FareyContactV1.complement_mem
#print axioms FVLT.FareyContactV1.complement_adj
#print axioms FVLT.FareyContactV1.complement_graph_auto
#print axioms FVLT.FareyContactV1.isolated_complement_pairs
#print axioms admissible_two
#print axioms interior_numerator
#print axioms phase_description
#print axioms sign_witness
#print axioms unit_phase
#print axioms complement_coordinates
end
end FVLT.FareyContactV1
