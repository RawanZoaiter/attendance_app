import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/date_format.dart';
import '../../data/models/attendance_session.dart';
import '../../data/models/halaqa.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../logic/attendance/attendance_cubit.dart';
import '../widgets/app_dialogs.dart';

/// عرض/تعديل جلسة محفوظة مع إمكانية المشاركة.
class SessionDetailScreen extends StatefulWidget {
  final Halaqa halaqa;
  final AttendanceSession session;

  const SessionDetailScreen({
    super.key,
    required this.halaqa,
    required this.session,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  late DateTime _date;
  late Set<String> _present;
  late Map<String, TextEditingController> _noteControllers;

  @override
  void initState() {
    super.initState();
    _date = widget.session.date;
    _present = widget.session.presentStudentIds.toSet();
    final existing = widget.session.notes ?? const {};
    _noteControllers = {
      for (final s in widget.halaqa.students)
        s.id: TextEditingController(text: existing[s.id] ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Map<String, String> _collectNotes() {
    final notes = <String, String>{};
    for (final entry in _noteControllers.entries) {
      final text = entry.value.text.trim();
      if (_present.contains(entry.key) && text.isNotEmpty) {
        notes[entry.key] = text;
      }
    }
    return notes;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = AppDate.dateOnly(picked));
    }
  }

  void _save() {
    context.read<AttendanceCubit>().updateSession(
          widget.session,
          date: _date,
          presentStudentIds: _present.toList(),
          notes: _collectNotes(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ التعديلات')),
    );
  }

  Future<void> _delete() async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'حذف الجلسة',
      message: 'حذف سجل حضور ${AppDate.full(_date)}؟',
    );
    if (ok && mounted) {
      context.read<AttendanceCubit>().deleteSession(widget.session);
      Navigator.pop(context);
    }
  }

  void _share() {
    // نبني نصاً يعكس الحالة الحالية (مع التعديلات غير المحفوظة).
    final temp = AttendanceSession(
      id: widget.session.id,
      halaqaId: widget.session.halaqaId,
      date: _date,
      presentStudentIds: _present.toList(),
      notes: _collectNotes(),
    );
    final text = AttendanceRepository().sessionReport(widget.halaqa, temp);
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final students = widget.halaqa.students;
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الجلسة'),
        actions: [
          IconButton(
            tooltip: 'مشاركة',
            icon: const Icon(Icons.share),
            onPressed: _share,
          ),
          IconButton(
            tooltip: 'حذف',
            icon: const Icon(Icons.delete_outline),
            onPressed: _delete,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.calendar_today, color: scheme.primary),
                title: const Text('التاريخ'),
                subtitle: Text(AppDate.full(_date)),
                trailing: TextButton(
                  onPressed: _pickDate,
                  child: const Text('تغيير'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                'الحاضرون: ${_present.length} من ${students.length}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          const Divider(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final isPresent = _present.contains(student.id);
                return Column(
                  children: [
                    CheckboxListTile(
                      value: isPresent,
                      title: Text(student.name),
                      secondary: CircleAvatar(child: Text('${index + 1}')),
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _present.add(student.id);
                          } else {
                            _present.remove(student.id);
                          }
                        });
                      },
                    ),
                    if (isPresent)
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            72, 0, 16, 8),
                        child: TextField(
                          controller: _noteControllers[student.id],
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'ملاحظة التسميع (اختياري)',
                            prefixIcon: Icon(Icons.menu_book_outlined),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('حفظ التعديلات'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
