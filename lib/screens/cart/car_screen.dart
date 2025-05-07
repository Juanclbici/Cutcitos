import 'package:flutter/material.dart';
import '../../services/cart/cart_service.dart';
import '../../services/seller/seller_service.dart';
import '../../services/order/order_service.dart';
import '../../widgets/custom_navbar.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/product_image.dart';

class CarScreen extends StatefulWidget {
  const CarScreen({super.key});

  @override
  State<CarScreen> createState() => _CarScreenState();
}

class _CarScreenState extends State<CarScreen> {
  Map<int, String> sellerNames = {};
  bool _loadingSellers = true;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _fetchSellers();
  }

  Future<void> _fetchSellers() async {
    try {
      final sellers = await SellerService.getAllSellers();
      setState(() {
        sellerNames = {for (var s in sellers) s.id: s.nombre};
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
    final productos = items
        .map((item) => {
      'producto_id': item.product.id,
      'cantidad': item.quantity,
    })
        .toList();

    final orderId = await OrderService.createOrderLote(
      vendedorId: sellerId,
      productos: productos,
      metodoPago: 'efectivo',
      direccion: 'Edificio A, CUT',
    );

    if (orderId != null) {
      setState(() {
        CartService.removeSellerFromCart(sellerId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pedido enviado al vendedor ${sellerNames[sellerId]}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear el pedido')),
      );
    }
  }

  Future<void> _cancelarPedido(int sellerId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Cancelar pedido?'),
        content: const Text('¿Deseas cancelar el pedido?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Sí')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      CartService.removeSellerFromCart(sellerId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido cancelado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartGrouped = CartService.getCart();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
        backgroundColor: Colors.cyan,
        automaticallyImplyLeading: true,
      ),
      drawer: const CustomDrawer(),
      body: _loadingSellers
          ? const Center(child: CircularProgressIndicator())
          : cartGrouped.isEmpty
          ? const Center(child: Text('Tu carrito está vacío'))
          : ListView(
        children: cartGrouped.entries.map((entry) {
          final sellerId = entry.key;
          final cartItems = entry.value;
          final nombreVendedor = sellerNames[sellerId] ?? 'Vendedor';

          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vendedor: $nombreVendedor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...cartItems.map((item) => ListTile(
                    leading: ProductImage(
                      imagePath: item.product.image,
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(item.product.name),
                    subtitle: Text('\$${item.product.price.toStringAsFixed(2)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
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
                          onPressed: () {
                            setState(() {
                              item.quantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _cancelarPedido(sellerId),
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        label: const Text('Cancelar Pedido',
                            style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () => _enviarPedido(sellerId, cartItems),
                        icon: const Icon(Icons.send, color: Colors.green),
                        label: const Text('Solicitar Pedido',
                            style: TextStyle(color: Colors.green)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 2),
    );
  }
}
