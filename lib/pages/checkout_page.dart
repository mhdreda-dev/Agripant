import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

import '../provider/cart_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final Map<String, String> _shippingDetails = {};
  final Map<String, String> _paymentDetails = {};
  String _selectedPaymentMethod = 'Credit Card';

  @override
  Widget build(BuildContext context) {
    // Get arguments passed from the cart page
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final total = args?['total'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep == 0 && !_validateShippingForm()) {
            return;
          }

          setState(() {
            if (_currentStep < 2) {
              _currentStep++;
            } else {
              _processOrder();
            }
          });
        },
        onStepCancel: () {
          setState(() {
            if (_currentStep > 0) {
              _currentStep--;
            }
          });
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 2 ? 'Place Order' : 'Continue'),
                ),
                if (_currentStep > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('Shipping Information'),
            content: _buildShippingForm(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Payment Method'),
            content: _buildPaymentMethodForm(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Order Summary'),
            content: _buildOrderSummary(total),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
        ],
      ),
    );
  }

  Widget _buildShippingForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(IconlyLight.profile),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
            onSaved: (value) {
              _shippingDetails['name'] = value ?? '';
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Address',
              prefixIcon: Icon(IconlyLight.location),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
            onSaved: (value) {
              _shippingDetails['address'] = value ?? '';
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'City',
                    prefixIcon: Icon(IconlyLight.home),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _shippingDetails['city'] = value ?? '';
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    prefixIcon: Icon(IconlyLight.paper),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Required';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _shippingDetails['postalCode'] = value ?? '';
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(IconlyLight.call),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              return null;
            },
            onSaved: (value) {
              _shippingDetails['phone'] = value ?? '';
            },
          ),
        ],
      ),
    );
  }

  bool _validateShippingForm() {
    final formState = _formKey.currentState;
    if (formState != null && formState.validate()) {
      formState.save();
      return true;
    }
    return false;
  }

  Widget _buildPaymentMethodForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildPaymentOption(
          'Credit Card',
          Icons.credit_card,
          'Pay with Visa, Mastercard, or American Express',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'PayPal',
          Icons.account_balance_wallet,
          'Fast and secure payment with PayPal',
        ),
        const SizedBox(height: 12),
        _buildPaymentOption(
          'Apple Pay',
          Icons.apple,
          'Quick checkout with Apple Pay',
        ),
        const SizedBox(height: 20),
        if (_selectedPaymentMethod == 'Credit Card') _buildCreditCardForm(),
      ],
    );
  }

  Widget _buildPaymentOption(String title, IconData icon, String description) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: _selectedPaymentMethod == title
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: title,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
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

  Widget _buildCreditCardForm() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card Number',
            prefixIcon: Icon(IconlyLight.wallet),
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            _paymentDetails['cardNumber'] = value;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (value) {
                  _paymentDetails['expiryDate'] = value;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _paymentDetails['cvv'] = value;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: Icon(IconlyLight.profile),
          ),
          onChanged: (value) {
            _paymentDetails['cardholderName'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double total) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.product.image != true
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.product.image,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(IconlyLight.image2),
              ),
              title: Text(
                item.product.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '\$${item.product.price.toStringAsFixed(2)} × ${item.quantity}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              trailing: Text(
                '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
        const Divider(height: 24),
        if (_shippingDetails.isNotEmpty) ...[
          const Text(
            'Shipping Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Name', _shippingDetails['name'] ?? ''),
          _buildInfoRow('Address', _shippingDetails['address'] ?? ''),
          _buildInfoRow('Location',
              '${_shippingDetails['city'] ?? ''}, ${_shippingDetails['postalCode'] ?? ''}'),
          _buildInfoRow('Phone', _shippingDetails['phone'] ?? ''),
          const Divider(height: 24),
        ],
        const Text(
          'Payment Method',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              _selectedPaymentMethod == 'Credit Card'
                  ? Icons.credit_card
                  : _selectedPaymentMethod == 'PayPal'
                      ? Icons.account_balance_wallet
                      : Icons.apple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(_selectedPaymentMethod),
          ],
        ),
        if (_selectedPaymentMethod == 'Credit Card' &&
            _paymentDetails.containsKey('cardNumber')) ...[
          const SizedBox(height: 4),
          Text(
            'Card ending in ${_paymentDetails['cardNumber']!.substring(_paymentDetails['cardNumber']!.length - 4)}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
        const Divider(height: 24),
        _buildSummaryRow('Subtotal', cartProvider.totalPrice),
        _buildSummaryRow(
          cartProvider.totalPrice > 50
              ? 'Shipping (Free over \$50)'
              : 'Shipping',
          cartProvider.totalPrice > 50 ? 0.0 : 5.99,
        ),
        _buildSummaryRow('Tax (10%)', cartProvider.totalPrice * 0.1),
        const Divider(height: 20),
        _buildSummaryRow(
          'Total',
          total,
          isTotal: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$title:',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount == 0.0 && title.contains('Free')
                ? 'FREE'
                : '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
              color: title.contains('Free') && amount == 0.0
                  ? Colors.green
                  : isTotal
                      ? Theme.of(context).colorScheme.primary
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  void _processOrder() {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate order processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed Successfully!'),
          content: const Text(
            'Thank you for your order. You will receive a confirmation email shortly.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear the cart
                Provider.of<CartProvider>(context, listen: false).clearCart();

                // Navigate back to home screen
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('CONTINUE SHOPPING'),
            ),
          ],
        ),
      );
    });
  }
}
