import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SessionService {
  static const _kUserId = 'session_user_id';
  static const _kUserName = 'session_user_name';
  static const _kUserEmail = 'session_user_email';
  static const _kUserPhone = 'session_user_phone';
  static const _kPermsGranted = 'session_perms_granted';
  static const _kIsGuest = 'session_is_guest';
  static const _kProfilePic = 'session_profile_pic';

  static Future<void> saveSession({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserId, userId);
    await prefs.setString(_kUserName, userName);
    await prefs.setString(_kUserEmail, userEmail);
    await prefs.setString(_kUserPhone, userPhone);
  }

  static Future<void> saveGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsGuest, true);
  }

  static Future<void> markPermissionsGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPermsGranted, true);
  }

  static Future<bool> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if Guest
    final isGuest = prefs.getBool(_kIsGuest) ?? false;
    if (isGuest) {
      ApiService.userId = null;
      return true;
    }

    final userId = prefs.getString(_kUserId);
    if (userId == null || userId.isEmpty) return false;

    // Reload into ApiService memory
    ApiService.userId = userId;
    ApiService.userName = prefs.getString(_kUserName) ?? '';
    ApiService.userEmail = prefs.getString(_kUserEmail) ?? '';
    ApiService.userPhone = prefs.getString(_kUserPhone) ?? '';
    return true;
  }

  static Future<bool> hasGrantedPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPermsGranted) ?? false;
  }

  static Future<void> saveProfilePic(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kProfilePic, path);
  }

  static Future<String?> getProfilePic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kProfilePic);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserPhone);
    await prefs.remove(_kIsGuest);
    await prefs.remove(_kProfilePic);
    // User explicitly requested to reset permissions state upon logout
    await prefs.remove(_kPermsGranted);
  }
}
