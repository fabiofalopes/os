---
title: Hermes exploration prompt — TP-Link OpenWrt cellular-to-LAN migration
date: 2026-09-07
created: 2026-09-07T11:28:48+01:00
status: prompt — discovery required before any change
tags:
  - hermes
  - openwrt
  - tp-link
  - networking
  - migration
  - safety
aliases:
  - OpenWrt TP-Link migration prompt
---

# Hermes exploration prompt — TP-Link OpenWrt cellular-to-LAN migration

## Mission

Explore, document, and prepare a safe, reversible plan for installing OpenWrt (only if hardware support is confirmed) on the TP-Link cellular/SIM device and integrating it with the larger TP-Link device that serves the Ethernet clients. Do **not** flash firmware, reset devices, change routing, or interrupt service during the discovery phase. Produce a durable evidence-backed corpus and an execution plan that a later Hermes session can safely carry out.

The intended outcome is to preserve the existing local network and device addressing, understood as `192.168.108.0/24` with the gateway possibly at `192.168.108.1`. Treat that as a hypothesis until verified from live devices. The larger TP-Link may need to operate as an access point/bridge rather than a second router; do not assume the topology.

## Context from the current session

- The current Linux host is connected through `wlan0` to a funny-named Wi-Fi profile.
- NetworkManager profile is already saved locally; do not expose its password or secrets.
- Observed connection profile:
  - SSID/profile: `(-(-_(-_-)_-)-)`
  - UUID: `bf67e986-5d00-4821-848c-8172b1aabc46`
  - Type: 802.11 wireless
  - Security: WPA-PSK
  - Current client profile had `802-11-wireless.hidden` set to `no` when inspected.
- A hidden-client profile can be requested with:
  `nmcli connection modify '(-(-_(-_-)_-)-)' 802-11-wireless.hidden yes`
- That client setting does not disable SSID broadcasting. SSID broadcast is controlled by the router/access point.
- Before reboot or router changes, verify the saved profile and record non-secret connection facts. Never print, commit, or place Wi-Fi passwords, SIM PINs, router admin passwords, API keys, or full secret-bearing exports in this corpus.

## Hermes operating rules

1. Start with read-only discovery. Ask for human confirmation before every disruptive or irreversible action.
2. Identify exact TP-Link models, hardware revisions, region variants, bootloader constraints, current firmware, and device roles. Photograph/read labels if needed; do not guess from a marketing name.
3. Verify OpenWrt support from authoritative sources and match the exact hardware revision. Check installation method, recovery path, image checksum, factory image requirements, sysupgrade rules, known cellular modem limitations, and rollback procedure.
4. Back up configurations and collect recovery evidence before touching firmware. Store secret-bearing backups outside ordinary notes with restricted permissions; record only paths, hashes, timestamps, and redacted summaries in the corpus.
5. Map the live topology: cellular uplink, router LAN/WAN, Ethernet cabling, Wi-Fi APs, DHCP server, DNS, default route, firewall/NAT, IPv4 subnet, IPv6 behavior, static leases, port forwards, VPNs, and any VLANs.
6. Determine whether the desired design is routed or bridged. Do not place two independent DHCP servers or two competing gateways on `192.168.108.0/24`.
7. Preserve existing device IPs where required. Inventory static addresses and DHCP leases, identify conflicts, and design a migration that keeps one authoritative DHCP service and one intended gateway.
8. Treat “mirroring `192.168.108.1/24`” as ambiguous. Explain the difference between same-LAN bridging/AP mode, routed downstream LANs, cloned SSID, Ethernet switching, and traffic mirroring/packet capture.
9. Separate cellular modem configuration from LAN configuration. Record APN, modem protocol, signal/registration state, MTU, carrier restrictions, and failover expectations without recording SIM secrets.
10. Keep the current Wi-Fi access available as a recovery path where possible. Schedule changes in stages with checkpoints, console/recovery access, timeout limits, and an explicit abort/rollback trigger.
11. Validate after each stage from independent vantage points: router, wired client, Wi-Fi client, and Internet/cellular uplink. Capture commands, timestamps, outputs, and pass/fail evidence.
12. End each session with a concise durable report, open questions, next safe action, and exact evidence paths so later Hermes sessions compound rather than repeat discovery.

## Discovery deliverables

Create or update a corpus under the appropriate vault/project location containing:

- `device-inventory.md`: exact models/revisions, serial-independent identifiers where safe, roles, firmware, ports, radios, modem details, and support status.
- `topology-before.md`: diagram and verified addressing/routing/DHCP/DNS facts.
- `openwrt-compatibility.md`: authoritative support links, image names/checksums, installation/recovery method, risks, and unresolved questions.
- `network-preservation-plan.md`: current-to-target topology, IP/DHCP plan, bridge/router decision, migration order, rollback, and acceptance tests.
- `evidence-log.md`: timestamped commands and redacted outputs; never secrets.
- `decision-log.md`: decisions, assumptions, confidence, owner, and human approval gates.

Use Mermaid where useful. Link related notes with Obsidian wikilinks. Keep a clear distinction between **observed**, **inferred**, and **proposed** facts.

## Proposed target to evaluate, not assume

```text
SIM/cellular TP-Link running supported OpenWrt
  LAN gateway candidate: 192.168.108.1/24
  One authoritative DHCP/DNS service
            │ Ethernet
            │
larger TP-Link serving Ethernet clients
  likely AP/bridge/switch role
  DHCP disabled if it is not the gateway
```

This target is acceptable only if it preserves required static IPs, leases, DNS, firewall policy, inbound services, and management access. If the existing larger TP-Link is the current gateway, propose a staged role reversal instead of changing it implicitly.

## First Hermes run

1. Read this prompt and existing project/network notes.
2. Perform read-only local and device inventory using approved access.
3. Produce the six discovery artifacts above, with redactions.
4. Report blockers and ask for the smallest required human decisions.
5. Do not install firmware or modify router settings until the exact-device compatibility and rollback gates pass.

## Compounding protocol

Every later session must begin by reading the latest corpus and evidence log, verify whether assumptions remain true, and append rather than rewrite history. Record what was learned, what changed, what was ruled out, and the next bounded experiment. Never repeat a scan or firmware lookup without stating why new evidence is needed. Preserve hashes and timestamps for downloaded firmware and backups. A session is complete only when it leaves a usable artifact, a log entry, and a clearly gated next step.

## Success criteria

- Exact hardware and OpenWrt compatibility are verified.
- Existing network behavior and required IP assignments are understood.
- The target topology has one intentional gateway and one authoritative DHCP service.
- Recovery and rollback are tested or credibly available before flashing.
- Migration steps are reversible, observable, and human-approved.
- No secrets are written into notes, reports, git, or chat.
