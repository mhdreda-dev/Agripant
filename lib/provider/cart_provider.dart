import 'package:flutter/foundation.dart';

import '../models/product.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  // Add a copyWith method for easier item updates
  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  // Calculate the total price for this cart item
  double get totalPrice => product.price * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  bool get isEmpty => _items.isEmpty;

  // Calculate total price for all items in cart
  double get totalPrice {
    return _items.fold(
      0.0,
      (sum, item) => sum + item.totalPrice,
    );
  }

  // Get the total number of products in cart (sum of quantities)
  int get totalQuantity {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Add or update item in cart
  void addToCart(CartItem newItem) {
    final existingIndex = _findItemIndex(newItem.product.id);

    if (existingIndex >= 0) {
      // Update existing item quantity
      updateQuantity(
          existingIndex, _items[existingIndex].quantity + newItem.quantity);
    } else {
      // Add new item
      _items.add(newItem);
      notifyListeners();
    }
  }

  // Update quantity of an item by index
  void updateQuantity(int index, int quantity) {
    if (index >= 0 && index < _items.length) {
      if (quantity <= 0) {
        // Remove item if quantity is 0 or negative
        _items.removeAt(index);
      } else {
        // Update quantity
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      notifyListeners();
    }
  }

  // Remove item by index
  void removeFromCart(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  // Remove item by product ID
  void removeItemByProductId(String productId) {
    final index = _findItemIndex(productId);
    if (index >= 0) {
      removeFromCart(index);
    }
  }

  // Check if a product exists in the cart
  bool containsProduct(String productId) {
    return _findItemIndex(productId) >= 0;
  }

  // Get cart item by product ID
  CartItem? getItemByProductId(String productId) {
    final index = _findItemIndex(productId);
    return index >= 0 ? _items[index] : null;
  }

  // Find index of an item by product ID
  int _findItemIndex(String productId) {
    return _items.indexWhere((item) => item.product.id == productId);
  }

  // Clear the cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
