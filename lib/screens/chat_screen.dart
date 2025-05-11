// Fichier: lib/screens/chat_screen.dart

import 'package:agriplant/models/chat_message.dart';
import 'package:agriplant/models/quick_questions.dart';
import 'package:agriplant/provider/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();

    // Léger délai pour permettre au widget de se construire avant de vérifier les arguments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (arguments != null && arguments.containsKey('initialQuestion')) {
        final initialQuestion = arguments['initialQuestion'] as String;
        _textController.text = initialQuestion;
        setState(() {
          _isComposing = initialQuestion.isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    _textController.clear();
    setState(() {
      _isComposing = false;
    });

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.addMessage(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    // Faites défiler jusqu'au bas après l'envoi
    _scrollToBottom();

    // Simuler une réponse (dans une application réelle, ce serait un appel API)
    _simulateResponse(text);
  }

  void _simulateResponse(String userMessage) {
    // Simule un délai de réponse
    Future.delayed(const Duration(seconds: 1), () {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);

      // Génère une réponse basée sur la question de l'utilisateur
      String response = _generateResponse(userMessage);

      chatProvider.addMessage(
        ChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );

      // Fait défiler jusqu'au bas après la réponse
      _scrollToBottom();
    });
  }

  String _generateResponse(String userMessage) {
    // Cette fonction pourrait être remplacée par un vrai appel API
    // Pour l'instant, elle génère des réponses simples basées sur des mots-clés

    userMessage = userMessage.toLowerCase();

    if (userMessage.contains('bonjour') || userMessage.contains('salut')) {
      return 'Bonjour ! Comment puis-je vous aider avec votre jardin aujourd\'hui ?';
    } else if (userMessage.contains('merci')) {
      return 'Avec plaisir ! N\'hésitez pas si vous avez d\'autres questions.';
    } else if (userMessage.contains('planter') ||
        userMessage.contains('légumes')) {
      return 'Pour la plantation de légumes, il est important de considérer la saison actuelle et votre zone climatique. En général, le printemps est idéal pour la plupart des légumes. Voulez-vous des conseils sur des légumes spécifiques ?';
    } else if (userMessage.contains('pucerons') ||
        userMessage.contains('parasites')) {
      return 'Pour traiter les pucerons naturellement, vous pouvez utiliser une solution d\'eau savonneuse, du purin d\'ortie, ou introduire des coccinelles dans votre jardin. Certaines plantes comme la lavande ou la menthe peuvent aussi aider à les repousser.';
    } else if (userMessage.contains('arroser') ||
        userMessage.contains('irrigation')) {
      return 'L\'arrosage est préférable tôt le matin ou en fin de journée pour éviter l\'évaporation. Pour les tomates, un arrosage régulier à la base de la plante est recommandé. Évitez de mouiller les feuilles pour prévenir les maladies fongiques.';
    } else if (userMessage.contains('commander')) {
      return 'Vous pouvez passer votre commande directement depuis notre page "Explorer" ou "Panier". Si vous avez des questions spécifiques sur une commande en cours, n\'hésitez pas à nous fournir son numéro.';
    } else if (userMessage.contains('livraison')) {
      return 'Nos délais de livraison sont généralement de 2-3 jours ouvrables pour les semences et petits équipements, et 3-5 jours pour les équipements plus volumineux. Vous recevrez un email de confirmation avec votre numéro de suivi.';
    } else if (userMessage.contains('premium')) {
      return 'Notre abonnement Premium offre plusieurs avantages : livraison gratuite, accès prioritaire aux nouveaux produits, remises exclusives, et conseils personnalisés avec nos agronomes. Vous pouvez vous abonner depuis la page Profil.';
    } else {
      return 'Merci pour votre question ! Je vais vous aider avec ça. Pourriez-vous me donner plus de détails pour que je puisse vous fournir les informations les plus précises ?';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA Agricole'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.infoSquare),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildWelcomeMessage()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessage(message);
                    },
                  ),
          ),
          _buildSuggestedQuestions(),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                IconlyBold.chat,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bienvenue dans l\'Assistant IA Agricole',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Posez vos questions sur le jardinage, les cultures, nos produits ou services, et obtenez une réponse instantanée.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exemples de questions:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildExampleQuestion(
                  'Comment cultiver des tomates bio ?',
                  IconlyBold.document,
                ),
                _buildExampleQuestion(
                  'Quels outils pour débuter un potager ?',
                  IconlyBold.bag,
                ),
                _buildExampleQuestion(
                  'Comment suivre ma commande ?',
                  IconlyBold.buy,
                ),
                _buildExampleQuestion(
                  'Quels sont les avantages Premium ?',
                  IconlyBold.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleQuestion(String question, IconData icon) {
    return InkWell(
      onTap: () {
        _textController.text = question;
        setState(() {
          _isComposing = true;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              radius: 16,
              child: const Icon(
                IconlyBold.chat,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color:
                    isUser ? Theme.of(context).primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: isUser
                          ? Colors.white.withOpacity(0.7)
                          : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 16,
              child: const Icon(
                IconlyBold.profile,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final chatProvider = Provider.of<ChatProvider>(context);

    // Ne montre les suggestions que si l'utilisateur a déjà envoyé au moins un message
    if (chatProvider.messages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sélectionne 3 questions aléatoires parmi les questions prédéfinies
    final random = quickQuestions..shuffle();
    final suggestedQuestions = random.take(3).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Questions suggérées:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            children: suggestedQuestions.map((question) {
              return ActionChip(
                label: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.grey[300]!),
                onPressed: () {
                  _textController.text = question.question;
                  setState(() {
                    _isComposing = true;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              IconlyLight.image,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              // Fonctionnalité pour ajouter une image (à implémenter)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fonctionnalité à venir'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              onChanged: (text) {
                setState(() {
                  _isComposing = text.trim().isNotEmpty;
                });
              },
              onSubmitted: _isComposing ? _handleSubmitted : null,
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),
          IconButton(
            icon: Icon(
              IconlyBold.send,
              color: _isComposing
                  ? Theme.of(context).primaryColor
                  : Colors.grey[400],
            ),
            onPressed: _isComposing
                ? () => _handleSubmitted(_textController.text)
                : null,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('À propos de l\'Assistant IA'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cet assistant est conçu pour vous aider avec toutes vos questions sur:',
                ),
                SizedBox(height: 10),
                Text('• Le jardinage et la culture'),
                Text('• Les produits et équipements'),
                Text('• Les services et conseils'),
                Text('• Les commandes et livraisons'),
                Text('• Et bien plus encore!'),
                SizedBox(height: 10),
                Text(
                  'L\'assistant utilise des réponses préprogrammées pour l\'instant, mais sera bientôt amélioré avec des capacités d\'IA plus avancées.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
