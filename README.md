# BareMetal — sensor foundation

A native iOS app that grabs the hardware as directly as public APIs
allow: raw motion streams, barometer, GPS/compass, microphone tap,
LiDAR scene depth, BLE scanning, and the device's own body state
(battery, thermal, proximity, brightness). Live console UI, no
smoothing theatre — what the sensor says is what the screen shows.

## Sensor inventory (free Apple ID signing)

| Feed | Framework | Notes |
|---|---|---|
| Accelerometer / gyro / magnetometer | CoreMotion | raw, 100 Hz / 100 Hz / 50 Hz |
| Attitude | CoreMotion device motion | fused, 60 Hz |
| Barometer / relative altitude | CMAltimeter | kPa + m |
| GPS / heading | CoreLocation | best-for-navigation accuracy |
| Microphone | AVAudioEngine tap | RMS + peak off the raw buffer |
| LiDAR depth | ARKit sceneDepth | sampled min/mean/max off the depth map (LiDAR devices) |
| Feature points / light | ARKit | rawFeaturePoints count, ambient intensity |
| Bluetooth LE | CoreBluetooth | scan all, name + RSSI |
| Battery / thermal / proximity / brightness | UIKit | 1 Hz poll |

Locked without the paid Developer Program entitlements: HealthKit,
NFC tag writing, Ultra Wideband (U1/U2) nearby interaction, push
notifications. Everything above works on a free account.

## Build — no Mac required

Push to `main`. The GitHub Actions workflow runs on a macOS runner,
generates the Xcode project (XcodeGen), builds unsigned, and publishes
`BareMetal.ipa` as a release. It then rewrites `apps.json` so the
source always points at the newest build.

Unsigned is deliberate: SideStore/AltStore re-sign with your free
personal certificate at install time.

## Install + easy updates (SideStore)

1. Install SideStore on the iPhone (one-time, from your PC).
2. In SideStore, add this repo's raw `apps.json` URL as a Source.
3. Install BareMetal from the source.
4. Every new build bumps the source — SideStore shows **Update**;
   tap it and the new version lands over the old, data intact.
5. The free certificate lasts 7 days; SideStore refreshes it in the
   background over your home network/Wi-Fi. Keep the PC's AltServer /
   SideStore refresh path alive per SideStore's own setup guide.

AltStore works the same way with the same `apps.json`.

## Alternative: build on the Windows PC

Install a macOS VM (VirtualBox/VMware) on the PC, Xcode inside it,
open the generated project, export an unsigned .ipa, host it next to
`apps.json` with `python -m http.server`, and add the PC's LAN address
as the source. Same update flow, nothing leaves the house.

## Layout

- `BareMetal/SensorBus.swift` — one bus, every feed, hardware timestamps
- `BareMetal/Sensors/*.swift` — one module per sense, start/stop pairs
- `BareMetal/ContentView.swift` — the live console
- `project.yml` — XcodeGen project definition (bundle id: com.marrow.baremetal)
