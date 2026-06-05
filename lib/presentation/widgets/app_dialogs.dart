import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// نتيجة حوار بيانات الطالبة.
class StudentInput {
  final String name;
  final int? age;
  const StudentInput(this.name, this.age);
}

/// حوارات مشتركة: إدخال نص + بيانات طالبة + تأكيد حذف.
class AppDialogs {
  AppDialogs._();

  /// حوار إدخال اسم الطالبة وعمرها (للإضافة أو التعديل).
  static Future<StudentInput?> student(
    BuildContext context, {
    String? initialName,
    int? initialAge,
    String title = 'إضافة طالبة',
    String confirmText = 'إضافة',
  }) {
    final nameController = TextEditingController(text: initialName);
    final ageController =
        TextEditingController(text: initialAge?.toString() ?? '');
    return showDialog<StudentInput>(
      context: context,
      builder: (ctx) {
        void submit() {
          final name = nameController.text.trim();
          if (name.isEmpty) return;
          final age = int.tryParse(ageController.text.trim());
          Navigator.pop(ctx, StudentInput(name, age));
        }

        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'اسم الطالبة',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => submit(),
                decoration: const InputDecoration(
                  labelText: 'العمر (اختياري)',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            FilledButton(onPressed: submit, child: Text(confirmText)),
          ],
        );
      },
    );
  }

  /// حوار إدخال اسم (للإضافة أو التعديل). يعيد النص أو null عند الإلغاء.
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String? initialValue,
    String hint = '',
    String confirmText = 'حفظ',
  }) {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (_) => _submit(ctx, controller.text),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => _submit(ctx, controller.text),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static void _submit(BuildContext context, String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    Navigator.pop(context, text);
  }

  /// حوار تأكيد. يعيد true عند الموافقة.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'حذف',
    bool destructive = true,
  }) async {
    final scheme = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
