import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/env_config.dart';
import '../utils/logger.dart';

class ConnectionService {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = false;
  bool _isApiReachable = false;

  static final ConnectionService _instance = ConnectionService._internal();

  factory ConnectionService() => _instance;

  ConnectionService._internal();

  /// Check internet connection status
  Future<bool> checkConnection() async {
    try {
      AppLogger.section('CONNECTION CHECK');
      AppLogger.info(
          'CONNECTION_CHECK_START', 'Checking internet connection...');

      final connectivityResult = await _connectivity.checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        AppLogger.warn('NO_INTERNET', 'No internet connection available');
        _isConnected = false;
        _isApiReachable = false;
        return false;
      }

      AppLogger.status(
          'INTERNET_STATUS', 'OK', 'Internet connection available');
      _isConnected = true;

      // Test API reachability
      final isApiReachable = await _testApiReachability();
      _isApiReachable = isApiReachable;

      return true;
    } catch (e) {
      AppLogger.error(
          'CONNECTION_CHECK_ERROR', 'Error checking connection: $e');
      _isConnected = false;
      _isApiReachable = false;
      return false;
    }
  }

  /// Test if the API is reachable
  Future<bool> _testApiReachability() async {
    try {
      AppLogger.info('API_REACHABILITY_TEST', 'Testing API reachability...');

      final response = await http.get(
        Uri.parse(EnvConfig.healthEndpoint),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warn('API_TIMEOUT', 'API request timed out');
          return http.Response('Timeout', 408);
        },
      );

      final isReachable = response.statusCode == 200;

      if (isReachable) {
        AppLogger.status('API_STATUS', 'OK', 'API is reachable');
        AppLogger.config('API_MODE', EnvConfig.useLiveApi ? 'LIVE' : 'LOCAL');
        AppLogger.config('API_URL', EnvConfig.baseUrl);
      } else {
        AppLogger.warn('API_UNREACHABLE',
            'API is not reachable, status: ${response.statusCode}');
      }

      return isReachable;
    } catch (e) {
      AppLogger.warn('API_UNREACHABLE', 'API is not reachable: $e');
      return false;
    }
  }

  /// Show connection status popup
  Future<void> showConnectionStatus(BuildContext context) async {
    if (!_isConnected) {
      AppLogger.warn(
          'SHOWING_NO_CONNECTION_POPUP', 'Showing no connection popup');

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.red),
                SizedBox(width: 8),
                Text('No Internet Connection'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please check your internet connection and try again.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  'The app requires an active internet connection to function properly.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Retry connection check
                  checkConnection().then((connected) {
                    if (connected) {
                      showConnectionStatus(context);
                    }
                  });
                },
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Exit'),
              ),
            ],
          );
        },
      );
    }
    // Only show popup when there's no internet connection
    // Do not show any popup when connected (whether API is reachable or not)
  }

  /// Initialize connection check on app start
  Future<void> initializeConnectionCheck(BuildContext context) async {
    AppLogger.section('APP_INITIALIZATION');
    AppLogger.info('INITIALIZATION_START', 'Starting app initialization...');

    // Log current configuration
    EnvConfig.logCurrentConfig();

    // Check connection
    final isConnected = await checkConnection();

    if (!isConnected) {
      AppLogger.warn(
          'INITIALIZATION_FAILED', 'No internet connection, showing popup');
      await showConnectionStatus(context);
    } else {
      AppLogger.info('INITIALIZATION_SUCCESS', 'Connection check passed');
      await showConnectionStatus(context);
    }
  }

  /// Get current connection status
  bool get isConnected => _isConnected;
  bool get isApiReachable => _isApiReachable;

  /// Monitor connection changes
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}
