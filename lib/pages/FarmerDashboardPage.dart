import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import this for locale initialization
import 'package:intl/intl.dart';

import 'AddProductPage.dart';

class FarmerDashboardPage extends StatefulWidget {
  const FarmerDashboardPage({super.key});

  @override
  State<FarmerDashboardPage> createState() => _FarmerDashboardPageState();
}

class _FarmerDashboardPageState extends State<FarmerDashboardPage> {
  // Données simulées pour démonstration
  final List<Map<String, dynamic>> _recentOrders = [
    {
      'id': '#1234',
      'customerName': 'Marie Dupont',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
      'amount': 45.50,
      'status': 'En attente'
    },
    {
      'id': '#1235',
      'customerName': 'Jean Martin',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'amount': 32.75,
      'status': 'Confirmée'
    },
    {
      'id': '#1236',
      'customerName': 'Sophie Laurent',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 78.20,
      'status': 'Expédiée'
    },
  ];

  final Map<String, double> _monthlyRevenue = {
    'Jan': 1200,
    'Fév': 1500,
    'Mar': 1800,
    'Avr': 2200,
    'Mai': 2700,
  };

  @override
  void initState() {
    super.initState();
    // Initialize date formatting for French locale
    initializeDateFormatting('fr_FR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord Agriculteur'),
        backgroundColor: Colors.green.shade700,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications à venir')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green.shade700,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.green),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Martin Agriculteur',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Ferme Bio du Soleil',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Tableau de bord'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: const Text('Mes Produits'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('Commandes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/my-orders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Rapports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/reports');
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Aide'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/help');
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Simuler le rafraîchissement des données
          await Future.delayed(const Duration(seconds: 1));
          setState(() {
            // Mise à jour des données si nécessaire
          });
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 20),
              _buildStatCards(),
              const SizedBox(height: 20),
              _buildSectionTitle('Commandes récentes'),
              _buildRecentOrders(),
              const SizedBox(height: 20),
              _buildSectionTitle('Revenus mensuels'),
              _buildRevenueChart(),
              const SizedBox(height: 20),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductPage(),
            ),
          );
        },
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE d MMMM', 'fr_FR');
    String greeting;

    if (now.hour < 12) {
      greeting = 'Bonjour';
    } else if (now.hour < 18) {
      greeting = 'Bon après-midi';
    } else {
      greeting = 'Bonsoir';
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, Martin!',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatter.format(now),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous avez 3 nouvelles commandes et 2 messages non lus.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          icon: Icons.shopping_cart,
          title: 'Commandes',
          value: '12',
          color: Colors.blue,
          subtitle: '+3 aujourd\'hui',
        ),
        _buildStatCard(
          icon: Icons.inventory,
          title: 'Produits',
          value: '28',
          color: Colors.orange,
          subtitle: '5 en rupture',
        ),
        _buildStatCard(
          icon: Icons.euro,
          title: 'Revenus',
          value: '854 €',
          color: Colors.green,
          subtitle: 'ce mois-ci',
        ),
        _buildStatCard(
          icon: Icons.star,
          title: 'Évaluations',
          value: '4.8/5',
          color: Colors.amber,
          subtitle: '36 avis',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required String subtitle,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentOrders.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final order = _recentOrders[index];
          final formatter = DateFormat('dd/MM HH:mm');

          return ListTile(
            title: Text(
              '${order['id']} - ${order['customerName']}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${formatter.format(order['date'])} - ${order['amount'].toStringAsFixed(2)} €',
            ),
            trailing: Chip(
              label: Text(
                order['status'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              backgroundColor: _getStatusColor(order['status']),
              padding: const EdgeInsets.all(0),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/order-details', arguments: order);
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En attente':
        return Colors.orange;
      case 'Confirmée':
        return Colors.blue;
      case 'Expédiée':
        return Colors.green;
      case 'Livrée':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: 9 400 €',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '+24% vs année précédente',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _monthlyRevenue.entries.map((entry) {
                    // Normaliser la hauteur par rapport à la valeur maximale
                    final maxValue = _monthlyRevenue.values
                        .reduce((max, value) => max > value ? max : value);
                    final barHeight = 140 * (entry.value / maxValue);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: Colors.green.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.key,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions rapides',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildActionButton(
                  icon: Icons.add_box,
                  label: 'Ajouter un produit',
                  onTap: () => Navigator.pushNamed(context, '/add-product'),
                ),
                _buildActionButton(
                  icon: Icons.local_shipping,
                  label: 'Gérer les livraisons',
                  onTap: () => Navigator.pushNamed(context, '/deliveries'),
                ),
                _buildActionButton(
                  icon: Icons.message,
                  label: 'Messages',
                  onTap: () => Navigator.pushNamed(context, '/messages'),
                ),
                _buildActionButton(
                  icon: Icons.calendar_today,
                  label: 'Calendrier',
                  onTap: () => Navigator.pushNamed(context, '/calendar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.green.shade100,
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
