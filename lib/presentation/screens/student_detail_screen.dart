import 'package:flutter/material.dart';

import '../../core/utils/date_format.dart';
import '../../data/models/halaqa.dart';
import '../../data/models/student.dart';
import '../../data/repositories/attendance_repository.dart';
import '../widgets/empty_state.dart';

/// سجل الطالبة: بياناتها + حضورها وتسميعاتها عبر كل الجلسات.
class StudentDetailScreen extends StatelessWidget {
  final Halaqa halaqa;
  final Student student;

  const StudentDetailScreen({
    super.key,
    required this.halaqa,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final repo = AttendanceRepository();
    final sessions = repo.getForHalaqa(halaqa.id);

    final attended =
        sessions.where((s) => s.presentStudentIds.contains(student.id)).length;
    final total = sessions.length;
    final pct = total == 0 ? 0 : (attended / total * 100).round();

    return Scaffold(
      appBar: AppBar(title: Text(student.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // بطاقة بيانات الطالبة.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(Icons.person,
                        color: scheme.onPrimaryContainer, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.name,
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          student.age == null
                              ? 'العمر غير محدّد'
                              : 'العمر: ${student.age} سنة',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ملخص الحضور.
          Card(
            color: scheme.secondaryContainer.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'حضرت', value: '$attended'),
                  _Stat(label: 'إجمالي', value: '$total'),
                  _Stat(label: 'النسبة', value: '$pct٪'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('سجل الجلسات والتسميع',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 32),
              child: EmptyState(
                icon: Icons.event_busy_outlined,
                title: 'لا توجد جلسات بعد',
              ),
            )
          else
            ...sessions.map((s) {
              final present = s.presentStudentIds.contains(student.id);
              final note = (s.notes ?? const {})[student.id];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    present ? Icons.check_circle : Icons.cancel,
                    color: present ? Colors.green : scheme.error,
                  ),
                  title: Text(AppDate.full(s.date)),
                  subtitle: Text(
                    present
                        ? (note != null && note.trim().isNotEmpty
                            ? note
                            : 'حاضرة')
                        : 'غائبة',
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: scheme.onSecondaryContainer)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
