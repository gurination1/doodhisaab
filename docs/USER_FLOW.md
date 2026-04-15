# DoodHisaab User Flow

This document shows how a normal user would move through the app.

## First launch

1. Open app
2. Complete onboarding
3. Set basic preferences such as language and pricing
4. Add initial customers

## Daily use

### Morning delivery run

1. Open app
2. Unlock with PIN if enabled
3. Tap `Start Delivery`
4. Select customer in route order
5. Enter liters
6. Confirm each customer entry
7. Save all when the round is complete

### Payment collection

1. Open app
2. Tap `Record Payment`
3. Select customer
4. Enter amount
5. Save payment
6. Customer balance updates immediately

### Customer lookup

1. Open `Customers`
2. Search by name if needed
3. Open customer profile
4. Review balance and statement history
5. Start payment flow from the customer if needed

### Price update

1. Open `Settings`
2. Open milk price settings
3. Enter new price
4. Add optional note
5. Save
6. Future deliveries use the new price

### Expense or other income

1. Open quick action from home
2. Select category
3. Enter amount
4. Add optional note
5. Save

### Monthly review

1. Open `Reports`
2. Review customer statements
3. Switch to `Profit & Loss`
4. Pick month
5. Review revenue, expenses, and totals

### Backup and export

1. Open `Settings`
2. Tap `Backup` to save a database snapshot
3. Tap `Export` to generate a CSV file
4. Share or store exported records

## Recovery flow

If the app closes during a delivery session:

1. Reopen app
2. The app checks for saved draft session entries
3. User can resume or discard the interrupted session

## Navigation map

- `/lock`
- `/home`
- `/onboarding`
- `/delivery/entry`
- `/payment/entry`
- `/customers`
- `/customers/new`
- `/customers/reorder`
- `/customers/:id`
- `/reports`
- `/reports/statement/:id`
- `/expenses/new`
- `/income/new`
- `/settings`
- `/settings/price`
- `/settings/backup`
- `/settings/export`
- `/settings/calculator`
- `/tutorial`
- `/privacy`
