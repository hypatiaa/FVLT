# P1 v0.1 — enclosed rational-point positions

Built on sealed and post-seal verified BSD_REAL_UNIFORMIZATION_U1_v0_1_20260923. PT1 and viewer v0.8 lineage are preserved. Read OPEN_QUESTIONS.md for Robin and Opus's settled clarifications, then P1_PROOF.md and HANDOFF.md.

Run node server.cjs and open the printed localhost URL. Apply an exact model or a family tile. P1 places certified subgroup elements, exact visits, and recorded PT1 arithmetic outputs. On 37a1 it shows the existing exact multiples and a separately replayed C6 torsion orbit. Use PT1's exact calculator followed by Place current exact point records to add a calculated point within PT1's existing operation cap.

The actual period parallelogram and the marked torus (a square with opposite edges identified) display enclosure boxes. Filled dots identify centers and have no error-bound meaning. Exact rational endpoints, component labels, wrap representatives and proof hashes remain inspectable. Positions never promote rank, regulator, L-values or Sha. The 37a1 certificate still says rank >= 1, never exact rank 1.

To keep verifying the same setting, choose Export full verified packet and keep the JSON file. On a later launch use Reopen full packet. It restores the held curve/source/marking/visits/calculations and reruns T4, PT1, U1 and P1 against the current context. It does not restore authority from a screenshot or a saved verdict. Legacy U1 and PT1 exports remain readable.

node p1-replay.cjs accepts a placement proof on stdin. node verify.cjs is the complete verifier. The p1, u1, pt1, core and v1-only modes are development subsets. All execution receipts live outside the source seal. Builder verification is separate from Opus's cold audit, seating and lock. M4 has not been started.
