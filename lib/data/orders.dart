import 'dart:math';

import 'package:agriplant/data/products.dart';
import 'package:agriplant/models/CartItemModel.dart';
import 'package:agriplant/models/order.dart';
import 'package:flutter/material.dart';

enum OrderStatus {
  processing,
  picking,
  shipping,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.picking:
        return 'Picking';
      case OrderStatus.shipping:
        return 'Shipping';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.processing:
        return Colors.blue;
      case OrderStatus.picking:
        return Colors.amber;
      case OrderStatus.shipping:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }
}

List<Order> orders = [
  Order(
    id: "ORD-2023-045",
    items: products.reversed
        .take(3)
        .map((product) =>
            CartItemModel(product: product, quantity: Random().nextInt(3) + 1))
        .toList(),
    date: DateTime.utc(2023, 4, 15),
    status: OrderStatus.processing,
    totalAmount: 124.99,
    address: "123 Farm Road, Agricultural District",
    name: "Mhd reda",
    phone: "233 5447 51048",
    paymentMethod: "Credit Card",
    trackingNumber: "AGRI23987654",
  ),
  Order(
    id: "ORD-2023-032",
    items: products
        .skip(1)
        .take(2)
        .map((product) =>
            CartItemModel(product: product, quantity: Random().nextInt(3) + 1))
        .toList(),
    date: DateTime.utc(2023, 3, 22),
    status: OrderStatus.shipping,
    totalAmount: 89.50,
    address: "456 Crop Lane, Harvest County",
    name: "John Doe",
    phone: "123 4567 8901",
    paymentMethod: "PayPal",
    trackingNumber: "AGRI23675432",
  ),
  Order(
    id: "ORD-2022-198",
    items: products
        .take(1)
        .map((product) =>
            CartItemModel(product: product, quantity: Random().nextInt(3) + 1))
        .toList(),
    date: DateTime.utc(2022, 12, 5),
    status: OrderStatus.delivered,
    totalAmount: 45.75,
    address: "789 Garden Street, Plant City",
    name: "Jane Smith",
    phone: "987 6543 2109",
    paymentMethod: "Bank Transfer",
    trackingNumber: "AGRI22456789",
  ),
  Order(
    id: "ORD-2022-156",
    items: products
        .skip(2)
        .take(3)
        .map((product) =>
            CartItemModel(product: product, quantity: Random().nextInt(3) + 1))
        .toList(),
    date: DateTime.utc(2022, 9, 18),
    status: OrderStatus.delivered,
    totalAmount: 157.25,
    address: "101 Soil Avenue, Growth Town",
    name: "Alice Johnson",
    phone: "456 7890 1234",
    paymentMethod: "Credit Card",
    trackingNumber: "AGRI22345678",
  ),
  Order(
    id: "ORD-2021-087",
    items: products.reversed
        .skip(1)
        .take(2)
        .map((product) =>
            CartItemModel(product: product, quantity: Random().nextInt(3) + 1))
        .toList(),
    date: DateTime.utc(2021, 7, 29),
    status: OrderStatus.delivered,
    totalAmount: 76.50,
    address: "202 Seed Road, Bloom Village",
    name: "Bob Wilson",
    phone: "321 6549 9876",
    paymentMethod: "PayPal",
    trackingNumber: "AGRI21567890",
  ),
  Order(
    id: "ORD-2023-067",
    items: products
        .take(2)
        .map((product) =>
            CartItemModel(product: product, quantity: Random().nextInt(3) + 1))
        .toList(),
    date: DateTime.utc(2023, 5, 7),
    status: OrderStatus.cancelled,
    totalAmount: 112.25,
    address: "303 Compost Street, Organic City",
    name: "Emma Brown",
    phone: "654 3210 9876",
    paymentMethod: "Bank Transfer",
    trackingNumber: null,
  ),
];

List<Order> getOrdersByStatus(OrderStatus status) {
  return orders.where((order) => order.status == status).toList();
}

Map<OrderStatus, int> getOrderStatusCounts() {
  final Map<OrderStatus, int> counts = {};
  for (final status in OrderStatus.values) {
    counts[status] = orders.where((order) => order.status == status).length;
  }
  return counts;
}

List<Order> getSortedOrders({bool ascending = true}) {
  return List.from(orders)
    ..sort((a, b) =>
        ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
}
