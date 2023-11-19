// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitStatusAdapter extends TypeAdapter<HabitStatus> {
  @override
  final int typeId = 2;

  @override
  HabitStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitStatus.deleted;
      case 1:
        return HabitStatus.created;
      case 2:
        return HabitStatus.updated;
      case 3:
        return HabitStatus.synchronized;
      case 4:
        return HabitStatus.normal;
      default:
        return HabitStatus.deleted;
    }
  }

  @override
  void write(BinaryWriter writer, HabitStatus obj) {
    switch (obj) {
      case HabitStatus.deleted:
        writer.writeByte(0);
        break;
      case HabitStatus.created:
        writer.writeByte(1);
        break;
      case HabitStatus.updated:
        writer.writeByte(2);
        break;
      case HabitStatus.synchronized:
        writer.writeByte(3);
        break;
      case HabitStatus.normal:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
