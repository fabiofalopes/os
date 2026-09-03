---
id: DEC-0003
type: decision
date: 2026-09-02
context: "EXP-0007 needs to run the held v2.1.88 harness against a fake localhost policy server. The shipped 2.1.88 binary is unobtainable (npm versions jump 2.1.87→2.1.89 — the leaked version was pulled). The brief's ANTHROPIC_BASE_URL lever is refuted by source: isFirstPartyAnthropicBaseUrl() requires it UNSET for eligibility."
options: ["reconstruct a full runnable bundle from the leak tree (stub ~250 stripped modules + fix stale pins + bundle defines)", "channel-level driver: run the genuine held-tree services/policyLimits module under bun with runtime MACRO global + USER_TYPE=ant/USE_LOCAL_OAUTH=1 lever", "abandon e2e, keep static-only scope (PARTIAL verdict)"]
decision: "Channel-level driver (option 2), with deviations documented in the experiment note; full-bundle reconstruction rejected as scope-creep (leak-reconstruction project, not an experiment)."
supersedes: null
status: active
summary: EXP-0007 runs the genuine held-tree policy service via bun driver with runtime MACRO global and the ant/local-oauth env lever; deviations honestly ledgered.
---
## Context

The eligibility gate (`isPolicyLimitsEligible`) requires provider=firstParty and `isFirstPartyAnthropicBaseUrl()` (i.e. `ANTHROPIC_BASE_URL` UNSET), so the only routing lever to a local fake server is the oauth `local` config branch: `USER_TYPE=ant` + `USE_LOCAL_OAUTH=1` + `CLAUDE_LOCAL_OAUTH_API_BASE`. In shipped builds `process.env.USER_TYPE` is inlined to `"external"` at bundle time, making the branch unreachable there; the leak-tree source evaluates it at runtime (the sandbox copy of the build script has that define removed — mirrors an ant-internal build).

Runtime gaps found and closed in the sandbox copy only (original tree untouched):
- ~250 modules absent from the leak (ant-internal features) — inert soft-proxy stubs, none on the policy path (`stubgen.py`, `leak-tree-gap-build.log`).
- Stale dependency pins (otel 1.30 vs v2 API in code) — newer packages installed in the copy.
- `MACRO.*` build-time defines (VERSION/PACKAGE_URL/ISSUES_EXPLAINER) — supplied at runtime by the driver; without it User-Agent construction throws pre-wire and the fetch silently retries 5x into fail-open (an instructive failure mode: the channel masks its own misconfiguration exactly as designed).

## Options considered

As listed above. Option 1 costs days and increases deviation surface; option 3 loses the 1h-poll/ETag behavioral evidence.

## Rationale

The claim surface (CLM-0020) IS the channel: endpoint, schema, poll interval, ETag, cache, fail-open, enforcement callsites — all fully contained in the service module driven via its real entrypoints exactly as main.tsx:958 does. Every deviation is documented in EXP-0007 + the kit README (honesty ledger). Negative control (runN2) demonstrates the fail-open/fallback semantics independently, so consumption evidence (runA2) is not confounded with miss semantics.
