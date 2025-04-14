import 'package:flutter/material.dart';
import '../../models/UserData.dart';
import 'package:intl/intl.dart';
import 'messages_screen.dart';

class InfoProfile extends StatefulWidget {
  const InfoProfile({super.key});

  @override
  State<InfoProfile> createState() => _InfoProfileState();
}

class _InfoProfileState extends State<InfoProfile> {
  final UserData _userData = UserData();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _userData.getCurrentUser();
      setState(() {
        _user = userData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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
        automaticallyImplyLeading: false, // Elimina la felcha de regresar
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
          ? const Center(child: Text('No se pudo cargar la información'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- PROFILE HEADER SECTION ---
            Center(
              child: Column(
                children: [
                  // --- PROFILE PHOTO ---
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(_user!.fotoPerfil),
                  ),
                  const SizedBox(height: 16),

                  // --- USER NAME ---
                  Text(
                    _user!.nombre,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // --- USER ROLE ---
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4
                    ),
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

                  // --- ACCOUNT STATUS ---
                  Text(
                    'Estado: ${_formatStatus(_user!.estadoCuenta)}',
                    style: TextStyle(
                      color: _user!.estadoCuenta == 'activo'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- USER INFORMATION SECTION ---
            const Divider(),

            // --- PERSONAL INFO TITLE ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.cyan),
                  const SizedBox(width: 8),
                  Text(
                    'Información Personal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),

            // --- INFO CARDS ---
            _buildInfoCard('Email', _user!.email, Icons.email),
            _buildInfoCard('Teléfono', _user!.telefono, Icons.phone),
            _buildInfoCard(
                'Código UDG',
                _user!.codigoUDG,
                Icons.school
            ),
            _buildInfoCard(
                'Fecha de registro',
                DateFormat('dd/MM/yyyy').format(_user!.fechaRegistro),
                Icons.calendar_today
            ),

            const SizedBox(height: 24),

            // --- EDIT PROFILE BUTTON ---
            ElevatedButton.icon(
              onPressed: () {
                // Navegación a pantalla de edición de perfil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Función de editar perfil en desarrollo'),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Editar Perfil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3, // Profile tab is selected by default
        onTap: (index) {
          if (index == 0) {
            // Navigate back to sellers_list when Home tab is tapped
            Navigator.pop(context);
          } else if (index == 1) {
            // Navigate to MessagesScreen when Messages tab is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          }
          // You can add navigation for other tabs later
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }


  // Helper method to build info cards
  Widget _buildInfoCard(String title, String value, IconData icon) {
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

  // Format role for display
  String _formatRole(String role) {
    switch (role) {
      case 'usuario':
        return 'Estudiante';
      case 'vendedor':
        return 'Vendedor';
      case 'admin':
        return 'Administrador';
      default:
        return role;
    }
  }

  // Format account status for display
  String _formatStatus(String status) {
    switch (status) {
      case 'activo':
        return 'Activo';
      case 'bloqueado':
        return 'Bloqueado';
      default:
        return status;
    }
  }
}

