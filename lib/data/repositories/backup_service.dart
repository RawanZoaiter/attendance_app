import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/attendance_session.dart';
import '../models/halaqa.dart';
import '../models/student.dart';
import 'hive_init.dart';

/// تصدير/استيراد كل البيانات كملف JSON واحد (نسخة احتياطية offline).
class BackupService {
  static const int _version = 1;

  Box<Halaqa> get _halaqas => Hive.box<Halaqa>(HiveBoxes.halaqas);
  Box<AttendanceSession> get _sessions =>
      Hive.box<AttendanceSession>(HiveBoxes.sessions);

  /// يبني نص JSON يمثّل كل البيانات.
  String exportToJson() {
    final data = {
      'version': _version,
      'halaqas': _halaqas.values
          .map((h) => {
                'id': h.id,
                'name': h.name,
                'createdAt': h.createdAt.toIso8601String(),
                'students': h.students
                    .map((s) => {'id': s.id, 'name': s.name, 'age': s.age})
                    .toList(),
              })
          .toList(),
      'sessions': _sessions.values
          .map((e) => {
                'id': e.id,
                'halaqaId': e.halaqaId,
                'date': e.date.toIso8601String(),
                'presentStudentIds': e.presentStudentIds,
                'notes': e.notes ?? {},
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// يكتب النسخة الاحتياطية لملف مؤقّت ويعيد مساره (للمشاركة).
  Future<File> writeBackupFile() async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .split('.')
        .first;
    final file = File('${dir.path}/attendance_backup_$stamp.json');
    await file.writeAsString(exportToJson());
    return file;
  }

  /// يستورد من نص JSON. يستبدل كل البيانات الحالية بالكامل.
  Future<void> importFromJson(String jsonStr) async {
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    final halaqas = (data['halaqas'] as List?) ?? const [];
    final sessions = (data['sessions'] as List?) ?? const [];

    await _halaqas.clear();
    await _sessions.clear();

    for (final raw in halaqas) {
      final h = raw as Map<String, dynamic>;
      final students = ((h['students'] as List?) ?? const [])
          .map((s) => Student(
                id: s['id'] as String,
                name: s['name'] as String,
                age: (s['age'] as num?)?.toInt(),
              ))
          .toList();
      final halaqa = Halaqa(
        id: h['id'] as String,
        name: h['name'] as String,
        createdAt: DateTime.parse(h['createdAt'] as String),
        students: students,
      );
      await _halaqas.put(halaqa.id, halaqa);
    }

    for (final raw in sessions) {
      final e = raw as Map<String, dynamic>;
      final notes = <String, String>{};
      (e['notes'] as Map?)?.forEach((k, v) => notes['$k'] = '$v');
      final session = AttendanceSession(
        id: e['id'] as String,
        halaqaId: e['halaqaId'] as String,
        date: DateTime.parse(e['date'] as String),
        presentStudentIds:
            ((e['presentStudentIds'] as List?) ?? const []).cast<String>(),
        notes: notes,
      );
      await _sessions.put(session.id, session);
    }
  }
}
