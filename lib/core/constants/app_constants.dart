class AppConstants {
  AppConstants._();

  static const String appName = 'Digital Tasbeeh';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String dhikrBox = 'dhikr_box';
  static const String settingsBox = 'settings_box';
  static const String sessionsBox = 'sessions_box';

  // Default Dhikr data
  static const List<Map<String, dynamic>> defaultDhikrs = [
    {
      'name': 'SubhanAllah',
      'arabicText': 'سُبْحَانَ ٱللَّٰهِ',
      'transliteration': 'SubhanAllah',
      'translation': 'Glory be to Allah',
      'targetCount': 33,
      'isDefault': true,
    },
    {
      'name': 'Alhamdulillah',
      'arabicText': 'ٱلْحَمْدُ لِلَّٰهِ',
      'transliteration': 'Alhamdulillah',
      'translation': 'Praise be to Allah',
      'targetCount': 33,
      'isDefault': true,
    },
    {
      'name': 'Allahu Akbar',
      'arabicText': 'ٱللَّٰهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'translation': 'Allah is the Greatest',
      'targetCount': 34,
      'isDefault': true,
    },
    {
      'name': 'Astaghfirullah',
      'arabicText': 'أَسْتَغْفِرُ ٱللَّٰهَ',
      'transliteration': 'Astaghfirullah',
      'translation': 'I seek forgiveness from Allah',
      'targetCount': 100,
      'isDefault': true,
    },
    {
      'name': 'La ilaha illallah',
      'arabicText': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'transliteration': 'La ilaha illallah',
      'translation': 'There is no god but Allah',
      'targetCount': 100,
      'isDefault': true,
    },
    {
      'name': 'SubhanAllahi wa bihamdihi',
      'arabicText': 'سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ',
      'transliteration': 'SubhanAllahi wa bihamdihi',
      'translation': 'Glory be to Allah and praise Him',
      'targetCount': 100,
      'isDefault': true,
    },
    {
      'name': 'Salawat / Durood',
      'arabicText': 'ٱللَّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      'transliteration': 'Allahumma salli ala Muhammad',
      'translation': 'O Allah, send blessings upon Muhammad',
      'targetCount': 100,
      'isDefault': true,
    },
    {
      'name': 'La hawla wa la quwwata illa billah',
      'arabicText': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِٱللَّٰهِ',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'translation': 'There is no power nor strength except with Allah',
      'targetCount': 100,
      'isDefault': true,
    },
  ];

  // Supported locales
  static const List<String> supportedLanguages = ['en', 'ar', 'ur'];

  // Notification channel
  static const String reminderChannelId = 'dhikr_reminder_channel';
  static const String reminderChannelName = 'Dhikr Reminders';
  static const String reminderChannelDescription = 'Reminders for your daily Dhikr';

  // Play Store & App Store IDs (update with actual IDs)
  static const String playStoreId = 'com.yourcompany.tesbeeh_counter';
  static const String appStoreId = 'com.yourcompany.tesbeeh_counter';
}
