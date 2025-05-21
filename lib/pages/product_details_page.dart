import 'package:agriplant/data/products.dart';
import 'package:agriplant/provider/cart_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late TapGestureRecognizer _readMoreGestureRecognizer;
  bool _showMore = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _readMoreGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        setState(() {
          _showMore = !_showMore;
        });
      };
  }

  @override
  void dispose() {
    _readMoreGestureRecognizer.dispose();
    super.dispose();
  }

  void _increaseQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _addToCart() {
    // Create a cart item
    final cartItem = CartItem(
      product: widget.product,
      quantity: _quantity,
    );

    // Add the item to cart using Provider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.addToCart(cartItem);

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.product.name} added to cart'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          onPressed: () {
            // Navigate to cart page
            Navigator.pushNamed(context, '/cart');
          },
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate to cart page after adding to cart
    Navigator.pushNamed(context, '/cart');
  }

  void _viewCart() {
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    // Get cart provider to show cart badge count
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItemCount = cartProvider.items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(IconlyLight.bookmark),
            tooltip: 'Save for later',
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _viewCart, // This will navigate to cart page
                icon: const Icon(IconlyLight.bag2),
                tooltip: 'View cart',
              ),
              if (cartItemCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProductImage(),
            const SizedBox(height: 16),
            _buildProductHeader(),
            const SizedBox(height: 20),
            _buildProductDescription(),
            const SizedBox(height: 20),
            _buildSimilarProducts(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProductImage() {
    return Hero(
      tag: 'product-${widget.product.id}',
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(widget.product.image),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "Available in stock",
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "MAD ${(widget.product.price).toStringAsFixed(2)}", // Convert price to MAD
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  TextSpan(
                    text: "/${widget.product.unit}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              Icons.star,
              size: 16,
              color: Colors.yellow.shade800,
            ),
            const SizedBox(width: 4),
            Text(
              "${widget.product.rating}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              " (192 reviews)",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            _buildQuantitySelector(),
          ],
        ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        SizedBox(
          height: 32,
          width: 32,
          child: IconButton.filledTonal(
            padding: EdgeInsets.zero,
            onPressed: _decreaseQuantity,
            iconSize: 18,
            icon: const Icon(Icons.remove),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            "$_quantity ${widget.product.unit}",
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: 32,
          width: 32,
          child: IconButton.filledTonal(
            padding: EdgeInsets.zero,
            onPressed: _increaseQuantity,
            iconSize: 18,
            icon: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }

  Widget _buildProductDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Description",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyMedium,
            children: [
              TextSpan(
                text: _showMore
                    ? widget.product.description
                    : widget.product.description.length > 100
                        ? '${widget.product.description.substring(0, 100)}...'
                        : widget.product.description,
              ),
              if (widget.product.description.length > 100)
                TextSpan(
                  recognizer: _readMoreGestureRecognizer,
                  text: _showMore ? " Read less" : " Read more",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarProducts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Similar Products",
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final similarProduct = products[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to the product details page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailsPage(
                        product: similarProduct,
                      ),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(similarProduct.image),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 80,
                      child: Text(
                        similarProduct.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            },
            separatorBuilder: (__, _) => const SizedBox(width: 12),
            itemCount: products.length > 5 ? 5 : products.length,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -1),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    "MAD ${(widget.product.price * _quantity).toStringAsFixed(2)}", // Convert price to MAD
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed:
                          _addToCart, // This adds to cart and then navigates
                      icon: const Icon(IconlyLight.bag2),
                      label: const Text("Add to cart"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: OutlinedButton(
                      onPressed: _viewCart, // This directly navigates to cart
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("VIEW"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
