import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order_service.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendorOrders();
  }

  Future<void> _loadVendorOrders() async {
    setState(() => _isLoading = true);
    try {
      final data = await OrderService.getOrdersBySeller();
      setState(() {
        _orders = data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al obtener pedidos del vendedor: $e');
      setState(() => _isLoading = false);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pedidos (Vendedor)'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
          ? const Center(child: Text('No hay pedidos aún'))
          : ListView.builder(
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final pedido = _orders[index];
          final estado = pedido.estado;

          return Card(
            margin: const EdgeInsets.all(10),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pedido #${pedido.id}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Estado: $estado'),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'Total: \$${pedido.total.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (estado == 'pendiente')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _confirmarPedido(pedido.id),
                          icon: const Icon(Icons.check),
                          label: const Text('Confirmar'),
                        ),
                        const SizedBox(width: 10),
                        TextButton.icon(
                          onPressed: () => _cancelarPedido(pedido.id),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    )
                  else if (estado == 'confirmado')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _entregarPedido(pedido.id),
                          icon: const Icon(Icons.local_shipping),
                          label: const Text('Entregar'),
                        ),
                        const SizedBox(width: 10),
                        TextButton.icon(
                          onPressed: () => _cancelarPedido(pedido.id),
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancelar'),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                        ),
                      ],
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
