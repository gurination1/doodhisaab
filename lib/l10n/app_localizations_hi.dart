// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'दूध हिसाब';

  @override
  String get navHome => 'होम';

  @override
  String get navCustomers => 'ग्राहक';

  @override
  String get navReports => 'रिपोर्ट';

  @override
  String get navSettings => 'सेटिंग';

  @override
  String get btnConfirm => 'पुष्टि करें';

  @override
  String get btnSaveAll => 'सब सहेजें';

  @override
  String get btnCancel => 'रद्द करें';

  @override
  String get btnNext => 'आगे';

  @override
  String get btnBack => 'पीछे';

  @override
  String get btnSkip => 'छोड़ें';

  @override
  String get btnDone => 'ठीक है';

  @override
  String get btnAddCustomer => 'नया ग्राहक';

  @override
  String get btnAddPayment => 'भुगतान दर्ज करें';

  @override
  String get btnBackupNow => 'अभी बैकअप लें';

  @override
  String get btnSave => 'सहेजें';

  @override
  String get labelPricePerLiter => 'प्रति लीटर कीमत';

  @override
  String get labelDefaultQty => 'डिफ़ॉल्ट दैनिक मात्रा';

  @override
  String get labelCustomerName => 'ग्राहक का नाम';

  @override
  String get labelPhone => 'फ़ोन नंबर';

  @override
  String get hintNameExample => 'जैसे: अहमद खान';

  @override
  String get hintPhoneLater => 'आप फ़ोन और भुगतान चक्र बाद में जोड़ सकते हैं';

  @override
  String get successSaved => 'सहेजा गया!';

  @override
  String get successSavedSubtitle => 'आज के रिकॉर्ड पूरे हो गए';

  @override
  String get recoveryTitle => 'अधूरा सत्र';

  @override
  String get recoveryBody =>
      'जहाँ छोड़ा था वहीं से जारी रखें या नया शुरू करें?';

  @override
  String get recoveryContinue => 'जारी रखें';

  @override
  String get recoveryRestart => 'नया शुरू करें';

  @override
  String get warningUnusualTitle => 'क्या यह सही है?';

  @override
  String warningUnusualBody(String name, String qty, String defaultQty) {
    return '$name: आज $qty लीटर? (आम तौर पर $defaultQty लीटर)';
  }

  @override
  String warningConfirmSafe(String defaultQty) {
    return '← नहीं, $defaultQty लीटर दर्ज करें';
  }

  @override
  String warningConfirmDangerous(String qty) {
    return 'हाँ, $qty लीटर सही है';
  }

  @override
  String balanceOwed(String amount) {
    return 'बकाया: ₹$amount';
  }

  @override
  String get today => 'आज';

  @override
  String get served => 'सेवा';

  @override
  String get liters => 'लीटर';

  @override
  String get customers => 'ग्राहक';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get expenses => 'खर्च';

  @override
  String get income => 'आमदनी';

  @override
  String get startDelivery => 'डिलीवरी शुरू करें';

  @override
  String get recordPayment => 'भुगतान दर्ज करें';

  @override
  String get noDairyToday => 'आज अभी कोई डेयरी दर्ज नहीं हुई';

  @override
  String deliverySummary(int count, String liters) {
    return 'आज $count ग्राहकों को $liters लीटर दिया गया';
  }

  @override
  String get settingsTitle => 'सेटिंग';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsTheme => 'थीम';

  @override
  String get settingsPricing => 'कीमत';

  @override
  String get settingsSecurity => 'सुरक्षा';

  @override
  String get settingsData => 'डेटा';

  @override
  String get settingsMilkPrice => 'दूध की कीमत';

  @override
  String get settingsMilkPriceSubtitle => 'मौजूदा कीमत और पुराना रिकॉर्ड देखें';

  @override
  String get settingsSetPin => 'पिन सेट करें';

  @override
  String get settingsChangePin => 'पिन बदलें';

  @override
  String get settingsSetPinSubtitle => 'ऐप को पिन से सुरक्षित करें';

  @override
  String get settingsChangePinSubtitle => 'नया 4 अंकों का पिन सेट करें';

  @override
  String get settingsRemovePin => 'पिन हटाएँ';

  @override
  String get settingsRemovePinSubtitle => 'ऐप बिना पिन के खुलेगी';

  @override
  String get settingsBackup => 'बैकअप';

  @override
  String get settingsBackupSubtitle => 'Downloads/DoodHisaab/ में सहेजें';

  @override
  String get settingsExportCsv => 'CSV निर्यात';

  @override
  String get settingsExportCsvSubtitle => 'स्प्रेडशीट के लिए फ़ाइल बनाएँ';

  @override
  String get settingsPrivacyTerms => 'Privacy & Terms';

  @override
  String get settingsPrivacyTermsSubtitle =>
      'Read simple privacy and app rules';

  @override
  String get settingsDataSafety => 'डेटा सुरक्षा';

  @override
  String get settingsDataSafetySubtitle =>
      'अगर फ़ोन खो जाए या खराब हो जाए तो क्या होगा?';

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
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'लाइट';

  @override
  String get themeDark => 'डार्क';

  @override
  String get pinSet => 'पिन सेट हो गया';

  @override
  String get pinChanged => 'पिन बदल गया';

  @override
  String get pinRemoved => 'पिन हटा दिया गया';

  @override
  String get removePinTitle => 'पिन हटाएँ?';

  @override
  String get removePinBody => 'हटाने के बाद ऐप बिना पिन के खुलेगी।';

  @override
  String get removeAction => 'हटाएँ';

  @override
  String get searchByName => 'नाम से खोजें...';

  @override
  String get closeAction => 'बंद करें';

  @override
  String get searchAction => 'खोजें';

  @override
  String get reorderAction => 'क्रम बदलें';

  @override
  String get paymentAction => 'भुगतान';

  @override
  String get historyAction => 'इतिहास';

  @override
  String noSearchResults(String query) {
    return '\"$query\" के लिए कोई परिणाम नहीं मिला';
  }

  @override
  String get noCustomersYet => 'अभी कोई ग्राहक नहीं';

  @override
  String get addFirstCustomer => 'अपना पहला ग्राहक जोड़ें';

  @override
  String get paymentReceivedNudge => 'क्या आपने आज कोई भुगतान लिया?';

  @override
  String get paymentRecordYes => 'हाँ, दर्ज करें';

  @override
  String get paymentRecordNo => 'नहीं, बाद में';

  @override
  String get onboardingStep1Title => 'दूध की कीमत सेट करें';

  @override
  String get onboardingStep2Title => 'पहला ग्राहक जोड़ें';

  @override
  String get onboardingStep3Title => 'शुरू करें';

  @override
  String get onboardingStartBtn => 'चलो शुरू करें';

  @override
  String get dataWarningTitle => 'अपना डेटा सुरक्षित रखें';

  @override
  String get dataWarningBody =>
      'आपका सारा डेटा इसी फ़ोन में सहेजा जाता है।\n\nअगर फ़ोन खो जाए या खराब हो जाए तो डेटा खो सकता है।\n\nसाप्ताहिक बैकअप अपने आप Downloads फ़ोल्डर में सहेजा जाता है।\nआप Settings से अभी भी बैकअप ले सकते हैं।';

  @override
  String get dataWarningOk => 'ठीक है';

  @override
  String backupSavedAt(String path) {
    return 'बैकअप सहेजा गया: $path';
  }

  @override
  String get reportTabStatements => 'स्टेटमेंट';

  @override
  String get reportTabPL => 'मुनाफ़ा और नुकसान';

  @override
  String get expensesNudge => 'सही मुनाफ़ा देखने के लिए खर्च दर्ज करें';

  @override
  String get outdoorModeLabel => 'तेज़ धूप में उपयोग करें';

  @override
  String get priceStaleBanner =>
      'आपकी पिछली कीमत 30 दिन पुरानी है। क्या कीमत बदली है?';

  @override
  String get skipToday => 'आज छोड़ें';

  @override
  String get previousCustomer => 'पिछला';

  @override
  String defaultQtyLabel(String qty) {
    return 'डिफ़ॉल्ट: $qty लीटर';
  }

  @override
  String get balanceClear => 'साफ';

  @override
  String dailyLitersShort(String liters) {
    return '$liters लीटर रोज़';
  }

  @override
  String get onboardingReadyTitle => 'शुरू करने के लिए तैयार';

  @override
  String get onboardingPriceSummaryLabel => 'दूध की कीमत';

  @override
  String get onboardingFirstCustomerSummaryLabel => 'पहला ग्राहक';

  @override
  String get onboardingDailyQtySummaryLabel => 'दैनिक मात्रा';

  @override
  String get onboardingCanSetupLater =>
      'आप कीमत और ग्राहक बाद में जोड़ सकते हैं';

  @override
  String litersValue(String qty) {
    return '$qty लीटर';
  }

  @override
  String get priceSettingsTitle => 'दूध की कीमत';

  @override
  String get priceSaved => 'कीमत सहेज ली गई';

  @override
  String get currentPriceLabel => 'मौजूदा कीमत';

  @override
  String get newPriceLabel => 'नई कीमत दर्ज करें (₹ / लीटर)';

  @override
  String get optionalNoteLabel => 'नोट (वैकल्पिक)';

  @override
  String get priceHistoryTitle => 'कीमत का इतिहास';

  @override
  String get noPriceYet => 'अभी कोई कीमत नहीं';

  @override
  String get noPriceSet => 'कीमत तय नहीं है';

  @override
  String priceDateLabel(String date) {
    return 'तारीख: $date';
  }

  @override
  String pricePerLiterValue(String price) {
    return '₹$price / लीटर';
  }

  @override
  String get priceStaleWarning => 'कीमत 30 दिन से ज़्यादा पुरानी है';

  @override
  String get noteExamplePrice => 'उदाहरण: नए सीज़न की कीमत';

  @override
  String get settingsCalculator => 'कैलकुलेटर';

  @override
  String get settingsCalculatorSubtitle => 'एक बेसिक कैलकुलेटर खोलें';

  @override
  String get settingsHelp => 'मदद';

  @override
  String get settingsTutorial => 'ट्यूटोरियल';

  @override
  String get settingsTutorialSubtitle =>
      'डिलीवरी, रिपोर्ट और बैकअप कैसे काम करते हैं देखें';

  @override
  String get calculatorTitle => 'बेसिक कैलकुलेटर';

  @override
  String get tutorialTitle => 'दूध हिसाब कैसे चलाएँ';

  @override
  String get tutorialHomeTitle => 'होम से शुरू करें';

  @override
  String get tutorialHomeBody =>
      'दूध दर्ज करने के लिए Start Delivery, वसूली के लिए Record Payment, और खर्च, आमदनी व कीमत बदलने के लिए quick tiles का उपयोग करें।';

  @override
  String get tutorialDeliveryTitle => 'डिलीवरी तरीका';

  @override
  String get tutorialDeliveryBody =>
      'ग्राहक चुनें, लीटर दर्ज करें और पुष्टि करें। जिन ग्राहकों को आज दूध दिया जा चुका है उन पर हरा टिक दिखेगा।';

  @override
  String get tutorialSaveTitle => 'सहेजें और बाहर जाएँ';

  @override
  String get tutorialSaveBody =>
      'बीच में रुकना हो तो ऊपर दाईं तरफ हरे save बटन का उपयोग करें। आपकी मौजूदा डिलीवरी बाद में फिर खुल जाएगी।';

  @override
  String get tutorialReportsTitle => 'रिपोर्ट और मुनाफ़ा';

  @override
  String get tutorialReportsBody =>
      'रिपोर्ट में ग्राहक बकाया, मुनाफ़ा-नुकसान, लीटर, आमदनी, खर्च और महीने की वसूली दिखाई जाती है।';

  @override
  String get tutorialSettingsTitle => 'सेटिंग और सुरक्षा';

  @override
  String get tutorialSettingsBody =>
      'सेटिंग में भाषा बदलें, कैलकुलेटर चलाएँ, यह ट्यूटोरियल फिर खोलें, CSV निर्यात करें और Downloads फ़ोल्डर में बैकअप बनाएँ।';

  @override
  String get backupFailed => 'बैकअप विफल हुआ';

  @override
  String get backupSaving => 'बैकअप सहेजा जा रहा है...';

  @override
  String get backupAutoDaily => 'ऑटो बैकअप: रोज़ाना';

  @override
  String get backupSavedBackups => 'सहेजे गए बैकअप';

  @override
  String get backupNoneYet => 'अभी कोई बैकअप नहीं';

  @override
  String get backupLatest => 'सबसे नया';

  @override
  String get exportTitle => 'CSV निर्यात';

  @override
  String get exportFailed => 'निर्यात विफल हुआ';

  @override
  String get exportDateRange => 'तारीख सीमा';

  @override
  String get exportFrom => 'से';

  @override
  String get exportTo => 'तक';

  @override
  String get exportIncludes => 'इस फ़ाइल में शामिल है:';

  @override
  String get exportIncludesDeliveries => 'डिलीवरी (पुष्ट)';

  @override
  String get exportIncludesPayments => 'भुगतान';

  @override
  String get exportIncludesExpenses => 'खर्च';

  @override
  String get exportIncludesOtherIncome => 'अन्य आमदनी';

  @override
  String get exportPreparing => 'फ़ाइल तैयार की जा रही है...';

  @override
  String get exportCreateShare => 'CSV बनाएँ और शेयर करें';

  @override
  String get exportSavedNotice =>
      'यह फ़ाइल Downloads/DoodHisaab/ में भी सहेजी जाती है।';

  @override
  String get reportGrossProfitTitle => 'कुल मुनाफ़ा';

  @override
  String get reportGrossProfitFormula => 'दूध की आमदनी + अन्य आमदनी - खर्च';

  @override
  String get reportCollectionsNote =>
      'नीचे दिखाई गई ग्राहक वसूली मुनाफ़े में नहीं जोड़ी जाती।';

  @override
  String get reportNoRecordsMonth => 'इस महीने के लिए कोई रिकॉर्ड नहीं';

  @override
  String get reportIncomeSection => 'आमदनी';

  @override
  String get reportMilkRevenue => 'दूध की आमदनी';

  @override
  String get reportTotalLiters => 'कुल लीटर';

  @override
  String get reportOtherIncome => 'अन्य आमदनी';

  @override
  String get reportExpensesSection => 'खर्च';

  @override
  String get reportTotalExpenses => 'कुल खर्च';

  @override
  String get reportCashCollections => 'नकद वसूली';

  @override
  String get reportReceivedFromCustomers => 'ग्राहकों से प्राप्त';

  @override
  String get reportActiveCustomers => 'सक्रिय ग्राहक';

  @override
  String get deliveryInvalidQuantity => 'पहले सही दूध मात्रा दर्ज करें।';

  @override
  String get deliveryEntryCleared => 'इस ग्राहक की एंट्री साफ कर दी गई है।';

  @override
  String get deliveryAllSkipped =>
      'कोई डिलीवरी दर्ज नहीं हुई। सभी ग्राहकों को छोड़ दिया गया।';

  @override
  String get deliveryExitTitle => 'डिलीवरी से बाहर निकलें?';

  @override
  String get deliveryExitWithProgress =>
      'हाँ दबाने पर मौजूदा डिलीवरी प्रगति सहेज दी जाएगी और यह स्क्रीन बंद हो जाएगी। Cancel दबाने पर आप यहीं रहेंगे।';

  @override
  String get deliveryExitWithoutProgress =>
      'हाँ दबाने पर डिलीवरी स्क्रीन बंद हो जाएगी। Cancel दबाने पर आप यहीं रहेंगे।';

  @override
  String get deliveryExitYes => 'हाँ';

  @override
  String get deliveryProgressSaved =>
      'डिलीवरी प्रगति सहेज ली गई है। आप इसे बाद में जारी रख सकते हैं।';

  @override
  String get deliveryNeedOneBeforeFinish =>
      'खत्म करने से पहले कम से कम एक डिलीवरी जोड़ें।';

  @override
  String get deliveryFinishNowTitle => 'अभी डिलीवरी समाप्त करें?';

  @override
  String get deliveryFinishNowBody =>
      'जो डिलीवरी सहेजी गई हैं उन्हें अभी पक्का कर दिया जाएगा। बाकी ग्राहक आज के लिए बिना दर्ज रहेंगे।';

  @override
  String get deliveryFinishAction => 'समाप्त करें';

  @override
  String get deliveryStatusRecorded => 'आज के लिए दर्ज';

  @override
  String get deliveryStatusSkipped => 'आज के लिए छोड़ा गया';

  @override
  String get deliveryStatusReady => 'पुष्टि के लिए तैयार';

  @override
  String get deliveryStatusNotRecorded => 'अभी दर्ज नहीं';

  @override
  String get deliveryUpdateFinalEntry => 'आखिरी एंट्री अपडेट करें';

  @override
  String get deliveryUpdateEntry => 'एंट्री अपडेट करें';

  @override
  String get deliveryConfirmFinalEntry => 'आखिरी एंट्री पुष्टि करें';

  @override
  String get deliveryConfirmEntry => 'एंट्री पुष्टि करें';

  @override
  String get deliverySkippedLabel => 'ग्राहक आज के लिए छोड़ा गया';

  @override
  String get deliverySkipLabel => 'ग्राहक को आज के लिए छोड़ें';

  @override
  String get deliveryClearRecordedEntry => 'दर्ज एंट्री साफ करें';

  @override
  String get deliveryClearEntry => 'यह एंट्री साफ करें';

  @override
  String get deliverySaveExitAction => 'सहेजें और बाहर जाएँ';

  @override
  String get deliveryQuantityLabel => 'मात्रा (लीटर)';

  @override
  String get deliveryLitersZero => '0 लीटर';

  @override
  String deliveryLitersValue(String qty) {
    return '$qty लीटर';
  }

  @override
  String deliveryPricePerLiter(String price) {
    return '₹$price/लीटर';
  }

  @override
  String deliveryAdvance(String amount) {
    return 'अग्रिम: ₹$amount';
  }

  @override
  String get deliveryTotalValue => 'कुल कीमत';
}
