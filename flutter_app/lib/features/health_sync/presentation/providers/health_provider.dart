import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/health_service.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  final service = HealthService();
  ref.onDispose(service.dispose);
  return service;
});

final healthStepsProvider = FutureProvider<int>((ref) async {
  final healthService = ref.watch(healthServiceProvider);
  // This gets aggregated steps from Health Connect / Apple Health for today
  return healthService.getTodaySteps();
});
