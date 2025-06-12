import 'package:agriplant/models/product.dart';

/// Représente un article dans le panier, associant un produit à sa quantité.
class CartItemModel {
  final Product product;
  int _quantity;

  CartItemModel({
    required this.product,
    required int quantity,
  }) : _quantity = quantity > 0 ? quantity : 1;

  /// Obtient la quantité de l'article.
  int get quantity => _quantity;

  /// Définit la quantité avec validation pour garantir qu'elle soit positive.
  set quantity(int value) {
    if (value > 0) {
      _quantity = value;
    } else {
      throw ArgumentError('La quantité doit être positive');
    }
  }

  /// Retourne le prix total de cet article (prix * quantité).
  double get totalPrice {
    return product.price * _quantity;
  }

  /// Méthode pour augmenter la quantité de cet article.
  void increaseQuantity() {
    _quantity++;
  }

  /// Méthode pour diminuer la quantité de cet article.
  void decreaseQuantity() {
    if (_quantity > 1) {
      _quantity--;
    }
  }
}
