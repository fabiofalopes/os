---
id: EXP-0001
type: experiment
hypothesis: "Claude Code 2.1.91 embeds obfuscated proxy/lab detection that alters the date string in the system prompt via apostrophe-variant Unicode characters."
target_version: "2.1.91"
method: static
status: done
date: 2026-08-26
verdict: supports
claims: [CLM-0003, CLM-0011]
summary: DEMONSTRATED — 147-host blocklist + 11 Chinese-lab keyword list, XOR-91+base64 obfuscated, encoded into the "Today's date" system line via 4 apostrophe variants; cnTZ rewrites date format too.
---
## Hypothesis
External claims (CLM-0003, grade 2) said v2.1.91+ hid proxy-detection telemetry.
Verify in the actual artifact.

## Method
1. `npm pack @anthropic-ai/claude-code@{2.1.91,2.1.196,2.1.246}` → archive
   (sha256 in MANIFEST). 2.1.88 absent from registry (pulled post-leak).
2. Static scan of the 13 MB minified `cli.js` for the claimed mechanisms:
   DateTimeFormat sites, invisible Unicode, fingerprint strings, BASE_URL
   handling.
3. Decoded the two obfuscated literals found adjacent to the detection logic,
   using the file's own deobfuscation routine (`DM4`: base64 → XOR 91 →
   split ","). Zero transcription: regex-extracted the exact literals from
   the artifact and decoded with the artifact's own algorithm.

## Expected vs Observed
- Expected (from claims): proxy fingerprinting, China-linked user flagging,
  invisible-Unicode channel in system prompt.
- Observed: ALL CONFIRMED, with precise mechanics:
  - `Zi_()` (detection): returns `{known, labKw, cnTZ, host}` — host known if
    it matches a **147-entry blocklist** of proxy/reseller domains
    (moonshot.ai, apiyi.com, yunwu.ai, duckcoding.com, openclaude.me …) AND
    Chinese corporate internal domains (baidu.com, alibaba-inc.com,
    bytedance.net, bilibili.co, jd.com …); `labKw` if host contains one of
    **11 Chinese-lab keywords** (deepseek, moonshot, minimax, zhipu,
    bigmodel, baichuan, stepfun, 01ai, dashscope, volces, xaminim);
    `cnTZ` = timezone is Asia/Shanghai or Asia/Urumqi.
  - `Gi_()` (encoding): 2 bits → 4 apostrophe variants in the system-prompt
    date line: `'` (none), `’` (known), `ʼ` (labKw), `ʹ` (both).
    `fM4()` embeds it: "Today's date is …" — the apostrophe itself is the
    covert channel, exactly the claimed "invisible Unicode alterations to
    the system prompt". Rendered identically to the eye; survives to
    Anthropic's servers inside the prompt text.
  - `cnTZ` additionally rewrites date separators `-` → `/` (second channel).
  - Obfuscation: base64 + XOR key 91 + comma-split, literals ~6KB and 200B.
  - Also present (benign, for the record): GrowthBook/Statsig feature gates
    (`tengu_*`), event_logging batch endpoint, undici HTTP_PROXY handling
    (standard), fetch-interceptor writing prompt dumps to local
    `dump-prompts/*.jsonl` (dev/telemetry-adjacent — flagged for follow-up).

## Verdict
SUPPORTS CLM-0003, mechanism now DEMONSTRATED (grade 4 for existence +
mechanism in 2.1.91). Note: the June-2026 rollback claim (removal) is NOT
yet tested — 2.1.196/2.1.246 are native-binary wrappers; the JS moved into
platform optionalDeps binaries. Follow-up: EXP-0002.

## Raw logs
`~/breaking-claude/experiments/exp-0001-artifacts.json` (decoded lists +
code excerpt + flow chain + sha256). Analysis performed on the checksummed
tarball copy.

## Addendum — full flow chain (same session, verified)
`iA()` → `currentDate: fM4(today)` → `Bg8(messages, userContext)` embeds the
encoded date line inside a `<system-reminder>` block in the **first user
message**. Critical precision: the channel therefore rides the conversation
payload to **whatever endpoint `ANTHROPIC_BASE_URL` points at** — a
third-party proxy receives (and could parse) the same encoded apostrophe —
and any network observer of the session sees it. It is not a separate
telemetry POST; it is steganography in the prompt itself.
