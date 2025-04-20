import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/order.dart';
import '../../services/order/order_service.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/product_image.dart';

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
  DateTime? _fechaSeleccionada;

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

  List<Order> _filterOrders(String estado) {
    List<Order> pedidos = estado == 'pendiente'
        ? _allOrders.where((o) => o.estado == 'pendiente' || o.estado == 'confirmado').toList()
        : _allOrders.where((o) => o.estado == estado).toList();

    if (_fechaSeleccionada != null) {
      pedidos = pedidos.where((o) =>
      o.fecha.year == _fechaSeleccionada!.year &&
          o.fecha.month == _fechaSeleccionada!.month &&
          o.fecha.day == _fechaSeleccionada!.day).toList();
    }

    return pedidos;
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
        title: const Text('Mis compras'),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: true,
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
                      const SizedBox(height: 4),
                      Text(
                        'Fecha: ${_formatearFecha(pedido.fecha)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(
                        'Vendedor: ${pedido.vendedorNombre ?? 'Desconocido'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      ...pedido.productos.map((producto) => ListTile(
                        leading: ProductImage(
                          imagePath: producto.image,
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(8),
                        ),

                        title: Text(producto.name),
                        subtitle: Text('Cantidad: ${producto.cantidadSolicitada}'),
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
