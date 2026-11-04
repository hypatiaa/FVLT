# Kernel correction candidate: the §9.4 Ford-circles row (Part II / II.5), v0.1

*2026-11-04.*
- **Written by** the skeleton seat (Claude Opus 5.5), at saphir's request ("do the kernel 9.4 correction draft for idea catalog to review").
- **Standing:** kernel **correction candidate** for Idea Catalog review. There is no automatic adoption, and kernel bytes are edited only through a reviewed successor that saphir labels and locks.
- **Base:** FVLT kernel **v3.4.0**, LOCKED, `kernel_v3_4_0.md`, sha256 `0d6beee233602502576c1d0eedfe5a586e66f1b4e4b8a1858c39189d872ec1a2`.
- **Rule followed:** saphir, 2026-10-30: verified Lean wins over kernel prose, and kernel corrections go through Idea Catalog candidates.

## What changes, and why

The row sits in the block "§9.4 classical connection — Ford circles (preserved)" of Part II / II.5, at line 644 of the base. It currently says:

> A map sending Vernier phasor paths to Ford-circle arcs has not been defined; this is an interpretive comparison only.

**FF-3 now defines and proves the discrete part of that map in Lean.** The map goes from lifted rosette data to Ford circles, with exact kiss-point certificates on tangent steps:
- FF-3 final audit PASS, bus #1554: `phasor_ford_map_v0_1_20261103/FF3_FINAL_AUDIT_v0_1.md`, sha256 `cf9f59c9faf849a378dcec1b2eca87116861e3119eb064adef11572c8d3e92a3`;
  - 37/37 statements rebuilt and strictly replayed by skeleton on nucleus, using only `propext`, `Classical.choice` and `Quot.sound`;
  - an independent fidelity review found 37/37 statements MATCH (signoff `abbf810a…`).
- In the shared theorem library **v23**, READY on three hosts (bus #1556). Its `SHA256SUMS` is `394e72c5…`, and the modules are `FVLTRosetteFordDataV1`, `PhaseV1`, `ArithmeticV1`, `SweepV1` and `EndpointsV1`.

**The parts that remain undefined are kept undefined:** oriented or continuous arcs, a map from unlabelled phasor values or paths, and any dynamical correspondence. So the correction narrows the row's "not defined" to exactly what is still open. It does **not** retroactively falsify the historical text, because the historical row was about phasor *paths* to *arcs*, and that is still not defined.

**Scope check.** In the base, line 644 is the kernel's only statement that the phasor-to-Ford map is undefined; this was checked by grep. The row is **not** inside any item-locked span:
- it precedes Rmk II.5a;
- it is outside the II.5g–k fold, Rmk II.5f and Thm II.3c;
- it carries no native-id tag.

## Proposed replacement (exact)

```
id:   FF3-FORD-9.4-ROW
kind: mathematical correction (scope narrowing to the Lean-verified construction)
old:  | **Ford circles** | Circle of radius $1/(2q^2)$ at $p/q$; tangent iff Farey neighbors [For38]. A map sending Vernier phasor paths to Ford-circle arcs has not been defined; this is an interpretive comparison only. |
```

**New:**

| Classical Object | Role in FVLT |
|---|---|
| **Ford circles** | Circle of radius $1/(2q^2)$ at $p/q$; tangent iff Farey neighbors [For38]. **Lifted-data map (Lean-verified, FF-3; shared library v23).** For lifted rosette data $(t_1,t_2,s,n_3)$ with $t_1,t_2\in\mathbb Z$, $s\in\mathbb Q$, $n_3\ge 1$ and a nonzero real amplitude $r$, the map $\Phi(t_1,t_2,s,n_3)=C(x)$ sends the record to the Ford circle at its Ford address $x=t_2s/n_3$. The phasor $r\,e^{i\pi a}$, with phase address $a=t_1s-x$, is real iff $a\in\mathbb Z$. On the lower-tooth shells $N=2,\dots,B+1$ ($t_1=t_2=1$), its real events with $s\in[0,N]$ are exactly $s=mN/(N-1)$, $0\le m\le N-1$, with addresses $m/(N-1)$; the deduplicated address set is the Farey set $F_B$, and consecutive members $a/b<c/d$ satisfy $bc-ad=1$. Along a finite address path, each edge is exactly one of tangent (determinant $\pm1$), stall (equal addresses) or break, and every tangent edge carries an exact rational kiss point lying on both circles. $\Phi$ is defined on lifted data, not on phasor values: at $N=3$, $s=0$ and $s=3$ give the same phasor and the addresses $0$ and $1$. Oriented or continuous Ford-circle arcs, a map from unlabelled phasor values or paths, and any dynamical correspondence are not defined; that comparison remains interpretive only. |

As a single replacement line, ready for a CORRECTIONS entry, see `REPLACEMENT_FF3-FORD-9.4-ROW_v0_1.json`.

## Standing of the new text

- **Unconditional, Lean-verified:** the lifted-data map and the statements in the row. Each one maps to named FF-3 theorems:
  - `phasor_real_iff`;
  - `phasor_alias_not_address_alias`;
  - `shell_contact_parameterization` and `shell_phasor_contact_iff`;
  - `shell_contact_address`;
  - `shell_addresses_eq_farey`;
  - `farey_consecutive_det`;
  - `path_edge_trichotomy`;
  - `classify_tangent_iff`;
  - `tangent_endpoint_certificate`.

  Supporting theorems: `integer_spin_parity`, P1–P4 and the remaining sweep and endpoint statements. The kernel's §9.4 citation [For38] stays.
- **Interpretive (unchanged):** any arc, path or dynamical reading.
- **Not claimed:**
  - Lemma 6a, which FF-3 does not assume;
  - register identification;
  - a factoring advantage;
  - viewer certification.

**Native items and tags.** No native item is added, and no native tag changes; the row has no tag. Rmk II.5b, which cites "§9.4 Ford circles", is unaffected: its determinant and tangency content is the same Ford-circle fact.

## For the reviewer

1. **Register in a table cell.** The II.5 block's status line is already "unconditional / definitional / interpretive (per-block)". Should the cell carry an explicit status marker, as written here ("Lean-verified, FF-3"), or should that marker move into the block's status line?
2. **Length.** The row is long for a table cell. One alternative keeps the cell short ("Lifted-data map defined and Lean-verified in FF-3; see Note II.5-FF3") and adds a declared Note under the item-addition policy (PR #72). That would be an item addition, not just a correction, so it is offered as an option rather than proposed.
3. **Phrasing of "real".** The row says "real" for "imaginary part zero", matching FF-3's `(phasorValue …).im = 0`.

## Checks (by script)

See `CHECK_9_4_CANDIDATE_v0_1.cjs` and its output:
- the old text occurs exactly once in the base kernel `0d6beee2…`;
- after replacement, the only changed line is line 644;
- the line count is unchanged;
- the applied draft's sha256 is recorded.

No kernel file is edited; the check writes its applied copy to a scratch path only.

Credit: the question of the map, the rosette and the instruments: saphir. FF-3: Codex (producer), skeleton (independent verifier), an independent fidelity reviewer. "The framework was assembled by Robin Miller; its components are classical results of others."
