// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'تسبيح رقمي';

  @override
  String get goodMorning => 'صباح الخير ☀️';

  @override
  String get goodAfternoon => 'مساء الخير 🌤️';

  @override
  String get goodEvening => 'مساء الخير 🌅';

  @override
  String get goodNight => 'تصبح على خير 🌙';

  @override
  String get keepConnected => 'حافظ على اتصال قلبك';

  @override
  String get continueWazifa => 'استمر في الوظيفة';

  @override
  String get quickDhikr => 'ذكر سريع';

  @override
  String get myWazifas => 'وظائفي';

  @override
  String get allAzkaar => 'جميع الأذكار';

  @override
  String get createWazifa => 'إنشاء وظيفة';

  @override
  String get noCustomWazifas => 'لا توجد وظائف مخصصة بعد';

  @override
  String get noCustomWazifasSubtitle => 'أنشئ وظائفك الخاصة للبدء';

  @override
  String get remaining => 'متبقي';

  @override
  String get completed => 'تم الانتهاء!';

  @override
  String get mashaAllahCompleted => 'ماشاء الله! تم الانتهاء';

  @override
  String get round => 'الجولة';

  @override
  String get tap => 'اضغط';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get saveAndExit => 'حفظ وخروج';

  @override
  String get resetProgressTitle => 'إعادة تعيين التقدم؟';

  @override
  String get resetProgressMessage =>
      'سيتم إعادة العدد الحالي إلى الصفر. سيتم الاحتفاظ بإعدادات الذكر.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get selectDhikr => 'اختر الذكر';

  @override
  String get defaultAzkaar => 'الأذكار الافتراضية';

  @override
  String get start => 'ابدأ';

  @override
  String get continue_ => 'استمر';

  @override
  String get edit => 'تعديل';

  @override
  String get delete => 'حذف';

  @override
  String get deleteWazifaTitle => 'حذف الوظيفة؟';

  @override
  String deleteWazifaMessage(Object name) {
    return 'هل أنت متأكد أنك تريد حذف \"$name\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get dhikrName => 'اسم الذكر';

  @override
  String get dhikrNameHint => 'مثال: أستغفر الله';

  @override
  String get arabicText => 'النص العربي (اختياري)';

  @override
  String get arabicTextHint => 'أَسْتَغْفِرُ ٱللَّٰهَ';

  @override
  String get transliteration => 'النطق (اختياري)';

  @override
  String get transliterationHint => 'أستغفر الله';

  @override
  String get translation => 'الترجمة (اختياري)';

  @override
  String get translationHint => 'أطلب المغفرة من الله';

  @override
  String get targetCount => 'الهدف';

  @override
  String get targetCountHint => 'مثال: 100';

  @override
  String get repeatMode => 'وضع التكرار';

  @override
  String get repeatModeSubtitle => 'ابدأ جولة جديدة تلقائياً بعد الانتهاء';

  @override
  String get dailyReminder => 'تذكير يومي';

  @override
  String get dailyReminderSubtitle => 'احصل على إشعار لتأدية هذا الذكر';

  @override
  String get reminderTime => 'وقت التذكير';

  @override
  String get notSet => 'غير محدد';

  @override
  String get startDate => 'تاريخ البدء (اختياري)';

  @override
  String get today => 'اليوم';

  @override
  String get numberOfDays => 'عدد الأيام (اختياري)';

  @override
  String get numberOfDaysHint => 'مثال: 7';

  @override
  String get notes => 'ملاحظات (اختياري)';

  @override
  String get notesHint => 'أي ملاحظات إضافية...';

  @override
  String get create => 'إنشاء';

  @override
  String get update => 'تحديث';

  @override
  String get settings => 'الإعدادات';

  @override
  String get appearance => 'المظهر';

  @override
  String get theme => 'السمة';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get counting => 'العد';

  @override
  String get volumeKeyCounting => 'عد بأزرار الصوت';

  @override
  String get volumeKeyCountingSubtitle => 'استخدم أزرار الصوت للعد';

  @override
  String get countingVibration => 'اهتزاز العد';

  @override
  String get countingSound => 'صوت العد';

  @override
  String get completion => 'الانتهاء';

  @override
  String get completionVibration => 'اهتزاز الانتهاء';

  @override
  String get completionSound => 'صوت الانتهاء';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notificationPermission => 'إذن الإشعارات';

  @override
  String get granted => 'مسموح';

  @override
  String get notGranted => 'غير مسموح';

  @override
  String get enable => 'تمكين';

  @override
  String get reminderNotifications => 'إشعارات التذكير';

  @override
  String get reminderNotificationsSubtitle => 'استلم تذكيرات يومية';

  @override
  String get defaultReminderTime => 'وقت التذكير الافتراضي';

  @override
  String get language => 'اللغة';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageUrdu => 'الأردية';

  @override
  String get languageSystem => 'النظام';

  @override
  String get app => 'التطبيق';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get checkForUpdates => 'التحقق من التحديثات';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get about => 'حول';

  @override
  String get version => 'الإصدار';

  @override
  String get onboardingTitle1 => 'تسبيح رقمي';

  @override
  String get onboardingDesc1 =>
      'احسب أذكارك اليومية بعداد رقمي سلس وجميل. اضغط الزر أو استخدم أزرار الصوت.';

  @override
  String get onboardingTitle2 => 'وظائف مخصصة';

  @override
  String get onboardingDesc2 =>
      'أنشئ وظائفك الخاصة بأهداف وجداول وتذكيرات مخصصة.';

  @override
  String get onboardingTitle3 => 'تذكيرات يومية';

  @override
  String get onboardingDesc3 =>
      'عين تذكيراتك حتى لا تفوتك ممارسة الأذكار اليومية.';

  @override
  String get onboardingTitle4 => 'حفظ واستمرار';

  @override
  String get onboardingDesc4 =>
      'يتم حفظ تقدمك تلقائياً. استمر من حيث توقفت بالضبط.';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'البدء';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get chooseLanguageSubtitle => 'اختر لغتك المفضلة للتطبيق';

  @override
  String get couldNotOpenReview => 'تعذر فتح المراجعة';

  @override
  String get onLatestVersion => 'أنت على أحدث إصدار';

  @override
  String get couldNotCheckUpdates => 'تعذر التحقق من التحديثات';

  @override
  String get validationRequired => 'هذا الحقل مطلوب';

  @override
  String get validationNumber => 'يرجى إدخال رقم صحيح';

  @override
  String get validationMin => 'يجب أن يكون على الأقل 1';

  @override
  String get moreOptions => 'المزيد من الخيارات';

  @override
  String get moreOptionsSubtitle =>
      'النص العربي، التذكيرات، الجدول، الملاحظات...';
}
