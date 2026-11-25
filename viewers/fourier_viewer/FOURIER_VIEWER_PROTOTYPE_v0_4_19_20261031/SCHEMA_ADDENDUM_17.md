# SCHEMA ADDENDUM 17 (v0.4.9, 2026-10-20): full stack and fraction stack (display only)
No change to the state schema, the exact export, the address id (`fv-comb-hopf/0.2`) or any exact readout.
1. Full stack: the point set {z_c(s, φ₃) = n₆·N^α·exp(iπ(N·t₁ + c·t₂)·s/N) : s, φ₃ ∈ {0 … B+1} on the host lattice (PORT_NOTE §1), N = B+1−φ₃ > 0, c in the comb offsets}. Module `host-core/stack-core.js` (fv-stack-core 0.1.0): exact phase residues, float64 amplitude and coordinates. Key: shell mode, B, n₆, α, t₁, t₂, m. Independent of φ₃, s, N mode and α_Tilt.
2. Views: Fourier (planar, canvas, frame includes the stack), Clifford (lift on the point's own leaf ρ_N, budget 12,000 − m, host head selection), Hopf base (chart image). Fraction stack heads (fraction-stack-core, unchanged) also drawn on Fourier and Hopf.
3. View string keys (drawing register, written only when not default): `fs`, `ff` (Fourier), `cs` (Clifford), `hs`, `hf` (Hopf), `so` (stack opacity, default 0.5; values 0.5, 0.3, 0.15, 0.06). Example `&view=fs%3D1`. A v0.4.8 reader ignores these keys and loads the state with the stacks off.
4. With all keys absent every output is byte-identical to v0.4.8.
