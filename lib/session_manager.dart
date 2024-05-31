import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  SharedPreferences? _prefs;

  Future<void> initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setUserToken(String token) async {
    await _prefs?.setString('userToken', token);
  }

  String? getUserToken() {
    return _prefs?.getString('userToken');
  }

  Future<void> logout() async {
    await _prefs?.remove('userToken');
  }
}
