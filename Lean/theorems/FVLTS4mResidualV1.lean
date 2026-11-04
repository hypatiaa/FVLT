import Mathlib.Tactic

/-!
SOURCE ONLY: no compilation or syntax check authorized by this file.
Root must preregister/pin/post and receive the execution gate first.

Generic exact residual identities for a total stream operator.  The P2 body
operator is NOT identified with the kit's temporal Theta.  The intended fixed
leading-output strips are lead=1 for physical driver10 and lead=0 for driver01;
the identities are valid for every fixed natural lead and do not assert the
map-specific coordinate theorem.  No survival, death, mortality, finite state
assumption, or uncompiled own-seat core module enters the definitions.
-/

set_option autoImplicit false

namespace FVLTS4mResidualV1

abbrev Stream := Nat → Bool
abbrev Prefix (n : Nat) := Fin n → Bool
abbrev StreamOperator := Stream → Stream
abbrev ResidualFunction := Stream → Stream

/-- Exact finite-prefix/continuation concatenation, in physical input order. -/
def prefixAppend {n : Nat} (u : Prefix n) (z : Stream) : Stream :=
  fun i => if h : i < n then u ⟨i, h⟩ else z (i - n)

/-- Add a single input bit at the right end of a finite prefix. -/
def appendBit {n : Nat} (u : Prefix n) (b : Bool) : Prefix (n + 1) :=
  fun i => if h : i.val < n then u ⟨i.val, h⟩ else b

/-- Add a bit at the left end of an infinite continuation. -/
def streamCons (b : Bool) (z : Stream) : Stream :=
  fun i => if i = 0 then b else z (i - 1)

def zeroStream : Stream := fun _ => false

/-- Strip precisely n+lead physical output coordinates after n input bits.
The fixed lead is a parameter of the operator convention, never fitted to u. -/
def residual (f : StreamOperator) (lead : Nat) {n : Nat}
    (u : Prefix n) : ResidualFunction :=
  fun z k => f (prefixAppend u z) (n + lead + k)

/-- Equality of residual FUNCTIONS across all continuations and all output
depths; prefixes may have different lengths but the function space is common. -/
def GlobalEquiv (f : StreamOperator) (lead : Nat)
    {n m : Nat} (u : Prefix n) (v : Prefix m) : Prop :=
  ∀ z k, residual f lead u z k = residual f lead v z k

/-- The work-order's same-level residual equivalence is a specialization,
not a replacement for the across-length relation needed for finite state. -/
def LevelEquiv (f : StreamOperator) (lead n : Nat)
    (u v : Prefix n) : Prop := GlobalEquiv f lead u v

/-- A SEPARATE, map-specific output-causality obligation.  Once the next
input b is supplied, the next residual output cannot depend on its tail.
Nothing below assumes every stream operator satisfies this predicate. -/
def NextHeadCausal (f : StreamOperator) (lead : Nat) : Prop :=
  ∀ (n : Nat) (u : Prefix n) (b : Bool) (z z' : Stream),
    residual f lead u (streamCons b z) 0 =
      residual f lead u (streamCons b z') 0

/-- Canonical evaluation.  Its agreement with arbitrary continuation tails
is justified only after NextHeadCausal is established for the actual map. -/
def emittedHead (f : StreamOperator) (lead : Nat) {n : Nat}
    (u : Prefix n) (b : Bool) : Bool :=
  residual f lead u (streamCons b zeroStream) 0

theorem prefixAppend_empty (u : Prefix 0) (z : Stream) :
    prefixAppend u z = z := by
  funext i
  simp [prefixAppend]

theorem prefixAppend_appendBit {n : Nat} (u : Prefix n)
    (b : Bool) (z : Stream) :
    prefixAppend (appendBit u b) z = prefixAppend u (streamCons b z) := by
  funext i
  by_cases h : i < n
  · have h' : i < n + 1 := by omega
    simp [prefixAppend, appendBit, h, h']
  · by_cases hi : i = n
    · subst i
      simp [prefixAppend, appendBit, streamCons]
    · have h' : ¬ i < n + 1 := by omega
      have hn : i - n ≠ 0 := by omega
      simp [prefixAppend, appendBit, h, h', streamCons, hn, Nat.sub_sub]

theorem globalEquiv_iff_residual_eq (f : StreamOperator) (lead : Nat)
    {n m : Nat} (u : Prefix n) (v : Prefix m) :
    GlobalEquiv f lead u v ↔ residual f lead u = residual f lead v := by
  constructor
  · intro h
    funext z k
    exact h z k
  · intro h z k
    exact congrFun (congrFun h z) k

theorem globalEquiv_refl (f : StreamOperator) (lead : Nat)
    {n : Nat} (u : Prefix n) : GlobalEquiv f lead u u := by
  intro z k
  rfl

theorem globalEquiv_symm (f : StreamOperator) (lead : Nat)
    {n m : Nat} {u : Prefix n} {v : Prefix m}
    (h : GlobalEquiv f lead u v) : GlobalEquiv f lead v u := by
  intro z k
  exact (h z k).symm

theorem globalEquiv_trans (f : StreamOperator) (lead : Nat)
    {n m r : Nat} {u : Prefix n} {v : Prefix m} {w : Prefix r}
    (huv : GlobalEquiv f lead u v) (hvw : GlobalEquiv f lead v w) :
    GlobalEquiv f lead u w := by
  intro z k
  exact (huv z k).trans (hvw z k)

/-- The exact next residual is the right derivative of the old residual:
consume input b, discard output coordinate0, then reindex k to k+1. -/
theorem residual_rightDerivative (f : StreamOperator) (lead : Nat)
    {n : Nat} (u : Prefix n) (b : Bool) (z : Stream) (k : Nat) :
    residual f lead (appendBit u b) z k =
      residual f lead u (streamCons b z) (k + 1) := by
  unfold residual
  rw [prefixAppend_appendBit]
  congr 1 <;> omega

/-- Global exact equivalence is preserved by consuming the same input bit.
This uses ALL continuations, not a bounded observation table. -/
theorem globalEquiv_appendBit (f : StreamOperator) (lead : Nat)
    {n m : Nat} {u : Prefix n} {v : Prefix m}
    (h : GlobalEquiv f lead u v) (b : Bool) :
    GlobalEquiv f lead (appendBit u b) (appendBit v b) := by
  intro z k
  calc
    residual f lead (appendBit u b) z k =
        residual f lead u (streamCons b z) (k + 1) :=
      residual_rightDerivative f lead u b z k
    _ = residual f lead v (streamCons b z) (k + 1) := h _ _
    _ = residual f lead (appendBit v b) z k :=
      (residual_rightDerivative f lead v b z k).symm

theorem levelEquiv_appendBit (f : StreamOperator) (lead n : Nat)
    {u v : Prefix n} (h : LevelEquiv f lead n u v) (b : Bool) :
    LevelEquiv f lead (n + 1) (appendBit u b) (appendBit v b) := by
  exact globalEquiv_appendBit f lead h b

/-- Output law is conditional on a separately proved causality guard.
This gives no finite representative family and no finite-state conclusion. -/
theorem emittedHead_eq_of_nextHeadCausal (f : StreamOperator) (lead : Nat)
    (hf : NextHeadCausal f lead) {n : Nat} (u : Prefix n)
    (b : Bool) (z : Stream) :
    residual f lead u (streamCons b z) 0 = emittedHead f lead u b := by
  exact hf n u b z zeroStream

end FVLTS4mResidualV1
