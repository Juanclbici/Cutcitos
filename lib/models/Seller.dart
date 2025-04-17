class Seller {
  final int id;
  final String nombre;
  final String email;
  final String fotoPerfil;
  final String telefono;
  final String codigoUDG;
  final String estadoCuenta;

  Seller({
    required this.id,
    required this.nombre,
    required this.email,
    required this.fotoPerfil,
    required this.telefono,
    required this.codigoUDG,
    required this.estadoCuenta,
  });

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['user_id'],
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      fotoPerfil: json['foto_perfil'] ?? 'default_profile.jpg',
      telefono: json['telefono'] ?? '',
      codigoUDG: json['codigo_UDG'] ?? '',
      estadoCuenta: json['estado_cuenta'] ?? '',
    );
  }
}
