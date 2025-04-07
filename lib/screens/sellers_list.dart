import 'package:flutter/material.dart';
import '../models/SellerData.dart';
import 'seller_screen.dart';
import 'info_profile.dart';
import 'messages_screen.dart';

class SellersList extends StatefulWidget {
  const SellersList({super.key});

  @override
  State<SellersList> createState() => _SellersListState();
}

class _SellersListState extends State<SellersList> {
  final SellerData _sellerData = SellerData();
  List<Seller> _sellers = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // Boton de Navegacion

  // Category list
  final List<String> _categories = [
    'Todos', 'Snacks', 'Comida', 'Bebidas', 'Postres', 'Saludable'
  ];
  String _selectedCategory = 'Todos';

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  Future<void> _loadSellers() async {
    try {
      final sellers = await _sellerData.getSellers();
      setState(() {
        _sellers = sellers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vendedores"),
        backgroundColor: Colors.cyan,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // --- SEARCH BAR WIDGET ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar vendedores o productos...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // --- CATEGORIES WIDGET ---
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: _selectedCategory == _categories[index],
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = _categories[index];
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.cyan.shade100,
                    labelStyle: TextStyle(
                      color: _selectedCategory == _categories[index]
                          ? Colors.cyan.shade700
                          : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),

          // --- SELLERS LIST WIDGET ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sellers.length,
              itemBuilder: (context, index) {
                final seller = _sellers[index];

                // --- SELLER CARD WIDGET ---
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SellerScreen(seller: seller),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        // --- SELLER COVER IMAGE ---
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            image: DecorationImage(
                              image: AssetImage(seller.coverImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // --- SELLER INFO SECTION ---
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(seller.profileImage),
                                radius: 25,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      seller.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            color: Colors.cyan, size: 16),
                                        const SizedBox(width: 4),
                                        Text(seller.rating.toString()),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR WIDGET ---

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) { // Messages tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          } else if (index == 3) { // Profile tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const InfoProfile(),
              ),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },

        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Mensajes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}