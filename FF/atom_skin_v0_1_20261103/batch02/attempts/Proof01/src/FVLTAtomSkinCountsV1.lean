import FVLTAtomSkinDataV1
import Mathlib.Data.Fintype.Powerset

namespace FVLT.AtomSkinV1

theorem vertex_count (ω : ℕ) (hω : 3 ≤ ω) :
    Fintype.card (Vertex ω) = 2 ^ ω := by
  simpa only [Fintype.card_fin] using (Fintype.card_finset (α := Fin ω))

theorem cube_genus_zero (h3 : 3 ≤ (3 : ℕ)) : genus 3 h3 = 0 := by
  decide

end FVLT.AtomSkinV1
