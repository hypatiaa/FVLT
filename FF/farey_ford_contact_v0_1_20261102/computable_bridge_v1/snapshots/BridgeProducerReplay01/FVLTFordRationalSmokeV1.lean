import FVLTFordRationalV1

/-! Finite executable evidence, separate from theorem/replay targets. -/
open FVLT.FordExactCoordinatesV1

def checks : List (String × Bool) := [
  ("zero.radius", decide (radiusQ 0 = (1/2 : ℚ))),
  ("zero.centre.re", decide ((centreQ 0).1 = 0)),
  ("zero.centre.im", decide ((centreQ 0).2 = (1/2 : ℚ))),
  ("one.radius", decide (radiusQ 1 = (1/2 : ℚ))),
  ("one.centre.re", decide ((centreQ 1).1 = 1)),
  ("one.centre.im", decide ((centreQ 1).2 = (1/2 : ℚ))),
  ("half.radius", decide (radiusQ (1/2) = (1/8 : ℚ))),
  ("half.centre.re", decide ((centreQ (1/2)).1 = (1/2 : ℚ))),
  ("half.centre.im", decide ((centreQ (1/2)).2 = (1/8 : ℚ))),
  ("negative.radius", decide (radiusQ (-3/4) = (1/32 : ℚ))),
  ("negative.centre.re", decide ((centreQ (-3/4)).1 = (-3/4 : ℚ))),
  ("negative.centre.im", decide ((centreQ (-3/4)).2 = (1/32 : ℚ))),
  ("adjacent.kissN", decide (kissNQ (1/2) (1/3) = 5)),
  ("adjacent.kissM", decide (kissMQ (1/2) (1/3) = 13)),
  ("adjacent.kiss.re", decide ((kissQ (1/2) (1/3)).1 = (5/13 : ℚ))),
  ("adjacent.kiss.im", decide ((kissQ (1/2) (1/3)).2 = (1/13 : ℚ))),
  ("adjacent.boundary.x", boundaryCheckQ (1/2) (kissQ (1/2) (1/3))),
  ("adjacent.boundary.y", boundaryCheckQ (1/3) (kissQ (1/2) (1/3))),
  ("nonadjacent.kissN", decide (kissNQ (1/3) (1/5) = 8)),
  ("nonadjacent.kissM", decide (kissMQ (1/3) (1/5) = 34)),
  ("nonadjacent.kiss.re", decide ((kissQ (1/3) (1/5)).1 = (4/17 : ℚ))),
  ("nonadjacent.kiss.im", decide ((kissQ (1/3) (1/5)).2 = (1/34 : ℚ))),
  ("nonadjacent.boundary.x", !(boundaryCheckQ (1/3) (kissQ (1/3) (1/5)))),
  ("nonadjacent.boundary.y", !(boundaryCheckQ (1/5) (kissQ (1/3) (1/5))))]

def main : IO UInt32 := do
  for item in checks do
    IO.println s!"{item.1}={item.2}"
  let failed := (checks.filter (fun item => !item.2)).length
  IO.println s!"groups=6 comparisons={checks.length} pass={checks.length-failed} fail={failed}"
  return if failed = 0 ∧ checks.length = 24 then 0 else 1
