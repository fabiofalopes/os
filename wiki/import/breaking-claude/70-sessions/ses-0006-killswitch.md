---
id: SES-0006
type: session
date: 2026-09-02
models_used: ["opencode-go/glm-5.3-flash (orchestrator)", "direct execution — no subagents (sub-fuel pin broken, see failures)"]
cycle_metrics:
  M1_time_release_to_verified: "CLM-0020 offline behavioral confirmation achieved within one session of the corrected static scope (EXP-0004 2026-08-26 → EXP-0007 2026-09-02)"
  M2_verdicts: "1 experiment (EXP-0007) with 6-run matrix; 1 verdict (DEMONSTRATED, runC 1h-poll sub-result finalized same session)"
  M3_version_coverage: "acquired/analyzed unchanged (v2.1.88); new provenance data: npm no longer serves 2.1.88 (2.1.87→2.1.89 gap); leak tree stripped of ~250 modules"
  M4_reproducibility: "run matrix deterministic; negative control reproduces fail-open + essential-traffic fallback semantics from source"
  V1: "unchanged (no grade changes; CLM-0020 stays g4, evidence strengthened)"
  V2_orphans: "0 — all new notes linked from indexes/MOC in-cycle"
failures:
  - "Subagent dispatch fix-1 failed at model resolution: zai/glm-5-turbo unresolvable in opencode catalog (upb lists it); lane reassigned to direct execution; config fix proposed for human (small_model → zai/glm-5.2)"
  - "Brief's ANTHROPIC_BASE_URL lever refuted by source: isFirstPartyAnthropicBaseUrl() gates eligibility on that exact var; corrected lever = USER_TYPE=ant + USE_LOCAL_OAUTH=1 + CLAUDE_LOCAL_OAUTH_API_BASE (V4 boot data point)"
  - "Full-CLI boot from leak tree impossible: ~250 stripped modules + stale dependency pins (otel 1.30 pins vs v2 API in code); pivoted to channel-level driver (DEC-0003)"
  - "MACRO build-time define missing at runtime (User-Agent construction threw pre-wire, 5x retry, fail-open) — diagnosed via sandbox-copy instrumentation; fixed with runtime MACRO global (DEC-0003)"
summary: Offline e2e for CLM-0020 (EXP-0007): fake localhost policy server + genuine held-tree v2.1.88 service; poll, schema, ETag/cache, fail-open, and corrected-key enforcement all demonstrated; refuted keys have zero callsites (boundary is callsite-level).
---
## Work done

- Boot per protocol; evidence extraction from CLM-0020/0014, EXP-0004, raw policy logs, and the held source tree.
- Built `experiments/exp-0007-killswitch/`: zero-dep fake policy server (ETag/304 contract, request logging, variants), channel driver, runner, auto-stub tooling.
- Ran 6-run matrix (see [[../50-experiments/exp-0007|EXP-0007]]): positive runs A/A2/B, port-independence replication runN, negative control runN2, and runC 1h-poll observation.
- Write-back ritual; leak-tree provenance findings recorded (feeds Q-0003).

## Metrics

See frontmatter. ZeroAnthropic-egress invariant held for all runs (REPL-style driver, no inference calls, telemetry/updater disabled, loopback-only server).

## Failures

See frontmatter; each is documented with root cause and either a fix or a proposed human action.
