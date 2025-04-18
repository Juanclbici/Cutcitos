import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/user/info_profile.dart';
import '../screens/orders/vendor_orders_screen.dart';
import '../screens/auth/login_screen.dart'; // Agrega este import

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _esVendedor = false;

  @override
  void initState() {
    super.initState();
    _verificarRol();
  }

  Future<void> _verificarRol() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = prefs.getString('rol') ?? '';
    setState(() {
      _esVendedor = rol.toLowerCase() == 'seller' || rol.toLowerCase() == 'vendedor';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // limpia todo
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 40),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InfoProfile()),
              );
            },
          ),
          if (_esVendedor)
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Ventas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VendorOrdersScreen()),
                );
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}
