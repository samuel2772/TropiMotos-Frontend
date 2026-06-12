class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value)) {
      return 'Ingresa un email valido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contrasena es requerida';
    }
    if (value.length < 6) {
      return 'Minimo 6 caracteres';
    }
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    final name = fieldName ?? 'Este campo';
    if (value == null || value.trim().isEmpty) {
      return '$name es requerido';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El telefono es requerido';
    }
    final regex = RegExp(r'^\+?[\d\s\-]{7,15}$');
    if (!regex.hasMatch(value)) {
      return 'Ingresa un telefono valido';
    }
    return null;
  }

  static String? minLength(String? value, int min, [String? fieldName]) {
    final name = fieldName ?? 'Este campo';
    if (value == null || value.isEmpty) {
      return '$name es requerido';
    }
    if (value.length < min) {
      return 'Minimo $min caracteres';
    }
    return null;
  }
}
