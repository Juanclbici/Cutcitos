import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/status_chip.dart';

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
  bool _esVendedor = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _verificarRol();
    _loadOrders();
  }

  Future<void> _verificarRol() async {
    final prefs = await SharedPreferences.getInstance();
    final rol = prefs.getString('rol') ?? '';
    setState(() {
      _esVendedor = rol.toLowerCase() == 'vendedor';
    });
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

  Future<void> _cancelarPedido(int orderId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text('¿Estás seguro que deseas cancelar este pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirmado == true) {
      final exito = await OrderService.cancelOrder(orderId);
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado con éxito')),
        );
        _loadOrders();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cancelar el pedido')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = ['pendiente', 'entregado', 'cancelado'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pedidos'),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pendientes'),
            Tab(text: 'Entregados'),
            Tab(text: 'Cancelados'),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
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
              final esCancelable = pedido.estado == 'pendiente' || pedido.estado == 'confirmado';

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
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Estado: '),
                          StatusChip(estado: pedido.estado),
                        ],
                      ),
                      Text(
                        'Vendedor: ${pedido.vendedorNombre ?? 'Desconocido'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      ...pedido.productos.map((producto) => ListTile(
                        leading: Image.asset(
                          producto.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported),
                        ),
                        title: Text(producto.name),
                        subtitle: Text('Cantidad: ${producto.availableQuantity}'),
                        trailing:
                        Text('\$${producto.price.toStringAsFixed(2)}'),
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
                      ),
                      if (esCancelable)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _cancelarPedido(pedido.id),
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            label: const Text('Cancelar pedido',
                                style: TextStyle(color: Colors.red)),
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
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 3),
    );
  }
}
