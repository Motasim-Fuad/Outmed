# Release notes

## Environments

```bash
flutter run
flutter run --dart-define=APP_ENV=dev
flutter run --dart-define=APP_ENV=dev --dart-define=API_BASE_URL=https://your-host
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
flutter run --dart-define=FIREBASE_ENABLED=true
```

`flutter run` uses the API (`APP_ENV=dev`). Pass `--dart-define=APP_ENV=mock` for the local catalog and any non-empty login. The Stripe secret key is never a dart-define.

## Firebase (later)

1. Create an Android app and an iOS app in the Firebase console.
2. Download `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`.
3. Run with `--dart-define=FIREBASE_ENABLED=true`. Crashlytics, Analytics, Performance, Remote Config, and Messaging initialize from `firebase_bootstrap.dart`.

## Stores

Ship with a staged rollout: internal testing, then a small production percentage, then 100%. Keep the mock flavor for screenshots. Production builds must set `APP_ENV=dev` (or a later `prod` value) and a real API host. Do not commit keystores, `google-services` files, or Stripe secrets.
