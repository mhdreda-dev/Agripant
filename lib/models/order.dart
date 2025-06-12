import 'package:agriplant/data/orders.dart';
import 'package:agriplant/models/cart_item_model.dart';
import 'package:flutter/material.dart';

/// Represents an order placed by a user.
class Order {
  final String id;
  final List<CartItemModel> items;
  final DateTime date;
  final OrderStatus status;
  final double totalAmount;
  final String address;
  final String name;
  final String phone;
  final String paymentMethod;
  final String? trackingNumber;

  Order({
    required this.id,
    required this.items,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.address,
    required this.name,
    required this.phone,
    required this.paymentMethod,
    this.trackingNumber,
  }) {
    if (id.isEmpty) throw ArgumentError('ID cannot be empty');
    if (items.isEmpty) throw ArgumentError('Items cannot be empty');
    if (address.isEmpty) throw ArgumentError('Address cannot be empty');
    if (name.isEmpty) throw ArgumentError('Name cannot be empty');
    if (phone.isEmpty) throw ArgumentError('Phone cannot be empty');
    if (paymentMethod.isEmpty) {
      throw ArgumentError('Payment method cannot be empty');
    }
  }

  /// Calculates the total amount based on item prices and quantities.
  double get calculatedTotal {
    return items.fold(
      0,
      (previousValue, item) =>
          previousValue + item.product.price * item.quantity,
    );
  }

  /// Formats the date as DD/MM/YYYY.
  String get formattedDate {
    return "${date.day}/${date.month}/${date.year}";
  }

  /// Gets the total number of items (sum of quantities).
  int get itemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Checks if the order can be cancelled.
  bool get canBeCancelled {
    return status == OrderStatus.processing || status == OrderStatus.picking;
  }

  /// Gets the color associated with the order status.
  Color get statusColor {
    return status.color;
  }
}
