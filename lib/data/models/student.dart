import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// عمر الطالبة (اختياري — قد يكون فارغاً للطلاب القدامى قبل إضافة الحقل).
  @HiveField(2)
  int? age;

  Student({required this.id, required this.name, this.age});
}
