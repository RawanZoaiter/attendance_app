part of 'halaqa_cubit.dart';

sealed class HalaqaState {
  const HalaqaState();
}

class HalaqaLoading extends HalaqaState {
  const HalaqaLoading();
}

class HalaqaLoaded extends HalaqaState {
  final List<Halaqa> halaqas;

  /// عدد جلسات الحضور لكل حلقة (مفتاح = id الحلقة).
  final Map<String, int> sessionCounts;

  const HalaqaLoaded({required this.halaqas, required this.sessionCounts});
}
