# Bolt Security Research — MITM Attack Capability

> Target app: **Bolt** (shared e-scooter / urban mobility)
> Rig: **rpi-net** — portable traffic-interception rig on Raspberry Pi 4 + Kali
> Project home: `~/rpi-net/` · Research subdir: `~/rpi-net/Bolt-Security-Research/`
> Status: **fully staged, never executed against the Bolt app**
> Last reviewed: 2026-06-25

---

## TL;DR — the one-paragraph story

We built a portable, battery-powered Raspberry Pi rig that sits between a phone and the internet (`rpi-net`). We proved it can **decrypt HTTPS traffic end-to-end** (validated on an iPhone 15 Pro — full request/response capture of live browsing). The mitmproxy CA certificate is already installed and trusted on the test phone. The rig has been carried and used "in the wild" — it's operational, not just a lab toy. We mapped the entire Bolt API surface from open-source intelligence (30+ endpoints, the auth flow, the BLE protocol, the bolt4free.py exploit logic). Every tool is installed (mitmproxy, frida, objection, jadx, apktool, scapy). **What we have never done — not once — is open the Bolt app on the test phone while the rig is intercepting.** That capture is the entire next step. Everything below is staged for it.

---

## The Rig — what we built

### Architecture

```
 MAIN PHONE (all app traffic)
   → "><>" AP   (wlan1, 192.168.42.1)        ← capture point
     → RPi  (NAT gateway = MITM position: tcpdump / mitmproxy)
       → wlan0 (10.250.0.232) → M7000 4G hotspot → internet
```

The phone joins the `><>` WiFi network. The Pi is the phone's only path to the internet. Everything the phone does online transits the Pi — by design. The Pi is in the perfect MITM position.

### Hardware

| Device | Role | Interface |
|--------|------|-----------|
| **TP-Link M7000** (4G LTE MiFi) | WAN uplink — the only internet path | connects to `wlan0` |
| **TP-Link Archer T3U Plus** (USB, RTL8822BU) | Capture point — broadcasts `><>` AP | `wlan1` |
| **Raspberry Pi 4** (Kali ARM64) | The MITM box — capture / intercept / replay | — |

**Power:** USB-C from a power bank → fully untethered field operation.

**Interface mapping (authoritative — older Bolt notes are stale):**
- `wlan0` = WAN client → connects to M7000 for internet
- `wlan1` = AP `><>` = **where interception happens**
- `eth0` = docked building LAN only; irrelevant when mobile

> ⚠️ Point all interception tools (mitmproxy, tcpdump, bettercap) at **`wlan1`**, never `wlan0`.

### The lexicon (used throughout the project)

| Plain name | Meaning |
|------------|---------|
| **the rig** | the whole field apparatus (the Pi + Kali) |
| **the net** | the `><>` AP on `wlan1` (the capture network) |
| **the line** | `wlan0` + the M7000 uplink (path to internet) |
| **the shore** | the internet, out there |
| **a catch** | a device that joined the net |
| **the haul** | a recorded traffic sample (`.pcap` / mitmproxy dump) |
| **going fishing** | running a field capture session |
| **the M7000** | the 4G hotspot device |

**SSID:** `><>` (small ASCII fish) · **Password:** `FcaVzguQAP5F3TnZ3qKE`

---

## What's Proven — the capability is real

### 1. Plumbing (Phase 0) — ✅ DONE

The rig boots untended from a power bank, brings up the `><>` AP, NATs the phone to the internet, and stays reachable. Controlled by a custom `rpi-net` CLI (~1540 lines) with systemd services for boot, watchdog, and USB hotplug. Field-tested: cold boot from power bank succeeded.

### 2. Raw capture (Phase 1) — ✅ VALIDATED

A device on `><>` has its internet traffic transit the Pi. Verified with the laptop @ `192.168.42.41`. `tcpdump -i wlan1` shows all phone traffic live.

### 3. HTTPS decryption (Campaign A) — ✅ PROVEN

This is the keystone achievement. **Decryption works end-to-end:**

- **Proven on iPhone 15 Pro** (`192.168.42.59`): browsing observador.pt decrypted completely — request paths, query params, POST bodies, feature-flag user IDs, analytics beacons, a live websocket.
- **mitmweb** running in transparent mode on `wlan1`:8080, web UI at `http://192.168.42.1:8081/?token=fishnet2026`.
- Flows saved to `/var/log/rpi-net/mitm.flows` (read with `mitmdump -nr`).
- CA cert trusted on the phone via: profile install **+** Settings → General → About → **Certificate Trust Settings** → enable full trust.

**Known limitation:** apps with **certificate pinning** fail (e.g. Apple/iCloud `metrics.icloud.com`). Unfixable without jailbreak. **Bolt reportedly has NO pinning** (per community research), so it should decrypt cleanly — but this has never been confirmed against the live Bolt app.

### 4. Field use — ✅ OPERATIONAL

The rig has been used "out in the wild." It's portable, it works untethered, the phone connects and browses through it. The CA cert stays trusted across sessions. This is not a lab-only setup.

---

## The Bolt Attack — fully prepped, never executed

This is the gap. Everything is staged for the actual Bolt capture, but it has **never been run**. Here's what's ready:

### Intelligence gathered (from open sources, not live capture)

**API surface mapped — 30+ endpoints across 6 base URLs:**

| Service | Base URL | Purpose |
|---------|----------|---------|
| User API | `user.bolt.eu` | Authentication, profile |
| User Live | `user.live.boltsvc.net` | Main API (newer) |
| Rental Search | `rental-search.bolt.eu` | Vehicle discovery |
| Rental Ops | `{region}-rental.taxify.eu` | Scooter operations |
| Global Rental | `global-rental.taxify.eu` | Ringing vehicles |
| Node | `node.bolt.eu` | Verification |

**Key endpoints (the ride lifecycle):**
- `POST /micromobility/user/ui/order/createAndStart` — start ride
- `POST /micromobility/user/ui/order/getActive` — poll active state
- `POST /micromobility/user/order/finish` — end ride

**Auth flow reversed (from OSINT):**
```
1. Phone validation → 2. SMS OTP register → 3. confirmVerification
   → returns deviceId (authenticated)
4. All subsequent requests: Authorization: Basic base64("+phone:deviceId")
5. deviceId is the session binding key — long-lived token
```

**Security observations already confirmed by the community:**
- ✅ **No certificate pinning** — mitmproxy works without Frida
- ✅ **GPS not validated server-side** — arbitrary coordinates accepted for unlock
- ✅ **deviceId as session key** — cloning allows session reuse across devices
- ✅ **No rate limiting on basic auth** — token reuse doesn't trigger anomalies
- ✅ **Auth token is long-lived**

**BLE protocol documented:** Bolt uses Segway-Ninebot SNSC2.x hardware. AES-128 CTR+CBC-MAC encryption, 3-phase handshake (PRE_COMM → SET_PWD → AUTH), replay protection via monotonic counter. Service UUID: `6e400001-b5a3-f393-e0a9-e50e24dcca9e`.

### Tools installed and ready

All 14 tools from the mission audit are installed:

| Tool | Version | Purpose |
|------|---------|---------|
| `mitmproxy` | — | Transparent TLS interception |
| `frida` | 17.14.1 | SSL pinning bypass, runtime hooks |
| `objection` | — | Frida wrapper for mobile RE |
| `jadx` | 1.5.5 | APK decompilation |
| `apktool` | 3.0.2 | APK unpacking |
| `scapy` | 2.7.1 | Custom protocol crafting |
| `hostapd` | 2.10 | AP (the `><>` network) |
| `btmon` | — | BLE HCI logging |
| `bettercap` | — | BLE MITM, GATT manipulation |
| `gatttool` / `bluez` | — | GATT enumeration |
| Wireshark | — | Deep packet inspection |
| Burp Suite | — | Request/response manipulation |

### Custom tooling built

| Artifact | Location | Status |
|----------|----------|--------|
| `bolt_client.py` | `Bolt-Security-Research/scripts/` | Modular Python client (replaces the 3-year-old bolt4free.py). Needs live-captured tokens to function. |
| `mitmproxy-flow-extractor.py` | `Bolt-Security-Research/configs/` | mitmproxy addon — auto-extracts auth tokens from captured flows. |
| `token-extractor.sh` | `Bolt-Security-Research/configs/` | Pulls Cookie, Authorization, payment_instrument_id from captures. |
| `static-analysis.sh` | `Bolt-Security-Research/configs/` | Ready to run on `apk/bolt.apk` (APK not yet downloaded). |
| API surface reference | `Bolt-Security-Research/reports/api-surface-reference.md` | Complete — 30+ endpoints documented. |

### Cert distribution pipeline — built and used

The mitmproxy CA cert is staged and servable to the phone:
- Public cert in `~/rpi-net/certserve/` (PEM + .cer, **no private key**)
- Served net-only at `http://192.168.42.1:8000/` by transient systemd unit
- iPhone flow: Safari → URL → tap cert → install profile → **enable Certificate Trust Settings**
- **This is already done on the test phone** — the cert is installed and trusted.

---

## How to Actually Run the Bolt Attack (the unstaged next step)

Everything above is prep. This is the execution that has never happened:

### Step 1 — Confirm the rig is up
```bash
sudo bash ~/rpi-net/scripts/validate-boot.sh    # should be 12/12 PASS
rpi-net status                                   # beach active, mitm layer on
```

### Step 2 — Confirm interception is active
```bash
# If not already running (should be persistent via rpi-net-mitm.service):
sudo iptables -t nat -A PREROUTING -i wlan1 -p tcp --dport 80  -j REDIRECT --to-ports 8080
sudo iptables -t nat -A PREROUTING -i wlan1 -p tcp --dport 443 -j REDIRECT --to-ports 8080
sudo systemd-run --unit=rpi-net-mitmweb /usr/bin/mitmweb --mode transparent --listen-port 8080 \
  --showhost --set web_host=0.0.0.0 --set web_port=8081 --set confdir=/home/ken/.mitmproxy -w /var/log/rpi-net/mitm.flows
```
Open `http://192.168.42.1:8081/?token=fishnet2026` to watch flows live.

### Step 3 — Connect phone to `><>`
- WiFi `><>` / password `FcaVzguQAP5F3TnZ3qKE`
- Verify the phone gets a DHCP lease (192.168.42.x)
- Browse any HTTPS site → confirm it decrypts in mitmweb

### Step 4 — Open the Bolt app
This is the moment everything was built for. Just use the Bolt app normally:
- Open the app (watch the auth/login flow decrypt)
- Search for scooters nearby
- Scan a QR code / select a scooter
- Unlock → ride → lock (a real, authorized ride on your own account)
- Take the parking photo

### Step 5 — Extract the tokens
```bash
# From the saved flows:
python3 ~/rpi-net/Bolt-Security-Research/scripts/bolt_client.py extract ...
# Or use the token extractor:
bash ~/rpi-net/Bolt-Security-Research/configs/token-extractor.sh
```
Targets: `Cookie`, `Authorization: Basic`, `payment_instrument_id`, `deviceId`, `user_id`.

### Step 6 — Analyze the haul
- Map every endpoint the app called (not just ride flow — profile, payment, analytics, websocket)
- Correlate app actions with captured network events
- Save the flow dump — this is **the haul**

> ⚠️ **Do NOT** run `Bolt-Security-Research/configs/setup-mitmproxy-transparent.sh` — it flushes ALL PREROUTING (kills Docker) and disables ip_forward (kills NAT). Use the surgical iptables commands above.

---

## What We Expect to Find (hypotheses to validate)

Based on the OSINT and bolt4free.py analysis, the live capture should confirm:

1. **Bolt has no cert pinning** — traffic decrypts cleanly without Frida (community-confirmed, never personally verified)
2. **GPS is client-side only** — the app sends `lat`/`lng` as query params; server accepts arbitrary values (location spoofing trivially works)
3. **Auth is Basic + deviceId** — `base64("+phone:deviceId")`, long-lived, reusable
4. **The order lifecycle** is `createAndStart → getActive → finish (×2)` with `order.id` round-tripping
5. **Photo confirmation can be bypassed** via `confirmed_view_keys: ["photo_capture_key"]`

### Attack ideas (prioritized, for responsible disclosure)

| Idea | Difficulty | Impact |
|------|-----------|--------|
| Auth capture automation (mitmproxy + token export) | Easy | Unlocks all further testing |
| Payment ID extraction from payment setup flow | Easy | Enables scripted ride control |
| GPS spoofer — unlock from arbitrary location | Medium | Tests location validation |
| API mapper — fuzz undocumented endpoints | Medium | Discovers hidden functionality |
| Session hijack — clone deviceId across devices | Medium | Multi-device access |
| Mass scanner — enumerate QR codes for fleet inventory | Medium | Fleet reconnaissance |
| BLE unlock capture — replay without app | Hard | Hardware-level control |

---

## Known Issues & Caveats

### Hardware reliability (the real ceiling)
- **Flaky TP-Link T3U Plus**: USB `-71 EPROTO` errors → adapter disconnects/re-enumerates. Each drop kills the `><>` AP temporarily. Mitigations: reseat firmly, use the blue USB 3.0 port, powered USB hub, verify power bank delivers ≥3A. Hotplug recovery usually brings it back in ~2 min.
- **Software hardening** partly compensates: boot script retries for wlan1, mitm service retries redirect-on, optional beach watchdog.

### Software (mostly resolved)
- **Boot cgroup kill** (hostapd/dnsmasq murdered by systemd on oneshot exit) — ✅ Fixed via `KillMode=process`.
- **`beach up` flapped wlan0** (knocked the M7000 link over) — ✅ Fixed; beach-up no longer touches wlan0.
- **USB hotplug `%k` bug** (passed USB bus path instead of interface) — ✅ Fixed + 20s poll.
- **SSID `>><>` stray `>`** — ✅ Fixed.
- **Conntrack gotcha**: flows established *before* the redirect rule was added bypass it. Only NEW :443 connections get intercepted. Fix: fresh connections, or install `conntrack` + `conntrack -F`.
- **mitm persistence**: was NOT surviving reboot (iptables + mitmweb vanished). The `rpi-net-mitm.service` unit now handles this but the ordering bug (`After=boot` but before wlan1 exists) needs the retry-on-wlan1 fix. **Recovery = reboot** → run `validate-boot.sh`.

---

## The Bigger Picture — where this fits

This Bolt work is **Campaign C ("First Catch")** in the rpi-net roadmap:

```
A (decryption)  ──┐
                  ├──► C (live research — THIS is Bolt)
B (field-ready)  ──┘
```

- **Campaign A (See Clearly) — ✅ DONE**: HTTPS decryption proven. This is what makes Bolt research possible at all.
- **Campaign B (Field-Ready) — 🟡 parallel**: remote control from phone (mosh/SSH works), hide the M7000 SSID, MAC allow-listing, auto-capture on join. Enabling, not blocking.
- **Campaign C (First Catch) — ⏳ THIS**: run the Bolt app through the rig, produce a documented haul, reverse the protocol, write up findings for responsible disclosure.

The Bolt case is the **first research target** mounted on the rig. Once the workflow is proven on Bolt, the same rig + methodology serves any future target found in the wild.

### Ethics boundary
Authorized assessment only. All testing uses owned accounts. Vulnerabilities go through Bolt's Bugcrowd program (coordinated disclosure). **No free rides.**

---

## Source of Truth — where to read more

| Document | Location | What it is |
|----------|----------|------------|
| **CONTEXT-UPDATE.md** | `~/rpi-net/CONTEXT-UPDATE.md` | **Live briefing — read first. Wins on conflict.** |
| CHARTER.md | `~/rpi-net/CHARTER.md` | Mission, rig architecture, phases, lexicon |
| ROADMAP.md | `~/rpi-net/ROADMAP.md` | Campaigns A/B/C and current direction |
| STATUS.md | `~/rpi-net/STATUS.md` | Durable project state, deployed artifacts |
| Mission.md | `~/rpi-net/Bolt-Security-Research/Mission.md` | Bolt-specific scope, methodology, tooling audit |
| Script-Analysis.md | `~/rpi-net/Bolt-Security-Research/Script-Analysis.md` | bolt4free.py deep-dive + execution plan |
| API surface reference | `~/rpi-net/Bolt-Security-Research/reports/api-surface-reference.md` | All 30+ endpoints, auth flow, BLE protocol |
| SESSION-CHECKPOINT.md | `~/rpi-net/Bolt-Security-Research/SESSION-CHECKPOINT.md` | ⚠️ Stale — assumes wlan0=AP (wrong; it's wlan1) |
| Reading order | `README → CHARTER → WORKING-AGREEMENT → CONTEXT-UPDATE → STATUS` | Intake protocol |

---

## Open Questions for the Next Session

1. **Is the rig currently up?** Run `validate-boot.sh` + `rpi-net status` to confirm before anything else.
2. **Is there a Bolt scooter in range to do a real test ride?** (Needed for the full scan→unlock→ride→lock capture.)
3. **Do we want a burner account** for the capture, or the main account? (Mission.md recommends dedicated research accounts with separate IDs.)
4. **Should we download the Bolt APK first** for static analysis (`jadx`) alongside the live capture? (The `apk/` directory is empty — APK never downloaded.)
5. **Power bank health**: does it deliver ≥3A under beach+mitm load? (Measure `vcgencmd measure_volts`, watch the throttled bit during a session.)
