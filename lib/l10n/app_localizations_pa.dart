// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Panjabi Punjabi (`pa`).
class AppLocalizationsPa extends AppLocalizations {
  AppLocalizationsPa([String locale = 'pa']) : super(locale);

  @override
  String get appName => 'دودھ حساب';

  @override
  String get navHome => 'ہوم';

  @override
  String get navCustomers => 'گاہک';

  @override
  String get navReports => 'رپورٹ';

  @override
  String get navSettings => 'سیٹنگز';

  @override
  String get btnConfirm => 'تصدیق کریں';

  @override
  String get btnSaveAll => 'سب محفوظ کریں';

  @override
  String get btnCancel => 'منسوخ';

  @override
  String get btnNext => 'آگے';

  @override
  String get btnBack => 'پیچھے';

  @override
  String get btnSkip => 'چھوڑیں';

  @override
  String get btnDone => 'ٹھیک ہے';

  @override
  String get btnAddCustomer => 'نیا گاہک';

  @override
  String get btnAddPayment => 'ادائیگی درج کریں';

  @override
  String get btnBackupNow => 'ابھی بیک اپ لیں';

  @override
  String get labelPricePerLiter => 'فی لیٹر دودھ کی قیمت';

  @override
  String get labelDefaultQty => 'عام یومیہ مقدار';

  @override
  String get labelCustomerName => 'گاہک کا نام';

  @override
  String get labelPhone => 'فون نمبر';

  @override
  String get hintNameExample => 'مثلاً: احمد خان';

  @override
  String get hintPhoneLater =>
      'آپ بعد میں فون اور ادائیگی کا طریقہ شامل کر سکتے ہیں';

  @override
  String get successSaved => 'محفوظ ہو گیا!';

  @override
  String get successSavedSubtitle => 'آج کا حساب مکمل ہو گیا';

  @override
  String get recoveryTitle => 'آج کا کام ادھورا ہے';

  @override
  String get recoveryBody => 'جاری رکھیں یا شروع سے شروع کریں؟';

  @override
  String get recoveryContinue => 'جاری رکھیں';

  @override
  String get recoveryRestart => 'شروع سے';

  @override
  String get warningUnusualTitle => 'کیا یہ درست ہے؟';

  @override
  String warningUnusualBody(String name, String qty, String defaultQty) {
    return '$name: آج $qty لیٹر؟ (عام طور پر $defaultQty لیٹر)';
  }

  @override
  String warningConfirmSafe(String defaultQty) {
    return '← نہیں، $defaultQty لیٹر درج کریں';
  }

  @override
  String warningConfirmDangerous(String qty) {
    return 'ہاں، $qty لیٹر درست ہے';
  }

  @override
  String balanceOwed(String amount) {
    return 'باقی: ₹$amount';
  }

  @override
  String get paymentReceivedNudge => 'کیا آپ نے آج کوئی ادائیگی وصول کی؟';

  @override
  String get paymentRecordYes => 'ہاں، درج کریں';

  @override
  String get paymentRecordNo => 'نہیں، بعد میں';

  @override
  String get onboardingStep1Title => 'دودھ کی قیمت مقرر کریں';

  @override
  String get onboardingStep2Title => 'پہلا گاہک شامل کریں';

  @override
  String get onboardingStep3Title => 'شروع کریں';

  @override
  String get onboardingStartBtn => 'شروع کریں';

  @override
  String get dataWarningTitle => 'اپنا ڈیٹا محفوظ رکھیں';

  @override
  String get dataWarningBody =>
      'آپ کا تمام ڈیٹا اس فون میں محفوظ ہے۔\n\nاگر فون گم ہو یا خراب ہو تو ڈیٹا ضائع ہو سکتا ہے۔\n\nہفتہ وار بیک اپ خودبخود ڈاؤن لوڈز فولڈر میں محفوظ ہوتا ہے۔\nآپ سیٹنگز میں جا کر ابھی بیک اپ لے سکتے ہیں۔';

  @override
  String get dataWarningOk => 'سمجھ گیا';

  @override
  String backupSavedAt(String path) {
    return 'بیک اپ محفوظ ہو گیا: $path';
  }

  @override
  String get reportTabStatements => 'حسابات';

  @override
  String get reportTabPL => 'آمدنی و اخراجات';

  @override
  String get expensesNudge => 'اخراجات درج کریں تاکہ درست منافع دیکھ سکیں';

  @override
  String get outdoorModeLabel => 'دھوپ میں استعمال کریں';

  @override
  String get priceStaleBanner =>
      'آپ کی آخری قیمت ۳۰ دن پرانی ہے۔ کیا قیمت بدلی ہے؟';

  @override
  String get skipToday => 'آج نہیں';

  @override
  String get previousCustomer => 'پچھلا';

  @override
  String defaultQtyLabel(String qty) {
    return 'عام مقدار: $qty لیٹر';
  }
}
