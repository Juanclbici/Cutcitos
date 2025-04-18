import 'package:flutter/material.dart';

import '../screens/sellers/sellers_list.dart';
import '../screens/user/messages_screen.dart';
import '../screens/cart/car_screen.dart';
import '../screens/orders/pending_orders_screen.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavigationBar({super.key, required this.selectedIndex});

  void _navigate(BuildContext context, int index) {
    if (index == selectedIndex) return;

    Widget destination;
    switch (index) {
      case 0:
        destination = const SellersList();
        break;
      case 1:
        destination = const MessagesScreen();
        break;
      case 2:
        destination = const CarScreen();
        break;
      case 3:
        destination = const PendingOrdersScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final indexToUse = selectedIndex >= 0 ? selectedIndex : 0;

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.white,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: BottomNavigationBar(
        currentIndex: indexToUse,
        onTap: (index) => _navigate(context, index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: selectedIndex == -1 ? Colors.grey : Colors.cyan,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 14,
        unselectedFontSize: 14,
        selectedIconTheme: selectedIndex == -1
            ? const IconThemeData(color: Colors.grey)
            : const IconThemeData(color: Colors.cyan),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Carrito'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Pedidos'),
        ],
      ),
    );
  }
}
