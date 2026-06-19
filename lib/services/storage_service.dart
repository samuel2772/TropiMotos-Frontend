import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.jwtTokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.jwtTokenKey);
  }

  Future<void> saveUserRole(String role) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userRoleKey, role);
  }

  Future<String?> getUserRole() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userRoleKey);
  }

  Future<void> saveUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userEmailKey);
  }

  Future<void> saveUserName(String nombre) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userNameKey, nombre);
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userNameKey);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.jwtTokenKey);
    await prefs.remove(AppConstants.userRoleKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove(AppConstants.userNameKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
