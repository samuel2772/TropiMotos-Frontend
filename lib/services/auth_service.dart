import 'dart:convert';
import '../config/constants.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        AppConstants.loginEndpoint,
        {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);

        if (body is! Map<String, dynamic> || body['success'] != true) {
          final msg = body is Map && body['message'] != null
              ? body['message']
              : 'Error al iniciar sesion';
          return {'success': false, 'error': msg};
        }

        final data = body['data'];
        if (data is! Map<String, dynamic>) {
          return {'success': false, 'error': 'Respuesta del servidor invalida'};
        }

        final token = data['token'];
        if (token == null || token.toString().isEmpty) {
          return {'success': false, 'error': 'Token no recibido del servidor'};
        }

        await _storage.saveToken(token);

        final user = User.fromJson(data);
        await _storage.saveUserRole(user.role.name.toUpperCase());
        await _storage.saveUserEmail(user.email);
        if (user.nombre != null) {
          await _storage.saveUserName(user.nombre!);
        }

        return {
          'success': true,
          'token': token,
          'user': user,
        };
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'error': 'Email o contrasena incorrectos',
        };
      } else {
        String errorMsg = 'Error del servidor';
        try {
          final body = jsonDecode(response.body);
          if (body is Map<String, dynamic> && body['message'] != null) {
            errorMsg = body['message'];
          }
        } catch (_) {}
        return {'success': false, 'error': errorMsg};
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error de conexion. Verifica tu internet e intenta de nuevo.',
      };
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  Future<User?> getCurrentUser() async {
    final token = await _storage.getToken();
    final email = await _storage.getUserEmail();
    final roleStr = await _storage.getUserRole();
    final nombre = await _storage.getUserName();

    if (token == null || email == null) return null;

    UserRole role;
    switch (roleStr) {
      case 'ADMIN':
        role = UserRole.admin;
        break;
      case 'CHOFER':
        role = UserRole.chofer;
        break;
      case 'CLIENTE':
        role = UserRole.cliente;
        break;
      default:
        role = UserRole.cliente;
    }

    return User(
      id: '',
      email: email,
      nombre: nombre,
      role: role,
    );
  }
}
