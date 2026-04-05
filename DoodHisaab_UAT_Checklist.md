# DoodHisaab MVP — UAT Checklist
> **Run on real hardware only.** Emulators pass tests that real Helio G25 devices fail.
> Target: Tecno Spark / Infinix Hot class, Android 7.0+, 1GB RAM.
> Complete every section in order. Do not ship until every ☐ becomes ☑.

---

## 0. Pre-Test Setup

```
Device:    ___________________________  (model, Android version)
Tester:    ___________________________
Date:      ___________________________
Build:     1.0.0+1
```

Before starting:
- Factory-reset the app (clear data from Android settings) or use a fresh install
- Disable Wi-Fi and mobile data — ALL core tests run offline
- Enable Developer Options → Show Touches (helps catch missed taps)
- Open DB Browser for SQLite on PC to verify database state where noted

---

## 1. First Launch & Onboarding

### 1.1 Onboarding Gate
```
☐  Install app — onboarding wizard opens immediately (NOT home screen)
☐  Close and reopen app — wizard shows again (first launch NOT marked done yet)
☐  Complete wizard through all 3 screens — home screen opens
☐  Close and reopen app — home screen opens directly (wizard never shows again)
```

### 1.2 Wizard — Screen 1: Milk Price
```
☐  Price field shows "₹ 0" placeholder in muted gray
☐  Custom numpad appears — system keyboard does NOT appear at any point
☐  Typing 120 → field shows "₹ 120"
☐  Backspace clears last digit
☐  Tap "آگے" — moves to screen 2
☐  Tap "چھوڑیں" (skip) — also moves to screen 2, no crash
☐  Progress bar advances from step 1 to step 2
```

### 1.3 Wizard — Screen 2: First Customer
```
☐  Name field: system keyboard opens for text input (correct — not a number field)
☐  Quantity chips render: 0.5, 1.0, 1.5, 2.0, 2.5, 3.0 litres visible
☐  Tap a chip — it highlights in green; tapping another moves highlight
☐  Tap "آگے" — moves to screen 3
☐  Tap "پیچھے" — goes back to screen 1 WITHOUT losing price data
☐  Return to screen 2 — name and selected qty still filled
```

### 1.4 Wizard — Screen 3: Confirm & Start
```
☐  Summary card shows entered price and customer name
☐  If skipped both: summary card shows "آپ بعد میں قیمت اور گاہک شامل کر سکتے ہیں"
☐  "شروع کریں" button is 72dp tall (visually larger than other buttons)
☐  Tapping it shows loading spinner briefly
☐  Data warning dialog appears (barrierDismissible = false — tap outside does nothing)
☐  Dialog body explains data is on this phone only and weekly backup runs automatically
☐  "سمجھ گیا" button dismisses dialog and opens home screen
☐  No second dialog on any subsequent app open
```

### 1.5 Onboarding Data Integrity
```
☐  Open DB Browser → app_settings table → first_launch_done = 'true'
☐  If price was entered: price_history table has 1 row with note = 'onboarding'
☐  If customer was entered: customers table has 1 row, is_active = 1
☐  Tap "پیچھے" in wizard → return to screen 1 → change price → tap "آگے"
    → DB must have only 1 price_history row (not 2) — write-once guard working
```

---

## 2. Critical Bug Verification

> **These 3 bugs would kill the app in production. Test them first.**

### 2A — ISSUE 6: Previous Button Duplicate Drafts (Billing Corruption)

```
Setup: Start a delivery session with at least 3 customers.

Step 1: Navigate to Customer #3
Step 2: Tap "تصدیق کریں" with 2.5 litres — observe green confirmation
Step 3: Tap "← پیچھے" to go back to Customer #2
Step 4: Navigate forward to Customer #3 again
Step 5: Change quantity to 3.0 litres
Step 6: Tap "تصدیق کریں" again

☐  DB check: SELECT COUNT(*) FROM deliveries WHERE customer_id=? AND session_id=? AND status='session_draft'
   → Result must be EXACTLY 1 (not 2)
☐  DB check: SELECT liters FROM deliveries WHERE customer_id=? AND session_id=?
   → Result must be 3.0 (the corrected value, not 2.5)

Step 7: Tap "سب محفوظ کریں"

☐  DB check: SELECT liters FROM deliveries WHERE customer_id=? AND status='confirmed'
   → Result must be 3.0 (not 5.5)
☐  Customer balance reflects 3.0 litres only
```

### 2B — ISSUE 7: Reports Screen (Isolate.run crash)

```
Setup: Ensure at least one customer with confirmed deliveries exists.

☐  Tap Reports tab in bottom nav
☐  Reports screen opens — NO crash
☐  Skeleton loader appears briefly while data loads
☐  Data populates: customer list, delivery totals visible
☐  Open monthly statement for any customer — NO crash
☐  Statement shows deliveries, payments, and balance correctly
☐  Rotate device (if supported) — no crash
```

### 2C — ISSUE 2: Backup + Main Isolate Integrity (WorkManager)

```
Setup: Add 5 confirmed deliveries and 1 payment. Note total balance.

Step 1: Go to Settings → Backup → Tap "ابھی بیک اپ لیں"
☐  Success message appears
☐  Open Files app → Downloads/DoodHisaab/ → backup .db file is visible and has a recent timestamp

Step 2: Restore from backup (Settings → Backup → Restore)
☐  App restores without crash
☐  Reopen app — home screen shows correct balance (matches pre-backup balance)

Step 3: Add 2 more deliveries AFTER restore
☐  New deliveries save correctly
☐  Balance updates correctly (not stale)
☐  DB check: new delivery rows exist in deliveries table
```

---

## 3. Go-Router Route Conflict (ISSUE 5)

```
☐  Tap "+ نیا گاہک" button from customer list
   → AddEditCustomerScreen opens (shows name/phone/qty input form)
   → NOT CustomerProfileScreen with id='add'
   → URL/route internally is '/customers/new'

☐  Tap an existing customer from the list
   → CustomerProfileScreen opens with that customer's data
   → URL/route internally is '/customers/:id'

☐  From customer profile → Edit → save → returns to profile (not wrong screen)
```

---

## 4. Delivery Session Flow

### 4.1 Basic Session
```
☐  Home screen → tap "آج کی ترسیل" (or delivery button)
☐  Customer cards load in route_order sequence
☐  Each card shows customer name (large text, ≥18sp), default quantity
☐  Quantity chips and numpad are both available for input
☐  Selecting a chip highlights it; numpad value updates to match
☐  Typing on numpad updates display (no system keyboard)
☐  Tap "تصدیق کریں" → card animates to next customer
☐  Previously-confirmed customers show green checkmark in avatar strip
☐  "سب محفوظ کریں" button is 72dp tall, distinct from other buttons
☐  Tap "سب محفوظ کریں" → success screen appears in green
☐  Success screen does NOT auto-dismiss — stays until user taps "ٹھیک ہے"
```

### 4.2 Crash Recovery
```
☐  Start a session → confirm 6 of 12 customers → force-stop app (from Android settings)
☐  Reopen app → recovery dialog appears offering to resume or discard
☐  Tap "جاری رکھیں" → session resumes at correct position with confirmed customers intact
☐  Tap "چھوڑیں" → all session_draft records for today are abandoned (status='abandoned')
☐  DB check: no session_draft rows remain after discard
```

### 4.3 Write-on-Confirm Verification
```
☐  Start session → confirm 3 customers → force-stop app (DO NOT tap "سب محفوظ کریں")
☐  Reopen app → recovery dialog shows those 3 customers confirmed
☐  DB check: 3 rows with status='session_draft' exist in deliveries table
   → These were written immediately on confirm, not held in memory
```

---

## 5. Payment Entry

```
☐  Open a customer profile → tap "ادائیگی درج کریں"
☐  Custom numpad for amount — system keyboard never appears
☐  Enter 500 → tap save
☐  Payment appears in customer's transaction history
☐  Customer balance decreases by 500

☐  DB check: payments table has 1 row with correct amount and customer_id
☐  DB check: customers.cached_balance updated correctly (not via full JOIN — delta method)

☐  Add a note to payment → note saved and displayed in history
```

---

## 6. Balance Integrity (IMPROVEMENT 1)

```
Run this after entering a mix of deliveries and payments for one customer.

SQL query (run in DB Browser):
  SELECT
    c.name,
    c.cached_balance,
    ROUND(SUM(d.total_value), 2) - ROUND(SUM(p.amount), 2) AS computed_balance
  FROM customers c
  LEFT JOIN deliveries d ON d.customer_id = c.customer_id AND d.status = 'confirmed'
  LEFT JOIN payments p ON p.customer_id = c.customer_id
  WHERE c.customer_id = ?
  GROUP BY c.customer_id;

☐  cached_balance = computed_balance for every customer tested
☐  Add 1 more delivery → re-run query → still matches
☐  Add 1 more payment → re-run query → still matches
```

---

## 7. App Lock PIN (ISSUE 4 + IMPROVEMENT 4)

```
☐  Settings → Security → Set PIN
☐  Enter 4 digits → app unlocks AUTOMATICALLY (no confirm button needed)
☐  Wrong PIN: no auto-unlock; error shown after 4th digit
☐  Close and reopen app → PIN screen appears (not home screen)
☐  Enter correct PIN → unlocks immediately at 4th digit

☐  DB check: app_settings table → pin_hash row contains a SHA-256 hash string
   (64 hex chars) — NOT the raw PIN digits

☐  Settings → Security → Remove PIN → confirm → lock screen no longer shows on reopen
```

---

## 8. Backup (ISSUE 11 + ISSUE 3)

```
☐  Settings → Backup → "ابھی بیک اپ لیں"
☐  Success toast/snack appears
☐  Open device Files app → navigate to Downloads/DoodHisaab/
☐  Backup file is visible (not hidden in app-private Android/data/ folder)
☐  File name format: doodhisaab_backup_YYYY-MM-DD.db
☐  File survives app uninstall (user can manually restore from Files app)

☐  Create 3 backups → only 2 most recent are kept (pruning working)

WorkManager auto-backup:
☐  Wait 7 days OR trigger via ADB:
   adb shell am broadcast -n com.google.android.gms/.gcm.GcmReceiver
☐  New backup file appears in Downloads/DoodHisaab/ without opening app
```

---

## 9. CSV Export (ISSUE 13 + IMPROVEMENT 6)

```
Setup: Ensure at least one record of each type exists:
  - Confirmed delivery
  - Payment
  - Expense (any category)
  - Other Income (e.g., Calf Sale)

☐  Settings → Export → Export CSV → file saved/shared
☐  Open file in Google Sheets or text editor

Section verification:
☐  "DELIVERIES" section present with date, customer, liters, price, total columns
☐  "PAYMENTS" section present with date, customer, amount columns
☐  "EXPENSES" section present with date, category, amount columns
☐  "OTHER INCOME" section present with date, category, amount columns
   (this section was missing in original plan — ISSUE 13)

RFC 4180 quoting (IMPROVEMENT 6):
☐  Add a customer with a comma in the name: e.g., "احمد, علی"
   → Export CSV → open in Sheets
   → Name field must be properly quoted: "احمد, علی"
   → Row must not be broken into extra columns
   → No data corruption visible in spreadsheet
```

---

## 10. WhatsApp Share (ISSUE 15)

```
Setup: Add a customer with phone number stored as "0300-1234567"
       (with dash, as farmers naturally enter it).

☐  Customer profile → Share Statement → WhatsApp
☐  WhatsApp opens with the customer's contact PRE-SELECTED
   (NOT a blank "new chat" or "new message" dialog)

☐  Verify normalisation:
   - "0300-1234567" → sent to wa.me as "923001234567"
   - Dashes stripped, leading 0 replaced with 92 country code

☐  Customer with no phone number saved:
   → Share button still works (falls back to share_plus generic sheet)
   → No crash

☐  WhatsApp not installed:
   → App falls back to share_plus (shows system share sheet)
   → No crash
```

---

## 11. Outdoor Mode (Step 24)

```
☐  Settings → Outdoor Mode toggle → ON
☐  App background changes from cream (#FBF8F1) to pure white (#FFFFFF)
☐  Text changes from near-black (#1A1A1A) to pure black (#000000)
☐  Primary button color changes from kGreen to kGreenOutdoor (slightly darker)
☐  Card borders become more visible (higher contrast)
☐  Toggle OFF → reverts to normal theme immediately
☐  Close and reopen app → outdoor mode persists correctly
☐  DB check: app_settings → outdoor_mode = '1' when enabled
```

---

## 12. Localization

```
☐  Default language on fresh install: Urdu
☐  All text in home screen, customer list, delivery entry is in Urdu
☐  Settings → Language → English → all UI text switches to English
☐  Settings → Language → Punjabi → text switches to Punjabi
☐  Settings → Language → Urdu → reverts to Urdu
☐  Language persists across app restarts
☐  RTL layout: text aligns right, icons on correct side, numerals display correctly
```

---

## 13. Performance (Real Hardware)

### 13.1 Frame Rate
```
☐  Enable Developer Options → GPU rendering profile (bars stay below green line)
☐  Customer list scroll (20+ customers): smooth, no dropped frames
☐  Delivery session card swipe animation: smooth (≤200ms, no jank)
☐  Opening home screen: <500ms to show content

☐  Verify itemExtent on list:
   grep -n "itemExtent" lib/screens/customers/customer_list_screen.dart
   → Must return a match with kListRowHeight
```

### 13.2 Memory
```
☐  Enable: Developer Options → Don't keep activities
☐  Start delivery session → switch to another app for 2 minutes → return
☐  Recovery dialog appears (app was killed) — correct behaviour
☐  Confirmed deliveries from before switch are preserved in SQLite
```

### 13.3 Arch Verification (Automated)
```bash
# Run from project root:
flutter analyze lib/                    # zero issues
grep -rn "Opacity(opacity: 0"  lib/    # must return empty
grep -rn "Isolate.run"         lib/    # must return empty
grep -rn "GestureDetector"     lib/widgets/numpad.dart  # must return empty (InkWell only)
grep -rn "_db ="               lib/    # must return empty (only closeAndReset() allowed)
grep -rn "_getBackupDir"       lib/    # must return empty (public getBackupDir only)
grep -rn "customers/add"       lib/    # must return empty (/customers/new is correct)
flutter test                           # all tests pass
```

---

## 14. Edge Cases

### 14.1 Zero / Empty State
```
☐  Fresh install with 0 customers → customer list shows empty state illustration
☐  Fresh install → delivery session started → 0 customers shown → graceful empty state
☐  Customer with 0 deliveries → profile shows zero balance, no crash
☐  Payment entered for customer with zero balance → warning shown (negative balance)
```

### 14.2 Large Numbers
```
☐  Enter price of 9999 per litre → saves and displays correctly
☐  Balance of Rs. 99,999 → displays without overflow or truncation
☐  50+ customers in route → list scrolls smoothly, no OOM
```

### 14.3 Interruptions
```
☐  Mid-session: incoming phone call → answer → return to app → session intact
☐  Mid-session: screen timeout → unlock → session intact
☐  Mid-onboarding: home button → return → wizard at same screen
```

### 14.4 Database Safety
```
☐  Force-kill app at exact moment of "سب محفوظ کریں" tap
☐  Reopen → DB is not corrupted (WAL journal protects committed transactions)
☐  DB check: PRAGMA integrity_check → returns 'ok'
```

---

## 15. Sign-off

| Section | Tester | Pass | Fail | Notes |
|---------|--------|------|------|-------|
| 1. Onboarding | | ☐ | ☐ | |
| 2A. Duplicate drafts | | ☐ | ☐ | |
| 2B. Reports crash | | ☐ | ☐ | |
| 2C. Backup + isolate | | ☐ | ☐ | |
| 3. Route conflict | | ☐ | ☐ | |
| 4. Delivery flow | | ☐ | ☐ | |
| 5. Payments | | ☐ | ☐ | |
| 6. Balance integrity | | ☐ | ☐ | |
| 7. PIN lock | | ☐ | ☐ | |
| 8. Backup files | | ☐ | ☐ | |
| 9. CSV export | | ☐ | ☐ | |
| 10. WhatsApp share | | ☐ | ☐ | |
| 11. Outdoor mode | | ☐ | ☐ | |
| 12. Localization | | ☐ | ☐ | |
| 13. Performance | | ☐ | ☐ | |
| 14. Edge cases | | ☐ | ☐ | |

**Ship decision:**
- All sections PASS → ✅ Ready to ship
- Any section FAIL → ❌ Fix and re-test that section only

---

*DoodHisaab UAT Checklist v1.0 — April 2026*
*Reference: DoodHisaab_Plan_Review.md — Issues 1–15, Improvements 1–8*
