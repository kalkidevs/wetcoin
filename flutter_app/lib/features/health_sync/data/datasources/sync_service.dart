import 'package:flutter/material.dart';
import 'package:sweatcoin/core/config/env_config.dart';
import 'package:sweatcoin/core/utils/logger.dart';
import 'health_service.dart';
import 'package:intl/intl.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SyncService {
  final HealthService _healthService;

  SyncService(this._healthService);

  Future<Map<String, dynamic>> syncToday() async {
    return await syncDate(DateTime.now());
  }

  Future<Map<String, dynamic>> syncDate(DateTime date) async {
    try {
      // 1. Get Steps
      int steps = await _healthService.getStepsForDate(date);

      // 2. Get Device ID
      String deviceId = await _getDeviceId();
      String dateStr = DateFormat('yyyy-MM-dd').format(date);
      String userId = await _getUserId();

      debugPrint("Syncing steps for $dateStr: $steps");

      // 3. Call REST API with environment-based URL
      final endpoint = EnvConfig.syncEndpoint;
      AppLogger.section('STEP SYNC OPERATION');
      AppLogger.syncSteps(userId, steps, date, deviceId);
      AppLogger.apiCall('/api/sync', 'POST', {
        'userId': userId,
        'steps': steps,
        'date': dateStr,
        'deviceId': deviceId
      });
      AppLogger.config('API_URL', endpoint);

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'steps': steps,
          'date': dateStr,
          'deviceId': deviceId,
          'requestTimestamp': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint("Sync successful: $result");
        return result;
      } else {
        debugPrint("Sync failed with status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
        return {
          'success': false,
          'error': 'Sync failed. Please try again later.',
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
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
  }
}
