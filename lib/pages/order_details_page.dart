import 'package:agriplant/data/orders.dart';
import 'package:agriplant/models/order.dart';
import 'package:agriplant/utils/extensions/date.dart';
import 'package:agriplant/widgets/order_item.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({
    Key? key,
    required this.order,
  }) : super(key: key);

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orderTimelines = ['Traitement', 'Préparation', 'Expédition', 'Livré'];
    final activeStep =
        order.status == OrderStatus.cancelled ? 0 : order.status.index;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de la commande"),
        actions: [
          if (order.canBeCancelled)
            IconButton(
              icon: const Icon(IconlyLight.closeSquare),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Annuler la commande'),
                    content: const Text(
                        'Êtes-vous sûr de vouloir annuler cette commande ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Non'),
                      ),
                      TextButton(
                        onPressed: () {
                          // Logique pour annuler la commande (par exemple, mettre à jour orders)
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Commande annulée')),
                          );
                        },
                        child: const Text('Oui'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: order.items.isEmpty
          ? const Center(
              child: Text(
                'Aucun article dans cette commande',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EasyStepper(
                  activeStep: activeStep,
                  lineLength: 70,
                  lineSpace: 0,
                  defaultLineColor: Colors.grey.shade300,
                  finishedLineColor: theme.colorScheme.primary,
                  activeStepTextColor: Colors.black87,
                  finishedStepTextColor: Colors.black87,
                  internalPadding: 0,
                  showLoadingAnimation: true,
                  stepRadius: 8,
                  lineThickness: 1.5,
                  steps: List.generate(orderTimelines.length, (index) {
                    return EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: activeStep >= index
                            ? theme.colorScheme.primary.withOpacity(0.5)
                            : Colors.grey.shade400,
                        child: CircleAvatar(
                          radius: 2.5,
                          backgroundColor: activeStep >= index
                              ? theme.colorScheme.primary
                              : Colors.grey.shade200,
                        ),
                      ),
                      title: orderTimelines[index],
                      topTitle: true,
                    );
                  }),
                  onStepReached: (index) {},
                ),
                const SizedBox(height: 20),
                Card(
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  elevation: 0.1,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Commande : ${order.id}",
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Chip(
                              shape: const StadiumBorder(),
                              side: BorderSide.none,
                              backgroundColor: theme
                                  .colorScheme.primaryContainer
                                  .withOpacity(0.4),
                              labelPadding: EdgeInsets.zero,
                              avatar: const Icon(Icons.fire_truck),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 10),
                              label: Text(
                                order.status.displayName,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Estimation de la livraison"),
                            Text(
                              order.date.deliveryDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          order.name,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(IconlyLight.home, size: 15),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                order.address,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(IconlyLight.call, size: 15),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                order.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Méthode de paiement"),
                            Text(
                              order.paymentMethod,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                OrderItem(order: order, visibleProducts: 1),
              ],
            ),
    );
  }
}
