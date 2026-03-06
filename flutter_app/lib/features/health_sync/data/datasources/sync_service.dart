import 'package:flutter/material.dart';
import 'package:sweatcoin/core/utils/logger.dart';
import 'package:sweatcoin/core/services/api_service.dart';
import 'health_service.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SyncService {
  final HealthService _healthService;
  final ApiService _api = ApiService();

  SyncService(this._healthService);

  Future<Map<String, dynamic>> syncToday() async {
    return await syncDate(DateTime.now());
  }

  Future<Map<String, dynamic>> syncDate(DateTime date) async {
    try {
      // 1. Get Steps from Health Connect / HealthKit
      int steps = await _healthService.getStepsForDate(date);

      // 2. Get Device ID
      String deviceId = await _getDeviceId();
      String dateStr = DateFormat('yyyy-MM-dd').format(date);
      String userId = await _getUserId();

      debugPrint("Syncing steps for $dateStr: $steps");

      AppLogger.section('STEP SYNC OPERATION');
      AppLogger.syncSteps(userId, steps, date, deviceId);
      AppLogger.apiCall('/api/sync', 'POST', {
        'userId': userId,
        'steps': steps,
        'date': dateStr,
        'deviceId': deviceId
      });

      // 3. Call backend API using ApiService (sends backend JWT token automatically)
      final result = await _api.post('/api/sync', {
        'userId': userId,
        'steps': steps,
        'date': dateStr,
        'deviceId': deviceId,
        'requestTimestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (result['success'] == true) {
        debugPrint("Sync successful: $result");
        return result;
      } else {
        debugPrint("Sync failed: ${result['error']}");
        return {
          'success': false,
          'error': result['error'] ?? 'Sync failed',
          'statusCode': result['statusCode'],
        };
      }
    } catch (e) {
      debugPrint("Sync failed: $e");
      return {
        'success': false,
        'error':
            'Sync service temporarily unavailable. Please try again later.',
      };
    }
  }

  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? 'unknown_ios';
    }
    return 'unknown';
  }

  Future<String> _getUserId() async {
    // First try Firebase Auth, which is the most reliable source of truth
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }

    // Fallback to ApiService stored user ID
    final storedId = await _api.getUserId();
    if (storedId != null && storedId.isNotEmpty) {
      return storedId;
    }

    return '';
  }
}
