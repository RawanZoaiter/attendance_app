// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'halaqa.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HalaqaAdapter extends TypeAdapter<Halaqa> {
  @override
  final int typeId = 1;

  @override
  Halaqa read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Halaqa(
      id: fields[0] as String,
      name: fields[1] as String,
      createdAt: fields[2] as DateTime,
      students: (fields[3] as List?)?.cast<Student>(),
    );
  }

  @override
  void write(BinaryWriter writer, Halaqa obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.students);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HalaqaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
