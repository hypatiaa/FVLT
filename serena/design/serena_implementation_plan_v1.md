# Serena v3.1.1 — First Implementation Plan

**March 25, 2026**
**Target: PowerSpec G527 (Nucleus) → Trycoo N150 (Membrane)**

This is the concrete deployment plan for what exists in the bundle today.
Not Phase I integration work. Just: get what we have running on real hardware.

---

## Prerequisites

- Ubuntu 24.04 LTS installed on Serena desktop (done)
- Tailscale installed on both nodes
- Trycoo N150 booted and accessible via SSH
- OLMo 3 7B confirmed running on RX 9060 XT via amdgpu (done)
- `serena-v3.1.1.tar.gz` transferred to Serena desktop

---

## Node 1: Serena Desktop (Nucleus)

### 1.1 — Unpack the bundle

```bash
mkdir -p ~/serena
cd ~/serena
tar xzf ~/Downloads/serena-v3.1.1.tar.gz
mv serena-v3.1.1/* .
rmdir serena-v3.1.1
```

Verify the tree:

```bash
ls core/ schemas/ scout/ tests/ docs/
# Expected: config.py  fvlt_congruence.py  fvlt_unified_kernel.py  orchestrator.py
#           nucleus_schema.cypher  perception_schema.cypher  tissue_schema.sql  ...
```

### 1.2 — Python environment

```bash
python3 -m venv ~/serena/.venv
source ~/serena/.venv/bin/activate
pip install numpy
pip install neo4j
```

### 1.3 — Verify the measurement stack

```bash
cd ~/serena
python core/config.py        # 7 tests — security guards
python core/fvlt_congruence.py   # congruence layer verification
python core/orchestrator.py      # orchestrator verification (12 tests)
```

All three must pass before proceeding. If any fail, stop.

### 1.4 — Preflight: verify install tools

```bash
# Confirm these are available before proceeding
for cmd in wget curl gpg grep nano systemctl; do
  command -v $cmd > /dev/null 2>&1 && echo "[OK] $cmd" || echo "[MISSING] $cmd — install before continuing"
done
```

Install anything missing: `sudo apt install wget curl gnupg grep nano -y`

### 1.5 — Install and configure Neo4j

```bash
# Add Neo4j repo (Community Edition, free)
wget -O - https://debian.neo4j.com/neotechnology.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/neo4j.gpg
echo 'deb [signed-by=/usr/share/keyrings/neo4j.gpg] https://debian.neo4j.com stable latest' | sudo tee /etc/apt/sources.list.d/neo4j.list
sudo apt update
sudo apt install neo4j

# Set initial password
sudo neo4j-admin dbms set-initial-password <your-generated-secret>

# Allow remote connections (for Trycoo access over Tailscale)
sudo nano /etc/neo4j/neo4j.conf
# Uncomment/set:
#   server.default_listen_address=0.0.0.0
#   server.bolt.listen_address=0.0.0.0:7687
#   OR bind to Tailscale IP only for tighter security:
#   server.bolt.listen_address=100.x.x.x:7687

# Start
sudo systemctl enable neo4j
sudo systemctl start neo4j

# Verify
cypher-shell -u neo4j -p <your-generated-secret> "RETURN 1;"
```

### 1.6 — Deploy nucleus schema

```bash
cd ~/serena
cypher-shell -u neo4j -p <your-generated-secret> -f schemas/nucleus_schema.cypher
cypher-shell -u neo4j -p <your-generated-secret> -f schemas/perception_schema.cypher
```

Verify:

```bash
cypher-shell -u neo4j -p <your-generated-secret> \
  "SHOW CONSTRAINTS;"
# Should show constraints for Percept, Fingerprint, Verdict, Reference, etc.
# Plus PerceptionSession, Perception, ReviewState, ProvenanceClass
```

### 1.7 — Configure environment

```bash
cd ~/serena
cp .env.example .env
nano .env
```

Fill in at minimum:

```
SERENA_NEO4J_URI=bolt://localhost:7687
SERENA_NEO4J_USER=neo4j
SERENA_NEO4J_PASSWORD=<your-generated-secret>
SERENA_NEO4J_DATABASE=neo4j

SERENA_NUCLEUS_OLLAMA=http://localhost:11434

SERENA_ALLOW_INSECURE_DEFAULTS=false
SERENA_ALLOW_PUBLIC_ENDPOINTS=false
```

Test config loading with real credentials:

```bash
cd ~/serena
python -c "
import sys; sys.path.insert(0, 'core')
from config import SerenaConfig
cfg = SerenaConfig.from_env()
print(f'Neo4j: {cfg.neo4j_uri}')
print(f'Think model: {cfg.think_model}')
print(f'Perceiver model: {cfg.perceiver_model}')
print('Config loaded successfully.')
"
```

If `_require_non_default_secret` raises, your password is still a placeholder.

### 1.8 — Verify Ollama models

```bash
# OLMo Think (reasoner)
ollama list | grep -i olmo
# Should show allenai/OLMo-3-7B-Think or equivalent

# Pull if not present
ollama pull allenai/OLMo-3-7B-Think

# Quick smoke test
ollama run allenai/OLMo-3-7B-Think "Return only the word 'ready'."

# Molmo 7B-O (perceiver) — pull but don't run yet (GPU sharing comes in Phase II)
ollama pull allenai/Molmo-7B-O-0924
```

### 1.8a — Expose Ollama to Tailscale interface

By default Ollama listens only on `127.0.0.1:11434`. The Trycoo needs to
reach it over Tailscale for Molmo inference proxying.

```bash
# Edit the Ollama systemd override
sudo systemctl edit ollama
```

Add these lines in the editor:

```ini
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

Then reload and restart:

```bash
sudo systemctl daemon-reload
sudo systemctl restart ollama

# Verify it listens beyond localhost
curl http://localhost:11434/api/tags          # should work
curl http://<serena-tailscale-ip>:11434/api/tags  # should also work now
```

For tighter security, bind to the Tailscale IP only:
`Environment="OLLAMA_HOST=100.x.x.x:11434"` — but then local `curl`
needs the Tailscale IP too.

### 1.9 — Verify FVLT lattice builds on this hardware

```bash
cd ~/serena
python -c "
import sys, time; sys.path.insert(0, 'core')
from fvlt_unified_kernel import build_unified_lattice
from fvlt_congruence import spectral_fingerprint
import numpy as np

t0 = time.time()
lattice = build_unified_lattice(6)
t1 = time.time()
print(f'Lattice built: {len(lattice.channels)} channels, N0={lattice.N0} ({(t1-t0)*1000:.0f}ms)')

signal = np.random.default_rng(42).normal(size=720)
fp = spectral_fingerprint(signal, lattice)
t2 = time.time()
print(f'Fingerprint: beta={fp.bridge_depth}, E={fp.total_energy:.4f}, herf={fp.herfindahl:.4f} ({(t2-t1)*1000:.0f}ms)')
print('Nucleus measurement stack verified on target hardware.')
"
```

### 1.10 — Desktop node status check

At this point the Serena desktop should have:

- [  ] Python venv with numpy + neo4j driver
- [  ] Neo4j running, password set, listening on Tailscale IP
- [  ] Nucleus schema deployed (both cypher files)
- [  ] `.env` configured with real credentials
- [  ] Config loads without security guard errors
- [  ] OLMo Think pulled in Ollama
- [  ] Molmo 7B-O pulled in Ollama
- [  ] Ollama listening on Tailscale interface (not just localhost)
- [  ] FVLT lattice builds and fingerprints in <1s
- [  ] All three core test suites pass

**Do not proceed to Trycoo until all boxes are checked.**

---

## Node 2: Trycoo N150 (Membrane)

### 2.1 — Base setup

```bash
# SSH from Serena desktop
ssh robin@<trycoo-tailscale-ip>

# System update
sudo apt update && sudo apt upgrade -y

# Python
sudo apt install python3 python3-venv python3-pip -y
```

### 2.1a — Preflight: verify install tools

```bash
# ArcadeDB requires Java 21+
for cmd in wget curl grep java; do
  command -v $cmd > /dev/null 2>&1 && echo "[OK] $cmd" || echo "[MISSING] $cmd"
done

# Check Java version (ArcadeDB 26.x requires Java 21+)
java -version 2>&1 | head -1
# Must show 21 or higher. If missing or older:
sudo apt install openjdk-21-jre-headless -y
```

### 2.2 — Transfer bundle

```bash
# From Serena desktop
scp ~/Downloads/serena-v3.1.1.tar.gz robin@<trycoo-tailscale-ip>:~/

# On Trycoo
mkdir -p ~/serena
cd ~/serena
tar xzf ~/serena-v3.1.1.tar.gz
mv serena-v3.1.1/* .
rmdir serena-v3.1.1
```

### 2.3 — Python environment (membrane)

```bash
cd ~/serena
python3 -m venv .venv
source .venv/bin/activate

# Core (for measurement surface — the scout imports from core/)
pip install numpy

# Membrane-specific
pip install -r scout/requirements-membrane.txt
# installs: fastapi, uvicorn, httpx, python-multipart, pydantic, neo4j
```

### 2.4 — Install and configure ArcadeDB

```bash
# Download ArcadeDB 26.3.1 (pinned — do not use wildcards)
wget https://github.com/ArcadeData/arcadedb/releases/download/26.3.1/arcadedb-26.3.1.tar.gz
tar xzf arcadedb-26.3.1.tar.gz
cd arcadedb-26.3.1

# Set root password
export ARCADEDB_ROOT_PASSWORD=<your-generated-secret>

# Start
bin/server.sh &

# Verify
curl -u root:<your-generated-secret> http://localhost:2480/api/v1/server
```

Create the Serena tissue database:

```bash
curl -u root:<your-generated-secret> \
  -X POST http://localhost:2480/api/v1/server \
  -d '{"command":"CREATE DATABASE serena_tissue"}'
```

### 2.5 — Deploy tissue schema

```bash
# Apply v3.1.1 tissue schema
# ArcadeDB executes SQL via REST API or console

# Option A: ArcadeDB console (run from ~/serena so paths resolve)
cd ~/serena
~/arcadedb-26.3.1/bin/console.sh
> CONNECT remote:localhost/serena_tissue root <password>
> LOAD ~/serena/schemas/tissue_schema.sql;

# Option B: line-by-line via curl (strip comments, execute each CREATE)
cd ~/serena
grep '^CREATE' schemas/tissue_schema.sql | while read stmt; do
  curl -u root:<password> \
    -X POST "http://localhost:2480/api/v1/command/serena_tissue" \
    -H "Content-Type: application/json" \
    -d "{\"language\":\"sql\",\"command\":\"$stmt\"}"
  echo
done
```

### 2.6 — Configure environment (membrane)

```bash
cd ~/serena
cp .env.example .env
nano .env
```

Fill in — note the Tailscale IPs:

```
# Points to Serena desktop over Tailscale
SERENA_NEO4J_URI=bolt://<serena-desktop-tailscale-ip>:7687
SERENA_NEO4J_USER=neo4j
SERENA_NEO4J_PASSWORD=<same-secret-as-desktop>
SERENA_NEO4J_DATABASE=neo4j

SERENA_NUCLEUS_OLLAMA=http://<serena-desktop-tailscale-ip>:11434

# Local ArcadeDB
SERENA_ARCADEDB_URL=http://127.0.0.1:2480
SERENA_ARCADEDB_DATABASE=serena_tissue
SERENA_ARCADEDB_USER=root
SERENA_ARCADEDB_PASSWORD=<arcadedb-secret>

# Membrane auth
SERENA_MEMBRANE_AUTH_USER=serena
SERENA_MEMBRANE_AUTH_PASSWORD=<membrane-secret>
SERENA_MEMBRANE_BEARER_TOKEN=<generated-bearer-token>

# Perceiver (proxied to desktop Ollama)
SERENA_PERCEIVER_MODEL=allenai/Molmo-7B-O-0924

SERENA_ALLOW_INSECURE_DEFAULTS=false
SERENA_ALLOW_PUBLIC_ENDPOINTS=false
```

### 2.7 — Verify cross-node connectivity

```bash
# From Trycoo: can we reach Neo4j on Serena desktop?
python3 -c "
from neo4j import GraphDatabase
driver = GraphDatabase.driver(
    'bolt://<serena-desktop-tailscale-ip>:7687',
    auth=('neo4j', '<password>')
)
with driver.session() as s:
    result = s.run('RETURN 1 AS n')
    print(f'Neo4j reachable: {result.single()[\"n\"]}')
driver.close()
"

# From Trycoo: can we reach Ollama on Serena desktop?
curl http://<serena-desktop-tailscale-ip>:11434/api/tags
# Should list available models
```

### 2.8 — Verify measurement surface on membrane

```bash
cd ~/serena
python -c "
import sys; sys.path.insert(0, 'core')
from fvlt_unified_kernel import build_unified_lattice
from fvlt_congruence import spectral_fingerprint
import numpy as np

lattice = build_unified_lattice(6)
signal = np.random.default_rng(42).normal(size=720)
fp = spectral_fingerprint(signal, lattice)
print(f'Membrane lattice: {len(lattice.channels)} channels, N0={lattice.N0}')
print(f'Fingerprint: beta={fp.bridge_depth}, E={fp.total_energy:.4f}')
print('Measurement surface verified on Trycoo.')
"
```

**Critical check:** The fingerprint values here must match what the desktop
produced in step 1.9 with the same seed, within tolerance (1e-10).
If they diverge, the measurement surface has drifted between nodes.
Stop and investigate.

### 2.9 — Start perception gateway (dry run)

```bash
cd ~/serena
source .venv/bin/activate

# Dry run — will fail to reach Molmo but should boot cleanly
uvicorn scout.membrane_perception:app --host 0.0.0.0 --port 8401 &

# Health check
curl http://localhost:8401/health
# Should return JSON with status

# Check from desktop over Tailscale
curl http://<trycoo-tailscale-ip>:8401/health
```

Stop the gateway after verifying it boots:

```bash
kill %1
```

### 2.10 — Install OLMo Instruct (membrane agent)

```bash
# Ollama on Trycoo (CPU inference)
curl -fsSL https://ollama.com/install.sh | sh

# Pull Instruct model
ollama pull allenai/OLMo-3-7B-Instruct

# Smoke test (will be slow — CPU, ~6-9 tok/s)
ollama run allenai/OLMo-3-7B-Instruct "Return only the word 'ready'."
```

### 2.11 — Trycoo node status check

- [  ] Python venv with numpy + membrane dependencies
- [  ] ArcadeDB running, tissue database created, schema deployed
- [  ] `.env` configured with Tailscale IPs and real credentials
- [  ] Config loads without security guard errors
- [  ] Neo4j reachable on Serena desktop over Tailscale
- [  ] Ollama reachable on Serena desktop over Tailscale
- [  ] FVLT lattice builds on Trycoo, fingerprints match desktop within tolerance (1e-10)
- [  ] Perception gateway boots and responds to /health
- [  ] OLMo Instruct pulled and responding (CPU)

---

## Cross-Node Verification

Once both nodes pass their individual checks:

### 3.1 — End-to-end measurement consistency

From the Trycoo, run the same deterministic signal through the FVLT and compare:

```bash
# Run on BOTH nodes — output must agree within tolerance
cd ~/serena && python -c "
import sys, json; sys.path.insert(0, 'core')
from fvlt_unified_kernel import build_unified_lattice
from fvlt_congruence import spectral_fingerprint
import numpy as np
lattice = build_unified_lattice(6)
signal = np.sin(2 * np.pi * 5 * np.arange(720) / 720)
fp = spectral_fingerprint(signal, lattice)
print(json.dumps({
    'beta': int(fp.bridge_depth),
    'total_energy': float(fp.total_energy),
    'herfindahl': float(fp.herfindahl),
    'eq_sum': float(sum(fp.eq_vector)),
}, indent=2))
"
```

Compare the outputs with an explicit tolerance:

```bash
# Acceptance criteria (run manually or script it):
#   beta must be identical (integer)
#   total_energy: |desktop - trycoo| < 1e-10
#   herfindahl:   |desktop - trycoo| < 1e-10
#   eq_sum:       |desktop - trycoo| < 1e-10
```

If `beta` disagrees or any scalar difference exceeds `1e-10`, there is a
portability issue — likely a numpy version mismatch or floating-point
environment difference. Stop and investigate before proceeding.

### 3.2 — Write a test percept to Neo4j from Trycoo

```bash
# On Trycoo
cd ~/serena && python -c "
from neo4j import GraphDatabase
driver = GraphDatabase.driver(
    'bolt://<serena-desktop-tailscale-ip>:7687',
    auth=('neo4j', '<password>')
)
with driver.session() as s:
    s.run('''
        CREATE (p:Percept {
            percept_id: 'test-deploy-001',
            timestamp: datetime(),
            source: 'deployment_verification',
            modality: 'test',
            content_type: 'smoke_test',
            signal_length: 720
        })
    ''')
    result = s.run('MATCH (p:Percept {percept_id: \"test-deploy-001\"}) RETURN p.source AS src')
    print(f'Written and read back: {result.single()[\"src\"]}')
driver.close()
"
```

### 3.3 — Clean up test data

```bash
# On Serena desktop
cypher-shell -u neo4j -p <password> \
  "MATCH (p:Percept {percept_id: 'test-deploy-001'}) DELETE p;"
```

---

## What You Have After This Plan

Two nodes, connected, verified:

```
Serena Desktop (Nucleus)              Trycoo N150 (Membrane)
├── Python venv                       ├── Python venv
├── Neo4j (nucleus + perception)      ├── ArcadeDB (tissue)
├── Ollama                            ├── Ollama
│   ├── OLMo Think 7B                │   └── OLMo Instruct 7B (CPU)
│   └── Molmo 7B-O                    ├── Perception gateway (scout)
├── FVLT core (kernel + congruence)   ├── FVLT core (same measurement surface)
├── Orchestrator                      └── .env → points to desktop
└── .env → localhost                      Neo4j + Ollama over Tailscale
         ╰── Tailscale ──╯
```

## What You Do NOT Have Yet

- Real `GraphInterface` implementation (still `MemoryGraph` in orchestrator)
- Inter-node typed message bus (FastAPI for Percept/MeasuredPercept/ActionProposal/ActionResult)
- Real reasoner (still `EchoReasoner`)
- Robin → Membrane CLI
- Robin → Scout direct chat
- Human gate UI
- Scout web agent (MolmoWeb 4B on Neo — Phase II)

Those are Phase I integration tasks (roadmap IDs A→B→D→C→E, per Chris's reorder).
This plan is Phase 0: **the organism's hardware is alive and connected.**

---

## Systemd Services (optional, for persistence)

Once verified, set up both nodes to survive reboot:

### Desktop — Neo4j

Already handled by `sudo systemctl enable neo4j`.

### Desktop — Ollama

```bash
# Ollama typically installs its own systemd service
sudo systemctl enable ollama
```

### Trycoo — ArcadeDB

```bash
# Create systemd unit
sudo tee /etc/systemd/system/arcadedb.service << 'EOF'
[Unit]
Description=ArcadeDB
After=network.target

[Service]
Type=simple
User=robin
Environment=ARCADEDB_ROOT_PASSWORD=<your-secret>
WorkingDirectory=/home/robin/arcadedb-26.3.1
ExecStart=/home/robin/arcadedb-26.3.1/bin/server.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable arcadedb
sudo systemctl start arcadedb
```

### Trycoo — Ollama

```bash
sudo systemctl enable ollama
```

### Trycoo — Perception Gateway (after Phase I wiring)

Not yet — the gateway needs the inter-node bus (roadmap B) before it should run as a persistent service. For now, start manually for testing.

---

*Phase 0 complete. The hardware is ready. Phase I begins.*
