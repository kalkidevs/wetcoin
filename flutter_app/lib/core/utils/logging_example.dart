import 'package:flutter/foundation.dart';
import 'dart:async';
import 'logger.dart';

/// Example class demonstrating how to use the enhanced logging system
class LoggingExample {
  /// Example of comprehensive authentication logging
  Future<void> demonstrateAuthLogging() async {
    AppLogger.section('AUTHENTICATION FLOW EXAMPLE');

    try {
      // User state logging
      AppLogger.userState('SIGN_IN_START', 'user123', 'user@example.com');

      // Firebase operations
      AppLogger.firebase('GOOGLE_SIGN_IN', 'Starting Google Sign-In flow');

      // API calls
      AppLogger.apiCall('/api/auth/verify-token', 'POST', {
        'idToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        'timestamp': DateTime.now().toIso8601String()
      });

      // Network requests with detailed logging
      AppLogger.network(
          'POST',
          'https://sweatcoin-backend.onrender.com/api/auth/verify-token',
          {'idToken': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'},
          200,
          {
            'success': true,
            'user': {
              'uid': 'user123',
              'name': 'John Doe',
              'email': 'user@example.com',
              'balance': 150
            },
            'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
          });

      // Database operations
      AppLogger.mongodb(
          'FIND_OR_CREATE', 'users', 'Creating new user document');

      // Performance metrics
      final stopwatch = Stopwatch()..start();
      await Future.delayed(Duration(milliseconds: 250));
      stopwatch.stop();
      AppLogger.performance('TOKEN_VERIFICATION', stopwatch.elapsed);

      // Success logging
      AppLogger.userState('SIGN_IN_SUCCESS', 'user123', 'user@example.com');
      AppLogger.auth('AUTH_SUCCESS', 'User authenticated successfully');
    } catch (error) {
      AppLogger.error('AUTH_ERROR', 'Authentication failed',
          error is Error ? error.stackTrace : null);
      AppLogger.auth('AUTH_FAILED', 'User authentication failed');
    }
  }

  /// Example of step sync logging
  Future<void> demonstrateSyncLogging() async {
    AppLogger.section('STEP SYNC EXAMPLE');

    const userId = 'user123';
    const steps = 5000;
    final date = DateTime.now();
    const deviceId = 'device_abc123';

    // Sync operation logging
    AppLogger.syncSteps(userId, steps, date, deviceId);

    // API call logging
    AppLogger.apiCall('/api/sync', 'POST', {
      'userId': userId,
      'steps': steps,
      'date': date.toIso8601String(),
      'deviceId': deviceId
    });

    // Network logging with response
    AppLogger.network(
        'POST',
        'https://sweatcoin-backend.onrender.com/api/sync',
        {
          'userId': userId,
          'steps': steps,
          'date': date.toIso8601String(),
          'deviceId': deviceId,
          'requestTimestamp': DateTime.now().millisecondsSinceEpoch
        },
        200,
        {'success': true, 'balance': 150, 'earned': 50, 'stepsSaved': 5000});

    // Performance logging
    final stopwatch = Stopwatch()..start();
    await Future.delayed(Duration(milliseconds: 150));
    stopwatch.stop();
    AppLogger.performance('STEP_SYNC', stopwatch.elapsed);

    AppLogger.info('SYNC', 'Steps synced successfully');
  }

  /// Example of system status logging
  Future<void> demonstrateStatusLogging() async {
    AppLogger.section('SYSTEM STATUS EXAMPLE');

    // Component status
    AppLogger.status('FIREBASE', 'OK', 'Authentication service connected');
    AppLogger.status('MONGODB', 'OK', 'Database connection established');
    AppLogger.status('NETWORK', 'OK', 'API endpoints responding');
    AppLogger.status('STORAGE', 'WARNING', 'Low disk space');
    AppLogger.status('BACKEND', 'ERROR', 'Service temporarily unavailable');

    // Configuration logging
    AppLogger.config('API_BASE_URL', 'https://sweatcoin-backend.onrender.com');
    AppLogger.config('ENVIRONMENT', 'development');
    AppLogger.config('DEBUG_MODE', 'true');
  }

  /// Example of error handling and debugging
  Future<void> demonstrateErrorLogging() async {
    AppLogger.section('ERROR HANDLING EXAMPLE');

    try {
      // Simulate an error
      throw Exception('Simulated network timeout');
    } catch (error, stackTrace) {
      AppLogger.error(
          'NETWORK_ERROR', 'Failed to connect to backend', stackTrace);
      AppLogger.warn('RETRY_ATTEMPT', 'Attempting to retry connection');

      // Retry logic
      try {
        await Future.delayed(Duration(seconds: 2));
        AppLogger.info('RETRY_SUCCESS', 'Connection restored');
      } catch (retryError) {
        AppLogger.error('RETRY_FAILED', 'Retry attempt failed',
            retryError is Error ? retryError.stackTrace : null);
      }
    }
  }

  /// Example of verbose debugging
  Future<void> demonstrateVerboseLogging() async {
    AppLogger.section('VERBOSE DEBUGGING EXAMPLE');

    if (kDebugMode) {
      AppLogger.verbose('DEBUG_INFO', 'Detailed debugging information');
      AppLogger.verbose('VARIABLE_STATE',
          'userId: user123, steps: 5000, date: ${DateTime.now()}');
      AppLogger.verbose('CONFIG_STATE',
          'API_BASE_URL: https://sweatcoin-backend.onrender.com');
      AppLogger.verbose('PERMISSIONS',
          'Location: granted, Health: granted, Storage: granted');
    }
  }

  /// Example of API response logging
  Future<void> demonstrateApiResponseLogging() async {
    AppLogger.section('API RESPONSE EXAMPLE');

    const endpoint = '/api/auth/verify-token';
    const statusCode = 200;
    final duration = Duration(milliseconds: 250);
    final responseData = {
      'success': true,
      'user': {
        'uid': 'user123',
        'name': 'John Doe',
        'email': 'user@example.com',
        'balance': 150,
        'lifetimeSteps': 50000,
        'lifetimeCoins': 500
      },
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
    };

    AppLogger.apiResponse(endpoint, statusCode, duration, responseData);
  }

  /// Run all logging examples
  Future<void> runAllExamples() async {
    AppLogger.clear();
    AppLogger.section('COMPREHENSIVE LOGGING DEMO');

    await demonstrateAuthLogging();
    await demonstrateSyncLogging();
    await demonstrateStatusLogging();
    await demonstrateErrorLogging();
    await demonstrateVerboseLogging();
    await demonstrateApiResponseLogging();

    AppLogger.section('LOGGING DEMO COMPLETE');
  }
}

/// Usage example:
/// 
/// final loggerExample = LoggingExample();
/// await loggerExample.runAllExamples();
/// 
/// This will produce output like:
/// 
/// ==================================== COMPREHENSIVE LOGGING DEMO ====================================
/// 
/// ==================================== AUTHENTICATION FLOW EXAMPLE ====================================
/// [USER][SIGN_IN_START] User: user123 (user@example.com)
/// [FIREBASE][GOOGLE_SIGN_IN] Starting Google Sign-In flow
/// [API][CALL] POST /api/auth/verify-token
/// [API][PARAMS] {
///   "idToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
///   "timestamp": "2026-02-26T12:17:00.123"
/// }
/// [NETWORK][REQUEST] POST https://sweatcoin-backend.onrender.com/api/auth/verify-token [200]
/// [NETWORK][REQUEST_BODY] {
///   "idToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// }
/// [NETWORK][RESPONSE] {
///   "success": true,
///   "user": {
///     "uid": "user123",
///     "name": "John Doe",
///     "email": "user@example.com",
///     "balance": 150
///   },
///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// }
/// [MONGODB][FIND_OR_CREATE] users - Creating new user document
/// [PERF][TOKEN_VERIFICATION] 250ms
/// [USER][SIGN_IN_SUCCESS] User: user123 (user@example.com)
/// [AUTH][AUTH_SUCCESS] User authenticated successfully
/// 
/// ==================================== STEP SYNC EXAMPLE ====================================
/// [SYNC][STEPS] User: user123, Steps: 5000, Date: 2026-02-26T12:17:00.123, Device: device_abc123
/// [API][CALL] POST /api/sync
/// [API][PARAMS] {
///   "userId": "user123",
///   "steps": 5000,
///   "date": "2026-02-26T12:17:00.123",
///   "deviceId": "device_abc123"
/// }
/// [NETWORK][REQUEST] POST https://sweatcoin-backend.onrender.com/api/sync [200]
/// [NETWORK][REQUEST_BODY] {
///   "userId": "user123",
///   "steps": 5000,
///   "date": "2026-02-26T12:17:00.123",
///   "deviceId": "device_abc123",
///   "requestTimestamp": 1740542820123
/// }
/// [NETWORK][RESPONSE] {
///   "success": true,
///   "balance": 150,
///   "earned": 50,
///   "stepsSaved": 5000
/// }
/// [PERF][STEP_SYNC] 150ms
/// [INFO][SYNC] Steps synced successfully
/// 
/// ==================================== SYSTEM STATUS EXAMPLE ====================================
/// [STATUS][FIREBASE] OK - Authentication service connected
/// [STATUS][MONGODB] OK - Database connection established
/// [STATUS][NETWORK] OK - API endpoints responding
/// [STATUS][STORAGE] WARNING - Low disk space
/// [STATUS][BACKEND] ERROR - Service temporarily unavailable
/// [CONFIG][API_BASE_URL] https://sweatcoin-backend.onrender.com
/// [CONFIG][ENVIRONMENT] development
/// [CONFIG][DEBUG_MODE] true
/// 
/// ==================================== ERROR HANDLING EXAMPLE ====================================
/// [ERROR][NETWORK_ERROR] Failed to connect to backend
/// [STACKTRACE][NETWORK_ERROR] #0   LoggingExample.demonstrateErrorLogging
/// #1   _AsyncAwaitCompleter.start
/// #2   LoggingExample.demonstrateErrorLogging
/// ...
/// [WARN][RETRY_ATTEMPT] Attempting to retry connection
/// [INFO][RETRY_SUCCESS] Connection restored
/// 
/// ==================================== VERBOSE DEBUGGING EXAMPLE ====================================
/// [VERBOSE][DEBUG_INFO] Detailed debugging information
/// [VERBOSE][VARIABLE_STATE] userId: user123, steps: 5000, date: 2026-02-26 12:17:00.123
/// [VERBOSE][CONFIG_STATE] API_BASE_URL: https://sweatcoin-backend.onrender.com
/// [VERBOSE][PERMISSIONS] Location: granted, Health: granted, Storage: granted
/// 
/// ==================================== API RESPONSE EXAMPLE ====================================
/// [API_RESPONSE][/api/auth/verify-token] Status: 200, Time: 250ms
/// [API_RESPONSE][DATA] {
///   "success": true,
///   "user": {
///     "uid": "user123",
///     "name": "John Doe",
///     "email": "user@example.com",
///     "balance": 150,
///     "lifetimeSteps": 50000,
///     "lifetimeCoins": 500
///   },
///   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
/// }
/// 
/// ==================================== LOGGING DEMO COMPLETE ====================================