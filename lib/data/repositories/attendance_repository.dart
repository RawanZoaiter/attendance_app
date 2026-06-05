import 'package:hive/hive.dart';

import '../../core/utils/date_format.dart';
import '../../core/utils/id_generator.dart';
import '../models/attendance_session.dart';
import '../models/halaqa.dart';
import 'hive_init.dart';

/// إحصائية حضور لطالب واحد ضمن حلقة.
class StudentStat {
  final String studentId;
  final String name;
  final int presentCount;
  final int totalSessions;

  StudentStat({
    required this.studentId,
    required this.name,
    required this.presentCount,
    required this.totalSessions,
  });

  double get rate => totalSessions == 0 ? 0 : presentCount / totalSessions;
  int get absentCount => totalSessions - presentCount;
}

/// عمليات جلسات الحضور وحساب الإحصائيات وبناء نصوص المشاركة.
class AttendanceRepository {
  Box<AttendanceSession> get _box =>
      Hive.box<AttendanceSession>(HiveBoxes.sessions);

  /// جلسات حلقة معيّنة مرتّبة من الأحدث إلى الأقدم.
  List<AttendanceSession> getForHalaqa(String halaqaId) {
    final list =
        _box.values.where((s) => s.halaqaId == halaqaId).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  int countForHalaqa(String halaqaId) =>
      _box.values.where((s) => s.halaqaId == halaqaId).length;

  Future<AttendanceSession> addSession({
    required String halaqaId,
    required DateTime date,
    required List<String> presentStudentIds,
    Map<String, String>? notes,
  }) async {
    final session = AttendanceSession(
      id: IdGenerator.newId(),
      halaqaId: halaqaId,
      date: AppDate.dateOnly(date),
      presentStudentIds: List<String>.from(presentStudentIds),
      notes: notes == null ? null : Map<String, String>.from(notes),
    );
    await _box.put(session.id, session);
    return session;
  }

  Future<void> updateSession(
    AttendanceSession session, {
    DateTime? date,
    List<String>? presentStudentIds,
    Map<String, String>? notes,
  }) async {
    if (date != null) session.date = AppDate.dateOnly(date);
    if (presentStudentIds != null) {
      session.presentStudentIds = List<String>.from(presentStudentIds);
    }
    if (notes != null) {
      session.notes = Map<String, String>.from(notes);
    }
    await session.save();
  }

  Future<void> deleteSession(AttendanceSession session) => session.delete();

  Future<void> deleteForHalaqa(String halaqaId) async {
    final keys = _box.values
        .where((s) => s.halaqaId == halaqaId)
        .map((s) => s.key)
        .toList();
    await _box.deleteAll(keys);
  }

  // ----- الإحصائيات -----

  List<StudentStat> statsForHalaqa(Halaqa halaqa) {
    final sessions = getForHalaqa(halaqa.id);
    final total = sessions.length;
    return halaqa.students.map((student) {
      final present = sessions
          .where((s) => s.presentStudentIds.contains(student.id))
          .length;
      return StudentStat(
        studentId: student.id,
        name: student.name,
        presentCount: present,
        totalSessions: total,
      );
    }).toList();
  }

  // ----- نصوص المشاركة -----

  /// نص ملخّص لجلسة واحدة.
  String sessionReport(Halaqa halaqa, AttendanceSession session) {
    final present = <String>[];
    final absent = <String>[];
    for (final s in halaqa.students) {
      if (session.presentStudentIds.contains(s.id)) {
        present.add(s.name);
      } else {
        absent.add(s.name);
      }
    }
    final notes = session.notes ?? const {};
    final buffer = StringBuffer()
      ..writeln('حلقة: ${halaqa.name}')
      ..writeln('التاريخ: ${AppDate.full(session.date)}')
      ..writeln('')
      ..writeln('الحاضرون (${present.length}):');
    for (final s in halaqa.students) {
      if (!session.presentStudentIds.contains(s.id)) continue;
      final note = notes[s.id];
      if (note != null && note.trim().isNotEmpty) {
        buffer.writeln('  ✓ ${s.name} — $note');
      } else {
        buffer.writeln('  ✓ ${s.name}');
      }
    }
    buffer
      ..writeln('')
      ..writeln('الغائبون (${absent.length}):');
    for (final n in absent) {
      buffer.writeln('  ✗ $n');
    }
    return buffer.toString();
  }

  /// تقرير إحصائي كامل للحلقة (مناسب للمشاركة كنص).
  String statsReport(Halaqa halaqa) {
    final stats = statsForHalaqa(halaqa);
    final total = stats.isEmpty ? 0 : stats.first.totalSessions;
    final buffer = StringBuffer()
      ..writeln('تقرير حضور حلقة: ${halaqa.name}')
      ..writeln('عدد الجلسات المسجّلة: $total')
      ..writeln('');
    for (final s in stats) {
      final pct = (s.rate * 100).round();
      buffer.writeln(
        '${s.name}: حضر ${s.presentCount} من $total ($pct٪)',
      );
    }
    return buffer.toString();
  }
}
