import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../services/order/order_service.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/product_image.dart';
import '../sellers/seller_chat.dart';

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
  DateTime? _fechaSeleccionada;

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

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';
  }

  List<Order> _filterOrders(String categoria) {
    List<Order> filtrados = switch (categoria) {
      'pendiente' => _allOrders.where((o) => o.estado == 'pendiente' || o.estado == 'confirmado').toList(),
      'entregado' => _allOrders.where((o) => o.estado == 'entregado').toList(),
      'cancelado' => _allOrders.where((o) => o.estado == 'cancelado').toList(),
      _ => []
    };

    if (_fechaSeleccionada != null) {
      filtrados = filtrados.where((o) =>
      o.fecha.year == _fechaSeleccionada!.year &&
          o.fecha.month == _fechaSeleccionada!.month &&
          o.fecha.day == _fechaSeleccionada!.day
      ).toList();
    }

    return filtrados;
  }

  Future<void> _confirmarPedido(int orderId) async {
    final success = await OrderService.confirmOrderByVendor(orderId);
    _showResult(success, 'Pedido confirmado');
  }

  Future<void> _entregarPedido(int orderId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Marcar como entregado?'),
        content: const Text('¿Estás seguro de que este pedido ha sido entregado?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí, entregar')),
        ],
      ),
    );

    if (confirmar == true) {
      final success = await OrderService.markOrderAsDelivered(orderId);
      _showResult(success, 'Pedido marcado como entregado');
    }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Filtrar por fecha',
            onPressed: _seleccionarFecha,
          ),
          if (_fechaSeleccionada != null)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Limpiar filtro',
              onPressed: () => setState(() => _fechaSeleccionada = null),
            ),
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
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: categorias.map((categoria) {
          final pedidos = _filterOrders(categoria);
          final esPendiente = categoria == 'pendiente';

          return pedidos.isEmpty
              ? const Center(child: Text('No hay pedidos en esta categoría'))
              : ListView.builder(
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido = pedidos[index];

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
                          Text('Pedido #${pedido.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          StatusChip(estado: pedido.estado),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Fecha: ${_formatearFecha(pedido.fecha)}',
                          style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      Text('Comprador: ${pedido.compradorNombre ?? 'Desconocido'}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 6),
                      ...pedido.productos.map((producto) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          leading: ProductImage(
                            imagePath: producto.image,
                            width: 50,
                            height: 50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          title: Text(producto.name),
                          subtitle: Text('Cantidad: ${producto.cantidadSolicitada ?? 'N/A'}'),
                          trailing: Text('\$${producto.price.toStringAsFixed(2)}'),
                        ),
                      )),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Total: \$${pedido.total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (pedido.estado == 'pendiente') ...[
                            ElevatedButton.icon(
                              onPressed: () => _confirmarPedido(pedido.id),
                              icon: const Icon(Icons.check),
                              label: const Text('Confirmar'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _cancelarPedido(pedido.id),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton.small(
                              heroTag: 'chat_buyer_${pedido.id}',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerChatScreen(
                                      sellerName: pedido.compradorNombre ?? 'Comprador',
                                      usuarioId: pedido.userId ?? 0,
                                      sellerImage: 'default_profile.jpg',
                                    ),
                                  ),
                                );
                              },
                              backgroundColor: Colors.cyan,
                              child: const Icon(Icons.message, color: Colors.white),
                            )
                          ],
                          if (pedido.estado == 'confirmado') ...[
                            ElevatedButton.icon(
                              onPressed: () => _entregarPedido(pedido.id),
                              icon: const Icon(Icons.local_shipping),
                              label: const Text('Entregar'),
                            ),
                            const SizedBox(width: 8),
                            TextButton.icon(
                              onPressed: () => _cancelarPedido(pedido.id),
                              icon: const Icon(Icons.cancel),
                              label: const Text('Cancelar'),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ]
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
