# DoodHisaab Technical Overview

This document gives a high-level engineering picture of the app.

## Stack

- Flutter
- Dart
- SQLite with `sqflite`
- Riverpod for state management
- Go Router for navigation
- Workmanager for scheduled backup work

## Main architecture ideas

### Offline-first

Core functionality is local-first and built around SQLite. Delivery, payment, reporting, backup, and export flows do not require internet.

### Write safety

The app favors immediate writes for critical operations instead of long unsaved sessions in memory.

- delivery entries save draft progress during the session
- payments save directly
- balance updates are kept fast with cached balance adjustment

### Session recovery

Delivery flow supports recovery of interrupted sessions by reading saved draft rows from the local database.

### Historical integrity

Price changes are stored as new rows in price history. Old deliveries keep their original stored price.

### Low-end device focus

The codebase includes multiple decisions aimed at older Android devices:

- custom numpad for key numeric flows
- visible chips instead of dropdown-heavy forms
- route and list performance optimizations
- avoidance of unsafe isolate usage with `sqflite`

## Major modules

### `lib/db`

Database schema and repositories for:

- customers
- deliveries
- payments
- price history
- expenses
- other income
- statements
- app settings

### `lib/screens`

User-facing flows such as:

- lock
- onboarding
- home
- delivery
- customers
- payments
- reports
- settings
- tutorial
- privacy

### `lib/services`

Supporting services such as:

- backup service
- CSV export service
- share service
- analytics service
- workmanager wiring

## Data outputs

### Backups

- database backups written to `Downloads/DoodHisaab/`

### CSV export

- single CSV with these sections:
  - deliveries
  - payments
  - expenses
  - other income

## Important project files

- `README.md`
- `DoodHisaab_DEV_CONTEXT.md`
- `DoodHisaab_UAT_Checklist.md`
- `pubspec.yaml`
- `lib/router/app_router.dart`
- `lib/db/db_provider.dart`

## Included artifact

The repository includes a downloadable APK in `releases/` so visitors can test the app without building from source.
