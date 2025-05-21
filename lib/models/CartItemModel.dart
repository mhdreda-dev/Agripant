import 'package:agriplant/models/product.dart';

/// Represents an item in the cart, associating a product with its quantity.
class CartItemModel {
  final Product product;
  int _quantity;

  CartItemModel({
    required this.product,
    required int quantity,
  }) : _quantity = quantity > 0 ? quantity : 1;

  /// Gets the quantity of the item.
  int get quantity => _quantity;

  /// Sets the quantity with validation to ensure it is positive.
  set quantity(int value) {
    if (value > 0) {
      _quantity = value;
    } else {
      throw ArgumentError('Quantity must be positive');
    }
  }
}
