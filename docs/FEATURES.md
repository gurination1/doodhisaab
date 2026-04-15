# DoodHisaab Features

This document explains the major user-facing functions in the app.

## Core purpose

DoodHisaab helps a milk seller or dairy farmer keep daily records on a phone without depending on internet access.

## Feature list

### Delivery recording

- Start a delivery session from the home screen
- Select customers in route order
- Enter milk quantity with a large custom numpad
- Confirm one customer at a time
- Save progress during the session
- Recover unfinished draft sessions after app interruption
- Prevent duplicate billing through draft overwrite behavior

### Customer ledger

- Add new customers
- Edit existing customers
- Search customers by name
- View customer profile details
- Reorder route sequence
- Keep a cached running balance for fast display

### Payments

- Record customer payments
- Pre-select a customer when entering from profile/history flows
- Warn on overpayment while still allowing advance payment
- Reduce the customer balance immediately after save

### Milk pricing

- Set current milk price
- Preserve a history of price changes
- Keep old delivery entries on their original price
- Add an optional reason or note for price changes

### Expenses

- Record expenses such as feed, medicine, fuel, electricity, labor, and other
- Use visible category chips instead of hidden dropdown menus
- Enter amount using a custom numpad
- Add an optional note

### Other income

- Record extra revenue outside milk sales
- Categories include calf sale, ghee sale, manure sale, and other
- Use the same fast-entry pattern as expense entry

### Reports

- Customer statements tab
- Customer balance list
- Detailed customer statement view
- Profit and loss tab
- Monthly summary support
- Visibility into milk revenue, other income, expenses, and balances

### Backups

- Manual backup on demand
- Daily auto backup
- Backups stored in `Downloads/DoodHisaab/`
- Backup list shown in reverse chronological order
- Old backups pruned automatically

### CSV export

- Export by date range
- Save CSV locally
- Share exported file through the device share sheet
- CSV contains:
  - Deliveries
  - Payments
  - Expenses
  - Other income

### Security and help

- Optional PIN lock
- Change or remove PIN
- Built-in tutorial
- Privacy screen
- Data safety guidance
- Basic calculator

### Localization and accessibility direction

- Urdu-first usage model
- Punjabi and English support
- Large touch targets
- Simple text and visible controls
- Design choices aimed at low-literacy users

## Why these features matter

The app is designed around real-world field failures:

- phones with low RAM
- unexpected app kills
- users who are not comfortable with dense forms
- users who need offline access
- users who need quick entry during delivery rounds
