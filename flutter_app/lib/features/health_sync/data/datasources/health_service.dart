import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';

class HealthService {
  final Health _health = Health();
  bool _usePedometerFallback = false;
  bool _isPedometerInitialized = false;
  final StreamController<StepCount> _stepController =
      StreamController.broadcast();

  Future<bool> requestPermissions() async {
    // Define the types to get.
    var types = [
      HealthDataType.STEPS,
    ];

    bool requested = false;
    try {
      // Requesting permissions.
      // On Android 14+, Health Connect is built-in.
      // On iOS, HealthKit.
      // We wrap this in try-catch because on Android < 14 without Health Connect installed,
      // this throws an UnsupportedError.
      requested = await _health.requestAuthorization(types);
    } catch (e) {
      debugPrint("Health Connect not available or error: $e");
      if (Platform.isAndroid &&
          e.toString().contains("Health Connect is not available")) {
        // Health Connect is not installed.
        // We can prompt the user to install it, or fallback to Pedometer.
        // For now, we enable fallback and mark requested as false (for Health Connect).
        // Optionally prompt: await _health.installHealthConnect();
        _usePedometerFallback = true;
      }
    }

    // Also request activity recognition on Android if needed, though Health Connect usually handles it.
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
    }

    // Initialize Pedometer stream if fallback is needed or purely as an augmentation
    // (Pedometer gives real-time updates from sensor)
    try {
      _initPedometer();
    } catch (e) {
      debugPrint("Error initializing Pedometer: $e");
    }

    return requested || _usePedometerFallback;
  }

  void _initPedometer() {
    if (_isPedometerInitialized) return;
    _isPedometerInitialized = true;

    Pedometer.stepCountStream.listen((event) {
      _stepController.add(event);
      debugPrint("Pedometer step count: ${event.steps}");
    }, onError: (error) {
      _stepController.addError(error);
      debugPrint("Pedometer error: $error");
    });
  }

  Stream<StepCount> get stepCountStream => _stepController.stream;

  bool get isUsingPedometer => _usePedometerFallback;

  /// Fetches steps for a specific date.
  /// Returns 0 if no data or error.
  Future<int> getStepsForDate(DateTime date) async {
    if (_usePedometerFallback) {
      // TODO: Implement local storage logic to calculate daily steps from cumulative Pedometer count.
      // For now, we return 0 to avoid errors, as Pedometer stream handles real-time updates.
      return 0;
    }

    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      // We use getTotalStepsInInterval which aggregates correctly.
      int? steps = await _health.getTotalStepsInInterval(start, end);

      return steps ?? 0;
    } catch (e) {
      // Handle error (permission, etc)
      debugPrint("Error fetching steps: $e");
      return 0;
    }
  }

  /// Fetch raw steps data points (if needed for deeper verification)
  Future<List<HealthDataPoint>> getRawSteps(DateTime date) async {
    if (_usePedometerFallback) return [];

    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

      return await _health.getHealthDataFromTypes(
          startTime: start, endTime: end, types: [HealthDataType.STEPS]);
    } catch (e) {
      debugPrint("Error fetching raw steps: $e");
      return [];
    }
  }
}
