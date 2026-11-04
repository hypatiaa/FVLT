import FVLTWovenEvolutionV1

/-! Prospective S4n II-1 source. The update canonicalizes NEW labels first.
No compilation is claimed. Real bit lift has white value zero. -/
namespace FVLT.S4nShellTransportV1
open WovenCanonicalV1 WovenEvolutionV1

local instance windowDecidable (L : ℕ) (i : ℤ) : Decidable (InWindow L i) :=
  inferInstanceAs (Decidable (lower L ≤ i ∧ i ≤ upper L))

def Supported (t : ℕ) (f : ℤ → Bool) : Prop :=
  ∀ i, (t : ℤ) < |i| → f i = false

def periodize (L : ℕ) (f : ℤ → Bool) (i : ℤ) : Bool := f (rep L i)
def cut (L : ℕ) (x : ℤ → Bool) (i : ℤ) : Bool :=
  if InWindow L i then x i else false
def compare (L M : ℕ) (x : ℤ → Bool) : ℤ → Bool := periodize M (cut L x)
def fullStep (f : ℤ → Bool) (i : ℤ) : Bool := rule (f (i-1)) (f i) (f (i+1))
def step (Lnext : ℕ) (x : ℤ → Bool) : ℤ → Bool :=
  periodize Lnext (fullStep x)
def bit (b : Bool) : ℝ := if b then 1 else 0
def realCompare (L M : ℕ) (x : ℤ → ℝ) (i : ℤ) : ℝ :=
  if InWindow L (rep M i) then x (rep M i) else 0

theorem actual_weave_step (L : ℕ → ℕ) (t : ℕ) :
    weave L (t+1) = step (L (t+1)) (weave L t) := rfl

theorem compare_read (L M : ℕ) (hM : 0<M) (x : ℤ → Bool)
    (i : ℤ) (hL : InWindow L i) (hi : InWindow M i) :
    compare L M x i = x i := by
  simp [compare, periodize, cut, rep_eq_self M hM i hi, hL]

theorem cut_periodize (L t : ℕ) (hcap : 2*t+1≤L)
    (f : ℤ → Bool) (hs : Supported t f) : cut L (periodize L f) = f := by
  funext i
  by_cases hi : InWindow L i
  · simp [cut, periodize, hi, rep_eq_self L (by omega) i hi]
  · have hout : (t : ℤ) < |i| := by
      by_contra hn
      exact hi (core_in_window L t hcap i (by omega))
    simp [cut, hi, hs i hout]

theorem compare_periodize (L M t : ℕ) (hcap : 2*t+1≤L)
    (f : ℤ → Bool) (hs : Supported t f) :
    compare L M (periodize L f) = periodize M f := by
  unfold compare
  rw [cut_periodize L t hcap f hs]

theorem supported_step (t : ℕ) (f : ℤ → Bool) (hs : Supported t f) :
    Supported (t+1) (fullStep f) := by
  intro i hi
  have hm : (t : ℤ) < |i-1| := by
    by_contra hn
    have hb := abs_le.mp (show |i-1| ≤ (t : ℤ) by omega)
    have hai := abs_le.mpr (show -((t+1 : ℕ) : ℤ) ≤ i ∧ i ≤ ((t+1 : ℕ) : ℤ) by
      push_cast
      omega)
    omega
  have hz : (t : ℤ) < |i| := by omega
  have hp : (t : ℤ) < |i+1| := by
    by_contra hn
    have hb := abs_le.mp (show |i+1| ≤ (t : ℤ) by omega)
    have hai := abs_le.mpr (show -((t+1 : ℕ) : ℤ) ≤ i ∧ i ≤ ((t+1 : ℕ) : ℤ) by
      push_cast
      omega)
    omega
  simp [fullStep, hs (i-1) hm, hs i hz, hs (i+1) hp, rule]

theorem parent_read (L Lnext t : ℕ) (hL : 0<L) (hn : 0<Lnext)
    (hcap : 2*t+1≤L) (hgap : Lnext/2+t+1<L)
    (f : ℤ → Bool) (hs : Supported t f)
    (j delta : ℤ) (hj : InWindow Lnext j) (hd : |delta|≤1) :
    f (rep L (j+delta)) = f (j+delta) := by
  by_cases hi : |j+delta|≤(t : ℤ)
  · rw [rep_core L t hcap _ hi]
  · have ho : (t : ℤ) < |j+delta| := by omega
    rw [hs _ (parent_outside_core L Lnext t hL hn hgap j delta hj hd ho), hs _ ho]

theorem step_periodize (L Lnext t : ℕ) (hL : 0<L) (hn : 0<Lnext)
    (hcap : 2*t+1≤L) (hgap : Lnext/2+t+1<L)
    (f : ℤ → Bool) (hs : Supported t f) :
    step Lnext (periodize L f) = periodize Lnext (fullStep f) := by
  funext i
  let j := rep Lnext i
  have hj : InWindow Lnext j := rep_bounds Lnext hn i
  have hm := parent_read L Lnext t hL hn hcap hgap f hs j (-1) hj (by norm_num)
  have hz := parent_read L Lnext t hL hn hcap hgap f hs j 0 hj (by norm_num)
  have hp := parent_read L Lnext t hL hn hcap hgap f hs j 1 hj (by norm_num)
  simp only [add_zero] at hz
  change rule (f (rep L (j-1))) (f (rep L j)) (f (rep L (j+1))) =
    rule (f (j-1)) (f j) (f (j+1))
  have hm' : f (rep L (j-1)) = f (j-1) := by simpa only [sub_eq_add_neg] using hm
  rw [hm', hz, hp]

/-- Literal three-parent and output-cutoff formula, not an unspecified difference. -/
def defect (L Lnext M Mnext : ℕ) (x : ℤ → Bool) (i : ℤ) : ℝ :=
  let j := rep Mnext i
  bit (rule (compare L M x (j-1)) (compare L M x j) (compare L M x (j+1))) -
    if InWindow Lnext j then bit (rule (x (j-1)) (x j) (x (j+1))) else 0

theorem transport_with_defect (L Lnext M Mnext : ℕ) (hn : 0<Lnext)
    (x : ℤ → Bool) (i : ℤ) :
    bit (step Mnext (compare L M x) i) =
      realCompare Lnext Mnext (fun j => bit (step Lnext x j)) i +
        defect L Lnext M Mnext x i := by
  let j := rep Mnext i
  by_cases hj : InWindow Lnext j
  · simp [step, periodize, fullStep, realCompare, defect, j,
      rep_eq_self Lnext hn j hj, hj]
  · simp [step, periodize, fullStep, realCompare, defect, j, hj]

/-- A row-independent radius-one localization guard. -/
def LocalGuard (L Lnext M Mnext : ℕ) (i : ℤ) : Prop :=
  let j := rep Mnext i
  InWindow Lnext j ∧ ∀ delta : ℤ, |delta|≤1 →
    InWindow L (j+delta) ∧ InWindow M (j+delta)

theorem defect_localized (L Lnext M Mnext : ℕ) (hM : 0<M)
    (x : ℤ → Bool) (i : ℤ) (hg : LocalGuard L Lnext M Mnext i) :
    defect L Lnext M Mnext x i = 0 := by
  rcases hg with ⟨hj, hp⟩
  have hm := compare_read L M hM x (rep Mnext i-1)
    (by simpa only [sub_eq_add_neg] using (hp (-1) (by norm_num)).1)
    (by simpa only [sub_eq_add_neg] using (hp (-1) (by norm_num)).2)
  have hz := compare_read L M hM x (rep Mnext i)
    (by simpa using (hp 0 (by norm_num)).1)
    (by simpa using (hp 0 (by norm_num)).2)
  have hh := compare_read L M hM x (rep Mnext i+1)
    (hp 1 (by norm_num)).1 (hp 1 (by norm_num)).2
  simp [defect, hj, hm, hz, hh]

theorem halo_transport (L Lnext M Mnext t : ℕ)
    (hL : 0<L) (hn : 0<Lnext) (hM : 0<M) (hmn : 0<Mnext)
    (hcapL : 2*t+1≤L) (hcapM : 2*t+1≤M)
    (hcapNext : 2*(t+1)+1≤Lnext)
    (hgapL : Lnext/2+t+1<L) (hgapM : Mnext/2+t+1<M)
    (f : ℤ → Bool) (hs : Supported t f) :
    step Mnext (compare L M (periodize L f)) =
      compare Lnext Mnext (step Lnext (periodize L f)) := by
  rw [compare_periodize L M t hcapL f hs,
    step_periodize M Mnext t hM hmn hcapM hgapM f hs,
    step_periodize L Lnext t hL hn hcapL hgapL f hs,
    compare_periodize Lnext Mnext (t+1) hcapNext (fullStep f) (supported_step t f hs)]

theorem halo_defect_zero (L Lnext M Mnext t : ℕ)
    (hL : 0<L) (hn : 0<Lnext) (hM : 0<M) (hmn : 0<Mnext)
    (hcapL : 2*t+1≤L) (hcapM : 2*t+1≤M)
    (hcapNext : 2*(t+1)+1≤Lnext)
    (hgapL : Lnext/2+t+1<L) (hgapM : Mnext/2+t+1<M)
    (f : ℤ → Bool) (hs : Supported t f) (i : ℤ) :
    defect L Lnext M Mnext (periodize L f) i = 0 := by
  have he := congrFun (halo_transport L Lnext M Mnext t hL hn hM hmn
    hcapL hcapM hcapNext hgapL hgapM f hs) i
  have hb : bit (compare Lnext Mnext (step Lnext (periodize L f)) i) =
      realCompare Lnext Mnext (fun j => bit (step Lnext (periodize L f) j)) i := by
    simp only [compare, periodize, cut, realCompare]
    split <;> simp_all [bit]
  have ht := transport_with_defect L Lnext M Mnext hn (periodize L f) i
  rw [he, hb] at ht
  linarith

theorem fixed_padding_guard (C t : ℕ) (hC : 5≤C) :
    (2*(t+1)+C)/2+t+1 < 2*t+C := by omega

end FVLT.S4nShellTransportV1
