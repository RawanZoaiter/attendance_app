import 'package:hive_flutter/hive_flutter.dart';

import '../models/attendance_session.dart';
import '../models/halaqa.dart';
import '../models/student.dart';

/// أسماء الصناديق في مكان واحد.
class HiveBoxes {
  HiveBoxes._();

  static const String halaqas = 'halaqas';
  static const String sessions = 'sessions';
}

/// تهيئة Hive وتسجيل الأدابترات وفتح الصناديق. تُستدعى مرة واحدة في main.
class HiveInit {
  HiveInit._();

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(StudentAdapter());
    Hive.registerAdapter(HalaqaAdapter());
    Hive.registerAdapter(AttendanceSessionAdapter());

    await Hive.openBox<Halaqa>(HiveBoxes.halaqas);
    await Hive.openBox<AttendanceSession>(HiveBoxes.sessions);
  }
}
