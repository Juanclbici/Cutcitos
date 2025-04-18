import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../cart/car_screen.dart';
import '../sellers/sellers_list.dart';
import '../sellers/seller_chat.dart';
import '../user/info_profile.dart';
import '../user/messages_screen.dart';

class PendingOrdersScreen extends StatefulWidget {
  const PendingOrdersScreen({super.key});

  @override
  State<PendingOrdersScreen> createState() => _PendingOrdersScreenState();
}

class _PendingOrdersScreenState extends State<PendingOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _allOrders = [];
  bool _isLoading = true;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await OrderService.getOrdersByUser();
      setState(() {
        _allOrders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print("Error cargando pedidos: $e");
      setState(() => _isLoading = false);
    }
  }

  List<Order> _filterOrders(String estado) {
    if (estado == 'pendiente') {
      return _allOrders.where((o) => o.estado == 'pendiente' || o.estado == 'confirmado').toList();
    }
    return _allOrders.where((o) => o.estado == estado).toList();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['pendiente', 'entregado', 'cancelado'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InfoProfile()),
              );
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Entregados'),
            Tab(text: 'Cancelados'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: tabs.map((estado) {
          final pedidos = _filterOrders(estado);
          return pedidos.isEmpty
              ? const Center(child: Text('No hay pedidos'))
              : ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pedido #${pedido.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Vendedor: ${pedido.vendedorNombre ?? 'Desconocido'}'),
                      const SizedBox(height: 6),
                      ...pedido.productos.map((producto) => ListTile(
                        leading: Image.asset(
                          producto.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                        ),
                        title: Text(producto.name),
                        subtitle: Text('Cantidad: ${producto.availableQuantity}'),
                        trailing: Text('\$${producto.price.toStringAsFixed(2)}'),
                      )),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: \$${pedido.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SellersList()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MessagesScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CarScreen()),
            );
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
}
