# Browser Harness — Live, Isolated, Tor Lanes

Built 2026-09-03. Any local agent drives local Chromium three ways, picked by identity risk. Local-first: no Browserbase/Steel-style cloud relay, no remote control plane.

## The three lanes

- **Isolated direct** (`browser` MCP) — headless Chromium, throwaway profile, direct IP. Screenshots, throwaway checks, testing own pages.
- **Live logged-in** (`browser-live` MCP) — attached via CDP to the real profile at `http://localhost:9222`. Acts as me. Confirm before irreversible acts; never log out, never clear profile data.
- **Tor anonymous** (`browser-tor` MCP) — isolated headless Chromium forced through Tor SOCKS `127.0.0.1:9050`. Default for all public scraping.

## Verified evidence (not assumed)

- System Chromium `150.0.7871.181` (Debian fork), `DISPLAY :0.0 x11`.
- Apt `playwright` is broken (`Cannot find module .../playwright/cli.js`) — harness uses upstream `npx @playwright/mcp@latest` (`0.0.80`).
- Debug instance relaunched same-profile (`kill 47852` → pid `355213`), 12 tabs restored, window `62914564` preserved via `xdotool` move test.
- `tor 0.4.9.11-1` installed; Tor-routed Chromium returns `IsTor:true` on `check.torproject.org` — observed exits `171.25.193.80`, `204.8.96.170`, `185.243.218.232`.
- `/browser-live` slash command embeds live context + open-tab list + guardrails in any prompt.

## Key decision

Logged-in Chromium stays OFF Tor permanently: cookies + logins deanonymize anyway, and Tor exits get accounts flagged. Anonymity comes from fresh-profile lanes, never from routing identity-bound sessions.

## File inventory

- `~/.config/opencode/opencode.json` — `browser`, `browser-live`, `browser-tor` MCP entries (backups: `opencode.json.bak.20260903-browser-harness`, `...-browser-tor`)
- `~/.config/opencode/playwright-mcp.json` / `playwright-mcp-tor.json` — isolated / Tor configs
- `~/.config/opencode/commands/browser-live.md` — `/browser-live` slash command
- `~/bin/agent-browser-shot`, `~/bin/agent-browser-cdp` — headless check, CDP hub launcher
- `~/.agents/skills/browser-master/SKILL.md` — lane router skill
- `~/.agents/skills/tor-gateway/SKILL.md` — Tor ops + hygiene skill

## Open

- First real Tor scrape target URL still pending (user to supply).
- Restart OpenCode TUI to load `browser-tor` + `/browser-live`.

Related: opencode-sessions.md, Claude Code + OpenCode Setup — Lusófona Endpoint Map.md
