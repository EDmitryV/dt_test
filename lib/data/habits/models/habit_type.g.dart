// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 3;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.good;
      case 1:
        return HabitType.bad;
      default:
        return HabitType.good;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.good:
        writer.writeByte(0);
        break;
      case HabitType.bad:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
