// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'done_date.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoneDateAdapter extends TypeAdapter<DoneDate> {
  @override
  final int typeId = 5;

  @override
  DoneDate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoneDate(
      date: fields[0] as int,
      synchronized: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, DoneDate obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.synchronized);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoneDateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
