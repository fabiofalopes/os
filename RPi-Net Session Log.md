# RPi-Net + Bolt Research — Session Log

> Living document. Updated as we work. Captures decisions, reasoning, and progress across sessions.
> Project home: `~/rpi-net/`

---

## 2026-06-26 — Lab Session: Android RE Setup + APK Analysis

### What we set out to do

Move from planning to execution. The rig is built, MITM decryption is proven, certs are on the iPhone. The missing piece has always been: **actually analyze the Bolt app's code**. Today we start that.

### Key decisions made this session

#### 1. Lab vs Field session rules (written into the project)

We recognized that the rig operates in two fundamentally different modes with opposite risk profiles:

- **Lab** (docked/home WiFi): freedom to break things, develop, test, validate
- **Field** (power bank + M7000): discipline, freeze tooling, capture-first, don't touch plumbing

Created `~/rpi-net/SESSION-RULES.md` with:
- A three-layer model (L1 rig infrastructure / L2 interception / L3 research tooling) — the layer tells you blast radius
- Lab protocol (break freely, validate before deploying L1)
- Field protocol (validate before, capture during, save haul after)
- A staging path: `lab/` → validated → promoted → deployed
- The validation gate is **only mandatory for L1** — L3 tooling (what we iterate on most) has no gate

Created `~/rpi-net/lab/` as the staging directory with a 6-item backlog of lab-testable work.

**Why this matters:** prevents the dev/prod split from creating blocking dependencies. Lab work is always unblocked. Only plumbing changes carry a validation gate. The structure makes lab easier (freedom) and field safer (discipline).

#### 2. Two-device division of labor

| Device | Role | Why |
|--------|------|-----|
| **iPhone 15 Pro** (main) | Traffic capture — Bolt app on `><>` WiFi | CA cert installed, HTTPS decryption proven end-to-end |
| **ASUS_Z012D** (older Android) | Code analysis — disassembly, runtime hooks | APK decompiles far more easily than iOS; frida is mature on Android |

The Android APK reveals the **code** (endpoints, crypto, secrets, logic). The iPhone capture reveals the **behavior** (what the app actually sends). Same backend, two complementary views. This is the ideal setup.

#### 3. Static analysis first, dynamic later

We clarified a conceptual tangle:
- **"Disassemble"** = static analysis = take the APK apart with `jadx`/`apktool` = **no phone needed, just the APK file**
- **"Work from within"** = dynamic analysis = hook functions at runtime with `frida`/`objection` = **needs USB + ADB**

The smart order: static first (understand the code before you know what to hook), dynamic later (root the phone, push frida-server, hook specific functions identified during static analysis).

#### 4. The older Android phone is a dedicated test device

Since it's not a daily driver, we can root it (Magisk), patch it, break it freely. Not rooted yet — that's a later step for the dynamic analysis phase. For static analysis, root is irrelevant.

### Tooling setup completed

| Tool | Status | Notes |
|------|--------|-------|
| `adb` | ✅ Installed (was missing) | `/usr/lib/android-sdk/platform-tools/adb`, v1.0.41 |
| udev rule for ASUS phone | ✅ Created | `/etc/udev/rules.d/51-android-asus.rules` (0b05:7781) |
| USB debugging | ✅ Authorized | Phone trusts this computer ("Always allow") |
| `jadx` | ✅ Already installed | v1.5.5 |
| `apktool` | ✅ Already installed | v3.0.2 |
| `frida` | ✅ Already installed | v17.14.1 (for later dynamic phase) |
| `objection` | ✅ Already installed | v1.12.5 (for later dynamic phase) |

### Phone specs (the test device)

| Property | Value |
|----------|-------|
| Model | ASUS_Z012D (ZenFone 3 Zoom) |
| Android | 8.0.0 (Oreo, SDK 26) |
| Architecture | arm64-v8a |
| Root | ❌ Not rooted (planned for later via Magisk) |
| Bolt app installed | ❌ Not yet (installing via Aurora Store) |
| Notable apps | Aurora Store (no Google account needed), F-Droid, Brave, Termux/SSH, Obsidian, Acode |

### Package discovery

**OSINT was wrong about the package name.** The Bolt research notes (`api-surface-reference.md`) referenced `com.taxify.core` — that doesn't exist. The actual package is:

- **`ee.mtakso.client`** — legacy Estonian name ("m-takso" = mobile taxi) from Taxify days, kept through the Bolt rebrand
- Latest version: CA.190.0 (build 3640), December 2025
- Minimum: Android 5.0+ (API 21) — will run on this phone
- Build type: Native Android (not Flutter/React Native) — good for decompilation
- Distributed as App Bundle (AAB) — split APKs (base + arch + language)

> ⚠️ Update `Bolt-Security-Research/reports/api-surface-reference.md` with the correct package name.

### Current state

- Workspace prepped: `~/rpi-net/Bolt-Security-Research/apk/` + `~/rpi-net/lab/jadx-output/`
- Waiting for: Bolt to be installed on the phone via Aurora Store
- Next: pull APK via `adb`, decompile with `jadx`, grep for endpoints/crypto/secrets

### Ideas for next steps (after static analysis)

1. **Root the ASUS phone with Magisk** — unlocks frida-server for direct runtime hooks
2. **Install mitmproxy CA cert on the Android phone** — then it can also be a traffic capture device (currently only iPhone has the cert)
3. **Run Bolt on the Android phone through `><>`** — capture + frida simultaneously (the killer combo)
4. **Patch APK with frida-gadget** (if we don't want to root) — objection can do `objection patchapk`
5. **Correlate static findings with live traffic** — match decompiled endpoint strings with actual captured requests from the iPhone

### Lessons so far

- **OSINT needs verification.** The package name `com.taxify.core` appeared authoritative in our research notes but was wrong. Always confirm against the actual Play Store listing.
- **adb wasn't installed** despite Kali being a pentesting distro. The Mission.md tool audit from 2026-06-17 claimed "all 14 tools ready" but adb was missing. Validate tool claims, don't trust checklists.
- **Cloudflare blocks automated APK downloads** from APKPure/APKMirror. Aurora Store on the phone is the practical workaround — no Google account needed, direct install, then `adb pull`.

### APK analysis — first pass (apktool smali)

#### Events

- **jadx decompilation killed** — OOM on 27MB APK; RPi crashed once from the load. Memory-conscious now.
- **apktool succeeded**: 48,875 smali files across `smali/` through `smali_classes5/`, full `AndroidManifest.xml` decoded.
- **Phone showed "unauthorized"** after RPi restart — needs re-auth on phone screen.

#### Discoveries from static analysis (apktool smali + resources)

**API Keys** from `res/values/strings.xml`:

| Key | Value | Purpose |
|-----|-------|---------|
| `braze_api_key` | `bb337267-38b5-4b4d-9e4c-f6238d69bf06` | Braze marketing SDK |
| `clevertap_account_token` | `3aa-600` | CleverTap analytics |
| `google_api_key` | `AIzaSyA1oNkgJ-bbPAuP4jM5Zb8HA8yROWwLJtw` | Google APIs |
| `google_auth_web_client_id` | `718916732167-fg6lta9iiuo6o1pcrnhat8fsot6hd6nd.apps.googleusercontent.com` | Google OAuth web client |
| `facebook_client_token` | `dc2d1966f5960e30234a7832bf765fd8` | Facebook SDK |

**Endpoint hosts** found in smali:

| Host | Likely purpose |
|------|----------------|
| `https://node.bolt.eu/` | Rental rules (`/rental-web/client/getLocalRules`) |
| `https://user.live.boltsvc.net/` | Main user API |
| `https://admin.bolt.eu/` | Fleet/drivers + user management |
| `https://admin.prelive.bolt.eu/` | Prelive admin environment |
| `https://images.bolt.eu/` | Static assets |
| `https://taxify-client.firebaseio.com` | Firebase Realtime Database |
| `scooters.taxify.eu` | Scooter-specific subdomain |
| `https://taxify.atlassian.net` | Internal tracking (?) |

**Key code locations**:

| Area | Smali path |
|------|------------|
| **BLE** | `eu/bolt/client/carsharing/offlinemode/helper/AndroidBluetoothServiceHelper.smali` |
| **Auth** | `eu/bolt/client/aidl/` (AIDL-based `AuthTokenService`), `eu/bolt/client/login/data/AuthPreferenceController.smali` |
| **MQTT** | `eu/bolt/*` packages (live tracking/telemetry) |
| **Netty** | `smali_classes2/io/netty/` (async networking) |
| **Protobuf** | Binary serialization (not JSON on some endpoints) |

**AndroidManifest highlights**:
- `compileSdk` 34, minimum Android 8.0+
- Permissions: `INTERNET`, `FINE`/`COARSE`/`BACKGROUND_LOCATION`, `CAMERA`, `NFC`, `RECORD_AUDIO`, `FOREGROUND_SERVICE_MICROPHONE`, `AD_ID`
- Cross-app shared auth with `com.bolt.deliveryclient`
- Queries WhatsApp packages (detects install for sharing/contact)
- **No `network_security_config.xml`** — no Android-level SSL pinning (consistent with OSINT: Bolt has no cert pinning)

#### Decisions

- **Dropped jadx** in favor of apktool smali output — smali is more accurate (closer to original bytecode) AND memory-efficient. The Pi crashed from jadx memory pressure; smali `grep` is lightweight.
- Working with smali directly (not Java source) — trade accuracy for memory.

#### State

- apktool output at `~/rpi-net/lab/apktool-output/` (48,875 smali files, full manifest, all resources)
- APKs in `~/rpi-net/Bolt-Security-Research/apk/` (4 files, 30MB total)
- jadx killed, not restarting
- Phone needs re-auth

#### Next

1. Find the main API base URL (`germany-rental.taxify.eu` equivalent for current region)
2. Examine `eu/bolt/client/login/` for auth flow implementation
3. Look at the BLE service implementation (`AndroidBluetoothServiceHelper`)
4. Update `Bolt-Security-Research/reports/api-surface-reference.md` with correct package name (`ee.mtakso.client`) and new findings

### Architecture discovery — server-side unlock model

#### Events

- Continued static analysis of the Bolt `base.apk` after the first apktool pass
- Extracted native libraries from `split_config.arm64_v8a.apk`
- Examined the RIBS architecture and `BuildConfig`
- Cross-referenced findings with the old OSINT (`bolt4free.py`, BLE analysis references in `Mission.md`)

#### Discoveries

**BuildConfig extracted** (`smali/ee/mtakso/client/BuildConfig.smali`):

| Field | Value |
|-------|-------|
| `APPLICATION_ID` | `ee.mtakso.client` |
| `BOLT_SERVER_HOST` | `user.live.boltsvc.net` |
| `BOLT_SERVER_URI` | `https://user.live.boltsvc.net/` |
| `BRAND_NAME` | `bolt` |
| `BUILD_TYPE` | `release` |
| `DISTRIBUTION_CHANNEL` | `googleplay` |
| `FLAVOR` | `liveGooglePlayBolt` |

**RIBS architecture** (Bolt's own modular framework — Router/Interactor/Builder/State):

- Root: `ee/mtakso/client/ribs/root/`
- Sub-RIBs: `ridehailing/`, `map/`, `loggedin/`, `splash/`, `login/`, `interactor/`, `helper/`
- `ridehailing/` contains `PreOrderFlowRibInteractor`, `activeOrderMarkers` (ride booking)
- No `scooter` or `micromobility` RIB — scooter functionality is embedded in the main app

**Native libraries** (`arm64-v8a` split):

| Library | Purpose |
|---------|---------|
| `libarcore_sdk_c.so`, `libarcore_sdk_jni.so` | Google AR SDK (ARCore) |
| `libcrashlytics*.so` | Firebase Crashlytics crash reporting |
| `libimage_processing_util_jni.so` | Image processing |
| — | **No Ninebot/Segway SNSC SDK found** |

**BLE code analysis:**

- `AndroidBluetoothServiceHelper` at `eu/bolt/client/carsharing/offlinemode/helper/`
- Written in Kotlin (coroutines, `Flow` API)
- Uses `android.bluetooth.BluetoothAdapter`
- Package path is `carsharing` + `offlinemode` — this handles **car-sharing** when offline, not scooters
- The phone talks to the car via BLE in that specific offline scenario

**Critical architectural insight:**

- No Ninebot/Segway/SNSC strings or SDK found **anywhere** in the APK
- No direct phone-to-scooter BLE protocol implementation
- Conclusion: Modern Bolt uses a **server-side unlock model** — the phone calls the API, and the server unlocks the scooter via cellular or BLE on the scooter's side
- The old OSINT (`bolt4free.py`, BLE MITM against phone-to-scooter) is **outdated** — it describes the 2022 architecture
- The actual attack surface is the **API**, not BLE. `Mission.md`'s BLE focus needs updating.

#### Decisions

- **Attack model shifted**: instead of BLE MITM (phone↔scooter), the focus is now API MITM (phone↔server) — which is exactly what the current rig is set up for
- The static analysis from the Android APK gives us the API code to understand what we'll see in the iPhone traffic capture
- Need to update `Mission.md` and `Script-Analysis.md` to reflect the server-side unlock model

#### State

- Extensive static analysis completed with apktool smali (jadx skipped — too memory-heavy for the Pi)
- Phone needs re-authorization (RPi may have rebooted)
- Full picture of the Bolt app's structure, API config, and security posture now available
- Major revision needed to the research docs — OSINT findings are outdated

#### Next

1. Find the actual rental/scooter endpoints (search for API path patterns beyond the base URI)
2. Look for the unlock command in the code — how does the app tell the server to unlock a scooter?
3. Update `api-surface-reference.md` with correct findings (package, endpoints, server model)
4. Plan the iPhone traffic capture: what endpoints to look for, what auth flow to expect
5. The real attack is now clear — capture and reverse the API calls, not BLE

### Pi reliability — zombie state fixed (hardware watchdog)

#### Events

- Pi became unresponsive during jadx decompilation (OOM cascade). Power cycled physically. This was not the first occurrence.
- Investigated root cause: `vcgencmd get_throttled` returned `0xe0008` — under-voltage detected, ARM frequency capping, currently throttled.
- SoC voltage at 0.8500V (low end), temperature at 82.7°C (above 80°C throttle threshold).
- Identified USB power budget as the root cause: TP-Link adapter + phone charging + USB drive + VIA hub exceed the Pi's 5V rail capacity.
- Installed and configured hardware watchdog (`bcm2835_wdt`) — the Pi will now self-recover from soft hangs within 30 seconds.
- Added 1GB swap file — OOM insurance for memory-intensive operations (jadx, large captures).

#### Decisions

- **Hardware watchdog is the primary fix**, not swap. Swap prevents OOM cascades; watchdog recovers from all soft hangs regardless of cause.
- **Watchdog-timeout=30** is aggressive but appropriate — if the network stack dies, SSH is unreachable within seconds. Waiting longer doesn't help.
- **Not adding cron-based health checks** (ping-triggered reboot) — the hardware watchdog is more reliable (works even if cron hangs).
- **Physical fixes deferred** — powered USB hub, separate phone charger, and cooling are recognized as necessary but not available right now.

#### State

| Component | Status | Detail |
|-----------|--------|--------|
| Watchdog daemon | ✅ active | `/dev/watchdog`, timeout=30, interval=10 |
| Swap | ✅ 1GB active | `/swapfile` in `/etc/fstab` |
| `dtparam=watchdog=on` | ⏳ pending reboot | Set in `/boot/config.txt` |
| Temperature | ⚠️ 81.8°C | Still hot — no physical fix applied yet |
| `get_throttled` | ⚠️ 0xe0008 (sticky) | Clears on clean boot |
| Load | ✅ 1.38 | Healthy |

#### Next

1. Procure powered USB hub — eliminates USB power draw from Pi's 5V rail
2. Stop charging phone from Pi — separate charger or dual-output power bank
3. Install heatsink + fan on Pi 4 SoC — bring temps below 80°C
4. Verify official 5.1V/3A power supply is being used
5. Add `vcgencmd get_throttled` check to field session startup checklist

### Loop skill — design proposal

Proposed a new agent behavior pattern: the **iterate-until loop** (six-field model: GOAL, CONDITION, MAX_ITERATIONS, ACTIONS, EVALUATION, ADJUSTMENT). The agent executes actions in a loop, checks a success condition, and adjusts its approach between iterations until the condition is met or MAX_ITERATIONS is reached.

Full design document at `obsidian-vault/Agent Loop Skill — Iterate-Until Pattern.md`. Includes 4 rpi-net examples (rig health, capture, APK analysis, build/validate) and 4 general pentesting examples (fuzzing, brute-force, port scanning, exploitation). Next step: formalize as SKILL.md and test against real rpi-net tasks.

### tmux persistence + reboot prep

#### What we did

The Pi needs a reboot to activate `dtparam=watchdog=on` in `/boot/config.txt`. Before doing that, we hardened session persistence so work survives the reboot:

- **TPM installed** at `~/.tmux/plugins/tpm` — the tmux plugin framework was referenced in config but never activated
- **tmux-resurrect** installed — saves full session state (windows, panes, working directories, running programs) to disk
- **tmux-continuum** installed — auto-saves every 15 minutes, auto-restores when tmux starts
- **Plugins enabled** in `~/.tmux.conf.local` (lines 452–458): resurrect, continuum, auto-restore, 15-min save interval, pane contents capture, nvim session strategy
- **Systemd unit created** at `/etc/systemd/system/tmux-server.service` (Type=forking, starts tmux at boot, restart on failure) — `systemctl enable`d
- **Current session saved** — save file at `~/.local/share/tmux/resurrect/tmux_resurrect_20260626T050107.txt` captures the opencode session (window 0, pane 0)

#### Why it matters

Before this, any Pi reboot killed the terminal session — opencode context, scrollback, working directory, everything. Now:
1. systemd starts tmux at boot
2. continuum auto-triggers restore from last save
3. User SSHes in → `tmux attach` → the opencode session is back with scrollback

This pairs with the hardware watchdog: the watchdog handles soft hangs (auto-reboot in 30s), and tmux persistence means even a watchdog-triggered reboot loses at most 15 minutes of work.

#### State

| Component | Status |
|-----------|--------|
| TPM | ✅ installed |
| tmux-resurrect | ✅ installed (via TPM) |
| tmux-continuum | ✅ installed (via TPM) |
| `~/.tmux.conf.local` plugins | ✅ configured |
| `tmux-server.service` | ✅ created + enabled |
| Last save | ✅ 2026-06-26 05:01:07 |

#### Save location

XDG path: `~/.local/share/tmux/resurrect/` — NOT `~/.tmux/resurrect/`
- `last` symlink → most recent save
- `tmux_resurrect_<timestamp>.txt` — session state
- `pane_contents.tar.gz` — pane scrollback
- `save/` — per-pane working directories and programs

#### Keybindings

| Binding | Action |
|---------|--------|
| `Ctrl-b + Ctrl-s` | Manual save |
| `Ctrl-b + Ctrl-r` | Manual restore |
| Continuum | Auto-save every 15 min (background) |

#### Next session

1. Reboot the Pi (verify `dtparam=watchdog=on` takes effect)
2. Run `validate-boot.sh` (now 13 checks — added watchdog + swap + throttle)
3. Verify tmux auto-restore: `tmux list-sessions` → `tmux attach`
4. Re-authorize phone via adb
5. Pick up from the "Next Session Pickup" vault note

### Deep smali analysis + loop skill + API rewrite

#### Events

- **Created iterate-until loop skill** at `~/.config/opencode/skills/iterate-until/SKILL.md` — a formal SKILL.md defining the six-field loop pattern (GOAL / CONDITION / MAX_ITERATIONS / ACTIONS / EVALUATION / ADJUSTMENT). Available as a loadable skill for future sessions.
- **Dispatched @explorer** for comprehensive Bolt smali analysis (7 categories). Explorer returned a goldmine: complete API endpoint map, auth model, payment flow, MQTT architecture.
- **Dispatched @fixer** to completely rewrite `api-surface-reference.md` with corrected findings (337 lines, up from 182).
- **Dispatched @fixer** to update `Mission.md` and `Script-Analysis.md` with corrections.

#### Key discoveries from smali analysis

**Complete API endpoint map found:**
- 18 micromobility (scooter) endpoints — the full ride lifecycle: `vehicle/getIdByUuid` → `search/getVehicles` → `order/createAndStart` → `order/getActive` → `order/finish` → `order/checkParkingPicture` → `order/rate`
- 31 ride-hailing (taxi) endpoints — `client/v1/createRide`, `cancelRide`, `getActiveOrder`, `polling/v1/rider`, etc.
- API base URL groups: micromobility, rides, rides/search, rider/safety, mobility, comms

**Auth model CORRECTED:**
- Token-based (likely Bearer), **NOT** Basic auth as `bolt4free.py` OSINT claimed
- `BoltRequestInterceptor` is the central OkHttp interceptor
- Auth token stored in SharedPreferences as `auth_token`
- Every request gets 16+ query params injected: `deviceId`, `device_name`, `gps_lat`, `gps_lng`, `gps_age`, `session_id`, `user_id`, etc.
- On 401: app force-logs-out the user

**Server-side unlock CONFIRMED:**
- Scooter unlock is via API call (`order/createAndStart`), server unlocks via cellular
- No phone-to-scooter BLE protocol in the app
- The old `bolt4free.py` BLE approach is completely outdated

**MQTT architecture:**
- Dual HiveMQ MQTT 3 systems: main MQTT (ride tracking/telemetry) + chat MQTT (driver/rider chat)
- Config (host/port/credentials) comes from REST API

**Payment:**
- Bolt's own system — **NO** Adyen, **NO** Stripe SDK
- `payment_instrument_id` included in order creation requests

**No gRPC/Protobuf** — REST + Retrofit + Gson (JSON) for all API communication.

#### State

- `api-surface-reference.md`: completely rewritten with actual APK findings (337 lines)
- `Mission.md` + `Script-Analysis.md`: being updated with corrections (fixer dispatched)
- Loop skill: created and available at `~/.config/opencode/skills/iterate-until/SKILL.md`
- All 48,875 smali files analyzed, key code locations identified

#### Next

- **iPhone traffic capture plan** — now we know EXACTLY what endpoints to look for
- The capture will confirm: token format, actual request/response payloads, GPS validation behavior, payment flow
- This is the transition from lab (static analysis) to field (live capture)

### Lab loop — comprehensive prep complete

#### Events (continuing the loop after the deep smali analysis)

- **Auth model CORRECTED again**: deeper smali trace confirmed it IS Basic auth `Basic base64("<phone>:<device_uuid>")` — the earlier "token-based Bearer" claim was wrong. The authenticator class at `eu/bolt/client/login/data/e.smali` method `q(User)` builds the header by concatenating phone:device_uuid, base64 encoding with NO_WRAP, formatting as `"Basic %s"`. The `auth_token` from the login response is for cross-app AIDL only, not HTTP.
- `api-surface-reference.md` auth section corrected back to Basic auth
- **Mock Bolt API server built** at `~/rpi-net/lab/mock-bolt-api/server.py` (357 lines, 8 endpoints, Python stdlib only)
- **Mock server lifecycle tested** end-to-end via curl: login → search → create+start → getActive → finish → rate — ALL PASS
- **Capture plan written** at `~/rpi-net/Bolt-Security-Research/CAPTURE-PLAN.md` (comprehensive field playbook)
- **Flow extractor reviewed** — correctly targets `user.live.boltsvc.net`, decodes Basic auth, extracts query params. Works as-is.
- `bolt_client.py` endpoint paths being updated (old `/micromobility/user/ui/order/*` → new `/micromobility/order/*`)
- **MQTT protocol analysis** in progress (determining if mitmproxy will capture it or if we need tcpdump)

#### Key auth findings (final, confirmed)

| Finding | Detail |
|---------|--------|
| Authorization header | `Basic base64("<phone_number>:<device_uuid>")` |
| device_uuid | UUID v4, generated once per install, stored in SharedPreferences key `user_auth_uuid` (device-scoped) |
| phone_number | International format (e.g., `+351912345678`) |
| Login endpoint | `POST profile/registration/signup/v2` — returns user object with auth_token, phone, auth_username, id |
| Pre-login requests | NO Authorization header (empty string returned, interceptor skips it) |
| On 401 | Force-logout via `logOutActiveUserLocalDataUseCase` — NO refresh token mechanism |
| Query params on every request | 18 params: deviceId, device_name, gps_lat, gps_lng, gps_age, gps_accuracy_m, session_id, etc. |

#### Order request models (confirmed from smali)

| Endpoint | Required Fields |
|----------|----------------|
| `order/createAndStart` | `vehicle_handle` (object with type+value), `payment_instrument_id` |
| `order/finish` | `order_id`, `supported_features` (list with `{"type":"vps"}`); optional `vps` location |
| `vehicle/getIdByUuid` | GET with `vehicle_uuid` query param (from QR scan) |
| `search/getVehicles/v2` | POST with optional `viewport` (map bounds) + `payment_instrument_id` |

#### State

| Component | Status |
|-----------|--------|
| `api-surface-reference.md` | ✅ Corrected to Basic auth, 337 lines |
| `CAPTURE-PLAN.md` | ✅ Written — comprehensive field playbook with pre/during/post capture steps |
| `mock-bolt-api/server.py` | ✅ Built and tested (357 lines, 8 endpoints, all pass) |
| `bolt_client.py` | 🔄 Being updated with correct endpoints |
| `flow-extractor.py` | ✅ Reviewed, works correctly |
| All docs | ✅ Corrected to reflect actual APK analysis |

#### Lab work complete — what's left requires the field

- Live Bolt traffic capture (need real scooters + real account)
- GPS spoofing validation (need real server response)
- MQTT capture (need real connection — may need tcpdump alongside mitmproxy)
- Token extraction from real flows (need captured data)
- `bolt_client.py` replay testing against real server

**This is the boundary. Everything that can be done in the lab IS done. The next step is a field session.**

### Android root preparation — comprehensive prep done

#### Events

- Investigated whether the Android phone (ASUS_Z012D) can be used for Bolt traffic capture alongside the iPhone
- **CRITICAL FINDING**: Android 7+ (API 24+) only trusts SYSTEM CA certificates by default. The Bolt app targets API 34, has no `network_security_config.xml`, is not debuggable → mitmproxy CA installed as USER cert is **SILENTLY REJECTED**. Traffic interception does NOT work on non-rooted Android.
- This is fundamentally different from iOS where user-installed CA works for all apps.
- **Decision**: plan the root of the ASUS phone. It's a dedicated test device.

#### Root research (via @librarian)

| Property | Value |
|----------|-------|
| Device | ASUS_Z012D = ZenFone 3 Zoom ZE553KL |
| SoC | Snapdragon 625 |
| Stock OS | Android 8.0 Oreo (SDK 26) |
| Bootloader unlock | Official ASUS unlock APK exists (`UnlockTool_9.2.0.0`) but commonly fails with "network error" on Oreo. Fallback: unofficial fastboot method ([snowwolf725/RootZenfone3](https://github.com/snowwolf725/RootZenfone3)) |
| Root method | **Magisk ONLY** (SuperSU on Oreo = instant brick). TWRP → flash Magisk ZIP is the community-recommended path |
| TWRP | `twrp-3.1.0-0-Z01H-20170408.img` (specific version, hosted on Mega.nz) |
| Latest firmware | WW-80.30.76.64 (Jan 2019). Never got Android 9+. |

#### Files downloaded to `~/rpi-net/lab/root-prep/`

| File | Size | Purpose |
|------|------|---------|
| `Magisk-v28.1.apk` | 12MB | Root (flash via TWRP) |
| `frida-server-17.14.1-android-arm64` | 52MB | Runtime hooks (push after root) |
| `AlwaysTrustUserCerts_v1.3.zip` | 7KB | Magisk module: promotes user CA to system trust store |
| `UnlockTool_ZE553KL.apk` | 753KB | Official bootloader unlock APK |

#### Tools installed

- `fastboot` v34.0.5-debian — was missing, now installed alongside `adb`

#### Still needed (manual download — requires browser)

- **TWRP recovery image** (`twrp-3.1.0-0-Z01H-20170408.img`) — on Mega.nz, browser-required
- **Stock firmware** (`UL-Z01H-WW-80.30.76.64_OTA.zip`) — needed for `boot.img` extraction and safety net fallback

#### Root procedure written

Complete step-by-step guide at `~/rpi-net/lab/root-prep/ROOT-PROCEDURE.md` covering:

1. **Bootloader unlock** — official ASUS APK (`UnlockTool_ZE553KL.apk`) as primary path; unofficial fastboot fallback if APK fails with "network error"
2. **TWRP flash** — `fastboot flash recovery twrp-3.1.0-0-Z01H-20170408.img` with critical **"DON'T BOOT TO SYSTEM FIRST"** warning (TWRP will restore stock recovery on first boot)
3. **Magisk flash** — via TWRP "Install" → select `Magisk-v28.1.apk` (renamed to `.zip`)
4. **Root verification** — `adb shell su -c id` returns `uid=0(root)`
5. **mitmproxy CA as system cert** — push `AlwaysTrustUserCerts_v1.3.zip` to phone, flash via Magisk Manager Modules
6. **frida-server installation** — `adb push frida-server-17.14.1-android-arm64 /data/local/tmp/frida-server`
7. **Traffic capture verification** — curl test against `https://example.com` with mitmproxy CA
8. **Unbrick procedure** — stock firmware + fastboot flash all partitions

#### Post-root vision: Dual-device capture setup

| Device | Role | Capabilities |
|--------|------|--------------|
| **iPhone 15 Pro** | Clean traffic capture | Real user experience, unmodified app, no hooks |
| **ASUS_Z012D** (rooted) | Instrumented capture | frida hooks, `logcat`, system CA, filesystem access, Magisk modules |

Same Bolt session captured on **both simultaneously** through the rig — clean reference + deep instrumentation side by side.

#### State

| Component | Status |
|-----------|--------|
| `ROOT-PROCEDURE.md` | ✅ Written — complete 8-step guide with unbrick safety net |
| `fastboot` | ✅ Installed (v34.0.5-debian) |
| Magisk v28.1 | ✅ Downloaded (`~/rpi-net/lab/root-prep/Magisk-v28.1.apk`) |
| frida-server 17.14.1 (arm64) | ✅ Downloaded |
| AlwaysTrustUserCerts module | ✅ Downloaded |
| UnlockTool APK | ✅ Downloaded |
| TWRP image | ❌ Needs browser download (Mega.nz) |
| Stock firmware | ❌ Needs browser download |
| Phone USB reconnect | ❌ User not at desk |
| Root execution | ⏳ Blocked on TWRP + firmware, user at desk |

#### Key warnings (hard constraints)

- **NEVER use SuperSU on Oreo** — instant hard brick, no recovery path
- **TWRP must not boot to system** before entering recovery — TWRP auto-restores stock recovery if you let it boot to system
- **Bootloader unlock WIPES ALL DATA** — phone is factory reset; take this as an opportunity for a clean OS
- **No safe re-lock mechanism exists** — once unlocked, the bootloader cannot be reliably re-locked; this phone is permanently a test device**

### Session wrap-up — next session is the root

**Massive lab session. Everything that can be done without physical phone access and without being near scooters is complete.**

**What was accomplished:**
- Bolt APK pulled and decompiled (48,875 smali files via apktool)
- Complete API mapped: 49 endpoints, Basic auth confirmed (`phone:device_uuid`), server-side unlock model
- Mock Bolt API server built and tested end-to-end (8 endpoints, all pass)
- Capture plan written (`CAPTURE-PLAN.md`)
- Pi reliability hardened (hardware watchdog, 1GB swap, tmux persistence with resurrect/continuum)
- Android root fully prepped — all downloadable files staged, `ROOT-PROCEDURE.md` written
- Loop skill (iterate-until pattern) created and formalized as SKILL.md
- pitemp monitor deployed at `~/bin/pitemp` (running in tmux window 2)

**You've reached the boundary. Next session is the root.**

**Session priorities (in order):**
1. Download TWRP image + stock firmware (browser needed — Mega.nz + ASUS CDN)
2. Root the ASUS phone (follow `~/rpi-net/lab/root-prep/ROOT-PROCEDURE.md`)
3. Install mitmproxy CA as system cert via AlwaysTrustUserCerts Magisk module
4. Push frida-server, verify with `frida-ps -U`
5. Test: open Bolt app on rooted Android through rig → traffic should decrypt
6. Field session for live capture (execute `CAPTURE-PLAN.md`)

**Key files for next session:**
- `~/rpi-net/lab/root-prep/ROOT-PROCEDURE.md` — the guide
- `~/rpi-net/lab/root-prep/` — all staged files (Magisk, frida-server, AlwaysTrustUserCerts, unlock tool)
- `~/rpi-net/Bolt-Security-Research/CAPTURE-PLAN.md` — field playbook
- `~/rpi-net/CONTEXT-UPDATE.md` — live state, read first

**Pi health:** Ended at ~85°C with active throttling. Shut down opencode to let it cool. pitemp monitor shows the cooldown. Root the phone when Pi is under 75°C. The lab is wrapped — go touch the hardware.

---

## 2026-06-30 — APK patch blocked, root is the path

### Events

- Pi rebooted, cooled to 56°C (from 85°C), throttle cleared
- Attempted APK patching: inject `network_security_config.xml` to trust user CAs — enable traffic capture on non-rooted Android WITHOUT rooting
- **BLOCKED**: aapt2 on ARM64 Debian rejects Bolt's auto-generated `$`-prefixed resource names. Resources compile but aapt2 exits code 1. ARM64 toolchain issue, not a Bolt bug. Would work on x86.
- Tried: fresh decompile (clean, 0 empty files), custom aapt2 wrapper (masked exit code but link phase failed), deleting `$`-prefixed files (names are inside XML, not standalone files)
- **Decision: root is the path.** APK patch can be done later on a Mac/PC if needed.

### Root prep status

| Item | Status |
|------|--------|
| Magisk v28.1 | ✅ Staged |
| frida-server 17.14.1 arm64 | ✅ Staged |
| AlwaysTrustUserCerts v1.3 | ✅ Staged |
| ASUS UnlockTool | ✅ Staged |
| `aapt` + `aapt2` | ✅ Installed (ARM64) |
| `zipalign` + `apksigner` | ✅ Installed |
| uber-apk-signer.jar | ✅ Backup signer staged |
| TWRP recovery image | ❌ Needs browser download (Mega.nz) |
| Stock firmware | ❌ Needs browser download (ASUS CDN) |
| `ROOT-PROCEDURE.md` | ✅ Written (10-step guide) |
| `PRE-ROOT-CHECKLIST.md` | ✅ Written |

### State

- Pi at 64°C, healthy
- All Bolt research intact (API map, capture plan, mock server)
- Android phone not currently connected (USB)
- **Next:** user downloads 2 files → validates plan → execute root
- **HARD RULE: NO ROOTING without explicit user validation**

### Root-prep downloads + integrity verification + doc reconciliation

> Continuation session (deepwork workflow, 2026-06-30). Goal: complete the two missing root-prep downloads + advance safe lab work. No rooting — staging/verification/docs only.

#### What advanced

**Staged root binaries verified authentic.** Re-downloaded canonical Magisk v28.1 (`8bfd3346…5691d`) and frida-server 17.14.1 `.xz` (`bf6f4969…92c97`) straight from GitHub; both are **byte-identical** to the staged copies. The extracted frida binary (`47bf8138…834d`) matches a fresh `xz -dc` re-extract. So of the four root-critical files, the two that have official checksummed sources are confirmed clean.

**TWRP CLI download hit a wall → document-only.** I wanted to fetch `twrp-3.2.3-0-Z01H-20181014.img` (the Oreo build — corrected from the stale `3.1.0-0` Nougat-unlock reference in the old docs) straight onto the Pi. Reverse-engineered AndroidFileHost's actual JS flow: gate `checks.otf.php {w:waitingtime}` → `mirrors.otf.php {submit,action:getdownloadmirrors,fid}`. Three blockers stacked up:
- AFH now **login-gates downloads** — `checks.otf.php` returns the login page (a free account is required now).
- `mirrors.otf.php` intermittently throws **Cloudflare 522** (origin unreachable).
- The community canonical host (**mega.nz**) is **network-unreachable from the Pi** (curl times out, 0 bytes); `megatools` isn't installed and wouldn't help if the network can't reach mega.

So TWRP is browser-only. Fetch path recorded in `INTEGRITY.md`: AFH with a free account (fid `17825722713688276838`, verify Android-bootimg magic + AFH re-upload MD5 `ade53c12…`), or the Mega folder from a machine that can reach it.

**Firmware is document-only too.** ASUS has delisted `UL-Z01H-WW-80.30.76.64` (`dlcdn.asus.com` doesn't even resolve); no checksums exist anywhere. The Pi doesn't need the 1.8 GB blob anyway — only the extracted ~30 MB `boot.img`. Documented: fetch on a trusted machine, `unzip … boot.img`, record its sha256, scp the boot.img over.

**New `lab/root-prep/INTEGRITY.md`** — a file-integrity ledger: verified sha256 of Magisk/frida, the community/unverifiable files, the two missing files with exact browser-fetch + verification commands, and a pre-root checklist.

**CAPTURE-PLAN accuracy pass.** The field playbook's pre-capture step still told you to hand-add `iptables -t nat -A …` and spin a transient `systemd-run --unit=rpi-net-mitmweb mitmweb`. But the rig now runs a **persistent `rpi-net-mitm.service`** (active + enabled, backed by `rpi-net-mitm.sh` idempotent `redirect-on/off`). The old manual approach would duplicate rules and conflict on :8080. Corrected it to `sudo systemctl start rpi-net-mitm` + `rpi-net-mitm status`, fixed the web-UI auth (`web_password=fishnet2026`, not a `?token=`), and made the HAR export path absolute. Same stale-commands banner added to the historical Campaign A section in CONTEXT-UPDATE.md.

**Doc reconciliation.** ROOT-PROCEDURE / PRE-ROOT-CHECKLIST / CONTEXT-UPDATE all carried the wrong TWRP version (3.1.0-0 Nougat) and an incomplete file inventory. Now consistent on 3.2.3-0 (Oreo), accurate 8-present/2-missing inventory, corrected sourcing, plus three new risk notes: Play Integrity/SafetyNet (HIGH — an unlocked bootloader may make Bolt refuse to run; pre-check on the locked device + stage a Universal SafetyNet/Play Integrity Fix module), frida integrity (MOD — re-extract from the verified .xz before root), and USB-cable/fastboot reliability (MOD — verify a stable `fastboot devices` before flashing).

#### State

| Item | Status |
|------|--------|
| Magisk v28.1 + frida 17.14.1 | ✅ verified authentic (canonical GitHub match) |
| `lab/root-prep/INTEGRITY.md` | ✅ written |
| CAPTURE-PLAN.md | ✅ corrected to persistent mitm service |
| TWRP 3.2.3-0 + firmware | ⬜ browser-only (AFH account / Mega / trusted-machine extract) |
| Universal SafetyNet Fix module | ⬜ new 3rd browser download to stage |
| Root execution | ⏳ gated on user validation + the 3 downloads |

#### Next

1. User fetches (browser): TWRP 3.2.3-0 (AFH w/ account, or Mega), firmware → extract boot.img, Universal SafetyNet/Play Integrity Fix module
2. On arrival: run the `INTEGRITY.md` verification commands
3. User validates the root plan
4. Execute root per `ROOT-PROCEDURE.md` → mitmproxy CA as system cert → first Android-side Bolt capture through the rig

**HARD RULE (unchanged): NO ROOTING without explicit user validation.**
