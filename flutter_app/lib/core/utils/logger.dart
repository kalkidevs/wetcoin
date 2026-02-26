import 'package:flutter/foundation.dart';
import 'dart:convert';

/// Enhanced centralized logging utility for comprehensive debugging
class AppLogger {
  static const bool _isDebug = kDebugMode;
  static const bool _isVerbose = true; // Set to false in production
  static const bool _showColors = true; // Enable colored output for better visibility

  // ANSI color codes for terminal output
  static const String _reset = '\x1b[0m';
  static const String _bold = '\x1b[1m';
  static const String _dim = '\x1b[2m';

  // Colors
  static const String _red = '\x1b[31m';
  static const String _green = '\x1b[32m';
  static const String _yellow = '\x1b[33m';
  static const String _blue = '\x1b[34m';
  static const String _magenta = '\x1b[35m';
  static const String _cyan = '\x1b[36m';
  static const String _white = '\x1b[37m';

  /// Format log message with colors and timestamp
  static String _formatMessage(String level, String tag, String message) {
    final timestamp =
        DateTime.now().toIso8601String().split('T').last.split('.').first;
    final color = _getColorForLevel(level);

    if (_showColors && _isDebug) {
      return '$color[$level]$_reset [$timestamp] [$tag] $message';
    } else {
      return '[$level] [$timestamp] [$tag] $message';
    }
  }

  /// Get color for log level
  static String _getColorForLevel(String level) {
    switch (level) {
      case 'DEBUG':
        return _cyan;
      case 'INFO':
        return _green;
      case 'WARN':
        return _yellow;
      case 'ERROR':
        return _red;
      case 'VERBOSE':
        return _dim + _white;
      case 'NETWORK':
        return _blue;
      case 'AUTH':
        return _magenta;
      case 'DATABASE':
        return _yellow;
      default:
        return _white;
    }
  }

  /// Log debug messages
  static void debug(String tag, String message) {
    if (_isDebug) {
      debugPrint(_formatMessage('DEBUG', tag, message));
    }
  }

  /// Log info messages
  static void info(String tag, String message) {
    if (_isDebug) {
      debugPrint(_formatMessage('INFO', tag, message));
    }
  }

  /// Log warning messages
  static void warn(String tag, String message) {
    debugPrint(_formatMessage('WARN', tag, message));
  }

  /// Log error messages
  static void error(String tag, String message, [StackTrace? stackTrace]) {
    debugPrint(_formatMessage('ERROR', tag, message));
    if (stackTrace != null && _isVerbose) {
      debugPrint(_formatMessage('STACKTRACE', tag, stackTrace.toString()));
    }
  }

  /// Log verbose messages (detailed debugging)
  static void verbose(String tag, String message) {
    if (_isDebug && _isVerbose) {
      debugPrint(_formatMessage('VERBOSE', tag, message));
    }
  }

  /// Log network requests with detailed information
  static void network(String method, String url,
      [dynamic body, int? statusCode, dynamic responseBody]) {
    if (_isDebug) {
      final statusColor =
          statusCode != null && statusCode >= 400 ? _red : _green;
      final statusText =
          statusCode != null ? '[$statusColor$statusCode$_reset]' : '';

      debugPrint(_formatMessage('NETWORK', 'REQUEST', '$method $url $statusText'));

      if (body != null) {
        final bodyStr = body is Map || body is List
            ? const JsonEncoder.withIndent('  ').convert(body)
            : body.toString();
        debugPrint(_formatMessage('NETWORK', 'REQUEST_BODY', bodyStr));
      }

      if (responseBody != null) {
        final responseStr = responseBody is Map || responseBody is List
            ? const JsonEncoder.withIndent('  ').convert(responseBody)
            : responseBody.toString();
        debugPrint(_formatMessage('NETWORK', 'RESPONSE', responseStr));
      }
    }
  }

  /// Log authentication events
  static void auth(String event, String message) {
    debugPrint(_formatMessage('AUTH', event, message));
  }

  /// Log database operations
  static void database(String operation, String collection, [String? details]) {
    if (_isDebug) {
      debugPrint(_formatMessage('DATABASE', operation,
          '$collection ${details != null ? '- $details' : ''}'));
    }
  }

  /// Log API endpoint calls
  static void apiCall(String endpoint, String method,
      [Map<String, dynamic>? params]) {
    if (_isDebug) {
      debugPrint(_formatMessage('API', 'CALL', '$method $endpoint'));
      if (params != null && params.isNotEmpty) {
        final paramsStr = const JsonEncoder.withIndent('  ').convert(params);
        debugPrint(_formatMessage('API', 'PARAMS', paramsStr));
      }
    }
  }

  /// Log step sync operations
  static void syncSteps(
      String userId, int steps, DateTime date, String deviceId) {
    if (_isDebug) {
      debugPrint(_formatMessage('SYNC', 'STEPS',
          'User: $userId, Steps: $steps, Date: ${date.toIso8601String()}, Device: $deviceId'));
    }
  }

  /// Log user authentication state
  static void userState(String state, String userId, [String? email]) {
    if (_isDebug) {
      final userStr = email != null ? '$userId ($email)' : userId;
      debugPrint(_formatMessage('USER', state, 'User: $userStr'));
    }
  }

  /// Log Firebase operations
  static void firebase(String operation, String message) {
    debugPrint(_formatMessage('FIREBASE', operation, message));
  }

  /// Log MongoDB operations
  static void mongodb(String operation, String collection, [String? details]) {
    if (_isDebug) {
      debugPrint(_formatMessage('MONGODB', operation,
          '$collection ${details != null ? '- $details' : ''}'));
    }
  }

  /// Log configuration changes
  static void config(String configName, String value) {
    if (_isDebug) {
      debugPrint(_formatMessage('CONFIG', configName, value));
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    if (_isDebug) {
      final color = duration.inMilliseconds > 1000
          ? _red
          : duration.inMilliseconds > 500
              ? _yellow
              : _green;
      debugPrint(_formatMessage('PERF', operation, '${duration.inMilliseconds}ms'));
    }
  }

  /// Log system status
  static void status(String component, String status, [String? details]) {
    final color = status == 'OK'
        ? _green
        : status == 'WARNING'
            ? _yellow
            : _red;
    final statusText = '$color$status$_reset';
    final detailsText = details != null ? " - $details" : "";
    debugPrint(_formatMessage('STATUS', component, '$statusText$detailsText'));
  }

  /// Clear console (for better readability during debugging)
  static void clear() {
    if (_isDebug) {
      debugPrint('\x1b[2J\x1b[H'); // ANSI escape code to clear screen
    }
  }

  /// debugPrint section separator
  static void section(String title) {
    if (_isDebug) {
      final separator = '=' * (title.length + 4);
      debugPrint('\n$_bold$separator$_reset');
      debugPrint("  $title");
      debugPrint('$separator$_reset\n');
    }
  }

  /// debugPrint API response summary
  static void apiResponse(String endpoint, int statusCode, Duration duration,
      [dynamic data]) {
    if (_isDebug) {
      final statusColor = statusCode >= 400
          ? _red
          : statusCode >= 300
              ? _yellow
              : _green;
      final durationColor = duration.inMilliseconds > 1000
          ? _red
          : duration.inMilliseconds > 500
              ? _yellow
              : _green;

      debugPrint(_formatMessage('API_RESPONSE', endpoint,
          'Status: $statusColor$statusCode$_reset, Time: $durationColor${duration.inMilliseconds}ms$_reset'));

      if (data != null && _isVerbose) {
        final dataStr = data is Map || data is List
            ? const JsonEncoder.withIndent('  ').convert(data)
            : data.toString();
        debugPrint(_formatMessage('API_RESPONSE', 'DATA', dataStr));
      }
    }
  }
}
