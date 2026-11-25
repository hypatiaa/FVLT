# Additive output-size repair

The initial M4 v0.1 seal remains immutable. A boundary probe after its seal found an admitted atom with coordinate orders 17,11,7, followed by thirteen 3s. Its shell has 166 bits and selected orbit 3927; the derived JSON occupies 12,607,818 bytes before envelope overhead. The importer already enforced a 12,000,000-byte cap, but the producer did not enforce the corresponding output cap. Small presets were unaffected.

M4 v0.2 checks the complete serialized output before returning a packet. Oversized results return UNAVAILABLE, clear the inspection and disable export. Arithmetic, source-function extraction and all inherited code remain unchanged. One arithmetic group and one actual-browser group reproduce this boundary. The original seal is pinned in build provenance and SOURCE_PINS.json and included in immutable source/stage inventories.

The repaired successor receives its own full pre-seal verification and a fresh complete post-seal run. The initial run is retained as development provenance, not the delivered M4 standing.
