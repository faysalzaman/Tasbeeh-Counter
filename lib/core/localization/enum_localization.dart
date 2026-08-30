import 'package:flutter/material.dart';
import '../../models/dhikr.dart';
import '../../models/dhikr_schedule.dart';
import 'l10n_extension.dart';

/// Localized helpers for enum values used across the app.
class EnumLocalizations {
  EnumLocalizations._();

  static String category(BuildContext context, DhikrCategory category) {
    final l10n = context.l10n;
    switch (category) {
      case DhikrCategory.general:
        return l10n.categoryGeneral;
      case DhikrCategory.morning:
        return l10n.categoryMorning;
      case DhikrCategory.evening:
        return l10n.categoryEvening;
      case DhikrCategory.afterSalah:
        return l10n.categoryAfterSalah;
      case DhikrCategory.beforeSleep:
        return l10n.categoryBeforeSleep;
      case DhikrCategory.friday:
        return l10n.categoryFriday;
      case DhikrCategory.forgiveness:
        return l10n.categoryForgiveness;
      case DhikrCategory.protection:
        return l10n.categoryProtection;
      case DhikrCategory.praise:
        return l10n.categoryPraise;
      case DhikrCategory.salawat:
        return l10n.categorySalawat;
    }
  }

  static String type(BuildContext context, DhikrType type) {
    final l10n = context.l10n;
    switch (type) {
      case DhikrType.single:
        return l10n.typeSingle;
      case DhikrType.collection:
        return l10n.typeCollection;
      case DhikrType.dua:
        return l10n.typeDua;
      case DhikrType.quran:
        return l10n.typeQuran;
    }
  }

  static String scheduleLabel(BuildContext context, DhikrSchedule schedule) {
    final l10n = context.l10n;
    switch (schedule) {
      case DhikrSchedule.daily:
        return l10n.scheduleLabel;
      case DhikrSchedule.fajr:
        return 'Fajr'; // TODO: localize
      case DhikrSchedule.morning:
        return l10n.categoryMorning;
      case DhikrSchedule.asar:
        return 'Asar'; // TODO: localize
      case DhikrSchedule.maghrib:
        return 'Maghrib'; // TODO: localize
      case DhikrSchedule.night:
        return 'Night'; // TODO: localize
      case DhikrSchedule.friday:
        return l10n.categoryFriday;
      case DhikrSchedule.saturday:
        return 'Saturday'; // TODO: localize
      case DhikrSchedule.sunday:
        return 'Sunday'; // TODO: localize
    }
  }
}
