import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/constants.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final StorageService _storage = StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.loginEndpoint}'),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final body = _decodeBody(response.body);

      if (response.statusCode == 200 && body['success'] == true) {
        final data = body['data'];
        if (data is! Map<String, dynamic>) {
          return {
            'success': false,
            'error': 'La respuesta del backend no tiene el formato esperado.',
          };
        }

        final token = data['token']?.toString();
        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'error': 'El backend no devolvió un JWT válido.',
          };
        }

        final user = User.fromJson(data);
        await _storage.saveToken(token);
        await _storage.saveUserEmail(user.email);
        await _storage.saveUserRole((data['rol'] ?? user.role.name).toString().toUpperCase());
        if (user.nombre != null && user.nombre!.isNotEmpty) {
          await _storage.saveUserName(user.nombre!);
        }

        return {
          'success': true,
          'token': token,
          'user': user,
          'message': body['message'],
        };
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        return {
          'success': false,
          'error': body['message']?.toString() ?? 'Credenciales incorrectas.',
        };
      }

      return {
        'success': false,
        'error': body['message']?.toString() ?? 'No fue posible iniciar sesión.',
      };
    } catch (_) {
      return {
        'success': false,
        'error': 'No se pudo conectar con el backend en ${AppConstants.baseUrl}.',
      };
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return _storage.hasToken();
  }

  Future<User?> getCurrentUser() async {
    final token = await _storage.getToken();
    final email = await _storage.getUserEmail();
    final roleStr = await _storage.getUserRole();
    final nombre = await _storage.getUserName();

    if (token == null || token.isEmpty || email == null || email.isEmpty) {
      return null;
    }

    return User(
      id: '',
      email: email,
      nombre: nombre,
      role: _mapRole(roleStr),
    );
  }

  Map<String, dynamic> _decodeBody(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      return <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  UserRole _mapRole(String? roleStr) {
    switch ((roleStr ?? '').toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'CHOFER':
        return UserRole.chofer;
      case 'CLIENTE':
      default:
        return UserRole.cliente;
    }
  }
}
