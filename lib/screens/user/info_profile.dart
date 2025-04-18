import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/User.dart';
import '../../services/user_service.dart';
import 'messages_screen.dart';
import '../cart/car_screen.dart';
import '../sellers/sellers_list.dart';
import '../orders/pending_orders_screen.dart';

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
        automaticallyImplyLeading: false,
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
            // Foto de perfil
            CircleAvatar(
              radius: 60,
              backgroundImage: _user!.fotoPerfil.startsWith('http')
                  ? NetworkImage(_user!.fotoPerfil)
                  : AssetImage(_user!.fotoPerfil) as ImageProvider,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) { // Home tab
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SellersList())
            );
          } if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          }else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CarScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PendingOrdersScreen(),
              ),
            );
          }else {
            setState(() {
              _selectedIndex = index;
            });
          }
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
            icon: Icon(Icons.assignment),
            label: 'Pedidos',
          ),
        ],
      ),
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
