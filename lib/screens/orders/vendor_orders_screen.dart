import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen>
    with SingleTickerProviderStateMixin {
  List<Order> _allOrders = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadVendorOrders();
  }

  Future<void> _loadVendorOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await OrderService.getOrdersBySeller();
      setState(() {
        _allOrders = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener pedidos del vendedor: $e');
      setState(() => _isLoading = false);
    }
  }

  List<Order> _filterOrders(String categoria) {
    switch (categoria) {
      case 'pendiente':
        return _allOrders
            .where((o) => o.estado == 'pendiente' || o.estado == 'confirmado')
            .toList();
      case 'entregado':
        return _allOrders.where((o) => o.estado == 'entregado').toList();
      case 'cancelado':
        return _allOrders.where((o) => o.estado == 'cancelado').toList();
      default:
        return [];
    }
  }

  Future<void> _confirmarPedido(int orderId) async {
    final success = await OrderService.confirmOrderByVendor(orderId);
    _showResult(success, 'Pedido confirmado');
  }

  Future<void> _entregarPedido(int orderId) async {
    final success = await OrderService.markOrderAsDelivered(orderId);
    _showResult(success, 'Pedido entregado');
  }

  Future<void> _cancelarPedido(int orderId) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cancelar pedido?'),
        content: const Text('¿Estás seguro de cancelar este pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirmado == true) {
      final success = await OrderService.cancelOrderByVendor(orderId);
      _showResult(success, 'Pedido cancelado');
    }
  }

  void _showResult(bool success, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? mensaje : 'Error al procesar la solicitud')),
    );
    if (success) _loadVendorOrders();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = ['pendiente', 'entregado', 'cancelado'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos'),
        backgroundColor: Colors.cyan,
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
        children: categorias.map((categoria) {
          final pedidos = _filterOrders(categoria);
          return pedidos.isEmpty
              ? const Center(child: Text('No hay pedidos en esta categoría'))
              : ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final estado = pedido.estado;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Estado: '),
                          StatusChip(estado: pedido.estado),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...pedido.productos.map((producto) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: Image.asset(
                            producto.image,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image_not_supported),
                          ),
                          title: Text(producto.name),
                          subtitle: Text(
                              'Cantidad: ${producto.availableQuantity}'),
                          trailing: Text(
                              '\$${producto.price.toStringAsFixed(2)}'),
                        ),
                      )),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Total: \$${pedido.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (estado == 'pendiente')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _confirmarPedido(pedido.id),
                              icon: const Icon(Icons.check),
                              label: const Text('Confirmar'),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: () =>
                                  _cancelarPedido(pedido.id),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                            ),
                          ],
                        )
                      else if (estado == 'confirmado')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _entregarPedido(pedido.id),
                              icon:
                              const Icon(Icons.local_shipping),
                              label: const Text('Entregar'),
                            ),
                            const SizedBox(width: 10),
                            TextButton.icon(
                              onPressed: () =>
                                  _cancelarPedido(pedido.id),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: -1),
    );
  }
}
