# Dependency decisions for 1.0

Each major bump needs a run on a physical Android device for the flow it
touches (incoming share, folder picker, permissions, foreground service,
audio playback). No device was available while preparing 1.0, so the major
bumps below are deferred, not rejected. Revisit after 1.0 with a device.

| Package | Before | After | Reason |
|---|---|---|---|
| palette_generator | ^0.3.3+7 | removed | Discontinued. Replaced by `ColorScheme.fromImageProvider` from the Flutter SDK (`scheme.primary` as the dominant color). |
| just_audio | 0.9.46 | deferred (0.10.6 available) | 0.10 is a minor series bump with platform channel changes; playback needs a device check. |
| receive_sharing_intent | 1.8.1 | deferred (1.9.0 available) | Changes the share intent plumbing; needs a real share from another app. |
| file_picker | 10.3.10 | deferred (13.4.0 available) | Three majors ahead; the folder picker and the config import/export depend on it. |
| permission_handler | 12.0.1 | deferred (13.0.2 available) | Storage permission behavior differs per Android version, needs a device. |
| share_plus | 12.0.1 | deferred (13.3.1 available) | Share sheet flow needs a device. |
| open_file | 4.0.0 | unchanged | Already on the latest release. |
| flutter_foreground_task | 9.2.1 | deferred (11.0.3 available) | Two majors ahead; the download service must be re-tested on device. |

Patch level updates inside the current constraints (`flutter pub upgrade`)
are not part of this list.
