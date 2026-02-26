import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pedometer/pedometer.dart';


/// Service responsible for interacting with Health Connect (Android) and HealthKit (iOS).
class HealthService {
  final Health _health;
  final Stream<StepCount>? _pedometerStream;

  // Stream controller to broadcast step updates from Pedometer (fallback/real-time)
  final StreamController<StepCount> _stepController =
      StreamController.broadcast();

  bool _isHealthConnectAvailable = false;
  bool _usePedometerFallback = false;

  HealthService({Health? health, Stream<StepCount>? pedometerStream})
      : _health = health ?? Health(),
        _pedometerStream = pedometerStream;

  /// Returns the stream of steps from Pedometer (if available/fallback).
  Stream<StepCount> get stepCountStream => _stepController.stream;

  /// Returns true if using Pedometer as fallback.
  bool get isUsingPedometer => _usePedometerFallback;

  /// Configures the Health API (types to request).
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
  ];

  /// Requests permissions for Health Connect (Android) or HealthKit (iOS).
  /// Also initializes Pedometer as a secondary source.
  Future<bool> requestPermissions() async {
    bool granted = false;
    try {
      // 1. Check/Request Health Permissions
      // configure() is required for Android before requesting permissions
      await _health.configure();

      // Request authorization
      granted = await _health.requestAuthorization(_types);

      if (Platform.isAndroid) {
        // Check if Health Connect is actually available/installed
        // Note: health package handles this check internally in requestAuthorization usually,
        // but we can infer from result or platform checks.
        // If granted is false, it might mean denied OR not available.
        // We can check `getHealthConnectSdkStatus` if needed, but for now we assume
        // if not granted, we might need fallback.

        // Also request Activity Recognition for Pedometer/Legacy Android
        await Permission.activityRecognition.request();
      }
    } catch (e) {
      debugPrint("Health API Error: $e");
      // If Health Connect is missing or error, enable fallback
      _usePedometerFallback = true;
    }

    if (!granted) {
      _usePedometerFallback = true;
    }

    // 2. Initialize Pedometer (Always init if possible for real-time UI updates)
    _initPedometer();

    return granted;
  }

  /// Initialize Pedometer stream.
  void _initPedometer() {
    try {
      final stream = _pedometerStream ?? Pedometer.stepCountStream;
      stream.listen(
        (event) {
          _stepController.add(event);
          debugPrint("Pedometer: ${event.steps}");
        },
        onError: (error) {
          debugPrint("Pedometer Error: $error");
          _stepController.addError(error);
        },
      );
    } catch (e) {
      debugPrint("Pedometer Init Error: $e");
    }
  }

  /// Fetches total steps for today (midnight to now).
  /// Returns 0 if failed.
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return getStepsForRange(start, now);
  }

  /// Fetches steps for a specific date (full day).
  Future<int> getStepsForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getStepsForRange(start, end);
  }

  /// Fetches steps for a specific range.
  Future<int> getStepsForRange(DateTime start, DateTime end) async {
    if (_usePedometerFallback) {
      return 0;
    }

    try {
      // Using getTotalStepsInInterval is the most reliable method in `health` package
      final steps = await _health.getTotalStepsInInterval(start, end);
      return steps ?? 0;
    } catch (e) {
      debugPrint("HealthService Fetch Error: $e");
      // If Health Connect fails (e.g. not initialized), fallback to 0 instead of crashing UI
      // We can also enable fallback mode here if it looks like a perm/availability issue
      if (e.toString().contains(
              "lateinit property dataReader has not been initialized") ||
          e.toString().contains("Health Connect is not available")) {
        _usePedometerFallback = true;
        return 0;
      }
      return 0;
    }
  }

  /// Returns raw health data points if needed for debugging.
  Future<List<HealthDataPoint>> getRawData(DateTime start, DateTime end) async {
    if (_usePedometerFallback) return [];
    try {
      return await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _types,
      );
    } catch (e) {
      debugPrint("HealthService Raw Data Error: $e");
      return [];
    }
  }

  void dispose() {
    _stepController.close();
  }
}
