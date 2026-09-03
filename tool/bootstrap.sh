#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  echo 'Flutter SDK is required.' >&2
  exit 1
fi

# Generate missing platform folders without overwriting lib/pubspec.
flutter create . --platforms=android --project-name alhakim_accounting
flutter pub get

echo 'Project bootstrapped successfully.'
echo 'Run: flutter run'
echo 'Release APK: flutter build apk --release'
