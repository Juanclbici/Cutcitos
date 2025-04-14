class User {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final DateTime fechaRegistro;
  final String fotoPerfil;
  final String telefono;
  final String estadoCuenta;
  final String codigoUDG;

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.fechaRegistro,
    required this.fotoPerfil,
    required this.telefono,
    required this.estadoCuenta,
    required this.codigoUDG,
  });
}

class UserData {
  // MANTENER: Patrón singleton
  static final UserData _instance = UserData._internal();
  factory UserData() => _instance;
  UserData._internal();

  // MODIFICAR: Método para obtener usuario actual
  Future<User> getCurrentUser() async {
    // REEMPLAZAR: Con consulta real a la BD
    return _mockUser;
  }

  // MODIFICAR: Método para obtener usuario por ID
  Future<User?> getUserById(String id) async {
    // REEMPLAZAR: Con consulta real a la BD
    if (id == _mockUser.id) {
      return _mockUser;
    }
    return null;
  }

  // ELIMINAR: Datos de prueba cuando se implemente la BD real
  final User _mockUser = User(
    id: '1001',
    nombre: 'Juan Pérez',
    email: 'juan.perez@alumnos.udg.mx',
    rol: 'usuario',
    fechaRegistro: DateTime(2023, 9, 15),
    fotoPerfil: 'assets/images/profile.jpg',
    telefono: '33-1234-5678',
    estadoCuenta: 'activo',
    codigoUDG: '123456789',
  );
}