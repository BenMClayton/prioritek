# Prioritek

A lightweight Flutter task board that ranks work using a transparent priority
score: `impact × 2 + urgency`. Tasks are sorted automatically so the most
important unfinished work stays at the top.

## Features

- add tasks with separate impact and urgency ratings;
- automatic Critical, High, Medium, and Low priority bands;
- live active, high-priority, and completed totals;
- mark work complete or remove it; and
- responsive Material 3 interface for desktop, web, and mobile.

## Run

Requirements: Flutter 3.19+ with Dart 3.3+.

```sh
cd prioritek
flutter pub get
flutter run
```

## Verification

```sh
cd prioritek
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Status

This is an interactive prioritisation prototype. Data is held in memory and
resets when the app closes; persistence, editing, and team collaboration are
future product work rather than implied as complete.
