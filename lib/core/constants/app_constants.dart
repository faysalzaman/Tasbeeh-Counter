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
      'schedule': 'daily',
    },
    {
      'name': 'Alhamdulillah',
      'arabicText': 'ٱلْحَمْدُ لِلَّٰهِ',
      'transliteration': 'Alhamdulillah',
      'translation': 'Praise be to Allah',
      'targetCount': 33,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Allahu Akbar',
      'arabicText': 'ٱللَّٰهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'translation': 'Allah is the Greatest',
      'targetCount': 34,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Astaghfirullah',
      'arabicText': 'أَسْتَغْفِرُ ٱللَّٰهَ',
      'transliteration': 'Astaghfirullah',
      'translation': 'I seek forgiveness from Allah',
      'targetCount': 100,
      'isDefault': true,
      'schedule': 'morning',
    },
    {
      'name': 'La ilaha illallah',
      'arabicText': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'transliteration': 'La ilaha illallah',
      'translation': 'There is no god but Allah',
      'targetCount': 100,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'SubhanAllahi wa bihamdihi',
      'arabicText': 'سُبْحَانَ ٱللَّٰهِ وَبِحَمْدِهِ',
      'transliteration': 'SubhanAllahi wa bihamdihi',
      'translation': 'Glory be to Allah and praise Him',
      'targetCount': 100,
      'isDefault': true,
      'schedule': 'fajr',
    },
    {
      'name': 'Salawat / Durood',
      'arabicText': 'ٱللَّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ',
      'transliteration': 'Allahumma salli ala Muhammad',
      'translation': 'O Allah, send blessings upon Muhammad',
      'targetCount': 100,
      'isDefault': true,
      'schedule': 'friday',
    },
    {
      'name': 'La hawla wa la quwwata illa billah',
      'arabicText': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰهِ',
      'transliteration': 'La hawla wa la quwwata illa billah',
      'translation': 'There is no power nor strength except with Allah. (Treasure of Jannah)',
      'targetCount': 100,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Dua Yunus',
      'arabicText': 'لَا إِلٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
      'transliteration': 'La ilaha illa anta subhanaka inni kuntu minaz-zalimin',
      'translation': 'There is no god but You, Glory to You; I was indeed among the wrongdoers. (Accepted for every need)',
      'targetCount': 100,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Hasbunallahu wa ni\'mal wakeel',
      'arabicText': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'transliteration': 'Hasbunallahu wa ni\'mal wakeel',
      'translation': 'Allah is sufficient for us, and He is the best Disposer of affairs.',
      'targetCount': 70,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Namaaz e Hajat',
      'arabicText': 'نَمَازِ حَاجَت',
      'transliteration': 'Namaaz e Hajat',
      'translation': 'Pray 2 rakat nafl for your need, then praise Allah, send durood, and ask your hajat.',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Ayatul Kursi',
      'arabicText': 'آيَةُ ٱلْكُرْسِيِّ',
      'transliteration': 'Ayatul Kursi',
      'translation': 'The Throne Verse',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'night',
    },
    {
      'name': 'Tasbih Fatimah',
      'arabicText': 'تَسْبِيح فَاطِمَة',
      'transliteration': 'Tasbih Fatimah',
      'translation': 'Fatimah\'s glorification',
      'targetCount': 33,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Surah Al-Kahf',
      'arabicText': 'سُورَةُ ٱلْكَهْف',
      'transliteration': 'Surah Al-Kahf',
      'translation': 'The Cave',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'friday',
    },
    {
      'name': 'Sayyidul Istighfar',
      'arabicText': 'سَيِّدُ ٱلِاسْتِغْفَار',
      'transliteration': 'Sayyidul Istighfar',
      'translation': 'The master of seeking forgiveness',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'fajr',
    },
    {
      'name': 'Adhkar after Salah',
      'arabicText': 'أَذْكَار بَعْد ٱلصَّلَاة',
      'transliteration': 'Adhkar ba\'d as-Salah',
      'translation': 'Remembrance after prayer',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'daily',
    },
    {
      'name': 'Morning Adhkar',
      'arabicText': 'أَذْكَار ٱلصَّبَاح',
      'transliteration': 'Adhkar as-Sabah',
      'translation': 'Morning remembrance',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'morning',
    },
    {
      'name': 'Evening Adhkar',
      'arabicText': 'أَذْكَار ٱلْمَسَاء',
      'transliteration': 'Adhkar al-Masa',
      'translation': 'Evening remembrance',
      'targetCount': 1,
      'isDefault': true,
      'schedule': 'asar',
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
