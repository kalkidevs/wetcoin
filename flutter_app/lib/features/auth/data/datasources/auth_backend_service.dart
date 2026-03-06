import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:sweatcoin/core/config/env_config.dart';
import 'package:sweatcoin/core/utils/logger.dart';
import 'package:sweatcoin/core/services/api_service.dart';

/// Service for communicating with our backend API
class AuthBackendService {
  String get _baseUrl => EnvConfig.baseUrl;

  /// Verify Firebase ID token with backend and get user data
  Future<Map<String, dynamic>> verifyToken(String idToken) async {
    try {
      AppLogger.section('BACKEND TOKEN VERIFICATION');
      AppLogger.auth('TOKEN_VERIFICATION_START',
          'Verifying Firebase ID token with backend');
      AppLogger.apiCall('/api/auth/verify-token', 'POST', {
        'idToken': '${idToken.substring(0, 20)}...',
        'timestamp': DateTime.now().toIso8601String()
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/verify-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      AppLogger.network(
          'POST',
          '$_baseUrl/api/auth/verify-token',
          {'idToken': '${idToken.substring(0, 20)}...'},
          response.statusCode,
          response.body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        AppLogger.auth('TOKEN_VERIFICATION_SUCCESS',
            'Token verified successfully. User: ${result['user']['name']} (${result['user']['email']})');
        AppLogger.auth('USER_DATA_RECEIVED',
            'Balance: ${result['user']['balance']}, Steps: ${result['user']['lifetimeSteps']}');

        // Save JWT token for authenticated API calls
        if (result['token'] != null && result['user']['uid'] != null) {
          await ApiService().saveToken(result['token'], result['user']['uid']);
        }

        return result;
      } else if (response.statusCode == 404) {
        AppLogger.warn('TOKEN_VERIFICATION_FAILED',
            'API endpoint not found (404). Status: ${response.statusCode}, Body: ${response.body}');
        return {
          'success': false,
          'error':
              'API endpoint not found. Please check if the backend server is running and has the correct routes.'
        };
      } else {
        AppLogger.warn('TOKEN_VERIFICATION_FAILED',
            'Backend token verification failed with status: ${response.statusCode}, Body: ${response.body}');
        return {'success': false, 'error': 'Backend token verification failed'};
      }
    } catch (e) {
      AppLogger.error('TOKEN_VERIFICATION_ERROR',
          'Network error during token verification: $e');
      return {
        'success': false,
        'error': 'Network error during token verification'
      };
    }
  }

  /// Refresh user data from backend
  Future<Map<String, dynamic>> refreshUser(String userId) async {
    try {
      debugPrint('[AuthBackendService] Refreshing user data...');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/refresh-user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': userId,
        }),
      );

      debugPrint(
          '[AuthBackendService] Refresh response status: ${response.statusCode}');
      debugPrint(
          '[AuthBackendService] Refresh response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        debugPrint('[AuthBackendService] User data refreshed successfully');
        return result;
      } else {
        debugPrint('[AuthBackendService] User refresh failed');
        return {'success': false, 'error': 'Failed to refresh user data'};
      }
    } catch (e) {
      debugPrint('[AuthBackendService] Error refreshing user: $e');
      return {'success': false, 'error': 'Network error during user refresh'};
    }
  }

  /// Sync steps with backend
  Future<Map<String, dynamic>> syncSteps({
    required String userId,
    required int steps,
    required DateTime date,
    required String deviceId,
  }) async {
    try {
      debugPrint('[AuthBackendService] Syncing steps with backend...');

      final result = await ApiService().post('/api/sync', {
        'userId': userId,
        'steps': steps,
        'date': date.toIso8601String().split('T').first, // YYYY-MM-DD format
        'deviceId': deviceId,
        'requestTimestamp': DateTime.now().millisecondsSinceEpoch,
      });

      if (result['success'] == true) {
        debugPrint('[AuthBackendService] Steps synced successfully');
        return result;
      } else {
        debugPrint('[AuthBackendService] Steps sync failed: ${result['error']}');
        return {'success': false, 'error': result['error'] ?? 'Failed to sync steps'};
      }
    } catch (e) {
      debugPrint('[AuthBackendService] Error syncing steps: $e');
      return {'success': false, 'error': 'Network error during step sync'};
    }
  }
}
