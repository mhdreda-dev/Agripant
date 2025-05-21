import 'package:agriplant/models/order.dart';
import 'package:agriplant/pages/OrderItemsPage.dart';
import 'package:flutter/material.dart';

class OrderItem extends StatelessWidget {
  const OrderItem({
    super.key,
    required this.order,
    this.visibleProducts = 1,
  });

  final Order order;
  final int visibleProducts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemsToShow = order.items.take(visibleProducts).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Items",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        if (itemsToShow.isEmpty)
          const Text(
            'No items in this order',
            style: TextStyle(color: Colors.grey),
          ),
        ...itemsToShow.map((item) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.asset(
                        item.product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${item.product.unit} - \$${item.product.price.toStringAsFixed(2)} x ${item.quantity}",
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "\$${(item.product.price * item.quantity).toStringAsFixed(2)}",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          );
        }).toList(),
        if (itemsToShow.length < order.items.length)
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderItemsPage(order: order),
                ),
              );
            },
            child: Text(
              "Show more (${order.items.length - itemsToShow.length})",
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
      ],
    );
  }
}
