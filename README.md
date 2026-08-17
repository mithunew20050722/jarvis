# JARVIS (Flutter/Android)

A real installable Android app version of JARVIS, built with Flutter —
same build pattern as your working `unity-md-app` (Flutter + Gradle +
GitHub Actions), which is much more reliable than the earlier
buildozer/Kivy attempt.

## Why this approach instead of buildozer

The buildozer/Kivy version depended on Vosk having a python-for-android
build recipe, which isn't guaranteed to exist/work. Flutter + Gradle is
a mainstream, extremely well-supported toolchain — the same one your
`unity-md-app` already builds successfully with on GitHub Actions.

## How background listening works here

- `android/app/.../ListenerService.kt` — a native Android **foreground
  service** with a persistent notification. This is what keeps the app's
  process alive in the background (same requirement Google Assistant has
  to satisfy) so Android doesn't kill it.
- `lib/services/wake_word_service.dart` — runs on the Dart side, using
  the `speech_to_text` plugin (Android's native `SpeechRecognizer`) in a
  continuous loop, listening for "jarvis" and then routing whatever
  follows to `lib/brain/router.dart`.
- `BootReceiver.kt` — restarts the listener service after phone reboot.

## Build via GitHub Actions

1. Push this repo to GitHub.
2. Actions tab → "Build & Release JARVIS APK" → it also auto-runs on
   every push to `main`.
3. Once finished, download the APK from either the run's **Artifacts**,
   or the auto-created **Release** (tagged `vX.Y.Z` from `pubspec.yaml`).
4. Install the APK on your phone (enable "install from unknown sources"
   if prompted).

No keystore secrets required — this builds a debug-signed release APK,
which is fine for personal use. (Your `unity-md-app` workflow shows how
to add a proper release keystore later if you ever want to distribute
this more widely.)

## First-build things to double check

- The `gradle-wrapper.jar` binary isn't committed to this repo (binary
  files can't be authored directly) — the workflow generates it fresh
  via `gradle wrapper --gradle-version 8.3` using the Gradle already
  installed on GitHub's runners. If that step fails, that's the first
  thing to check in the log.
- `pubspec.yaml` dependency versions were chosen based on what's current
  and compatible as of writing — if `flutter pub get` reports a version
  conflict, that's normal package-ecosystem drift; paste the error and
  I'll adjust the version pins.
- Package names in `AppManagerService.appPackages` cover common apps —
  add more `'name': 'com.package.id'` entries as needed.

## Features included

- Wake-word background listening ("jarvis" + command, works with screen off)
- Open apps / go home
- Battery status, volume, brightness, vibrate
- Weather, jokes, advice
- WhatsApp message (opens app with message ready — user taps Send)
- Text-to-speech responses

## Not yet ported from the Termux version

Straightforward to add following the same `lib/services/*.dart` +
`lib/brain/router.dart` pattern: image generation, alarms/reminders,
flashlight toggle, web search. Say which ones you want next and I'll add
them.
