enum DhikrType { single, collection, dua, quran }

enum DhikrCategory {
  general,
  morning,
  evening,
  afterSalah,
  beforeSleep,
  friday,
  forgiveness,
  protection,
  praise,
  salawat,
}

extension DhikrCategoryLabel on DhikrCategory {
  String get label {
    switch (this) {
      case DhikrCategory.general:
        return 'General';
      case DhikrCategory.morning:
        return 'Morning';
      case DhikrCategory.evening:
        return 'Evening';
      case DhikrCategory.afterSalah:
        return 'After Salah';
      case DhikrCategory.beforeSleep:
        return 'Before Sleep';
      case DhikrCategory.friday:
        return 'Friday';
      case DhikrCategory.forgiveness:
        return 'Forgiveness';
      case DhikrCategory.protection:
        return 'Protection';
      case DhikrCategory.praise:
        return 'Praise';
      case DhikrCategory.salawat:
        return 'Salawat';
    }
  }
}

enum ReferenceType { hadith, quran }

class Dhikr {
  final String id;

  /// Example: Tasbih Fatimah
  final String name;

  /// Example: تَسْبِيح فَاطِمَة
  final String arabicTitle;

  /// Example: Fatimah's glorification
  final String translation;

  /// Short explanation about this dhikr
  final String description;

  final DhikrType type;
  final DhikrCategory category;

  /// The actual dhikr/azkar to recite
  final List<AzkarItem> azkar;

  /// Hadith or Quran references
  final List<DhikrReference> references;

  /// Authentic benefits and virtues
  final List<String> benefits;

  /// Example: Morning, Evening, After Salah
  final List<String> recommendedTimes;

  /// Default app dhikr or custom user dhikr
  final bool isDefault;

  /// If user created this dhikr
  final bool isCustom;

  final DateTime? createdAt;

  const Dhikr({
    required this.id,
    required this.name,
    required this.arabicTitle,
    required this.translation,
    required this.description,
    required this.type,
    required this.category,
    required this.azkar,
    this.references = const [],
    this.benefits = const [],
    this.recommendedTimes = const [],
    this.isDefault = false,
    this.isCustom = false,
    this.createdAt,
  });

  /// The first azkar item, used for single-item counter display.
  AzkarItem? get firstAzkar => azkar.isEmpty ? null : azkar.first;

  /// Convenience accessor for the primary Arabic text to recite.
  String? get arabicText => firstAzkar?.arabicText;

  /// Convenience accessor for the primary transliteration.
  String? get transliteration => firstAzkar?.transliteration;

  /// Sum of every azkar's target count (the overall target for this dhikr).
  int get totalTargetCount => azkar.fold(0, (sum, a) => sum + a.targetCount);

  factory Dhikr.fromMap(Map<String, dynamic> map) {
    return Dhikr(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      arabicTitle: map['arabicTitle'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      description: map['description'] as String? ?? '',
      type: _parseType(map['type']),
      category: _parseCategory(map['category']),
      azkar: (map['azkar'] as List?)
              ?.map((e) => AzkarItem.fromMap(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      references: (map['references'] as List?)
              ?.map((e) => DhikrReference.fromMap(
                  Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      benefits: (map['benefits'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      recommendedTimes: (map['recommendedTimes'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isDefault: (map['isDefault'] as bool?) ?? false,
      isCustom: (map['isCustom'] as bool?) ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabicTitle': arabicTitle,
      'translation': translation,
      'description': description,
      'type': type.name,
      'category': category.name,
      'azkar': azkar.map((a) => a.toMap()).toList(),
      'references': references.map((r) => r.toMap()).toList(),
      'benefits': benefits,
      'recommendedTimes': recommendedTimes,
      'isDefault': isDefault,
      'isCustom': isCustom,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Dhikr copyWith({
    String? id,
    String? name,
    String? arabicTitle,
    String? translation,
    String? description,
    DhikrType? type,
    DhikrCategory? category,
    List<AzkarItem>? azkar,
    List<DhikrReference>? references,
    List<String>? benefits,
    List<String>? recommendedTimes,
    bool? isDefault,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Dhikr(
      id: id ?? this.id,
      name: name ?? this.name,
      arabicTitle: arabicTitle ?? this.arabicTitle,
      translation: translation ?? this.translation,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      azkar: azkar ?? this.azkar,
      references: references ?? this.references,
      benefits: benefits ?? this.benefits,
      recommendedTimes: recommendedTimes ?? this.recommendedTimes,
      isDefault: isDefault ?? this.isDefault,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class AzkarItem {
  final String id;

  /// Arabic text to display
  final String arabicText;

  /// English pronunciation
  final String transliteration;

  /// Meaning
  final String translation;

  /// Recommended count
  final int targetCount;

  /// Whether this count is established from an authentic source
  final bool isSunnahCount;

  /// Optional note
  final String? note;

  const AzkarItem({
    required this.id,
    required this.arabicText,
    required this.transliteration,
    required this.translation,
    required this.targetCount,
    this.isSunnahCount = false,
    this.note,
  });

  factory AzkarItem.fromMap(Map<String, dynamic> map) {
    return AzkarItem(
      id: map['id'] as String? ?? '',
      arabicText: map['arabicText'] as String? ?? '',
      transliteration: map['transliteration'] as String? ?? '',
      translation: map['translation'] as String? ?? '',
      targetCount: (map['targetCount'] as num?)?.toInt() ?? 0,
      isSunnahCount: (map['isSunnahCount'] as bool?) ?? false,
      note: map['note'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'arabicText': arabicText,
      'transliteration': transliteration,
      'translation': translation,
      'targetCount': targetCount,
      'isSunnahCount': isSunnahCount,
      if (note != null) 'note': note,
    };
  }

  AzkarItem copyWith({
    String? id,
    String? arabicText,
    String? transliteration,
    String? translation,
    int? targetCount,
    bool? isSunnahCount,
    String? note,
  }) {
    return AzkarItem(
      id: id ?? this.id,
      arabicText: arabicText ?? this.arabicText,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      targetCount: targetCount ?? this.targetCount,
      isSunnahCount: isSunnahCount ?? this.isSunnahCount,
      note: note ?? this.note,
    );
  }
}

class DhikrReference {
  final ReferenceType type;

  /// Short text explaining the reference
  final String? text;

  /// Example: Sahih al-Bukhari
  final String source;

  /// Example: Sahih
  final String? grade;

  /// Example: Abu Hurairah رضي الله عنه
  final String? narrator;

  /// Example: 6405
  final String? referenceNumber;

  /// For Quran
  /// Example: Al-Baqarah
  final String? surah;

  /// Example: 255
  final String? verse;

  const DhikrReference({
    required this.type,
    required this.source,
    this.text,
    this.grade,
    this.narrator,
    this.referenceNumber,
    this.surah,
    this.verse,
  });

  factory DhikrReference.fromMap(Map<String, dynamic> map) {
    return DhikrReference(
      type: _parseReferenceType(map['type']),
      source: map['source'] as String? ?? '',
      text: map['text'] as String?,
      grade: map['grade'] as String?,
      narrator: map['narrator'] as String?,
      referenceNumber: map['referenceNumber'] as String?,
      surah: map['surah'] as String?,
      verse: map['verse'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'source': source,
      if (text != null) 'text': text,
      if (grade != null) 'grade': grade,
      if (narrator != null) 'narrator': narrator,
      if (referenceNumber != null) 'referenceNumber': referenceNumber,
      if (surah != null) 'surah': surah,
      if (verse != null) 'verse': verse,
    };
  }
}

DhikrType _parseType(Object? value) {
  if (value is DhikrType) return value;
  if (value == null) return DhikrType.single;
  for (final t in DhikrType.values) {
    if (t.name == value.toString()) return t;
  }
  return DhikrType.single;
}

DhikrCategory _parseCategory(Object? value) {
  if (value is DhikrCategory) return value;
  if (value == null) return DhikrCategory.general;
  for (final c in DhikrCategory.values) {
    if (c.name == value.toString()) return c;
  }
  return DhikrCategory.general;
}

ReferenceType _parseReferenceType(Object? value) {
  if (value is ReferenceType) return value;
  if (value == null) return ReferenceType.hadith;
  for (final r in ReferenceType.values) {
    if (r.name == value.toString()) return r;
  }
  return ReferenceType.hadith;
}

/// Whether a [DhikrCategory] is relevant to recite at the current time.
bool isDhikrCategoryRelevantNow(DhikrCategory category) {
  final now = DateTime.now();
  final hour = now.hour;

  switch (category) {
    case DhikrCategory.morning:
      return hour >= 4 && hour < 12;
    case DhikrCategory.evening:
      return hour >= 15 && hour < 21;
    case DhikrCategory.beforeSleep:
      return hour >= 20 || hour < 4;
    case DhikrCategory.friday:
      return now.weekday == DateTime.friday;
    case DhikrCategory.afterSalah:
    case DhikrCategory.general:
    case DhikrCategory.forgiveness:
    case DhikrCategory.protection:
    case DhikrCategory.praise:
    case DhikrCategory.salawat:
      return true;
  }
}
