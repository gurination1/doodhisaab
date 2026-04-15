# DoodHisaab

DoodHisaab is an offline-first milk ledger app built in Flutter for dairy farmers and milk distributors. It records daily deliveries, customer balances, payments, expenses, other income, price changes, backups, and CSV exports in a simple mobile workflow designed for older Android phones and low-literacy users.

## What the app is for

This app is meant for real daily field use, not demo-only bookkeeping.

- Track milk deliveries customer by customer
- Store payment collections and running balances
- Set and preserve milk price history
- Record farm expenses and non-milk income
- View customer statements and monthly profit/loss
- Back up the database locally to `Downloads/DoodHisaab/`
- Export farm data to CSV for sharing or record keeping
- Work without internet for core operations

## Target users

- Dairy farmers
- Milk delivery operators
- Rural Punjabi and Urdu-speaking households
- Users on low-end Android devices
- Users who need large touch targets and simple flows

## Main functions

### 1. Lock and startup

- PIN lock support
- Splash / startup flow
- Onboarding for first-time setup
- Resume protection for interrupted delivery sessions

### 2. Home dashboard

- Start delivery
- Record payment
- Quick access to expenses
- Quick access to other income
- Quick access to milk price settings
- Quick access to backup
- Today summary widgets

### 3. Delivery workflow

- Customer-by-customer delivery entry
- Liters entered with a custom numpad
- Immediate draft save on confirm
- Session recovery after crash or forced close
- UPSERT behavior to prevent duplicate billing
- Final save-all flow for confirmed entries

### 4. Customer management

- Add customer
- Edit customer
- Search customers by name
- View customer profile
- Reorder delivery route
- Open payment flow from customer context
- Open customer statement/history

### 5. Payment workflow

- Record payment against a selected customer
- Pre-select a customer from profile or other screens
- Overpayment warning while still allowing advance payments
- Immediate balance update

### 6. Pricing

- Set milk price
- Keep full price history
- Preserve historical delivery prices
- Optional note when changing price
- Stale-price warning

### 7. Expenses and other income

- Expense entry with visible category chips
- Other income entry with visible category chips
- Custom numpad for amount entry
- Optional text notes
- Designed for quick entry on low-end devices

### 8. Reports

- Customer statements tab
- Per-customer balance view
- Statement detail page
- Monthly profit and loss tab
- Milk revenue visibility
- Other income visibility
- Expense visibility
- Cash collection visibility

### 9. Data safety and export

- Manual backup button
- Daily auto backup
- Backup retention limit
- CSV export by date range
- CSV includes deliveries, payments, expenses, and other income
- File sharing flow for exported data

### 10. Settings and help

- Language switcher
- Theme mode
- PIN set / change / remove
- Calculator
- Tutorial screen
- Privacy policy screen
- Data safety information

## Languages

- Urdu-first usage model
- Punjabi support
- English support
- Additional localization work is present in the repo

## Design goals

- Offline-first core flow
- Large text and touch targets
- Simple visible controls instead of hidden dropdown-heavy UX
- Safe writes for weak devices and interrupted sessions
- Budget-phone-friendly performance

## APK

This repo includes a recent working APK for easier testing and sharing.

- APK: [`releases/doodhisaab-update-20260412.apk`](releases/doodhisaab-update-20260412.apk)
- Checksums: [`releases/SHA256SUMS.txt`](releases/SHA256SUMS.txt)
- APK notes: [`releases/README.md`](releases/README.md)

## Screenshots

- Baseline app screenshot: [`docs/images/doodhisaab_baseline.png`](docs/images/doodhisaab_baseline.png)

## Documentation

- Full feature breakdown: [`docs/FEATURES.md`](docs/FEATURES.md)
- User flow overview: [`docs/USER_FLOW.md`](docs/USER_FLOW.md)
- Technical overview: [`docs/TECHNICAL_OVERVIEW.md`](docs/TECHNICAL_OVERVIEW.md)
- Development context: [`DoodHisaab_DEV_CONTEXT.md`](DoodHisaab_DEV_CONTEXT.md)
- UAT checklist: [`DoodHisaab_UAT_Checklist.md`](DoodHisaab_UAT_Checklist.md)

## Tech stack

- Flutter
- Dart
- SQLite via `sqflite`
- Riverpod
- Go Router
- Workmanager
- `share_plus`
- `url_launcher`

## Local development

Requirements:

- Flutter SDK
- Android SDK
- Android device or emulator

Run:

```bash
flutter pub get
flutter test
flutter run
```

Build release APK:

```bash
flutter build apk --release
```

## Project structure

```text
lib/
  core/
  db/
  l10n/
  models/
  providers/
  router/
  screens/
  services/
  theme/
  widgets/

test/
releases/
docs/
```

## Repository contents

- Flutter application source
- Included APK for direct download
- Product and testing docs
- Development context and architecture notes

## Status

This repository is set up to show both the source code and a ready-to-download APK so someone visiting GitHub can quickly understand what the app does and test it without building locally.
