class AppConstants {
  AppConstants._();

  static const String appName = 'Digital Tasbeeh';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String customDhikrBox = 'custom_dhikrs';
  static const String dhikrProgressBox = 'dhikr_progress';
  static const String settingsBox = 'settings';

  // Store listing
  static const String appStoreId = 'com.tesbeeh.counter';

  // Notification channel
  static const String reminderChannelId = 'dhikr_reminders';
  static const String reminderChannelName = 'Dhikr Reminders';
  static const String reminderChannelDescription =
      'Reminders for your daily dhikr and wazifas';

  static const List<Map<String, dynamic>> defaultDhikrs = [
    {
      'id': 'subhanallah',
      'name': 'SubhanAllah',
      'arabicTitle': 'سُبْحَانَ اللَّهِ',
      'translation': 'Glory be to Allah',
      'description':
          'A remembrance that glorifies Allah and declares Him free from all imperfections.',
      'type': 'single',
      'category': 'praise',
      'azkar': [
        {
          'id': 'subhanallah',
          'arabicText': 'سُبْحَانَ اللَّهِ',
          'transliteration': 'SubhanAllah',
          'translation': 'Glory be to Allah.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {'type': 'hadith', 'source': 'Sahih Muslim', 'grade': 'Sahih'},
      ],
      'benefits': [
        'A form of glorifying Allah.',
        'Part of the authentic remembrance recited after obligatory prayers.',
      ],
      'recommendedTimes': ['After Salah', 'Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'alhamdulillah',
      'name': 'Alhamdulillah',
      'arabicTitle': 'الْحَمْدُ لِلَّهِ',
      'translation': 'All praise is due to Allah',
      'description': 'A remembrance of praise and gratitude to Allah.',
      'type': 'single',
      'category': 'praise',
      'azkar': [
        {
          'id': 'alhamdulillah',
          'arabicText': 'الْحَمْدُ لِلَّهِ',
          'transliteration': 'Alhamdulillah',
          'translation': 'All praise is due to Allah.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {'type': 'hadith', 'source': 'Sahih Muslim', 'grade': 'Sahih'},
      ],
      'benefits': [
        'A form of praising and thanking Allah.',
        'Part of authentic adhkar after Salah.',
      ],
      'recommendedTimes': ['After Salah', 'Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'allahu_akbar',
      'name': 'Allahu Akbar',
      'arabicTitle': 'اللَّهُ أَكْبَرُ',
      'translation': 'Allah is the Greatest',
      'description': 'A declaration of the greatness and supremacy of Allah.',
      'type': 'single',
      'category': 'praise',
      'azkar': [
        {
          'id': 'allahu_akbar',
          'arabicText': 'اللَّهُ أَكْبَرُ',
          'transliteration': 'Allahu Akbar',
          'translation': 'Allah is the Greatest.',
          'targetCount': 34,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': 'Sahih al-Bukhari and Sahih Muslim',
          'grade': 'Sahih',
        },
      ],
      'benefits': ['A declaration of the greatness of Allah.'],
      'recommendedTimes': ['Before sleeping', 'Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'astaghfirullah',
      'name': 'Astaghfirullah',
      'arabicTitle': 'أَسْتَغْفِرُ اللَّهَ',
      'translation': 'I seek forgiveness from Allah',
      'description':
          'A remembrance through which a person asks Allah for forgiveness.',
      'type': 'single',
      'category': 'forgiveness',
      'azkar': [
        {
          'id': 'astaghfirullah',
          'arabicText': 'أَسْتَغْفِرُ اللَّهَ',
          'transliteration': 'Astaghfirullah',
          'translation': 'I seek forgiveness from Allah.',
          'targetCount': 100,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {'type': 'hadith', 'source': 'Sahih al-Bukhari', 'grade': 'Sahih'},
      ],
      'benefits': ['The Prophet ﷺ frequently sought forgiveness from Allah.'],
      'recommendedTimes': ['Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'la_ilaha_illallah',
      'name': 'La ilaha illallah',
      'arabicTitle': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      'translation': 'There is no god worthy of worship except Allah',
      'description':
          'The declaration of Tawhid and one of the greatest forms of remembrance.',
      'type': 'single',
      'category': 'general',
      'azkar': [
        {
          'id': 'la_ilaha_illallah',
          'arabicText': 'لَا إِلَٰهَ إِلَّا اللَّهُ',
          'transliteration': 'La ilaha illallah',
          'translation': 'There is no god worthy of worship except Allah.',
          'targetCount': 100,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': 'Sahih al-Bukhari and Sahih Muslim',
          'grade': 'Sahih',
        },
      ],
      'benefits': [
        'A declaration of the oneness of Allah.',
        'Mentioned in authentic daily remembrance.',
      ],
      'recommendedTimes': ['Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'subhanallahi_wa_bihamdihi',
      'name': 'SubhanAllahi wa bihamdihi',
      'arabicTitle': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      'translation': 'Glory and praise be to Allah',
      'description':
          'A concise remembrance combining glorification and praise of Allah.',
      'type': 'single',
      'category': 'praise',
      'azkar': [
        {
          'id': 'subhanallahi_wa_bihamdihi',
          'arabicText': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
          'transliteration': 'SubhanAllahi wa bihamdihi',
          'translation': 'Glory and praise be to Allah.',
          'targetCount': 100,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': 'Sahih al-Bukhari and Sahih Muslim',
          'grade': 'Sahih',
        },
      ],
      'benefits': [
        'The Prophet ﷺ mentioned a special virtue for saying it one hundred times in a day.',
      ],
      'recommendedTimes': ['Morning', 'Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'salawat',
      'name': 'Salawat / Durood',
      'arabicTitle': 'الصَّلَاةُ عَلَى النَّبِيِّ',
      'translation': 'Sending blessings upon Prophet Muhammad ﷺ',
      'description': 'Sending prayers and blessings upon Prophet Muhammad ﷺ.',
      'type': 'dua',
      'category': 'salawat',
      'azkar': [
        {
          'id': 'short_salawat',
          'arabicText': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
          'transliteration': 'Allahumma salli ala Muhammad',
          'translation': 'O Allah, send blessings upon Muhammad.',
          'targetCount': 100,
          'isSunnahCount': false,
          'note': 'The target count can be used as a personal goal.',
        },
      ],
      'references': [
        {'type': 'hadith', 'source': 'Sahih Muslim', 'grade': 'Sahih'},
      ],
      'benefits': [
        'Sending blessings upon the Prophet ﷺ is a highly encouraged act of remembrance.',
      ],
      'recommendedTimes': ['Friday', 'Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'la_hawla',
      'name': 'La hawla wa la quwwata illa billah',
      'arabicTitle': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      'translation': 'There is no power and no strength except through Allah',
      'description': 'A declaration of complete dependence upon Allah.',
      'type': 'single',
      'category': 'general',
      'azkar': [
        {
          'id': 'la_hawla',
          'arabicText': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
          'transliteration': 'La hawla wa la quwwata illa billah',
          'translation':
              'There is no power and no strength except through Allah.',
          'targetCount': 100,
          'isSunnahCount': false,
          'note': 'The count is a personal target.',
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': 'Sahih al-Bukhari and Sahih Muslim',
          'narrator': 'Abu Musa al-Ashari رضي الله عنه',
          'grade': 'Sahih',
        },
      ],
      'benefits': [
        'The Prophet ﷺ described it as a treasure from the treasures of Paradise.',
      ],
      'recommendedTimes': ['Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'dua_yunus',
      'name': 'Dua Yunus',
      'arabicTitle': 'دُعَاءُ يُونُسَ',
      'translation': 'The supplication of Prophet Yunus عليه السلام',
      'description':
          'The supplication made by Prophet Yunus عليه السلام while in distress.',
      'type': 'dua',
      'category': 'general',
      'azkar': [
        {
          'id': 'dua_yunus',
          'arabicText':
              'لَا إِلَٰهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
          'transliteration':
              'La ilaha illa anta subhanaka inni kuntu minaz-zalimin',
          'translation':
              'There is no god except You. Glory be to You. Indeed, I have been among the wrongdoers.',
          'targetCount': 100,
          'isSunnahCount': false,
          'note': 'The count can be changed as a personal target.',
        },
      ],
      'references': [
        {
          'type': 'quran',
          'source': 'The Quran',
          'surah': 'Al-Anbiya',
          'verse': '87',
        },
      ],
      'benefits': [
        'A supplication of Prophet Yunus عليه السلام mentioned in the Quran.',
      ],
      'recommendedTimes': ['Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'hasbunallahu',
      'name': 'Hasbunallahu wa ni\'mal wakeel',
      'arabicTitle': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'translation':
          'Allah is sufficient for us, and He is the best Disposer of affairs',
      'description': 'A statement of trust and reliance upon Allah.',
      'type': 'dua',
      'category': 'general',
      'azkar': [
        {
          'id': 'hasbunallahu',
          'arabicText': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
          'transliteration': 'Hasbunallahu wa ni\'mal wakeel',
          'translation':
              'Allah is sufficient for us, and He is the best Disposer of affairs.',
          'targetCount': 70,
          'isSunnahCount': false,
          'note': 'The count is a personal target.',
        },
      ],
      'references': [
        {
          'type': 'quran',
          'source': 'The Quran',
          'surah': 'Aal Imran',
          'verse': '173',
        },
      ],
      'benefits': [
        'A Quranic statement expressing complete reliance upon Allah.',
      ],
      'recommendedTimes': ['Any time'],
      'isDefault': true,
      'isCustom': false,
    },

    {
      'id': 'tasbih_fatimah',
      'name': 'Tasbih Fatimah',
      'arabicTitle': 'تَسْبِيح فَاطِمَة',
      'translation': 'The glorification taught to Fatimah رضي الله عنها',
      'description':
          'A special remembrance taught by Prophet Muhammad ﷺ to Fatimah رضي الله عنها and Ali رضي الله عنهما.',
      'type': 'collection',
      'category': 'beforeSleep',
      'azkar': [
        {
          'id': 'subhanallah',
          'arabicText': 'سُبْحَانَ اللَّهِ',
          'transliteration': 'SubhanAllah',
          'translation': 'Glory be to Allah.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
        {
          'id': 'alhamdulillah',
          'arabicText': 'الْحَمْدُ لِلَّهِ',
          'transliteration': 'Alhamdulillah',
          'translation': 'All praise is due to Allah.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
        {
          'id': 'allahu_akbar',
          'arabicText': 'اللَّهُ أَكْبَرُ',
          'transliteration': 'Allahu Akbar',
          'translation': 'Allah is the Greatest.',
          'targetCount': 34,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': 'Sahih al-Bukhari',
          'narrator': 'Ali ibn Abi Talib رضي الله عنه',
          'grade': 'Sahih',
        },
      ],
      'benefits': [
        'A Sunnah remembrance taught by Prophet Muhammad ﷺ.',
        'Recommended as remembrance before sleeping.',
      ],
      'recommendedTimes': ['Before sleeping'],
      'isDefault': true,
      'isCustom': false,
    },
  ];
}
