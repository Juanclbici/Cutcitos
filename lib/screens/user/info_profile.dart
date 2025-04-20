import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/User.dart';
import '../../services/user/user_service.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/user_image.dart';

class InfoProfile extends StatefulWidget {
  const InfoProfile({super.key});

  @override
  State<InfoProfile> createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  User? _user;
  bool _isLoading = true;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await UserService.getCurrentUser();
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: true,
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('No se pudo cargar la información'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            UserImage(
              imagePath: _user!.fotoPerfil,
              width: 120,
              height: 120,
              borderRadius: BorderRadius.circular(60), // Para que se vea como un círculo
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 16),

            // Nombre
            Text(
              _user!.nombre,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Rol
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.cyan.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatRole(_user!.rol),
                style: TextStyle(
                  color: Colors.cyan.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Estado de cuenta
            Text(
              'Estado: ${_formatStatus(_user!.estadoCuenta)}',
              style: TextStyle(
                color: _user!.estadoCuenta == 'active'
                    ? Colors.green.shade700
                    : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),
            const Divider(),

            // Sección de información
            _sectionTitle('Información Personal', Icons.person),
            _infoCard('Email', _user!.email, Icons.email),
            _infoCard('Teléfono', _user!.telefono, Icons.phone),
            _infoCard('Código UDG', _user!.codigoUDG, Icons.school),
            _infoCard(
              'Fecha de registro',
              DateFormat('dd/MM/yyyy')
                  .format(_user!.fechaRegistro),
              Icons.calendar_today,
            ),

            const SizedBox(height: 24),

            // Botón editar (placeholder)
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Función de editar perfil en desarrollo'),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyan),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.cyan.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'buyer':
        return 'Comprador';
      case 'seller':
        return 'Vendedor';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'active':
        return 'Activo';
      case 'inactive':
        return 'Bloqueado';
      default:
        return status;
    }
  }
}
