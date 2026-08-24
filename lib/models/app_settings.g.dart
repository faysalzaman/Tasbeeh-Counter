// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      themeMode: fields[0] as String,
      languageCode: fields[1] as String,
      countingVibration: fields[2] as bool,
      completionVibration: fields[3] as bool,
      countingSound: fields[4] as bool,
      completionSound: fields[5] as bool,
      volumeKeyCounting: fields[6] as bool,
      reminderNotifications: fields[7] as bool,
      defaultReminderTime: fields[8] as String,
      hasCompletedOnboarding: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.themeMode)
      ..writeByte(1)
      ..write(obj.languageCode)
      ..writeByte(2)
      ..write(obj.countingVibration)
      ..writeByte(3)
      ..write(obj.completionVibration)
      ..writeByte(4)
      ..write(obj.countingSound)
      ..writeByte(5)
      ..write(obj.completionSound)
      ..writeByte(6)
      ..write(obj.volumeKeyCounting)
      ..writeByte(7)
      ..write(obj.reminderNotifications)
      ..writeByte(8)
      ..write(obj.defaultReminderTime)
      ..writeByte(9)
      ..write(obj.hasCompletedOnboarding);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
