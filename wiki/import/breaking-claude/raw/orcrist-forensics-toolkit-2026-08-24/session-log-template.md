# Session Log Template — Documenting Forensic Session Output

> Copy this template at the start of each forensic session. Fill in as you go.

---

## Usage

- Copy this file to `~/projetos/breaking-claude/handoffs/YYYY-MM-DD-HHMM-[slug].md` at session start
- Fill in sections as the session progresses
- At session end, update `threat-register.md` with any findings

---

## Template

Copy everything below this line:

---

```markdown
# Session Log: [DATE] — [SESSION OBJECTIVE]

## Session Metadata
- **Date**: YYYY-MM-DD HH:MM
- **Agent**: [Claude Code / OpenCode / Hermes]
- **Model**: [model name + provider]
- **Objective**: [one-line goal]
- **Claude Code Version**: [version if applicable]
- **Init Prompt Used**: YES/NO (which variant)

## Hypotheses Tested
- [HYP-XXX]: [what was tested, result]

## Findings
- [Finding 1]: [description, evidence reference]
- [Finding 2]: [description, evidence reference]

## Evidence Captured
- [path/to/evidence1] — [what it shows]
- [path/to/evidence2] — [what it shows]

## Incidents Updated
- [INC-XXX]: [what changed — status, evidence, etc.]

## Tools/Commands Used
- [command or tool]: [what it was used for]

## Next Steps
- [ ] [follow-up action 1]
- [ ] [follow-up action 2]

## Open Questions
- [question that remains unanswered]

## Raw Notes
- [any unstructured observations]
```

---

## Naming Convention

- **File name**: `YYYY-MM-DD-HHMM-[short-slug].md`
- **Location**: `~/projetos/breaking-claude/handoffs/` for session handoffs
- **Alternative**: `~/projetos/breaking-claude/research/experiments/` for experiment-specific logs

## Evidence Storage

- **Captured artifacts**: `~/projetos/breaking-claude/research/experiments/[date]-[slug]/`
- **Naming**: `YYYY-MM-DD_[description].[ext]`
- **What to include**: captured prompts, proxy logs, binary analysis output, grep results
- **Cross-reference**: Add evidence paths to `threat-register.md` incident entries

---

*Template v1.0 — 2026-07-23*
