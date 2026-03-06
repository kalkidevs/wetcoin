import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../config/env_config.dart';

/// Centralized API service for all backend HTTP calls.
/// Manages JWT token storage and includes auth headers automatically.
/// Auto-refreshes the backend JWT if the user is signed in but has no token.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _tokenKey = 'backend_jwt_token';
  static const String _userIdKey = 'backend_user_id';
  String? _cachedToken;
  String? _cachedUserId;
  bool _isRefreshing = false;

  String get _baseUrl => EnvConfig.baseUrl;

  // ── Token Management ──

  /// Store the JWT token received from backend after verify-token
  Future<void> saveToken(String token, String userId) async {
    _cachedToken = token;
    _cachedUserId = userId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId);
    debugPrint('[ApiService] Token saved for user: $userId');
  }

  /// Get the stored JWT token, auto-refreshing if needed
  Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);

    // Auto-refresh: if no token but user is signed in via Firebase, get one
    if (_cachedToken == null && !_isRefreshing) {
      await _autoRefreshToken();
    }

    return _cachedToken;
  }

  /// Get the stored user ID
  Future<String?> getUserId() async {
    if (_cachedUserId != null) return _cachedUserId;
    final prefs = await SharedPreferences.getInstance();
    _cachedUserId = prefs.getString(_userIdKey);

    // If no stored user ID, try Firebase
    if (_cachedUserId == null) {
      _cachedUserId = FirebaseAuth.instance.currentUser?.uid;
    }

    return _cachedUserId;
  }

  /// Clear stored token (on sign out)
  Future<void> clearToken() async {
    _cachedToken = null;
    _cachedUserId = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    debugPrint('[ApiService] Token cleared');
  }

  // ── Auto Token Refresh ──

  /// If user is signed in via Firebase but has no backend JWT,
  /// automatically call verify-token to get one.
  Future<void> _autoRefreshToken() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return;

    _isRefreshing = true;
    try {
      debugPrint('[ApiService] Auto-refreshing backend JWT token...');
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) return;

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/verify-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['token'] != null && result['user']?['uid'] != null) {
          await saveToken(result['token'], result['user']['uid']);
          debugPrint('[ApiService] Auto-refresh successful');
        }
      } else {
        debugPrint('[ApiService] Auto-refresh failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ApiService] Auto-refresh error: $e');
    } finally {
      _isRefreshing = false;
    }
  }

  // ── HTTP Helpers ──

  /// Build headers with optional auth token
  Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (auth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// GET request
  Future<Map<String, dynamic>> get(String path, {bool auth = true, Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: await _headers(auth: auth))
          .timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiService] GET $path error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: await _headers(auth: auth),
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
      return _handleResponse(response);
    } catch (e) {
      debugPrint('[ApiService] POST $path error: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final result = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return result;
      }
      return {
        'success': false,
        'error': result['error'] ?? 'Request failed (${response.statusCode})',
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to parse response (${response.statusCode})',
      };
    }
  }
}
