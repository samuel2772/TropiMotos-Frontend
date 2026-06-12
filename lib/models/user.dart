enum UserRole { admin, chofer, cliente }

class User {
  final String id;
  final String email;
  final String? nombre;
  final String? telefono;
  final UserRole role;

  const User({
    required this.id,
    required this.email,
    this.nombre,
    this.telefono,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    String roleStr = (json['role'] ?? json['rol'] ?? 'CLIENTE').toString().toUpperCase();
    UserRole role;
    switch (roleStr) {
      case 'ADMIN':
        role = UserRole.admin;
        break;
      case 'CHOFER':
        role = UserRole.chofer;
        break;
      case 'CLIENTE':
      default:
        role = UserRole.cliente;
    }

    return User(
      id: (json['id'] ?? json['idUsuario'] ?? '').toString(),
      email: json['email'] ?? '',
      nombre: json['nombre'],
      telefono: json['telefono'],
      role: role,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'telefono': telefono,
      'role': role.name.toUpperCase(),
    };
  }

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrador';
      case UserRole.chofer:
        return 'Chofer';
      case UserRole.cliente:
        return 'Cliente';
    }
  }

  String get initials {
    if (nombre == null || nombre!.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : '?';
    }
    final parts = nombre!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  User copyWith({
    String? id,
    String? email,
    String? nombre,
    String? telefono,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      telefono: telefono ?? this.telefono,
      role: role ?? this.role,
    );
  }
}
