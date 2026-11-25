# SCHEMA ADDENDUM 14: comb-hopf v0.4.6 (2026-10-20)

**Status:** builder's record, additive successor of v0.4.5. Not reviewed yet.
**Credits:** saphir: decision (option A: hide the n1 group in integer mode). Claude Sonnet 5.5: v0.4.6.
**Amends:** addendum 13 section 3 (cap): the integer base now shows 39 controls.

## 1. UI change only
`syncControls` sets `#n1grp` display to none when shellMode is integer (CA already did). The n1 select, its minus and plus buttons were disabled in integer mode, so no action is lost. The state, `st.n1`, the address grammar, the `ca=1` field, exports and exact readouts are unchanged. Switching back to n! shows the group with the stored n1.
## 2. Counts (v0.4.5 counting method)
n! base 41, integer base 39, CA 39, continuous (n! base) 41.
