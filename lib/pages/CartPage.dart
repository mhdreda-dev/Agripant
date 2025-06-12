import 'package:agriplant/models/cart_item_model.dart';
import 'package:agriplant/provider/cart_provider.dart';
import 'package:agriplant/widgets/cartitemwidget.dart'; // Assure-toi que l'import est correct
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear cart?"),
        content: const Text(
          "Are you sure you want to remove all items from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<CartProvider>(context, listen: false).clearCart();
            },
            child: const Text("CLEAR"),
          ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, double total) {
    Navigator.pushNamed(context, '/checkout', arguments: {'total': total});
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          cartItems.isEmpty
              ? "My Cart"
              : "My Cart (${cartProvider.totalQuantity})",
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: () => _clearCart(context),
              icon: const Icon(
                IconlyLight.delete,
              ), // Correct usage of IconlyLight.delete
              tooltip: "Clear cart",
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, cartItems.cast<CartItemModel>()),
      bottomNavigationBar:
          cartItems.isEmpty ? null : _buildCheckoutBar(context, cartProvider),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyBold.bag,
            size: 80,
            color: Colors.grey.shade400,
          ), // Correct usage of IconlyBold.bag
          const SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Add items to start a cart",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Navigate back to products
            },
            child: const Text("Browse Products"),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    List<CartItemModel> cartItems,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];

        return CartItemWidget(
          cartItem: cartItem,
          onQuantityChanged: (quantity) {
            Provider.of<CartProvider>(
              context,
              listen: false,
            ).updateQuantity(index, quantity);
          },
          onRemove: () {
            Provider.of<CartProvider>(
              context,
              listen: false,
            ).removeFromCart(index);
          },
        );
      },
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cartProvider) {
    final subtotal = cartProvider.totalPrice;
    final shipping = subtotal > 50 ? 0.0 : 5.99; // Free shipping over $50
    final tax = subtotal * 0.1; // 10% tax
    final total = subtotal + shipping + tax;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(context, "Subtotal", subtotal),
            _buildSummaryRow(context, "Shipping", shipping),
            _buildSummaryRow(context, "Tax (10%)", tax),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    "MAD ${total.toStringAsFixed(2)}",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _proceedToCheckout(context, total),
              child: const Text("Proceed to Checkout"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            "MAD ${amount.toStringAsFixed(2)}",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
