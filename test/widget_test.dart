// اختبار بسيط لمكوّن الحالة الفارغة (بدون الحاجة لتهيئة Hive).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:attendance_app/presentation/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState shows title and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.groups_2_outlined,
            title: 'لا توجد حلقات بعد',
            subtitle: 'أضف حلقتك الأولى.',
          ),
        ),
      ),
    );

    expect(find.text('لا توجد حلقات بعد'), findsOneWidget);
    expect(find.text('أضف حلقتك الأولى.'), findsOneWidget);
    expect(find.byIcon(Icons.groups_2_outlined), findsOneWidget);
  });
}
