import Lean
open Lean

/-! Axiom audit for a theorem-library version.

Run from the library folder: `lake env lean --run ../tools/AxiomCheck.lean Mod1 Mod2 ...`.
For every constant declared in the named modules, it collects the axioms the constant depends
on. It prints one line per module, then `AXIOMS_OK` if every axiom is one of the three standard
ones, or `AXIOMS_FAIL` with the offending constants. `sorryAx` and `Lean.ofReduceBool`
(`native_decide`) count as offending. -/

def standard : List Name := [``propext, ``Classical.choice, ``Quot.sound]

def axiomsOf (env : Environment) (c : Name) : IO (Array Name) := do
  let (axs, _) ← (collectAxioms c : CoreM (Array Name)).toIO
    { fileName := "<axiom-check>", fileMap := default } { env }
  return axs

def main (args : List String) : IO UInt32 := do
  initSearchPath (← findSysroot)
  let mods := args.toArray.map String.toName
  let env ← importModules (mods.map fun m => { module := m }) {} (trustLevel := 1024)
  let mut bad : Array (Name × Name) := #[]
  let mut total := 0
  for m in mods do
    let some idx := env.getModuleIdx? m | throw <| IO.userError s!"module not loaded: {m}"
    let consts := env.header.moduleData[idx.toNat]!.constNames
    let mut seen : Std.HashSet Name := {}
    for c in consts do
      for ax in (← axiomsOf env c) do
        seen := seen.insert ax
        unless standard.contains ax do bad := bad.push (c, ax)
    total := total + consts.size
    let axs := seen.toList.map toString |>.toArray.qsort (· < ·)
    IO.println s!"{m}: {consts.size} constants, axioms {axs.toList}"
  if bad.isEmpty then
    IO.println s!"AXIOMS_OK modules={mods.size} constants={total}"
    return 0
  else
    for (c, ax) in bad do IO.println s!"OFFENDING {c} uses {ax}"
    IO.println s!"AXIOMS_FAIL offending={bad.size}"
    return 1
