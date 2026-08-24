// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Digital Tasbeeh';

  @override
  String get goodMorning => 'Good Morning ☀️';

  @override
  String get goodAfternoon => 'Good Afternoon 🌤️';

  @override
  String get goodEvening => 'Good Evening 🌅';

  @override
  String get goodNight => 'Good Night 🌙';

  @override
  String get keepConnected => 'Keep your heart connected';

  @override
  String get continueWazifa => 'Continue Wazifa';

  @override
  String get quickDhikr => 'Quick Dhikr';

  @override
  String get myWazifas => 'My Wazifas';

  @override
  String get allAzkaar => 'All Azkaar';

  @override
  String get createWazifa => 'Create Wazifa';

  @override
  String get noCustomWazifas => 'No custom wazifas yet';

  @override
  String get noCustomWazifasSubtitle =>
      'Create your own wazifas to get started';

  @override
  String get remaining => 'remaining';

  @override
  String get completed => 'Completed!';

  @override
  String get mashaAllahCompleted => 'MashaAllah! Completed';

  @override
  String get round => 'Round';

  @override
  String get tap => 'Tap';

  @override
  String get reset => 'Reset';

  @override
  String get saveAndExit => 'Save & Exit';

  @override
  String get resetProgressTitle => 'Reset Progress?';

  @override
  String get resetProgressMessage =>
      'This will reset the current count to zero. The Dhikr configuration will be preserved.';

  @override
  String get cancel => 'Cancel';

  @override
  String get selectDhikr => 'Select Dhikr';

  @override
  String get defaultAzkaar => 'Default Azkaar';

  @override
  String get start => 'Start';

  @override
  String get continue_ => 'Continue';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteWazifaTitle => 'Delete Wazifa?';

  @override
  String deleteWazifaMessage(Object name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get dhikrName => 'Dhikr Name';

  @override
  String get dhikrNameHint => 'e.g., Astaghfirullah';

  @override
  String get arabicText => 'Arabic Text (Optional)';

  @override
  String get arabicTextHint => 'أَسْتَغْفِرُ ٱللَّٰهَ';

  @override
  String get transliteration => 'Transliteration (Optional)';

  @override
  String get transliterationHint => 'Astaghfirullah';

  @override
  String get translation => 'Translation (Optional)';

  @override
  String get translationHint => 'I seek forgiveness from Allah';

  @override
  String get targetCount => 'Target Count';

  @override
  String get targetCountHint => 'e.g., 100';

  @override
  String get repeatMode => 'Repeat Mode';

  @override
  String get repeatModeSubtitle =>
      'Automatically start a new round after completion';

  @override
  String get dailyReminder => 'Daily Reminder';

  @override
  String get dailyReminderSubtitle => 'Get notified to perform this Dhikr';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get notSet => 'Not set';

  @override
  String get startDate => 'Start Date (Optional)';

  @override
  String get today => 'Today';

  @override
  String get numberOfDays => 'Number of Days (Optional)';

  @override
  String get numberOfDaysHint => 'e.g., 7';

  @override
  String get notes => 'Notes (Optional)';

  @override
  String get notesHint => 'Any additional notes...';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get counting => 'Counting';

  @override
  String get volumeKeyCounting => 'Volume Key Counting';

  @override
  String get volumeKeyCountingSubtitle => 'Use volume buttons to count';

  @override
  String get countingVibration => 'Counting Vibration';

  @override
  String get countingSound => 'Counting Sound';

  @override
  String get completion => 'Completion';

  @override
  String get completionVibration => 'Completion Vibration';

  @override
  String get completionSound => 'Completion Sound';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationPermission => 'Notification Permission';

  @override
  String get granted => 'Granted';

  @override
  String get notGranted => 'Not granted';

  @override
  String get enable => 'Enable';

  @override
  String get reminderNotifications => 'Reminder Notifications';

  @override
  String get reminderNotificationsSubtitle => 'Receive daily reminders';

  @override
  String get defaultReminderTime => 'Default Reminder Time';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageUrdu => 'Urdu';

  @override
  String get languageSystem => 'System';

  @override
  String get app => 'App';

  @override
  String get rateApp => 'Rate App';

  @override
  String get checkForUpdates => 'Check for Updates';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get onboardingTitle1 => 'Digital Tasbeeh';

  @override
  String get onboardingDesc1 =>
      'Count your daily Dhikr with a smooth, beautiful digital counter. Tap the button or use volume keys.';

  @override
  String get onboardingTitle2 => 'Custom Wazifas';

  @override
  String get onboardingDesc2 =>
      'Create your own Wazifas with custom targets, schedules, and reminders.';

  @override
  String get onboardingTitle3 => 'Daily Reminders';

  @override
  String get onboardingDesc3 =>
      'Set reminders so you never miss your daily Dhikr practice.';

  @override
  String get onboardingTitle4 => 'Save & Continue';

  @override
  String get onboardingDesc4 =>
      'Your progress is automatically saved. Continue exactly where you left off.';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get chooseLanguageSubtitle =>
      'Select your preferred language for the app';

  @override
  String get couldNotOpenReview => 'Could not open review';

  @override
  String get onLatestVersion => 'You are on the latest version';

  @override
  String get couldNotCheckUpdates => 'Could not check for updates';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationNumber => 'Please enter a valid number';

  @override
  String get validationMin => 'Must be at least 1';
}
