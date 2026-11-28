import Lean

open Lean

private def forbidden : List Name :=
  [`ZMod.wilsons_lemma, `Nat.prime_iff_fac_equiv_neg_one,
   `FiniteField.prod_univ_units_id_eq_neg_one]

private def allowedAxioms : List Name := [`propext, `Classical.choice, `Quot.sound]

private def edges (info : ConstantInfo) : NameSet := Id.run do
  let used := info.getUsedConstantsAsSet
  match info with
  | .inductInfo i => return used ++ NameSet.ofList i.all
  | .ctorInfo c => return used.insert c.induct
  | .recInfo r =>
    return r.rules.foldl (fun acc rule =>
      (acc.insert rule.ctor) ++ rule.rhs.getUsedConstantsAsSet) used
  | _ => return used

private def closure (env : Environment) (root : Name) : IO (Std.HashSet Name) := do
  let mut pending := [root]
  let mut seen : Std.HashSet Name := {}
  repeat
    let n :: rest := pending | break
    pending := rest
    unless seen.contains n do
      let some info := env.find? n | throw <| IO.userError s!"Missing declaration: {n}"
      seen := seen.insert n
      if let .axiomInfo _ := info then
        unless allowedAxioms.contains n do
          throw <| IO.userError s!"Unexpected axiom under {root}: {n}"
      for dep in edges info do
        unless seen.contains dep do pending := dep :: pending
  return seen

def main : IO Unit := do
  initSearchPath (← findSysroot)
  -- Private olean data includes imported proof bodies, also for opaque declarations.
  let env ← importModules #[{module := `WilsonMechanism}] {} (level := .private)
  let roots := [`WilsonMechanism.wilson_from_polygon,
                `WilsonMechanism.active_gate_iff_prime_via_polygon]
  for root in roots do
    let seen ← closure env root
    for n in forbidden do
      if seen.contains n then throw <| IO.userError s!"Forbidden dependency under {root}: {n}"
    for n in [`WilsonMechanism.mirror_pair, `WilsonMechanism.self_paired_iff,
              `WilsonMechanism.prod_vertices_even, `WilsonMechanism.units_are_polygon,
              `WilsonMechanism.inverse_is_mirror, `WilsonMechanism.self_inverse_units] do
      unless seen.contains n do throw <| IO.userError s!"Missing polygon dependency under {root}: {n}"
    if root == `WilsonMechanism.active_gate_iff_prime_via_polygon &&
        !seen.contains `WilsonMechanism.wilson_from_polygon then
      throw <| IO.userError "The gate does not depend on the prime-direction theorem."
    let axioms := allowedAxioms.filter seen.contains
    IO.println s!"PASS {root}: {seen.size} declarations; all six polygon lemmas reached; excluded {forbidden}; axioms {axioms}"
