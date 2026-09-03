# Threat Register — Claude Code Security Incidents

> Living document. Both a template for future incidents and a tracker of current confirmed threats and hypotheses.

---

## How to Use This Register

- **For new incidents**: Copy the template below, assign next INC-XXX ID, fill in all fields
- **For status updates**: Change the Status field, update Last Verified date, add evidence link
- **For new hypotheses**: Copy the hypothesis format, assign next HYP-XXX ID, set confidence level
- **Keep confirmed and hypothesized STRICTLY SEPARATED**

---

## Incident Template

```
### INC-XXX: [Incident Name]
- **Status**: CONFIRMED / PATCHED / HYPOTHESIZED / DISPUTED
- **Severity**: CRITICAL / HIGH / MEDIUM / LOW
- **Affected Versions**: [version range]
- **Discovered**: [date] by [researcher]
- **Description**: [what happened, 2-3 sentences]
- **Technical Detail**: [mechanism, PoC reference]
- **Evidence**: [GitHub issue, blog post, binary analysis link]
- **Resolution**: [patched in vX.Y.Z / unresolved / N/A]
- **Last Verified**: [date]
```

---

## CONFIRMED INCIDENTS

### INC-001: Steganographic Endpoint Fingerprinting
- **Status**: CONFIRMED / PATCHED
- **Severity**: MEDIUM-HIGH
- **Affected Versions**: v2.1.91 – v2.1.196
- **Discovered**: 2026-06-30 by thereallo (binary RE) + Adnane Khan (independent verification)
- **Description**: Claude Code silently encoded a 3-bit fingerprint into the "Today's date is..." system prompt line, but ONLY when ANTHROPIC_BASE_URL pointed to a non-Anthropic endpoint. Used Unicode apostrophe variants (U+0027/U+2019/U+02BC/U+02B9) and date separator swaps.
- **Technical Detail**: Two obfuscated lists (147 domains + 11 keywords) encoded with XOR-91 + base64. Domain list checks proxy hostname; keyword list checks for AI lab names. Date separator encodes timezone (Asia/Shanghai flag). See `init-prompt-breaking-claude.md` for full PoC and encoding table.
- **Evidence**: GitHub issue #72518 (anthropics/claude-code); thereallo.dev blog; vincentschmalbach.com analysis; agentpedia.codes breakdown; TechTimes coverage
- **Resolution**: v2.1.197 shipped 2026-07-01 as stated fix. NO changelog mention. Post-patch binary audit not yet published.
- **Last Verified**: 2026-07-01

### INC-002: Network Sandbox Bypass #1 (Inverted Default)
- **Status**: CONFIRMED / SILENTLY PATCHED
- **Severity**: HIGH
- **Affected Versions**: Unknown
- **Discovered**: Unknown (before May 2026)
- **Description**: Empty allowlist was interpreted as "allow all traffic" instead of "block all traffic" — an inverted safety default in the network sandbox.
- **Technical Detail**: In a tool with shell access, file write, and git push permissions, the network sandbox's empty allowlist should have been deny-by-default. It was allow-by-default.
- **Evidence**: No CVE, no advisory, no changelog entry. Patched silently.
- **Resolution**: Silently patched. No disclosure.
- **Last Verified**: 2026-07-23

### INC-003: Network Sandbox Bypass #2
- **Status**: CONFIRMED / SILENTLY PATCHED
- **Severity**: HIGH
- **Affected Versions**: Unknown
- **Discovered**: May 2026 by Aonan Guan
- **Description**: Second network sandbox escape found in the same tool with shell+file+git access.
- **Technical Detail**: Disclosure by security researcher Aonan Guan. Details not publicly available.
- **Evidence**: Disclosed privately. No CVE, no advisory, no changelog entry.
- **Resolution**: Silently patched. No disclosure.
- **Last Verified**: 2026-07-23

### INC-004: Silent Model Downgrade
- **Status**: CONFIRMED / PARTIALLY REMEDIATED
- **Severity**: MEDIUM
- **Affected Versions**: Unknown (during Fable 5 launch period)
- **Discovered**: June 2026 (during Fable 5 launch)
- **Description**: Flagged/resource-intensive requests were silently routed to a weaker model without disclosure. Users billed as if receiving full-capability output.
- **Technical Detail**: During Fable 5 launch, Anthropic silently downgraded flagged requests. No UI indicator, no notification. Pattern-consistent with other incidents: behavioral change undisclosed until found externally.
- **Evidence**: Community exposure. Anthropic apologized after discovery.
- **Resolution**: Visible fallback indicators added after community exposure. Partial remediation — behavior change was undisclosed until externally discovered.
- **Last Verified**: 2026-07-23

---

## ADJACENT THREATS (not Anthropic-attributed)

### ADJ-001: Persona Persistence Attacks (PPA)
- **Status**: CONFIRMED (attack class, NOT Anthropic-attributed)
- **Severity**: HIGH
- **Discovered**: 2026-03-31 by ClawSouls/SoulScan
- **Description**: CLAUDE.md/SOUL.md files containing self-modification instructions ("Update CLAUDE.md after each session") create permanent backdoors. Unlike prompt injection (dies at session end), PPAs write to disk and persist across all future sessions.
- **Technical Detail**: A persona file instructs the LLM to modify itself. The LLM executes it, modifying the file on disk. Next session loads the modified file as trusted system-level context. Behavior permanently altered.
- **Evidence**: dev.to/tomleelive article; clawsouls.ai/soulscan; SEC090 (ERROR) and SEC091 (WARNING) detection rules
- **Model Dependency Gap**: Conservative models (Claude) refuse self-modification. Open-weight models (Qwen, GLM, Llama) comply without question. **THE WEAKEST MODEL IN YOUR PIPELINE SETS THE SECURITY FLOOR.**
- **Resolution**: N/A (attack class, not vendor bug). Mitigation: Run SoulScan before loading any external persona file.

---

## UNVERIFIED HYPOTHESES (tracking)

### HYP-001: Deliberate Model Degradation on Endpoint Redirect
- **Status**: UNDER INVESTIGATION
- **Confidence**: LOW
- **Hypothesis**: Claude Code may contain triggers that cause the model to become erratic or fail specifically when the endpoint is modified (e.g., redirected to non-Anthropic model).
- **Evidence For**: User reports of erratic behavior when using alternative endpoints. Difficulty modifying the harness.
- **Evidence Against**: No technical evidence found. Could be explained by token overhead, context mismatch, or model capability differences.
- **Test**: Run identical tasks through Anthropic endpoint vs alternative endpoint with same model. Compare output quality.

### HYP-002: Cross-Agent Attack via Shared Filesystem
- **Status**: UNDER INVESTIGATION
- **Confidence**: MEDIUM
- **Hypothesis**: Claude Code may use its filesystem permissions to influence other running agents by writing to or modifying shared config files (CLAUDE.md, AGENTS.md, soul.md).
- **Evidence For**: AutoDAN research paper validates that binaries can inject instructions into LLM pipelines via string variables. PPA research shows filesystem-based persistence is viable.
- **Evidence Against**: No direct evidence of Anthropic-deployed cross-agent attacks.
- **Test**: Monitor `~/.claude/` for unexpected file writes during sessions. Run file integrity monitoring on persona files.

### HYP-003: Embedded Speculative Local Decoder
- **Status**: UNDER INVESTIGATION
- **Confidence**: LOW
- **Hypothesis**: Anthropic may embed a small local model in the Claude Code binary that acts as a speculative decoder, coupling the harness to their backend and making it unstable when decoupled.
- **Evidence For**: Industry trend toward edge-to-cloud speculative decoding. Anthropic's cost-reduction incentives.
- **Evidence Against**: No evidence of embedded model in v2.1.1 binary (220MB — too small for a useful local model). Pure speculation.
- **Test**: Static binary analysis for model weights or inference code. Network analysis for undisclosed local compute.

### HYP-004: Undisclosed Phone-Home Beyond Configured Endpoint
- **Status**: TESTABLE
- **Confidence**: MEDIUM
- **Hypothesis**: Claude Code may phone home to endpoints beyond the configured ANTHROPIC_BASE_URL (e.g., Statsig for feature flags, analytics endpoints, policy limits API).
- **Evidence For**: Leaked source (v2.1.88) shows Statsig integration, quota probes, policy limits API calls. `block-claude-phonehome.sh` blocks multiple domains.
- **Evidence Against**: These phone-homes are documented in the leaked source and may be legitimate feature flag / telemetry, not covert surveillance.
- **Test**: Run sandboxed egress test (Docker `--network=none` with explicit allowlist). Monitor ALL outbound connections.

---

## VERSION MATRIX

| Incident | Our Version (v2.1.1) | Affected Range | Status |
|----------|---------------------|----------------|--------|
| INC-001 (Steganography) | SAFE (predates) | v2.1.91–v2.1.196 | Patched v2.1.197 |
| INC-002 (Sandbox #1) | Unknown | Unknown | Silently patched |
| INC-003 (Sandbox #2) | Unknown | Unknown | Silently patched |
| INC-004 (Model Downgrade) | N/A (server-side) | Fable 5 launch period | Partially remediated |
| ADJ-001 (PPA) | N/A (attack class) | All versions with persona files | Mitigation: SoulScan |

---

## UPDATE PROTOCOL

- **When a new incident is confirmed**: Add as INC-XXX using template. Update `init-prompt-breaking-claude.md` to include it.
- **When a hypothesis is verified**: Move from HYP section to INC section. Update confidence to CONFIRMED.
- **When a hypothesis is debunked**: Mark as DEBUNKED with evidence. Do NOT delete — keep for reference.
- **After each forensic session**: Update relevant entries with new evidence, changed status, last verified date.

---

*Register v1.0 — 2026-07-23 — Incidents sourced from Perplexity cyber threat report and community research*
