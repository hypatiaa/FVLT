# Serena: design records for the build (index)

Collected 2026-11-13 by the serena track owner (Claude Opus 5.5, local session `local_472fb93f…`) at saphir's request, so sessions working from this repo can read the Serena design and the rulings that precede the build. Documents only: no credentials, launchers, state files or binaries. Copies are byte-identical to their sources on Neo unless a filename was normalised (noted below).

**Standing:** reference material. Nothing here authorizes a build, a deployment, a database write or a host change; each of those stays with saphir.

## Read in this order

1. `design/architecture_v2.md`: Serena Architecture v2.0, three lobes on three nodes (March 2026).
2. `design/serena_stack_v3_1_1.md`: the stack discipline: four layers, typed messages, no bypass of the congruence stage.
3. `design/corrigibility_v2.md`: the permanent manual gate.
4. `records/HANDOFF_AGORA_ZULIP_GEMMA_v0_1_20261025.md`: the 26 October record (live checks 2026-10-26 00:17 UTC): OLMo removed on purpose, local Gemma on Nucleus, chat pilot reused via a versioned successor, ports 443/8443 preserved, Serena and pen architecture rules (§5, §6), host roles.
5. `records/MEMBRANE_VIEWERS_SETUP_v0_1_20261106.md`: the 6 November record: Membrane serves viewers on 8088 via systemd user services with lingering. Infrastructure only, no rulings.
6. `roadmap/roadmap_2026-07-02_serena-installation-kernel-parity.md`: staged installation roadmap; every phase lands on saphir's gate.
7. `track/SERENA_MEMORY_PROGRESS_SUMMARY_20261019.md`: the October serena-track memory work in plain words.

## Rulings recorded on the serena track (October 2026)

Quoted from the track record `stack_bus_autocheck/tracks/serena.json` on Neo; saphir's words verbatim.

| Date (UTC) | Ruling | saphir |
|---|---|---|
| 2026-10-19 | The serena track owns schema serena-order-state/0.2; idea-catalog and the Zettelkasten consume it; schema changes go through discipline review; each version pinned by hash. | "I will take the lean." |
| 2026-10-19 | Next memory design (v0.3) and raven study v0.2 are grounded in kernel_v3_1_15: IV.1 walk-relative lens (base/operative/current lens; contraction = view change not erasure; breathing lens = masks/clocks; scope function; Rmk 1.3c non-lift), Rmk 1.5c two readouts (Hasse = where, harmonic = what), Rmk 1.6b three observation contexts (node/visit/transition, each its own Lambda_desc; never merged; cross-context needs a constructed fourth). Do not use the word lens for energy/phase/tone; call them readouts and observation contexts. | "That sounds right" |
| 2026-10-19 | Serena records, concept lattices (Lambda_desc per context) and implication bases must be exportable in open formats that map cleanly onto Palantir Foundry Ontology primitives (object types, properties, link types, actions, time series / events), without any runtime dependency on Palantir; local-first stays primary. | "Yes, I want to maintain compatibility for devs doing work on palantir for enterprise, or for small companies who may later need their free offering" |
| 2026-10-19 | G7 cleared for Stage 1: build the memory core (design v0.2.2) as a local, exact, standard-library Python package with tests and fixtures; local files only; no host, no database in Stage 1. | "I want to finish this serena memory and get it and the zettlekasten implemented / build core now, 1" |
| 2026-10-19 | Observation sources in order: viewer walks and Zettelkasten notes first; drawing strokes and hexapod telemetry later. | "I like all four, but viewer walks and zettlekasten notes come first. As we develop the ability to work with humans and robotics, we move to the others" |
| 2026-10-19 | The serena track builds the memory AND the Zettelkasten side, working with the Idea Catalog cloud Opus partner and the Codex Idea Catalog (reviews, ontology mapping, ArcadeDB knowledge). Supersedes the earlier zettelkasten boundary for building; ownership of the ontology mapping review stays shared. | "Serena track builds both - the Opus in Idea Catalog is a cloud session. work with opus and the codex counterpart" |
| 2026-10-19 | First running version is local on this machine; Serena/Nucleus deployment is a later step saphir authorizes. | "Local on this machine (Recommended)" |
| 2026-10-19 | The pen and ontology derivation are a standalone product (core: pen operations, ontology derivation, provenance, portable formats). Serena is one consumer via a Serena adapter: Nemotron, the scout seat, uses the pen and ontology derivation; Palantir is a later adapter; independent use without either platform. Next spec defines the product interface first, then the Serena (scout/Nemotron) and Palantir adapters. | "right, we will develop for nemotron to use the pen (serena side) and ontology derivation, and then we also adapt it to palantir / nemotron is the scout seat" |
| 2026-10-20 | Q1 answer: Nemotron runs locally on the scout box; tool calling is not yet designed; the model is not yet installed. Installing it is a host action for saphir. | "my nemotron is local on the scout box. we haven't designed the tool calling and need to install the model." |

Also on record (26 Oct handoff): OLMo was removed deliberately and must not be reinstalled; the chat pilot is connectivity, not the governed Stack Bus; model prose cannot choose recipients, run commands, grant permissions or write the authoritative graph; ArcadeDB connection is an explicit adapter/promotion step.

## Points now out of date

- The 26 Oct record lists home-LAN addresses only. Since 29 Oct the hosts are also reached over Tailscale (agora 100.124.20.93, nucleus 100.105.106.41, membrane 100.98.98.121, scout 100.113.13.47); the Stack Bus gateway stays at 192.168.0.225:8443, reached off-LAN through a Tailscale /32 route.
- Its ports table predates the Tailscale access-rule changes of 29 Oct and 7 Nov.

## Serena-track documents not copied here (on Neo, `s6_atom/serena_track/`)

| Path | What | sha256 |
|---|---|---|
| `STATE_DESIGN_v0_2_3_20261019/DESIGN.md` | memory design v0.2.3 (PASS #556) | `0b3ca6f4bbc81bf2dac7e47815f6241c4c71801b66c5f89cefd0e9eb4b120083` |
| `SERENA_MEMORY_CORE_v0_1_20261019/MANIFEST.sha256` | Stage 1 memory core (local, exact, stdlib Python) | `4ad3f63908e4b7f4e6956acb578f376323da6b4e490eac14853e212ee7e9126a` |
| `MEMORY_PRESHEAF_NOTE_v0_1_1_20261020/NOTE.md` | presheaf/sheaf note v0.1.1 | `94edb7309f7bc8b65389a936b9e5dcfe0a9b32f13ae71cb1e4239a2003d4f38d` |
| `PEN_ONTOLOGY_PRODUCT_SPEC_v0_1_4_20261020/SPEC.md` | pen + ontology product spec v0.1.4 | `4e4044b2c0fb7eb6379f1bcf69e3637a406f384b95e354e640df9e4ccfbc75bd` |
| `PALANTIR_COMPAT_SPEC_v0_1_1_20261019/SPEC.md` | Palantir compatibility spec v0.1.1 | `4feca84f7e8c58b8ffa558d5139b9bc38ab1db3c1db4095f4904ecfa19dec3b1` |
| `TISSUE_MAPPING_NOTE_v0_1_20261021/NOTE.md` | memory core onto tissue rc1, mapping note v0.1 | `d1d6b60a83e79ccaa3e4cb4575cba8328f7070900185721909299ab45563203c` |
| `HANDOFF_C4_MATHEMATICS_v0_1_20261022/HANDOFF.md` | C4 harness mathematics (analysis only) | `df3ec012d4435dd5f56417a1256d4dabaaddf6f3b45affbe050f06d3cc7539df` |

## Files in this folder

| File | sha256 |
|---|---|
| `design/architecture_v2.md` | `9bcbde0de04195a899191188a5cdfc56a821777064433fb0dba156a7881e921f` |
| `design/corrigibility_v2.md` | `4b741f48f25b4ba66cb185178e030f1afa1eae7dde0983e40e0245cd8e231511` |
| `design/engineering_doctrine.md` | `869d352989331a5554ee003c475e335a098f9499c9bac8b872027f0cd370472a` |
| `design/immune_system_v0_1.md` | `f48b3cd0b1dc3d1aa3f63953d6e58cfc4d3f747d8c72b2eceac7ea2f7d40b306` |
| `design/persona_rescope_2026_05_08.md` | `eb1269f58eb242a7662305a8fad7f6d3cfb8821fc43ed21d9052250cdb52395a` |
| `design/remaining_work_v3_1_1.md` | `6b7095c7705f43a184d564119a81f8bec84c9e5a0bd9293c53a368bef7f7857b` |
| `design/separability_gate_f.md` | `8d4557ea80815923fbf97efa7ef680db06b2b38cdd9356161c97e4699c6101a1` |
| `design/serena_implementation_plan_v1.md` | `c7d453af0748e7512e09f2e786ff88493e5086d9d287b784615ae3f3eb67c63c` |
| `design/serena_stack_v3_1_1.md` | `006c5fff681832a1f49ff1705719e84c5bec3f8d599675a76466c5d73cba62f9` |
| `design/zettelkasten_schema_v1.md` | `df737249b293d3c6aabcc75723d6e4d3943dcca8cf1c304d3b3941d31a0b51f2` |
| `records/HANDOFF_AGORA_ZULIP_GEMMA_v0_1_20261025.md` | `439489fc814e5b23d9d2aa7839d4a095dbdd246d5877f1673d8ec62132428fd0` |
| `records/MEMBRANE_VIEWERS_SETUP_v0_1_20261106.md` | `3eea94330df3929800896a029057cf1ba7de25aa3c77365168c7d14bbd2d7bfd` |
| `records/RUNBOOK_AGORA_ZULIP_GEMMA_v0_1_20261025.md` | `cd04d23f52d0de862f3be5f5ff20dd9de1e238a2c7c16eac658a8e76e44e0093` |
| `roadmap/freeze_record_2026-06-14_serena-v3.1.6-gemma-and-arch-patch-spec.md` | `c3b41cb31b24d3e4c1824632a29ac24f01459fc4c20f169e8b8e80f25b75eaf4` |
| `roadmap/roadmap_2026-07-02_serena-installation-kernel-parity.md` | `1aee650f8815c080165a6fc9245ff6af0095fb590a0e547a9e6eb8b66449fd05` |
| `roadmap/ruling_note_2026-07-02_product-bar-wide-margin.md` | `59a0e7f79d19126369e9b302f8690ebc0d8cce2876046b2e2392e795f0fb68bf` |
| `track/SERENA_MEMORY_PROGRESS_SUMMARY_20261019.md` | `67fa3c7c52fe28a20d35ed038431bea365b0e0c994930caf812efe0049dbe5fe` |

Renamed on copy: `freeze_record_2026-06-14_serena-v3.1.6-gemma-and-arch-patch-spec (2).md` → without the ` (2)`; the 26 Oct handoff and runbook got the folder name as prefix. Sources: `serena/serena early/serena-consolidated-2026-05-26 (1)/serena-consolidated/docs/` and `serena/serena early/` on Neo.
