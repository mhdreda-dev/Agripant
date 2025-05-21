import 'dart:convert';

import 'package:agriplant/models/chat_message.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => [..._messages];

  ChatProvider() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('chat_messages');

      if (messagesJson != null) {
        final List<dynamic> decoded = jsonDecode(messagesJson);
        _messages = decoded.map((item) => ChatMessage.fromJson(item)).toList();
        notifyListeners();
      } else {
        // Ajouter un message de bienvenue de l'assistant
        addMessage(
          ChatMessage(
            text:
                'Bonjour ! Je suis votre assistant agricole. Comment puis-je vous aider aujourd\'hui ?',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print('Erreur lors du chargement des messages: $e');
      // En cas d'erreur, initialiser avec un message de bienvenue
      _messages = [
        ChatMessage(
          text:
              'Bonjour ! Je suis votre assistant agricole. Comment puis-je vous aider aujourd\'hui ?',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
      notifyListeners();
    }
  }

  void addMessage(ChatMessage message) {
    _messages.add(message);
    _saveMessages();
    notifyListeners();
  }

  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson =
          jsonEncode(_messages.map((m) => m.toJson()).toList());
      await prefs.setString('chat_messages', messagesJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde des messages: $e');
    }
  }

  void clearMessages() {
    // Garder seulement le message de bienvenue
    _messages = [
      ChatMessage(
        text:
            'Bonjour ! Je suis votre assistant agricole. Comment puis-je vous aider aujourd\'hui ?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ];
    _saveMessages();
    notifyListeners();
  }

  void deleteMessage(int index) {
    if (index >= 0 && index < _messages.length) {
      _messages.removeAt(index);
      _saveMessages();
      notifyListeners();
    }
  }
}
