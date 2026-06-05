import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/halaqa/halaqa_cubit.dart';
import '../widgets/app_dialogs.dart';
import '../widgets/backup_actions.dart';
import '../widgets/empty_state.dart';
import 'halaqa_detail_screen.dart';

/// الواجهة الرئيسية: بما أن الاستخدام لحلقة واحدة، نفتح مباشرة على حلقتها.
/// إذا لم توجد حلقة بعد، نعرض شاشة إنشاء.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _createHalaqa(BuildContext context) async {
    final name = await AppDialogs.prompt(
      context,
      title: 'إنشاء الحلقة',
      hint: 'اسم الحلقة',
      confirmText: 'إنشاء',
    );
    if (name != null && context.mounted) {
      context.read<HalaqaCubit>().addHalaqa(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HalaqaCubit, HalaqaState>(
      builder: (context, state) {
        if (state is! HalaqaLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state.halaqas.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('الحضور')),
            body: Column(
              children: [
                const Expanded(
                  child: EmptyState(
                    icon: Icons.groups_2_outlined,
                    title: 'أهلاً بك 👋',
                    subtitle: 'أنشئ حلقتك لتبدأ بتسجيل الحضور.',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _createHalaqa(context),
                          icon: const Icon(Icons.add),
                          label: const Text('إنشاء الحلقة'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => BackupActions.import(
                          context,
                          onDone: () =>
                              context.read<HalaqaCubit>().refresh(),
                        ),
                        icon: const Icon(Icons.restore),
                        label: const Text('استيراد'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        // حلقة واحدة (أو الأحدث): نفتح عليها مباشرة.
        final halaqa = state.halaqas.first;
        return HalaqaDetailScreen(
          key: ValueKey(halaqa.id),
          halaqaId: halaqa.id,
          isHome: true,
        );
      },
    );
  }
}
