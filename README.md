# Locus

A Garmin watch face that turns your changing physiology into a six-hour phase portrait.
Built in Monkey C for the Forerunner 265 and 265S.

<p align="center">
  <img src="docs/images/fr265.png" width="300" alt="Locus on the FR265, simulator demo" />
  <img src="docs/images/fr265-loops.png" width="300" alt="Locus with closed trajectories and intersection markers, simulator demo" />
</p>

Warm ivory hours, golden minutes, and a flat coral heart keep the current moment in focus.
A fine trajectory fades from the accent color toward the current point, with sparse observation
marks, subtle closed-region fills, and highlighted intersections. Weekday and date sit above
the time; device battery sits at the bottom. Screenshots show **DEMO** fixtures, not athlete data.

## Configuration

Configure six positions from the watch's watch-face settings or the official phone settings:

| Position | Default |
| --- | --- |
| Current point and annotation | Heart rate |
| Horizontal axis | Recovery time |
| Vertical axis | Body Battery |
| Lower left | Weekly run distance |
| Lower center | Weekly bike distance |
| Lower right | Today's steps |

Each position supports hidden, heart rate, recovery, Body Battery, weekly run/bike distance,
steps, device battery, stress, Pulse Ox, respiration, running/cycling VO2 max, floors, and weekly
intensity minutes. Labels, units, and icons follow the selected metric. Axes adapt their range;
changing either axis starts a new trajectory. Heart size follows heart rate within fixed bounds.

Six accent colors, 12/24-hour time, km/mi, date visibility, and always-on time are configurable.
Unavailable data shows `--`. Training readiness and sleep are not offered without a supported
public API. The separate AMOLED low-power screen displays only time.

## Build and run

Install the official [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/), put
`monkeyc` and `monkeydo` on `PATH`, and use Python 3.10+ and a developer signing key.
See [development instructions](docs/DEVELOPMENT.md) for key setup and architecture.

```sh
python3 scripts/build.py --device fr265 --release
python3 scripts/build.py --device fr265s --release
```

Outputs go to `build/locus-<device>-live.prg`. To sideload, connect the matching watch in file
transfer mode, copy its PRG into `GARMIN/APPS/`, disconnect, and select **Locus** as the watch face.
This repository has not been published to the Connect IQ Store.

Start the official simulator before running the native suite:

```sh
python3 scripts/test.py
```

To inspect a deterministic simulator demo:

```sh
python3 scripts/build.py --preview
monkeydo build/locus-fr265-demo-normal.prg fr265
```

Add `--scenario loops`, `missing`, `extreme`, or `aod` to exercise the corresponding scene.
Run SDK builds and simulator sessions serially. Fixtures and native tests are excluded from
production builds; all generated output is ignored by Git.

## Data and limits

Data comes from Garmin's native Complications API; there is no network service or account.
Trajectory observations are stored locally, bounded to 73 samples over six hours. They are
collected during normal active updates, at most once every five minutes. Low-power mode does
not sample athlete data. Gaps longer than 15 minutes remain disconnected, so this is an observed
history rather than guaranteed continuous background monitoring.

The FR265 (416 px) and FR265S (360 px) are supported build targets. Native simulator tests and
screenshots do not establish physical-device compatibility or battery life; those checks remain
outstanding.

## License

Project code is [MIT licensed](LICENSE). Metric icons use official
[Tabler Icons](https://github.com/tabler/tabler-icons) paths, with their
[MIT license](resources/icons/tabler/LICENSE) and pinned
[provenance](resources/icons/tabler/provenance.json) included.
