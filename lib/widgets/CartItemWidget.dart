import 'package:flutter/material.dart';

import '../models/cart_item_model.dart'; // Assure-toi que l'import est correct

class CartItemWidget extends StatelessWidget {
  final CartItemModel cartItem; // Type de CartItemModel
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(cartItem.product.name),
      subtitle: Text("Quantity: ${cartItem.quantity}"),
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onRemove, // Appelle la fonction de suppression
      ),
      onTap: () {
        // Implémenter la logique pour changer la quantité
      },
    );
  }
}
