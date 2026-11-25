# P1 cold-audit handoff for Opus

Candidate BSD_POINT_PLACEMENT_P1_v0_1_20260924 follows sealed, post-seal verified BSD_REAL_UNIFORMIZATION_U1_v0_1_20260923. Both may be cold-audited together. Their controlling prompt is ../U1_P1_BUILD_PROMPT_CLAUDE_OPUS_20260923.md. Read OPEN_QUESTIONS.md and the two proof notes before code review. The baseline PT1 independent audit remains a separate predecessor standing.

Run node check-integrity.cjs, then node verify.cjs with its complete default. Fresh mutable receipts live outside source/stage seals. The sibling BSD_POINT_PLACEMENT_P1_POSTSEAL_20260924 contains the builder's complete post-seal receipt, suite results, screenshots, exported 37a1 setting, inherited fresh arithmetic receipts and checksums. SUMMARY.json names the candidate manifest and actual counts. Historical Cayley smoke has PARTIAL declared scope even though its eight checks pass; the strict 84/84 tally is retained.

Review p1-engine.cjs, p1-replay.cjs, p1-linked.js and the client/export integration. Replay attacks cover interval, component, marking, orientation, conjugation, order, rank and context substitutions. Test exact thirds/sixths/half-periods, the 37a1 rounded reference and signed multiples, arbitrary marked beta, every wrap representative, input maps and refusal paths. All source and staged inventories must remain unchanged.

Use node server.cjs for the viewer. Export full verified packet / Reopen full packet preserves the setting and reruns current verification. The source-pinned p1-reference.json is a separate comparison curve, explicitly not active arithmetic. No independent P1/U1 audit, seating or lock is asserted here. M4 is not part of these deliverables.
