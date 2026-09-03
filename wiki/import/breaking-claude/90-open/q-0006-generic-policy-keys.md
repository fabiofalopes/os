---
id: Q-0006
type: question
opened: 2026-09-02
priority: medium
blocked_by: []
status: open
summary: Does any harness version add isPolicyAllowed() callsites beyond the three allow_* keys, turning the key-agnostic service record into a generic remote killswitch surface?
---
## Question

EXP-0007 demonstrated the v2.1.88 policy-limits service honors ANY key present in the served `restrictions` record (`isPolicyAllowed` is a generic record lookup) while the enforcement boundary in this version is callsite-level (only `allow_remote_control`, `allow_remote_sessions`, `allow_product_feedback` are ever queried). Do later versions (or hidden/internal builds) add callsites querying additional keys — e.g. a `bypassPermissions` or MCP-related key — which would silently reactivate the CLM-0014-style killswitch capabilities?

## Why it matters

The service side is already a generic killswitch engine: vendor can push any `{key: {allowed: bool}}` record and the client persists it mode-0600 and honors it on query. The ONLY thing preventing remote permission-posture control in v2.1.88 is the absence of callsites. A single new `isPolicyAllowed('bypassPermissions')` call in any future version flips the answer. This is the highest-leverage single-line diff to watch across versions.

## What would answer it

- Tree-wide `isPolicyAllowed(` enumeration per acquired version (same method as EXP-0004; cheap static pass per M3 acquisition).
- Specifically grep for `bypassPermissions`, `mcp`, `permissions` string literals as first arguments.
- M3 acquisition of additional versions (handoff next-step #2) feeds this directly.
