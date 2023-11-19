// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 4;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      uid: fields[0] as String,
      color: fields[1] as Color,
      count: fields[2] as int,
      date: fields[3] as int,
      description: fields[4] as String,
      frequency: fields[5] as int,
      priority: fields[6] as HabitPriority,
      title: fields[7] as String,
      type: fields[8] as HabitType,
      doneDates: (fields[9] as List).cast<DoneDate>(),
      doneDatesSynchronized: fields[10] as bool,
      status: fields[11] as HabitStatus,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.color)
      ..writeByte(2)
      ..write(obj.count)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.frequency)
      ..writeByte(6)
      ..write(obj.priority)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.type)
      ..writeByte(9)
      ..write(obj.doneDates)
      ..writeByte(10)
      ..write(obj.doneDatesSynchronized)
      ..writeByte(11)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
