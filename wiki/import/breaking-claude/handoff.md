# Handoff — state after SES-0006

## Completed
- EXP-0007 offline e2e policy-channel demo (CLM-0020): fake localhost policy server + genuine held-tree v2.1.88 service via bun channel driver (DEC-0003). 6-run matrix archived with SHA256SUMS (`archive/exp-0007-killswitch-2026-09-02/`): fetch/parse/cache/apply, decision-level corrected-key enforcement, cache rewrite on variant switch, 1h background poll + If-None-Match→304, negative control matching source fallback semantics. Zero Anthropic egress.
- CLM-0020 evidence extended (stays g4, last_confirmed 2026-09-02); key nuance recorded: service is key-agnostic, refuted-key boundary is callsite-level → Q-0006 opened.
- KB: 20 claims, 11 sources, 7 experiments, 3 decisions, 6 open questions; indexes de-staled (50-experiments, 70-sessions, MASTER_INDEX counts).

## Needs human review
- DEC-0001 project location; DEC-0002 routing table (first production routing human-approved)
- opencode config defect: `small_model: zai/glm-5-turbo` unresolvable (subagent dispatch fix-1 failed; upb lists the model, opencode catalog does not). Proposed fix: repoint to `zai/glm-5.2` (validated main fuel). NOT changed in-session (global config mid-session).
- Public-repo posture of orcrist breaking-claude (see fabio@orcrist:~/obsidian-vault/breaking-claude-repo-plan.md)

## Next (in order)
1. Version acquisition: enumerate + fetch additional tarballs beyond 88/91/196/246 (M3 workstream); note npm no longer serves 2.1.88 (2.1.87→2.1.89 gap) — acquisition provenance matters. Each new version = full static scan pass + Q-0006 callsite check per forensic-methodology
2. MITM capture of startup sequence (quota probe behavioral confirm + egress map) via RPi-Net or laptop MITM setup
3. Rewrite INDEX.md claims on orcrist w/ inline grades harvested from this vault (only >=g3 quoted)
4. Q-0003 follow-up: leak-tree provenance — ~250 stripped modules + stale dependency pins documented in EXP-0007/leak-tree-gap-build.log

## Do NOT
- Do not re-litigate CLM-0013 without a version-specific artifact
- Do not quote the 108 figure publicly without build artifacts
- Do not set ANTHROPIC_BASE_URL for policy-channel experiments — it kills eligibility (isFirstPartyAnthropicBaseUrl); use the DEC-0003 lever instead
