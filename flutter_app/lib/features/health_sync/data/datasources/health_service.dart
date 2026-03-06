import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// Service responsible for interacting with Health Connect (Android) and HealthKit (iOS).
/// Fetches aggregated step data from external apps (e.g. Google Fit, Apple Health).
class HealthService {
  final Health _health;
  bool _permissionsGranted = false;

  HealthService({Health? health}) : _health = health ?? Health();

  /// Configures the Health API (types to request).
  static const List<HealthDataType> _types = [
    HealthDataType.STEPS,
  ];

  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
  ];

  /// Requests permissions for Health Connect (Android) or HealthKit (iOS).
  Future<bool> requestPermissions() async {
    try {
      // 1. Configure the health plugin (required before any API call)
      await _health.configure();

      if (Platform.isAndroid) {
        // Check if Health Connect is installed
        try {
          final status = await _health.getHealthConnectSdkStatus();
          debugPrint("[HealthService] Health Connect SDK status: $status");

          if (status == HealthConnectSdkStatus.sdkUnavailable ||
              status == HealthConnectSdkStatus.sdkUnavailableProviderUpdateRequired) {
            debugPrint("[HealthService] Health Connect not available. Prompting install...");
            await _health.installHealthConnect();
            return false;
          }
        } catch (e) {
          debugPrint("[HealthService] Error checking Health Connect status: $e");
        }
      }

      // 2. Always request authorization (don't rely on hasPermissions which can be unreliable)
      debugPrint("[HealthService] Requesting health permissions...");
      _permissionsGranted = await _health.requestAuthorization(
        _types,
        permissions: _permissions,
      );
      debugPrint("[HealthService] Permissions granted: $_permissionsGranted");

      return _permissionsGranted;
    } catch (e) {
      debugPrint("[HealthService] Permission request error: $e");

      if (Platform.isAndroid && e.toString().contains("Health Connect")) {
        try {
          await _health.installHealthConnect();
        } catch (_) {}
      }
      return false;
    }
  }

  /// Fetches total steps for today (midnight to now).
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return getStepsForRange(start, now);
  }

  /// Fetches steps for a specific date (full day).
  Future<int> getStepsForDate(DateTime date) async {
    final now = DateTime.now();
    final start = DateTime(date.year, date.month, date.day);
    // If it's today, only go up to now; otherwise full day
    final end = (date.year == now.year && date.month == now.month && date.day == now.day)
        ? now
        : DateTime(date.year, date.month, date.day, 23, 59, 59);
    return getStepsForRange(start, end);
  }

  /// Fetches steps for a specific range from Health Connect / HealthKit.
  Future<int> getStepsForRange(DateTime start, DateTime end) async {
    try {
      // Ensure permissions are granted before fetching
      if (!_permissionsGranted) {
        debugPrint("[HealthService] Permissions not yet granted; requesting...");
        final granted = await requestPermissions();
        if (!granted) {
          debugPrint("[HealthService] Permissions denied, returning 0 steps");
          return 0;
        }
      }

      final steps = await _health.getTotalStepsInInterval(start, end);
      debugPrint("[HealthService] Fetched ${steps ?? 0} steps for ${start.toIso8601String()} to ${end.toIso8601String()}");
      return steps ?? 0;
    } catch (e) {
      debugPrint("[HealthService] Fetch steps error: $e");

      // If permission error, mark as not granted and try once more
      if (e.toString().contains('SecurityException') ||
          e.toString().contains('READ_STEPS')) {
        debugPrint("[HealthService] Permission revoked — re-requesting...");
        _permissionsGranted = false;
        final granted = await requestPermissions();
        if (granted) {
          try {
            final steps = await _health.getTotalStepsInInterval(start, end);
            return steps ?? 0;
          } catch (retryError) {
            debugPrint("[HealthService] Retry also failed: $retryError");
          }
        }
      }

      return 0;
    }
  }

  /// Returns raw health data points if needed for debugging.
  Future<List<HealthDataPoint>> getRawData(DateTime start, DateTime end) async {
    try {
      return await _health.getHealthDataFromTypes(
        startTime: start,
        endTime: end,
        types: _types,
      );
    } catch (e) {
      debugPrint("[HealthService] Raw data error: $e");
      return [];
    }
  }

  void dispose() {
    // No streams to close
  }
}
