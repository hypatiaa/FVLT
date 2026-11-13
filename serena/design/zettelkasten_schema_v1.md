# Zettelkasten Ontology Schema — Serena Tissue Layer (ArcadeDB)

**Version**: 1.0  
**Date**: 2026-03-10  
**Location**: Membrane (Trycoo N150)  
**Engine**: ArcadeDB (JVM capped at 2GB: `-Xms1G -Xmx2G -XX:+UseG1GC`)  
**License alignment**: Apache 2.0  

---

## Design Principles

1. **Atomic notes, rich links.** The Zettel is one idea. The value is in the edges.
2. **No imposed taxonomy.** Structure emerges from confirmed links, not categories.
3. **Lattice as referee.** Proposed links can be tested against the FVLT instrument (Neo4j nucleus). The lattice confirms or rejects.
4. **Manual gate.** All promotions from draft to permanent require Robin's approval until the middle path is adopted.
5. **Multi-model native.** Documents, vertices, and edges coexist in one engine. No stitching.

---

## Vertex Types

### Zettel

The atomic unit. One idea, one note.

```sql
CREATE TYPE Zettel EXTENDS V;

-- Properties
uid          STRING   -- Unique address (format: YYYYMMDD-HHMMSS-NNN or UUID)
content      STRING   -- The idea. 1-3 sentences. Never a summary.
created_at   DATETIME -- Extraction timestamp
status       STRING   -- draft | approved | dead_end
proposed_by  STRING   -- membrane | robin | think | instruct
approved_at  DATETIME -- NULL until promoted from draft
domain_hint  STRING   -- Optional. Not a category — a loose origin tag (eeg | market | foundry | theory | philosophy)

-- Lattice coordinates (populated when the source data has been measured)
lattice_channels LIST<INTEGER>  -- Which Div(720) channels carried energy in the source signal
lattice_bridge_depth INTEGER    -- Calibrated β from source measurement (NULL if unmeasured)
lattice_p_null DOUBLE           -- p-value from permutation test (NULL if unmeasured)
lattice_ce_z DOUBLE             -- Complement energy z-score (NULL if unmeasured)
```

### SourceDocument

Raw session material. The ore from which Zettel are extracted.

```sql
CREATE TYPE SourceDocument EXTENDS V;

-- Properties
uid           STRING   -- Unique identifier
title         STRING   -- Brief label ("Claude session 2026-03-10: Zettelkasten design")
created_at    DATETIME -- Session timestamp
source_system STRING   -- claude | gemini | terminal | robin_manual
digest        STRING   -- Full session digest (markdown)
filepath      STRING   -- Path to local markdown file (for LlamaIndex indexing)
```

### LatticeAnchor

A pointer to a node in the Neo4j nucleus. This is the seam between tissue and nucleus. ArcadeDB does not duplicate lattice structure — it references it.

```sql
CREATE TYPE LatticeAnchor EXTENDS V;

-- Properties
neo4j_node_id   STRING  -- The node ID in Neo4j (e.g., "DivisorNode:720" or "TheoremNode:3.14")
node_type        STRING  -- divisor | theorem | bridge | measurement
label            STRING  -- Human-readable label ("q=45", "Thm 8.14", "Frobenius bridge")
divisor_value    INTEGER -- For divisor nodes: the value q (NULL for non-divisor nodes)
```

### OntologyCluster

Emergent grouping. Created only when a region of the Zettelkasten reaches sufficient density of lattice-confirmed links. Never pre-defined.

```sql
CREATE TYPE OntologyCluster EXTENDS V;

-- Properties
uid          STRING   -- Unique identifier
label        STRING   -- Descriptive name (assigned by Robin on review)
created_at   DATETIME
zettel_count INTEGER  -- Number of member Zettel (maintained on link changes)
description  STRING   -- What this cluster represents (1-2 sentences)
```

---

## Edge Types

### LINKS_TO

The core Luhmann edge. Zettel to Zettel.

```sql
CREATE TYPE LINKS_TO EXTENDS E;

-- Properties
proposed_at    DATETIME
proposed_by    STRING   -- membrane | robin | think
status         STRING   -- proposed | lattice_pending | lattice_confirmed | lattice_rejected | manually_approved
reason         STRING   -- Why this link was proposed (1 sentence)

-- Lattice verification (populated after instrument test)
tested_at      DATETIME -- When the lattice test ran (NULL if untested)
shared_channels LIST<INTEGER>  -- Channels where both source signals deposited energy
channel_overlap_ratio DOUBLE   -- |intersection| / |union| of active channels
beta_agreement BOOLEAN         -- Do both sources share the same calibrated bridge depth?
ce_z_delta     DOUBLE          -- Difference in complement energy z-scores

-- Approval
approved_at    DATETIME -- NULL until approved
approved_by    STRING   -- robin (manual gate)
```

### EXTRACTED_FROM

Zettel back to its SourceDocument. Provenance chain.

```sql
CREATE TYPE EXTRACTED_FROM EXTENDS E;

-- Properties
extracted_at   DATETIME
extracted_by   STRING   -- membrane | robin
passage_ref    STRING   -- Optional: line range or marker in the source document
```

### ANCHORED_TO

Zettel to LatticeAnchor. Connects an idea to a specific location in the mathematical structure.

```sql
CREATE TYPE ANCHORED_TO EXTENDS E;

-- Properties
anchor_type   STRING  -- channel | theorem | bridge | region
confidence    STRING  -- measured | inferred | speculative
notes         STRING  -- Why this Zettel relates to this lattice location
```

### CLUSTERS_IN

Zettel to OntologyCluster. Membership is explicit, not computed.

```sql
CREATE TYPE CLUSTERS_IN EXTENDS E;

-- Properties
added_at     DATETIME
added_by     STRING   -- robin
```

### SUPERSEDES

Zettel to Zettel. When an idea is refined, the new Zettel supersedes the old. The old one is not deleted — it remains as history.

```sql
CREATE TYPE SUPERSEDES EXTENDS E;

-- Properties
superseded_at DATETIME
reason        STRING   -- What changed
```

### CONTRADICTS

Zettel to Zettel. Explicit disagreement between ideas. Tension is signal, not noise.

```sql
CREATE TYPE CONTRADICTS EXTENDS E;

-- Properties
identified_at  DATETIME
identified_by  STRING   -- membrane | robin | think
nature         STRING   -- empirical | theoretical | methodological
resolved       BOOLEAN  -- FALSE until one side is superseded or reconciled
resolution     STRING   -- NULL until resolved
```

### DEAD_END

Not a vertex status — a special edge from a Zettel to the SourceDocument where the dead end was identified. Captures *why* something didn't work.

```sql
CREATE TYPE DEAD_END EXTENDS E;

-- Properties (Zettel -> SourceDocument where the dead end was discovered)
identified_at DATETIME
reason        STRING   -- What failed or why this path was abandoned
lattice_rejected BOOLEAN -- TRUE if the lattice specifically rejected the link
```

---

## Document Types (ArcadeDB Document Layer)

### ReviewQueueItem

Proposed Zettel or link awaiting Robin's approval. The membrane writes here. Robin reads and promotes or rejects.

```json
{
  "type": "zettel | link",
  "proposed_at": "2026-03-10T14:30:00Z",
  "proposed_by": "membrane",
  "status": "pending | approved | rejected",

  "zettel_draft": {
    "content": "Status acts as structural hub rather than flat schema dimension",
    "source_document_uid": "session-2026-03-10-001",
    "domain_hint": "foundry",
    "passage_ref": "lines 42-58"
  },

  "link_draft": {
    "from_zettel_uid": "20260301-143022-001",
    "to_zettel_uid": "20260215-091500-003",
    "reason": "Both describe ontology fitness gap in different domains",
    "lattice_test_requested": true
  },

  "review_notes": null,
  "reviewed_at": null
}
```

### SessionIndex

Lightweight metadata for LlamaIndex to discover and rank source documents without reading the full digest.

```json
{
  "source_document_uid": "session-2026-03-10-001",
  "source_system": "claude",
  "date": "2026-03-10",
  "topics": ["zettelkasten", "arcadedb", "memory architecture", "neo4j"],
  "zettel_count": 5,
  "lattice_regions_touched": [45, 40, 48, 30],
  "filepath": "/var/lib/arcadedb/documents/sessions/2026-03-10-001.md"
}
```

---

## Cross-System Reference Pattern

The nucleus (Neo4j) and tissue (ArcadeDB) never directly query each other. The application layer (Think or Instruct via orchestrator.py) bridges them:

```
1. Membrane extracts Zettel → writes to ArcadeDB review queue
2. Robin approves → Zettel promoted to vertex
3. Robin (or membrane) proposes link → link edge created with status "proposed"
4. Lattice test requested → orchestrator reads both Zettel's source data
5. Orchestrator runs FVLT on both sources via Think → queries Neo4j for E_q, β, p_null, ce_z
6. Results written back to LINKS_TO edge properties in ArcadeDB
7. Robin reviews lattice result → approves or rejects the link
```

The LatticeAnchor vertices are the stable reference points. They don't change unless the lattice itself changes (rare). They give ArcadeDB a way to say "this Zettel is about channel q=45" without importing the full divisor lattice.

---

## Address Convention

Zettel UIDs follow the format: `YYYYMMDD-HHMMSS-NNN`

- Timestamp of extraction (not of the source session)
- NNN = sequence number within that second (allows burst extraction)
- Example: `20260310-143022-001`

This is a Luhmann-style address — sequential, non-semantic, stable. The address tells you *when*, never *what*. What is in the content. Where is in the links.

---

## Bootstrap Sequence

```sql
-- 1. Create vertex types
CREATE TYPE Zettel IF NOT EXISTS EXTENDS V;
CREATE TYPE SourceDocument IF NOT EXISTS EXTENDS V;
CREATE TYPE LatticeAnchor IF NOT EXISTS EXTENDS V;
CREATE TYPE OntologyCluster IF NOT EXISTS EXTENDS V;

-- 2. Create edge types
CREATE TYPE LINKS_TO IF NOT EXISTS EXTENDS E;
CREATE TYPE EXTRACTED_FROM IF NOT EXISTS EXTENDS E;
CREATE TYPE ANCHORED_TO IF NOT EXISTS EXTENDS E;
CREATE TYPE CLUSTERS_IN IF NOT EXISTS EXTENDS E;
CREATE TYPE SUPERSEDES IF NOT EXISTS EXTENDS E;
CREATE TYPE CONTRADICTS IF NOT EXISTS EXTENDS E;
CREATE TYPE DEAD_END IF NOT EXISTS EXTENDS E;

-- 3. Create indexes
CREATE INDEX ON Zettel (uid) UNIQUE;
CREATE INDEX ON Zettel (status);
CREATE INDEX ON Zettel (created_at);
CREATE INDEX ON Zettel (domain_hint);
CREATE INDEX ON SourceDocument (uid) UNIQUE;
CREATE INDEX ON SourceDocument (source_system);
CREATE INDEX ON SourceDocument (created_at);
CREATE INDEX ON LatticeAnchor (neo4j_node_id) UNIQUE;
CREATE INDEX ON LatticeAnchor (divisor_value);
CREATE INDEX ON OntologyCluster (uid) UNIQUE;
CREATE INDEX ON LINKS_TO (status);

-- 4. Seed LatticeAnchors for the 30 divisor channels
-- (One per divisor of 720: 1, 2, 3, 4, 5, 6, 8, 9, 10, 12, 15, 16, 18,
--  20, 24, 30, 36, 40, 45, 48, 60, 72, 80, 90, 120, 144, 180, 240, 360, 720)

CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:1', node_type = 'divisor', label = 'q=1', divisor_value = 1;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:2', node_type = 'divisor', label = 'q=2', divisor_value = 2;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:3', node_type = 'divisor', label = 'q=3', divisor_value = 3;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:4', node_type = 'divisor', label = 'q=4', divisor_value = 4;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:5', node_type = 'divisor', label = 'q=5', divisor_value = 5;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:6', node_type = 'divisor', label = 'q=6', divisor_value = 6;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:8', node_type = 'divisor', label = 'q=8', divisor_value = 8;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:9', node_type = 'divisor', label = 'q=9', divisor_value = 9;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:10', node_type = 'divisor', label = 'q=10', divisor_value = 10;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:12', node_type = 'divisor', label = 'q=12', divisor_value = 12;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:15', node_type = 'divisor', label = 'q=15', divisor_value = 15;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:16', node_type = 'divisor', label = 'q=16', divisor_value = 16;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:18', node_type = 'divisor', label = 'q=18', divisor_value = 18;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:20', node_type = 'divisor', label = 'q=20', divisor_value = 20;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:24', node_type = 'divisor', label = 'q=24', divisor_value = 24;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:30', node_type = 'divisor', label = 'q=30', divisor_value = 30;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:36', node_type = 'divisor', label = 'q=36', divisor_value = 36;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:40', node_type = 'divisor', label = 'q=40', divisor_value = 40;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:45', node_type = 'divisor', label = 'q=45', divisor_value = 45;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:48', node_type = 'divisor', label = 'q=48', divisor_value = 48;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:60', node_type = 'divisor', label = 'q=60', divisor_value = 60;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:72', node_type = 'divisor', label = 'q=72', divisor_value = 72;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:80', node_type = 'divisor', label = 'q=80', divisor_value = 80;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:90', node_type = 'divisor', label = 'q=90', divisor_value = 90;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:120', node_type = 'divisor', label = 'q=120', divisor_value = 120;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:144', node_type = 'divisor', label = 'q=144', divisor_value = 144;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:180', node_type = 'divisor', label = 'q=180', divisor_value = 180;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:240', node_type = 'divisor', label = 'q=240', divisor_value = 240;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:360', node_type = 'divisor', label = 'q=360', divisor_value = 360;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:720', node_type = 'divisor', label = 'q=720', divisor_value = 720;

-- 5. Seed LatticeAnchors for complement divisors (Div(1001) = {1, 7, 11, 13, 77, 91, 143, 1001})
-- Note: q=1 already exists above
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:7', node_type = 'divisor', label = 'q=7', divisor_value = 7;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:11', node_type = 'divisor', label = 'q=11', divisor_value = 11;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:13', node_type = 'divisor', label = 'q=13', divisor_value = 13;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:77', node_type = 'divisor', label = 'q=77', divisor_value = 77;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:91', node_type = 'divisor', label = 'q=91', divisor_value = 91;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:143', node_type = 'divisor', label = 'q=143', divisor_value = 143;
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'DivisorNode:1001', node_type = 'divisor', label = 'q=1001', divisor_value = 1001;

-- 6. Seed LatticeAnchors for bridge edges
CREATE VERTEX LatticeAnchor SET neo4j_node_id = 'Bridge:30-1001', node_type = 'bridge', label = 'Frobenius bridge 30↔1001', divisor_value = null;
```

---

## Query Patterns

### "What Zettel are linked to this lattice region?"
```sql
SELECT expand(in('ANCHORED_TO')) FROM LatticeAnchor WHERE divisor_value = 45;
```

### "Show me all proposed links awaiting review"
```sql
SELECT FROM LINKS_TO WHERE status = 'proposed';
```

### "Which Zettel have lattice-confirmed links?"
```sql
SELECT expand(bothV()) FROM LINKS_TO WHERE status = 'lattice_confirmed';
```

### "Find contradictions that are unresolved"
```sql
SELECT FROM CONTRADICTS WHERE resolved = FALSE;
```

### "Trace a Zettel back to its source session"
```sql
SELECT expand(out('EXTRACTED_FROM')) FROM Zettel WHERE uid = '20260310-143022-001';
```

### "What clusters have formed?"
```sql
SELECT uid, label, zettel_count FROM OntologyCluster ORDER BY zettel_count DESC;
```

### "Dead ends in foundry domain"
```sql
SELECT FROM Zettel WHERE status = 'dead_end' AND domain_hint = 'foundry';
```

---

## Notes

- **LatticeAnchors are read-only references.** They point to Neo4j. They don't replicate it. If the lattice changes (new theorem, revised proof status), update the anchor label — don't rebuild.
- **OntologyClusters are late-stage.** Don't create them until a region has 5+ Zettel with lattice-confirmed links between them. Premature clustering is premature taxonomy.
- **CONTRADICTS edges are valuable.** Don't rush to resolve them. Tension between Zettel is signal. Luhmann kept contradictions alive for decades.
- **The review queue is a document, not a vertex.** It doesn't become structure until Robin says so. The queue is ephemeral; the graph is permanent.
- **domain_hint is not a category.** It's a loose tag for convenience. Never filter exclusively by it. The lattice channels are the real organizer.
