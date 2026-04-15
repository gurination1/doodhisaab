// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DoodHisaab';

  @override
  String get navHome => 'Home';

  @override
  String get navCustomers => 'Customers';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get btnConfirm => 'Confirm';

  @override
  String get btnSaveAll => 'Save All';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnNext => 'Next';

  @override
  String get btnBack => 'Back';

  @override
  String get btnSkip => 'Skip';

  @override
  String get btnDone => 'OK';

  @override
  String get btnAddCustomer => 'New Customer';

  @override
  String get btnAddPayment => 'Record Payment';

  @override
  String get btnBackupNow => 'Backup Now';

  @override
  String get btnSave => 'Save';

  @override
  String get labelPricePerLiter => 'Price per Liter';

  @override
  String get labelDefaultQty => 'Default Daily Quantity';

  @override
  String get labelCustomerName => 'Customer Name';

  @override
  String get labelPhone => 'Phone Number';

  @override
  String get hintNameExample => 'e.g. Ahmad Khan';

  @override
  String get hintPhoneLater => 'You can add phone and payment schedule later';

  @override
  String get successSaved => 'Saved!';

  @override
  String get successSavedSubtitle => 'Today\'s records are complete';

  @override
  String get recoveryTitle => 'Incomplete Session';

  @override
  String get recoveryBody => 'Continue where you left off or start fresh?';

  @override
  String get recoveryContinue => 'Continue';

  @override
  String get recoveryRestart => 'Start Over';

  @override
  String get warningUnusualTitle => 'Is this correct?';

  @override
  String warningUnusualBody(String name, String qty, String defaultQty) {
    return '$name: ${qty}L today? (usually ${defaultQty}L)';
  }

  @override
  String warningConfirmSafe(String defaultQty) {
    return '← No, enter ${defaultQty}L';
  }

  @override
  String warningConfirmDangerous(String qty) {
    return 'Yes, ${qty}L is correct';
  }

  @override
  String balanceOwed(String amount) {
    return 'Balance: ₹$amount';
  }

  @override
  String get today => 'Today';

  @override
  String get served => 'Served';

  @override
  String get liters => 'Liters';

  @override
  String get customers => 'Customers';

  @override
  String get reports => 'Reports';

  @override
  String get expenses => 'Expenses';

  @override
  String get income => 'Income';

  @override
  String get startDelivery => 'Start Delivery';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get noDairyToday => 'No deliveries recorded for today yet';

  @override
  String deliverySummary(int count, String liters) {
    return '$count customers received $liters liters today';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsPricing => 'Pricing';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsMilkPrice => 'Milk Price';

  @override
  String get settingsMilkPriceSubtitle => 'View current price and history';

  @override
  String get settingsSetPin => 'Set PIN';

  @override
  String get settingsChangePin => 'Change PIN';

  @override
  String get settingsSetPinSubtitle => 'Protect the app with a PIN';

  @override
  String get settingsChangePinSubtitle => 'Set a new 4-digit PIN';

  @override
  String get settingsRemovePin => 'Remove PIN';

  @override
  String get settingsRemovePinSubtitle => 'App will open without a PIN';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupSubtitle => 'Save into Downloads/DoodHisaab/';

  @override
  String get settingsExportCsv => 'Export CSV';

  @override
  String get settingsExportCsvSubtitle => 'Create a spreadsheet-friendly file';

  @override
  String get settingsPrivacyTerms => 'Privacy & Terms';

  @override
  String get settingsPrivacyTermsSubtitle =>
      'Read simple privacy and app rules';

  @override
  String get settingsDataSafety => 'Data Safety';

  @override
  String get settingsDataSafetySubtitle =>
      'What happens if the phone is lost or damaged?';

  @override
  String get privacySimpleTitle => 'About this app';

  @override
  String get privacySimpleBody =>
      'This app helps you keep milk records, payments, income, and expenses on your phone.';

  @override
  String get privacyDataTitle => 'Your data';

  @override
  String get privacyDataBody =>
      'Your records stay on your phone. We do not sell your personal details.';

  @override
  String get privacyAnalyticsTitle => 'Small app usage data';

  @override
  String get privacyAnalyticsBody =>
      'To improve the app, we only see simple app use. No name. No phone number. No money details.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get pinSet => 'PIN set';

  @override
  String get pinChanged => 'PIN changed';

  @override
  String get pinRemoved => 'PIN removed';

  @override
  String get removePinTitle => 'Remove PIN?';

  @override
  String get removePinBody => 'The app will open without a PIN after removal.';

  @override
  String get removeAction => 'Remove';

  @override
  String get searchByName => 'Search by name...';

  @override
  String get closeAction => 'Close';

  @override
  String get searchAction => 'Search';

  @override
  String get reorderAction => 'Reorder';

  @override
  String get paymentAction => 'Payment';

  @override
  String get historyAction => 'History';

  @override
  String noSearchResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get noCustomersYet => 'No customers yet';

  @override
  String get addFirstCustomer => 'Add your first customer';

  @override
  String get paymentReceivedNudge => 'Did you collect any payment today?';

  @override
  String get paymentRecordYes => 'Yes, record it';

  @override
  String get paymentRecordNo => 'No, later';

  @override
  String get onboardingStep1Title => 'Set Milk Price';

  @override
  String get onboardingStep2Title => 'Add First Customer';

  @override
  String get onboardingStep3Title => 'Get Started';

  @override
  String get onboardingStartBtn => 'Let\'s Start';

  @override
  String get dataWarningTitle => 'Keep Your Data Safe';

  @override
  String get dataWarningBody =>
      'All your data is stored on this phone.\n\nIf the phone is lost or damaged, data may be lost.\n\nWeekly backup is saved automatically to the Downloads folder.\nYou can also back up now from Settings.';

  @override
  String get dataWarningOk => 'Got it';

  @override
  String backupSavedAt(String path) {
    return 'Backup saved: $path';
  }

  @override
  String get reportTabStatements => 'Statements';

  @override
  String get reportTabPL => 'Profit & Loss';

  @override
  String get expensesNudge => 'Add expenses to see accurate profit';

  @override
  String get outdoorModeLabel => 'Use in bright sunlight';

  @override
  String get priceStaleBanner =>
      'Your last price is 30 days old. Has the price changed?';

  @override
  String get skipToday => 'Skip Today';

  @override
  String get previousCustomer => 'Previous';

  @override
  String defaultQtyLabel(String qty) {
    return 'Default: ${qty}L';
  }

  @override
  String get balanceClear => 'Clear';

  @override
  String dailyLitersShort(String liters) {
    return '$liters L daily';
  }

  @override
  String get onboardingReadyTitle => 'Ready to Start';

  @override
  String get onboardingPriceSummaryLabel => 'Milk Price';

  @override
  String get onboardingFirstCustomerSummaryLabel => 'First Customer';

  @override
  String get onboardingDailyQtySummaryLabel => 'Daily Quantity';

  @override
  String get onboardingCanSetupLater => 'You can add price and customers later';

  @override
  String litersValue(String qty) {
    return '$qty L';
  }

  @override
  String get priceSettingsTitle => 'Milk Price';

  @override
  String get priceSaved => 'Price saved';

  @override
  String get currentPriceLabel => 'Current Price';

  @override
  String get newPriceLabel => 'Enter New Price (₹ / L)';

  @override
  String get optionalNoteLabel => 'Note (optional)';

  @override
  String get priceHistoryTitle => 'Price History';

  @override
  String get noPriceYet => 'No prices yet';

  @override
  String get noPriceSet => 'Price not set';

  @override
  String priceDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String pricePerLiterValue(String price) {
    return '₹$price / L';
  }

  @override
  String get priceStaleWarning => 'Price is older than 30 days';

  @override
  String get noteExamplePrice => 'Example: New season price';

  @override
  String get settingsCalculator => 'Calculator';

  @override
  String get settingsCalculatorSubtitle => 'Open a basic calculator';

  @override
  String get settingsHelp => 'Help';

  @override
  String get settingsTutorial => 'Tutorial';

  @override
  String get settingsTutorialSubtitle =>
      'Learn how delivery, reports, and backup work';

  @override
  String get calculatorTitle => 'Basic Calculator';

  @override
  String get tutorialTitle => 'How to Use DoodHisaab';

  @override
  String get tutorialHomeTitle => 'Start from Home';

  @override
  String get tutorialHomeBody =>
      'Use Start Delivery for milk entry, Record Payment for collections, and the quick tiles for expenses, income, and price changes.';

  @override
  String get tutorialDeliveryTitle => 'Delivery Flow';

  @override
  String get tutorialDeliveryBody =>
      'Select a customer, enter liters, then confirm. A green check appears for customers already recorded for today.';

  @override
  String get tutorialSaveTitle => 'Save and Exit';

  @override
  String get tutorialSaveBody =>
      'Use the green save button on the top right if you want to stop in the middle. Your current delivery progress will reopen later.';

  @override
  String get tutorialReportsTitle => 'Reports and Profit';

  @override
  String get tutorialReportsBody =>
      'Reports shows customer balances, profit and loss, liters, income, expenses, and cash collections for the month.';

  @override
  String get tutorialSettingsTitle => 'Settings and Safety';

  @override
  String get tutorialSettingsBody =>
      'Settings lets you change language, use the calculator, open this tutorial again, export CSV, and make backups to the Downloads folder.';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get backupSaving => 'Saving backup...';

  @override
  String get backupAutoDaily => 'Auto backup: daily';

  @override
  String get backupSavedBackups => 'Saved Backups';

  @override
  String get backupNoneYet => 'No backups yet';

  @override
  String get backupLatest => 'Latest';

  @override
  String get exportTitle => 'CSV Export';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get exportDateRange => 'Date Range';

  @override
  String get exportFrom => 'From';

  @override
  String get exportTo => 'To';

  @override
  String get exportIncludes => 'This file includes:';

  @override
  String get exportIncludesDeliveries => 'Deliveries (confirmed)';

  @override
  String get exportIncludesPayments => 'Payments';

  @override
  String get exportIncludesExpenses => 'Expenses';

  @override
  String get exportIncludesOtherIncome => 'Other income';

  @override
  String get exportPreparing => 'Preparing file...';

  @override
  String get exportCreateShare => 'Create and Share CSV';

  @override
  String get exportSavedNotice =>
      'The file is also saved to Downloads/DoodHisaab/';

  @override
  String get reportGrossProfitTitle => 'Gross Profit';

  @override
  String get reportGrossProfitFormula =>
      'Milk revenue + other income - expenses';

  @override
  String get reportCollectionsNote =>
      'Customer collections are shown below and are not added to profit.';

  @override
  String get reportNoRecordsMonth => 'No records for this month';

  @override
  String get reportIncomeSection => 'Income';

  @override
  String get reportMilkRevenue => 'Milk Revenue';

  @override
  String get reportTotalLiters => 'Total Liters';

  @override
  String get reportOtherIncome => 'Other Income';

  @override
  String get reportExpensesSection => 'Expenses';

  @override
  String get reportTotalExpenses => 'Total Expenses';

  @override
  String get reportCashCollections => 'Cash Collections';

  @override
  String get reportReceivedFromCustomers => 'Received from Customers';

  @override
  String get reportActiveCustomers => 'Active Customers';

  @override
  String get deliveryInvalidQuantity => 'Enter a valid milk quantity first.';

  @override
  String get deliveryEntryCleared => 'Entry cleared for this customer.';

  @override
  String get deliveryAllSkipped =>
      'No deliveries were recorded. All customers were skipped.';

  @override
  String get deliveryExitTitle => 'Exit delivery?';

  @override
  String get deliveryExitWithProgress =>
      'Yes will save your current delivery progress and close this screen. Cancel will keep you in delivery entry.';

  @override
  String get deliveryExitWithoutProgress =>
      'Yes will close delivery entry. Cancel will keep you on this screen.';

  @override
  String get deliveryExitYes => 'Yes';

  @override
  String get deliveryProgressSaved =>
      'Delivery progress saved. You can continue it later.';

  @override
  String get deliveryNeedOneBeforeFinish =>
      'Add at least one delivery before finishing.';

  @override
  String get deliveryFinishNowTitle => 'Finish delivery now?';

  @override
  String get deliveryFinishNowBody =>
      'Saved deliveries will be finalized now. Remaining customers will stay unrecorded for today.';

  @override
  String get deliveryFinishAction => 'Finish';

  @override
  String get deliveryStatusRecorded => 'Recorded for today';

  @override
  String get deliveryStatusSkipped => 'Skipped for today';

  @override
  String get deliveryStatusReady => 'Ready to confirm';

  @override
  String get deliveryStatusNotRecorded => 'Not recorded yet';

  @override
  String get deliveryUpdateFinalEntry => 'Update final entry';

  @override
  String get deliveryUpdateEntry => 'Update entry';

  @override
  String get deliveryConfirmFinalEntry => 'Confirm final entry';

  @override
  String get deliveryConfirmEntry => 'Confirm entry';

  @override
  String get deliverySkippedLabel => 'Customer skipped for today';

  @override
  String get deliverySkipLabel => 'Skip customer for today';

  @override
  String get deliveryClearRecordedEntry => 'Clear recorded entry';

  @override
  String get deliveryClearEntry => 'Clear this entry';

  @override
  String get deliverySaveExitAction => 'Save and exit';

  @override
  String get deliveryQuantityLabel => 'Quantity (liters)';

  @override
  String get deliveryLitersZero => '0 liters';

  @override
  String deliveryLitersValue(String qty) {
    return '$qty liters';
  }

  @override
  String deliveryPricePerLiter(String price) {
    return '₹$price/liter';
  }

  @override
  String deliveryAdvance(String amount) {
    return 'Advance: ₹$amount';
  }

  @override
  String get deliveryTotalValue => 'Total value';
}
