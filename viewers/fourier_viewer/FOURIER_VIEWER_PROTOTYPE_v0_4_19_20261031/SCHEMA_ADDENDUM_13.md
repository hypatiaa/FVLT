# SCHEMA ADDENDUM 13: comb-hopf v0.4.5 (2026-10-20)

**Status:** builder's record for v0.4.5, an additive successor of v0.4.4. Not reviewed yet.
**Credits:** saphir: both decisions (cap 41; CA mode in the address). Claude Sonnet 5.5: v0.4.5.
**Amends:** addendum 12 section 1 ("UI overlay, not part of the state or the address"). Superseded: the CA overlay is now carried by the page address. The state schema, comb-core's address grammar, exact readouts and exports are unchanged.

## 1. Address field
`#v=<ADDRESS_ID>&<ADDRESS_KEYS...>` optionally followed by `&ca=1`. The panel writes the field only while CA is effectively on (UI.ca, shellMode integer, B a member of FVCa.CA_PRESETS). Otherwise the address is byte-identical to `C.encodeAddress(st)` (v0.4.4). Reading: the panel removes every `ca` / `ca=...` part before handing the rest to `C.importAny`, which therefore never sees it (comb-core still refuses unknown keys). The `hashchange` handler honours the field too.
## 2. Refusals (CA flag only, never the state)
- value not exactly `1`, or the field repeated: flag refused, label "CA flag refused (the field must be exactly ca=1); loaded without CA mode."
- `ca=1` with shellMode factorial, or integer with B not a CA preset: flag refused, label "CA flag refused: B = <B> ...", state loaded at that B, CA unpressed. (Chosen over the UI's behaviour of setting B = 5040, so an address never changes the B it names.)
- an invalid state part is refused as before (defaults, "Address refused").
Exports (state/exact files, pair address, stats text) keep `C.encodeAddress(st)` and carry no CA field: CA mode is a display overlay.
## 3. Control cap
The visible-control cap of the instrument panel is 41. The v0.3 assertions with 40 remain in the old file unedited and fail by one; `build/browser-check-v045.cjs` supersedes them.
