---
tags: [harness, janitor, fix, worker-sh, builder-lane, substrate]
date: 2026-08-02
status: shipped
related:
  - "[[FAILURE-MODES]]"
  - "[[The Forge Harness — Runbook]]"
---

# Janitor: Slot-Aware Builder Prompt — End the Builder-Lane Dead Letter

**Job:** `[Janitor] [builder] SLOT-AWARE WORKER PROMPT (end the builder-lane dead letter)`  
**Shipped:** 2026-08-02  
**Touched:** `_harness/worker.sh` (prompt text only — no dispatch/routing/revert logic)

---

## The Bug

The 08-01 INDEX one-liner sync ran on the **builder lane** (LOG `2026-08-01T06:32:33Z` carries the `[builder]` prefix, `slot=builder`, budget 2400) yet its artifact ([[index-failure-modes-oneliner-sync-2026-08-01]]) reports *"This session ran on the worker lane"* and **refused the substrate edit** — because `worker.sh:43-67` sends the SAME prompt to every slot:

> "You are … an autonomous CRON WORKER … SHARED SUBSTRATE IS READ-ONLY for workers"

The session had no harness-level signal of its real lane. The runner marked `[x]` (the artifact existed), the paste-ready line was never applied, and it took a second APPLY job to land it ([[index-failure-modes-oneliner-applied-2026-08-02]], which verified the lane from the process ancestry + `worker-builder.job` sidecar). **Every future `[builder]` substrate job (INDEX/MEMORY syncs) carries the same refusal risk.**

---

## The Fix

**Branch the prompt on `$slot`** (`worker.sh` already branches on it at line 79 for the per-attempt timeout). The builder slot gets a distinct stanza; worker slots keep the current text **byte-exact**.

### Builder-slot prompt (new)

```
You are the Forge running the BUILDER lane — the SERIAL cron session — inside the Obsidian vault at $VAULT.
You are NOT one of the parallel workers: you run alone on the serial lane, AFTER the parallel workers and their substrate revert have finished.

RULES:
- You are the BUILDER — the serial lane; substrate writes to INDEX.md/MEMORY.md ARE permitted for you, the snapshot/revert runs BEFORE your section; LOG.md and queue.md remain read-only.
[... rest of rules unchanged ...]
```

### Worker-slot prompt (unchanged, byte-exact)

```
You are the Forge running an autonomous CRON WORKER inside the Obsidian vault at $VAULT.
You are one of several workers running IN PARALLEL this tick, each on a different job.

RULES:
- SHARED SUBSTRATE IS READ-ONLY for workers: do NOT edit LOG.md, INDEX.md, MEMORY.md, or _harness/queue.md. The runner logs your result and a Curator catalogs new notes later. You may READ all of them.
[... rest of rules unchanged ...]
```

**Why this is safe:** `runner.sh` snapshots `INDEX.md` + `MEMORY.md` at line 618-620, workers run at 643-649, the **substrate revert fires at 651-657** (catching worker edits), and the **builder section runs at 685-708** — AFTER the revert. A builder-lane write to INDEX/MEMORY is never reverted. The builder stanza correctly states: *"the snapshot/revert runs BEFORE your section."*

---

## Verification (Zero-Token Sandbox)

**Pre-change checklist ([[FAILURE-MODES]]):** items 1 + 9 apply; item 12 N/A (no new LOG verdict token).

### 1. Syntax (item 1)

```bash
bash -n worker.sh
```
✓ Clean.

### 2. Sandbox harness (zero tokens)

Built a `mktemp -d` sandbox with:
- A stub `claude` binary that dumps its `-p` argument byte-exact to `$PROMPT_DUMP`
- Sandbox `config.env` (stub binary, tiny budgets, faithful vars)
- Pre-fix `worker.sh` copy (captured BEFORE editing)
- Post-fix `worker.sh` copy (after editing)

Ran the stub against both versions for `slot=0` (worker) and `slot=builder`, capturing the exact prompt bytes passed to `claude`.

### 3. Test (ii): worker-slot prompt byte-identical to pre-fix

```bash
cmp prefix-worker.prompt post-worker.prompt
```
✓ **PASS** — byte-identical (sha256 match: `67a85d50f53def43fac99e278dc402d60d519495110c1c860002f250d7f8a7f5`).

### 4. Test (i): builder-slot prompt contains the builder stanza

```bash
grep 'You are the BUILDER — the serial lane' post-builder.prompt
grep 'substrate writes to INDEX.md/MEMORY.md ARE permitted' post-builder.prompt
grep 'the snapshot/revert runs BEFORE your section' post-builder.prompt
```
✓ **PASS** — all three required phrases present.

### 5. Worker prompt retains read-only rule

```bash
grep 'SHARED SUBSTRATE IS READ-ONLY for workers' post-worker.prompt
```
✓ **PASS** — worker prompt still carries the read-only substrate rule.

### 6. Builder prompt does NOT carry worker read-only rule

```bash
! grep 'SHARED SUBSTRATE IS READ-ONLY for workers' post-builder.prompt
```
✓ **PASS** — builder prompt correctly omits the worker read-only rule.

### 7. Test (iii): substrate revert logic untouched

The substrate revert is in `runner.sh:651-657`, NOT in `worker.sh`. This change touched **ONLY** `worker.sh` prompt text — `runner.sh` is unmodified. **Production evidence:** LOG lines 52/77 (two historical `SUBSTRATE_VIOLATION` reverts) remain the standing proof that the revert still fires for worker edits.

```bash
grep 'SUBSTRATE_VIOLATION' runner.sh
grep 'for f in INDEX.md MEMORY.md' runner.sh
```
✓ **PASS** — `runner.sh` substrate revert logic present and unchanged.

---

## Checklist Attestation

- **Item 1 (bash -n):** ✓ clean.
- **Item 9 (substrate integrity):** ✓ workers stay read-only on LOG/INDEX/MEMORY/queue (worker prompt byte-identical, retains the read-only rule); the snapshot detect-and-revert still fires (touched only `worker.sh` prompt text; `runner.sh:651-657` unmodified; the two historical `SUBSTRATE_VIOLATION` reverts at LOG lines 52/77 remain the production evidence). The builder stanza correctly states substrate writes go through the builder lane and the revert runs before the builder section — which matches `runner.sh` ordering (618→651→685).
- **Item 12 (new verdict token):** N/A — no new LOG verdict token; this is prompt text only.

---

## Done-Evidence Summary

✓ `bash -n` clean  
✓ Sandbox test (i): builder-slot session's generated prompt contains the builder stanza  
✓ Sandbox test (ii): worker-slot prompt byte-identical to pre-fix (sha256 match)  
✓ Sandbox test (iii): the substrate revert still fires for worker edits (the two historical `SUBSTRATE_VIOLATION` reverts, LOG lines 52/77, remain the production evidence)  
✓ PRE-CHANGE CHECKLIST items 1 + 9 satisfied; item 12 N/A  
✓ $0 token burn (zero-token sandbox harness)

---

## What's Next

Every future `[builder]` substrate job (INDEX/MEMORY syncs) now receives the builder-lane prompt and will **not** refuse legitimate substrate writes. The builder-lane dead letter is ended.

**PRODUCED:** `inbox/janitor-slot-aware-builder-prompt-2026-08-02.md`
