---
id: CTX-mission
type: context
---

# Mission — Breaking Claude

Understand, verify, and document what the Claude Code harness actually is and
what it actually does — every version we decide matters, latest version first.
Combine trusted external research with our own hands-on disassembly in the
sandbox. The target is either innocent or guilty; our job is to map everything
and let evidence decide. No opinion without an evidence pointer; no claim
amplified before grading.

## Why (background, graded elsewhere)
- The Apr 2026 period surfaced: source-map leak (2026-03-31), third-party
  harness ban (Apr 4), official postmortem (Apr 23) admitting harness-caused
  degradation, and hidden proxy-detection telemetry (v2.1.91) later rolled
  back. External claims graded in the Forge vault synthesis note
  "Breaking Claude — The Landscape 2026 (Research Synthesis)" — those grades
  now migrate into `20-claims/` as canonical IDs.
- Our position: UPB runs the harness over paid third-party keys (zai/GLM
  default), no impersonation. We study the harness; we don't fight it.

## Never
- The phonetic/voice-capture tangent — out of scope, unlinked, forever.
- No DoS, no attacks on Anthropic infrastructure, no ToS-violating credential
  games. Observation and disassembly of artifacts we legitimately hold.
- No drift into generalizing the machinery at the mission's expense.

## Assets
Leaked source tree `~/research/claude-code-original` (2026-03-31 snapshot);
upb gateway (model routing for all roles); Kali host as experimentation rig;
Forge vault (sibling knowledge system, human-facing). Tester account:
**not yet located — human to supply**; authenticated-run hypotheses blocked
until then.
