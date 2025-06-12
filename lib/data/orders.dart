import 'dart:math';

import 'package:agriplant/data/products.dart';
import 'package:agriplant/models/order.dart';
import 'package:flutter/material.dart';

import '../models/cart_item_model.dart' show CartItemModel;

/// Enum que representa los posibles estados de una orden
enum OrderStatus {
  processing,
  picking,
  shipping,
  delivered,
  cancelled,
}

/// Clase para manejar configuración de monedas y tasas de cambio
class CurrencyConfig {
  static const double _usdToMadRate = 10.2; // Actualizar según tasa actual
  static const String _defaultCurrency = 'USD';

  /// Obtiene la tasa de cambio USD a MAD
  static double get usdToMadRate => _usdToMadRate;

  /// Convierte USD a MAD
  static double convertUsdToMad(double usdAmount) => usdAmount * _usdToMadRate;

  /// Convierte MAD a USD
  static double convertMadToUsd(double madAmount) => madAmount / _usdToMadRate;

  /// Formatea un monto según la moneda especificada
  static String formatAmount(double amount,
      {String currency = _defaultCurrency}) {
    switch (currency.toUpperCase()) {
      case 'DH':
      case 'MAD':
        return '${amount.toStringAsFixed(2)} DH';
      case 'USD':
      default:
        return '\${amount.toStringAsFixed(2)}';
    }
  }
}

/// Extensión para manejar conversión de precios
extension PriceExtension on double {
  /// Convierte el precio a Dirham marroquí (asumiendo que el precio base está en USD)
  /// Tasa de cambio aproximada: 1 USD = 10.2 MAD (actualizar según tasa actual)
  double get toDirham => this * CurrencyConfig.usdToMadRate;

  /// Formatea el precio en Dirham con símbolo
  String get formattedDirham => '${toDirham.toStringAsFixed(2)} DH';

  /// Formatea el precio original con símbolo USD
  String get formattedUSD => '\${toStringAsFixed(2)}';

  /// Formatea el precio según la moneda especificada
  String formatPrice({String currency = 'MAD'}) {
    return CurrencyConfig.formatAmount(this, currency: currency);
  }
}

/// Extensión para OrderStatus que provee métodos útiles para la UI
extension OrderStatusExtension on OrderStatus {
  /// Nombre legible para mostrar en la interfaz
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

  /// Color asociado al estado para mostrar en la UI
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

  /// Indica si el estado permite cancelación
  bool get canBeCancelled {
    return this == OrderStatus.processing || this == OrderStatus.picking;
  }

  /// Indica si el estado es final (no puede cambiar)
  bool get isFinal {
    return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  }
}

/// Clase para manejar la lógica de órdenes
/// Clase para manejar la lógica de órdenes
/// Clase para manejar la lógica de órdenes
class OrderService {
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
  OrderService._internal() {
    // Automatically initialize test data when service is created
    initializeTestData();
  }

  // Lista privada de órdenes
  final List<Order> _orders = [];

  /// Obtiene todas las órdenes
  List<Order> get orders {
    // Ensure data is initialized even if constructor didn't run
    if (_orders.isEmpty) {
      initializeTestData();
    }
    return List.unmodifiable(_orders);
  }

  /// Inicializa los datos de prueba
  void initializeTestData() {
    if (_orders.isNotEmpty) return; // Evitar duplicar datos

    final random = Random();

    _orders.addAll([
      Order(
        id: "ORD-2025-045",
        items: _createRandomCartItems(3),
        date: DateTime.now().subtract(const Duration(days: 5)),
        status: OrderStatus.processing,
        totalAmount: 1274.95, // 124.99 USD = ~1274.95 DH
        address: "123 Farm Road, Agricultural District, Casablanca",
        name: "Mhd reda",
        phone: "233 5447 51048",
        paymentMethod: "Credit Card",
        trackingNumber: "AGRI25987654",
      ),
      Order(
        id: "ORD-2025-032",
        items: _createRandomCartItems(2),
        date: DateTime.now().subtract(const Duration(days: 2)),
        status: OrderStatus.shipping,
        totalAmount: 912.90, // 89.50 USD = ~912.90 DH
        address: "456 Crop Lane, Harvest County, Rabat",
        name: "John Doe",
        phone: "123 4567 8901",
        paymentMethod: "PayPal",
        trackingNumber: "AGRI25675432",
      ),
      Order(
        id: "ORD-2024-198",
        items: _createRandomCartItems(1),
        date: DateTime.now().subtract(const Duration(days: 30)),
        status: OrderStatus.delivered,
        totalAmount: 466.65, // 45.75 USD = ~466.65 DH
        address: "789 Garden Street, Plant City, Marrakech",
        name: "Jane Smith",
        phone: "987 6543 2109",
        paymentMethod: "Bank Transfer",
        trackingNumber: "AGRI24456789",
      ),
      Order(
        id: "ORD-2025-156",
        items: _createRandomCartItems(3),
        date: DateTime.now(),
        status: OrderStatus.delivered,
        totalAmount: 1603.95, // 157.25 USD = ~1603.95 DH
        address: "101 Soil Avenue, Growth Town, Fès",
        name: "Alice Johnson",
        phone: "456 7890 1234",
        paymentMethod: "Credit Card",
        trackingNumber: "AGRI25345678",
      ),
      Order(
        id: "ORD-2025-087",
        items: _createRandomCartItems(2),
        date: DateTime.now().subtract(const Duration(days: 1)),
        status: OrderStatus.delivered,
        totalAmount: 780.30, // 76.50 USD = ~780.30 DH
        address: "202 Seed Road, Bloom Village, Agadir",
        name: "Bob Wilson",
        phone: "321 6549 9876",
        paymentMethod: "PayPal",
        trackingNumber: "AGRI25567890",
      ),
      Order(
        id: "ORD-2025-067",
        items: _createRandomCartItems(2),
        date: DateTime.now().subtract(const Duration(days: 7)),
        status: OrderStatus.cancelled,
        totalAmount: 1144.95, // 112.25 USD = ~1144.95 DH
        address: "303 Compost Street, Organic City, Tanger",
        name: "Emma Brown",
        phone: "654 3210 9876",
        paymentMethod: "Bank Transfer",
        trackingNumber: null,
      ),
    ]);
  }

  /// Crea items de carrito aleatorios para testing
  List<CartItemModel> _createRandomCartItems(int count) {
    final random = Random();
    return products
        .take(count)
        .map((product) => CartItemModel(
              product: product,
              quantity: random.nextInt(3) + 1,
            ))
        .toList();
  }

  /// Obtiene órdenes por estado
  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Obtiene una orden por ID
  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene órdenes de un usuario específico
  List<Order> getOrdersByUser(String userName) {
    return _orders
        .where((order) => order.name.toLowerCase() == userName.toLowerCase())
        .toList();
  }

  /// Obtiene órdenes en un rango de fechas
  List<Order> getOrdersByDateRange(DateTime startDate, DateTime endDate) {
    return _orders
        .where((order) =>
            order.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
            order.date.isBefore(endDate.add(const Duration(days: 1))))
        .toList();
  }

  /// Obtiene órdenes ordenadas por fecha (más recientes primero)
  List<Order> getOrdersSortedByDate({bool ascending = false}) {
    final sortedOrders = List<Order>.from(_orders);
    sortedOrders.sort((a, b) =>
        ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    return sortedOrders;
  }

  /// Obtiene órdenes pendientes (no finalizadas)
  List<Order> getPendingOrders() {
    return _orders.where((order) => !order.status.isFinal).toList();
  }

  /// Obtiene estadísticas de órdenes por estado
  Map<OrderStatus, int> getOrderStatistics() {
    final stats = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      stats[status] = getOrdersByStatus(status).length;
    }
    return stats;
  }

  /// Calcula el total de ventas
  double getTotalSales() {
    return _orders
        .where((order) => order.status == OrderStatus.delivered)
        .fold(0.0, (sum, order) => sum + order.totalAmount);
  }

  /// Calcula el total de ventas en Dirham
  double getTotalSalesInDirham() {
    return getTotalSales().toDirham;
  }

  /// Obtiene el total de ventas formateado
  String getFormattedTotalSales({String currency = 'USD'}) {
    return getTotalSales().formatPrice(currency: currency);
  }

  /// Actualiza el estado de una orden
  bool updateOrderStatus(String orderId, OrderStatus newStatus) {
    try {
      final order = getOrderById(orderId);
      if (order == null) return false;

      // Validar transiciones de estado
      if (!_isValidStatusTransition(order.status, newStatus)) {
        return false;
      }

      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        // Crear nueva instancia con estado actualizado
        final updatedOrder = Order(
          id: order.id,
          items: order.items,
          date: order.date,
          status: newStatus,
          totalAmount: order.totalAmount,
          address: order.address,
          name: order.name,
          phone: order.phone,
          paymentMethod: order.paymentMethod,
          trackingNumber: order.trackingNumber,
        );
        _orders[index] = updatedOrder;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Valida si una transición de estado es válida
  bool _isValidStatusTransition(OrderStatus current, OrderStatus next) {
    // Estados finales no pueden cambiar
    if (current.isFinal) return false;

    // Definir transiciones válidas
    switch (current) {
      case OrderStatus.processing:
        return next == OrderStatus.picking || next == OrderStatus.cancelled;
      case OrderStatus.picking:
        return next == OrderStatus.shipping || next == OrderStatus.cancelled;
      case OrderStatus.shipping:
        return next == OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return false; // Estados finales
    }
  }

  /// Cancela una orden si es posible
  bool cancelOrder(String orderId) {
    final order = getOrderById(orderId);
    if (order == null || !order.status.canBeCancelled) {
      return false;
    }
    return updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  /// Agrega una nueva orden
  void addOrder(Order order) {
    _orders.add(order);
  }

  /// Elimina una orden (solo para testing)
  bool removeOrder(String orderId) {
    final initialLength = _orders.length;
    _orders.removeWhere((order) => order.id == orderId);
    return _orders.length < initialLength;
  }

  /// Limpia todas las órdenes (solo para testing)
  void clearOrders() {
    _orders.clear();
  }
}

// Instancia global del servicio
final orderService = OrderService();

// Funciones de conveniencia para mantener compatibilidad con código existente
List<Order> get orders => orderService.orders;

List<Order> getOrdersByStatus(OrderStatus status) =>
    orderService.getOrdersByStatus(status);

Map<OrderStatus, int> getOrderStatusCounts() =>
    orderService.getOrderStatistics();

List<Order> getSortedOrders({bool ascending = true}) =>
    orderService.getOrdersSortedByDate(ascending: ascending);
