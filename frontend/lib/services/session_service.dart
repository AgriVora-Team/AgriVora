import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class SessionService {
  // ── Shared Preferences keys ────────────────────────────────────────────────
  static const _kUserId = 'session_user_id';
  static const _kUserName = 'session_user_name';
  static const _kUserEmail = 'session_user_email';
  static const _kUserPhone = 'session_user_phone';
  static const _kPermsGranted = 'session_perms_granted';
  static const _kIsGuest = 'session_is_guest';
  static const _kProfilePic = 'session_profile_pic';

  // ──────────────────────────────────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────────────────────────────────
  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  static void _loadUserIntoMemory(SharedPreferences prefs, String userId) {
    ApiService.userId = userId;
    ApiService.userName = prefs.getString(_kUserName) ?? '';
    ApiService.userEmail = prefs.getString(_kUserEmail) ?? '';
    ApiService.userPhone = prefs.getString(_kUserPhone) ?? '';
  }

  static Future<void> _removeKeys(
    SharedPreferences prefs,
    List<String> keys,
  ) async {
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Save (called right after a successful login)
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveSession({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    final prefs = await _prefs();
    await prefs.setString(_kUserId, userId);
    await prefs.setString(_kUserName, userName);
    await prefs.setString(_kUserEmail, userEmail);
    await prefs.setString(_kUserPhone, userPhone);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Save Guest Session
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveGuestSession() async {
    final prefs = await _prefs();
    await prefs.setBool(_kIsGuest, true);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Mark permissions granted
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> markPermissionsGranted() async {
    final prefs = await _prefs();
    await prefs.setBool(_kPermsGranted, true);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Restore
  // ──────────────────────────────────────────────────────────────────────────
  static Future<bool> restoreSession() async {
    final prefs = await _prefs();

    final isGuest = prefs.getBool(_kIsGuest) ?? false;
    if (isGuest) {
      ApiService.userId = null;
      return true;
    }

    final userId = prefs.getString(_kUserId);
    if (userId == null || userId.isEmpty) return false;

    _loadUserIntoMemory(prefs, userId);
    return true;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Check permissions state
  // ──────────────────────────────────────────────────────────────────────────
  static Future<bool> hasGrantedPermissions() async {
    final prefs = await _prefs();
    return prefs.getBool(_kPermsGranted) ?? false;
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Profile Picture
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> saveProfilePic(String path) async {
    final prefs = await _prefs();
    await prefs.setString(_kProfilePic, path);
  }

  static Future<String?> getProfilePic() async {
    final prefs = await _prefs();
    return prefs.getString(_kProfilePic);
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Clear
  // ──────────────────────────────────────────────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await _prefs();
    await _removeKeys(prefs, [
      _kUserId,
      _kUserName,
      _kUserEmail,
      _kUserPhone,
      _kIsGuest,
      _kProfilePic,
      _kPermsGranted,
    ]);
  }
}