import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'seller_screen.dart';
import '../user/info_profile.dart';
import '../user/messages_screen.dart';
import '../../services/category_service.dart';
import '../../services/product_service.dart';
import '../../widgets/product_image.dart';

class SellersList extends StatefulWidget {
  const SellersList({super.key});

  @override
  State<SellersList> createState() => _SellersListState();
}

class _SellersListState extends State<SellersList> {
  bool _isLoading = true;
  int _selectedIndex = 0;
  List<Category> _categories = [];
  bool _isLoadingCategories = true;
  String _selectedCategory = 'Todos';
  List<Product> _products = [];
  bool _isLoadingProducts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAllProducts();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error cargando categorías: $e")),
      );
    }
  }

  Future<void> _loadAllProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _isLoadingProducts = true;
      });

      final products = await ProductService.getAllProducts();

      // Verifica los productos recibidos
      print('Productos para mostrar: ${products.length}');

      setState(() {
        _products = products;
        _isLoading = false;
        _isLoadingProducts = false;
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _isLoadingProducts = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadProductsByCategory(int categoryId) async {
    try {
      setState(() => _isLoadingProducts = true);
      final products = await ProductService.getProductsByCategory(categoryId);
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() => _isLoadingProducts = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Productos"),
        backgroundColor: Colors.cyan,
      ),
      body: _isLoading || _isLoadingCategories
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Search Bar (se mantiene igual)
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

          // Categorías (se mantiene igual)
          Container(
            height: 50,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: const Text('Todos'),
                      selected: _selectedCategory == 'Todos',
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = 'Todos';
                        });
                        _loadAllProducts();
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Colors.cyan.shade100,
                      labelStyle: TextStyle(
                        color: _selectedCategory == 'Todos'
                            ? Colors.cyan.shade700
                            : Colors.black87,
                      ),
                    ),
                  );
                }

                final category = _categories[index - 1];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category.name),
                    selected: _selectedCategory == category.name,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category.name;
                      });
                      _loadProductsByCategory(category.id);
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.cyan.shade100,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category.name
                          ? Colors.cyan.shade700
                          : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),

          // Lista de Productos (nueva implementación)
          Expanded(
            child: _isLoadingProducts
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
                ? const Center(child: Text("No hay productos disponibles"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: InkWell(
                    onTap: () {
                      // Aquí puedes navegar a la pantalla de detalle del producto
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductImage(
                            imagePath: product.image,
                            width: 100,
                            height: 100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.description ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '\$${product.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyan,
                                      ),
                                    ),
                                    Text(
                                      'Disponibles: ${product.availableQuantity}',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MessagesScreen(),
              ),
            );
          } else if (index == 3) {
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