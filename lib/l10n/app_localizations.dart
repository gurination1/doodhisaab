import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ur.dart';

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
    Locale('pa'),
    Locale('ur')
  ];

  /// No description provided for @appName.
  ///
  /// In ur, this message translates to:
  /// **'دودھ حساب'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In ur, this message translates to:
  /// **'ہوم'**
  String get navHome;

  /// No description provided for @navCustomers.
  ///
  /// In ur, this message translates to:
  /// **'گاہک'**
  String get navCustomers;

  /// No description provided for @navReports.
  ///
  /// In ur, this message translates to:
  /// **'رپورٹ'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In ur, this message translates to:
  /// **'سیٹنگز'**
  String get navSettings;

  /// No description provided for @btnConfirm.
  ///
  /// In ur, this message translates to:
  /// **'تصدیق کریں'**
  String get btnConfirm;

  /// No description provided for @btnSaveAll.
  ///
  /// In ur, this message translates to:
  /// **'سب محفوظ کریں'**
  String get btnSaveAll;

  /// No description provided for @btnCancel.
  ///
  /// In ur, this message translates to:
  /// **'منسوخ'**
  String get btnCancel;

  /// No description provided for @btnNext.
  ///
  /// In ur, this message translates to:
  /// **'آگے'**
  String get btnNext;

  /// No description provided for @btnBack.
  ///
  /// In ur, this message translates to:
  /// **'پیچھے'**
  String get btnBack;

  /// No description provided for @btnSkip.
  ///
  /// In ur, this message translates to:
  /// **'چھوڑیں'**
  String get btnSkip;

  /// No description provided for @btnDone.
  ///
  /// In ur, this message translates to:
  /// **'ٹھیک ہے'**
  String get btnDone;

  /// No description provided for @btnAddCustomer.
  ///
  /// In ur, this message translates to:
  /// **'نیا گاہک'**
  String get btnAddCustomer;

  /// No description provided for @btnAddPayment.
  ///
  /// In ur, this message translates to:
  /// **'ادائیگی درج کریں'**
  String get btnAddPayment;

  /// No description provided for @btnBackupNow.
  ///
  /// In ur, this message translates to:
  /// **'ابھی بیک اپ لیں'**
  String get btnBackupNow;

  /// No description provided for @labelPricePerLiter.
  ///
  /// In ur, this message translates to:
  /// **'فی لیٹر دودھ کی قیمت'**
  String get labelPricePerLiter;

  /// No description provided for @labelDefaultQty.
  ///
  /// In ur, this message translates to:
  /// **'عام یومیہ مقدار'**
  String get labelDefaultQty;

  /// No description provided for @labelCustomerName.
  ///
  /// In ur, this message translates to:
  /// **'گاہک کا نام'**
  String get labelCustomerName;

  /// No description provided for @labelPhone.
  ///
  /// In ur, this message translates to:
  /// **'فون نمبر'**
  String get labelPhone;

  /// No description provided for @hintNameExample.
  ///
  /// In ur, this message translates to:
  /// **'مثلاً: احمد خان'**
  String get hintNameExample;

  /// No description provided for @hintPhoneLater.
  ///
  /// In ur, this message translates to:
  /// **'آپ بعد میں فون اور ادائیگی کا طریقہ شامل کر سکتے ہیں'**
  String get hintPhoneLater;

  /// No description provided for @successSaved.
  ///
  /// In ur, this message translates to:
  /// **'محفوظ ہو گیا!'**
  String get successSaved;

  /// No description provided for @successSavedSubtitle.
  ///
  /// In ur, this message translates to:
  /// **'آج کا حساب مکمل ہو گیا'**
  String get successSavedSubtitle;

  /// No description provided for @recoveryTitle.
  ///
  /// In ur, this message translates to:
  /// **'آج کا کام ادھورا ہے'**
  String get recoveryTitle;

  /// No description provided for @recoveryBody.
  ///
  /// In ur, this message translates to:
  /// **'جاری رکھیں یا شروع سے شروع کریں؟'**
  String get recoveryBody;

  /// No description provided for @recoveryContinue.
  ///
  /// In ur, this message translates to:
  /// **'جاری رکھیں'**
  String get recoveryContinue;

  /// No description provided for @recoveryRestart.
  ///
  /// In ur, this message translates to:
  /// **'شروع سے'**
  String get recoveryRestart;

  /// No description provided for @warningUnusualTitle.
  ///
  /// In ur, this message translates to:
  /// **'کیا یہ درست ہے؟'**
  String get warningUnusualTitle;

  /// No description provided for @warningUnusualBody.
  ///
  /// In ur, this message translates to:
  /// **'{name}: آج {qty} لیٹر؟ (عام طور پر {defaultQty} لیٹر)'**
  String warningUnusualBody(String name, String qty, String defaultQty);

  /// No description provided for @warningConfirmSafe.
  ///
  /// In ur, this message translates to:
  /// **'← نہیں، {defaultQty} لیٹر درج کریں'**
  String warningConfirmSafe(String defaultQty);

  /// No description provided for @warningConfirmDangerous.
  ///
  /// In ur, this message translates to:
  /// **'ہاں، {qty} لیٹر درست ہے'**
  String warningConfirmDangerous(String qty);

  /// No description provided for @balanceOwed.
  ///
  /// In ur, this message translates to:
  /// **'باقی: ₹{amount}'**
  String balanceOwed(String amount);

  /// No description provided for @paymentReceivedNudge.
  ///
  /// In ur, this message translates to:
  /// **'کیا آپ نے آج کوئی ادائیگی وصول کی؟'**
  String get paymentReceivedNudge;

  /// No description provided for @paymentRecordYes.
  ///
  /// In ur, this message translates to:
  /// **'ہاں، درج کریں'**
  String get paymentRecordYes;

  /// No description provided for @paymentRecordNo.
  ///
  /// In ur, this message translates to:
  /// **'نہیں، بعد میں'**
  String get paymentRecordNo;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In ur, this message translates to:
  /// **'دودھ کی قیمت مقرر کریں'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In ur, this message translates to:
  /// **'پہلا گاہک شامل کریں'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In ur, this message translates to:
  /// **'شروع کریں'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStartBtn.
  ///
  /// In ur, this message translates to:
  /// **'شروع کریں'**
  String get onboardingStartBtn;

  /// No description provided for @dataWarningTitle.
  ///
  /// In ur, this message translates to:
  /// **'اپنا ڈیٹا محفوظ رکھیں'**
  String get dataWarningTitle;

  /// No description provided for @dataWarningBody.
  ///
  /// In ur, this message translates to:
  /// **'آپ کا تمام ڈیٹا اس فون میں محفوظ ہے۔\n\nاگر فون گم ہو یا خراب ہو تو ڈیٹا ضائع ہو سکتا ہے۔\n\nہفتہ وار بیک اپ خودبخود ڈاؤن لوڈز فولڈر میں محفوظ ہوتا ہے۔\nآپ سیٹنگز میں جا کر ابھی بیک اپ لے سکتے ہیں۔'**
  String get dataWarningBody;

  /// No description provided for @dataWarningOk.
  ///
  /// In ur, this message translates to:
  /// **'سمجھ گیا'**
  String get dataWarningOk;

  /// No description provided for @backupSavedAt.
  ///
  /// In ur, this message translates to:
  /// **'بیک اپ محفوظ ہو گیا: {path}'**
  String backupSavedAt(String path);

  /// No description provided for @reportTabStatements.
  ///
  /// In ur, this message translates to:
  /// **'حسابات'**
  String get reportTabStatements;

  /// No description provided for @reportTabPL.
  ///
  /// In ur, this message translates to:
  /// **'آمدنی و اخراجات'**
  String get reportTabPL;

  /// No description provided for @expensesNudge.
  ///
  /// In ur, this message translates to:
  /// **'اخراجات درج کریں تاکہ درست منافع دیکھ سکیں'**
  String get expensesNudge;

  /// No description provided for @outdoorModeLabel.
  ///
  /// In ur, this message translates to:
  /// **'دھوپ میں استعمال کریں'**
  String get outdoorModeLabel;

  /// No description provided for @priceStaleBanner.
  ///
  /// In ur, this message translates to:
  /// **'آپ کی آخری قیمت ۳۰ دن پرانی ہے۔ کیا قیمت بدلی ہے؟'**
  String get priceStaleBanner;

  /// No description provided for @skipToday.
  ///
  /// In ur, this message translates to:
  /// **'آج نہیں'**
  String get skipToday;

  /// No description provided for @previousCustomer.
  ///
  /// In ur, this message translates to:
  /// **'پچھلا'**
  String get previousCustomer;

  /// No description provided for @defaultQtyLabel.
  ///
  /// In ur, this message translates to:
  /// **'عام مقدار: {qty} لیٹر'**
  String defaultQtyLabel(String qty);
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
      <String>['en', 'pa', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pa':
      return AppLocalizationsPa();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
