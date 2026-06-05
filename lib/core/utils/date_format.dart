import 'package:intl/intl.dart';

/// أدوات تنسيق التاريخ بالعربية في مكان واحد.
class AppDate {
  AppDate._();

  /// مثال: السبت، ٤ حزيران ٢٠٢٦
  static String full(DateTime date) =>
      DateFormat('EEEE، d MMMM y', 'ar').format(date);

  /// مثال: ٢٠٢٦/٠٦/٠٤
  static String short(DateTime date) =>
      DateFormat('y/MM/dd', 'ar').format(date);

  /// نفس اليوم بصرف النظر عن الوقت.
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// تطبيع التاريخ إلى منتصف الليل (لتجاهل الوقت عند المقارنة/التخزين).
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
