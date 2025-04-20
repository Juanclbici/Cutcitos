class Product {
  final String name;
  final String price;
  final String status;
  final String image;

  Product({
    required this.name,
    required this.price,
    required this.status,
    required this.image,
  });

  // Metodo para crear una copia del producto con valores opcionalmente actualizados
  Product copyWith({
    String? name,
    String? price,
    String? status,
    String? image,
  }) {
    return Product(
      name: name ?? this.name,
      price: price ?? this.price,
      status: status ?? this.status,
      image: image ?? this.image,
    );
  }
}

class Seller {
  final String id;
  final String name;
  final String profileImage;
  final String coverImage;
  final double rating;
  final List<Product> products;

  Seller({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.coverImage,
    required this.rating,
    required this.products,
  });

  // Metodo para crear una copia del vendedor con valores opcionalmente actualizados
  Seller copyWith({
    String? id,
    String? name,
    String? profileImage,
    String? coverImage,
    double? rating,
    List<Product>? products,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      rating: rating ?? this.rating,
      products: products ?? this.products,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}

class SellerData {
  // Patrón singleton
  static final SellerData _instance = SellerData._internal();
  factory SellerData() => _instance;
  SellerData._internal();

  // Lista de vendedores de prueba (eliminar cuando se conecte a base de datos)
  final List<Seller> sellers = [
    Seller(
      id: '1',
      name: 'Gomitas',
      profileImage: 'assets/images/panditas.jpg',
      coverImage: 'assets/images/gomitas1.jpg',
      rating: 4.8,
      products: [
        Product(
          name: 'Gomitas',
          price: '15 MXN',
          status: 'Disponible',
          image: 'assets/images/gomitas1.jpg',
        ),
      ],
    ),
    Seller(
      id: '2',
      name: 'Chocolates',
      profileImage: 'assets/images/chocolates2.jpg',
      coverImage: 'assets/images/chocolates.jpg',
      rating: 4.5,
      products: [
        Product(
          name: 'Chocolate Oscuro',
          price: '45 MXN',
          status: 'Disponible',
          image: 'assets/images/chocolates.jpg',
        ),
      ],
    ),
  ];

  // Metodo para obtener la lista de vendedores
  Future<List<Seller>> getSellers() async {
    // En una implementación real, aquí se haría la consulta a la base de datos
    return sellers;
  }

  // Metodo para obtener un vendedor por su ID
  Future<Seller?> getSellerById(String sellerId) async {
    try {
      return sellers.firstWhere((seller) => seller.id == sellerId);
    } catch (e) {
      return null;
    }
  }

  // Metodo para agregar un nuevo producto a un vendedor
  Future<void> addProduct(String sellerId, Product newProduct) async {
    final sellerIndex = sellers.indexWhere((seller) => seller.id == sellerId);
    if (sellerIndex != -1) {
      // Crear una copia del vendedor con el nuevo producto añadido
      final updatedSeller = sellers[sellerIndex].copyWith(
        products: [...sellers[sellerIndex].products, newProduct],
      );

      // Actualizar la lista de vendedores
      sellers[sellerIndex] = updatedSeller;
    }
  }

  // Metodo para actualizar un producto existente
  Future<void> updateProduct(
      String sellerId,
      int productIndex,
      Product updatedProduct,
      ) async {
    final sellerIndex = sellers.indexWhere((seller) => seller.id == sellerId);
    if (sellerIndex != -1 && productIndex < sellers[sellerIndex].products.length) {
      // Crear una nueva lista de productos con el producto actualizado
      final updatedProducts = List<Product>.from(sellers[sellerIndex].products);
      updatedProducts[productIndex] = updatedProduct;

      // Crear una copia del vendedor con los productos actualizados
      final updatedSeller = sellers[sellerIndex].copyWith(
        products: updatedProducts,
      );

      // Actualizar la lista de vendedores
      sellers[sellerIndex] = updatedSeller;
    }
  }

  // Metodo para eliminar un producto
  Future<void> removeProduct(String sellerId, int productIndex) async {
    final sellerIndex = sellers.indexWhere((seller) => seller.id == sellerId);
    if (sellerIndex != -1 && productIndex < sellers[sellerIndex].products.length) {
      // Crear una nueva lista de productos sin el producto eliminado
      final updatedProducts = List<Product>.from(sellers[sellerIndex].products);
      updatedProducts.removeAt(productIndex);

      // Crear una copia del vendedor con los productos actualizados
      final updatedSeller = sellers[sellerIndex].copyWith(
        products: updatedProducts,
      );

      //Actualizar la lista de vendedores
      sellers[sellerIndex] = updatedSeller;
    }
  }

  //Metodo para buscar productos por nombre
  Future<List<Product>> searchProducts(String query) async {
    final results = <Product>[];
    for (final seller in sellers) {
      for (final product in seller.products) {
        if (product.name.toLowerCase().contains(query.toLowerCase())) {
          results.add(product);
        }
      }
    }
    return results;
  }
}