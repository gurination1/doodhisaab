// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appName => 'ਦੂਧ ਹਿਸਾਬ';

  @override
  String get navHome => 'ਹੋਮ';

  @override
  String get navCustomers => 'ਗਾਹਕ';

  @override
  String get navReports => 'ਰਿਪੋਰਟਾਂ';

  @override
  String get navSettings => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get btnConfirm => 'ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get btnSaveAll => 'ਸਭ ਸੰਭਾਲੋ';

  @override
  String get btnCancel => 'ਰੱਦ ਕਰੋ';

  @override
  String get btnNext => 'ਅੱਗੇ';

  @override
  String get btnBack => 'ਪਿੱਛੇ';

  @override
  String get btnSkip => 'ਛੱਡੋ';

  @override
  String get btnDone => 'ਠੀਕ ਹੈ';

  @override
  String get btnAddCustomer => 'ਨਵਾਂ ਗਾਹਕ';

  @override
  String get btnAddPayment => 'ਭੁਗਤਾਨ ਦਰਜ ਕਰੋ';

  @override
  String get btnBackupNow => 'ਹੁਣੇ ਬੈਕਅੱਪ ਲਓ';

  @override
  String get btnSave => 'ਸੰਭਾਲੋ';

  @override
  String get labelPricePerLiter => 'ਪ੍ਰਤੀ ਲੀਟਰ ਕੀਮਤ';

  @override
  String get labelDefaultQty => 'ਰੋਜ਼ਾਨਾ ਮਿਆਰੀ ਮਾਤਰਾ';

  @override
  String get labelCustomerName => 'ਗਾਹਕ ਦਾ ਨਾਮ';

  @override
  String get labelPhone => 'ਫੋਨ ਨੰਬਰ';

  @override
  String get hintNameExample => 'ਜਿਵੇਂ: ਅਹਿਮਦ ਖਾਨ';

  @override
  String get hintPhoneLater =>
      'ਤੁਸੀਂ ਫੋਨ ਅਤੇ ਭੁਗਤਾਨ ਚੱਕਰ ਬਾਅਦ ਵਿੱਚ ਜੋੜ ਸਕਦੇ ਹੋ';

  @override
  String get successSaved => 'ਸੰਭਾਲਿਆ ਗਿਆ!';

  @override
  String get successSavedSubtitle => 'ਅੱਜ ਦੇ ਰਿਕਾਰਡ ਪੂਰੇ ਹੋ ਗਏ';

  @override
  String get recoveryTitle => 'ਅਧੂਰਾ ਸੈਸ਼ਨ';

  @override
  String get recoveryBody =>
      'ਜਿੱਥੇ ਛੱਡਿਆ ਸੀ ਉੱਥੋਂ ਜਾਰੀ ਰੱਖਣਾ ਹੈ ਜਾਂ ਨਵਾਂ ਸ਼ੁਰੂ ਕਰਨਾ ਹੈ?';

  @override
  String get recoveryContinue => 'ਜਾਰੀ ਰੱਖੋ';

  @override
  String get recoveryRestart => 'ਨਵਾਂ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get warningUnusualTitle => 'ਕੀ ਇਹ ਠੀਕ ਹੈ?';

  @override
  String warningUnusualBody(String name, String qty, String defaultQty) {
    return '$name: ਅੱਜ $qty ਲੀਟਰ? (ਆਮ ਤੌਰ \'ਤੇ $defaultQty ਲੀਟਰ)';
  }

  @override
  String warningConfirmSafe(String defaultQty) {
    return '← ਨਹੀਂ, $defaultQty ਲੀਟਰ ਦਰਜ ਕਰੋ';
  }

  @override
  String warningConfirmDangerous(String qty) {
    return 'ਹਾਂ, $qty ਲੀਟਰ ਠੀਕ ਹੈ';
  }

  @override
  String balanceOwed(String amount) {
    return 'ਬਕਾਇਆ: ₹$amount';
  }

  @override
  String get today => 'ਅੱਜ';

  @override
  String get served => 'ਸਪਲਾਈ';

  @override
  String get liters => 'ਲੀਟਰ';

  @override
  String get customers => 'ਗਾਹਕ';

  @override
  String get reports => 'ਰਿਪੋਰਟਾਂ';

  @override
  String get expenses => 'ਖਰਚੇ';

  @override
  String get income => 'ਆਮਦਨੀ';

  @override
  String get startDelivery => 'ਡਿਲੀਵਰੀ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get recordPayment => 'ਭੁਗਤਾਨ ਦਰਜ ਕਰੋ';

  @override
  String get noDairyToday => 'ਅੱਜ ਕੋਈ ਡੇਅਰੀ ਦਰਜ ਨਹੀਂ ਹੋਈ';

  @override
  String deliverySummary(int count, String liters) {
    return 'ਅੱਜ $count ਗਾਹਕਾਂ ਨੂੰ $liters ਲੀਟਰ ਦਿੱਤਾ ਗਿਆ';
  }

  @override
  String get settingsTitle => 'ਸੈਟਿੰਗਾਂ';

  @override
  String get settingsLanguage => 'ਭਾਸ਼ਾ';

  @override
  String get settingsTheme => 'ਥੀਮ';

  @override
  String get settingsPricing => 'ਕੀਮਤ';

  @override
  String get settingsSecurity => 'ਸੁਰੱਖਿਆ';

  @override
  String get settingsData => 'ਡਾਟਾ';

  @override
  String get settingsMilkPrice => 'ਦੁੱਧ ਦੀ ਕੀਮਤ';

  @override
  String get settingsMilkPriceSubtitle => 'ਮੌਜੂਦਾ ਕੀਮਤ ਅਤੇ ਪਿਛਲਾ ਰਿਕਾਰਡ ਵੇਖੋ';

  @override
  String get settingsSetPin => 'ਪਿਨ ਸੈੱਟ ਕਰੋ';

  @override
  String get settingsChangePin => 'ਪਿਨ ਬਦਲੋ';

  @override
  String get settingsSetPinSubtitle => 'ਐਪ ਨੂੰ ਪਿਨ ਨਾਲ ਸੁਰੱਖਿਅਤ ਕਰੋ';

  @override
  String get settingsChangePinSubtitle => 'ਨਵਾਂ 4 ਅੰਕਾਂ ਵਾਲਾ ਪਿਨ ਸੈੱਟ ਕਰੋ';

  @override
  String get settingsRemovePin => 'ਪਿਨ ਹਟਾਓ';

  @override
  String get settingsRemovePinSubtitle => 'ਐਪ ਬਿਨਾਂ ਪਿਨ ਦੇ ਖੁੱਲੇਗੀ';

  @override
  String get settingsBackup => 'ਬੈਕਅੱਪ';

  @override
  String get settingsBackupSubtitle => 'Downloads/DoodHisaab/ ਵਿੱਚ ਸੰਭਾਲੋ';

  @override
  String get settingsExportCsv => 'CSV ਐਕਸਪੋਰਟ ਕਰੋ';

  @override
  String get settingsExportCsvSubtitle => 'ਸਪ੍ਰੈਡਸ਼ੀਟ ਲਈ ਫਾਈਲ ਬਣਾਓ';

  @override
  String get settingsPrivacyTerms => 'ਪਰਾਈਵੇਸੀ ਅਤੇ ਨਿਯਮ';

  @override
  String get settingsPrivacyTermsSubtitle => 'ਸੌਖੇ ਨਿਯਮ ਅਤੇ ਪਰਾਈਵੇਸੀ ਪੜ੍ਹੋ';

  @override
  String get settingsDataSafety => 'ਡਾਟਾ ਸੁਰੱਖਿਆ';

  @override
  String get settingsDataSafetySubtitle =>
      'ਜੇ ਫੋਨ ਗੁੰਮ ਜਾਂ ਖਰਾਬ ਹੋ ਜਾਵੇ ਤਾਂ ਕੀ ਹੋਵੇਗਾ?';

  @override
  String get privacySimpleTitle => 'ਇਸ ਐਪ ਬਾਰੇ';

  @override
  String get privacySimpleBody =>
      'ਇਹ ਐਪ ਦੁੱਧ ਦਾ ਹਿਸਾਬ, ਭੁਗਤਾਨ, ਆਮਦਨੀ ਅਤੇ ਖਰਚੇ ਫੋਨ ਵਿੱਚ ਰੱਖਦੀ ਹੈ।';

  @override
  String get privacyDataTitle => 'ਤੁਹਾਡਾ ਡਾਟਾ';

  @override
  String get privacyDataBody =>
      'ਤੁਹਾਡਾ ਰਿਕਾਰਡ ਤੁਹਾਡੇ ਫੋਨ ਵਿੱਚ ਰਹਿੰਦਾ ਹੈ। ਅਸੀਂ ਤੁਹਾਡੀ ਨਿੱਜੀ ਜਾਣਕਾਰੀ ਨਹੀਂ ਵੇਚਦੇ।';

  @override
  String get privacyAnalyticsTitle => 'ਛੋਟੀ ਵਰਤੋਂ ਜਾਣਕਾਰੀ';

  @override
  String get privacyAnalyticsBody =>
      'ਐਪ ਨੂੰ ਚੰਗਾ ਕਰਨ ਲਈ ਅਸੀਂ ਸਿਰਫ਼ ਸੌਖੀ ਵਰਤੋਂ ਦੇਖਦੇ ਹਾਂ। ਕੋਈ ਨਾਮ ਨਹੀਂ। ਕੋਈ ਫੋਨ ਨੰਬਰ ਨਹੀਂ। ਕੋਈ ਪੈਸੇ ਦੀ ਜਾਣਕਾਰੀ ਨਹੀਂ।';

  @override
  String get themeSystem => 'ਸਿਸਟਮ';

  @override
  String get themeLight => 'ਲਾਈਟ';

  @override
  String get themeDark => 'ਡਾਰਕ';

  @override
  String get pinSet => 'ਪਿਨ ਸੈੱਟ ਹੋ ਗਿਆ';

  @override
  String get pinChanged => 'ਪਿਨ ਬਦਲ ਗਿਆ';

  @override
  String get pinRemoved => 'ਪਿਨ ਹਟਾ ਦਿੱਤਾ ਗਿਆ';

  @override
  String get removePinTitle => 'ਪਿਨ ਹਟਾਉਣਾ ਹੈ?';

  @override
  String get removePinBody => 'ਹਟਾਉਣ ਤੋਂ ਬਾਅਦ ਐਪ ਬਿਨਾਂ ਪਿਨ ਦੇ ਖੁੱਲੇਗੀ।';

  @override
  String get removeAction => 'ਹਟਾਓ';

  @override
  String get searchByName => 'ਨਾਮ ਨਾਲ ਖੋਜੋ...';

  @override
  String get closeAction => 'ਬੰਦ ਕਰੋ';

  @override
  String get searchAction => 'ਖੋਜ';

  @override
  String get reorderAction => 'ਕ੍ਰਮ ਬਦਲੋ';

  @override
  String get paymentAction => 'ਭੁਗਤਾਨ';

  @override
  String get historyAction => 'ਇਤਿਹਾਸ';

  @override
  String noSearchResults(String query) {
    return '\"$query\" ਲਈ ਕੋਈ ਨਤੀਜਾ ਨਹੀਂ ਮਿਲਿਆ';
  }

  @override
  String get noCustomersYet => 'ਹਾਲੇ ਕੋਈ ਗਾਹਕ ਨਹੀਂ';

  @override
  String get addFirstCustomer => 'ਆਪਣਾ ਪਹਿਲਾ ਗਾਹਕ ਜੋੜੋ';

  @override
  String get paymentReceivedNudge => 'ਕੀ ਤੁਸੀਂ ਅੱਜ ਕੋਈ ਭੁਗਤਾਨ ਲਿਆ?';

  @override
  String get paymentRecordYes => 'ਹਾਂ, ਦਰਜ ਕਰੋ';

  @override
  String get paymentRecordNo => 'ਨਹੀਂ, ਬਾਅਦ ਵਿੱਚ';

  @override
  String get onboardingStep1Title => 'ਦੁੱਧ ਦੀ ਕੀਮਤ ਸੈੱਟ ਕਰੋ';

  @override
  String get onboardingStep2Title => 'ਪਹਿਲਾ ਗਾਹਕ ਜੋੜੋ';

  @override
  String get onboardingStep3Title => 'ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get onboardingStartBtn => 'ਆਓ ਸ਼ੁਰੂ ਕਰੀਏ';

  @override
  String get dataWarningTitle => 'ਆਪਣਾ ਡਾਟਾ ਸੁਰੱਖਿਅਤ ਰੱਖੋ';

  @override
  String get dataWarningBody =>
      'ਤੁਹਾਡਾ ਸਾਰਾ ਡਾਟਾ ਇਸ ਫੋਨ ਵਿੱਚ ਸੰਭਾਲਿਆ ਜਾਂਦਾ ਹੈ।\n\nਜੇ ਫੋਨ ਗੁੰਮ ਜਾਂ ਖਰਾਬ ਹੋ ਜਾਵੇ ਤਾਂ ਡਾਟਾ ਖਤਮ ਹੋ ਸਕਦਾ ਹੈ।\n\nਹਫ਼ਤਾਵਾਰੀ ਬੈਕਅੱਪ ਆਪਣੇ ਆਪ Downloads ਫੋਲਡਰ ਵਿੱਚ ਸੇਵ ਹੁੰਦਾ ਹੈ।\nਤੁਸੀਂ Settings ਤੋਂ ਹੁਣੇ ਵੀ ਬੈਕਅੱਪ ਕਰ ਸਕਦੇ ਹੋ।';

  @override
  String get dataWarningOk => 'ਠੀਕ ਹੈ';

  @override
  String backupSavedAt(String path) {
    return 'ਬੈਕਅੱਪ ਸੇਵ ਹੋਇਆ: $path';
  }

  @override
  String get reportTabStatements => 'ਸਟੇਟਮੈਂਟ';

  @override
  String get reportTabPL => 'ਮੁਨਾਫ਼ਾ ਅਤੇ ਨੁਕਸਾਨ';

  @override
  String get expensesNudge => 'ਸਹੀ ਮੁਨਾਫ਼ਾ ਦੇਖਣ ਲਈ ਖਰਚੇ ਦਰਜ ਕਰੋ';

  @override
  String get outdoorModeLabel => 'ਤੇਜ਼ ਧੁੱਪ ਵਿੱਚ ਵਰਤੋਂ';

  @override
  String get priceStaleBanner =>
      'ਤੁਹਾਡੀ ਪਿਛਲੀ ਕੀਮਤ 30 ਦਿਨ ਪੁਰਾਣੀ ਹੈ। ਕੀ ਕੀਮਤ ਬਦਲੀ ਹੈ?';

  @override
  String get skipToday => 'ਅੱਜ ਛੱਡੋ';

  @override
  String get previousCustomer => 'ਪਿਛਲਾ';

  @override
  String defaultQtyLabel(String qty) {
    return 'ਮਿਆਰੀ ਮਾਤਰਾ: $qty ਲੀਟਰ';
  }

  @override
  String get balanceClear => 'ਸਾਫ਼';

  @override
  String dailyLitersShort(String liters) {
    return '$liters ਲੀਟਰ ਰੋਜ਼';
  }

  @override
  String get onboardingReadyTitle => 'ਸ਼ੁਰੂ ਕਰਨ ਲਈ ਤਿਆਰ';

  @override
  String get onboardingPriceSummaryLabel => 'ਦੁੱਧ ਦੀ ਕੀਮਤ';

  @override
  String get onboardingFirstCustomerSummaryLabel => 'ਪਹਿਲਾ ਗਾਹਕ';

  @override
  String get onboardingDailyQtySummaryLabel => 'ਰੋਜ਼ਾਨਾ ਮਾਤਰਾ';

  @override
  String get onboardingCanSetupLater =>
      'ਤੁਸੀਂ ਕੀਮਤ ਅਤੇ ਗਾਹਕ ਬਾਅਦ ਵਿੱਚ ਜੋੜ ਸਕਦੇ ਹੋ';

  @override
  String litersValue(String qty) {
    return '$qty ਲੀਟਰ';
  }

  @override
  String get priceSettingsTitle => 'ਦੁੱਧ ਦੀ ਕੀਮਤ';

  @override
  String get priceSaved => 'ਕੀਮਤ ਸੰਭਾਲ ਲਈ ਗਈ';

  @override
  String get currentPriceLabel => 'ਮੌਜੂਦਾ ਕੀਮਤ';

  @override
  String get newPriceLabel => 'ਨਵੀਂ ਕੀਮਤ ਦਰਜ ਕਰੋ (₹ / ਲੀਟਰ)';

  @override
  String get optionalNoteLabel => 'ਨੋਟ (ਚੋਣਵਾਂ)';

  @override
  String get priceHistoryTitle => 'ਕੀਮਤ ਦਾ ਇਤਿਹਾਸ';

  @override
  String get noPriceYet => 'ਹਾਲੇ ਕੋਈ ਕੀਮਤ ਨਹੀਂ';

  @override
  String get noPriceSet => 'ਕੀਮਤ ਸੈੱਟ ਨਹੀਂ ਹੈ';

  @override
  String priceDateLabel(String date) {
    return 'ਤਾਰੀਖ: $date';
  }

  @override
  String pricePerLiterValue(String price) {
    return '₹$price / ਲੀਟਰ';
  }

  @override
  String get priceStaleWarning => 'ਕੀਮਤ 30 ਦਿਨ ਤੋਂ ਵੱਧ ਪੁਰਾਣੀ ਹੈ';

  @override
  String get noteExamplePrice => 'ਉਦਾਹਰਨ: ਨਵੇਂ ਸੀਜ਼ਨ ਦੀ ਕੀਮਤ';

  @override
  String get settingsCalculator => 'ਕੈਲਕੁਲੇਟਰ';

  @override
  String get settingsCalculatorSubtitle => 'ਸਧਾਰਣ ਕੈਲਕੁਲੇਟਰ ਖੋਲ੍ਹੋ';

  @override
  String get settingsHelp => 'ਮਦਦ';

  @override
  String get settingsTutorial => 'ਟਿਊਟੋਰਿਯਲ';

  @override
  String get settingsTutorialSubtitle =>
      'ਡਿਲੀਵਰੀ, ਰਿਪੋਰਟ ਅਤੇ ਬੈਕਅੱਪ ਕਿਵੇਂ ਕੰਮ ਕਰਦੇ ਹਨ ਵੇਖੋ';

  @override
  String get calculatorTitle => 'ਬੇਸਿਕ ਕੈਲਕੁਲੇਟਰ';

  @override
  String get tutorialTitle => 'ਦੂਧ ਹਿਸਾਬ ਕਿਵੇਂ ਵਰਤਣਾ ਹੈ';

  @override
  String get tutorialHomeTitle => 'ਹੋਮ ਤੋਂ ਸ਼ੁਰੂ ਕਰੋ';

  @override
  String get tutorialHomeBody =>
      'ਦੁੱਧ ਦਰਜ ਕਰਨ ਲਈ Start Delivery ਵਰਤੋ, ਵਸੂਲੀ ਲਈ Record Payment ਵਰਤੋ, ਅਤੇ ਖਰਚੇ, ਆਮਦਨ ਤੇ ਕੀਮਤ ਬਦਲਣ ਲਈ quick tiles ਵਰਤੋ।';

  @override
  String get tutorialDeliveryTitle => 'ਡਿਲੀਵਰੀ ਤਰੀਕਾ';

  @override
  String get tutorialDeliveryBody =>
      'ਗਾਹਕ ਚੁਣੋ, ਲੀਟਰ ਦਰਜ ਕਰੋ ਅਤੇ ਪੁਸ਼ਟੀ ਕਰੋ। ਜਿਨ੍ਹਾਂ ਗਾਹਕਾਂ ਨੂੰ ਅੱਜ ਦੁੱਧ ਦੇ ਦਿੱਤਾ ਗਿਆ ਹੈ ਉਨ੍ਹਾਂ ਉੱਤੇ ਹਰਾ ਟਿਕ ਦਿਖੇਗਾ।';

  @override
  String get tutorialSaveTitle => 'ਸੰਭਾਲੋ ਅਤੇ ਬਾਹਰ ਜਾਓ';

  @override
  String get tutorialSaveBody =>
      'ਵਿਚਕਾਰ ਰੁਕਣਾ ਹੋਵੇ ਤਾਂ ਉੱਪਰ ਸੱਜੇ ਹਰੇ save ਬਟਨ ਨੂੰ ਵਰਤੋ। ਤੁਹਾਡੀ ਮੌਜੂਦਾ ਡਿਲੀਵਰੀ ਬਾਅਦ ਵਿੱਚ ਫਿਰ ਖੁਲ ਜਾਵੇਗੀ।';

  @override
  String get tutorialReportsTitle => 'ਰਿਪੋਰਟ ਅਤੇ ਮੁਨਾਫ਼ਾ';

  @override
  String get tutorialReportsBody =>
      'ਰਿਪੋਰਟ ਵਿੱਚ ਗਾਹਕ ਬਕਾਇਆ, ਮੁਨਾਫ਼ਾ-ਨੁਕਸਾਨ, ਲੀਟਰ, ਆਮਦਨ, ਖਰਚੇ ਅਤੇ ਮਹੀਨੇ ਦੀ ਵਸੂਲੀ ਦਿਖਦੀ ਹੈ।';

  @override
  String get tutorialSettingsTitle => 'ਸੈਟਿੰਗਾਂ ਅਤੇ ਸੁਰੱਖਿਆ';

  @override
  String get tutorialSettingsBody =>
      'ਸੈਟਿੰਗਾਂ ਵਿੱਚ ਭਾਸ਼ਾ ਬਦਲੋ, ਕੈਲਕੁਲੇਟਰ ਵਰਤੋ, ਇਹ ਟਿਊਟੋਰਿਯਲ ਫਿਰ ਖੋਲ੍ਹੋ, CSV ਐਕਸਪੋਰਟ ਕਰੋ ਅਤੇ Downloads ਫੋਲਡਰ ਵਿੱਚ ਬੈਕਅੱਪ ਬਣਾਓ।';

  @override
  String get backupFailed => 'ਬੈਕਅੱਪ ਫੇਲ੍ਹ ਹੋ ਗਿਆ';

  @override
  String get backupSaving => 'ਬੈਕਅੱਪ ਸੰਭਾਲਿਆ ਜਾ ਰਿਹਾ ਹੈ...';

  @override
  String get backupAutoDaily => 'ਆਟੋ ਬੈਕਅੱਪ: ਹਰ ਰੋਜ਼';

  @override
  String get backupSavedBackups => 'ਸੰਭਾਲੇ ਬੈਕਅੱਪ';

  @override
  String get backupNoneYet => 'ਹਾਲੇ ਕੋਈ ਬੈਕਅੱਪ ਨਹੀਂ';

  @override
  String get backupLatest => 'ਸਭ ਤੋਂ ਨਵਾਂ';

  @override
  String get exportTitle => 'CSV ਐਕਸਪੋਰਟ';

  @override
  String get exportFailed => 'ਐਕਸਪੋਰਟ ਫੇਲ੍ਹ ਹੋ ਗਿਆ';

  @override
  String get exportDateRange => 'ਤਾਰੀਖ ਰੇਂਜ';

  @override
  String get exportFrom => 'ਤੋਂ';

  @override
  String get exportTo => 'ਤੱਕ';

  @override
  String get exportIncludes => 'ਇਸ ਫਾਈਲ ਵਿੱਚ ਇਹ ਸ਼ਾਮਲ ਹੈ:';

  @override
  String get exportIncludesDeliveries => 'ਡਿਲੀਵਰੀਆਂ (ਪੁਸ਼ਟੀਸ਼ੁਦਾ)';

  @override
  String get exportIncludesPayments => 'ਭੁਗਤਾਨ';

  @override
  String get exportIncludesExpenses => 'ਖਰਚੇ';

  @override
  String get exportIncludesOtherIncome => 'ਹੋਰ ਆਮਦਨ';

  @override
  String get exportPreparing => 'ਫਾਈਲ ਤਿਆਰ ਕੀਤੀ ਜਾ ਰਹੀ ਹੈ...';

  @override
  String get exportCreateShare => 'CSV ਬਣਾਓ ਅਤੇ ਸਾਂਝਾ ਕਰੋ';

  @override
  String get exportSavedNotice =>
      'ਇਹ ਫਾਈਲ Downloads/DoodHisaab/ ਵਿੱਚ ਵੀ ਸੰਭਾਲੀ ਜਾਂਦੀ ਹੈ।';

  @override
  String get reportGrossProfitTitle => 'ਕੁੱਲ ਮੁਨਾਫ਼ਾ';

  @override
  String get reportGrossProfitFormula => 'ਦੁੱਧ ਆਮਦਨ + ਹੋਰ ਆਮਦਨ - ਖਰਚੇ';

  @override
  String get reportCollectionsNote =>
      'ਹੇਠਾਂ ਦਿਖਾਈ ਗਈ ਗਾਹਕ ਵਸੂਲੀ ਮੁਨਾਫ਼ੇ ਵਿੱਚ ਨਹੀਂ ਜੋੜੀ ਜਾਂਦੀ।';

  @override
  String get reportNoRecordsMonth => 'ਇਸ ਮਹੀਨੇ ਲਈ ਕੋਈ ਰਿਕਾਰਡ ਨਹੀਂ';

  @override
  String get reportIncomeSection => 'ਆਮਦਨ';

  @override
  String get reportMilkRevenue => 'ਦੁੱਧ ਦੀ ਆਮਦਨ';

  @override
  String get reportTotalLiters => 'ਕੁੱਲ ਲੀਟਰ';

  @override
  String get reportOtherIncome => 'ਹੋਰ ਆਮਦਨ';

  @override
  String get reportExpensesSection => 'ਖਰਚੇ';

  @override
  String get reportTotalExpenses => 'ਕੁੱਲ ਖਰਚੇ';

  @override
  String get reportCashCollections => 'ਨਗਦ ਵਸੂਲੀ';

  @override
  String get reportReceivedFromCustomers => 'ਗਾਹਕਾਂ ਤੋਂ ਮਿਲਿਆ';

  @override
  String get reportActiveCustomers => 'ਸਰਗਰਮ ਗਾਹਕ';

  @override
  String get deliveryInvalidQuantity => 'ਪਹਿਲਾਂ ਸਹੀ ਦੁੱਧ ਮਾਤਰਾ ਦਰਜ ਕਰੋ।';

  @override
  String get deliveryEntryCleared => 'ਇਸ ਗਾਹਕ ਦੀ ਐਂਟਰੀ ਸਾਫ਼ ਕਰ ਦਿੱਤੀ ਗਈ ਹੈ।';

  @override
  String get deliveryAllSkipped =>
      'ਕੋਈ ਡਿਲੀਵਰੀ ਦਰਜ ਨਹੀਂ ਹੋਈ। ਸਾਰੇ ਗਾਹਕ ਛੱਡੇ ਗਏ।';

  @override
  String get deliveryExitTitle => 'ਡਿਲੀਵਰੀ ਤੋਂ ਬਾਹਰ ਨਿਕਲਣਾ ਹੈ?';

  @override
  String get deliveryExitWithProgress =>
      'ਹਾਂ ਦਬਾਉਣ ਨਾਲ ਮੌਜੂਦਾ ਡਿਲੀਵਰੀ ਪ੍ਰਗਤੀ ਸੰਭਾਲੀ ਜਾਵੇਗੀ ਅਤੇ ਇਹ ਸਕ੍ਰੀਨ ਬੰਦ ਹੋ ਜਾਵੇਗੀ। Cancel ਨਾਲ ਤੁਸੀਂ ਇੱਥੇ ਹੀ ਰਹੋਗੇ।';

  @override
  String get deliveryExitWithoutProgress =>
      'ਹਾਂ ਦਬਾਉਣ ਨਾਲ ਡਿਲੀਵਰੀ ਸਕ੍ਰੀਨ ਬੰਦ ਹੋ ਜਾਵੇਗੀ। Cancel ਨਾਲ ਤੁਸੀਂ ਇੱਥੇ ਹੀ ਰਹੋਗੇ।';

  @override
  String get deliveryExitYes => 'ਹਾਂ';

  @override
  String get deliveryProgressSaved =>
      'ਡਿਲੀਵਰੀ ਪ੍ਰਗਤੀ ਸੰਭਾਲ ਲਈ ਗਈ ਹੈ। ਤੁਸੀਂ ਇਸ ਨੂੰ ਬਾਅਦ ਵਿੱਚ ਜਾਰੀ ਰੱਖ ਸਕਦੇ ਹੋ।';

  @override
  String get deliveryNeedOneBeforeFinish =>
      'ਮੁਕੰਮਲ ਕਰਨ ਤੋਂ ਪਹਿਲਾਂ ਘੱਟੋ-ਘੱਟ ਇੱਕ ਡਿਲੀਵਰੀ ਜੋੜੋ।';

  @override
  String get deliveryFinishNowTitle => 'ਹੁਣੇ ਡਿਲੀਵਰੀ ਮੁਕੰਮਲ ਕਰਨੀ ਹੈ?';

  @override
  String get deliveryFinishNowBody =>
      'ਜੋ ਡਿਲੀਵਰੀਆਂ ਸੰਭਾਲੀਆਂ ਗਈਆਂ ਹਨ ਉਹ ਹੁਣ ਪੱਕੀ ਕਰ ਦਿੱਤੀਆਂ ਜਾਣਗੀਆਂ। ਬਾਕੀ ਗਾਹਕ ਅੱਜ ਲਈ ਬਿਨਾਂ ਦਰਜ ਰਹਿਣਗੇ।';

  @override
  String get deliveryFinishAction => 'ਮੁਕੰਮਲ ਕਰੋ';

  @override
  String get deliveryStatusRecorded => 'ਅੱਜ ਲਈ ਦਰਜ ਹੈ';

  @override
  String get deliveryStatusSkipped => 'ਅੱਜ ਲਈ ਛੱਡਿਆ ਗਿਆ';

  @override
  String get deliveryStatusReady => 'ਪੁਸ਼ਟੀ ਲਈ ਤਿਆਰ';

  @override
  String get deliveryStatusNotRecorded => 'ਹਾਲੇ ਦਰਜ ਨਹੀਂ';

  @override
  String get deliveryUpdateFinalEntry => 'ਆਖਰੀ ਐਂਟਰੀ ਅਪਡੇਟ ਕਰੋ';

  @override
  String get deliveryUpdateEntry => 'ਐਂਟਰੀ ਅਪਡੇਟ ਕਰੋ';

  @override
  String get deliveryConfirmFinalEntry => 'ਆਖਰੀ ਐਂਟਰੀ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get deliveryConfirmEntry => 'ਐਂਟਰੀ ਪੁਸ਼ਟੀ ਕਰੋ';

  @override
  String get deliverySkippedLabel => 'ਗਾਹਕ ਅੱਜ ਲਈ ਛੱਡਿਆ ਗਿਆ';

  @override
  String get deliverySkipLabel => 'ਗਾਹਕ ਨੂੰ ਅੱਜ ਲਈ ਛੱਡੋ';

  @override
  String get deliveryClearRecordedEntry => 'ਦਰਜ ਐਂਟਰੀ ਸਾਫ਼ ਕਰੋ';

  @override
  String get deliveryClearEntry => 'ਇਹ ਐਂਟਰੀ ਸਾਫ਼ ਕਰੋ';

  @override
  String get deliverySaveExitAction => 'ਸੰਭਾਲੋ ਅਤੇ ਬਾਹਰ ਜਾਓ';

  @override
  String get deliveryQuantityLabel => 'ਮਾਤਰਾ (ਲੀਟਰ)';

  @override
  String get deliveryLitersZero => '0 ਲੀਟਰ';

  @override
  String deliveryLitersValue(String qty) {
    return '$qty ਲੀਟਰ';
  }

  @override
  String deliveryPricePerLiter(String price) {
    return '₹$price/ਲੀਟਰ';
  }

  @override
  String deliveryAdvance(String amount) {
    return 'ਅਡਵਾਂਸ: ₹$amount';
  }

  @override
  String get deliveryTotalValue => 'ਕੁੱਲ ਕੀਮਤ';
}
