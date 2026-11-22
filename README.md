# De'Longhi My Coffee Lounge (Daedalus) — Home Assistant Integration

Home Assistant custom integration for **modern De'Longhi machines** that ship the
**My Coffee Lounge** app (package `com.delonghigroup.daedalus`), including the
**Eletta Ultra** and **PrimaDonna Aromatic**.

> **Status: beta.** Monitor the machine over the local network or with optional
> read-only cloud telemetry.

This README describes the Daedalus **0.5.2** source tree. Check the
[latest published release](https://github.com/sk7n4k3d/delonghi-daedalus-ha/releases/latest)
for the available version. See the [tagged v0.4.7 README](https://github.com/sk7n4k3d/delonghi-daedalus-ha/blob/v0.4.7/README.md)
for that release's setup and limitations.

This integration is the **Daedalus stack** counterpart to
[`delonghi-ha`](https://github.com/sk7n4k3d/delonghi-ha) (which targets the older
**Coffee Link / Ayla Networks** machines like the Eletta Explore).

## Which one do I need?

| Your app | Use this integration |
|---|---|
| **Coffee Link** (older, Ayla cloud) | [`delonghi-ha`](https://github.com/sk7n4k3d/delonghi-ha) |
| **My Coffee Lounge** (newer, AWS IoT, Eletta Ultra and PrimaDonna Aromatic) | **this repository** |

## Installation

The integration requires **Home Assistant 2024.11.0 or later**.

### HACS — recommended

This integration is listed in HACS' **default** repository, so there is no custom
repository to add:

1. In HACS → **Integrations** → **Explore & add repositories**.
2. Search for **De'Longhi My Coffee Lounge (Daedalus)** and download it.
3. Restart Home Assistant, then go to **Settings → Devices & Services → Add
   Integration** and select **De'Longhi My Coffee Lounge**.

### Home Assistant 2026.11 and later

1. Go to **Settings → Marketplace → Add from link**.
2. Add `https://github.com/sk7n4k3d/delonghi-daedalus-ha`. Connect a GitHub account if Marketplace prompts you to do so.
3. Open **De'Longhi My Coffee Lounge (Daedalus)** and install the latest stable release.
4. Open setup from Marketplace. Restart Home Assistant after an upgrade.

### Home Assistant 2024.11 through 2026.10 — custom repository (fallback)

Only needed if the integration does not show up in **Explore & add repositories**
yet (newly listed repositories can take a few hours to propagate).

1. In HACS → **Integrations** → ⋮ → **Custom repositories**
2. Add `https://github.com/sk7n4k3d/delonghi-daedalus-ha` as an **Integration** custom repository.
3. Download the latest stable release of **De'Longhi My Coffee Lounge (Daedalus)**.
4. Restart Home Assistant.
5. Go to **Settings → Devices & Services → Add Integration** and select **De'Longhi My Coffee Lounge**.

If you install manually, download `delonghi_daedalus.zip` from the [mirror releases](https://github.com/sk7n4k3d/delonghi-daedalus-ha/releases). Extract it into `custom_components/delonghi_daedalus` so that `manifest.json` is directly inside that folder. On a manual upgrade, replace that component folder with a clean extraction and restart Home Assistant.

## Configuration

1. Sign in with your **My Coffee Lounge** account and choose your machine from
   the account's device directory. If discovery is unavailable, the setup flow
   offers manual serial number entry.
2. Confirm the machine's LAN address and approve its certificate on a network
   you trust. Enable cloud telemetry to monitor the machine without local access.

Follow the [upstream setup guide](https://github.com/sk7n4k3d/delonghi-ha/blob/master/docs/daedalus-setup.md)
for certificate verification, reconfiguration and interpreting availability.

### Brewing statistics

Enable **Read-only cloud telemetry** to see lifetime brewing counters on
compatible machines. Daedalus 0.5.2 also exposes these statistics when the
machine reports them.

- **Time of day.** Enable **Reported brewing time buckets** among the disabled
  diagnostics on the device page. The sensor's state is the number of intervals
  available, and its attributes give the brew count for each reported interval.
  [Brewing hours dashboard guide](https://github.com/sk7n4k3d/delonghi-ha/blob/master/docs/daedalus-brewing-hours.md)
- **By drink and temperature.** Enable the individual recipe counters you want
  on the device page. Mapped recipes show their names on recognized models, and
  other recipes show their IDs. **Hot brew count** and **Cold brew count** are
  enabled by default when reported.
  [Drink statistics dashboard guide](https://github.com/sk7n4k3d/delonghi-ha/blob/master/docs/daedalus-drink-statistics.md)

### Upgrading from 0.4.7

Restart Home Assistant after the upgrade. Open the integration entry's menu and
select **Reconfigure** to approve the machine's LAN certificate. Cloud telemetry,
if enabled, can continue while certificate approval is pending. Retained
entities keep their IDs and customizations. If an automation or dashboard used
the obsolete cloud LAN address sensor, update it to use the **LAN IP address**
diagnostic entity.

## Controls and limitations

Beverage preparation remains unavailable in Daedalus. The separate opt-in
**Warm up** action was verified on specific EU PrimaDonna Aromatic ECAM63070
firmware. In 0.5.0, long **Languages** lists fit Home Assistant's 255-character
state limit. The full list remains available in the sensor's attributes.

## Privacy

Setup uses your email and password to sign in with De'Longhi's account service.
Home Assistant stores the account email, session credentials and machine
identifiers in the config entry. The password is used at sign-in and requested
again if reauthentication is needed. Optional cloud telemetry reads operating
state, alarms and capabilities from De'Longhi's AWS IoT service.

Home Assistant pins the certificate you approve and checks it before sending
account credentials to the machine over the LAN. Integration diagnostics redact
account credentials and machine identifiers. Review downloaded diagnostics
before sharing them publicly.

## Verified models

| Machine | Verified behavior |
|---|---|
| Eletta Ultra | Monitoring |
| PrimaDonna Aromatic ECAM63070 | [Monitoring](https://github.com/sk7n4k3d/delonghi-ha/issues/55) and [opt-in warm-up for the verified EU firmware](https://github.com/sk7n4k3d/delonghi-ha/pull/59) |

## Source of truth

The integration code lives in the upstream
[`delonghi-ha` monorepo](https://github.com/sk7n4k3d/delonghi-ha) under
`custom_components/delonghi_daedalus/`. This repo is **a packaging mirror** for
HACS distribution. See the [mirror release process](docs/releasing.md).

Report bugs and request features in the [upstream issue tracker](https://github.com/sk7n4k3d/delonghi-ha/issues).
Submit code changes as [upstream pull requests](https://github.com/sk7n4k3d/delonghi-ha/pulls).

## License

[MIT](LICENSE), including the upstream attribution for the Aromatic warm-up
protocol reference.
