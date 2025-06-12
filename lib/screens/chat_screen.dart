import 'package:agriplant/provider/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _hasSentInitialQuestion = false;
  bool _isComposing = false;
  bool _showScrollToBottom = false;
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // Suggestions prédéfinies
  final List<String> _quickSuggestions = [
    "Comment planter des tomates ? 🍅",
    "Quand arroser mes légumes ? 💧",
    "Problème de parasites 🐛",
    "Conseils pour débutant 🌱",
    "Agriculture biologique 🌿",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _setupAnimations();
    _setupScrollListener();
    _controller.addListener(_onTextChanged);
  }

  void _setupAnimations() {
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100;

      if (_showScrollToBottom == isAtBottom) {
        setState(() {
          _showScrollToBottom = !isAtBottom;
        });
      }
    });
  }

  void _onTextChanged() {
    final isComposing = _controller.text.trim().isNotEmpty;
    if (_isComposing != isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Remet le focus quand l'app reprend
      _focusNode.requestFocus();
    }
  }

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollController.hasClients) return;

    if (animated) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  void _handleInitialQuestion(
      String? initialQuestion, ChatProvider chatProvider) {
    if (!_hasSentInitialQuestion &&
        initialQuestion != null &&
        initialQuestion.isNotEmpty) {
      _hasSentInitialQuestion = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await chatProvider.addUserMessage(initialQuestion);
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final chatProvider = Provider.of<ChatProvider>(context);

    // Gestion de la question initiale
    final args = ModalRoute.of(context)?.settings.arguments;
    final initialQuestion = (args is Map && args['initialQuestion'] is String)
        ? args['initialQuestion'] as String
        : null;

    _handleInitialQuestion(initialQuestion, chatProvider);

    if (user == null) {
      return _buildNotAuthenticatedScreen();
    }

    return Scaffold(
      appBar: _buildAppBar(context, chatProvider),
      body: Column(
        children: [
          // Indicateur d'erreur
          if (chatProvider.error != null) _buildErrorBanner(chatProvider),

          // Zone de chat
          Expanded(child: _buildChatArea(user, chatProvider)),

          // Indicateur de frappe
          _buildTypingIndicator(chatProvider),

          // Suggestions rapides
          if (chatProvider.messages.length <= 1)
            _buildQuickSuggestions(chatProvider),

          // Barre de saisie
          _buildInputSection(context, chatProvider),
        ],
      ),
      floatingActionButton:
          _showScrollToBottom ? _buildScrollToBottomButton() : null,
    );
  }

  Widget _buildNotAuthenticatedScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant IA Agricole'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              "Vous devez être connecté",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            Text(
              "Connectez-vous pour accéder à l'assistant",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, ChatProvider chatProvider) {
    return AppBar(
      title: const Text('Assistant IA Agricole'),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      actions: [
        // Statistiques de conversation
        if (chatProvider.hasMessages)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                '${chatProvider.messageCount}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        // Menu d'options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleMenuAction(value, chatProvider),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'clear',
              child: ListTile(
                leading: Icon(Icons.clear_all),
                title: Text('Effacer la conversation'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'export',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Exporter'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorBanner(ChatProvider chatProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.red.shade100,
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              chatProvider.error!,
              style: TextStyle(color: Colors.red.shade700, fontSize: 14),
            ),
          ),
          TextButton(
            onPressed: chatProvider.clearError,
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(User user, ChatProvider chatProvider) {
    if (chatProvider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Chargement de la conversation...'),
          ],
        ),
      );
    }

    // Utilise les messages du provider local en priorité
    if (chatProvider.hasMessages) {
      return _buildLocalMessagesList(chatProvider);
    }

    // Fallback sur Firestore si pas de messages locaux
    return _buildFirestoreMessagesList(user);
  }

  Widget _buildLocalMessagesList(ChatProvider chatProvider) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: chatProvider.messages.length,
      itemBuilder: (context, index) {
        final message = chatProvider.messages[index];
        return _buildMessageBubble(
          text: message.text,
          isUser: message.isUser,
          timestamp: message.timestamp,
          index: index,
        );
      },
    );
  }

  Widget _buildFirestoreMessagesList(User user) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(user.uid)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState("Erreur de chargement des messages");
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        // Auto-scroll quand de nouveaux messages arrivent
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        if (docs.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(
              text: data['text'] ?? '',
              isUser: data['isUser'] ?? false,
              timestamp:
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
              index: index,
            );
          },
        );
      },
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isUser,
    required DateTime timestamp,
    required int index,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          elevation: 1,
          color: isUser ? Theme.of(context).primaryColor : Colors.grey.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                SelectableText(
                  text,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('HH:mm').format(timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: isUser ? Colors.white70 : Colors.black45,
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.done_all,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(ChatProvider chatProvider) {
    if (!chatProvider.isTyping) return const SizedBox.shrink();

    _typingAnimationController.repeat();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _typingAnimation,
                  builder: (context, child) {
                    return Row(
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade600.withOpacity(
                              (0.4 +
                                      0.6 *
                                          (_typingAnimation.value +
                                              index * 0.2) %
                                          1.0)
                                  .clamp(0.0, 1.0),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  chatProvider.typingIndicator,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions(ChatProvider chatProvider) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ActionChip(
              label: Text(
                _quickSuggestions[index],
                style: const TextStyle(fontSize: 13),
              ),
              onPressed: () =>
                  _sendQuickMessage(_quickSuggestions[index], chatProvider),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
              side: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.3)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, ChatProvider chatProvider) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, -1),
              blurRadius: 4,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Posez votre question agricole...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(chatProvider),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                icon: Icon(
                  _isComposing ? IconlyBold.send : IconlyLight.send,
                  color: _isComposing
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
                onPressed:
                    _isComposing ? () => _sendMessage(chatProvider) : null,
                style: IconButton.styleFrom(
                  backgroundColor: _isComposing
                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return FloatingActionButton.small(
      onPressed: () => _scrollToBottom(),
      backgroundColor: Theme.of(context).primaryColor,
      foregroundColor: Colors.white,
      child: const Icon(Icons.keyboard_arrow_down),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Commencez une conversation !',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Posez vos questions sur l\'agriculture',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(ChatProvider chatProvider) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Feedback haptique
    HapticFeedback.lightImpact();

    _controller.clear();
    setState(() {
      _isComposing = false;
    });

    // Maintient le focus
    _focusNode.requestFocus();

    try {
      await chatProvider.addUserMessage(text);
      _scrollToBottom();
    } catch (e) {
      // Gestion d'erreur avec snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendQuickMessage(
      String message, ChatProvider chatProvider) async {
    // Supprime les emojis pour le message
    final cleanMessage = message.replaceAll(RegExp(r'[^\w\s\?]'), '').trim();

    _controller.text = cleanMessage;
    setState(() {
      _isComposing = true;
    });

    await _sendMessage(chatProvider);
  }

  void _handleMenuAction(String action, ChatProvider chatProvider) async {
    switch (action) {
      case 'clear':
        await _showClearConfirmationDialog(chatProvider);
        break;
      case 'export':
        await _exportConversation(chatProvider);
        break;
    }
  }

  Future<void> _showClearConfirmationDialog(ChatProvider chatProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer la conversation'),
        content:
            const Text('Êtes-vous sûr de vouloir effacer tous les messages ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await chatProvider.clearMessages();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conversation effacée')),
        );
      }
    }
  }

  Future<void> _exportConversation(ChatProvider chatProvider) async {
    try {
      final exported = chatProvider.exportMessages();
      await Clipboard.setData(ClipboardData(text: exported));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conversation copiée dans le presse-papiers'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'export: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
