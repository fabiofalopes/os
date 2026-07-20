# Agent Loop Skill — Iterate-Until Pattern

> Behavior pattern: **iterative task execution with success detection, safety bounds, and adaptive retry**
> Project: `rpi-net` + general agent operations
> Status: **design proposal — not yet a production SKILL.md**
> Last reviewed: 2026-06-26

---

## TL;DR

An agent with a task often tries once and gives up. A loop skill fixes that: the agent keeps executing until a success condition is met, within a bounded number of attempts, with an adjustment strategy between iterations. This is the "agentic loop" pattern — known as ReAct, Boris loop, YOLO loop, or iterate-until depending on the lineage. Same core idea, different names. This document proposes a six-field formalization of the pattern, with examples from the rpi-net project and general pentesting operations.

---

## Concept

The default agent behavior is single-shot: observe, think, act, done. If the action fails, the agent rarely retries with a different approach. The loop skill builds persistence into the agent's model by formalizing:

1. **What success looks like** — a boolean check that tells the agent to stop
2. **When to stop trying** — a hard iteration limit that prevents infinite loops
3. **What to do each round** — the action sequence for one iteration
4. **How to adapt** — what changes between iterations when the condition isn't met

This is not a new idea. The ReAct pattern (Yao et al., 2022) interleaves reasoning and acting in a loop. The "Boris loop" (named after the agent that kept trying until it worked) demonstrated persistence beating sophistication on practical tasks. The "YOLO loop" (You Only Live Once... but try again) is a tongue-in-cheek name for the same pattern. This document distills the common structure into a reusable skill definition.

**Why it matters for rpi-net:**
- The agent already loops internally (think-act-respond), but it often gives up after one failed attempt
- A formalized loop pattern gives the agent persistence and a clear success criteria
- The safety bound (MAX_ITERATIONS) prevents infinite loops and resource waste
- The adjustment strategy prevents the agent from repeating the same failed action
- This pattern is applicable to MANY tasks across the rpi-net project and beyond

---

## The Pattern

Six fields define any loop task:

| Field | Description | Default |
|-------|-------------|---------|
| **GOAL** | What we're trying to achieve | (required) |
| **CONDITION** | Boolean check — how to know we've succeeded | (required) |
| **MAX_ITERATIONS** | Safety bound — give up after N tries | 10 |
| **ACTIONS** | What to do each iteration | (required) |
| **EVALUATION** | How to check the condition after each iteration | (required) |
| **ADJUSTMENT** | What changes between attempts if not yet met | (required) |

### Field definitions

**GOAL:** A plain-language description of the desired outcome. Used for logging, diagnostics, and reporting. Should be specific enough that a human reading the failure report understands what was attempted.

**CONDITION:** A boolean check that returns true when the goal is met. This should be an executable check — a command, a grep, an API call, a file existence test. The condition must be evaluable without side effects (or with controlled side effects that don't interfere with the loop).

**MAX_ITERATIONS:** Hard upper bound on attempts. Prevents runaway loops. The default of 10 is generous; most tasks should succeed in 2–3 iterations. If a task needs more than 10, reconsider whether the actions or adjustment strategy are effective.

**ACTIONS:** The sequence of operations to perform in one iteration. This is the body of the loop — what the agent actually does each time it tries. Actions should be idempotent where possible, or at least safe to repeat.

**EVALUATION:** How to check the condition after the actions complete. Often this is simply "run the condition check," but it can include additional diagnostics, logging, or evidence collection.

**ADJUSTMENT:** The delta applied between iterations. This is what makes the loop effective — without adjustment, every iteration is identical, and the agent will repeatedly fail the same way. The adjustment strategy should be informed by **why** the condition failed (e.g., which check in a multi-part condition failed, or what error was produced).

---

## Execution Flow

```
1. DEFINE GOAL and CONDITION
2. SET iteration = 0, MAX = MAX_ITERATIONS
3. LOOP:
   a. INCREMENT iteration
   b. EXECUTE ACTIONS
   c. EVALUATE against CONDITION
   d. IF condition met:
        → STOP, report SUCCESS with evidence
   e. IF condition not met AND iteration < MAX:
        → APPLY ADJUSTMENT
        → CONTINUE loop (step 3a)
   f. IF condition not met AND iteration >= MAX:
        → STOP, report FAILURE with diagnostics
        → Include: what was tried, which iteration, what the last error was
```

### Pseudocode

```
function iterateUntil(goal, condition, maxIterations, actions, evaluate, adjust):
    iteration = 0
    while iteration < maxIterations:
        iteration += 1
        log("Iteration #{iteration}: {goal}")
        
        result = actions()
        success = evaluate(result, condition)
        
        if success:
            log("SUCCESS after {iteration} iterations: {goal}")
            return SUCCESS(result)
        
        if iteration < maxIterations:
            adjustment = adjust(result, iteration)
            log("Adjustment: {adjustment}")
        else:
            log("FAILURE after {maxIterations} iterations: {goal}")
            log("Diagnostics: {result.errors}")
            return FAILURE(result)
```

### Key behaviors

- **Log every iteration** — the diagnostic output is how a human understands what happened
- **Adjust based on failure mode** — don't blindly retry the same thing; use the error signal to choose what to change
- **Report evidence of success** — the condition check result (e.g., "12/12 PASS" or the matching grep output) is the proof
- **Report diagnostics on failure** — the last error, the iteration count, and the final state help decide next steps

---

## Examples — rpi-net

### Rig health loop

| Field | Value |
|-------|-------|
| GOAL | Rig is fully operational |
| CONDITION | `validate-boot.sh` returns 12/12 PASS |
| MAX_ITERATIONS | 20 |
| ACTIONS | Check status → diagnose issue → apply fix → re-validate |
| EVALUATION | Run `validate-boot.sh` and count PASS lines |
| ADJUSTMENT | Based on which check failed — network → restart NM, USB → replug, watchdog → restart service |

**Why 20 iterations:** The rig can take multiple rounds to fully recover. Network checks may pass/fail transiently. 20 gives the agent room to work through layered failures.

### Capture loop

| Field | Value |
|-------|-------|
| GOAL | Valid Bolt flows captured |
| CONDITION | `mitm.flows` file contains requests to `user.live.boltsvc.net` |
| MAX_ITERATIONS | 5 |
| ACTIONS | Verify interception active → open target app → wait 60s → check flows file |
| EVALUATION | `grep -c user.live.boltsvc.net /var/log/rpi-net/mitm.flows` > 0 |
| ADJUSTMENT | If no flows — check iptables redirect, check mitmweb status, check phone WiFi, restart mitmproxy |

**Why 5 iterations:** Each iteration is a 60-second wait. 5 iterations = 5 minutes max. If the app hasn't sent traffic in 5 minutes, something fundamental is wrong.

### APK analysis loop

| Field | Value |
|-------|-------|
| GOAL | Find the specific endpoint or function in smali |
| CONDITION | `grep` returns a match in the target file |
| MAX_ITERATIONS | 10 |
| ACTIONS | Grep with one pattern → if no match, try another pattern |
| EVALUATION | `grep -r "$PATTERN" smali*/` exits 0 |
| ADJUSTMENT | Broader pattern → different directory → related terms → semantic variants |

**Why 10 iterations:** APK analysis is exploratory. Each iteration tries a different search strategy. 10 patterns cover most endpoint variants (e.g., `createAndStart`, `create_and_start`, `CreateAndStart`, `startRide`, `start_order`, etc.).

### Build/validate loop

| Field | Value |
|-------|-------|
| GOAL | Configuration change validated |
| CONDITION | Deploy + reboot + `validate-boot.sh` passes |
| MAX_ITERATIONS | 3 |
| ACTIONS | Edit config → deploy → test |
| EVALUATION | `validate-boot.sh` returns 12/12 PASS |
| ADJUSTMENT | Revert last change → try smaller change → try different config path |

**Why 3 iterations:** Each iteration involves a reboot (~60s). 3 iterations = 3 minutes max, and three attempts should be enough to get a config change right. If it fails 3 times, the approach is wrong.

---

## Examples — Pentesting (General)

### Fuzzing loop

| Field | Value |
|-------|-------|
| GOAL | Crash the target process |
| CONDITION | Target becomes unreachable or returns 500 on previously working endpoint |
| MAX_ITERATIONS | 1000+ (fuzzing is high-iteration by nature) |
| ACTIONS | Send next payload from the fuzz corpus |
| EVALUATION | Check if target is still responsive |
| ADJUSTMENT | Switch payload category based on observed response codes |

### Brute-force loop

| Field | Value |
|-------|-------|
| GOAL | Authenticate as a valid user |
| CONDITION | Login endpoint returns HTTP 200 with session cookie |
| MAX_ITERATIONS | Set by credential list size |
| ACTIONS | Try next credential pair |
| EVALUATION | Parse HTTP response for success indicator |
| ADJUSTMENT | Rotate proxy IP after N failures (rate limiting) |

### Port scan loop

| Field | Value |
|-------|-------|
| GOAL | Find a specific open port |
| CONDITION | `nmap` or `nc` returns open on the target port |
| MAX_ITERATIONS | 3 (per port) with increasing scan depth |
| ACTIONS | Scan port with current technique |
| EVALUATION | Check scan output for `open` state |
| ADJUSTMENT | SYN scan → connect scan → full TCP handshake → OS-level check |

### Exploitation loop

| Field | Value |
|-------|-------|
| GOAL | Obtain a reverse shell |
| CONDITION | Listener receives callback (incoming connection on handler port) |
| MAX_ITERATIONS | 5 (per payload variant) |
| ACTIONS | Deploy payload with current configuration, trigger, wait for callback |
| EVALUATION | Listen on handler port for incoming connection |
| ADJUSTMENT | Change payload type, change LHOST/LPORT, change encoding, change delivery method |

---

## Usage

### Invocation in agent prompts

The pattern can be invoked directly in agent prompts using a compact field notation:

```
Use the iterate-until loop:
  GOAL=rig healthy
  CONDITION=validate-boot.sh 12/12 PASS
  MAX=20
  ACTIONS=[check, diagnose, fix, re-validate]
```

Or referenced by name if the skill is registered:

```
Apply the iterate-until loop skill to this task.
```

### Integration with existing agent workflow

The loop skill wraps the agent's existing think-act-respond cycle. Instead of:

```
Agent: thinks about the problem → acts once → returns result
```

The loop version does:

```
Agent: thinks → acts → evaluates → if not done, adjusts → loops
```

The agent's reasoning capabilities are used **within** each iteration (to decide what to do) and **between** iterations (to decide what to change). The loop skill provides the scaffolding; the agent provides the intelligence.

### When to use the loop skill

| Use it when... | Don't use it when... |
|----------------|---------------------|
| The task has a clear success signal | Success is subjective or unmeasurable |
| You can bound the effort (MAX_ITERATIONS) | The task could never succeed |
| There's a meaningful adjustment strategy | Every retry is identical (pointless looping) |
| Failure is recoverable | Failure corrupts state irreversibly |
| Each iteration is cheap | Each iteration costs significant time/money |

---

## Status — Design Proposal

| Component | Status |
|-----------|--------|
| Pattern definition | ✅ Drafted (six-field model) |
| Execution flow | ✅ Specified |
| Examples (rpi-net) | ✅ Drafted (4 examples) |
| Examples (general) | ✅ Drafted (4 examples) |
| Usage guide | ✅ Drafted |
| Formal SKILL.md | ❌ Not yet created |
| Tested against real tasks | ❌ Not yet tested |
| Skill vault registration | ❌ Not yet registered |

This is a **design proposal**. The next step is to formalize this as a SKILL.md in the skill vault and test it against rpi-net tasks.

---

## Next Steps

1. **Formalize as SKILL.md** — create a canonical skill definition in the skill vault (`/home/ken/shared-local/skills/` or equivalent) with metadata, invocation syntax, and the full pattern definition
2. **Test against rpi-net tasks** — run the loop pattern against real tasks (rig health validation, APK analysis, capture loop) and observe whether the agent uses it effectively
3. **Refine adjustment strategies** — the current ADJUSTMENT field descriptions are high-level; real adjustments need concrete commands (e.g., "run `systemctl restart networking`" not "restart networking")
4. **Add error taxonomy** — different failure modes should map to different adjustments; a taxonomy of common failures would make the pattern more robust
5. **Evaluate MAX_ITERATIONS defaults** — 10 is a guess; real usage will show whether tasks converge faster or need more iterations
6. **Consider a meta-pattern** — what if the loop itself fails? Should there be a loop-of-loops (escalation pattern)? Design decision: probably not — let the human decide between iterations or after MAX failure

---

## Source of Truth — Related Documents

| Document | Location | What it is |
|----------|----------|------------|
| **RPi-Net Session Log** | `obsidian-vault/RPi-Net Session Log.md` | Session log — loop skill proposed here |
| RPi Reliability | `obsidian-vault/RPi Reliability — Zombie State Prevention.md` | Reliability patterns (complementary — hardware watchdog is a loop of last resort) |
| Bolt Security Research | `obsidian-vault/Bolt Security Research — MITM Attack Capability.md` | Project context — where some of these loops will be used |
| Skill vault (pending) | `shared-local/skills/` | Future home of the formalized SKILL.md |
