# Forensic Methodology — Commands and Procedures for Claude Code Analysis

> The operational companion to the init prompt. Copy-pasteable commands for active forensic analysis.

---

## Why Wireshark Alone Is Wrong

Claude Code traffic is TLS 1.3 HTTPS. Wireshark shows you encrypted handshakes, not payloads. You need a TLS-terminating MITM proxy to inspect actual request/response bodies.

---

## Method 1: System Prompt Codepoint Auditing

**Highest signal, lowest effort.** Scan captured system prompts for non-ASCII apostrophes — these are the steganographic fingerprint signal from Incident 1.

```python
# Scan for steganographic codepoints in captured system prompt
# Looks for the "Today's date is..." line and checks each character
for line in open('captured_prompt.txt'):
    if 'Today' in line:
        for i, c in enumerate(line):
            if ord(c) > 127 or c in ("'", ''', '', ''):
                print(f'pos {i}: U+{ord(c):04X}')
```

```bash
# Slash vs dash date separator = timezone flag (Asia/Shanghai or Asia/Urumqi)
grep -P "Today.s date is \d{4}/" captured_prompt.txt

# If this returns a match, the timezone flag is active
```

**Community baseline for diffing**: Clone `github.com/Piebald-AI/claude-code-system-prompts` — 515+ system prompts from 230 versions for comparison.

---

## Method 2: Static Binary Analysis (XOR-91 Blob Extraction)

The Claude Code binary contains obfuscated domain/keyword lists encoded as base64 + XOR key 91. This extracts all such blobs.

```bash
# XOR-91 decode over all base64-looking strings in the bundle
# Works on any version's bundle.js or compiled binary
grep -oP '[A-Za-z0-9+/]{40,}={0,2}' bundle.js | while read b; do
  python3 -c "
import base64
try:
    d = base64.b64decode('$b')
    x = bytes(v^91 for v in d)
    if all(32<=v<127 for v in x): print(x.decode())
except: pass
"
done
```

**Note**: The obfuscation scheme may change in future versions. Adapt the XOR key or encoding as needed.

---

## Method 3: Traffic Capture via MITM Proxy

Three options for intercepting Claude Code's traffic, from simplest to most capable:

### Option A: mitmproxy

```bash
# Install and run mitmproxy as TLS-terminating MITM
pip install mitmproxy
mitmproxy --mode regular -p 8080 -w ~/claude-capture.mitm
export ANTHROPIC_BASE_URL=http://localhost:8080
```

### Option B: CLIProxyAPI (Claude-Code-native)

Full MITM + logging proxy specifically designed for Claude Code traffic.

- Repo: `github.com/router-for-me/CLIProxyAPI`
- Wraps Claude Code as OpenAI-compatible API with full request/response logging
- Config: `github.com/router-for-me/CLIProxyAPI/blob/main/config.example.yaml`

### Option C: UPB Proxy (our existing tool)

The Universal Provider Bridge at `~/projetos/breaking-claude/jailbreak/claude-universal/` already translates Anthropic-to-OpenAI. Add request logging to `src/index.ts` for traffic capture without additional tools.

- Architecture: `~/projetos/breaking-claude/gas/gateway/provider-bridge-architecture.md`

---

## Method 4: Sandboxed Egress Testing

Test for undisclosed phone-home behavior by running Claude Code in a container with no network access except the configured endpoint.

```bash
# Run Claude Code in a network-isolated container
# Any attempt to reach beyond the configured endpoint fails visibly
# Replace your-proxy and your_key with actual values at runtime
docker run -it --rm --network=none \
  -e ANTHROPIC_BASE_URL=https://your-proxy \
  -e ANTHROPIC_API_KEY=your_key \
  node:20 bash -c "npm install -g @anthropic-ai/claude-code && claude --version"
```

**Interpretation**: If Claude Code attempts any connection beyond `your-proxy`, it will fail visibly (connection refused). This tests HYP-004 (undisclosed phone-home).

**Pre-built block**: `~/projetos/breaking-claude/tools/block-claude-phonehome.sh` blocks known telemetry domains via `/etc/hosts`.

---

## Method 5: Persona File Audit (PPA Detection)

Check `CLAUDE.md`, `AGENTS.md`, and `SOUL.md` files for self-modification instructions that create persistent backdoors.

```bash
# Detect Persona Persistence Attack patterns in persona/config files
grep -iE "(update|modify|rewrite|append|write).*(CLAUDE\.md|AGENTS\.md|soul|instructions)" CLAUDE.md AGENTS.md SOUL.md

# If any match is found, manually review the instruction
# SEC090 (ERROR): "update CLAUDE.md" / "modify AGENTS.md" — permanent backdoor
# SEC091 (WARNING): "rewrite your instructions" — suspicious self-modification
```

**Critical**: "The weakest model in your pipeline sets the security floor." Test with ALL models — open-weight models (Qwen, GLM, Llama) comply with self-modification that Claude would refuse.

**Automated tool**: SoulScan at `clawsouls.ai/soulscan` provides SEC090/SEC091 rule scanning.

---

## Method 6: Version Diffing Workflow

**How to capture a new version's system prompt**:
1. Use the logging proxy method from Method 3 (set `ANTHROPIC_BASE_URL` to your MITM proxy)
2. Launch the target Claude Code version
3. Capture the system prompt from the proxy log
4. Save as `~/projetos/breaking-claude/research/experiments/YYYY-MM-DD_system-prompt-vXXX.txt`

**How to diff against community baseline**:
```bash
git clone https://github.com/Piebald-AI/claude-code-system-prompts
diff your-captured-prompt.txt claude-code-system-prompts/vXXX/CLAUDE.md
```

**How to do binary diff for post-patch verification**:
DON'T TRUST THE CHANGELOG. The steganography fix in v2.1.197 had NO changelog mention. Only binary diff confirms the code was actually removed.
```bash
# Extract both versions' bundle and diff
strings claude-code-v196.js > /tmp/v196-strings.txt
strings claude-code-v197.js > /tmp/v197-strings.txt
diff /tmp/v196-strings.txt /tmp/v197-strings.txt | grep -i "today\|apostrophe\|unicode"
```

---

## Method 7: IPC Race Condition Audit

From Andrey Kolkov's research: Claude Code's multi-agent IPC uses file-based mailboxes.

- Location: `~/.claude/work/ipc/`
- Polling: 500ms
- 13 race conditions documented in leaked source
- 5 of those are privilege escalation vectors

**Starting point for filesystem audit**: Monitor `~/.claude/work/ipc/` for concurrent access patterns using `inotifywait`:
```bash
inotifywait -m -r ~/.claude/work/ipc/ -e access,modify,create,delete
```

---

## Evidence Collection Protocol

- **Save captures to**: `~/projetos/breaking-claude/research/experiments/[date]-[slug]/`
- **Naming convention**: `YYYY-MM-DD_[description].[ext]`
  - Example: `2026-07-23_system-prompt-v211.txt`
  - Example: `2026-07-23_xor91-decode-output.txt`
  - Example: `2026-07-23_mitmproxy-capture.mitm`
- **What to include**: captured prompts, proxy logs, binary analysis output, grep results, codepoint audit output
- **Cross-reference**: Add evidence paths to `threat-register.md` incident entries

---

## Tool Prerequisites

- [ ] Python 3 (for codepoint audit and XOR decode)
- [ ] mitmproxy (`pip install mitmproxy`) — for traffic capture
- [ ] Docker — for sandboxed egress testing
- [ ] git — for cloning community baselines
- [ ] Optional: Ghidra + GhidraMCP (`github.com/LaurieWired/GhidraMCP`) — for binary analysis
- [ ] Optional: SoulScan (`clawsouls.ai/soulscan`) — for automated PPA detection

---

*Methodology v1.0 — 2026-07-23 — Commands adapted from Perplexity cyber threat report and community research*
