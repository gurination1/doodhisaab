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
}
