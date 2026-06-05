// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AttendanceSessionAdapter extends TypeAdapter<AttendanceSession> {
  @override
  final int typeId = 2;

  @override
  AttendanceSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AttendanceSession(
      id: fields[0] as String,
      halaqaId: fields[1] as String,
      date: fields[2] as DateTime,
      presentStudentIds: (fields[3] as List?)?.cast<String>(),
      notes: (fields[4] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, AttendanceSession obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.halaqaId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.presentStudentIds)
      ..writeByte(4)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
