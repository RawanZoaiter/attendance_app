import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_service.dart';
import 'app_dialogs.dart';

/// إجراءات التصدير/الاستيراد مع رسائل للمستخدم.
class BackupActions {
  BackupActions._();

  /// يصدّر كل البيانات لملف ويفتح قائمة المشاركة لحفظه خارج الجهاز.
  static Future<void> export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await BackupService().writeBackupFile();
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'نسخة احتياطية - تطبيق الحضور',
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('تعذّر إنشاء النسخة الاحتياطية: $e')),
      );
    }
  }

  /// يستورد نسخة احتياطية من ملف يختاره المستخدم (يستبدل البيانات الحالية).
  /// يستدعي [onDone] بعد نجاح الاستيراد لإعادة تحميل الواجهة.
  static Future<void> import(
    BuildContext context, {
    required VoidCallback onDone,
  }) async {
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await AppDialogs.confirm(
      context,
      title: 'استيراد نسخة احتياطية',
      message:
          'سيتم استبدال كل البيانات الحالية بمحتوى الملف. هل تريد المتابعة؟',
      confirmText: 'استيراد',
      destructive: false,
    );
    if (!confirmed) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      final path = result?.files.single.path;
      if (path == null) return;

      final content = await File(path).readAsString();
      await BackupService().importFromJson(content);
      onDone();
      messenger.showSnackBar(
        const SnackBar(content: Text('تم استيراد النسخة الاحتياطية')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('تعذّر استيراد الملف: $e')),
      );
    }
  }
}
