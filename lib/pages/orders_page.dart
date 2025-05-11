import 'package:agriplant/data/orders.dart';
import 'package:agriplant/widgets/order_item.dart';
import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const List<String> tabs = [
    "Processing",
    "Shipping",
    "Delivered",
    "Cancelled"
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Orders"),
          bottom: TabBar(
            physics: const BouncingScrollPhysics(),
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.label,
            tabs: buildTabs(context), // Passage du context en paramètre
          ),
        ),
        body: TabBarView(
          children: buildTabViews(),
        ),
      ),
    );
  }

  List<Widget> buildTabs(BuildContext context) {
    // Ajout du paramètre context
    return tabs.map((tab) {
      // Count orders in each status category (in real app, filter orders by status)
      final int count = tab == "Processing"
          ? 3
          : tab == "Shipping"
              ? 2
              : tab == "Delivered"
                  ? 5
                  : 0;

      return Tab(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tab),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> buildTabViews() {
    return tabs.map((tab) {
      // Filter orders based on tab (simulated here)
      final filteredOrders = orders.where((order) {
        if (tab == "Processing") {
          return order.date.year >= 2023;
        } else if (tab == "Shipping") {
          return order.date.year == 2022;
        } else if (tab == "Delivered") {
          return order.date.year < 2022;
        } else {
          return false; // No cancelled orders in this example
        }
      }).toList();

      return Builder(builder: (context) {
        // Utilisation de Builder pour accéder au context
        return filteredOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_rounded,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No orders in $tab",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  return OrderItem(order: filteredOrders[index]);
                },
              );
      });
    }).toList();
  }
}
