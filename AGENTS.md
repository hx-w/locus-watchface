# Locus

Independent Garmin watch-face project. Keep changes in this repository and maintain `main` as
the sole branch. The current coordinate-and-trajectory watch face is the only implementation.

- Build with `python3 scripts/build.py`; verify with `python3 scripts/test.py` while the official
  Connect IQ simulator is running. SDK builds and simulator sessions must run serially.
- `source/data/` owns native Complications and field semantics; `source/settings/` owns typed
  properties and phone/watch configuration; `source/render/` owns drawing. App/view own lifecycle
  and caching. Never read athlete data, storage, or the network from rendering.
- Preserve the app UUID, `Field1`–`Field6`, metric IDs, and observation storage key across updates.
  Missing data is `--`, raw recovery is minutes, and raw distance is meters. Do not add calories
  or fabricate unsupported sleep/readiness values.
- Field changes update label, unit, and icon together. Battery marks mean body/device battery;
  heart marks mean heart rate; hourglass marks mean recovery.
- AMOLED has a separate time-only low-power path. Respect DISPLAY_MODE_OFF and LOW_POWER.
  Do not load vector fonts or read athlete/history data in AOD. MIP retains the full chart
  on minute updates; guard AMOLED-only APIs by capability.
- `build/`, `bin/`, `private/`, keys, and tokens are excluded from Git. Fixtures live under tests,
  visibly say DEMO, and are isolated from production. Release builds exclude tests and previews.
- Retain icon provenance and upstream licenses. Keep documentation captures few and current;
  do not commit generated PRGs, logs, caches, design archives, or deployment receipts.
- Native tests and simulator captures are separate from physical-device and battery-life
  acceptance. Report those surfaces separately.
