import 'package:flutter/material.dart';
import 'package:sweatcoin/core/constants/app_constants.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sync_service.dart';
import 'health_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == AppConstants.workerSyncSteps) {
      try {
        await Firebase.initializeApp(); // Initialize Firebase
        final healthService = HealthService();
        final syncService = SyncService(healthService);
        await syncService.syncToday();
        return Future.value(true);
      } catch (e) {
        debugPrint("Background sync failed: $e");
        return Future.value(false);
      }
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
  }

  static Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "1",
      AppConstants.workerSyncSteps,
      frequency: const Duration(hours: 6),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}
