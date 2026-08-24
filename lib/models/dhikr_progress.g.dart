// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dhikr_progress.dart';

class DhikrProgressAdapter extends TypeAdapter<DhikrProgress> {
  @override
  final int typeId = 2;

  @override
  DhikrProgress read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DhikrProgress(
      id: fields[0] as String,
      currentCount: fields[1] as int? ?? 0,
      roundCount: fields[2] as int? ?? 1,
      isCompleted: fields[3] as bool? ?? false,
      repeatEnabled: fields[4] as bool? ?? false,
      reminderEnabled: fields[5] as bool? ?? false,
      reminderTime: fields[6] as String?,
      startDate: fields[7] as DateTime?,
      endDate: fields[8] as DateTime?,
      numberOfDays: fields[9] as int?,
      notes: fields[10] as String?,
      schedule: fields[11] as String?,
      lastSessionDate: fields[12] as DateTime?,
      createdAt: fields[13] as DateTime?,
      updatedAt: fields[14] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DhikrProgress obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.currentCount)
      ..writeByte(2)
      ..write(obj.roundCount)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.repeatEnabled)
      ..writeByte(5)
      ..write(obj.reminderEnabled)
      ..writeByte(6)
      ..write(obj.reminderTime)
      ..writeByte(7)
      ..write(obj.startDate)
      ..writeByte(8)
      ..write(obj.endDate)
      ..writeByte(9)
      ..write(obj.numberOfDays)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.schedule)
      ..writeByte(12)
      ..write(obj.lastSessionDate)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DhikrProgressAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
