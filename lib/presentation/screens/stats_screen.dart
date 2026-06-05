import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/halaqa.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../logic/halaqa/halaqa_cubit.dart';
import '../widgets/empty_state.dart';

/// إحصائيات حضور الطلاب لحلقة معيّنة.
class StatsScreen extends StatelessWidget {
  final String halaqaId;

  const StatsScreen({super.key, required this.halaqaId});

  Color _rateColor(ColorScheme scheme, double rate) {
    if (rate >= 0.75) return Colors.green;
    if (rate >= 0.5) return Colors.orange;
    return scheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final repo = AttendanceRepository();
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
        final stats = repo.statsForHalaqa(h);
        final total = stats.isEmpty ? 0 : stats.first.totalSessions;
        final scheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
            title: const Text('الإحصائيات'),
            actions: [
              if (stats.isNotEmpty && total > 0)
                IconButton(
                  tooltip: 'مشاركة التقرير',
                  icon: const Icon(Icons.ios_share),
                  onPressed: () {
                    SharePlus.instance.share(
                      ShareParams(text: repo.statsReport(h)),
                    );
                  },
                ),
            ],
          ),
          body: stats.isEmpty || total == 0
              ? const EmptyState(
                  icon: Icons.insights_outlined,
                  title: 'لا توجد بيانات كافية',
                  subtitle: 'سجّل بعض جلسات الحضور لعرض الإحصائيات.',
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.event_note, color: scheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                'عدد الجلسات المسجّلة: $total',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: stats.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final s = stats[index];
                          final pct = (s.rate * 100).round();
                          final color = _rateColor(scheme, s.rate);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          s.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ),
                                      Text(
                                        '$pct٪',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(color: color),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: s.rate,
                                      minHeight: 8,
                                      backgroundColor: scheme
                                          .surfaceContainerHighest,
                                      valueColor:
                                          AlwaysStoppedAnimation(color),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'حضر ${s.presentCount} — غاب ${s.absentCount}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
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
      },
    );
  }
}
