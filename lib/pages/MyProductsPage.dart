import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Produits'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('produits')
            .where('uid', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final produits = snapshot.data!.docs;

          if (produits.isEmpty) {
            return const Center(child: Text("Aucun produit trouvé."));
          }

          return ListView.builder(
            itemCount: produits.length,
            itemBuilder: (context, index) {
              final doc = produits[index];
              final produit = doc.data() as Map<String, dynamic>;
              final nom = produit['nom'] ?? 'Sans nom';
              final categorie = produit['categorie'] ?? 'Sans catégorie';
              final prix = produit['prix']?.toString() ?? '0';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.eco, color: Colors.green),
                  title: Text(nom),
                  subtitle: Text("Catégorie : $categorie"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("$prix DH",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Supprimer le produit"),
                              content: Text(
                                  "Es-tu sûr de vouloir supprimer « $nom » ?"),
                              actions: [
                                TextButton(
                                  child: const Text("Annuler"),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                ),
                                TextButton(
                                  child: const Text("Supprimer"),
                                  onPressed: () => Navigator.pop(context, true),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await doc.reference.delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Produit supprimé.")),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
