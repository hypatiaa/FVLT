# Agora handoff: reuse the Zulip pilot, migrate to Gemma, preserve Serena and the pen

25 October 2026, America/New_York. **Prepared for the instance already working on Agora.** This packet is a checked handoff and local documentation update, not a deployed bot migration.

## Decision and immediate finding

**OLMo was deliberately removed. Do not reinstall it or treat its absence as a broken Nucleus.** Robin clarified in this chat that the replacement is **local Gemma on Nucleus**, not Google's Gemini API. Opus's quoted note agrees. The old upgrade-pause instruction is historical and does not govern today's Nucleus. That correction is not permission to perform further upgrades.

The existing pilot should be reused through a versioned successor, not replaced by an unrelated bot/router stack. A live read-only check found:

| Check | Observed result |
|---|---|
| Agora `~/agora-chat-pilot/pilot.py` | Exists; SHA-256 `7e1c27d4703cb2afa97c9dda9ef0221139f828b017ad948aa8a2038c112f7ce9`; identical to the inspected local source copy. |
| Existing `--check-zulip` | PASS: bot 10, human 9, `sandbox` / `setup-test`, TLS verified, zero messages sent. |
| Existing full `--check` | FAIL: `Stopped: URLError.` |
| Agora listening ports | `192.168.0.225:443` and `192.168.0.225:8443` present; **no listening port 11434** in the captured TCP listener inventory. |
| Nucleus `ollama list` and local `/api/tags` | One model listed: `gemma4:26b-a4b-it-qat`; no OLMo entry. |
| Gemma digest | `2dd70431afed94dd3688d790443768c1487ed086b57147ff083851116ae4c4e4` |
| Docker container inspection | Unavailable to the SSH user without additional privilege; no sudo attempt made. Do not claim a fresh Docker health check from this pass. |

These are observations at **2026-10-26 00:17:50 UTC / October 25, 8:17:50 p.m. EDT**, with the Nucleus inventory taken just beforehand. The pilot's full check cannot currently reach its expected model route; even after that route is restored, its pinned OLMo name/digest will require migration. The Zulip preflight itself passed. This does **not** certify generation, a live bot reply, every Zulip feature, images or a production service.

## 1. Start from these sources

Workspace root: `C:/Users/robin/s6_atom`. Paths below are workspace-relative; selected reading copies are under `sources/` in the portable packet.

1. `AGORA_PILOT_CURRENT.md`: current entry point, naming the intentional OLMo removal.
2. `AGORA_OLLAMA_ZULIP_WORKFLOW_2026-10-05.md`: **historical** verified pilot workflow. It still has OLMo commands and the superseded upgrade hold. Preserve its bytes; do not follow it as current startup instructions.
3. `agora_setup_2026-09-24/chat_pilot/pilot.py`, `test_pilot.py`, `README.md`, `verification.json`: source and offline tests. The installed `pilot.py` matched this source at inspection. The old README's installation/verification wording is historical too.
4. On Agora: `/home/saphir/agora-chat-pilot/`; state is under `state/`. Read its installed public source before editing; it may change after this handoff.
5. `HANDOFF_OPUS_FOURIER_PEN_WORK_v0_1_20261025/HANDOFF.md`: the comprehensive pen locator. Its separate portable ZIP contains 78 selected source files; this packet includes the locator but not that entire ZIP.
6. `INSTRUMENT_LANGUAGE.md`, header edition v0.12 when inspected: shared semantics, model experience, retained/discarded measurements and the corrected navigation chapter.

`SOURCE_MAP.json` pins this reading snapshot. Stored historical manifests inside selected source folders describe their original complete packages; some original members are intentionally not included in this reading packet. Use the packet's own manifest to verify the packet.

Portable reading links: [current migration runbook](RUNBOOK.md), [historical pilot source](sources/agora_setup_2026-09-24/chat_pilot/pilot.py), [historical pilot tests](sources/agora_setup_2026-09-24/chat_pilot/test_pilot.py), [pen locator](sources/HANDOFF_OPUS_FOURIER_PEN_WORK_v0_1_20261025/HANDOFF.md), [combined language](sources/INSTRUMENT_LANGUAGE.md), [live inspection results](LIVE_CHECKS.json), and [offline test result](OFFLINE_CHECKS.json). Historical links inside source copies retain their original targets and may require the original workspace or the separate full pen packet.

## 2. Topology and responsibilities

| Host alias from Neo | Saved address | User | Role retained |
|---|---|---|---|
| `ssh agora` | 192.168.0.225 | saphir | Zulip/transport, bounded chat routing, coordination infrastructure. |
| `ssh nucleus` | 192.168.0.177 | saphir | Local Gemma; current intended first chat backend. |
| `ssh scout` | 192.168.0.228 | saphir | Main GPU model box; Opus reports `nemotron-vl` for visual inspection. Exact current tag/capabilities not checked here. |
| `ssh membrane` | 192.168.0.210 | saphir | Light-model coordinator/routing role; not automatically a drop-in substitute for every backend. |

The recent resource report for Agora (about 11 GB RAM available, four idle cores, 434 GB free disk) is user-supplied, not a fresh capacity measurement here. A successful SSH login or installed model tag does not establish image support, schema conformance, pen competence, latency or deployment.

Preserve the service on **8443**, recorded in the existing Stack Bus/gateway architecture, and Zulip on **443**. Port presence was observed; the 8443 process identity was not freshly audited. Inspect before changing either. A chat router must not replace the authenticated Stack Bus gateway, take its port, borrow its keys or acquire its authorities. No new LiteLLM, Open WebUI, monitoring stack or reverse proxy is necessary to finish this first bounded migration.

## 3. Repair the model route without broad exposure

The historical route is Nucleus -> reverse SSH tunnel -> **Agora loopback 11434** -> Nucleus loopback Ollama 11434. It formerly required a foreground tunnel and pilot terminal. It is not currently listening on Agora.

- First check whether another authorized instance is already restoring or supervising that route. Do not start a second bot or competing port forward.
- Prefer retaining a loopback SSH route for the first migration. If the owner chooses a LAN endpoint instead, document it and restrict allowed callers; do not broadly expose an unauthenticated Ollama API to every Wi-Fi client by default.
- On Nucleus, the old reverse-tunnel command connects to **Agora**, so Neo's SSH aliases are not automatically available there. Use an address/alias known on that host. When restoring a tunnel under the existing task, explicitly bind its Agora end to `127.0.0.1:11434`, retain host-key verification and `ExitOnForwardFailure`, and confirm which Nucleus endpoint it reaches.
- A missing route is not a reason to reinstall OLMo, reinstall Zulip, disable TLS verification, rotate unrelated credentials or reset state.
- Decide supervision separately after the bounded test works. A process kept alive by an interactive SSH session is not a boot-persistent deployment.

## 4. Migrate every OLMo dependency, not just MODEL

The inspected installed source still hardcodes these old assumptions:

| Area | Existing source lines | Required successor behavior |
|---|---|---|
| Model and digest | 27-28; preflight 155-160 | Pin current Gemma name **and full digest**. Verify through the actual route. Do not weaken the preflight to accept any installed model. |
| System identity | 35 and following | Stop telling Gemma it is OLMo. Preserve the no-tools/no-action/no-authority scope. |
| Trigger and parsing | 197-200 | Replace or explicitly deprecate `olmo:`. If choosing `gemma:`, replace fixed `[5:]` slicing with `len(prefix)`; otherwise the prompt is misparsed. Do not silently expand to arbitrary mentions/topics/users. |
| Reply attribution | 254 | Identify Gemma, Nucleus and the actual route/model identity. Keep output labeled unverified. |
| READY/help text | 278, 306 | Reflect the new explicit trigger and scope. |
| Documentation and fixtures | Old runbook, README, test fixtures | Update the active successor and tests; historical OLMo examples remain historical, not an install requirement. |
| History and delivery records | `Store.history`, `state/delivery.sqlite3` | Preserve deduplication and delivery evidence. Begin a new Gemma conversational context unless an explicit provenance-preserving history import is designed. Old untagged OLMo replies must not silently appear to be Gemma's earlier answers. |

The current pilot verifies the exact response model name and a completed final response, bounds prompt/history/output size, and rejects empty finals, tool calls and embedded thinking markers. Keep those behaviors. Check Gemma's actual response shape and supported options before changing them. A response budget failure should remain a visible failed request, not a reason to leak thinking text or silently change model.

Retain the existing application allowlist (human 9, channel 2, topic `setup-test`) until an actual broader bot scope is specified. Keep TLS, source-message revalidation after generation, mention neutralization, single-worker locking and uncertain-delivery handling. Do not delete `state/` to make the new model work. Maintain global deduplication by source occurrence while separating model-specific context. If adding identity fields, make the migration versioned and reversible and treat legacy provenance explicitly.

## 5. Preserve the Serena architecture

The chat pilot is a connectivity tool, not the governed Stack Bus and not the full Serena system.

Proposed integration shape:

```text
Zulip source occurrence -> authenticated, bounded input admission
 -> explicit route and model capability check -> model proposal/final
 -> deterministic validation -> fixed Zulip reply destination

Pen proposal -> separate pen executor -> revision-bound preview
 -> vision advice -> explicit experience record -> reviewed memory promotion
```

- Agora coordinates transport. Model prose cannot choose recipients, execute shell commands, grant permissions, accept ontology claims or write the authoritative graph.
- Preserve the separation between typed routing advice and prose/model work. Route by actual capabilities and task, not simply whichever box is idle. A text-only fallback cannot quietly satisfy a vision request. Fallback identity and reason must be visible; do not substitute a cloud API.
- Keep chat-delivery SQLite state distinct from Serena persistent memory, canonical events and the Zettelkasten. Use existing context/provenance contracts for any later connection.
- The Stage 1 memory core has its own exact-conductor energy/update/log implementation and disclosed flags. It does not already supply real-source observation adapters, FCA, ArcadeDB integration, the numerical FFT route or learned weights.
- The ontology's mathematical meaning is not defined by a generic graph database or message router. Keep assertions/evidence, definitions, executions, views and occurrence identities distinct. ArcadeDB integration remains an explicit adapter/promotion step.

## 6. Preserve the pen architecture

Read `FOURIER_PEN_ADAPTER_v0_1_1_20261017/README.md` and `AGENT_GUIDE.md`; read the prepared local model contract in `IDEA_CATALOG_LUMEN/output/PYDANTIC_AI_FOURIER_PEN_SCHEMA_v0_1_20261018/SPECIFICATION.md` and `schema.py`.

- Gemma proposes strokes. Nemotron supplies image-bound observations/advice. Controlled code validates scope, permissions, groups, budgets, document revision and frame before mutation. A model proposal or a hash does not grant permission.
- The actual preview bytes must reach the visual model. Preserve image/frame hashes and exact crop-to-document mapping. Nucleus's current text-only assigned role does not establish that this particular serving path can inspect images; capability tests are separate.
- `pen_fit_path` fits supplied contour points; it is not an implemented learned image-to-stroke decoder. The adapter's exact phase/rational records and its numerical fitting/rendering diagnostics retain separate standings.
- Keep ordered actions, holds, alternatives, observed prefixes, outcomes, model/route identity, parameters and occurrence provenance alongside summaries. Full conductor energy, scalar-line energy and residual energy discard different information. An FFT is not a universal replacement for these contracts, and none is the RH Poisson/GCD norm.
- Saving an experience externally does not train model weights. The lattice-memory demo uses scripted choices; it is not evidence of neural learning. Any later training/evaluation needs its own data and experiment scope.
- The quoted Opus pen probe was described as ready, not as completed evidence. Do not run or report it as having passed from this handoff alone. The paused raven placement experiment also stays paused.

## 7. Bounded work order for the Agora instance

Continue within Robin's existing bot task; this document does not itself perform remote changes or authorize a broader deployment.

1. Inspect the installed pilot and route, pin their current state, and check concurrent ownership before changes.
2. Prepare the smallest versioned Gemma successor, configuration and offline tests. Preserve old source and delivery state; do not restore OLMo or its upgrade hold.
3. Reproduce offline admission, output-filtering, changed-input, duplicate, crash and uncertain-send checks; add prefix-length, Gemma identity/digest, history separation and fallback-provenance cases.
4. Restore the selected model route within the authorized bot scope. Run separate read-only Zulip and model-inventory checks. A Zulip PASS must remain distinguishable from a backend failure.
5. Under the bot task's actual live-posting authorization, use one new human-provided `sandbox/setup-test` prompt for a bounded Gemma response. Record input ID, host, full model digest, reply ID, completion/error state and scope. Do not send a test merely because this handoff contains an example.
6. Test interruption/restart and duplicates without replaying old prompts. Preserve uncertain sends for inspection; neither inference retry nor fallback may resubmit an ambiguously delivered reply.
7. Report the exact changed files, original/current pins, offline results, actual live observations, remaining limitations and rollback route. Keep service supervision, broader channels, vision and pen execution as separate stages.

No production exactly-once guarantee is inferred from the SQLite claim strategy. It intentionally favors missed replies over duplicated sends after ambiguity.

## 8. Required report and evidence

The owner should return:

- Source/configuration identity and model/digest; obsolete OLMo references resolved in the **active** route and docs.
- Separate Zulip health, backend reachability, model availability, inference, posting and persistence results.
- Admission/routing scope, fallback policy and any capability limits.
- History/delivery-state migration behavior, duplicate prevention and uncertain-send handling.
- Preservation of 443/8443, existing credentials, Stack Bus authority boundaries and the pen/memory contracts.
- What remains proposed or untested; no restoration of intentionally removed software.

## 9. What this preparation actually did

Read local sources, inspected host aliases, compared the installed public pilot hash, read Nucleus's model inventory, ran the existing read-only preflights and inspected listeners. The preflights authenticate through the existing private bot configuration internally; credential contents were not printed or copied. **Zero model generations, zero Zulip messages, no remote file/service/configuration changes, no model downloads and no database migration.** The old local runbook and source remain byte-preserved. An offline fake-server test rerun, if present in this packet, is labeled separately from live checks.

**Offline rerun:** all nine existing pilot tests passed from the selected copied source, using fake servers and a fresh local temporary state. This verifies the historical guardrails at that scope; it is not a test of the unimplemented Gemma successor. `OFFLINE_CHECKS.json` and the captured output record the run. `verify_handoff.py` checks the selected snapshots and packet hashes without executing source programs; pass `--workspace <root>` to compare originals too.

Public API references: [Ollama model inventory](https://docs.ollama.com/api/tags), [Ollama chat](https://docs.ollama.com/api/chat), [Zulip message reads](https://zulip.com/api/get-messages), [Zulip sends](https://zulip.com/api/send-message). Installed behavior and the pinned source, not the latest documentation alone, determine compatibility here.
