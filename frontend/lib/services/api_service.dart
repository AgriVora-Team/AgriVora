import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_service.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:8000";
    // Uses adb reverse tcp:8000 tcp:8000 — phone routes through USB to host PC.
    // This works for physical devices connected via USB, regardless of Wi-Fi IP.
    if (Platform.isAndroid) return "http://127.0.0.1:8000";
    return "http://127.0.0.1:8000";
  }

  static String? userId;
  static String? userName;
  static String? userEmail;
  static String? userPhone;

  // -------------------------
  // Helpers
  // -------------------------
  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  static String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      // FastAPI often returns: {"detail":"..."} OR {"detail":[{...}]} OR {"message":"..."}
      final detail = decoded['detail'];
      if (detail is String) return detail;

      if (detail is List && detail.isNotEmpty) {
        final first = detail.first;
        if (first is Map && first['msg'] != null)
          return first['msg'].toString();
        return detail.toString();
      }

      if (decoded['message'] != null) return decoded['message'].toString();
      if (decoded['error'] != null) return decoded['error'].toString();

      return "Server error (${response.statusCode})";
    } catch (_) {
      // if response body isn't JSON
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

  // -------------------------
  // Authentication
  // -------------------------
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
      throw Exception('Connection timed out. Check if backend is running.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  static Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final pw = password.trim();

      // DEBUG (remove later): confirms what you are sending
      // If bytes > 72 with a "short" UI password, you are passing the WRONG value into signup()
      final pwBytes = utf8.encode(pw).length;
      // ignore: avoid_print
      print('SIGNUP password chars=${pw.length}, bytes=$pwBytes');

      final body = {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': pw,
      };

      // ignore: avoid_print
      print('SIGNUP body => ${jsonEncode(body)}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signup'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Check if backend is running.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // -------------------------
  // Forgot Password
  // -------------------------
  static Future<Map<String, dynamic>> requestResetOTP(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password/request-otp'),
            headers: _headers,
            body: jsonEncode({'email': email.trim().toLowerCase()}),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error requesting OTP: $e');
    }
  }

  static Future<Map<String, dynamic>> verifyResetOTP(
      String email, String otp) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password/verify-otp'),
            headers: _headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'otp': otp.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error verifying OTP: $e');
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password/reset'),
            headers: _headers,
            body: jsonEncode({
              'email': email.trim().toLowerCase(),
              'otp': otp.trim(),
              'new_password': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error resetting password: $e');
    }
  }

  // -------------------------
  // Profile / Settings
  // -------------------------
  static Future<Map<String, dynamic>> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    if (userId == null) throw Exception('User not logged in');

    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (phone != null) body['phone'] = phone;

      final response = await http
          .put(
            Uri.parse(
                '$baseUrl/api/users/profile/$userId'), // matching prefix from api.py router
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        if (fullName != null) userName = fullName;
        if (phone != null) userPhone = phone;
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (userId == null) throw Exception('User not logged in');

    try {
      final body = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };

      final response = await http
          .put(
            Uri.parse('$baseUrl/api/users/$userId/change-password'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error changing password: $e');
    }
  }

  /// Clears the in-memory session AND persisted prefs (call before navigating to login)
  static Future<void> logout() async {
    userId = null;
    userName = null;
    userEmail = null;
    userPhone = null;
    await SessionService.clearSession();
  }

  // -------------------------
  // History
  // -------------------------
  static Future<void> saveToHistory(Map<String, dynamic> data) async {
    if (userId == null) return; // Silent return for guests
    data['userId'] = userId; // Ensure userId is injected

    try {
      await http
          .post(
            Uri.parse('$baseUrl/history/save'),
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));
    } catch (e) {
      debugPrint("Failed to save explicitly to history: $e");
    }
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

  // -------------------------
  // Recommendations
  // -------------------------
  static Future<Map<String, dynamic>> getRecommendations({
    required String soilType,
    required double ph,
    required double temperature,
    required double rainfall,
    required double humidity,
  }) async {
    if (userId == null) throw Exception('User not logged in');

    try {
      final body = {
        'user_id': userId, // use snake_case for backend consistency
        'soil_type': soilType,
        'ph': ph,
        'temperature': temperature,
        'rainfall': rainfall,
        'humidity': humidity,
      };

      final response = await http
          .post(
            Uri.parse(
                '$baseUrl/recommend'), // change to /api/recommend if your backend uses that
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException {
      throw Exception('Connection timed out. Check if backend is running.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // -------------------------
  // Location Summary (Weather + Soil)
  // -------------------------
  static Future<Map<String, dynamic>> getLocationSummary(
      double lat, double lon) async {
    try {
      final body = {
        'lat': lat,
        'lon': lon,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/location/summary'),
            headers: _headers,
            body: jsonEncode(body),
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
    } on TimeoutException {
      throw Exception('Connection timed out. Check if backend is running.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // -------------------------
  // Soil Image Analysis
  // -------------------------
  static Future<Map<String, dynamic>> analyzeSoilImage(File imageFile) async {
    // TF loads the model on first request — can take 60-90s cold start.
    // Subsequent requests are fast (<3s). Timeout must be generous.
    const kAnalysisTimeout = Duration(seconds: 120);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/image/texture'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // must match "file" argument in FastAPI
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send().timeout(kAnalysisTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException {
      throw Exception('Analysis timed out after 120 s.\n'
          'The first scan takes longer while the AI model loads.\n'
          'Please try again — it will be much faster.');
    } catch (e) {
      throw Exception('Upload error: $e');
    }
  }

  // -------------------------
  // Crop Recommendation (LightGBM)
  // -------------------------
  static Future<Map<String, dynamic>> predictCropLGBM({
    required double temperature,
    required double humidity,
    required double rainfall,
    required double ph,
    required double nitrogen,
    required double carbon,
    required String soilType,
  }) async {
    try {
      final body = {
        'user_id':
            userId, // Allow backend to know who predicted this for History
        'temperature': temperature,
        'humidity': humidity,
        'rainfall': rainfall,
        'ph': ph,
        'nitrogen': nitrogen,
        'carbon': carbon,
        'soil_type': soilType,
      };

      final response = await http
          .post(
            Uri.parse('$baseUrl/crop/recommend'),
            headers: _headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 && decoded is Map) {
        // Handle both older FastAPI direct-return and standard success-envelope
        if (decoded.containsKey('success') && decoded['success'] == true) {
          return Map<String, dynamic>.from(decoded['data']);
        }
        if (decoded.containsKey('recommended_crop')) {
          return Map<String, dynamic>.from(decoded);
        }
        throw Exception(_extractErrorMessage(response));
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } on TimeoutException {
      throw Exception('Crop recommendation timed out.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }

  // -------------------------
  // Chat AI
  // -------------------------
  static final List<String> _candidateIps = [
    "http://192.168.8.106:8000",
    "http://127.0.0.1:8000",
    "http://172.20.10.4:8000",
    "http://10.31.8.3:8000",
  ];
  static String? _workingIp;

  static Future<Map<String, dynamic>> askChatAI(String message) async {
    final ipsToTry = _workingIp != null
        ? [_workingIp!, ..._candidateIps.where((ip) => ip != _workingIp)]
        : _candidateIps;

    for (String currentIp in ipsToTry) {
      try {
        final response = await http
            .post(
              Uri.parse('$currentIp/chat'),
              headers: _headers,
              body: jsonEncode({'message': message}),
            )
            .timeout(const Duration(seconds: 45));

        final decoded = _safeJsonDecode(response.body);
        if (response.statusCode == 200 &&
            decoded is Map &&
            decoded['success'] == true) {
          _workingIp = currentIp; // Save fastest/working IP
          return Map<String, dynamic>.from(decoded['data']);
        } else if (response.statusCode == 200 &&
            decoded is Map &&
            decoded['success'] == false) {
          throw Exception(decoded['error'] ?? 'Unknown backend error');
        }
      } catch (e) {
        if (currentIp == ipsToTry.last) {
          throw Exception('Connection timed out. Ensure backend is running.');
        }
      }
    }
    throw Exception('Unknown Chat AI Error');
  }

  // -------------------------
  // Sensor
  // -------------------------
  static Future<Map<String, dynamic>> searchDevice() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/ph/search_device'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error searching device: $e');
    }
  }

  static Future<Map<String, dynamic>> getLivePh() async {
    try {
      final uid = userId ?? "guest";
      final response = await http
          .get(Uri.parse('$baseUrl/ph/live/$uid'), headers: _headers)
          .timeout(const Duration(seconds: 15));

      final decoded = _safeJsonDecode(response.body);
      if (response.statusCode == 200 &&
          decoded is Map &&
          decoded['success'] == true) {
        return Map<String, dynamic>.from(decoded['data']);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      throw Exception('Error fetching live pH: $e');
    }
  }

  // -------------------------
  // Health check
  // -------------------------
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = _safeJsonDecode(response.body);
        return decoded is Map && decoded['success'] == true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
