# Development

## Toolchain

Use Python 3.10+, OpenSSL, and the official Connect IQ SDK. The project is developed with SDK
9.2.0 with current official device definitions and a minimum Connect IQ API level of 5.0.0.
Supported targets are listed in the manifest and README; build/test choices use the manifest.
No third-party Python packages are required.

Create a developer key once, keep it private, and retain it for future updates:

```sh
mkdir -p private
openssl genrsa -out private/developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in private/developer_key.pem -out private/developer_key.der -nocrypt
chmod 600 private/developer_key.der private/developer_key.pem
```

The build uses `private/developer_key.der` by default. Set `CIQ_SIGNING_KEY` to use an existing
DER key elsewhere. Keys, `private/`, and generated output must never be committed.

## Structure

- `source/`: application lifecycle, display-mode handling, and minute cache.
- `source/data/`: native Complications and monthly activity reads, field semantics, axis conversion, and bounded observations.
- `source/settings/`: typed properties and the watch configuration menu.
- `source/render/`: chart, trajectory topology, reusable drawing, licensed icons, and time-only AOD.
- `resources/` and `resources-zhs/`: icons, phone settings, and English / Simplified Chinese strings.
- `tests/`: native unit and render tests; `tests/preview/` contains simulator-only demo data.
- `scripts/`: the build and native-test entry points.
- `docs/images/`: a small set of actual simulator captures used by the README.

`Field1`–`Field6` and metric IDs 0–14 are stable. Raw recovery values are minutes and raw distances
are meters. Preserve the application UUID and observation storage key across updates. Rendering
must not read athlete data, storage, or the network. The view reads and caches data only while
active, and initializes history lazily.

## Verification

```sh
python3 scripts/test.py                     # All declared device profiles; simulator must be running
python3 scripts/test.py --device fr265       # One device
python3 scripts/build.py --device fr265 --release
python3 scripts/build.py --device fr265s --release
```

Current simulator captures: [FR265](images/fr265.png), [FR265 closed trace](images/fr265-loops.png),
and [FR265S closed trace](images/fr265s-loops.png). All show illustrative observations in the native renderer.

Tests exercise local calendar-month activity totals, sport filtering, invalid records, metric
conversions, missing and extreme data, field replacement, property reload,
display lifecycle on AMOLED and MIP, chart bounds, all six palettes, 73-point trajectories,
interpolating B-spline endpoints and continuity, activity gaps, stationary knots,
loop geometry, intersections, history expiry,
and the cold AOD path. The AOD luminance assertion is a conservative drawing envelope, not a
hardware power measurement. Test logs and reports stay under ignored `build/`.

`--preview` creates isolated data and settings, visibly marked DEMO. It never changes production
properties. Preview, test, and release modes cannot be combined. Compiler output is kept beneath `build/`; IDE caches in `bin/` are also ignored.

For Store submission, export a release `.iq` package using the official Monkey C project export
command and the same developer key. Include proper store assets and every declared device profile, then
follow Garmin's [submission workflow](https://developer.garmin.com/connect-iq/submit-an-app/).
A source push is separate from a Store release.
