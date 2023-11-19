// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_priority.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitPriorityAdapter extends TypeAdapter<HabitPriority> {
  @override
  final int typeId = 1;

  @override
  HabitPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitPriority.low;
      case 1:
        return HabitPriority.medium;
      case 2:
        return HabitPriority.high;
      default:
        return HabitPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, HabitPriority obj) {
    switch (obj) {
      case HabitPriority.low:
        writer.writeByte(0);
        break;
      case HabitPriority.medium:
        writer.writeByte(1);
        break;
      case HabitPriority.high:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
