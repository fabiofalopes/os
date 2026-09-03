# breaking-claude init/ — Forensic Session Bootstrap Toolkit

> The session entry point. Paste the init prompt, get full forensic context in one shot.

---

## What This Is

The `init/` directory is the session entry point for Claude Code forensic analysis. It provides a self-contained prompt that gives any agent complete awareness of the security research state — confirmed threats, hypotheses, tools, researchers, and methodology.

The `breaking-claude` repo IS the toolkit. The `init/` directory is how you bootstrap a session within it. Everything else in the repo (source code, analysis docs, jailbreak scripts) is reference material that the init prompt directs you to read as needed.

---

## File Index

| File | Lines | Description | When to Use |
|------|------:|-------------|-------------|
| `init-prompt-breaking-claude.md` | ~400 | Self-contained paste-into-session prompt with full threat report | Start of ANY forensic session |
| `forensic-methodology.md` | ~180 | Copy-pasteable forensic commands (codepoint audit, XOR decode, MITM, egress test) | When performing active forensic analysis |
| `threat-register.md` | ~160 | Living incident tracker + template for new incidents | When updating threat status after findings |
| `session-log-template.md` | ~70 | Per-session output template | At start of each session, copy to `handoffs/` |
| `README.md` | this file | Navigation guide | Reference — you are here |

---

## Quick Start

1. Open `init-prompt-breaking-claude.md` and copy ALL content between the `---` markers
2. Paste as your FIRST message in a new Claude Code or OpenCode session
3. Fill in the "MISSION FOR THIS SESSION" section with your specific task

That's it. The agent now has complete forensic context: 4 confirmed incidents with PoC detail, 4 unverified hypotheses, 10 community researchers, 6 external tools, attack surface map, and a mission template to guide the session.

---

## When to Use This vs Other Prompts

| Prompt | Location | Complexity | Use For |
|--------|----------|------------|---------|
| **breaking-claude init** | `init/init-prompt-breaking-claude.md` | Full forensic context (~400 lines) | Security research, incident investigation, harness analysis |
| Mac validation init | `~/projetos/llms-mac-254/handoffs/init-prompt-mac-validation.md` | Simple infrastructure check | Quick "is the server up?" validation on Mac |

The breaking-claude init is for deep forensic work. The Mac validation init is for quick infrastructure checks. They serve completely different purposes.

---

## Update Protocol

| File | When to Update |
|------|----------------|
| `init-prompt-breaking-claude.md` | When new incidents are confirmed, version changes, or community researchers publish new findings |
| `threat-register.md` | After EACH forensic session — add evidence, change status, update last verified date |
| `forensic-methodology.md` | When new tools or analysis techniques are discovered |
| `session-log-template.md` | Rarely — only if session format evolves |
| `README.md` | When files are added/removed from the toolkit |

---

## Relationship to INDEX.md

`INDEX.md` (606 lines) is the master project map — full architecture, source code map, hidden features catalog, jailbreak documentation, gas/provider infrastructure.

The init prompt is the session bootstrap — condensed forensic context optimized for pasting into a session. They complement each other:
- The init prompt says "Read INDEX.md FIRST" for full project depth
- INDEX.md cross-references `init/` for session bootstrapping

If you need to understand the full project architecture, read INDEX.md. If you need to start a forensic session, use the init prompt.

---

## Source Material

This toolkit synthesizes content from these primary research documents:

- `~/obsidian-vault/perplexity-research-claude-code-security-analysis-and-reverse-engineering-map.md` — Perplexity cyber threat report (889 lines, 67 citations, full incident details, community researcher map, RE toolchain)
- `~/obsidian-vault/prompt-dev-research-investigate-claude-code-harness-forensic-analysis-and-deconstruction.md` — User's hypothesis document (research plan, methodology, hypotheses)
- `~/projetos/llms-mac-254/handoffs/2026-07-23-2100-network-fix-claude-mac-breaking-claude.md` — Session handoff with captured system prompt details and community researcher list
- `~/projetos/breaking-claude/INDEX.md` — Master project index (606 lines, full architecture)
- `~/projetos/breaking-claude/vault-notes/Claude-Code-Steganography-And-Hidden-Features.md` — 20 hidden features cataloged across 5 severity tiers (413 lines)

---

*Toolkit v1.0 — 2026-07-23 — Part of the breaking-claude forensic research project*
