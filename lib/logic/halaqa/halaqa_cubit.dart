import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/halaqa.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/halaqa_repository.dart';

part 'halaqa_state.dart';

class HalaqaCubit extends Cubit<HalaqaState> {
  final HalaqaRepository _repo;
  final AttendanceRepository _attendanceRepo;

  HalaqaCubit(this._repo, this._attendanceRepo)
      : super(const HalaqaLoading()) {
    load();
  }

  void load() {
    final halaqas = _repo.getAll();
    final counts = <String, int>{
      for (final h in halaqas) h.id: _attendanceRepo.countForHalaqa(h.id),
    };
    emit(HalaqaLoaded(halaqas: halaqas, sessionCounts: counts));
  }

  Future<void> addHalaqa(String name) async {
    await _repo.addHalaqa(name);
    load();
  }

  Future<void> renameHalaqa(Halaqa halaqa, String name) async {
    await _repo.renameHalaqa(halaqa, name);
    load();
  }

  Future<void> deleteHalaqa(Halaqa halaqa) async {
    await _attendanceRepo.deleteForHalaqa(halaqa.id);
    await _repo.deleteHalaqa(halaqa);
    load();
  }

  Future<void> addStudent(Halaqa halaqa, String name, {int? age}) async {
    await _repo.addStudent(halaqa, name, age: age);
    load();
  }

  Future<void> editStudent(
    Halaqa halaqa,
    String studentId, {
    required String name,
    int? age,
  }) async {
    await _repo.editStudent(halaqa, studentId, name: name, age: age);
    load();
  }

  /// إعادة تحميل بعد عملية خارجية (مثل استيراد نسخة احتياطية).
  void refresh() => load();

  Future<void> deleteStudent(Halaqa halaqa, String studentId) async {
    await _repo.deleteStudent(halaqa, studentId);
    load();
  }
}
