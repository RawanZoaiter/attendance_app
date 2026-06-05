/// مولّد معرّفات فريدة بسيط بدون أي حزمة خارجية (يبقى التطبيق offline وخفيف).
/// يدمج الطابع الزمني مع عدّاد متزايد لتفادي التكرار ضمن نفس الميلي ثانية.
class IdGenerator {
  IdGenerator._();

  static int _counter = 0;

  static String newId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    _counter = (_counter + 1) & 0xFFFF;
    return '${now.toRadixString(36)}-${_counter.toRadixString(36)}';
  }
}
