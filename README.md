# Android Toolset Utility App (Flutter)

Scaffolded project for a production-grade Android utility toolbox built with Flutter and Kotlin platform channels.

## Quick Start

- Flutter: 3.29+ (Dart 3.7+)
- Platforms: Android only

```bash
flutter pub get
flutter run
```

## Modules

- Files, Cleanup, Process Insights, Battery, Settings
- Riverpod for state, go_router for navigation
- AdMob via `google_mobile_ads` with UMP consent (platform channel)

## Notes

- Platform channel stubs are wired in `MainActivity.kt`.
- INTERNET permission declared; feature permissions to be added per module.
- See `privacy-policy.md` for GDPR and ads disclosure.

