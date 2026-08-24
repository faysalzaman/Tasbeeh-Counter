import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
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
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ar'),
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Digital Tasbeeh'**
  String get appName;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning ☀️'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon 🌤️'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening 🌅'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good Night 🌙'**
  String get goodNight;

  /// No description provided for @keepConnected.
  ///
  /// In en, this message translates to:
  /// **'Keep your heart connected'**
  String get keepConnected;

  /// No description provided for @continueWazifa.
  ///
  /// In en, this message translates to:
  /// **'Continue Wazifa'**
  String get continueWazifa;

  /// No description provided for @quickDhikr.
  ///
  /// In en, this message translates to:
  /// **'Quick Dhikr'**
  String get quickDhikr;

  /// No description provided for @myWazifas.
  ///
  /// In en, this message translates to:
  /// **'My Wazifas'**
  String get myWazifas;

  /// No description provided for @allAzkaar.
  ///
  /// In en, this message translates to:
  /// **'All Azkaar'**
  String get allAzkaar;

  /// No description provided for @createWazifa.
  ///
  /// In en, this message translates to:
  /// **'Create Wazifa'**
  String get createWazifa;

  /// No description provided for @noCustomWazifas.
  ///
  /// In en, this message translates to:
  /// **'No custom wazifas yet'**
  String get noCustomWazifas;

  /// No description provided for @noCustomWazifasSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your own wazifas to get started'**
  String get noCustomWazifasSubtitle;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed!'**
  String get completed;

  /// No description provided for @mashaAllahCompleted.
  ///
  /// In en, this message translates to:
  /// **'MashaAllah! Completed'**
  String get mashaAllahCompleted;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @tap.
  ///
  /// In en, this message translates to:
  /// **'Tap'**
  String get tap;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @saveAndExit.
  ///
  /// In en, this message translates to:
  /// **'Save & Exit'**
  String get saveAndExit;

  /// No description provided for @resetProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress?'**
  String get resetProgressTitle;

  /// No description provided for @resetProgressMessage.
  ///
  /// In en, this message translates to:
  /// **'This will reset the current count to zero. The Dhikr configuration will be preserved.'**
  String get resetProgressMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @selectDhikr.
  ///
  /// In en, this message translates to:
  /// **'Select Dhikr'**
  String get selectDhikr;

  /// No description provided for @defaultAzkaar.
  ///
  /// In en, this message translates to:
  /// **'Default Azkaar'**
  String get defaultAzkaar;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @continue_.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continue_;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteWazifaTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Wazifa?'**
  String get deleteWazifaTitle;

  /// No description provided for @deleteWazifaMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteWazifaMessage(Object name);

  /// No description provided for @dhikrName.
  ///
  /// In en, this message translates to:
  /// **'Dhikr Name'**
  String get dhikrName;

  /// No description provided for @dhikrNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Astaghfirullah'**
  String get dhikrNameHint;

  /// No description provided for @arabicText.
  ///
  /// In en, this message translates to:
  /// **'Arabic Text (Optional)'**
  String get arabicText;

  /// No description provided for @arabicTextHint.
  ///
  /// In en, this message translates to:
  /// **'أَسْتَغْفِرُ ٱللَّٰهَ'**
  String get arabicTextHint;

  /// No description provided for @transliteration.
  ///
  /// In en, this message translates to:
  /// **'Transliteration (Optional)'**
  String get transliteration;

  /// No description provided for @transliterationHint.
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get transliterationHint;

  /// No description provided for @translation.
  ///
  /// In en, this message translates to:
  /// **'Translation (Optional)'**
  String get translation;

  /// No description provided for @translationHint.
  ///
  /// In en, this message translates to:
  /// **'I seek forgiveness from Allah'**
  String get translationHint;

  /// No description provided for @targetCount.
  ///
  /// In en, this message translates to:
  /// **'Target Count'**
  String get targetCount;

  /// No description provided for @targetCountHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 100'**
  String get targetCountHint;

  /// No description provided for @repeatMode.
  ///
  /// In en, this message translates to:
  /// **'Repeat Mode'**
  String get repeatMode;

  /// No description provided for @repeatModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically start a new round after completion'**
  String get repeatModeSubtitle;

  /// No description provided for @dailyReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get dailyReminder;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified to perform this Dhikr'**
  String get dailyReminderSubtitle;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date (Optional)'**
  String get startDate;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @numberOfDays.
  ///
  /// In en, this message translates to:
  /// **'Number of Days (Optional)'**
  String get numberOfDays;

  /// No description provided for @numberOfDaysHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 7'**
  String get numberOfDaysHint;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Any additional notes...'**
  String get notesHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

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

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @counting.
  ///
  /// In en, this message translates to:
  /// **'Counting'**
  String get counting;

  /// No description provided for @volumeKeyCounting.
  ///
  /// In en, this message translates to:
  /// **'Volume Key Counting'**
  String get volumeKeyCounting;

  /// No description provided for @volumeKeyCountingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use volume buttons to count'**
  String get volumeKeyCountingSubtitle;

  /// No description provided for @countingVibration.
  ///
  /// In en, this message translates to:
  /// **'Counting Vibration'**
  String get countingVibration;

  /// No description provided for @countingSound.
  ///
  /// In en, this message translates to:
  /// **'Counting Sound'**
  String get countingSound;

  /// No description provided for @completion.
  ///
  /// In en, this message translates to:
  /// **'Completion'**
  String get completion;

  /// No description provided for @completionVibration.
  ///
  /// In en, this message translates to:
  /// **'Completion Vibration'**
  String get completionVibration;

  /// No description provided for @completionSound.
  ///
  /// In en, this message translates to:
  /// **'Completion Sound'**
  String get completionSound;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @notGranted.
  ///
  /// In en, this message translates to:
  /// **'Not granted'**
  String get notGranted;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @reminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Reminder Notifications'**
  String get reminderNotifications;

  /// No description provided for @reminderNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive daily reminders'**
  String get reminderNotificationsSubtitle;

  /// No description provided for @defaultReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Default Reminder Time'**
  String get defaultReminderTime;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for Updates'**
  String get checkForUpdates;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Digital Tasbeeh'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Count your daily Dhikr with a smooth, beautiful digital counter. Tap the button or use volume keys.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Custom Wazifas'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Create your own Wazifas with custom targets, schedules, and reminders.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Daily Reminders'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Set reminders so you never miss your daily Dhikr practice.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingTitle4.
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get onboardingTitle4;

  /// No description provided for @onboardingDesc4.
  ///
  /// In en, this message translates to:
  /// **'Your progress is automatically saved. Continue exactly where you left off.'**
  String get onboardingDesc4;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @chooseLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app'**
  String get chooseLanguageSubtitle;

  /// No description provided for @couldNotOpenReview.
  ///
  /// In en, this message translates to:
  /// **'Could not open review'**
  String get couldNotOpenReview;

  /// No description provided for @onLatestVersion.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get onLatestVersion;

  /// No description provided for @couldNotCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get couldNotCheckUpdates;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// No description provided for @validationNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validationNumber;

  /// No description provided for @validationMin.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 1'**
  String get validationMin;
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
      <String>['ar', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
