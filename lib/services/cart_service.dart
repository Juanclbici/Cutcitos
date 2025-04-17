import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartService {
  // Mapa para agrupar productos por vendedor
  static final Map<int, List<CartItem>> _cartGrouped = {};

  static Map<int, List<CartItem>> getCart() {
    return _cartGrouped;
  }

  static void addToCart(Product product) {
    final sellerId = product.sellerId;

    if (!_cartGrouped.containsKey(sellerId)) {
      _cartGrouped[sellerId] = [];
    }

    final existingItem = _cartGrouped[sellerId]!
        .firstWhere((item) => item.product.id == product.id, orElse: () => CartItem(product: product, quantity: 0));

    if (existingItem.quantity > 0) {
      existingItem.quantity++;
    } else {
      _cartGrouped[sellerId]!.add(CartItem(product: product));
    }
  }

  static void removeFromCart(Product product) {
    final sellerId = product.sellerId;
    final cartItems = _cartGrouped[sellerId];
    if (cartItems == null) return;

    cartItems.removeWhere((item) => item.product.id == product.id);

    if (cartItems.isEmpty) {
      _cartGrouped.remove(sellerId);
    }
  }

  static void clearCart() {
    _cartGrouped.clear();
  }

  static void removeSellerFromCart(int sellerId) {
    _cartGrouped.remove(sellerId);
  }
}
