# De'Longhi My Coffee Lounge (Daedalus) — Home Assistant Integration

Home Assistant custom integration for **modern De'Longhi machines** that ship the
**My Coffee Lounge** app (package `com.delonghigroup.daedalus`) — most notably
the **Eletta Ultra**.

> **Status: beta.** Monitoring works end to end — over the LAN socket and, since
> 0.4.0, through optional read-only cloud telemetry (~77 mapped shadow fields:
> state, alarms, profiles, counters, firmware versions). Brewing commands are
> still not decoded; help wanted via
> [issue #18 on the upstream repo](https://github.com/sk7n4k3d/delonghi-ha/issues/18).

This integration is the **Daedalus stack** counterpart to
[`delonghi-ha`](https://github.com/sk7n4k3d/delonghi-ha) (which targets the older
**Coffee Link / Ayla Networks** machines like the Eletta Explore). The two stacks
share *nothing* at the wire-protocol level, so they live in two separate
integrations / repos.

## Which one do I need?

| Your app | Use this integration |
|---|---|
| **Coffee Link** (older, Ayla cloud) | [`delonghi-ha`](https://github.com/sk7n4k3d/delonghi-ha) |
| **My Coffee Lounge** (newer, AWS IoT, BLE provisioning, Eletta Ultra) | **this repo** |

If your machine is on Coffee Link don't install this integration — install
the upstream `delonghi-ha` instead.

## Installation (HACS)

1. In HACS → **Integrations** → ⋮ → **Custom repositories**
2. Add `https://github.com/sk7n4k3d/delonghi-daedalus-ha` as **Integration**
3. Find **De'Longhi My Coffee Lounge (Daedalus)** in the list, install
4. Pick the latest release (stable versions ship since 0.4.0)
5. Restart Home Assistant
6. **Settings → Devices & Services → Add Integration → De'Longhi My Coffee Lounge**

## Configuration

You'll need:

- **My Coffee Lounge** account email + password
- **LAN IP** of the machine (look it up on your router or in the official app)
- **Serial number** printed on the machine (sticker on the side / underside)
- **Region** — the integration auto-probes EU / EU_US / CH on `403005` errors,
  so leave on EU unless you know your account was created in another pool

The password is **not** persisted — only the long-lived Gigya session token and
the JWT are stored on disk. Home Assistant's native reauth flow asks for the
password again on the rare occasion the session token is revoked.

## Security notes

- LAN connections use TLS with a self-signed certificate (the firmware presents
  one). The integration accepts the cert via `verify_mode=CERT_NONE` but **only**
  if the host you configure is a numeric IP in a private / loopback / link-local
  range. Public IPs and hostnames are rejected — auth credentials in the WebSocket
  AUTH frame would otherwise be MITM-able.
- All Gigya API keys hardcoded in `const.py` are extracted from the public APK
  manifest — equivalent to OAuth client IDs, not secrets.
- A diagnostics endpoint is wired so you can attach a `Download diagnostics` zip
  to GitHub issues without leaking your JWT, session token, email, or serial
  number — those are scrubbed in the payload.

## What works today

- ✅ Gigya login + JWT retrieval (auto-probe across pools)
- ✅ LAN WebSocket handshake (`/ws/lan2lan`) with AUTH frame
- ✅ HA reauth flow + diagnostics (JWT / session token / email / serial scrubbed)
- ✅ Connection-state binary sensor + LAN ID / SN / IP diagnostic sensors
- ✅ **Cloud telemetry (opt-in, read-only)** since 0.4.0: AWS IoT device shadows
  (`MachineStatus`, `MachineCapabilities`) over MQTT 5, ~77 mapped fields as
  sensors/binary sensors (state, alarms, user profiles, coffee temperatures,
  grinder/hopper, firmware versions), EN+FR labels, example Lovelace card
  upstream at `docs/daedalus-cloud-card.yaml`. Works even when the machine is
  off the LAN; never exposes `BlePassCode` / `MAC` / `SN`.

## Verified models

| Machine | Model id | Monitoring | Commands | Tested with |
|---|---|---|---|---|
| Eletta Ultra | — | ✅ | ❌ (not decoded yet) | maintainer |
| PrimaDonna Aromatic | ECAM63070 | ✅ (45 sensors + 40 binary sensors, LAN handshake, state matches) | not tested | Daedalus 0.4.7, HA Core 2026.11.1, EU owner account — thanks @numanx11 ([#55](https://github.com/sk7n4k3d/delonghi-ha/issues/55)) |

Known quirk: on some machines the `Languages` sensor value exceeds Home
Assistant's 255-character state limit. Cosmetic only; a truncation fix is
planned.

## What does NOT work yet

- ❌ Brewing commands (need an MITM trace of the official app to decode the
  `Message` catalog — help wanted, see upstream issue #18)
- ❌ Cloud `/devices` auto-discovery (the serial + IP are entered manually;
  the cloud directory is only used internally to resolve the shadow thing name)

## Source of truth

The integration code lives in the upstream
[`delonghi-ha` monorepo](https://github.com/sk7n4k3d/delonghi-ha) under
`custom_components/delonghi_daedalus/`. This repo is **a packaging mirror** for
HACS distribution — releases here are cut from the upstream `master` branch.

Open issues, PRs, and contribute on the upstream repo.

## License

Same as upstream `delonghi-ha`. Reverse-engineering for personal HA
interoperability with hardware you own.
