import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    if (Platform.isAndroid) return "http://127.0.0.1:8000";
    return "http://127.0.0.1:8000";
  }

  static String? userId;
  static String? userName;
  static String? userEmail;
  static String? userPhone;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static String _extractErrorMessage(http.Response response) {
    final decoded = _safeJsonDecode(response.body);

    if (decoded is Map) {
      if (decoded['detail'] is String) return decoded['detail'];
      if (decoded['message'] != null) return decoded['message'].toString();
      if (decoded['error'] != null) return decoded['error'].toString();

      if (decoded['detail'] is List && decoded['detail'].isNotEmpty) {
        final first = decoded['detail'].first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
      }
    }

    return "Server error (${response.statusCode})";
  }

  static Future<http.Response> _post(String path, Map<String, dynamic> body) {
    return http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 20));
  }

  static Future<http.Response> _get(String path) {
    return http
        .get(Uri.parse('$baseUrl$path'), headers: _headers)
        .timeout(const Duration(seconds: 20));
  }

  static Future<Map<String, dynamic>> login(
      String emailOrPhone, String password) async {
    try {
      final response = await _post('/api/auth/login', {
        'email_or_phone': emailOrPhone.trim(),
        'password': password.trim(),
      });

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        userId = (decoded['user_id'] ?? decoded['userId'])?.toString();
        userName = decoded['full_name']?.toString();
        userEmail = decoded['email']?.toString();
        userPhone = decoded['phone']?.toString();
        return Map<String, dynamic>.from(decoded);
      }

      throw Exception(_extractErrorMessage(response));
    } on TimeoutException {
      throw Exception('Connection timed out.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<void> logout() async {
    userId = null;
    userName = null;
    userEmail = null;
    userPhone = null;
    await SessionService.clearSession();
  }

  static Future<void> saveToHistory(Map<String, dynamic> data) async {
    if (userId == null) return;

    data['userId'] = userId;

    try {
      await _post('/history/save', data);
    } catch (_) {}
  }

  static Future<List<dynamic>> getUserHistory() async {
    if (userId == null) throw Exception('User not logged in');

    try {
      final response = await _get('/history/$userId');
      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return List<dynamic>.from(decoded['data'] ?? []);
      }

      throw Exception(_extractErrorMessage(response));
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  static Future<Map<String, dynamic>> getLocationSummary(
      double lat, double lon) async {
    try {
      final response = await _post('/location/summary', {
        'lat': lat,
        'lon': lon,
      });

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded['data']);
      }

      throw Exception(_extractErrorMessage(response));
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<bool> checkHealth() async {
    try {
      final response = await _get('/health');
      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }
}