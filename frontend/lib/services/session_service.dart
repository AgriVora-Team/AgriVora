class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;

  SessionService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get userId => _prefs?.getString('userId');

  Future<void> saveUser(String id) async {
    await _prefs?.setString('userId', id);
  }

  Future<void> logout() async {
    await _prefs?.clear();
  }
}