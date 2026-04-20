# Shopping App

Flutter business management app for inventory, customers, sales, expenses, finance reporting, and optional Supabase sync.

## Stack

- Flutter + Riverpod
- Hive for local persistence
- Supabase for online auth and cloud sync
- Android Studio SDK/JBR for Android builds

## Current Architecture

- `lib/models`: app entities and serialization
- `lib/repositories`: local-first persistence and sync behavior
- `lib/providers`: Riverpod state wiring
- `lib/services`: app configuration, auth/session, finance calculations, sync, maintenance
- `lib/screens`: UI flows

## Environment Configuration

This app no longer bundles `.env` inside the application.

Provide Supabase configuration with `--dart-define` when running or building:

```powershell
flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

For desktop development, you can also set user environment variables:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

If these values are missing, the app still starts in local/offline mode, but:

- online sign-up is disabled
- cloud sync is disabled
- connection checks against Supabase will fail with a clear config message

## Getting Started

1. Install Flutter SDK and Android Studio.
2. Make sure Android Studio SDK, platform tools, build tools, and NDK are installed.
3. Run:

```powershell
flutter pub get
flutter doctor
```

4. Start an emulator from Android Studio or connect an Android device.
5. Run the app:

```powershell
flutter run
```

## Android Build

Debug APK:

```powershell
flutter build apk --debug
```

Release APK:

```powershell
flutter build apk --release
```

Current Android build assumptions:

- Java 17 from Android Studio JBR
- Android Gradle plugin compatible with the installed Flutter SDK
- NDK pinned in `android/app/build.gradle`

## Session Model

The app now distinguishes between:

- `online` session: authenticated with Supabase
- `offline` session: authenticated from locally cached credentials
- `guest` session: local-only development mode

This avoids relying on a nullable Supabase session to determine whether the app should unlock.

## Finance Model

Finance calculations live in `lib/services/financial_stats_service.dart`.

This keeps business rules out of the Riverpod provider layer and makes them unit-testable.

Important note:

- inventory capital is currently valued from `purchasePrice * stockQuantity`
- this is intentionally more conservative than resale-value-based reporting

## Tests

Run all tests:

```powershell
flutter test
```

Added coverage focuses on:

- finance calculations
- session timeout policy
- sync record ID resolution

## Known Gaps

- release signing is still using debug signing in Android config and should be replaced before store deployment
- some older UI files still have analyzer warnings and deprecated API usage
- sync conflict handling is improved for ID mapping, but deeper field-level conflict resolution is still basic
