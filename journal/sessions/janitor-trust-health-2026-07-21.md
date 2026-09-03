---
tags: [janitor, harness, health, trust]
date: 2026-07-21
status: durable — fix + verification evidence
related:
  - "[[meta-review-2026-07-21]]"
  - "[[multi-agent-orchestration-patterns]]"
---

# [Janitor] TRUST + HEALTH FIX — 2026-07-21

> Job: (a) make the permissions allowlist apply to cron sessions (trust flag; the "Ignoring 25 permissions.allow entries" warning was hanging jobs to the 900s timeout — LOG 04:45Z, 06:45Z); (b) fix `health.sh` counting non-session LOG lines as failed runs. Verify both with evidence.

## Verdict

**Both resolved and verified.** (a) trust flag already `true` for both relevant project keys — confirmed from disk; workers additionally run `--dangerously-skip-permissions`, so trust/allowlist no longer gate cron sessions at all. (b) the `manual`-line exclusion was already in the working tree (prior session, uncommitted); I found and fixed one remaining non-session class — the substrate-guard line — and verified `health.sh` now matches an independent LOG grep exactly.

## (a) Workspace trust

Evidence (read from `/home/fabio/.claude.json`):
- `projects["/home/fabio"].hasTrustDialogAccepted = true`
- `projects["/home/fabio/obsidian-vault-kali"].hasTrustDialogAccepted = true`

Idempotent setter run: **no change needed** (both already true; no file rewrite, no backup created).

Root-cause chain of the 900s hangs, for the record:
1. Pre-wave-engine runner did not `cd` into the vault → workspace = `/home/fabio` → untrusted → Claude ignored the allowlist → headless session can't run tools → hangs to the 900s timeout (LOG 04:45Z, 06:45Z both carry the warning).
2. Now double-covered: (i) trust flag true for both keys; (ii) `_harness/worker.sh:24` does `cd "$VAULT"` and `worker.sh:69,72` pass `--dangerously-skip-permissions` — permissions are bypassed entirely for workers.

Clarification so a future Steward doesn't chase this: the **"25 permissions.allow entries" are home-level** (`/home/fabio/.claude/settings.local.json`) — legacy camera/ESP32 rules migrated from an old machine (they reference `/home/ken`). The **vault's** `.claude/settings.local.json` has **1** entry (`Bash(crontab -l)`). Neither matters while workers run with `--dangerously-skip-permissions`; if that flag is ever removed, the vault allowlist — not the home one — is what needs populating.

## (b) health.sh non-session counting

State found: the `manual`-ops exclusion (the reported "21 fails vs 19 real" bug) was **already fixed in the working tree** by a prior session (uncommitted; `git diff` shows it). While verifying, I found a third non-session class still counted: the substrate guard's revert note (`| 0s | SUBSTRATE_VIOLATION | (guard) |`, added with the wave engine) — bookkeeping, not a session.

Fix applied to `_harness/health.sh`: one shared `NONSESSION` regex (SKIP/QUARANTINED + `SUBSTRATE_VIOLATION | (guard)` + `manual` lines) used by `ran_today`, `ok_today`, and the `recent` window — so the three sites can't drift.

Evidence — count progression today (same LOG, 32 dated lines):

| version | runs | ok | fail |
|---|---|---|---|
| HEAD (no exclusions) | 32 | 6 | 26 |
| working tree (manual excluded) | 29 | 6 | 23 |
| **now (manual + guard excluded)** | **28** | **6** | **22** |
| independent grep (ground truth) | 28 | 6 | 22 |

Verification (07:51Z): `bash _harness/health.sh` → `runs today: 28 (ok=6 fail=22 proxy-skips=0)`; independent grep → `sessions=28 ok=6 fail=22`, excluded `manual=3 guard=1 skip/quar=0`. **Exact match.** Verdict `FAILING` is *correct* (recent-5 = 06:45 TIMEOUT + 07:33 wave; ok=2 fail=3) — the engine really did fail those runs; the counter just no longer double-counts bookkeeping.

## Out-of-scope observations (not touched)

- The 07:33:42Z wave (3× `TIMEOUT(900s)`, "(no output captured)") coincides with the `SUBSTRATE_VIOLATION` guard firing — looks like wave-reaping, **not** trust (no allowlist warning on those lines). A previous attempt of this same Janitor job died in that wave. Worth a Steward look if it recurs.
- Home-level `settings.local.json` is 25 entries of stale off-machine rules — candidate for a future clean if permissions are ever re-enabled.

**One-line record:** [Janitor] Verified trust=true on both project keys (no change needed; workers also run --dangerously-skip-permissions → 900s trust-hang structurally dead) and fixed health.sh's last non-session counting bug (substrate-guard line; unified NONSESSION filter) — output now matches an independent LOG grep exactly (28 runs, 6 ok, 22 fail); evidence in `journal/sessions/janitor-trust-health-2026-07-21.md`.
