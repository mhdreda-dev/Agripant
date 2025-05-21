import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

import '../provider/cart_provider.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    Key? key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                cartItem.product.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          cartItem.product.name,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(IconlyLight.delete),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                        splashRadius: 20,
                        tooltip: 'Remove item',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.product.unit,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Text(
                        "\$${cartItem.product.price.toStringAsFixed(2)}",
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),
                      // Quantity selector
                      _buildQuantityControls(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context) {
    return Row(
      children: [
        // Decrease button
        _buildQuantityButton(
          context: context,
          icon: Icons.remove,
          onPressed: cartItem.quantity > 1
              ? () => onQuantityChanged(cartItem.quantity - 1)
              : null,
        ),
        // Quantity
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "${cartItem.quantity}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // Increase button
        _buildQuantityButton(
          context: context,
          icon: Icons.add,
          onPressed: () => onQuantityChanged(cartItem.quantity + 1),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required BuildContext context,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: Material(
        color: onPressed != null
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Icon(
            icon,
            size: 16,
            color: onPressed != null
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}
