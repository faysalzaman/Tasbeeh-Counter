// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr.dart';

class DhikrAdapter extends TypeAdapter<Dhikr> {
  @override
  final int typeId = 0;

  @override
  Dhikr read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dhikr(
      id: fields[0] as String,
      name: fields[1] as String,
      arabicText: fields[2] as String?,
      transliteration: fields[3] as String?,
      translation: fields[4] as String?,
      targetCount: fields[5] as int,
      currentCount: fields[6] as int,
      isDefault: fields[7] as bool,
      repeatEnabled: fields[8] as bool,
      roundCount: fields[9] as int,
      reminderEnabled: fields[10] as bool,
      reminderTime: fields[11] as String?,
      startDate: fields[12] as DateTime?,
      endDate: fields[13] as DateTime?,
      numberOfDays: fields[14] as int?,
      notes: fields[15] as String?,
      isCompleted: fields[16] as bool,
      lastSessionDate: fields[17] as DateTime?,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
      schedule: fields[20] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Dhikr obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.arabicText)
      ..writeByte(3)
      ..write(obj.transliteration)
      ..writeByte(4)
      ..write(obj.translation)
      ..writeByte(5)
      ..write(obj.targetCount)
      ..writeByte(6)
      ..write(obj.currentCount)
      ..writeByte(7)
      ..write(obj.isDefault)
      ..writeByte(8)
      ..write(obj.repeatEnabled)
      ..writeByte(9)
      ..write(obj.roundCount)
      ..writeByte(10)
      ..write(obj.reminderEnabled)
      ..writeByte(11)
      ..write(obj.reminderTime)
      ..writeByte(12)
      ..write(obj.startDate)
      ..writeByte(13)
      ..write(obj.endDate)
      ..writeByte(14)
      ..write(obj.numberOfDays)
      ..writeByte(15)
      ..write(obj.notes)
      ..writeByte(16)
      ..write(obj.isCompleted)
      ..writeByte(17)
      ..write(obj.lastSessionDate)
      ..writeByte(18)
      ..write(obj.createdAt)
      ..writeByte(19)
      ..write(obj.updatedAt)
      ..writeByte(20)
      ..write(obj.schedule);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
