// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advance.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AdvanceAdapter extends TypeAdapter<Advance> {
  @override
  final int typeId = 2;

  @override
  Advance read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Advance(
      id: fields[0] as String?,
      employeeId: fields[1] as String,
      date: fields[2] as DateTime,
      amount: fields[3] as double,
      note: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Advance obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.employeeId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdvanceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
