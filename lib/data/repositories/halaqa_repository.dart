import 'package:hive/hive.dart';

import '../../core/utils/id_generator.dart';
import '../models/halaqa.dart';
import '../models/student.dart';
import 'hive_init.dart';

/// عمليات القراءة والكتابة الخاصة بالحلقات والطلاب.
class HalaqaRepository {
  Box<Halaqa> get _box => Hive.box<Halaqa>(HiveBoxes.halaqas);

  /// كل الحلقات مرتّبة من الأحدث إنشاءً إلى الأقدم.
  List<Halaqa> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Halaqa? getById(String id) {
    for (final h in _box.values) {
      if (h.id == id) return h;
    }
    return null;
  }

  Future<Halaqa> addHalaqa(String name) async {
    final halaqa = Halaqa(
      id: IdGenerator.newId(),
      name: name.trim(),
      createdAt: DateTime.now(),
    );
    await _box.put(halaqa.id, halaqa);
    return halaqa;
  }

  Future<void> renameHalaqa(Halaqa halaqa, String name) async {
    halaqa.name = name.trim();
    await halaqa.save();
  }

  Future<void> deleteHalaqa(Halaqa halaqa) => halaqa.delete();

  // ----- الطلاب -----

  Future<void> addStudent(Halaqa halaqa, String name, {int? age}) async {
    halaqa.students.add(
      Student(id: IdGenerator.newId(), name: name.trim(), age: age),
    );
    await halaqa.save();
  }

  Future<void> editStudent(
    Halaqa halaqa,
    String studentId, {
    required String name,
    int? age,
  }) async {
    for (final s in halaqa.students) {
      if (s.id == studentId) {
        s.name = name.trim();
        s.age = age;
        break;
      }
    }
    await halaqa.save();
  }

  Future<void> deleteStudent(Halaqa halaqa, String studentId) async {
    halaqa.students.removeWhere((s) => s.id == studentId);
    await halaqa.save();
  }
}
