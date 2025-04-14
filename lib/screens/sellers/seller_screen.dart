import 'package:flutter/material.dart';
import 'seller_chat.dart';
import '../../models/SellerData.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Stack para la imagen de portada y el perfil del vendedor
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Imagen de portada
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.seller.coverImage),
                    fit: BoxFit.cover,
                  ),
                  color: Colors.cyan, // Color de respaldo si la imagen falla
                ),
              ),

              //Boton de regreso
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

              // Información del vendedor
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
                        backgroundImage: AssetImage(widget.seller.profileImage),
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
                          widget.seller.name,
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

          // Espacio para compensar la foto de perfil
          const SizedBox(height: 50),

          // Información adicional del vendedor
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _infoItem(Icons.star, widget.seller.rating.toString(), "Valoración"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Título de productos
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Productos disponibles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Lista de productos
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.seller.products.length,
              itemBuilder: (context, index) {
                final product = widget.seller.products[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade200,
                        image: DecorationImage(
                          image: AssetImage(product.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(product.price, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.cyan)),
                        Text(product.status, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart, color: Colors.cyan),
                      onPressed: () {},
                    ),
                  ),
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
                sellerName: widget.seller.name,
                sellerImage: widget.seller.profileImage,
              ),
            ),
          );
        },
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.chat),
      ),
    );
  }

  // Add the missing _infoItem method
  Widget _infoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.cyan),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}