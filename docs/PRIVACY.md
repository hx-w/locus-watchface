# Locus Privacy Policy

Effective date: October 4, 2026

Locus is an independent Garmin watch face maintained at
[github.com/hx-w/locus-watchface](https://github.com/hx-w/locus-watchface).
It displays selected watch metrics and a locally stored trajectory. It has no developer-operated
server, account system, advertising, analytics, or network communication.

## Data used on your watch

Depending on your selected fields and available device data, Locus reads native Garmin
Complications for heart rate, recovery time, Body Battery,
steps, device battery, stress, Pulse Ox, respiration, running/cycling VO2 max, floors, and weekly
intensity minutes. These values are used to render your chosen watch-face fields and axes.

For monthly running and cycling totals, the UserProfile permission allows Locus to read the
start time, sport type, and distance of saved activities exposed on your watch. Activities
starting in the current local calendar month are summed in meters. Totals are cached in memory
for up to five minutes and refreshed when returning to the face; activity records are not
stored by Locus. Activities unavailable in the watch history cannot be included.

Locus stores up to 73 timestamped observations of the two selected axis values in the watch's
application storage. During active updates, observations outside the six-hour window are removed.
No athlete observations are collected in the AMOLED low-power or display-off path. Solar/MIP
watches retain the full chart and may collect observations during minute updates. Configuration
preferences, such as selected metrics, units, colors, and time format, are stored on the device
using Garmin application properties.

Locus does not read your name, email address, Garmin account credentials, GPS location,
or activity routes. It does not send your watch metrics or stored observations to the developer,
advertisers, analytics providers, or other third parties. Garmin's own devices and services are
subject to Garmin's separate privacy policies.

## Your choices

You can change or hide metrics in the watch-face settings. Changing either axis starts a new
trajectory at the next active update. Select another watch face or uninstall Locus to stop its
use of your device metrics. Use Garmin's device and application-management tools to manage local
application data.

If you contact us through GitHub, information you choose to include in an issue will be handled
by GitHub and may be public. Do not include private health data or account credentials in public
issues. Support messages are used to respond to your request and maintain the application.

## Changes and contact

This policy will be updated if Locus changes how it reads, stores, or transfers data.
For privacy questions, contact the maintainer through the project's
[issue tracker](https://github.com/hx-w/locus-watchface/issues).
