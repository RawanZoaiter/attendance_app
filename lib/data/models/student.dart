import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 0)
class Student extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  /// صف الطالبة (اختياري). مثال: "الصف الأول" ... "البكالوريا".
  /// نستخدم رقم حقل جديد (3) حتى لا نتعارض مع بيانات العمر القديمة في الحقل 2.
  @HiveField(3)
  String? grade;

  Student({required this.id, required this.name, this.grade});
}
