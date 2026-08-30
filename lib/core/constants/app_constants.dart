// app_constants.dart

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
    // ============================================================
    // 1. SUBHANALLAH
    // ============================================================
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

    // ============================================================
    // 2. ALHAMDULILLAH
    // ============================================================
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

    // ============================================================
    // 3. ALLAHU AKBAR
    // ============================================================
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

    // ============================================================
    // 4. ASTAGHFIRULLAH
    // ============================================================
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

    // ============================================================
    // 5. LA ILAHA ILLALLAH
    // ============================================================
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

    // ============================================================
    // 6. SUBHANALLAHI WA BIHAMDIHI
    // ============================================================
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

    // ============================================================
    // 7. SALAWAT / DUROOD
    // ============================================================
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

    // ============================================================
    // 8. LA HAWLA WA LA QUWWATA ILLA BILLAH
    // ============================================================
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

    // ============================================================
    // 9. DUA YUNUS
    // ============================================================
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

    // ============================================================
    // 10. HASBUNALLAHU WA NI'MAL WAKEEL
    // ============================================================
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

    // ============================================================
    // 11. SALAT AL-HAJAH
    // ============================================================
    {
      'id': 'salat_al_hajah',
      'name': 'Salat al-Hajah',
      'arabicTitle': 'صَلَاةُ الْحَاجَةِ',
      'translation': 'Prayer for a need',
      'description':
          'A voluntary prayer performed when a person wishes to ask Allah for a particular need.',
      'type': 'prayer',
      'category': 'general',
      'azkar': [
        {
          'id': 'salat_al_hajah_instruction',
          'arabicText': 'صَلَاةُ الْحَاجَةِ',
          'transliteration': 'Salat al-Hajah',
          'translation':
              'Pray voluntary prayer and supplicate to Allah for your need.',
          'targetCount': 1,
          'isSunnahCount': false,
          'note':
              'This item is informational and should not be treated as a normal tasbeeh counter.',
        },
      ],
      'references': [],
      'benefits': [
        'A reminder to turn to Allah and make dua when seeking help.',
      ],
      'recommendedTimes': ['When needed'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 12. AYATUL KURSI
    // ============================================================
    {
      'id': 'ayatul_kursi',
      'name': 'Ayatul Kursi',
      'arabicTitle': 'آيَةُ الْكُرْسِيِّ',
      'translation': 'The Throne Verse',
      'description':
          'One of the greatest verses of the Quran, found in Surah Al-Baqarah.',
      'type': 'quran',
      'category': 'protection',
      'azkar': [
        {
          'id': 'ayatul_kursi',
          'arabicText':
              'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
          'transliteration': 'Allahu la ilaha illa huwal-hayyul-qayyum...',
          'translation':
              'Allah—there is no god worthy of worship except Him, the Ever-Living, the Sustainer of all.',
          'targetCount': 1,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {
          'type': 'quran',
          'source': 'The Quran',
          'surah': 'Al-Baqarah',
          'verse': '255',
        },
        {'type': 'hadith', 'source': 'Sahih al-Bukhari', 'grade': 'Sahih'},
      ],
      'benefits': [
        'The Prophet ﷺ described it as the greatest verse in the Book of Allah.',
        'Protection through the night when recited before sleeping.',
      ],
      'recommendedTimes': ['Before sleeping', 'After Salah'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 13. TASBIH FATIMAH
    // ============================================================
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

    // ============================================================
    // 14. SURAH AL-KAHF
    // ============================================================
    {
      'id': 'surah_al_kahf',
      'name': 'Surah Al-Kahf',
      'arabicTitle': 'سُورَةُ الْكَهْفِ',
      'translation': 'The Cave',
      'description': 'The eighteenth chapter of the Quran.',
      'type': 'quran',
      'category': 'friday',
      'azkar': [
        {
          'id': 'surah_al_kahf',
          'arabicText': 'سُورَةُ الْكَهْفِ',
          'transliteration': 'Surah Al-Kahf',
          'translation': 'Recitation of Surah Al-Kahf.',
          'targetCount': 1,
          'isSunnahCount': false,
          'note':
              'This should open a Quran reader rather than work as a normal tasbeeh counter.',
        },
      ],
      'references': [
        {'type': 'quran', 'source': 'The Quran', 'surah': 'Al-Kahf'},
      ],
      'benefits': [
        'Reciting Surah Al-Kahf on Friday brings special virtues and illumination.',
      ],
      'recommendedTimes': ['Friday'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 15. SAYYIDUL ISTIGHFAR
    // ============================================================
    {
      'id': 'sayyidul_istighfar',
      'name': 'Sayyidul Istighfar',
      'arabicTitle': 'سَيِّدُ الِاسْتِغْفَارِ',
      'translation': 'The master of seeking forgiveness',
      'description':
          'A comprehensive supplication for seeking Allah’s forgiveness.',
      'type': 'dua',
      'category': 'forgiveness',
      'azkar': [
        {
          'id': 'sayyidul_istighfar',
          'arabicText':
              'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ خَلَقْتَنِي وَأَنَا عَبْدُكَ وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
          'transliteration':
              'Allahumma anta Rabbi la ilaha illa anta, khalaqtani wa ana abduka, wa ana ala ahdika wa wadika mastatatu...',
          'translation':
              'O Allah, You are my Lord. There is no god worthy of worship except You. You created me and I am Your servant...',
          'targetCount': 1,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': 'Sahih al-Bukhari',
          'narrator': 'Shaddad ibn Aws رضي الله عنه',
          'grade': 'Sahih',
        },
      ],
      'benefits': [
        'The Prophet ﷺ described it as the best form of seeking forgiveness.',
      ],
      'recommendedTimes': ['Morning', 'Evening'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 16. ADHKAR AFTER SALAH
    // ============================================================
    {
      'id': 'adhkar_after_salah',
      'name': 'Adhkar after Salah',
      'arabicTitle': 'أَذْكَارُ بَعْدَ الصَّلَاةِ',
      'translation': 'Remembrance after prayer',
      'description':
          'A collection of authentic remembrances recited after the obligatory prayers.',
      'type': 'collection',
      'category': 'afterSalah',
      'azkar': [
        {
          'id': 'after_salah_astaghfirullah',
          'arabicText': 'أَسْتَغْفِرُ اللَّهَ',
          'transliteration': 'Astaghfirullah',
          'translation': 'I seek forgiveness from Allah.',
          'targetCount': 3,
          'isSunnahCount': true,
        },
        {
          'id': 'after_salah_allahumma_antas_salam',
          'arabicText':
              'اللَّهُمَّ أَنْتَ السَّلَامُ وَمِنْكَ السَّلَامُ تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
          'transliteration':
              'Allahumma antas-salam wa minkas-salam tabarakta ya dhal-jalali wal-ikram',
          'translation':
              'O Allah, You are Peace and from You comes peace. Blessed are You, O Possessor of majesty and honor.',
          'targetCount': 1,
          'isSunnahCount': true,
        },
        {
          'id': 'after_salah_subhanallah',
          'arabicText': 'سُبْحَانَ اللَّهِ',
          'transliteration': 'SubhanAllah',
          'translation': 'Glory be to Allah.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
        {
          'id': 'after_salah_alhamdulillah',
          'arabicText': 'الْحَمْدُ لِلَّهِ',
          'transliteration': 'Alhamdulillah',
          'translation': 'All praise is due to Allah.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
        {
          'id': 'after_salah_allahu_akbar',
          'arabicText': 'اللَّهُ أَكْبَرُ',
          'transliteration': 'Allahu Akbar',
          'translation': 'Allah is the Greatest.',
          'targetCount': 33,
          'isSunnahCount': true,
        },
      ],
      'references': [
        {'type': 'hadith', 'source': 'Sahih Muslim', 'grade': 'Sahih'},
      ],
      'benefits': ['Authentic adhkar prescribed after obligatory prayers.'],
      'recommendedTimes': ['After Salah'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 17. MORNING ADHKAR
    // ============================================================
    {
      'id': 'morning_adhkar',
      'name': 'Morning Adhkar',
      'arabicTitle': 'أَذْكَارُ الصَّبَاحِ',
      'translation': 'Morning remembrance',
      'description':
          'A collection of Quranic and prophetic supplications and remembrances for the morning.',
      'type': 'collection',
      'category': 'morning',
      'azkar': [
        {
          'id': 'morning_ayatul_kursi',
          'arabicText': 'آيَةُ الْكُرْسِيِّ',
          'transliteration': 'Ayatul Kursi',
          'translation': 'The Throne Verse.',
          'targetCount': 1,
          'isSunnahCount': true,
        },
        {
          'id': 'morning_sayyidul_istighfar',
          'arabicText': 'سَيِّدُ الِاسْتِغْفَارِ',
          'transliteration': 'Sayyidul Istighfar',
          'translation': 'The master of seeking forgiveness.',
          'targetCount': 1,
          'isSunnahCount': true,
        },
        {
          'id': 'morning_subhanallahi_bihamdihi',
          'arabicText': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
          'transliteration': 'SubhanAllahi wa bihamdihi',
          'translation': 'Glory be to Allah and praise be to Him.',
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
        'Helps establish a regular habit of remembering Allah at the beginning of the day.',
      ],
      'recommendedTimes': ['Morning'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 18. EVENING ADHKAR
    // ============================================================
    {
      'id': 'evening_adhkar',
      'name': 'Evening Adhkar',
      'arabicTitle': 'أَذْكَارُ الْمَسَاءِ',
      'translation': 'Evening remembrance',
      'description':
          'A collection of Quranic and prophetic supplications and remembrances for the evening.',
      'type': 'collection',
      'category': 'evening',
      'azkar': [
        {
          'id': 'evening_ayatul_kursi',
          'arabicText': 'آيَةُ الْكُرْسِيِّ',
          'transliteration': 'Ayatul Kursi',
          'translation': 'The Throne Verse.',
          'targetCount': 1,
          'isSunnahCount': true,
        },
        {
          'id': 'evening_sayyidul_istighfar',
          'arabicText': 'سَيِّدُ الِاسْتِغْفَارِ',
          'transliteration': 'Sayyidul Istighfar',
          'translation': 'The master of seeking forgiveness.',
          'targetCount': 1,
          'isSunnahCount': true,
        },
        {
          'id': 'evening_subhanallahi_bihamdihi',
          'arabicText': 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
          'transliteration': 'SubhanAllahi wa bihamdihi',
          'translation': 'Glory be to Allah and praise be to Him.',
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
        'Helps establish a regular habit of remembering Allah in the evening.',
      ],
      'recommendedTimes': ['Evening'],
      'isDefault': true,
      'isCustom': false,
    },

    // ============================================================
    // 19. DUROOD SHARIF — FRIDAY SPECIAL
    // ============================================================
    // Source: Al-Qawl al-Badee' fi al-Salat 'ala al-Habib al-Shafee'
    //         by Imam Sakhawi
    // Scholarly note: The narration attributing a specific virtue to
    // reciting this 80 times after Asr on Friday is disputed among
    // scholars (some grade it weak, others consider it acceptable
    // for fada'il al-a'mal). Sending blessings upon the Prophet ﷺ
    // is always rewarded, and Friday holds general virtue for it.
    // ============================================================
    {
      'id': 'durood_friday_80',
      'name': 'Durood Sharif (Friday)',
      'arabicTitle': 'دَرُوْد شَرِیف',
      'translation': 'Blessings upon the Prophet ﷺ — Friday Special',
      'description':
          'A special salawat for Friday. Scholars differ on the authenticity of the narration mentioning exactly 80 times; however, sending blessings upon the Prophet ﷺ is always rewarded, and Friday holds special virtue for it.',
      'type': 'dua',
      'category': 'friday',
      'azkar': [
        {
          'id': 'durood_friday_80',
          'arabicText':
              'اَللّٰهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ النَّبِيِّ الْأُمِّيِّ وَعَلَىٰ آلِهِ وَسَلِّمْ تَسْلِيمًا',
          'transliteration':
              'Allahumma salli ala Muhammadin an-Nabiyyil-Ummiyyi wa ala alihi wa sallim tasliman',
          'translation':
              'O Allah! Send blessings upon Muhammad, the unlettered Prophet, and upon his family, and grant them complete peace.',
          'targetCount': 80,
          'isSunnahCount': false,
          'note':
              'Scholars differ on the authenticity of the narration mentioning exactly 80 times. Sending blessings upon the Prophet ﷺ is always rewarded, and Friday is a day of special virtue for it.',
        },
      ],
      'references': [
        {
          'type': 'hadith',
          'source': "Al-Qawl al-Badee' fi al-Salat 'ala al-Habib al-Shafee'",
          'narrator': 'Abu Hurairah رضي الله عنه',
          'grade': 'Disputed / Weak',
        },
      ],
      'benefits': [
        'Sending blessings upon the Prophet ﷺ is a highly encouraged act of worship.',
        'Friday is the best day of the week and holds special virtue for increasing salawat.',
      ],
      'recommendedTimes': ['Friday', 'After Asr'],
      'isDefault': true,
      'isCustom': false,
    },
  ];
}
