import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/utils/date_format.dart';
import '../../data/models/halaqa.dart';
import '../../logic/attendance/attendance_cubit.dart';

/// شاشة تسجيل حضور جديد: اختيار تاريخ + تعليم الحاضرين + ملاحظة تسميع لكل حاضرة.
class TakeAttendanceScreen extends StatefulWidget {
  final Halaqa halaqa;

  /// التاريخ المختار مسبقاً للجلسة (يُمرَّر من شاشة "إضافة جلسة").
  final DateTime? initialDate;

  const TakeAttendanceScreen({
    super.key,
    required this.halaqa,
    this.initialDate,
  });

  @override
  State<TakeAttendanceScreen> createState() => _TakeAttendanceScreenState();
}

class _TakeAttendanceScreenState extends State<TakeAttendanceScreen> {
  late DateTime _date;
  late Set<String> _present;
  late Map<String, TextEditingController> _noteControllers;

  @override
  void initState() {
    super.initState();
    _date = AppDate.dateOnly(widget.initialDate ?? DateTime.now());
    // الافتراضي: الكل حاضر.
    _present = widget.halaqa.students.map((s) => s.id).toSet();
    _noteControllers = {
      for (final s in widget.halaqa.students) s.id: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final c in _noteControllers.values) {
      c.dispose();
    }
    super.dispose();
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

  void _setAll(bool present) {
    setState(() {
      if (present) {
        _present = widget.halaqa.students.map((s) => s.id).toSet();
      } else {
        _present = {};
      }
    });
  }

  void _save() {
    final notes = <String, String>{};
    for (final entry in _noteControllers.entries) {
      final text = entry.value.text.trim();
      if (_present.contains(entry.key) && text.isNotEmpty) {
        notes[entry.key] = text;
      }
    }
    context.read<AttendanceCubit>().addSession(
          date: _date,
          presentStudentIds: _present.toList(),
          notes: notes,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الحضور')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final students = widget.halaqa.students;
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل حضور')),
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
            child: Row(
              children: [
                Text(
                  'الحاضرون: ${_present.length} من ${students.length}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _setAll(true),
                  child: const Text('تحديد الكل'),
                ),
                TextButton(
                  onPressed: () => _setAll(false),
                  child: const Text('إلغاء الكل'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
                label: const Text('حفظ الحضور'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
