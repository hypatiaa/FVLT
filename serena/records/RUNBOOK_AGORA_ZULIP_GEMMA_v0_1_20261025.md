# Current Agora pilot runbook: Gemma migration required

25 October 2026. Additive successor to the historical `AGORA_OLLAMA_ZULIP_WORKFLOW_2026-10-05.md`; the original is preserved unchanged.

**Do not run the old OLMo startup/test commands. OLMo removal was intentional. The old Nucleus upgrade pause is historical, not a current instruction. Local Gemma is the selected replacement; no Gemini cloud API is selected.**

## Current observed state

- Zulip-only read-only preflight: PASS, bot 10 / human 9 / `sandbox/setup-test` / verified TLS.
- Full old pilot check: FAIL (`URLError`). Agora has no listener on the pilot's expected model port 11434.
- The installed source still pins OLMo. Restoring the route alone is insufficient.
- Nucleus lists `gemma4:26b-a4b-it-qat`, digest `2dd70431afed94dd3688d790443768c1487ed086b57147ff083851116ae4c4e4`.
- Listeners 443 and 8443 were present. Preserve both services.

Checks were taken on October 25, 2026 at approximately 8:17 p.m. America/New_York. Recheck before changes; another instance is working on Agora.

## Read-only checks from Neo

```powershell
ssh agora python3 -B /home/saphir/agora-chat-pilot/pilot.py --check-zulip
ssh nucleus ollama list
```

The first command uses the private bot configuration internally but prints no key. It does not post or start the bot. Do not paste the credential file. `ollama list` lists models without generating a response.

The old full `--check` inspects the expected model through Agora's route and currently fails. Do not reinstall OLMo, disable certificate checks, reset `state/`, or start a competing tunnel to force it to pass.

## Next startup path

Follow [HANDOFF.md](HANDOFF.md): identify concurrent ownership; prepare and check the versioned Gemma successor; restore its declared route; pass both read-only preflights; then perform one bounded sandbox exchange under the existing bot assignment. Update the actual script path and chosen trigger in a later version of this runbook only after implementation exists. No working Gemma bot command is invented here.

Preserve model-specific context identity and the global delivery registry. The old `olmo:` prefix and fixed five-character slicing must be changed together. Keep replies unverified, final-only and attributed to the model/host that actually answered.
