import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

import '../provider/cart_provider.dart';
import '../widgets/CartItemWidget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  void _clearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear cart?"),
        content: const Text(
            "Are you sure you want to remove all items from your cart?"),
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
    Navigator.pushNamed(
      context,
      '/checkout',
      arguments: {'total': total},
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(cartItems.isEmpty
            ? "My Cart"
            : "My Cart (${cartProvider.totalQuantity})"),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: () => _clearCart(context),
              icon: const Icon(IconlyLight.delete),
              tooltip: "Clear cart",
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, cartItems),
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
          ),
          const SizedBox(height: 16),
          Text(
            "Your cart is empty",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            "Add items to start a cart",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context); // Navigate back to products
            },
            icon: const Icon(IconlyLight.discovery),
            label: const Text("Browse Products"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, List<CartItem> cartItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final cartItem = cartItems[index];

        return CartItemWidget(
          cartItem: cartItem,
          onQuantityChanged: (quantity) {
            Provider.of<CartProvider>(context, listen: false)
                .updateQuantity(index, quantity);
          },
          onRemove: () {
            Provider.of<CartProvider>(context, listen: false)
                .removeFromCart(index);

            // Show confirmation snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${cartItem.product.name} removed from cart'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    // Add the item back to cart
                    Provider.of<CartProvider>(context, listen: false)
                        .addToCart(cartItem);
                  },
                ),
              ),
            );
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
            // Order summary rows
            _buildSummaryRow(context, "Subtotal", subtotal),
            _buildSummaryRow(
              context,
              subtotal > 50 ? "Shipping (Free over 500 MAD)" : "Shipping",
              shipping,
              isHighlighted: shipping == 0.0,
            ),
            _buildSummaryRow(context, "Tax (10%)", tax),
            const Divider(height: 24),
            // Total row
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
                    "MAD ${total.toStringAsFixed(2)}", // Price in MAD
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            // Checkout button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _proceedToCheckout(context, total),
                icon: const Icon(IconlyLight.wallet),
                label: const Text("Proceed to Checkout"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, double amount,
      {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            amount == 0.0 && isHighlighted
                ? "FREE"
                : "MAD ${amount.toStringAsFixed(2)}", // Display price in MAD
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isHighlighted ? Colors.green : null,
                ),
          ),
        ],
      ),
    );
  }
}
