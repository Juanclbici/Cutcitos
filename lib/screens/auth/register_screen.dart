import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../services/user/auth_service.dart';
import '../home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _selectedRole;
  String? _completePhoneNumber;

  // Mapeo de roles (visualización en español -> valor para backend en inglés)
  final Map<String, String> _roleMapping = {
    "Vendedor": "seller",
    "Consumidor": "buyer"
  };

  // Lista de roles para mostrar en el dropdown (solo las keys en español)
  List<String> get _roles => _roleMapping.keys.toList();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      setState(() => _isLoading = true);

      try {
        if (!mounted) return;

        final result = await _authService.register(
          context: context,
          codigo: _codigoController.text,
          password: _passwordController.text,
          nombre: _nombreController.text,
          rol: _roleMapping[_selectedRole] ?? "",
          telefono: _completePhoneNumber ?? "",
          email: _emailController.text,
        );

        if (!mounted) return;

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Registro exitoso')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          _showErrorDialog(result['message']);
        }

      } catch (e) {
        if (!mounted) return;
        _showErrorDialog('Error: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          'Registro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildInputField("Nombre", "Ingrese su nombre completo", _nombreController),
              _buildInputField("Código", "Ingrese su código", _codigoController),

              // Dropdown para el rol
              const Text('Rol', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text("Seleccione un rol"),
                items: _roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) => value == null ? 'Seleccione un rol' : null,
                decoration: _inputDecoration(),
              ),
              const SizedBox(height: 16),

              // Campo de teléfono con formato MX y 10 dígitos
              const Text('Teléfono', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
              const SizedBox(height: 8),
              IntlPhoneField(
                decoration: _inputDecoration(hintText: 'Ingrese su teléfono'),
                initialCountryCode: 'MX',
                onChanged: (phone) {
                  // Elimina el +52 y guarda solo los 10 dígitos
                  final fullNumber = phone.completeNumber;
                  _completePhoneNumber = fullNumber.replaceFirst(RegExp(r'^\+\d{2}'), '');
                  print("Número guardado: $_completePhoneNumber"); // Para debug
                },
                validator: (phone) {
                  if (phone?.number == null || phone!.number.isEmpty) {
                    return 'Ingrese su teléfono';
                  }
                  if (phone.number.length != 10) {
                    return 'Debe tener 10 dígitos (sin lada)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildInputField("Correo Electrónico", "Ingrese su correo", _emailController, isEmail: true),
              _buildInputField("Contraseña", "Ingrese su contraseña", _passwordController, isPassword: true),

              const SizedBox(height: 30),
              _buildRegisterButton(),

              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '¿Ya tienes cuenta? Inicia sesión aquí',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false, bool isEmail = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
          decoration: _inputDecoration(hintText: hint),
          validator: (value) {
            if (value!.isEmpty) return 'Ingrese su $label';
            if (isPassword && value.length < 8) return 'La contraseña debe tener al menos 8 caracteres';
            if (isEmail && !value.contains('@')) return 'Ingrese un correo válido';
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _register,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Registrar', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    );
  }
}