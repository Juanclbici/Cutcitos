import 'package:flutter/material.dart';
import '../../models/seller.dart';
import '../../models/product.dart';
import '../../services/product/product_service.dart';
import '../../widgets/user_image.dart';
import '../../widgets/product_image.dart';
import '../../widgets/user_cover.dart';
import 'seller_chat.dart';
import '../../services/user/user_service.dart';
import '../../services/cart/cart_service.dart';

class SellerScreen extends StatefulWidget {
  final Seller seller;

  const SellerScreen({
    super.key,
    required this.seller,
  });

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProductsForSeller();
  }

  Future<List<Product>> _loadProductsForSeller() async {
    final allProducts = await ProductService.getAllProducts();
    return allProducts
        .where((product) => product.sellerId == widget.seller.id)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final seller = widget.seller;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const UserCover(),

              Positioned(
                top: 40,
                left: 16,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: UserImage(
                          imagePath: seller.fotoPerfil,
                          width: 85,
                          height: 85,
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          seller.nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoItem(Icons.mail, seller.email, "Correo"),
                _infoItem(Icons.phone, seller.telefono, "Teléfono"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Productos disponibles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final products = snapshot.data ?? [];

                if (products.isEmpty) {
                  return const Center(child: Text('No hay productos de este vendedor.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              ProductImage(
                                imagePath: product.image,
                                width: 70,
                                height: 70,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    Text('\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.cyan)),
                                    Text(product.status ?? 'Disponible',
                                        style: TextStyle(color: _getStatusColor(product.status))),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.cyan),
                                onPressed: () async {
                                  final user = await UserService.getCurrentUser();

                                  if (user.id == product.sellerId.toString()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('No puedes comprar tus propios productos')),
                                    );
                                    return;
                                  }

                                  CartService.addToCart(product);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${product.name} agregado al carrito')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerChatScreen(
                sellerName: widget.seller.nombre,
                sellerImage: widget.seller.fotoPerfil,
                usuarioId: widget.seller.id,
              ),
            ),
          );
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.chat, color: Colors.white),
      ),

    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Disponible':
        return Colors.green;
      case 'Agotado':
        return Colors.red;
      case 'Próximamente':
        return Colors.orange;
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyan),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}
