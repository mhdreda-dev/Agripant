import 'dart:convert';
import 'dart:math';

import 'package:agriplant/models/chat_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  static const String _messagesKey = 'chat_messages';
  static const int _maxMessages =
      1000; // Limite pour éviter une mémoire excessive

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  bool _isTyping = false;
  bool get isTyping => _isTyping;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final List<String> _typingIndicators = [
    "L'assistant réfléchit...",
    "Préparation de la réponse...",
    "Analyse en cours...",
    "Recherche d'informations...",
    "Traitement de votre demande...",
  ];

  // Cache pour les réponses intelligentes
  final Map<String, List<String>> _responseCache = {};

  // Patterns de reconnaissance améliorés
  final Map<RegExp, List<String>> _responsePatterns = {
    RegExp(r'\b(bonjour|salut|hello|bonsoir|coucou|hi)\b',
        caseSensitive: false): [
      "Bonjour ! Comment puis-je vous aider aujourd'hui ? 🌱",
      "Salut 👋 Prêt à cultiver de nouvelles idées ?",
      "Bonsoir ! Que puis-je faire pour votre jardin ce soir ?",
    ],
    RegExp(r'\b(merci|thanks|parfait|génial|super|excellent)\b',
        caseSensitive: false): [
      "Avec plaisir 😊 ! N'hésitez pas si vous avez d'autres questions.",
      "Toujours là pour vous aider dans vos projets agricoles !",
      "Content de pouvoir vous aider ! 🌿",
    ],
    RegExp(r'\b(planter|cultiver|semer|légume|potager|jardin)\b',
        caseSensitive: false): [
      "Quel légume souhaitez-vous planter ? Je peux vous conseiller selon la saison 🌱",
      "Un bon potager commence avec un bon sol. Avez-vous testé votre terre ?",
      "Excellent choix ! Quelle est la taille de votre espace de culture ?",
    ],
    RegExp(r'\b(malade|problème|insecte|parasite|traitement)\b',
        caseSensitive: false): [
      "Décrivez-moi les symptômes que vous observez sur vos plantes 🔍",
      "Avez-vous des photos du problème ? Cela m'aiderait à mieux vous conseiller.",
      "Quel type de plante est affecté ? Et depuis quand observez-vous ce problème ?",
    ],
    RegExp(r'\b(arroser|arrosage|eau|irrigation)\b', caseSensitive: false): [
      "L'arrosage dépend du type de plante et de la saison. De quoi parlez-vous ? 💧",
      "Trop ou pas assez d'eau ? C'est l'équilibre à trouver ! Parlez-moi de vos plantes.",
      "Un bon drainage est essentiel. Comment arrosez-vous actuellement ?",
    ],
    RegExp(r'\b(saison|quand|période|moment)\b', caseSensitive: false): [
      "La période de plantation varie selon les espèces. Que voulez-vous cultiver ? 📅",
      "Nous sommes en quelle saison chez vous ? Cela influence mes conseils !",
      "Chaque plante a son calendrier optimal. Précisez votre projet 🗓️",
    ],
  };

  ChatProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    _setLoading(true);
    try {
      await _loadMessages();
    } catch (e) {
      _setError('Erreur lors de l\'initialisation: $e');
      debugPrint('Erreur initialisation ChatProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void clearError() {
    _setError(null);
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString(_messagesKey);

      if (messagesJson != null && messagesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messages = decoded
            .map((item) => ChatMessage.fromJson(item))
            .where((msg) => msg.text.isNotEmpty) // Filtre les messages vides
            .toList();

        // Limite le nombre de messages chargés
        if (_messages.length > _maxMessages) {
          _messages = _messages.sublist(_messages.length - _maxMessages);
          await _saveMessages(); // Sauvegarde la liste tronquée
        }
      } else {
        await _initializeWelcomeMessage();
      }
    } catch (e) {
      debugPrint('Erreur lors du chargement des messages: $e');
      await _initializeWelcomeMessage();
    }
    notifyListeners();
  }

  Future<void> _initializeWelcomeMessage() async {
    final welcomeMessages = [
      'Bonjour ! Je suis votre assistant agricole. Comment puis-je vous aider aujourd\'hui ? 🌱',
      'Salut ! Prêt à faire pousser vos connaissances en agriculture ? 🌿',
      'Bienvenue ! Que souhaitez-vous cultiver ou découvrir aujourd\'hui ? 🚜',
      'Hello ! Votre expert jardin est là pour vous accompagner ! 🌻',
    ];

    final welcomeMessage =
        welcomeMessages[Random().nextInt(welcomeMessages.length)];

    _messages = [
      ChatMessage(
        text: welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
    await _saveMessages();
  }

  Future<bool> addMessage(ChatMessage message) async {
    if (message.text.trim().isEmpty) return false;

    try {
      _messages.add(message);

      // Maintient la limite de messages
      if (_messages.length > _maxMessages) {
        _messages.removeAt(0);
      }

      await _saveMessages();

      // Sauvegarde asynchrone dans Firestore (non bloquante)
      _saveToFirestoreAsync(message);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'ajout du message: $e');
      debugPrint('Erreur addMessage: $e');
      return false;
    }
  }

  Future<bool> addUserMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return false;

    final userMessage = ChatMessage(
      text: trimmedText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final success = await addMessage(userMessage);
    if (success) {
      // Génère la réponse de manière asynchrone
      _generateResponseAsync(trimmedText);
    }
    return success;
  }

  Future<void> _generateResponseAsync(String userMessage) async {
    try {
      _setTyping(true);

      // Simule un délai de réflexion plus réaliste
      final delay = Duration(milliseconds: 800 + Random().nextInt(1200));
      await Future.delayed(delay);

      if (!_isTyping) return; // Annulé pendant l'attente

      final response = await _generateIntelligentResponse(userMessage);

      if (!_isTyping) return; // Annulé pendant la génération

      final assistantMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      await addMessage(assistantMessage);
    } catch (e) {
      _setError('Erreur lors de la génération de réponse: $e');
      debugPrint('Erreur _generateResponseAsync: $e');
    } finally {
      _setTyping(false);
    }
  }

  void _setTyping(bool typing) {
    if (_isTyping != typing) {
      _isTyping = typing;
      notifyListeners();
    }
  }

  String get typingIndicator {
    return _typingIndicators[Random().nextInt(_typingIndicators.length)];
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = jsonEncode(
        _messages.map((m) => m.toJson()).toList(),
      );
      await prefs.setString(_messagesKey, messagesJson);
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde des messages: $e');
      _setError('Erreur de sauvegarde locale');
    }
  }

  // Sauvegarde asynchrone dans Firestore pour ne pas bloquer l'UI
  void _saveToFirestoreAsync(ChatMessage message) {
    _sendMessageToFirestore(message.text, message.isUser).catchError((e) {
      debugPrint('Erreur Firestore: $e');
      // On ne bloque pas l'UI pour les erreurs Firestore
    });
  }

  Future<void> _sendMessageToFirestore(String text, bool isUser) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(user.uid)
        .collection('messages')
        .add({
      'text': text,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (isUser) {
      await _updateContactInfo(text);
    }
  }

  Future<void> _updateContactInfo(String lastMessage) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('contacts').doc(user.uid).set({
      'userId': user.uid,
      'username': user.displayName ?? 'Utilisateur',
      'lastMessage': lastMessage.length > 100
          ? '${lastMessage.substring(0, 100)}...'
          : lastMessage,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> _generateIntelligentResponse(String userMessage) async {
    final normalizedMsg = userMessage.toLowerCase().trim();

    // Vérifie le cache
    if (_responseCache.containsKey(normalizedMsg)) {
      final cachedResponses = _responseCache[normalizedMsg]!;
      return cachedResponses[Random().nextInt(cachedResponses.length)];
    }

    final responses = _getContextualResponses(normalizedMsg);

    if (responses.isNotEmpty) {
      // Met en cache pour les futures utilisations
      _responseCache[normalizedMsg] = responses;
      return responses[Random().nextInt(responses.length)];
    }

    return _getDefaultResponse();
  }

  List<String> _getContextualResponses(String msg) {
    final responses = <String>[];

    // Utilise les patterns définis
    for (final entry in _responsePatterns.entries) {
      if (entry.key.hasMatch(msg)) {
        responses.addAll(entry.value);
      }
    }

    // Réponses spécifiques combinées
    if (msg.contains('bio') || msg.contains('organique')) {
      responses.addAll([
        "L'agriculture biologique est excellente ! Évitez les pesticides chimiques 🌿",
        "Pour du bio, privilégiez les engrais naturels et la rotation des cultures.",
      ]);
    }

    if (msg.contains('débutant') || msg.contains('commencer')) {
      responses.addAll([
        "Parfait pour débuter ! Commencez avec des légumes faciles comme les radis ou la laitue 🥬",
        "Pour commencer, choisissez un petit espace bien exposé au soleil !",
      ]);
    }

    return responses;
  }

  String _getDefaultResponse() {
    final fallbackResponses = [
      "Pouvez-vous préciser votre question ? Je suis là pour vous aider dans votre jardin 🌾",
      "Très intéressant ! Parlez-moi un peu plus de votre projet agricole 🌿",
      "Je n'ai pas bien saisi. Reformulez votre question sur l'agriculture 🚜",
      "Hmm, pouvez-vous être plus spécifique ? Je connais bien le jardinage ! 🌻",
    ];
    return fallbackResponses[Random().nextInt(fallbackResponses.length)];
  }

  // Méthodes utilitaires améliorées
  Future<bool> clearMessages() async {
    try {
      _messages.clear();
      await _initializeWelcomeMessage();
      _responseCache.clear(); // Vide le cache
      clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression: $e');
      return false;
    }
  }

  Future<bool> deleteMessage(int index) async {
    if (index < 0 || index >= _messages.length) return false;

    try {
      _messages.removeAt(index);
      await _saveMessages();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de la suppression du message: $e');
      return false;
    }
  }

  List<ChatMessage> searchMessages(String query) {
    if (query.trim().isEmpty) return [];

    final normalizedQuery = query.toLowerCase();
    return _messages
        .where((m) => m.text.toLowerCase().contains(normalizedQuery))
        .toList();
  }

  // Getters utiles
  int get messageCount => _messages.length;

  ChatMessage? get lastMessage => _messages.isNotEmpty ? _messages.last : null;

  bool get hasUserMessages => _messages.any((m) => m.isUser);

  bool get hasMessages => _messages.isNotEmpty;

  // Statistiques
  int get userMessageCount => _messages.where((m) => m.isUser).length;

  int get assistantMessageCount => _messages.where((m) => !m.isUser).length;

  // Nettoyage des ressources
  @override
  void dispose() {
    _responseCache.clear();
    super.dispose();
  }

  // Méthode pour exporter les messages (utile pour backup)
  String exportMessages() {
    return jsonEncode(_messages.map((m) => m.toJson()).toList());
  }

  // Méthode pour importer des messages
  Future<bool> importMessages(String messagesJson) async {
    try {
      final List<dynamic> decoded = jsonDecode(messagesJson);
      final importedMessages =
          decoded.map((item) => ChatMessage.fromJson(item)).toList();

      _messages = importedMessages;
      await _saveMessages();
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'importation: $e');
      return false;
    }
  }
}
