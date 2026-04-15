import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('pa')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DoodHisaab'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get navCustomers;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @btnConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btnConfirm;

  /// No description provided for @btnSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save All'**
  String get btnSaveAll;

  /// No description provided for @btnCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// No description provided for @btnNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get btnNext;

  /// No description provided for @btnBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get btnBack;

  /// No description provided for @btnSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get btnSkip;

  /// No description provided for @btnDone.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get btnDone;

  /// No description provided for @btnAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get btnAddCustomer;

  /// No description provided for @btnAddPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get btnAddPayment;

  /// No description provided for @btnBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Backup Now'**
  String get btnBackupNow;

  /// No description provided for @btnSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// No description provided for @labelPricePerLiter.
  ///
  /// In en, this message translates to:
  /// **'Price per Liter'**
  String get labelPricePerLiter;

  /// No description provided for @labelDefaultQty.
  ///
  /// In en, this message translates to:
  /// **'Default Daily Quantity'**
  String get labelDefaultQty;

  /// No description provided for @labelCustomerName.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get labelCustomerName;

  /// No description provided for @labelPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get labelPhone;

  /// No description provided for @hintNameExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Ahmad Khan'**
  String get hintNameExample;

  /// No description provided for @hintPhoneLater.
  ///
  /// In en, this message translates to:
  /// **'You can add phone and payment schedule later'**
  String get hintPhoneLater;

  /// No description provided for @successSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get successSaved;

  /// No description provided for @successSavedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s records are complete'**
  String get successSavedSubtitle;

  /// No description provided for @recoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Incomplete Session'**
  String get recoveryTitle;

  /// No description provided for @recoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off or start fresh?'**
  String get recoveryBody;

  /// No description provided for @recoveryContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get recoveryContinue;

  /// No description provided for @recoveryRestart.
  ///
  /// In en, this message translates to:
  /// **'Start Over'**
  String get recoveryRestart;

  /// No description provided for @warningUnusualTitle.
  ///
  /// In en, this message translates to:
  /// **'Is this correct?'**
  String get warningUnusualTitle;

  /// No description provided for @warningUnusualBody.
  ///
  /// In en, this message translates to:
  /// **'{name}: {qty}L today? (usually {defaultQty}L)'**
  String warningUnusualBody(String name, String qty, String defaultQty);

  /// No description provided for @warningConfirmSafe.
  ///
  /// In en, this message translates to:
  /// **'← No, enter {defaultQty}L'**
  String warningConfirmSafe(String defaultQty);

  /// No description provided for @warningConfirmDangerous.
  ///
  /// In en, this message translates to:
  /// **'Yes, {qty}L is correct'**
  String warningConfirmDangerous(String qty);

  /// No description provided for @balanceOwed.
  ///
  /// In en, this message translates to:
  /// **'Balance: ₹{amount}'**
  String balanceOwed(String amount);

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @served.
  ///
  /// In en, this message translates to:
  /// **'Served'**
  String get served;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'Liters'**
  String get liters;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @startDelivery.
  ///
  /// In en, this message translates to:
  /// **'Start Delivery'**
  String get startDelivery;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @noDairyToday.
  ///
  /// In en, this message translates to:
  /// **'No deliveries recorded for today yet'**
  String get noDairyToday;

  /// No description provided for @deliverySummary.
  ///
  /// In en, this message translates to:
  /// **'{count} customers received {liters} liters today'**
  String deliverySummary(int count, String liters);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get settingsPricing;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsData;

  /// No description provided for @settingsMilkPrice.
  ///
  /// In en, this message translates to:
  /// **'Milk Price'**
  String get settingsMilkPrice;

  /// No description provided for @settingsMilkPriceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View current price and history'**
  String get settingsMilkPriceSubtitle;

  /// No description provided for @settingsSetPin.
  ///
  /// In en, this message translates to:
  /// **'Set PIN'**
  String get settingsSetPin;

  /// No description provided for @settingsChangePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get settingsChangePin;

  /// No description provided for @settingsSetPinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect the app with a PIN'**
  String get settingsSetPinSubtitle;

  /// No description provided for @settingsChangePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new 4-digit PIN'**
  String get settingsChangePinSubtitle;

  /// No description provided for @settingsRemovePin.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN'**
  String get settingsRemovePin;

  /// No description provided for @settingsRemovePinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App will open without a PIN'**
  String get settingsRemovePinSubtitle;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save into Downloads/DoodHisaab/'**
  String get settingsBackupSubtitle;

  /// No description provided for @settingsExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get settingsExportCsv;

  /// No description provided for @settingsExportCsvSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a spreadsheet-friendly file'**
  String get settingsExportCsvSubtitle;

  /// No description provided for @settingsPrivacyTerms.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Terms'**
  String get settingsPrivacyTerms;

  /// No description provided for @settingsPrivacyTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read simple privacy and app rules'**
  String get settingsPrivacyTermsSubtitle;

  /// No description provided for @settingsDataSafety.
  ///
  /// In en, this message translates to:
  /// **'Data Safety'**
  String get settingsDataSafety;

  /// No description provided for @settingsDataSafetySubtitle.
  ///
  /// In en, this message translates to:
  /// **'What happens if the phone is lost or damaged?'**
  String get settingsDataSafetySubtitle;

  /// No description provided for @privacySimpleTitle.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get privacySimpleTitle;

  /// No description provided for @privacySimpleBody.
  ///
  /// In en, this message translates to:
  /// **'This app helps you keep milk records, payments, income, and expenses on your phone.'**
  String get privacySimpleBody;

  /// No description provided for @privacyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get privacyDataTitle;

  /// No description provided for @privacyDataBody.
  ///
  /// In en, this message translates to:
  /// **'Your records stay on your phone. We do not sell your personal details.'**
  String get privacyDataBody;

  /// No description provided for @privacyAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Small app usage data'**
  String get privacyAnalyticsTitle;

  /// No description provided for @privacyAnalyticsBody.
  ///
  /// In en, this message translates to:
  /// **'To improve the app, we only see simple app use. No name. No phone number. No money details.'**
  String get privacyAnalyticsBody;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @pinSet.
  ///
  /// In en, this message translates to:
  /// **'PIN set'**
  String get pinSet;

  /// No description provided for @pinChanged.
  ///
  /// In en, this message translates to:
  /// **'PIN changed'**
  String get pinChanged;

  /// No description provided for @pinRemoved.
  ///
  /// In en, this message translates to:
  /// **'PIN removed'**
  String get pinRemoved;

  /// No description provided for @removePinTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove PIN?'**
  String get removePinTitle;

  /// No description provided for @removePinBody.
  ///
  /// In en, this message translates to:
  /// **'The app will open without a PIN after removal.'**
  String get removePinBody;

  /// No description provided for @removeAction.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeAction;

  /// No description provided for @searchByName.
  ///
  /// In en, this message translates to:
  /// **'Search by name...'**
  String get searchByName;

  /// No description provided for @closeAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeAction;

  /// No description provided for @searchAction.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchAction;

  /// No description provided for @reorderAction.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorderAction;

  /// No description provided for @paymentAction.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentAction;

  /// No description provided for @historyAction.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAction;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers yet'**
  String get noCustomersYet;

  /// No description provided for @addFirstCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add your first customer'**
  String get addFirstCustomer;

  /// No description provided for @paymentReceivedNudge.
  ///
  /// In en, this message translates to:
  /// **'Did you collect any payment today?'**
  String get paymentReceivedNudge;

  /// No description provided for @paymentRecordYes.
  ///
  /// In en, this message translates to:
  /// **'Yes, record it'**
  String get paymentRecordYes;

  /// No description provided for @paymentRecordNo.
  ///
  /// In en, this message translates to:
  /// **'No, later'**
  String get paymentRecordNo;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Set Milk Price'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Add First Customer'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStartBtn.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Start'**
  String get onboardingStartBtn;

  /// No description provided for @dataWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep Your Data Safe'**
  String get dataWarningTitle;

  /// No description provided for @dataWarningBody.
  ///
  /// In en, this message translates to:
  /// **'All your data is stored on this phone.\n\nIf the phone is lost or damaged, data may be lost.\n\nWeekly backup is saved automatically to the Downloads folder.\nYou can also back up now from Settings.'**
  String get dataWarningBody;

  /// No description provided for @dataWarningOk.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get dataWarningOk;

  /// No description provided for @backupSavedAt.
  ///
  /// In en, this message translates to:
  /// **'Backup saved: {path}'**
  String backupSavedAt(String path);

  /// No description provided for @reportTabStatements.
  ///
  /// In en, this message translates to:
  /// **'Statements'**
  String get reportTabStatements;

  /// No description provided for @reportTabPL.
  ///
  /// In en, this message translates to:
  /// **'Profit & Loss'**
  String get reportTabPL;

  /// No description provided for @expensesNudge.
  ///
  /// In en, this message translates to:
  /// **'Add expenses to see accurate profit'**
  String get expensesNudge;

  /// No description provided for @outdoorModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Use in bright sunlight'**
  String get outdoorModeLabel;

  /// No description provided for @priceStaleBanner.
  ///
  /// In en, this message translates to:
  /// **'Your last price is 30 days old. Has the price changed?'**
  String get priceStaleBanner;

  /// No description provided for @skipToday.
  ///
  /// In en, this message translates to:
  /// **'Skip Today'**
  String get skipToday;

  /// No description provided for @previousCustomer.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousCustomer;

  /// No description provided for @defaultQtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Default: {qty}L'**
  String defaultQtyLabel(String qty);

  /// No description provided for @balanceClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get balanceClear;

  /// No description provided for @dailyLitersShort.
  ///
  /// In en, this message translates to:
  /// **'{liters} L daily'**
  String dailyLitersShort(String liters);

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to Start'**
  String get onboardingReadyTitle;

  /// No description provided for @onboardingPriceSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Milk Price'**
  String get onboardingPriceSummaryLabel;

  /// No description provided for @onboardingFirstCustomerSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'First Customer'**
  String get onboardingFirstCustomerSummaryLabel;

  /// No description provided for @onboardingDailyQtySummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Quantity'**
  String get onboardingDailyQtySummaryLabel;

  /// No description provided for @onboardingCanSetupLater.
  ///
  /// In en, this message translates to:
  /// **'You can add price and customers later'**
  String get onboardingCanSetupLater;

  /// No description provided for @litersValue.
  ///
  /// In en, this message translates to:
  /// **'{qty} L'**
  String litersValue(String qty);

  /// No description provided for @priceSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Milk Price'**
  String get priceSettingsTitle;

  /// No description provided for @priceSaved.
  ///
  /// In en, this message translates to:
  /// **'Price saved'**
  String get priceSaved;

  /// No description provided for @currentPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get currentPriceLabel;

  /// No description provided for @newPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter New Price (₹ / L)'**
  String get newPriceLabel;

  /// No description provided for @optionalNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get optionalNoteLabel;

  /// No description provided for @priceHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Price History'**
  String get priceHistoryTitle;

  /// No description provided for @noPriceYet.
  ///
  /// In en, this message translates to:
  /// **'No prices yet'**
  String get noPriceYet;

  /// No description provided for @noPriceSet.
  ///
  /// In en, this message translates to:
  /// **'Price not set'**
  String get noPriceSet;

  /// No description provided for @priceDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String priceDateLabel(String date);

  /// No description provided for @pricePerLiterValue.
  ///
  /// In en, this message translates to:
  /// **'₹{price} / L'**
  String pricePerLiterValue(String price);

  /// No description provided for @priceStaleWarning.
  ///
  /// In en, this message translates to:
  /// **'Price is older than 30 days'**
  String get priceStaleWarning;

  /// No description provided for @noteExamplePrice.
  ///
  /// In en, this message translates to:
  /// **'Example: New season price'**
  String get noteExamplePrice;

  /// No description provided for @settingsCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get settingsCalculator;

  /// No description provided for @settingsCalculatorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Open a basic calculator'**
  String get settingsCalculatorSubtitle;

  /// No description provided for @settingsHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get settingsHelp;

  /// No description provided for @settingsTutorial.
  ///
  /// In en, this message translates to:
  /// **'Tutorial'**
  String get settingsTutorial;

  /// No description provided for @settingsTutorialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn how delivery, reports, and backup work'**
  String get settingsTutorialSubtitle;

  /// No description provided for @calculatorTitle.
  ///
  /// In en, this message translates to:
  /// **'Basic Calculator'**
  String get calculatorTitle;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Use DoodHisaab'**
  String get tutorialTitle;

  /// No description provided for @tutorialHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Start from Home'**
  String get tutorialHomeTitle;

  /// No description provided for @tutorialHomeBody.
  ///
  /// In en, this message translates to:
  /// **'Use Start Delivery for milk entry, Record Payment for collections, and the quick tiles for expenses, income, and price changes.'**
  String get tutorialHomeBody;

  /// No description provided for @tutorialDeliveryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Flow'**
  String get tutorialDeliveryTitle;

  /// No description provided for @tutorialDeliveryBody.
  ///
  /// In en, this message translates to:
  /// **'Select a customer, enter liters, then confirm. A green check appears for customers already recorded for today.'**
  String get tutorialDeliveryBody;

  /// No description provided for @tutorialSaveTitle.
  ///
  /// In en, this message translates to:
  /// **'Save and Exit'**
  String get tutorialSaveTitle;

  /// No description provided for @tutorialSaveBody.
  ///
  /// In en, this message translates to:
  /// **'Use the green save button on the top right if you want to stop in the middle. Your current delivery progress will reopen later.'**
  String get tutorialSaveBody;

  /// No description provided for @tutorialReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports and Profit'**
  String get tutorialReportsTitle;

  /// No description provided for @tutorialReportsBody.
  ///
  /// In en, this message translates to:
  /// **'Reports shows customer balances, profit and loss, liters, income, expenses, and cash collections for the month.'**
  String get tutorialReportsBody;

  /// No description provided for @tutorialSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings and Safety'**
  String get tutorialSettingsTitle;

  /// No description provided for @tutorialSettingsBody.
  ///
  /// In en, this message translates to:
  /// **'Settings lets you change language, use the calculator, open this tutorial again, export CSV, and make backups to the Downloads folder.'**
  String get tutorialSettingsBody;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @backupSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving backup...'**
  String get backupSaving;

  /// No description provided for @backupAutoDaily.
  ///
  /// In en, this message translates to:
  /// **'Auto backup: daily'**
  String get backupAutoDaily;

  /// No description provided for @backupSavedBackups.
  ///
  /// In en, this message translates to:
  /// **'Saved Backups'**
  String get backupSavedBackups;

  /// No description provided for @backupNoneYet.
  ///
  /// In en, this message translates to:
  /// **'No backups yet'**
  String get backupNoneYet;

  /// No description provided for @backupLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest'**
  String get backupLatest;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'CSV Export'**
  String get exportTitle;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @exportDateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get exportDateRange;

  /// No description provided for @exportFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get exportFrom;

  /// No description provided for @exportTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get exportTo;

  /// No description provided for @exportIncludes.
  ///
  /// In en, this message translates to:
  /// **'This file includes:'**
  String get exportIncludes;

  /// No description provided for @exportIncludesDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries (confirmed)'**
  String get exportIncludesDeliveries;

  /// No description provided for @exportIncludesPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get exportIncludesPayments;

  /// No description provided for @exportIncludesExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get exportIncludesExpenses;

  /// No description provided for @exportIncludesOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other income'**
  String get exportIncludesOtherIncome;

  /// No description provided for @exportPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing file...'**
  String get exportPreparing;

  /// No description provided for @exportCreateShare.
  ///
  /// In en, this message translates to:
  /// **'Create and Share CSV'**
  String get exportCreateShare;

  /// No description provided for @exportSavedNotice.
  ///
  /// In en, this message translates to:
  /// **'The file is also saved to Downloads/DoodHisaab/'**
  String get exportSavedNotice;

  /// No description provided for @reportGrossProfitTitle.
  ///
  /// In en, this message translates to:
  /// **'Gross Profit'**
  String get reportGrossProfitTitle;

  /// No description provided for @reportGrossProfitFormula.
  ///
  /// In en, this message translates to:
  /// **'Milk revenue + other income - expenses'**
  String get reportGrossProfitFormula;

  /// No description provided for @reportCollectionsNote.
  ///
  /// In en, this message translates to:
  /// **'Customer collections are shown below and are not added to profit.'**
  String get reportCollectionsNote;

  /// No description provided for @reportNoRecordsMonth.
  ///
  /// In en, this message translates to:
  /// **'No records for this month'**
  String get reportNoRecordsMonth;

  /// No description provided for @reportIncomeSection.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get reportIncomeSection;

  /// No description provided for @reportMilkRevenue.
  ///
  /// In en, this message translates to:
  /// **'Milk Revenue'**
  String get reportMilkRevenue;

  /// No description provided for @reportTotalLiters.
  ///
  /// In en, this message translates to:
  /// **'Total Liters'**
  String get reportTotalLiters;

  /// No description provided for @reportOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get reportOtherIncome;

  /// No description provided for @reportExpensesSection.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportExpensesSection;

  /// No description provided for @reportTotalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get reportTotalExpenses;

  /// No description provided for @reportCashCollections.
  ///
  /// In en, this message translates to:
  /// **'Cash Collections'**
  String get reportCashCollections;

  /// No description provided for @reportReceivedFromCustomers.
  ///
  /// In en, this message translates to:
  /// **'Received from Customers'**
  String get reportReceivedFromCustomers;

  /// No description provided for @reportActiveCustomers.
  ///
  /// In en, this message translates to:
  /// **'Active Customers'**
  String get reportActiveCustomers;

  /// No description provided for @deliveryInvalidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid milk quantity first.'**
  String get deliveryInvalidQuantity;

  /// No description provided for @deliveryEntryCleared.
  ///
  /// In en, this message translates to:
  /// **'Entry cleared for this customer.'**
  String get deliveryEntryCleared;

  /// No description provided for @deliveryAllSkipped.
  ///
  /// In en, this message translates to:
  /// **'No deliveries were recorded. All customers were skipped.'**
  String get deliveryAllSkipped;

  /// No description provided for @deliveryExitTitle.
  ///
  /// In en, this message translates to:
  /// **'Exit delivery?'**
  String get deliveryExitTitle;

  /// No description provided for @deliveryExitWithProgress.
  ///
  /// In en, this message translates to:
  /// **'Yes will save your current delivery progress and close this screen. Cancel will keep you in delivery entry.'**
  String get deliveryExitWithProgress;

  /// No description provided for @deliveryExitWithoutProgress.
  ///
  /// In en, this message translates to:
  /// **'Yes will close delivery entry. Cancel will keep you on this screen.'**
  String get deliveryExitWithoutProgress;

  /// No description provided for @deliveryExitYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get deliveryExitYes;

  /// No description provided for @deliveryProgressSaved.
  ///
  /// In en, this message translates to:
  /// **'Delivery progress saved. You can continue it later.'**
  String get deliveryProgressSaved;

  /// No description provided for @deliveryNeedOneBeforeFinish.
  ///
  /// In en, this message translates to:
  /// **'Add at least one delivery before finishing.'**
  String get deliveryNeedOneBeforeFinish;

  /// No description provided for @deliveryFinishNowTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish delivery now?'**
  String get deliveryFinishNowTitle;

  /// No description provided for @deliveryFinishNowBody.
  ///
  /// In en, this message translates to:
  /// **'Saved deliveries will be finalized now. Remaining customers will stay unrecorded for today.'**
  String get deliveryFinishNowBody;

  /// No description provided for @deliveryFinishAction.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get deliveryFinishAction;

  /// No description provided for @deliveryStatusRecorded.
  ///
  /// In en, this message translates to:
  /// **'Recorded for today'**
  String get deliveryStatusRecorded;

  /// No description provided for @deliveryStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped for today'**
  String get deliveryStatusSkipped;

  /// No description provided for @deliveryStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready to confirm'**
  String get deliveryStatusReady;

  /// No description provided for @deliveryStatusNotRecorded.
  ///
  /// In en, this message translates to:
  /// **'Not recorded yet'**
  String get deliveryStatusNotRecorded;

  /// No description provided for @deliveryUpdateFinalEntry.
  ///
  /// In en, this message translates to:
  /// **'Update final entry'**
  String get deliveryUpdateFinalEntry;

  /// No description provided for @deliveryUpdateEntry.
  ///
  /// In en, this message translates to:
  /// **'Update entry'**
  String get deliveryUpdateEntry;

  /// No description provided for @deliveryConfirmFinalEntry.
  ///
  /// In en, this message translates to:
  /// **'Confirm final entry'**
  String get deliveryConfirmFinalEntry;

  /// No description provided for @deliveryConfirmEntry.
  ///
  /// In en, this message translates to:
  /// **'Confirm entry'**
  String get deliveryConfirmEntry;

  /// No description provided for @deliverySkippedLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer skipped for today'**
  String get deliverySkippedLabel;

  /// No description provided for @deliverySkipLabel.
  ///
  /// In en, this message translates to:
  /// **'Skip customer for today'**
  String get deliverySkipLabel;

  /// No description provided for @deliveryClearRecordedEntry.
  ///
  /// In en, this message translates to:
  /// **'Clear recorded entry'**
  String get deliveryClearRecordedEntry;

  /// No description provided for @deliveryClearEntry.
  ///
  /// In en, this message translates to:
  /// **'Clear this entry'**
  String get deliveryClearEntry;

  /// No description provided for @deliverySaveExitAction.
  ///
  /// In en, this message translates to:
  /// **'Save and exit'**
  String get deliverySaveExitAction;

  /// No description provided for @deliveryQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (liters)'**
  String get deliveryQuantityLabel;

  /// No description provided for @deliveryLitersZero.
  ///
  /// In en, this message translates to:
  /// **'0 liters'**
  String get deliveryLitersZero;

  /// No description provided for @deliveryLitersValue.
  ///
  /// In en, this message translates to:
  /// **'{qty} liters'**
  String deliveryLitersValue(String qty);

  /// No description provided for @deliveryPricePerLiter.
  ///
  /// In en, this message translates to:
  /// **'₹{price}/liter'**
  String deliveryPricePerLiter(String price);

  /// No description provided for @deliveryAdvance.
  ///
  /// In en, this message translates to:
  /// **'Advance: ₹{amount}'**
  String deliveryAdvance(String amount);

  /// No description provided for @deliveryTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total value'**
  String get deliveryTotalValue;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
