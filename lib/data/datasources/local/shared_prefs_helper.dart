import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPrefsHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  final SharedPreferences _prefs;

  SharedPrefsHelper(this._prefs);

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await _prefs.remove(_tokenKey);
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userKey, json.encode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userString = _prefs.getString(_userKey);
    if (userString != null) {
      return json.decode(userString);
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _prefs.remove(_userKey);
  }
}
