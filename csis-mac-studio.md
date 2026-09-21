---
title: csis-mac-studio
date: 2026-09-21
tags: [infra, mac-studio, tailscale, ssh]
status: active
related: "[[Mac Studio VNC Black Screen — Session Handoff 2026-09-21]]"
---

# csis-mac-studio

Apple Mac Studio on the tailnet. Facts verified live over SSH on 2026-09-21.

| Fact | Value |
|---|---|
| Tailscale IP | `100.94.171.75` (host `csis-mac-studio`) |
| OS | macOS 26.2 |
| Local user | `csi` (the ONLY user — `fabio` does not exist) |
| SSH | key auth via alias `ssh mac-studio` |
| SSH key | `~/.ssh/id_ed25519_bridge_100.94.171.75` (li→studio bridge) |
| Remote GUI | Apple Screen Sharing (RFB 3.889) on :5900, enabled |
| Physical display | none — HDMI disconnected, network-only (headless) |

## Quick access

```bash
ssh mac-studio                                # passwordless, host key pinned
ssh-bridge                                    # generic key-exchange tool (~/projects/ssh-key-bridge)
```

Wake the display remotely (lasts ~30 s unless display sleep is prevented):

```bash
ssh mac-studio 'caffeinate -u -t 3'           # wake display
ssh mac-studio 'nohup caffeinate -dis -t 1800 >/dev/null 2>&1 &'
```

Troubleshooting history and open problem: [[Mac Studio VNC Black Screen — Session Handoff 2026-09-21]].