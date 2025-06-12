import 'package:agriplant/models/order.dart';
import 'package:flutter/material.dart';

class OrderItemsPage extends StatelessWidget {
  const OrderItemsPage({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${order.id} Items'),
      ),
      body: order.items.isEmpty
          ? const Center(
              child: Text(
                'No items in this order',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: order.items.length,
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Padding(
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
                );
              },
            ),
    );
  }
}
