import FVLTFareyCertificatesV1
import Mathlib.Data.Rat.Lemmas
import Mathlib.Tactic

/-! FF-1 R1: classical reduced-fraction and mediant arithmetic.
Framework assembled by Robin Miller; classical components: Farey, Ford (1938),
Apostol, ch. 5. Structural reference: Paulson, Farey Sequences and Ford Circles,
Isabelle AFP (2025). No novelty or Rule 30 claim.
-/
namespace FVLT.FareyContactV1

def rawValue (a : ℤ) (q : ℕ) : ℚ := (a : ℚ) / (q : ℚ)
def mediant (x y : ℚ) : ℚ :=
  rawValue (x.num + y.num) (x.den + y.den)
def unitFrac (a : ℕ) : ℚ := 1 / (a : ℚ)

private theorem coprime_from_det (a b c d : ℤ)
    (h : |a*d-c*b| = 1) : Nat.Coprime a.natAbs b.natAbs := by
  apply Nat.dvd_one.mp
  apply Int.natCast_dvd_natCast.mp
  change (Nat.gcd a.natAbs b.natAbs : ℤ) ∣ (1 : ℤ)
  rw [← h]
  apply (dvd_abs _ _).mpr
  have ha : (Nat.gcd a.natAbs b.natAbs : ℤ) ∣ a :=
    Int.natCast_dvd.mpr (Nat.gcd_dvd_left _ _)
  have hb : (Nat.gcd a.natAbs b.natAbs : ℤ) ∣ b :=
    Int.natCast_dvd.mpr (Nat.gcd_dvd_right _ _)
  exact dvd_sub (dvd_mul_of_dvd_left ha d) (dvd_mul_of_dvd_right hb c)

theorem raw_det_one_coprime (a c : ℤ) (q s : ℕ)
  (hq : 0 < q) (hs : 0 < s)
  (hdet : |a * (s : ℤ) - c * (q : ℤ)| = 1) :
  Nat.Coprime a.natAbs q ∧ Nat.Coprime c.natAbs s ∧ Nat.Coprime q s := by
  have h1 := coprime_from_det a (q : ℤ) c (s : ℤ) hdet
  have h2 := coprime_from_det c (s : ℤ) a (q : ℤ) (by
    rw [show c*(q:ℤ)-a*(s:ℤ) = -(a*(s:ℤ)-c*(q:ℤ)) by ring, abs_neg]
    exact hdet)
  have h3 := coprime_from_det (q : ℤ) (s : ℤ) (-a) (-c) (by
    convert hdet using 1 <;> congr 1 <;> ring)
  simpa using And.intro h1 (And.intro h2 h3)

theorem rawValue_num_den (x : ℚ) : rawValue x.num x.den = x := by
  exact Rat.num_div_den x

theorem rawValue_canonical (a : ℤ) (q : ℕ) (hq : 0 < q)
  (hred : Nat.Coprime a.natAbs q) :
  (rawValue a q).num = a ∧ (rawValue a q).den = q := by
  have hp : (0 : ℤ) < (q : ℤ) := by exact_mod_cast hq
  have hc : Nat.Coprime a.natAbs (q : ℤ).natAbs := by simpa using hred
  constructor
  · simpa [rawValue] using Rat.num_div_eq_of_coprime hp hc
  · have hd := Rat.den_div_eq_of_coprime hp hc
    have hd' : ((rawValue a q).den : ℤ) = (q : ℤ) := by simpa [rawValue] using hd
    exact_mod_cast hd'

theorem rawValue_unique (a c : ℤ) (q s : ℕ)
  (hq : 0 < q) (hs : 0 < s)
  (ha : Nat.Coprime a.natAbs q) (hc : Nat.Coprime c.natAbs s) :
  rawValue a q = rawValue c s ↔ a = c ∧ q = s := by
  constructor
  · intro h
    have hn := congrArg Rat.num h
    have hd := congrArg Rat.den h
    simpa only [(rawValue_canonical a q hq ha).1,
      (rawValue_canonical c s hs hc).1,
      (rawValue_canonical a q hq ha).2,
      (rawValue_canonical c s hs hc).2] using And.intro hn hd
  · rintro ⟨rfl, rfl⟩
    rfl

theorem coprime_den_not_adj :
  Nat.Coprime (unitFrac 3).den (unitFrac 5).den ∧
  ¬ fareyAdj (unitFrac 3) (unitFrac 5) ∧
  |det (unitFrac 3) (unitFrac 5)| = 2 := by
  decide +kernel

theorem adjacent_mediant (x y : ℚ) (hxy : x < y) (h : fareyAdj x y) :
  Nat.Coprime (x.num + y.num).natAbs (x.den + y.den) ∧
  (mediant x y).num = x.num + y.num ∧
  (mediant x y).den = x.den + y.den ∧
  x < mediant x y ∧ mediant x y < y ∧
  fareyAdj x (mediant x y) ∧ fareyAdj (mediant x y) y := by
  have hh : |(x.num+y.num)*(x.den:ℤ)-x.num*((x.den+y.den:ℕ):ℤ)| = 1 := by
    rw [show (x.num+y.num)*(x.den:ℤ)-x.num*((x.den+y.den:ℕ):ℤ) =
      -(x.num*(y.den:ℤ)-y.num*(x.den:ℤ)) by push_cast; ring, abs_neg]
    exact h
  have hs : 0 < x.den+y.den := by have := x.den_pos; omega
  have hc := (raw_det_one_coprime (x.num+y.num) x.num (x.den+y.den) x.den hs x.den_pos hh).1
  have hd := rawValue_canonical (x.num+y.num) (x.den+y.den) hs hc
  change (mediant x y).num = _ ∧ (mediant x y).den = _ at hd
  have hx : (0 : ℚ) < x.den := by exact_mod_cast x.den_pos
  have hy : (0 : ℚ) < y.den := by exact_mod_cast y.den_pos
  have hcross : (x.num : ℚ)*(y.den:ℚ) < (y.num:ℚ)*(x.den:ℚ) := by
    apply (div_lt_div_iff₀ hx hy).mp
    simpa only [Rat.num_div_den] using hxy
  have hleft : x < mediant x y := by
    have hh' : (x.num:ℚ)/(x.den:ℚ) <
        ((x.num:ℚ)+(y.num:ℚ))/((x.den:ℚ)+(y.den:ℚ)) := by
      apply (div_lt_div_iff₀ hx (add_pos hx hy)).mpr
      nlinarith
    simpa only [mediant,rawValue,Int.cast_add,Nat.cast_add,Rat.num_div_den] using hh'
  have hright : mediant x y < y := by
    have hh' : ((x.num:ℚ)+(y.num:ℚ))/((x.den:ℚ)+(y.den:ℚ)) <
        (y.num:ℚ)/(y.den:ℚ) := by
      apply (div_lt_div_iff₀ (add_pos hx hy) hy).mpr
      nlinarith
    simpa only [mediant,rawValue,Int.cast_add,Nat.cast_add,Rat.num_div_den] using hh'
  refine ⟨hc, hd.1, hd.2, hleft, hright, ?_, ?_⟩
  · unfold fareyAdj det
    rw [hd.1, hd.2]
    convert h using 1 <;> unfold fareyAdj det <;> congr 1 <;> push_cast <;> ring
  · unfold fareyAdj det
    rw [hd.1, hd.2]
    convert h using 1 <;> unfold fareyAdj det <;> congr 1 <;> push_cast <;> ring

private theorem unitFrac_data (a : ℕ) (ha : 0 < a) :
    (unitFrac a).num = 1 ∧ (unitFrac a).den = a := by
  simpa [unitFrac, rawValue] using rawValue_canonical 1 a ha (by simp)

theorem rosette (N : ℕ) (hN : 2 ≤ N) :
  |det (unitFrac (N - 1)) (unitFrac (N + 1))| = 2 ∧
  mediant (unitFrac (N - 1)) (unitFrac (N + 1)) = unitFrac N ∧
  fareyAdj (unitFrac N) (unitFrac (N - 1)) ∧
  fareyAdj (unitFrac N) (unitFrac (N + 1)) := by
  have hm := unitFrac_data (N-1) (by omega)
  have hp := unitFrac_data (N+1) (by omega)
  have hn := unitFrac_data N (by omega)
  have hminus : ((N-1:ℕ):ℤ) = (N:ℤ)-1 := by omega
  have hminusQ : ((N-1:ℕ):ℚ) = (N:ℚ)-1 := by exact_mod_cast hminus
  have hq : (N:ℚ) ≠ 0 := by exact_mod_cast (show N ≠ 0 by omega)
  refine ⟨?_, ?_, ?_, ?_⟩
  · simp [det, hm.1,hm.2,hp.1,hp.2,hminus]
  · unfold mediant
    rw [hm.1,hp.1,hm.2,hp.2]
    unfold rawValue unitFrac
    push_cast
    rw [hminusQ]
    field_simp
    <;> ring
  · simp [fareyAdj,det,hn.1,hn.2,hm.1,hm.2,hminus]
  · simp [fareyAdj,det,hn.1,hn.2,hp.1,hp.2]

#print axioms FVLT.FareyContactV1.raw_det_one_coprime
#print axioms FVLT.FareyContactV1.rawValue_num_den
#print axioms FVLT.FareyContactV1.rawValue_canonical
#print axioms FVLT.FareyContactV1.rawValue_unique
#print axioms FVLT.FareyContactV1.coprime_den_not_adj
#print axioms FVLT.FareyContactV1.adjacent_mediant
#print axioms FVLT.FareyContactV1.rosette
end FVLT.FareyContactV1
