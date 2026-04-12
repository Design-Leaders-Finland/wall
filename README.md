# wall

> Write anonymous messages — max 160 characters, 5-minute lifetime, visible to everyone.

An anonymous public message board. No accounts, no identities, no history. Messages vanish within five minutes, leaving nothing behind.

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/7f5b282964644331adf2295a81254267)](https://app.codacy.com/gh/Design-Leaders-Finland/wall/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![Maintainability](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall/maintainability.svg)](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall)
[![Code Coverage](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall/coverage.svg)](https://qlty.sh/gh/Design-Leaders-Finland/projects/wall)
[![Netlify Status](https://api.netlify.com/api/v1/badges/ab129df3-0fb9-48fe-a8fa-d50464ecc2f5/deploy-status)](https://wall.designleaders.fi)

![Screenshot](docs/screenshot.png)

## Features

- **Anonymous posting** — No login, no account, no identity
- **160-character limit** — Short, focused messages only
- **5-minute message lifetime** — Messages auto-delete; nothing is permanent
- **Real-time updates** — See new messages as they arrive
- **Offline indicator** — Clear status when connection is unavailable
- **Cooldown timer** — Rate-limited posting to prevent spam

## Platform Support

| Platform | Minimum Version               | Status                 |
| -------- | ----------------------------- | ---------------------- |
| Android  | 13 (API 33)                   | ✓ Supported            |
| iOS      | 18.0                          | ✓ Supported            |
| macOS    | 15.0                          | ✓ Supported            |
| Windows  | 11                            | ✓ Supported            |
| Web      | Last 2 major browser versions | ✓ Supported (deployed) |

Live web app: **[wall.designleaders.fi](https://wall.designleaders.fi)**

## Getting Started

**Prerequisites:** Flutter 3.35.5 (Dart 3.9.2)
[Install Flutter](https://docs.flutter.dev/get-started/install) (includes Dart):
   - Follow the instructions for your operating system.
   - After installation, run `flutter doctor` in your terminal to check for any missing dependencies.

```sh
git clone https://github.com/Design-Leaders-Finland/wall.git
cd wall
flutter pub get
flutter run
```

A Supabase project is required for the backend. Copy the environment variables and configure Supabase credentials before running.

## Build

```sh
# Web
flutter build web --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS host required)
flutter build ios --release --no-codesign

# macOS
flutter build macos --release

# Windows
flutter build windows --release
```

## Test

```sh
# Run all tests with coverage
flutter test --coverage

# Generate HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
```

Tests mirror the `lib/` structure:

```
test/
  test_helpers.dart
  main_test.dart
  controllers/        — Auth, connection, message controller tests
  models/             — Message model tests
  services/           — Service unit tests (mocked)
  utils/              — Logger tests
  widgets/            — Widget tests
```

## CI/CD

| Workflow                | Trigger                      | Purpose                                                             |
| ----------------------- | ---------------------------- | ------------------------------------------------------------------- |
| `ci-cd.yml`             | Push/PR to `main`, `develop` | Format → Analyse → Test+Coverage → Build matrix → Deploy to Netlify |
| `release.yml`           | Tag `v*`                     | Builds all platforms, creates GitHub Release with artifacts         |
| `codeql.yml`            | Push to `main`, weekly       | CodeQL security scan                                                |
| `dependency-review.yml` | Pull requests                | Blocks PRs with known-vulnerable dependencies                       |
| `scorecards.yml`        | Push to `main`, weekly       | OpenSSF Scorecard supply-chain security                             |

API docs are auto-generated with `dart doc` and deployed to GitHub Pages on every push to `main`.

📚 [View API Documentation](https://design-leaders-finland.github.io/wall/api-docs/)

## Pricing & Privacy

- **Price:** 1 EUR (one-time purchase, no subscriptions)
- **Ads:** None
- **Tracking:** None — no analytics, no telemetry, no persistent user identity
- **Data:** Messages are public while they exist and deleted automatically after 5 minutes

## Architecture

```
lib/
  controllers/       — Auth, connection, message, and page-state controllers
  services/          — Supabase, auth, avatar, SSL, local storage services
  models/            — Message model
  widgets/           — All UI components
  utils/             — Logger, SSL debug helper
```

## License

[Apache 2.0](LICENSE) © Design Leaders Finland
