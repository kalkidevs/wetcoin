import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

class EnvConfig {
  // API Base URLs
  static const String liveBaseUrl = 'https://sweatcoin-backend.onrender.com';
  static const String localBaseUrl = 'http://localhost:5002';

  // Manual override: set this to true if you want live API, false for local
  static const bool useLiveApi = false; // Changed to false for local testing

  // Determine which base URL to use
  static String get baseUrl {
    const url = useLiveApi ? liveBaseUrl : localBaseUrl;

    // Log which API URL is being used
    AppLogger.section('API CONFIGURATION');
    AppLogger.config('API_MODE', useLiveApi ? 'LIVE' : 'LOCAL');
    AppLogger.config('BASE_URL', url);
    AppLogger.config('ENVIRONMENT', kDebugMode ? 'DEBUG' : 'RELEASE');
    AppLogger.status('API_CONNECTION', 'OK', 'Connected to $url');

    return url;
  }

  // API Endpoints
  static String get syncEndpoint => '$baseUrl/api/sync';
  static String get walletEndpoint => '$baseUrl/api/wallet';
  static String get rewardsEndpoint => '$baseUrl/api/rewards';

  // Health check endpoint
  static String get healthEndpoint => '$baseUrl/health';

  /// Log current configuration
  static void logCurrentConfig() {
    AppLogger.section('CURRENT CONFIGURATION');
    AppLogger.config('API_MODE', useLiveApi ? 'LIVE' : 'LOCAL');
    AppLogger.config('BASE_URL', baseUrl);
    AppLogger.config('SYNC_ENDPOINT', syncEndpoint);
    AppLogger.config('WALLET_ENDPOINT', walletEndpoint);
    AppLogger.config('REWARDS_ENDPOINT', rewardsEndpoint);
    AppLogger.config('HEALTH_ENDPOINT', healthEndpoint);
    AppLogger.config('ENVIRONMENT', kDebugMode ? 'DEBUG' : 'RELEASE');
    AppLogger.config('PLATFORM', defaultTargetPlatform.toString());
  }
}
