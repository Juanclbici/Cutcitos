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

  // MANTENER: Patrón singleton
  static final SellerData _instance = SellerData._internal();
  factory SellerData() => _instance;
  SellerData._internal();


  // Metodo para obtener la lista de vendedores
  //Modificar cuando se agregue la base de datos
  Future<List<Seller>> getSellers() async {

    return sellers;
  }


  // ELIMINAR: La info en memoria que uso para pruebas,
  // borrar cuando se agregue la base de datos
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
}