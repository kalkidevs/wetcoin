import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sync_service.dart';
import 'health_provider.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final healthService = ref.watch(healthServiceProvider);
  return SyncService(healthService);
});
