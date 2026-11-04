import FVLTWovenEvolutionV1

/-!
Packed finite certificates for the actual current-canonical-label recurrence.
The checker compares every represented cell at every certified transition.
It does not recursively evaluate the exponential infinite-row expression.
-/
namespace FVLT.WovenCertificateV1
open WovenCanonicalV1 WovenEvolutionV1

def label (L : ℕ) (b : Fin L) : ℤ := (b.val : ℤ) - offset L

def readPacked (L bits : ℕ) (i : ℤ) : Bool :=
  bits.testBit (rep L i + offset L).toNat

theorem readPacked_rep (L : ℕ) (hL : 0 < L) (bits : ℕ) (i : ℤ) :
    readPacked L bits (rep L i) = readPacked L bits i := by
  simp only [readPacked, rep_idempotent L hL]

theorem representative_has_index (L : ℕ) (hL : 0 < L) (i : ℤ) :
    ∃ b : Fin L, label L b = rep L i := by
  have hr := rep_bounds L hL i
  have hp := half_partition_int L hL
  have hn : 0 ≤ rep L i + offset L := by
    have h := hr.1
    change -offset L ≤ rep L i at h
    omega
  have hu : rep L i + offset L < (L : ℤ) := by
    have h := hr.2
    omega
  have hb : (rep L i + offset L).toNat < L := by omega
  refine ⟨⟨(rep L i + offset L).toNat, hb⟩, ?_⟩
  have he := Int.toNat_of_nonneg hn
  dsimp [label]
  omega

def BaseCheck (L bits : ℕ) : Prop :=
  ∀ b : Fin L, readPacked L bits (label L b) = decide (label L b = 0)

def RowCheck (L Lnext before after : ℕ) : Prop :=
  ∀ b : Fin Lnext,
    readPacked Lnext after (label Lnext b) =
      rule (readPacked L before (label Lnext b - 1))
        (readPacked L before (label Lnext b))
        (readPacked L before (label Lnext b + 1))

def CertifiedRun (L : ℕ → ℕ) (n : ℕ) (rows : ℕ → ℕ) : Prop :=
  BaseCheck (L 0) (rows 0) ∧
    ∀ t : Fin n, RowCheck (L t.val) (L (t.val + 1)) (rows t.val) (rows (t.val + 1))

theorem baseCheck_all (L : ℕ) (hL : 0 < L) (bits : ℕ)
    (h : BaseCheck L bits) (i : ℤ) :
    readPacked L bits i = decide (rep L i = 0) := by
  obtain ⟨b, hb⟩ := representative_has_index L hL i
  have he := h b
  rw [hb] at he
  exact (readPacked_rep L hL bits i).symm.trans he

theorem rowCheck_all (L Lnext before after : ℕ) (hnext : 0 < Lnext)
    (h : RowCheck L Lnext before after) (i : ℤ) :
    readPacked Lnext after i =
      rule (readPacked L before (rep Lnext i - 1))
        (readPacked L before (rep Lnext i))
        (readPacked L before (rep Lnext i + 1)) := by
  obtain ⟨b, hb⟩ := representative_has_index Lnext hnext i
  have he := h b
  rw [hb] at he
  exact (readPacked_rep Lnext hnext after i).symm.trans he

/-- Soundness checks all cells; packed values are not assumed to be real dynamics. -/
theorem certifiedRun_sound (L : ℕ → ℕ) (hpos : ∀ t, 0 < L t)
    (n : ℕ) (rows : ℕ → ℕ) (h : CertifiedRun L n rows) :
    ∀ t, t ≤ n → ∀ i : ℤ, weave L t i = readPacked (L t) (rows t) i := by
  intro t
  induction t with
  | zero =>
    intro _ i
    exact (baseCheck_all (L 0) (hpos 0) (rows 0) h.1 i).symm
  | succ t ih =>
    intro ht i
    have ht' : t < n := by omega
    have he := rowCheck_all (L t) (L (t + 1)) (rows t) (rows (t + 1))
      (hpos (t + 1)) (h.2 ⟨t, ht'⟩) i
    change rule (weave L t (rep (L (t + 1)) i - 1))
      (weave L t (rep (L (t + 1)) i))
      (weave L t (rep (L (t + 1)) i + 1)) = _
    rw [ih (by omega) _, ih (by omega) _, ih (by omega) _]
    exact he.symm

/-- Each bit position b stores canonical integer label b-50. -/
def fixed101Rows : List ℕ := [
  1125899906842624,
  3940649673949184,
  5348024557502464,
  17310711067705344,
  19351404648857600,
  67378072550113280,
  81399044827512832,
  284808695966072832,
  296195238383321088,
  1019772845506428928,
  1403455124600258560,
  4398677081022529536,
  5015255988966522880,
  17072705695515672576,
  21267019092904116224,
  73351450771184418816,
  74802428386064990208,
  259637276061772808192,
  354944794560020086784,
  1139397136915877593088,
  1262372620236773916672,
  4402005331785461792768,
  5362755220147911262208,
  18715511120099167698944,
  19239539394237494722560,
  67257640218969084264448,
  90962725649700286889984,
  289940102630340684677120,
  326961751144669602906112,
  1122884617561556478066688,
  1380860974264786000805888,
  4829466040807126640099328,
  4848176815183541092220928,
  16956807161050204617441280,
  23019245218745317376327680,
  74475344057644543859589120,
  83314028180846950572408832,
  289139335991198444740894720,
  350478516300307779649875968,
  1221230306975740245371508736,
  1275893642044932949534329856,
  4372982330406729129778411008,
  6020155618213614007145337600,
  18912902409211841174171237760,
  21556008070440029678642775232,
  73264020941951090175155007328,
  91466100817732518513896300848,
  314700345459127114073424835544,
  321026680867681184660861721676,
  1115840459114243235042027955958,
  1521755834504317905508856838675,
  2363713705874918480787846581052]

def fixed101Cert (t : ℕ) : ℕ := fixed101Rows.getD t 0

set_option maxRecDepth 4096 in
theorem fixed101_certified : CertifiedRun (fun _ => 101) 51 fixed101Cert := by
  unfold CertifiedRun BaseCheck RowCheck
  decide +kernel

theorem fixed101_final_read : readPacked 101 (fixed101Cert 51) 51 = false := by
  decide

theorem fixed101_row51_false : weave (fun _ => 101) 51 51 = false := by
  have h := certifiedRun_sound (fun _ => 101) (by intro t; norm_num)
    51 fixed101Cert fixed101_certified 51 le_rfl 51
  exact h.trans fixed101_final_read

theorem infinite_right_edge : ∀ t : ℕ, infinite t (t : ℤ) = true
  | 0 => rfl
  | t + 1 => by
    have he : ((t + 1 : ℕ) : ℤ) - 1 = (t : ℤ) := by omega
    change rule (infinite t (((t + 1 : ℕ) : ℤ) - 1))
      (infinite t ((t + 1 : ℕ) : ℤ))
      (infinite t (((t + 1 : ℕ) : ℤ) + 1)) = true
    rw [he, infinite_right_edge t,
      infinite_right_false t _ (by omega), infinite_right_false t _ (by omega)]
    rfl

theorem safe_growing_row51_true : weave (fun t => 2 * t + 5) 51 51 = true := by
  have he : infinite 51 (51 : ℤ) = true := by simpa using infinite_right_edge 51
  rw [linear_two_plus_five 51 51 (by norm_num)]
  exact he

theorem fixed101_row51_mismatch : weave (fun _ => 101) 51 51 ≠ infinite 51 51 := by
  have he : infinite 51 (51 : ℤ) = true := by simpa using infinite_right_edge 51
  rw [fixed101_row51_false, he]
  decide

theorem fixed101_differs_from_safe_row51 :
    weave (fun _ => 101) 51 51 ≠ weave (fun t => 2 * t + 5) 51 51 := by
  rw [fixed101_row51_false, safe_growing_row51_true]
  decide

end FVLT.WovenCertificateV1
