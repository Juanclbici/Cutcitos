import 'package:flutter/material.dart';
import '../../services/cart_service.dart';
import '../../services/seller_service.dart';
import '../../services/order_service.dart';
import '../../models/product.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  Map<int, String> sellerNames = {};
  Map<int, int> orderIds = {}; // sellerId -> orderId
  bool _loadingSellers = true;

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    try {
      final sellers = await SellerService.getAllSellers();
      setState(() {
        sellerNames = {
          for (var seller in sellers) seller.id: seller.nombre,
        };
        _loadingSellers = false;
      });
    } catch (e) {
      setState(() => _loadingSellers = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener vendedores: $e')),
      );
    }
  }

  Future<void> _enviarPedido(int sellerId, List<CartItem> items) async {
    final productos = items.map((item) => {
      'producto_id': item.product.id,
      'cantidad': item.quantity,
    }).toList();

    final orderId = await OrderService.createOrderLote(
      vendedorId: sellerId,
      productos: productos,
      metodoPago: 'efectivo',
      direccion: 'Edificio A, CUT',
    );

    if (orderId != null) {
      setState(() {
        orderIds[sellerId] = orderId;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado correctamente al vendedor: ${sellerNames[sellerId] ?? "vendedor"}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Error visual: la orden pudo haberse creado, pero hubo una falla en la respuesta.')),
      );
    }
  }



  Future<void> _cancelarPedido(int sellerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cancelar pedido?'),
        content: const Text('¿Estás seguro de cancelar el pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirm != true) return;

    final orderId = orderIds[sellerId];
    if (orderId != null) {
      final success = await OrderService.cancelOrder(orderId);
      if (success) {
        setState(() {
          CartService.removeSellerFromCart(sellerId);
          orderIds.remove(sellerId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido cancelado')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo cancelar el pedido')),
        );
      }
    } else {
      // Solo limpiar carrito si aún no se ha hecho el pedido
      setState(() {
        CartService.removeSellerFromCart(sellerId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartGrouped = CartService.getCart();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.cyan,
      ),
      body: _loadingSellers
          ? const Center(child: CircularProgressIndicator())
          : cartGrouped.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : ListView(
        children: cartGrouped.entries.map((entry) {
          final sellerId = entry.key;
          final cartItems = entry.value;
          final nombreVendedor =
              sellerNames[sellerId] ?? 'Vendedor';
          final pedidoEnviado = orderIds.containsKey(sellerId);

          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vendedor: $nombreVendedor',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 8),
                  ...cartItems.map((item) => ListTile(
                    leading: Image.asset(
                      item.product.image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item.product.name),
                    subtitle: Text(
                        '\$${item.product.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: pedidoEnviado
                              ? null
                              : () {
                            setState(() {
                              if (item.quantity > 1) {
                                item.quantity--;
                              }
                            });
                          },
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: pedidoEnviado
                              ? null
                              : () {
                            setState(() {
                              item.quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  if (pedidoEnviado)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Estado: Pendiente',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.orange),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _cancelarPedido(sellerId),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar Pedido'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!pedidoEnviado)
                        ElevatedButton.icon(
                          onPressed: () => _enviarPedido(
                              sellerId, cartItems),
                          icon: const Icon(Icons.send),
                          label: const Text('Solicitar Pedido'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
