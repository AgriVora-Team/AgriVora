class UserSession {
  final String userId;
  final String name;
  final String email;
  final String phone;

  UserSession({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
  });
}

class SessionService {
  static Future<void> save(UserSession user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', '${user.userId}|${user.name}|${user.email}|${user.phone}');
  }

  static Future<UserSession?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('user');
    if (data == null) return null;

    final parts = data.split('|');
    return UserSession(
      userId: parts[0],
      name: parts[1],
      email: parts[2],
      phone: parts[3],
    );
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}