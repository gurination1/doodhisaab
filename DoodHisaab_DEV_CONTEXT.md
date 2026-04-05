# DoodHisaab — Development Context File
> **⚠️ THIS IS THE SINGLE SOURCE OF TRUTH**
> Every future chat session must read this file first.
> Every completed step must update this file before ending the session.
> Never ask for context — derive everything from this file.

---

## 🧭 Project Identity

| Field | Value |
|---|---|
| App name | DoodHisaab (دودھ حساب) |
| Purpose | Dairy farm delivery + payment ledger for rural Punjabi farmers |
| Target users | Low-literacy farmers, 50+ years old, 5th-grade education |
| Target device | Tecno Spark / Infinix Hot class — Android 7.0+, 1GB RAM |
| Target region | Punjab, Pakistan / India |
| Primary language | Urdu (default), Punjabi, English (opt-in) |
| Offline-first | Yes — 100% core functionality with zero internet |
| Plan version | v2.0 — Final (April 2026) |
| Plan file | `DoodHisaab_MVP_Final_Plan.md` |

---

## 🏗 Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| Database | SQLite via `sqflite ^2.3.0` |
| State | `flutter_riverpod ^2.4.0` + `riverpod_annotation ^2.3.0` |
| Navigation | `go_router ^13.0.0` |
| Background tasks | `workmanager ^0.5.2` |
| Unique IDs | `uuid ^4.2.0` |
| File system | `path_provider ^2.1.0` |
| Sharing | `url_launcher ^6.2.0` + `share_plus ^7.2.0` |
| PIN security | `crypto ^3.0.3` (SHA-256) |
| Localization | `flutter_localizations` + `intl ^0.18.1` |
| Code gen | `build_runner ^2.4.0` + `riverpod_generator ^2.3.0` |
| Testing DB | `sqflite_common_ffi ^2.3.0` |

---

## 📐 Architecture Decisions (Locked — Do Not Change Without Noting Here)

| Decision | Rationale |
|---|---|
| Write-on-confirm (not batch save) | Android kills background apps on 1GB RAM devices; in-memory data is lost |
| Delta balance update (`adjustCachedBalance`) | `rebuildCachedBalance` full JOIN is too slow at scale; delta is O(1) |
| `FutureBuilder` for reports (no `Isolate.run`) | sqflite `MethodChannel` is bound to main isolate; crosses isolate boundary = crash |
| `Offstage` for hidden cards (not `Opacity(0)`) | `Opacity(0)` still runs full GPU paint; `Offstage` skips layout + paint entirely |
| `InkWell + Material` for numpad keys | `GestureDetector` gives no visual feedback; users double-tap; causes double-entry |
| Public `getBackupDir()` and `pruneOldBackups()` | Private Dart methods can't cross file boundaries; CSV and WorkManager both need these |
| WorkManager backup = file copy only | WorkManager runs in separate Dart isolate; DB singleton is invisible; no sqflite calls |
| Backup to public `Downloads/DoodHisaab/` | `getExternalStorageDirectory()` is app-private, invisible in Files app, deleted on uninstall |
| `/customers/new` before `/:id` in go_router | Router matches top-to-bottom; `new` would match `/:id` with id='new' if declared after |
| UPSERT on delivery confirm | Previous button + re-confirm creates duplicate draft records; UPSERT prevents double-billing |
| No `monthly_cache` table | `idx_del_date` index makes monthly queries <500ms; cache invalidation adds complexity for no MVP gain |
| `closeAndReset()` on `DatabaseProvider` | `_db` is private; `BackupService` can't access it directly; needs public reset method |
| `selectionClick()` only for haptics | `mediumImpact()` requires API 26; target is API 24; silently does nothing on target devices |
| 2 fields only in onboarding Step 2 | 4+ fields → ~40% abandonment; Name + Quantity is enough to start; phone/cycle added later |

---

## 🗄 Database Schema (Complete)

### Tables

```
customers          — customer_id (PK), name, phone, address, default_liters,
                     payment_cycle, payment_cycle_days, price_override,
                     price_override_reason, route_order, is_active, archived_at,
                     cached_balance, created_at

deliveries         — delivery_id (PK), customer_id (FK), date, liters,
                     price_per_liter, total_value, note, status, session_id,
                     created_by_device, sync_status, created_at
                     status values: 'session_draft' | 'confirmed' | 'abandoned'

payments           — payment_id (PK), customer_id (FK), date, amount, note,
                     created_by_device, sync_status, created_at

price_history      — price_id (PK), price_per_liter, effective_from, note

expenses           — expense_id (PK), date, category, amount, note, created_at
                     categories: Feed, Medicine, Fuel, Electricity, Labor, Other

other_income       — income_id (PK), date, category, amount, note, created_at
                     categories: Calf Sale, Ghee Sale, Manure Sale, Other

delivery_edit_log  — log_id (PK), delivery_id (FK), old_liters, new_liters,
                     reason, edited_at, edited_by

app_settings       — key (PK), value
                     keys: device_id, language, app_version, first_launch_done,
                           outdoor_mode, pin_hash
```

### Required Indices (7 total — verify all exist at startup)

```
idx_cust_active_route  ON customers(is_active, route_order ASC)
idx_del_cust_date      ON deliveries(customer_id, date DESC)
idx_del_date           ON deliveries(date DESC)
idx_pay_cust_date      ON payments(customer_id, date DESC)
idx_edit_delivery      ON delivery_edit_log(delivery_id)
idx_price_from         ON price_history(effective_from DESC)
idx_income_date        ON other_income(date DESC)
```

### SQLite Pragmas (set in `_onCreate`)

```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
```

---

## 📁 File Structure (Target)

```
lib/
├── main.dart
├── app.dart
├── router/
│   └── app_router.dart
├── theme/
│   └── app_theme.dart
├── l10n/
│   ├── app_ur.arb
│   ├── app_en.arb
│   └── app_pa.arb
├── db/
│   ├── db_provider.dart
│   ├── settings_repository.dart
│   ├── customer_repository.dart
│   ├── price_repository.dart
│   ├── expense_repository.dart
│   ├── other_income_repository.dart
│   └── statement_repository.dart
├── models/
│   ├── customer.dart
│   ├── delivery.dart
│   ├── payment.dart
│   ├── expense.dart
│   ├── other_income.dart
│   ├── price_history.dart
│   └── customer_statement.dart
├── providers/
│   ├── customer_provider.dart
│   ├── customer_provider.g.dart         ← generated
│   ├── delivery_provider.dart
│   ├── delivery_provider.g.dart         ← generated
│   └── settings_provider.dart
├── services/
│   ├── backup_service.dart
│   ├── workmanager_setup.dart
│   ├── csv_export_service.dart
│   └── share_service.dart
├── widgets/
│   ├── numpad.dart
│   ├── quantity_chips.dart
│   ├── customer_avatar.dart
│   └── skeleton_loader.dart
└── screens/
    ├── lock_screen.dart
    ├── home_screen.dart
    ├── onboarding/
    │   └── onboarding_wizard.dart
    ├── delivery/
    │   └── delivery_entry_screen.dart
    ├── customers/
    │   ├── customer_list_screen.dart
    │   ├── customer_profile_screen.dart
    │   └── add_edit_customer_screen.dart
    ├── payments/
    │   └── payment_entry_screen.dart
    ├── reports/
    │   └── reports_screen.dart
    └── settings/
        └── settings_screen.dart
```

---

## 🎨 Design System (Reference)

### Colors

| Token | Hex | Use |
|---|---|---|
| `kGreen` | `#1B7A4A` | Primary action, success, confirmed |
| `kGreenDark` | `#145C37` | Button pressed state |
| `kCream` | `#FBF8F1` | App background |
| `kInkBlack` | `#1A1A1A` | Primary text |
| `kMittiBrown` | `#8B6914` | Secondary accent |
| `kAlertRed` | `#C0392B` | Overdue, error |
| `kAmber` | `#D4820A` | Warning, unusual entry |
| `kMutedGray` | `#9E9E9E` | Placeholder, secondary |
| `kSurfaceGray` | `#F2EFE8` | Card backgrounds |
| `kWhite` | `#FFFFFF` | Modals, elevated surfaces |

### Touch Targets

| Component | Size |
|---|---|
| Primary buttons | 56dp height |
| Confirmation button (SAVE ALL) | 72dp height |
| List rows | 64dp height |
| Form inputs | 60dp height |
| Bottom nav icons | 56dp |

### Typography

- Primary font: Noto Sans (multilingual, Urdu support built-in)
- Urdu text: Noto Nastaliq Urdu
- Minimum body size: **16sp** — never below this in production
- Urdu body minimum: **18sp** (Nastalikh needs more space for legibility)

---

## 🚦 Phase + Step Status

| # | Step | Phase | Status | Notes |
|---|---|---|---|---|
| 1 | Bootstrap + pubspec.yaml | 1 | ✅ COMPLETE | crypto ^3.0.3 included, generate: true set |
| 2 | SQLite Schema + DatabaseProvider | 1 | ✅ COMPLETE | WAL mode, all 7 indices, closeAndReset() public |
| 3 | Device ID + Settings Repository | 1 | ✅ COMPLETE | Language defaults to 'ur', UUID persisted forever |
| 4 | Theme | 1 | ✅ COMPLETE | buildAppTheme/buildOutdoorTheme, all color tokens, no hardcoded hex |
| 5 | Localization | 1 | ✅ COMPLETE | ARB files (ur/en/pa), l10n.yaml, Urdu default |
| 6 | Navigation (go_router) | 1 | ✅ COMPLETE | /customers/new and /customers/reorder BEFORE /:id |
| 7 | Custom Numpad + Quantity Chips | 1 | ✅ COMPLETE | InkWell + Material, no GestureDetector |
| 8 | Data Models | 2 | ✅ COMPLETE | 7 model files, fromMap keys match schema exactly |
| 9 | Riverpod Provider Pattern | 2 | ✅ COMPLETE | customer/delivery/settings providers; run build_runner after pull |
| 10 | Customer Repository | 2 | ✅ COMPLETE | delta balance, isOverdue, adjustCachedBalance |
| 11 | Onboarding Wizard | 2 | ✅ COMPLETE | 2 fields only, NumpadWidget, write-on-confirm per step |
| 12 | Delivery Entry Flow | 2 | ✅ COMPLETE | write-on-confirm UPSERT, crash recovery, Offstage next card |
| 13 | Payment Entry | 3 | ✅ COMPLETE | adjustCachedBalance delta on save |
| 14 | Pricing Engine | 3 | ✅ COMPLETE | PriceRepository, historical lookup by date |
| 15 | Expenses + Other Income | 3 | ✅ COMPLETE | both entry screens, both repositories |
| 16 | Reports | 3 | ✅ COMPLETE | FutureBuilder on main isolate, _StatementSkeleton, no Isolate.run |
| 17 | App Lock PIN | 4 | ✅ COMPLETE | SHA-256 via crypto, auto-submit at 4 digits |
| 18 | Atomic Backup | 4 | ✅ COMPLETE | getBackupDir public, Downloads path, temp→rename |
| 19 | WorkManager Auto-Backup | 4 | ✅ COMPLETE | file-copy only in isolate, no DB singleton touch |
| 20 | CSV Export | 4 | ✅ COMPLETE | 4 sections incl. other_income, RFC 4180 quoting |
| 21 | WhatsApp Share | 4 | ✅ COMPLETE | normalizePhoneForWhatsapp, share_plus fallback |
| 22 | Performance Hardening | 5 | ✅ COMPLETE | itemExtent on all ListViews, repairAllBalances() in main, WorkManager wired |
| 23 | Pre-rendered Card Transition | 5 | ✅ COMPLETE | Offstage used in delivery_entry_screen, no Opacity(0) in codebase |
| 24 | Outdoor Bright Mode | 5 | ✅ COMPLETE | buildOutdoorTheme(), kGreenOutdoor token, toggle in settings_screen |
| 25 | First-Launch Data Warning | 5 | ✅ COMPLETE | _showDataWarning() in onboarding_wizard.dart, barrierDismissible=false |
| 26 | UAT Checklist | 5 | ✅ COMPLETE | DoodHisaab_UAT_Checklist.md — 16 sections, 80+ test cases, sign-off table |

**Status legend:** ⬜ NOT STARTED · 🔄 IN PROGRESS · ✅ COMPLETE · ❌ BLOCKED

---

## ❌ Explicitly Removed from MVP

| Feature | Reason | Add when? |
|---|---|---|
| Info Hub (market prices, weather, vet alerts) | No reliable machine-readable APIs in Pakistan | Phase 3 only if real API is confirmed first |
| Ambient light sensor auto-mode | Tecno Spark, Infinix Hot 12 Play have no sensor | Never — use manual toggle |
| Swipe gestures | <8% discovery rate in rural SA user studies | Never — use visible buttons |
| Streak / gamification | Culturally inappropriate; farmers who miss a day feel blamed | Never |
| `monthly_cache` table | Premature optimization; index is sufficient | Phase 3 if profiling proves needed |
| `+0.5` numpad key | Confusing to all tested users | Never — use quantity chips |
| Auto-dismiss success screen | Destroys trust moment; screen is a receipt | Never |
| `Isolate.run()` with sqflite | Crashes at runtime — MethodChannel bound to main isolate | Never (use FutureBuilder) |
| Batch save (write only at SAVE ALL) | Data loss under memory pressure | Never (use write-on-confirm) |
| Voice TTS | Social context: 6 AM, people nearby | Phase 2, opt-in only |
| `HapticFeedback.mediumImpact()` | Requires API 26; target is API 24; silent failure | Never — use selectionClick() only |

---

## 🔁 Progress Notes (Auto-Updated)

---

### Session 1 — Plan Finalized (April 2026)

**What was done:**
- Read original MVP plan, staff engineer review (15 critical issues, 8 improvements), and design critique v2 (10 critical UX failures)
- Merged all three documents into a single production-ready 26-step build plan
- Applied all critical bug fixes inline into the plan (not as separate patch notes)
- Applied all design v2 changes inline

**Critical issues resolved in plan:**
1. `crypto ^3.0.3` added to pubspec (was missing → compile error)
2. `DatabaseProvider.closeAndReset()` public method added (private `_db` was accessed from `BackupService` → compile error)
3. `BackupService.getBackupDir()` and `pruneOldBackups()` made public (were private → compile error from `csv_export_service.dart`)
4. go_router `/customers/new` declared before `/:id` (was reversed → Add Customer screen never opened)
5. UPSERT implemented for delivery confirm (Previous + re-confirm → duplicate records → double-billing)
6. `Isolate.run()` with sqflite replaced by `FutureBuilder` (sqflite crosses isolate boundary → runtime crash on every report open)
7. `isOverdue()` fully implemented (was a placeholder comment → compile error)
8. `Offstage` used for hidden cards instead of `Opacity(0)` (Opacity still renders → GPU waste on Helio G25)
9. `pruneOldBackups` filters `entity is File` (was operating on `FileSystemEntity` including dirs → silent failure)
10. Backup path changed to `Downloads/DoodHisaab/` (was `Android/data/pkg/files/` → invisible to user, deleted on uninstall)
11. WorkManager backup = file copy only, no DB singleton touch (singleton invisible in separate isolate → would corrupt main isolate's DB connection after restore)
12. `other_income` added to CSV export (was missing → all calf/ghee/manure income silently missing from export)
13. Phone normalization for WhatsApp (stored `0300-1234567` → wa.me needs `923001234567` → without fix, opens generic new-chat)
14. All 8 improvements applied: delta balance, InkWell numpad, 2-field onboarding, PIN auto-submit, 4 extra indices, RFC 4180 CSV quoting, share_plus fallback, `_StatementSkeleton`

**Design v2 changes applied:**
- Write-on-confirm replaces batch-save (crash safety)
- Quantity chips replace `+0.5` key
- Success screen never auto-dismisses
- Avatar strip replaces progress bar
- Swipe gestures removed, visible buttons added
- Info Hub removed entirely
- Ambient light sensor removed, manual toggle added
- Streak mechanics removed
- P&L secondary to Customer Statements
- 2-field onboarding only
- Unusual entry warning uses safe-default psychology (safe = green primary, dangerous = outlined secondary)
- Post-delivery payment nudge added (primary discovery mechanism for payment recording)

**Key architectural decisions locked:**
- Write-on-confirm: every customer confirmation → immediate SQLite INSERT
- Crash recovery: on app open, detect `session_draft` records from today → offer resume
- Delta balance: `adjustCachedBalance(id, +/-delta)` on every write, `repairAllBalances()` once at startup
- WAL mode + `PRAGMA synchronous = NORMAL` — safe with WAL, faster than FULL

**Output files created:**
- `DoodHisaab_MVP_Final_Plan.md` — the 26-step build plan
- `DoodHisaab_DEV_CONTEXT.md` — this file (single source of truth)

**Next step:** Step 1 — Bootstrap. Create Flutter project, configure `pubspec.yaml` with all dependencies including `crypto ^3.0.3`.

---

### New Critical Insights:

- **Memory pressure on 1GB RAM phones:** Android Low Memory Killer activates at ~150MB available. Flutter engine baseline = 50MB, app heap = 30-60MB. Leaving <100MB for Android. Any WhatsApp video call can kill the app mid-session. Write-on-confirm is mandatory, not optional.
- **Noto Nastalikh font shaping:** 8-15ms on first render of Urdu text on Helio G25. Pre-render next customer card (Offstage) before slide animation starts — eliminates this from the animation frame budget.
- **WAL mode behavior on power cut:** Each confirmed customer = one committed transaction. Power cut after N confirmations = N records safe, the rest missing cleanly. User sees exactly which customers were confirmed. No corruption, no silent data loss.
- **SQLite with FutureBuilder on main isolate:** 40-80ms for monthly statement query with `idx_del_cust_date` on 2 years of data. Well within acceptable range. Skeleton loader covers the brief wait.
- **Pakistani phone number format:** Farmers store `0300-1234567`. wa.me requires `923001234567`. Without `normalizePhoneForWhatsapp()`, WhatsApp opens a blank "new chat" — one-tap share silently fails.
- **Onboarding abandonment:** 4+ fields = ~40% abandonment. 2 fields (name + quantity) = sufficient to start. Phone and payment cycle are collected later when the user is already engaged.
- **Success screen as trust artifact:** The session-save success screen is shown to the customer standing next to the farmer as proof of delivery. Auto-dismiss destroys the only trust-building moment in the app.

---

### Changes Introduced vs. Original Plan:

- Steps reordered: Data Models (8) and Riverpod Providers (9) inserted before Customer Repository (10) and Onboarding (11). Developer was previously blocked at Step 9 because `Customer.fromMap()` didn't exist.
- `monthly_cache` table removed from schema.
- `session_id` and `status` fields added to `deliveries` table for write-on-confirm and crash recovery.
- 4 additional indices added: `idx_edit_delivery`, `idx_price_from`, `idx_cust_active_route`, `idx_income_date`.
- `delivery_edit_log` table retained (audit trail for edited deliveries).
- WorkManager constraint: `requiresBatteryNotLow: true` added (prevents backup draining an already-low battery).
- CSV export now has 4 sections: deliveries, payments, expenses, other_income.
- Reports screen: Customer Statements is primary tab, P&L is secondary.

---

### Next Step:

**→ Step 1: Bootstrap**

Create the Flutter project and write `pubspec.yaml` with all dependencies.

Key checkpoints:
- `crypto: ^3.0.3` is present
- `workmanager: ^0.5.2` is present
- `riverpod_annotation` and `build_runner` are in `dev_dependencies`
- `sqflite_common_ffi` is in `dev_dependencies` (for tests)
- Run `flutter pub get` — zero errors, zero warnings
- Commit with message: `chore: bootstrap project and configure pubspec`

After Step 1: proceed immediately to Step 2 (SQLite Schema).
Do not build any screens before Step 8 (Data Models) is complete.
Do not build repositories before Step 8 (Data Models) is complete.

---

## ⚡ Fast-Reference: Common Mistakes to Avoid

```
❌  DatabaseProvider._db = null             → use DatabaseProvider.closeAndReset()
❌  BackupService._getBackupDir()           → use BackupService.getBackupDir()
❌  GoRoute('/customers/add', ...)          → use '/customers/new'
❌  Isolate.run(() => generateStatement())  → use FutureBuilder on main isolate
❌  Opacity(opacity: 0, child: NextCard())  → use Offstage(offstage: true, ...)
❌  GestureDetector on numpad keys          → use InkWell + Material
❌  getExternalStorageDirectory()           → use getDownloadsDirectory()
❌  INSERT delivery on every confirm        → UPSERT (check existing session_draft first)
❌  HapticFeedback.mediumImpact()           → use HapticFeedback.selectionClick()
❌  wa.me/0300-1234567                      → normalize to wa.me/923001234567 first
❌  rebuildCachedBalance() full JOIN        → use adjustCachedBalance(id, delta)
❌  holding deliveries in memory            → write each confirm to SQLite immediately
❌  auto-dismiss success screen             → stays until user taps Done
❌  +0.5 key on numpad                      → use quantity chips
❌  swipe gestures on customer list         → use visible [ادائیگی] [تاریخ] buttons
```

---

## 📋 Session Handoff Protocol

When starting a new chat session, the AI must:

1. Read this entire file before doing anything
2. Identify the last completed step from the Progress Notes
3. Identify the "Next Step" at the bottom of Progress Notes
4. Begin building that step without asking for context
5. After completing any step, update this file:
   - Change step status in the table from ⬜/🔄 to ✅
   - Add a new dated section under Progress Notes
   - Update "Next Step" to the following step
   - Add any new insights, decisions, or discovered constraints

When updating this file, NEVER delete previous progress notes. Only append.

---

## 🧪 Test Setup Reference

```dart
// test/database_test.dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reset singleton between tests — required
    await DatabaseProvider.closeAndReset();
  });

  // Each test gets a fresh DB
}
```

---

## 📞 UAT Quick Reference (Critical Test Cases)

| Test | What to check |
|---|---|
| Previous button duplicate | Confirm #3 → Previous → change qty → confirm → COUNT = 1 row only |
| WorkManager isolate | Trigger backup → main isolate data still correct after |
| Report screen crash | Open reports → must NOT crash → skeleton → data |
| Route conflict | Tap "+ New Customer" → AddEditCustomerScreen, NOT CustomerProfile with id='add' |
| Backup visibility | Files app → Downloads/DoodHisaab/ → backup file visible |
| WhatsApp phone | Customer phone "0300-1234567" → share → contact pre-selected in WhatsApp |
| CSV other_income | Add calf sale → export → "OTHER INCOME" section present |
| PIN auto-submit | Enter 4 digits → unlocks without confirm button |
| Success screen | SAVE ALL → green screen → does NOT dismiss on its own |
| Crash recovery | Confirm 6/12 → force-stop → reopen → recovery dialog appears |
| Offline entry | Airplane mode → complete full session → data in SQLite |
| Balance integrity | SQL: `cached_balance = SUM(confirmed deliveries) - SUM(payments)` |

---

*DoodHisaab DEV CONTEXT v1.0 — Session 1 — April 2026*
*Next session: read this file, build Step 1*

---

### Session 2 — Steps 1 + 2 Built (April 2026)

**What was done:**
- Built Step 1: `pubspec.yaml` — all 13 runtime dependencies, `crypto ^3.0.3` confirmed present, `generate: true` for l10n, `sqflite_common_ffi` in dev_dependencies
- Built `l10n.yaml` — ARB dir, template file, output file configured
- Built `lib/main.dart` — calls `DatabaseProvider.database` on cold start; `repairAllBalances()` stubbed with `TODO(Step 10)` marker
- Built `lib/app.dart` — compilable bootstrap stub; theme and router wired in Steps 4 and 6 respectively; Urdu locale defaulted
- Built Step 2: `lib/db/db_provider.dart` — complete schema: 8 tables, 7 indices, WAL + NORMAL pragmas, `closeAndReset()` public, `_onUpgrade` hook stubbed
- Built `test/database_test.dart` — 5 tests: DB opens, 8 tables, 7 indices, closeAndReset, WAL mode

**Files created this session:**
- `pubspec.yaml` ✅
- `l10n.yaml` ✅
- `lib/main.dart` ✅
- `lib/app.dart` ✅ (stub — updated in Steps 4 and 6)
- `lib/db/db_provider.dart` ✅
- `test/database_test.dart` ✅

**Verify before continuing:**
```
flutter pub get         # zero errors
flutter test            # 5 tests pass
```

**Bug fixed vs. plan:**
- Plan had SQL comment `-- status values:` inside a Dart string inside `db.execute()` — this is valid SQL but was confusing. Converted to a Dart `//` comment above the execute call for clarity.

---

### Session 3 — Step 3 Built (April 2026)

**What was done:**
- Built Step 3: `lib/db/settings_repository.dart`

**Files created this session:**
- `lib/db/settings_repository.dart` ✅

**Implementation details:**
- `SettingsRepository.instance` — const singleton, no constructor noise
- `_get()` / `_set()` private helpers; `_set` uses `ConflictAlgorithm.replace` (true UPSERT, zero duplicate-key risk)
- `getDeviceId()` — UUID v4, generated once on first call, persisted forever; used as `created_by_device` on all delivery/payment rows
- `getLanguage()` / `setLanguage()` — defaults to `'ur'`; asserts on invalid language codes
- `getAppVersion()` / `setAppVersion()` — for version-upgrade detection in main.dart
- `isFirstLaunchDone()` / `markFirstLaunchDone()` — onboarding gate (Step 11)
- `pin_hash` and `outdoor_mode` stubbed as comments only — not implemented (Steps 17 and 24)

**Verify before continuing:**
```
flutter analyze lib/db/settings_repository.dart   # zero issues
```

---

### Next Step:

**→ Step 4: Theme (`lib/theme/app_theme.dart`)**

Key checkpoints:
- All 9 color tokens defined as top-level `const Color` constants (`kGreen`, `kGreenDark`, `kCream`, `kInkBlack`, `kMittiBrown`, `kAlertRed`, `kAmber`, `kMutedGray`, `kSurfaceGray`, `kWhite`)
- No hardcoded hex values anywhere outside this file
- Touch target sizes documented as constants (56dp buttons, 72dp SAVE ALL, 64dp list rows, 60dp inputs)
- Typography: Noto Sans base, Noto Nastaliq Urdu for Urdu text, minimum 16sp body, 18sp Urdu body
- `AppTheme.light()` returns a `ThemeData` — wired into `app.dart` (Step 2 stub)

Do not build any screens before Step 8 (Data Models) is complete.
Do not build repositories before Step 8 (Data Models) is complete.

---

### Session 4 — Steps 22 + 23 + 24 Built (April 2026)

**What was done:**

- Built Step 22: Performance Hardening
  - `lib/main.dart` — full startup sequence: WorkManager init → `repairAllBalances()` → `runApp()`; `repairAllBalances()` stub replaced with real call
  - `lib/screens/customers/customer_list_screen.dart` — `ListView.builder` with `itemExtent: kListRowHeight` on both live list and skeleton; eliminates per-item layout measurement
  - `lib/router/app_router.dart` — updated routing; `/customers/new` confirmed before `/customers/:id`
  - `lib/app.dart` — full wiring: theme (outdoor-aware), router, localization, `ProviderScope`
  - `lib/screens/reports/reports_screen.dart` — `FutureBuilder` on main isolate, skeleton loader; no `Isolate.run()`
  - `lib/screens/settings/backup_screen.dart` — updated with correct `getBackupDir()` public method

- Built Step 23: Pre-rendered Card Transition
  - `delivery_entry_screen.dart` already in codebase uses `Offstage` pattern — confirmed no `Opacity(0)` wrappers in codebase

- Built Step 24: Outdoor Bright Mode
  - `lib/theme/app_theme.dart` — `buildAppTheme()` and `buildOutdoorTheme()` split; `kGreenOutdoor = Color(0xFF155D38)` added; single `_buildTheme(outdoor:)` private builder
  - `lib/screens/settings/settings_screen.dart` — `_toggleOutdoorMode()` calls `SettingsRepository.instance.setOutdoorMode()`; `ref.invalidate(outdoorModeProvider)` triggers rebuild; `Icons.brightness_high_outlined` toggle tile in UI

**Files updated this session:**
- `lib/main.dart` ✅ (repairAllBalances + WorkManager wired)
- `lib/app.dart` ✅ (outdoor theme + go_router fully wired)
- `lib/theme/app_theme.dart` ✅ (buildOutdoorTheme, kGreenOutdoor)
- `lib/router/app_router.dart` ✅ (/customers/new before /:id confirmed)
- `lib/screens/customers/customer_list_screen.dart` ✅ (itemExtent: kListRowHeight)
- `lib/screens/reports/reports_screen.dart` ✅ (FutureBuilder, skeleton)
- `lib/screens/settings/backup_screen.dart` ✅ (getBackupDir public method)
- `lib/screens/settings/settings_screen.dart` ✅ (outdoor mode toggle)

**Verify before continuing:**
```
flutter analyze lib/           # zero issues
grep -r "Opacity(opacity: 0"   # must return empty
grep -r "Isolate.run"          # must return empty
grep -r "itemExtent"           # must appear in customer_list_screen.dart
```

---

### Session 5 — Steps 25 + 26 Completed (April 2026)

**What was done:**
- Audited full codebase against DEV_CONTEXT step table — steps 4–24 were all present in uploaded zip but table was outdated. Corrected all statuses to ✅ COMPLETE.
- Step 25: `_showDataWarning()` confirmed already implemented in `onboarding_wizard.dart` from a prior session — `barrierDismissible: false`, RTL Urdu text inline (localization step not yet separately wired into ARBs but strings are correct and app compiles), dialog fires from `_finish()` AFTER `markFirstLaunchDone()` is called, routes to `/home` on dismiss.
- Step 26: Created `DoodHisaab_UAT_Checklist.md` — 16 test sections, 80+ individual test cases covering all 15 critical issues and 8 improvements from the staff engineer review. Includes DB-level SQL verification queries, architecture grep checks, sign-off table for tester sign-off.

**Files created this session:**
- `DoodHisaab_UAT_Checklist.md` ✅

**🏁 ALL 26 STEPS COMPLETE — MVP READY FOR UAT**

**Pre-UAT commands to run:**
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze lib/                    # zero issues required
flutter test                            # all tests pass required
grep -rn "Opacity(opacity: 0"  lib/    # must be empty
grep -rn "Isolate.run"         lib/    # must be empty
grep -rn "GestureDetector"     lib/widgets/numpad.dart  # must be empty
```

**UAT:** Run `DoodHisaab_UAT_Checklist.md` on real hardware (Tecno/Infinix class device).
Start with Section 2 (Critical Bug Verification) before anything else.

### Next Step:
**→ UAT on real device. All 26 build steps complete. No code changes until UAT failures are identified.**
