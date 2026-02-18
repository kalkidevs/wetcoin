import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import '../../data/datasources/health_service.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  return HealthService();
});

final healthStepsProvider = FutureProvider<int>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  // This gets steps from Health Connect (or 0 if fallback)
  return healthService.getStepsForDate(DateTime.now());
});

final pedometerStreamProvider = StreamProvider<StepCount>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  // We need to ensure the stream is initialized, which happens in requestPermissions.
  // But we can expose it here.
  return healthService.stepCountStream ?? const Stream.empty();
});
