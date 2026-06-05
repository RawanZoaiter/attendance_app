import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/attendance_session.dart';
import '../../data/repositories/attendance_repository.dart';

part 'attendance_state.dart';

/// يدير جلسات الحضور لحلقة واحدة محدّدة بـ [halaqaId].
class AttendanceCubit extends Cubit<AttendanceState> {
  final AttendanceRepository _repo;
  final String halaqaId;

  AttendanceCubit(this._repo, this.halaqaId)
      : super(const AttendanceLoading()) {
    load();
  }

  void load() {
    emit(AttendanceLoaded(_repo.getForHalaqa(halaqaId)));
  }

  Future<void> addSession({
    required DateTime date,
    required List<String> presentStudentIds,
    Map<String, String>? notes,
  }) async {
    await _repo.addSession(
      halaqaId: halaqaId,
      date: date,
      presentStudentIds: presentStudentIds,
      notes: notes,
    );
    load();
  }

  Future<void> updateSession(
    AttendanceSession session, {
    DateTime? date,
    List<String>? presentStudentIds,
    Map<String, String>? notes,
  }) async {
    await _repo.updateSession(
      session,
      date: date,
      presentStudentIds: presentStudentIds,
      notes: notes,
    );
    load();
  }

  Future<void> deleteSession(AttendanceSession session) async {
    await _repo.deleteSession(session);
    load();
  }
}
