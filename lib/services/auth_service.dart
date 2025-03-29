class AuthService {
  // Simula la autenticación (en la vida real usarías una API)
  Future<bool> authenticate(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simula tiempo de red
    return username == 'user' && password == 'password';
  }

  Future<bool> register({
    required String codigo,
    required String password,
    required String nombre,
    required String rol,
    required String telefono,
    required String email,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (codigo.isEmpty || password.isEmpty || nombre.isEmpty ||
        rol.isEmpty || telefono.isEmpty || email.isEmpty) {
      return false;
    }

    return true;
  }

  // Versión alternativa si prefieres mantener compatibilidad
  Future<bool> registerLegacy(String username, String password) async {
    return register(
      codigo: username,
      password: password,
      nombre: '',
      rol: '',
      telefono: '',
      email: '',
    );
  }

  // Método para recuperación de contraseña (versión simulada)
  Future<bool> resetPassword(String email) async {
    // Simula tiempo de red
    await Future.delayed(const Duration(seconds: 1));

    // Validación básica del formato de email
    if (!email.contains('@') || !email.contains('.')) {
      return false;
    }

    // Simulación: siempre devuelve true si el email tiene formato válido
    return true;

    // En una implementación real aquí harías:
    // 1. Verificación en tu base de datos
    // 2. Envío de email con enlace de recuperación
    // 3. Registro del intento en tu sistema
  }
}