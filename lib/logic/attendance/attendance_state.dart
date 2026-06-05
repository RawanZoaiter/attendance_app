part of 'attendance_cubit.dart';

sealed class AttendanceState {
  const AttendanceState();
}

class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

class AttendanceLoaded extends AttendanceState {
  final List<AttendanceSession> sessions;

  const AttendanceLoaded(this.sessions);
}
