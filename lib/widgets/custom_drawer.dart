import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/user/info_profile.dart';
import '../screens/orders/vendor_orders_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/sellers/seller_list_screen.dart';
import '../screens/sellers/my_products_screen.dart.dart';
import '../screens/admin/category_admin_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<void> _mostrarConfirmacionLogout(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar sesión?'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, salir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await Provider.of<AuthProvider>(context, listen: false).logout();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión cerrada correctamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final esVendedor = auth.user?.rol.toLowerCase() == 'seller';
    final esAdmin = auth.user?.rol.toLowerCase() == 'admin';

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
          if (esVendedor)
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
          if (esVendedor)
            ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Mis Productos'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyProductsScreen()),
                );
              },
            ),
          ListTile(
            leading: const Icon(Icons.people_alt),
            title: const Text('Vendedores'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SellerListScreen()),
              );
            },
          ),
          if (esAdmin)
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Categorías'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CategoryAdminScreen()),
                );
              },
            ),

          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
            onTap: () => _mostrarConfirmacionLogout(context),
          ),
        ],
      ),
    );
  }
}
