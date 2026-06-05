import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/attendance_session.dart';
import '../../data/models/halaqa.dart';
import '../../data/models/student.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../core/utils/date_format.dart';
import '../../logic/attendance/attendance_cubit.dart';
import '../../logic/halaqa/halaqa_cubit.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/backup_actions.dart';
import '../widgets/empty_state.dart';
import 'session_detail_screen.dart';
import 'stats_screen.dart';
import 'student_detail_screen.dart';
import 'take_attendance_screen.dart';

class HalaqaDetailScreen extends StatelessWidget {
  final String halaqaId;

  /// عند فتحها كواجهة رئيسية لا نعرض زر الرجوع.
  final bool isHome;

  const HalaqaDetailScreen({
    super.key,
    required this.halaqaId,
    this.isHome = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AttendanceCubit(AttendanceRepository(), halaqaId),
      child: _HalaqaDetailView(halaqaId: halaqaId, isHome: isHome),
    );
  }
}

class _HalaqaDetailView extends StatelessWidget {
  final String halaqaId;
  final bool isHome;

  const _HalaqaDetailView({required this.halaqaId, required this.isHome});

  Future<void> _renameHalaqa(BuildContext context, Halaqa halaqa) async {
    final name = await AppDialogs.prompt(
      context,
      title: 'تعديل اسم الحلقة',
      initialValue: halaqa.name,
      hint: 'اسم الحلقة',
    );
    if (name != null && context.mounted) {
      context.read<HalaqaCubit>().renameHalaqa(halaqa, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    // نراقب HalaqaCubit حتى تنعكس تعديلات الطلاب/الاسم مباشرة.
    return BlocBuilder<HalaqaCubit, HalaqaState>(
      builder: (context, state) {
        Halaqa? halaqa;
        if (state is HalaqaLoaded) {
          for (final h in state.halaqas) {
            if (h.id == halaqaId) {
              halaqa = h;
              break;
            }
          }
        }
        if (halaqa == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final h = halaqa;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: !isHome,
              title: Text(h.name),
              actions: [
                IconButton(
                  tooltip: 'الإحصائيات',
                  icon: const Icon(Icons.bar_chart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StatsScreen(halaqaId: h.id),
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    final cubit = context.read<HalaqaCubit>();
                    switch (v) {
                      case 'rename':
                        _renameHalaqa(context, h);
                      case 'export':
                        BackupActions.export(context);
                      case 'import':
                        BackupActions.import(context,
                            onDone: cubit.refresh);
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                        value: 'rename', child: Text('تعديل اسم الحلقة')),
                    PopupMenuItem(
                        value: 'export', child: Text('نسخة احتياطية (تصدير)')),
                    PopupMenuItem(
                        value: 'import', child: Text('استيراد نسخة')),
                  ],
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'سجلات الحضور', icon: Icon(Icons.event_note)),
                  Tab(text: 'الطلاب', icon: Icon(Icons.people_outline)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _SessionsTab(halaqa: h),
                _StudentsTab(halaqa: h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ----------------- تبويب الطلاب -----------------

class _StudentsTab extends StatefulWidget {
  final Halaqa halaqa;

  const _StudentsTab({required this.halaqa});

  @override
  State<_StudentsTab> createState() => _StudentsTabState();
}

class _StudentsTabState extends State<_StudentsTab> {
  String _query = '';

  Future<void> _addStudent() async {
    final input = await AppDialogs.student(context, title: 'إضافة طالبة');
    if (input != null && mounted) {
      context
          .read<HalaqaCubit>()
          .addStudent(widget.halaqa, input.name, age: input.age);
    }
  }

  Future<void> _editStudent(Student student) async {
    final input = await AppDialogs.student(
      context,
      title: 'تعديل بيانات الطالبة',
      initialName: student.name,
      initialAge: student.age,
      confirmText: 'حفظ',
    );
    if (input != null && mounted) {
      context.read<HalaqaCubit>().editStudent(
            widget.halaqa,
            student.id,
            name: input.name,
            age: input.age,
          );
    }
  }

  Future<void> _deleteStudent(Student student) async {
    final ok = await AppDialogs.confirm(
      context,
      title: 'حذف الطالبة',
      message: 'حذف "${student.name}" من الحلقة؟',
    );
    if (ok && mounted) {
      context.read<HalaqaCubit>().deleteStudent(widget.halaqa, student.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ترتيب أبجدي + فلترة بالبحث.
    final students = [...widget.halaqa.students]
      ..sort((a, b) => a.name.compareTo(b.name));
    final filtered = _query.isEmpty
        ? students
        : students.where((s) => s.name.contains(_query)).toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addStudent,
        icon: const Icon(Icons.person_add_alt),
        label: const Text('طالبة'),
      ),
      body: widget.halaqa.students.isEmpty
          ? const EmptyState(
              icon: Icons.person_outline,
              title: 'لا يوجد طلاب بعد',
              subtitle: 'أضف أسماء الطالبات لتتمكن من تسجيل حضورهن.',
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    onChanged: (v) => setState(() => _query = v.trim()),
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'بحث عن طالبة',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? const EmptyState(
                          icon: Icons.search_off,
                          title: 'لا نتائج',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final student = filtered[index];
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => StudentDetailScreen(
                                        halaqa: widget.halaqa,
                                        student: student,
                                      ),
                                    ),
                                  );
                                },
                                leading: const CircleAvatar(
                                    child: Icon(Icons.person)),
                                title: Text(student.name),
                                subtitle: student.age == null
                                    ? null
                                    : Text('العمر: ${student.age}'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (v) {
                                    if (v == 'edit') _editStudent(student);
                                    if (v == 'delete') {
                                      _deleteStudent(student);
                                    }
                                  },
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                        value: 'edit',
                                        child: Text('تعديل')),
                                    PopupMenuItem(
                                        value: 'delete', child: Text('حذف')),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

// ----------------- تبويب سجلات الحضور -----------------

class _SessionsTab extends StatelessWidget {
  final Halaqa halaqa;

  const _SessionsTab({required this.halaqa});

  Future<void> _newSession(BuildContext context) async {
    final attendanceCubit = context.read<AttendanceCubit>();
    if (halaqa.students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف طالبات أولاً قبل تسجيل الحضور.')),
      );
      return;
    }
    // أول شي: اختيار تاريخ الجلسة.
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      helpText: 'اختر تاريخ الجلسة',
    );
    if (pickedDate == null || !context.mounted) return;
    // بعدين: قائمة الطالبات لأخذ الحضور بنفس التاريخ.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: attendanceCubit,
          child: TakeAttendanceScreen(halaqa: halaqa, initialDate: pickedDate),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _newSession(context),
        icon: const Icon(Icons.add),
        label: const Text('إضافة جلسة'),
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          if (state is! AttendanceLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.sessions.isEmpty) {
            return const EmptyState(
              icon: Icons.event_busy_outlined,
              title: 'لا توجد جلسات بعد',
              subtitle: 'سجّل أول حضور بالضغط على زر "إضافة جلسة".',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: state.sessions.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final session = state.sessions[index];
              return _SessionCard(halaqa: halaqa, session: session);
            },
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final Halaqa halaqa;
  final AttendanceSession session;

  const _SessionCard({required this.halaqa, required this.session});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final present = session.presentStudentIds
        .where((id) => halaqa.students.any((s) => s.id == id))
        .length;
    final total = halaqa.students.length;
    final attendanceCubit = context.read<AttendanceCubit>();
    return Card(
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: attendanceCubit,
                child: SessionDetailScreen(halaqa: halaqa, session: session),
              ),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: scheme.secondaryContainer,
          child: Icon(Icons.event, color: scheme.onSecondaryContainer),
        ),
        title: Text(AppDate.full(session.date)),
        subtitle: Text('حضر $present من $total'),
        trailing: const Icon(Icons.chevron_left),
      ),
    );
  }
}
