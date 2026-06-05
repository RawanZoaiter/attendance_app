import 'package:hive/hive.dart';

part 'attendance_session.g.dart';

@HiveType(typeId: 2)
class AttendanceSession extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String halaqaId;

  @HiveField(2)
  DateTime date;

  /// معرّفات الطلاب الحاضرين. أي طالب في الحلقة غير موجود هنا يُعتبر غائباً.
  @HiveField(3)
  List<String> presentStudentIds;

  /// ملاحظة تسميع لكل طالبة في هذه الجلسة (مفتاح = id الطالبة).
  /// قد يكون null للجلسات القديمة قبل إضافة الحقل.
  @HiveField(4)
  Map<String, String>? notes;

  AttendanceSession({
    required this.id,
    required this.halaqaId,
    required this.date,
    List<String>? presentStudentIds,
    Map<String, String>? notes,
  })  : presentStudentIds = presentStudentIds ?? <String>[],
        notes = notes ?? <String, String>{};
}
