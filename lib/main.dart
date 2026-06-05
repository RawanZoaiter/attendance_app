import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/halaqa_repository.dart';
import 'data/repositories/hive_init.dart';
import 'logic/halaqa/halaqa_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveInit.init();
  await initializeDateFormatting('ar');

  runApp(
    BlocProvider(
      create: (_) => HalaqaCubit(HalaqaRepository(), AttendanceRepository()),
      child: const AttendanceApp(),
    ),
  );
}
