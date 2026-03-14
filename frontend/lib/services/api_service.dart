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

  static String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final detail = decoded['detail'];

      if (detail is String) return detail;

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null) {
          return first['msg'].toString();
        }
        return detail.toString();
      }

      if (decoded['message'] != null) return decoded['message'].toString();
      if (decoded['error'] != null) return decoded['error'].toString();

      return "Server error (${response.statusCode})";
    } catch (_) {
      return "Server error (${response.statusCode}): ${response.body}";
    }
  }

  static dynamic _safeJsonDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> login(
      String emailOrPhone, String password) async {
    try {
      final body = {
        'email_or_phone': emailOrPhone.trim(),
        'password': password.trim(),
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        userId = (decoded['user_id'] ?? decoded['userId'])?.toString();
        userName = decoded['full_name']?.toString();
        userEmail = decoded['email']?.toString();
        userPhone = decoded['phone']?.toString();
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
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
      await http
          .post(
            Uri.parse('$baseUrl/history/save'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {}
  }

  static Future<List<dynamic>> getUserHistory() async {
    if (userId == null) throw Exception('User not logged in');

    try {
      final response = await http
          .get(Uri.parse('$baseUrl/history/$userId'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return List<dynamic>.from(decoded['data'] ?? []);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  static Future<Map<String, dynamic>> getLocationSummary(
      double lat, double lon) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/location/summary'),
            headers: _headers,
            body: jsonEncode({'lat': lat, 'lon': lon}),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      final decoded = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      throw Exception("Health check failed");
    } catch (e) {
      throw Exception('Health check error: $e');
    }
  }
}