import 'package:agriplant/models/quick_questions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';

class ChatFAB extends StatelessWidget {
  const ChatFAB({super.key});

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _ChatOptionsBottomSheet(),
    );
  }
}

class _ChatOptionsBottomSheet extends StatelessWidget {
  const _ChatOptionsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildSectionTitle(context, 'Questions fréquentes'),
          const SizedBox(height: 10),
          Expanded(child: _buildCategoryQuestions(context)),
          _buildChatButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
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
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _navigateToChat(context),
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
    );
  }

  Widget _buildCategoryQuestions(BuildContext context) {
    // Gestion d'erreur si quickQuestions est null ou vide
    if (quickQuestions.isEmpty) {
      return const Center(
        child: Text(
          'Aucune question disponible pour le moment',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final categories = _getUniqueCategories();

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final categoryQuestions = _getQuestionsForCategory(category);

        return _CategoryExpansionTile(
          category: category,
          questions: categoryQuestions,
          isInitiallyExpanded: index == 0,
          onQuestionTap: (question) =>
              _navigateToChatWithQuestion(context, question),
        );
      },
    );
  }

  List<String> _getUniqueCategories() {
    return quickQuestions.map((q) => q.category).toSet().toList();
  }

  List<QuickQuestion> _getQuestionsForCategory(String category) {
    return quickQuestions.where((q) => q.category == category).toList();
  }

  void _navigateToChat(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(context, '/chat');
  }

  void _navigateToChatWithQuestion(BuildContext context, String question) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {'initialQuestion': question},
    );
  }
}

class _CategoryExpansionTile extends StatelessWidget {
  final String category;
  final List<QuickQuestion> questions;
  final bool isInitiallyExpanded;
  final Function(String) onQuestionTap;

  const _CategoryExpansionTile({
    required this.category,
    required this.questions,
    required this.isInitiallyExpanded,
    required this.onQuestionTap,
  });

  static const Map<String, IconData> _categoryIcons = {
    'culture': IconlyBold.document,
    'produits': IconlyBold.bag,
    'services': IconlyBold.work,
    'commande': IconlyBold.buy,
    'general': IconlyBold.infoSquare,
  };

  static const Map<String, String> _categoryTitles = {
    'culture': 'Culture et Jardinage',
    'produits': 'Produits et Équipements',
    'services': 'Services et Conseils',
    'commande': 'Commandes et Livraisons',
    'general': 'Questions Générales',
  };

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: Icon(
        _categoryIcons[category] ?? IconlyBold.document,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        _getCategoryTitle(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: isInitiallyExpanded,
      children:
          questions.map((question) => _buildQuestionTile(question)).toList(),
    );
  }

  String _getCategoryTitle() {
    return _categoryTitles[category] ??
        '${category.substring(0, 1).toUpperCase()}${category.substring(1)}';
  }

  Widget _buildQuestionTile(QuickQuestion question) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 56, right: 16),
      title: Text(
        question.question,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () => onQuestionTap(question.question),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
    );
  }
}
