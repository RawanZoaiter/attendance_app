import 'package:hive/hive.dart';

import 'student.dart';

part 'halaqa.g.dart';

@HiveType(typeId: 1)
class Halaqa extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  List<Student> students;

  Halaqa({
    required this.id,
    required this.name,
    required this.createdAt,
    List<Student>? students,
  }) : students = students ?? <Student>[];
}
