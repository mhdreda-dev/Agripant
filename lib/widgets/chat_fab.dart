// Fichier: lib/widgets/chat_fab.dart

import 'package:agriplant/models/quick_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class ChatFAB extends StatelessWidget {
  const ChatFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showChatOptions(context),
      backgroundColor: Theme.of(context).primaryColor,
      tooltip: 'Assistant IA agricole',
      child: const Icon(
        IconlyBold.chat,
        color: Colors.white,
      ),
    );
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          // Hauteur ajustable pour montrer une partie significative de l'écran
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Icon(
                          IconlyBold.chat,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Assistant IA Agricole',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Questions fréquentes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildCategoryQuestions(context),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/chat');
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(IconlyBold.chat),
                    label: const Text(
                      'Ouvrir la conversation',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryQuestions(BuildContext context) {
    // Obtenir les catégories uniques
    final categories = quickQuestions.map((q) => q.category).toSet().toList();

    // Icônes pour chaque catégorie
    final categoryIcons = {
      'culture': IconlyBold.document,
      'produits': IconlyBold.bag,
      'services': IconlyBold.work,
      'commande': IconlyBold.buy,
      'general': IconlyBold.infoSquare,
    };

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryQuestions =
            quickQuestions.where((q) => q.category == category).toList();

        // Traduction des catégories en français
        String categoryTitle;
        switch (category) {
          case 'culture':
            categoryTitle = 'Culture et Jardinage';
            break;
          case 'produits':
            categoryTitle = 'Produits et Équipements';
            break;
          case 'services':
            categoryTitle = 'Services et Conseils';
            break;
          case 'commande':
            categoryTitle = 'Commandes et Livraisons';
            break;
          case 'general':
            categoryTitle = 'Questions Générales';
            break;
          default:
            categoryTitle =
                category.substring(0, 1).toUpperCase() + category.substring(1);
        }

        return ExpansionTile(
          leading: Icon(
            categoryIcons[category] ?? IconlyBold.document,
            color: Theme.of(context).primaryColor,
          ),
          title: Text(
            categoryTitle,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          initiallyExpanded:
              index == 0, // La première catégorie est développée par défaut
          children: categoryQuestions.map((question) {
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 56, right: 16),
              title: Text(question.question),
              onTap: () {
                // Ferme la modal et ouvre le chat avec la question préremplie
                Navigator.pop(context);
                _navigateToChatWithQuestion(context, question.question);
              },
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _navigateToChatWithQuestion(BuildContext context, String question) {
    // Navigue vers la page de chat et passe la question préremplie
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'initialQuestion': question},
    );
  }
}
