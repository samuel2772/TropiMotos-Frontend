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

  Future<void> saveUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userIdKey, userId);
  }

  Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userIdKey);
  }

  Future<void> saveUserVehicleId(String vehicleId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userVehicleIdKey, vehicleId);
  }

  Future<void> saveUserDriverId(String driverId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.userDriverIdKey, driverId);
  }

  Future<String?> getUserDriverId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userDriverIdKey);
  }

  Future<String?> getUserVehicleId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userVehicleIdKey);
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

  Future<void> saveActiveTripId(String tripId) async {
    final prefs = await _prefs;
    await prefs.setString(AppConstants.activeTripIdKey, tripId);
  }

  Future<String?> getActiveTripId() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.activeTripIdKey);
  }

  Future<void> clearActiveTripId() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.activeTripIdKey);
  }

  Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString(AppConstants.userNameKey);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(AppConstants.jwtTokenKey);
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userDriverIdKey);
    await prefs.remove(AppConstants.userVehicleIdKey);
    await prefs.remove(AppConstants.userRoleKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove(AppConstants.userNameKey);
    await prefs.remove(AppConstants.activeTripIdKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
