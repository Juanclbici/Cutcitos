class User {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String telefono;
  final String codigoUDG;
  final String estadoCuenta;
  final String fotoPerfil;
  final DateTime fechaRegistro;

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.telefono,
    required this.codigoUDG,
    required this.estadoCuenta,
    required this.fotoPerfil,
    required this.fechaRegistro
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'].toString(),
      nombre: json['nombre'] ?? 'Sin nombre',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'usuario',
      telefono: json['telefono']?.toString() ?? 'No registrado',
      codigoUDG: json['codigo_UDG']?.toString() ?? 'N/A',
      estadoCuenta: json['estado_cuenta'] ?? 'activo',
      fotoPerfil: _parseProfileImage(json['foto_perfil']),
      fechaRegistro: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static String _parseProfileImage(dynamic img) {
    if (img == null) return 'assets/images/default_profile.jpg';
    final path = img.toString();
    return path.startsWith('http')
        ? path
        : 'assets/images/$path';
  }
}
