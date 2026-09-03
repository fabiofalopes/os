---
id: EXP-0002
type: experiment
hypothesis: "The proxy-detection telemetry DEMONSTRATED in 2.1.91 JS survives into the native-binary era (2.1.196 and 2.1.246 linux-x64)."
target_version: "2.1.196, 2.1.246"
method: static
status: done
date: 2026-08-26
verdict: mixed
claims: [CLM-0003, CLM-0011, CLM-0012]
summary: SPLIT VERDICT — 2.1.196 native binary retains the full 2.1.91 mechanism byte-equivalently (147-host XOR-91 blocklist + apostrophe steganography); 2.1.246 has REMOVED it (plain YYYY-MM-DD date fn, zero detection markers). No pod needed; $0 spent.
---
## Hypothesis
EXP-0001 left open whether the obfuscated proxy/lab detection survived the
move to Bun-compiled native binaries (2.1.196, 2.1.246).

## Method
1. `npm pack @anthropic-ai/claude-code-linux-x64@{2.1.196,2.1.246}` →
   tarballs sha256-pinned (see artifacts). Both are Bun standalone ELF
   executables ("---- Bun! ----" container), not stripped, app JS recoverable
   as plaintext strings.
2. Static only (CPU, host): grep/regex over binary + extracted payload region
   for 2.1.91 telltales — blob prefix `ODV3KDo1MC46`, decoded markers
   (Asia/Shanghai, Asia/Urumqi, blocklist hosts, lab keywords), apostrophe
   variants near "date is", XOR-91 decoder pattern, plus a XOR-85–95 sweep
   over all ≥300-char base64 blobs looking for a comma host-list signature.
3. For 2.1.246 the whole `currentDate` → date-function chain was traced to
   its definition to close the loop (not just absence-of-string).

## Expected vs Observed
- **2.1.196 — PRESENT, byte-equivalent.** Same `Uup`/`Fup` base64 blobs
  (decoded with the binary's own `$la` algorithm: base64→XOR 91→split ","):
  **147 blocklist hosts** (cn, sankuai.com, …, yunwu.ai, zenmux.ai) and the
  same **11 CN-lab keywords** (deepseek, moonshot, minimax, xaminim, zhipu,
  bigmodel, baichuan, stepfun, 01ai, dashscope, volces). Same `qup()`
  detector ({known, labKw, cnTZ, host} off `ANTHROPIC_BASE_URL` hostname +
  Asia/Shanghai/Urumqi TZ), same `Vup()` apostrophe encoder (' ’ ʼ ʹ),
  same `Ola()` embed incl. cnTZ `-`→`/` rewrite. Mechanism simply moved
  inside the native binary.
- **2.1.246 — ABSENT.**
  - `currentDate:`Today's date is ${V5()}.`` — plain ASCII apostrophe,
    outside the interpolation (structurally incompatible with the
    steganography, which needed to own the apostrophe byte).
  - Chain closed: `function Jrt(){…return`${t}-${n}-${r}`}` (plain
    YYYY-MM-DD, no host/TZ input exists anywhere in the chain);
    `V5=$h(Jrt)` is a wrapper around Jrt only.
  - Zero hits in plaintext app JS for: Asia/Shanghai or Asia/Urumqi as
    standalone strings (only inside full IANA TZ name tables), every
    blocklist host (apiyi, yunwu, duckcoding, openclaude, baidu.com,
    alibaba-inc, bytedance.net, bilibili.co, jd.com), XOR-91 pattern, and
    the XOR-85–95 host-list sweep. Remaining moonshot/deepseek/minimax/
    stepfun hits are a MODEL-NAME regex, unrelated.
- **Dynamic confirmation (pod)**: NOT used — static closed both verdicts.
  (Also: PI wallet at $0.85 < $1 pod minimum, so the fallback was unfundable
  this session; moot.)

## Verdict
- Supports CLM-0011 extended to **2.1.196** (native binary, mechanism
  identical) — CLM-0011 versions now [2.1.91, 2.1.196].
- **Refutes** the telemetry's survival in **2.1.246** → new claim CLM-0012
  (removal), grade 4 for the date-line channel (chain closed in plaintext),
  grade 3 for "no proxy-detection anywhere in 2.1.246" (see caveat).
- Consistent with CLM-0003's "rolled back Jun 2026 after exposure" — 246 is
  the first post-rollback version we've audited.

### Caveats
- The 2.1.246 container contains 3865 zstd-magic byte sequences that resist
  naive decompression (likely coincidental/mid-stream). A compressed-module
  remainder cannot be 100% textually excluded; however the entire
  currentDate→V5→Jrt chain resolved in plaintext and contains no encoder, so
  the *demonstrated channel* is gone. Full closure would need decoding the
  compressed remainder or a dynamic run.
- `$h` in `V5=$h(Jrt)` was not definitively identified (name collides across
  bundle chunks); whatever it is, Jrt takes no host/TZ input, so it cannot
  inject detection bits into the date string.
- Environment note: a shell hook on this host prints "claude native binary
  not installed" on some Bash calls — a local npm-wrapper artifact, NOT an
  execution of any target binary (guardrail held: no Anthropic binary run).

## Raw logs
`~/breaking-claude/experiments/exp-0002/` — tarballs, extracted ELFs,
`exp-0002-artifacts.json` (sha256s, decoded lists, code excerpts, absence
counts, offsets). Analysis on checksummed copies.

## Fuel (DEC-0002)
Single-session zai/glm-5.2 reasoning throughout; no subagents spawned.
Models used: glm-5.2 (operator). Cost: $0 compute (host CPU only).

## EXP-0003 should be
Decode the zstd-compressed remainder of the 2.1.246 container (reference:
build a known Bun `--compile` binary and diff container structure; try
dictionary-aware decompression) to close the grade-3→4 gap on "no residual
detection anywhere". Secondary: trace `dump-prompts` fetch-interceptor
(present in 246, 3 hits) — what gets written where; and check whether
2.1.196 gates any feature on the detection bits locally (callers of `qup`).
