import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/logger.dart';

class EnvConfig {
  // API Base URLs
  static const String liveBaseUrl = 'https://sweatcoin-backend.onrender.com';
  static const String _defaultLocalBaseUrl = 'http://localhost:5001';

  // Manual override: set this to true if you want live API, false for local
  static const bool useLiveApi = false;

  // Cached base URL to avoid re-computing
  static String? _cachedBaseUrl;

  // Get local base URL, adjusting for Android Emulator if needed
  static String get localBaseUrl {
    // Try to get from .env, fallback to default
    String url = dotenv.env['API_BASE_URL'] ??
        (const bool.hasEnvironment('API_BASE_URL')
            ? const String.fromEnvironment('API_BASE_URL')
            : _defaultLocalBaseUrl);

    // Adjust for Android Emulator if it's localhost
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      url = url.replaceAll('localhost', '10.0.2.2');
      url = url.replaceAll('127.0.0.1', '10.0.2.2');
    }

    return url;
  }

  // Determine which base URL to use (no side effects — use logCurrentConfig for logging)
  static String get baseUrl {
    _cachedBaseUrl ??= useLiveApi ? liveBaseUrl : localBaseUrl;
    return _cachedBaseUrl!;
  }

  // API Endpoints
  static String get syncEndpoint => '$baseUrl/api/sync';
  static String get walletEndpoint => '$baseUrl/api/wallet';
  static String get rewardsEndpoint => '$baseUrl/api/rewards';

  // Health check endpoint
  static String get healthEndpoint => '$baseUrl/health';

  /// Log current configuration — call this once at startup
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
