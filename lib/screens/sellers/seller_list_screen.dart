import 'package:flutter/material.dart';
import '../../models/seller.dart';
import '../../services/seller/seller_service.dart';
import '../../widgets/user_image.dart';
import 'seller_screen.dart';

class SellerListScreen extends StatefulWidget {
  const SellerListScreen({super.key});

  @override
  State<SellerListScreen> createState() => _SellerListScreenState();
}

class _SellerListScreenState extends State<SellerListScreen> {
  late Future<List<Seller>> _sellersFuture;

  @override
  void initState() {
    super.initState();
    _sellersFuture = SellerService.getAllSellers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Vendedores'),
      ),
      body: FutureBuilder<List<Seller>>(
        future: _sellersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sellers = snapshot.data ?? [];

          if (sellers.isEmpty) {
            return const Center(child: Text('No hay vendedores registrados.'));
          }

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: UserImage(
                    imagePath: seller.fotoPerfil,
                    width: 60,
                    height: 60,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  title: Text(seller.nombre),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Teléfono: ${seller.telefono}')
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerScreen(seller: seller),
                      ),
                    );
                  },

                ),
              );

            },
          );
        },
      ),
    );
  }
}
